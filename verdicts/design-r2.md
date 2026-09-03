# CRITIC verdict r2 — `docs/DESIGN.md`, `docs/definitions.md` (adjudication round)

Round 2 (adjudicate). Prior: `verdicts/design-r1.md` (FAIL, 13 MAJOR / 11 MINOR / 7 NOTE).
Work order under review: `docs/design-repair-r1-response.md` (27 FIXED / 1 RETRACTED / 3 DOWNGRADED / 0 RESIDUE)
and `briefs/06-design-repair.md`. Scope: `git diff da54528 HEAD -- docs/DESIGN.md docs/definitions.md`
(421 insertions, 254 deletions). `src/` and `test/` are another worker's lane and were not read.

Every number below is my own recomputation. Scratch:
`/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-.../scratchpad/critic-design-r2/`
(`tb0.jl`, `tb0b.jl`, `tb0c.jl`, `tb0d.jl`, `tb0e.jl`, `muta.jl`) — independent 16-variable sparse
polynomial arithmetic over `Z` with a `mod 2` image, plus `GF(2^3)` and `GF(2^11)` evaluation
(`x^3+x+1`, `x^11+x^2+1`, `rho = x`). No code from the design or from `src/` was used.

**Standing credit is preserved.** r1's resolution of all 78 `gt-NN:Lx-Ly` citations still holds. I
additionally resolved the 17 citations added by the repair (`gt-03:L231-L239`, `gt-03:L836-L840`,
`gt-04:L590-L595`, `gt-10:L1226-L1246`, `L1379-L1383`, `L1404-L1408`, `L1409-L1412`, `L1412-L1413`,
`L1413-L1414`, `L1414-L1416`, `L1860-L1965`, `L1944-L1946`, `L1990-L1999`, `L1993-L1999`,
`L2001-L2071`, `L2027-L2047`, `L2048-L2053`): all land on the named object. One is off by three
lines (see NOTE a).

---

## 0. Recomputation of the TB0 fixture (brief obligation 2)

Circuit `w1=NOT x1; w2=NOT w1; w3=NOT w1; w4=w2 AND w3; w5=w4 AND o1; w6=w5 AND x5`, so
`C = x1 AND o1 AND x5` and `fanout(w1)=2`. Variable order `(X1..X5, O1..O5, W1..W6)`, `m=1`, `s=6`,
`m'=16`, witness `a_1=[0,1]`, `a_2=...=a_5=[0,0]`.

| design claim (`DESIGN.md` §5, §5.1, §1.3) | my recomputation | verdict |
|---|---|---|
| present / absent clauses `128 / 896` | 128 / 896 out of 1024 | **CONFIRMED** |
| satisfying five-block witnesses `512` | 512 of 1024; all and only those with `a_1[1]=1` | **CONFIRMED** |
| named witness satisfies `phi_C` | yes (present clauses all have `x_1=1,o_1=1`) | **CONFIRMED** |
| occurrence vector `(2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3)` | identical, from the formula tree | **CONFIRMED** |
| actual `inddeg` vector of `F_arith` **equals** the occurrence vector | identical over `Z` **and** over char 2 | **CONFIRMED** |
| actual `inddeg` vector of `c_0` `(3,0,0,0,2, 3,1,1,1,1, 6,4,4,4,4,3)` | identical over `Z` and char 2; `inddeg(c_0)=6` | **CONFIRMED** |
| `F_arith(b_rho) = rho^4 (1+rho)`, nonzero | `GF(8)`: both sides `= 1`; `GF(2^11)`: both sides `= 48`; nonzero | **CONFIRMED** |
| mutation B (`remove g_2-o_2`) killed at `b_rho` with `O2=rho` | honest `beta_0` = verifier RHS = `2` (`GF(8)`) / `96` (`GF(2^11)`); mutated `beta_0` = `1` / `48` -> **reject** | **CONFIRMED** |
| ...and *not* killed at `b_rho` itself | at `O2=1` honest and mutated both give `1` / `48`: no separation | **CONFIRMED — the design's conditioning on `O2=rho` is necessary, not decorative** |
| `expected_support(c_0) <= 6^3*7^3*2 = 148,176` pre-normalization | gadget term counts measured `[6,6,6,7,7,7]`; estimate reproduces exactly | **CONFIRMED** |
| normalized monomial count "must be measured" | **measured: 49,252 over `Z`; 33,432 over char 2 (`GF(8)`/`GF(2^11)`)**; `|support(F_arith)| = 27,489 / 18,620` | **MEASURED (design correctly refused to predict it)** |

**Is `deg = occ` really true for NOT gadgets?** Yes, and I checked it symbolically rather than
trusting the design's sentence. For `z = (¬a ∧ w) ∨ (a ∧ ¬w)`, `arith_q(z) = a + w - 3aw + aw^2 +
a^2 w - a^2 w^2`; the coefficient of `a^2` is `w - w^2 != 0` and of `w^2` is `a - a^2 != 0`, so
`deg_a = deg_w = 2 = occ`. In characteristic 2 the polynomial becomes `a + w + aw + aw^2 + a^2 w +
a^2 w^2` and both leading coefficients (`w+w^2`, `a+a^2`) are still nonzero — no cancellation. The
AND gadget gives `1 - ab - w + abw + a^2b^2w + abw^2 - a^2b^2w^2` (7 terms), `deg_a=deg_b=deg_w=2`.
Since `F_q[X,O,W]` is an integral domain the per-variable degrees add over the six gadget factors
and the `w6` literal, reproducing `(2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)` exactly. The design's stated
reason is the correct reason.

**Additional facts I computed that the design does not state** (all used below):

- zero-basis decomposition: remainder `r` is the zero polynomial and
  `c_0 == sum_i c_i * zero(z_i) + r` holds coefficientwise. `|support(c_i)| =
  [24976,0,0,0,6232,9945,0,0,0,0,7407,713,176,208,90,36]` over `Z`
  (`[15638,0,0,0,4024,5516,0,0,0,0,4386,522,120,184,90,36]` over char 2).
- **seven quotients vanish** (`c_2,c_3,c_4,c_7,c_8,c_9,c_10`) — exactly the coordinates with
  `deg_j(c_0) <= 1`. **Nine are nonzero, including all six `W` quotients.** This is a real repair of
  r1's M3 (there, ten vanished and the whole `W` block was zero).
- quotient bounds of §1.4 all hold: `deg_j(c_i) <= D_j`, `deg_i(c_i) <= D_i-2`, `deg_j(c_i) <= 1`
  for `j<i`; `max_i inddeg(c_i) = 6 = d`.
- `totaldeg(F_arith) = 31`, `totaldeg(c_0) = 36`, `max_i totaldeg(c_i) = 34` — all far inside the
  `(deg_F+5d)m' = 976` and `m'd = 176` bounds.
- F1 two-gate regression (`g1=x1∧x2`, `g2=w1∧x3`, output literal `w2`): occurrence vector and actual
  degree vector are **both** `(2,2,2,4,3)`; `deg_w1 = 4 > 2`. C8's counterexample stands.
- mutation A (`e-2 -> e-1` in the rewrite) breaks the coefficient identity on both the §5.1 item-3
  fixture `f = x^3-x^2+xy^2-xy` (whose honest decomposition I checked has `r = 0`) **and** on TB0's
  `c_0`, while leaving the remainder empty — so it is killed by the identity replay and by nothing
  else, exactly as §5.1 assigns it.
- mutation C (omit `w6`): without the output literal, `exists w. F(x,o,w)=1` holds for **all** 1024
  inputs, so the 896 absent inputs break the circuit/Tseitin truth table. Killed as assigned.
- mutation E (`fanout(w1) 2 -> 1`): structural occurrence for `w1` becomes `4` while measured degree
  is `6`, so `structural >= actual` goes red. Killed as assigned.
- M1's vacuity is gone: over `GF(8)`, `zero(z)=z(1-z)` vanishes at only 2 of 8 points, and the
  all-zero proof is separated at `b_rho` (verifier RHS `= 48 != 0 = beta_0`).

---

## 1. Disposition audit (brief obligation 1)

### MAJOR

| id | claimed | my verification | verdict |
|---|---|---|---|
| M1 | DOWNGRADED | No `q=2` row, no `TB0-tiny`, no "exhaustive PCP" claim survives (grepped). `GF(8)` scope is named ("16 named coordinate lines `S_j`"), `GF(2^11)` is sampled. At `q=8` the zero test is non-vacuous (`zero` vanishes at 2/8 points) and the all-zero proof is separated at `b_rho`. | **VERIFIED** |
| M2 | FIXED | Five mutations, each with one owning rung + checker. I independently killed A (coefficient identity, both fixtures), B (`GF(8)` and `GF(2^11)` formula test at `O2=rho`, **not** at `b_rho`), C (truth table), E (occurrence/support comparison). D (field-axiom sweep) is structural and uncontested. | **VERIFIED** |
| M3 | RETRACTED | The `(prod x_i o_i)^2` fixture is gone; `F_arith = arith_q(tseitin(C) ∧ w_out)` genuinely depends on `W` (all six `W` quotients nonzero). The retraction is real. **But** the second half of r1's fix demand — "state exactly which quotients are identically zero and which ground-truth contracts the fixture does not exercise" — is not discharged; see **R3**. | **VERIFIED (retraction) / carried forward as R3** |
| M4 | DOWNGRADED | `deg_v(F_arith) <= occ_v` replaces the occurrence-<=-2 gate (DD-18); the occurrence and degree vectors, `deg_F=6`, `inddeg(c_0)=6`, `d>=6` and the `(deg_F+5d)m'` constant all recomputed above and all correct. | **VERIFIED** |
| M5 | FIXED | `eq:V-pcp` (`gt-10:L1897-L1913`) gives `V_{6,coord} = (⊕_{i=1..5} V_{i,coord}) ⊕ V_{aux,coord}` with each summand `≅ F_q`, i.e. **dimension 6**; `V_{aux,pt/dir} ≅ F_q^{5+s}` so `dim V_{6,pt} = dim V_{6,dir} = m'`. Both files now say 6; the `table:tpcp` conflict is recorded and `chi` reads `V_aux,coord` under a visible `SOURCE_REPAIR` (DD-20). | **VERIFIED** |
| M6 | FIXED | `CLStep` takes disjoint coordinate-index sets only; the general-subspace branch and the rank certificate are deleted (no occurrence of "rank" remains). `def:register-subspace` (`gt-03:L231-L239`) and the `{0,1}^s` factor-space format (`gt-04:L590-L595`) both cited correctly. | **VERIFIED** |
| M7 | FIXED | `Hole(name,sort)` is in the grammar; `Closed` = scoped + hole-free; `Specialize : PartialProgram x StaticEnv -> ClosedProgram` total on a sort-correct environment; `Fix` requires the `self_code : Quoted{Decider}` hole; `D_M_L = Fix(Psi_M_L)`. All four fix demands discharged. Residue: three symbols in the term still have no production/sort — see **R5**. | **VERIFIED (with R5)** |
| M8 | FIXED | Checked line by line against source: `thm:introspection` (`gt-08:L784-L817`, 5-level, `poly(n,λ,ℓ)`, `poly(2^{λn},ℓ)`, `poly(λ,ℓ)`, hypotheses λ-bounded ℓ-level); `thm:ar` (`gt-10:L2077-L2116`, `eq:ar-params-1` `T=(2^{λn})^μ`, `Q=(λn)^μ`, `eq:ar-time-assumption`, `n>=2`); `thm:repetition` (`gt-11:L226-L258`, `k(n)=(λn)^{(1+c')τ}`, `ℓ+2`, completeness needs `TIME_D<=(λn)^τ`); `thm:compression` (`gt-12:L26-L53`, unconditional 9-level + `poly(n,λ)` + sampler independence, completeness/soundness need λ-bounded 9-level, `n>=C_0`, `N=2^n`). Every hypothesis is now carried. | **VERIFIED** |
| M9 | FIXED | `@enum Grade CONSTRUCTED CHECKED CITED ASSUMED SOURCE_REPAIR`. I extracted every status/grade cell of every table in `DESIGN.md`: all 30 are exactly one of the five. `ASSERTED` occurs zero times; none of r1's eleven pseudo-grades survives; the §4.1 tree and §3 trace printer use only `[CHECKED]`/`[CONSTRUCTED]`/`[CITED]`. Every `CertNode` carries a grade and CHECKED requires `replay`. | **VERIFIED** |
| M10 | DOWNGRADED | The six predicates match `def:pcpparams` (`gt-10:L1396-L1422`) item for item, and the tuple-formation rule ("smallest odd `k` satisfying 2--5") is correct. `k=11` arithmetic all reproduced: `(2+55)·16/2048 = 912/2048`, `(6+55)·16/2048 = 976/2048`, `k=9` gives `752/512` and `816/512`, zero test `208/2048`; `16 | 2048`; `P_tail` `11·16/2048 = 11/128 < 1/6 <= 6^{-b'}` for `0<b'<1`. **But** the evaluability semantics are self-contradictory and one report entry is wrong — see **R1**. | **VERIFIED (arithmetic) / NOT VERIFIED (predicate semantics) — R1** |
| M11 | FIXED | `detype :: Checked{VerifierIR,CitedCert}` is in §2; `AnswerReduce = detype ∘ answer_reduce_pcp`. `lem:detyping-verifiers` (`gt-06:L444-L475`) confirms `+2` levels, `16^{|Type|}` soundness loss, value-1 completeness preservation. `Type^ar = Type^ora x Type^pcp` = `3 x 18 = 54`, so `16^54`; `max(ℓ,3)+2 = max(ℓ+2,5)` is algebraically right and matches `thm:ar`. | **VERIFIED** |
| M12 | FIXED | `Q_len` cited to `gt-10:L1379-L1383` ("x and y are a pair of strings of length at most Q each", `Q <= T`); `Q_time` to `eq:ar-time-assumption` (`L1820-L1825`, `TIME_S(n) <= Q(n)`); `eq:ar-params-1` equality recorded; `pcpverifier`'s spec tuple uses `Q_len`. | **VERIFIED** |
| M13 | FIXED | Transcription checked **guard by guard** against `gt-10:L1985-L2063`. All six `table:tpcp` question and answer formats are verbatim correct. Step 1 `t_alice=t_bob`; step 2 `(oracle, v)` + `(Point_6, Point_v)`; step 3 `t_Q,w=t_Q,wbar=v` + `(Point_v, ALine_v/DLine_v)`, `ldparams=(q,m,d,1)`; step 4 `t_Q,w=t_Q,wbar=oracle` with (a) `(Point_i,Point_6)`, `i∈{3,4,5}`, (b) `(Point_i,ALine_i/DLine_i)`, `i∈{3,4,5}`, (c) `(Point_6,ALine_6/DLine_6)` with `ldparams'=(q,m',d,m'+6)`; step 5 `t_Q,w=oracle`, `x_{w,v}=L^v(x_{Q,w})`, `t_Pi,w=Point_6`, `pcpverifier(...)`. The `alice<->1, bob<->2` remark and the omitted `sigma` are both carried. No guard, index restriction, or `ldparams` tuple is missing or altered. | **VERIFIED** |

### MINOR

| id | claimed | my verification | verdict |
|---|---|---|---|
| m14 | FIXED | `seed_dim` column present; TB1 `seed_dim = 2m+1 = 5`, `8^5 = 32,768`. | **VERIFIED** |
| m15 | FIXED | `definitions.md` `d` row: "claimed upper bound ... never the measured degree"; §1.4 prints `inddeg(c_0)=6` separately from `d=6` / `d=11`. | **VERIFIED** |
| m16 | FIXED | §1.5 now says the 18 maps are one typed family, each level 1/2/3 on all of `V^pcp` zeroing other registers, padded to common level 3, "not a product of six samplers" — matching `gt-10:L1920-L1941`. Merge proposal C4 carries the same wording. | **VERIFIED** |
| m17 | FIXED | `P_exponent_range: d<=q-1` named in §2 and `definitions.md`, cited to `gt-03:L836-L840` (exponents in `{0,...,q-1}`). TB0-small `6<=7`, TB0-sampled `11<=2047`, TB1 `1<=7`. | **VERIFIED** |
| m18 | FIXED | `SuccinctDecoupled5SAT` carries `N_1..N_5`; equal `m`-blocks are the padded subtype via `prop:explicit-padded-succinct-deciders` (`gt-10:L1226-L1246`); DD-17. Matches `def:decoupled-5sat` (`gt-10:L948-L979`). | **VERIFIED** |
| m19 | FIXED | §5.3: reference draws the axis uniformly and builds `line(u_0,e_i)` directly from `lem:alnf`/`lem:dlnf`; `chi` is mutated only in the CL implementation. | **VERIFIED** |
| m20 | FIXED | §5.2 is a wrapper around `toys/midpoint/`, reusing implementation, tests, mutations and proof. | **VERIFIED** |
| m21 | FIXED | `restrict_to_line(p,u0,v) :: Checked{UnivariatePoly,RestrictCert}` in §2 with `<=d` (axis) / `<=m*d` (diagonal), the formats `fig:ld-decider` compares. | **VERIFIED** |
| m22 | FIXED | Risk replaced by (i) no-op type-pair frequency over `54^2 = 2916` and (ii) per-question strategy rebuild; seeded questions conditioned on triggering guards. The corrected size claim `m'+6 = 22` univariates of degree `<= m'd = 176`, `22*177 = 3,894` field elements, is arithmetically right. | **VERIFIED** |
| m23 | FIXED | The dispatch mutation is deleted and replaced by composition-order/level-chain (`5 -> 7 -> 9`) and missing-replay mutations, both semantic. | **VERIFIED** |
| m24 | FIXED | (a) DD-12 and every hash field are gone (zero occurrences of "hash"); CHECKED is now `replay = term -> CheckResult` recomputed at test time. (b) `Closure`/`UEval`/`Specialized` are a three-line remark; only `Quoted` and `CircuitIR` are IR types. (c) `BoundExpr ::= Concrete(Int) | Opaque(description,parameters)`. DD numbering preserved (DD-12 left as a deliberate gap, new DDs are DD-17..DD-21). | **VERIFIED** |

### NOTE

| id | my verification | verdict |
|---|---|---|
| n25 | §1.5 states ALine's two stages and DLine's coordinate/direction/point three-stage order separately. | **VERIFIED** |
| n26 | `Prim(halts_within, Opaque("n steps",(n,)), M, n)` — the static `Bound` is now opaque, not a host integer. | **VERIFIED** |
| n27 | DD-21 makes `Levels` the end-to-end index; the chain `Introspect -> 5`, `AnswerReduce: 5 -> 7`, `Repeat: 7 -> 9`, `Compress: 9 -> 9` is exactly `fig:compress` (`gt-12:L75-L92`, `ComputeIntroVerifier(V,λ,9)`). | **VERIFIED** |
| n28 | `P_divisibility` is explained as `chi` forming `m'` equal buckets for copy 6, cited to `gt-10:L1944-L1946` ("the classical low-degree test parameterized by `q` and `m'`"). Correct reading. | **VERIFIED** |
| n29 | §7 risk 5 now names the correct side of both typos: `F_q^{m'}` at L1709-L1715 and `alpha_i=g_i(x_i)` at L1725. | **VERIFIED** |
| n30 | `L_lnf(0)=identity` retained as `SOURCE_REPAIR`; §5.3 still tests zero directions. | **VERIFIED** |
| n31 | `16^{|Type^ar|} = 16^54` evaluated, and its absorption located *only* in `thm:ar`'s universal constant `a`, never dropped from the detyping certificate. | **VERIFIED** |

**Handoff coverage.** The eight items r1 marked *inadequate* are now addressed: explicit IR/D1 (§1.1
`Hole`/`Fix`), sampler/D2/D5 (§1.5, DD-19/DD-20), verifier contracts (§1.6 ASSUME/PROVE), query
number and form (`table:tpcp` + guard table), pipeline completeness (`detype`, `restrict_to_line`),
D3 (real six-gate Tseitin), consistency checks (exact guards), D8 (§7 risk 9's ordered completion
path). I re-checked each against the section named in the response table; all are present.

---

## 2. New objections (new text only; 3 MAJOR, 2 MINOR)

### R1 · MAJOR — the `ParameterPolicy` evaluability rule contradicts the §5 reports, and TB0-small's `P_growth` entry is wrong
**Location** `DESIGN.md` §2 ("unknown universal constants give 2 and 4 grade `CITED` and checker
result `NOT_EVALUABLE`, never PASS") vs §5 (the two six-predicate reports).

**Independent computation.** §2 numbers the predicates `1 P_shape, 2 P_growth, 3 P_formula_paper,
4 P_tail, 5 P_divisibility, 6 P_degree`, and rules that **2 and 4** are always `NOT_EVALUABLE`.
§5 then prints `P_tail=PASS` for TB0-sampled and `P_tail=FAIL` for TB0-small. A checker cannot
satisfy both sections; the assertions §5.1 requires ("Print ... all six policy predicates") are
untestable as specified, and TB0-small's `P_tail=FAIL` — one of the rung's printed assertions —
would never fire.

§5 is the correct half. `P_tail` **is** decidable over the whole admissible constant range:
`def:pcpparams` fixes `0 < b' < 1` (`gt-10:L1402-L1403`), so `s^{-b'γ} = 6^{-b'} ∈ (1/6, 1)`;
at `k=11`, `11·16/2048 = 11/128 = 0.0859 < 1/6` (PASS for every `b'`), and at `k=3`,
`3·16/8 = 6 > 1` (FAIL for every `b'`). Both are determined.

Worse, the design applies the wrong rule in the other direction. **TB0-small's `P_growth` is not
`NOT_EVALUABLE`; it is FAIL for every admissible `(a',b')`.** With `γ=1`, `s=6`, the requirement is
`k >= (1 + 3a'/b')·log 6`, and `a' > 1`, `b' < 1` force `a'/b' > 1`, so the right-hand side exceeds
`4·log 6` — `10.34` in base 2, `7.17` in base e — while `k = 3`. No admissible constants make it
true. (At `k=11` it genuinely is `NOT_EVALUABLE`: `a'/b' ∈ (1, 1.085)` would satisfy it and
`a'/b' > 1.085` would not, so the design's entry there is right.)

**FIX DEMAND.** Define `NOT_EVALUABLE` as "not determined by the predicate over the whole admissible
range of the universal constants", delete §2's blanket "2 and 4 ... never PASS" (keep it for
`P_growth` only, and only as a possible outcome), and correct TB0-small's report to
`P_shape=PASS, P_growth=FAIL, P_formula_paper=FAIL, P_tail=FAIL, P_divisibility=FAIL, P_degree=FAIL`.

**SURVIVING STATEMENT.** With `γ=1`, `m'=16`, `s=6`: at `q=2^11` five of the six predicates are
determined and PASS and only `P_growth` is undetermined; at `q=8` five are determined and FAIL,
`P_growth` is determined and FAILS, and `P_shape` PASSes. `k=11` is the smallest odd `k` satisfying
`P_formula_paper` and `P_divisibility` under either formula constant, as the design computes.

---

### R2 · MAJOR — `deg_F` is treated as a constant, so §4.1's repaired Schwartz–Zippel inequality is graded CHECKED although the installed parameter policy does not imply it
**Location** `DESIGN.md` §4.1 (`ParameterInequality((deg_F+5d)m'/q < 1/2)` `[CHECKED]`), §2
(`P_formula_structural`), §7 risk 5; merge proposal C5/C8.

**Independent analysis.** §4.1 is explicitly "a derivation, not a numerical experiment" — a general
statement, not a TB0 statement. In it, `deg_F` is "the checked formula-occurrence bound", i.e.
`max_v occ_v(F)`, and my occurrence law (verified above) gives `occ(w_i) = 2 + 2·fanout(w_i) +
[i=out]`, so `deg_F <= 2·fanout_max + 3` and is **unbounded in the circuit**, not the constant 6.
Meanwhile `def:pcpparams` selects `k` from item 2(b), which contains the literal `2`, not `deg_F`.
Nothing in the design's `ParameterPolicy` therefore guarantees `(deg_F+5d)m'/q < 1/2` in general —
yet the node is graded `CHECKED`, which under §3 obliges a replay function that would have to fail
on some admissible input. This is precisely the C8 consequence the campaign exists to surface, and
it is recorded nowhere: §7 risk 5 lists the `deg_F` vs `2` mismatch as a source *typo-class* repair.

The repair is cheap, because item 2(a) absorbs it. `def:pcpparams` 2(a) forces
`k >= ((γb'+3a')/b')·log s > 4 log s`, hence `2^k > s^{4 log 2}` (`s^4` in base 2, `s^{2.77}` in base
e). With `deg_F <= 2s+3` and `m' = O(s)`, `(deg_F+5k)m'/2^k = O(s^2/s^{2.77}) -> 0`. So the
structural predicate is *implied* by the growth predicate for all large `s`, and the repair changes
only small-instance parameter selection — but this must be stated, not left as an open discrepancy
next to a `CHECKED` grade.

**FIX DEMAND.** In §4.1 regrade `ParameterInequality((deg_F+5d)m'/q < 1/2)` from `CHECKED` to
`CHECKED (fixture) / ASSUMED (general)`, and add one DD recording (i) `deg_F <= 2·fanout_max + 3`,
(ii) that `def:pcpparams` chooses `k` from the literal-2 predicate, and (iii) the absorption argument
above with the `m' = O(s)` hypothesis stated explicitly. Do not fold (iii) into the C8 row.

**SURVIVING STATEMENT.** For TB0 the repaired inequality is genuinely checked:
`(6+55)·16/2048 = 976/2048 < 1/2`, and the measured total degree of the formula difference is 36,
three orders of magnitude inside the bound. For general circuits `deg_F` depends on fan-out, and the
repaired inequality follows from `def:pcpparams` item 2(a) only under a stated `m' = O(s)` relation.

---

### R3 · MAJOR — the TB0 witness makes four of the five `g_i` identically zero, which empties C3's block content and TB2's step-4b, and is silently what keeps the fixture inside `MonomialBudget`
**Location** `DESIGN.md` §5 (witness choice), §5.1 item 5, §5.4; merge proposal C3.

**Independent computation.** The design picks `a_1=[0,1]`, `a_2=...=a_5=[0,0]`, so
`g_1 = X_1` and `g_2 = g_3 = g_4 = g_5 = 0`. Consequences the design does not state:

- C3's "each `g_i` is multilinear in block `X_i` only" is exercised **only for `i=1`**; for
  `i=2,...,5` the zero polynomial satisfies it vacuously and its `Dependencies` set is empty.
- `fig:decider-pcp` step 4(b) restricts `i` to `{3,4,5}` — precisely the three blocks whose `g_i`
  are identically zero. TB2's "individual low degree test" therefore runs on three zero polynomials,
  and step 4(a) compares `alpha_i = alpha'_i = 0`.
- exactly seven quotients vanish (`c_2,c_3,c_4,c_7,c_8,c_9,c_10`, the coordinates with
  `deg_j(c_0) <= 1`); nine including all of `W` are nonzero. r1's M3 fix demand required this list
  to be printed in §5. It is derivable from the displayed degree vector, but it is not stated.
- **the degeneracy is load-bearing for the budget.** I rebuilt `c_0` with a non-degenerate witness
  (`a_1=[0,1], a_2=[1,0], a_3=[0,1], a_4=[1,0], a_5=[0,1]` — also satisfying, since every witness
  with `a_1[1]=1` satisfies `phi_C`): degree vector `(3,1,1,1,3,3,1,1,1,1,6,4,4,4,4,3)`,
  `inddeg` still 6, but **normalized support 1,773,072 over `Z` / 1,203,552 over char 2**, with a
  candidate estimate of `6^3·7^3·2^5 = 2,370,816` — an order of magnitude past
  `MonomialBudget = 160,000`. So the design's chosen witness is the only kind that fits the budget,
  and that trade-off is invisible in the document.

**FIX DEMAND.** State in §5 (i) that `g_2..g_5 = 0` for the chosen witness and which contracts are
consequently vacuous (C3's block locality for `i != 1`, `fig:decider-pcp` 4(a)/4(b) for
`i ∈ {3,4,5}`), (ii) the list of vanishing quotients with the reason `deg_j(c_0) <= 1`, and
(iii) the measured cost of the non-degenerate alternative, so that the budget choice is a recorded
design decision rather than an accident. Either that, or shrink the circuit until a witness with
five non-constant blocks fits the budget. C3 may not be promoted until (i) is in the row.

**SURVIVING STATEMENT.** For this fixture the degree/dependency report is fully verified where it
has content: the occurrence and actual degree vectors of `F_arith` coincide on all sixteen
coordinates, those of `c_0` coincide on all sixteen, `inddeg(c_0)=6`, every `c_i` has
`inddeg <= 6 = d`, and `g_1 = X_1` is multilinear in block `X_1` only. Nine of sixteen quotients are
nonzero and the whole `W` block is exercised — a genuine repair of M3.

---

### R4 · MINOR — `MonomialBudget` has no defined accounting, and the §5 table conflates the estimate with the measurement
**Location** `DESIGN.md` §1.3 ("estimate candidate products before multiplying ... return
`ExpansionRefused(estimate,budget)`"), §5 table column "`c_0` / target time = `<=148,176 measured`".

**Independent computation.** Under the per-multiplication reading the incremental candidate counts
for TB0 are `[6, 36, 162, 756, 3927, 27489, 27489, 54978, 49252, 49252, 49252, 49252]`, peak
**54,978** — comfortably inside 160,000. Under a cumulative reading the total is **311,851**, which
**exceeds** the budget and would make TB0 return `ExpansionRefused`. The document does not say which.
Separately, the table cell `<=148,176 measured` prints the pre-normalization *estimate* in the column
whose header the design elsewhere insists must hold a *measurement*; the measurements are
**49,252 (`Z`) / 33,432 (`GF(8)`, `GF(2^11)`)** for `c_0` and 27,489 / 18,620 for `F_arith`.

**FIX DEMAND.** State that `MonomialBudget` bounds the candidate count of a **single** product
(`|partial| * |factor|`), record the peak 54,978 as the design-time prediction, and replace the table
cell with `estimate 148,176 / measured` so the estimate and the measurement never share a slot.

**SURVIVING STATEMENT.** `MonomialBudget = 160,000` is adequate for TB0 under the per-multiplication
reading with 66% headroom, and the design is right that the normalized count must be measured rather
than predicted — the estimate overshoots it by 3.0x over `Z` and 4.4x in characteristic 2.

---

### R5 · MINOR — `Psi_M_L` still uses three symbols with no production or sort (residue of M7)
**Location** `DESIGN.md` §1.1 grammar and the `Psi_M_L` display.

**Independent analysis.** The grammar is `P ::= BoundVar | Hole | Lambda | Apply | Fix | If | Prim |
Quote | Eval | Specialize`, and the declared data are `Name`, `PrimName`, `Nat`, `StaticEnv`. The
displayed term uses (i) `true` as the then-branch of `If`, and there is no literal/constant
production; (ii) `(n,x,y,a,b)` as `Eval`'s `Pargs`, and the grammar never says `Pargs` is a list of
`P`; (iii) `FuelBound(n,L)` as `Eval`'s `Fuel`, and `Fuel` is neither a production nor one of the
four declared data sorts. Each is one line to fix (`true = Prim(true, Concrete(1))`, `Pargs : P*`,
`Fuel` added to the data list) and none affects the mathematics, but as written the flagship term is
still not literally derivable from the grammar — the exact defect M7 named.

**FIX DEMAND.** Add `Pargs : P*` and `Fuel` to the sort declarations and either add a `Const`
production or state that nullary `Prim` is the literal form.

**SURVIVING STATEMENT.** With `Hole`, `Closed`, total `Specialize` and `D_M_L = Fix(Psi_M_L)` in
place, the fixed-point equation of `handoff.md:L21-L39` is now expressible; only three surface sorts
are undeclared.

### NOTEs (no fix demanded)

- **(a)** `table:tpcp` is cited as `gt-10:L1990-L1999` in both files; the rows actually span
  `L1987-L1998` (`L1990` starts inside the second row). r1 introduced this range, so it is not
  charged against the repair.
- **(b)** "an untriggered guard accepts" is cited to `gt-10:L2001-L2071`. The literal sentence
  "In all cases where no action is indicated, accept" is in `gt-07:L368` (`fig:ld-decider`);
  `fig:decider-pcp` only says "Otherwise, accept" inside step 5. The semantics claimed are right;
  the citation is a reading, not a quotation.
- **(c)** TB0's circuit contains three NOT gates, while `fig:pcpverifier` step 1 describes the padded
  circuit as containing "at most `s` AND and OR gates". `s=6` counts all six gates and `m'=16` is
  consistent, and `briefs/06` authorized NOT gates; but §5 does not disclose the divergence the way
  §5.5 discloses TB3's.
- **(d)** Merge proposal C1 says "coordinate subcube" where §5.1 item 5 says "16 named coordinate
  lines `S_j`". Aligned in the authorization below.

---

## 3. Adjudication of the MERGE PROPOSALS (brief obligation 6)

No status is promoted in this round; every row stays at the status the response proposes. Apply the
authorized text verbatim.

**C1 — AUTHORIZED, with `subcube` -> `line` (NOTE (d)).** Exact row text:

```markdown
| C1 | For the explicit real six-gate TB0 instance, the constructed PCP proof Pi is checked by formal coefficient identities, accepted by `pcpverifier` on every one of the 16 named `GF(8)` coordinate lines `S_j` through `b_rho` and on the Boolean subcube, and accepted at at least 10^4 uniformly sampled `z in GF(2^11)^16` plus named branch-directed points. This is completeness evidence, not an exhaustive all-`z` or soundness claim. | CONJECTURE | C2,C3,D1 | — | — | — |
```

**C2 — AUTHORIZED, with the dropped quantifier restored.** The proposal replaces the old row's
`r == 0 iff the witness satisfies phi_C` with the vaguer "check the ... correspondence". The `iff` is
true and checkable, and I verified both directions: if the witness satisfies `phi_C` then every
present clause has some `g_i(x_i)=o_i`, so `c_0` vanishes on `{0,1}^16` (confirmed: the
multilinearization of `c_0` is the zero polynomial) and the rewrite returns `r=0`; if it does not,
the falsifying present clause `(x,o)` together with its true wire assignment `w` gives
`c_0(x,o,w) = 1 != 0`. Exactly 512 of the 1024 witnesses satisfy `phi_C`. Exact row text:

```markdown
| C2 | (Zero-basis certificate) For `c_0` built from `arith_q(tseitin(C) and w_out)` in TB0, the multilinearization rewrite produces `c_1,...,c_16` with `c_0=sum_i c_i zero(z_i)` as a formal coefficient identity and zero multilinear remainder. Exhaustive Boolean truth tables over all `2^16` assignments and all `2^10` candidate five-block witnesses check the circuit/Tseitin/`phi_C` correspondence for this fixture, including that `r=0` holds for exactly the 512 witnesses satisfying `phi_C`; the general correspondence remains CITED. | CONJECTURE | D1 | — | — | — |
```

**C3 — HOLD.** Both displayed vectors are exactly right (I recomputed them over `Z` and over
characteristic 2, and both equal the structural occurrence bound). The missing step is R3(i): the row
asserts "each `g_i` is multilinear in block `X_i` only" without disclosing that `g_2=...=g_5=0` for
the TB0 witness, so four fifths of that clause is vacuous, and "each quotient is checked against `d`"
does not say what relation is checked (measured: `max_i inddeg(c_i) = 6 = d`, and seven quotients are
identically zero). Re-propose with the degeneracy and the relation named.

**C4 — AUTHORIZED verbatim.** Every clause checks out: register-subspace `CLStep` (`gt-03:L231-L239`),
levels 1/2/3 (`eq:cl-ptf`, `eq:cl-alnf`, `eq:cl-dlnf`), the `chi`-independent reference histogram
(`lem:alnf`/`lem:dlnf`), one typed family padded to level 3 (`gt-10:L1920-L1941`), and the
answer-reduced typed level `max(ell,3)` (`gt-10:L1963-L1965`).

**C5 — HOLD.** The two bounds and the `SOURCE_REPAIR(C8)` framing are correct and the status stays
SKETCH, but the row as written says "the derivation uses formula bound `(deg_F+5d)m'/q`" without
recording that `def:pcpparams` selects `q` from the literal-2 predicate, so the repaired inequality
is an extra obligation rather than a consequence. That is R2's missing step; re-propose with the
sentence "the parameter tuple returned by `def:pcpparams` bounds `(2+5k)m'/2^k`, not
`(deg_F+5k)m'/2^k`, so `P_formula_structural` is an additional obligation, discharged for both TB0
rows and, in general, only under a stated `m'=O(s)` relation via item 2(a)".

**C8 — AUTHORIZED, with the loose final clause replaced by the measured one.** The occurrence law,
the two-gate vector `(2,2,2,4,3)` with `deg_w1 = 4`, and TB0's attainment are all independently
reproduced; the new bound `deg_v <= occ_v` is strictly tighter and more accurate than the old
`2(1+fanout(v))` (for a circuit input it gives `2·fanout`, not `2+2·fanout`), and it now includes the
F2 output-literal term. Exact row text:

```markdown
| C8 | (Refutation candidate, findings F1/F2) For NW19 Tseitin arithmetized along the formula tree and conjoined with `w_out`, `deg_v(F_arith)<=occ_v`, where an input has occurrence `2 fanout(v)` and gate wire `w_i` has `2+2 fanout(w_i)+indicator(i=out)`. The two-gate regression has degree vector `(2,2,2,4,3)`, in particular `deg_w1=4>2`; TB0 attains its displayed occurrence vector coordinatewise, with equality on all sixteen coordinates. Consequently `deg_v(c_0) <= occ_v(F_arith) + deg_v(prod_i (g_i - o_i))`, which for multilinear `g_i` adds at most 1 per coordinate, and the formula Schwartz--Zippel constant is `deg_F+5d`, not 2+5d, unless the source claim is separately repaired. | CONJECTURE | — | docs/findings.md F1,F2 | — | — |
```

---

## 4. Trajectory

r1: 13 MAJOR, 11 MINOR, 7 NOTE. r2: **3 MAJOR, 2 MINOR, 4 NOTE**, with 11 of 13 MAJOR fully
verified, one verified-with-residue (M7 -> R5) and one verified-in-part (M10 -> R1); all 11 MINOR and
all 7 NOTEs verified. The fixture that r1 refuted has been replaced by one whose every displayed
number I reproduced independently. Severity is falling monotonically; none of the three remaining
MAJORs requires a design change larger than a paragraph plus one regraded certificate node.

VERDICT: FAIL(R1,R2,R3)
