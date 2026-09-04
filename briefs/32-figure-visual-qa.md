# Brief 32 — VISUAL QA and nit-fix pass on the figures of docs/analytic (one lane per part)

You are an Opus visual-QA agent with vision (the Read tool shows you PNGs). The user has looked at the PDF and says: "the figures have lots of little nits — the main issues are overlapping content, or arrows that go the wrong way." Your job is to find and FIX every such nit in your lane, by looking at the rendered pages, not by reasoning about TikZ alone.

## Lane (hard boundary — three other agents work the other parts concurrently, and a codex worker edits docs/DESIGN.md)
- Lane files: `docs/analytic/parts/<PART>.tex` and every `docs/analytic/figs/fig-*.tex` that this part `\input`s (run `grep -o 'figs/fig-[a-z0-9-]*' parts/<PART>.tex | sort -u` to get the exact list). Edit NOTHING else: not `figstyle.tex`, not `analytic-underpinnings.tex`, not other parts, nothing outside `docs/analytic/`. If a fix genuinely needs a new shared style, define it locally at the top of the figure file with `\tikzset` and list it under STYLE REQUESTS.
- Compile ONLY into your own directory: `pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/qa<LANE> analytic-underpinnings.tex` (twice). Never compile into `docs/analytic/` itself.
- Render pages with `pdftoppm -r 110 -png -f P -l P build/qa<LANE>/analytic-underpinnings.pdf <scratch>/pN` and LOOK at them with Read. Scratch dir: `/tmp/claude-1000/-home-tobias-Projects-discussions/03b2c3d3-f2b5-4e3b-8e73-afff562cb7ae/scratchpad/qa<LANE>/` (create it).
- No git, no Julia.

## Read first
`docs/analytic/FIGURES.md` §1 (visual system rules) and `docs/analytic/figstyle.tex` (style names; semantic colours machine/term/desc/check/cited/focus/bad). Then your part file, to know what each figure is supposed to show.

## Procedure
1. Compile. Find your lane's page range from the `.toc`/`.aux` (`python3 tools/figcoverage.py build/qa<LANE>/analytic-underpinnings.aux` lists sections per page).
2. Render EVERY page in your range at 110 dpi and look at every figure on it. For each figure write one line in your notes: OK, or the nit(s).
3. Nit checklist (fix all that apply):
   - **Overlap**: any text touching or crossing a line, box, arrow or other text; labels colliding; captions running into the figure; nodes overlapping; legends over content.
   - **Arrow direction**: every arrow must point the way the mathematics flows — time downward on traces, transformations left→right, `binder → variable` for `bind` arcs, `before → after` for `beta`/`step`, quotation from object to bytes, "returns/feeds back" arrows clearly closed loops with the head at the consumer. An arrow whose head is at the wrong end, or a double-headed arrow where the relation is directed, is a bug. Check `<-`/`->`/`Latex-` forms and `edge` directions.
   - **Clipping**: content cut off at the figure edge, or a figure wider than the text width (compare to the text block edges).
   - **Alignment**: tape cells not on one baseline; tree children not symmetric under their parent; columns of a table-like figure not aligned; ragged rows.
   - **Legibility**: text smaller than `\scriptsize`; low-contrast text on a coloured fill; lines too thin to see at 100%.
   - **Semantics**: colour roles used wrongly (a lambda object in teal, a cited theorem in solid green); focus amber used on more than one thing per figure.
   - **Caption**: the caption must match what is drawn; "Figure~\ref" sentence in the prose must be true.
4. Fix in the figure `.tex` (prefer `positioning`/`calc`/`matrix` to hand-placed coordinates; widen `node distance`; use `align=center` + `text width` for long labels; shorten arrows with `shorten >=`; route with `|-`/`-|` or `to[out=,in=]` to avoid crossings). Recompile, re-render THE SAME PAGE, and look again. Repeat until the figure is clean. Do not "fix" by deleting content.
5. After all figures: full recompile, `python3 tools/figcoverage.py build/qa<LANE>/analytic-underpinnings.aux` must still show no page without a figure in your range; overfull count 0; undefined 0.

## Report: `briefs/32-figure-visual-qa-<LANE>.last.md` (≤ 50 lines)
Per figure: slug · page · verdict (CLEAN / FIXED: what) — one line each. Then: counts (figures inspected, fixed, left with a known residual and why), STYLE REQUESTS, and any figure you think should be redrawn from scratch (say why; do not redraw it unless it is a small figure).
