# Brief 103 — PROPOSER (codex gpt-6-astra xhigh): analytic document repair r4 — verdicts/analytic-doc-r6.md F2 residual (typographic only)

Lane: `docs/analytic/**` + `briefs/103-analytic-repair-r4.last.md`. No Julia. pdflatex in place (twice; third if "Rerun"), `cd docs/analytic && python3 tools/figcoverage.py` exit 0 (EVERY page must still carry a figure — user directive), 0 undefined refs, 94 pp ±1. Never edit verdicts/ or CLAIMS. No content/status prose changes.

**Orchestrator ruling (2026-10-02) on verdicts/analytic-doc-r6.md F2:** the 28 SAME-PAGE inversions (a `[t]` float at the top of the page that first references it) are standard LaTeX practice and ACCEPTED — do not touch them. Fix only:
1. The four EARLIER-PAGE previews (verdict §3 table, first four rows: figures 1, 3, 4 and the fourth listed) — each must be referenced on or before its page: add a short in-text forward reference near it (e.g. "Figure~\ref{…} previews …") in the surrounding front-matter/intro prose, or move the float so it lands on/after its first-reference page — whichever keeps figcoverage at exit 0.
2. Figure 2 (standalone symbol table, `analytic-underpinnings.tex:90–95`): give it one in-text reference on or before its page.
Report per figure: before → after (figure page, first-reference page), build table (pages, undefined, figcoverage exit), and confirm the six figures discharged in r6 (70, 90, 94, 104, 108, 109) still follow their references.
