# Brief 03 — Midpoint toy: exact optimal cheating probability (claims C6, N1)

You are the proposer (gpt-5.6-sol, xhigh). Work fully autonomously; do not ask questions. Your lane: `toys/midpoint/` ONLY (create it). Standalone Julia 1.12, stdlib only (Test, Random). Do not read or depend on docs/DESIGN.md (being written concurrently); this rung will be re-homed later.

## Ground truth
`handoff.md` §"A diagnostic toy example": the recursive midpoint protocol for the claim y = f^{2^n}(x); at each level the prover supplies z and the verifier checks, with probability 1/2 each, ONE of z = f^{2^{n−1}}(x) or y = f^{2^{n−1}}(z); at n=0 the verifier tests y = f(x) directly. Handoff claims: perfect completeness; for a FALSE claim the optimal acceptance probability is exactly p_n = 1 − 2^{−n}.

## Deliverables (red/green TDD: write `test.jl` FIRST, run it, show it red, then implement)
1. `toys/midpoint/midpoint.jl`:
   - The protocol as DATA: a tiny explicit term IR (structs, no macros, no `Expr`): `Test(pred)`, `Ask(k)` (prover supplies a value, k is a continuation), `Coin(t1,t2)` (verifier picks one uniformly), and a fixed-point construction producing the level-n protocol term from the handoff's Y-term. Include a pretty-printer so the term for n=2 can be printed as a trace.
   - An exact evaluator `value(term, prover)` and an exact OPTIMAL-prover evaluator `optval(term)` over a finite domain: rational arithmetic (`Rational{BigInt}`), maximizing over the prover's choice at every `Ask`, averaging at every `Coin`. Brute force is fine for the domain sizes below.
   - `completeness(f, x, n)` returning the honest value (must be 1).
2. `toys/midpoint/test.jl` (uses Test; must exit nonzero on failure; no bare `@assert`):
   - For f(t) = (t+1) mod N and f(t) = (3t+1) mod N with N ∈ {5, 8}, all x, all false y, n = 0..5: `optval == 1 − 2^{−n}` EXACTLY (rational equality), and honest value == 1 for the true y.
   - A test that `optval` for the true claim is 1.
   - A "naive amplification" test: r independent repetitions (verifier accepts iff all accept) have optimal cheating value (1−2^{−n})^r exactly (product, since optimal prover can play optimally per repetition independently — state whether this needs an argument and give it in a comment; if you cannot justify independence, compute the sequential-repetition value exactly by DP instead and test THAT), and print the r needed for value ≤ 1/2 for n = 1..8, exhibiting Θ(2^n) growth (test: r(n+1)/r(n) → 2 within tolerance for n ≥ 4).
3. `toys/midpoint/mutations/` with a runner `run.jl` that applies each mutation on a COPY of `midpoint.jl` in a temp dir and asserts that `test.jl` exits NONZERO for it. Mutations (at least): (M1) Coin checks BOTH subclaims (value should change); (M2) prover cannot choose z (fixed z = x) ; (M3) off-by-one in the exponent 2^{n−1} → 2^n.
4. `toys/midpoint/PROOF.md`: a Lamport-style hierarchical proof (numbered steps ⟨1⟩1, ⟨2⟩1, …; explicit ASSUME/PROVE) that optval_n(false) = 1 − 2^{−n} for every f, x, n and every false y, over any domain, with the sharp upper bound (at least one subclaim is false) and the matching strategy. State exactly what the tests check vs what the proof covers (the tests are finite instances; the proof is general).

Run everything; report actual outputs (copy the test summary lines and the r(n) table). If something fails, say so verbatim. Final message ≤ 20 lines.
