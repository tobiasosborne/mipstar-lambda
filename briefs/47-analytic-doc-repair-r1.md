# Brief 47 — analytic document repair r1 (work order = verdicts/analytic-doc-r1.md: M1–M11 MAJOR, the 21 MINORs, 3 NOTEs, the accepted pedagogy items S1/S2/S3/S5, and the 12-step repair order)

You are an Opus agent with vision. You own ALL of `docs/analytic/` this round; edit nothing outside it (DESIGN/CLAIMS changes go in MERGE PROPOSALS in your report). No git, no Julia (grep `src/`/`test/` for identifiers is required). Compile ONLY into `docs/analytic/build/rep1/` (pdflatex twice, three if refs move); render with `pdftoppm -r 110 -png -f P -l P` into your scratch dir and LOOK at every figure you touch, before and after.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/doc-repair-r1/`

## Read order
1. `verdicts/analytic-doc-r1.md` IN FULL — it is the binding work order, including its repair order (1)–(12). Then `CLAUDE.md` (ground truth = `ground-truth/gt-*.tex` ONLY; cite line ranges), `docs/analytic/FIGURES.md` §1, `docs/DESIGN.md` §1.1 (λ, Quoted, Checked{T,C} grammar), §3 (certificate grammar), §9–§13 (TB5–TB7, the level chain `9→5→7→9`, dims `206→840→848→1696`), `claims/CLAIMS.md` (CURRENT rows: C4a, C4b, C9 are TESTED; C12–C15 CONJECTURE; C5 SKETCH — the document may state nothing stronger, law 1).
2. The ground-truth lines the verdict cites for each MAJOR (M2: `gt-10-answer-reduction.tex` L1105–L1107 and eq:5sat; M1: `gt-12-compression.tex` L435–L440 fig:halt_f; M6: the simulation-cost source in Part I's own argument).

## Work order (in the verdict's order; each item: fix, recompile, re-render the affected page, look)
1. **M2** rewrite `parts/part2b.tex` ~L215 and redraw `fig-decoupled-5sat` so literals land in `w_1,w_2,w_3` per gt-10 L1105–L1107 and eq:5sat; the figure must agree with `fig-D-decider-guards` on the same page.
2. **M4/M5** `fig-ladder`: TB5 = Repeat (C13), TB6 = Introspect (C14), TB7 = Compress (C15), TB3/TB4 = C10/C11 (proposed rows; label them "proposed"), chips transcribe CLAIMS.md exactly; §14.6 rewritten to the current state (TB0–TB2 landed and under critic rounds; TB3–TB7 briefed with DESIGN §9–13 converged); add the **TB7 parameter card** (S2): λ, μ, γ, τ, k(n), the level chain and dimension chain, with gt citations.
3. **M1** global rename `L : Level` → the paper's `λ` in §10.3/(10.4) and the 7 figures; keep `level(V)` distinct; MERGE PROPOSAL for DESIGN §1.1 if any wording there conflicts.
4. **M3** level laws as memberships/upper bounds (`rk:higher-level`; C4a disclaims minimality); include the `id ⊕ id` counterexample in a footnote or margin note.
5. **M9/M10** replace the four non-existent Julia names by the real ones (grep `src/`), re-grade `ld_decider` under the correct claim (C9/TB2 evidence, not C4a), fix every wrong claim id in §14 (S4 counter-demand).
6. **M8** `fig-four-layers`: the C5 layer is SKETCH/CITED, never EXECUTED; then move the figure to the head of §12 (S3).
7. **M6** fix the simulation-theorem exponent so statement and proof agree (state the honest exponent with the argument that gives it; if a tighter one is claimed, prove it in the text).
8. **M7** every Part I/II theorem the document asserts as its own result gets either a `\gt` citation (if it is the paper's) or a MERGE PROPOSAL row at SKETCH in your report (statement with quantifiers, where-proved = the section); the document text must say "SKETCH — not yet adversarially verified" for those.
9. **M11** a short subsection presenting the `Checked{T,C}` certificate grammar of DESIGN §3 (CHECKED / CONSTRUCTED / CITED / ASSUMED / SOURCE_REPAIR / NOT_EVALUABLE / VACUOUS) with one figure drawing a real certificate tree (take the shape from `test/tb2_answer_reduce.jl`'s printed tree).
10. The four visible blemishes: orphan sentence p29 (find it in the PDF, fix the source for real this time), display (8.2) arity, Fig 80 swap, p54–56 float order.
11. **S5** symbol table after the abstract (TIME, fuel, charge, level, description size, λ, Q, R, k(n)); **S1** the §11 worked miniature (one 2×4 toy tableau carried CEK trace → succinct 3SAT → decoupled 5SAT).
12. All 21 MINORs and 3 NOTEs, each with a one-line disposition.
Final gate: two/three passes, 0 errors, 0 overfull, 0 undefined, `python3 tools/figcoverage.py` lists no page, every figure you touched re-rendered and inspected; copy the PDF to `docs/analytic/analytic-underpinnings.pdf`.

## Report: `briefs/47-analytic-doc-repair-r1.last.md` (≤ 70 lines)
Response table M1–M11, m1–m21, n1–n3, S1–S5: FIXED / DOWNGRADED / RESIDUE with part:line or figure slug; the final gate numbers; figures redrawn (slug · page · before→after one line); MERGE PROPOSALS (DESIGN §1.1 wording; SKETCH claim rows for M7 — verbatim rows in CLAIMS format).
