# Verdict tb2-r2 — adversarial critic on rung TB2 after repair r1 (commit `a4dc22a`)

Evaluated on an archived copy (`git archive a4dc22a | tar -x`) in
`/tmp/claude-1000/.../scratchpad/critic-tb2-r2/tree/`, instantiated there; the live
working tree was never read for `src/`/`test/` and never written. Julia 1.12.5, 12
cores. **Concurrency caveat (brief 41):** a second Opus critic (`critic-tb1-r2`) was
running its own suite throughout, and my own mutation driver ran three extra Julia
processes; `pgrep -fa 'runtests|mutations/run'` was never empty during this round.
Load average was `3.82` when the suite started and `3.91 → 7.52` across the mutation
runner. Both walls are reported below. The only wall with a gate — the TB0 60 s
test-body limit — passed at **40.675 s under load 3.8**, so no gate failed under load
and no quiet re-run was needed.

Files under review: `src/samplers/pcp_sampler.jl` (320 L, was 459),
`src/samplers/oracularize.jl` (151 L, was 210), `src/verifiers/answer_reduce.jl`
(621 L), `test/tb2_answer_reduce.jl` (452 L), `test/mutations/tb2_*.jl` (8 files),
`test/mutations/run.jl` (194 L), plus `src/samplers/cl.jl`/`typed.jl` where TB1's
lazy-`CLStep` repair carries TB2.

---

## 1. Adjudication of every response-table row in `briefs/38-tb1-tb2-repair-r1-resume.last.md`

Only the TB2 rows are mine; TB1 O1–O12 belong to `verdicts/tb1-r2.md`.

| r1 obj | claimed | **adjudication** | my evidence |
|---|---|---|---|
| **O1** FATAL — runner never executes a TB2 mutant | FIXED | **ACCEPTED** | I ran the documented command: `MUTATION REGISTRY: killed=37/37 wall=449.33 s`, **exit 0**, and all eight `MUTANT TB2 …` lines are present and KILLED. Each mutant is one process loading the precompiled image and `Base.include`-ing only the mutated file (`run.jl:125-173`); scoring distinguishes LOAD-ERROR / SURVIVED / KILLED / KILLED-BY-CRASH (`run.jl:160-171`) and no block can abort another (`asyncmap` over one flat queue, `run.jl:179-189`). The precompile-time `const` fixtures are gone: `pcp_sampler.jl` and `oracularize.jl` now hold only `precompile(...)` declarations plus the lazy `tb2_*_report()` functions (`oracularize.jl:104-143`). Decisive corroboration: `MUTANT TB1 M-level omit_inductive_increment => KILLED (exit=1, 47.12 s)` — the regression r1 O1 pinned on TB2 is gone. |
| **O2** MAJOR — cold run fails the gate | FIXED | **ACCEPTED** | `test/runtests.jl:1-6` starts `load_started` before `using` and prints the load time **ungated**; the gated clock (`started`, `:8`) begins after the package is loaded, so `Pkg` precompilation is structurally outside the gate. My warm-depot measurement: `TB0 test-body wall seconds = 40.675 (warning=45.0, hard_limit=60.0)`, `TB0 60 s test-body hard limit (measured 40.675 s) \| Pass 1 1`, exit 0 — under load 3.8, i.e. 19 s of headroom. Proposer's quiet cold figure (precompile 44.476 s ungated, body 36.415 s) is consistent. |
| **O3** MAJOR — step 5's `(x_alice,x_bob)` inert | DOWNGRADED (law 5) | **ACCEPTED as a legitimate law-5 downgrade** | The no-op is now *asserted as a fact* rather than left implicit: `CertNode(SOURCE_REPAIR, :PCPVerifierFixedFormula)` (`answer_reduce.jl:79-80`) says in terms that `fig:pcpverifier` steps 1–2 are not executed and the circuit is `(x,y)`-independent; it is asserted present (`test:122-123`); and `test:329-368` asserts `x_alice == apply(original_sampler.left, x_Q)`, `x_bob == apply(original_sampler.right, x_Q)`, `x_alice != x_bob`, that `pcp_decider_specification` carries both, and — openly, at `:361-362` — that the **swapped** call returns the same `(ok, formula_ok, zero_ok)`. That is the honest weaker statement, not concealment. Trace re-observed: seed `(815,828)` → `x=(815,0)`, `y=(0,828)`. Scoped into C9 below. |
| **O4** MAJOR — `PCPCLMap`'s level is a free tag | FIXED | **ACCEPTED** | See recomputation §2.1. `PCPCLMap`/`PCPPaddedMap`/`PCPStage`/`_pcp_stages` are deleted (0 grep hits in `src/`); the 18 maps are lazy `CLStep` nestings (`pcp_sampler.jl:65-112`) and `level(L::CLStep) = 1 + level(L.child_shape)` reads a real nested witness (`cl.jl:50`). My forgery attempt is rejected at construction. |
| **O5** MINOR — the committed report is a stub | RESIDUE (out of lane) | **PARTIAL** | `briefs/18-tb2.last.md` is restored (23 lines) with an orchestrator note. But r1's fix demand was to restore it *"with the 'no semantic deviation' sentence replaced by the list above"*; the sentence **"Deviations from DESIGN: representation-only lazy adapter above; no semantic deviation"** is still there verbatim, and the appended note only *points at* the verdict. Residual defect: the report of record for brief 18 still asserts something false in its own body. Mitigated: `briefs/38-…last.md` is a truthful record of the repaired state, and I found no discrepancy between it and the tree. |
| **O6** MAJOR — prover/decider DLine directions differ | FIXED | **ACCEPTED** | Single definition confirmed: `_question_line` calls `axis_line`/`diagonal_line` (`answer_reduce.jl:220-223`) and `ld_decider` calls the same two (`src/verifiers/ldt.jl:114-115`). Hand-checked in §2.2; red test at `test:422-443` feeds a hand-built unprojected `DLine_6` direction; `tb2_mc1` KILLED (108.72 s). |
| **O7** MAJOR — one seed; 8 bits of question entropy | FIXED | **ACCEPTED** | `case_index += 1` in every loop body (`test:181,192,204,214,223,231,241`) giving 37 distinct indices; the seeded suite draws `rand(rng, field_elements(GF2048))` per coordinate (`test:301-302`) and asserts `length(seeds) == 256`. Recomputed in §2.4: χ now takes **12 of 16** values across the deterministic suite (r1 measured 1) and **16 of 16** across the seeded suite. |
| **O8** MINOR — "Otherwise, accept" not implemented | DOWNGRADED | **ACCEPTED as a legitimate law-5 downgrade** | I re-transcribed `gt-10:2058-2063`: the literal text terminates the decider with ACCEPT when `τ_{Q,w}=oracle` and `τ_{Π,w} ≠ Point_6`; the code falls through, so it rejects strictly more. `CertNode(SOURCE_REPAIR, :PCPGameOtherwiseFallthrough)` (`answer_reduce.jl:81-82`) is present and asserted (`test:124-125`), and DESIGN §1.6's step-5 row carries the same sentence. See §2.5. |
| **O9** MINOR — mutation seams and dead code in `src/` | FIXED | **ACCEPTED** | `_truncate_univariate`, `_tb2_bundle_point_entries`, `_tb2_individual_point_entry`, `_tb2_finalize_line_answers`: 0 hits in `src/`. The three mutants are re-anchored in situ on `view.beta0` (`tb2_formula`), `_evaluate_individual` (`tb2_g3`) and the interpolation loop bound `for raw_t in 0:degree_bound` (`tb2_line`). |
| **O10** MINOR — certificate honesty; replay is a tautology | FIXED | **PARTIAL** | Genuinely improved: `verify_certificate(checked)` is now called (`test:120`), the ASSUMED / two SOURCE_REPAIR / CITED leaves are asserted (`:121-127`), `detype`'s `+2 → 5` and `16^54` are asserted (`:128-130`), `tb2_has_node` is live, and `_answer_reduce_replay_steps` really executes five type-pair cases. **Residual defect:** the replay collects only `entry.step` and requires `steps == Set(1:5)` (`answer_reduce.jl:51,604`) — reachability, not outcome. My mutant **ND4** (§4) disables every low-degree check and the testset that runs `verify_certificate` exits **0 with 0 failed assertions**. Raised as **N2**. |
| **O11** MINOR — DESIGN↔code lockstep; named rejections | FIXED | **PARTIAL** | Lockstep is clean: the four lane-local datatypes are gone from `src/` and never appear in `docs/DESIGN.md`, `docs/definitions.md` or `claims/CLAIMS.md` (0 grep hits); §1.5 now describes exactly `CLZero`/`CLStep` with the brief-38 vector-register note and the "not a product of six samplers" sentence; §1.6's step-5 row carries the fallthrough repair and the `σ` typo note; peak RSS is printed (685.4 MiB, `test:116-118`). **Residual defect:** DESIGN §5.4 requires that *each* mutation "produce at least one named rejection", and `expected_evidence` (`run.jl:161-162`) is supplied for only **4 of the 8** TB2 mutants (`tb2_formula`, `tb2_g3`, `tb2_line`, `tb2_guard`); `tb2_i345`, `tb2_mc1`, `tb2_mc2`, `tb2_mc3` are scored on exit code alone. |
| **O12** NOTE — `m=1` fixture is degenerate | RESIDUE, stated in C9 | **ACCEPTED** | Confirmed: `χ(s, m=1) = 1` for all 37 deterministic seeds, so `π_{i-1}=id` and `L^lnf(e_1)=0` in copies 1–5. Honest answer degrees measured at 1 against the declared bound `d=11` (§2.3), so eight degrees of slack remain unused except by the hand-built `t^12` witness (`test:408-418`). |
| **O13** NOTE — 93.8 % of pairs trigger no check | FIXED | **ACCEPTED** | Asserted at `test:322-323`, and independently recomputed by me from a fresh hand transcription of `fig:decider-pcp`: **2736/2916 = 76/81 = 93.827 %**, with **0 disagreements** against `answer_reduce_guard_branches` over all 2916 ordered pairs (§2.4). |
| **O14** NOTE — M-i345 killed only by a tautology | RESIDUE, stated in C9 | **ACCEPTED** | `test:449` still restates `_PROOF_INDIVIDUAL_COPIES`; that is the honest reading and it is scoped in the C9 row. |

**Score: 9 ACCEPTED · 2 ACCEPTED-as-DOWNGRADED (both law-5 legitimate) · 3 PARTIAL ·
0 REJECTED · 0 escapes.** Neither downgrade hides a result: both replace an
unsupportable claim with a named `SOURCE_REPAIR` node that is asserted by a test and
copied into the claim row, which is exactly law 5.

---

## 2. Independent recomputations (all on the archived copy; scripts under scratch)

### 2.1 The 18 maps' levels, recomputed by my own walk over the datatype

I wrote my own `depth(L) = L isa CLZero ? 0 : 1 + depth(L.child_shape)` and compared
it with `intrinsic_pcp_levels` and with `level`:

```
ALine_1..6 = 2   DLine_1..6 = 3   Point_1..6 = 1        levels_all_correct = true
padded_all_level_3 = true    sampler common level = 3
marginal telescoping + stage count on 18 maps x 20 random seeds = true
```

This is a *constructed* depth, not a tag. The stage list is what `apply` is defined
from (`cl.jl:139-146`), `marginal_k` walks the same chain (`:169-192`), and `_child`
validates every reached continuation against the field, the seed dimension, the rest
register and — decisively — `level(child) == level(L.child_shape)` (`cl.jl:103-116`).
I attempted r1 O4's forgery directly: a level-1 `CLStep` over the full ambient basis
whose branch returns the real level-3 `DLine_6`:

```
FORGED wrapper constructed; declared level = 1
FORGERY rejected: ArgumentError: CL continuation must occupy exactly the rest register
```

and the only level-1 map I *can* build over the whole ambient basis is the identity,
whose `apply` differs from `DLine_6`'s. Independently of the suite I also re-verified,
on 18 maps × 20 random full-field seeds, that each stage output equals
`A_i · seed|_{V_i}` scattered back, that the factor spaces are pairwise disjoint and
exhaust `{1,…,38}`, that `length(factor_spaces) == level`, and that the stage sum
equals `apply`. **r1 O4's stated missing step is met.**

Register arithmetic re-derived from `eq:V-pcp`: `m'=5m+5+s=16`; `dim V^pcp = 5·3 + 11
+ 1 + 11 = 38`; `V_{6,pt}={1,4,7,10,13} ∪ [16..26]` (16), `V_{6,dir}={3,6,9,12,15} ∪
[28..38]` (16), `V_{6,coord}={2,5,8,11,14,27}` (6), `auxiliary_coordinate = 27`. All
match the code and `table:tpcp`'s scalar exposure via the DD-20 repair.

### 2.2 Prover and decider agree on the DLine direction — one line by hand

Seed drawn with `MersenneTwister(0xBEEF)`; `s_aux = 395`, `χ(395,16) = 4`:

```
seed dir[1:4]     = [475, 1789, 623, 338]
sampled dir[1:4]  = [  0,    0,   0, 338]        pi_prefix(seed dir, chi-1) == sampled : true
_question_line direction == sampled direction : true ; base == sampled base : true
hand-evaluated line_point(t=7) == line_point(dl,7)  : true
hand-built UNPROJECTED question -> _question_line projects it : true
eq:cl-dlnf base = L^lnf_{pi_{i-1}(v)}(u) matches sampled base : true
```

The projection now lives **inside the CL map** (`pcp_sampler.jl:103-106`,
`projection[i,i]=1` for `i ∈ axis:length(direction)`, i.e. exactly `π_{χ(s)-1}`), and
both the honest prover and `D^ld` re-derive the line through the same `diagonal_line`.
The two code paths of r1 O6 are now one function.

### 2.3 Honest line answers vs the true restriction at all `q=2048` points

Fresh seed (`MersenneTwister(0x2048)`, `χ = 7` — a different axis from r1's `χ = 6`):

```
ALine_6 chi=7 : mismatches over all 2048 t = 0 ; max answer degree = 1 (bound d=11)
DLine_3       : mismatches over all 2048 t = 0 ; degree = 1 (bound m*d=11)
```

for the 22-tuple bundle against `ev_z(Π, u_0 + t·e_7)` and for the individual
`g_3(u_0 + t·v)` on the non-degenerate witness (ii). This re-confirms r1's finding at
a new parameter and is the evidence behind C9's restriction clause.

### 2.4 Seeds, χ coverage, and the no-check fraction

```
deterministic branch suite : distinct case_index = 37 ; distinct seeds = 37
                             chi(s_aux,16) distinct = 12 of 16  -> [1,6,7,8,...,16]
                             chi(s,m=1) for copies 1..5         -> [1]  (constant, as O12 says)
256 seeded questions       : distinct seeds = 256 ; distinct type pairs = 140 of 180
                             chi(s_aux,16) distinct = 16 of 16
no-check fraction          : my own transcription of fig:decider-pcp -> 2736/2916 = 93.827 %
                             disagreements with answer_reduce_guard_branches over 2916 pairs = 0
```

### 2.5 Step 5's plumbing and its "Otherwise, accept"

The `(x_{w,alice}, x_{w,bob})` computed from `L^alice`/`L^bob` do reach the
decider-specification argument — `PCPGameCall` carries them, `pcp_decider_specification`
copies them out, and the suite asserts both equalities and their inequality
(`test:342-350`). They still do not enter the decision, and both facts are asserted.
"Otherwise, accept" is **not** implemented literally: for
`((oracle,ALine_6),(oracle,Point_6))` the guard set is
`(:proof_simultaneous_low_degree, :game)`, i.e. alice's non-`Point_6` step 5 does not
terminate the decider and bob's `:game` still runs. Recorded as `SOURCE_REPAIR`.

### 2.6 Fidelity spot-checks against the ground truth

Re-transcribed `fig:decider-pcp` (gt-10:2010-2064) before re-reading the code; all
five guards, the `i ∈ {3,4,5}` restriction, the alice↔1/bob↔2 convention and both
`ldparams=(q,m,d,1)` / `ldparams'=(q,m',d,m'+6)` match, as in r1. Re-checked against
gt-10:1919-1935 that each `L_{τ_i}` "acts on `V_{i,pt} ⊕ V_{i,coord} ⊕ V_{i,dir}` and
zeroes out all the other registers" — the code's `complement(point)` factor with a
selector matrix does exactly that. `E^ar` is the tensor graph of gt-10:1949-1955; the
code writes the complete `54²` graph literally, which coincides here because both
factor graphs are complete, and the DESIGN §9.4 red-test edge
`((oracle,Point_1),(alice,DLine_6))` is present. `eq:cl-alnf`/`eq:cl-dlnf` are
implemented as three-stage nestings matching gt-07:213-237's own decomposition.
Source's step-5 tuple omits `σ`; the executable reconstructs it from `fig:pcpverifier`'s
own 8-component signature, already recorded in DESIGN §1.6.

---

## 3. New objections

### N1 · MAJOR · the 54-type product's CL maps are never on the decider path, and a wrong product survives the whole suite

**Location** `src/samplers/oracularize.jl:71-76` (`_build_typed_sampler_product`)
versus `src/verifiers/answer_reduce.jl:115-132` (`sample_answer_reduce_questions`),
with the only application site at `oracularize.jl:134`.

**My computation.** `sample_answer_reduce_questions` splits the 40-dimensional seed by
hand — `original_seed = seed[1:2]`, `pcp_seed = seed[3:40]` — and pushes them through
`oracularized_sampler.left[role]` and `sample_pcp_question(pcp_sampler, kind, ·)`. It
never touches `verifier.sampler.left`/`.right`. Grepping every read of
`verifier.sampler` gives only `length(types)`, `length(type_graph)`, `level(...)` and
`seed_dim(...)` (`answer_reduce.jl:46-56,99-100,118,592`). The product maps are applied
in exactly one place in the whole repository: the self-consistency line
`marginal_k(map, product_seed, level(map)).value == apply(map, product_seed)`
(`oracularize.jl:134`), which is true for *any* CL value by construction.

I therefore mutated the product itself (**ND2**): swap the `direct_sum` summand order
for both `left` and `right`, so the answer-reduced sampler becomes
`L_{τ_pcp} ⊕ L_{τ_ora}` on the seed order the questions use. Result:

```
MUTANT ND2 product_direct_sum_order_swapped => SURVIVED (exit=0, failed_assertions=0, 65.8 s)
```

The entire TB2 suite stays green. The mathematics is *not* wrong — I verified
independently that `apply(sampler.left[(role,kind)], z) == (apply(ora, z[1:2])...,
apply(pcp, z[3:40])...)` on 20 random seeds × 12 types, 0 disagreements — but the
object C4b names and the object C9 judges are joined by an unasserted convention, and
`gt-10:1956-1962` ("the corresponding CL function is simply the direct sum … the
distribution is the product distribution `μ_ora × μ_pcp`") is precisely the statement
that has no red neighbour. This is also the last surviving piece of r1's Elegance 3.

**FIX DEMAND** Make `sample_answer_reduce_questions` a projection of
`sample(verifier.sampler, edge, seed)` (or assert their equality over ≥ 20 random
seeds and all 54 types), and register a permanent mutant that swaps the `direct_sum`
summand order and must be KILLED.

**SURVIVING WEAKER STATEMENT** At `(2048,11,1,11,6,16)` the product maps *do* equal
the hand split on 20 seeds × 12 types (critic recomputation), the product has 54
types, `54²` edges — which coincides with `E^ora × E^pcp` because both factor graphs
are complete — and level `max(1,3)=3`; but the product's summand order is evidenced
only by this verdict, not by the suite.

### N2 · MINOR · the CHECKED `:TypedAnswerReduce` replay verifies reachability, not the checks

**Location** `src/verifiers/answer_reduce.jl:45-57` and `:579-607`
(`_answer_reduce_replay`, `_answer_reduce_replay_steps`), node created at `:83-87`.

**My computation.** The replay unions `entry.step` over five type-pair cases and
requires `steps == Set(1:5)`; no `entry.result` is inspected. Mutant **ND4** replaces
the body of `_ar_ld_check` so that every low-degree check returns
`CheckResult(true, :ld_axis_point)`:

```
ND4  [TB2_TARGET=sampler]  => SURVIVED (exit=0, failed_assertions=0, 34.9 s)
ND4b [TB2_TARGET=all]      => KILLED   (exit=1, failed_assertions=2, 75.8 s)
```

The testset that calls `verify_certificate(checked)` is green while three of the five
figure checks are disabled. The node is not *vacuous* — deleting a guard would break
`steps == Set(1:5)` — but its CHECKED grade is stronger than what it replays, which is
r1 O10's complaint one level in.

**FIX DEMAND** Have `_answer_reduce_replay_steps` assert, per case, both an
honest-accept and a deliberately corrupted-answer reject, and compare
`entry.result.rule` against the expected rule; then re-run ND4 and require KILLED.

**SURVIVING WEAKER STATEMENT** `:TypedAnswerReduce` honestly certifies the *shape*
(54 types, `54²` edges, `level = max(ℓ_ora, ℓ_pcp)`) and that all five guarded branches
are reachable on the fixture; the checks' correctness is evidenced by the branch and
mutation testsets, not by the certificate.

### N3 · MINOR · `pad_level` prepends its zero stages; `rk:higher-level` and DESIGN §9.4 append them

**Location** `src/samplers/typed.jl:3-16` versus `docs/DESIGN.md` §9.4 ("A genuine
`r>=1`-level child padded to a larger level keeps its first `r` factors and appends
empty factors … stage 1 reports the all-ones indicator for its entire ambient space")
and `gt-04-cl.tex:122-130` (`rk:higher-level` promotes with `V_1 = V`, `L_1 = 0`).

**My computation.** On the padded maps actually stored in the sampler:

```
Point_6 padded: stage factor sizes = [0, 0, 38]   Marginal(1) is the zero vector = true
ALine_6 padded: stage factor sizes = [0, 22, 16]  Marginal(1) is the zero vector = true
DLine_6       : stage factor sizes = [6, 16, 16]  (no padding needed)
Marginal(j) == apply(intrinsic map)?  j=1 false, j=2 false, j=3 true
```

The padded object is a valid 3-level CL function either way (`def:cl-func` permits an
empty register factor), and the *final* marginal — the one `sample_questions` reads —
is unchanged, so nothing in TB2 is wrong. But `def:sampler`'s `marginal` query at
`j < ℓ` returns `0` under this convention and the point under DESIGN's, and TB5's
§9.2 chain replay is written against DESIGN's. Single-source divergence today; a
silent behaviour change for `describe_cl` tomorrow.

**FIX DEMAND** Either make `pad_level` append the zero stages (keeping the child's
first `r` factors) so it matches DESIGN §9.4, or amend §9.4 and §1.5 to state the
prepend convention explicitly and pin it with a test on `marginal_k(padded, z, 1)`.

**SURVIVING WEAKER STATEMENT** Padding to the common level is real and level-correct;
only the position of the zero-factor stages, and hence the intermediate marginals, is
unspecified in DESIGN §1.5 and contrary to §9.4.

### N4 · NOTE · the decider's loop order is player-outer, the source's is step-outer

`fig:decider-pcp` says "performs the following steps sequentially, for all
`w ∈ {alice,bob}`"; `typed_answer_reduced_decider` runs `(alice: 2,3,4,5)` then
`(bob: 2,3,4,5)` (`answer_reduce.jl:409-515`). Because the verdict is the conjunction
of all triggered checks and every rejection is terminal, the accept/reject decision is
identical; only *which* rule is reported first can differ. No fix demanded; worth one
sentence in DESIGN §1.6 so a future reader does not read it as a deviation.

### N5 · NOTE · the type graph is written complete, not computed as a tensor product

`_build_typed_sampler_product` (`oracularize.jl:77`) and `_build_pcp_sampler`
(`pcp_sampler.jl:152`) emit `[(l,r) for l in types for r in types]`. That equals
`E^ora × E^pcp` here only because both factor graphs happen to be complete. DESIGN
§9.4's `DL9-product` requires the tensor rule and names a red test for it; TB5 must
compute the edge set rather than assume completeness.

---

## 4. Test and mutation evidence I observed

```
SUITE  (archived tree a4dc22a, warm depot, load average 3.82 -> 2.87)
  MIPStarLambda load/precompile seconds = 0.288 (ungated)
  TB0 test-body wall seconds = 40.675 (warning=45.0, hard_limit=60.0)
  TB0 60 s test-body hard limit (measured 40.675 s) | Pass 1  Total 1
  Test Summary: MIPStarLambda | Pass 224  Total 224  Time 1m45.7s
  /usr/bin/time -v : Elapsed 1:47.21 · Maximum RSS 959,916 KiB · Exit status 0
  in-test print    : TB2 lazy CLStep replay: maps=18 seeds/map=20; DLine_6 apply=2.15 us;
                     peak RSS MiB=685.4
  proposer's quiet warm figure 224/224 1m40.8s, TB0 body 40.374 s — agrees within noise.

MUTATION RUNNER  (`julia --project=. test/mutations/run.jl`, load average 3.91 -> 7.52)
  package image ready after 0.75 s
  TB0 : A, B, C, D, E, F, C8, G, H, I, J, K, L, M                    14/14 KILLED
  TB1 : M-χ, M-π, M-lnf, M-deg, M-level, N1..N5, M-concat,
        M-repair, M-ambient, M-dsum, M-kappa                         15/15 KILLED
  TB2 : c0_plus_one_formula 121.27 s · truncate_line_polynomial 111.21 s ·
        M-guard 126.10 s · g3_plus_one_individual_only 134.09 s ·
        M-i345 83.53 s · MC1 sampler_dline_skips_pi 108.72 s ·
        MC3 ldparams_not_ldparams_prime 100.27 s ·
        MC2 input_consistency_compares_other_block 116.99 s          8/8 KILLED
  MUTATION REGISTRY: killed=37/37 wall=449.33 s
  /usr/bin/time -v : Elapsed 7:30.59 · Maximum RSS 709,424 KiB · Exit status 0
  Proposer's quiet-box figure: wall 230.24 s, real 3m51. My 449 s is the same runner
  under load 4-7.5 with three of my own Julia processes resident; the runner carries no
  time gate and exits 0 in both measurements. NOTE, not an objection.
```

The four TB2 mutants that carry `expected_evidence` are additionally scored on the
named rejection rule; I confirmed the clean run prints the *complementary* lines
(`MUTATION_EXPECTED_RULE pcpverifier actual=answer_reduce_accept passed=true`, etc.),
so the evidence strings really do discriminate mutant from clean.

## 5. New mutations written by this critic (applied on isolated copies; the tree was never modified)

| id | mutation | expectation | outcome |
|---|---|---|---|
| **ND1** | `answer_reduce.jl:368-372` `_pcp_view_from_answer` rotates the bundle: `alpha := answer[2..6]`, `beta0 := answer[1]` — step 5 reads the `Point_6` answer in the wrong order | step 5 must reject | **KILLED** (exit 1, 17 failed assertions, 89.9 s; first failure `passed(run.decision)` at `test:188`) |
| **ND2** | `oracularize.jl:72-75` `direct_sum(ora, pcp)` → `direct_sum(pcp, ora)` for both `left` and `right` — the answer-reduced sampler no longer matches the seed order its questions use | must break the answer-reduced sampler | **SURVIVED** (exit 0, 0 failed assertions, 65.8 s) → **N1** |
| **ND3** | `pcp_sampler.jl:46-47` copy-6 point register becomes `vcat(auxiliary_point, individual points)` — `z=(y,o,w)` block order permuted at fixed dimension 16 | must break steps 2/4/5 | **KILLED** (exit 1, 8 failed assertions, 55.0 s) |
| **ND4** | `answer_reduce.jl:362-364` `_ar_ld_check` discards `ld_decider`'s verdict and returns `CheckResult(true, :ld_axis_point)` | probe: is the CHECKED replay red-capable? | **SURVIVED** under `TB2_TARGET=sampler` (exit 0); **KILLED** under `TB2_TARGET=all` (2 failures) → **N2** |

ND1 and ND3 are semantic mutants the proposer did not anticipate and the suite kills
both. ND2 and ND4 are the two survivors and are the substance of N1 and N2.

## 6. Elegance — the three remaining places the code is heavier than the mathematics

1. **The seed split is written twice.** `sample_answer_reduce_questions`
   (`answer_reduce.jl:118-129`) re-implements what `direct_sum` + `sample(::TypedSampler,
   edge, seed)` already do (`typed.jl:68-78`). *Simplification:* build the questions by
   `sample(verifier.sampler, edge, seed)` and project; ≈ 12 lines vanish and N1 becomes
   impossible.
2. **The five guards are still written twice, verbatim.** `typed_answer_reduced_decider`
   (`:399-515`) and `answer_reduce_guard_branches` (`:523-561`) encode the same
   predicates independently — 40 duplicated lines that can drift, and only a drift that
   makes the decider *narrower* is caught. *Simplification:* one
   `guard_branches(left,right)` returning `(step, branch, player, index, line_kind)` with
   the decider iterating over it. (Carried over unfixed from r1; not re-litigated as an
   objection.)
3. **`_pcp_cl_map`'s first factor is the whole complement.** For copies 1–5 the
   coordinate stage takes a 36- or 37-dimensional factor whose matrix is a single 1
   (`pcp_sampler.jl:84,98`). It is correct — the map must zero all other registers — but
   `_pcp_stage_matrix` then allocates a 37×37 matrix to express one selector.
   *Simplification:* keep the factor list but store the selector as an index set with a
   `_matvec` specialisation; the `DLine_6` `apply` cost (2.15 µs) is dominated by these
   dense multiplies.

---

## 7. Forward look — does this rung's datatype support DESIGN §9?

1. `Dimension` maps to `seed_dim` and `Marginal(n,w,j,z)` to
   `marginal_k(L, z, j).value`: both present, total, and validated (`0 ≤ k ≤ level`).
2. **Gap (NOTE):** `Factor` and `Linear` are *prefix*-addressed in `def:sampler`
   (`u ∈ L_{<j}(V)` resp. `u ∈ V_{<j}`; DESIGN §9.1 keeps the asymmetry deliberately),
   but `marginal_k` is *seed*-addressed. The only prefix walk is the private `_child`,
   whose key is the **local stage output vector** `A_j(x^{V_j})`, not the ambient
   prefix `u`. TB5 needs a public prefix-walk entry point and a documented
   `u ↦ (local keys)` translation; `Linear` at an unreachable `u ∈ V_{<j}` must be
   answerable, which the current memo dictionary keyed on reached values does not
   guarantee.
3. **Gap (NOTE):** §9.3 admits only branches built from a named pure `QuotedBranch`
   constructor. Every branch introduced by brief 38 is an anonymous Julia closure
   (`typeof(L_DLine_6.branch) == var"#_pcp_cl_map##11#..."`), so `describe_cl` on the
   TB2 family returns `NotDescribable` today. DESIGN §9.3 already books this as "the
   remaining adapter work after the lazy-branch repair"; TB5 should convert
   `_pcp_cl_map`'s three closures first, since they are the largest family.
4. **Gap (N3):** the padding convention. `pad_level` prepends zero-factor stages, so a
   padded map's `Marginal(j)` for `j < ℓ` is `0`; DESIGN §9.4 and `rk:higher-level`
   promote with `V_1 = V`. The §9.2 `enu:cl-space-sum` replay passes under both, but
   `enu:cl-map-sum` per-stage reports and the `SOURCE_REPAIR(zero-map-factor-partition)`
   tag are written against §9.4's order.
5. **Gap (N5):** `DL9-product` must compute `E^ar` from `E^ora × E^pcp`; the current
   constructors hardcode completeness.
6. Positive: `CLMarginal` already carries `factor_spaces` and `linear_maps` per stage,
   which is exactly the payload `Factor`/`Linear` need, and `level` is CONSTRUCTED with
   per-branch validation — so §9.3's "level and both well-formedness invariants are
   CONSTRUCTED by nesting" is already true of this rung's values.

---

## 8. Per-claim decisions

### C4b — **PROMOTE** (CONJECTURE → TESTED)

r1's stated missing step was: *"rebuild `PCPCLMap` so that `level` is the length of a
stage list that `apply` is defined from, and add the `output_i = A_i · seed|_{V_i}` +
disjointness/completeness replay over many seeds."* Both are done — `PCPCLMap` is
deleted, the 18 maps are lazy `CLStep` nestings whose level is the constructed nesting
depth and which `_child` validates at every reached branch, and the replay runs over
18 maps × 20 random full-field seeds. I recomputed both independently (§2.1). r1's
authorized "Missing step" paragraph is now **stale and factually false** (it cites
`PCPCLMap` at `pcp_sampler.jl:63-147`, which no longer exists) and **must not be
applied**. The following row text is **AUTHORIZED VERBATIM** and replaces the C4b row
in `claims/CLAIMS.md` (status TESTED):

> | C4b | (Sampler is CL — PCP family) At `(q,k,m,d,s,m')=(2048,11,1,11,6,16)` the 18 PCP maps `{Point_i, ALine_i, DLine_i}_{i=1..6}` form one typed CL family on `V^pcp` (`seed_dim` 38), of constructed nesting depth 1, 2 and 3 respectively — upper bounds in the sense of `rk:higher-level`, not minimality claims — built only from lazy `CLStep` stages (`src/samplers/pcp_sampler.jl:65-112`) whose factor and rest registers are disjoint coordinate-index sets whose union is all of `{1,...,38}`, with every reached continuation validated against the constructed child level and rest register, so a level-1 wrapper around a level-3 continuation is rejected at construction (`verdicts/tb2-r2.md` §2.1). All 18 are padded to the common level 3, and the typed product with the three-role oracularized sampler has 54 types, `54^2` edges and level `max(ell,3)=max(1,3)=3`. On 18 maps x 20 random full-field seeds, every stage output equals `A_i * seed|_{V_i}` scattered back, the factor spaces are pairwise disjoint and exhaust the ambient basis, the stage count equals the level, and the stage sum equals `apply` (`test/tb2_answer_reduce.jl:83-107`, independently recomputed in `verdicts/tb2-r2.md`); `apply(L_DLine_6)` costs 2.15 us. **Scope:** `eq:V-pcp` gives `dim V_{6,coord}=6` while `table:tpcp` supplies one scalar; `chi` reads `V_{aux,coord}` and the other five coordinate components are zeroed (`SOURCE_REPAIR :PCPCopy6CoordinateScalar`). `pad_level` prepends its zero-factor stages, so a padded map's marginals `L_{<=j}` for `j<3` are zero rather than the `V_1=V` promotion of `rk:higher-level`/DESIGN §9.4 (`verdicts/tb2-r2.md` N3). The `54^2` type graph is written complete rather than computed as `E^ora x E^pcp`; the two coincide here only because both factor graphs are complete (ibid. N5). The product is evidenced through its type/edge counts, its level and its self-consistent marginals only: the decider's questions are generated by an explicit seed split, not by applying the product maps, and swapping the `direct_sum` summand order leaves the whole suite green (ibid. N1) — the two were checked equal on 20 seeds x 12 types by the critic, not by the suite. No claim is made about any other `(q,m)`, about `def:sampler`'s four-query machine interface, or about the `enu:cl-space-sum`/`enu:cl-map-sum` replay at prefix-addressed `Factor`/`Linear` calls. | TESTED | D2, C4a | — | `test/tb2_answer_reduce.jl` (`sampler`); red: `test/mutations/tb2_mc1.jl`, `test/mutations/tb1_{level,dsum,concat,ambient}.jl` | `verdicts/tb2-r2.md` |

### C9 — **PROMOTE** (new row, TESTED)

`claims/CLAIMS.md` has no C9 row today. r1 authorized one conditional on O1, O3 and
O7; all three are now addressed (ACCEPTED above). The row below is r1's authorized
text with (a) its verdict pointers updated, (b) the O8 fallthrough repair added, and
(c) the N1 question-generation scope added. It is **AUTHORIZED VERBATIM** (status
TESTED); nothing may be added to it without a further verdict.

> | C9 | (Typed answer-reduced decider — TB0 fixture) For the row `(q,k,m,d,s,m')=(2048,11,1,11,6,16)`, the trivial two-coordinate original sampler and its three-role oracularization, the typed answer-reduced decider implements the five guarded checks of `fig:decider-pcp` with the exact type-pair guards, the `i in {3,4,5}` restriction and both `ldparams=(q,m,d,1)` and `ldparams'=(q,m',d,m'+6)`; the honest strategy built from the TB0 PCP proof (witness (ii) for checks 4(a)/4(b)) is accepted on all 37 directed guard orientations at 37 distinct seeds and on 256 conditioned seeded question pairs at 256 distinct full-field seeds covering all 16 values of `chi(s_aux,m')`, and every honest line answer checked equals the true restriction of the corresponding PCP polynomial at all `q=2048` line points (critic recomputation, `verdicts/tb2-r1.md` and `verdicts/tb2-r2.md` §2.3; the suite itself checks one such line through `D^ld`). Exactly `2736/2916 = 76/81 = 93.827%` of ordered product-type pairs trigger no check, and of the remainder 107 trigger only step 5 and 54 only step 1. **Scope:** step 5 executes only items 3-5 of `fig:pcpverifier`; items 1-2 (`PaddedSuccinctDecider` -> Tseitin -> arithmetization) are not implemented, the formula is a construction-time constant, and the computed `x_alice=L^alice(x_Q)`, `x_bob=L^bob(x_Q)` reach `pcp_decider_specification` but do not enter the decision — asserted, including the equal verdict under a swapped call (`SOURCE_REPAIR :PCPVerifierFixedFormula`; `verdicts/tb2-r1.md` O3). Step 5's "otherwise, accept" is read as fallthrough, so the decider is strictly stricter than the literal source (`SOURCE_REPAIR :PCPGameOtherwiseFallthrough`; ibid. O8). The questions judged are produced by an explicit seed split rather than by applying the 54-type product sampler's CL maps; the two agree on 20 seeds x 12 types by critic recomputation only (`verdicts/tb2-r2.md` N1). The `i in {3,4,5}` restriction has no honest-play consequence and is evidenced only structurally (O14). `m=1` makes checks 3 and 4(b) act on the whole of `F_q^1`, and honest answer degrees are 1 against the declared bound `d=11` (O12). The `:TypedAnswerReduce` certificate replays branch reachability and shape, not the checks' verdicts (`verdicts/tb2-r2.md` N2). Detyping, its `+2` levels and its `16^54` loss, and every quantum conclusion remain CITED. | TESTED | D1,D2,C3,C4a,C4b | — | `test/tb2_answer_reduce.jl`; red: `test/mutations/tb2_{formula,g3,line,guard,i345,mc1,mc2,mc3}.jl` | `verdicts/tb2-r2.md` |

### C4a — no change (stays TESTED); r1's flag is cleared

`test/mutations/tb1_level.jl` is KILLED again at this commit (47.12 s), so C4a's
`where-tested` cell is true. Its row text is `verdicts/tb1-r2.md`'s business.

### C7 — no change (CONJECTURE)

It depends on C4a and C4b; C4b's promotion to TESTED at one parameter does not touch
the closure hypothesis.

### C1, C2, C3, C5, C6, C8, N1(negative), C12–C15 — untouched by this rung; no change.

---

## 9. Work order for the next repair round

1. **N1 (MAJOR, blocking).** Route the questions through the product sampler, or assert
   the equality, and register the summand-order mutant. Until then C4b and C9 carry the
   scope sentences above.
2. **N2 (MINOR).** Give `:TypedAnswerReduce` an outcome-checking replay; ND4 must become
   KILLED under `TB2_TARGET=sampler`.
3. **N3 (MINOR).** Reconcile `pad_level` with DESIGN §9.4 in one direction and pin it.
4. **O5 residue.** Replace the false "no semantic deviation" sentence in
   `briefs/18-tb2.last.md` (orchestrator lane).
5. **O11 residue.** Add `expected_evidence` to `tb2_{i345,mc1,mc2,mc3}`.
6. **N4, N5 (NOTE).** One DESIGN sentence each.

Objection trajectory for this rung: **14 → 5** (1 FATAL + 4 MAJOR + 6 MINOR + 3 NOTE →
1 MAJOR + 2 MINOR + 2 NOTE). Severity is falling monotonically and no r1 objection was
rejected or escaped.

VERDICT: FAIL(N1)
