# Verdict r1 — CRITIC on `toys/midpoint/` (claims C6, N1)

Critic: Opus (adversarial, round 1). Target: `toys/midpoint/{midpoint.jl,test.jl,mutations/run.jl,PROOF.md}`.
All critic scratch work under `/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-0dce-432d-85cc-272c91280792/scratchpad/critic-midpoint-r1/`
(`brute.jl` 35 L, `seqrep.jl` 38 L, `parrep.jl` 34 L, `tb05.jl` 16 L, `mutate*.jl`, `test_aug.jl`). No repo file other than this verdict was touched.

## 0. Observed runs (verbatim summary lines)

`julia toys/midpoint/test.jl` — exit 0, 6.9 s:

```text
Test Summary:                | Pass  Total  Time
term IR and exact evaluators |    9      9  0.6s
Test Summary:                    | Pass  Total  Time
exhaustive exact midpoint values | 1380   1380  3.3s
r(n) for cheating value <= 1/2
n  r(n)  r(n+1)/r(n)
1  1  3.0
2  3  2.0
3  6  1.833333
4  11  2.0
5  22  2.045455
6  45  1.977778
7  89  2.0
8  178  -
Test Summary:                   | Pass  Total  Time
naive independent amplification |   84     84  0.4s
```

`julia toys/midpoint/mutations/run.jl` — exit 0, 28.1 s:

```text
M1 killed (exit 1): Coin checks both subclaims
M2 killed (exit 1): prover cannot choose z (z is fixed to x)
M3 killed (exit 1): use 2^n instead of 2^(n-1) for the midpoint
Test Summary:           | Pass  Total   Time
midpoint mutation suite |    3      3  26.9s
```

## 1. Independent recomputation (obligation 2) — NO MISMATCH

`scratchpad/critic-midpoint-r1/brute.jl` (35 lines, no memoisation, no shared code, plain
`V_0(x,y)=[y=f(x)]`, `V_n(x,y)=max_z (V_{n-1}(x,z)+V_{n-1}(z,y))/2` in `Rational{BigInt}`),
`f(t)=(3t+1) mod 8`, `D=0:7`, `n=0..4`, all `(x,y)`:

```text
checked=320 mismatches=0
n=2, x=0 row: Rational{BigInt}[1, 3//4, 3//4, 3//4, 3//4, 3//4, 3//4, 3//4]
```

My values agree with `optval` **and** with `1−2^{−n}` (resp. 1) on all 320 pairs. I additionally ran the
bottom-up DP that `docs/DESIGN.md` §5.2 actually specifies (`Z/17Z`, `f(t)=t+1`, `n=0..8`, all `17×17` pairs,
`tb05.jl`, 16 lines): **2601 exact assertions, 0 mismatches, 1.1 s**.

**The mathematics of C6 is correct and PROOF.md's induction is sound in substance.** Everything below is
about (i) what the checkers can actually falsify, (ii) missing quantifiers, and (iii) N1, which is
essentially unaddressed by the artifact.

---

## Objections

### O1 · MAJOR · `toys/midpoint/midpoint.jl:152-200` + all of `toys/midpoint/test.jl` — the suite has ZERO red-capability for the optimisation that C6 is *about*

C6 is a statement about an **optimum over all prover strategies**. The suite cannot distinguish `optval`
from the honest-prover evaluator. Four semantic, construction-breaking mutants of mine stayed **green**
(`mutate2.jl`, each run on a copy in a temp dir):

```text
N-P  SURVIVED (GREEN)    Ask domain collapsed to the honest midpoint only (prover loses all freedom)
N-Q  SURVIVED (GREEN)    optval on Ask replays term.k.honest instead of maximizing
N-T  SURVIVED (GREEN)    optval := value(term, honest_prover)   (no optimisation at all)
N-U  SURVIVED (GREEN)    Ask domain = orbit of x under f, ignoring the caller's domain
```

N-T is the damning one: **delete the entire maximiser, evaluate the honest strategy, and 1473/1473
assertions still pass.** Cause: for this protocol the honest midpoint happens to be optimal at every node,
and the term carries the honest move (`FiniteContinuation.honest`, see O8), so honest-evaluation and
optimum coincide on the whole tested corpus. rk-light law 4 ("every machine-checkable certificate must be
demonstrably able to FAIL") is violated for the single most load-bearing function in the toy.

Seven further mutants of mine were correctly killed (N-A honest move → `x`; N-B memo key drops `y`; N-C right
subclaim reversed; N-D `max`→`min`; N-E `Coin`→`max` in `optval`; N-H product→union bound; N-I biased coin;
N-K predicate reversed).

**FIX DEMAND.** Append this block to `test.jl` (extend line 1 to `using Test: @test, @testset, @test_throws`).
I verified it passes on the current code (9/9, 0.8 s) and that it **kills N-P, N-Q, N-T, N-U, N-F and N-G**
while M1/M2/M3 stay killed (`mutate3.jl`: 9/9 mutants dead, 1 m 55 s):

```julia
@testset "RED: the optimum is not the honest value; Ask really offers the whole domain" begin
    # (R1) optval must maximise, not replay the recorded honest move.
    suboptimal = FiniteContinuation((0, 1), z -> Test(() -> z == 1), 0, 0,
                                    (:suboptimal_example,), "z")
    bad = Ask(suboptimal)
    @test value(bad, honest_prover) == QZERO
    @test optval(bad) == QONE

    f = t -> mod(t + 1, 5)
    # (R2) the Ask domain is exactly the domain handed to midpoint_protocol.
    term = midpoint_protocol(f, 0:4, 0, 3, 2)          # true y = f^4(0) = 4, so this is false
    @test collect(term.k.domain) == collect(0:4)
    @test optval(term) == QONE - QONE // BigInt(4)

    # (R3) prover freedom is load-bearing: deleting the honest midpoint f^2(0)=2
    # from the domain strictly lowers the optimum.
    @test optval(midpoint_protocol(f, [0, 1, 3, 4], 0, 3, 2)) < QONE - QONE // BigInt(4)

    # (R4) the domain guard on `value` is live.
    @test_throws ArgumentError value(midpoint_protocol(f, 0:4, 0, 3, 1), _ -> 99)

    # (R5) the pretty-printer prints the whole honest expansion, not half of it.
    trace = pretty(midpoint_protocol(f, 0:4, 0, iterate_function(f, 0, 4), 2))
    @test count(_ -> true, eachmatch(r"Ask\(",  trace)) == 3
    @test count(_ -> true, eachmatch(r"Coin\(", trace)) == 3
    @test count(_ -> true, eachmatch(r"Test\(", trace)) == 4
end
```

(My computation for R3: `optval(f=t+1 mod 5, D=[0,1,3,4], x=0, y=3, n=2) = 1//2 < 3//4`; with the full
domain `0:4` it is `3//4`.) Also add N-P/N-Q/N-T/N-U to `mutations/run.jl` as permanent mutants.

**SURVIVING WEAKER STATEMENT.** *On the tested corpus the honest-midpoint strategy attains the value
`1−2^{−n}`; the current suite certifies that this value is **attained**, not that it is the **maximum**.*

---

### O2 · MAJOR · `toys/midpoint/midpoint.jl:222-226`, `test.jl:60-86`, `PROOF.md:114-118` — repetition is never modelled; the test is a tautology and PROOF.md overclaims it

`amplified_optval(term, r) = optval(term)^r` **is** the claim, restated as code. `test.jl:79`
(`@test amplified_optval(term, r) == p^r`) therefore checks `optval(term)^r == p^r` given `optval(term) == p`
from line 77 — it has no content about repetition. Nothing in the repo represents an `r`-copy protocol, so
no mutation of *repetition semantics* is even possible. Meanwhile `PROOF.md` ⟨1⟩3.⟨2⟩1 asserts the suite
"checks … **exact AND repetition** through level 8". It does not. That sentence is a lockstep violation
(law 2): the summary is stronger than the artifact.

On the substance the brief asks about (obligation 3): **the comment at `test.jl:60-64` is correct**, and I
verified it rather than refereeing it. The precise argument it gestures at:

> Fix any prover, deterministic w.l.o.g. after conditioning on its private randomness (shared randomness
> across copies is handled by conditioning on it first; the bound then averages). Let `T_{<i}` be the full
> transcript before copy `i` starts. Conditioned on `T_{<i} = t`, the residual behaviour of the prover in
> copy `i` is a well-defined **single-copy** strategy, and copy `i`'s verifier coins are fresh and
> independent of `T_{<i}`. Hence `Pr[copy i accepts | T_{<i}=t] ≤ p` pointwise. The event "copies `1..i−1`
> accept" is `T_{<i}`-measurable, so `Pr[all r accept] = E[∏_i 1{copy i accepts}] ≤ p^r` by iterated
> conditioning. The bound is attained by playing a single-copy optimal strategy in each copy.

Note the two things the current comment leaves implicit and which must be written down: (a) *`T_{<i}`-measurability*
of the past-acceptance event, and (b) that this is **sequential** repetition — the argument does **not**
transfer to parallel repetition, where copy `i`'s later rounds see other copies' coins (Bellare–Impagliazzo–Naor:
parallel repetition need not reduce error for multi-round protocols). See O3.

My independent adaptive cross-copy DP (`seqrep.jl`, exact rationals; the prover maximises at every node with
full knowledge of the past and of how many copies remain) confirms the product formula:

```text
n=1 r=1..4  adaptive = 1//2, 1//4, 1//8, 1//16                       = p^r  (all equal=true)
n=2 r=1..4  adaptive = 3//4, 9//16, 27//64, 81//256                  = p^r
n=3 r=1..4  adaptive = 7//8, 49//64, 343//512, 2401//4096            = p^r
n=4 r=1..4  adaptive = 15//16, 225//256, 3375//4096, 50625//65536    = p^r
```

**FIX DEMAND.** Implement the `r`-copy sequential AND game and test *that* against `p^r`, then add a mutant
of it. The whole DP is 15 lines and needs no new IR node:

```julia
# opt value of: play the current copy on claim (x,y,n); on accept run `k` more fresh
# copies of the base claim; on reject, reject.  Adaptive across copies by construction.
A(g, k) = k == 0 ? EXACT_ONE : G(g, g.x0, g.y0, g.n0, k - 1)
function G(g, x, y, n::Int, k::Int)
    haskey(g.memo, (x, y, n, k)) && return g.memo[(x, y, n, k)]
    v = n == 0 ? ((y == g.f(x)) ? A(g, k) : EXACT_ZERO) :
        maximum(z -> (G(g, x, z, n-1, k) + G(g, z, y, n-1, k)) / BigInt(2), g.D)
    g.memo[(x, y, n, k)] = v
end
```

and correct `PROOF.md` ⟨1⟩3.⟨2⟩1 (it currently claims a check that does not exist).

**SURVIVING WEAKER STATEMENT.** *`(1−2^{−n})^r` is the correct value of `r`-fold sequential AND-repetition
(independently verified for `n ≤ 4`, `r ≤ 4`), but the repo currently **assumes** it rather than checking
it, and `PROOF.md` misdescribes the suite.*

---

### O3 · MAJOR · `claims/CLAIMS.md:15` (N1) and all of `PROOF.md` — N1 has no derivation anywhere; three of its four content words are unsupported

N1 asserts three things beyond C6: (i) `Θ(2ⁿ)` repetitions; (ii) for **sequential *or parallel*** repetition;
(iii) "and therefore **cannot serve as a compression step**". `PROOF.md` contains **not one line** about
repetition. The only evidence is `test.jl:95-97`, four ratio points with a hand-tuned tolerance
(`isapprox(rs[n+1]/rs[n], 2.0; atol=0.06)`, largest observed margin `45/22 − 2 = 0.0455` — 24 % headroom).
Four finite ratios are not `Θ`.

(i) is provable in three lines and should be. With `p = 1−2^{−n}`, `r(n) = min{r : p^r ≤ 1/2} =
⌈ln 2 / (−ln p)⌉`; from `ε ≤ −ln(1−ε) ≤ ε/(1−ε)` with `ε = 2^{−n}`:

    2ⁿ ln 2 − ln 2  ≤  r(n)  ≤  2ⁿ ln 2 + 1 .

My check: `r(1..8) = 1, 3, 6, 11, 22, 45, 89, 178` from the closed form, identical to the printed table; and
for `n=8` the bounds bracket it, `[176.753, 178.446] ∋ 178`.

(ii) is *not* covered by the `test.jl:60-64` argument (O2). I therefore brute-forced **true parallel
repetition** myself (`parrep.jl`: all `r` copies in lockstep, prover sends all `r` midpoints simultaneously
having seen *every* copy's past coins, verifier flips `r` fresh coins; exact rationals, `f(t)=t+1 mod 5`):

```text
n=1 r=1,2,3  PARALLEL = 1//2, 1//4, 1//8        = p^r
n=2 r=1,2,3  PARALLEL = 3//4, 9//16, 27//64     = p^r
n=3 r=1,2    PARALLEL = 7//8, 49//64            = p^r
```

So the parallel clause is empirically fine on these instances — but it is **unproved in the repo**, and the
general theory says it needs an argument. (The direction N1 actually needs is easy and should be stated:
playing independently in each copy gives value `≥ p^r` for *any* repetition scheme, hence `r ≥ ln 2/(−ln p) =
Ω(2ⁿ)` is **necessary** for sequential *and* parallel repetition alike.)

(iii) is unsupported: nothing in the toy has a cost model (see O12). "Cannot serve as a compression step"
requires the handoff's `O(n)`-verifier-time half of the diagnostic, which is absent.

**FIX DEMAND.** Add `PROOF.md` ⟨1⟩4 with: (a) the two-sided bound above ⇒ `r(n)=Θ(2ⁿ)`; (b) the
`value ≥ p^r` lower bound valid for any repetition scheme, which is what makes N1 a *negative* result;
(c) either the sequential/parallel distinction proved, or delete "parallel" from N1; (d) either a verifier
cost measure (O12) or delete "and therefore cannot serve as a compression step". Replace the fragile ratio
test by an exact assertion against the closed form `r(n) = ⌈ln 2/(−ln p)⌉` and by `2ⁿln2 − ln2 ≤ r(n) ≤ 2ⁿln2 + 1`
in `Rational`/interval form for `n = 1..12`.

**SURVIVING WEAKER STATEMENT.** *For sequential AND-repetition of the midpoint protocol,
`r(n) = min{r : (1−2^{−n})^r ≤ 1/2}` satisfies `2ⁿ ln2 − ln2 ≤ r(n) ≤ 2ⁿ ln2 + 1`, i.e. `r(n) = Θ(2ⁿ)`, with
`r(1..8) = 1,3,6,11,22,45,89,178`. Any repetition scheme (sequential or parallel) needs `r = Ω(2ⁿ)` because
independent play already achieves `p^r`. The consequence "destroys compression" is not established here.*

---

### O4 · MAJOR · `claims/CLAIMS.md:13` (C6) and `midpoint.jl:115-121` — C6 carries no quantifiers and is FALSE as literally written; the constructor has no guard

The DAG column header is "statement (**quantifiers included**)". C6 supplies none: no `D`, no `f`, no
`x, y`, no `n`, and in particular no hypothesis relating `D` to `f`. `midpoint_protocol(f, domain, x, y, n)`
accepts **any** `domain`. Counterexample I computed (`precond.jl`), `f(t) = t+1 mod 5`, `D = {0,1,2}`,
`n = 2`, `x = 0` (true `y = 4`):

```text
optval(TRUE  claim x=0,y=4,n=2) = 1//2     <-- perfect completeness FAILS
optval(false claim x=0,y=0,n=2) = 1//2     <-- p_2 = 3//4, so C6 as written FAILS
optval(false claim x=0,y=1,n=2) = 3//4
optval(false claim x=0,y=2,n=2) = 3//4
```

`PROOF.md` ⟨1⟩1 *does* carry the hypothesis `f : D → D`, so the proof is fine — the DAG row and the code are
not. Moreover `f : D → D` is **stronger than necessary**: the sharp hypothesis is that `D` contains the
orbit prefix, and I verified the sharper version holds where `f`-closure does not — `D = {0,1,2}`,
`f(t)=t+1 mod 5`, `n = 1`, `x = 0` (so `{f^k(0) : k ≤ 2} = {0,1,2} ⊆ D`, but `f(2)=3 ∉ D`):

```text
optval(true y=2)  = 1//1      optval(false y=0) = 1//2      optval(false y=1) = 1//2
```

**FIX DEMAND.** (a) Rewrite C6 with quantifiers, e.g. *"For every nonempty `D`, every `f : D → D`, every
`n ≥ 0` and all `x, y ∈ D` with `y ≠ f^{2ⁿ}(x)`, the optimal acceptance probability of the level-`n`
midpoint protocol (prover choosing freely in `D` at every `Ask`, verifier's coin revealed before the next
`Ask`) is exactly `1 − 2^{−n}`; for `y = f^{2ⁿ}(x)` it is 1."* (b) Add to `midpoint_protocol` an explicit
precondition check `{f^k(x) : 0 ≤ k ≤ 2ⁿ} ⊆ domain` (or `f(D) ⊆ D`) that throws, plus a `@test_throws`.
(c) Record the sharper orbit-prefix hypothesis in `PROOF.md` ⟨1⟩1 as a remark.

**SURVIVING WEAKER STATEMENT.** *The theorem holds verbatim under the hypothesis
`{f^k(x) : 0 ≤ k ≤ 2ⁿ} ⊆ D` (implied by, but weaker than, `f : D → D`). Without it both perfect
completeness and the value `1−2^{−n}` fail, by the `D = {0,1,2}` counterexample above.*

---

### O5 · MINOR · `PROOF.md:12-13` (⟨1⟩1.⟨2⟩2), `PROOF.md:18-20` (⟨2⟩4), `PROOF.md:124-127` (⟨1⟩3.⟨2⟩3) — `max` where `sup` is required, and no prover strategy space is defined

⟨2⟩2 *defines* `V_n(x,y)` as "the **maximum** acceptance probability", and ⟨2⟩4 justifies `V ∈ [0,1]` because
"an `Ask` **maximizes** such values". For infinite `D` — which ⟨1⟩3.⟨2⟩3 explicitly claims to cover — the
maximum need not exist a priori; attainment is part of what is being proved, so the definition must be a
`sup` and ⟨3⟩4 must be read as "the sup is attained at `z = f^h(x)`". As written, ⟨2⟩2 assumes its own
conclusion in the infinite case. Separately, the proof never says what a prover *is*: adaptive vs.
non-adaptive (equivalent here, since distinct `Ask` nodes carry distinct choices — but it must be argued),
deterministic vs. randomised (`sup` over randomised = `sup` over deterministic by convexity of the value in
the prover's mixture — one line, currently absent), and whether the verifier's coin is revealed before the
next `Ask` (it is, in the code; unstated in the proof, and the value would need re-argument if it were not).

**FIX DEMAND.** Change ⟨2⟩2 to `V_n(x,y) := sup over deterministic prover strategies`; add ⟨2⟩2a defining a
strategy as a map from `Ask`-node-address to `D`, note the coin is revealed, and add the one-line convexity
remark for randomised provers; state in ⟨3⟩4 that the sup is attained.
**SURVIVING WEAKER STATEMENT.** *For finite `D` the proof is unaffected. For infinite `D` the correct
statement is `sup_z … = p_n`, attained at `z = f^h(x)`.*

---

### O6 · MINOR · `midpoint.jl:126-131` — the domain guard is never exercised (mutant N-F survived green)

Replacing the `throw(ArgumentError("prover choice is outside the finite domain"))` guard by `true` leaves the
whole suite green. The guard is what makes `value(term, prover)` mean "prover restricted to `D`".
**FIX DEMAND.** Assertion (R4) of the O1 block (verified to kill N-F).
**SURVIVING WEAKER STATEMENT.** *`optval` maximises over `D` regardless; only `value`'s contract is unpinned.*

### O7 · MINOR · `test.jl:26-31`, `midpoint.jl:251-278` — the pretty-printer is asserted by three `occursin` calls

A printer that silently drops branch 2 of every `Coin` passes (mutant N-G survived green), yet the printed
`n = 2` trace is a named brief-03 deliverable.
**FIX DEMAND.** Assertion (R5) of the O1 block: exactly 3 `Ask`, 3 `Coin`, 4 `Test` in the honest `n=2`
expansion (verified to kill N-G).
**SURVIVING WEAKER STATEMENT.** *The trace shown in the run log is in fact correct; it is merely unpinned.*

### O8 · MINOR · `midpoint.jl:31-38, 98-106` — the witness and evaluator state are stored *inside the term*

`FiniteContinuation` carries `honest` (the correct midpoint), `fixed` (`= x`, used by nothing but mutation
M2), `cache_key` (an `optval` implementation detail) and `label`. Two consequences: (a) the "protocol as
data" deliverable is compromised — the term contains the answer, which is what makes O1's N-Q/N-T possible;
(b) `fixed` is unconstrained by the suite — my mutant N-J (`fixed = y` instead of `x`) is **green**, silently
changing what M2 tests without any test noticing.
**FIX DEMAND.** Move `honest` into a separate `honest_move(f, x, n)` / `Strategy` object, drop `fixed`
(re-express M2 as a mutation of `_maximize_ask`), and move `cache_key` into the evaluator's own keying
(`objectid`/an explicit claim tuple passed alongside the term). Keep only `domain` and the continuation.
**SURVIVING WEAKER STATEMENT.** *`optval` never reads `honest` or `fixed`, so C6's computed numbers are
unaffected; only the "term = protocol" representational claim and M2's meaning are.*

### O9 · MINOR · `midpoint.jl:103, 181-189`; `test.jl:14` — memo key omits `f` and `domain`

`(:midpoint_claim, x, y, n)` is sound only because a single `optval` call fixes `f` and `D`. Compose two
sub-terms built with different domains (exactly what a later "re-homed" TB0.5 might do) and the cache is
unsound. The hand-written key `(:small_example,)` in `test.jl:14` has the same hazard.
**FIX DEMAND.** Include `objectid(f)` and `objectid(domain)` (or a caller-supplied context tag) in the key,
or key on `objectid(term.k)`; add a regression test composing two domains.
**SURVIVING WEAKER STATEMENT.** *No current call site is affected; this is latent, not live.*

### O10 · MINOR · `PROOF.md` throughout — inline math delimiters are destroyed

Every `\(…\)` has lost its backslashes: line 5 reads "a nonempty domain (D), a function (f:D\to D)", line 12
"Let (V_n(x,y)) be the maximum …". The proof of record does not render. **FIX DEMAND.** Restore `$…$` or
`\(…\)`. **SURVIVING WEAKER STATEMENT.** *Content unaffected; presentation only.*

### O11 · NOTE · obligation 5 — Y-term fidelity: the fixed point is genuinely explicit, not smuggled

`FixedPoint{F}` with `(fixed::FixedPoint)(state) = fixed.body(fixed, state)` (`midpoint.jl:67-73`) is a
self-passing fixed point — the Z/Mendler-style call-by-value analogue of `Y`, since strict Julia cannot run
`λf.(λx. f(x x))(λx. f(x x))`. There is **no** named self-recursive function, no macro, no `Expr`; the
recursion is carried by the value handed to the body. `MidpointYTerm(self, claim)` reproduces the handoff's
body faithfully, including branch order: `n == 0 → Test(y == f(x))`, else `Ask(z ↦ Coin(r(x,z,n−1), r(z,y,n−1)))`.
Two deviations, neither a misrepresentation: (a) `f` and `D` are captured in the `MidpointYTerm` struct
rather than being λ-parameters as in `λ r f n x y`, so the term is `Y(Ψ_{f,D})` rather than the handoff's
`Y(Ψ)` applied to `f`; (b) `Ask` holds a 6-field struct rather than a bare `λz.…` (see O8). **FIX DEMAND
(cosmetic).** Add `f` and `domain` to the body's argument list so the code literally mirrors `λ r f n x y`,
and say in a comment that `FixedPoint` is the call-by-value (Z) fixed point.

### O12 · NOTE · whole toy — the *other half* of the handoff diagnostic (`O(n)` verifier time) is not represented

The handoff's point is `O(n)` verifier time **and** `p_n = 1−2^{−n}`; only the second is modelled. There is no
round counter, no query count, no description-size measure — so "destroys compression" (N1) cannot even be
stated in the model. **FIX DEMAND.** Add `rounds(term)` / `queries(term)` to the IR (the honest `n = 2`
expansion has depth 3: 3 `Ask`, 3 `Coin`, 4 `Test`) and a test that every root-to-leaf transcript has exactly
`n` `Ask`s and `n` `Coin`s and one `Test`; then `r(n)·rounds = Θ(2ⁿ·n)` makes N1(iii) sayable.

### O13 · NOTE · lockstep with `docs/DESIGN.md:645-657` (§5.2 TB0.5)

DESIGN specifies TB0.5 on `Z/17Z`, `f(x)=x+1`, `0 ≤ n ≤ 8`, via the bottom-up table
`p[n,x,y] = max_z (p[n−1,x,z]+p[n−1,z,y])/2`. The delivered toy uses `Z/5`, `Z/8`, `n ≤ 5` and a term-rebuilding
evaluator. Brief 03 explicitly sanctioned ignoring DESIGN, so this is not a violation — but the two must be
reconciled at re-homing, and DESIGN's version is *stronger and cheaper*: I ran it (`tb05.jl`, 16 lines):
**2601 exact assertions, n = 0..8, 0 mismatches, 1.1 s** versus the delivered 1380 assertions, `n ≤ 5`, 3.3 s.

### O14 · NOTE · `claims/CLAIMS.md:13,15` — C6 and N1 still have `where-proved = —`, `where-tested = —`

`PROOF.md` and `test.jl` exist and are not referenced from the DAG. Fill both columns (and the `verdict`
column with this file) at promotion time.

---

## Elegance — three concrete simplifications (obligation 6)

**E1. Take the witness and the evaluator's cache key out of the term** (`midpoint.jl:31-40, 98-106`).
`struct Ask{K}` should hold `domain` plus a plain `z ↦ term` continuation. Supply `honest_move(f, x, n) =
iterate_function(f, x, 1 << (n-1))` separately and define `honest_prover` from *it*, not from the term.
Deletes the `honest`, `fixed`, `cache_key`, `label` fields (≈20 lines), restores "the term is the protocol",
and makes the O1 survivors N-Q/N-T structurally impossible rather than merely test-detectable.

**E2. Stop hand-rolling `maximum` and the rational constructors.** `_maximize_ask` (`midpoint.jl:165-178`,
13 lines with a `first_choice` flag and a `best` accumulator) is exactly

```julia
_optval(t::Ask, cache) = maximum(z -> _optval(t.k(z), cache), t.k.domain)
```

Likewise `_probability(v::Bool)` (`:124`) is `ExactProbability(v)`, and `test.jl:5-8` redefines
`Q/QZERO/QONE/QHALF` that `midpoint.jl:18-21` already provides as `ExactProbability/EXACT_ZERO/EXACT_ONE/
EXACT_HALF` — a single-source violation (law 2) in a 4-line block.

**E3. Keep the term IR as the *representation*, and use the bottom-up DP as the independent *oracle*.**
Twelve lines (`tb05.jl`) give `Z/17Z`, `n = 0..8`, all pairs, 2601 exact assertions in 1.1 s. Testing
`optval(midpoint_protocol(...)) == p[n,x,y]` for every entry cross-checks two genuinely different
implementations — the defence layer that is missing today, and the one that would have caught N-Q/N-T
without any hand-written red test. It also removes the `O(|D|²·n)` term rebuild that currently caps the
suite at `n ≤ 5`.

*(Bonus E4: `iterate_function` is called with `steps = 2ⁿ` and loops that many times — `completeness` alone
does `2ⁿ` applications per call. Fine at `n ≤ 8`; use repeated squaring of the permutation, or cache the
orbit, if TB0.5 is ever run at the DESIGN's `n = 8` over larger domains.)*

---

## Per-claim recommendation

**C6 — HOLD.** The mathematics is right: I reproduced `1−2^{−n}` independently on 320 pairs
(`f(t)=3t+1 mod 8`, `n ≤ 4`) and on 2601 pairs (`Z/17Z`, `n ≤ 8`) with zero mismatches, and `PROOF.md`'s
induction (sharp upper bound via "both subclaims cannot be true", matching strategy via the honest midpoint)
is sound in substance. Missing steps blocking promotion:

- to **TESTED**: O4(a,b) — quantify the row and guard the precondition; and O1 — land the red block so that
  the suite can distinguish `optval` from the honest evaluator (four construction-breaking mutants are
  currently green). Both are verified-to-work fixes given above.
- to **PROVED**: additionally O5 — `sup` rather than `max` in ⟨1⟩1.⟨2⟩2/⟨2⟩4, an explicit prover strategy
  space (adaptive/randomised/coin-revealed), and the orbit-prefix hypothesis recorded in ⟨1⟩1.

**N1 — HOLD**, and further from promotion than C6. Missing steps:

- O2 — no model of repetition exists; `amplified_optval` restates the claim and the test is a tautology,
  while `PROOF.md` ⟨1⟩3.⟨2⟩1 asserts a check that is not performed.
- O3(i) — no proof of `r(n) = Θ(2ⁿ)`; the evidence is four ratio points at `atol = 0.06`. The two-sided
  bound `2ⁿln2 − ln2 ≤ r(n) ≤ 2ⁿln2 + 1` is three lines and must be in `PROOF.md`.
- O3(ii) — the word "parallel" in N1 is unsupported by anything in the repo (my brute force says it is *true*
  for `n ≤ 3, r ≤ 3`, but that is my computation, not the artifact's, and the sequential argument does not
  transfer). Prove it, or delete "parallel", or replace by the scheme-independent `value ≥ p^r ⇒ r = Ω(2ⁿ)`.
- O3(iii) + O12 — "cannot serve as a compression step" has no cost model behind it.

Recommended interim downgrade of N1 to the surviving weaker statement in O3 until (O2, O3) land.

---

VERDICT: FAIL(O1,O2,O3,O4)
