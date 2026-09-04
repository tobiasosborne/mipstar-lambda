# DESIGN v2 repair r1 response

Work order: `verdicts/design-v2-r1.md`.  Scope is limited to `docs/DESIGN.md` §§9–13, `docs/definitions.md` §H, this response, and the requested brief report.  The response follows rk-light law 5: every verdict item has an explicit disposition and no repaired text promotes a theorem leaf.

Disposition totals for the tables below are **FIXED 32 / RETRACTED 1 / DOWNGRADED 2 / RESIDUE 0**.

## Objections, minors, and notes

| id | disposition | exact DESIGN location | one-line change |
|---|---|---|---|
| O1 | FIXED | §§9.1–9.6, 10.1, 11.2–11.3 | Added `enu:cl-space-sum` and `enu:cl-map-sum` to every output `LawCert`; zero maps now use whole-space stage 1 under `SOURCE_REPAIR(zero-map-factor-partition)`, with all originating constructors enumerated. |
| O2 | FIXED | §§11.4, 11.6, 13.3 C14 | Fixed the one authoritative non-Pauli encoding to full `Q`-bit vectors, retained printed literal `>=3Q`, made `>3Q` operative under `SOURCE_REPAIR(intro-3Q-guard)`, and printed literal rejection counts 10/116 and 22/128. |
| O3 | FIXED | §§11.6, 12.5, 13.1, 13.3 C14 | Added `TB6b-M` with `ell=3,s=6`, live prefix-dependent factors and dual schedule; made TB7 input nine-stage with `s_0=9`; introduced explicit `VACUOUS` grades. |
| O4 | FIXED | §§11.6, 13.3 C14 | `TB6b-M` has `L^alice!=L^bob` and a named seed/order-sensitive transcript that makes `M6-game` red. |
| O5 | RETRACTED | §§12.4–12.5, 13.1, 13.3 C15 | Added `P_pcp_encodes_D1=FAIL`, marked actual-`D1` `enu:ar-game` `NOT_EXECUTED` with owner, and removed the aggregate “16 honest accepts” claim; no parameter-only PCP is called content-faithful. |
| O6 | FIXED | §13.2 | Added the twelfth CL/dual-theory CITED item, removed “exact,” and recorded the `rg`-based unique-label classification audit. |
| O7 | FIXED | §§9.2, 12.1 | Restored explicit `max{Ent(...),(1-delta)2^(2^(lambda*n))}`; only the exact symbolic scalar floor branch is CHECKED, while the Ent branch and semantic implication remain CITED. |
| O8 | FIXED | §9.4 | Replaced the Cartesian graph claim by the tensor-product edge formula and added `((O,Point_1),(A,DLine_6))` as the distinguishing red pair. |
| O9 | FIXED | §10.3, §13.3 C13 | Added named transcripts `T5-game-seed1`, `T5-anchor-one`, `T5-one-corrupt`, and `T5-boundary`, with an explicit owner for each affected mutant. |
| O10 | FIXED | §§12.3, 12.5, 13.2 item 10 | Tagged `SOURCE_REPAIR(intro-decider-fixed-width)`, required exact printed `sigma_1`, and separated CHECKED repaired dependency from the paper lemma's CITED dependency gap. |
| O11 | FIXED | §§11.4, 11.6 | Deleted the non-repairing boundary tag and replaced it with the actual `intro-3Q-guard` repair, synchronized to definitions §H. |
| O12 | FIXED | §9.6 | Made typed descriptions refinement aliases and defined `VerifierDescription`; definitions §H now has all three rows. |
| O13 | FIXED | §§9.4–9.6 | Standardized the public arity to `detype(s,d)` and made sampler/decider forms internal projections. |
| O14 | FIXED | §13.3 C12 | Named all six `DL9-*` implementation lemmas in the C12 proposal and its promotion steps. |
| O15 | FIXED | §§9.4, 10.2 | Renamed the folded row `anchored_repeat`, stated that its input is pre-anchoring, and distinguished it from internal repetition of an already anchored sampler. |
| O16 | FIXED | §9.1 | Recorded the source's wider legal prefix domain for `Linear` and the reachable-image restriction for `Factor`. |
| O17 | FIXED | §9.1 | Raw typed code returns source-literal `0` for out-of-range types; only the validated public wrapper substitutes `QueryError`, which certified constructors cannot trigger. |
| O18 | FIXED | §12.1 | Attributed `epsilon1` and `epsilon2` to `eq:re-eps-1` and `eq:re-eps-2`, leaving `mu,gamma` at `eq:mu-gamma`. |
| O19 | FIXED | §13.1 | Split construction/transcript budgets and printed the matching TB5 `<7 s` and combined TB6b `<43 s` totals. |
| O20 | FIXED | §§12.5, 13.1 | Reduced TB7 to `<512 MiB`, quantified declared payload bytes, and required a printed structural `c_j` evaluator rather than a dense `12^16` representation. |
| O21 | FIXED | §11.4 | Replaced “projection” by the source-exact canonical linear map with kernel basis `S`, noting the register-subspace special case. |
| N1 | FIXED | §10.2 | Recorded the short-exponent conflict at `gt-12:L70` and retained `(lambda*n)^((1+c_prime)tau)` from the two agreeing source occurrences. |
| N2 | FIXED | §§11.1, 11.6, 12.5 | Replaced the weak theorem capacity report by `s(N)<=R<=M<=Q`, with `M>=R` separately graded. |
| N3 | FIXED | §9.2 | Defined CHECKED `LawCert` AST equality as equality to an independently hand-transcribed AST, not theorem proof. |
| N4 | FIXED | §§10.2, 11.4 | Preserved Repeat's strict `>` boundary and displayed Introspect's literal `>=` beside the operative repaired `>`. |
| N5 | FIXED | §9.4 | Added explicit ASSUME `q=p^k` with odd `k` to `downsize`. |
| N6 | FIXED | §9.1 | Retained the four-query boundary and added the zero-stage counterexample showing why `Factor` is independent. |

## MERGE PROPOSALS adjudication response

| id | disposition | exact DESIGN location | one-line change |
|---|---|---|---|
| MP-preamble | FIXED | §13.3 preamble | Accepted unchanged: the rows remain orchestrator-paste proposals and `claims/CLAIMS.md` is untouched. |
| MP-C12 | FIXED | §13.3 C12 | Retained CONJECTURE and added the six `DL9-*` names, sampler-validity blocker, zero-map rule, and tensor-product correction. |
| MP-C13 | FIXED | §13.3 C13 | Retained CONJECTURE and added nonzero-Anchor, one-corrupt-component, and exact-boundary transcript clauses. |
| MP-C14 | DOWNGRADED | §13.3 C14 | Replaced the rejected single-fixture completeness wording by separately scoped exhaustive/diagnostic fixtures, operative/literal guards, printed counts, and named live checks. |
| MP-C15 | DOWNGRADED | §13.3 C15 | Limited the row to composition/bookkeeping/hash/fixed-point evidence and made PCP-content failure plus non-execution explicit. |
| MP-missing-steps | FIXED | §13.3 post-table bullets | Added the O1 replay, O9 negatives, O3/O4 second fixture and VACUOUS grades, and O5 content predicate/owner. |
| MP-DD23–30 | FIXED | §§9–13 DD-23–DD-30 | Accepted the decisions; repairs enforce DD-24 and DD-28 where the verdict found violations. |
| MP-residue | FIXED | §13.2 | Kept the residue inventory form, added item 12 and its audit method, and stopped claiming lexical exhaustiveness. |

## Confirmed recomputations retained

The repair relies on and preserves the critic's recomputations in `verdicts/design-v2-r1.md`: R(a) `9→5→7→9`; R(b) `206→840→848→1696` (unchanged when `s_0` becomes 9 because Introspect resets its output dimension); R(c) 26 Pauli types and `6ell+110` oriented Intro pairs; and R(d) literal `>=3Q` versus an honest Hide length exactly `3Q`.  No competing arithmetic was substituted.

## DIRECTIVES FOR TB5–TB7

### TB5

- Emit the §9.2 factor-partition/telescoping children for anchor and repeated outputs, then make `M-factor-partition` red.
- Run `T5-game-seed1`, `T5-anchor-one`, `T5-one-corrupt`, and both halves of `T5-boundary`; report every `M5-*` owner and nonzero exit independently.
- Report construction and transcript walls separately so the `<2 s + <5 s = <7 s` target is mechanically comparable.

### TB6

- Keep `TB6b-E` as the exhaustive six-qubit fixture, use only the §11.4 full-`Q` encoding, and print `literal_hide_rejections=10/116` beside operative acceptance.
- Add `TB6b-M` exactly as specified: `n=2,N=4,lambda=2,ell=3,s=6,(q,m,d)=(8,2,1)`, `R=16,M=4,Q=12`, dimension 179, 26 physical tableau qubits, seed `z*`, prefix-dependent factors, nonsymmetric stage-2 map, and `L^alice!=L^bob`.
- Print `VACUOUS` for empty guard sets or a low-degree margin `>=1/2`; never count it as PASS.  Make `M6-factor-prefix`, `M6-perp`, and `M6-game` red only on the live fixture.
- Adopt `M-factor-partition`, `M-detype-view-orientation`, and `M-intro-fuel` with the exact killers in §11.6; the warm diagnostic target is `<25 s`, and the combined TB6b target is `<43 s` and `<512 MiB`.

### TB7

- Use the nine-bit/nine-stage input while retaining the verdict-confirmed dimension chain; print the resulting failed `Q_I>=s_0(N)` predicate.
- Compute and print exact fixed-width `sigma_1`, `P_pcp_encodes_D1=FAIL`, and `enu:ar-game=NOT_EXECUTED(owner=pcpverifier-D1-trace)`; do not substitute the six-gate PCP content or report aggregate honest acceptance.
- Print `representation=structural-evaluator` for `c_j`; keep the warm/peak gates at `<60 s` and `<512 MiB`.
- Run all ten named `M7-*` mutations, including tensor-vs-Cartesian, IntroGap floor deletion, and PCP-content provenance, with one expected failing assertion apiece.

No Julia command was run in this documentation-only repair.
