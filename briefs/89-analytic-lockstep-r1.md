# Brief 89 — PROPOSER (Opus): analytic document lockstep pass r1 + pedagogy n6–n10

Role: writer/editor (Opus subagent). Autonomous; no questions. Lane: `docs/analytic/**` (parts, figs, FIGURES.md) and your report `briefs/89-analytic-lockstep-r1.last.md` ONLY. No Julia (a critic owns the Julia side of the machine); pdflatex is fine. No git commands that change state. The PDF/aux are tracked: build in place (`cd docs/analytic && pdflatex -interaction=nonstopmode -halt-on-error analytic-underpinnings.tex` twice) and leave the rebuilt PDF.

## Why
`briefs/88-analytic-status.last.md` (READ FIRST, in full): the figure programme is complete (110 figures, every page has one, figcoverage exit 0) but Part II §14.6/§14.7/§15 and several figures still say that TB3–TB7 are "absent / designed only / nothing has been run" and that C1, C10–C14 are Conjecture/No row. The ratchet says otherwise. The document must be in lockstep with `claims/CLAIMS.md`; it may NEVER be ahead of it.

## Authority (never from memory; never from the tutorial)
1. `claims/CLAIMS.md` — the ONLY source for statuses and verdict files. C1 TESTED; C9–C14 TESTED (C14 TESTED **scoped**: explicit toy child fuel, N1/N2 strikes on HOLD pending TB6 r4); C15 **CONJECTURE**; C16–C19 SKETCH; C7 CONJECTURE; C5 SKETCH; C6/N1 PROVED; C8 TESTED (refutation).
2. `HANDOFF.md` §"RESUME (session 7)" + `briefs/44-tb7-compress.last.md` (first 40 lines) for what TB7 IS: an executable WIP CHECKPOINT under a printed ToyPolicy (n=2, λ=32768, s_0=9): composition order constructed, level chain 9→5→7→9, dimensions 206→840→848→1696, fixed point 5/5, 317-node certificate, 13-row predicate report with owned FAIL/VACUOUS/NOT_EXECUTED rows. Critic r1 (brief 85) is RUNNING; until its verdict, the document says exactly: "executes as a toy-policy checkpoint; C15 remains CONJECTURE pending critic r1". Do not describe TB7 as verified, and do not reproduce the certificate tree.
3. `docs/DESIGN.md` §§9–13 and `docs/definitions.md` for Julia names and term-language facts; verify every Julia identifier you write with `grep -rn` in `src/` and `test/` (the document's correspondence tables name functions/files — a name that does not grep is a defect).
4. `ground-truth/gt-*.tex` for anything about the paper's construction; cite `gt-NN:Lxx–Lyy`.
5. `verdicts/analytic-doc-r3.md` for n6–n10 (and m29) — read the items verbatim.
6. Soundness theorems (thm:introspection soundness, thm:ar, thm:compression, parallel repetition) REMAIN CITED leaves everywhere. Introspect/Repeat/AnswerReduce/Compress are BUILT transformations whose contracts are TESTED on toys; never conflate the two.

## Edits (every item in brief 88 §"Staleness vs code state", plus n6–n10)
A. `parts/part2b.tex`: §14.6 preamble (~L1170–1180), §14.6 table cells (~L1202–1224), caption fig:D-correspondence-compression (~L1189), §14.7 intro (~L1229–1236), §14.1 heading/cells (~L963–1002), AnswerReduce/detype "no current row" cells (~L1132–1136), C1 wording (~L616–618, L1042), §15 prose (~L1310–1316), §"Introspection soundness … not implemented" (~L915–918). `parts/part2a.tex` ~L532–537 tense. Line numbers are from brief 88; re-locate by content.
B. Figures: `figs/fig-ladder.tex` (full re-transcription of chips from CLAIMS: every claim C1–C19, N1; add C1 and C7 → closes n9), `figs/fig-D-correspondence-compression.tex`, `figs/fig-tb7-card.tex`, `figs/fig-D-correspondence-description.tex`, and check `fig-D-correspondence-{typed,midpoint}.tex` + `fig-correspondence-map.tex` (m29: no `NO ROW` left; C19 SKETCH).
C. Also check the §14.2–14.5 correspondence cells (~L1027–1103) against CLAIMS/src — brief 88 did not.
D. Pedagogy: n6 (a status chip `Cxx · STATUS` on each Part II theorem/lemma environment that corresponds to a claim; chips come from CLAIMS; use the existing chip macro from `figstyle.tex` if any, else define ONE small macro there), n7 (caption invariant sentence on the correspondence-map figure), n8 (the (10.4) tag overprint on p58 and the Fig 88 green box abutting `m'` on p74 — fix by spacing/placement, verify in the rebuilt PDF via `pdftotext` or page inspection), n10 (hyphenating bold headers in Fig 47 — `\mbox` or wider column).
E. Optional one-line evidence statement in §15 (12730 passed / 1 broken; 235 mutants all killed; 93/93 baselines — HANDOFF session 7), labelled as of 2026-09-27.

## Discipline
- Every status word in the document must be traceable to a CLAIMS row; make a table in your report: document location → claim id → status written → CLAIMS status (must match).
- Keep the visual system (`figstyle.tex` styles only; FIGURES.md rules). No new colours.
- Rebuild twice; `python3 tools/figcoverage.py` must exit 0; 0 undefined refs; report overfull/underfull counts before/after. Page count may change; every page still needs a figure.
- `grep -n -i "absent\|nothing has been run\|not executed here\|no current row\|NO ROW\|Conj\." docs/analytic/parts/*.tex docs/analytic/figs/*.tex` after editing: every remaining hit must be justified in the report (e.g. C15 CONJECTURE is correct; "NOT_EXECUTED" rows of the TB7 predicate report are correct).

## Output
`briefs/89-analytic-lockstep-r1.last.md` (≤ 80 lines): what changed per item A–E; the status traceability table; the grep table; build numbers (pages, overfull, underfull, figcoverage exit); items you could NOT do and why. Hand back a 10-line summary.
