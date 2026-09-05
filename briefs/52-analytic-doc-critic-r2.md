# Brief 52 — CRITIC verdict r2 on the analytic document after repair r1 (brief 47)

You are the adversarial critic (Opus, with vision). ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/analytic-doc-r2.md` ONLY; files only under scratch; never edit repo files; no state-changing git. Evaluate the ARCHIVED tree at commit `dcaaf34` (`git archive dcaaf34 | tar -x -C <scratch>/tree`), compile there (pdflatex ×3 into a scratch build dir), render with `pdftoppm -r 110 -png` and LOOK at every figure the repair touched or added.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-analytic-doc-r2/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `verdicts/analytic-doc-r1.md` (your prior — the work order; do not re-litigate what r1 passed); `briefs/47-analytic-doc-repair-r1.md` and `briefs/47-analytic-doc-repair-r1.last.md` (response table: M1–M11, m1–m21, n1–n3, S1–S5 with dispositions; figures redrawn; nine new figures; MP-1…MP-4).
2. `claims/CLAIMS.md` at dcaaf34 (C2, C3, C4a, C4b, C8, C9 TESTED; C16–C19 now SKETCH rows pasted from MP-4; C15 reworded `D_{M,lambda}`); `docs/DESIGN.md` §1.1 (the `L→lambda` rename applied per MP-1), §3, §9–13.
3. The ground truth for every MAJOR you adjudicate (recompute from `ground-truth/gt-*.tex`).

## Obligations
- **Adjudicate every response row** (M1–M11, m1–m21, n1–n3, S1–S5): ACCEPTED / REJECTED (exact residual) / PARTIAL. For M2 re-derive the 5SAT literal placement from gt-10 L1105–L1107 and eq:5sat and check the redrawn `fig-decoupled-5sat` AND `fig-D-decider-guards` agree. For M6 check the exponent ladder is a correct derivation (state and proof agree). For M7 check every Part II theorem now carries a `\gt` citation or a SKETCH provenance matching C16–C19 exactly (statement text in the document vs the CLAIMS row). For M4/M5 check `fig-ladder` and the TB7 card transcribe CLAIMS/DESIGN at dcaaf34 exactly (including C2, C4b, C9 TESTED and C16–C19 SKETCH).
- **Look at all nine new figures and every redrawn one** (list in the report): mechanism shown, arrows, colours, overlap, caption truth. A misleading figure is MAJOR.
- **Fidelity sweep of everything the repair rewrote** (diff `git diff e3fe341 dcaaf34 -- docs/analytic` in the archived tree's history is not available — diff the two archives): any new misstatement of the paper is MAJOR; any claim stronger than CLAIMS.md is MAJOR (law 1).
- **Pedagogy**: the symbol table, parameter card, §11 miniature, certificate-grammar section — do they actually do the job for a physicist reader? Concrete demands only.
- New objections numbered M12…, m22…, n4….

## Output: `verdicts/analytic-doc-r2.md`
Adjudication table; figure table (slug · page · verdict); new objections with severity/location/computation/FIX DEMAND; a ≤ 8-line repair plan; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
