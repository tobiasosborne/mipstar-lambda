# Brief 37 — analytic-document sidequest: visual QA (lanes A, C, D), two page fills, style promotion

Build `docs/analytic/build/sq`. Every page of parts 1a / 2a / 2b rendered at 110 dpi and looked at;
suspect figures re-rendered at 250–600 dpi and re-checked after each fix.

## 1. Styles promoted into `figstyle.tex` (single source)
`copyflow` (rust wavy copy/substitute, distinct from violet `quote` = object→bytes) ·
`inlineredex` (tight amber box for a subterm inside a maths node) ·
`tag machine` (+ `tag desc`, `tag bad`) beside `tag check`/`tag cited`/`tag focus`.
Local `\tikzset` removed from `fig-beta-tree-surgery`, `fig-factorial-unfold`, `fig-y-vs-z-cbv`;
`\node[tag check,text=machine]` workaround in `fig-dictionary-bridge` → `tag machine`.
`grep -l tikzset figs/*.tex` is now empty; pp. 16/23/24 re-rendered, identical.

## 2. New figures (FIGURES.md plan table updated with all three)
- `occurrence-vs-degree` · p62 (F1 finding). Three panels: the two-gate fixture with the amber
  wire `w_1`; a ledger of its four literal occurrences; the three accounts of `deg_{w_1}`
  (source proposition ≤2 CITED / occurrence bound ≤4 / `arith_q` sparse support =4 TESTED) with
  a red "differ" and an ink "attained". Caption keeps the soft framing and cites `docs/findings.md` F1.
- `chi-axis-buckets` · p70 (§13.2). F_8 split into m=2 buckets of 4; sampled s=5 ⇒ χ(s)=2 ⇒ e_2;
  the two CL stages that make `L_ALine` level two.
- `D-decider-guards` · p72 (added: filling p69/p62 pushed a new hole to p72; the gate needs it).
  The five guarded checks of `fig:decider-pcp` in order, one shared rejection bar, amber
  fall-through for a type pair whose trigger never fires. Checked against gt-10 lines 2004–2065.

## 3. Figures FIXED (all others inspected CLEAN)
- `pipeline-glance` · 1 · FIXED: "EXECUTED ON FINITE DESCRIPTIONS" touched the dashed cited arrow rising into Introspect → three short lines.
- `kleene-square` · 14 · FIXED: "two copies of p" and the grey gloss sat inside the specialize box; the violet feedback arc ran *through* both boxes (bend left, wrong side); the four amber `=` were double-headed arrows drawn across box borders → arc above the row, gaps 20/17 mm, `=` set in the gaps, chain→identity arrow reversed; width 498→448 pt.
- `quine` · 15 · FIXED: the amber "same finite string" arc crossed the whole output tape and its head landed inside ⟨e_Q⟩ → arc now runs above the tape from the first cell.
- `halt-f-construction` · 16 · FIXED (rebuilt): "halts", "otherwise", "self code" and the amber self-code gloss all straddled box borders; the ComputeSampler box was clipped by the cited box; the ⟨d^c⟩ return arrow collided with the 0/1 cell; the "otherwise" branch ran along the middle row's top edges; picture was 26 mm over \textwidth (middle row anchored under `F`, not `inputs`).
- `eval-delimiter` · 39 · FIXED: the step arrows started at the *text* edge, so each shaft crossed its own counter box → matrix cell nodes, edge-to-edge.
- `u-l-heap` · 46 · FIXED: "lazy head-and-position link" sat on the callout shaft → below-right of it.
- `resource-dictionary` · 47 · FIXED: both bound boxes exactly covered their arrows (no heads visible) and "interpret" was half-hidden under one → boxes narrowed to 33 mm, labels moved off; fuel node given its own gloss.
- `trace-tableau` · 57 · FIXED: `cell blank`/`cell head`/`cell,fill=` re-apply `cell` and reset `minimum width`, so rows C_0, C_r, C_F were out of column; the τ arrow pointed into the gap between two cells → uniform cell width, τ retargeted into `b'`.
- `tseitin-fanout` · 63 · FIXED: the two panels had different heights, so "computed fixture" and "source proposition" sat at different heights either side of "compare" → filler coordinate + shared baseline.
- `pcp-local-verifier` · 66 · FIXED: "few reads" and "accept iff both" were drawn over their arrow shafts (`inner sep=0.5pt`) → lifted 1.4–1.6 mm.
- `chi-axis-buckets` · 70 · FIXED during QA: "sampled seed coordinate s=5" overlapped stage 1's border; the callout ended 3 cm outside the box.

## 4. Counts
Front matter + part 1a: 17 inspected · 4 fixed · 0 residual.
Part 2a: 29 inspected · 3 fixed · 0 residual.
Part 2b: 35 inspected (3 new) · 5 fixed · 0 residual.
Part 1b (lane B, already complete): 3 re-checked after the style promotion, unchanged.
**81 figures inspected · 12 fixed · 3 added · 0 residual.**

## 5. Final gate (`build/sq`, three passes, then copied to `docs/analytic/analytic-underpinnings.pdf`)
pages **82** · overfull **0** · undefined **0** · errors **0** · `grep -c Warning *.log` = **0** ·
`figcoverage.py`: 101 figures, **pages without a figure: []** · (4 underfull hboxes: loose
justification in two captions and one paragraph, not layout damage).

## 6. Pedagogy suggestions for the next doc round
1. §11.1–11.3 jumps from the CEK trace to succinct 3SAT to decoupled 5SAT with no worked
   miniature; a single 2-row × 4-cell toy tableau carried through all three would anchor it.
2. Part II never restates the four global parameters (λ, μ, γ, and the level chain 9→5→7→9) in
   one place; a one-page "parameter card" early in §7 would stop the reader re-deriving them.
3. §12.4's four soundness layers are the argumentative core but arrive after the algebra; moving
   the layer figure to the head of §12 would frame everything that follows.
4. §14's six correspondence tables are longtables read straight through; splitting each into
   "what the code constructs" vs "what the code only labels" would make the evidence grade land.
5. The document defines `TIME`, fuel, charge, level and description size in five different
   places; a short symbol table after the abstract would pay for itself by §9.
