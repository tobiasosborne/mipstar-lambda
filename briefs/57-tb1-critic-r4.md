# Brief 57 — CRITIC verdict r4 on rung TB1 after repair r3 (brief 54) — closing round

You are the adversarial critic (Opus). ATTACK; do not summarize. Autonomous; no questions. Lane: write `verdicts/tb1-r4.md` ONLY; Julia/files only under scratch; never edit repo files; no state-changing git. Evaluate the ARCHIVED tree at commit `<SHA>` (`git archive <SHA> | tar -x -C <scratch>/tree`; instantiate there; cold precompile 100–200 s). Never read src/test from the live tree (another worker edits it); `claims/CLAIMS.md` may be read live (orchestrator-owned).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb1-r4/`

## Read order
`~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `docs/DESIGN.md` §1.5, §9 (as amended for brief 54); `claims/CLAIMS.md`; `verdicts/tb1-r3.md` (your prior — the work order); `briefs/54-tb1-tb2-repair-r3.md`, `briefs/54-tb1-tb2-repair-r3.last.md` (response table, runs, MERGE PROPOSALS incl. the scope edits and, for TB1, the new C4c row; the two flagged judgment calls: the encoder needed no change, and the in-chain empty-register terminal rule).

## Obligations
- **Run** suite (summary + TB0 wall; quiet re-run per the caveat) and runner (`MUTATION REGISTRY` line; all KILLED; baselines ok).
- **Adjudicate** every r3 row for this rung: ACCEPTED / REJECTED / PARTIAL.
- **Independent recomputation on a COPY:** decode_cl round trip on all 3 maps x 8^5 seeds; the separator pair (L_Point vs the V_coord(+)V_dir projector, 75 bytes each, distinct); the stage-1 matrix byte window 41:65; tb1_prefix_walk KILLED makes map_sum_ok red-capable — re-run your NM8 comparison→true probe: is it now caught?; the :ld_honest_sweep CHECKED node replay (tamper off_line_hits=1 → rejected); pad_level of CLZero(F,5,Int[]) → [[1..5],[],[]] and the in-chain empty terminal rule — adjudicate the DESIGN §9.4 rule the proposer wrote as a design decision. Disagreement with the report is MAJOR.
- **Two NEW semantic mutations**; survivors are MAJOR with the red test as FIX DEMAND.
- **Per-claim:** C4a (re-affirm with the brief-54 scope edits) and the proposed NEW row C4c (D^ld) — AUTHORIZED verbatim row text (the proposer's proposed text is a proposal; you decide the wording), or HOLD with the missing step.
- **Forward look (≤ 6 lines):** with the serializer now injective and round-tripping, what must TB5's `SamplerDescription`/description-level `direct_sum` preserve (byte format, hashing, dependency sets) — NOTEs for brief 39.

## Output: `verdicts/tb1-r4.md`
Adjudication table; recomputations; new objections; runs + walls; your mutations; per-claim block; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
