# Claims DAG — mipstar-lambda

Status legend: PROVED (adversarially verified derivation) · TESTED (machine-checked on explicit instances, red-capable) · SKETCH (derivation written, not yet verified) · CONJECTURE · REFUTED (kept as negative result).
Statuses move UP only via a converged verdict in `verdicts/`. Author may move them DOWN at any time.

| id | statement (quantifiers included) | status | depends-on | where-proved | where-tested | verdict |
|----|----------------------------------|--------|------------|--------------|--------------|---------|
| C1 | For the explicit instance in `test/instances/`, the constructed low-degree PCP proof Π=(g₁..g₅,c₀..c_{m'}) is accepted by `pcpverifier` (fig:pcpverifier) at EVERY z∈F_q^{m'} (exhaustive when feasible, else at ≥10⁴ uniformly sampled z with the exhaustive check on a sub-instance). | CONJECTURE | C2,C3,D1 | — | — | — |
| C2 | (Zero-basis certificate) For c₀ built as in the completeness proof of thm:pcp-decider, the multilinearization rewrite produces c₁..c_{m'} with c₀ = Σᵢ cᵢ·zero(zᵢ) as a POLYNOMIAL IDENTITY (checked by coefficient comparison, not sampling), and the multilinear remainder is the zero polynomial iff the witness satisfies φ_C. | CONJECTURE | D1 | — | — | — |
| C3 | (Degree/dependency report) g_i are multilinear in block x_i only; F_arith has individual degree ≤2; c₀ has individual degree ≤3; each c_j has individual degree ≤3. Structural (derivation-tree) bounds and actual support-computed degrees AGREE on the explicit instance. | CONJECTURE | D1 | — | — | — |
| C4 | (Sampler is CL) L_Point, L_ALine, L_DLine as implemented are 1-, 2-, 3-level CL functions BY CONSTRUCTION (inductive datatype), and on a small (q,m) the induced distributions μ_{L_ALine,L_Point}, μ_{L_DLine,L_Point} equal the axis-line/diagonal-line-vs-point distributions of lem:alnf / lem:dlnf (exact histogram comparison). The PCP sampler is the product of six such and is 3-level. | CONJECTURE | D2 | — | — | — |
| C5 | (Soundness vs low-degree proofs) If Π is a low-degree PCP proof (ind. degree ≤ d) accepted w.p. > 1/2 over uniform z, then (thm:pcp-decider item 4) holds, with the Schwartz–Zippel bounds (2+5d)m'/q and (2+d)m'/q as in the paper. Derivation tree to be produced; NOT numerically established. | SKETCH | C2 | — | n/a | — |
| C6 | (Toy diagnostic) For the recursive midpoint protocol of handoff §"diagnostic toy example", optimal cheating acceptance probability for a false claim is exactly 1−2^{−n}. | CONJECTURE | — | — | — | — |
| C7 | (Structural hypothesis, handoff §"Broader structural question") The reusable object is an algebra 𝒬 of CL question distributions closed under Introspect, PCPCompose, ×; low-degree PCPs fit because affine restrictions, random-point tests, and products preserve CL-ness. | CONJECTURE | C4 | — | n/a | — |
| N1 | (Negative) Naive sequential/parallel repetition of the midpoint protocol needs Θ(2ⁿ) repetitions to reach constant gap and therefore cannot serve as a compression step. | CONJECTURE | C6 | — | — | — |
| C8 | (Refutation candidate, docs/findings.md F1) For the NW19 Tseitin transformation arithmetized along the formula tree, deg_v(F_arith) ≤ 2(1+fanout(v)) and this is attained: for the 2-gate circuit g1=x1∧x2, g2=w1∧x3 the formal individual degree of w1 in F_arith is exactly 4 > 2, contradicting prop:tseitin-arith-degree as stated. Surviving statement: c₀ has individual degree ≤ 1+2(1+fanout_max); thm:pcp-decider holds with (2+5d)m' replaced by (2(1+fanout_max)+5d)m' and d ≥ 1+2(1+fanout_max). | CONJECTURE | — | docs/findings.md F1 | — | — |

## Definitions referenced
- D1: the symbolic term language for polynomials, circuits, and PCP proofs — `docs/DESIGN.md` §Poly, §Circuit
- D2: the CL-function / sampler IR — `docs/DESIGN.md` §Sampler
