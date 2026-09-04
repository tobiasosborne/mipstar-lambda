# Findings against the ground truth (orchestrator log; each becomes a claim row and is verified by a rung + critic)

## F1 — possible discrepancy: prop:tseitin-arith-degree (individual degree ≤ 2) vs. the NW19 Tseitin transformation as we read it (our reading may be wrong)
Source: `ground-truth/gt-10-answer-reduction.tex` prop:tseitin-arith-degree says "every variable in F occurs at most twice, and therefore F_arith has individual degree 2", citing NW19 Def 3.27/3.28. The NW19 definition (`ground-truth/nw19/nw19-tseitin-arith.tex`) is
  z_i := (g_i(x,w) ∧ w_i) ∨ (¬g_i(x,w) ∧ ¬w_i),   F := z_1 ∧ … ∧ z_s,
arithmetized along the formula tree (∨ via De Morgan, ∧ ↦ ×, ¬ ↦ 1−·).
Hand computation (orchestrator, 2026-09-03): the arithmetization of a formula tree is multilinear in its LEAF OCCURRENCES, so deg_v(F_arith) ≤ #occurrences of v in the tree. In z_i, w_i occurs twice and every input variable of g_i occurs twice. Hence over the whole F:
  occ(w_i) = 2 + 2·fanout(gate i),   occ(x_j) = 2·fanout(input j).
Example: g1 = x1∧x2, g2 = w1∧x3. z1 = 1 − g − w + gw + g²w + gw² − g²w² with g=x1x2, w=w1: coefficient of w1² is (g − g²) ≠ 0 formally, so deg_{w1}(z1)=2; similarly deg_{w1}(z2)=2 (g'=w1x3 enters squared); F_arith = z1·z2 has deg_{w1} = 4 (leading coefficients multiply in an integral domain).
Surviving weaker statement: deg_v(F_arith) ≤ 2(1+fanout_max); with copy gates enforcing fanout ≤ 2 (at most doubling s) this is ≤ 6, so c₀ has individual degree ≤ 7 and the Schwartz–Zippel bounds become (6+5d)m'/q and (2+d)m'/q — the theorem survives with changed constants provided d ≥ 7, which the paper's d = k ≥ 11 satisfies. Also note the ind.-degree-3 statement for c₀ in the completeness proof of thm:pcp-decider inherits the error.
Status: CONJECTURE (C8) until TB0 computes actual individual degrees of a real Tseitin arithmetization and a critic recomputes.

## F2 — NW19's Tseitin formula omits the output constraint
`F := z_1 ∧ … ∧ z_s` constrains w to be the wire values but does not assert the output wire is 1, so "C(x)=1 iff ∃w F(x,w)=1" fails as written (F is satisfiable for every x). The MIP*=RE def:tseitin states the contract, not the construction, so implementations must add the conjunct w_out (one more occurrence of w_out: occ = 3 + 2·fanout). Status: NOTE; handled in the IR by construction (TB0 Tseitin includes the output literal).
