# Assessment draft r1 — critic review (brief 99)

Reviewed docs/assessment.md (2026-10-02, 87 lines) against the governing claims, both held verdicts, the handoffs, and every directly cited ground-truth range. The draft has 22 claim rows and 0 status-column mismatches. Its HOLDs and most prose limitations are accurate. One necessity claim exceeds C5; two omissions should also be corrected. No Julia, tests, benchmarks, beads, git, or external literature search ran. Historical execution results below belong to the cited critics, not this review.

## Numbered findings

1. **A1 · MAJOR · docs/assessment.md:44 · “requires d ≥ 8”.** Authority: claims/CLAIMS.md:14 says d ≥ deg_F+1 “suffices,” deriving 8 from the conservative bound deg_F ≤ 7. The source ground-truth/gt-10-answer-reduction.tex:1685–1692 supplies the multiplication by multilinear factors, not a necessity theorem. The draft turns a sufficient uniform choice into a necessary condition. A smaller actual degree can admit smaller d: claims/CLAIMS.md:10 retains degree-6 proofs at d=6. The SKETCH label does not license the stronger logical claim.
   **FIX DEMAND:** Write “d ≥ deg_F+1 is sufficient, hence d ≥ 8 suffices under this uniform bound”; retain SKETCH and the extra parameter obligation.

2. **A2 · MINOR · docs/assessment.md:50 · “dimensions 206→840→848→1696”.** Authority: verdicts/tb7-r1.md:59–66,79 and HANDOFF.md:32 distinguish typed answer reduction, 206+38·11=624, from detyping, 624+4·54=840. The displayed subsequence is correct but hides the typed interface and its +216 detyping overhead. Contrary to the work order's premise about CLAIMS, the current claims/CLAIMS.md:25 itself has the abbreviated chain; verdicts/design-v2-r3.md:178–207 also has it. This is an incomplete explanatory trace, not a status mismatch.
   **FIX DEMAND:** Label the full chain 206 (Intro) → 624 (typed AR) → 840 (detyped AR) → 848 (anchored) → 1696 (toy two-copy repeat).

3. **A3 · MINOR · docs/assessment.md:52,58,68 · “Settle replay binding, computed policy statuses, actual-code execution, reached-chain coverage and authoritative mutation results”.** Authority: verdicts/tb7-r1.md:27–31 and HANDOFF.md:11–12 also identify T7-5: the archived implementation chose the sampler and decider fallbacks separately, whereas ground-truth/gt-08-introspection.tex:757–763 replaces the pair under one verifier-size predicate. Neither the failure summary nor the concrete repair list mentions this construction error. Likewise, the explanation of TB6 acceptance mentions toy fuel but omits the operative answer-cap repair: source ≥3Q versus implemented >3Q (claims/CLAIMS.md:24; verdicts/tb6-r4.md:25,31; ground-truth/gt-08-introspection.tex:417–425). These matter to an author preserving the construction, beyond improving test provenance.
   **FIX DEMAND:** Add a short source-fidelity paragraph naming the paired-fallback objection and the TB6 answer-cap/fixed-width repairs, distinguishing recorded defects, proposed repairs, and pending adjudication; include T7-5 in step 1's closure criterion.

## Status and claim-citation audit

SUPPORTS means that the reference supports the scoped sentence or the specified part of it. It never means a fresh execution succeeded. PARTIAL identifies a limitation or stale authority. DOES NOT identifies a specific unsupported inference. Repeated CLAIMS references in the prose inherit these same scope checks; A1 is the one stronger mathematical inference found. The terse table summaries are not noticeably weaker claims given the explicit quantifier disclaimer at draft line 9.

| Draft line / row | Governing authority opened | Citation decision |
|---|---|---|
| 13 / C1 TESTED | claims/CLAIMS.md:8; test/tb0_core.jl:464–471; verdicts/tb0-r4.md:342–351,392–409 | SUPPORTS: named-point/line completeness; no uniform large-field PCP sampling. |
| 14 / C2 TESTED | claims/CLAIMS.md:9; test/tb0_core.jl:450–456 | SUPPORTS: coefficient identities and the retained negative witness; general correspondence remains cited. |
| 15 / C3 TESTED | claims/CLAIMS.md:10; test/tb0_core.jl:450–456,571–576 | SUPPORTS: degree report; only the nondegenerate fixture supports the block-dependency statement. |
| 16 / C4a TESTED | claims/CLAIMS.md:11; test/tb1_ld_sampler.jl:70–93,221–275,312–339 | SUPPORTS: constructed levels, four-query replay, description codec at the stated fixture. |
| 17 / C4b TESTED | claims/CLAIMS.md:12; verdicts/tb2-r8.md §6, 328–352 | SUPPORTS: declared-chain evidence and scoped family/product claim; no universal-chain claim. |
| 18 / C4c TESTED | claims/CLAIMS.md:13; test/tb1_ld_sampler.jl:663–692 | SUPPORTS: one polynomial fixture and no soundness promotion. |
| 19 / C5 SKETCH | claims/CLAIMS.md:14; docs/findings.md F1, 3–11 | PARTIAL: CLAIMS supports the summary; F1 is an older sketch with stale constants and status. The draft correctly gives C5 precedence, but line 44 has A1. |
| 20 / C6 PROVED | claims/CLAIMS.md:15; toys/midpoint/PROOF.md:5–66,119–130 | SUPPORTS: orbit-prefix hypothesis retained. |
| 21 / N1 PROVED | claims/CLAIMS.md:17; toys/midpoint/PROOF.md:132–154 | SUPPORTS: sequential adaptive repetition only. |
| 22 / C7 CONJECTURE | claims/CLAIMS.md:16 | SUPPORTS: structural hypothesis, not a result of finite closure tests. |
| 23 / C8 TESTED | claims/CLAIMS.md:19; docs/findings.md F1/F2, 3–14 | PARTIAL: governing row supports two-circuit evidence; findings line 11 still says CONJECTURE and is not the status authority. Soft “implemented reading” is appropriate. |
| 24 / C9 TESTED | claims/CLAIMS.md:18; verdicts/tb2-r8.md §6, 328–374 | SUPPORTS: typed TB0-fixture decider; detyping and quantum conclusions not promoted. |
| 25 / C10 TESTED | claims/CLAIMS.md:20; test/tb3_frontend.jl:86–101,373–388,660–702 | SUPPORTS: quoted fixtures, fixture-only Cook–Levin, equality circuit's expansion refusal. |
| 26 / C11 TESTED | claims/CLAIMS.md:21; verdicts/tb4-r3.md:8–10 | SUPPORTS: contracts/quoted fixed point with explicit stubs. |
| 27 / C12 TESTED | claims/CLAIMS.md:22; test/tb5_repeat.jl:290–316 | SUPPORTS: description constructors and selected-chain evidence; semantic implications remain cited. |
| 28 / C13 TESTED | claims/CLAIMS.md:23; test/tb5_repeat.jl:454–473,532–546,666–686,832–847 | SUPPORTS: toy anchoring/repetition with explicit resource limitations. |
| 29 / C14 TESTED + HOLD | claims/CLAIMS.md:24; verdicts/tb6-r4.md:1–31 | SUPPORTS: no unauthorized replacement; 43 is the critic's required owned count, not this session's mutation result; corrected nested numbers and test-only D1(d) are retained. |
| 30 / C15 CONJECTURE + HOLD | claims/CLAIMS.md:25; verdicts/tb7-r1.md:1–55 | SUPPORTS: refuted Pauli-execution clause explicitly held; no promotion from bookkeeping. |
| 31 / C16 SKETCH | claims/CLAIMS.md:26; analytic part2a §8, 329–353,711–748,802–841 | SUPPORTS: written semantics/fuel derivations, not adversarially verified. |
| 32 / C17 SKETCH | claims/CLAIMS.md:27; analytic part2a §9, 947–969,1032–1061,1170–1183 | SUPPORTS: written costed bridge. |
| 33 / C18 SKETCH | claims/CLAIMS.md:28; analytic part2a §10, 1244–1260,1282–1297,1381–1406,1512–1530 | SUPPORTS: written self-reference/size accounting; fixed-point value argument remains cited. |
| 34 / C19 SKETCH | claims/CLAIMS.md:29; analytic part2b §11, 42–55,107–134,267–279 | SUPPORTS: general written Cook–Levin construction; fixture implementation is narrower. |

Prose status words were checked separately. Draft lines 36,40,42,44,48,50,52,56,58,60,62,68–74,78–87 do not silently promote a rung or erase a HOLD. In particular, “CITED” describes source soundness conclusions, whereas C5's repaired derivation remains SKETCH; finite arithmetic confirmation does not make C15 TESTED; “had four agreements” is historical; and brief 97 remains explicitly pending. The draft's separation of historical R10 from the remaining R9 residue is correct. No live issue-status audit is implied by its issue names.

## Ground-truth citation table

All 46 explicit ground-truth range occurrences were opened: 39 literal path/range spellings, or 38 distinct physical ranges after normalizing the optional ground-truth/ prefix. Every path below is under ground-truth/. Repeated uses are listed together. Source citations establish source statements; CLAIMS/verdict citations establish implementation status.

| ID | Draft line(s) | Exact cited range opened | Decision / support |
|---|---|---|---|
| G01 | 5,40,70 | gt-12-compression.tex:75–98 | SUPPORTS: ordered Introspect → AnswerReduce → Repeat construction. |
| G02 | 36,56 | gt-07-ldt.tex:413–440 | SUPPORTS: low-degree extraction quantified over successful projective strategies and measurements. |
| G03 | 36,56 | gt-07-ldt.tex:1431–1445 | SUPPORTS: Pauli rigidity quantified over strategies, with local isometries and extracted EPR state. |
| G04 | 36 | gt-08-introspection.tex:784–817 | SUPPORTS: introspection construction, hypotheses, completeness, soundness and entanglement conclusion. |
| G05 | 36 | gt-10-answer-reduction.tex:1509–1540 | SUPPORTS: PCP soundness only against low-degree proofs, explicitly distinguished from later quantum soundness. |
| G06 | 36 | gt-10-answer-reduction.tex:2077–2116 | SUPPORTS: conditional answer-reduction theorem and soundness/entanglement implications. |
| G07 | 36 | gt-11-parallel-repetition.tex:112–136 | SUPPORTS: anchoring theorem, entanglement implication and construction laws. |
| G08 | 36,56 | gt-11-parallel-repetition.tex:229–258 | SUPPORTS: anchored parallel repetition's quantitative entanglement implication; not the midpoint toy. |
| G09 | 36,70 | gt-12-compression.tex:26–53 | SUPPORTS: transformation on descriptions and separate conditional soundness conclusion. |
| G10 | 40 | gt-12-compression.tex:426–449 | SUPPORTS: descriptions are computed and passed to Compress and the resulting decider. |
| G11 | 42 | gt-10-answer-reduction.tex:173–190 | SUPPORTS: literal degree-2 assertion and its occurrence-count justification. |
| G12 | 44 | gt-10-answer-reduction.tex:1409–1416 | SUPPORTS: source selects k using (2+5k)m'/2^k, then d=k; it does not automatically check the repaired expression. |
| G13 | 44 | gt-10-answer-reduction.tex:1685–1692 | PARTIAL: product with multilinear factors justifies adding at most 1 per coordinate; DOES NOT establish that d≥8 is necessary (A1). |
| G14 | 44 | gt-10-answer-reduction.tex:1733–1755 | SUPPORTS: source formula-test Schwartz–Zippel constant is (2+5d)m'/q. Replacement by deg_F is the identified SKETCH inference. |
| G15 | 46 | gt-10-answer-reduction.tex:148–158 | SUPPORTS: acceptance iff existence of a satisfying auxiliary assignment. It does not itself print NW19's gadget; the draft properly attributes the omission report to F2. |
| G16 | 48,74 | gt-04-cl.tex:151–180 | SUPPORTS: factor partition, marginal sum, and CL characterization used by the proposed interface tests. |
| G17 | 48,74 | gt-04-cl.tex:572–601 | SUPPORTS: four sampler queries and distinct Factor/Linear prefix domains. General software validity still needs C4/C12's qualifications. |
| G18 | 48 | gt-04-cl.tex:122–130 | SUPPORTS: level promotion, so an exhibited level is not necessarily minimal. |
| G19 | 48 | gt-04-cl.tex:282–327 | SUPPORTS: concatenation level k+ell and direct-sum level max ell_j are membership constructions. |
| G20 | 50 | gt-08-introspection.tex:784–797 | SUPPORTS: Intro outputs level 5. Numeric dimension 206 comes from the separately cited design calculation, not these lines. |
| G21 | 50 | gt-10-answer-reduction.tex:2085–2096 | SUPPORTS: AR outputs max(ell+2,5), hence 7 after Intro. |
| G22 | 50 | gt-06-types.tex:371–404 | SUPPORTS: detyping adds 2 levels and 4 times the number of types in dimension. |
| G23 | 50 | gt-11-parallel-repetition.tex:123–129 | SUPPORTS: anchoring adds 2 levels and 8 dimensions. |
| G24 | 50 | gt-11-parallel-repetition.tex:200–215 | SUPPORTS: repetition multiplies the anchored dimension by k; k=2 is a toy override, not the source value. |
| G25 | 50 | gt-11-parallel-repetition.tex:250–257 | SUPPORTS: combined Repeat has ell+2 levels and the stated sampler dependency. |
| G26 | 52 | gt-06-types.tex:409–427 | SUPPORTS: malformed/non-edge graph views accept, so accepted counts alone do not establish child-game coverage. |
| G27 | 56 | gt-11-parallel-repetition.tex:216–220 | SUPPORTS: malformed and oversized inputs require bounded parsing for runtime control. |
| G28 | 56 | gt-12-compression.tex:9–53 | SUPPORTS: lambda-boundedness is uniform over n≥2, and output complexity and conditional value guarantees are different obligations. |
| G29 | 58 | gt-08-introspection.tex:525–534 | SUPPORTS the source embedding and membership obligation. The universal pre-dispatch rejection is implementation-specific and is supported by T7-6 plus the opened code, not asserted by these lines alone. |
| G30 | 58 | gt-08-introspection.tex:417–425 | SUPPORTS: original child timeout N^lambda; also exposes the omitted answer-cap repair (A3). |
| G31 | 58 | gt-10-answer-reduction.tex:1406–1408 | SUPPORTS: m'=5m+5+s. No prover-cost lower bound follows from this identity alone. |
| G32 | 58 | gt-10-answer-reduction.tex:1429–1442 | SUPPORTS: evaluation-table proof representation, degree bound and x/o/w blocks. This does not rule out other executable representations. |
| G33 | 62 | gt-12-compression.tex:426–455 | SUPPORTS: the paper's diagonal program; a finite anchor run cannot establish the whole construction. |
| G34 | 62 | gt-12-compression.tex:502–519 | SUPPORTS: separate value/entanglement equivalences for the diagonal verifier. |
| G35 | 62 | gt-12-compression.tex:569–576 | SUPPORTS: existence of a suitable uniform lambda/resource bound is a separate lemma. |
| G36 | 72 | gt-10-answer-reduction.tex:237–273 | SUPPORTS: general succinct Cook–Levin contract, answer reservation, equivalence and size bounds. |
| G37 | 72 | gt-10-answer-reduction.tex:1226–1248 | SUPPORTS: padded succinct-decider contract including 2^m≥2T. |
| G38 | 72 | gt-10-answer-reduction.tex:1558–1581 | SUPPORTS: input decider → circuit → Tseitin → arithmetization → local formula/zero tests. |
## Other directly cited ranges and sections

The 22-row table above covers all claim-table evidence pointers, including the file-level test pointers. Sections are located to the relevant statements below; reading these is not a reproof of the whole analytic document or a rerun of the cited critics.

| Draft line(s) | Reference opened | Decision / support |
|---|---|---|
| 5 | handoff.md:263–280; CLAUDE.md:3 | SUPPORTS: deliverables 7–8 and expanded description-level Compress objective. |
| 19,23,42,44,46 | docs/findings.md F1/F2, 3–14 | PARTIAL overall: supports the reported occurrence example and missing-output observation; F1's old constants/status must not be reused as authority. |
| 40 | docs/DESIGN.md:53–92 | SUPPORTS: evaluator/codec distinctions, host specialization, quoted code versus executable program. |
| 48 | docs/DESIGN.md:1144–1224 | SUPPORTS: four-query boundary, prefix domains, finite replay versus general construction validity. |
| 48 | analytic §13, docs/analytic/parts/part2b.tex:681–735 | SUPPORTS: exhibited levels only, with explicit nonminimality examples. |
| 50 | verdicts/design-v2-r3.md §2.3, 178–207 | SUPPORTS the abbreviated toy arithmetic; PARTIAL as a complete interface trace (A2). |
| 52 | verdicts/tb2-r8.md §2.1, 65–91 | SUPPORTS: independently enumerated rejecting-key equality, including player and copy coverage. |
| 52 | verdicts/tb5-r1.md O8, 335–348 | SUPPORTS: most random accepted components take accept-on-invalid; draft wisely does not repeat stale exact percentages. |
| 52 | verdicts/tb5-r1.md O9, 352–360 | SUPPORTS: self-derived leaf law comparison carries no independent transcription content. |
| 52 | verdicts/tb7-r1.md T7-1, 3–7 | SUPPORTS: literal statuses and incomplete policy eligibility checks on the reviewed archive. |
| 52 | verdicts/tb7-r1.md T7-2, 9–13 | SUPPORTS: facts/children not authenticated by old callbacks. |
| 52,62 | verdicts/tb7-r1.md T7-3, 15–19 | SUPPORTS: constant-true and discarded-code mutants survived; pristine finite run itself existed. |
| 52 | verdicts/tb7-r1.md T7-4, 21–25 | SUPPORTS: final-seed chain coverage missing from the historical evidence. |
| 52 | verdicts/tb7-r1.md T7-8, 45–49 | SUPPORTS: four true agreements, five game-reaching rejections; failed CHECKED node. |
| 52 | verdicts/tb6-r4.md T6-1, 3–7 | SUPPORTS: interior-tail weakening survived while implementation rejected the critic's exhaustive malformed cases. |
| 52 | verdicts/tb6-r4.md T6-2, 9–13 | SUPPORTS: fake stdout tally could receive false credit. |
| 58 | verdicts/tb7-r1.md T7-6, 33–37 | SUPPORTS: zero Pauli/introspection dispatches at Q=2<s=9. |
| 60,70 | test/tb7_compress.jl:60–65 | SUPPORTS: production symbolic construction remains an explicit broken assertion. |
| 60 | src/compress/compress7.jl:447–450 | SUPPORTS: compress refuses policies other than ToyPolicy. |
| 60 | verdicts/design-r4.md R9, 124–147 | SUPPORTS: historical missing binder-sort derivation. |
| 60 | verdicts/design-r4.md R10, 149–172 | SUPPORTS historical code/application defect only; the draft explicitly recognizes its subsequent correction. |
| 60 | docs/DESIGN.md:33–51 | SUPPORTS: Lambda has arity but no argument-sort vector; the cited residue is real in this grammar. |
| 60 | docs/DESIGN.md:77–92 | SUPPORTS: compressor is inlined; old Apply(Quote(Compress),…) is refused. |
| 60 | verdicts/tb6-r4.md:31 | SUPPORTS: uncharged projections, dual elimination, nested Pauli/PCP arithmetic remain scoped limitations. |
| 87 | HANDOFF.md “Future directions”, 73–88 | SUPPORTS: explicitly DISCUSSION, not claims; does not authorize importing its unverified lower-bound/class-collapse/delegation assertions. |

## Independent numerical check

These are lightweight Python integer, rational and polynomial calculations, not Julia execution or timing evidence.

- **F1 and F2:** under the reported formula-tree reading, z(g,w)=1−(1−gw)(1−(1−g)(1−w)). Expanding z(x1*x2,w1) z(w1*x3,w2) w2 over characteristic 2 gives individual degrees **(2,2,2,4,3)**. Thus the shared wire has degree 4. This checks the reported reading, not an uncited claim about every implementation of the external reference. The formula tree gives deg_v≤occ_v; the gate-wire count is 2+2f+indicator(output). With f≤2 the coarse uniform bound is 7, and multiplying the disjoint-block multilinear factors adds at most 1 per coordinate, yielding the sufficient bound 8. Sources opened: ground-truth/gt-10-answer-reduction.tex:148–190,1685–1692; claims/CLAIMS.md:14,19; docs/findings.md:3–14. The latter's “≤6 / c0≤7 / d≥7” calculation omits the output-literal increment from its uniform formula bound. Neither conservative bound is a minimality theorem.
- **Parameter predicates:** the fixture's occurrence bound is 6. For TB0-small (q,d,m')=(8,6,16), (6+5d)m'/q=72, which fails <1/2. For TB0-sampled (2048,11,16), it is 61/128=0.4765625, which passes. The literal paper predicate uses k, not the toy row's d: it is 34 at k=3,q=8 and 57/128 at k=11,q=2048. Test parameters/assertions were opened at test/tb0_core.jl:424–437; the source predicate is ground-truth/gt-10-answer-reduction.tex:1409–1416. This supports the draft's FAIL/PASS report without establishing soundness.
- **Levels:** 9 → Intro's 5 → max(5+2,5)=7 → Anchor's 9 → direct-sum Repeat's 9. Ground-truth laws opened: gt-08-introspection.tex:784–797; gt-10-answer-reduction.tex:2085–2096; gt-11-parallel-repetition.tex:123–129,250–257; gt-04-cl.tex:315–327. No minimality inference.
- **Dimensions:** the toy intro tuple is (q,m,d)=(2,1,1); the AR tuple has q=2048,m=1,s=6,m'=16. Intro: (3*1+3)*1+4*50=206. PCP ambient: five (2m+1)-dimensional blocks and one (2(5+s)+1)-dimensional block give 5*3+23=38 field coordinates, hence 418 bits. Typed AR: 206+418=624; 54 types add 216 when detyped, giving 840; anchoring adds 8, giving 848; toy k=2 gives 1696. Sources opened: gt-08-introspection.tex:218–226,318–345; gt-10-answer-reduction.tex:1890–1910,1948–1965; gt-06-types.tex:371–404; gt-11-parallel-repetition.tex:123–129,200–215; verdicts/design-v2-r3.md:178–207 and tb7-r1.md:59–66. The source expression with the toy substitutions would give (32768*2)^2=4294967296 repetitions, not 2; the draft correctly calls this a toy chain.
- **Embedding:** N=2^2=4 and Q=2^1*log2(2)=2<9; also 3Q=6<9. The source explains Q at gt-08-introspection.tex:197–202 and the embedding at 524–534. The live code at src/introspect/intro_decider.jl:449–486 checks Q≥s at line 470, before Pauli dispatch at 483–486. This independently confirms zero predicate dispatches for the stated input; it is not a new all-pair runtime sweep. The policy tuple is src/policy/policy.jl:51–53.
- **Nested cost:** from the explicitly itemized historical charge model in verdicts/tb6-r4.md:27, depth 1 is (1+2+142+142+3+3)+272+81*272+1+(2+6+6+3+3)=22618. Depth 2 is (2+16+14+6+6+3+3+2*(2+16+14))+5+8+2=129. Total **22747**. Uncharged arithmetic remains outside that accounting. The “43 owned mutants” is an attributed requirement of tb6-r4:31,63, not a newly counted current-registry result.
- **Agreement split:** tb7-r1:45–49 lists four agreements (global consistency, input axis, input diagonal, proof individual diagonal) and five game-reaching cases (input consistency, proof consistency, simultaneous axis, simultaneous diagonal, game); 4+5=9. The draft has the direction correct. No fresh agreement execution is claimed.
- **Large field:** 2^11=2048; the exponent 16 is the retained PCP ambient m', not a uniform-coverage guarantee (claims/CLAIMS.md:8; gt-10-answer-reduction.tex:1429–1442).

## Content and prose assessment

The “became clearer” material is concrete: it identifies separate representation interfaces, the degree/output-literal findings, legal CL prefix domains, intermediate-size accounting, and failed provenance/coverage mechanisms. This answers handoff.md:273–280 without generic praise. It should not imply that homoiconicity has already eliminated general Cook–Levin or resource-accounting work; lines 40,60,62 correctly avoid that conclusion.

The mathematical / scale / representation split is mostly useful. Q<s is an invalid toy embedding, not evidence of computational intractability; the paragraph should label that distinction explicitly. For a physicist, the source statement at gt-08:197–202 supplies one concrete interpretation: the certified EPR register is intended to supply randomness for the original sampler, and this toy register cannot hold its nine-bit space. No claim of a physically viable compressor follows. The remaining quantum-strategy arguments and sequential-versus-parallel distinction are correctly separated.

The ranking is defensible: adjudicate evidence, expose symbolic production descriptions, then implement faithful answer reduction. Each item has a size estimate and an outcome criterion. Putting symbolic descriptions before materializing actual D1 agrees with HANDOFF.md:84–86. Step 3 should retain the goal of one general local-window compiler tested across differing descriptions, so its first accepting/rejecting fixture cannot merely recreate C10's already-existing equality surrogate. Step 4 combines small maintenance with an unsized research experiment; split those costs when it becomes an implementation brief.

The prose is sober, with no marketing, truncated sentences or garbled mathematics found. “Reconcile that residue rather than describe both defects as unchanged” (line 60) reads like an internal editorial instruction; replace it with a direct statement of the remaining binder-sort gap. Dense issue/theorem identifiers are useful author references but not explanations for physicists.

## Missing content

- A3's paired-fallback construction defect and a compact account of the source repairs governing TB6 acceptance, including the answer cap and fixed-width description caveat. Other CL conventions listed in HANDOFF.md:124 can be linked without reproducing the whole repair inventory.
- A small, structurally measured feasibility ladder before the large actual-D1 attempt: fixed accepting/rejecting programs of increasing circuit size, monomial/storage/operation counts, and a declared refusal budget. HANDOFF.md:76 proposes such a probe, but its unverified lower-bound/ceiling claims must not be imported and today's wall times must not be evidence.
- At most two clearly labeled later experiments enabled by the symbolic API: space/depth accounting and whether a different CL construction closes at a lower exhibited level (HANDOFF.md:82–86). Neither needs to precede core implementation. Prover-efficiency/delegation claims require the source/literature checks prescribed at HANDOFF.md:74,80; their omission as established results is correct.
- One physical interpretation of the embedding failure and one concrete bridge from a changed sampler/degree law to the failed downstream obligation would make this useful beyond readers already fluent in the rung names.

## Review command record

A complete command ledger with numeric exit results follows. Two exit fields from the first oversized aggregate were not retained in the displayed tool output; they are marked unknown rather than invented. Their relevant content was reopened in later, bounded reads. No wall-clock value is used as evidence.

Shell invocations: **29**; recorded exit 0: **27**; unretained exit fields: **2**. Python-only calculation/validation invocations: **2**, both exit 0. Julia processes **0**; test/registry/benchmark/rebuild commands **0**; bd commands **0**; git commands **0**. No timing was treated as evidence. Apply-patch calls: **5** total, **4** successful writes to this verdict and **1** rejected duplicate-target patch with **0** changes. No scratch file was needed and no other file was written. The ledger records shell-invocation exits, not uncaptured internal pipeline exits.

<details>
<summary>Every shell invocation, exact command and recorded result</summary>

**Command 1 — exit 0**

```bash
pwd
```

**Command 2 — exit 0**

```bash
rg --files -g 'AGENTS.md' -g 'assessment.md' -g '*98*last.md' -g 'CLAIMS.md' -g 'tb7-r1.md' -g 'tb6-r4.md' -g 'handoff.md' -g 'HANDOFF.md' -g 'findings.md' -g 'DESIGN*' -g 'assessment-r1.md'
```

**Command 3 — exit 0**

```bash
nl -ba AGENTS.md
```

**Command 4 — exit 0**

```bash
nl -ba docs/assessment.md
nl -ba briefs/98-final-assessment-draft.last.md
```

**Command 5 — exit UNKNOWN (initial aggregate output truncated)**

```bash
nl -ba claims/CLAIMS.md
```

**Command 6 — exit UNKNOWN (initial aggregate output truncated)**

```bash
nl -ba verdicts/tb7-r1.md
nl -ba verdicts/tb6-r4.md
```

**Command 7 — exit 0**

```bash
nl -ba handoff.md | sed -n '240,290p'
nl -ba HANDOFF.md
```

**Command 8 — exit 0**

```bash
nl -ba docs/findings.md
```

**Command 9 — exit 0**

```bash
wc -l claims/CLAIMS.md verdicts/tb7-r1.md verdicts/tb6-r4.md docs/assessment.md docs/DESIGN.md
nl -ba docs/assessment.md | sed -n '76,110p'
nl -ba briefs/98-final-assessment-draft.last.md
nl -ba handoff.md | sed -n '263,280p'
nl -ba CLAUDE.md | sed -n '1,20p'
```

**Command 10 — exit 0**

```bash
nl -ba claims/CLAIMS.md | sed -n '1,21p'
```

**Command 11 — exit 0**

```bash
nl -ba claims/CLAIMS.md | sed -n '14,17p;22,24p'
```

**Command 12 — exit 0**

```bash
nl -ba claims/CLAIMS.md | sed -n '25,33p'
nl -ba verdicts/tb6-r4.md | sed -n '1,112p'
```

**Command 13 — exit 0**

```bash
nl -ba verdicts/tb7-r1.md | sed -n '1,150p'
rg -n '^#|§2.3|206|624|840|848|1696' verdicts/design-v2-r3.md verdicts/tb2-r8.md verdicts/tb4-r3.md verdicts/tb0-r4.md
rg -n 'O8|O9|R9|R10|^#' verdicts/tb5-r1.md verdicts/design-r4.md
```

**Command 14 — exit 0**

```bash
nl -ba ground-truth/gt-12-compression.tex | sed -n '9,53p;75,98p;426,455p;502,519p;569,576p'
nl -ba ground-truth/gt-08-introspection.tex | sed -n '417,425p;525,534p;784,817p'
```

**Command 15 — exit 0**

```bash
nl -ba ground-truth/gt-07-ldt.tex | sed -n '413,440p;1431,1445p'
nl -ba ground-truth/gt-11-parallel-repetition.tex | sed -n '112,136p;200,220p;229,258p'
nl -ba ground-truth/gt-06-types.tex | sed -n '371,404p;409,427p'
```

**Command 16 — exit 0**

```bash
nl -ba ground-truth/gt-10-answer-reduction.tex | sed -n '148,190p;237,273p;1226,1248p;1406,1416p;1429,1442p;1509,1540p;1558,1581p;1685,1692p;1733,1755p;2077,2116p'
```

**Command 17 — exit 0**

```bash
nl -ba ground-truth/gt-04-cl.tex | sed -n '122,130p;151,180p;282,327p;572,601p'
nl -ba docs/DESIGN.md | sed -n '33,92p;1144,1224p'
nl -ba test/tb7_compress.jl | sed -n '60,65p'
nl -ba src/compress/compress7.jl | sed -n '447,450p'
```

**Command 18 — exit 0**

```bash
nl -ba verdicts/design-v2-r3.md | sed -n '178,208p'
nl -ba verdicts/tb2-r8.md | sed -n '65,92p;328,356p;358,374p'
nl -ba verdicts/tb5-r1.md | sed -n '335,361p'
nl -ba verdicts/design-r4.md | sed -n '124,173p'
nl -ba verdicts/tb4-r3.md
```

**Command 19 — exit 0**

```bash
rg -n '^\\section|^\\subsection|^\\begin\{(theorem|lemma)|^\\label|not.*minimal|minimal|SKETCH' docs/analytic/parts/part2a.tex docs/analytic/parts/part2b.tex
rg -n '^#|PROMOTE|RE-AFFIRM|C1|C2|C3|C8' verdicts/tb0-r4.md
rg -n '^#|orbit|1-2|Theta|sequential' toys/midpoint/PROOF.md
rg -n '624|Findings|FD[1-6]|SOURCE_REPAIR' HANDOFF.md
rg -n 'Q =|Q>=s|Q >= s|embedding|Pauli|intro_tuple|TB7_TOY_POLICY' src/introspect/intro_decider.jl src/policy/policy.jl src/compress/compress7.jl
```

**Command 20 — exit 0**

```bash
nl -ba docs/analytic/parts/part2a.tex | sed -n '329,353p;711,748p;802,841p;947,969p;1032,1061p;1170,1183p;1244,1260p;1282,1297p;1381,1406p;1512,1530p'
nl -ba docs/analytic/parts/part2b.tex | sed -n '42,55p;107,134p;267,279p;681,735p'
```

**Command 21 — exit 0**

```bash
nl -ba HANDOFF.md | sed -n '1,32p;73,88p;121,125p'
nl -ba src/policy/policy.jl | sed -n '49,54p'
nl -ba src/introspect/intro_decider.jl | sed -n '445,489p'
nl -ba ground-truth/gt-08-introspection.tex | sed -n '516,527p;757,765p'
rg -n 'eq:V-pcp|3m|32.*ell|type.*intro' ground-truth/gt-08-introspection.tex ground-truth/gt-10-answer-reduction.tex | head -n 20
```

**Command 22 — exit 0**

```bash
nl -ba ground-truth/gt-08-introspection.tex | sed -n '218,226p;318,350p'
nl -ba ground-truth/gt-10-answer-reduction.tex | sed -n '1890,1910p;1940,1965p'
nl -ba toys/midpoint/PROOF.md | sed -n '1,74p;119,154p'
rg -n -m 8 'C1|C2|C3|C8|VERDICT:' verdicts/tb0-r4.md
rg -n -m 12 'TB0_SMALL|TB0_SAMPLED|P_formula_structural|formula_structural|PCPParams\(8|PCPParams\(2048' src test/tb0_core.jl
```

**Command 23 — exit 0**

```bash
rg -n '^## 6|C1 —|C1:|VERDICT:' verdicts/tb0-r4.md
nl -ba test/tb0_core.jl | sed -n '424,437p;450,471p;563,576p;674,698p'
rg -n 'testset' test/tb1_ld_sampler.jl test/tb3_frontend.jl test/tb5_repeat.jl | head -n 45
rg -n -F 'Q =' ground-truth/gt-08-introspection.tex ground-truth/gt-07-ldt.tex | head -n 12
```

**Command 24 — exit 0**

```bash
python3 - <<'PY'
from pathlib import Path
from fractions import Fraction
import re
pat = r'^\| ([CN]\d+[a-z]?) \|.*?\| (PROVED|TESTED|SKETCH|CONJECTURE|REFUTED) \|'
draft = Path('docs/assessment.md').read_text()
a = dict(re.findall(pat, draft, re.M))
b = dict(re.findall(pat, Path('claims/CLAIMS.md').read_text(), re.M))
print('CLAIM_ROWS',len(a),'STATUS_MISMATCHES',sum(b.get(k)!=v for k,v in a.items()))
print('STATUSES',a)
# Independent characteristic-two polynomial arithmetic for the reported two-gate reading.
zero = (0,)*5
one = {zero}
def add(a,b): return a ^ b
def mul(a,b):
    out=set()
    for x in a:
        for y in b:
            z=tuple(i+j for i,j in zip(x,y))
            if z in out: out.remove(z)
            else: out.add(z)
    return out
def var(i): return {tuple(int(j==i) for j in range(5))}
def neg(a): return add(one,a)
def OR(a,b): return neg(mul(neg(a),neg(b)))
def gadget(g,w): return OR(mul(g,w),mul(neg(g),neg(w)))
x1,x2,x3,w1,w2 = map(var,range(5))
p=mul(mul(gadget(mul(x1,x2),w1),gadget(mul(w1,x3),w2)),w2)
deg=tuple(max(t[i] for t in p) for i in range(5))
print('TWO_GATE_DEGREES',deg,'MONOMIALS',len(p))
print('FANOUT2_OCCURRENCE_BOUND',2+2*2+1,'C0_UNIFORM_BOUND',2+2*2+1+1)
for name,q,k,d in [('small',8,3,6),('sampled',2048,11,11)]:
    structural=Fraction((6+5*d)*16,q)
    paper=Fraction((2+5*k)*16,q)
    print('POLICY',name,'structural',str(structural),'PASS',structural<Fraction(1,2),'paper_k',str(paper))
print('LEVELS',[9,5,max(5+2,5),max(5+2,5)+2])
s1=(3*1+3)*1+4*(26+2*(3+9))
st=s1+(5*(2*1+1)+(2*(5+6)+1))*11
sd=st+4*(3*(3*6))
print('DIMENSIONS',[s1,st,sd,sd+8,2*(sd+8)])
print('EMBEDDING',dict(n=2,N=2**2,lam=32768,Q=2**1*1,s0=9,threeQ=3*2))
depth1=(1+2+142+142+3+3)+272+81*272+1+(2+6+6+3+3)
depth2=(2+16+14+6+6+3+3+2*(2+16+14))+5+8+2
print('NESTED',depth1,depth2,depth1+depth2)
print('AGREEMENT_CASE_COUNTS',len(['global','input axis','input diagonal','individual diagonal']),len(['input consistency','proof consistency','simultaneous axis','simultaneous diagonal','game']))
refs=[]
for line_no,line in enumerate(draft.splitlines(),1):
    for m in re.finditer(r'`((?:ground-truth/)?gt-[^`:]+\.tex):([^`]+)`',line):
        refs.extend((line_no,m.group(1),x) for x in m.group(2).split(','))
print('GT_RANGE_OCCURRENCES',len(refs),'DISTINCT',len(set((p,r) for _,p,r in refs)))
for x in refs: print('CITE',*x)
PY
```

**Command 25 — exit 0**

```bash
nl -ba test/tb1_ld_sampler.jl | sed -n '70,93p;221,275p;312,339p;663,692p'
nl -ba verdicts/tb0-r4.md | sed -n '342,351p;390,409p'
```

**Command 26 — exit 0**

```bash
nl -ba test/tb3_frontend.jl | sed -n '86,101p;373,388p;660,702p'
nl -ba test/tb5_repeat.jl | sed -n '290,316p;454,473p;532,546p;666,686p;832,847p'
```

**Command 27 — exit 0**

```bash
nl -ba docs/assessment.md
nl -ba ground-truth/gt-08-introspection.tex | sed -n '197,207p'
nl -ba HANDOFF.md | sed -n '73,76p'
rg -n 'occurrence|two-gate|two gate|nondegenerate.*degree|Dependencies\(g' test/tb0_core.jl | tail -n 20
```

**Command 28 — exit 0**

```bash
cat verdicts/assessment-r1.md
```

**Command 29 — exit 0**

```bash
python3 - <<'PY'
from pathlib import Path
import re
p=Path('verdicts/assessment-r1.md')
s=p.read_text()
d=Path('docs/assessment.md').read_text()
expected=[]
for m in re.finditer(r'`((?:ground-truth/)?gt-[^`:]+\.tex):([^`]+)`',d):
    expected.extend((m.group(1).removeprefix('ground-truth/'),r) for r in m.group(2).split(','))
rows=re.findall(r'^\| G\d+ \| [^|]+ \| (gt-[^:]+\.tex):(\d+–\d+) \|',s,re.M)
print('GT_OCCURRENCES',len(expected),'PHYSICAL_RANGES',len(set(expected)),'TABLE_ROWS',len(rows),'MISSING',len(set(expected)-set(rows)),'EXTRA',len(set(rows)-set(expected)))
print('CLAIM_AUDIT_ROWS',len(re.findall(r'^\| \d+ / [CN]\d+[a-z]? ',s,re.M)))
print('FINDINGS',re.findall(r'^\d+\. \*\*(A\d+) · (MAJOR|MINOR)',s,re.M))
print('FINAL_LINE',s.strip().splitlines()[-1])
print('DRAFT_LINES',len(d.splitlines()),'VERDICT_LINES',len(s.splitlines()))
assert len(expected)==46 and set(rows)==set(expected) and len(rows)==38
assert len(re.findall(r'^\| \d+ / [CN]\d+[a-z]? ',s,re.M))==22
assert s.strip().splitlines()[-1]=='VERDICT: FAIL(A1)'
PY
```

</details>

Not done: no runtime validation, no fresh mutation census, no brief-97 adjudication, no edits to the assessed draft, no issue updates, no commit or push. Only verdicts/assessment-r1.md was written; the orchestrator owns subsequent changes.

VERDICT: FAIL(A1)
