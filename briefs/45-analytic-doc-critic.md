# Brief 45 — CRITIC verdict r1 on the analytic document `docs/analytic/` (fidelity to ground truth, mathematical correctness, pedagogy, figures)

You are the adversarial critic (Opus, with vision). ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/analytic-doc-r1.md` ONLY. Create files only under the scratch dir below; never edit repo files; never run git commands that change state. Evaluate the ARCHIVED tree at commit `e3fe341` (`git archive e3fe341 | tar -x -C <scratch>/tree`), compiling with `pdflatex -output-directory=<scratch>/build` (twice) and rendering pages with `pdftoppm -r 110 -png` to LOOK at figures with Read.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-analytic-doc-r1/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md` (north star; the ground-truth rule: `ground-truth/gt-*.tex` is the ONLY authority); `handoff.md` §"Representation requirements" (what the document is supposed to explain: TM → lambda underpinnings, computability refresher for physicists, why descriptions rather than closures).
2. `docs/analytic/FIGURES.md` §1 (visual system) and `briefs/37-analytic-doc-sidequest.last.md` (the five pedagogy suggestions — adjudicate them, do not just repeat them).
3. `docs/DESIGN.md` §1–3, §9, §12–13 and `claims/CLAIMS.md`: the document must not claim anything the claims ratchet does not (law 1), and must present F1 SOFTLY ("our reading of NW19 may be wrong").
4. The document: `docs/analytic/analytic-underpinnings.tex` + `parts/part1a,1b,2a,2b.tex` + every `figs/fig-*.tex`.

## Obligations
- **Fidelity audit**: every `\gt{label}{file}` citation and every stated theorem/definition/parameter in Part II must match the ground-truth TeX (open the cited gt file and line; recompute every number: field sizes, degrees, dimensions, level chains `9→5→7→9`, `206→840→848→1696`, Tseitin degree vectors, the `3Q` boundary). A misstatement of the paper is MAJOR; a claim stronger than CLAIMS.md is MAJOR.
- **Mathematical correctness of Part I**: the TM formalism, the two-state equality machine trace, the s-m-n / recursion-theorem arguments, the Z combinator and YCode, de Bruijn quotation, the Cook–Levin locality argument, the simulation theorems' cost bounds. Recompute every displayed trace and bound by hand; an error is MAJOR.
- **Pedagogy for a physicist reader**: for each section, is the motivation stated before the formalism; are notations defined before use; is there a worked miniature where the text goes abstract; does the roadmap on p.2 match the actual structure? Adjudicate the five brief-37 suggestions (ACCEPT with location / REJECT with reason).
- **Figures** (look at the rendered pages): for at least 30 figures chosen across all parts, does the figure show the mechanism the caption claims (not decoration); arrows direction; semantic colours per FIGURES.md; any remaining overlap/clipping; is the caption true. A figure that misleads about the mathematics is MAJOR; decoration-only figures are MINOR with a suggested replacement.
- **Consistency**: symbols (`TIME`, fuel, charge, level, description size) defined once and used consistently; every `\ref` resolves to the intended object; §14 correspondence tables agree with the code's actual names (grep `src/`).
- **Structure**: is anything missing that the north star requires (the executable Compress, the four transformations, the certificate grammar, the fixed point) or present that does not belong?

## Output: `verdicts/analytic-doc-r1.md`
Numbered objections: severity FATAL/MAJOR/MINOR/NOTE · exact location (part file:line or figure slug, page) · your independent computation or the gt line that contradicts · one-line FIX DEMAND. Then: the fidelity table (label → gt file:line → OK/DEFECT), the figure table (slug · page · verdict), the adjudication of the five suggestions, and a ≤ 12-line prioritised repair plan. Final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
