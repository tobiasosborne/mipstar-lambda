# Verdict tb2-r1 — adversarial critic on rung TB2 (commit `4a3474c`)

Evaluated on an archived copy (`git archive 4a3474c | tar -x`) in
`/tmp/claude-1000/.../scratchpad/critic-tb2-r1/tb2/`, never in the live tree.
Machine: 12 cores; load average `0.71 / 1.96 / 2.86` when the cold run started;
a `codex` TB0-repair worker was resident throughout and pushed load to 4–5
during the mutation runs. Julia 1.12.5.

Files under review: `src/samplers/pcp_sampler.jl` (459 L), `src/samplers/oracularize.jl`
(210 L), `src/verifiers/answer_reduce.jl` (585 L), `test/tb2_answer_reduce.jl` (338 L),
`test/mutations/tb2_*.jl`, plus the additive edits to `src/MIPStarLambda.jl`,
`test/runtests.jl`, `test/mutations/run.jl`.

---

## O1 · FATAL · `test/mutations/run.jl` never executes a single TB2 mutant

**Location** `test/mutations/run.jl:100-110` (top-level `@testset` for TB1 aborts the
script before line 107), caused by `src/samplers/pcp_sampler.jl:295-297,431` and
`src/samplers/oracularize.jl:136-139,201` (module-level `const` initialisers), and
mis-scored by the kill predicate at `test/mutations/run.jl:83-85`.

**Independent computation.** I ran the documented command verbatim:

```
MUTANT A e-2_to_e-1                      => KILLED (exit=1)      … 7/7 TB0 KILLED
TB0 targeted mutations |    7      7  17m51.6s
MUTANT TB1 M-χ shift_bucket_boundary     => KILLED (exit=1)
MUTANT TB1 M-π omit_prefix_projection    => KILLED (exit=1)
MUTANT TB1 M-lnf noncanonical_complement => KILLED (exit=1)
MUTANT TB1 M-deg axis_accepts_md         => KILLED (exit=1)
MUTANT TB1 M-level omit_inductive_increment target=tb1_levels => SURVIVED (exit=1)
TB1 targeted mutations | Pass 4  Fail 1  Total 5  15m57.9s
ERROR: LoadError: Some tests did not pass: 4 passed, 1 failed …  run.jl:100
MUTWALL 2032.06 s ; exit=1
```

There is **no `MUTANT TB2 …` line anywhere in the output**: the top-level TB1
`@testset` throws at `finish()`, so the `TB2 targeted mutations` block at
`run.jl:107` is never reached. The rung's entire red-capability evidence is
unreachable from the documented entry point.

Root cause, traced: `tb1_level.jl` rewrites `level(::CLStep) = 1 + level(child)` to
`level(::CLStep) = level(child)`, which makes `pad_level`'s `while level(result) <
target` loop forever (`src/samplers/typed.jl:6-13`). TB2 moved the whole product
construction into `const` values evaluated at **precompile** time, so the mutant now
dies as `StackOverflowError … level(L::CLStep) (repeats 22617 times) → pad_level →
marginal_k @ oracularize.jl:76 → _compute_tb2_sampler_invariant_report`, i.e.
`Failed to precompile MIPStarLambda`. The output then contains neither `"Test Failed"`
nor `"Some tests did not pass"`, so `copied_mutant` scores it **SURVIVED**.

This is a **regression introduced by TB2**. At the parent commit `08021a2` I ran
`MUTATION_FILTER="M-level"`:

```
MUTANT TB1 M-level omit_inductive_increment target=tb1_levels => KILLED (exit=1)
PARENTWALL 80.40 s ; exit=0
```

**FIX DEMAND** Make `_TB2_PCP_SAMPLER` / `_TB2_SAMPLER_PRODUCT` / the two report
`const`s lazily memoised (`Ref` + `get!`) so a mutated `level` cannot crash
precompilation; score a mutant whose test process fails to load as KILLED-BY-CRASH
(never SURVIVED); and run each rung's mutant block so it cannot abort later blocks.

**SURVIVING WEAKER STATEMENT** Run one rung at a time, the TB2 mutants do die.
Running the TB2 block alone, all five do die:

```
MUTANT TB2 c0_plus_one_formula target=tb2_formula                  => KILLED (exit=1)
MUTANT TB2 g3_plus_one_individual_only target=tb2_proof_consistency => KILLED (exit=1)
MUTANT TB2 truncate_line_polynomial target=tb2_line                => KILLED (exit=1)
MUTANT TB2 M-guard Point_ALine_to_Point_DLine target=tb2_guard     => KILLED (exit=1)
MUTANT TB2 M-i345 extend_to_i12 target=tb2_i345 => KILLED (exit=1)   I345WALL 112.16 s ; exit=0
```

TB0 is 7/7; TB1 is 4/5 at this commit.

---

## O2 · MAJOR · a cold `julia --project=. test/runtests.jl` FAILS and exits 1

**Location** `test/runtests.jl:3-16` (`started = time()` precedes the `using
MIPStarLambda` inside `tb0_core.jl`, so `Pkg` precompilation is inside the timed
region).

**Independent computation.** Cold (empty precompile cache for this tree, quiet box):

```
Precompiling packages...   92936.6 ms  ✓ MIPStarLambda (serial)
┌ Warning: TB0 suite exceeded its 45 s warning │ measured_seconds = 146.086
Test Summary: MIPStarLambda | 187  187  2m25.7s
TB0 total wall seconds = 146.086 (warning=45.0, hard_limit=60.0)
TB0 60 s hard limit (measured 146.086 s) | Fail 1 1
ERROR: LoadError: Some tests did not pass: 0 passed, 1 failed
Elapsed (wall clock) 2:29.39 ; Maximum RSS 1,790,016 KiB ; Exit status: 1
```

Warm, immediately after:

```
Test Summary: MIPStarLambda | 187  187  53.1s
TB0 total wall seconds = 53.551 (warning=45.0, hard_limit=60.0)
TB0 60 s hard limit (measured 53.551 s) | Pass 1 1
WALL 54.46 s  CPU 100%  RSS 742,552 KiB ; exit 0
```

`CLAUDE.md` requires this command to exit 0. It does not on a fresh checkout, nor
after any edit that invalidates the cache — which is precisely the state a repair
worker leaves the tree in. The proposer's "cold 55.71 s" is a cold *process* with a
warm depot, not a cold checkout; the report does not say so.

**FIX DEMAND** Start the timer after the package is loaded (or precompile as a
separate documented step) so the 45/60 s gate measures test work, not `Pkg`.

**SURVIVING WEAKER STATEMENT** On a warm depot the suite is 187/187, 53.55 s, exit 0
— but with only 6.4 s of headroom and the 45 s warning already tripped, and TB2 is
what pushed it past that warning.

---

## O3 · MAJOR · step 5's game check is provably independent of `x_alice`/`x_bob`

**Location** `src/verifiers/answer_reduce.jl:317`
`pcpverifier(call::PCPGameCall, view::PCPView) = pcpverifier(call.formula, view)`,
consuming the values computed at `:504-512`.

**Independent computation.** `fig:pcpverifier` (gt-10:1557-1580) begins
`C = PaddedSuccinctDecider(D, n, T, Q, σ, x, y)` and only then Tseitin-encodes and
arithmetises it; the formula test at item 4 is on that `x,y`-dependent
`F_arith`. The implementation supplies a formula fixed at construction time
(`TrivialOriginalVerifier.formula`, the TB0 six-gate `tf`), i.e. **steps 1–2 of
`fig:pcpverifier` are absent** and the two computed questions are inert. I
confirmed empirically with a new mutant (MC6): replacing
`x_alice = apply(sampler.left, …)` by `apply(sampler.right, …)` leaves **every
accept/reject decision unchanged** — 0 failures of `passed(run.decision)` across the
46-assertion branch suite, the 256 seeded questions and the no-check fraction; the
only two failures are the mirror-assertions at `test/tb2_answer_reduce.jl:274` and
`:278`, which restate the computation they are checking.

So the answer to the brief's question: `L^alice`/`L^bob` **are** applied to the
oracle's seed and do reach `PCPGameCall` (trace: seed `(815,828)` →
`x=(815,0)`, `y=(0,828)`, and `x≠y`), but nothing downstream reads them. The
check that fires is `pcpverifier(tf, view)` on `(z, a_w)` alone. DESIGN risk 6
pre-registers "a trivial product … cannot support the theorem's consistency claim";
it does not record that the plumbing is a no-op, and no certificate node does either.

**FIX DEMAND** Add an `ASSUMED`/`SOURCE_REPAIR` node "`fig:pcpverifier` steps 1–2 not
executed; the formula is a construction-time constant; `(x_alice,x_bob)` do not enter
the decision", and a red test in which two oracle seeds yield two different formulas
with opposite step-5 outcomes.

**SURVIVING WEAKER STATEMENT** Items 3–5 of `fig:pcpverifier` are executed on
`(z, a_w)` and are red-capable: my new mutant MC5 (`zero(z_i) = z_i(1−z_i)` → `z_i²`
at `src/verifiers/pcp.jl`) is killed with 17 TB2 assertion failures.

---

## O4 · MAJOR · `PCPCLMap`'s level is a free tag, not constructed — C4b's precondition fails

**Location** `src/samplers/pcp_sampler.jl:63-70` (`PCPStageZero`, `PCPStage{C}`,
`_pcp_stages`), `:78` (`level(map) = _pcp_stage_depth(map.stages)`), `:274`
(`depth = kind.kind == :Point ? 1 : kind.kind == :ALine ? 2 : 3`).

**Independent computation.** `PCPStage{C}` carries no matrix, no register split and
no branch function: `_pcp_stages(n)` is a unary numeral, and the exponent is a
hard-coded literal keyed off the type's *name*. I built
`PCPCLMap{GF2048,…}(PCPType(:DLine,6), layout, _pcp_stages(1))`; it is accepted, it
reports `level = 1`, and its `apply` is bit-identical to the real `DLine_6` map,
while `marginal_k(pad_level(forged,1), seed, 1).value != apply(forged, seed)` — and
nothing anywhere rejects it. Contrast the real `CLStep` (`src/samplers/cl.jl:59-95`),
which materialises every attainable image, validates every child's rest register and
pins one fixed child level; there "level" genuinely cannot be forged, which is what
DESIGN §1.5 / DD-7 and the CLAIMS C4a phrase "constructed nesting depth" mean.

The DESIGN invariant table still reads `CL level | CONSTRUCTED | CLZero/CLStep
nesting`. For the 18 PCP maps the grade is at best `CHECKED`, and the only check the
suite performs is `marginal_k(map,seed,level).value == apply(map,seed)` at **one**
hard-wired seed (`oracularize.jl:189-192`).

**FIX DEMAND** Make the stage list the datatype — one `PCPStage` per stage carrying
its factor index set and a matrix-valued function of earlier stage outputs — define
`apply` as the sum of stages and `level` as the stage count, and add a replay that
checks `output_i = A_i · seed|_{V_i}`, factor disjointness and completeness over many
seeds.

**SURVIVING WEAKER STATEMENT** `def:cl-func`'s *substance* does hold. Independently
of the suite I audited all 18 maps × 20 random seeds and verified: (i) the stage
factor spaces are pairwise disjoint and their union is exactly `{1,…,38}`; (ii) each
stage output equals its declared matrix applied to the seed restricted to its factor,
scattered back; (iii) the stage outputs sum to `apply`. Result: **PASS, 18 maps ×
20 seeds**. By inspection of `_pcp_stage_data` (`pcp_sampler.jl:149-200`) each stage
matrix depends only on earlier stage outputs (`coordinate → π_{χ(s)-1} → L^lnf`). So
the 18 maps *are* CL of level ≤ 1/2/3 — CHECKED post hoc, not CONSTRUCTED.

---

## O5 · MAJOR · the committed proposer report is a nine-line self-referential stub

**Location** `briefs/18-tb2.last.md` (all 9 lines; its last line links to itself).
The real 23-line report — RED excerpt, five traces, mutation lines, API requests,
deviations and both merge proposals — exists only inside
`briefs/18-tb2.codex.log:268298-268326` (an 86,858-line file).

Two substantive consequences beyond process. (a) The brief-22 instruction to
adjudicate "MERGE PROPOSALS C9 and C4b in `briefs/18-tb2.last.md`" has no target;
I recovered them from the log and adjudicate them below. (b) The recovered report's
line *"Deviations from DESIGN: representation-only lazy adapter above; no semantic
deviation"* is **false**: O3 (fig:pcpverifier steps 1–2 dropped, `x,y` inert), O4
(CONSTRUCTED → tag), O6 (prover/decider disagree on the diagonal direction) and O8
(step 5's "otherwise, accept") are all semantic. Disagreement with the proposer's
printed report is MAJOR by the brief's own rule.

Also noted: the claimed RED was `UndefVarError: PCPType not defined` — a load error,
not a failing assertion. That is the weakest admissible form of red.

**FIX DEMAND** Restore the 23-line report as `briefs/18-tb2.last.md`, with the
"no semantic deviation" sentence replaced by the list above.

---

## O6 · MAJOR · prover and decider use different DLine directions

**Location** `src/verifiers/answer_reduce.jl:230-231`
`_question_line(q::PCPDLineQuestion) = AffineLine(q.base, q.direction)` versus
`src/samplers/ldt.jl:151-159` `diagonal_line`, which applies
`pi_prefix(direction, chi(s)-1)`.

**Independent computation.** `fig:ld-decider` item 3 and `table:tpcp` give the DLine
question content as `(u_0, s, v)` with `v ∈ F_q^{m'}` **arbitrary**, and require
`v' = π_{χ(s)-1}(v)`. The decider does re-project (correct); the honest strategy does
not. They agree only because `sample_pcp_question` already returns a projected
direction, so the honest strategy is undefined on the rest of the declared question
format. My new mutant MC1 — drop `pi_prefix` at `pcp_sampler.jl:115` — is KILLED
(2 failures, `test/tb2_answer_reduce.jl:168`, the `(oracle,Point_6) × (oracle,DLine_6)`
orientation), which is exactly the demonstration that the two code paths are not the
same function.

**FIX DEMAND** Have `_question_line` call `diagonal_line`/`pi_prefix` (single
definition), and add a red test that feeds a hand-built `DLine_6` question with an
unprojected `v`.

**SURVIVING WEAKER STATEMENT** On every question the TB2 sampler can emit, the two
lines coincide and the honest answers are the true restrictions (verified below).

---

## O7 · MAJOR · the "branch-covering" suite runs at one seed; the "256 seeded questions" carry 8 bits

**Location** `test/tb2_answer_reduce.jl:114,121,131,143,153,162,171,181` —
`case_index = 10` is re-**assigned** to 10 inside every loop body rather than
incremented; and `:45-47`
`tb2_seed(sampler,index) = ntuple(j -> GF2048(mod(37index + 13j + 1, 2048)), …)`;
and `:232-242`, where the `MersenneTwister` chooses only the type pair.

**Independent computation.** With `case_index` pinned, all 37 guard orientations are
evaluated at the single product seed `index = 10`. The 37 is otherwise exactly right
(1 + 2·2 + 2·2·2 + 2·3 + 2·3·2 + 2·2 + 2 = 37, all orientations). The 256 "seeded"
questions have their 40 coordinates determined by one integer `index ∈ 1001..1256`:
8 bits of question entropy over a fixed arithmetic progression, not 40·11 bits.
Consequence for coverage: `χ` takes exactly one value in copy 6 across the whole
deterministic suite (I computed `s_aux = 748`, `χ(748,16) = 6`), so `π_{i-1}` is
exercised at exactly one `i`.

**FIX DEMAND** Increment `case_index`, and draw seeds with
`rand(rng, field_elements(GF2048), seed_dim(sampler))`.

**SURVIVING WEAKER STATEMENT** 37 guard orientations at one seed, plus 256
(type-pair, structured-seed) pairs, all accept.

---

## O8 · MINOR · step 5's "Otherwise, accept" is not implemented

**Location** `src/verifiers/answer_reduce.jl:502-517` versus gt-10:2058-2063 and
DESIGN §1.6 step-5 row ("… reject iff it rejects, otherwise accept"). The figure
terminates the decider with ACCEPT when `τ_{Q,w} = oracle` and `τ_{Π,w} ≠ Point_6`;
the code merely falls through, so the second player's steps 1–5 still run. The
implementation is therefore strictly stricter than the literal source. Honest play is
unaffected; a dishonest prover is affected.

**FIX DEMAND** Implement the literal early accept, or record the reading you adopt as
a `SOURCE_REPAIR` node and in DESIGN §1.6.

---

## O9 · MINOR · mutation seams planted in shipped source; `_truncate_univariate` is dead code

**Location** `src/verifiers/answer_reduce.jl:173-176` — `_tb2_bundle_point_entries`,
`_tb2_individual_point_entry(value, copy::Int) = value` (the `copy` argument is
unused), `_tb2_finalize_line_answers(answers::Tuple) = answers` — and `:294-303`
`_truncate_univariate`, which has **no call site in `src/` at all**; its only caller
is `test/mutations/tb2_line.jl`. Three of the five TB2 mutants therefore perturb
identity adapters inserted for their benefit rather than the mathematics in situ; the
mutation score measures the seams. Mutants that do bite the code (`M-guard`,
`M-i345`) are the two constants at `:21-22`.

**FIX DEMAND** Delete `_truncate_univariate` from `src/` and put the truncation in
the mutant; inline the three identity seams and re-anchor the DESIGN §5.4 mutants on
`view.beta0`, `evaluate(proof.gs[copy], …)` and the interpolation loop bound.

---

## O10 · MINOR · certificate honesty and unexercised certificate

**Location** `src/verifiers/answer_reduce.jl:45-83`. The root node is
`CertNode(CHECKED, :TypedAnswerReduce; facts=(display="finite Figure decider-pcp
executable; typed level=max(ell,3)=3",), replay=_answer_reduce_replay)`, but
`_answer_reduce_replay` only re-counts 54 types / 2916 edges and asserts
`level(product) == max(level(ora), level(pcp))`, which is true by construction of
`TypedProductCL` (`oracularize.jl:57`) — a tautology. Nothing in that replay can fail
because of a decider defect, so the CHECKED node is stronger than its evidence.
Moreover `verify_certificate` is **never** called on the answer-reduced `Checked`
anywhere in the suite (only on the PCP sampler, `oracularize.jl:188`); `detype` /
`AnswerReduce` (`answer_reduce.jl:92-102`) are never exercised, so the `+2` level and
`16^54` factor are never asserted; and `tb2_has_node` (`test/tb2_answer_reduce.jl:49-52`)
is dead code.

Non-findings, for the record: `claims/CLAIMS.md` was **not** touched by this commit
(no law-1 violation), and the `SOURCE_REPAIR :PCPCopy6CoordinateScalar` node is
genuinely present and asserted (`source_repair=true`).

**FIX DEMAND** Give `:TypedAnswerReduce` a replay that re-executes one question of
each of the five checks; call `verify_certificate` on the reduction in the suite;
assert the CITED/ASSUMED leaves and the detyping numbers.

---

## O11 · MINOR · DESIGN ↔ code lockstep (law 2)

Four sampler datatypes appear in code and nowhere in the single source:
`PCPCLMap`, `PCPPaddedMap`, `PCPStage` (`pcp_sampler.jl:63-147`) and
`TypedProductCL` (`oracularize.jl:52-98`). DESIGN §1.5 still lists only
`CLZero`/`CLStep` with `direct_sum`/`product`, both of which already exist
(`src/samplers/cl.jl:238,317`). DESIGN §5.4 asks for peak memory for TB2 — not
reported — and for "each [mutation] must produce at least one named rejection", which
is not verified: `copied_mutant` (`run.jl:83-85`) only greps for `"Test Failed"` and
never inspects the rejection rule.

**FIX DEMAND** File a DESIGN merge proposal for the lazy adapter and its grade, or
add `_shift_cl(::PCPPaddedMap, …)` so `direct_sum`/`product` are reused; extend
`copied_mutant` to require the expected `CheckResult.rule` in the output.

---

## O12 · NOTE · the fixture is degenerate for the individual low-degree tests

`m = 1`. Hence for copies 1–5: `χ ≡ 1`, `π_{χ-1} = id`, `L^lnf(e_1)u = 0`, and every
"line" is the whole of `F_q^1`. Steps 3 and 4(b) therefore never exercise a proper
subline, and `π_{i-1}` is nontrivial only in copy 6 (and there, per O7, at one `i`).
Honest answer degrees are 1 (individual `g_3`) and ≤ 3 (the 22-tuple bundle) against
the declared bound `d = 11`, so the degree/format checks carry eight degrees of
unused slack; only the hand-built `t^12` witness at `test/tb2_answer_reduce.jl:319-327`
touches the bound.

## O13 · NOTE · 93.8 % of ordered type pairs trigger no check at all

Independently recomputed twice (a standalone Python transcription of
`fig:decider-pcp` and a Julia sweep against `answer_reduce_guard_branches`):
**2736 / 2916 = 76/81 = 93.827 %**, and the Julia sweep reported **0 disagreements**
over all 2916 ordered pairs. Of the 180 triggering pairs, 107 trigger only step 5 and
54 only step 1; just **34 ordered pairs (1.17 %)** reach a step-2/3/4 check
(input_consistency 4, input_ld 8, proof_cons 6, proof_ind 12, proof_sim 4). Under the
uniform edge distribution over the complete type graph this caps any pre-detyping
soundness gap at 6.2 %. This is a property of the source construction, not a defect,
but it belongs in C9's statement.

## O14 · MINOR · M-i345 is killed only by a tautology

`test/tb2_answer_reduce.jl:335` asserts
`proof_individual_guard_copies(reduced.decider) == (3,4,5)`, which literally restates
the constant the mutant edits (`answer_reduce.jl:21`). Brief 18 permitted this *if
stated as such*; the committed report does not state it (only the log's report does).
No honest-play consequence exists — extending the guard to `i ∈ {1,2}` runs extra
low-degree tests that an honest prover passes — so the `i ∈ {3,4,5}` restriction has
**zero behavioural evidence** at this fixture. Say so in C9.

---

## Fidelity audit vs the ground truth — what checks out

I transcribed `fig:decider-pcp` (gt-10:2010-2064) from the TeX myself before reading
the code. Every guard and parameter matches:

| step | source guard | code | verdict |
|---|---|---|---|
| 1 global consistency | `τ_alice = τ_bob` (**both** components) | `left_type == right_type` on `AnswerReduceType(role,pcp)`, `:401-410` | ✓ |
| 2 input consistency | `τ_{Q,w}=oracle`, `τ_{Q,w̄}=v∈{alice,bob}`, `(Point_6, Point_v)`, reject `α_v ≠ α'_v` | `:421-433`, `other_answer[1] == current_answer[input_copy]`, `_role_copy` gives alice↔1, bob↔2 | ✓ |
| 3 input low degree | `τ_{Q,w}=τ_{Q,w̄}=v`, `(Point_v, ALine_v/DLine_v)`, `ldparams=(q,m,d,1)` | `:435-450`, `_ar_ld_check(decider, params.m, 1, …)` | ✓ |
| 4(a) | both oracle, `(Point_i, Point_6)`, `i∈{3,4,5}`, `α_i ≠ α'_i` | `:454-465` | ✓ |
| 4(b) | both oracle, `(Point_i, ALine_i/DLine_i)`, `i∈{3,4,5}`, `ldparams` | `:467-482` | ✓ |
| 4(c) | both oracle, `(Point_6, ALine_6/DLine_6)`, `ldparams'=(q,m',d,m'+6)` | `:484-498`, `(params.m_prime, params.m_prime+6)` | ✓ |
| 5 game | `τ_{Q,w}=oracle`; `x_{w,v}=L^v(x_{Q,w})`; `τ_{Π,w}=Point_6` → `pcpverifier` | `:501-517` | guards ✓, payload ✗ (O3), "otherwise accept" ✗ (O8) |

Both ldparams tuples are observed in the traces: `(2048, 1, 11, 1)` and
`(2048, 16, 11, 22) = (q, m', d, m'+6)`.

**Register dimensions of `eq:V-pcp`.** Independently: `m=1, s=6 ⇒ m' = 5m+5+s = 16`
✓ (power of two, `16 | 2048` ✓, `m | q` ✓, `d = k = 11` ✓,
`(2+5k)m'/2^k = 912/2048 < 1/2` ✓). `dim V^pcp = 5(m+1+m) + (5+s) + 1 + (5+s) = 15+23
= 38`, matching the code's `NTuple{38,GF2048}`. `dim V_{6,pt} = dim V_{6,dir} = m' =
16` ✓; `dim V_{6,coord} = 5·1 + 1 = 6` ✓ from `eq:V-pcp` — and `gt-07-ldt.tex:194-197`
says the coordinate register of the low-degree test is isomorphic to `F_q`, i.e. the
copy-6 test wants **1**, while `table:tpcp` exposes one scalar. The code preserves 6
and lets `χ` read only `V_aux,coord`, zeroing the other five — the DD-20
`SOURCE_REPAIR`, and I confirm the node is present in the certificate and asserted.
The registers of copy 6 are the *same* coordinates as copies 1–5 plus aux (not fresh
ones), which is exactly what makes steps 2 and 4(a) non-vacuous: `L_{Point_v}` and
`L_{Point_6}`, driven by one shared seed, necessarily give `y_v = z|_{block v}`.

**One seed through a pair of CL maps.** `sample_answer_reduce_questions`
(`answer_reduce.jl:109-126`) splits one 40-dimensional seed into the 2-dimensional
oracularization part and the 38-dimensional PCP part and pushes **both** the left and
the right map through the **same** sub-seeds. This is genuine typed-CL shared-seed
semantics (`gt-06-types.tex:57-151`), not an independent mixture. ✓ (It re-implements
the split by hand instead of calling `sample(::TypedSampler, edge, seed)` — see
Elegance 3.) Oracularization matches `gt-09:42-70` exactly: roles
`{oracle,alice,bob}`, complete graph with self-loops, `L^oracle = Id`,
`L^alice/L^bob` from the original sampler.

**Honest answers really are restrictions of Π.** I recomputed two line answers
independently of the interpolation the code uses, by evaluating the proof polynomials
directly at every one of the 2048 line points:

* `ALine_6` at the suite's seed: `s_aux = 748`, `χ(748,16) = 6`, base
  `(410,449,488,527,566,0,618,…,735)` (note the zeroed 6-th coordinate, as
  `L^lnf(e_6)` demands). The 22 returned univariates agree with
  `(α_1..α_5, β_0, β_1..β_16) = ev_z(Π, u_0 + t·e_6)` at **all 2048** `t`;
  **0 mismatches**, max degree 3 ≤ d = 11.
* `DLine_3` with witness (ii): base `(0)`, `s = 501`, direction `(514)`, `χ = 1`.
  The answer agrees with `g_3(u_0 + t·v)` at **all 2048** `t`; **0 mismatches**,
  degree 1 ≤ m·d = 11.

---

## Test and mutation summary lines observed

```
COLD  (fresh precompile cache)
  Test Summary: MIPStarLambda | 187  187  2m25.7s
  TB0 60 s hard limit (measured 146.086 s) | Fail 1 1     ← exit status 1
WARM
  Test Summary: MIPStarLambda | 187  187  53.1s
  TB0 60 s hard limit (measured 53.551 s) | Pass 1 1
  WALL 54.46 s  CPU 100%  RSS 742,552 KiB                 ← exit status 0

MUTATION RUNNER, as documented
  TB0 targeted mutations | 7 7 17m51.6s                   (7/7 KILLED)
  MUTANT TB1 M-level omit_inductive_increment => SURVIVED (exit=1)
  TB1 targeted mutations | Pass 4  Fail 1  Total 5  15m57.9s
  MUTWALL 2032.06 s ; exit=1     ← TB2 block never reached (O1)

MUTATION RUNNER, per-rung re-run by me
  MUTATION_FILTER="TB2 "  : c0_plus_one_formula KILLED · g3_plus_one_individual_only
                            KILLED · truncate_line_polynomial KILLED ·
                            M-guard Point_ALine_to_Point_DLine KILLED
  MUTATION_FILTER="M-i345" : MUTANT TB2 M-i345 extend_to_i12 => KILLED (exit=1)
                            I345WALL 112.16 s ; exit=0        (5/5 TB2 KILLED)
  MUTATION_FILTER="M-level" at parent 08021a2 : KILLED, exit=0   ← proves O1 is a
                                                                   TB2 regression
```

## New mutations written by this critic (applied on copies, never in place)

| id | mutation | expectation | outcome |
|---|---|---|---|
| MC1 | `pcp_sampler.jl:115` `pi_prefix(direction, axis-1)` → `direction` (L_DLine skips `π_{i-1}`) | must break the diagonal test | **KILLED** (2 fails, `tb2_answer_reduce.jl:168`) |
| MC2 | `answer_reduce.jl:426` step 2 compares `α_v` with `α'_{3-v}` (swap `α_v` / `α'_v`) | must break input consistency | **KILLED** (6 fails) |
| MC3 | `answer_reduce.jl:489` step 4(c) uses `ldparams=(q,m,d,1)` instead of `ldparams'` | must break the simultaneous test | **KILLED** (5 fails, incl. the `(2048,16,11,22)` assertion at `:206`) |
| MC4 | `answer_reduce.jl:227` honest `_question_line` for `ALine` uses axis 1 instead of `χ(s)` | must break the copy-6 axis test | **KILLED** (2 fails) |
| MC5 | `pcp.jl` `zero(z_i) = z_i(1−z_i)` → `z_i²` | step 5 must reject | **KILLED** (17 fails) |
| MC6 | `answer_reduce.jl:504` step 5 computes `x_alice` with `L^bob` | probe: does `x` reach the decision? | **decision unchanged**; only the two mirror-assertions at `:274`/`:278` fail → evidence for O3 |

MC1, MC2, MC4 and MC5 are new semantic mutants the proposer did not anticipate; MC3
is the brief's `ldparams`/`ldparams'` swap; MC6 is a diagnostic, not a red test.

---

## Elegance — three places where the code is more complicated than the mathematics

1. **The stage decomposition is derived backwards.** `apply` (`pcp_sampler.jl:89-121`)
   writes out the closed form; `_pcp_stage_data` (`:149-200`) then *re-derives* the
   same three stages from `apply`'s output; `sample_pcp_question` (`:351-366`)
   re-derives the case split a third time. **Simplification:** make the stage list the
   datatype (factor index set + matrix-of-earlier-outputs), define
   `apply = Σ stages` and `level = length(stages)`, and let `sample_pcp_question` be a
   projection of `apply`. Deletes `AbstractPCPStage`/`PCPStage`/`PCPStageZero`/
   `_pcp_stages` and one of the two 30-line cascades — and makes O4 impossible.
2. **`TypedProductCL` re-implements `direct_sum`.** `oracularize.jl:52-98` (47 lines)
   duplicates `direct_sum` (`cl.jl:238-249`) and `marginal_k` purely because
   `_shift_cl` is eager. **Simplification:** add one `_shift_cl(::PCPPaddedMap, offset,
   total)` method and call the existing `product`/`direct_sum`; the struct, its
   `apply` and its `marginal_k` all disappear.
3. **The five guards are written twice, verbatim.** `typed_answer_reduced_decider`
   (`answer_reduce.jl:401-517`) and `answer_reduce_guard_branches` (`:526-564`) encode
   the same predicates independently, so the no-check fraction and the decider can
   silently drift apart. **Simplification:** one `guard_branches(left,right)`
   returning `(step, branch, player, index, line_kind)` tuples, with the decider
   iterating over it — about 40 duplicated lines removed and the drift made
   impossible.

---

## Per-claim recommendation

**C9 (new row) — HOLD.** Missing steps, in order: (i) **O1** — `test/mutations/run.jl`
must actually execute the five TB2 mutants; a claim cannot be TESTED while its red
neighbours are unreachable from the documented command and a previously-killed TB1
mutant survives; (ii) **O3** — the statement must exclude `fig:pcpverifier` steps 1–2
and say that `(x_alice,x_bob)` do not enter the decision; (iii) **O7** — the statement
must say the deterministic suite is one seed and the 256 seeded questions are one
parameter family. Once O1, O3 and O7 are addressed, the following row text is
**authorized verbatim** (status TESTED):

> | C9 | (Typed answer-reduced decider — TB0 fixture) For the row `(q,k,m,d,s,m')=(2048,11,1,11,6,16)`, the trivial two-coordinate original sampler and its three-role oracularization, the typed answer-reduced decider implements the five guarded checks of `fig:decider-pcp` with the exact type-pair guards, the `i∈{3,4,5}` restriction and both `ldparams=(q,m,d,1)` and `ldparams'=(q,m',d,m'+6)`; the honest strategy built from the TB0 PCP proof (witness (ii) for checks 4(a)/4(b)) is accepted on all 37 directed guard orientations and on 256 conditioned seeded question pairs, and every honest line answer checked equals the true restriction of the corresponding PCP polynomial at all `q=2048` line points. Exactly `2736/2916 = 76/81 = 93.827%` of ordered product-type pairs trigger no check, and of the remainder 107 trigger only step 5 and 54 only step 1. **Scope:** step 5 executes only items 3–5 of `fig:pcpverifier`; items 1–2 (`PaddedSuccinctDecider` → Tseitin → arithmetization) are not implemented, the formula is a construction-time constant, and the computed `x_alice=L^alice(x_Q)`, `x_bob=L^bob(x_Q)` do not enter the decision (`verdicts/tb2-r1.md` O3). The `i∈{3,4,5}` restriction has no honest-play consequence and is evidenced only structurally (O14). `m=1` makes checks 3 and 4(b) act on the whole of `F_q^1` (O12). Detyping, its `+2` levels and its `16^54` loss, and every quantum conclusion remain CITED. | TESTED | D1,D2,C3,C4a | — | `test/tb2_answer_reduce.jl`; red: `test/mutations/tb2_{formula,g3,line,guard,i345}.jl`, and `verdicts/tb2-r1.md` MC1–MC5 | `verdicts/tb2-r1.md` |

**C4b — HOLD.** The brief's precondition is not met. The lane-local `PCPCLMap` is a
**fresh datatype whose level is a free tag**: `PCPStage` carries no register split, no
matrix and no branch, and the depth is the literal `Point→1, ALine→2, DLine→3`
(O4). It is therefore *not* constructed by nesting the way `CLStep` is, and
`C4b`'s phrase "each of level 1, 2 or 3" would be an unfalsifiable annotation.
`def:cl-func`'s substance *is* satisfied — register subspaces, linear stage maps, and
continuations depending only on earlier stage outputs, verified by me on 18 maps × 20
random seeds — but as a CHECKED property, and the suite checks only the sum identity
at one seed. **Missing step:** rebuild `PCPCLMap` so that `level` is the length of a
stage list that `apply` is *defined from* (Elegance 1), and add the
`output_i = A_i · seed|_{V_i}` + disjointness/completeness replay over many seeds.
Until then C4b stays CONJECTURE, with its "Missing step" paragraph replaced by:

> **Missing step:** built at `(q,m,d,s,m')=(2048,1,11,6,16)` via a lane-local lazy adapter `PCPCLMap` (`src/samplers/pcp_sampler.jl:63-147`), but that adapter's level is a hard-coded tag rather than a constructed nesting: `PCPStage` carries no register split, matrix or branch, and a `DLine_6` map declared at level 1 is accepted and reports level 1 (`verdicts/tb2-r1.md` O4). `def:cl-func`'s register/linearity/continuation conditions hold on all 18 maps over 20 random seeds (ibid.), so the surviving statement is CHECKED-at-one-parameter, not CONSTRUCTED.

**C4a — no change (stays TESTED), with a flag.** Its cited red neighbour
`test/mutations/tb1_level.jl` **SURVIVES at this commit** (O1). This is a TB2 harness
regression, not a defect in the TB1 mathematics, so I do not recommend a downgrade;
but C4a's `where-tested` cell is currently false and must be re-verified once O1 is
fixed.

**C7 — no change (CONJECTURE).** It depends on C4b, which is held.

**C1, C2, C3, C5, C6, C8, N1 — untouched by this rung; no change.**

---

VERDICT: FAIL(O1,O2,O3,O4,O5,O6,O7)
