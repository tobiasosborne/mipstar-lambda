# Verdict — TB6 r2 (brief 81). Critic: Opus, 2026-09-22. Target: archived tree `0db7811`.

Lane: this file only. Nothing else in the repo was written; no state-changing git ran.
Everything below was run on `git archive 0db7811 | tar -x` in
`…/scratchpad/critic-tb6-r2/tree`; `claims/CLAIMS.md` was read live. Recomputations are by hand
from the code/TeX or with my own code on copies (`…/critic-tb6-r2/own/E_experiments.jl`,
`own/C5_demo.jl`, mutated copies `tree-crit5/`, `tree-crit6/`), never from the package's printed
numbers. Ground truth cited by `gt-*.tex` line.

---

## 0. Runs, walls, load (4-core cloud container, Julia 1.12.7, no governor; walls advisory)

| run | result | wall | `uptime` load, before → after |
|---|---|---|---|
| `Pkg.instantiate()` + precompile | exit 0; `189865.5 ms ✓ MIPStarLambda` | 190 s | → 19:07:06 `1.62 1.64 2.68` |
| `julia --project=. test/runtests.jl` | **`MIPStarLambda | 12474  12474  4m22.5s`, exit 0** | 266 s | 19:07:27 `1.16 1.53 2.62` → 19:11:53 `1.00 1.21 2.20` |
| `MUTATION_JOBS=4 julia --project=. test/mutations/run.jl` | **`MUTATION REGISTRY: killed=216/216 baselines ok=85/85 wall=1632.4 s`, exit 0** | 1633 s | 19:32:45 `0.79 1.03 1.35` → 19:59:58 `3.49 3.93 3.59` |
| CRIT-5 copy, full suite | 12474/12474, exit 0 → **SURVIVED** | 263 s | 19:16:03 `0.69` → 19:23:40 `1.01` |
| CRIT-6 copy, full suite | 12474/12474, exit 0 → **SURVIVED** | 263 s | 19:23:40 `1.01` → 19:31:14 `1.02` |
| `test/tb7_compress.jl` standalone | 1/1, exit 0 | 64 s (test 61.9 s) | after the registry |

Gate lines of my suite run (kernel `0.7787 s`):
`TB0 test-body wall seconds = 31.455 … ratio = 40.4 (gate 50.0)`;
`calibrated gate tb6a_audit: elapsed = 5.088 s … ratio = 6.53 (gate K = 18 …); absolute ceiling 35.0 s`;
`calibrated gate tb6b_E: elapsed = 8.859 s … ratio = 11.38 (gate K = 33)`;
`tb6b_M: 5.096 s, ratio 6.54 (K = 21)`; `tb6b_combined: 13.955 s, ratio 17.92 (K = 54)`;
`tb5_construction 0.72 (K 4)`, `tb5_transcripts 1.12 (K 4)`, `tb5_total 1.84 (K 6)`;
TB4 ratio 20.2 (gate 38). Registry: every one of the 216 lines is labelled `KILLED` (none
`KILLED-BY-CRASH`, `SURVIVED`, `LOAD-ERROR`, `UNATTRIBUTABLE`, no `BROKEN` baseline), including
`MUTANT TB0 M-gate-body-inflated tb0_body_run_three_times target=tb0_gate => KILLED (exit=1, 310.26 s)`,
`TB6 M6a-gate-body-inflated … => KILLED`, `TB6 M6b-gate-body-inflated … => KILLED`,
`TB5 M5-gate-body-inflated … => KILLED`, the 13 conjunct drops, `M6-forced-outcome-free`,
`M6-nested-depth`, `M7-lower-sampler-arity`. 37 `TB6` + 4 `TB7` mutants in this registry.

---

## 1. Independent recomputation

**(1) D1's thirteen conjuncts — count, isolation, kill attribution.** Re-derived from
`_intro_ordered` (`src/introspect/intro_decider.jl` L329–L430) against `fig:intro-decider`
(`gt-08-introspection.tex:L436–L478`): 2(a) 1 comparison (`a_w^V = z_wbar`), 2(b) 2, 3(a) 2,
3(b) 2, 3(c) 4 (`y_<k`, `y⊥_≤k`, `x_>k+1`, the stage-`k+1` dual image), 3(d) 2 → **13**; the
`length(aw)==Q` guards of 2(a)/3(d), the parse guards and items 1/4/5 are not comparisons of 2(a)–3(d).
13 is right. With my own corruption code and my own field parser, every witness differs from its
honest leaf in **exactly one bit of exactly one parsed field, inside `V`** (coordinate ≤ s = 6),
is rejected through exactly its test with every child call returning. Then, re-evaluating
`_intro_ordered` with each registered drop mutant in turn (in-process, `invokelatest`), the
13×13 matrix "witness j accepted under drop-mutant i" is **exactly the identity**:

```
        C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13
C01       A   .   .   .   .   .   .   .   .   .   .   .   .
 …  (rows C02–C13 likewise: A on the diagonal only)
E1 kill matrix is exactly diagonal: true
```
So each conjunct-drop mutant is killed by ITS witness and by no other, and each witness hits only
its conjunct (the 3(c) witnesses share the fired name `:hiding_same`; the registry, not the fired
name, is what guards their isolation — a non-isolated witness would make its drop mutant SURVIVE).

**(2) The ten cost slots and the charge table, by hand from the `_charge!` sites.** TB6b-M child at
`N=4` (`1+ndigits(4;base=2)=4`), alice:
Dimension `4+1 = 5`. Marginal(3) at z* `4+2+6 = 12`; stage 1 (k=1) `1+1+1+1` + accumulate `1` = 5,
prefix e1 → stage 2 `[4,5]` (k=2) `2+4+2+1+2 = 11`, stage 3 `[2,3,6]` `3+9+3+1+3 = 19`; output 6 → **53**.
Factor(2,e1) `12`; walk key read 1; elimination on the 1×1 `[1|1]`: copy 2, pivot search 1, scale 2,
final scan 2 = 7; branch 1; support scan 6; indicator 6; output 6 → **39**. Linear(2,e1,e4)
`4+2+12 = 18`; walk `1+1`; scan 6; stage `2+4+2 = 8`; output 6 → **40**. Factor(3) `12`; stage-1 walk
`1+7+1`; stage-2 walk `2 + (6+2+3+1+6) + 1`; scan 6; indicator 6; output 6 → **60** (the metered value
at prefix e1+e4 is 60, own run). Linear(3) `18+2+3+6+15+6` → **50**. Decider `(:ZeroAnswers,[1,3])`:
`4 + (6+6+1+1) + (2+2)` → **22**. TB6b-E: Dimension 5; Marginal `4+2+1+5+1` → **13**; Factor
`4+2+1+1+1+1` → **10**; Linear `4+2+2+1+3+1` → **13**; `:Copy` decider `4+4+2` → **10**. All ten slots
and all four charge-table values reproduced (r1 did eight; the two decider slots are new).
The DESIGN §11.4 charge list as written does NOT reproduce them (N7): list-only Marginal(3) is
`12 + (4+9+16) + 6 = 47`, and no reading of the list reaches 39 for Factor(2,e1).

**(3) The one-currency overheads.** Own runs of `eval_program(lower_sampler(S), args)` minus the
metered steps: **10** for TB6b-E and TB6b-M samplers, all four modes (including `Linear`, which
TB6b (m) omits), and `Dimension(1024)` (metered 13, overhead still 10); decider overhead **8** at
input lengths (1,1,1,1) and (3,1,0,5) (metered 10 and 17). Invariant under query, description,
index and argument length, and equal to `arity + 3` in both cases (7+3, 5+3): a constant of the
lowering by construction, not a coincidence of the three queries.

**(4) `_require_image`.** Reproduced: 142 → 74,671/148, 179 → 113,946/185, **206 → 155,631/212**,
824 → 4,488,710/830, 1648 → 17,899,098/1,654 (walls 0.0004 s at 206, 0.0677 s at 1648). Structural
identity for the call counts at all five dimensions: `child_calls = dim + 6` = 5 `Factor` (one per
stage of the level-5 child) + `dim` `Linear` (the stage registers partition `V`, one call per basis
vector) + 1 `Factor` on the level-9 leaf. I did not re-meter the 155,631 steps step by step.

**(5) The nested decider (TB6b (k) setup), full budget sweep.** `by_depth = [22618, 15]`; my own
count of the enclosing charges: Detype decoding `1+2+142+142+3+3 = 293`, `8T = 272`, `8T·81 = 22,032`
(the matching oriented pair is 81st, T = 34), `+1`, TypedDecider input `2+6+6+3+3 = 20` → **22,618**;
depth 2 = Dimension 5 + `:Copy` 10 = **15**. Sweep of every budget 22,615…22,635: `FuelExhausted`
for B ≤ 22,617; `false` for 22,618 ≤ B ≤ 22,632; `true` for B ≥ 22,633 — monotone, the four points
TB6b (k) pins are on it. Same identity on TB6b-M's live edges: `(Hide_1_alice,Hide_2_alice)`
`by_depth = [21842, 207]` with Σ(flat child-call steps) = 207; `(Pauli_X,Hide_1_bob)` `[25442, 68]`,
Σ = 68 — i.e. the nested decider's own predicate work contributes **0** steps (N3).

**(6) Gate arithmetic.** `K = max(4, ceil(3·quiet_ratio))` re-derived for all seven rows (4, 4, 6,
18, 33, 21, 54); `quiet_ratio = quiet_seconds / 0.7825` for the six cloud rows and
`2.765/0.4798 = 5.76` for tb6a. Ceiling/quiet: 14.4×, 7.8×, 7.6×, 12.7×, 7.4×, 7.6×, 7.5× — the
"≥ 12× the quiet measurement" sentence is false for five rows (N6(v)); no ceiling or ratio gate
fired in any of the 85 baselines of my registry run under its 4-way load.

---

## 2. Objections

### N1 — MAJOR. The source's `V`-membership rejection has no negative witness: `_in_V ≡ true` passes the whole suite (CRIT-6)

**Location.** `src/introspect/intro_decider.jl` L231 (`_in_V`) and its uses in `parse_intro_answer`
L232–L252; `test/tb6b_introspect.jl` (j) and the `IntroDecider` replay L536–L547.
**Ground truth.** `gt-08-introspection.tex:L531–L534`: "if `y, y⊥` are not presented as vectors in
the subspace `V`, then the decider rejects"; answer key L406–L413 (`(y,y⊥,a) ∈ V×V×{0,1}*`).
**Computation.** In process: on `(Introspect_bob, Read_bob)` of TB6b-M, flip `y⊥` coordinate
s+1 = 7 of the Read answer (outside `V`): clean code rejects (parse), `_in_V ≡ true` **accepts**
(3(a) compares only `y` and `a`); honest leaves still accept. On a copy with that one-line change the
entire suite is `12474/12474, exit 0` (§0). This is `verdicts/tb6-r1.md` O1's defect class one layer
down: the thirteen comparisons are now red-covered, the parse-layer conjunct is not.
**FIX DEMAND.** Named out-of-`V` negative transcripts (at least `y⊥` on Read via 3(a), `z` on Sample
via 2(b), `x` on Hide via 3(d)), asserting rejection before any child call past `Dimension`; register
`M6-in-V` (`_in_V ≡ true`) shown KILLED; add one out-of-`V` case to the `IntroDecider` replay.
**SURVIVING WEAKER STATEMENT.** Every comparison of items 2(a)–3(d) has an isolated named negative
witness; the rejection of vectors not presented in `V` is implemented but untested.

### N2 — MAJOR. The steps a timed-out nested child executed can be dropped from the enclosing meter without any test failing (CRIT-5)

**Location.** `_child_query` L107 and `_child_decide` L215 (`_charge_parent!(c, ctx)` after a
timeout); `test/tb6b_introspect.jl` (k), which asserts only `short.steps <= total - 1`.
**Computation.** CRIT-5 = charge the parent only when `outcome == :return` (both sites). Full suite
on the copy: `12474/12474, exit 0` → SURVIVED. Own demo (`own/C5_demo.jl`, E (k) setup): budget
22,632 → clean `steps 22631, by_depth [22618, 13]` (the copy decider ran 8 steps before its refused
block), CRIT-5 `22623, [22618, 5]`; budget 22,622 → clean `22622, [22618, 4]`, CRIT-5 `22618, [22618]`.
The verdict is unchanged, so every current assertion passes; but DESIGN §11.4 ("charged to the
enclosing meter at depth + 1 as it returns … the depth-attributed steps sum to the total") is violated
and, in a caller that continues after a `false` (the `:Repeat` loop `verdict &= …` runs all k
components), the enclosing budget would again pay for steps already executed.
**FIX DEMAND.** Pin `short.steps == 22631 && short.by_depth == [22618, 13]` and the 22,622 point
(`[22618, 4]`); register CRIT-5 as `M6-nested-timeout-uncharged`, shown KILLED.
**SURVIVING WEAKER STATEMENT.** Nested verdicts equal the flat verdict and their boundaries
(throw < 22,618 ≤ reject < 22,633 ≤ accept) are pinned; the accounting of timed-out nested calls is not.

### N3 — MAJOR. "Nested typed deciders" (DESIGN §11.4) claims more than the code meters: the nested decider's own work and a nested answer-reduced body are uncharged

**Location.** DESIGN §11.4 paragraph "Nested typed deciders" ("A `TypedDecider` child (a detyped
introspection **or answer-reduced** decider …) is metered … Hence **no level ever executes a step
the enclosing budget could not pay for**"); `src/introspect/pauli_decider.jl` L282–L288
(`pauli_decide` and `_decide_answer_reduce(…, trace)` receive no `parent`);
`_decide_intro`/`_intro_ordered` charge nothing for their own comparisons, projections and the
`perp_map` elimination.
**Ground truth.** `gt-08-introspection.tex:L417–L419`: the enclosing decider "aborts and rejects if
the subroutine takes more than `N^λ` time steps" — the subroutine's whole running time, own work included.
**Computation.** §1(5): depth-2 steps equal the sum of the nested decider's child-call steps exactly
(15, 207, 68); the two `Linear` calls' 2×2 dual-map Gaussian elimination, four register projections and
three vector comparisons on the Hide_1/Hide_2 leaf cost 0. A nested `:AnswerReduce` body (the TB7
chain's middle stage) is charged only `2+|x|+|y|+|a|+|b|` for its whole PCP check.
**FIX DEMAND.** Either charge the nested body's own steps in the §11.4 unit at depth + 1 and thread
`parent` into the `:Pauli` and `:AnswerReduce` bodies (red test: a nested AR/intro body whose own
work alone exceeds the enclosing budget must time out), or restate §11.4 and C14 as "input decoding
and child calls only; own predicate work UNCHARGED (owner=tb7-nested-own-steps)" and pin the identity
`by_depth[2] == Σ child steps` as the documented gap. Owner of the code fix: brief 44 (the AR body is
in `src/compress/`); the DESIGN sentence must be corrected now.
**SURVIVING WEAKER STATEMENT.** A nested introspection body's input decoding is charged at the
enclosing depth and each of its child calls runs on a meter bounded by `min(F_child, enclosing
remaining)` and is charged at depth + 1 on return; nothing else a nested decider does is metered.

### N4 — MINOR. D1(d) was not done: the `IntroDecider` certificate replay carries none of the new witnesses

`intro_decider.jl` L536–L547 is unchanged from r1 (bit1–bit4 only), while brief 80 D1(d) required
the thirteen witnesses there and the report counts D1 as FIXED with no RESIDUE entry. The predicate's
red capability lives in `test/tb6b_introspect.jl` (j) and the registry only; `verify_certificate` does
not re-exercise it. **FIX DEMAND:** add the witnesses (and N1's) to the replay, or record D1(d) as
DOWNGRADED. **SURVIVING:** the witnesses and the diagonal kill matrix exist at test level.

### N5 — MINOR. D7's new measurements are printed, not pinned (O4's class, recurring)

`test/tb6a_audit.jl` (3) asserts 142 and 179 exactly but for 206 only `results[206].steps >
results[179].steps`; 824 and 1648 not at all; the actual TB7 chain dimensions 848/1696 are not
measured (824/1648 proxies); no wall gate. DESIGN §12.1 quotes `155,631`/`212`, `17,899,098`/`1,654`
and `0.0349 s` (my run: 0.0677 s) as MEASURED. **FIX DEMAND:** pin (steps, calls) at 206/824/1648 and
`child_calls == dim + 6`; say "proxy" in §12.1. **SURVIVING:** the D13 decision stands — the 1648 proxy
costs < 0.07 s, far below both thresholds.

### N6 — MINOR (lockstep). Stale or false DESIGN text beside the landed paragraphs

(i) §13.1 TB5 row "construction `<2 s`; transcripts `<5 s`; total `<7 s`" and §10.3 L1473 — the walls
are calibrated ratio gates (K 4/4/6) at `0db7811`; (ii) §11.6 "Targets are `<3 s` … `<15 s`" (E) and
"Feasibility target … must replace them" (M) — not replaced; (iii) §11.4 "costs and budget-fit results
remain `NOT_EVALUABLE(owner=tb6-child-meter)` until a quoted-interpreter trace exists" and §11.6
"C14 remains a proposal" — contradict the pinned slots and C14 = TESTED; (iv) §11.6 "pinned per
oriented pair" — the test pins the aggregate histogram and the SET of distinct per-pair counts
`{1,2,72,88,120,256}`, not a per-pair map; (v) §13.1 and `test/calibration.jl` "ceiling … (≥ 12× the
quiet measurement)" — false for five of seven rows (§1(6)). **FIX DEMAND:** correct each sentence.

### N7 — MINOR (lockstep; this corrects `verdicts/tb6-r1.md` §4 row 1, which approved the list). The §11.4 charge list, now "the definition of that unit", does not reproduce the pinned numbers

Missing charges: Marginal's `+k` accumulate per stage; the prefix walk's `k` key reads, `+1` branch
per walked stage and `+s` support scan; Factor's `s`-element indicator; a typed label's
`ncodeunits`; and the elimination is charged per element touched (`rows·(cols+1)` copy, pivot search
`rows−p+1`, `cols+1` per scale/eliminate, `2(cols+1)` per swap, `rows·(cols+1)` final scan), not
"one per canonical-elimination row operation". §1(2): list-only Marginal(3) = 47 ≠ 53; Factor(2,e1)
cannot reach 39. **FIX DEMAND:** replace the prose list by the exhaustive table of `_charge!` sites
(`machines.jl` L779–L811, `meter.jl`), and derive the four charge-table values from that table in a
test. **SURVIVING:** the ten slots and the charge table are exact and pinned in the code's unit.

### N8 — MINOR (runner; session-5 change (e)). A crash is credited as a kill in the registry tally

`test/mutations/run.jl` `disposition`: `killed = failed_after_start && evidence_ok`, so
`KILLED-BY-CRASH` counts toward `killed=N/N`; `M5-gate-body-inflated` and `M6b-gate-body-inflated`
carry no expected evidence, so a shadow-tree load failure or an unrelated assertion would be credited
(the worklog records two such false kills before the sandbox fix). In my run all 216 are labelled
`KILLED`, so no current credit is wrong. **FIX DEMAND:** tally only `KILLED` (fail the registry on
`KILLED-BY-CRASH`); add evidence `"tb6b_walls E ratio<33 => true M ratio<21 => false"` and
`"tb5_walls transcripts ratio<4 => false"`-style strings to the two gate witnesses.

### Notes

* **NOTE-a (session-5 (a)).** A nested child refused by the ENCLOSING budget makes the nested decider
  return `false`, so its caller records `:return/false` where the source's cause is a timeout, and under
  `decider_machine` the same exhaustion surfaces as `Value(false)` or `OutOfFuel` depending on where it
  hits. Verdict-equivalent because every consumer is monotone (Repeat AND, `enu:intro-game`
  accept-if, Anchor pass-through); keep it that way or propagate the timeout.
* **NOTE-b (session-5 (c)).** DESIGN §1.1 fixes `Decider` (5) and `Compressor` (2) arities but not
  `Sampler`; `_admits_sort` accepts any `Lambda` arity ≥ 1, which is why `Lambda(8)` was invisible until
  apply time. Fix the Sampler sort at 7 (§9.1 L1164–L1170: six-input machine + type).
* **NOTE-c (D3 scope).** The dense reference replaces only the state update: it shares `honest_answer!`,
  `coarse_measure!`, `plain_measure!`, `_pauli_of`, `anticommute` and the Pauli-product phase
  (`Base.:*` via `_g`) with the production path. It is a real check of the tableau, not of the strategy.
* **NOTE-d.** TB0's in-suite ratio on this box is 40.4 against gate 50 (1.24× headroom; 32.3 in r1 on
  the reference box). TB0's lane, but it will bind first when TB7 joins the suite.
* **NOTE-e.** `PadMachine` and the `_metered_walk` `j = level + 1` path (in TB6's `meter.jl`) are on
  main with no test and no mutant; DESIGN §12.1 describes them. TB7 obligation.

---

## 3. The critic's own mutations (on copies)

| id | mutation | target | result |
|---|---|---|---|
| CRIT-5 | `_child_query`/`_child_decide`: `outcome == :return && _charge_parent!(c, ctx)` (timed-out nested child not charged) | full suite | **SURVIVED** (12474/12474, exit 0) → N2 |
| CRIT-6 | `_in_V(v, s) = true` (answer vectors not required to lie in `V`, gt-08:L531–L534) | full suite | **SURVIVED** (12474/12474, exit 0) → N1 |
| kill matrix | each of the 13 registered drop mutants × each of the 13 witnesses (in process) | 169 cells | exactly diagonal (§1(1)) |

Both mutated packages were verified live (`pathof` in the copy; `_in_V(Bool[0,1],1) == true`;
the CRIT-5 marker present in the loaded source).

---

## 4. O1–O10 and r1 §§4–7: discharge table

| r1 item | status | evidence |
|---|---|---|
| **O1** conjunct witnesses | **DISCHARGED** | 13 witnesses, one bit of one field in `V` each; kill matrix diagonal (§1(1)); 13 drop mutants incl. `CRIT-1 sampling_intro`, `CRIT-1 hiding_intro`, `CRIT-4` KILLED in my registry. Residue: D1(d) replay (N4); the parse-layer conjunct (N1) is new. |
| **O2** registry completes | **DISCHARGED** | `killed=216/216 baselines ok=85/85`, exit 0, `TB0 M-gate-body-inflated => KILLED`; TB5/TB6a/TB6b walls are ratio gates; `M5-`, `M6a-`, `M6b-gate-body-inflated` KILLED. |
| **O3** mass identity | **DISCHARGED** | assertion struck; dense 64-amplitude reference compared per (edge, seed) with exact rationals; histogram and count-set pinned; `M6-forced-outcome-free` KILLED. Scope NOTE-c; "per oriented pair" wording N6(iv). |
| **O4** pins | **DISCHARGED** | ten slots, charge table, 30/64, 48/64, `_require_image` 142/179 are `@test`s; `M6-charge-branch`, `M6-literal-suffix-register`, `M6a-require-image-charge` KILLED. New D7 numbers unpinned (N5). |
| **O5** 10/22/58 | **DISCHARGED** | `tb6a_audit.jl:81–82` asserts `2(4+2(ℓ−1))+2ℓ` at ℓ = 1,3,9; brief-43 report corrected in place. |
| **O6** (a)–(d) | **DISCHARGED** | §11.6 table measured; §11.6/§13.1 TB6a K = 18; §13.1 calibration paragraph; definitions §H rows with the required anchors + `k_rep` clause. Residual stale text N6. |
| **O7** `_require_image` at scale | **DISCHARGED** | measured at 206 and the 1648 proxy; D13 decision recorded (not binding). Pins N5. |
| **O8** probe sentence | **DISCHARGED** | §11.4 sentence; (l) asserts 7 child `Dimension` calls for 6 vector queries; `M6-probe-from-input` KILLED. |
| **O9** attempted count | **DISCHARGED (rename deferred to TB7, accepted)** | §11.4 sentence; (l) asserts `steps == 13, budget 10, ctx.steps == 8`; `M6-fuel-attempted-clamped` KILLED. |
| **O10** degenerate E | **DISCHARGED** | §11.6 sentence; carried in C14's scope. |
| §4 §9.5 / §9.6 | **landed verbatim** | byte-compared with `briefs/43-tb6-introspect.last.md` L19. |
| §4 §11.4 unit sentence | **landed, but incomplete** | N7 (my r1 approval was wrong on this point). |
| §5 C14 row | pasted verbatim at `5f2e091` | its O1 and O4 scope sentences are now false → replaced in §6. |
| §6 C12/C13 | pasted verbatim except C13's walls clause | ruled in §6. |
| §7 TB7 blockers | (1) **DISCHARGED** (one currency, §1(3)); (2) **PARTIAL** (N2, N3); (3) **DECIDED** (not binding; Pad node untested, NOTE-e); (4) **DISCHARGED** (`M7-repeat-index`, `M7-normal-form-display` KILLED). |

---

## 5. Session-5 changes (made by the orchestrator) — adjudicated

**(a) TB6b (k): `@test_throws` at `total−1` → rejection at `total−1`, throw only below the enclosing
level's own depth-1 charges — ACCEPTED (not a weakening to match code).** DESIGN §11.4 "Nested typed
deciders" (written with the old test in the same session-4 commit) already said "an exhausted
enclosing budget refuses the call before its first step (a timeout, hence a rejection)"; the old
assertion contradicted the design text. Against `gt-08:L417–L419` both readings give the same verdict
at every enclosing consumer (its `_child_decide` maps a throw to `:timeout` → reject; a returned
`false` → reject). My full sweep (§1(5)) confirms the boundaries the test pins
(22,617 throw / 22,618 false / 22,632 false / 22,633 true) and monotonicity in between. Residue: N2
(the enclosing step count at those points is not pinned) and NOTE-a.

**(b) TB6b (m) `falses(6)` → `Vector{Bool}` — ACCEPTED; the primitive contract is right.** The §1.1
IR value of sort `Bits` is exactly `Vector{Bool}` (`_value_has_sort`, `programs.jl` L178–L181; `Eval`
argument check L992; `_encode_bits!(::Vector{Bool})`). Accepting any `AbstractVector{Bool}` in one
primitive would create a second runtime representation of one IR value. The refusal is loud
(`SortError(:primitive_contract)`) — my own E3 hit it with a broadcast `.|` result. Tolerance belongs
in a host-side helper, not in the primitive.

**(c) `lower_sampler` `Lambda(8)` → `Lambda(7)` — ACCEPTED; `M7-lower-sampler-arity` is killed for the
right reason.** `SamplerQuery` has seven logical inputs (mode, n, w, j, u, y, t: the six-input machine
plus the type, DESIGN §9.1 L1164–L1170); `sampler_machine` is registered at arity 8 = bytes + 7. The
mutant (8 binders) fails `SortError(:apply_arity)` on the 7-argument call and `out.result isa Value`
in TB6b (m) goes red — an arity defect caught as an arity defect. NOTE-b: §1.1's unspecified Sampler
arity is why it was not a Quote-time error.

**(d) nested `TypedDecider` `Vector{Bool}` normalization — ACCEPTED.** `_intro_ordered` is typed on
`Vector{Bool}`; the flat entry `intro_decide_traced` converts identically; the conversion preserves
values; my nested runs on E and on M's Hide edges pass through it with verdicts equal to the flat ones.

**(e) calibration module `@optlevel 2`; shadow tree for test-file mutants; two TB5 evidence strings —
ACCEPTED with N8.** The kernel in its own module compiles at the default level both in-suite and
standalone (in-suite 0.7787 s here; the old -O0 standalone kernel made standalone ratios ~20× laxer,
which would have let gate mutants survive, not be falsely killed). The shadow tree links every
top-level entry and every other test file to the real tree and runs with `--project=ROOT`, so the
mutated test file is the only difference from the baseline: a kill is attributable. The residual
crediting risk is N8 (crash counted as kill; two gate witnesses without evidence strings); no
current credit is wrong. The TB5 evidence strings match the new gate prints.

**(f) CALIBRATED_GATES — honest and red-capable, ACCEPTED with N6(v).** Arithmetic re-derived (§1(6));
the TB5/TB6b rows are from one in-suite cloud run and say so; tb6a uses the r1 reference-box ratio.
Quiet headroom in my run ≥ 2.7× for every calibrated row; all 85 baselines held under the runner's
4-way load; the four body-inflation witnesses (TB0, M5, M6a, M6b) KILLED. The K+1-kernel witnesses
prove the gates are wired, not that K is tight — acceptable for walls the user calls advisory.

---

## 6. Claim decisions

### C12 — CONFIRMED. The r1 §6 strike/insert is in the row verbatim; the O9 `DescribeCL` sentence is kept (still true); `where-tested` carries `tb5_repeat.jl` (nine new) and `tb5_gate.jl`. No change.

### C13 — the r1 §6 "hard gates" clause is RULED OUT (false at `0db7811`); authorize the replacement below verbatim

The orchestrator was right not to paste it: D2 converted all three walls to ratio gates. In the C13
statement replace

> "Exact census (56, 9, 27, 10, 4, 6)."

by, verbatim:

> "Exact census (56, 9, 27, 10, 4, 6); the warm construction, transcript and total walls are calibrated ratio gates against the suite calibration kernel (K = 4, 4, 6 kernel units; absolute ceilings 7.68 s, 7.68 s, 11.52 s; `M5-wall-construction`, `M5-wall-transcripts` and `M5-gate-body-inflated` KILLED) (verdicts/tb6-r2.md §6)."

append to its red cell: `, test/mutations/tb6_introspect.jl (M5-gate-body-inflated)`; and replace its
verdict cell's parenthesis "its "hard gates" evidence clause NOT pasted: brief 80 D2 replaced those
walls by calibrated ratio gates -- for the next critic" by "walls clause ruled: verdicts/tb6-r2.md §6".
`status TESTED` unchanged.

### C14 — REPLACE the row (status stays TESTED, scoped). Authorized verbatim:

> (TB6 Introspect, explicit toy child fuel) `introspect(V, lambda, ell; tuple, F_child)` is executable end to end on `TB6b-E` (n=2, N=4, λ=1, ℓ=1, (2,1,1), dimension 6→142) and `TB6b-M` (λ=2, ℓ=3, s=6, (8,2,1), 27→179): `TypePauli`/`G^pauli` (26 types, 30 non-loops, 86 oriented pairs) and `TypeIntro`/`G^intro` (32+2ℓ types, 2ℓ+39 non-loops, 6ℓ+110 oriented pairs at ℓ=1,3,9) are CHECKED against hand transcriptions of `fig:type-graph-ms`, `fig:type-graph-pauli` and `fig:type-graph-intro`; the Pauli family, `tilde S^intro` and `graph_sampler` carry the §9.6 output-sampler replay rows with the promoted zero maps (`SOURCE_REPAIR(zero-map-factor-partition)`); `D^pauli` executes all eight guards of `fig:decider_pauli` in both player orders on hand-built accept/reject transcripts and its applicability census is `26/4/2/2/2/54/18`; the typed introspection decider reads `V` only through the four queries and one decider call — the recorded query log equals the §11.4 schedule, the child runs one sizing `Dimension` probe per vector query (7 for 6 on the Hide_1/Hide_2 leaf), and every call is at `N=2^n` (`M6-N` red) — each under the step meter with budget `N^lambda` in production (every honest Introspect/Sample transcript times out at exactly `R=16` and the decider rejects; acceptance under the source gate is withdrawn) or the supplied `F_child=65,536` in toy mode, with `toy_child_fuel=FAIL(owner=tb6-child-meter)`; the ten honest cost slots (E 5/13/10/13/10, M 5/53/60/50/22 steps), the `TB6b-M` charge table (Dimension 5, Marginal(3) 53, Factor(2,e1) 39, Linear(2,e1,e4) 40) and `_require_image` at dimensions 142 and 179 (74,671 steps/148 child calls, 113,946/185) are pinned by assertions and independently reproduced by the critic, and every record fits `F_child`; the exact stabilizer simulation of the honest strategy is enumerated over every oriented pair of E (14,378 leaves; leaf-probability histogram 3058/600/10720 at 1, 1/2, 1/4 and the set of per-pair leaf counts {1,2,72,88,120,256} pinned) and agrees on every (edge, seed) with a test-only dense 64-amplitude reference simulator (`M6-forced-outcome-free` red), and over eight directed M transcripts plus 512 seeded draws, typed and detyped, and the operative toy decider accepts every one of them; the paper-literal `>=3Q` guard rejects exactly 10 of 116 and 22 of 128 oriented pairs (the Hide-incident sets) while the operative `>3Q` guard admits the honest `3Q`-bit Hide answer; each of the thirteen comparisons of items 2(a)–3(d) of `fig:intro-decider` has a named negative transcript on `TB6b-M` (an honest leaf with one bit of one field corrupted inside `V`) rejected through its test, and each of the thirteen conjunct-drop mutants (CRIT-1 at both sites and CRIT-4 among them) is killed by its own witness and by no other (verdicts/tb6-r2.md §1); `T6-view-swap` is rejected typed and after detyping; the sampler description is intensionally independent of the input decider (dependency set `{hash(S)}`, identical bytes for byte-distinct deciders); the literal-register and literal-dual-map readings reject exactly 30 and 48 of the 64 honest Hide_1/Hide_2 leaves (pinned) and both source defects are disclosed and repaired (`intro-perp-orthogonal`, `intro-hide-suffix-register`); a nested detyped introspection decider runs as a metered child — its input decoding charged at the enclosing depth, each of its child calls on a meter bounded by `min(F_child, enclosing remaining)` and charged at depth + 1, its verdict equal to the flat call, rejecting from 22,618 and accepting from 22,633 steps on the `TB6b-E` game edge (`M6-nested-depth` red); the `thm:introspection` ASSUME clause `|V| <= lambda` FAILS on both toy quotes, so the `HypothesisAudit` refuses and no theorem conclusion is invoked; `thm:pauli`, `thm:introspection`, `lem:intro-sampler-complexity`, `lem:intro-decider-complexity` and `lem:commute` stay CITED. Thirty-seven owned TB6 mutants are KILLED. **Scope.** Every leaf's exact dyadic probability is structural of the branch enumerator and is not evidence; the dense reference is independent of the tableau only in the state update — it shares the honest strategy, the measured Pauli families and the Pauli-product phases with the production path. The source's rejection of answer vectors not presented in `V` (`gt-08-introspection.tex:L531-L534`) has no negative witness: replacing the membership check by `true` passes the entire suite (`verdicts/tb6-r2.md` N1, CRIT-6). In the nested metering, the steps a timed-out child executed can be dropped from the enclosing meter without any test failing (N2, CRIT-5), and the nested decider's own predicate computation and a nested `:Pauli` or `:AnswerReduce` body are not charged at all (N3). All live adaptive hiding evidence rests on the single `TB6b-M` child sampler, since `enu:hiding-same` is VACUOUS and `s(N)=1` at `TB6b-E` (`verdicts/tb6-r1.md` O10). Acceptance is asserted only for the operative toy decider under the supplied `F_child`; no production-fuel acceptance and no claim about `thm:introspection`'s conclusion follows.

`status TESTED`; `depends-on C12, C4a`; `where-proved src/introspect/` (unchanged list);
`where-tested test/tb6a_audit.jl, test/tb6b_introspect.jl (a)–(m)`; `red test/mutations/tb6_introspect.jl`;
`verdict verdicts/tb6-r1.md (PROMOTE, scoped); verdicts/tb6-r2.md (row replaced, scoped)`.
When N1/N2/N3 are repaired, the next critic strikes the corresponding scope sentences.

### C15 — no change (CONJECTURE; TB7 has not run).

---

## 7. TB7 readiness (brief 44)

1. **Brief 44 can start now.** r1's four API blockers: (1) one currency decided and demonstrated
   (overhead a constant of the lowering, §1(3)); (4) done; (3) decided "not binding", `PadMachine`
   present but untested; (2) partial — nested child calls are metered, nested own work is not (N3).
2. **Blockers before TB7 can be GREEN (not before it starts):** N3's code half is brief 44's —
   thread the enclosing meter into the `:AnswerReduce` body and meter a nested body's own steps, or
   print `UNCHARGED(owner=…)` everywhere `D_{M,lambda}`'s fuel is claimed; C15's "one finite unfold"
   cannot cite fuel otherwise.
3. **TB6-lane repairs, parallelizable (disjoint lane `src/introspect`, `test/tb6*`):** N1, N2, N4,
   N5 plus the DESIGN text of N3/N6/N7 — a short TB6 r3; nothing in brief 44 waits on them.
4. **Obligations:** add `tb7_compress.jl` to `runtests.jl` under a calibrated TB7 ratio gate
   (testset (a) alone took 61.9 s standalone incl. compilation; TB0 already runs at 40.4/50 here);
   testsets (b)… of §12.5 and the eleven named `M7-*` (none of the eleven exists yet; the four
   `M7-*` registered are D11/D14's); a test + mutant for `PadMachine` and the `j = level + 1` walk;
   D9's `FuelExhausted.attempted` rename; `P_pcp_encodes_D1 = FAIL` established by actually running
   TB3's front end on `D1`; non-Pauli schemas `VACUOUS(owner=Q_I<s_0)` with count 0; fixed-width
   `sigma_1` two-input hash; the certificate census; fix the §1.1 Sampler arity (NOTE-b).

---

## 8. Elegance — three places where the code is more complicated than the mathematics

1. **`_intro_ordered` as thirteen hand-written early-return chains.** Mathematically each test is an
   applicability predicate on `(t_w, t_wbar)` plus an ordered list of equalities. A table
   `INTRO_TESTS = [(name, applies, [(:C08, lhs, rhs), …])]` evaluated by one loop that returns the
   first failing conjunct id would make `rejected_by == :C08` observable, let TB6b (j) assert the
   conjunct directly instead of the shared fired name, and make every drop mutant one table row.
2. **Nested metering by after-the-fact re-charging** (`_IntroContext.parent`, `_child_meter`,
   `_charge_parent!` with save/restore of `depth`, a throw inside the `try`). The CEK machine already
   has the right object — a stack of limits with a running minimum (`programs.jl` L907–L908, L1003). Give
   `Meter` that stack: push `min(own, remaining)` on child entry, pop on return, charge each step
   once at its depth. `_charge_parent!` disappears and N2's bug class becomes unrepresentable.
3. **`Vector{Bool}` vs `BitVector` normalized in four places** (`intro_decide_traced`, the nested
   branch, `parse_intro_answer`, test helpers) and refused by the primitives. One host-boundary
   conversion (`bits(x)::Vector{Bool}` at `decide`/`metered_query`/`eval_program` entry) and
   `AbstractVector{Bool}` signatures internally would delete three of them and the session-5 defect class.

---

VERDICT: FAIL(N1,N2,N3)
