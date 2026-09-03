# Verdict r2 — CRITIC adjudication on `toys/midpoint/` (claims C6, N1)

Critic: Opus (adversarial, round 2 — adjudication). Prior: `verdicts/midpoint-r1.md`
(FAIL(O1,O2,O3,O4)). Target delta: `git diff b6fa4e9 HEAD -- toys/midpoint`
(679 insertions / 249 deletions across `midpoint.jl`, `test.jl`, `mutations/run.jl`,
`PROOF.md`, `repair-r1-response.md`).

Scope discipline (rk-light "later rounds"): I treat r1 as prior, verify each claimed
disposition by **fresh recomputation**, attack only text that changed, and do not
re-litigate what already passed. Critic scratch under
`/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-0dce-432d-85cc-272c91280792/scratchpad/critic-midpoint-r2/`
(`indep_single.jl` 44 L, `indep_seq.jl` 62 L, `rn2.jl` 39 L, `xcheck.jl` 21 L,
`mutate.jl` 40 L). No repo file other than this verdict was touched; both new mutants
were applied to COPIES in `mktempdir`.

---

## 0. Observed runs (obligation 1) — verbatim summaries

`julia toys/midpoint/test.jl` from repo root — **exit 0**:

```text
Test Summary:                                    | Pass  Total  Time
term IR, red optimum block, and exact evaluators |   12     12  1.5s
Test Summary:                 | Pass  Total  Time
sharp orbit-prefix hypothesis |    7      7  0.5s
Test Summary:                    | Pass  Total  Time
exhaustive exact midpoint values | 1380   1380  3.2s
adaptive sequential AND values
n=1 r=1..4: 1//2, 1//4, 1//8, 1//16
n=2 r=1..4: 3//4, 9//16, 27//64, 81//256
n=3 r=1..4: 7//8, 49//64, 343//512, 2401//4096
n=4 r=1..4: 15//16, 225//256, 3375//4096, 50625//65536
Test Summary:                      | Pass  Total  Time
adaptive sequential AND repetition |   20     20  0.8s
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
transcript cost model |   18     18  0.9s
Z/17Z bottom-up exact assertions: 2601
Test Summary:         | Pass  Total  Time
Z/17Z bottom-up table | 2601   2601  0.5s
```

(4086 assertions total. The `n=2` term trace printed by the first testset is elided here; it
shows both branches at every `Coin`. Everything above matches `repair-r1-response.md` exactly.)

`julia toys/midpoint/mutations/run.jl` from repo root — **exit 0**, 1 m 56.8 s:

```text
M1  killed (exit 1): Coin checks both subclaims
M2  killed (exit 1): prover cannot choose z (each Ask is fixed to its left endpoint)
M3  killed (exit 1): honest midpoint uses 2^n instead of 2^(n-1)
M4  killed (exit 1): N-P: Ask domain collapsed to the honest midpoint
M5  killed (exit 1): N-Q: Ask evaluator replays one fixed move instead of maximizing
M6  killed (exit 1): N-T: optval evaluates a fixed strategy instead of optimizing
M7  killed (exit 1): N-U: Ask domain is only the orbit of x, ignoring caller domain
M8  killed (exit 1): N-F: value accepts an out-of-domain prover message
M9  killed (exit 1): N-G: pretty-printer drops Coin branch 2
M10 killed (exit 1): N-J: separate honest strategy chooses the claim endpoint
M11 killed (exit 1): O9: evaluator memo aliases distinct Ask/domain nodes
M12 killed (exit 1): O2: sequential game stops after one accepted copy
Test Summary:           | Pass  Total     Time
midpoint mutation suite |   12     12  1m56.5s
```

The proposer's reported summaries reproduce **exactly**. No summary inflation.

---

## 1. Independent recomputation (obligation 2 core)

**(a) Single-copy optimum — `indep_single.jl`.** Plain tree recursion in
`Rational{BigInt}`, *no memo, no DAG, no hash-consing*, sharing no code with the repo, so the
prover may play a different `z` at the same `(x,y,n)` claim in different transcripts:

```text
N ∈ {5,7,8};  f ∈ {t+1, 3t+1, t²+2, 2t} mod N  (two of these are NON-injective);
x ∈ D, n = 0..4, all y ∈ D
indep single-copy: checked=2760 mismatches=0
```

All 2760 values equal `1` (true claim) or `1−2^{−n}` (false claim). Combined with the
repo's own 1380 + 2601 exact assertions, **the C6 numbers are confirmed on three
independent implementations** (my tree recursion, the repo's term/DAG evaluator, the
DESIGN-style bottom-up table).

**(b) Sharp orbit-prefix hypothesis — same file.** `f(t)=t+1 mod 5`, `D={0,1,2}`
(**not** `f`-closed: `f(2)=3∉D`):

```text
n=1, orbit prefix {0,1,2} ⊆ D :  V(0,0)=1/2   V(0,1)=1/2   V(0,2)=1        (= p_1 / 1)
n=2, orbit prefix {0,1,2,3,4} ⊄ D : V(0,0)=1/2  V(0,1)=3/4  V(0,2)=3/4     (≠ p_2 uniformly)
```

So the r1 counterexample is a genuine **hypothesis failure**, not a value failure, and the
orbit-prefix condition really is weaker than `f`-closure. Note every value at `n=2` is still
`≤ 3/4`, corroborating the orbit-free upper bound (⟨1⟩2 statement 1).

**(c) Adaptive cross-copy sequential AND — `indep_seq.jl`, two independent methods.**

*Method A* — raw game tree, **no memoisation whatsoever**, so the prover is adaptive across
copies and within copies by construction (`N=3,n≤3`; `N=4,5,n≤2`; `r≤3`, all false `y`):

```text
N=3 n=1 y=0 r=1,2,3  A = 1/2, 1/4, 1/8       = p^r
N=3 n=2 y=2 r=1,2,3  A = 3/4, 9/16, 27/64    = p^r
N=4 n=1 y=3 r=1,2,3  A = 1/2, 1/4, 1/8       = p^r
N=4 n=2 y=1 r=1,2,3  A = 3/4, 9/16, 27/64    = p^r
N=5 n=1 y=3 r=1,2,3  A = 1/2, 1/4, 1/8       = p^r
N=5 n=2 y=0 r=1,2,3  A = 3/4, 9/16, 27/64    = p^r
(N=3, n=3, r≤3: no mismatch printed)
```

*Method B* — bottom-up table over the whole domain parameterised by the payoff `c` collected
at an accepting leaf, iterated over copies (`N∈{5,7}`, `n≤4`, `r≤5`, all false `y`): **zero
mismatches against `p^r`**. Method B also supplies a one-line *independent proof* for this
protocol: the value recursion (`max`, average) is positively homogeneous in the leaf payoffs,
so playing one copy with continuation payoff `c` has value `c·p`; hence `A_r = p·A_{r−1}`,
`A_0 = 1`.

*Cross-check of the repo's own DP* — `xcheck.jl`, `sequential_and_optval` vs `p^r` for
`N∈{5,7}`, `n=1..4`, `r=0..4`, all false `y`: **mismatches = 0**.

**(d) `r(n)` and the logarithmic bounds — `rn2.jl`, 400-bit `BigFloat` + exact rationals,
independent of the repo's rational `ln 2` series:**

```text
n   r(n)   2^n ln2 − ln2   2^n ln2 + 1   lo≤r   r≤hi
1   1      0.69315         2.38629       true   true
2   3      2.07944         3.77259       true   true
3   6      4.85203         6.54518       true   true
4   11    10.39721        12.09035       true   true
5   22    21.48756        23.18071       true   true
6   45    43.66827        45.36142       true   true
7   89    88.02969        89.72284       true   true
8   178  176.75253       178.44568       true   true
9   355  354.19821       355.89136       true   true
10  710  709.08957       710.78271       true   true
11  1420 1418.87228     1420.56543       true   true
12  2839 2838.43770     2840.13085       true   true
n=1..12 both bounds hold: true
r(n) == ceil(ln2 / −ln p) for n=1..12: true
n=13..60 (closed form): bounds hold: true
repo ln2 enclosure: lo ≤ ln2  true;  ln2 ≤ hi  true;  width 1.23e−17
```

The printed `r(n)` table in the repo matches mine digit for digit through `n=12`, the closed
form `⌈ln2/(−ln p)⌉` agrees at every `n`, and both bounds of ⟨1⟩5 hold (verified out to
`n=60`). The repo's rational enclosure of `ln 2` really does bracket `ln 2` — see O16 for the
one thing that is *not* pinned.

---

## 2. Dispositions O1–O14 (obligation 2)

| id | claimed | my disposition | basis |
|---|---|---|---|
| O1 | FIXED | **VERIFIED** | The r1 red block is in `test.jl:18-56` (R1 `optval(bad)==1` vs `value(bad,Strategy(_->0))==0`; R2 root-domain identity; R3 restricted-domain strict inequality on a direct `Ask`; R4 `@test_throws` on the guard; R5 3/3/4 node counts). The four r1 survivors are now permanent mutants M4 (N-P), M5 (N-Q), M6 (N-T), M7 (N-U) and all four are killed in my own run. R3 was re-expressed on a synthetic `Ask` pair rather than on `midpoint_protocol` — a **necessary** adaptation, since the new orbit-prefix guard (O4) refuses to build the `D=[0,1,3,4]` term I used in r1; the discriminating power is preserved by R1+R2, which is what actually kills M4–M7. I additionally confirmed by mutation X2 (§3) that deeper `Ask` domains, which R2 does *not* inspect, are still pinned by the exhaustive value block. |
| O2 | FIXED | **VERIFIED** | `sequential_and_optval` (`midpoint.jl:236-274`) is a real adaptive cross-copy DP over `(x,y,n,copies_after)`, not a restatement of `p^r`; `test.jl:107-125` checks it against `p^r` for `n≤4, r≤4` (20 assertions); M12 (restart deleted) is killed. `PROOF.md` ⟨1⟩3 now carries the numbered transcript-measurability / fresh-coin argument. My Methods A and B (§1c) reproduce every value exactly and my `xcheck.jl` reproduces the repo function's outputs. The r1 lockstep violation ("checks … exact AND repetition through level 8") is gone: ⟨1⟩7.⟨2⟩1-⟨2⟩4 now describe the suite accurately (I checked each scope sentence against the code — 1380 = 2·5·6·7 + 2·8·6·10 ✓, 20 ✓, 48 ✓, 18 ✓, 2601 ✓). |
| O3 | DOWNGRADED | **VERIFIED** (with residue, see O15/O16/O17) | ⟨1⟩5 proves both bounds; I read it step by step and re-derived each: `r(n)=⌈ln2/(−ln p)⌉` ✓ (min integer `r` with `r·(−ln p) ≥ ln 2`); `ε ≤ −ln(1−ε) ≤ ε/(1−ε)` ✓; `r ≥ ln2·(1−ε)/ε = (2^n−1)ln2` ✓; `r ≤ ln2/ε + 1 = 2^n ln2 + 1` ✓. The `atol=0.06` ratio test is gone, replaced by exact `p^r ≤ 1/2 < p^{r−1}` plus rational-enclosure inequalities, verified independently for `n≤12` (§1d). "parallel" is removed from the proposed N1 row and ⟨1⟩4 states the non-claim explicitly. The cost model exists (⟨1⟩6 + `rounds`/`queries`/`transcript_profiles` + `test.jl:152-162`). |
| O4 | FIXED | **VERIFIED** | `_validated_choices` (`midpoint.jl:122-134`) enforces `x,y ∈ D` **and** `{f^k(x):0≤k≤2^n} ⊆ D`; `xcheck.jl` confirms `midpoint_protocol(t↦t+1 mod 5, [0,1,2], 0, 0, 2)` now raises `ArgumentError("orbit prefix through f^(2^n)(x) must lie in the domain")`. `test.jl:62-79` asserts the counterexample as a **hypothesis failure** (`!orbit_prefix_in_domain`, `@test_throws`) and then exercises the sharp hypothesis on the same non-`f`-closed `D={0,1,2}` at `n=1`, where the repo returns `(0,1/2),(1,1/2),(2,1)` — identical to my independent values. ⟨1⟩1.⟨2⟩6 records the sharp hypothesis and its strictness. |
| O5 | FIXED | **VERIFIED** | ⟨1⟩1.⟨2⟩2 defines the strategy space (map from public transcript ending at an `Ask` to `D`; coin revealed before the next `Ask`; adaptivity across sequential copies), ⟨2⟩3 uses **supremum** and disposes of randomised provers by conditioning, ⟨2⟩4 justifies branch-independent continuations, and ⟨1⟩2 statement 3 + ⟨3⟩3.⟨4⟩4 prove **attainment**. Every `max` that mattered is now a `sup`. |
| O6 | FIXED | **VERIFIED** | `test.jl:41-42` `@test_throws ArgumentError value(guarded, Strategy(_ -> 99))`; M8 (guard deleted) killed in my run. |
| O7 | FIXED | **VERIFIED** | `test.jl:49-51` pins exactly 3 `Ask`, 3 `Coin`, 4 `Test`; M9 (branch-2 dropped) killed. The printed trace in my run shows both branches at every `Coin`. |
| O8 | FIXED | **VERIFIED** | `FiniteContinuation` now carries only `domain` and `next` (`midpoint.jl:24-31`); `honest`, `fixed`, `cache_key`, `label` are gone; the witness lives in a separate `Strategy` built by `honest_strategy`. M10 (corrupt the separate strategy) killed. `mutable struct` is the right choice here — it is what makes `IdDict` keying by object identity sound (an immutable struct with equal fields would alias under `===`). |
| O9 | FIXED | **VERIFIED** | `_optval` keys an `IdDict` on `term.k` (`midpoint.jl:186-193`), i.e. on continuation identity, not on a hand-written tuple; `test.jl:53-56` composes two `Ask` nodes with different domains under one `Coin` and requires `1/2`; M11 (`key = typeof(term)`) killed. |
| O10 | FIXED | **VERIFIED** | `PROOF.md` uses `$…$` and `$$…$$` throughout; no stripped `\(…\)` remains. |
| O11 | FIXED | **VERIFIED** | `FixedPoint` is commented as "a concrete call-by-value (Z-style) fixed point" (`midpoint.jl:77-80`) and the body signature is `(::MidpointYTerm)(self, state)` with `(; f, domain, x, y, n) = state`, so `f` and `D` flow through the state rather than being captured — the handoff's `λ r f n x y` shape. |
| O12 | FIXED | **VERIFIED** | `transcript_profiles` / `rounds` / `queries` (`midpoint.jl:326-369`); `test.jl:152-162` asserts `transcript_profiles == {(n,n,1)}`, `rounds == n`, `queries == 1` for `n=0..5`; `xcheck.jl` reproduces `(n, rounds, queries) = (0,0,1),(1,1,1),…,(5,5,1)`. ⟨1⟩6 states the consequence. |
| O13 | FIXED | **VERIFIED** | `test.jl:164-187` is the DESIGN §5.2 bottom-up table on `Z/17Z`, `n=0..8`, all `17×17` pairs — 2601 exact assertions in 0.5 s, matching my r1 `tb05.jl` figure exactly. This is now the second, structurally different oracle I asked for in E3. |
| O14 | RESIDUE | **VERIFIED as correct lane behaviour** | The proposer did not touch `claims/CLAIMS.md` and supplied MERGE PROPOSAL rows instead. That is exactly rk-light lane discipline. The authorized rows are in §4 below. |

**Score: 14/14 dispositions VERIFIED.** No claimed fix failed re-check; no disposition was
overstated.

---

## 3. Attack on the new text (obligation 3) — two new mutants, on copies

`mutate.jl`, each applied to a `mktempdir` copy of *both* files:

```text
[X1 ln2 enclosure inverted (lo/hi swapped)]                SURVIVED (GREEN)
[X2 deep Ask domains collapsed to the orbit of x]          killed (exit 1)
```

X2 is the residual hole I expected from R2 (which inspects only the *root* `Ask`'s domain): I
restricted every **non-root** `Ask` to `unique(orbit_prefix(f,x,n))` while leaving the root
domain intact. It dies on `test.jl:101` (`optval(false_term) == expected`) in the exhaustive
block. **No new objection.** X1 is O16 below.

I also read the whole of the new `PROOF.md` line by line. New objections follow; none is
FATAL or MAJOR.

---

### O15 · MINOR · `repair-r1-response.md` N1 MERGE ROW; `PROOF.md:200-206` (⟨1⟩6) — "cannot serve as a compression step" is still not derivable inside this repo

`docs/definitions.md:133,150` define `Compress = Repeat ∘ AnswerReduce ∘ Introspect` acting on
**descriptions of λ-bounded MIP\* verifiers** (`lambda`: description length `≤ λ`, runtime
`≤ n^λ`). The toy is a classical interactive proof about `f`-iteration; it instantiates no
`λ`, no sampler, no nonlocal game, and therefore nothing in `toys/midpoint/` can discharge a
statement *about* `Compress`. r1's O3(iii)/O12 asked for "a verifier cost measure … or delete
the clause"; the cost measure landed and makes the *cost* statement sayable
(`r(n)·Θ(n) = Θ(n2^n)` vs `Θ(n)`), but the inference "⇒ cannot serve as a compression step"
is a bridge with no formal span. Promoting it would be silent strengthening at the exact
summary moment rk-light law 5 warns about.

**FIX DEMAND.** Strike the clause from the N1 row (done in my authorized row, §4) and change
`PROOF.md` ⟨1⟩6's last sentence from "in this cost model it therefore cannot serve as a
compression step" to: "in this cost model amplification is exponentially more expensive than
a single run; no claim is made about the `Compress` operator of `docs/definitions.md`, which
this toy does not instantiate." File the struck clause as a tracked residue to be ratcheted
back only when a toy carries a `λ`-bounded description-size measure.

**SURVIVING STATEMENT.** *In the unit-cost transcript model of ⟨1⟩6, sequential amplification
of the midpoint protocol to error `≤ 1/2` costs `Θ(n2^n)` against `Θ(n)` for one run. Whether
this rules the protocol out as a `Compress` ingredient is not established here.*

---

### O16 · MINOR · `test.jl:9-15, 141-142` — the rigorous `ln 2` enclosure is itself unpinned; inverting it stays GREEN

Both bound assertions are deliberately *strengthened* forms:
`(2^n−1)·ln2_hi ≤ r` implies the claim only if `ln2_hi ≥ ln 2`, and
`r ≤ 2^n·ln2_lo + 1` implies the claim only if `ln2_lo ≤ ln 2`. Nothing tests either
direction. My mutant **X1** replaces `return lower, lower + tail_upper` by
`return lower + tail_upper, lower` — so `ln2_lo > ln 2 > ln2_hi`, both inequalities become
*strictly weaker* than the claimed ones, and the suite is **green**. (Two sanity notes: a
*wrong constant*, e.g. `2^n·ln2_hi ≤ r`, is correctly killed at `n=1`; and halving `ln2_lo`
is killed by the upper assertion. The hole is exactly the swap/undershoot direction.) A
second structural point: `ln2_interval` lives in `test.jl`, which `mutations/run.jl` copies
**unmutated** (`apply_mutation` only edits `midpoint.jl`), so no mutant in the permanent
corpus can ever reach it.

I verified the enclosure is in fact sound (§1d: `lo ≤ ln2 ≤ hi`, width `1.23e−17`), so the
mathematics is unaffected; this is a law-4 red-capability defect, not an error.

**FIX DEMAND.** Add three lines to the `exact repetition threshold` testset. I *tested* these:
they pass on the current code, they kill X1 on all three (the swap makes every one false), and
they are robust for `terms` anywhere in `8..24`.

```julia
# ln 2 = 0.693147180559945309417232121458176568… (independent 30-digit sandwich)
const LN2_LO_REF = BigInt(693147180559945309417232121458) // BigInt(10)^30   # < ln 2
const LN2_HI_REF = BigInt(693147180559945309417232121459) // BigInt(10)^30   # > ln 2
@test ln2_lo <= ln2_hi                # an enclosure must not be inverted
@test ln2_lo <= LN2_LO_REF            # certifies ln2_lo <= ln 2
@test LN2_HI_REF <= ln2_hi            # certifies ln 2 <= ln2_hi
```

Note that a naive version of this fix does **not** work: because the enclosure is only
`1.23e−17` wide, anchors at 15-digit precision (`693147180559945//10^15` and
`693147180559946//10^15`) are satisfied by *both* endpoints and by the swap, so they kill
nothing — I checked. The anchors must be tighter than the enclosure width. Also extend
`mutations/run.jl` so a mutation may target `test.jl` (today `apply_mutation` reads only
`midpoint.jl`) and add X1 as a permanent mutant.

**SURVIVING STATEMENT.** *The `n≤12` bounds are true (independently confirmed at 400-bit
precision, and out to `n=60` from the closed form); the suite's claim to establish them
"with no floating tolerance" rests on unchecked code inside the checker.*

---

### O17 · MINOR · `PROOF.md:200-206` (⟨1⟩6) — the cost paragraph is the one un-Lamport step, and `O(n)` cannot yield `Θ(n2^n)`

⟨1⟩6 is prose: no `ASSUME`/`PROVE`, no `⟨2⟩` sub-steps, and its two ingredients are (i) the
transcript-shape lemma "every root-to-leaf execution of a level-`n` term has exactly `n`
`Ask`, `n` `Coin` and one `Test`", asserted rather than proved (it *is* a two-line induction
on the recursion of ⟨1⟩1.⟨2⟩4, and it is machine-checked only for `n ≤ 5`), and (ii) the
conclusion `r(n)·O(n) = Θ(n2^n)`, which does not follow from an `O(n)` upper bound — a
`Θ(n)` two-sided bound is required (and is true: unit cost gives exactly `2n+2`).

**FIX DEMAND.** Renumber ⟨1⟩6 as `⟨1⟩6 ASSUME … PROVE …` with `⟨2⟩1` the transcript-shape
induction, `⟨2⟩2` the exact per-run cost `2n+2 = Θ(n)`, `⟨2⟩3` the product `r(n)·Θ(n) =
Θ(n2^n)` using ⟨1⟩5. Replace "hence verifier work `O(n)`" by "hence verifier work exactly
`2n+2 = Θ(n)`".

**SURVIVING STATEMENT.** *Every level-`n` transcript has profile `(n,n,1)` (machine-checked
`n≤5`, immediate by induction), so one run costs `Θ(n)` and `r(n)` runs cost `Θ(n2^n)`.*

---

### O18 · MINOR · `repair-r1-response.md` N1 MERGE ROW — the row quantifies `n` but not `r`

"For every $n\ge1$ and every false midpoint claim satisfying C6, adaptive $r$-copy sequential
AND repetition has optimal acceptance probability $(1-2^{-n})^r$" leaves `r` free, in a column
whose header is "statement (**quantifiers included**)". Also `where-proved` for C6 cites
⟨1⟩2 only, although the protocol, the strategy space and the hypothesis `H` are all defined in
⟨1⟩1 — a single-source citation gap (law 2).

**FIX DEMAND.** Use the rows in §4, which bind `r ∈ ℕ` and cite ⟨1⟩1–⟨1⟩2.
**SURVIVING STATEMENT.** *Editorial; the intended statement is the `∀r` one, which is what
⟨1⟩3 proves and what the suite tests for `r ≤ 4`.*

---

### O19 · NOTE · `PROOF.md:22-30` (⟨1⟩1.⟨2⟩4) — a lemma is presented as a definition

⟨2⟩3 defines `V_n` as a supremum over strategies; ⟨2⟩4 then *asserts* the recurrence
`V_n(x,y) = sup_z (V_{n-1}(x,z)+V_{n-1}(z,y))/2` under the heading "The protocol recurrence",
inside the definitions block. That identity is a claim (sup over global strategies factorises
into sup over the first message and independent sups on the two public branches). Its
justification is present — the one sentence about the coin being public is precisely the
reason the two continuations may be optimised independently — so this is a labelling defect,
not a gap. **FIX DEMAND (cosmetic).** Move it to a numbered `⟨2⟩4 PROVE` with the two-line
derivation (`σ ↦ (σ(∅), σ|_{b1}, σ|_{b2})` is a bijection onto `D × Σ_{n−1} × Σ_{n−1}`).

### O20 · NOTE · `midpoint.jl:122-134` vs `PROOF.md:51-52` (⟨1⟩2 statement 1) — the orbit-free half of the theorem is now unreachable from the constructor

The (correct) new guard means the suite can never evaluate a term violating `H`, so statement 1
(`y ≠ f^{2^n}(x) ⇒ V_n ≤ p_n` **without** any orbit hypothesis) — the load-bearing induction
hypothesis of the whole upper bound — has no machine check at all. My independent recursion
does check it (§1b: on `D={0,1,2}`, `n=2`, the values `1/2, 3/4, 3/4` are all `≤ 3/4 = p_2`).
**FIX DEMAND (cheap).** Expose the raw recurrence (or an `unchecked=true` keyword) and assert
`optval ≤ cheating_bound(n)` on a few `H`-violating instances.

### O21 · NOTE · `midpoint.jl:236-274` — cross-copy *adaptivity* is not red-testable, by construction

`sequential_and_optval` memoises on `(x,y,n,copies_after)`, i.e. it assumes the past transcript
is irrelevant to the future subgame. That assumption is *true* here (the remaining game is
identical whatever the history), which is exactly why no instance can separate an adaptive from
a non-adaptive implementation and no mutant can exist for the word "adaptive". The word is
carried by ⟨1⟩3 and by my Method A (a memo-free game tree in which the prover is fully adaptive
by construction), not by the suite. Recorded so the next reader does not mistake M12 for
evidence of adaptivity.

---

## 4. Adjudication of the MERGE PROPOSAL rows (obligation 4)

### C6 — **PROMOTE → `PROVED`**

Basis. (i) `PROOF.md` ⟨1⟩1–⟨1⟩2 is a complete Lamport derivation and it survives my
line-by-line check: strategy space and public-coin convention fixed (⟨1⟩1.⟨2⟩2), value a
supremum with randomised provers reduced by conditioning (⟨2⟩3), `p_n = (1+p_{n−1})/2`
verified (⟨2⟩5), the sharp hypothesis isolated (⟨2⟩6); the three-part simultaneous induction
is correctly designed — statement 1 is deliberately *orbit-free*, which is exactly what
⟨2⟩2.⟨3⟩1.⟨4⟩2 needs, and I confirmed `H(f,D,x,n) ⇒ H(f,D,x,n−1) ∧ H(f,D,f^{2^{n−1}}(x),n−1)`
(the second because `{f^k(f^h(x)) : k ≤ h} = {f^j(x) : h ≤ j ≤ 2^n}`), that
`z=f^h(x) ∧ y=f^h(z) ⇒ y=f^{2^n}(x)` (⟨4⟩1), and that attainment propagates (⟨3⟩3.⟨4⟩4). No
step is missing. (ii) 2760 independently recomputed exact values, zero mismatches, over three
moduli and four `f` including non-injective ones; plus the repo's 1380 + 2601. (iii) The
certificate is red-capable: 12 permanent mutants killed, plus my X2.
Only MINOR/NOTE residue (O19, O20), which per rk-light does not block convergence.

**Authorized row — copy verbatim:**

| id | statement (quantifiers included) | status | depends-on | where-proved | where-tested | verdict |
|----|----------------------------------|--------|------------|--------------|--------------|---------|
| C6 | (Toy diagnostic) For every set $S$, every $f:S\to S$, every $n\in\mathbb N$, every $D\subseteq S$, and all $x,y\in D$ with $\{f^k(x):0\le k\le 2^n\}\subseteq D$: in the level-$n$ recursive midpoint protocol over $D$ (terms `Test`/`Ask`/`Coin` and prover-strategy space as defined in `toys/midpoint/PROOF.md` ⟨1⟩1 — the prover chooses freely in $D$ at each `Ask` and sees the selected `Coin` branch before the next `Ask`; the value is the supremum over deterministic adaptive strategies, which randomized provers cannot exceed), the optimal acceptance probability is $1$ if $y=f^{2^n}(x)$ and exactly $1-2^{-n}$ if $y\ne f^{2^n}(x)$, and in both cases the supremum is attained by a deterministic strategy. Dropping the orbit-prefix hypothesis leaves exactly the upper bound $\le 1-2^{-n}$ for false claims (⟨1⟩2 statement 1); the value $1-2^{-n}$ and perfect completeness both fail without it ($f(t)=t+1 \bmod 5$, $D=\{0,1,2\}$, $n=2$). | PROVED | — | `toys/midpoint/PROOF.md` ⟨1⟩1–⟨1⟩2 | `toys/midpoint/test.jl` (1380 exact values, $\mathbb Z/5,\mathbb Z/8$, two $f$, all endpoints, $n\le5$; 2601 exact values, $\mathbb Z/17$, $n\le8$; sharp-hypothesis and failed-hypothesis blocks); `toys/midpoint/mutations/run.jl` (M1–M12 all killed) | `verdicts/midpoint-r2.md` (PROMOTE) |

### N1 — **PROMOTE → `PROVED`**, with the compression clause STRUCK

Basis. ⟨1⟩3 survives line-by-line: conditioning on private randomness (⟨2⟩1), `T_{<i}` and
`A_i` defined (⟨2⟩2), the two load-bearing facts stated explicitly — `A_1∩⋯∩A_{i−1}` is
`T_{<i}`-measurable and copy `i`'s coins are fresh, giving `Pr[A_i | T_{<i}=t] ≤ p` pointwise
(⟨2⟩3) — and matching attainment (⟨2⟩5). ⟨1⟩5 is correct at every step (§2, O3). All of it is
independently reproduced: Method A (memo-free, fully adaptive game tree), Method B
(payoff-parameterised bottom-up table, plus the homogeneity argument), and `r(n)` to 400-bit
precision. ⟨1⟩4 makes the parallel non-claim explicit, which is the honest downgrade r1 asked
for.

**HOLD applies to one clause only**, and I have removed it rather than holding the whole row:
"and therefore cannot serve as a compression step". **Missing step:** a definition of
"compression step" that this toy can satisfy — `docs/definitions.md:133,150` defines `Compress`
on descriptions of `λ`-bounded MIP\* verifiers, and `toys/midpoint/` instantiates no `λ`, no
sampler and no nonlocal game, so no artifact here can discharge it (O15). Ratchet it back when
a toy carries a description-size / `λ` measure.

**Authorized row — copy verbatim:**

| id | statement (quantifiers included) | status | depends-on | where-proved | where-tested | verdict |
|----|----------------------------------|--------|------------|--------------|--------------|---------|
| N1 | (Negative; **sequential repetition only**) For every $n\ge1$, every instance satisfying the hypotheses of C6 with $y\ne f^{2^n}(x)$, and every $r\in\mathbb N$: adaptive $r$-copy **sequential** AND repetition (copy $i+1$ begins only if copy $i$ accepted; the prover sees the entire earlier public transcript, including all earlier copies' coins; each copy's verifier coins are fresh) has optimal acceptance probability exactly $(1-2^{-n})^r$. Consequently $r(n)=\min\{r\in\mathbb N:(1-2^{-n})^r\le 1/2\}$ satisfies $2^n\ln 2-\ln 2\le r(n)\le 2^n\ln 2+1$, hence $r(n)=\Theta(2^n)$, with $r(1..12)=1,3,6,11,22,45,89,178,355,710,1420,2839$; and in the unit-cost transcript model of `PROOF.md` ⟨1⟩6 (unit charge per `Ask`, `Coin`, `Test`, and per application of $f$), where one level-$n$ run costs exactly $2n+2=\Theta(n)$, amplification to soundness error $\le 1/2$ costs $\Theta(n2^n)$. NO claim is made about parallel repetition (`PROOF.md` ⟨1⟩4), and no claim is made about the `Compress` operator of `docs/definitions.md`, which this toy does not instantiate (`verdicts/midpoint-r2.md` O15). | PROVED | C6 | `toys/midpoint/PROOF.md` ⟨1⟩3–⟨1⟩6 | `toys/midpoint/test.jl` (exact $(1-2^{-n})^r$ from the adaptive cross-copy DP, $1\le n\le4$, $0\le r\le4$; $r(n)$ and both logarithmic bounds by rigorous rational enclosure, $1\le n\le12$, no floating tolerance; transcript profile $(n,n,1)$ for $n\le5$); `toys/midpoint/mutations/run.jl` M12 | `verdicts/midpoint-r2.md` (PROMOTE; "cannot serve as a compression step" struck — O15) |

**Conditions on the promotion.** The two rows above are to be applied verbatim, with no added
sentence. The MINOR fixes O15 (⟨1⟩6 wording), O16 (two `ln 2` enclosure assertions), O17
(renumber ⟨1⟩6, `O(n)` → `Θ(n)`) must land in the same commit as the promotion so that
`PROOF.md` and the DAG stay in lockstep; O19–O21 may be deferred. None of them is a promotion
blocker, and none changes a number.

---

## 5. Convergence

Objection trajectory: **r1 = 4 MAJOR + 6 MINOR + 4 NOTE (14) → r2 = 0 FATAL, 0 MAJOR,
4 MINOR, 3 NOTE (7)**, with every r1 disposition verified by fresh recomputation and 14/14
holding. Severity falls monotonically and no claim was re-overclaimed during repair — the
proposer downgraded N1 to sequential-only *before* being told to. This is the healthy
signature.

VERDICT: PASS
