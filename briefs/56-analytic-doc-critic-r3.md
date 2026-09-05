# Brief 56 — CRITIC verdict r3 on the analytic document after repair r2 (brief 53) — closing round

You are the adversarial critic (Opus, with vision). ATTACK; do not summarize. Autonomous; no questions. Lane: write `verdicts/analytic-doc-r3.md` ONLY; files only under scratch; never edit repo files; no state-changing git; no Julia. Evaluate the ARCHIVED tree at commit `44160d1` (`git archive 44160d1 | tar -x -C <scratch>/tree`), compile there (pdflatex ×3), render with `pdftoppm -r 110 -png` and LOOK at every page the repair cites.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-analytic-doc-r3/`

## Read order
`~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `verdicts/analytic-doc-r2.md` (your prior — the work order); `briefs/53-analytic-doc-repair-r2.md` and `briefs/53-analytic-doc-repair-r2.last.md` (20 rows, each with a final-PDF page; MP-A/MP-B — both applied by the orchestrator in 44160d1); `claims/CLAIMS.md` and `docs/DESIGN.md` §1.1 at 44160d1 (C1 CONJECTURE, C2/C3/C4a/C4b/C8/C9 TESTED, C16–C19 SKETCH, C17 without the stray 2).

## Obligations
- **Adjudicate every row** (M12–M17, m22–m28, n4–n5, and the six former PARTIALs M1/M3/M7/M8/M10/m10): ACCEPTED / REJECTED / PARTIAL — by LOOKING at the cited page, not the source.
- **Sweep for regressions** introduced by two repair rounds: grep every claim id chip in `parts/*.tex` and `figs/*.tex` against CLAIMS.md statuses at 44160d1 (any chip stronger than the row is MAJOR; stale weaker chips MINOR); grep for any surviving `L`-for-`λ` (the pattern from r2); every `\gt` label resolves.
- **Fidelity**: any statement the repairs rewrote about the paper, checked against gt lines.
- **Pedagogy**: is the document now something a physicist can read front to back? Name up to five concrete remaining improvements as NOTEs (not objections) for a future round.
- New objections only if MAJOR and genuinely new (M18…).

## Output: `verdicts/analytic-doc-r3.md`
Adjudication table; regression-sweep table (chip → row status → OK/DEFECT); figure spot-checks; NOTEs; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
