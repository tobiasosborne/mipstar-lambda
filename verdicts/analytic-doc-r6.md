# Analytic document r6 — closing review of brief 96

Target: **archived commit `bc48af2`**, extracted with `git archive bc48af2 | tar -x -C <scratch>/tree`. Scratch is `/tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/critic-analytic-r6/`. All document, code, claim and verdict citations below refer to that archive. `verdicts/analytic-doc-r5.md` and `briefs/96-analytic-repair-r3.last.md` were read **in full**; both are byte-identical between the archive and the live files initially read.

**Three DISCHARGED, one PARTIAL, zero NOT.** The semantic repairs pass. All six named figures now follow their first references. The literal requirement for **every one of 110 figures** still fails: 32 referenced figures precede their first reference in rendered reading order. This is a MINOR placement defect, not a new promotion of an unverified claim.

## 1. Discharge of R4, R10, F1 and F2

| Item | Ruling | New text and location | Reopened authority and reasoning |
|---|---|---|---|
| R4 | DISCHARGED | `docs/analytic/parts/part2a.tex:517–520`: “callbacks at visited nodes”; “It stops at the first failure”; “Only a passing walk guarantees that every CHECKED replay ran and passed.” | `src/certificates.jl:88–105,108–120` at `bc48af2` checks the local replay and returns on the first local or child failure. `verdicts/tb7-r1.md:9–13,295–298` separates unauthenticated recorded facts from callbacks and explains why the critic replayed nodes individually. The new `BoundReplay` implementation at `src/certificates.jl:31–65,73–105` is present in the target, but is not an independently verified discharge of T7-2. The document retains that distinction at `part2a.tex:530–538`. |
| R10 | DISCHARGED | `docs/analytic/parts/part2b.tex:973–977`: “C2 checks the rewrite on its fixtures”; “C12 checks description-law AST equality against a separately transcribed table and evaluates the laws at the tracer index”; semantic implications “stay CITED.” | `claims/CLAIMS.md:9` (C2) covers the retained zero-basis witnesses; `:11` (C4a) explicitly excludes concatenate/direct_sum/product/TypedSampler; `:22` (C12) authorizes the stated AST/tracer checks and retains CITED semantics. Reopened `ground-truth/gt-04-cl.tex:282–363`: concatenation gives level k+ell (`:284–291`) and direct sum max level (`:317–326`), with proofs. No C4a credit remains in the repaired sentence. |
| F1 | DISCHARGED | `docs/analytic/parts/part2b.tex:1429–1431`: “agrees in four of nine cases”; “the other five complete decisions reject at the disclosed unexecuted game layer”; “its CHECKED replay fails.” | `verdicts/tb7-r1.md:45–49` gives exactly four agreements, five rejected complete decisions, and the failed pristine CHECKED replay. |
| F2 | **PARTIAL** overall; the named moves are discharged | `docs/analytic/parts/part2a.tex:1458–1465`: “Figure … closes the construction” now precedes `[H]`. `part2b.tex:1354–1355`: “Figure … closes the account at the fixed point itself” now precedes its environment at `:1389–1394`. | The rebuilt PDF and its aux/link/caption coordinates confirm 70, 90, 94, 104, 108 and 109 all follow their first references (§3). The stronger all-110 requirement fails independently: four earlier-page previews and 28 same-page inversions remain. Figure 2 has no reference. No theorem authority is relevant to this typographical condition; the authority is the archived source plus its independently built output. |

Quotes normalize TeX styling. R4 is a statement about traversal, not a certification of the brief-93 binding repair; R10 distinguishes a description-law check from the semantic closure theorem; F1 states the governing r1 result, not a fresh run of the repaired code.

## 2. Regression against governing claims and verdicts

The required `git diff 632a17f bc48af2 -- docs/analytic/parts` was opened in full. Its prose changes narrow traversal, correct the C12 scope, and correct the T7-8 count; its other changes move a figure introduction, change figure 70's placement, and enlarge one page by one baseline. No changed sentence promotes C14/C15 or turns the brief-93 repair into verified evidence. Governing authorities remain TB7 r1 and TB6 r4; neither `docs/assessment.md` nor `verdicts/tb7-r2-pre.md` is used as authority.

| Governing state reopened | Document text checked | Result |
|---|---|---|
| `verdicts/tb7-r1.md:119,584`: C15 HOLD; no TESTED replacement; FAIL(T7-1,…,T7-8). `claims/CLAIMS.md:25` retains CONJECTURE with its zero-dispatch HOLD annotation. | `part2b.tex:1230–1233,1306–1313`: “returned FAIL with C15 on HOLD”; brief 93 “had not been reviewed”. `:1422–1436` still names all eight obligations and the missing production construction. | MATCH. The revised agreement count matches T7-8, not a later preliminary assessment. |
| `verdicts/tb6-r4.md:1–13,31`: FAIL(T6-1,T6-2), C14 replacement HOLD; C11–C13 priors not reopened. `claims/CLAIMS.md:24` retains the earlier scoped TESTED row with a HOLD annotation. | `part2b.tex:1227–1239`: C14 “keeps its earlier TESTED row”; replacement “is on HOLD, with two findings … open”. `:1432–1434` repeats that status. | MATCH. A held replacement does not erase the narrower prior. |
| `verdicts/tb7-r1.md:33–37,83–99,101–119`: no Pauli dispatch, row 6's local surrogate, actual-D1 game unexecuted, finite self-reference only. | `part2b.tex:1247,1317,1321–1337,1416–1421`; `fig-tb7-card.tex:37–56`; `fig-D-correspondence-compression.tex:8–27`. | MATCH. The thirteen card cells remain explicitly PRINTED, not independently verified policy decisions. |
| `verdicts/tb7-r1.md:127–155`: suite 12729 pass / 1 broken; registry exit 1, 233/235, baselines 93/93. | `part2b.tex:1441–1449` separates the earlier author history from that governing run and says neither run covers brief 93. | MATCH as historical counts. No timing measurement is evidence in this review. |

The target archive already includes the `BoundReplay` code (`src/certificates.jl:31–65,73–105`). That does not supersede the governing verdict. The nearby text expressly discloses an unreviewed repair (`part2a.tex:535–538`), so retaining the r1 findings is appropriate under this brief. The other live-tree assertion, “0 of 164 oriented pairs” (`part2b.tex:1333`), is provisional implementation reporting, not an independently reproduced result here.

## 3. Figures and archived build

All builds ran inside the extracted archive's `docs/analytic/`. No Julia build, dependency installation or clean/rebuild command ran; the requested archive had no cached auxiliaries.

| pdflatex pass | Exit | Pages | Undefined-reference warnings | Overfull | Underfull | Actual rerun warnings |
|---|---:|---:|---:|---:|---:|---:|
| 1 | 0 | 93 | 274 | 0 | 11 | 1 |
| 2 | 0 | 94 | 0 | 0 | 12 | 1 |
| 3, required by pass 2's warning | 0 | **94** | **0** | **0** | 12 | **0** |

Passes 2→3 changed **0 of the 3 aux/toc/out files**. Both final-pass PDFs were 1,520,063 bytes; size alone is not used as a content-equality check. The remaining word “Rerun” in pass 3's log is the `rerunfilecheck` package description, not a warning. `python3 tools/figcoverage.py` **exited 0: 110 figures; pages without a figure `[]`**. There are **0 backward figure-page pairs** and **0 undefined references** in the stable build. These successful checks do not establish first-reference order.

**All-figure method and result.** I inventoried all 110 source environments/labels, matched each aux number/page to its PDF named destination, and located every figure-reference hyperlink in PDF reading order. I reconciled the two symbol-table references to figure 43 (`figs/fig-symbol-table.tex:36,42`) and the later caption reference to figure 74 (`part2b.tex:221`): **0 source/PDF reference-count mismatches** remain. Poppler bounding boxes independently locate all **110 numbered captions**; in **all 32 failing cases even the caption is above/before the reference**, so the result is not an artifact of an early hyperlink destination.

The complete 110-entry inventory is saved as `figure-placement.json` and `figure-placement.tsv` in scratch. Results: **77 after their first reference; 32 before; 1 standalone, unreferenced symbol table**. Of the 32 failures, **4 are on an earlier page and 28 are above the reference on the same page**. Even a page-only interpretation fails the four previews. The symbol table (`analytic-underpinnings.tex:90–95`, figure 2, p2) is not counted as an inversion, but has no first-reference claim to verify.

| Named figure | Reopened source first reference / environment | Stable rendered order | Ruling |
|---|---|---|---|
| 70 | `part2a.tex:1458–1459` / `:1460–1465` | p59 reference above diagram | PASS |
| 90 | `part2b.tex:672–673` / `:674–679` | reference p76 → figure p77 | PASS |
| 94 | `part2b.tex:834–835` / `:836–841` | p80 reference above diagram | PASS |
| 104 | `part2b.tex:1209–1210` / `:1211–1216` | reference p87 → figure p88 | PASS |
| 108 | `part2b.tex:1354–1355` / `:1389–1394` | reference p91 → figure p92 | PASS |
| 109 | `part2b.tex:1456–1457` / `:1458–1463` | p93 reference above diagram; caption remains on p93 | PASS |

**F2 residual — MINOR, universal placement not discharged.** The first four entries below are the inherited previews explicitly left unchanged by brief 96. The remaining entries are the full set of current same-page inversions; source-ordering a paragraph before a `[t]` float does not prevent that float from appearing above it. This finding does not claim that brief 96 introduced all these inversions. All locations listed below were reopened; `main` denotes `docs/analytic/analytic-underpinnings.tex`, and `a1/b1/a2/b2` denote `docs/analytic/parts/part1a.tex`, `part1b.tex`, `part2a.tex`, `part2b.tex` respectively.

| Figure | Figure page → first-reference page | First-reference source | Environment start |
|---:|---|---|---|
| 1 | 1 → 4 | a1:13–14 | main:83–88 |
| 3 | 3 → 4 | a1:14–15 | main:101–106 |
| 4 | 4 → 5 | a1:61–62 | a1:20–25 |
| 5 | 5 → 6 | a1:91 | a1:30–35 |
| 6 | 6 → 6, above | a1:104–105 | a1:107–108 |
| 7 | 7 → 7, above | a1:159–160 | a1:162–163 |
| 29 | 23 → 23, above | b1:353–354 | b1:356–357 |
| 32 | 25 → 25, above | b1:457–458 | b1:460–461 |
| 33 | 26 → 26, above | b1:491–492 | b1:493–494 |
| 36 | 28 → 28, above | b1:586–587 | b1:589–590 |
| 38 | 30 → 30, above | b1:680–681 | b1:682–683 |
| 39 | 31 → 31, above | a2:45–46 | a2:47–48 |
| 40 | 32 → 32, above | a2:90–91 | a2:92–93 |
| 41 | 33 → 33, above | a2:127–128 | a2:129–130 |
| 44 | 35 → 35, above | a2:217–218 | a2:219–220 |
| 48 | 38 → 38, above | a2:390–391 | a2:392–393 |
| 49 | 39 → 39, above | a2:449–450 | a2:451–452 |
| 50 | 40 → 40, above | a2:483–484 | a2:485–486 |
| 53 | 43 → 43, above | a2:590–591 | a2:592–593 |
| 55 | 45 → 45, above | a2:700–701 | a2:702–703 |
| 56 | 46 → 46, above | a2:748–749 | a2:750–751 |
| 60 | 49 → 49, above | a2:936–937 | a2:938–939 |
| 61 | 50 → 50, above | a2:991–992 | a2:993–994 |
| 66 | 55 → 55, above | a2:1260–1261 | a2:1262–1263 |
| 67 | 56 → 56, above | a2:1299–1300 | a2:1301–1302 |
| 68 | 57 → 57, above | a2:1370–1371 | a2:1372–1373 |
| 69 | 58 → 58, above | a2:1422–1423 | a2:1424–1425 |
| 75 | 64 → 64, above | b2:106 | b2:86–91 |
| 77 | 66 → 66, above | b2:183–184 | b2:185–186 |
| 81 | 69 → 69, above | b2:341–342 | b2:343–344 |
| 83 | 70 → 70, above | b2:379–380 | b2:381–382 |
| 84 | 71 → 71, above | b2:400–401 | b2:404–405 |

Concrete rendered counterexamples: figure 6's caption starts at y=228.77pt on p6, while “Figure 6 contrasts the finite witness…” (`part1a.tex:104–105`) starts at y=385.62pt. Figure 75's caption starts at y=192.19pt on p64, while “Figure 75 follows one clause index…” (`part2b.tex:106`) starts at y=678.08pt. Coordinates are measured down from the page top. Both were also visually inspected.

Visual inspection covered **15 pages: 1, 3, 4, 5, 6, 25, 59, 64, 77, 80, 88, 91, 92, 93, 94**. The six named figures are legible with intact captions, and the enlarged p93 retains figure 109 and its caption without clipping or overlap. No clipping or overlap defect was observed on these pages; the failure is reading order.

## 4. Final sweep of §§14–15; limits and command ledger

All prose, captions and table cells in `docs/analytic/parts/part2b.tex:951–1509` were opened. **No further status/execution overclaim found in this light sweep.** In addition to §2:

- The table preamble distinguishes certificate grades, ratchet status and the thirteen SKETCH derivations (`:954–980`). The repaired extra-lemma paragraph now agrees with C2/C4a/C12.
- The TB3 example distinguishes the trivial PCP continuation from the refused equality fixture (`:1416–1418`), consistent with `claims/CLAIMS.md:20`; the TB2/TB7 answer-reduction split matches C9's fixture-only scope (`claims/CLAIMS.md:18`).
- The midpoint statements retain the orbit-prefix condition, adaptive **sequential** AND, and the exclusion of quantum repetition/actual Compress (`:1465–1480`), matching C6/N1 at `claims/CLAIMS.md:15,17`.
- `fig-ladder.tex:19–49`, `fig-D-correspondence-compression.tex:8–41`, `fig-tb7-card.tex:37–56`, `fig-evidence-boundary.tex:24–44`, `fig-final-accounting.tex:13–25` and `fig-D-final-seal.tex:4–11` retain the finite-fixture/cited-theorem boundary. The closing text (`part2b.tex:1490–1507`) describes the remaining **proof** task; the preceding section separately preserves the implementation/evidence repairs. It does not say only mathematics remains.

**Not checked:** 0 Julia processes; no suite, mutation registry, benchmark, callback execution, numerical fuel/performance reproduction, or production-policy construction. No independent acceptance of brief 93, no live source/test inspection, and no promotion of the newly present binding code. I did not reprove the SKETCH derivations or the ground-truth theorems, re-audit all historical citation sites, inspect the HTML tutorial, compare the rebuilt PDF byte-for-byte with the committed PDF, or visually inspect the other 79 pages. The 110-figure check is an exhaustive source/link/caption-coordinate inventory, with visual QA limited to the 15 pages above. Timing values appearing in historical authorities were not treated as fresh evidence.

**Writes and command ledger.** Repository output: **only `verdicts/analytic-doc-r6.md`**. All build and review artifacts remain in scratch. A relative-path error initially placed four generated `pass1.{log,aux,toc,out}` files in scratch's parent; command 14 moved those exact four files into the authorized scratch directory, leaving **0 misplaced generated files**. No live document, CLAIMS, source, test, other verdict or brief was edited. There were **0 bd commands, 0 state-changing git commands, 0 commits/pushes**; the orchestrator owns commits.

Below, `S` abbreviates the full scratch directory printed above, `T=S/tree`, and `A=T/docs/analytic`. These are display abbreviations for the actual absolute paths. Numbered rows enumerate every shell-tool launch; Python heredocs are identified by the work they performed, as in brief 96's ledger. Child process commands are counted separately below. **26 launches exited 0; 1 exited 1** because the final validator incorrectly counted the repair-plan heading as a plan line; the corrected validator passed. Truncated read output is explicitly noted and critical ranges were reopened.

| # | Command / operation | Exit |
|---:|---|---:|
| 1 | `mkdir -p S/tree`; `git archive bc48af2 \| tar -x -C S/tree` | 0 |
| 2 | `cat verdicts/analytic-doc-r5.md briefs/96-analytic-repair-r3.last.md` | 0 |
| 3 | `git diff 632a17f bc48af2 -- docs/analytic/parts` | 0 |
| 4 | `cat /home/tobias/.codex/plugins/cache/openai-primary-runtime/pdf/26.909.12148/skills/pdf/SKILL.md` | 0 |
| 5 | `rg --files` with AGENTS, TeX, figcoverage, TB7/TB6, CLAIMS, r5 and brief-96 filename globs, in T | 0 |
| 6 | `python3 -`: archived/live report equality; numbered AGENTS/code/verdict/CLAIMS/gt-04/source/tool reads; output truncated | 0 |
| 7 | `pdflatex -interaction=nonstopmode -halt-on-error analytic-underpinnings.tex > S/pass1.stdout`, in A | 0 |
| 8 | `python3 -`: certificate 108–130, TB7/TB6 and C2/C4a/C12 reads; combined output truncated | 0 |
| 9 | `python3 -`: part2b 951–1218 | 0 |
| 10 | `python3 -`: reopen complete C2/C4a/C12 rows and TB6 31–38,59–66 | 0 |
| 11 | `python3 -`: part2b 1218–1509 | 0 |
| 12 | `python3 -`: preserve pass-1 log/aux/toc/out and inspect dependency availability; then `pdflatex -interaction=nonstopmode -halt-on-error analytic-underpinnings.tex > S/pass2.stdout`, in A | 0 |
| 13 | `python3 -`: C14/C15, figstyle and initial/moved source ranges | 0 |
| 14 | `python3 -`: relocate the four generated pass-1 files into S | 0 |
| 15 | `python3 -`: build source figure inventory | 0 |
| 16 | `python3 -`: reopen six status/boundary figure sources | 0 |
| 17 | `python3 -`: preserve pass 2; run required third pdflatex pass; save pass 3; compare aux/toc/out | 0 |
| 18 | `python3 -`: C5/C6/N1/C9/C10/C11/C13/C16 rows | 0 |
| 19 | `python3 tools/figcoverage.py`, in A | 0 |
| 20 | `python3 -`: distinguish real rerun warnings; inspect PDF destinations/references and aux figure entries | 0 |
| 21 | `python3 S/audit_figures.py`: first 110-figure PDF inventory | 0 |
| 22 | `python3 -`: reopen every failing figure's reference/environment lines and inspect two source/link-count mismatches | 0 |
| 23 | `pdftotext -bbox-layout analytic-underpinnings.pdf S/final-bbox.html`, in A | 0 |
| 24 | `python3 -`: reconcile auxiliary references; corroborate all 32 inversions with captions; render 15 pages | 0 |
| 25 | `python3 S/audit_figures.py`: completed source/PDF/caption inventory; 0 reference-count mismatches | 0 |
| 26 | `python3 -`: final validator; failed its own repair-section line-count assertion after passing section/final-line checks | 1 |
| 27 | `python3 -`: corrected final validator; structure, two repair lines, required final line, build metrics, inventory and ledger | 0 |

Child commands from Python: **1** `pdflatex -interaction=nonstopmode -halt-on-error analytic-underpinnings.tex` (pass 3), **exit 0**; **15** `pdftoppm -f P -l P -r 100 -singlefile -png A/analytic-underpinnings.pdf S/page-P`, for P = 1,3,4,5,6,25,59,64,77,80,88,91,92,93,94, **15 exits 0**. Total pdflatex processes: **3**, all exit 0. The archive pipeline's recorded result is its overall exit 0; separate pipeline-member exit statuses were not captured.

Tool operations outside that shell ledger: **5 successful `apply_patch` operations** (3 incremental verdict writes, 2 scratch audit-script writes); **5 `write_stdin` polls**, all successful, with **4 completion results at exit 0** and 1 still-running result; **15 successful `view_image` inspections**. The initially crude `Rerun` substring counts were corrected by opening the actual warning lines, and the first inventory's 2 reference-count mismatches were resolved before the final counts above.

## 5. Repair plan (≤ 3 lines, or "none")

1. Fix the 32 first-reference inversions listed in §3; keep the six named fixes and explicitly introduce the standalone symbol table if all 110 need a first reference.
2. Rebuild to stable references/TOC and recheck all 110 rendered placements plus figure coverage; retain TB7/TB6 FAIL/HOLD until an authorized replacement verdict exists.

VERDICT: FAIL(F2)
