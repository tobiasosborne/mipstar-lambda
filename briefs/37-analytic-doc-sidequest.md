# Brief 37 — analytic document sidequest: finish visual QA (lanes A, C, D), fill pages without a figure, promote styles

You are an Opus agent with vision. You own ALL of `docs/analytic/` this round (no other agent edits it). No git, no Julia. Edit nothing outside `docs/analytic/`.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/doc-sidequest/` (create). Compile ONLY into `docs/analytic/build/sq/`:
`pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/sq analytic-underpinnings.tex` (twice). Render pages with `pdftoppm -r 110 -png -f P -l P build/sq/analytic-underpinnings.pdf <scratch>/pN` and LOOK at them with Read.

## Context
`briefs/32-figure-visual-qa.md` is the QA procedure and nit checklist — it is binding here. Lane B (`parts/part1b.tex`) is COMPLETE (`briefs/32-figure-visual-qa-B.last.md`). Lanes A (`part1a`), C (`part2a`), D (`part2b`) were interrupted with no report; some of their fixes are on disk. Current state (commit 2d91620): 81 pp, 0 overfull, `python3 tools/figcoverage.py build/sq/analytic-underpinnings.aux` reports pages **62** (§11.5 occurrence-vector discrepancy) and **69** without a figure.

## Work order (in this order)
1. **Promote lane B's STYLE REQUESTS** into `figstyle.tex` (the ONLY style source): `copyflow`, `inlineredex`, `tag machine`. Then delete every local `\tikzset` at the top of figure files that duplicates a figstyle style (`grep -l tikzset figs/*.tex`). Recompile; must be identical or better.
2. **Fill pages 62 and 69** with one excellent figure each, in the house style (`FIGURES.md` §1, semantic colours machine/term/desc/check/cited/focus/bad, one amber focus per figure). Page 62 wants the F1 finding drawn: the occurrence vector vs the actual individual-degree vector for a fan-out gate (framing SOFT: "our reading of NW19 may be wrong"; cite `docs/findings.md`). Read the surrounding prose to choose the figure for page 69. Update `FIGURES.md`'s plan table with both.
3. **Visual QA of parts 1a, 2a, 2b** per brief 32 §Procedure: render EVERY page of those parts, inspect every figure, fix overlaps / wrong-way arrows / clipping / alignment / legibility / semantics / caption mismatch. Recompile and re-render the same page after each fix. Do not fix by deleting content.
4. Final gate: full recompile (twice), `figcoverage.py` lists NO page, overfull 0, undefined references 0, `grep -c Warning build/sq/*.log` reported. Copy the final PDF to `docs/analytic/analytic-underpinnings.pdf` (this one file at the top level is the deliverable the user reads).

## Report: `briefs/37-analytic-doc-sidequest.last.md` (≤ 60 lines)
Per figure inspected: slug · page · CLEAN / FIXED: what. Then counts per part; the two new figure slugs; styles promoted and local tikzsets removed; residuals you could not fix and why; suggestions for the next doc round (pedagogy gaps you noticed while reading, ≤ 5 bullets).
