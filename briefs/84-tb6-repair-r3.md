# Brief 84 — TB6 repair r3 (work order = `verdicts/tb6-r3.md`: R1, R2, R3 MAJOR; R4, R5 MINOR)

You are the proposer (Opus). Autonomous; no questions; **no state-changing git** (`git diff`/`git status`/`git show` are fine; the orchestrator commits). You are the ONLY worker running; nothing else uses Julia while you work. Report: `briefs/84-tb6-repair-r3.last.md` (≤ 30 lines, format below). The next critic adjudicates it.

Tree: live `main` at c7aa93a (the TB7 WIP checkpoint is ON this tree; the verdict evaluated the older 2eff253, so its line numbers have moved and the nested pin is now `by_depth=[22618,129]`, not `[22618,15]` — re-locate every site by content, not by line number).

## Read order
1. `CLAUDE.md`; `~/.claude/skills/rk-light/SKILL.md`; `verdicts/tb6-r3.md` IN FULL (the work order; its "Independent computations" section is your oracle).
2. `briefs/82-tb6-repair-r2.md` and `.last.md` (what r2 did); `docs/DESIGN.md` §11.4, §11.6, §13.1; `docs/definitions.md` §H.
3. Ground truth: `ground-truth/gt-08-*.tex` around L400–L420 and L520–L540 (answer key; V-presentation rejection). Cite line ranges; never work from memory of the paper.
4. `src/introspect/intro_decider.jl`, `test/tb6b_introspect.jl` (testsets (i), (j), (k)), `test/mutations/run.jl`, `test/mutations/tb6_introspect.jl`, `test/calibration.jl`.

Lane: `src/introspect/intro_decider.jl`; `test/tb6b_introspect.jl`; `test/mutations/**`; the four test files owning the error-only kills (`test/tb1_ld_sampler.jl`, `test/tb5_repeat.jl`) ONLY for the R3 owner conversions; `test/calibration.jl` (comment only); `docs/DESIGN.md` §11.4, §13.1. NEVER `claims/CLAIMS.md`, `verdicts/**`, `ground-truth/**`. Anything else you must touch: list under CROSS-LANE EDITS with the reason.

## Order of work (binding) — red before green, every step

### Step 1 — R3 first: the runner's kill rule (it changes what KILLED means for every rung)
- `test/mutations/run.jl` `disposition`: a kill is credited ONLY when the mutant run contains at least one explicitly FAILED ASSERTION. The generic sentence "Some tests did not pass" must not count (Julia prints it for 0 failed / ≥1 errored). Prefer structured results (e.g. the child prints a machine-readable `pass/fail/error` tally from the top-level testset, or parse the Test Summary's Fail column); parsing `Test Failed at` lines is the acceptable minimum. A run with errors but zero failed assertions is `KILLED-BY-ERROR (not credited)` and FAILS the registry, like `KILLED-BY-CRASH`.
- Register two permanent NEGATIVE runner tests, per the verdict's `CRIT-R3-crash-outside` and `CRIT-R3-crash-inside` (a `getindex(1,"critic_bad_index")` MethodError injected at TB6b top-level setup, and inside TB6b (k)'s `@testset` before its first assertion). They must be scored as NOT credited. They are expected-non-kills: design the registry so these probes are asserted to yield zero credit and the registry still exits 0 when (and only when) they are correctly refused — and show RED first: under the OLD rule the inside probe is credited.
- Also fix: the registry throws on its final assertions BEFORE printing the `MUTATION REGISTRY:` summary line (verdict §Required runs). Print the summary line first, then fail.
- Convert the four error-only owners to genuine assertion witnesses (the mutant must make an `@test` FAIL, not throw): `TB1 M-repair drop_lnf_zero_direction_node`, `TB1 M9-linear-narrowed-domain linear_rejects_unreachable_prefix`, `TB5 M-boundary query_throws`, `TB5 M-repeat-level repeat_adds_two_levels`. Typical fix: the test guards the access (`@test haskey/…`, `@test_throws` replaced by an asserted outcome, or `try`-wrapped evaluation compared against an expected value) so the mutated behaviour yields a failed comparison. Do not weaken what the test asserts on the unmutated tree.
- After the new rule is in, run the WHOLE registry once and list every mutant of every rung that the new rule no longer credits (there may be more than four on this newer tree, TB7's `M7-*` included). Convert each; none may be deleted or relabelled to hide it.

### Step 2 — R1: V-membership on every non-Pauli answer
- RED: add permanent tests rebuilding the critic's `red_membership_loops.jl` (its scratch copy is gone): on the real self-loops of `G^intro` — Read, Introspect, Sample, Hide (player-typed as the graph has them) — both players return the IDENTICAL malformed answer with one vector field outside `V = span(e_1..e_s) ⊂ F_2^Q` (e.g. Read: `(0^12, e7, 0)` on TB6b-M, s=6, Q=12). Assert: direct parser rejects; typed decider REJECTS; valid-detyped decider REJECTS; trace is `[:Dimension]` (no child call past Dimension). Show them RED on the current tree (expected shape per verdict: parser assertions pass, the typed/detyped rejection assertions fail).
- GREEN: in `_decide_intro`, validate every non-Pauli answer's schema and V membership after the Dimension/embedding/length checks and BEFORE dispatch, on every edge including self-loops (gt-08:L531–L534 is unconditional). One validation site, not one per branch. Honest transcripts, the 13×13 conjunct kill matrix, leaf histogram and all existing pins must be unchanged; if a meter pin moves because validation is now charged or ordered differently, STOP and report the old/new values with the derivation — do not silently re-pin.
- Mutant: register `M6-membership-dispatch-bypass` (validation skipped on self-loops / equal types) — KILLED by the new loop tests only.

### Step 3 — R2: the whole outside tail
- RED→GREEN tests: out-of-V witnesses at coordinates `s+1`, `s+2` and `Q` for each vector slot the answer key lists (Read y and y⊥, Sample z, Hide x, and the Introspect fields that are V-vectors), each changing exactly one bit of one field of an honest leaf; assert parse rejection and trace `[:Dimension]`. Include the critic's `red_tail.jl` case: Read.y⊥ coordinate Q=12 (wire position 24) on `(Introspect_bob, Read_bob)`.
- Register the tail mutant `M6-in-V-first-tail-only`: `_in_V(v, s) = length(v) <= s || !v[s+1]`. It must be KILLED (it SURVIVED 9,667/9,667 before). Also extend the generic `IntroDecider` replay's out-of-V case beyond bit `s+1` if that is cheap.

### Step 3b — S1 (NEW, orchestrator's registry on c7aa93a, 2026-09-27): a formerly KILLED mutant now SURVIVES
`MUTANT TB6 M6-nested-timeout-uncharged timed_out_child_steps_dropped target=tb6b_nested => SURVIVED (exit=0, 34.74 s)`. It was KILLED at 2eff253. The TB7 checkpoint re-pinned TB6b (k) (`by_depth=[22618,129]`; boundaries `total-1 → (22745,[22618,127])`, `22732 → (22732,[22618,114])`), and neither new boundary times out INSIDE a child sampler query any more, so `outcome == :return && _charge_parent!(c, ctx)` in `_child_query` (`intro_decider.jl`, the site ~L107) is unobserved. This is a regression of verdicts/tb6-r2.md N2's discharge.
- Re-derive, from the charge tables (by hand, in the report), a budget at which the nested child's Dimension/sampler query is refused PART-WAY (the analogue of the old `22,622 → (22622,[22618,4])` on the new accounting with its 114 reserved depth-2 steps) and one at which the child DECIDER is refused part-way; pin `(steps, by_depth)` at both.
- The registered mutant must be KILLED by the first; register the decider-site twin `M6-nested-decider-timeout-uncharged` (`_child_decide`, same replacement; the critic's `CRIT-R3-decider-timeout`) KILLED by the second. Show each RED→GREEN.

### Step 3c — S2 (orchestrator's change, already on the tree; VERIFY, do not redo)
On this device (Threadripper 3970X, WSL2; unrelated Julia sessions of the user keep load ~3–4 — that is the permanent environment) the UNMUTATED suite failed the TB0 ratio gate: ratio 53.2 (registry baseline) and 59.2 (suite alone), body 37.6–38.4 s, kernel 0.65–0.71 s; suite `12582 passed, 1 failed, 1 broken`. The orchestrator set `TB0_RATIO = 100.0` (`test/runtests.jl`) and changed `TB0 M-gate-body-inflated` to add `TB0_RATIO + 1` kernel passes (`test/mutations/tb5_gate.jl`). Your close runs must show the suite baseline OK and this mutant KILLED with its evidence string. If any OTHER calibrated gate fails unmutated on this device, report the measured ratios and propose K by the `max(4, ceil(3·ratio))` rule in the report — do not edit K yourself.

### Step 4 — R4, R5 (documentation; small)
- R4: DESIGN §11.4 — retitle the 15-row table to SAMPLER charge sites and add a DECIDER charge table covering untyped-decider input, Copy comparison, Detype edge scan, control transfer and typed-decider input (sites in `intro_decider.jl`), sufficient to derive `293 + 272 + 22,032 + 1 + 20 = 22,618` and the Copy `8 + 2` split from the tables alone. Add a test in TB6b (i) or (k) that derives 22,618 from the table's formulas (not from the meter) and compares with the metered value; one mutant.
- R5: DESIGN §13.1 and the `test/calibration.jl` comment — state the cloud-row ratio range truthfully (7.4–14.4×, TB5 construction being 7.68/0.533) or give per-row ratios; phrase the 12× statement as a guarantee at the reference kernel rate.

## Close
- `julia --project=. test/runtests.jl` exit 0 — paste the summary line and every gate line.
- `MUTATION_JOBS=4 julia --project=. test/mutations/run.jl` exit 0 — paste the `MUTATION REGISTRY:` line; zero SURVIVED / KILLED-BY-CRASH / KILLED-BY-ERROR / LOAD-ERROR / UNATTRIBUTABLE among real mutants; the two runner probes reported as correctly refused. `uptime` before and after each run. If the TB0 absolute 60 s ceiling fires in the baseline under your own load, say so and rerun quiet; do not change any gate constant.
- Truthfulness: report what ran and what did not. A failing close is reported as failing.

## Report format (`briefs/84-tb6-repair-r3.last.md`)
Table: R1–R5 → FIXED / DOWNGRADED / RESIDUE with `file:line`. Then: the list of kills the new rule un-credited and how each owner was converted; RED evidence (counts pass/fail/error before the fix) per step; suite and registry summary lines; CROSS-LANE EDITS; MERGE PROPOSALS (proposed C14 row text only — you may not change any status; the row must state D1(d)'s test-only scope and the owned TB6 mutant count); open items for TB7 critic r1.
