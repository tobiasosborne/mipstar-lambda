# Brief 32 — visual QA, LANE B (Part I §4–6, `parts/part1b.tex`, pages 16–29)

Build: `build/qaB` · rendered every page 16–29 at 110/300 dpi and inspected each figure.
Gates at final compile: **overfull 0, errors 0, undefined 0**; figcoverage: every page 15–29 has ≥1 figure.

## Per figure (slug · page · verdict)
- `term-tree-scope` · 16 · FIXED: "bound x" callout crossed the @–y edge; both annotation boxes moved below the leaves; bind arc now targets the node so its head lands *on* x.
- `beta-tree-surgery` · 16 · FIXED: REDEX and `t[x:=u]` sat on the panel borders; "copy u…" crossed the left panel edge; β arrow pierced both panels; panels ragged; violet `quote` arrow misused for substitution → rust `copyflow`, equal-height panels, β in the gap at root level, label two lines in the gap.
- `capture` · 17 · FIXED: double border (stray amber `fit` node) on the α-renamed box; "naive substitution" and `=_α` touched their shafts; the two outcomes were 2 mm out of level; "free argument" was floating → connector added.
- `confluence` · 17 · FIXED: "common reduct" moved below-right of w, off the v→w arrow.
- `normal-vs-cbv` · 18 · FIXED (redrawn): titles struck through the top boxes; both arrow labels escaped the panels; Ω was a 28 mm circle overflowing its panel; the Ω→Ω self-loop was degenerate → titles above the boxes inside the fit, Ω a rounded box, a real loop whose head returns into the box.
- `church-bool-if` · 19 · FIXED: a grey callout ran from `f` across the f→B edge and the SECOND tag into the green box's border → now B→boxed-B; FIRST/SECOND moved outside the trees.
- `church-pair` · 19 · FIXED: "true"/"false" text overflowed their circles → ellipses; the output A/B restyled to match the input A/B (amber had been on two nodes); the two input arrows no longer land on one point.
- `church-numeral` · 20 · CLEAN.
- `pred-ladder` · 21 · FIXED: the brace caption was centred on the figure, not on the brace; now centred on the brace span.
- `list-fold` · 21 · CLEAN.
- `y-derivation` · 22 · FIXED: `f:=h h` and "choose" straddled the box borders (8 mm gaps → 22 mm); `YF→F(YF)` was crossed by its own arrow (moved 6 mm off the shaft); "assemble" lifted off the wavy arrow.
- `factorial-unfold` · 23 · FIXED: `F(YF)`, "unfold", "base branch" all sat on box borders; the inline amber `redex` circles burst out of their parentheses (box 4 badly broken) → tight `inlineredex` boxes inside `\left(...\right)`, gaps 24/26 mm.
- `y-vs-z-cbv` · 24 · FIXED: η-DELAY and "argument a arrives" crossed the right panel border; titles overlapped the top boxes; the `F(λu.(ZF)u)` circle broke the parens; panels of very unequal height; hyphenated loop label → all inside equal-height panels, inline box, two-line label.
- `de-bruijn` · 24 · FIXED: all four `bind` arcs stopped short of their variables and their heads pointed past them into empty space → arcs target the nodes; trees separated 34→44 mm so "cross 1" clears the named tree.
- `quotation` · 25 · FIXED (redrawn): a thick `|-` arrow ran through the "prefix-free fields" label and straight through the evaluator box's text, with heads sliding along the box tops; Lambda/BoundVar(0) were oversized circles → clean fork from the byte strip into the two consumers, ellipse nodes, field label above the strip.
- `tm-to-lambda-zipper` · 26 · FIXED: "read view"/"list update" sat on the box borders; the tape→tape arrow was a stray arrowhead in a 3 mm gap; the L / focus s / R labels overlapped → 34 mm tape separation with a labelled "head right" arrow, second label line, equal-width tuple boxes.
- `lambda-to-tm-layout` · 26 · FIXED: "lookup 0" touched q_h; dropped the unexplained teal fill on region 1 so amber focus is the only coloured region.
- `dictionary-bridge` · 27 · FIXED: "MACHINE BANK" was rendered in check-green above teal machine boxes → machine teal.
- `pipeline-stages` · 28 · FIXED: the three glosses were centred under the boxes, not their arrows, and hyphenated ("cir-cuit", "sev-eral") → at the arrow midpoints with explicit breaks; uniform stage widths; panel ysep 14 mm.
- `two-layers` · 29 · FIXED: both ring titles were struck through by their own ellipse arcs; "rigidity"/"entanglement bounds" crossed the inner dashed ellipse; the outer boxes' corners poked out of the outer ellipse; two stub arrowheads, the right one pointing the **wrong way** (outward) → geometry rescaled (outer 7.4×3.5, inner 4.5×2.1), 2×2 grid of equal boxes, two-line outer title, both boundary arrows now point inward.

## Counts
20 inspected · 18 fixed · 2 already clean · **0 left with a residual**.

## STYLE REQUESTS (currently `\tikzset` at the top of the figure files, please promote to `figstyle.tex`)
- `copyflow` — rust wavy arrow for "copy/substitute this subterm" (`fig-beta-tree-surgery`). Needed because `quote` (violet wavy) is reserved for object→bytes and was being used for substitution.
- `inlineredex` — tight amber rounded box for a highlighted subterm *inside* a math node (`fig-factorial-unfold`, `fig-y-vs-z-cbv`). `redex` is a circle: used inline it balloons and escapes the enclosing parentheses.
- A `tag machine` companion to `tag check`/`tag cited`/`tag focus` would remove the `\node[tag check,text=machine]` workaround in `fig-dictionary-bridge`.

## Redraw-from-scratch
None outstanding. `normal-vs-cbv` and `quotation` were the two that needed it; both were redrawn in place (small figures).

## Cross-lane finding (NOT touched — outside lane B)
`parts/part2a.tex` line 1 is an orphaned fragment "the second." — the sentence it belonged to now ends in part1b §6 ("…as Figure~\ref{fig:two-layers} makes explicit."). It renders as a one-line stray paragraph at the bottom of p29. Lane C owns that file.
