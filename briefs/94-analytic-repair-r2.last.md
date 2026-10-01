# Brief 94 report: analytic repair r2 (Opus proposer, 2026-10-01; pdflatex only, no Julia, no git writes)

Spec: `verdicts/analytic-doc-r4.md` R1–R11 + §7. Authorities: CLAIMS rows C1/C9/C10/C11/C14/C15; `verdicts/tb7-r1.md` (T7-1…T7-9, run block); `verdicts/tb6-r4.md` head. Code facts are from grep of the LIVE tree, which brief 93 is editing concurrently. Edited only `docs/analytic/{parts/part2a.tex,parts/part2b.tex,figs/fig-D-correspondence-compression.tex,fig-tb7-card.tex,fig-ladder.tex,fig-D-threshold-margin.tex}` and the PDF.

## Per item
- **R1 DONE** part2b:268–277. Old: "run the generated instance through the PCP builder and the answer-reduced decider on two one-bit-answer fixtures". New: both fixtures go through trace/3SAT/5SAT/padding. Only the trivial fixture continues to `build_pcp` and TB2's AR decider. The equality fixture is refused by `arith_q` (ExpansionRefused 279 936 > 160 000) and never reaches `build_pcp`. Authority: CLAIMS:20; live `test/tb3_frontend.jl:686,699`. The §15.1 evidence table and closing prose repeat this (part2b:1408ff).
- **R2 DONE** part2b:1324–1335. Old: "only the Pauli-typed introspection predicates execute at TB7". New: no introspection predicate is dispatched at TB7, Pauli pairs included. The Q≥s(N) guard runs before dispatch. Cited: critic 0/86 (tb7-r1 T7-6) and live test 0/164 (`test/tb7_compress.jl:386–389`, labelled "live tree"). What does execute is the Pauli sampler construction and its finite queries; local Pauli predicate evidence belongs to TB6/C14. The TB7 card footer adds "no introspection predicate is dispatched at TB7" (fig-tb7-card:55), and the §15.1 evidence table adds "any introspection predicate dispatch at TB7" (part2b:1366). Authority: tb7-r1 T7-6 (stricter than the stale C15 sentence); live `src/introspect/intro_decider.jl:470`.
- **R3 DONE** fig-D-correspondence-compression:4–15,24. The single green "AnswerReduce built (TB2; TB7 on descriptions)" box under C9 TESTED is now two boxes. A green "AnswerReduce, TB2 host" box carries the chip "C9 TESTED (TB2 only)". An amber "TB7 overload: C15 conj." box sits beneath it. The caption (part2b:1245) states the split and that the actual-D1 game is not executed. Card row 6 (fig-tb7-card:42) now reads "on the disclosed local polynomial fixture (not the formula of D1)", and the card caption repeats it. Authority: CLAIMS:18,25; tb7-r1 T7-8, row-6 ruling. p89 inspected at 150 dpi: no overlap.
- **R4 DONE** part2a:517–536. The "stale evidence unrepresentable … turns the suite red" sentence is withdrawn. New text: the walk only guarantees that each CHECKED replay is run and that a missing replay fails; a replay is an arbitrary callback (`src/certificates.jl`, live). Validated binding is listed per fixture: C1 (identity check at ten of eleven nodes), C10 (front-end identity binding), C11 (specialize/fix_specialize). TB7 r1 T7-2/T7-3 findings are disclosed (133 CHECKED nodes, forged facts change no outcome; stale hash and two semantic survivors). The live `BoundReplay` repair (brief 93) has no converged verdict, so no universal claim is made. Also added at part2a:564–566: the five-outcome vocabulary is not a checker (T7-1).
- **R5 DONE** part2a:54–60. The false "paper says only polynomial overhead … our own quantification" is gone. The bound is now attributed to `thm:universal-tm`, gt-03 L116–L124 (verified: theorem L116–L124, bound C(k·|α|·|x|·T)^c, C,c≥1), with "constants renamed (the paper's C,c)".
- **R6 DONE** part2a:1486–1492. The decider-only Compressor is called a named narrowing: the paper's Compress returns the pair (gt-12 L28–L39 verified; fig:halt_f steps 4–5 at L445–L449 verified). It is licensed because ComputeSampler(λ) supplies the common sampler (same-sampler sentence in the proof of lem:dhalt-values at gt-12 L530–L534; lem:compress-independent-samplers at L108–L118, both verified; `docs/definitions.md` §F).
- **R7 DONE**. "pending critic r1" no longer appears anywhere (grep returns 0 hits). Changed sites:
  - §14.6 preamble (part2b:1226–1234): r1 FAIL, C15 HOLD, brief 93 repair in progress; C14 keeps its earlier TESTED row and its tb6-r4 replacement row is on HOLD (T6-1/T6-2).
  - §14.7 intro (part2b:1303–1307) and card caption.
  - ladder footer: "critic r1: FAIL, HOLD; repair in progress".
  - card footer.
  - §15.1 (part2b:1406–1442): the three concrete examples requested in verdict §6, the eight open T7 findings in one line each, and dated run history. The 2026-09-27 HANDOFF figures (12730/1, 235 killed, 93/93) are kept as history. The latest governing run is tb7-r1, 2026-10-01, archive 2fa15e4: suite exit 0 at 12729/1 broken; registry exit 1 at 233/235, with 2 gate survivors (T7-7). Neither run covers brief 93.
- **R8 DONE** part2b:857–864. Old: the questions come from a seed split, so the product is not evidenced as their source. New: the questions are projections of the 54-type product sampler's own `sample` output (`sample_answer_reduce_questions`, live `src/verifiers/answer_reduce.jl:143–150`). The hand split is only a test reference, asserted equal on 20 seeds × 54 types × both sides (live `test/tb2_answer_reduce.jl:160–180`; CLAIMS:18; tb2-r2 N1).
- **R9 DONE**. The table row is split in two (part2b:1163–1168):
  - TB2 host marker `CitedDetypedVerifier` / one-argument `detype` / CITED / loss: no current row.
  - DL9 descriptions `SamplerDescription`/`DeciderDescription`/`VerifierDescription` / `detype_sampler`, `detype_decider`, two-argument `detype` / CHECKED DL9 levels / C12 TESTED.

  The prose (part2b:888–895) qualifies the marker as the TB2 overload and names the executable DL9 overload. Authority: live `src/verifiers/answer_reduce.jl:103–117`, `src/descriptions/transformations.jl:288`, `src/repeat/anchor.jl:45,77`.
- **R10 DONE** part2b:962–975. "Every theorem and lemma of Part II" is narrowed to the thirteen enumerated results of §§8–11. Lemma 12.1 (zero-rewrite: the division step of the prop:zero-basis proof, gt-10 L1296–L1359) and Lemma 13.2 (level laws, gt-04 L282–L363, verified: concat L282–L314, direct sum L315–L363) are named as having no row; their executed instances fall under C2 and under C4a/C12. Both are also excepted at part2a:314–319 (prose plus the fig:three-provenances caption). No chips were added.
- **R11 DONE** fig-D-threshold-margin:7. The amber line now runs from y=0.45 down to y=−0.16, stopping above the "1/2" tick label. p75 inspected at 130 dpi: the line is clear of the label.

## Layout repairs (no content change; critic should glance)
The added text pushed 5 pages to text-only (figcoverage exit 1). Fixes:
- fig:C-closed-verifier env moved directly after eq. (10.5).
- fig:cl-inductive moved beside Lemma 13.2 (intro now says "unfolds Definition 13.1").
- §13.3 reordered: the typed-decider paragraph and fig:D-decider-guards now come before oracularization, and the detyping paragraph now follows the thm:ar contract.
- fig:midpoint-diagnostic moved to the end of §14.5 (TB0.5 midpoint), with its intro now "…counts that the N1 formula gives".
- The fig:final-accounting [t] float env moved after the §15.1 table, so it now appears on p92, two pages before its reference.

## Build (in place, pdflatex ×2, exit 0/0)
| | pages | overfull | underfull | undefined refs | figcoverage |
|---|---|---|---|---|---|
| Before | 92 | 0 | 12 | 0 | exit 0 |
| After | 94 | 0 | 12 | 0 | 110 figs, bare pages [], exit 0 |

After the rebuild there was no "Label(s) may have changed" warning. Figure order is monotone over all 110 figures (0 backward pairs). Pages inspected as PNG: 59, 75, 83, 88, 89, 90, 92–94.

## Disputes / notes
- None with the verdict.
- The "0 of 164" count and BoundReplay are cited as live-tree facts with no converged verdict; the document says so.
- CLAIMS C15 still carries the stale Pauli-execution clause, and C14 still says "37 mutants / 22633 accepting". The document follows tb7-r1/tb6-r4 here, as the brief requires; CLAIMS itself is not in this lane.
- The §14.7 heading still says "two non-executed layers" (C15's two named layers). The prose adds that the Pauli predicates are not dispatched either.
