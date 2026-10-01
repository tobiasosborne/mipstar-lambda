# Brief 92 — CRITIC (codex gpt-6.1-sol, xhigh): analytic document r4 — lockstep + citations + pedagogy

You are the adversarial critic. ATTACK; do not summarize. Autonomous; no questions. Lane: write `verdicts/analytic-doc-r4.md` ONLY; scratch under `<SCRATCH>/critic-analytic-r4/`; never edit repo files; NO git commands that change state. No Julia (another worker may own the Julia side; `grep` over `src/`/`test/` is how you check code facts). pdflatex is allowed in a scratch copy of `docs/analytic/`.

## What changed since your predecessor (`verdicts/analytic-doc-r3.md`, PASS)
Session 8 (2026-10-01), commits 8f59e2a and a39375e, reports `briefs/88-analytic-status.last.md`, `briefs/89-analytic-lockstep-r1.last.md`, `briefs/90-analytic-citation-check.last.md`, `briefs/91-analytic-citation-fix.last.md`:
- Part II §14.1/§14.6/§14.7/§15, `figs/fig-ladder.tex`, `fig-tb7-card.tex`, `fig-D-correspondence-{compression,description,typed}.tex`, `fig-correspondence-map.tex`, `fig-evidence-boundary.tex`, `fig-three-provenances.tex` re-transcribed from `claims/CLAIMS.md` (C1, C10–C13 TESTED; C14 TESTED scoped; C15 CONJECTURE as a toy-policy checkpoint; soundness theorems CITED).
- Julia identifiers in §14 replaced by names that grep in `src/`/`test/`.
- Pedagogy n6–n10 and m29 closed (`\statuschip` macro in `figstyle.tex`).
- Six citation defects fixed; the orchestrator REJECTED the checker's "defect 2" (sec:ld-encoding, gt-03:L874–L892 does define the multilinear g_a). Two footnotes for the known source typos (CLAUDE.md).

## Authority
`ground-truth/gt-*.tex` for the construction (never from memory; cite `gt-NN:Lxx–Lyy`); `claims/CLAIMS.md` for every status; `docs/DESIGN.md`, `docs/definitions.md`, `src/**`, `test/**` for code facts; `HANDOFF.md` §"RESUME (session 7)" and `briefs/44-tb7-compress.last.md` for what TB7 is (checkpoint; C15 CONJECTURE until `verdicts/tb7-r1.md` exists — if that file exists when you run, read it and judge the document against ITS verdict, not against the checkpoint description).

## Obligations
1. **Lockstep audit (the ratchet rule: the document may never be ahead of CLAIMS).** Every status word, chip, ladder rung, table cell, caption and prose sentence that asserts a status or an "implemented / executed / verified" fact: table of location → claim → written → CLAIMS → MATCH/AHEAD/BEHIND. Any AHEAD is MAJOR. Check prose too, not only chips (brief 90 checked only status words adjacent to a C-id).
2. **Julia-name audit.** Every identifier in §14 tables and the correspondence figures: `grep -rn` in `src/`, `test/`, `toys/`; report any that do not exist or exist with a different signature/role than the cell claims.
3. **Ground-truth fidelity.** Re-check ALL 79 citation sites from brief 90 independently (do not trust its OK verdicts), and adjudicate the orchestrator's rejection of defect 2. Each `\gt{label}{file}`: does the label live in that file (`grep -n '\\label{'`)? Does the sentence attribute only what the cited text says?
4. **Regression sweep** of r3's items m1–m29, n1–n10: still closed?
5. **Figures.** Rebuild in scratch; `tools/figcoverage.py` must exit 0; inspect (pdftoppm a page, or pdftotext) the edited figures: fig-ladder (all C1–C19, N1 present with correct statuses), fig-tb7-card (13 predicate rows match `test/tb7_compress.jl`'s asserted statuses — grep the test), fig-correspondence-map, fig-three-provenances column 3, the two n8 overprint sites, Fig 47 headers (n10).
6. **Pedagogy** (physicist reader, front to back): does the §14.6/§14.7/§15 story now say clearly what is built, what is tested on toys, and what is cited — without overclaiming? List overclaims or underclaims with the sentence quoted.

## Output
`verdicts/analytic-doc-r4.md`: sections 1–6 as above, then `## 7. Repair plan (≤ 5 lines)` and a final line `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`. Every finding: file:line, the quoted text, the authority that contradicts it, severity MAJOR/MINOR. Say explicitly what you did NOT check.
