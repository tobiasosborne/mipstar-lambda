# Brief 100 — CRITIC (codex gpt-6-astra xhigh): analytic document r6 — closing round on brief 96

You are the closing reviewer for `docs/analytic/`. Be skeptical; look for real defects. Autonomous; no questions. Lane: write `verdicts/analytic-doc-r6.md` ONLY; scratch `/tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/critic-analytic-r6/`; never edit repo files; no git commands that change state; no Julia. Evaluate the ARCHIVED commit `bc48af2`: `git archive bc48af2 | tar -x -C /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/critic-analytic-r6/tree`; compile `docs/analytic` there (pdflatex twice, third if "Rerun"; `cd docs/analytic && python3 tools/figcoverage.py`).

## Obligations
1. Read `verdicts/analytic-doc-r5.md` IN FULL (the prior round: FAIL R4, R10 PARTIAL, F1, F2; others DISCHARGED) and brief 96's report `briefs/96-analytic-repair-r3.last.md`. Discharge table for R4, R10, F1, F2: DISCHARGED / PARTIAL / NOT, each with quoted new text, file:line, and the authority you reopened (`verdicts/tb7-r1.md` T7-2/T7-8 lines, `claims/CLAIMS.md` rows C2/C4a/C12, `ground-truth/gt-04-cl.tex:282–363`, archived code `src/certificates.jl` at bc48af2).
2. Regression: diff `git diff 632a17f bc48af2 -- docs/analytic/parts`; does any changed sentence get ahead of CLAIMS or the TB7/TB6 verdicts (tb7-r1 FAIL, C15 HOLD; tb6-r4 FAIL, C14 HOLD)? Note: docs/assessment.md and verdicts/tb7-r2-pre.md are NOT governing; brief 93's repairs are not yet verified, so the document must still describe the tb7-r1/tb6-r4 state.
3. Figures: every one of the 110 at or after its first reference (the moved ones: 70, 90, 94, 104, 108, 109); figcoverage exit 0; page count; 0 undefined refs.
4. A final light sweep of §14–§15 for any remaining status/execution overclaim.

## Output
`verdicts/analytic-doc-r6.md`: sections 1–4, `## 5. Repair plan (≤ 3 lines, or "none")`, what you did NOT check, final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`. Final message ≤ 8 lines.
