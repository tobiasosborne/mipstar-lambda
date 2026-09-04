# Brief 38 — resume TB1 + TB2 repair r1 (work order = brief 21) from the interrupted partial state on disk

You are the proposer (Fable). Autonomous; no questions; **no git** (the orchestrator commits; do not run any git command that changes state; `git diff`/`git status` are fine). Lane: `src/**`, `test/**`, `Project.toml`. Report: `briefs/38-tb1-tb2-repair-r1-resume.last.md`.

Scratch (for anything not in lane): `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/tb1-tb2/`

## State you inherit
The working tree at commit 2d91620 has UNCOMMITTED changes in 24 files (`git status -s`): the interrupted codex attempt at brief 21 (lazy `CLStep`, decider red tests, six new TB1 mutants, TB2 lazy refactor). Its last known state: 220/221 assertions green; the TB0 60 s test-body gate had REGRESSED to 67 s warm (it was 35.9 s at the TB0 repair r2 commit 1a96917); the mutation runner had NOT been re-run. Start with `git diff --stat` and `git diff` to see exactly what it changed, then run `julia --project=. test/runtests.jl` to see where it stands. You may keep, rework, or discard any of that partial work — you own the outcome, not its history.

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `docs/DESIGN.md` §1–8 (single source of definitions — code cites, never redefines); `docs/definitions.md`; `claims/CLAIMS.md` (C4a, C4b, C9 rows; you may NOT change any status — MERGE PROPOSALS only).
2. `briefs/21-tb1-repair.md` IN FULL — every fix demand there is binding here, TB1 part and TB2 EXTENSION.
3. `verdicts/tb1-r1.md` and `verdicts/tb2-r1.md` IN FULL (the objections; the critic's ready-made red testsets and killer mutations are in there — use them).
4. `briefs/16-tb1.last.md`, `briefs/18-tb2.last.md`, `briefs/20-tb0-repair-r2.last.md` (how the rungs were built; TB0's gate handling in runtests.jl — keep it).
5. Ground truth as cited by the verdicts: `ground-truth/gt-04-cl.tex` (def:cl-func, lem:alnf, lem:dlnf, L590–595 lazy interface), `gt-07-ldt.tex` (fig:ld-decider, L_Point/L_ALine/L_DLine), `gt-10-answer-reduction.tex` (fig:decider-pcp). Recompute from it, never from memory.

## Binding requirements (in addition to brief 21)
- Red/green: for every objection whose fix is a test, show the test RED against the pre-fix behaviour (a mutant or a stash-free copy under scratch) before GREEN. Every new machine-checkable assertion gets a mutation in `test/mutations/` registered in `run.jl`, and the runner must show it KILLED.
- The TB0 gate must be back under 60 s warm on a quiet machine (`nothing else running` — see concurrency note). If the regression came from the lazy `CLStep` or package-load changes, fix the cause; you may touch `test/tb0_core.jl` or TB0 src ONLY to restore the gate, and list every such line under CROSS-LANE EDITS.
- `test/mutations/run.jl`: isolate each mutant; no 12× package precompile; exit 0 with every mutant of every rung (TB0 14, TB1, TB2) listed KILLED; target < 5 min total; paste the full runner output in the report.
- Concurrency: an Opus critic runs its own Julia copy under scratch for part of this round. Take the final timing measurements when `pgrep -fa 'runtests|mutations/run'` shows only your processes; report cold (fresh depot not required — just `--compiled-modules=yes` after touching nothing) and warm walls.
- Delete dead code planted for mutants (`_truncate_univariate`); the report of record must be truthful; ≤ 40 lines.

## Report: `briefs/38-tb1-tb2-repair-r1-resume.last.md`
Response table: one row per objection in `verdicts/tb1-r1.md` (O1–O12) and `verdicts/tb2-r1.md` (O1–O14): FIXED / DOWNGRADED (law 5: prefer the honest weaker statement over "prove more") / RETRACTED / RESIDUE, with file:line. Test summary lines (cold, warm, TB0 wall), full mutation runner summary, CROSS-LANE EDITS, and MERGE PROPOSALS (verbatim row text for C4a, C4b, C9 — proposals only, statuses unchanged; the critic's authorized C9 scoped row and C4b "missing step" paragraph go here).
