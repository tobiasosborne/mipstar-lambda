# Brief 35 — CRITIC verdict r3 on DESIGN v2 (docs/DESIGN.md §9–13, docs/definitions.md §G–H) after repair r2

You are the adversarial critic (Opus). ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/design-v2-r3.md` ONLY. Create files only under the scratch dir below; never edit repo files. Evaluate the ARCHIVED tree at commit `dd4cf82` (`git archive dd4cf82 | tar -x -C <scratch>/tree`).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-design-v2-r3/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `claims/CLAIMS.md` (C12, C13, C15 are now CONJECTURE rows you authorized in r2; C14 is on HOLD).
2. `verdicts/design-v2-r2.md` (your prior: N1, N2 MAJOR, m1–m11, §4 C14 HOLD conditions). Treat it as the work order; do NOT re-litigate O1–O10 (ACCEPTED in r2) or anything r2 confirmed.
3. `briefs/34-design-v2-repair-r2.md` (binding orchestrator directives), `briefs/34-design-v2-repair-r2.last.md`, `docs/design-v2-repair-r2-response.md` (FIXED 12 / DOWNGRADED 1).
4. The ground truth cited by N1/N2: `ground-truth/gt-08-introspection.tex` L419–L421, L525–L531, L983–L988; `gt-05-games-normalform.tex` L641–L653; `gt-07-ldt.tex` def:introparams. Recompute; never from memory.
5. The target: `docs/DESIGN.md` §9–13 (incl. §13.3) and `docs/definitions.md` §G–H.

## Obligations
- **Adjudicate every response-table row** (N1, N2, m1–m11): ACCEPTED / REJECTED (exact residual defect) / PARTIAL. The N1 DOWNGRADE: is the "explicit failed fuel-override route" (F_child=65,536 printed as `toy_child_fuel=FAIL(owner=tb6-child-meter)`, honest costs NOT_EVALUABLE) a faithful weaker statement under rk-light law 5, or an escape that lets TB6b print PASS somewhere it should not? grep §11.6, §12.4, §13.3 C14 for any PASS that depends on an unmeasured cost.
- **N2**: is `VACUOUS(owner=Q_I<s_0)` printed for EVERY non-Pauli TB7 schema, and does the §12.4 general rule ("a paper-parameter guard that stops admitting the honest witness at toy size prints VACUOUS/FAIL with an owner") now cover O2, N1, N2 uniformly? Check that the §12 heading and C15's "Missing steps" name both non-executed layers.
- **Arithmetic recheck** of the response's §"Arithmetic and scope checks" (E: R=4, M=2, Q=2, 10/116; M: R=16, M=4, Q=12, 22/128, canonical-m obstruction c=1→m=4, c=2→m=8; TB7 levels 9→5→7→9, dims 206→840→848→1696). Disagreement is MAJOR.
- **Lockstep**: DESIGN §13.3 says C12/C13/C15 MERGED — confirm CLAIMS.md rows match the authorized r2 text verbatim (law 1: no status wording beyond CONJECTURE). definitions §G SOURCE_REPAIR widening and §H new rows (anchored_repeat, IntroAnswerEncoding) consistent with DESIGN.
- **New objections** only if MAJOR and genuinely new; number N3, N4, ….
- **C14**: AUTHORIZED (verbatim CONJECTURE row text the orchestrator may paste) or HOLD (missing step named).
- **Implementation readiness**: the next rung is TB5 (Repeat: anchoring + parallel repetition, DESIGN §10, `briefs/` has none yet). State in ≤10 lines whether §10 + §13.1 give an implementer everything needed for TB5 without further design rounds; name any gap as a NOTE.

## Output: `verdicts/design-v2-r3.md`
Per-row adjudication table; recomputations in full; new objections with severity/location/computation/FIX DEMAND/SURVIVING WEAKER STATEMENT; the C14 AUTHORIZED/HOLD block; TB5 readiness block; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
