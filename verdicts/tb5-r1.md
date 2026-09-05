# Verdict — TB5 r1 (brief 74): the DESIGN §9 description layer and executable Repeat

Critic: Opus, adversarial round 1. Target: the **archived** tree at `f7e69ed`
(`git archive f7e69ed | tar -x`), instantiated in
`/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb5-r1/tree`.
Nothing in the live tree was read under `src/` or `test/`; `claims/CLAIMS.md` was read live.
Power profile: `powerprofilesctl get` → **performance** throughout.

**VERDICT: FAIL(O1,O2)** — see the final line.

---

## 0. Runs, walls, load

| run | result | wall | `uptime` before → after |
|---|---|---:|---|
| cold precompile (`Pkg.instantiate(); using MIPStarLambda`) | ok | **71.4 s** precompile, 86.4 s total | `12:57` load 1.40/2.97/2.97 |
| `julia --project=. test/runtests.jl` | **1796/1796, exit 0** | **95.9 s** (`Test Summary` 1m35.0s) | `12:59:18 up 4:11` load 1.68/2.54/2.81 → `13:00:53 up 4:13` load 1.25/2.17/2.65 |
| `MUTATION_JOBS=4 julia --project=. test/mutations/run.jl` | **`MUTATION REGISTRY: killed=140/140 baselines ok=62/62 wall=670.67 s`, exit 0** | **11 m 11 s** real | `13:01:17 up 4:13` load 0.89/2.03/2.59 → `13:12:28 up 4:24` load 5.06/4.58/3.89 |
| critic mutants (12 isolated target runs + 4 whole-suite runs) | see §2 | 7–31 s each | `13:20` load 5.25/3.58/3.43; `13:30` load 5.08/4.95/4.28 |

Suite walls reproduced from the log: **TB0 body 15.528 s** (warning 45.0, hard limit 60.0),
**TB4 body 4.706 s** (budget 5.0), **TB5 body 23.011 s**; inside TB5,
`construction = 1.36`, `transcripts = 0.461`, `product = 2.777`,
`construction allocation MiB = 342.1`, `process peak RSS MiB = 1623.1`.
The registry wall (670.7 s vs the proposer's 595.4 s) is inflated because my
independent recomputation scripts ran concurrently; every mutant result is
unaffected (each runs in its own process with an unmutated baseline).

## 1. Independent recomputation (own code, on a copy)

I wrote a standalone module `Indep` (own GF(2^k) arithmetic, own reader for the
`0xC3`/`0xC1` byte grammars, own re-serializer, own FNV-1a, own `def:cl-func`
evaluator with `chi`/`L_lnf` re-derived from `gt-07-ldt.tex:216-223` and
`gt-03-prelim.tex:375-384`, own anchor/detype/repeat query machines, own
framed-tuple parser and anchored predicate, own `lem:cl-kth` replay). It calls
**no** package decoder or interpreter. Results:

1. **Leaf sizes and pair layout.** `|S|` = **130 / 244 / 292** bytes for
   `describe_cl(L_Point/L_ALine/L_DLine,·,8)`; own re-serialization is byte-identical;
   own FNV-1a matches (`286fe47d0779fa2d`, `25b73864f874f331`, `d0a1fadd6465c017`).
   Header is literally `c3 01 00 00 00 08` and `|S| = 6 + 2·|single-CL body|`
   (62/119/143), i.e. `0xC3 01 q ‖ termA ‖ termB` confirmed.
2. **Compact loop.** `|S^rep| = 85` bytes at λ = 1, 2 **and 3**, with
   k(9) = 81 / 324 / 729 and dimension 729 / 2916 / 6561; own re-encode matches;
   hashes `925f2085c0763b30` / `0bc8eaca98ece463` / `a0aad296049b54ee`.
   `|D^rep| = 63`, `|S^anch| = 68`, `|D^anch| = 46`, `|S_copy| = 66`.
   The repetition is genuinely a loop term: `description_size` is independent of k.
3. **Four query modes, all 8^5 seeds.** Own evaluator vs the package's `query`:
   `65536/65536`, `131072/131072`, `196608/196608` marginal agreements
   (Point/ALine/DLine × every legal j × both players); **distinct reachable
   prefixes 1 / 9 / 297**; `Factor` agrees at every reachable prefix and `Linear`
   at every factor basis vector (5 / 19 / 593). Boundary reproduced: `QueryError`
   for j = 0, j > ℓ, `w = carol`, a short seed, a type on an untyped description
   and an unreachable `Factor` prefix, while `Linear` on the *same* prefix is
   accepted (`gt-04-cl.tex:L588-L594`'s asymmetric domain).
4. **§9.2 replay counts, recomputed by my own replay.** Exhaustive 8^5:
   `space_sum` and `map_sum` true, 32768 completed, **distinct chains 1 / 8 / 288**.
   Typed anchor per (player,type): chains 1, replays 2, both obligations true.
   `S^anch` exhaustive 2^9: **18 chains / 512 replays**, both true, and 0/3072
   mismatches against the package's marginals. `S^rep` on 32 seeds of my own:
   both true, 0 mismatches, and each 9-bit block of the repeated marginal equals
   the anchored marginal of that block's seed. `enu:cl-space-sum`/`enu:cl-map-sum`
   are driven through the *description's* four queries (`DescribedCL`) and are
   red-capable there (`M-validity`, `M-zero-promotion`, `M-factor-partition` all
   KILLED), not merely inherited from TB1.
5. **DL9 laws, recomputed.** `direct_sum(P,D)`: field 8, level 3, dimension 10,
   bytes 426 = 2 + 4 + 129 + 291 (**not** 130 + 292). `product(T_ora,T_pcp)`:
   3 × 18 = 54 types, 9 × 324 = **2916** oriented edges = 54² (tensor, and
   `("oracle,Point_1","alice,DLine_6")` present — `gt-10:L1949-L1955` verified
   verbatim), dimension 2 + 38 = 40, level 3, field 2048. `downsize(ALine)`:
   field 2, level 2, dimension 5·log2 8 = 15. `detype`: ℓ+2 and s(n)+4·TypeCount.
6. **Anchoring.** Type set `["Game","Anchor"]`, complete graph with both
   self-loops = 4 oriented edges; `Marginal(Anchor,·) = 0`; `Factor(Anchor,1,0) = [1]`
   (whole ambient) and `QueryError` off `{0}` — the literal all-zero report at
   `gt-11:L96` is repaired exactly as `rk:higher-level` (`gt-04:L122-L130`,
   re-read: `V_1 = V`, `V_{>1} = {0}`) prescribes. Detyped: level 3, dimension 9.
   The detyped graph views match `fig:graph-distribution` and
   `def:detyped-CL`/`gt-06:L419-L420` exactly, re-derived by hand.
7. **Repetition.** B(9) = (1·9)^1 = **9**, k(9) = (1·9)^{(1+1)·1} = **81**,
   level 3, dimension 729. `gt-12:L70` prints `(λn)^τ` while `gt-11:L200` and
   `gt-12:L355` print `(λn)^{(1+c′)τ}` — the finding is confirmed verbatim.
   See **O3** and **O4** for two defects in this area.
8. **Transcripts.** 128/128 honest repeated pairs accept with exactly 81 child
   calls (my own predicate); `T5-game-seed1` reproduces `x = 101100101`,
   `y = 001010111`, accept at (1,1) and reject at (0,1); `T5-anchor-one`
   reproduces `x = 011100010` and rejects an Anchor answer 1; the 10-bit
   component, the oversized answer, the 80-tuple and the trailing bit all reject
   **with an empty child-call log**, the exactly-9-bit question component accepts.
   See **O8** for what those 128 accepts actually cover.
9. **Sampler independence.** Structural, as it should be: the sampler term never
   embeds a decider term, so `copy_decider`/`trivial_decider` give byte-identical
   `S^rep`; dependency set `{hash(S), :lambda, :tau, :c_prime}`. See **O10**.
10. **CITED labels.** All ten CITED leaves of the Repeat tree carry a
    `\label{…}` inside their declared range: `lem:cl-kth`@151, `def:sampler`@573,
    `lem:cl-func-prod`@316, `lem:cl-concat`@283, `lem:downsize_sampler`@667,
    `lem:detyping-verifiers`@445, `def:typed-sampler`@96, `thm:ar`@2077,
    `prop:anchoring`@113, `thm:repetition`@230.
11. **Certificate census (recomputed).** **55 nodes: CONSTRUCTED 9, CHECKED 27,
    CITED 10, ASSUMED 4, SOURCE_REPAIR 5**; every CHECKED node carries a replay;
    `verify_certificate` = true. Two CHECKED nodes (`SamplerValidity`, `pad_level`)
    carry a `SOURCE_REPAIR` child — that is the intended disclosure pattern of
    definitions §G, not a strength inversion, and the literal reading is itself
    red-tested by `M-factor-partition`.

Everything in items 1–11 that the proposer reported is **correct**. The
objections below are about coverage, over-strict predicates, an unreported
source inconsistency, and lockstep.

---

## 2. Objections

### O1 — MAJOR. The repeated AND is not red-covered at the last component index

**Location.** `src/descriptions/deciders.jl`, `_decide(term::(:Repeat,…))`, the
`for i in 1:k … verdict &= accepted` loop; `test/tb5_repeat.jl` testset (g),
`T5-one-corrupt` (`i = first(game_blocks)`).

**Computation.** I mutated, on a copy, `verdict &= accepted` →
`i < k && (verdict &= accepted)` (all k child calls still made and logged; only
the *last* component's verdict is discarded). Result:

```
CRIT-1  target=tb5_transcripts  baseline=0 mutant=0 => SURVIVED
        tb5_repeat, tb5_anchor, tb5_tree, tb5_laws, tb5_replay => SURVIVED
        TB5_TARGET=all exit=0 ;  FULL SUITE exit=0
```

Witness on a copy, seeded with the all-Game seed `z = repeat(z1, 81)` so that
every one of the 81 components is a genuine `(Game,Game)` edge view:

| corrupted component | clean tree | CRIT-1 mutant |
|---|---|---|
| 1  | reject | reject |
| 40 | reject | reject |
| **81** | **reject** | **ACCEPT** (one child call still rejects) |

`T5-one-corrupt` picks `first(game_blocks)`, which is essentially never index k;
`repeat_decider`'s own replay only asserts `length(honest[2]) == k` plus the four
guard rejections; `M5-or` (AND → OR) is killed by any single corrupted
component and does not constrain the index. Nothing in the corpus pins the
final index.

**FIX DEMAND.** Add `T5-last-corrupt` to `test/tb5_repeat.jl` (g): build the
all-Game transcript `zrep = repeat(z1, 81)`, flip `as[81]`, assert
`!bit && length(calls) == 81 && count(c -> !c.accepted, calls) == 1 && !calls[81].accepted`;
register an owned mutant `M5-and-drops-last` with exactly the replacement above
in `test/mutations/tb5_repeat.jl` and show it KILLED.

**SURVIVING WEAKER STATEMENT.** The repeated decider rejects when a component at
a **non-final** index is corrupted, and makes exactly k logged child calls; no
evidence excludes a wrapper that ignores the k-th component's verdict.

---

### O2 — MAJOR. `DL9-repeat`'s per-block `Factor` law is not red-covered

**Location.** `src/descriptions/machines.jl`, `_factor(m::RepeatMachine, …)`;
`src/descriptions/transformations.jl`, `_metered_node` (`0 <= c.factor <= expected`).

**Computation.** `gt-11:L280-L284` fixes `V^{rep,w}_{j,u} = ⊕_{i=1..k} V^w_{j,u_i}`.
I mutated, on a copy, the repeated `Factor` so that block 1's child factor is
computed once and replicated to all k blocks:

```
CRIT-2  targets tb5_repeat, tb5_replay, tb5_transcripts, tb5_tree,
        tb5_laws, tb5_queries  =>  ALL SURVIVED
        TB5_TARGET=all exit=0 ;  FULL SUITE exit=0
```

Three independent reasons the corpus cannot see it:
(a) for `V_copy` the detyped stage-1/2 factors are the graph registers and the
stage-3 factor is `[0,…,0,1]` for **every** prefix, so the answer value cannot
change; (b) `_metered_node` pins `Marginal` exactly but bounds `Factor`/`Linear`
only from above, so dropping 80 of 81 child `Factor` calls is invisible;
(c) no test issues a repeated `Factor` with an unreachable prefix in a block
other than the first, so the per-block domain check is never exercised.

I built a red witness on a copy: a level-3 `F_2` child on `F_2^4` whose stage-2
factor register is `{2}` or `{2,3}` depending on the stage-1 bit (both spellings
cover the ambient, so the child's own certificate passes). With λ=τ=c′=1, n=2
(k=4, dimension 16) and the reachable prefix `u = e_1`:

```
clean :  Factor(S^rep,2,alice,2,u) = [0,1,1,0 | 0,1,0,0 | 0,1,0,0 | 0,1,0,0]
         = gt-11:L281 expectation ;  verify_certificate(repeat_sampler) = true
CRIT-2:  Factor(S^rep,2,alice,2,u) = [0,1,1,0 | 0,1,1,0 | 0,1,1,0 | 0,1,1,0]
         WRONG ;                     verify_certificate(repeat_sampler) = false
```

So the fixture, not the checker, is the weak point: the same certificate rows
*do* kill the mutant once a non-degenerate child is supplied.

**FIX DEMAND.** (i) In `_metered_node`, pin `Factor` and `Linear` exactly when
`!at_most` (`c.factor == expected && c.linear == expected`), not `<=`;
(ii) add to `test/tb5_repeat.jl` (f) the prefix-dependent-factor repeat fixture
above (or, minimally, `Factor(S^rep, 9, :alice, 2, u)` with `u` supported only in
block 2's opposite-vertex register, asserting `QueryError`); (iii) register an
owned mutant `M5-repeat-factor-block1` with the replacement above and show it KILLED.

**SURVIVING WEAKER STATEMENT.** For the `V_copy` fixture — whose detyped factor
registers are prefix-independent at every stage — the repeated `Factor` answer
equals the blockwise concatenation and the per-`Marginal` child-call count is
exactly k(n); no evidence shows that a general child's *per-block* factor spaces
and per-block prefix domains are used.

---

### O3 — MINOR. The k(n)-integrality predicate is stronger than DESIGN §10.2 and prints a falsehood

**Location.** `src/descriptions/laws.jl`, `evaluate_law`, the `^` branch;
`src/repeat/repeat.jl`, `_integrality_node`; `test/tb5_repeat.jl` (f).

**Computation.** DESIGN §10.2: "The description is valid only when this
expression denotes a positive integer." The code instead requires the *exponent*
`(1+c′)τ` to be integral. At λ=1, τ=1, **c′ = 1/2, n = 9** the exponent is 3/2 but
`k(9) = 9^{3/2} = 27` is a positive integer. Measured on the archived tree:

```
c'=1//2, n=9 : (1+c')tau = 3//2 ; k = 9^(3/2) = 27 (an integer)
package Dimension = QueryError("k(n) = 9^3//2 is not an integer:
                               the exponent (1 + c')tau is not integral")
```

The message asserts something false, `KRepIntegrality` would grade `FAIL` on a
legal description, and `Dimension`/`decide` become unavailable for it. The only
test uses `c_prime=1//2, tracer_index=2` and reads `Dimension(…, 3)`, where
`3^{3/2}` really is irrational — so the over-strictness is invisible.

**FIX DEMAND.** Decide integrality of the **value**: evaluate `(λn)^{(1+c′)τ}` as
an exact rational power (integer root extraction) and admit it iff the result is
a positive integer; correct the message to name the actual quantity. Add a red
test at λ=1, τ=1, c′=1//2, n=9 expecting `k = 27`, dimension 27·9 = 243.

**SURVIVING WEAKER STATEMENT.** For integral `(1+c′)τ` the stored `k(n)` law
evaluates exactly and the toy substitution c′ = 1 gives k(9) = 81; the
implemented refusal is sufficient but not necessary for `k(n) ∈ N`.

---

### O4 — MINOR. An unreported source inconsistency at `gt-11:L219-L220`, hidden by c′ = 1

**Location.** `REPETITION_COUNT_FINDING` (`src/repeat/repeat.jl`) reports only the
`gt-12:L70` conflict; DESIGN §10.2 "Source finding" likewise.

**Computation (mine, from the TeX).** `gt-11:L219` sets the per-component guard
at `(λn)^τ`. `gt-11:L220` then states: "as long as `TIME_{D^anch}(n)` is at most
`(λn)^{τc′}`, then the strings x,y,a,b never need to be longer than
`k(n)·(λn)^τ = (λn)^{(1+2c′)τ}`". But

```
k(n)·(λn)^τ = (λn)^{(1+c′)τ} · (λn)^τ = (λn)^{(2+c′)τ},
(2+c′)τ = (1+2c′)τ  ⇔  c′ = 1.
```

Conversely, L220's printed right-hand side is correct only if the per-component
bound is `(λn)^{τc′}` — contradicting L219 one clause earlier. Either way L219/L220
are internally inconsistent unless c′ = 1. TB5 substitutes exactly c′ = 1, which
collapses `(λn)^τ`, `(λn)^{τc′}` and the two exponents, so `B_rep`, DD-26 and the
whole boundary suite cannot distinguish the two readings.

**FIX DEMAND.** Add a `SOURCE_REPAIR`/`ASSUMED` node (e.g. `RepeatGuardExponent`)
beside `RepetitionCountInconsistency` recording the L219/L220 tension, stating
that `B_rep(n) = (λn)^τ` implements the L219 reading, and noting that the toy
c′ = 1 identifies the two candidate guards; mirror the sentence in DESIGN §10.2.

**SURVIVING WEAKER STATEMENT.** `B(n) = (λn)^τ` is the literal L219 guard and is
what DD-26 enforces; at c′ = 1 it coincides with the guard L220's arithmetic implies.

---

### O5 — MINOR. Printed TB5 targets are not the enforced gates; the allocation figure is not the quantity §10.3 names

**Location.** `test/tb5_repeat.jl`: `println("… (target < 2)")` next to
`@test TB5_LOG[:construction_seconds] < 20`; `println("… (target < 5)")` with **no**
assertion at all on the transcript wall; `TB5_LOG[:construction_alloc_MiB] = stats.bytes/2^20`.

**Computation.** `@timed(…).bytes` is **total bytes allocated**, not peak live
memory. The measured 342.1 MiB is therefore not comparable with DESIGN §10.3 /
§13.1's "peak allocation target `<256 MiB`", and no peak figure exists anywhere
(the printed 1623.1 MiB is process `maxrss`, dominated by TB0). The construction
gate is 10× looser than the printed target (measured 1.36 s, so it passes either
way, but a 19 s regression would be green).

**FIX DEMAND.** Assert the actual §10.3 numbers (`construction < 2`,
`transcripts < 5`, `total < 7`) or amend §10.3/§13.1 to the measured budget in
the **same** edit; relabel the printed figure "total allocated during
construction" and either measure a real peak (GC live bytes / RSS delta around
the construction) or delete the peak-allocation target from §10.3 and §13.1.

**SURVIVING WEAKER STATEMENT.** Construction 1.36 s and transcripts 0.461 s are
within the §10.3 targets on this box; the allocation target is unmeasured.

---

### O6 — MINOR. The 55-node census is printed, not pinned

**Location.** `test/tb5_repeat.jl` (j): `@test grades[CHECKED] >= 8 &&
grades[CITED] >= 5 && grades[SOURCE_REPAIR] >= 2`.

**Computation.** I recomputed the tree independently: 55 nodes, CONSTRUCTED 9,
CHECKED 27, CITED 10, ASSUMED 4, SOURCE_REPAIR 5, every CHECKED node with a
replay — the report's numbers are exactly right. But the assertions are lower
bounds ~3× below the true values, so no mutant can ever be killed by a change to
the census (e.g. silently dropping a `SOURCE_REPAIR` disclosure or two CITED leaves).

**FIX DEMAND.** Assert the exact tuple `(55, 9, 27, 10, 4, 5)` and
`all(n.grade == CHECKED ⇒ n.replay !== nothing)` over the whole tree, or remove
the counts from C13's evidence.

---

### O7 — MINOR. Lockstep: DESIGN §9–10 vs code

(a) DESIGN §10.2 states `question_length(n), answer_length(n) <= k(n)*B(n)`; the
code emits `:(k(n) * (B(n) + 32))`. (b) DESIGN §9.2 has no non-additivity
sentence for `description_size` (I measured 130 + 292 → **426**). (c) DESIGN
§9.4's table prints `O(...)` on four query-time cells while `expected_laws` and
`_term_laws` emit the bare expressions (`:(2 + (C_1(n) + C_2(n)))`,
`:(k(n) * C_1(n))`, …) — DD-24 makes `O(...)` the CITED marker, so the table and
the emitted AST disagree on the grade of the same cell. (d) DESIGN §9.4's rows
`anchor(v)` (level ℓ+2, dim s+8) and `anchored_repeat(v,λ,τ)` (level ℓ+2, dim
k(n)(s(n)+8)) are the **public** composites, but the `LawCert`s *named*
`DL9-anchor` and `DL9-repeat` check the **internal** rows (typed anchor: level
`ell_1`, dim `s_1(n)`; `repeat_sampler`: level `ell_1`, dim `k(n)·s_1(n)`). The
public numbers appear only in CONSTRUCTED display strings and in test assertions.

**FIX DEMAND.** Land (a) and (b) as proposed (adjudicated in §4 below), and add
two §9.4 sentences covering (c) and (d) so a reader cannot mistake which row a
`DL9-*` LawCert checks.

---

### O8 — NOTE. The "128 honest accepts" are 98.5 % accept-on-invalid

**Computation (mine).** Over the same 128 × 81 = 10368 repeated components, only
**159 (1.53 %)** present a valid oriented-edge graph view at all, and only
**40 (0.39 %)** are `(Game,Game)` pairs that actually reach the copy decider.
This is forced arithmetic, not a bug: a valid alice/bob view needs
`z_eA = z_eB = (1,1)` and `z_vA, z_vB` unit — probability 1/64 per block, of
which 1/4 is `(Game,Game)`. The remaining 98.5 % exercise `detype_decider`'s
literal accept-on-invalid branch (`gt-06:L426`).

**FIX DEMAND.** Print the per-run (edge-view, `(Game,Game)`) component counts
beside the 128, add them to the C13 row, and keep the all-Game seeded transcript
(`repeat(z1, 81)`) as a declared chain alongside the random one — it is also
what O1's red test needs.

---

### O9 — NOTE. The leaf `DescribeCL` LawCert is near-tautological

`_leaf` builds `expected` **from the description it is checking**
(`level = S.level`, `dimension = Dimension(S,n)`, `field = q`), and `_term_laws`
sets a leaf's laws to the machine's own values, so `expected == actual` holds by
construction; `expected_laws(:DescribeCL)` is dead code. The node is not
worthless (its sibling `AdapterReplay` is substantive, and I verified it
exhaustively at 8^5), but as a CHECKED "transcription check" it carries no
information. Either drive it from `expected_laws(:DescribeCL)` or drop it.

### O10 — NOTE. Dependency-set semantics and the extra `c_prime`

`_dependency_walk!` pushes the **symbols** `:lambda, :tau, :c_prime`, while the
docstring says "every parameter literal it carries". Consequence: λ = 1 and λ = 2
have the *same* dependency set although their bytes differ (`925f2085c0763b30`
vs `0bc8eaca98ece463`). Symbols are the right reading of `gt-11:L257`, so fix the
docstring, not the code. Separately, `gt-11:L257` says `S^rep` depends only on
`S, λ, τ`; the executable's `S^rep` bytes additionally encode `c′` (a *universal*
constant in the source). C13 should say so explicitly rather than letting
`{hash(S), lambda, tau, c_prime}` read as the paper's set.

### O11 — NOTE. `completeness_decider_time` is evaluated at the wrong index

`REPEAT_CONTRACT`'s hypothesis uses `big(2*p.lambda)^p.tau` — i.e. n = 2 — while
the fixture's tracer index is 9 and `B(9) = 9`. The grade is `NOT_EVALUABLE`
either way (the bound is `Opaque`), so nothing is wrong today, but the printed
predicate is not the one C13 names. Bind it to the construction index.
Related: `_normal_form_status(::VerifierDescription)` checks only `field == 2 &&
untyped` (correct per `def:normal-ver`, `gt-05:L624-L634`, which I re-read), yet
its display asserts "decider a total five-input predicate" and deviation (5)
claims a "total decider" check. Weaken the display to what is checked.

### O12 — NOTE (elegance). Three places the code is more complicated than the mathematics

1. `_padded_marginal`/`_padded_linear`/`_padded_factor` plus `_require_image`
   (`machines.jl` L108–L160) re-derive "`u ∈ L_{≤r}(V)`" by rebuilding each stage's
   column space out of `Factor` + `Linear` calls at the parent. The identical
   predicate already exists structurally as `_walk_prefix`/`_in_column_space`.
   The duplication exists only because padding lives at the parent instead of
   being a `Pad` node in the term grammar; a `(:Pad, extra, S)` tag would delete
   `_require_image` entirely.
2. `dependency_walk` has two conventions for one walk: a **top-level** leaf is
   `{:S}` while an **embedded** leaf is its hash; and `_decider_dependencies` /
   `_decider_leaf_hashes!` each push `:lambda,:tau,:c_prime` for `:Repeat`, so the
   same three symbols are pushed twice on nested repetitions. One recursive walk
   with one leaf rule and an explicit top-level alias would be shorter and clearer.
3. `_law_cert` builds a display string, an expected/actual AST pair, a numeric
   evaluation and a replay closure in one function, and its `evaluations`
   NamedTuple silently changes `dimension` from `Int` to the **string**
   `"NOT_EVALUABLE: …"` on failure — a stringly-typed error channel inside a
   sort where `QueryError` already exists for exactly this purpose.

---

## 3. Claim decisions

### C12 — **PROMOTE to TESTED**, with the scoping sentence below appended verbatim

Everything C12 asserts was independently reproduced (§1 items 1, 3, 4, 5, 6, 9),
its CHECKED rows are red-capable at the description level, and 140/140 mutants
are KILLED with 62/62 baselines. Apply the proposer's proposed C12 statement
**verbatim** (briefs/39-tb5-descriptions-repeat.last.md, MERGE PROPOSAL 1) with
these two sentences appended, verbatim and unparaphrased, before "Semantic
implications stay CITED":

> The per-block `Factor`/`Linear` clause of `DL9-repeat` is checked only on
> fixtures whose child factor spaces and prefix domains are prefix-independent,
> and the metered `Factor`/`Linear` counts are bounded above rather than pinned,
> so a wrapper answering every block from block 1's child factor is not excluded
> by the current tests (verdicts/tb5-r1.md O2). The leaf `DescribeCL` `LawCert`
> derives its expected AST from the description it checks and carries no
> independent transcription content; the leaf evidence is its `AdapterReplay`
> (verdicts/tb5-r1.md O9).

`depends-on C4a,C4b`; `where-tested test/tb5_repeat.jl` (a)–(e); mutants as proposed.

### C13 — **PROMOTE to TESTED**, scoped weaker row (the tb4-r1 pattern)

The fixture, the levels/dimensions `1,1 → 3,9 → 3,729`, `B = 9`, `k = 81`,
`|S^rep| = 85` independent of k (verified also at λ = 3), `|D^rep| = 63`, the four
named transcripts, the DD-26 guard with an empty child-call log, and sampler
independence were all independently reproduced. The AND clause, however, is
red-covered only away from the final index (O1). Apply the proposer's proposed
C13 statement **verbatim** with these three sentences appended, verbatim:

> The repeated AND is red-covered only at non-final component indices: a decider
> that discards the k-th component's verdict passes the whole suite
> (verdicts/tb5-r1.md O1). Of the 128 × 81 = 10368 honest components, 159 present
> a valid oriented-edge graph view and 40 are `(Game,Game)` pairs reaching the
> child decider; the remaining components are accepted by the literal
> accept-on-invalid branch of `gt-06:L409-L427` (verdicts/tb5-r1.md O8). `S^rep`
> additionally depends on the toy `c'`, which `gt-11:L257` treats as a universal
> constant rather than a parameter, and the stored `k(n)` term is refused
> whenever `(1 + c')tau` is non-integral even where `k(n)` is a positive integer
> (verdicts/tb5-r1.md O3, O4).

`depends-on C12`; `where-tested` (e)–(j); mutants as proposed. The full-strength
AND clause and the general per-block `Factor` clause are the tracked repair for r2.

---

## 4. DESIGN / definitions adjudication

| proposal | decision |
|---|---|
| §9.2 "`description_size` is the exact byte length of the composite's canonical term; it is not additive under `direct_sum`" | **APPROVED verbatim.** Verified: 130 + 292 → 426 bytes. |
| §9.3 the N31 canonical-order rule of deviation (7), and "the k-fold repetition is one `Repeat` term, never k children" | **APPROVED verbatim.** Verified: 85 bytes at λ = 1, 2, 3. |
| §10.2 the framing sentence of deviation (1) | **APPROVED, with the replacement made explicit**: the block `question_length(n), answer_length(n) <= k(n)*B(n)` must be **replaced** by `k(n)*(B(n)+32)` (not merely annotated), and the sentence must name `SOURCE_REPAIR(RepeatTupleFraming)` and `gt-11:L216-L220`. Until that edit lands, DESIGN and the code disagree (O7a). |
| Calibration-ratio gate (tb1-r5 N33 / addendum 3c) | **APPROVED WITH CONDITIONS.** (i) keep `elapsed < 60` as a hard gate and let `TB0_BUDGET_SECONDS` only *lower* it, as proposed; (ii) name the calibration kernel and its measured quiet-run value in DESIGN §13.1, and require it to be deterministic, in-process and **excluded** from the timed body; (iii) the ratio gate must be a hard `@test`, never a warning; (iv) **a red test is mandatory** — an owned mutant that inflates the TB0 body (e.g. a doubled inner loop) must fail the ratio gate on a box where the absolute gate still passes. Without (iv) the new gate is a CHECKED artefact with no mutant, which is exactly what law 4 forbids. (v) The same discipline applies to the TB5 walls: fix O5 in the same edit. |
| *Critic-added, required* | §9.4 must state (1) that the table's `anchor(v)`/`anchored_repeat(v,λ,τ)` rows are the **public** composites while the `DL9-anchor`/`DL9-repeat` `LawCert`s check the **internal** typed-anchor and `repeat_sampler` rows (O7d), and (2) that the `O(...)` in the table's query-time cells is dropped in the emitted ASTs, which are never evaluated (O7c). §10.2 must gain the O4 source finding. |

`docs/definitions.md` §G–H needs no change: `SamplerDescription`,
`TypedSamplerDescription`, the four queries, `DeciderDescription`,
`VerifierDescription`, `QuotedLaw/LawCert`, `Game/Anchor/anchor`,
`anchored_repeat`, `c_prime`, `k_rep`, `B_rep` and
`SOURCE_REPAIR(zero-map-factor-partition)` all match the code as built. The one
addition I require is a clause on the `k_rep(n)` row recording O3's
exponent-vs-value distinction once it is fixed.

---

## 5. TB6 readiness (brief 43)

1. **TB6a (source audit: type/edge counts, schemas, query plan) — YES, no design round.**
2. **TB6b — NO: two short design decisions are needed first.**
3. **Blocker 1 (the API REQUEST, real).** Descriptions are *data* for the two
   fixed Julia interpreters `query`/`decide`; `Meter` counts child **calls** by
   mode at depth 1 only, and `_validated_answer` deliberately runs its sizing
   `Dimension` probe on a fresh `Meter`. TB6's `F_child`/`toy_child_fuel` must
   count **quoted-interpreter steps of the child sampler/decider** (§11.4). No
   such unit exists. Decide it in DESIGN §11.4 before brief 43 (a step meter
   inside `_decide`/`_validated_answer`, or lowering into the §1.1 `Eval` fuel).
4. **Blocker 2.** The decider grammar has no general typed term: `_decider_typing`
   returns the hard-wired `ANCHOR_TYPING` for `:TypedAnchor` and `Untyped()`
   otherwise. `typed_intro_decider` (7-input, 34–38 types) needs a `Typed(TypeSet)`
   decider term that carries its labels in the bytes — one grammar tag, but it
   must be designed, not improvised.
5. **Gap 3 (cheap).** `detype_decider`/`_decide(:Detype)` iterate an **oriented**
   edge list; `G^pauli` (26 loops + 30 non-loops, 86 oriented pairs) and `G^intro`
   are specified undirected. Fix the convention once, in §9.5.
6. **Gap 4 (cheap).** `_SAMPLER_TAGS` has 8 tags; `pauli_sampler`, `tilde_S_intro`
   and `graph_sampler` need their own primitive tags plus the mandatory §9.6 rows.
7. **Gap 5.** `Meter` is depth-1 only, so §11.6's "per-mode costs" of a nested
   introspection sampler cannot be attributed; generalise it with the step meter of (3).
8. **Risk to measure before TB6b.** `_require_image` rebuilds each padded stage's
   column space with `|support|` `Linear` calls; at dimensions 142/179 and level 5
   that is affordable, at TB7's 206→1696 it is not. Measure it in TB6a.
9. **Ready and reusable as-is:** the four-query API (exhaustively verified),
   both leaf adapters, `direct_sum`/`product`/`downsize`/`detype`/`anchor` with the
   zero-map promotion, `decide_traced` with a child-call log, `StageVerifier` +
   `params` on the `CompressStage` surface, and the five mandatory certificate rows.
10. **Also carry O1/O2's fixes into TB6:** the metered `Factor`/`Linear` counts
    must be pinned exactly, and every AND/OR combinator must have a last-index
    red witness, before the introspection decider's multi-check conjunction lands.

---

VERDICT: FAIL(O1,O2)
