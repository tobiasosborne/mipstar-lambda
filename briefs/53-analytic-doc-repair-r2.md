# Brief 53 — analytic document repair r2 (work order = verdicts/analytic-doc-r2.md: M12–M17 MAJOR, m22–m28 MINOR, n4–n5 NOTE, and the six PARTIAL rows M1, M3, M7, M8, M10, m10 from r1)

You are an Opus agent with vision. You own ALL of `docs/analytic/`; edit nothing outside it. No git, no Julia. Compile ONLY into `docs/analytic/build/rep2/` (pdflatex ×3); render with `pdftoppm -r 110 -png -f P -l P` and LOOK at every page you touch, before and after.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/doc-repair-r2/`

## Process rule (from the critic's process finding)
Three r1 rows were reported FIXED but were only partly fixed in the delivered PDF, and two figures named in the r1 response table were never edited at the cited sites. This round: **every row in your response table must cite the page number in the FINAL PDF where the fix is visible, and you must have rendered and looked at that page after your last compile.** A row without a page you looked at is not FIXED.

## Read order
`verdicts/analytic-doc-r2.md` IN FULL (binding); `verdicts/analytic-doc-r1.md` for the PARTIAL rows' original demands; `claims/CLAIMS.md` (C16–C19 SKETCH govern the document's own Part II theorems — cite them by id wherever the text now says "no row"; C2/C3/C4a/C4b/C8/C9 TESTED; C5 SKETCH covers only what its row says — `thm:ar` is NOT under C5: it is CITED, with the executable part under C9/TB2); `docs/DESIGN.md` §1.1 (λ), §4 (soundness layers: what is CHECKED at the fixture vs CITED — Schwartz–Zippel is CITED), `FIGURES.md` §1.

## Work order
1. **M12** the four residual `L`-for-`λ` sites in three figures (Fig 69 self-contradiction first); grep every `figs/*.tex` and `parts/*.tex` for the pattern the verdict gives and fix all.
2. **M13** replace the four "no row in CLAIMS.md" sentences by the C16–C19 SKETCH provenance (exact ids per theorem: C16 semantics §8, C17 bridge §9, C18 self-reference §10, C19 Cook–Levin §11); §14 Claim cells accordingly; `fig-three-provenances` and `fig-ladder` chips updated if they mention it.
3. **M14** Fig 90 level laws as memberships/upper bounds, consistent with the page's text.
4. **M15** Fig 47 anchoring so no evidence tag is overstruck (render and look).
5. **M16** `thm:ar` graded CITED (executable classical part: C9 / TB2), not "C5 SKETCH"; sweep every grade chip that names C5 and check it against C5's row text.
6. **M17** Fig 84 box 3: the Schwartz–Zippel lemma is CITED (gt-03 lem:schwartz-zippel), never "CHECKED AT THE FIXTURE"; agree with §12.4 and Fig 88.
7. The six PARTIAL rows (M1, M3, M7, M8, M10, m10) to full: read each residual in the r2 verdict and finish it.
8. m22–m28, n4–n5 with one-line dispositions.
Final gate: 0 errors/overfull/undefined, `figcoverage.py` lists no page, 0 backward figure/page pairs; copy the PDF to `docs/analytic/analytic-underpinnings.pdf`.

## Report: `briefs/53-analytic-doc-repair-r2.last.md` (≤ 50 lines)
Response table with **final-PDF page number per row** (M12–M17, m22–m28, n4–n5, the six PARTIALs): FIXED / RESIDUE; gate numbers; figures touched (slug · page · what); any MERGE PROPOSAL (DESIGN/CLAIMS wording only).
