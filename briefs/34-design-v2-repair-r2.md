# Brief 34 — REPAIR round r2 for DESIGN v2 (work order = verdicts/design-v2-r2.md: N1, N2 MAJOR + §4 residual MINOR/NOTES)

You are the proposer (gpt-5.6-sol, xhigh). Work fully autonomously; do not ask questions; do not run git or Julia. Lane: `docs/DESIGN.md` §9–13 (incl. §13.3), `docs/definitions.md`, and a new `docs/design-v2-repair-r2-response.md` ONLY. Do NOT edit claims/, src/, test/, docs/analytic/.

Read: `~/.claude/skills/rk-light/SKILL.md` law 5; `verdicts/design-v2-r2.md` IN FULL (§1 adjudication — everything ACCEPTED stays as is; §3 N1 and N2 with their FIX DEMANDS; §4 residual MINOR/NOTES; §5 the C12–C15 block — the orchestrator has pasted C12, C13, C15 into claims/CLAIMS.md as CONJECTURE, so §13.3 must now describe those rows as MERGED and carry only the amended C14 proposal; §6 the proposed §12.4 rule); `docs/design-v2-repair-r1-response.md`; ground truth `gt-08-introspection.tex` L419–L421 (the `R = N^λ` child-fuel gate), L525–L531, L588–L591; `gt-12-compression.tex` for `s_0`, `Q_I`.

Address every N-objection and every §4 item with a response-table row (id → FIXED / RETRACTED / DOWNGRADED / RESIDUE, section, one line). Binding directives:
- N1: implement the critic's fix demand (a)+(b): declare the child fuel unit explicitly in §11.4; choose λ for TB6b-E and TB6b-M so the honest metered child cost fits `R = N^λ` (the critic's example λ=8 ⇒ R=65,536 — verify with arithmetic that every other TB6b predicate is unchanged; if a smaller λ suffices, show the computation), OR record an explicit failed production predicate `toy_child_fuel` with owner — never both a printed FAIL of the hypothesis and a required PASS of its consequence. Update §11.6 and the C14 proposal in §13.3 accordingly.
- N2: in §12.5 print the non-Pauli introspection answer schemas as `VACUOUS(owner=Q_I<s_0)`; in §13.2 list BOTH non-executed layers (enu:ar-game against the actual D1; the non-Pauli introspection answer schemas at TB7) and delete "the explicit exception"; adopt the critic's §6 general §12.4 rule (a paper-parameter guard that stops admitting the honest witness at toy size must be surfaced as a printed VACUOUS/FAIL predicate with owner) as a numbered DD.
- §13.3: mark C12, C13, C15 MERGED (cite claims/CLAIMS.md), keep the amended C14 proposal with N1's resolution, and apply the two "Missing steps" additions the critic authorized.
- All §4 residual MINOR/NOTES: fix or downgrade with reason.

Report: `briefs/34-design-v2-repair-r2.last.md` (≤ 12 lines): disposition counts, the λ chosen for N1 with the R value and the honest child cost, the N2 wording used.
