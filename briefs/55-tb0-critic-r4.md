# Brief 55 — CRITIC verdict r4 on rung TB0 after repair r4 (brief 49) — closing round

You are the adversarial critic (Opus). ATTACK; do not summarize. Autonomous; no questions. Lane: write `verdicts/tb0-r4.md` ONLY; Julia/files only under scratch; never edit repo files; no state-changing git. Evaluate the ARCHIVED tree at commit `44160d1` (`git archive 44160d1 | tar -x -C <scratch>/tree`; instantiate there; cold precompile ~100–200 s). Never read src/test from the live tree (another worker edits it).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb0-r4/`

## Read order
`~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `claims/CLAIMS.md` C1 (CONJECTURE — the promotion target), C2, C3, C8 (TESTED; pointer cells re-pointed by the orchestrator for the line shifts listed in `briefs/49-tb0-repair-r4.last.md`); `verdicts/tb0-r3.md` (your prior — the work order: N8–N12, N7 partial); `briefs/49-tb0-repair-r4.md`, `briefs/49-tb0-repair-r4.last.md` (response table, runner lines, the C1 MERGE PROPOSAL with the r3 corrections applied, the "unresolved" notes incl. that DESIGN §5 edits landed in the orchestrator's fcd5113); `docs/DESIGN.md` §3, §5; ground truth as in brief 36.

## Obligations
- **Run** suite (summary + TB0 wall, quiet re-run per the caveat) and runner (`MUTATION REGISTRY` line, all KILLED, baselines ok). Run `tools/cold_precompile.sh` once and report its figure.
- **Adjudicate** N8–N12 and N7: ACCEPTED / REJECTED / PARTIAL. Re-run your r3 disarm scenario (separator at O3) on a copy — the unmutated target must now go red and mutant B must be UNATTRIBUTABLE. Re-run the borrowed-certificate probe (witness (iii) with witness (i)'s certificate → `:certificate_binding`). Verify `encoding_checks` covers all of GF(8)^m for m=1,2,3 (8/64/512) and 512 seeded GF(2^11) points.
- **Two NEW semantic mutations**; survivors are MAJOR with the red test as FIX DEMAND.
- **Pointer audit**: every where-tested cell of C1 (proposed), C2, C3, C8 resolves to the assertion it names in the archived tree.
- **Certificate honesty, lockstep (DESIGN §5 vs code vs CLAIMS), elegance** per the template. Note the two evidence-binding regimes (identity in `build_pcp`, proof-addressed in `change_field`) — objection or elegance note, your call.

## Output: `verdicts/tb0-r4.md`
Adjudication table; recomputations; new objections; runs + walls; your mutations; per-claim decision: C1 PROMOTE/HOLD with the AUTHORIZED verbatim row (pointer cells updated to the archived tree's line numbers), C2/C3/C8 re-affirm or withdraw; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
