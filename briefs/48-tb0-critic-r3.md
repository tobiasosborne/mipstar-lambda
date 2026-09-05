# Brief 48 — CRITIC verdict r3 on rung TB0 (files: src/**, test/tb0_core.jl, test/mutations/run.jl, src/precompile.jl) after repair r3 (brief 42)

You are the adversarial critic (Opus). ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/tb0-r3.md` ONLY. You may run Julia and create files ONLY under the scratch dir below; never edit repo files; never run git commands that change state. Evaluate the ARCHIVED tree at commit `6f4083a` (`git archive 6f4083a | tar -x -C <scratch>/tree`; instantiate there). The live tree is being edited by another worker — never read src/test from it.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb0-r3/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `docs/DESIGN.md` §1.2–1.4, §3, §5.1; `claims/CLAIMS.md` C1, C2, C3, C8.
2. `verdicts/tb0-r2.md` — your prior (N1–N7, X1–X4, O6/O14/O15 rejected/partial); it is the work order; do not re-litigate what r2 accepted.
3. `briefs/42-tb0-repair-r3.md` (binding directives) and `briefs/42-tb0-repair-r3.last.md` (response table, runner output, the UNATTRIBUTABLE demonstration, MERGE PROPOSALS for C1, C2, C3, and the three "unresolved" notes: C8 cell re-pointed by the orchestrator; TB2's one-token `.term` edit; cold precompile 48→95 s because `src/precompile.jl` now runs a TB0 workload at image-build time).
4. Ground truth as in brief 36 (recompute, never from memory).

## Obligations
- **Run** `julia --project=. test/runtests.jl` (paste summary + TB0 wall; quiet-machine re-run per the timing caveat: another Julia worker may run) and `julia --project=. test/mutations/run.jl` (paste `MUTATION REGISTRY` line; every mutant KILLED; baselines ok). Then REPRODUCE the UNATTRIBUTABLE demonstration yourself on a copy (plant an `error(...)` in an unmutated testset, register a no-op mutant against it, require the runner to report UNATTRIBUTABLE and exit nonzero). A runner that credits a kill on a broken baseline is FATAL.
- **Adjudicate** every response row N1–N7, X1–X4, O6/O14/O15: ACCEPTED / REJECTED (exact residual) / PARTIAL. Especially: N4 — is the `:Tseitin` replay now falsifiable by a wrong occurrence vector (re-run your X4 probe on the archived tree); N5 — does `change_field`'s `Checked` root replay actually re-derive `d=11` from the target-field points (mutate `d` and the points on a copy); N1 — witness (iii)'s failing coefficient identity is real (recompute `|c_0|=18,620`, `|r|=2` independently).
- **Precompile workload honesty**: `src/precompile.jl` now executes TB0 work at image-build time. Is anything that CLAIMS/DESIGN calls a test outcome now computed at precompile and merely re-read by the tests? (A test that passes because the precompile image cached a value it never recomputes is MAJOR.) Report cold precompile time and whether the 60 s gate is per test body only.
- **Two NEW semantic mutations** not used in r1/r2 (e.g. the m=2 layout fixture's tables permuted; `tseitin_occurrence_account` ignoring `include_output`); apply on a copy; survivors are MAJOR with the red test as FIX DEMAND.
- **Certificate honesty, lockstep, elegance** as in `briefs/templates/rung-critic.md`.

## Output: `verdicts/tb0-r3.md`
Adjudication table; recomputations; new objections with severity/location/computation/FIX DEMAND/SURVIVING WEAKER STATEMENT; test/runner lines + walls; your mutations; per-claim PROMOTE/HOLD for C1, C2 (proposed TESTED), C3, C8 (re-affirm) with AUTHORIZED verbatim row text; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
