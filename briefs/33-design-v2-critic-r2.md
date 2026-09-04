# Brief 33 — CRITIC verdict r2 on DESIGN v2 (docs/DESIGN.md §9–13, docs/definitions.md §H) after repair r1

You are the adversarial critic. ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/design-v2-r2.md` ONLY. Create files only under the scratch dir below; never edit repo files. Evaluate the ARCHIVED tree at the commit named in your launch message (`git archive <sha> | tar -x -C <scratch>/tree`).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/03b2c3d3-f2b5-4e3b-8e73-afff562cb7ae/scratchpad/critic-design-v2-r2/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `claims/CLAIMS.md`.
2. `verdicts/design-v2-r1.md` (your prior: O1–O10 MAJOR, the MINOR list, NOTES, R(a)–R(d), MERGE adjudication, C12–C15 recommendation). Treat it as the work order; do NOT re-litigate what r1 passed or what r1 confirmed.
3. `briefs/31-design-v2-repair.md` (the orchestrator's binding directives) and `briefs/31-design-v2-repair.last.md`; `docs/design-v2-repair-r1-response.md` (the response table: FIXED 32 / RETRACTED 1 / DOWNGRADED 2 / RESIDUE 0).
4. The ground truth the r1 objections cite; recompute from `ground-truth/gt-*.tex`, never from memory.
5. The target: `docs/DESIGN.md` §9–13 (incl. §13.3 MERGE PROPOSALS) and `docs/definitions.md`.

## Obligations
- **Adjudicate every response-table row**: for each O1–O10 and each MINOR/NOTE, state ACCEPTED / REJECTED (with the exact residual defect) / PARTIAL. A row marked FIXED whose fix does not actually meet the r1 FIX DEMAND is REJECTED. Check the RETRACTED and DOWNGRADED rows especially: is the retraction/downgrade justified by the ground truth, or is it an escape?
- **O2 recomputation**: the proposer chose full-`Q` encoding and reject only when `> 3Q`. Recompute from `gt-08-introspection.tex` L424–L425 and L588–L591 whether the honest Hide answer length under THAT encoding is accepted by `> 3Q` and rejected by the literal `≥ 3Q`; check the printed rejection count promised in C14's new wording is computable.
- **O3/O4 recomputation**: TB6b-M `ell=3, s=6, (q,m,d)=(8,2,1)`: recompute the dimension chain and the Pauli/intro type counts for this fixture; verify that `enu:hiding-same`'s index set is non-empty (so the adaptive schedule runs), that `L^alice ≠ L^bob`, and that the `< 25 s` estimate has arithmetic behind it (state sizes, number of transcripts). Check the mutations M6-factor-prefix, M6-game, M-factor-partition, M-detype-view-orientation each now have a named killer transcript.
- **O5**: `P_pcp_encodes_D1 = FAIL` and `enu:ar-game = NOT_EXECUTED`: is this honestly surfaced in §12.4/§13.1 and in the C15 wording, with no sentence anywhere in §9–13 still implying content-faithful end-to-end execution? grep for "end-to-end", "honest accepts", "16".
- **O1**: is the def:sampler well-formedness replay present in `LawCert` AND in the output contract of every transformation (downsize, detype, anchor, repeat, product, Pauli, introspection)? List each.
- **O6**: recompute exhaustiveness of the CITED residue: grep every `lem:`/`thm:`/`prop:` label cited in §9–13 and check each is either in §13.2's list or is a construction (not a soundness) label.
- **O10, O2**: definitions.md rows for SOURCE_REPAIR(intro-3Q-guard) and SOURCE_REPAIR(intro-decider-fixed-width) exist and are consistent with DESIGN.
- **Lockstep**: DESIGN ↔ definitions ↔ the proposed C12–C15 rows in §13.3; any status wording a proposer may not use (law 1).
- **New objections** only if MAJOR and genuinely new (not reachable from r1); number them N1, N2, …
- **MERGE PROPOSALS**: adjudicate §13.3 rows for C12–C15 as AUTHORIZED (verbatim row text the orchestrator may paste into claims/CLAIMS.md as CONJECTURE) or HOLD (missing step named).

## Output: `verdicts/design-v2-r2.md`
Per-row adjudication table (O1–O10, MINORs, NOTEs → ACCEPTED/REJECTED/PARTIAL + one line); your recomputations in full; new objections N* with severity, location, computation, FIX DEMAND, SURVIVING WEAKER STATEMENT; the C12–C15 AUTHORIZED/HOLD block; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)` where PASS means no open FATAL/MAJOR.
