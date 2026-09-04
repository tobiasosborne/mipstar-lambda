# DESIGN v2 repair r2 response

Work order: [verdicts/design-v2-r2.md](../verdicts/design-v2-r2.md), N1–N2, §4, and the binding Brief 34 directives.  Edits are confined to DESIGN §§9–13, definitions §§G–H, this response, and the requested brief report.  The round-2 §1 ACCEPTED findings are retained; the changes below address the named remaining work without promoting a claim.

Disposition totals: **FIXED 12 / RETRACTED 0 / DOWNGRADED 1 / RESIDUE 0**.  DOWNGRADED records the authorized weaker N1 statement; it does not certify an unmeasured runtime or a completed TB6 implementation.

| id | disposition | section | one-line response |
|---|---|---|---|
| N1 | DOWNGRADED | DESIGN §§11.1, 11.4, 11.6, 12.4, 13.1, 13.3 C14; definitions §H | Declared the primitive interpreter fuel unit, retained λ=1/2 and R=4/16, printed `toy_child_fuel=FAIL(owner=tb6-child-meter)` for the explicit 65,536-step override, and made toy acceptance conditional on measured fit; exact per-mode costs remain visibly NOT_EVALUABLE pending implementation. |
| N2 | FIXED | DESIGN §§12.4–12.6, 13.1–13.3; definitions §H | Printed `VACUOUS(owner=Q_I<s_0)` for every non-Pauli TB7 schema, listed both non-executed layers with owners, added DD-31 and `M7-intro-schema`, and scoped the timeout test as synthetic evaluator entry. |
| m1 | FIXED | definitions §G | Widened SOURCE_REPAIR to include a construction change closing a source gap with its changed theorem input named. |
| m2 | FIXED | DESIGN §9.2 | Defined `prefix_i := Marginal(i-1,x)` and the mathematical zero first prefix, without adding an illegal stage-0 API call. |
| m3 | FIXED | DESIGN §§9.2, 12.5, 13.1 | Limited larger-fixture replay to a declared branch-directed chain set and required distinct-chain/completed-replay counts for every sampler. |
| m4 | FIXED | DESIGN §§11.1, 11.6 | Printed embedding separately from the broken capacity chain: E has 2≥1 and M has 12≥6. |
| m5 | FIXED | DESIGN §11.6; §13.3 C14 | Pinned E's deterministic child answer to one bit, so Read length 5<6 cannot add literal rejections to 10/116. |
| m6 | FIXED | DESIGN §11.6 | Printed M's admissibility, divisibility, d, embedding and canonical-equality rows, with the even-c obstruction computed explicitly. |
| m7 | FIXED | DESIGN §11.6 mandatory negatives and mutation 11; §13.1 | Enrolled `T6-view-swap` as a mandatory typed-to-detyped reject-preservation transcript owned by `M-detype-view-orientation`. |
| m8 | FIXED | DESIGN §9.6 | Added `pauli_sampler`, `tilde_S_intro`, and `graph_sampler` to the mandatory output-sampler PROVE coverage. |
| m9 | FIXED | DESIGN §11.4; definitions §H IntroAnswerEncoding | Attributed the Q-bit wire format to gt-08 L525–L531 and separated it from the actual 3Q guard repair. |
| m10 | FIXED | DESIGN §12 heading | Named the two non-executed layers in the title. |
| m11 | FIXED | definitions §H | Added the `anchored_repeat` row with pre-anchoring input and exactly one anchoring/detyping step. |

## N1: the weaker statement and the unmeasured cost

The selected route is the critic's explicit failed `toy_child_fuel` alternative, not the λ-increase route.  The source timeout is literal at [gt-08 L419–L421](../ground-truth/gt-08-introspection.tex); its runtime hypothesis is separate from the description-size condition.  Both fixtures keep their source λ and all previously adjudicated mathematical parameters.  Their supplied toy budget is `F_child=65,536`, giving failed production equalities `65,536=4` and `65,536=16`.  An exact-R boundary test remains mandatory independently of honest toy acceptance, with the same red boundary test repeated at F_child.

No metered TB6 quoted interpreter or compiled child exists in the current implementation.  Consequently the requested N1(c) exact honest costs cannot truthfully be supplied as numbers in this documentation repair.  DESIGN §11.6 prints all ten fixture/mode slots—Dimension, Marginal, Factor, Linear, and child decider for each fixture—beside R and F_child as `NOT_EVALUABLE(owner=tb6-child-meter)`.  The corresponding fit and source-runtime results are also NOT_EVALUABLE, never PASS.  This is the explicit downgrade of the acceptance claim: C14 asserts no source-fuel acceptance, and toy acceptance cannot receive PASS before the exact traces fit F_child.  A completed measurement is not inferred from `4^8=65,536`.

This follows [rk-light law 5](/home/tobias/.claude/skills/rk-light/SKILL.md): “Default to the DOWNGRADE whenever a fix offers ‘downgrade or prove more’.”  Owner `tb6-child-meter`, tracked under existing issue `mipstar-lambda-9w7`, retains the exact-cost implementation and stronger source-fuel acceptance obligation.  C14 remains an unmerged CONJECTURE proposal on HOLD for critic adjudication; no executable success is claimed here.

## Arithmetic and scope checks

- E: `R=4^1=4`, `M=2`, `Q=2`, embedding `2≥1`; `R≥4` and `s≤R` pass, while `M≥R` and `Q≥R` fail.  Canonical equality still fails: `ceil(log2 log2 4)=1`, and q=2 would require c=0 instead of the required positive even c≥2.  Type/edge counts remain 34/116, detyped dimension 142, and Hide length 6.  One-bit child answers make Read length 5, leaving exactly 10 Hide-incident oriented pairs at the literal boundary.
- M: `R=4^2=16`, `M=4`, `Q=12`, embedding `12≥6`; `R≥4` and `s≤R` pass, while `M≥R` and `Q≥R` fail.  q=8 is an odd-degree binary extension and 2 divides 8.  Canonical equality fails because exponent 3 would force c=1; at that forbidden c, the largest power of two ≤5 is m=4, while the least allowed c=2 gives m=8.  Either contradicts m=2.  Counts remain 38/128, dimension 179, Hide length 36, literal rejection count 22, and `dm/q=1/4`.  No paper parameter changed on the fuel-override route.
- TB7 retains `s_0=9`, `M_I=2`, `Q_I=2`, and `3Q_I=6`.  The source's required embedding is impossible, independently of the repaired length comparator.  Levels remain `9→5→7→9` and dimensions `206→840→848→1696`.  Non-Pauli tests print `VACUOUS(owner=Q_I<s_0)`; actual-D1 `enu:ar-game` prints `NOT_EXECUTED(owner=pcpverifier-D1-trace)`.  Pauli-typed local tests retain their own applicable outcomes.
- The 520 positive/diagnostic M transcripts and existing wall/memory budgets are unchanged; `T6-view-swap` belongs to the already budgeted owned negative set.  TB7 now has eleven named mutations, including `M7-intro-schema`.

## Claim merge state and verification

DESIGN §13.3 now records C12, C13, and C15 as **MERGED**, citing [claims/CLAIMS.md](../claims/CLAIMS.md), where all three are still CONJECTURE.  C15 already contains the authorized `C12,C13,C14` dependencies and both non-executed layers.  Only amended C14 remains a paste proposal.  The authorized N1 and N2 additions appear in the C14 and C15 “Missing steps” bullets; the accepted C12/C13 requirements and DD-23–DD-30 remain.

Independent Python arithmetic and document checks passed: fixture capacities/counts/dimensions, literal rejection counts, canonical-m obstruction, unchanged TB7 dimension chain, all 13 response rows, eleven TB7 mutations, merged claim states, and all 36 theorem labels covered by the residue inventory.  The DESIGN prefix before §9 and claims/src/test/ground-truth/verdict files match pre-edit hashes.  The broader lane audit detected 19 changed files under docs/analytic during the session; none was a target of this repair's writes, and those concurrent changes were left untouched.  Julia, git, executable tracer bullets, and their mutations were not run; the new mutation and cost-report requirements are design obligations, not claimed test results.
