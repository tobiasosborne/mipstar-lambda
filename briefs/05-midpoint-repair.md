# Brief 05 — REPAIR round r1 for toys/midpoint (work order = verdicts/midpoint-r1.md)

You are the proposer (gpt-5.6-sol, xhigh). Work fully autonomously; do not ask questions. Lane: `toys/midpoint/` and the new file `toys/midpoint/repair-r1-response.md` ONLY. Do NOT edit claims/CLAIMS.md (write your proposed row text for C6/N1 in a "MERGE PROPOSAL" section of the response file instead). Do not run git.

Read: `~/.claude/skills/rk-light/SKILL.md` (law 5: downgrade over ambition); `briefs/03-midpoint-toy.md`; `verdicts/midpoint-r1.md` (the work order, in full); the current `toys/midpoint/*`.

Address EVERY objection O1–O14. For each, one row in `repair-r1-response.md`: objection id → FIXED / RETRACTED / DOWNGRADED / RESIDUE, with the exact file:line of the edit. Specifically:
- O1: add the critic's red block (or stronger); move the honest witness and memo out of the term (a term is data, a strategy is separate); ensure the nine mutants the critic lists are killed by the suite. Add them to `mutations/run.jl` as M4…M12 (each on a COPY).
- O2: model sequential AND-repetition exactly: an adaptive cross-copy DP with the prover choosing z in copy i as a function of the verifier's coins in copies < i; test that its value equals p^r for n ≤ 4, r ≤ 4 exactly; state measurability/independence argument in PROOF.md as a numbered step. Label any parallel-repetition statement as UNTESTED unless you implement the lockstep game (one z per level for all copies simultaneously is NOT the right model — think; if unsure, restrict N1 to sequential repetition and say so).
- O3: prove 2^n ln 2 − ln 2 ≤ r(n) ≤ 2^n ln 2 + 1 (or the critic's bound) in PROOF.md, test it exactly for n ≤ 12 (no atol), and write the cost-model sentence for "cannot serve as a compression step" (verifier work scales as r(n)·O(n) = Θ(n 2^n) vs the single-run O(n)).
- O4: add the sharp hypothesis (orbit prefix {f^k(x): k ≤ 2^n} ⊆ D) to the theorem, add the critic's counterexample as a test that the theorem's HYPOTHESIS fails there (not as a passing "value" test), and use `sup` over prover strategies for infinite D.
- O5–O14: fix or downgrade; broken LaTeX in PROOF.md must be fixed ($…$ math).
Run `julia toys/midpoint/test.jl` and `julia toys/midpoint/mutations/run.jl` from the repo root; paste summaries into the response file. Final message ≤ 15 lines: disposition table counts and anything left as RESIDUE.
