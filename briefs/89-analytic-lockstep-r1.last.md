# Brief 89 — analytic lockstep r1 + n6–n10 (Opus proposer, 2026-10-01; pdflatex only, no Julia, no git)

## What changed
**A (prose).** part2b: TB3 paragraph (C10 TESTED via `verdicts/tb3-r2.md`; C19 SKETCH for the general construction); §12.4 close: C1 TESTED, scoped to the two retained proofs, formal identities, and 128 points on 16 named lines, "not acceptance at every z, not soundness"; §13.4: Introspect is built (C14 TESTED, scoped), C12 TESTED, `thm:introspection` CITED, C7 CONJECTURE; §14 preamble: one sentence saying a built transformation's row never promotes the cited theorem beside it; §14.1 heading is now "(TB3)" with new intro and caption; §14.6 preamble rewritten (C11/C12/C13 TESTED, C14 TESTED scoped to explicit toy child fuel, C15 CONJECTURE, "TB7 executes as a toy-policy checkpoint; C15 remains CONJECTURE pending critic r1", soundness theorems CITED); Fig 104 intro, caption and §14.7 intro (transcribes brief 44 + `test/tb7_compress.jl:118-120`; certificate tree not reproduced); §14.7 "only the Pauli-typed introspection predicates execute at TB7"; §15.1 Repeat paragraph rewritten (missing = analytic leaves, production-policy Compress (the 1 broken test), C15 verdict) and the evidence-boundary table rows. part2a: the predicate-outcome paragraph now lists 5 outcomes incl. NOT_EXECUTED, matching `src/policy/policy.jl:96`; Fig 47 caption no longer says "the middle column is the largest"; the reminder mentions the chips.
**B (figures).** fig-ladder re-transcribed (every row C1–C19, N1: C1,C2,C3,C8 / C6,N1 / C4a,C4c / C4b,C9 + C5 SKETCH / C10 / C11 / C13 / C14 scoped / C15 CONJECTURE + "toy checkpoint runs" / C12 under the DL9 box / C7 CONJECTURE chip / C16–C19 SKETCH box). This closes n9. fig-D-correspondence-compression: built boxes with C14/C9/C13 chips, Compress amber with C11 TESTED + C15 CONJECTURE, and a row of four CITED soundness leaves. fig-tb7-card: amber chain, full 13-row printed report with owners, footer as mandated. fig-D-correspondence-description: checked C10 box plus a dashed C19 leaf. fig-D-correspondence-typed: C4b/C9 chips, "detyping loss and thm:ar" "CITED — NO RATCHET ROW". fig-correspondence-map: row 1 is C10 TESTED; C19 SKETCH, row 6 is C11 TESTED; C15 CONJ. (m29: no `NO ROW` left). fig-evidence-boundary: 5+5 boxes, front end and Introspect/Repeat below the boundary, soundness above. fig-three-provenances col 3: adds C1, C4c, C10–C14.
**C (§14.2–14.5 cells).** C1 Conj.→Tested; `fig:ld-decider` "no current row"→C4c Tested, and `D_ld` (does not grep) was removed; `lem:cl-concat` row→C12 Tested (DL9 laws CHECKED); detyping row→`detype_sampler`/`detype_decider`, "C12 Tested; loss: no current row"; `thm:ar` row→"C9 Tested; contract: no current row". §14.1: `description_size`→`description_length`, `decider_input_sorted` (C11); `Eval`→`eval_program` (C11; C16 Sketch); added `pad5`. §14.6: design-only names `AnchoredVerifier`/`IntroVerifier` (they grep nowhere) replaced by `VerifierDescription`.
**D.** n6: `\statuschip` macro in figstyle.tex (amber, existing colours), placed on the 13 C16–C19 envs (11 in part2a, 2 in part2b). The zero-rewrite and level-laws lemmas have no row, so they get no chip. n7: invariant sentence in the Fig 98 caption. n8: the (10.4) split line is broken in two, and the tag is clear at p58 (inspected). Fig 88's policy box is now 2 lines and narrower, so the box is clear of `m'` at p74 (inspected). n10: Fig 47 headers use `\mbox` line breaks and no longer hyphenate (p37 inspected); box heights equalised at 5.3 cm. Also fixed: TB7 card's predicate column is now ragged-right.
**E.** §15.1 sentence: "As of 2026-09-27 … 12730 passed / 1 broken, all 235 registered mutants killed and 93/93 baselines (HANDOFF session 7: full runs before, and a focused run after, the removal of one memory bound)".

## Status traceability (doc location → claim → written → CLAIMS)
| location | claim | written | CLAIMS |
|---|---|---|---|
| p2b §12.4 close; TB0 table fig:pcpverifier; ladder; Fig 47 | C1 | TESTED | TESTED |
| ladder; Fig 47; TB0 table; map row 2 | C2/C3/C8 | TESTED | TESTED |
| TB1 table (4 rows); ladder; Fig 47; map row 3 | C4a/C4c | TESTED | TESTED |
| TB2 table; ladder; Fig 102; map row 4 | C4b/C9 | TESTED | TESTED |
| ladder; TB0 table `thm:pcp-decider` | C5 | SKETCH | SKETCH |
| ladder; TB0.5 table; Fig 47; map row 5 | C6/N1 | PROVED | PROVED |
| §13.4; ladder chip; Figs closure-gap/structural-hypothesis | C7 | CONJECTURE | CONJECTURE |
| TB3 paragraph; §14.1 table/caption; Fig 99; ladder; map row 1 | C10 | TESTED | TESTED |
| §14.1 rows 2–3; §14.6 fig:compress, fig:halt_f; ladder; Fig 104; map row 6 | C11 | TESTED | TESTED |
| TB1/TB2 detype rows; §14.6 def:sampler; §13.4; ladder | C12 | TESTED | TESTED |
| §14.6 anchoring row; Fig 104; ladder | C13 | TESTED | TESTED |
| §14.6 introspection row; §13.4; Fig 104; ladder | C14 | TESTED (scoped) | TESTED (scoped toy child fuel) |
| §14.6 preamble + 3 cells; §14.7; Fig 105; Fig 104; ladder; map row 6; §15.1 | C15 | CONJECTURE (toy checkpoint) | CONJECTURE |
| 13 env chips; §14.1 rows; Fig 99; ladder box; Fig 47 | C16–C19 | SKETCH | SKETCH |

## Grep table (`absent|nothing has been run|not executed here|no current row|NO ROW|Conj.`, -i)
| hit | justification |
|---|---|
| part2a:394, 603; part1a:444 "absent" | about lambda syntax and TM semantics, not status |
| part2b:946 "no current row" | definition of the phrase |
| part2b:1103 `lem:ld-soundness` no current row | correct: no CLAIMS row, CITED |
| part2b:1144 detyping loss: no current row | correct: the 16^|Type| loss has no row; executable detype is C12 |
| part2b:1148 thm:ar contract: no current row | correct: only the executable part is C9 |
| part2b:1200 "no row of this table promotes them" | prose, correct |
| part2b:1240, 1245, 1252; fig-correspondence-map:36 "C15 Conj." | correct: C15 CONJECTURE |
"nothing has been run", "not executed here" and "NO ROW": 0 hits. NOT_EXECUTED appears only as the printed TB7 row 10 and in the five-outcome list (correct). fig-D-correspondence-typed reads "NO RATCHET ROW" (correct, not a grep hit).

Julia identifiers: every `\code`/`\texttt` token in §14 and in the 7 edited figures was grepped in src/test/toys. All hit except: the DESIGN IR sorts `ClosedProgram` and `PartialProgram` (DESIGN.md §1.1, IR-sort column only); split cells (`CitedDetyped`+`Verifier`, `TypedAnswer`+`ReducedDecider/Verifier`, `typed_answer_`+`reduced_decider`, `sequential_and_`+`optval`), which all grep as wholes; and the claim ids. `sequential_and_optval` lives in `toys/midpoint/` (the table says so).

## Build (in place, pdflatex ×2, exit 0/0)
Before (scratch copy of HEAD): 92 pp, 0 overfull, 11 underfull, figcoverage 110 figs / 0 pages bare, exit 0. After: 92 pp, 0 overfull, 11 underfull, 0 undefined refs, no "Label(s) may have changed", figcoverage 110 figs, pages without a figure [], exit 0. One fix was needed to get there: fig:midpoint-diagnostic was moved before the evidence table to keep p90 covered.

## Not done / for the critic
- The §14.7/Fig 105/§14.6 C15 wording is final only until the brief-85 C15 verdict. The certificate tree and the fig-final-accounting figure were left untouched.
- fig-D-threshold-margin: the amber threshold line still crosses its own "1/2" tick label. This was there before and is cosmetic.
- C14's "N1/N2 strikes on HOLD pending TB6 r4" is not mentioned: the CLAIMS row carries no HOLD wording for C14 itself.
- Not re-checked: §14.2–14.5 Analytic-statement cells against gt line ranges (statuses and Julia names only).
