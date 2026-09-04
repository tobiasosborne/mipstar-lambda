# CRITIC verdict r1 — rung TB0 (`Project.toml`, `src/**`, `test/**`) at commit `747f746`

Round 1 (attack). Priors: `verdicts/design-r4.md` (PASS, design cycle converged) and its two extra
DIRECTIVES FOR TB0 (4) and (5). No prior verdict exists on this rung, so nothing is re-litigated;
`verdicts/design-r1..r4.md` are treated as settled for `docs/`.

**Isolation.** Per brief §Isolation I extracted `git archive 747f746` into
`/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-.../scratchpad/critic-tb0-r1/tb0/` and ran
every test, mutation and experiment there. All `file:line` citations below are that copy, which is
byte-identical to `747f746`. The live working tree (TB1 worker's lane) was never read or run.

**Independence.** Every number in §0 was recomputed from a *new* implementation I wrote from
`docs/DESIGN.md` §5's circuit prose and from `gt-10` (`def:tseitin` via `nw19-tseitin-arith.tex`,
`def:formula-arithmetization`, `prop:zero-basis`, `fig:pcpverifier` steps 4–5) and `gt-03`
(`sec:ld-encoding`) — packed-nibble 16-variable sparse arithmetic over `Z` and over `GF(2)`, a fresh
zero-basis divider, fresh carry-less `GF(2^3)`/`GF(2^11)` arithmetic with log/exp tables, and a
numpy evaluator. Scratch: `.../critic-tb0-r1/indep/{tb0.py,gfeval.py,run1..run5.py}`. No code from
`src/`, from `docs/`, or from `verdicts/design-r4.md`'s scratch was reused.

---

## 0. Independent recomputation (brief obligations 1–6)

**(1) `F_arith` occurrence vector = actual individual-degree vector — CONFIRMED.**

```
occ(F_arith)    = (2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3)   [literal count on my formula tree]
account(2f / 2+2f+[out]) = (2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3)
inddeg(F_arith) = (2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3)   over Z  AND  in char 2
support(F_arith) = 27,489 over Z   /  18,620 in char 2
gadget term counts = [6,6,6,7,7,7] + the output literal (1)
128 present / 896 absent clauses; 512 satisfying five-block witnesses
```

**(2) Witness (ii) `([0,1])^5` — CONFIRMED on every figure.**

```
c_0 support        = 788,032 over Z   /  534,912 in char 2
inddeg(c_0)        = (3,1,1,1,3, 3,1,1,1,1, 6,4,4,4,4,3)   over Z and char 2
remainder          = 0 (both)         coefficient identity re-expanded and compared: TRUE (both)
max_j inddeg(c_j)  = 6                zero quotients = (2,3,4,7,8,9,10)
quotient inddeg    = [6,-,-,-,5,5,-,-,-,-,4,4,3,4,3,1]
quotient supports (char 2) = [250208,0,0,0,109536,71488,0,0,0,0,59344,7072,1536,2304,1440,576]
```

Witness (i) cross-check, also independent: `c_0` support 49,252 over `Z` / **33,432** in char 2,
`inddeg = (3,0,0,0,2,3,1,1,1,1,6,4,4,4,4,3)`, `r=0`, quotient supports
`[15638,0,0,0,4024,5516,0,0,0,0,4386,522,120,184,90,36]` and max degrees
`[6,-1,-1,-1,5,5,-1,-1,-1,-1,4,4,3,4,3,1]` — **byte-for-byte the table the suite prints**
(`TB0 quotient table:` line of my run). Note: `verdicts/design-r4.md` §0.1's quotient supports are the
**`Z`** figures; mine above are char 2, and both implementations agree where they overlap.

**(3) `pcpverifier` by hand at `b_rho` and `b_rho[O2<-rho]` — CONFIRMED.**
With `rho = x`, `b_rho = (X=0^5, O=1^5, W=(rho,0,0,0,0,rho))`:

| field | `F_arith(b_rho)` | `c_0(b_rho)` | honest `beta_0` at `b_rho[O2<-rho]` | mutation-B `beta_0` | verifier RHS |
|---|---|---|---|---|---|
| `GF(8)` | `1 = rho^4(1+rho)` | **1 ≠ 0** | **2** `= rho^5(1+rho)` | **1** | 2 |
| `GF(2^11)` | `48` | **48 ≠ 0** | **96** | **48** | 96 |

Both witnesses give the same values (at `b_rho` all `alpha_i = 0` and all five factors `(0-1)=1`, so
`c_0(b_rho) = F_arith(b_rho)`). My verifier used **my own** quotients for `beta_j` and accepted both
tests — an end-to-end independent confirmation of the zero-basis + verifier pipeline.

**(4) `GF(2^11)` modulus — CONFIRMED independently.** `0x805 = x^11+x^2+1` is irreducible by my own
trial division over all divisors of degree `1..5`; `0x00b = x^3+x+1` likewise. `ord(x) = 7` in `GF(8)`
and `2047` in `GF(2^11)`; primitivity re-checked by the prime-factor test `2047 = 23*89`
(`x^(2047/23) != 1`, `x^(2047/89) != 1`).

**(5) Lifted vs direct `GF(2^11)` — CONFIRMED at 70 points of my choosing** (50 uniform, seed
`20260904`, plus `0^16`, `1^16`, `2^16`, `b_rho`, and the 16 points `b_rho[j <- 1023]`). I had Julia
dump `ev_z` for the lifted and the directly-built `GF(2^11)` proofs and compared **both** against my
own evaluation of `alpha_1..5`, `beta_0`, `beta_1..16`: **0 mismatches on all three pairings**
(`indep/run4.py`). Julia's own `PrimeFieldPCPProof` semantics is therefore faithful, not just
self-consistent.

**(6) The six `def:pcpparams` predicates, line by line — AGREE with the proposer's report.**

| | `P_shape` (2.i) | `P_growth` (2.a) | `P_formula_paper` (2.b) | `P_tail` (2.c) | `P_divisibility` (2.d) | `P_degree` (3) |
|---|---|---|---|---|---|---|
| TB0-small `(8,3,1,6,6,16)` | `16=5+5+6`, `2^4` → **PASS** | `k=3` below any admissible RHS → **FAIL** | `2*17*16=544 !< 8` → **FAIL** | `3*16/8=6 >= 1` → **FAIL** | `8%16=8` → **FAIL** | `6 != 3` → **FAIL** |
| TB0-sampled `(2048,11,1,11,6,16)` | **PASS** | `k=11` above the code's threshold → **NOT_EVALUABLE** | `2*57*16=1824<2048` → **PASS** | `11*16/2048=11/128 <= 1/6` → **PASS** | `2048%16=0` → **PASS** | `11=11` → **PASS** |

Plus `P_formula_structural` `FAIL/PASS` (`2*(6+30)*16=1152 !< 8`; `2*(6+55)*16=1952<2048`),
`P_zero` sampled `PASS` (`416<2048`), `P_exponent_range` small `PASS` (`6<=7`), and
`minimal_checkable_odd_k(6,16)=11` (`k=9`: `2*51*16=1632 !< 512`). **No disagreement.** One fidelity
defect in the *rule* (not in either row's answer) is filed as O9.

---

## 1. Objections

### O1 · **MAJOR** · `test/runtests.jl:3–13` — the 60 s hard gate measures `using MIPStarLambda`, so it **fails on a clean checkout on a quiet machine**

`started = time()` is on line 3; the clock is stopped after `include("tb0_core.jl")`, whose line 3 is
`using MIPStarLambda`. Package load — and, on a cold cache, **package precompilation** — is inside the
timed region. This commit newly adds `src/precompile.jl` (89 `precompile` calls, `+89` lines, T2's
optimisation), which moves ~42 s of work into exactly that region.

My run, nothing else running, unmutated code, fresh compile cache (a plain clone + `julia --project=.
test/runtests.jl`, i.e. skipping the `Pkg.instantiate()` step of `CLAUDE.md` §Build & test):

```
MIPStarLambda | 93 passed / 93 total | 2m20.2s
TB0 total wall seconds = 140.754 (warning=45.0, hard_limit=60.0)
TB0 60 s hard limit (measured 140.754 s) | 1 Fail | 1 Total
ERROR: LoadError: Some tests did not pass: 0 passed, 1 failed, 0 errored, 0 broken.
EXTERNAL WALL 145.79 s        <- exit code 1
```

So the rung's own acceptance gate is red on a clean machine. T2 did not remove 28 s of work; it moved
it upstream of the measurement, where the gate still sees it whenever the depot is cold — and it made
the mutation runner ~12x slower (O16).

**FIX DEMAND** — move `using MIPStarLambda` above `started = time()` in `test/runtests.jl` (or start the
clock after a warm-up `using`), and print load/precompile time as a separate, ungated measurement.
**SURVIVING WEAKER STATEMENT** — with a warm depot (the documented `Pkg.instantiate()` flow) the suite
is green and comfortably inside the gate: I measured **34.558 s** and **34.273 s** (harness), 35.27 s /
35.00 s external, 647 MB / 634 MB peak RSS, on two consecutive quiet runs — consistent with the
proposer's 33.245 s.

### O2 · **MAJOR** · `src/tb0.jl:216`, `test/tb0_core.jl:254–266` — design-r4 **DIRECTIVE (4) is not implemented**

design-r4 §3 directed: *"assert the sixteen named `GF(8)` lines are non-vacuous for witness (ii) —
`c_0(b_rho) != 0` suffices, and it is the assertion that would have caught R6 automatically."*
The only non-vacuity assertion in the repo is `base_value_ok` (`src/tb0.jl:216`), and it asserts
`F_arith(b_rho) != 0` — a different polynomial — and it is only ever evaluated on the **degenerate**
fixture (`tb0_degenerate_core_report` is called at `test/tb0_core.jl:175` with `polynomial_fixture(GF8,6)`,
witness (i)). The witness-(ii) line report at `test/tb0_core.jl:258–259` asserts acceptance only, which
is exactly the check R6 showed to be satisfiable by a vacuously-zero `c_0`. `c0_nonzero`
(`src/tb0.jl:372`) belongs to the unrelated `m=2` toy fixture.

**My computation:** `c_0^{(ii)}(b_rho) = 1` in `GF(8)` and `48` in `GF(2^11)`, both nonzero — the
assertion *would* pass today. **FIX DEMAND** — add `@test !iszero(evaluate(fixture8.c0, b8))` (and the
`GF(2^11)` analogue) to testset `6c` for the non-degenerate fixture.
**SURVIVING WEAKER STATEMENT** — the sixteen named lines *are* non-vacuous for witness (ii)
(independently verified above), but the repository does not check it and would not turn red if a future
tuple change made them vacuous again — the precise regression design-r4 asked to be immunised against.

### O3 · **MAJOR** · `src/polynomials/zero_basis.jl:36–44` — `_accumulate!`'s `GF2k` fast path is wrong outside the prime subfield, so `zero_basis_decompose` mis-implements `prop:zero-basis`

```julia
function _accumulate!(terms::Dict{K,F}, key::K, coefficient::F) where {K,F<:GF2k}
    if coefficient.bits == 1
        haskey(terms, key) ? delete!(terms, key) : (terms[key] = coefficient)
        return terms
    end
```

The toggle is valid only if the *stored* value is also `1`. **My computation:** in `GF(8)`,
`GF8(2) + GF8(1) == GF8(3)`, but `MIPStarLambda._accumulate!(Dict(k => GF8(2)), k, GF8(1))` **deletes**
the key. This is reachable from the public entry point: for `f = x^3 + 2x^2 + 3x` over `GF(8)`, which
vanishes on `{0,1}` (`1+2+3 = 0`), `zero_basis_decompose(f,(1,2))` returns **remainder `3x != 0`**,
contradicting `prop:zero-basis` (`gt-10:1281–1373`). Brute-forcing the 512 subcube-vanishing quartics
`c4 x^4 + c3 x^3 + c2 x^2 + c1 x` over `GF(8)`, **150 are decomposed wrongly**. The same accumulator is
used by the *checker* `verify_zero_decomposition` (lines 138–139), so constructor and checker share the
defect (`.../critic-tb0-r1/accbug2.jl`).

**FIX DEMAND** — guard the fast path the way `_multiply_terms` already guards its own
(`src/polynomials/sparse.jl:191–194`): take it only when `coefficient.bits == 1 &&
get(terms,key,zero(F)).bits <= 1`; add the `f = x^3+2x^2+3x` case as a permanent red test.
**SURVIVING WEAKER STATEMENT** — **no TB0 number in this rung is affected**: every coefficient of
`F_arith`, `c_0` and every `c_j` here lies in `{0,1}` (enforced at `src/verifiers/pcp.jl:191`), and I
reproduced all of them with an independent implementation. C2/C3 as written quantify only over the TB0
fixture and survive; `DESIGN.md` §1.4's *generic* statement of `zero_basis_decompose` does not.

### O4 · **MAJOR** · `src/polynomials/sparse.jl:396` (and `:381`) — a NEW semantic mutation leaves the suite **GREEN**: the low-degree encoding's coordinate↔bit order is untested

New mutation **N3**: in `g_a`, `bit = (index >> (M - local_coordinate)) & 1` → `(index >>
(local_coordinate - 1)) & 1` (little- instead of big-endian `y`, i.e. the wrong lexicographic
identification in `eq:ld-encoding`, `gt-03:873–897`). Result: **SURVIVED — 93/93 passed, 37.534 s**.
New mutation **N7**, the same reversal in `ind` (`sparse.jl:381`): **SURVIVED — 93/93, 35.454 s**.

Cause: TB0 uses `m = 1`, where the two conventions coincide, and the *only* `m >= 2` table exercised
anywhere is `F[0,1,1,0]` (`src/tb0.jl:35`), which is **invariant under transposing the two
coordinates** — so `g_a`, `ind`, `dec` and the `a . ind_m(x)` cross-check are all blind to the defect.
`DESIGN.md` §5.1 item 2 names this table explicitly, and TB1/TB2 need `m >= 2` encodings.

**FIX DEMAND** — the red test to add: use an **asymmetric** `m=2` table, e.g. `F[0,0,1,0]`, and assert
`evaluate(extension2, F[1,0]) == 0` and `evaluate(extension2, F[0,1]) == 1`, which pins the
big-endian `y=(y_1,y_2)` lexicographic order of `eq:ld-encoding`; keep `[0,1,1,0]` as well.
**SURVIVING WEAKER STATEMENT** — for `m = 1`, which is all of TB0, the encoding is order-independent,
so no C1/C2/C3 figure is affected; the defect class is live only from TB1 onward.

### O5 · **MAJOR** · `src/polynomials/sparse.jl:288–291`, `src/verifiers/pcp.jl:263–269, 316–337` — `pcpverifier` never reads `c_0`'s sparse expansion, so the acceptance experiments carry no information about the object whose support and degree vector the rung reports

`evaluate(poly, point)` dispatches to `_evalplan(poly.plan, point)`, i.e. it re-evaluates the
*construction expression tree*, never `poly.terms`. Consequently `beta_0 = evaluate(proof.c0, z)` in
`ev_z`, and every acceptance test (`128` `GF(8)` line points, the `65,536`-point Boolean cube, the
`10,000` `GF(2^11)` samples, the `16` separators) is a statement about the factored object
`F_arith . prod_i (g_i - o_i)`, not about the 33,432-/534,912-monomial expansion.

**My experiments** (`.../critic-tb0-r1/circ.jl`, `circ2.jl`):

- replacing `c0.terms` by the **empty dictionary**, plan untouched → `pcpverifier` accepts
  **200/200** random `GF(8)` points, *both* tests;
- deleting **one monomial** from `c0.terms` before the zero-basis pass, plan untouched, quotients
  rebuilt → `pcpverifier` accepts **300/300**, both tests, and `actual_degrees` is unchanged, while
  `verify_zero_decomposition` correctly returns `false`.

Nothing anywhere compares `c0.terms` with `c0.plan`. Step 4 is additionally computed twice by textually
duplicated code — `_evalplan(::FormulaEvalPlan, ...)` (`src/ir/circuits.jl:337–354`) and
`evaluate_arith_formula(tf, ...)` (`:314–331`) are the same loop over `tf.program` — so it certifies the
five PCP factors (mutants B, N1 and N6 all die on it) but is insensitive to a *shared* arithmetisation
error, which only testset 4's `2^16` truth table catches.

**FIX DEMAND** — add a red test asserting `evaluate(c0, z) == evaluate(SparsePlan(c0.terms), z)` at
>= 1,000 seeded points for both witnesses; better, delete `Poly.plan` and evaluate from `terms`
(elegance E2), which makes the defect unrepresentable.
**SURVIVING WEAKER STATEMENT** — the sparse expansion *is* certified, but by
`verify_zero_decomposition`'s exact coefficient identity and by the degree-vector assertions, **not** by
`pcpverifier` acceptance. C1 may claim acceptance for the factored proof object and coefficient-identity
evidence for the expansion; it may not present the `10^4`-sample acceptance as evidence for the latter.

### O6 · **MAJOR** · proposed C2 row vs `src/tb0.jl:60–100`, `test/tb0_core.jl:95–107` — "`r=0` holds for exactly the 512 witnesses satisfying `phi_C`" has **no checker**

`tb0_truth_report` exhausts the `2^10` circuit inputs (128/896), the `2^16` `(x,o,w)` assignments and
the `2^10` five-block witnesses, and returns `satisfying = 512` — but it never touches `c_0`, a
zero-basis remainder, or `build_c0`. The remainder is computed for **exactly two** witnesses, (i) and
(ii), both of which satisfy `phi_C`; **no `phi_C`-failing witness is ever exhibited with `r != 0`**. The
row's "exactly" is therefore an unchecked identification of two different conditions.

**My check:** the statement is *true* — `r=0` iff `c_0` vanishes on `{0,1}^16` iff for every present
clause some `a_i[x_i] = o_i` iff `phi_C` — but that is a derivation, not a test.
**FIX DEMAND** — the red test to add: loop over all 1,024 five-block witnesses and assert
`vanishes_on_cube(c_0(witness)) == phi_C(circuit, witness)`; this needs only the 128 present clauses per
witness (131,072 boolean checks, milliseconds), or a full `build_c0` on two extra named witnesses, one
of which fails `phi_C`.
**SURVIVING WEAKER STATEMENT** — `r=0` and the coefficient identity are machine-checked, red-capably,
for witnesses (i) and (ii); the "exactly the 512" clause must be scoped to a derivation or tested.

### O7 · **MAJOR** · `src/verifiers/pcp.jl:216–220, 248–250` — the `:PCPVerifier` CHECKED node's replay does not check what the node says, and cannot fail

```julia
_replay_pcp_shape(proof) = CheckResult(length(proof.gs) == 5 && length(proof.cs) == N, :pcp_shape; ...)
verifier_node = CertNode(CHECKED, :PCPVerifier;
    facts=(display="formula + zero tests = accept on certified views",), replay=_replay_pcp_shape)
```

The node the trace prints as *"formula + zero tests = accept on certified views"* replays an **arity**
check. Worse, that check is unfalsifiable by construction: `gs::NTuple{5,Poly{F,N}}` is type-enforced
and `build_pcp` already `throw`s at line 237 when `length(cs) != N`, so no reachable `PCPProof` can make
it fail. `DESIGN.md` §3 requires *"A CHECKED node must carry `replay = term -> CheckResult`"* precisely
so that grade/replay mutation tests can turn red; this one cannot.

**FIX DEMAND** — the replay must run `pcpverifier` on at least one stored certified view (e.g. `b_rho`
and one seeded point carried in the node's facts) and return its `CheckResult`; otherwise regrade the
node and change its displayed fact.
**SURVIVING WEAKER STATEMENT** — verifier acceptance *is* established, by the test suite; but
`verify_certificate` establishes only three things (degree accounts of `c_0`, the zero-basis coefficient
identity, quotient individual degrees `<= d`), and the printed trace overstates it.

---

### O8 · MINOR · `src/tb0.jl:212` — design-r4 DIRECTIVE (5) is discharged only implicitly

design-r4 NOTE (h) asked for an **explicit** assertion of the cumulative-vs-per-multiplication
distinction at witness (i). The code asserts `peak_ok = multiplication_peak(c0) <= 160_000` and a
refusal on an unrelated product (`mul_poly(farith, unit, |F_arith|-1)`, line 197–198); nothing computes
a cumulative sum. **My computation** for witness (i): the five `build_c0` candidate counts are
`[37240, 33432, 33432, 33432, 33432]` (char 2), cumulative **170,968**, plus `arith_q`'s
`[6,36,120,574,2660,18620,18620]` = **211,604** total, against a peak of **37,240** and a budget of
160,000 (over `Z`: peak 54,978, cumulative 251,986 — design-r4's 311,851 counts more products than
`tb0_build_fixture` performs). The distinction *is* red-capable indirectly (a cumulative reading would
refuse and `test/tb0_core.jl:174` would fail), which is why this is MINOR and not MAJOR.
**FIX DEMAND** — assert `cumulative > 160_000 >= multiplication_peak(c0)` for witness (i).
**SURVIVING** — `DESIGN.md` §1.3's "the budget is not a cumulative sum" is testable and would fail
loudly, but no test names it.

### O9 · MINOR · `src/verifiers/pcp.jl:47` — `parameter_policy` uses the natural logarithm where `def:pcpparams` 2(a)'s `log` is base 2

`gt-03-prelim.tex:20` states *"All logarithms are base 2."* The code writes
`growth = params.k <= 4log(params.s) ? FAIL : NOT_EVALUABLE`, i.e. `4 ln s`. For `s = 6` the correct
threshold is `4 log2 6 = 10.34`, the code's is `4 ln 6 = 7.17`. **My computation:** for `k = 9` — a
value `DESIGN.md` §5 explicitly reasons about — `def:pcpparams` 2(a) forces **FAIL** while the code
returns **NOT_EVALUABLE**. Neither TB0 row changes (`k=3` FAIL, `k=11` NOT_EVALUABLE under both).
**FIX DEMAND** — `4log2(params.s)`. **SURVIVING** — both reported six-predicate vectors are correct;
the FAIL region is understated by ~30% for other `k`.

### O10 · MINOR · `src/tb0.jl:6–16, 224–245`, `src/verifiers/pcp.jl:242–255` — constructor certificates are discarded and the derivation tree is never inspected

`tseitin` (`circuits.jl:260`), `arith_q` (`:390`), `g_a` (`sparse.jl:407`), `build_c0` (`pcp.jl:77`) and
`zero_basis_decompose` (`zero_basis.jl:96`) each build a `CertNode`; `tb0_build_fixture` keeps only
`.term` and throws every one away, and `build_pcp` hand-builds three fresh nodes. The printed trace is
therefore exactly four nodes and contains **no `ArithTseitin`**, which `DESIGN.md` §3's own example
trace lists (`[CHECKED] ArithTseitin | degrees = occurrences; inddeg = 6`). §3's normative sentence
*"Tests inspect the tree, not its prose: node sequence, grade, rule name, bound value/description,
dependency set, and source label are all matched"* is unimplemented: no test in `test/tb0_core.jl` reads
`.children`, `.grade`, `.rule` or any node's `facts`.
**FIX DEMAND** — thread the constructor certificates in as `build_pcp`'s children and add one test
asserting the node sequence and grades. **SURVIVING** — every fact the four nodes display is separately
asserted by the suite; only the tree, as the design's evidence object, is unverified.

### O11 · MINOR · `src/tb0.jl:197–198` vs `d196bdd:test/tb0_core.jl:271` — the budget red test was replaced by a trivial one

r0 asserted `build_c0(farith, gs; budget=MonomialBudget(148_175)) isa ExpansionRefused` under r0's
*estimate*-driven `mul_poly` (`d196bdd:sparse.jl:150`, `estimate = a.expected * b.expected`). r1 changed
`mul_poly` to the **actual** support product (`sparse.jl:208`), which is what `DESIGN.md` §1.3 specifies
(*"the single-product candidate count `|partial support|*|next factor support|`"*) — a genuine fix, but
an unrecorded semantic change to the `MonomialBudget` contract, and the sharp red test had to go. Its
replacement multiplies `F_arith` by the constant `1`, which never exercises the `build_c0` pipeline.
**FIX DEMAND** — assert `build_c0(farith, gs, MonomialBudget(37_239)) isa ExpansionRefused` and
`MonomialBudget(37_240)` succeeds (I verified 37,240 is the exact first-step candidate count), and
record the contract change in a response document.

### O12 · MINOR · `src/tb0.jl:213` — witness (i)'s measured support is never asserted

`support_ok = monomial_count(c0) <= 148_176` compares the measurement (33,432) against the *estimate*.
`DESIGN.md` §5 requires TB0 to "report its own normalized support"; it is printed but not pinned, while
witness (ii)'s 534,912 / 788,032 *are* pinned exactly (`test/tb0_core.jl:223–230`).
**FIX DEMAND** — `@test monomial_count(fixture8.c0) == 33_432` (and multiplication peak `== 37_240`).

### O13 · MINOR · `src/tb0.jl:194–195` — `deg_F = 6` and `gamma = 1` are literals, not derived

`parameter_policy(PCPParams(8,3,1,6,6,16), 6)` hard-codes the formula-occurrence bound `6`; C5 defines
it as *"the checked formula-occurrence bound"*, i.e. `maximum(occurrences(tf.formula, 16))`. Likewise
`PCPParams` carries no `gamma`, so `DESIGN.md` §5's *"All PCP rows fix `gamma=1`"* survives only as a
code comment at `src/verifiers/pcp.jl:36, 45–46`; conditions 2(a) and 2(c) both depend on `gamma`.
**FIX DEMAND** — derive `degree_formula` from the fixture and add `gamma` to `PCPParams`.

### O14 · MINOR · `src/verifiers/pcp.jl:222–231` — `_replay_pcp_degree` checks `<= d` for the quotients only

`def:pcp-proof` (`gt-10:1429–1443`) requires **all** of `g_1..g_5, c_0, ..., c_{m'}` to have individual
degree at most `d`. The replay checks `degree_accounts_valid` (structural vs actual) for all of them but
`<= proof.d` only for `proof.cs`. `lift_pcp` re-labels `d = 11` with no degree re-check at all.
**FIX DEMAND** — extend the `<= proof.d` quantifier to `gs` and `c0`. **SURVIVING** — on both TB0
witnesses `inddeg(c_0) = 6 <= d` and `inddeg(g_i) = 1`, asserted exactly elsewhere, so the fixtures are
compliant.

### O15 · MINOR · `briefs/14-tb0-repair.last.md` — the committed proposer report is the chat summary, not the report

The committed file is 7 lines of codex's closing message (including a self-referencing link to itself).
The actual T1–T6 disposition rows **and the MERGE PROPOSALS this verdict was briefed to adjudicate**
exist only inside `briefs/14-tb0-repair.codex.log` (the report body is the diff hunk at
`briefs/14-tb0-repair.codex.log:312796` ff.). I recovered them from there and adjudicate them in §4.
**FIX DEMAND** — commit the report body as `briefs/14-tb0-repair.last.md` so the merge proposals are
addressable outside a 14 MB log.

### O16 · MINOR · `test/mutations/run.jl:39–63` — the reported mutation-runner time is not reproducible

The report says *"`TB0 targeted mutations | 7 passed / 7 total | 30.9 s`"*. On my machine, quiet:
**6m12.0s** (373.25 s wall) and, on an immediate second run, **6m47.5s** (408.80 s). Each mutant is run
from a fresh `mktempdir()` project whose sources have new mtimes, so Julia re-precompiles
`MIPStarLambda` (~40–45 s) for every one of the seven — a cost that grew with `src/precompile.jl`.
**FIX DEMAND** — either report the runner's time on a cold depot, or pass
`--pkgimages=no`/`JULIA_PKG_PRECOMPILE_AUTO=0` to the mutant subprocesses and report the reduced figure.

### NOTEs (no fix demanded)

- **(a)** `test/tb0_core.jl` has duplicate testset labels — two `5b` (`:157`, `:187`), two `6a`
  (`:220`, `:330`), two `6b` (`:243`, `:348`) — and no `5c`. The printed summary and the
  `where-tested` pointers are ambiguous as a result.
- **(b)** Dead code: `pcp_seeded_report` (`src/tb0.jl:283`) is defined, exported and precompiled but
  never called; `pcp_eval` (`pcp.jl:312–313`) and `check_pcp_point` (`test/tb0_core.jl:143`) are never
  called. New mutation **N5** (drop the `prime_support` guard in `_multiply_terms`, `sparse.jl:194`)
  **SURVIVED — 93/93, 38.123 s**, confirming that guard is never exercised either (which is the same
  latent-optimisation class as O3, correctly guarded here).
- **(c)** `minimal_checkable_odd_k` (`pcp.jl:54–63`) omits `P_divisibility`, although `DESIGN.md` §5's
  minimality sentence names it. The answer is unchanged (`2^k % 16 == 0` for every odd `k >= 5`).
- **(d)** `pcp_boolean_cube_report` (`src/tb0.jl:315–336`) feeds `pcpverifier` a hand-built view with
  `beta = 0^16` rather than `ev_z(Pi, z)`. The substitution is *provably* harmless — `zero(z_i) = 0` for
  `z_i in {0,1}`, so step 5's RHS is `0` for any `beta` — and the code says so, but C1's phrase
  "accepted by `pcpverifier` ... on the Boolean subcube" is literally about a different view. What the
  sweep genuinely establishes, exhaustively, is `c_0 = 0` on all `2^16` Boolean points.
- **(e)** `def:pcp-eval` says `alpha_i = g_i(x_i)`; the code evaluates `g_i` on the full `m'`-vector.
  Faithful here because `Dependencies(g_i) = {X_i}` is separately asserted for witness (ii), but nothing
  enforces it in the general `ev_z` path.
- **(f)** Fidelity checks that **passed** and are not objections: `fig:pcpverifier` steps 4–5 exactly
  (`pcp.jl:317–333`, `(alpha_i - o_i)` and `sum beta_i z_i(1-z_i)`); `zero(x) = x(1-x)` per
  `prop:zero-basis`; the `d-2` bookkeeping (`zero_basis.jl:79`) and the `min(bound,1)` remainder
  bookkeeping (`:86`); the NW19 gadget `(g and w) or (not g and not w)` and the right-nested conjunction
  (`circuits.jl:202, 205–212`); the `w_out` literal (finding F2, `:249`); `g_a` per `eq:ld-encoding` and
  `dec` per `coded_H` (`gt-03:917–924`); `def:pcp-eval`'s ordering as `PCPView(z, alpha, beta0, beta)`.
  All five `gt-NN:Lx-Ly` citations in `src/` resolve to the labels they name.
- **(g)** Lane and ratchet discipline are clean: `git diff 7c76721 747f746` touches no `docs/`,
  `claims/`, `toys/` or `verdicts/` file, and no CLAIMS status was raised by the proposer (law 1 held).
  No `@assert` anywhere in `src/` or `test/`; no `/tmp` depot manipulation remains (T3 confirmed).
  `pcpverifier` and `build_c0` are layout-driven via `block_coordinates(..., :O)` with no `5 + i`
  remaining in either (T4 confirmed); I re-derived the `m=2` test's discriminating power by hand — with
  the old hard-coded `6:10` lookup, `z_6 = 0` makes the factor product `0 != beta_0 = 6`, so testset 7
  genuinely separates the two implementations.

---

## 2. Test and mutation summaries observed

Suite, warm depot, quiet machine (two consecutive runs after `Pkg.instantiate()`, 1.93 s):

```
Test Summary:  | Pass  Total  Time
MIPStarLambda  |   93     93  34.1s      TB0 total wall seconds = 34.558 (warning=45.0, hard_limit=60.0)
MIPStarLambda  |   93     93  33.9s      TB0 total wall seconds = 34.273 (warning=45.0, hard_limit=60.0)
EXTERNAL WALL 35.27 s / 35.00 s   MAXRSS 647,020 KB / 634,224 KB
```

Cold (fresh compile cache, unmutated code, nothing else running) — **see O1**:
`TB0 total wall seconds = 140.754`, hard-limit testset **FAILED**, exit 1, external wall 145.79 s.
Package precompilation alone measures 42–49 s in this environment.

Mutation runner (`julia --project=. test/mutations/run.jl`), run twice:

```
MUTANT A e-2_to_e-1                 target=zero_basis     => KILLED (exit=1)
MUTANT B omit_g2_minus_o2           target=pcp_separator  => KILLED (exit=1)
MUTANT C omit_output_literal        target=circuit        => KILLED (exit=1)
MUTANT D corrupt_field_reduction    target=field          => KILLED (exit=1)
MUTANT E w1_fanout_2_to_1           target=occurrence     => KILLED (exit=1)
MUTANT F degenerate_witness_ii_a3   target=nondegenerate  => KILLED (exit=1)
MUTANT C8 occurrence_ignores_fanout target=c8             => KILLED (exit=1)
TB0 targeted mutations | 7 passed / 7 total | 6m12.0s   (WALL 373.25 s)
TB0 targeted mutations | 7 passed / 7 total | 6m47.5s   (WALL 408.80 s)
```

All seven reproduce as KILLED; only the reported *time* does not (O16). Each mutant runs under its
DESIGN-named owning target, so no mutant is credited by an unrelated failure.

## 3. My new mutations (semantic; applied on copies, full suite each)

| id | mutation | site | outcome |
|---|---|---|---|
| **N1** | `g_i - o_i` -> `g_i - (1 - o_i)` (the brief's `o_i <-> 1-o_i` swap) | `pcp.jl:72` | **KILLED** (`ExpansionRefused`; `c_0` no longer vanishes on the cube; 35 passed / 4 failed / 23 errored) |
| **N2** | `zero(z) := z^2` in `fig:pcpverifier` step 5 | `pcp.jl:331` | **KILLED** (6 failures: both line reports, the 10,000 samples, both separators, the `m=2` verifier) |
| **N3** | `g_a` reverses the `m`-bit index order (`eq:ld-encoding` lexicographic identification) | `sparse.jl:396` | **SURVIVED — 93/93, 37.534 s** → **O4** |
| **N4** | total- instead of individual-degree quotient bound | `pcp.jl:225–226` | **KILLED** (`certificate_ok` false on both witnesses) |
| **N5** | drop the `prime_support` guard in `_multiply_terms` | `sparse.jl:194` | **SURVIVED — 93/93, 38.123 s** → NOTE (b) |
| **N6** | `build_c0` pairs `g_i` with the **reversed** sign block | `pcp.jl:71` | **KILLED** (6 failures incl. both support tuples and the cube) |
| **N7** | `ind` reverses the `m`-bit index order | `sparse.jl:381` | **SURVIVED — 93/93, 35.454 s** → **O4** |

Two further hand-built experiments, not textual mutations: replacing `c0.terms` by the empty dictionary
(200/200 accept) and deleting one monomial from it (300/300 accept) — **O5**; and the `GF(8)` quartic
search showing `zero_basis_decompose` is wrong on 150 of 512 subcube-vanishing inputs — **O3**.

*(N5's first run appeared to be killed by the wall gate at 76.5 s; on investigation that was my
harness precompiling inside the timed region — which is itself O1. Re-run with a pre-warmed cache it
survives. I report this rather than the misleading first reading.)*

---

## 4. Adjudication of the merge proposals (recovered from `briefs/14-tb0-repair.codex.log:312796` ff.)

The proposals were `C1, C2, C3, C8 -> TESTED` with `where-tested` pointers only.

### C1 — **HOLD**

**Missing steps, all three required before promotion:** (1) **O2** — no assertion that
`c_0(b_rho) != 0` for witness (ii), the design-r4 directive whose whole purpose is to keep the
"16 named coordinate lines" scope non-vacuous; (2) **O5** — `pcpverifier` never reads `c_0`'s sparse
expansion, so the row's acceptance evidence must be scoped to the factored proof object; (3) NOTE (d) —
the Boolean-subcube acceptance is obtained from a substituted `beta = 0^16` view, which is sound but is
not what the row's words say. Every *number* in C1 is confirmed (128 line points, 65,536 cube points,
10,000 samples + 16 separators, both witnesses, all accepted; coefficient identity exact) — the hold is
about what the acceptance evidences, not about whether it happened.

### C2 — **HOLD**

**Missing step: O6.** The clause *"including that `r=0` holds for exactly the 512 witnesses satisfying
`phi_C`"* has no checker anywhere; the remainder is computed for two witnesses, both satisfying, and no
`phi_C`-failing witness is exhibited with `r != 0`. Everything else in C2 is confirmed independently
(the coefficient identity and `r=0` for both witnesses; 128/896; 512; the `2^16` truth table). Add the
1,024-witness `r=0 <-> phi_C` test (O6's fix demand) and C2 is promotable as written; alternatively
narrow the clause to *"`r=0` is machine-checked for the two retained witnesses"*.

### C3 — **PROMOTE to TESTED**

Every displayed figure is independently reproduced by my implementation: the `F_arith` vector
`(2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)`; witness (i)'s `c_0` vector `(3,0,0,0,2,3,1,1,1,1,6,4,4,4,4,3)`,
`r=0`, `max_i inddeg(c_i)=6<=d` with equality at `d=6`, and **exactly** `c_2,c_3,c_4,c_7,c_8,c_9,c_10`
zero with the stated reason `deg_j(c_0)<=1` visible from the asserted `c_0` vector; witness (ii)'s
`c_0` vector `(3,1,1,1,3,3,1,1,1,1,6,4,4,4,4,3)`, `inddeg(c_0)=6`, every quotient `inddeg(c_i)<=6<=d`,
every `g_i` non-constant (a genuine two-point evaluation, `test/tb0_core.jl:247–248`) and
`Dependencies(g_i)={X_i}` exactly with no other block. Mutants E, F and C8 are the owning red tests and
all die. O3 and O4 do not reach these numbers (`m=1`; prime-subfield coefficients throughout).

**Authorized row text: the C3 row exactly as committed at `claims/CLAIMS.md:10`, unchanged, with status
`CONJECTURE -> TESTED`.** No word is to be added.
`where-tested`: `test/tb0_core.jl:330-344` (occurrence/degree equality, both structural and actual);
`test/tb0_core.jl:172-213` (`r=0`, quotient split, `max inddeg = 6`, certificate replay);
`test/tb0_core.jl:220-241`, `:243-252` (witness (ii) support, vectors, exact dependencies);
`test/mutations/run.jl` mutants E, F, C8 (all KILLED).
`verdict`: `verdicts/tb0-r1.md` (PROMOTE).
Promotion is consistent with the DAG only once C8 is also promoted, which it is below.

### C8 — **PROMOTE to TESTED, but SCOPED**

The proposal is to promote the row unchanged. That row states the occurrence formula and the
Schwartz–Zippel consequence without quantifier scope, and **the code establishes the formula on exactly
two circuit instances** — `tb0_circuit()` and `c8_two_gate_circuit()`. There is no property-based or
family check; `tseitin_occurrence_account` is compared with `occurrences` and with `actual_degrees` on
those two circuits only. The final clause about the `deg_F+5d` constant belongs to C5 (SKETCH) and is
not tested here. I independently confirm both instances — TB0's sixteen coordinates with equality, and
the two-gate vector `(2,2,2,4,3)` with `deg_w1 = 4 > 2`, refuting `prop:tseitin-arith-degree`.

**Authorized row text (apply verbatim; the only permitted adaptation is table escaping):**

> | C8 | (Refutation of `prop:tseitin-arith-degree`, findings F1/F2) For NW19 Tseitin arithmetized along the formula tree and conjoined with `w_out`, `deg_v(F_arith)<=occ_v`, where `occ_v` is the literal-occurrence count of `v` in the Tseitin formula. On the two machine-checked circuits that count is exactly `2 fanout(v)` for an input and `2+2 fanout(w_i)+indicator(i=out)` for a gate wire: the two-gate regression has degree vector `(2,2,2,4,3)`, in particular `deg_w1=4>2`, refuting the source's individual-degree-2 claim, and TB0 attains its displayed occurrence vector `(2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)` coordinatewise, with equality on all sixteen coordinates. Both the bound and the occurrence formula are machine-checked ON THESE TWO CIRCUITS ONLY; the general statement for arbitrary circuits is the derivation in `docs/findings.md` F1 and is NOT machine-established. On the same two instances `deg_v(c_0) <= occ_v(F_arith) + deg_v(prod_i (g_i - o_i))` is checked coordinatewise, which for the multilinear `g_i` used here adds at most 1 per coordinate. The consequence that the formula Schwartz--Zippel constant is `deg_F+5d` rather than `2+5d` is an inference carried by C5, not tested here. | TESTED | — | `docs/findings.md` F1,F2 | `test/tb0_core.jl:330-344`; `test/tb0_core.jl:347-359`; `test/mutations/run.jl` mutants E, C8 (both KILLED) | `verdicts/tb0-r1.md` (PROMOTE, scoped) |

---

## 5. Elegance — the three places the code is more complicated than the mathematics

1. **`src/verifiers/pcp.jl:88–172, 272–300` — `SharedEvalPlan` / `EvalDAGNode`.** ~120 lines of
   interned multivariate-Horner DAG, plus a second raw-`UInt16` evaluator (`_evaluate_shared_as`) that
   re-implements `GF(2^k)` multiplication and accumulation outside `src/fields/gf2k.jl`, to express one
   line of mathematics: `beta_j = c_j(z)`. *Simplification:* evaluate each `c_j` from its own `terms`
   with a single shared per-coordinate power table (~12 lines), and delete the `_as` path by building a
   real `Poly{GF2048,16}` once via `change_field` instead of the lazy `PrimeFieldPCPProof`. Testset 8
   already measures the direct `GF(2^11)` build at **1.9 s** — the whole lifting apparatus buys under
   two seconds.
2. **`src/polynomials/sparse.jl:50–67, 245–281, 321–341` + `src/ir/circuits.jl:333–357` — the
   evaluation-plan interpreter.** Six plan node types and three parallel recursions (`_evalplan`,
   `_evalplan_as`, `_change_plan`) constitute a *second* representation of every polynomial, although
   `DESIGN.md` §1.3 says the payload **is** `Dict{ExponentVector,FieldElement}`. *Simplification:*
   delete `Poly.plan` and evaluate from `terms`. That removes ~90 lines, removes the
   `FormulaEvalPlan`/`evaluate_arith_formula` code duplication, and — the real prize — makes **O5**
   unrepresentable, because the verifier would then read the same object whose support and degree
   vector the rung reports.
3. **`src/tb0.jl` (374 lines) — test assertions living in `src/`.** Ten `tb0_*_report` functions push
   the assertions into the library, so `test/tb0_core.jl:178–184` compares a fifteen-field NamedTuple
   and needs `Base.invokelatest` (`:175`, `:201`) to call freshly-included code, and
   `tb0_print_degenerate_report` interleaves six `println`s with the six booleans it returns.
   *Simplification:* keep only the fixture builders (`tb0_build_fixture`,
   `tb0_build_nondegenerate_fixture`, `tb0_base_point`) in `src/`, move the assertions back to `test/`
   as `d196bdd` had them, and make the printing a `traceprint`-style function. That also deletes the
   twelve `export tb0_*` lines and both `invokelatest` calls. (Minor kin: `_accumulate!` has two
   methods where one correct one suffices — O3 — and `mul_poly`/`arith_q`/`build_c0`/`build_pcp`/
   `lift_pcp` each carry a redundant keyword form, ten lines of pure duplication.)

---

## 6. Trajectory and verdict

First critic round on this rung. **7 MAJOR / 9 MINOR / 7 NOTE, 0 FATAL.** The rung's *arithmetic* is
in excellent shape: every headline number — the occurrence vector, both `c_0` degree vectors, 33,432 /
534,912 / 788,032, the seven-zero/nine-nonzero quotient split, all sixteen quotient supports and
degrees, `r=0` and the coefficient identity, the `2/1` and `96/48` separator values, `c_0(b_rho) != 0`,
the six `def:pcpparams` predicates, `minimal_checkable_odd_k = 11`, the modulus irreducibility, and the
lifted/direct agreement — reproduces exactly against a from-scratch implementation. The MAJORs are
about **what the green suite is evidence for**: a gate that is red on a clean machine (O1), a directive
not implemented (O2), a library routine that is wrong off the fixture's coefficient set (O3), a
surviving semantic mutation in the low-degree encoder (O4), acceptance tests that never read the object
whose numbers are reported (O5), a proposed row clause with no checker (O6), and a CHECKED certificate
node that cannot fail (O7). None of them refutes a TB0 figure; each of them changes what may be claimed.

C3 and C8 are promotable now (C8 with the scoping above). C1 and C2 need one cheap red test each, both
specified above, and then should promote in the next round.

VERDICT: FAIL(O1,O2,O3,O4,O5,O6,O7)
