# Repair r1 response — midpoint toy

The repair follows rk-light law 5: N1 is restricted to the proved and tested
sequential statement; exact parallel repetition is explicitly **UNTESTED**.
No claim status is promoted by this proposer.

## Objection dispositions

| objection | disposition | exact edit location | response |
|---|---|---|---|
| O1 | FIXED | `toys/midpoint/test.jl:18`; `toys/midpoint/mutations/run.jl:31`; `toys/midpoint/midpoint.jl:24` | Added the critic's red block (with a guard-compatible direct freedom test), made term data contain only domain plus continuation, and added M4–M12. All nine new mutants and M1–M3 are killed. |
| O2 | FIXED | `toys/midpoint/midpoint.jl:258`; `toys/midpoint/test.jl:107`; `toys/midpoint/PROOF.md:122` | Added an exact adaptive cross-copy sequential AND DP, exact tests for $n\le4,r\le4$, and the numbered transcript-measurability/fresh-coin argument at `PROOF.md:134`. Parallel repetition is labeled UNTESTED at `PROOF.md:153`. |
| O3 | DOWNGRADED | `toys/midpoint/PROOF.md:162`; `toys/midpoint/test.jl:127`; `toys/midpoint/PROOF.md:200` | Proved both requested logarithmic bounds, tested them through $n=12$ using rigorous rational enclosures and no tolerance, supplied the cost model, and restricted proposed N1 to sequential repetition. |
| O4 | FIXED | `toys/midpoint/PROOF.md:7`; `toys/midpoint/midpoint.jl:127`; `toys/midpoint/test.jl:62` | The theorem now uses the sharp orbit-prefix hypothesis, the constructor enforces it, and the critic's counterexample is tested only as a failed hypothesis. The proof's optimum is a supremum. |
| O5 | FIXED | `toys/midpoint/PROOF.md:12`; `toys/midpoint/PROOF.md:16`; `toys/midpoint/PROOF.md:114` | Defined adaptive deterministic strategies, public coins, randomized-strategy conditioning, and a supremum over strategies; proved attainment. |
| O6 | FIXED | `toys/midpoint/midpoint.jl:156`; `toys/midpoint/test.jl:40` | Exercised the live domain guard with `@test_throws`; M8 deletes it and is killed. |
| O7 | FIXED | `toys/midpoint/midpoint.jl:317`; `toys/midpoint/test.jl:44` | The printer takes a separate strategy and the test pins exactly 3 Ask, 3 Coin, and 4 Test nodes; M9 drops branch 2 and is killed. |
| O8 | FIXED | `toys/midpoint/midpoint.jl:24`; `toys/midpoint/midpoint.jl:37`; `toys/midpoint/midpoint.jl:233` | Removed `honest`, `fixed`, labels, and cache keys from the term; honest moves now live in a separate `Strategy`. M10 corrupts that strategy and is killed. |
| O9 | FIXED | `toys/midpoint/midpoint.jl:193`; `toys/midpoint/test.jl:53` | Evaluator memoization keys on continuation identity; a composed cross-domain regression catches aliasing, and M11 is killed. |
| O10 | FIXED | `toys/midpoint/PROOF.md:7` | Rewrote the proof with valid `$...$` and display-math delimiters throughout. |
| O11 | FIXED | `toys/midpoint/midpoint.jl:84`; `toys/midpoint/midpoint.jl:111` | Identified the fixed point as call-by-value/Z-style and passed $f,D,x,y,n$ through the body state rather than capturing $f,D$ in the body. |
| O12 | FIXED | `toys/midpoint/midpoint.jl:331`; `toys/midpoint/test.jl:152`; `toys/midpoint/PROOF.md:200` | Added all-path transcript profiles, `rounds`, and `queries`; tested shape $(n,n,1)$ and stated the unit-cost consequence $\Theta(n2^n)$. |
| O13 | FIXED | `toys/midpoint/test.jl:164` | Added the DESIGN-aligned bottom-up table on $\mathbb Z/17\mathbb Z$, all pairs and $0\le n\le8$: 2601 exact checks. |
| O14 | RESIDUE | `toys/midpoint/repair-r1-response.md:32` | Lane rules prohibit editing `claims/CLAIMS.md`; exact unpromoted replacement rows are supplied in MERGE PROPOSAL below. |

## MERGE PROPOSAL

Replace the C6 and N1 rows in `claims/CLAIMS.md` verbatim with:

| id | statement (quantifiers included) | status | depends-on | where-proved | where-tested | verdict |
|----|----------------------------------|--------|------------|--------------|--------------|---------|
| C6 | (Toy diagnostic) For every set $S$, every nonempty $D\subseteq S$, every $f:S\to S$, every $n\in\mathbb N$, and all $x,y\in D$ satisfying $\{f^k(x):0\le k\le2^n\}\subseteq D$, the level-$n$ recursive midpoint protocol (the prover chooses freely in $D$ at each Ask and sees each selected Coin branch before the next Ask) has optimal acceptance probability $1$ if $y=f^{2^n}(x)$ and exactly $1-2^{-n}$ otherwise. | CONJECTURE | — | `toys/midpoint/PROOF.md` ⟨1⟩2 | `toys/midpoint/test.jl` | `verdicts/midpoint-r1.md` (HOLD; r1 repair submitted) |
| N1 | (Negative; sequential only) For every $n\ge1$ and every false midpoint claim satisfying C6, adaptive $r$-copy sequential AND repetition has optimal acceptance probability $(1-2^{-n})^r$. The least $r(n)$ making this at most $1/2$ obeys $2^n\ln2-\ln2\le r(n)\le2^n\ln2+1$, hence $r(n)=\Theta(2^n)$; under the stated unit-cost transcript model amplification costs $\Theta(n2^n)$ rather than the single run's $O(n)$ and cannot serve as a compression step. No parallel-repetition claim is made. | CONJECTURE | C6 | `toys/midpoint/PROOF.md` ⟨1⟩3–⟨1⟩6 | `toys/midpoint/test.jl` | `verdicts/midpoint-r1.md` (HOLD; r1 repair submitted) |

## Requested run summaries

`julia toys/midpoint/test.jl` — exit 0:

```text
Test Summary:                                    | Pass  Total  Time
term IR, red optimum block, and exact evaluators |   12     12  1.5s
Test Summary:                 | Pass  Total  Time
sharp orbit-prefix hypothesis |    7      7  0.4s
Test Summary:                    | Pass  Total  Time
exhaustive exact midpoint values | 1380   1380  3.2s
adaptive sequential AND values
n=1 r=1..4: 1//2, 1//4, 1//8, 1//16
n=2 r=1..4: 3//4, 9//16, 27//64, 81//256
n=3 r=1..4: 7//8, 49//64, 343//512, 2401//4096
n=4 r=1..4: 15//16, 225//256, 3375//4096, 50625//65536
Test Summary:                      | Pass  Total  Time
adaptive sequential AND repetition |   20     20  0.7s
r(n) for sequential cheating value <= 1/2
n  r(n)
1  1
2  3
3  6
4  11
5  22
6  45
7  89
8  178
9  355
10  710
11  1420
12  2839
Test Summary:                                     | Pass  Total  Time
exact repetition threshold and logarithmic bounds |   48     48  0.2s
Test Summary:         | Pass  Total  Time
transcript cost model |   18     18  1.2s
Z/17Z bottom-up exact assertions: 2601
Test Summary:         | Pass  Total  Time
Z/17Z bottom-up table | 2601   2601  0.5s
```

`julia toys/midpoint/mutations/run.jl` — exit 0:

```text
M1 killed (exit 1): Coin checks both subclaims
M2 killed (exit 1): prover cannot choose z (each Ask is fixed to its left endpoint)
M3 killed (exit 1): honest midpoint uses 2^n instead of 2^(n-1)
M4 killed (exit 1): N-P: Ask domain collapsed to the honest midpoint
M5 killed (exit 1): N-Q: Ask evaluator replays one fixed move instead of maximizing
M6 killed (exit 1): N-T: optval evaluates a fixed strategy instead of optimizing
M7 killed (exit 1): N-U: Ask domain is only the orbit of x, ignoring caller domain
M8 killed (exit 1): N-F: value accepts an out-of-domain prover message
M9 killed (exit 1): N-G: pretty-printer drops Coin branch 2
M10 killed (exit 1): N-J: separate honest strategy chooses the claim endpoint
M11 killed (exit 1): O9: evaluator memo aliases distinct Ask/domain nodes
M12 killed (exit 1): O2: sequential game stops after one accepted copy
Test Summary:           | Pass  Total     Time
midpoint mutation suite |   12     12  1m56.5s
```
