# CRITIC verdict r2 — rung TB0 (`Project.toml`, `src/**`, `test/tb0_core.jl`, `test/mutations/run.jl` TB0 entries, clock lines of `test/runtests.jl`) at commit `2d91620` (TB0 code = `1a96917`)

Round 2 (adjudicate). Prior: `verdicts/tb0-r1.md` (O1–O16). Work order: `briefs/36-tb0-critic-r2.md`;
repair order `briefs/20-tb0-repair-r2.md` (whose "binding fix demands" list transposes the labels O3 and O5 relative to `verdicts/tb0-r1.md`; `briefs/36` inherits the transposition — **this verdict uses r1's numbering throughout, which is also what the response table uses**: O3 = the `zero_basis_decompose` prime-subfield bug, O5 = `pcpverifier` not reading `c_0`'s sparse expansion); response table + merge proposals recovered from
`briefs/20-tb0-repair-r2.codex.log:895099` ff. (see N6). Nothing that passed in r1 is re-litigated.

**Isolation.** `git archive 2d91620 | tar -x` into
`/tmp/.../scratchpad/critic-tb0-r2/tree/`; `Pkg.instantiate()` there; every run, probe and mutation is
in that copy or under `.../critic-tb0-r2/{indep,mut}/`. The live working tree (uncommitted TB1/TB2
repair) was never read or run. No repo file other than this verdict was written.

**Independence.** §0 is recomputed by a *new* from-scratch implementation written against `DESIGN.md`
§5 prose, `gt-03` `sec:ld-encoding`, `gt-10` (`def:tseitin` via `nw19-tseitin-arith.tex`,
`def:formula-arithmetization`, `prop:zero-basis`, `fig:pcpverifier`, `def:pcpparams`) — packed-nibble
16-variable sparse arithmetic over `Z` and over `GF(2)`, a fresh zero-basis divider, fresh carry-less
`GF(2^3)`/`GF(2^11)` arithmetic, a fresh verifier and a fresh zeta-transform cube sweep
(`.../indep/{tb0.py,run1..run5.py}`). It shares no code with `src/`, with `docs/`, or with r1's scratch.

---

## 0. Independent recomputation (brief obligations 1–5, plus the off-prime-subfield probe)

**(1) occurrence vector = actual individual-degree vector — CONFIRMED.**

```
occ(F_arith)             = (2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3)
account(2f / 2+2f+[out]) = (2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3)   match
inddeg(F_arith)          = (2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3)   over Z AND in char 2
support(F_arith) = 27,489 over Z / 18,620 in char 2 ; gadget terms [6,6,6,7,7,7]
128 present / 896 absent clauses ; 512 satisfying witnesses (exactly those with a_1[1]=1)
2^16 Boolean formula/trace mismatches = 0
```

**(2) witness supports, remainders, quotients — CONFIRMED, every printed figure.**

```
witness (i)  |c0| = 33,432 (char 2) / 49,252 (Z)   inddeg = (3,0,0,0,2,3,1,1,1,1,6,4,4,4,4,3)
             per-product candidates [37240,33432,33432,33432,33432]  peak 37,240  cumulative 170,968
             (over Z: [54978,49252,49252,49252,49252], peak 54,978)      r = 0, identity TRUE
             quotient supports [15638,0,0,0,4024,5516,0,0,0,0,4386,522,120,184,90,36]
             quotient inddeg   [6,-,-,-,5,5,-,-,-,-,4,4,3,4,3,1]   max_j inddeg(c_j) = 6
             zero quotients = c_2,c_3,c_4,c_7,c_8,c_9,c_10 (7 zero / 9 nonzero)
witness (ii) |c0| = 534,912 (char 2) / 788,032 (Z)  inddeg = (3,1,1,1,3,3,1,1,1,1,6,4,4,4,4,3)
             per-product candidates [37240,66864,133728,267456,534912]  peak 534,912
             r = 0, identity TRUE, max_j inddeg(c_j) = 6, same quotient degree profile
             quotient supports [250208,0,0,0,109536,71488,0,0,0,0,59344,7072,1536,2304,1440,576]
expected_support: 6^3*7^3*2 = 148,176 (i) and 6^3*7^3*2^5 = 2,370,816 (ii)
```

No disagreement with the report or with the assertions at `test/tb0_core.jl:350-357, 418-422`.
Cross-check against the *repository's own* code for the facts the suite no longer asserts (N4): a
direct `tb0_build_fixture(GF8, 6, ((0,1),(0,0),(0,0),(0,0),(0,0)), MonomialBudget(160_000))` gives
remainder `0`, `verify_zero_decomposition` **true**, zero quotients exactly `[2,3,4,7,8,9,10]` with
nine nonzero, `max_j inddeg(c_j) = 6`, quotient supports
`[15638,0,0,0,4024,5516,0,0,0,0,4386,522,120,184,90,36]`, `|c_0| = 33,432`, peak `37,240` — i.e.
identical to my Python and to the DESIGN figures, and identical at the DESIGN budget 160,000 and at
37,240. `passed(verify_certificate(Checked(fixture.proof, fixture.certificate)))` returns **true**, so
N4's fix demand is a working one-liner, verified.

**(3) `pcpverifier` at `b_rho` and `b_rho[O2<-rho]` — CONFIRMED in both fields, both witnesses.**

| witness | field | `F_arith(b_rho)` | `c_0(b_rho)` | accept @ `b_rho` | `beta_0` @ sep | RHS | honest `rho^5(1+rho)` | mutated `rho^4(1+rho)` |
|---|---|---|---|---|---|---|---|---|
| (i) | `GF(8)` | 1 | **1 != 0** | yes | **2** | 2 | 2 | 1 |
| (i) | `GF(2^11)` | 48 | **48 != 0** | yes | **96** | 96 | 96 | 48 |
| (ii) | `GF(8)` | 1 | **1 != 0** | yes | **2** | 2 | 2 | 1 |
| (ii) | `GF(2^11)` | 48 | **48 != 0** | yes | **96** | 96 | 96 | 48 |

My own verifier, on my own quotients, also accepts **128/128** points of the 16 named `GF(8)` lines
through `b_rho` for witness (i), and my own zeta transform confirms `c_0` vanishes at **all 65,536**
Boolean points.

**(4) moduli — CONFIRMED independently.** `0x00b` and `0x805` are irreducible by my own trial division
over every divisor of degree `1..k/2`; `ord(x)=7` and `ord(x)=2047`; `2047 = 23*89` and
`x^(2047/23) != 1`, `x^(2047/89) != 1`.

**(5) the six `def:pcpparams` predicates — AGREE exactly.**

| | `P_shape` | `P_growth` | `P_formula_paper` | `P_tail` | `P_divisibility` | `P_degree` |
|---|---|---|---|---|---|---|
| TB0-small `(8,3,1,6,6,16,gamma=1)` | PASS | FAIL | FAIL | FAIL | FAIL | FAIL |
| TB0-sampled `(2048,11,1,11,6,16,gamma=1)` | PASS | NOT_EVALUABLE | PASS | PASS | PASS | PASS |

plus `P_formula_structural` FAIL/PASS, `P_zero` PASS (sampled), `P_exponent_range` PASS (small,
`6<=7`), and `minimal_checkable_odd_k(6,16) = 11` (`k=9`: `2*(6+45)*16 = 1632 !< 512`). The base-2
`(gamma+3)log2(s) = 10.34` threshold is the correct one-sided reading of item 2(a) — **O9 discharged**.

**(6) `zero_basis_decompose` OFF the prime subfield — the r1 bug is genuinely FIXED.** My own probe
(`.../indep/gf2048_zerobasis.jl`, run against the archived tree):

```
A. 20,000 random GF(2^11) quartics c4 x^4+c3 x^3+c2 x^2+c1 x with c1=c2+c3+c4 (vanish on {0,1}):
   nonzero-remainder failures = 0   coefficient-identity failures = 0
B. 200 random 3-variable GF(2^11) polynomials built as sum_i q_i*zero(z_i) with every quotient
   coefficient drawn from {2,...,2047} (never in the prime subfield):
   200/200 have non-prime coefficients; remainder failures = 0; identity failures = 0
C. r1's counterexample x^3+2x^2+3x over GF(8): remainder = 0, identity = true
D. all 512 GF(8) subcube-vanishing quartics: 512/512 correct
E. non-vanishing input GF(2^11): remainder = 1 term, the identity WITH r reconstructs exactly,
   and verify_zero_decomposition correctly returns false
```

The guard `coefficient.bits == 1 && stored.bits <= 1` (`src/polynomials/zero_basis.jl:37`) is the
right one, and the same accumulator is used by the checker, so constructor and checker stay in step.

---

## 1. Adjudication of the r2 response table (`briefs/20-tb0-repair-r2.codex.log:895099` ff.)

| id | claimed | adjudication | evidence / exact residual defect |
|---|---|---|---|
| O1 | FIXED | **ACCEPTED (with N7)** | `test/runtests.jl:1-6` prints load/precompile ungated, `started=time()` is line 8, after `using MIPStarLambda`. Residual: the gated region was ALSO narrowed from all three rungs to `tb0_core.jl` alone (old `1a96917^:test/runtests.jl` timed tb0+tb1+tb2); the whole suite now runs **1m17.9 s** quiet (1m42.5 s loaded) and would be red under the old gate. Scope change, not in the fix demand → N7. |
| O2 | FIXED | **ACCEPTED** | `test/tb0_core.jl:439-442` (`!iszero(evaluate(fixture.c0, base8))` and the `GF(2^11)` analogue). Independently: `c_0^{(ii)}(b_rho)` = 1 and 48. Directive (5) at `:354`. |
| O3 | FIXED | **ACCEPTED** | See §0(6). Guard at `zero_basis.jl:37`; permanent family test `test/tb0_core.jl:108-123`; mutant **I** reintroduces the bug under target `zero_basis`. |
| O4 | FIXED | **ACCEPTED** | `test/tb0_core.jl:57` uses the asymmetric `[0,0,1,0]`; `:66` adds the `m=3` singleton `[0,0,0,0,1,0,0,0]`. `:59` compares against the cube enumerated `b1`-outermost, so the convention is pinned **independently of `ind`**; mutants **G** and **H** each reverse one side. |
| O5 | FIXED | **ACCEPTED** | `Poly.plan`, `_evalplan*`, `SharedEvalPlan`, `EvalDAGNode`, `_evaluate_shared_as`, `PrimeFieldPCPProof`, `lift_pcp` all deleted; `evaluate` (`sparse.jl:258-261`) and `_pcp_view` (`pcp.jl:128-137`) both read `poly.terms`; `line_values` and `boolean_cube_zero_report` read `terms`; `test/tb0_core.jl:390` pins `view.beta0 == evaluate(c0, z)`; empty-`terms` rejection at `:391-398`; mutant **J**. |
| O6 | FIXED | **REJECTED** | The replacement (`test/tb0_core.jl:140-146, 174-195`) is a De Morgan tautology and never touches `c_0`, `build_c0` or any remainder — **N1**. |
| O7 | FIXED | **ACCEPTED for `:PCPVerifier`** | `_replay_pcp_verifier` (`pcp.jl:148-158`) re-runs both equations on the stored views and is falsified by `test/tb0_core.jl:400-405` and mutant **L**. The *class* survives elsewhere — **N4**. |
| O8 | FIXED | **ACCEPTED** | `:354` `sum(counts) > 160_000 >= maximum(counts)` with `counts` pinned at `:353`. I confirm 170,968 / 37,240. Note: `c0_candidate_counts` (`:238-246`) uses the FINAL `|c_0|` for steps 2–5 rather than the true intermediates; for this fixture they coincide (verified), so the number is right but the helper is not the incremental sequence in general. |
| O9 | FIXED | **ACCEPTED** | `pcp.jl:48` `(gamma+3)*log2(s)`; matches `docs/definitions.md`'s 10.34 and gt-03's base-2 convention. |
| O10 | FIXED | **ACCEPTED as to the fix demand** | `tb0.jl:30-32` threads the six constructor certificates; `test/tb0_core.jl:380-387` matches all 11 rules and CHECKED grades. Residual (the replays are never *run*) → **N4**. |
| O11 | FIXED | **ACCEPTED** | `:350-351` `MonomialBudget(37_239)` refuses with `estimate == 37_240`, and the retained fixture is built at exactly 37,240 (`:215`). I confirm 37,240 is the exact first-product candidate count. Residual: the DESIGN-named budget 160,000 is now exercised by nothing → N7. |
| O12 | FIXED | **ACCEPTED** | `:355-357` pins 33,432 / 37,240 / 148,176 exactly. All three independently confirmed. |
| O13 | FIXED | **ACCEPTED** | `gamma` is `PCPParams`'s 7th field (`pcp.jl:10`); `degree_formula = maximum(occurrences(fixture.tf.formula, 16))` (`:339`). |
| O14 | FIXED | **PARTIAL** | `_replay_pcp_degree` (`pcp.jl:117-126`) now quantifies over `(gs..., c0, cs...)` — accepted. But `change_field` (`pcp.jl:199-208`) still relabels `d` with no re-check and returns a proof with **no certificate and empty `certified_views`**; mutations X2 and X3 survive — **N5**. |
| O15 | FIXED | **REJECTED** | `briefs/20-tb0-repair-r2.last.md` at `2d91620` is again 9 lines of the closing chat message, containing a link to itself. The 28-line response table and both merge proposals exist only inside the 41 MB codex log — **N6**. |
| O16 | FIXED | **ACCEPTED (measurement)** | The runner now strips later-lane modules (`run.jl:87-101`) and selects compile mode per target (`:116-122`) with `JULIA_PKG_PRECOMPILE_AUTO=0`. My own wall time is in §3. But the runner's kill predicate (`:129-133`) is what lets a broken testset be credited as a kill — **N2**. |
| NOTEs (a)–(g) | FIXED / DOWNGRADED / RESIDUE | **ACCEPTED** except (b) | (a) labels are unique; (c) `P_divisibility` added to `minimal_checkable_odd_k` (`pcp.jl:62`); (d) C1 now says the cube *vanishes* — honest and confirmed; (e) `ev_z` enforces the block guard (`pcp.jl:190-194`) — but `_pcp_view` is also called directly by `build_pcp:167` **without** that guard, so certified views bypass it (MINOR, folded into N4's fix). (b) dead code: `pcp_eval`/`pcp_seeded_report` are gone, but two whole testsets are now dead instead — **N2**, **N3**. |

---

## 2. New objections

### N1 · **MAJOR** · `test/tb0_core.jl:140-146` and `:174-195` — testset 4b "r=0 iff phi_C on all witnesses" is a **De Morgan tautology**; the ⟺ clause of C2 still has no checker (residual of O6)

```julia
function remainder_zero_fast(circuit, witness)          # test/tb0_core.jl:140-146
    for input in present_clauses(circuit)
        all(witness[i][Int(input[i]) + 1] != input[5 + i] for i in 1:5) && return false
    end
    true
end
```
against `phi_C` (`src/ir/circuits.jl:113-123`), which returns `false` exactly when some present clause
has `!any(witness[i][Int(input[i]) + 1] == input[5 + i] for i in 1:5)`. `all(a != b) == !any(a == b)`;
both loops range over the same 128 present clauses computed by the same `evaluate_circuit` over the
same `0:2^10-1` enumeration. So `iff_ok` at `:185` is **identically true for every circuit and every
witness**, and `zero_remainders` is by definition `satisfying`. The testset never calls `build_c0`,
`zero_basis_decompose`, `c_0`, `boolean_cube_zero_report`, or any remainder. Mutant **K** flips `!=`
to `==` inside the surrogate, which only shows the tautology is stated in that exact form.

**My computation** — the missing link, run through the *real* pipeline (`.../indep/run5.py`), is cheap:

```
witness            phi_C   |c_0|     |r|   r=0    c_0 vanishes on 2^16 cube
all-[0,0]          False   18,620      2   False   False        <-- 18,620 monomials, milliseconds
a1=[1,0], rest 0   False   35,336      2   False   False
a1=[0,0], rest 1   False  297,920     32   False   False
witness (i)        True    33,432      0   True    True
witness (ii)       True   534,912      0   True    True
```

The all-`[0,0]` remainder is exactly
`x1 x5 o1 o2 o3 o4 o5 w2 w3 w4 w5 w6 (1 + w1)` (two monomials).

**Confirmed through the repository's own code** (`.../indep/witness3.jl`, archived tree):
`tb0_build_fixture(GF8, 6, ((0,0),(0,0),(0,0),(0,0),(0,0)), MonomialBudget(160_000))` gives
`phi_C = false`, `|c_0| = 18,620`, peak `18,620`, **`|r| = 2`**, and
`verify_zero_decomposition` correctly **false**. So the missing test is a three-line addition that
passes and is red-capable today.

**FIX DEMAND** — add witness (iii) `((0,0),(0,0),(0,0),(0,0),(0,0))` to the fixture set and assert
`!isempty(...decomposition.remainder.terms)` and `!passed(verify_zero_decomposition(c0, decomposition))`
(the whole build is 18,620 monomials — a cold standalone process took 12.97 s including JIT, so the
marginal cost inside the already-warm suite is small; measure it), and assert
`boolean_cube_zero_report(c_0).zero == phi_C(circuit, witness)` for witnesses (i), (ii) and (iii) —
that is the sentence that connects the 1,024-witness surrogate to `c_0`.
Keep the 1,024-witness loop, but state in the row that it is a clause-relation count, not a
remainder computation.
**SURVIVING WEAKER STATEMENT** — `r = 0` and the coefficient identity are machine-checked for
witness (ii) only (see N4); the "exactly the 512" clause of C2 is a derivation plus a tautology, and
must be scoped as such until a `phi_C`-failing witness is exhibited with `r != 0`.

### N2 · **MAJOR** · `test/tb0_core.jl:322-333` + `test/mutations/run.jl:129-133` — **mutant B is a false kill**: its owning testset errors on UNMUTATED code

`mutation_b_separator` (`:314-320`) opens with `view = first(proof.certified_views)`, but
`change_field` (`src/verifiers/pcp.jl:207`) constructs its result with `certified_views = ()`.
Testset "5a. mutation-B formula separator" calls it on `proof11 = change_field(source.proof, ...)`
(`:327`). My run of the **unmutated** archived tree:

```
$ TB0_TARGET=pcp_separator julia --project=. test/tb0_core.jl
5a. mutation-B formula separator: Error During Test ... ArgumentError: tuple must be non-empty
Test Summary:                    | Error  Total   Time
5a. mutation-B formula separator |     1      1  19.9s
ERROR: LoadError: Some tests did not pass: 0 passed, 0 failed, 1 errored, 0 broken.   exit 1
```

The runner's kill predicate accepts `occursin("Some tests did not pass", output)`, which this error
prints, so **mutant B is reported KILLED whether or not the mutation is applied**. `DESIGN.md` §5.1
states normatively "No mutation is credited merely because an unrelated test fails", and mutant B is
the named owner of the `g_i - o_i` factor structure — the single most important red test of
`build_c0`. The testset is unreachable from `test/runtests.jl` (the guard is `TB0_TARGET ==
"pcp_separator"`, and the default is `"all"`), so it has never been observed green; it was working
introduced by this repair: the pre-repair `mutation_b_separator`
(`1a96917^:test/tb0_core.jl:145-154`) built the view with `ev_z(proof, z)`, which works on any proof.

**FIX DEMAND** — (a) repair the testset: build the `GF(2^11)` view with `ev_z(proof11, point)` (or
have `change_field` carry the certified points over); (b) make `copied_mutant` run the targeted
testset **unmutated first** and require exit 0 before crediting any kill — that is the permanent red
test for this whole defect class.
**SURVIVING WEAKER STATEMENT** — the defect mutant B is supposed to catch *is* caught, by testset 6d
(`:456-462`, honest `beta_0 = 2`, mutated value 1), which does run green; but the mutation-runner
line "MUTANT B ... => KILLED" carries no information: of the reported "TB0 14/14 killed", 13
are attributable and one is an artefact of a broken testset.

### N3 · **MAJOR** · `test/tb0_core.jl:476-494` — testset 7 (`layout_m2`) is **unreachable dead code**, and a mutation reverting the r1-confirmed layout fix SURVIVES

The guard was `if runs("layout_m2")` before the repair (`1a96917^:test/tb0_core.jl:302`) and is now
`if TB0_TARGET == "layout_m2"`. `TB0_TARGET` defaults to `"all"`, so the testset never runs in
`test/runtests.jl`; and **no mutant in `test/mutations/run.jl` uses that target** (`grep layout_m2`
matches only this one line in the whole tree). It is therefore unreachable from both documented
commands. r1 NOTE (g) had verified by hand that this testset is exactly what separates a
layout-driven sign block from a hard-coded `6:10`.

There are two layout-driven `:O` lookups. I mutated each to the hard-coded range:

| mutation | site | default suite (`TB0_TARGET=all`) | `TB0_TARGET=layout_m2` |
|---|---|---|---|
| **X1b** `sign_coordinates = block_coordinates(farith.layout, :O)` -> `6:10` in `build_c0` | `pcp.jl:71` | **SURVIVED, 71/71, exit 0** | **KILLED** (`Test Failed at :492, !(iszero(beta0))`, exit 1) |
| **X1** the same substitution in `pcpverifier` | `pcp.jl:214` | **SURVIVED, 71/71, exit 0** | **SURVIVED, 2/2, exit 0** |

X1b is exactly the defect testset 7 was written to catch — it dies there and nowhere else, and
testset 7 is reachable from neither documented command. X1 is worse: even with testset 7 restored the
verifier's own lookup has **no owning test at all**: the new testset 7 (`:476-494`) calls only
`build_c0` and `evaluate`, whereas the r1 testset also asserted `passed(report.verifier)`
(`1a96917^:test/tb0_core.jl:302-309`) — that assertion was dropped in the rewrite. Unmutated, `TB0_TARGET=layout_m2`
passes 2/2, so the testset itself is healthy — only unreachable.

**FIX DEMAND** — restore `if runs("layout_m2")`; add X1b as a permanent mutant with target
`layout_m2`; extend testset 7 with one `pcpverifier` call on the `m=2` layout (a hand-built `PCPView`
suffices) and add X1 as a second permanent mutant; and give testset "5a. mutation-B formula
separator" a `runs(...)` guard once N2 is repaired.
**SURVIVING WEAKER STATEMENT** — both layout-driven lookups *are* implemented correctly today;
nothing reachable from `test/runtests.jl` or `test/mutations/run.jl` would notice if either were
reverted to the TB0-specific constant.

### N4 · **MAJOR** · `test/tb0_core.jl:375-407`, `src/tb0.jl:30-32`, `src/ir/circuits.jl:260-267` — witness (i)'s zero-basis certificate is **no longer checked at all**, 9 of the 11 CHECKED replays are never invoked, and the `:Tseitin` replay cannot fail

`verify_certificate` is called exactly once in the whole rung — on the toy quartic of testset 3
(`:106`). It is never called on either TB0 proof. Testset 5c invokes only the **root** replay
(`:379`, `_replay_pcp_degree`, degrees only) and the `:PCPVerifier` replay (`:404-405`). Consequently:

- `verify_zero_decomposition` and `isempty(remainder.terms)` are asserted **only for witness (ii)**
  (`:423, :427`). For witness (i) there is no `r = 0` assertion, no coefficient identity, and no
  quotient-split assertion anywhere in the tree. The r1 tree asserted all of them
  (`1a96917^:test/tb0_core.jl:171-186`: `remainder_zero=true, quotient_split=true,
  quotient_degree=6, base_value_ok=true`).
- The trace nevertheless prints, unconditionally, `[CHECKED] ZeroBasis | remainder = 0; coefficient
  identity = true` — the string `coefficient identity = true` is a **literal** in
  `src/polynomials/zero_basis.jl:97` / `src/verifiers/pcp.jl:175`, not a computed fact.
- The `:Tseitin` node's replay (`circuits.jl:262-266`) compares `tf.occurrence_vector` against
  `occurrences(tf.formula, length(tf.layout.names))` — but `tf.occurrence_vector` was *set* by
  evaluating that same pure function on that same formula (`circuits.jl:256`). It is a tautological
  self-comparison. **My probe X4**: with `counts[node.variable] += 1` changed to `= 1`, the stored
  vector becomes `(1,0,0,0,1,1,0,0,0,0,1,1,1,1,1,1)` and the node still replays **`true`** — a CHECKED
  node that cannot fail, i.e. exactly the O7 defect at a different leaf.
- `_pcp_view` is called directly by `build_pcp:167` without `ev_z`'s block-locality guard, so the
  stored certified views bypass NOTE (e)'s check.

**My computation** — the facts that are no longer checked are all TRUE (§0(2)): witness (i) has
`r = 0`, exact coefficient identity, `max_j inddeg(c_j) = 6`, and exactly
`c_2,c_3,c_4,c_7,c_8,c_9,c_10` zero with nine nonzero. So no number is wrong; the *evidence* is gone.

**FIX DEMAND** — one line: `@test passed(verify_certificate(Checked(fixture.proof,
fixture.certificate)))` for **both** fixtures (`_bind_certificate` already binds each child to its own
term, so this runs all 11 replays); plus restore the witness-(i) assertions
`isempty(fixture.decomposition.remainder.terms)`,
`passed(verify_zero_decomposition(fixture.c0, fixture.decomposition))`,
`findall(isempty ∘ (q -> q.terms), quotients) == [2,3,4,7,8,9,10]`, and
`maximum(maximum(actual_degrees(q); init=-1) for q in quotients) == 6`; make `:Tseitin`'s replay
compare against the independent `tseitin_occurrence_account(circuit)` (which *is* falsifiable —
mutant C8 changes it), or regrade the node and change its displayed fact; and stop printing
`coefficient identity = true` as a literal.
**SURVIVING WEAKER STATEMENT** — the coefficient identity and `r = 0` are machine-checked,
red-capably, for witness (ii) only; the degenerate proof is supported by evaluation evidence
(128 line points, the 2^16 cube sweep, one certified view) and by the shared code path, not by its own
coefficient-wise certificate. **Proposed C1's clause "both retained PCP proofs are checked by formal
coefficient identities" is false as written**, and already-promoted **C3's** witness-(i) sentence
("its certificate checks `c_0=sum_i c_i zero(z_i)`, `r=0`, ... exactly `c_2,c_3,c_4,c_7,c_8,c_9,c_10`
zero ... and the other nine quotients nonzero") no longer has the machine evidence its row cites.

### N5 · **MAJOR** · `src/verifiers/pcp.jl:199-208, 148-151` — the `GF(2^11)` proof carries **no replayable certificate**, and both mutations of that fact survive (residual of O14)

`change_field(proof, GF2048, 11)` returns a bare `PCPProof` — no `Checked`, no certificate, empty
`certified_views` — and re-labels `d` from the argument without re-deriving or re-checking anything.
`def:pcp-proof` (`gt-10:1426-1442`) requires **all** of `g_1..g_5, c_0, ..., c_{m'}` to have individual
degree at most `d`. Nothing in the rung evaluates that for the sampled row, which is the object TB2/C9
consume (`test/tb2_answer_reduce.jl:32`).

- **My mutation X2** — `pcp.jl:207`, `PCPProof(gs, c0, cs, decomposition, d, proof.tf, ())` ->
  `... , 1, proof.tf, ())` (the `GF(2^11)` proof now claims individual degree `<= 1` while its `c_0`
  has individual degree 6): **SURVIVED, 71/71 passed, exit 0.**
- **My mutation X3** — `pcp.jl:149-151`, the `isempty(proof.certified_views)` branch of
  `_replay_pcp_verifier` returns `CheckResult(true, ...)` instead of `false`, i.e. a proof with no
  stored view replays as accepted: **SURVIVED, 71/71 passed, exit 0.**

**FIX DEMAND** — have `change_field` return a `Checked` whose root replay is `_replay_pcp_degree`
(and carry the certified points across the field change, which also repairs N2), and add
`@test passed(verify_certificate(changed))` plus a permanent mutant reproducing X2.
**SURVIVING WEAKER STATEMENT** — the `GF(2^11)` polynomials are the `GF(8)` polynomials with the
identical monomial support, whose degrees *are* asserted `<= 6 <= 11`; so `def:pcp-proof`'s degree
condition holds, but by inheritance argument, not by any check on the sampled object.

### N6 · MINOR · `briefs/20-tb0-repair-r2.last.md` — O15 recurs verbatim

The committed file is 9 lines of codex's closing chat message, including a link to itself, exactly as
in r1. The 28-line response table and the C1/C2 merge proposals — the documents this verdict was
briefed to adjudicate — exist only inside `briefs/20-tb0-repair-r2.codex.log` (report body at line
895,099 ff.). The response row for O15 claims "This addressable report contains the response and
proposals (`briefs/20-tb0-repair-r2.last.md:1`)", which is false of the committed file.
**FIX DEMAND** — commit the report body; this is an orchestrator/harness fix (the worker cannot
control what overwrites its report), so make the orchestrator extract and commit it after each run.

### N7 · MINOR · lockstep audit (rk-light law 2) — `docs/` and `claims/` did not move with the code

1. `docs/DESIGN.md` §5.1 item 5 still requires "Over `GF(2^11)`, run `pcpverifier` at at least 10,000
   seeded uniform `z` plus explicit separators on analogous lines", and the §5 parameter table still
   lists TB0-sampled's field-point scope as ">=10,000 seeded uniform `z`". The code no longer samples
   at all, and proposed C1 explicitly retracts it. The retraction is honest in the *claim*, but the
   single-source design document was not moved with it. (The repair lane excluded `docs/`, so this is
   an orchestrator obligation, not a worker fault.)
2. `docs/DESIGN.md` §1.3 and §5.1 name `MonomialBudget = 160,000` for witness (i); the fixture is now
   built at 37,240 (`test/tb0_core.jl:215`) and 160,000 is exercised by nothing. The code comment "the
   retained proof is identical under the design budget 160000" is unverified *by the suite*; I checked
   it and it is **true** (`|c_0| = 33,432`, peak `37,240` at budget 160,000), so this is a
   documentation/coverage gap, not an error.
3. **Stale `where-tested` pointers on two already-promoted rows.** `claims/CLAIMS.md` C3 cites
   `test/tb0_core.jl:330-344`, `:172-213`, `:220-241`, `:243-252`; in the r2 tree those ranges are
   inside `line_values`, `polynomial_fixture`, `proof11_fixture` and `c0_candidate_counts` — helper
   bodies, not tests. C8 cites `:330-344` and `:347-359`; its content now lives at `:499-511` and
   `:513-525`. C8's substance is intact; C3's witness-(i) substance is not (N4).
4. The 60 s gate now covers only TB0 (see O1 adjudication): the documented `test/runtests.jl` command
   takes **1m17.9 s** in total on a quiet machine, with no gate on the remaining ~40 s.
**FIX DEMAND** — in one commit: amend `DESIGN.md` §5.1 item 5 + the §5 table row to match the
retraction (or restore the sampling), re-point C3's and C8's `where-tested`, restate C3's witness-(i)
sentence if N4 is not repaired, and say explicitly in §5 whether the 60 s limit is per rung or per suite.

---

## 2b. Fidelity audit (checks that PASSED — no objection)

| ground truth | code | verdict |
|---|---|---|
| `fig:pcpverifier` step 4 (`gt-10:1548-1585`) | `pcp.jl:212-222`: `evaluate_arith_formula(tf,z)` then `*= alpha_i - z[o_i]` over `block_coordinates(layout,:O)` | faithful |
| `fig:pcpverifier` step 5, `zero(x)=x(1-x)` | `pcp.jl:224-228` | faithful |
| `def:pcp-eval` ordering `(alpha_1..5, beta_0..m')` | `PCPView(z,alpha,beta0,beta)` (`pcp.jl:91-96`) | faithful |
| `def:pcp-proof` degree condition on **all** `g_i,c_0,c_j` | `_replay_pcp_degree` (`pcp.jl:117-126`) | faithful — except for `change_field` output (N5) |
| `prop:zero-basis` rewrite, `d-2` and `min(bound,1)` bookkeeping (`gt-10:1281-1373`) | `zero_basis.jl:64-86`; coefficient-wise checker `:133-142` | faithful, and generically correct (§0(6)) |
| `eq:ld-encoding` big-endian lexicographic identification (`gt-03:873-897`) | `sparse.jl:326` (`ind`), `:342` (`g_a`) | faithful, now pinned by the asymmetric `m=2`/`m=3` tables |
| `coded_H` membership-or-zero (`gt-03:917-924`) | `dec` (`sparse.jl:360-374`) | faithful |
| `def:tseitin` via NW19: gadget, right-nested conjunction, `w_out` (finding F2) | `circuits.jl:198-212, 249` | faithful |
| `def:formula-arithmetization` (`gt-10:160-190`) | `circuits.jl:298-311, 314-331, 333-346` | faithful; my own `2^16` sweep agrees exactly |
| `def:pcpparams` items 1, 2(a)–(d), 3 (`gt-10:1396-1422`) | `pcp.jl:32-54` | faithful with the base-2 correction |

All five `gt-NN:Lx-Ly` citations in `src/` resolve to the labels they name (`prop:zero-basis`,
`def:pcpparams`, `fig:pcpverifier`, `sec:ld-encoding`, `def:formula-arithmetization`). No `@assert`
appears in `src/` or `test/` (the only match is a docstring). No CITED or ASSUMED leaf appears in the
TB0 derivation tree, as `DESIGN.md` §3 requires for C1–C4's machine-tested portion.

## 2c. Certificate honesty

Eleven CHECKED nodes; **two** replays are actually exercised (`:PCPProof` root and `:PCPVerifier`,
`test/tb0_core.jl:379, 404-405`) and **nine** are never invoked, because `verify_certificate` is never
called on a TB0 proof (N4). Of the nine, `:Tseitin`'s is unfalsifiable by construction (probe X4).
Two nodes display facts nothing replays: `:ZeroBasis`'s `coefficient identity = true` is a literal
string, and `:BuildC0`'s `inddeg`/`monomials` are formatted at construction. `:PCPVerifier`'s displayed
fact is now accurate ("accept on 1 stored certified views") — O7's specific repair is sound.

## 2d. Elegance — the three places the code is more complicated than the mathematics

1. **`test/tb0_core.jl` now carries three private re-implementations of library mathematics** —
   `line_values` (`:248-277`, a second polynomial evaluator, never cross-checked against `evaluate` at
   the base point), `boolean_cube_zero_report` (`:302-312`, a zeta transform), and
   `remainder_zero_fast` (`:140-146`, a surrogate for the zero-basis remainder). None is
   mutation-tested as library code, and one of them is N1. *Simplification:* move
   `restrict_to_line(poly, base, coordinate)` and `vanishes_on_cube(poly)` into `src/polynomials/`
   beside `evaluate`, assert `restrict_to_line(...)[index_of(base[j])] == evaluate(poly, base)` in one
   line, and delete `remainder_zero_fast` in favour of N1's witness (iii).
2. **Four code paths for "add/multiply in characteristic two."** `_accumulate!` has two methods
   (`zero_basis.jl:29-44`) and `_multiply_terms` two (`sparse.jl:166-181`); the fast paths are pure
   optimisations, one of which was the r1 bug and the other of which is exercised by exactly one
   assertion (`test/tb0_core.jl:127`) plus mutant M. *Simplification:* delete both fast paths — the
   generic versions are correct and the whole witness-(ii) build measures 7.5 s — or keep one and give
   it a property test over random non-prime coefficient sets (the shape of §0(6)B).
3. **Six module-level mutable caches to memoise two fixtures.** `POLY_CACHE`, `BUILD_STATS`,
   `PROOF11_CACHE`, `C0_11_CACHE`, `NONDEGENERATE_INTEGER_STATS` and the
   `(; fixture, integer_report)` wrapper returned by `tb0_build_nondegenerate_fixture`
   (`src/tb0.jl:39-49`), whose entire payload is the hard-coded literal `788_032` plus a timing.
   *Simplification:* build the two fixtures once into two `const`s at the top of the file, delete all
   six caches and the wrapper, and assert `788_032` directly in testset 6a. (`tb0.jl` then reduces to
   `tb0_circuit`-driven `tb0_build_fixture` and `tb0_base_point` alone.)

---

## 3. Test and mutation summaries observed

Suite, archived tree, warm depot (`Pkg.instantiate()` first). Two runs: the first while the
neighbouring TB1/TB2 lane was running its own Julia timing jobs on this host, the second with
`pgrep julia` empty (the brief's timing caveat).

```
RUN 1 (loaded machine)
MIPStarLambda load/precompile seconds = 0.488                (ungated -- O1 fixed)
TB0 test-body wall seconds = 52.414 (warning=45.0, hard_limit=60.0)
  |- Warning: TB0 test body exceeded its 45 s warning        <-- 45 s warning fired
TB0 60 s test-body hard limit (measured 52.414 s) | 1 Pass   <-- gate PASSES
Test Summary:  | Pass  Total     Time
MIPStarLambda  |  175    175  1m42.5s                        exit 0
EXTERNAL WALL  real 1m44.5s / user 1m43.8s

RUN 2 (quiet machine, no other julia process)
MIPStarLambda load/precompile seconds = 0.309                (ungated)
TB0 test-body wall seconds = 37.384 (warning=45.0, hard_limit=60.0)   <-- no warning
TB0 60 s test-body hard limit (measured 37.384 s) | 1 Pass
Test Summary:  | Pass  Total     Time
MIPStarLambda  |  175    175  1m17.9s                        exit 0
EXTERNAL WALL  real 1m19.6s / user 1m19.0s
```

**The gate is green on a quiet machine** — 37.384 s, consistent with the proposer's reported warm
38.469 s; O1's repair holds and the 52.414 s reading is load, not regression (NOTE only, per the
brief's caveat). The *suite* total (1m17.9 s quiet / 1m42.5 s loaded) is no longer gated at all
(N7.4). Executed testsets: 1, 2, 3, 4a, 4b, 5a(policy), 5b, 5c, 6a, 6b, 6c, 6d, 8, 9 — i.e. testsets
"5a. mutation-B formula separator" and "7. layout-driven sign block for m=2" do **not** run
(N2, N3).

Mutation runner (`julia --project=. test/mutations/run.jl`), same tree, same load:

```
MUTANT A e-2_to_e-1 target=zero_basis => KILLED (exit=1)
MUTANT B omit_g2_minus_o2 target=pcp_separator => KILLED (exit=1)
MUTANT C omit_output_literal target=circuit => KILLED (exit=1)
MUTANT D corrupt_field_reduction target=field => KILLED (exit=1)
MUTANT E w1_fanout_2_to_1 target=occurrence => KILLED (exit=1)
MUTANT F degenerate_witness_ii_a3 target=nondegenerate => KILLED (exit=1)
MUTANT C8 occurrence_ignores_fanout target=c8 => KILLED (exit=1)
MUTANT G g_a_reverse_bit_order target=encoding => KILLED (exit=1)
MUTANT H ind_reverse_bit_order target=encoding => KILLED (exit=1)
MUTANT I restore_GF2k_accumulator_bug target=zero_basis => KILLED (exit=1)
MUTANT J ev_z_ignores_c0_terms target=c0_terms => KILLED (exit=1)
MUTANT K witness_iff_reverses_factor target=witness_iff => KILLED (exit=1)
MUTANT L PCPVerifier_replays_degree_only target=certificate => KILLED (exit=1)
MUTANT M drop_nonprime_multiply_guard target=nonprime => KILLED (exit=1)
MUTANT TB1 M-χ shift_bucket_boundary target=tb1_histogram_axis => KILLED (exit=1)
MUTANT TB1 M-π omit_prefix_projection target=tb1_histogram_diagonal => KILLED (exit=1)
MUTANT TB1 M-lnf noncanonical_complement target=tb1_histogram_diagonal => KILLED (exit=1)
MUTANT TB1 M-deg axis_accepts_md target=tb1_degree => KILLED (exit=1)
MUTANT TB1 M-level omit_inductive_increment target=tb1_levels => KILLED (exit=1)
MUTANT TB2 c0_plus_one_formula target=tb2_formula => KILLED (exit=1)
MUTANT TB2 g3_plus_one_individual_only target=tb2_proof_consistency => KILLED (exit=1)
MUTANT TB2 truncate_line_polynomial target=tb2_line => KILLED (exit=1)
MUTANT TB2 M-guard Point_ALine_to_Point_DLine target=tb2_guard => KILLED (exit=1)
MUTANT TB2 M-i345 extend_to_i12 target=tb2_i345 => KILLED (exit=1)
TB0 targeted mutations |   14     14  6m56.3s
TB1 targeted mutations |    5      5  8m30.9s
TB2 targeted mutations |    5      5  9m07.1s
real	24m37,745s
user	47m32,581s
sys	0m30,103s
exit=0
```

All 24 lines exit nonzero and the runner exits 0. Two caveats. (i) Mutant **B**'s kill is an
artefact: its owning testset errors identically with and without the mutation (N2, proved by running
the mutant-B copy alone — same `ArgumentError: tuple must be non-empty`, same
`0 passed, 0 failed, 1 errored`), so the honest count for the TB0 block is **13 attributable kills out
of 14 lines**. (ii) The 24m37s wall is not a performance datum: the neighbouring lane was running its
own `test/mutations/run.jl` concurrently for most of it (`user` 47m32s over `real` 24m37s reflects the
per-mutant subprocesses). O16's *mechanism* fix (module stripping, `--compiled-modules=no`,
`JULIA_PKG_PRECOMPILE_AUTO=0`, a 12-line skippable `precompile.jl`) is in place and is accepted; the
TB0 block alone is 6m56.3s under that load. The TB1/TB2 blocks belong to the neighbouring lane and are
reported only for completeness.


## 4. My new mutations (semantic, applied on copies, full `TB0_TARGET=all` run of `test/tb0_core.jl`)

| id | mutation | site | outcome |
|---|---|---|---|
| **X1** | `pcpverifier` locates the sign block by hard-coded `6:10` instead of `block_coordinates(layout, :O)` | `src/verifiers/pcp.jl:214` | **SURVIVED — 71/71, exit 0; also survives `TB0_TARGET=layout_m2` (2/2)** → **N3** |
| **X1b** | the same substitution inside `build_c0` | `src/verifiers/pcp.jl:71` | **SURVIVED the default suite — 71/71, exit 0**; KILLED only by the unreachable testset 7 → **N3** |
| **X2** | `change_field` labels the `GF(2^11)` proof `d = 1` while `inddeg(c_0) = 6` | `src/verifiers/pcp.jl:207` | **SURVIVED — 71/71, exit 0** → **N5** |
| **X3** | `_replay_pcp_verifier` accepts a proof with **no** stored certified view | `src/verifiers/pcp.jl:149-151` | **SURVIVED — 71/71, exit 0** → **N5** |
| **X4** (probe, not a suite run) | `occurrences` counts each variable at most once (`+= 1` -> `= 1`) | `src/ir/circuits.jl:218` | `:Tseitin` CHECKED replay still returns **true** on the wrong vector `(1,0,0,0,1,1,0,0,0,0,1,1,1,1,1,1)` → **N4** |

Plus the unmutated probes that produced N2 and N3: `TB0_TARGET=pcp_separator` on clean code **errors,
exit 1**; `TB0_TARGET=layout_m2` on clean code passes 2/2 but is never reached.

---

## 5. Per-claim decisions

### C1 — **HOLD** (two named missing steps)

**Is the narrowing honest?** (brief obligation) — **Yes, with one exception.** The proposed row's
retractions are exactly right and exactly law 5: it drops witness-(ii) all-line acceptance, `GF(2^11)`
*verifier* acceptance, the substituted-view Boolean-cube acceptance (r1 NOTE (d)), the `10^4` random
`GF(2^11)` points, all-field completeness and soundness. Every one of those is genuinely no longer
performed by the code, and the stronger 10^4-point statement is tracked as `mipstar-lambda-yqw`.
Everything the row *does* assert, I reproduced independently: 128/128 acceptances on the 16 named
`GF(8)` lines through `b_rho`, `c_0` zero at all 65,536 Boolean points, `c_0^{(ii)}(b_rho)` = 1 and 48,
the `GF(8)` separator 2 (mutated 1) and the `GF(2^11)` separator 96 (mutated 48).

**Missing steps:**
1. **N4** — the row's opening clause "**both** retained PCP proofs are checked by formal coefficient
   identities" is **false**: `verify_zero_decomposition` runs only on witness (ii) (`:427`), and
   `verify_certificate` is never called on either proof. Either add the one-line
   `@test passed(verify_certificate(Checked(fixture.proof, fixture.certificate)))` for both fixtures
   (which makes the clause true), or narrow the clause to witness (ii).
2. **N2** — the row cites mutants **B**, J, L as its red tests; mutant B is credited by a testset that
   errors identically with and without the mutation. Repair the testset, or drop B from the row.

*Also for the promoting commit*: the sampling retraction must land in `docs/DESIGN.md` §5.1 item 5 and
the §5 table in the same commit (N7.1) — otherwise the DESIGN document keeps asserting an obligation
the code and the claim have both dropped. NOTE (no fix demanded): the 128 line acceptances are computed
by the test-local `line_values`, which is never cross-checked against `evaluate`; I reproduced the
128/128 with my own evaluator, so the number is right, but the row rests on an un-cross-checked second
evaluator.

### C2 — **HOLD** (one named missing step)

**Missing step: N1.** The clause "including by the equivalent 128-present-clause test that `r=0` holds
for exactly the 512 witnesses satisfying `phi_C`" is discharged by a De Morgan tautology that never
touches `c_0` or any remainder. Add witness (iii) `((0,0),(0,0),(0,0),(0,0),(0,0))` through the real
`build_c0`/`zero_basis_decompose` (18,620 monomials, `|r| = 2`, `verify_zero_decomposition` false —
all three verified by me against the repository's own code) and the
`vanishes_on_cube(c_0) == phi_C(...)` comparison, and C2 is promotable as proposed; otherwise narrow
the clause to "the 1,024-witness clause-relation count is 512, and `r = 0` is machine-checked for the
retained witnesses."

Everything else in the proposed C2 is independently confirmed: the coefficient identity and `r = 0`
for witness (ii) (and, mathematically, for witness (i) — but see N4 for its missing checker); the
`2^16` truth table; 128/896; 512; and that the general correspondence stays CITED. Its cited mutants A
and I are correctly owned; K only mutates the surrogate.

### C3 — **HOLD** (re-affirmation withheld; row currently unsupported by this tree)

C3 is already `TESTED`, promoted by `verdicts/tb0-r1.md` against commit `747f746`. I do not lower a
status (law 1: only the author may), but I record that in the tree under review the row is not
supported:

- Its witness-(i) sentence — "*its certificate checks `c_0=sum_i c_i zero(z_i)`, `r=0`, and
  `max_i inddeg(c_i)=6<=d` (with equality on TB0-small), with exactly `c_2,c_3,c_4,c_7,c_8,c_9,c_10`
  zero ... and the other nine quotients nonzero*" — has **no machine checker anywhere** (N4). Every one
  of those facts is TRUE (I recomputed all of them, §0(2)); none is asserted.
- All four `where-tested` ranges are stale and now point at helper-function bodies (N7.3).

**Two admissible repairs, either of which restores the row verbatim:** (a) apply N4's fix demand and
re-point `where-tested` to the new line numbers; or (b) the author strikes the witness-(i) certificate
sentence and the row is re-scoped to witness (ii)'s vectors plus the occurrence/degree equalities. I
will re-affirm C3 at r3 under either. Mutants E, F and C8 remain correctly owned by live, green
testsets (8, 6a–6d, 9).

### C8 — **RE-AFFIRM `TESTED`; pointer correction only**

Substance intact and independently re-confirmed: TB0's occurrence vector
`(2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)` with equality on all sixteen coordinates
(`test/tb0_core.jl:499-511`), and the two-gate vector `(2,2,2,4,3)` with `deg_w1 = 4 > 2`
(`:513-525`). Mutants E (target `occurrence`, testset 8) and C8 (target `c8`, testset 9) are both
owned by testsets that run green in the default suite.

**Authorized row text: the C8 row exactly as committed at `claims/CLAIMS.md:17`, unchanged.** No word
is to be added or removed. The only permitted edit is the `where-tested` cell, which must become:
`test/tb0_core.jl:499-511`; `test/tb0_core.jl:513-525`; `test/mutations/run.jl` mutants E, C8 (both
KILLED). `verdict`: `verdicts/tb0-r1.md` (PROMOTE, scoped); `verdicts/tb0-r2.md` (re-affirmed).

---

## 6. Trajectory

r1: 7 MAJOR / 9 MINOR / 7 NOTE. r2: **5 MAJOR / 2 MINOR, 0 FATAL**, of which two (N1, N5) are
residuals of r1 objections and three (N2, N3, N4) are **regressions introduced by the repair** —
two testsets silently removed from every reachable run, and witness (i)'s certificate assertions
deleted along with the report library. Severity is falling and the arithmetic remains impeccable:
every headline figure — the occurrence vector, both `c_0` degree vectors, 33,432 / 534,912 / 788,032,
the candidate-count sequences and both peaks, all sixteen quotient supports and degrees, the
seven-zero/nine-nonzero split, `r = 0` and the coefficient identity for both witnesses, `c_0(b_rho)`,
the `2/1` and `96/48` separators, the 128 line points, the `2^16` cube, the six predicates,
`minimal_checkable_odd_k = 11`, and both moduli — reproduces exactly against a from-scratch
implementation, and the r1 zero-basis bug is genuinely and generically fixed. Every r2 MAJOR is again
about **what the green suite is evidence for**, and each has a one-to-five-line fix.

VERDICT: FAIL(N1,N2,N3,N4,N5)
