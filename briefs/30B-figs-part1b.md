# Brief 30B — figures for docs/analytic, lane B: `docs/analytic/parts/part1b.tex` (Part I §4–6)

You are the proposer for a DESIGN + IMPLEMENTATION lane. Work fully autonomously; do not ask questions. Deliver excellent TikZ figures — this is the user's explicit north star for this document: **at least one amazing figure on every page**, "Turing machines are begging for good diagrams, and lambda calculus should be super."

## Lane (hard boundary — other codex workers run concurrently in the other parts)
- You MAY edit: `docs/analytic/parts/part1b.tex` and create files `docs/analytic/figs/fig-<slug>.tex` for the slugs assigned to you below (and extra ones you add, prefixed with your lane letter if the slug could collide: `fig-B-<slug>.tex`).
- You MUST NOT edit: `analytic-underpinnings.tex`, `figstyle.tex`, `FIGURES.md`, any other `parts/*.tex`, anything outside `docs/analytic/`. If you need a style that figstyle.tex lacks, put a minimal local `\tikzset` at the top of your figure file and list it under STYLE REQUESTS in your report — do not redefine any existing colour or style.
- Compile ONLY into your own build directory: `cd docs/analytic && mkdir -p build/laneB && pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/laneB analytic-underpinnings.tex` (run twice). Never compile into `docs/analytic/` itself (shared aux files).
- Do not run git. Do not run Julia.

## Read order
1. `docs/analytic/FIGURES.md` — the visual system (§1, binding rules 1–12), the coverage gate (§2), and YOUR figure plan: **F16–F35** under "Lane B" (§3). ★ figures are mandatory; others may be replaced by a better figure of the same object if you explain why.
2. `docs/analytic/figstyle.tex` — the only colours and styles you use. Read every style name; use the semantic roles (machine/term/desc/check/cited/focus/bad) exactly as documented.
3. Your part file `docs/analytic/parts/part1b.tex` in full. Every figure depicts an object the text actually defines, with the text's notation and numbers.
4. For fidelity to the paper where the plan says so: the cited `ground-truth/gt-*.tex` labels (`CLAUDE.md` lists locations). Keep the F1 framing soft ("as we read the gadget"; never "error in the paper").
5. `docs/analytic/README.md` for the file layout.

## Craft bar (what "amazing" means here)
- Each figure is a *drawing of the mathematics*: real tapes with real symbols, real trees with real binders, the real term Ψ_{M,L}, the real trace of M_= — never a box that says "Turing machine".
- Before/after and side-by-side layouts; the amber `focus` marks the one thing to look at; the evidence boundary (green `checked` vs slate dashed `citedbox`) appears on every figure that touches soundness.
- Alignment: use `matrix`, `chains`, `positioning` and `calc` — no hand-placed coordinates that drift. Tapes are `cell` nodes in a chain; trees use the `trees` library or explicit `positioning`.
- Typography: labels in `lbl`/`lblsm`; maths in the text font; nothing smaller than `\scriptsize`; no text overlapping a line; no overfull boxes.
- Captions per FIGURES.md rule 9: one sentence what-to-see, one sentence why-it-matters. Each figure is referenced in the prose (`Figure~\ref{fig:<slug>}`) at the paragraph that discusses the object; add or lightly edit ONE sentence of prose to introduce it where needed. Do not rewrite the text otherwise.
- Use pgfplots (`house` style) where the figure is genuinely quantitative (fuel curves, exponent comparisons); otherwise TikZ.
- Every figure file compiles in isolation in the document; zero `Overfull` warnings originating from your figures; zero undefined references.

## Procedure
1. Compile the current document into `build/laneB` and run `python3 tools/figcoverage.py build/laneB/analytic-underpinnings.aux --from 10 --to 17` to see your pages.
2. Implement figures in plan order, compiling after every 3–4 figures. Fix every TikZ error before continuing.
3. After the whole plan: re-run the coverage tool for your page range. Every page in your range must have a figure. (Your range is determined by where your part starts and ends in the CURRENT build; other lanes' pages may shift — judge by section, not by absolute page number.) Add figures until it holds. Figures add pages: re-check.
4. Self-review each figure against the craft bar; look at the PDF pages (`pdftoppm -r 60 -f P -l P build/laneB/analytic-underpinnings.pdf out` then inspect with any image-viewing means available to you; if none, inspect the TikZ geometry by reasoning) and fix overlaps and misalignments.

## Report: `briefs/30B-figs-part1b.last.md` (write it yourself at the end; ≤ 60 lines)
STATUS line; the list of figures delivered (slug, page, ★ or not, one-line description); the coverage tool output for your range (verbatim summary line); overfull count from your figures; STYLE REQUESTS (styles you had to define locally); PLAN DEVIATIONS (figures replaced and why); FIDELITY NOTES (which gt labels you checked); KNOWN GAPS.
