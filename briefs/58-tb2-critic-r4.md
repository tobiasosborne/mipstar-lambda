# Brief 58 — CRITIC verdict r4 on rung TB2 after repair r3 (brief 54) — closing round

You are the adversarial critic (Opus). ATTACK; do not summarize. Autonomous; no questions. Lane: write `verdicts/tb2-r4.md` ONLY; Julia/files only under scratch; never edit repo files; no state-changing git. Evaluate the ARCHIVED tree at commit `<SHA>` (`git archive <SHA> | tar -x -C <scratch>/tree`; instantiate there; cold precompile 100–200 s). Never read src/test from the live tree (another worker edits it); `claims/CLAIMS.md` may be read live (orchestrator-owned).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb2-r4/`

## Read order
`~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `docs/DESIGN.md` §1.5, §9 (as amended for brief 54); `claims/CLAIMS.md`; `verdicts/tb2-r3.md` (your prior — the work order); `briefs/54-tb1-tb2-repair-r3.md`, `briefs/54-tb1-tb2-repair-r3.last.md` (response table, runs, MERGE PROPOSALS incl. the scope edits and, for TB1, the new C4c row; the two flagged judgment calls: the encoder needed no change, and the in-chain empty-register terminal rule).

## Obligations
- **Run** suite (summary + TB0 wall; quiet re-run per the caveat) and runner (`MUTATION REGISTRY` line; all KILLED; baselines ok).
- **Adjudicate** every r3 row for this rung: ACCEPTED / REJECTED / PARTIAL.
- **Independent recomputation on a COPY:** decode_cl round trip on all 18 PCP maps over the 36-seed chain set incl. factor_spaces; the 18 byte strings pairwise distinct and copy-6 ByAxis tables with 16 distinct children; NE1 KILLED; the four-number split (2736,180,107,92,54,53) and tb2_guard_split; replay_seeds at three seeds (21 pairs) — note the certificate replay in answer_reduce.jl still runs at the zero seed (lane); no TB2 certificate carries :zero_map_factor_partition and no described stage has an empty factor register. Disagreement with the report is MAJOR.
- **Two NEW semantic mutations**; survivors are MAJOR with the red test as FIX DEMAND.
- **Per-claim:** C4b and C9 (re-affirm with the brief-54 scope edits) — AUTHORIZED verbatim row text (the proposer's proposed text is a proposal; you decide the wording), or HOLD with the missing step.
- **Forward look (≤ 6 lines):** with the serializer now injective and round-tripping, what must TB5's `SamplerDescription`/description-level `direct_sum` preserve (byte format, hashing, dependency sets) — NOTEs for brief 39.

## Output: `verdicts/tb2-r4.md`
Adjudication table; recomputations; new objections; runs + walls; your mutations; per-claim block; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
