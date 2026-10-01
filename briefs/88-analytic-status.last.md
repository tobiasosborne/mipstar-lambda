# Brief 88 — analytic document status probe (Sonnet, 2026-10-01, pdflatex only)

Method: tracked `analytic-underpinnings.pdf` exists, so the build was done in a copy under the session scratchpad (`.../scratchpad/analytic/`). The repo tree was not touched except this file. No julia run.

## Build: result, pages, warnings
- `pdflatex -interaction=nonstopmode -halt-on-error` x2: both exit 0. Output: 92 pages, 1.50 MB.
- Warnings in final log: 0 Overfull, 11 Underfull (benign), 0 undefined references/citations, 0 missing figures; the only LaTeX Warning is "Label(s) may have changed" (from the first pass; the 2nd pass is clean).
- Page count 92 matches the figure count/brief-53 statement ("110 figures, one on every page of 92"), i.e. the PDF has not grown since repair round 2 although the code moved on (TB3-TB7).

## Figure coverage
- `tools/figcoverage.py [aux] [--from A --to B]`: reads the `.aux` lof/toc entries, prints figs per page, exit 1 if any page lacks one.
- Result: figures in range 110; pages without a figure: NONE; exit code 0. (Pages 1-92 all have >= 1 figure; the max is 2.)
- Counts: files in `docs/analytic/figs/` = 110; distinct figure files `\input` = 110 (107 from `parts/*.tex` + 3 from `analytic-underpinnings.tex`: `pipeline-glance`, `symbol-table`, `roadmap`); true orphans = 0; referenced-but-missing = 0. (`fig-config-path` is input at part1a.tex:109.)

## Figure plan vs reality (FIGURES.md)
All 77 plan items F0-F76 (incl. F0b, F63b, F68b, F70b) are DONE: every slug in the plan has a file in `figs/` and is input. No star figure dropped.
| group | planned | status |
|---|---|---|
| Lane A F0-F15 (pipeline-glance, roadmap, tm-anatomy, one-step, config-path, eq-machine-states, eq-machine-trace, verifier-normal-form, description-bits, timeout-wrapper, universal-machine, smn, diagonal, semidecision, kleene-square, quine, halt-f-construction) | 17 | DONE |
| Lane B F16-F35 (term-tree-scope ... two-layers) | 20 | DONE |
| Lane C F36-F58 (dual-rail ... three-presentations) | 23 | DONE |
| Lane D F59-F76 incl. b-items (trace-tableau ... final-accounting) | 20 | DONE |
| Added brief 47 (symbol-table, parameter-card, ar-invokes-pcp, three-provenances, grades, certificate-tree, exponent-ladder, miniature, tb7-card) | 9 | DONE |
Caveat: DONE = file exists and is placed; CONTENT of fig-ladder, fig-correspondence-map, fig-D-correspondence-{description,compression,typed,midpoint}, fig-tb7-card is stale vs code (see Staleness).

## Open verdict items (analytic-doc-r3 = last; r1, r2, r3 exist; r3 = PASS, closing round)
- m29 (MINOR): `figs/fig-correspondence-map.tex:16` `NO ROW` -> `C19 SKETCH`. Not verified fixed in this probe; fig-correspondence-map.tex lines 15/35 now read "absent; cited" and "C15 CONJ."; check line 16 (grep showed no `NO ROW` left in that file, so probably fixed).
- n6: per-theorem status chip (`C17 · SKETCH`) on the 13 Part II theorem/lemma environments (parts/ has 15 theorem/lemma envs; C16/C17 appear only 4x in part2a). OPEN.
- n7: Fig 98 (correspondence-map) caption states the claim column equals the §14.x table's Claim column. OPEN.
- n8: `(10.4)` equation tag overprints `F_C))` (p58); Fig 88 green box abuts `m'` (p74). OPEN.
- n9: ladder omits C1/C7 chips (the claims that did not land). OPEN, and now moot-ish: C1 is TESTED in CLAIMS; ladder needs a full re-transcription.
- n10: Fig 47 (three-provenances) bold column headers hyphenate mid-word. OPEN.
- Bead d48 (OPEN, P3) bundles n6-n10 plus "keep the doc in lockstep as TB3-TB7 land" — the lockstep part is the large one.

## Staleness vs code state (file:line -> correction)
CLAIMS.md: C1 TESTED, C11-C14 TESTED (C14 scoped), C12-C14 have code (`src/introspect/`, `src/compress.jl`, `test/tb5_repeat.jl`, `test/tb6b_introspect.jl`), C15 CONJECTURE but TB7 toy checkpoint executable (printed ToyPolicy, level chain 9->5->7->9, dims 206->840->848->1696).
- parts/part2b.tex:1170-1180 (§14.6 preamble): "the four rungs ... are not [landed]; ... four ratchet rows ... all stand at Conjecture ... No line of src/ implements them" -> TB4 (C11 TESTED), TB5 (C12/C13 TESTED), TB6 (C14 TESTED scoped) are implemented; only C15 stays CONJECTURE (TB7 toy checkpoint executes; soundness theorems CITED).
- part2b.tex:1202,1206,1210,1214,1219,1224 (§14.6 table cells): "absent; designed in DESIGN §9/§10/§11/§12", "no current implementation", claim column "C12/C13/C14 Conj." -> Julia names exist (`describe_*`, `AnchoredVerifier`/`repeat`, `introspect`, `compress`), claims C12/C13/C14 TESTED (C14 scoped to explicit toy child fuel), C15 CONJ. stays; grade column should be CHECKED/CITED mix, not all CITED.
- part2b.tex:1189 (caption fig:D-correspondence-compression) and figs/fig-D-correspondence-compression.tex:9 ("absent implementation"): "no implementation exists" -> Introspect, AnswerReduce, Repeat are built rungs; their soundness leaves stay CITED.
- part2b.tex:1229-1236 (§14.7 intro): "Nothing in it has been run." and figs/fig-tb7-card.tex:51 "nothing here has been executed" -> TB7 toy checkpoint is executed with a printed predicate report (C15 still CONJECTURE: two layers NOT_EXECUTED/VACUOUS stay).
- part2b.tex:953 (caption fig:ladder) and figs/fig-ladder.tex:23-41: chips "C15/C14/C13/C12 CONJECTURE", "NO ROW C10/C11 PROPOSED", footer "TB3-TB7 are designed and briefed, not executed here" -> C10, C11, C12, C13, C14 TESTED (C14 scoped); C15 CONJECTURE; TB3-TB7 executed. Also add C1 (TESTED) and C7 (CONJECTURE).
- part2b.tex:963-970 (§14.1 heading "planned TB3", "still absent") and :985-1002 ("CITED; absent" for bounded_trace, cook_levin, decouple5) and figs/fig-D-correspondence-description.tex:6: contradicts part2b.tex:266-272 (same file: "exist in src/frontend/") and C10 TESTED -> heading "TB3, landed", Julia columns CHECKED on fixtures, claim C10/C19.
- part2b.tex:1136 ("AnswerReduce ... no current row") and :1132 (`CitedDetypedVerifier`, "no current row"): C9 TESTED / TB2 answer-reduce certificate tree exist; give the C9 / C12 (executable DL9-detype) rows.
- part2b.tex:616-618: "C1 ... remains CONJECTURE" and :1042 "C1 Conj." -> C1 is now TESTED (explicit six-gate TB0 instance; formal coefficient identities).
- part2b.tex:1310-1316: "theorem-backed rather than executed here ... C12--C15 record that design at Conjecture ... What is missing is implementation" -> implementation exists for TB4-TB7 toys; what is missing is the soundness theorems (stay CITED) and a C15 verdict.
- part2b.tex:915-918 "Introspection soundness and normal-form closure are not implemented": the transformation is implemented (C14, scoped); soundness stays CITED, C7 stays CONJECTURE — reword.
- part2a.tex:532-537 ("The TB5-TB7 design adds four predicate outcomes", "the TB7 report of..."): tense — now built.
- part1b.tex:620-630, part1a.tex:563-570, analytic-underpinnings.tex:86, part2a.tex:219: pipeline text uses Compress=Repeat∘AnswerReduce∘Introspect correctly; no contradiction found.
- Counts: no occurrence of 12730 / 235 / test or mutant totals anywhere in parts/ (grep) -> nothing to correct; optionally add a one-line evidence statement (12730 passed / 1 broken; 235/235 mutants killed, HANDOFF session 7).
- Not checked in detail: remaining correspondence cells (§14.2-14.5, :1027-1103) for C9-C12 changes since brief 53; figs/fig-D-correspondence-{typed,midpoint}.

## Lanes 30A-D status
All four COMPLETED (each `.last.md` reports "pages without a figure: []", zero overfull/undefined, visual inspection): A 17 figs (part1a), B 20 figs (part1b), C 29 in range (part2a), D 30 in range (part2b). Reports reference `/home/tobias/Projects/discussions/...` paths (original machine). Their work is subsumed by the current 110-figure, 92-page state (repair rounds r1-r3, briefs 37/47/53/56).

## Recommended next brief
1. Opus writer, first: a §14.6/§14.7 + fig-ladder + fig-D-correspondence-{compression,description} + fig-tb7-card + §15 prose lockstep pass to the CLAIMS state (items above), keeping C15 CONJECTURE and all soundness theorems CITED; add C1 TESTED and C7 CONJECTURE to the ladder (n9). Then m29/n6/n7/n8/n10 (cheap).
2. Writer must re-run figcoverage (page count will grow) and keep figure/table claim cells identical (n7 invariant: add a grep check).
3. Sol critic should check: every claim chip against `claims/CLAIMS.md` row by row (r3 section 2.1 method); Julia-name cells against `src/` exports; tb7-card numbers against the printed TB7 report; no "absent/not run" survivors (grep list above); gt fidelity of any rewritten text.
4. Needs the C15 (TB7) verdict first: the final wording of §14.6 row `fig:compress`/`thm:compression`, §14.7 "two non-executed layers", fig-tb7-card and fig-final-accounting. Everything else (C10-C14 cells, ladder, n6-n10) can proceed now.
