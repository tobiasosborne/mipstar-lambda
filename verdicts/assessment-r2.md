# Assessment r2 — brief 104

Review target: `docs/assessment.md` at `43c41ca`, compared with `43c41ca~1`. This is an assessment-text review, not acceptance of brief 93, a runtime rerun, or authorization to replace CLAIMS. Only this verdict is written. The current session rules supersede AGENTS.md's bd/git completion workflow.

## Discharge of assessment-r1

The prior demands and missing-content list were reopened at `verdicts/assessment-r1.md:7–14,138–151`. Source authority below means the actual `ground-truth/gt-*.tex` text; CLAIMS and verdicts establish the recorded implementation scope, not mathematical ground truth.

| Prior | Disposition | New text / assessment line | Authority reopened and decision |
|---|---|---|---|
| A1 | DISCHARGED | L44: “`d ≥ 8` suffices under this bound; it is not necessary.” | `claims/CLAIMS.md:10,14,19`; `ground-truth/gt-10-answer-reduction.tex:1685–1692,1409–1416,1733–1755`. The product adds at most one coordinate degree for multilinear disjoint-block factors; the conservative uniform choice is sufficient. C3 supplies an actual degree-6 example at d=6. The general repair stays SKETCH and the stronger parameter obligation remains explicit. |
| A2 | DISCHARGED | L50: “dimensions are `206→624→840→848→1696`, for Intro → typed AR → detyped AR → anchored → toy two-copy repeat.” | `verdicts/tb7-r1.md:59–67,79`; `ground-truth/gt-10-answer-reduction.tex:1890–1910,1948–1965`; `ground-truth/gt-06-types.tex:371–404`; `ground-truth/gt-11-parallel-repetition.tex:123–129,200–215`. The added 418-bit typed increment and 216-bit detyping increment are distinct and correctly labeled. |
| A3 | DISCHARGED | L52: “one verifier-size predicate, `\|V\|>λ`”; L54: “the source's `≥3Q` rejects honest Hide answers”; L70: “Close T7-5 by verifying … both construction paths”. | `verdicts/tb7-r1.md:27–31,71`; `verdicts/tb6-r4.md:25,31`; `claims/CLAIMS.md:24–25`; `ground-truth/gt-08-introspection.tex:417–425,757–776`; `ground-truth/gt-12-compression.tex:128–135`. Separate fallback choices are identified as the recorded defect; answer-cap and fixed-width changes are disclosed; reported repair and eventual acceptance are separated. |

| Missing-content demand | Disposition | New text / assessment line | Authority reopened |
|---|---|---|---|
| Source repairs plus inventory link | DISCHARGED | L54: “`intro-decider-fixed-width` … changes the construction”; “remaining design repair inventory.” | A3 authorities above; `HANDOFF.md:11–12,124`. This names the construction changes without claiming their eventual adjudication. |
| Structural feasibility ladder | DISCHARGED | L74: “one general local-window compiler”; “fixed ladder of accepting/rejecting programs”; “monomial, storage and operation counts against a declared refusal budget”. | `claims/CLAIMS.md:20,29`; `HANDOFF.md:74–76`; `ground-truth/gt-10-answer-reduction.tex:237–273,1226–1248,1558–1581`. Same compiler across descriptions, structural measurements, no wall-time evidence or inferred lower bound. |
| At most two later experiments | DISCHARGED | L76: “two later experiments of presently unestimated scope” — space/depth and a lower exhibited CL level. | `HANDOFF.md:82–86`; `claims/CLAIMS.md:16,22`; `ground-truth/gt-04-cl.tex:122–130,151–180,282–327,572–601`. Explicitly after the symbolic API/core path, with neither closure nor C7 promotion claimed. |
| Physical interpretation and downstream obligation | DISCHARGED | L60: “two qubits per party cannot hold its nine-bit sampler space”; L72: “raising the formula-occurrence bound can invalidate `(deg_F+5d)m'/q<1/2`”. | `ground-truth/gt-08-introspection.tex:197–202,525–534`; `verdicts/tb7-r1.md:33–37`; `claims/CLAIMS.md:14`; `ground-truth/gt-10-answer-reduction.tex:1409–1416,1733–1755`. The embedding failure is correctly classified; increasing the bound can require parameter reselection. |

The other prose requests at r1:140–144 are also discharged: L62 states the binder-sort gap directly, and L76 separates small maintenance from unestimated later experiments.

## Findings and regression

**No new MAJOR or MINOR finding in the repair; FIX DEMAND: none.** All three numbered demands and all four missing-content bullets are discharged. This verdict concerns the assessment, not the implementation defects it reports.

The exact commit diff adds 11 lines and removes 9. Comparing sentence text with the parent yields **32 added/rewritten sentence units**, including two bold sentence headings and the sentence whose citation moved (S17). Each is covered below. Quoted fragments identify the full sentences at the indicated assessment line; “supported” means supported at the assessment's stated scope. Recommendations are checked as proposed work, not established results.

For compact source references in this table, **GT04/06/08/10/11/12** mean respectively `ground-truth/gt-04-cl.tex`, `ground-truth/gt-06-types.tex`, `ground-truth/gt-08-introspection.tex`, `ground-truth/gt-10-answer-reduction.tex`, `ground-truth/gt-11-parallel-repetition.tex`, and `ground-truth/gt-12-compression.tex`.

| Sentence / line | Quote | Reopened authority and ruling |
|---|---|---|
| S01 / 44 | “conservative uniform bound `deg_F ≤ 7`” | CLAIMS:14,19; GT10:148–190,1685–1692. Supported as C5's proposed repair, not a new theorem. |
| S02 / 44 | “`d ≥ 8` suffices … not necessary” | CLAIMS:10,14; GT10:1685–1692. Supported; A1 discharged. |
| S03 / 44 | “C3 retains degree-6 proofs at `d=6`” | CLAIMS:10 explicitly has max degree 6 with equality on TB0-small. Supported. |
| S04 / 44 | “general repair remains SKETCH” | CLAIMS:14. Exact status; no promotion. |
| S05 / 44 | “older `≤6 / c0≤7 / d≥7` constants … omit the output-literal increment” | `docs/findings.md:5–10,14`; CLAIMS:14,19. Old count is 2+2f; adding the output literal gives the extra indicator. Supported as the conservative C5 bound. |
| S06 / 50 | “dimensions are `206→624→840→848→1696`” | TB7-r1:59–67,79; `verdicts/design-v2-r3.md:178–207`; CLAIMS:25. Full toy chain supported; the abbreviated CLAIMS chain is not contradicted. |
| S07 / 50 | “`38×11=418` … `54 types × 4=216`” | Same TB7/design ranges; `HANDOFF.md:32`; GT10:1890–1910,1948–1965; GT06:371–404; GT11:123–129,200–215. Arithmetic and stage labels supported. |
| S08 / 50 | “PCP ambient space and product supply the typed increment” | GT10:1890–1910,1948–1965,2085–2096; GT08:784–797; GT06:371–404; GT11:123–129,200–215,250–257. All eight cited ranges support the respective laws. |
| S09 / 52 | “T7-5 … separate sampler/decider fallback choices” | TB7-r1:27–31; GT08:757–763. Accurate historical defect and paired source rule; no assertion that the repaired paths now work. |
| S10 / 54 | “Source repairs qualify acceptance and description claims.” | CLAIMS:24–25; TB6-r4:25,31; TB7-r1:71. Accurate heading for the paragraph's qualifications. |
| S11 / 54 | “excluding 10/116 and 22/128 oriented pairs on E/M” | CLAIMS:24 supplies denominators and operative/literal distinction; TB6-r4:25 retains 10/22; GT08:410–413,417–425,525–534 supplies Hide vectors, cap and embedding. Supported; GT alone is not credited with the finite counts. |
| S12 / 54 | “explicit toy child fuel” | CLAIMS:24; TB6-r4:31; GT08:417–419. Correctly distinguishes toy acceptance from the source timeout. |
| S13 / 54 | “equal description lengths on the tested inputs … inference … remains CITED” | CLAIMS:25; TB7-r1:27–31,71; GT08:772–776; GT12:128–135. Fixed-width equality is finite evidence; source's bound-to-independence inference is not promoted. |
| S14 / 54 | “Brief 93 reports … [pending brief 97]” | `HANDOFF.md:11–12`; TB7-r1:27–31; TB6-r4:31. Accurate attribution, not repair acceptance. Pre-review scope below confirms the boundary. |
| S15 / 54 | “remaining design repair inventory” | `HANDOFF.md:124` contains that inventory. Supported as a pointer, not incorporation of other handoff claims. |
| S16 / 60 | “invalid toy embedding … sampler randomness” | GT08:197–202,525–534; TB7-r1:33–37. Register embedding requires s≤Q; Q=2<s=9 is an invalid toy substitution, not an intractability result. |
| S17 / 60 | “zero introspection predicates execute” | CLAIMS:25 HOLD; TB7-r1:33–37. Supported for the explicitly named primary TB7 input. No oversized-fallback generalization. |
| S18 / 62 | “remaining gap is a binder-sort derivation” | `verdicts/design-r4.md:124–172`; `docs/DESIGN.md:33–51,77–92`. Current grammar has arity only; current text explicitly fixes quoted-code application by inlining. Supported. |
| S19 / 70 | “Settle replay binding … authoritative mutation results.” | TB7-r1:3–23; TB6-r4:3–11,31. Appropriate pending work, not a discharged result. |
| S20 / 70 | “both fallback components in both construction paths” | TB7-r1:27–31; GT08:757–763. Precisely includes the missing closure criterion and adjudication alternative. |
| S21 / 70 | “only authorized CLAIMS replacements … [pending brief 97]” | CLAIMS:3–4,24–25; TB6-r4:31; TB7-r1:51–55. Correctly preserves HOLDs and caveats. |
| S22 / 72 | “raising the formula-occurrence bound can invalidate …” | CLAIMS:14; GT10:1409–1416,1733–1755. Supported conditional implication at fixed remaining parameters; no claim that every increase invalidates it. |
| S23 / 74 | “one general local-window compiler … exact input decider” | CLAIMS:20,29; GT10:237–273,1226–1248,1558–1581. Appropriate response to the fixture-only gap; not a claim of existing implementation. |
| S24 / 74 | “fixed ladder … through that same compiler” | CLAIMS:20,29; `HANDOFF.md:74–76`. A discriminating proposed experiment, not another fixture-specific compiler. |
| S25 / 74 | “structural measurements, not wall times” | Same scope plus current session rules. Appropriate proposed budget discipline; no timing result used. |
| S26 / 74 | “trace across differing descriptions … negative witnesses” | CLAIMS:20,29; GT10:237–273,1226–1248,1558–1581. Concrete success criterion, not evidence that it has been met. |
| S27 / 74 | “without inferring an inherent lower bound” | CLAIMS:20's expansion refusal; GT10:237–273,1226–1248,1558–1581. Correctly avoids extrapolating one representation's refusal. |
| S28 / 74 | “trace needed to compare an alternative PCP” | Same scope: prospective comparison capability, not a positive alternative-PCP result. Supported as a recommendation. |
| S29 / 76 | “small local maintenance tasks” | CLAIMS:8,16,22 and current DESIGN sort residue. Scope estimate applies to maintenance, with research explicitly separated. |
| S30 / 76 | “two later experiments of presently unestimated scope” | `HANDOFF.md:82–86`. Accurately extracts proposals and dependency order without importing its class or prover-efficiency assertions. |
| S31 / 76 | “factor partitions and legal prefixes as well as level laws” | GT04:122–130,151–180,282–327,572–601. Those are real obligations; exhibited levels are upper bounds, not minimum-level proofs. |
| S32 / 76 | “neither experiment establishes restricted-verifier closure or promotes C7” | CLAIMS:8,16,22; GT04 ranges above. Correct non-promotion and quantifier boundary. |

All **33 ground-truth range occurrences / 29 distinct ranges** printed on the added nonblank diff lines were reopened, including ranges carried by unchanged neighboring sentences. The full inventory is: GT04:122–130,151–180,282–327,572–601; GT06:371–404,409–427; GT08:197–202,417–425,525–534,757–763,772–776,784–797; GT10:237–273,1226–1248,1406–1408,1409–1416,1429–1442,1558–1581,1685–1692,1733–1755,1890–1910,1948–1965,2085–2096; GT11:123–129,200–215,250–257; GT12:26–53,75–98,128–135. Additional source context opened: GT08:401–415 and GT10:148–190.

## Pre-review boundary, prose and limits

`verdicts/tb7-r2-pre.md:1–62,80–101` was reopened. Its **P97-1…P97-7 remain defects of the repair checkpoint**, with no row authorization. It is a non-governing pre-review; its local probes do not replace the closing round. The assessment makes **0 mentions** of that file and **4 explicit pending-brief-97 marks**. Omission is allowed by this brief. L54 says “reports,” L70 demands verification, and neither turns the pre-review's partial/static discharges into acceptance. In particular, P97-5's effective-pair reporting inconsistency remains compatible with the primary-input zero-dispatch statement; the latter is not a statement about every fallback input.

Length is **2,247 whitespace-delimited words / 89 lines**, below approximately 2,700 by 453 words. There are **22 status rows / 0 status mismatches**, **0 replacement characters**, and no garbled or unfinished prose found. The prose is sober, distinguishes reports from results, retains SKETCH/CITED and both HOLDs, and gives useful stage arithmetic and physical interpretation. Its dense references remain appropriate to an author-facing assessment. The old editorial imperative is gone. No runtime, new theorem, or implementation acceptance is inferred from this writing review.

One inherited citation-location nit is outside the new-sentence regressions: the production-test pointer at L62/L72 says `test/tb7_compress.jl:60–65`; the actual broken assertion is now at :68 (opened :64–78). The cited :65 is its testset header, and the co-cited `src/compress/compress7.jl:447–450` still directly supports ToyPolicy-only construction. This does not change the claim or any discharge; it is not a required repair for this assessment round.

## Session record

Only `verdicts/assessment-r2.md` is written. No assessment, CLAIMS, implementation, test, handoff or other lane is edited. Julia processes, tests, mutation registry runs, benchmarks, rebuilds, bd commands, state-changing git commands, commits and pushes are all **0**. No wall-clock measurement is evidence. The orchestrator owns committing. Brief 97's implementation adjudication and any resulting assessment finalization remain **not done** here.

The exact command ledger and final validation record follow.
