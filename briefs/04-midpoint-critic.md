# Brief 04 — CRITIC verdict r1 on toys/midpoint (claims C6, N1)

You are the adversarial critic (Opus). ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `/home/tobias/Projects/discussions/verdicts/midpoint-r1.md` ONLY. Run Julia freely, but any files you create go under `/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-0dce-432d-85cc-272c91280792/scratchpad/critic-midpoint-r1/` (create it). Never edit repo files other than your verdict.

Read order: `~/.claude/skills/rk-light/SKILL.md`; `/home/tobias/Projects/discussions/handoff.md` §"A diagnostic toy example"; `claims/CLAIMS.md` rows C6, N1; `briefs/03-midpoint-toy.md`; `briefs/03-midpoint-toy.last.md`; then the target `toys/midpoint/{midpoint.jl,test.jl,mutations/run.jl,PROOF.md}`.

Obligations:
1. Run `julia toys/midpoint/test.jl` and `julia toys/midpoint/mutations/run.jl` (from the repo root) and paste the summary lines.
2. Recompute independently: write your OWN ≤40-line Julia brute-force for V_n(x,y) for f(t)=(3t+1) mod 8, n=0..4, all x,y, and compare to `optval`. Any mismatch is FATAL.
3. Attack PROOF.md step by step: quantifiers (is D allowed infinite? is `max` a `sup`?), the claim that a Coin/Ask value lies in [0,1], the sequential-AND-repetition bound in the test.jl comment (lines ~55–64): is "conditional acceptance of copy i ≤ p given the past" actually justified for an ADAPTIVE prover across copies with shared randomness? State the precise argument or the counterexample.
4. Write at least two NEW mutations (semantic) on a copy and check the suite goes red; if a construction-breaking mutation stays green, MAJOR with the red test to add.
5. Does the term IR actually represent the handoff's Y-term Y(λr f n x y. if n=0 then Test(y=f(x)) else Ask(λz. Coin (r f (n−1) x z)(r f (n−1) z y)))? Is the fixed point explicit or is recursion smuggled in via Julia recursion? NOTE-level unless misrepresented.
6. Elegance: three concrete simplifications.

Output format: numbered objections (FATAL/MAJOR/MINOR/NOTE · location · your computation · FIX DEMAND · SURVIVING WEAKER STATEMENT); observed test/mutation summaries; per-claim recommendation for C6 and N1: PROMOTE to TESTED / PROMOTE to PROVED / HOLD (name the missing step). Final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
