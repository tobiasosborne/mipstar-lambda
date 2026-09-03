# Brief 07 — CRITIC adjudication r2 on toys/midpoint (claims C6, N1)

You are the adversarial critic (Opus), round 2. Work fully autonomously; do not ask questions. Lane: write `/home/tobias/Projects/discussions/verdicts/midpoint-r2.md` ONLY; scratch files under `/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-0dce-432d-85cc-272c91280792/scratchpad/critic-midpoint-r2/`.

Read: `~/.claude/skills/rk-light/SKILL.md` (adjudication round rules: treat r1 as prior, verify each claimed disposition by fresh recomputation, attack only what changed, do not re-litigate what passed); `verdicts/midpoint-r1.md` (your prior); `toys/midpoint/repair-r1-response.md`; then `git -C /home/tobias/Projects/discussions diff b6fa4e9 HEAD -- toys/midpoint` for the exact delta; then the current files.

Obligations:
1. Run `julia toys/midpoint/test.jl` and `julia toys/midpoint/mutations/run.jl` from the repo root; paste summaries.
2. For each O1–O14: verify the disposition by recomputation (e.g. for O2 write your own adaptive cross-copy DP for n ≤ 3, r ≤ 3 and compare exactly; for O4 confirm the counterexample is now a hypothesis-failure test; for O3 check the bounds 2^n ln2 − ln2 ≤ r(n) ≤ 2^n ln2 + 1 exactly for n ≤ 12 and read the proof step by step). Mark each VERIFIED / NOT VERIFIED (with why).
3. Attack any NEW text (PROOF.md rewrites, new evaluators) for new errors; at most two new mutations on a copy.
4. Adjudicate the MERGE PROPOSAL rows for C6 and N1 in `repair-r1-response.md`: for each, PROMOTE (to which status: TESTED = finite instances machine-checked and red-capable; PROVED = the general Lamport proof survives your line-by-line check) or HOLD naming the missing step. Write the exact row text you authorize (the proposer will copy it verbatim).

Output: numbered dispositions, any new objections (with severity, location, computation, FIX DEMAND, SURVIVING STATEMENT), the authorized claim rows, final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
