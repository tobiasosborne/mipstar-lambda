# Brief 11 — REPAIR round r2 for docs/DESIGN.md + docs/definitions.md (work order = verdicts/design-r2.md)

You are the proposer (gpt-5.6-sol, xhigh). Work fully autonomously; do not ask questions; do not run git. Lane: `docs/DESIGN.md`, `docs/definitions.md`, new `docs/design-repair-r2-response.md` ONLY. Do NOT edit claims/, src/, test/ (a TB0 worker owns src/ and test/; put any instruction for it under "DIRECTIVES FOR TB0" in the response file).

Read: `~/.claude/skills/rk-light/SKILL.md` law 5; `verdicts/design-r2.md` in full (R1–R3 MAJOR, R4+ minor/notes, the HOLD reasons for C3 and C5, the AUTHORIZED rows for C1, C2, C4, C8); `docs/design-repair-r1-response.md`; current docs.

Address every R-objection with a response-table row (id → FIXED/RETRACTED/DOWNGRADED/RESIDUE, exact section). Binding orchestrator directives:
- R1: make the six-predicate report consistent between §2 and §5; TB0-small's P_growth = FAIL as the critic derived; state predicates 2 and 4 evaluability honestly once, in one place, and cite it elsewhere.
- R2: regrade the `(deg_F + 5d)m'/q < 1/2` node as an EXTRA obligation `P_formula_structural` (not a def:pcpparams consequence); include the critic's absorption sentence (fan-out bounded via copy gates ⇒ deg_F ≤ 2·fanout_max+3, so d ≥ … suffices) as the surviving statement; keep the literal-2 predicate as the paper's, tagged SOURCE_REPAIR(C8).
- R3: the TB0 fixture keeps BOTH witnesses: (i) the degenerate one (g₂..g₅ ≡ 0; fast; disclosed as degenerate, with the quotient relation named); (ii) a NON-degenerate witness with every g_i non-constant (choose one of the 512 with a_i ≠ constant for all i, or if none exists, say so and change the circuit minimally — prefer changing the witness over the circuit). The critic measured ≈1,773,072 monomials for a non-degenerate c₀: set MonomialBudget for (ii) at 2,500,000 with the sentence that this is a MEASURED figure to be confirmed by TB0, and require TB0 to report time and peak memory; C3's block-dependency evidence must come from (ii), never (i). Amend §5.1 items and the mutation owners accordingly.
- Apply the authorized row texts for C1, C2, C4, C8 into a "MERGE PROPOSALS (authorized verbatim by design-r2)" section — the orchestrator will paste them; add your amended C3 and C5 proposals answering the HOLD reasons exactly.
- All minor/notes: fix or downgrade.
Final message ≤ 10 lines: disposition counts, any RESIDUE with reason, and the chosen non-degenerate witness.
