# docs/analytic — Analytic Underpinnings

Build (from this directory):

    pdflatex -interaction=nonstopmode -halt-on-error analytic-underpinnings.tex   # run twice

Layout:
- `analytic-underpinnings.tex` — preamble only; `\input`s the parts below.
- `figstyle.tex` — the single visual system (palette, TikZ node/arrow styles, pgfplots house style). Figures use ONLY these styles.
- `parts/part1a.tex` (§1–3), `parts/part1b.tex` (§4–6), `parts/part2a.tex` (§7–10), `parts/part2b.tex` (§11–15).
- `figs/fig-<slug>.tex` — one TikZ figure body per file, `\input` from the part that uses it.
- `FIGURES.md` — visual system rules and the figure plan (one figure per page minimum).
- `tools/figcoverage.py` — pages without a figure, from the `.aux`; exit 1 if any.
