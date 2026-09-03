# Brief 08 — CRITIC adjudication r2 on docs/DESIGN.md + docs/definitions.md

You are the adversarial critic (Opus), round 2. Work fully autonomously; do not ask questions. Lane: write `/home/tobias/Projects/discussions/verdicts/design-r2.md` ONLY; scratch under `/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-0dce-432d-85cc-272c91280792/scratchpad/critic-design-r2/`.

Read: `~/.claude/skills/rk-light/SKILL.md` (adjudication rules: r1 is your prior; verify each disposition by fresh recomputation; attack only changed text; do not re-litigate what passed); `verdicts/design-r1.md`; `docs/design-repair-r1-response.md`; `briefs/06-design-repair.md` (orchestrator directives); `git -C /home/tobias/Projects/discussions diff da54528 HEAD -- docs/DESIGN.md docs/definitions.md`; then the current files; ground truth as needed.

Obligations:
1. For each of M1–M13, m14–m24, and the NOTEs: VERIFIED / NOT VERIFIED with your recomputation.
2. Recompute the TB0 fixture in §5 from scratch (write your own ≤60-line Julia over Q or GF(8)): the circuit's present-clause count (128/896), witness count (512), the occurrence vector (2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3), the actual individual-degree vector of F_arith and of c₀ (the design claims equality with the occurrence vector — is that TRUE for NOT gadgets? a NOT gadget z = (¬a ∧ w) ∨ (a ∧ ¬w): check the formal degree in a and in w), the value F_arith(b_ρ) = ρ⁴(1+ρ), the normalized monomial count of c₀ (measure it; the design says ≤148,176 pre-normalization), and whether mutation B ("remove g₂−o₂") is really killed at b_ρ with O2=ρ. Any mismatch is MAJOR.
3. Check the six def:pcpparams predicates as now written against `gt-10-answer-reduction.tex` def:pcpparams, and the k=11 minimality arithmetic.
4. Check that the new fig:decider-pcp transcription (M13) matches the ground truth guard-by-guard, that `detype` (M11) and `Hole` (M7) are coherent, and that the Grade enum (M9) is used consistently in every table.
5. New text only: at most 5 new objections, each with FIX DEMAND and SURVIVING STATEMENT.
6. Adjudicate the MERGE PROPOSALS for claim rows in the response file: authorize exact row text or HOLD with the missing step.

Final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
