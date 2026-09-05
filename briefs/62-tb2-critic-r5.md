# Brief 62 — CRITIC verdict r5 on rung TB2 after repair r4 (brief 59) — closing round

You are the adversarial critic (Opus). ATTACK; do not summarize. Autonomous; no questions. Lane: write `verdicts/tb2-r5.md` ONLY; Julia/files only under scratch; never edit repo files; no state-changing git. Evaluate the ARCHIVED tree at commit `<SHA>` (`git archive <SHA> | tar -x -C <scratch>/tree`; instantiate there; cold precompile ~190 s). Never read src/test from the live tree; `claims/CLAIMS.md` may be read live.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb2-r5/`

Read: `~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `docs/DESIGN.md` §1.5, §9; `claims/CLAIMS.md`; `verdicts/tb2-r4.md` (your prior — the work order); `briefs/59-tb1-tb2-repair-r4.md`, `briefs/59-tb1-tb2-repair-r4.last.md` (response table, runs, MERGE PROPOSALS, the two judgment calls: N25 throw branch; NF2 eighth replay case not taken).

Obligations: run suite (summary + TB0 wall; quiet re-run per caveat — note the suite is now 907 assertions and the TB0 body sits at ~40 s quiet; the gate is a test-body budget) and runner (`MUTATION REGISTRY` line; all KILLED; baselines ok). Adjudicate every r4 row: ACCEPTED / REJECTED / PARTIAL. Recompute on a COPY: the decider/enumerator lockstep over all 2916 ordered pairs (mismatches=0; the step-4(b) widening mutant gives mismatches=12); step-1 rejection of entries 1/6/7/22 on the five equal-type copy-6 pairs (20/20; the first-entry mutant 5/20); the seven-case replay left unchanged (C9 wording) — is the arity-22 fact adequately owned outside the certificate?. Two NEW semantic mutations; survivors MAJOR with the red test as FIX DEMAND. Per-claim: C4b, C9 (re-affirm with the brief-59 scope edits) — AUTHORIZED verbatim row text. This is intended as the closing round for this rung: if no MAJOR remains, say PASS and list residual MINOR/NOTE items for the record without demanding another round.

Output: `verdicts/tb2-r5.md` — adjudication table; recomputations; new objections; runs + walls; your mutations; per-claim block; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
