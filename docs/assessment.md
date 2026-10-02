# DRAFT — pending the TB7/TB6 closing round (brief 97)

2026-10-02

This addresses deliverables 7 and 8 of `handoff.md:263–280`, against the expanded objective in `CLAUDE.md:3`: an executable transformation of verifier descriptions implementing Compress = Repeat ∘ AnswerReduce ∘ Introspect (`ground-truth/gt-12-compression.tex:75–98`). The useful result so far is an inspectable construction with explicit failures and evidence boundaries. It is not yet a complete implementation on arbitrary input descriptions.

## What was built and at what status

The status column follows `claims/CLAIMS.md` exactly; HOLD annotations qualify the existing rows rather than promote or replace them. Summaries below do not replace those rows' quantifiers and caveats. “TESTED” means evidence on the stated fixtures, not a theorem about the transformation.

| Claim | Content and scope | Status | Evidence pointer |
|---|---|---|---|
| C1 | Explicit PCP completeness on named points and lines; no uniform large-field sampling. | TESTED | CLAIMS C1; `test/tb0_core.jl`; `verdicts/tb0-r4.md` |
| C2 | Zero-basis coefficient identities and rejection of the retained unsatisfying witness. | TESTED | CLAIMS C2; `test/tb0_core.jl` |
| C3 | Degree and dependency reports; only the nondegenerate witness supplies block-dependency evidence. | TESTED | CLAIMS C3; `test/tb0_core.jl` |
| C4a | Explicit low-degree-test CL maps, query replay and description codec. | TESTED | CLAIMS C4a; `test/tb1_ld_sampler.jl` |
| C4b | PCP sampler family and typed product on the declared chain set. | TESTED | CLAIMS C4b; `verdicts/tb2-r8.md` §6 |
| C4c | Classical low-degree decider on its stated polynomial fixture. | TESTED | CLAIMS C4c; `test/tb1_ld_sampler.jl` |
| C5 | Repaired low-degree-PCP soundness derivation, with an additional parameter obligation. | SKETCH | CLAIMS C5; `docs/findings.md` F1 |
| C6 | Midpoint diagnostic under its orbit-prefix hypothesis. | PROVED | CLAIMS C6; `toys/midpoint/PROOF.md` |
| N1 | Midpoint amplification obstruction for sequential repetition only. | PROVED | CLAIMS N1; `toys/midpoint/PROOF.md` |
| C7 | CL query algebra as the reusable structural explanation. | CONJECTURE | CLAIMS C7 |
| C8 | Degree discrepancy for the implemented reading of Tseitin arithmetization. | TESTED | CLAIMS C8; `docs/findings.md` F1/F2 |
| C9 | Typed answer-reduced decider on the TB0 fixture; quantum conclusions remain cited. | TESTED | CLAIMS C9; `verdicts/tb2-r8.md` §6 |
| C10 | Quoted front end on fixtures; Cook–Levin is a fixture surrogate. | TESTED | CLAIMS C10; `test/tb3_frontend.jl` |
| C11 | Compress contracts and quoted fixed point with disclosed construction stubs. | TESTED | CLAIMS C11; `verdicts/tb4-r3.md` |
| C12 | Description-level CL combinators and laws on selected chains. | TESTED | CLAIMS C12; `test/tb5_repeat.jl` |
| C13 | Executable anchoring and repetition under toy substitutions. | TESTED | CLAIMS C13; `test/tb5_repeat.jl` |
| C14 | TB6 introspection under explicit toy child fuel. **HOLD** — `tb6-r4` FAIL(T6-1,T6-2); scope stands, no complete replacement authorized; eventual row must state 43 owned mutants, nested `[22618,129]=22747`, D1(d) test-only; repair = brief 93. | TESTED | CLAIMS C14; `verdicts/tb6-r4.md` |
| C15 | TB7 composition bookkeeping and finite fixed-point unfold. **HOLD** — `tb7-r1` T7-6 refutes its Pauli-execution clause; no replacement authorized. | CONJECTURE | CLAIMS C15; `verdicts/tb7-r1.md` |
| C16 | Written semantics and fuel laws for the analytic term language. | SKETCH | CLAIMS C16; `docs/analytic/parts/part2a.tex` §8 |
| C17 | Written costed machine/term bridge. | SKETCH | CLAIMS C17; analytic §9 |
| C18 | Written description-level self-reference and size accounting. | SKETCH | CLAIMS C18; analytic §10 |
| C19 | Written general Cook–Levin construction for descriptions. | SKETCH | CLAIMS C19; `docs/analytic/parts/part2b.tex` §11 |

Here and below, “CLAIMS C…” denotes the corresponding row of `claims/CLAIMS.md`; all `gt-*` citations denote files in `ground-truth/`. In particular, `lem:ld-soundness`, `thm:pauli`, `thm:introspection`, `thm:pcp-decider`, `thm:ar`, `prop:anchoring`, `thm:repetition` and `thm:compression` remain **CITED** for their soundness conclusions: implementing predicates or simulating honest strategies does not establish guarantees against arbitrary cheating strategies (CLAIMS C5, C9, C12–C15; `gt-07-ldt.tex:413–440,1431–1445`; `gt-08-introspection.tex:784–817`; `gt-10-answer-reduction.tex:1509–1540,2077–2116`; `gt-11-parallel-repetition.tex:112–136,229–258`; `gt-12-compression.tex:26–53`). Whether brief 93 discharges the held objections and permits replacement rows remains unresolved [pending brief 97].

## What became clearer

**Descriptions force the interfaces to become explicit.** Quotation, host specialization, evaluation, description length, fuel and dependency are now distinct objects. C10 also exposes the limit: its Cook–Levin step fits transitions on fixture traces rather than implementing the general local-window construction. C11 exposes the stubs beneath its fixed-point demonstration. This is useful semantic bookkeeping, without elevating C16–C19 beyond SKETCH (CLAIMS C10–C11, C16–C19; `docs/DESIGN.md:53–92`). The source itself computes and passes descriptions at each transformation boundary (`gt-12-compression.tex:75–98,426–449`).

**F1 made a hidden degree assumption inspectable.** The source asserts individual degree at most 2 and justifies it by an occurrence count (`gt-10-answer-reduction.tex:173–190`). Under the project's reading of the cited Tseitin gadget, the regression instead has a wire of degree 4; C8 tests occurrence bounds on two circuits only. This is a discrepancy against that reading, not a verified classification of all possible Tseitin constructions (CLAIMS C8; `docs/findings.md` F1).

The surviving statement is `deg_v(F_arith) ≤ occ_v`. Including the output literal, C5's proposed repair with fanout at most 2 gives `deg_F ≤ 7` and requires `d ≥ 8`; these are SKETCH inferences, not a tested general repair. The formula bound becomes `(deg_F+5d)m'/q`, while the paper uses `(2+5d)m'/q`; its parameter selection therefore does not automatically discharge the stronger obligation. `P_formula_structural` fails on TB0-small and passes on TB0-sampled (CLAIMS C5, C8; source comparison `gt-10-answer-reduction.tex:1409–1416,1685–1692,1733–1755`). The earlier constants in `docs/findings.md` F1 must not override C5.

**F2 separates a consistent wire assignment from acceptance.** The finding reports that the referenced gadget omits the output constraint; the implementation conjoins `w_out`. The ground-truth contract requires circuit acceptance iff a satisfying auxiliary assignment exists, so merely assigning consistent gate values is insufficient (CLAIMS C2, C8; `docs/findings.md` F2; `gt-10-answer-reduction.tex:148–158`).

**Conditional linearity is an interface obligation.** `Dimension`, `Marginal`, `Factor` and `Linear` expose the factor partition and marginal decomposition, including different legal prefix domains. C4a/C4b and C12 supply finite replay evidence; general closure semantics remain cited (`gt-04-cl.tex:151–180,572–601`; `docs/DESIGN.md:1144–1224`). Concatenation and direct sum exhibit allowed levels, not minimal levels (`gt-04-cl.tex:122–130,282–327`). This agrees with analytic §13; it does not prove the broader C7 conjecture.

**Bookkeeping agrees even where execution fails.** Independent recomputation confirms the toy level chain `9→5→7→9` and dimensions `206→840→848→1696` (`verdicts/design-v2-r3.md` §2.3; CLAIMS C15). The source supplies the introspection, answer-reduction and repetition level laws and the detyping/anchoring dimension increments (`gt-08-introspection.tex:784–797`; `gt-10-answer-reduction.tex:2085–2096`; `gt-06-types.tex:371–404`; `gt-11-parallel-repetition.tex:123–129,200–215,250–257`). Agreement of this arithmetic does not discharge the parameter predicates.

**The critics found implementation failures, not just missing theorems.** TB2's rejecting-key equality made player, copy and dispatch coverage explicit (`verdicts/tb2-r8.md` §2.1). TB5 showed that many accepted transcripts reach only the source's accept-on-invalid detyping branch, and that a law comparison derived from the object itself can be tautological (`verdicts/tb5-r1.md` O8/O9; `gt-06-types.tex:409–427`). TB7 found replay callbacks detached from printed facts, constant-true and discarded-code mutants, missing final-chain coverage, and literal predicate statuses (`verdicts/tb7-r1.md` T7-1–T7-4). Its agreement node had four agreements among nine cases; the other five complete decisions hit the unexecuted game layer (`verdicts/tb7-r1.md` T7-8). TB6 additionally exposed interior-coordinate coverage holes and forged mutation tallies (`verdicts/tb6-r4.md` T6-1/T6-2). Passing counts need provenance and branch witnesses.

## What remains difficult

**Mathematical.** Low-degree extraction and Pauli rigidity quantify over strategies and measurements; honest stabilizer simulation cannot replace those arguments (`gt-07-ldt.tex:413–440,1431–1445`). Anchored parallel repetition has its own quantitative entanglement implication, which C6/N1's sequential midpoint diagnostic does not establish (CLAIMS C6, N1; `gt-11-parallel-repetition.tex:229–258`). Uniform-in-index runtime bounds require a costed semantics and composition argument, including malformed inputs, rather than timings at a toy index (CLAIMS C16–C19; `gt-11-parallel-repetition.tex:216–220`; `gt-12-compression.tex:9–53`). For extensions, retaining cited theorems is legitimate only while their hypotheses and constructions still apply.

**Scale and engineering.** At TB7's `n=2, λ=32768`, the toy encoding has `Q_I=2<s_0(N)=9`. The embedding guard rejects before dispatch: zero introspection predicates execute, including Pauli predicates (CLAIMS C15 HOLD; `verdicts/tb7-r1.md` T7-6; source embedding `gt-08-introspection.tex:525–534`). TB6 acceptance uses explicit toy child fuel, not acceptance under the source's child timeout (CLAIMS C14; `gt-08-introspection.tex:417–425`). The actual-`D1` PCP game remains unexecuted; even C10's equality fixture is refused before `build_pcp` (CLAIMS C10, C15). C1 has no uniform sampling in `GF(2^11)^16` (`yqw`). The source has `m'=5m+5+s`, but this alone establishes no unavoidable prover-cost lower bound; the particular expanded representation is a separate engineering choice (`gt-10-answer-reduction.tex:1406–1408,1429–1442`).

**Representation.** Production construction is still a broken test; `compress` requires ToyPolicy (`test/tb7_compress.jl:60–65`; `src/compress/compress7.jl:447–450`). The lambda layer also needs a precise sort account. Historical `ruj` R9 concerns untyped binder slots; R10 concerns applying quoted code. DESIGN now explicitly corrects R10 by inlining the compressor, while its grammar still gives `Lambda` only an arity (`verdicts/design-r4.md` R9/R10; `docs/DESIGN.md:33–51,77–92`). Reconcile that residue rather than describe both defects as unchanged. The implemented evaluator's cost convention differs from the analytic one (CLAIMS C16–C18), and `verdicts/tb6-r4.md:31` explicitly retains uncharged nested vector, dual-map, Pauli and PCP arithmetic; neither issue disappears when the printed bound is correct.

The finite fixed point establishes neither the general value argument nor a suitable uniform resource bound. TB7's anchor run does not exercise its missing game layers, and its original tests admitted substituted execution (CLAIMS C11, C15, C18; `verdicts/tb7-r1.md` T7-3). The paper's corresponding claims remain separate (`gt-12-compression.tex:426–455,502–519,569–576`).

## Recommended next steps

Ranked by usefulness to an author changing the construction; sizes below are scope estimates, not measured schedules.

1. **Close the evidence boundary — small review/repair cycle.** Settle replay binding, computed policy statuses, actual-code execution, reached-chain coverage and authoritative mutation results before treating the repaired checkpoint as evidence. Success means explicit decisions on the named TB7/TB6 objections and only authorized CLAIMS replacements; acceptance of brief 93 remains [pending brief 97]. This is a prerequisite for trusting the traces used in later experiments.

2. **Represent the parameterized production family — medium implementation spanning descriptions, policies and constructors.** Add a symbolic construction API that retains unknown universal constants and indexed resource laws, independently of materializing questions or answers. Success means serializable output descriptions with a trace of each stage's dimensions, levels, degrees, dependencies, premises and source repairs, plus explicit refusal at a bounded execution boundary. An extension author should be able to replace a sampler or parameter law and see precisely which downstream obligations change. The current production refusal makes this the most useful missing interface (`test/tb7_compress.jl:60–65`; source transformation contract `gt-12-compression.tex:26–53,75–98`).

3. **Complete the semantic answer-reduction path — large staged implementation, with a research risk in proof representation.** Replace the fixture-fitted Cook–Levin front end and bind the PCP content to the exact input decider. First use a small accepting/rejecting decider; then attempt the actual introspection decider. Success is an inspectable description→trace→clauses→Tseitin→polynomials→query-view trace, with negative witnesses at each boundary and explicit evidence for any lazy polynomial representation. Report structural storage/operation counts and refusal causes; do not infer an inherent lower bound from expansion failure (CLAIMS C10, C19; source contracts `gt-10-answer-reduction.tex:237–273,1226–1248,1558–1581`). This directly advances the original answer-reduction deliverable and supplies the trace needed to compare an alternative PCP.

4. **Make the extension surface reliable — small local tasks, followed by a broader experiment.** Add the missing large-field sampling (`yqw`), reconcile binder and quotation sorts (`ruj`), and synchronize the physicist tutorial with authorized statuses (`n6b`). Then compare a candidate query construction through the existing sampler API, recording where factor partitions, legal prefixes or resource contracts fail. Success would be a reproducible obstruction or a precise new conjecture; it would not automatically promote C7 (CLAIMS C1, C7, C12; `gt-04-cl.tex:151–180,572–601`).

## Open items

Issue names here are handoff references, not a live beads-status audit; no issue was changed in this writing session.

- **f7v:** this assessment; finalize the closing-round-dependent account [pending brief 97].
- **yqw:** uniform large-field PCP sampling absent from C1.
- **ruj:** reconcile design-r4 R9/R10 with subsequent lambda-layer repairs.
- **n6b:** tutorial upkeep after the governing claim text is settled.
- **7jd:** complete TB7 beyond the toy checkpoint, including production descriptions and faithful game execution.
- **fxw:** critic follow-through on TB7/TB6 and authorization of replacement rows.

The roadmap deliberately leaves the speculative “Future directions” in `HANDOFF.md` as research proposals: no new prover-efficiency theorem, restricted-verifier closure result, or asymptotic conclusion is claimed here.
