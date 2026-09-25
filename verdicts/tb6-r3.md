# TB6 r3 — brief 83, archive `2eff253`

Critic: Codex (brief 83). Only brief 82's N1–N8 deltas and r2 §7 readiness are adjudicated. O1–O10 and session-5 (a)–(f) remain accepted. All source/test reads and Julia runs use the archive under `/tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/74478cf7-c75e-46db-bc49-bfda0ac1586c/scratchpad/critic-tb6-r3/`; live source/test files were not read. No state-changing git command ran. This file and `verdicts/tb4-r3.md` are the only repository outputs.

## Numbered objections

### R1 — MAJOR · `src/introspect/intro_decider.jl:446–480`; TB6b (j), N1

The parser rejects out-of-V fields, but the decider does not always call it. On the **actual Read_alice self-loop** of `G^intro`, give both players the identical 25-bit answer `(0^12, e7, 0)`. Here `e7 ∉ span(e1,…,e6)` (although it is orthogonal to that whole subspace), and the direct parser refuses it. `_decide_intro` passes Dimension and the length guard, neither ordered pass applies a Read/Read test, and consistency accepts because the two malformed answers are equal. This contradicts the unconditional V-presentation rejection at gt-08:L531–L534. Own archived execution confirms `parser_reject=true`, `typed_accept=true`, `trace=[:Dimension]`, `fired=[:consistency]` for that minimal Read answer. The four-loop red file fails **8 rejection assertions** (4 other checks pass), including all four valid detyped loops. The same bypass exists on Introspect, Sample, and Hide loops; these are graph edges, not unused nonedges. The new V1–V4 and replay bit5 all take an ordered-test branch that actually parses, so they do not expose the bypass.

**FIX DEMAND:** validate every non-Pauli answer's schema and V membership after Dimension/embedding/length checks and before dispatch, and keep the typed and valid-detyped malformed-loop red cases in `red_membership_loops.jl` as permanent tests.

**SURVIVING WEAKER STATEMENT:** direct parsing is correct on the fixed-Q fields tested here, V1–V4 reject in their named applicable tests, and the previously accepted honest-transcript and thirteen-comparison results remain intact; global rejection of malformed non-Pauli answers is false.

### R2 — MAJOR · `test/tb6b_introspect.jl:1026–1042`; `src/introspect/intro_decider.jl:231,550–554`; N1

Every new negative vector uses coordinate `s+1`, including replay bit5. The new semantic mutant `CRIT-R3-tail` replaces the membership predicate by
`_in_V(v::AbstractVector{Bool}, s::Int) = length(v) <= s || !v[s+1]`.
It tests only the first coordinate outside V. It **SURVIVED the complete TB6b file: 9,667/9,667 assertions, exit 0**, with a passing unmutated target and `CRIT_R3_TAIL_ACTIVE=true` confirming the replacement was loaded; the registry correctly exits 1 for that survivor. On M, y⊥=e12 in the Read player's answer on `(Introspect_bob,Read_bob)` is then admitted and 3(a) accepts: that test compares y and a, not y⊥. This changes one bit of one field. The pristine parser/decider reject that same transcript: my new boundary test is **2/2 green on the archive**, then **0 pass / 2 fail / 0 errors** under this mutant. The mutant therefore changes semantics on N1's surface while retaining all four newly selected witnesses.

**FIX DEMAND:** add outside-coordinate coverage through Q (at least `s+2` and Q as well as `s+1`) for the vector slots, assert parse rejection and trace `[:Dimension]`, and register this mutant; `red_tail.jl` supplies the missing last-coordinate test.

**SURVIVING WEAKER STATEMENT:** the new tests prove the first outside coordinate is guarded on the four named paths; they do not make the entire outside tail red-capable.

### R3 — MAJOR · `test/mutations/run.jl:416–427`; N8

The added `&& assertion_failure` does not implement assertion-only credit. `assertion_failure` accepts the generic string `Some tests did not pass`, which Julia also emits for a testset with **zero failed assertions and one error**. Injecting `getindex(1,"critic_bad_index")` into TB6b (k)'s setup inside its `@testset` causes a MethodError, not an assertion failure, yet satisfies this new scoring condition. The corresponding outside-testset setup crash takes the newly added `KILLED-BY-CRASH (not credited)` branch. The distinction is merely where Julia catches the exception. The outside probe’s registry exits **1**. The inside probe’s child has **0 pass / 0 fail / 1 error**, but its registry exits **0** and prints `MUTATION REGISTRY: killed=1/1 baselines ok=1/1 wall=58.69 s`. The required registry also credits four existing error-only runs, listed below; this is not merely a hypothetical future false kill.

**FIX DEMAND:** score explicit failed assertions (prefer structured Test results) rather than the generic TestSetException summary; register both setup-crash probes as negative tests of the runner, require zero credit and nonzero registry exit for each, and convert existing error-only owners to assertion witnesses before restoring an all-assertion kill claim.

**SURVIVING WEAKER STATEMENT:** uncaught setup crashes after the marker are no longer credited; crashes caught by `@testset` can still inflate the tally.

**R4 — MINOR · DESIGN §11.4, lines 1588–1608 (N7).** The new table calls itself exhaustive and defines the interpreter's unit, yet contains no untyped-decider input charge, Copy comparison charge, Detype edge-scan charge, or typed-decider input charge (`intro_decider.jl:125,127,138,144,147,198`). Its last row delegates composite details back to `_charge!` in `machines.jl`, and cannot supply those sites in `intro_decider.jl`. In particular the table alone cannot derive 22,618 or the timed-out Copy's eight consumed units. **FIX DEMAND:** restrict the table's title to sampler charges and add a decider charge table with these sites, or complete the claimed exhaustive table. **SURVIVING WEAKER STATEMENT:** the four displayed leaf-sampler numbers are independently derivable and pinned.

**R5 — MINOR · DESIGN §13.1 line 1972; `test/calibration.jl:13–14` (N6).** The replacement says approximately 7.4–8× for the cloud TB5/TB6b rows and “at least 12x only” at the reference kernel. But the published TB5 construction row gives `7.68/0.533 = 14.409…`, on that same cloud measurement. The K=4 floor is precisely why this row lies outside the new range. **FIX DEMAND:** say 7.4–14.4× for the six cloud rows, or give the per-row ratios, and phrase the reference-rate 12× statement as a guarantee rather than an “only” condition. **SURVIVING WEAKER STATEMENT:** K and the ceilings remain honest, explicit gates; this defect changes no runtime limit.

## N1–N8 discharge table

| item | ruling | evidence and limit |
|---|---|---|
| N1 | **PARTIAL** | V1–V4 and bit5 are genuine single-field, single-bit outside-V corruptions and reject with trace `[:Dimension]`. The direct parser matches the independent V transcription on all 28,672 field cases. `M6-in-V` is killed by precisely the new block: 73 pass / 11 fail / 0 errors; old conjunct evidence remains `13/13`, and `tb6b_out_of_V rejected=0/4`. Its registered `expected_evidence` is **nothing**, not a protected rule string; the raw assertion/output evidence establishes attribution for this run. Global dispatch bypasses parsing on real loops (R1), and the new tail mutant exposes missing coordinate coverage (R2). |
| N2 | **DISCHARGED** | Both arithmetic boundaries reproduce independently. The registered mutant changes only `_child_query` and fails line 1083: `(22618,[22618]) != (22622,[22618,4])`. My separate decider-only mutant fails line 1080: `(22623,[22618,5]) != (22631,[22618,13])`, with 15 pass / 1 fail / 0 errors. Thus the decider-call site is covered by the new test even though it lacks its own permanent registry entry. |
| N3 | **PARTIAL** | The restated Nested typed deciders paragraph is true about the charged input decoding and returned/timed-out child calls, and about the uncharged own predicates/Pauli/AnswerReduce bodies. The test pins `[22618,15]` and `by_depth[2] == flat_steps == 15`; independently the two flat costs are Dimension 5 and Decider 10. The named `UNCHARGED` gap is prose only, not executable output. The code residue remains brief 44's and is not grounds to pretend whole-subroutine fuel is enforced. |
| N4 | **DISCHARGED (downgrade)** | D1(d)'s thirteen fixture witnesses are honestly downgraded to test-level diagonal-matrix evidence. The generic replay now adds bit5, not the thirteen witnesses. C14 cites the witnesses/matrix and test file and makes no claim that its certificate replays all thirteen; it does **not literally spell out** the downgrade. The next complete row should explicitly state that limitation. No strengthening of the old accepted matrix is authorized. |
| N5 | **DISCHARGED** | 206, 824, 1648 exact (steps,calls) assertions ran and passed; `dim+6` follows independently from the five-stage schedule. §12.1 labels the larger sizes PROXY and the walls advisory. The actual 848/1696 chain sizes are not silently substituted for them. |
| N6 | **PARTIAL** | All five requested edits landed: §10.3/§13.1 TB5 ratios; §11.6 E/M/combined ratios; measured slots and scoped TESTED C14; aggregate histogram plus SET of counts; removal of unconditional ≥12×. `rg` finds the old TB5/E targets only in explicitly retired-history clauses, and no old “C14 remains a proposal,” “pinned per oriented pair,” or M feasibility requirement. The replacement ceiling range remains numerically false for TB5 construction (R5). |
| N7 | **PARTIAL** | The four sampler values derive independently from the 15-row table, and the test's local GF(2) elimination count shares no production meter/counting helper. The table still cannot define the whole claimed unit or supply the decider boundary derivation (R4). |
| N8 | **PARTIAL** | Outside-testset setup crash: `KILLED-BY-CRASH (not credited)`, registry exit 1. Inside-testset setup crash: falsely `KILLED`, registry exit 0 (R3). Both new gate evidence strings are registered and actually appear with the intended false ratio; the gate mutants are assertion-killed. |

## Claims

**C14 — HOLD the proposed complete replacement.** The old “no negative witness” sentence is now obsolete, and N2's dropped-timeout-accounting clause is disproved by the new assertions plus both mutation-site kills. Nevertheless, striking N1's limitation without replacement would conceal the actual malformed-loop acceptance and the surviving tail mutation. Missing steps: repair R1, add/register the R2 boundary witness and mutant, and fix R3's assertion-credit rule before asserting a clean closing registry. Keep N3's limitation until its brief-44 code obligation is discharged; no whole-subroutine fuel claim is authorized. The eventual row must also state D1(d)'s test-only scope and update the owned TB6 count from 37 to **39**. No complete C14 replacement row is authorized in this round; TESTED is not promoted.

**C12 — CONFIRMED, unchanged statement. C13 — CONFIRMED, unchanged statement.** Brief 82 changes no CL-closure or Repeat semantics. C13's K=4/4/6 and 7.68/7.68/11.52 ceilings match the archive, pass in the standalone suite run and the registry’s full-suite baseline, and the three named wall mutants are assertion-killed. N8's false assertion-only credit affects the registry evidence presentation (including TB5 `M-boundary` and `M-repeat-level`); it does not refute either row's unchanged executable statement or authorize stronger red-credit language.

**C11 — full corrected row authorized only in `verdicts/tb4-r3.md`, verbatim.** Its 33 mutants and 9 target baselines were separately checked against actual assertion failures, rather than inferred from the broken global scoring rule.

## Independent computations

**Membership.** From gt-08:L524–L534, not from the sampler's image or a dual-map image,
`V = {(v1,…,v_s,0,…,0) : vi ∈ F₂} = span(e1,…,e_s) ⊂ F₂^Q`.
For M, `s=6`, `Q=12`. There is no additional affine coset restriction: any first-six-bit pattern is in V. A vector such as `e7` is orthogonal to every vector of V and nevertheless outside V. Orthogonality cannot replace membership. The source's answer key at L409–L412 requires every indicated vector field to lie in V, including Sample's z and Hide's x; L531–L534 explicitly requires rejection for Read's y/y⊥.

The four new witnesses use the second player's wire offsets 19, 7, 31, 7. Splitting the wire independently at multiples of Q gives Read.y⊥[7], Sample.z[7], Hide.x[7], Sample.z[7]. Each changes exactly one bit of exactly one field; the other fields retain the honest leaf. The generic replay's bit5 changes only Sample.z[s+1], at coordinate 2 for E and 7 for M. Its `Q==s`/nonembedding cases are vacuous, not negative evidence. The honest fixtures have `Q>s`.

**Nested boundaries.** The 15-row table does not contain all decider charges (R4), so deriving these numbers solely from it is impossible. Supplementing it with the actual decider charge sites at `intro_decider.jl:125–148,198` gives:

- Detype input: `1+ndigits(2; base=2)+142+142+3+3 = 293`.
- `T=34`: initial graph work `8T=272`; the matching game edge is 81st, hence `81·272=22,032` scanned units; control transfer 1.
- Typed input: `2+6+6+3+3=20`.
- Own total: `293+272+22,032+1+20=22,618`.
- Child Dimension at N=4: `1+ndigits(4; base=2)+1=4+1=5`.
- Child Copy: input `4+1+1+1+1=8`, comparisons `1+1=2`, total 10.

Thus the completed depth-2 cost is `15=5+10`, and total `22,633`.
At B=22,632, 14 units remain: Dimension spends 5, Copy spends its input block 8, and its comparison block 2 is refused against the remaining 1. Consumed total is `22,618+5+8=22,631`, depths `[22618,13]`. At B=22,622 only 4 remain: Dimension's four-unit header succeeds and its final unit is refused, giving `(22622,[22618,4])`. Neither is inferred from a timeout record's budget-valued `steps` field.

**Four charge-table values.** No production counting helper is needed. At N=4 the header is 4, s=6, and the e1 branch's stage sizes are 1,2,3.

- Dimension: `4+1=5`.
- Marginal(3): decode `4+2+6=12`; each stage costs `k+k²+k+1+k`, i.e. 5,11,19; serialize 6. `12+5+11+19+6=53`.
- Factor(2,e1): decode 12; one key read; eliminate `[1|1]`: copy both entries 2, search one row 1, scale two entries 2, no swap/elimination, final scan two entries 2, total 7; one branch; support scan 6; indicator 6; serialization 6. `12+1+7+1+6+6+6=39`.
- Linear(2,e1,e4): decode `4+2+12=18`; key/branch `1+1`, no reachability elimination; support scan 6; selected-stage read/multiply/write `2+4+2=8`; serialization 6. `18+2+6+8+6=40`.

TB6b (i)'s `elim_cost` is a local Boolean implementation, not `_metered_in_column_space`, `_charge!`, or a production cost helper. Its final values and the metered values are compared separately with literal pins. The independence is sufficient for these four sampler examples; it does not make the table exhaustive for deciders.

**Padding count.** `_require_image` walks the five stages of the introspection sampler. Their factor registers partition its whole dimension, so there are 5 Factor calls and exactly dim Linear basis-vector calls. The other summand contributes one Factor at the queried stage: `child_calls = 5+dim+1 = dim+6`; at 206 this is 212. The archived run reproduces `(155631,212)`, and the heavy proxy cases reproduce `(4488710,830)` at 824 and `(17899098,1654)` at 1648. Heavy mode defaults to 1 and ran here. The last two are proxies, not measurements of 848/1696. Walls remain advisory.



## Required runs and raw scoring

Environment: the stated 12-core workstation, balanced profile, another Julia worker active; Julia 1.12.5. All work uses the archived tree. Instantiation exited 0 (Pkg precompile 158 s, MIPStarLambda image 251.371 s; the registry download warning did not prevent local resolution). The suite and registry were run **one at a time**, without changing gates, with `MUTATION_JOBS=4` for the registry. Auxiliary Julia runs were likewise sequential; each registry internally used four jobs. All depots/logs/probe files are in scratch (the existing home depot is a read fallback).

`julia --project=. test/runtests.jl` — exit 0:

```text
MIPStarLambda                                                                                                                                                | 12500  12500  5m56.0s
```

`MUTATION_JOBS=4 julia --project=. test/mutations/run.jl` — **exit 1**. There is **no native `MUTATION REGISTRY` summary line to paste**: `run.jl:462–465` throws on its final assertions before the summary `println` at line 466. Reconstructed from its 218 individual disposition lines and 85 baseline lines: **killed=217/218, baselines ok=84/85**. Labels: 217 KILLED, 1 UNATTRIBUTABLE, 0 SURVIVED, 0 LOAD-ERROR, 0 KILLED-BY-CRASH. This does **not** reproduce brief 82's `218/218,85/85`. The uncredited result is:

```text
MUTANT TB0 M-gate-body-inflated tb0_body_run_three_times target=tb0_gate => UNATTRIBUTABLE (target exits 1 unmutated) (exit=1, 530.67 s)
```

Moreover, four of the 217 credited results have no failed assertion at all (all four have `expected_evidence=nothing`):

| native label | actual Test summary (pass / fail / error) | preserved log |
|---|---:|---|
| `TB1 M-repair drop_lnf_zero_direction_node` | 4 / 0 / 1 | `registry-linked/mutant-125.log` |
| `TB1 M9-linear-narrowed-domain linear_rejects_unreachable_prefix` | 26 / 0 / 1 | `registry-linked/mutant-137.log` |
| `TB5 M-boundary query_throws` | 32 / 0 / 8 | `registry-linked/mutant-243.log` |
| `TB5 M-repeat-level repeat_adds_two_levels` | 0 / 0 / 1 | `registry-linked/mutant-247.log` |

Under the advertised assertion-only rule, this run supplies **213 attributable assertion kills**, not 217. All 303 child logs were retained by hard links before the runner cleaned its temporary directory. This adjudicates N8's changed scoring promise; it does not reopen those earlier rungs' semantics.

The registered `M6-in-V` attribution is exact: all eleven failures occur at lines 1034/1036/1037/1041 of the new outside-V block, with `tb6b_negative conjuncts=13/13` and `tb6b_out_of_V rejected=0/4`. No unrelated assertion or crash supplied its kill. The sampler-only N2 mutant has exactly one failure, at the new 22,622 point. Both new gate filters are present and matched the real output: `tb6b_walls E ratio<33 => true M ratio<21 => false` and `tb5_walls transcripts ratio<4 => false`; their mutants are genuinely assertion-killed. TB4's 33 mutants also each contain real assertion failures against its 9 passing target baselines.

Gate lines from the green suite, verbatim:

```text
TB0 test-body wall seconds = 29.11 (warning=45.0, hard_limit=60.0); calibration kernel = 0.983 s; ratio = 29.6 (gate 50.0)
TB0 ratio gate: ratio<50.0 => true; wall<60.0 => true
TB4 test-body wall seconds = 10.006; calibration kernel = 0.6073 s; ratio = 16.5 (gate 38.0 = floor(6.0 s / 0.154 s reference in-suite kernel); enforced body budget at this kernel rate = 23.08 s; TB4_BUDGET_SECONDS = Inf; gated)
calibrated gate tb5_construction: elapsed = 1.18 s; kernel = 0.983 s; ratio = 1.2 (gate K = 4 => budget 3.93 s at this run's rate; quiet 0.533 s, quiet ratio 0.68); absolute ceiling 7.68 s
calibrated gate tb5_transcripts: elapsed = 1.579 s; kernel = 0.983 s; ratio = 1.61 (gate K = 4 => budget 3.93 s at this run's rate; quiet 0.986 s, quiet ratio 1.26); absolute ceiling 7.68 s
calibrated gate tb5_total: elapsed = 2.759 s; kernel = 0.983 s; ratio = 2.81 (gate K = 6 => budget 5.9 s at this run's rate; quiet 1.519 s, quiet ratio 1.94); absolute ceiling 11.52 s
calibrated gate tb6a_audit: elapsed = 8.909 s; kernel = 0.983 s; ratio = 9.06 (gate K = 18 => budget 17.69 s at this run's rate; quiet 2.765 s, quiet ratio 5.76); absolute ceiling 35.0 s
calibrated gate tb6b_E: elapsed = 11.91 s; kernel = 0.983 s; ratio = 12.12 (gate K = 33 => budget 32.44 s at this run's rate; quiet 8.51 s, quiet ratio 10.88); absolute ceiling 63.36 s
calibrated gate tb6b_M: elapsed = 4.015 s; kernel = 0.983 s; ratio = 4.08 (gate K = 21 => budget 20.64 s at this run's rate; quiet 5.316 s, quiet ratio 6.79); absolute ceiling 40.32 s
calibrated gate tb6b_combined: elapsed = 15.925 s; kernel = 0.983 s; ratio = 16.2 (gate K = 54 => budget 53.08 s at this run's rate; quiet 13.826 s, quiet ratio 17.67); absolute ceiling 103.68 s
```

## Gate observation (not a re-adjudication of r2 session-5 (f))

The independent whole-suite run is green. In the required four-job registry, however, its full-suite baseline has `12499 passed, 1 failed` because TB0's **absolute** ceiling fires: `80.95544099807739 < 60.0` is false, although its calibrated ratio is `31.3 < 50`. The other baseline gates pass. Thus “walls advisory” describes the task's interpretation, not every assertion in the archive: `runtests.jl:38` still enforces the 60-second ceiling. I neither changed K nor reran a calibration campaign. The registry result must retain this failed baseline and must not credit the TB0 inflation mutant against it. This observation does not reopen the previously accepted ratio-gate design.


## New mutations, red tests, and load

The copied runner at `probe-tree/test/mutations/run.jl` uses the original archive as ROOT, applies mutants only to isolated scratch copies, and retains each process's stdout even for a credited kill. Its scoring function is unchanged. The two new semantic mutations are distinct from r2 CRIT-5/CRIT-6: one isolates the previously unregistered **decider** timeout site; the other weakens V-membership to only the first tail coordinate, rather than replacing it by true.

| probe | target and outcome |
|---|---|
| `CRIT-R3-decider-timeout` | Only `_child_decide` changes to `outcome == :return && _charge_parent!(c,ctx)`. KILLED by TB6b (k), 15 pass / 1 fail / 0 errors, baseline OK. Native registry line: `MUTATION REGISTRY: killed=1/1 baselines ok=1/1 wall=38.56 s`. |
| `CRIT-R3-tail` | Only `_in_V`'s semantics change to `length(v)<=s \|\| !v[s+1]` (plus an active-mutant diagnostic). Complete TB6b target: baseline exit 0; mutant **SURVIVED**, 9,667/9,667, exit 0; registry exit 1. R2 supplies its missing permanent red test. No claim that a second whole-repository mutant suite was run. |
| `CRIT-R3-crash-outside` | Register a `getindex(1,"critic_bad_index")` MethodError in the test file's top-level setup. `KILLED-BY-CRASH (not credited)`; registry exit 1. This satisfies the requested outside-testset N8 demonstration. |
| `CRIT-R3-crash-inside` | Register the same MethodError in TB6b (k)'s setup inside `@testset`, before its first assertion. False `KILLED`; 0 pass / 0 fail / 1 error; registry exit 0. R3. |
| `own_checks.jl` | 27 wire-check assertions plus 4 independent accounting assertions pass. The wire assertion exhaustively compares all 4,096 possible 12-bit vectors in each of seven vector slots (28,672 cases) with the independently transcribed V. Four malformed real loops accept typed and detyped; the minimal synthetic Read loop independently does too. |
| `red_membership_loops.jl` | Pristine archive: **4 pass / 8 fail / 0 errors**, exit 1; parser rejection passes, typed/detyped rejection fails on all four loops. R1's concrete red test. |
| `red_tail.jl` | Pristine archive **2/2**, exit 0; with `CRIT_TAIL_MUTANT=1`, **0 pass / 2 fail / 0 errors**, exit 1. The one changed field is Read.y⊥ coordinate Q=12 (wire position 24). R2's concrete red test. |

The `uptime` before and after every top-level Julia run (including instantiation and the metadata-only registry census) follows. Walls are advisory; the required main runs were not repeated or retuned.

```text
instantiate
12:50:45 up 2 days, 14:29,  1 user,  load average: 2.97, 2.56, 2.16
 12:57:49 up 2 days, 14:36,  1 user,  load average: 9.24, 7.20, 4.45
exit=0
suite
12:58:37 up 2 days, 14:37,  1 user,  load average: 5.57, 6.52, 4.36
 13:04:37 up 2 days, 14:43,  1 user,  load average: 6.34, 6.33, 4.90
exit=0
registry
13:04:51 up 2 days, 14:43,  1 user,  load average: 5.90, 6.24, 4.90
 13:51:14 up 2 days, 15:29,  1 user,  load average: 8.25, 7.53, 7.83
exit=1
own
13:51:14 up 2 days, 15:29,  1 user,  load average: 8.25, 7.53, 7.83
 13:52:08 up 2 days, 15:30,  1 user,  load average: 5.95, 7.05, 7.65
exit=0
attribution
13:52:08 up 2 days, 15:30,  1 user,  load average: 5.95, 7.05, 7.65
 13:52:10 up 2 days, 15:30,  1 user,  load average: 5.95, 7.05, 7.65
exit=0
crash_outside
13:52:10 up 2 days, 15:30,  1 user,  load average: 5.95, 7.05, 7.65
 13:52:53 up 2 days, 15:31,  1 user,  load average: 4.51, 6.51, 7.43
exit=1
crash_inside
13:52:53 up 2 days, 15:31,  1 user,  load average: 4.51, 6.51, 7.43
 13:53:52 up 2 days, 15:32,  1 user,  load average: 4.28, 6.12, 7.24
exit=0
decider_mutant
13:53:52 up 2 days, 15:32,  1 user,  load average: 4.28, 6.12, 7.24
 13:54:31 up 2 days, 15:33,  1 user,  load average: 4.46, 5.92, 7.13
exit=0
tail_mutant
13:54:31 up 2 days, 15:33,  1 user,  load average: 4.46, 5.92, 7.13
 13:56:32 up 2 days, 15:35,  1 user,  load average: 4.60, 5.60, 6.87
exit=1
red_loops
13:56:32 up 2 days, 15:35,  1 user,  load average: 4.60, 5.60, 6.87
 13:57:06 up 2 days, 15:35,  1 user,  load average: 3.89, 5.31, 6.72
exit=1
red_tail_baseline
13:57:06 up 2 days, 15:35,  1 user,  load average: 3.89, 5.31, 6.72
 13:57:30 up 2 days, 15:36,  1 user,  load average: 3.59, 5.12, 6.62
exit=0
red_tail_mutant
13:57:31 up 2 days, 15:36,  1 user,  load average: 3.59, 5.12, 6.62
 13:58:00 up 2 days, 15:36,  1 user,  load average: 3.48, 4.95, 6.52
exit=1
```

All scratch-relative evidence paths above are under the scratch root named at the top. The exact probe definitions, runner copies, raw logs, and missing red tests remain there for reproduction.

## Elegance and TB7 readiness

Brief 82 does not make the three r2 §8 simplifications structurally harder: it adds tests, a generic replay case, and documentation, without changing the predicate dispatch or parent-meter architecture. Its fixed `[22618,15]` assertion intentionally pins a documented gap, so brief 44 must replace that gap assertion when it starts charging own work; preserving the zero-cost predicate would defeat the repair.

The single simplification to carry to brief 44 is **a shared Meter with a stack of active limits and one charge per step at its real depth**. Thread it through the nested Intro/Pauli/AnswerReduce bodies. This removes `_charge_parent!` and its duplicated return/timeout accounting, while allowing the missing own work to use the same budget. The equality table and Bool-container cleanup remain useful but secondary.

R2 §7's permission to start TB7 stands. Its condition for TB7 GREEN also stands: charge nested own work and propagate the parent meter into Pauli/AnswerReduce, or expose the `UNCHARGED(owner=tb7-nested-own-steps)` limitation wherever fuel is claimed. In this archive that exact limitation is prose only; `rg` finds it in DESIGN §11.4, with only an owner comment in TB6b (k), and no executable printer in `src/` or `test/`. Neither the numeric nested log nor `toy_child_fuel=FAIL(owner=tb6-child-meter)` prints this distinct gap. This is not an implementation of the pending brief-44 obligation. No live TB7 work is adjudicated here.


VERDICT: FAIL(R1,R2,R3)
