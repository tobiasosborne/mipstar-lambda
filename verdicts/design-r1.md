# CRITIC verdict r1 — `docs/DESIGN.md`, `docs/definitions.md`

Round 1 (attack). Target commit `da54528` (design), read against `CLAUDE.md`, `handoff.md`,
`claims/CLAIMS.md` (as of the C8 row), `briefs/01-design.md`, and `ground-truth/gt-*.tex`.
All computations below are the critic's own; scratch at
`/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-.../scratchpad/critic-design-r1/`
(`zb.jl`, `tb0.jl`, `mut.jl`, `vac.jl`).

**Standing credit, so the repair round does not disturb it.** I resolved all 78 distinct
`gt-NN:Lx-Ly (label)` citations in both documents against the source. Every one lands on the
named object. The `delta_ld` formula, the two Schwartz–Zippel degree bounds `(2+5d)m'` and
`(2+d)m'`, the `d-2` quotient remark, the `max{ell+2,5}` and 9-level arithmetic, the
`k(n)=(lambda n)^{(1+c')tau}` exponent, `m'=5m+5+s`, `|Type^ar| = 54`, and the two flagged
source typos (`formula(x,s)`, the omitted `sigma` at `L2058-L2063`) are all correct. The
objections below are about what the design *builds on top of* those citations.

---

## FATAL

None. Every defect below is repairable without abandoning the architecture.

---

## MAJOR

### M1 · TB0-tiny's exhaustive rung is vacuous — it accepts a proof whose quotients are all zero
**Severity** MAJOR · **Location** `DESIGN.md` §5 table row `TB0-tiny`, §5.1 item 4, §7 risk 3; `CLAIMS.md` C1.

**Independent computation.** At `q=2`, `zero(z)=z(1-z)` vanishes at both points of `F_2`, and
`F_2^{m'}` *is* the Boolean cube `{0,1}^16`. Therefore for every `z` in the exhaustive sweep,
`sum_{j=1}^{16} beta_j * zero(z_j) = 0` identically, whatever `c_1..c_16` are, and
`beta_0 = c_0(z) = 0` because `c_0` vanishes on the cube by construction. I built the design's
own fixture (`c0 = (prod_i x_i o_i)^2 * prod_i (x_i - o_i)`, support 32, `inddeg = 3` — both
numbers as claimed) and ran `pcpverifier` at all 65,536 points (`vac.jl`):

```
honest proof                          : (formula, zero) = (65536, 65536) / 65536
c_1 = ... = c_16 := 0                 : (formula, zero) = (65536, 65536) / 65536
c_0 = c_1 = ... = c_16 := 0           : (formula, zero) = (65536, 65536) / 65536
```

The exhaustive rung therefore carries **zero** information about the objects the zero-basis
certificate produces. `fig:pcpverifier` step `enu:zero-test`
(`gt-10-answer-reduction.tex:L1579-L1583`) is the only check that reads `beta_1..beta_{m'}`,
and it is identically satisfied over `F_2`. §7 risk 3 flags "distinct formal polynomials can
induce the same function" but not this — which is a strictly stronger and more damaging fact.

**FIX DEMAND.** Delete the claim that TB0-tiny gives exhaustive evidence for C1; either replace
the tiny field by the smallest admissible `q` with `q > d` and `m' | q` where exhaustive is
still infeasible (so C1's exhaustive clause is retired), or state in DESIGN §5 and in C1 that
the exhaustive rung exercises **only** the coefficient identity, and move the acceptance
evidence entirely to the paper-field row.

**SURVIVING WEAKER STATEMENT.** Over `q=2` the design's fixture satisfies
`c_0 = sum_i c_i * zero(z_i)` as a formal coefficient identity with zero remainder (verified,
`tb0.jl`); no statement about `pcpverifier` acceptance at `q=2` distinguishes the honest proof
from the all-zero proof.

---

### M2 · Two of the three TB0 mutations are not killed by the rung they are attached to
**Severity** MAJOR · **Location** `DESIGN.md` §5.1 final paragraph ("Each must make its dedicated test nonzero"), DD-14.

**Independent computation** (`mut.jl`, all at the design's `q=2`, `m'=16` fixture):

| mutation | coefficient identity | `r == 0` | exhaustive `(formula, zero)` |
|---|---|---|---|
| honest | holds | yes | (65536, 65536) |
| A: rewrite `e-2` → `e-1` | **fails** | yes | **(65536, 65536)** |
| B: drop one `(g_i - o_i)` factor from `c_0` | **holds** | yes | **(65536, 65536)** |

Mutation A is killed only by the coefficient identity, never by the verifier sweep. Mutation B
is killed by **nothing in TB0-tiny**: the truncated `c_0'` still vanishes on the cube (checked
at all 65,536 points), so the rewrite still returns `r = 0` and the identity still holds, and
both PCP tests still accept everywhere. Over `Z/5` the mutated `c_0'` is separated from
`F_arith * prod (g_i - o_i)` at only 71/2000 uniform points — i.e. mutation B is an *off-cube,
large-field* phenomenon and belongs to the paper-field row, not the exhaustive one.

**FIX DEMAND.** Annotate every mutation in §5 with the rung and the *specific checker* that
must go red, and prove the pairing at design time (as above) rather than asserting it; move
mutation B to TB0-paper-field.

**SURVIVING WEAKER STATEMENT.** Mutation A is a red test for the zero-basis coefficient
checker; mutation B is a red test for the formula test at `q = 2^13` only.

---

### M3 · The PCP fixture is not an arithmetized Tseitin formula, and the design does not disclose how degenerate it is
**Severity** MAJOR · **Location** `DESIGN.md` §5 opening paragraph; `CLAIMS.md` C2, C3.

**Independent computation.** `def:tseitin` (`gt-10:L151-L159`) requires
`C(x,o) = 1 iff exists w. formula(x,o,w) = 1`, so any genuine Tseitin arithmetization *depends
on `w`*. The fixture's `F_arith = (prod_i x_i o_i)^2` does not mention `w` at all. Running the
zero-basis rewrite on the resulting `c_0` (`tb0.jl`, identical over `Z/2` and `Z/5`):

```
|support(c_i)|  = [48,48,48,48,48,16, 0,0,0,0, 0,0,0,0,0,0]
inddeg(c_i)     = [ 3, 3, 3, 3, 3, 3,-1,...,-1]
```

Ten of the sixteen quotients — including the **entire six-variable `W` block** — are the zero
polynomial. So (i) the `exists w` contract of `def:tseitin` is never exercised; (ii) C3's
"`F_arith` has individual degree ≤ 2" is checked on a hand-written monomial, not on the output
of `arith_q`, which is the transformation whose degree bound is the actual mathematical content
(`prop:tseitin-arith-degree`, `gt-10:L173-L191`); (iii) C2's "`r == 0` iff the witness satisfies
`phi_C`" is tested against a one-clause relation with a `w`-free `F_arith`.

**FIX DEMAND.** State in §5 exactly which quotients are identically zero and which
ground-truth contracts the fixture does **not** exercise, and add a second fixture (still tiny)
whose `F_arith` is produced by `arith_q(tseitin(C))` and genuinely depends on `W`, before C2/C3
may be promoted.

**SURVIVING WEAKER STATEMENT.** On the fixture, six nonzero quotients of individual degree 3
(and degree ≤ 1 in their own variable) reproduce `c_0` exactly; nothing about `arith_q`,
Tseitin, or `phi_C` follows.

---

### M4 · The "every variable occurs at most twice" Tseitin constructor is unsatisfiable, and contradicts CLAIMS C8
**Severity** MAJOR · **Location** `DESIGN.md` §1.2 ("The specialized constructor … refuses a result unless every variable occurs at most twice; this certifies the arithmetization's individual-degree-2 bound"), §1.2 invariant table; `CLAIMS.md` C8; `docs/findings.md` F1.

**Independent computation.** For NW19's Tseitin formula
`z_i = (g_i and w_i) or (not g_i and not w_i)`, `F = z_1 and ... and z_s`, the arithmetization
of one `z_i` is (I expanded it independently)
`1 - g - w + gw + g^2 w + g w^2 - g^2 w^2`, so `deg_w(z_i) = 2` with leading coefficient
`g - g^2 != 0`. Variable `w_i` also occurs (twice, squared) inside every `z_j` whose gate takes
wire `i` as input, so `occ(w_i) = 2 + 2*fanout(i)` and
`deg_{w_i}(F_arith) = 2(1 + fanout(i))`. For `g1 = x1 and x2`, `g2 = w1 and x3` the leading
coefficients multiply in the integral domain `F_q[x,w]` and `deg_{w1}(F_arith) = 4 > 2`.
Hence **no** real Tseitin formula has all variables occurring at most twice (even at fanout 1,
`occ(w_i) = 4`), and the design's private constructor would refuse every genuine input. The
design's degree ladder (`F_arith ≤ 2`, `c_0 ≤ 3`, hence `(2+5d)m'`) inherits the error.

**FIX DEMAND.** Replace the occurrence-≤-2 gate with a computed per-variable occurrence vector
and the bound `deg_v(F_arith) ≤ occ(v)`; add a DD recording the divergence from
`prop:tseitin-arith-degree` and a lockstep row pointing at C8; propagate the consequent change
to the `c_0` degree and to the `(2+5d)m'` constant in §4.1.

**SURVIVING WEAKER STATEMENT.** `deg_v(arith_q(F)) ≤ #occurrences of v in F` is CHECKED from
the formula tree; "≤ 2 for Tseitin formulas" is not, and must be carried as `Cited(disputed)`
until C8 is adjudicated.

---

### M5 · `dim V_{6,coord}` is stated as `m'`; the source says 6, and the question table says 1
**Severity** MAJOR · **Location** `DESIGN.md` §1.5 ("the sixth point, coordinate, and direction registers are the direct sums and have dimension `m'=5m+5+s`"); `definitions.md` row `V_{i,pt}/V_{i,coord}/V_{i,dir}`.

**Independent citation.** `eq:V-pcp` (`gt-10:L1897-L1913`): `V_{i,coord} ~ F_q` for `i=1..5`
(L1903), `V_{aux,coord} ~ F_q` (L1904-1905), and
`V_{6,coord} = (direct-sum_{i=1..5} V_{i,coord}) direct-sum V_{aux,coord}` (L1909-1910), i.e.
**dimension 6**. Only `V_{6,pt}` and `V_{6,dir}` have dimension `m'`. Worse, `table:tpcp`
(`gt-10:L1995`) gives the `ALine_6` question as `v in F_q^{m'} x F_q` — a **single** field
element `s` — which is what `eq:cl-alnf` requires, since `chi(s)` (`eq:chi-func`,
`gt-07:L208-L221`) is defined on one element of `F_q`. So the source itself is inconsistent
(`eq:V-pcp` vs `table:tpcp`) and the design states a *third*, wrong value. TB2's asserted test
"assert … the register dimensions in `V^pcp`" cannot be written until this is settled.

**FIX DEMAND.** Correct `dim V_{6,coord} = 6` in both files, record a `SOURCE_REPAIR` node
naming the `eq:V-pcp` / `table:tpcp` conflict, and state which single component `chi` reads for
copy 6.

**SURVIVING WEAKER STATEMENT.** `dim V_{6,pt} = dim V_{6,dir} = m' = 5m+5+s`; the coordinate
register of copy 6 is ambiguous in the source and must be a flagged repair, not a design fact.

---

### M6 · `CLStep` admits general complementary subspaces; `def:cl-func` demands *register* subspaces
**Severity** MAJOR · **Location** `DESIGN.md` §1.5 ("general subspaces require a checked rank/decomposition certificate before the private constructor returns `CLStep`"), DD-7, invariant row "complementary spaces: CONSTRUCTED or CHECKED"; `CLAIMS.md` C4.

**Independent citation.** `def:cl-func` (`gt-04-cl.tex:L47-L50`): "There exist complementary
**register** subspaces `V_1` and `V_{>1}` of `V`". `def:register-subspace`
(`gt-03-prelim.tex:L231-L239`): "a subspace that is the span of a subset of the **standard
basis**". `def:sampler` (`gt-04-cl.tex:L590-L595`) requires the factor space to be output "as a
vector in `{0,1}^s` indicating which elementary basis vectors … span the factor space". A
`CLStep` built over a general complementary pair with a rank certificate is therefore **not** a
witness of CL-ness in the paper's sense, and C4's "BY CONSTRUCTION" is false for that branch.

**FIX DEMAND.** Delete the general-subspace branch: `CLStep` takes two disjoint coordinate index
sets, full stop, and the rank certificate is deleted with it. Record the restriction as a DD
citing `def:register-subspace`.

**SURVIVING WEAKER STATEMENT.** Restricted to register (coordinate) subspaces, "`L` is an
`ell`-level CL function" is CONSTRUCTED by the `CLZero`/`CLStep` nesting.

---

### M7 · The term language cannot express its own flagship term
**Severity** MAJOR · **Location** `DESIGN.md` §1.1 grammar and the `Psi_M_L` / `D_M_L` display; handoff deliverable 1.

**Independent analysis.** The grammar is
`P ::= BoundVar(depth,slot) | Lambda(arity,P) | Apply | Fix | If | Prim | Quote(Closed(P)) | Eval | Specialize(Pcode, StaticEnv)`.
There is **no free-variable / hole constructor**, so `StaticEnv` has nothing to bind and
`Specialize` is a no-op on every well-formed term. The displayed
`Lambda(self_code, n, x, y, a, b, …)` uses named parameters, which the stated `Lambda(arity,P)`
with de Bruijn addressing does not have; and if `self_code` really is that lambda's own
parameter, then `Specialize(…, {self_code => d})` substitutes into a bound variable — a capture
violation — while if it is free, `Quote(Closed(P))` cannot be applied to the body. Finally
`D_M_L = Apply(YCode, Psi_M_L)` uses `YCode` as if it were a term; the grammar's fixed point is
`Fix(P)`. So the one artifact the design offers as the payoff of the lambda layer is not a term
of the language it defines.

**FIX DEMAND.** Add `Hole(name, sort)` to the grammar, define `Closed` as "no free `BoundVar`
and no `Hole`", restate `Specialize : PartialProgram x StaticEnv -> Closed`, and rewrite
`Psi_M_L` with `self_code` as a `Hole` and `D_M_L = Fix(Psi_M_L)`.

**SURVIVING WEAKER STATEMENT.** The intent — that `Compress` consumes the quoted pair
`(S_L, d)` and its byte length, never an extensional value — is correct and matches
`gt-12:L26-L39`; the concrete syntax realising it does not yet exist.

---

### M8 · All four transformation contracts drop their theorem hypotheses
**Severity** MAJOR · **Location** `DESIGN.md` §1.6 bullets for `Introspect`, `AnswerReduce`, `Repeat`, `Compress`.

**Independent citation.** Each source theorem is conditional and the design states only the
conclusions:

| contract | dropped hypothesis | source |
|---|---|---|
| `Introspect` | "if `V` is a `lambda`-bounded `ell`-level verifier" | `gt-08:L802-L803` |
| `AnswerReduce` | `TIME_D(n) <= T(n)` and `TIME_S(n) <= Q(n)` (`eq:ar-time-assumption`) | `gt-10:L1818-L1825` |
| `Repeat` | completeness needs `TIME_D(n) <= (lambda n)^tau` | `gt-11:L241-L243` |
| `Compress` | "if furthermore `V` is a `lambda`-bounded, **9-level** normal form verifier", and "for all `n >= C_0`, `N = 2^n`" | `gt-12:L41-L44` |

A `Cited` certificate built from §1.6 as written would assert a strictly stronger statement than
the theorem it names — exactly the failure mode `rk-light` law 5 exists to prevent.

**FIX DEMAND.** Restate each contract as `ASSUME <hypotheses> PROVE <conclusions>`, and make
`Cited` carry the hypothesis list so `verify_certificate` can report an undischarged hypothesis.

**SURVIVING WEAKER STATEMENT.** The stated conclusions are transcribed correctly; they hold
only under the listed hypotheses, which the IR must carry as obligations.

---

### M9 · The evidence-grade vocabulary is not a fixed enumeration, so the grade cannot be machine-matched
**Severity** MAJOR · **Location** `DESIGN.md` header (CONSTRUCTED / CHECKED / ASSERTED→CITED|ASSUMED), §1.1–§1.6 tables, §3 (`Certificate` grammar), §4.1 tree, §5.6 mutation; `definitions.md` §G.

**Independent audit.** `definitions.md` §G fixes five grades
`{CONSTRUCTED, CHECKED, CITED, ASSUMED, SOURCE_REPAIR}`. `DESIGN.md` introduces a sixth word
(`ASSERTED`) in its header and then emits, in tables and trees, at least eleven distinct grade
strings: `ASSERTED or CITED`, `ASSERTED/CITED`, `ASSERTED (false until measured)`,
`CONSTRUCTED or CHECKED`, `CHECKED on TB1`, `[CHECKED logic]`, `[CHECKED bound]`,
`[CHECKED arithmetic]`, `[SZ lemma]`, `[DERIVED]`, `[CHECKED/CITED]`, `[CITED generally]`.
Meanwhile §3's `Certificate` grammar assigns a replay obligation only "when its grade is
CHECKED", and leaves `Bound`, `SchwartzZippel`, and `Compose` ungraded. Consequence: §3's claim
that "node sequence, **grade**, rule name … are all matched" is not implementable, and §5.6's
mutation "relabel a CITED leaf as CHECKED" is evadable by relabelling it as `Bound(...)` or
`SchwartzZippel(...)` instead, neither of which owes a replay.

**FIX DEMAND.** One `@enum Grade` with exactly the five values of `definitions.md` §G; every
`Certificate` constructor carries a `Grade` field; `verify_certificate` fails on any node whose
grade is `CHECKED` and whose `replay` is absent; rewrite §4.1's tree using only the five words.

**SURVIVING WEAKER STATEMENT.** The four-way split of PCP soundness (§4.1–§4.4, DD-13) is the
right decomposition and the CITED/CHECKED boundary is drawn in the right place; it is the
encoding of that boundary that is currently unenforceable.

---

### M10 · `def:pcpparams` is only half recorded, and the "paper-field" rows are not derived from it
**Severity** MAJOR · **Location** `DESIGN.md` §2 (`build_pcp` … "the field/divisibility policy"), §5 table and following paragraph, §7 risk 2; `definitions.md` `PCPParams` row.

**Independent citation and computation.** `def:pcpparams` (`gt-10:L1396-L1422`) imposes
`m' = 5m+5+s` **with `m'` a power of 2** (item 1), and lets `q = 2^k` for the **smallest odd**
`k` satisfying *four* conditions: (a) `k >= ((gamma b' + 3a')/b') log s`;
(b) `(2+5k) m'/2^k < 1/2`; (c) `k m'/2^k <= s^{-b' gamma}`; (d) `m' | 2^k`; and then `d = k`.
The design records only (b), (d) and `q = 2^k` odd `k`. Recomputing for the fixture
(`m' = 16`, `s = 6`): the smallest odd `k` satisfying (b) and (d) is **`k = 11`**
(`(2+55)*16/2048 = 0.4453 < 0.5`; `k = 9` gives `1.469`), not the design's `k = 13`. The design's
`k = 13` may still be forced by (a)/(c) for a given `gamma`, but the design never evaluates
them, so the label "paper-field" and the value `d = 13` are asserted, not derived. For the
record, `k = 13` does satisfy the two conditions the design does state:
`(2+5*13)*16/8192 = 0.1309 < 1/2` and `(2+13)*16/8192 = 0.0293 < 1/2`.
Separately, §5 says TB0-tiny "violates **only** `m' | q`" — it also violates (b), (c) and
`d = k` (at `q = 2`, `k = 1`, so `d` must be 1, not 3).

**FIX DEMAND.** Put all six `def:pcpparams` obligations into `ParameterPolicy` as named,
individually checkable predicates; make every row of the §5 table print pass/fail per
predicate; delete the word "only" from the TB0-tiny sentence.

**SURVIVING WEAKER STATEMENT.** `q = 2^13`, `m = 1`, `s = 6`, `m' = 16` satisfies
`q = 2^k` with `k` odd, `m | q`, `m' | q`, `m'` a power of 2, `d = k`, and both Schwartz–Zippel
inequalities; it is not shown to be the tuple `pcpparams(n,T,Q,sigma,gamma)` returns.

---

### M11 · `AnswerReduce` returns a typed object but carries the detyped theorem's contract, and no `detype` combinator exists
**Severity** MAJOR · **Location** `DESIGN.md` §2 signature list (`answer_reduce_pcp :: Checked{TypedVerifier,…}` vs `AnswerReduce :: Checked{VerifierIR,…}`), §1.5 ("Detyping is a separate CITED transformation"), §1.6 `AnswerReduce` bullet, DD-8.

**Independent citation.** `thm:ar` (`gt-10:L2077-L2116`) is about `V^ar = detype(hat V^ar)`; the
`max{ell+2,5}` level and the `delta(eps,n)` soundness map are properties of the **detyped**
verifier, and the proof of `thm:ar` runs `detype` explicitly (`gt-06:L436-L474`,
`lem:detyping-verifiers`, `+2` levels and a `16^{|Type|}` loss with `|Type^ar| = 54`). §2 lists
no `detype` signature at all, yet `AnswerReduce` is typed as returning a `VerifierIR` bearing
`thm:ar`'s contract. The pipeline as drawn cannot reach its own stated output object.

**FIX DEMAND.** Either add `detype(v::TypedVerifier) :: Checked{VerifierIR, Cited}` to §2 and
make `AnswerReduce = detype ∘ answer_reduce_pcp`, or retype `AnswerReduce` as returning
`TypedVerifier` and move the `thm:ar` contract onto the composite that includes detyping.

**SURVIVING WEAKER STATEMENT.** `answer_reduce_pcp` builds the typed verifier `hat V^ar` whose
typed level is `max{ell,3}` (`gt-10:L1963-L1965`); the `max{ell+2,5}` figure belongs to an object
this campaign does not construct.

---

### M12 · `Q` is given one meaning in `definitions.md` and used with the other in `DESIGN.md`
**Severity** MAJOR · **Location** `definitions.md` §C row `Q`; `DESIGN.md` §1.6 / §5.5 (`pcpverifier` decider specification `(D,n,T,Q,sigma,gamma,x,y)`).

**Independent citation.** In `def:pcpparams` and `thm:pcp-decider` (`gt-10:L1379-L1383`,
`L1397-L1399`, `L1461-L1467`), `Q` (`\qlen`) is the **question-length** bound: `Q <= T` and `x`,
`y` are strings of length at most `Q`. In `eq:ar-time-assumption` (`gt-10:L1820-L1825`) the same
symbol bounds the **sampler runtime**, `TIME_S(n) <= Q(n)`. `definitions.md` records only the
second meaning and cites only `L1817-L1825`. Since `s = s(n,T,Q,sigma)` and hence `m'` and `q`
depend on `Q`, feeding the wrong quantity silently changes the whole parameter tuple.

**FIX DEMAND.** Split into two rows — `Q_len` (question length, `gt-10:L1379-L1383`) and
`Q_time` (sampler runtime, `gt-10:L1820-L1825`) — note that `eq:ar-params-1` sets them equal to
`(lambda n)^mu` in the answer-reduction instantiation, and use the disambiguated names in
`DESIGN.md`.

**SURVIVING WEAKER STATEMENT.** In the answer-reduction instantiation the two readings coincide
numerically; outside it they do not, and `pcpverifier`'s specification tuple uses the
question-length reading.

---

### M13 · `fig:decider-pcp` is pointed at but never specified, so TB2 is not implementable from the design
**Severity** MAJOR · **Location** `DESIGN.md` §2 pipeline item 6, §5.4; `definitions.md` `D_AR` row; handoff "Representation requirements → number and form of random queries".

**Independent citation.** `fig:decider-pcp` (`gt-10:L1975-L2071`) contains, beyond the five step
*names* the design does record: `table:tpcp`'s six question formats and six answer formats
(`L1990-L1999`); the type-pair guard for every step; the restriction `i in {3,4,5}` in the
proof-consistency and individual-low-degree checks (`L2037`, `L2044`); and **two distinct**
low-degree parameter tuples, `ldparams = (q,m,d,1)` for steps 3 and 4b and
`ldparams' = (q,m',d,m'+6)` for step 4c (`L2031`, `L2049-L2052`). None of these appear in either
document. §5.4 nevertheless promises TB2 will "assert … every question and answer parser" and
"execute all five checks … on a branch-covering deterministic suite". It cannot; the parsers and
the branch conditions are not written down anywhere in the design.

**FIX DEMAND.** Add a §1.6 (or §2) subsection transcribing `table:tpcp` and a five-row table
`step → type-pair guard → what is compared → ldparams`, each with its `gt-10` line range; state
the `kappa` values `1` and `m'+6` in `definitions.md`.

**SURVIVING WEAKER STATEMENT.** The design correctly names the five checks and their order and
correctly identifies `g_3` (an `i in {3,4,5}` index) as the right target for the
proof-consistency mutation; the content of the checks is currently CITED, not specified.

---

## MINOR

### m14 · `s` is overloaded in the §5 table against `definitions.md`'s own rule
`DESIGN.md` §5 table puts `5 (ambient dimension)` in the `s` column for TB1, while
`definitions.md` §A reserves `s` for the padded gate count and says "A sampler ambient dimension
is always named `seed_dim` in code". **FIX DEMAND** add a `seed_dim` column. **SURVIVING**
TB1's ambient dimension is `2m+1 = 5` and `q^{2m+1} = 32768`, both correct.

### m15 · `d` is overloaded: parameter vs. actual degree
`definitions.md` fixes `d = k` in the paper's parameters; §5's table gives `d = 3` for
TB0-tiny (where `k = 1`) and `d = 13` for the paper rows, while §1.4 says "For the honest PCP
`d = 3`". **FIX DEMAND** use `d` for the parameter only and `inddeg(c_0)` for the measured
value. **SURVIVING** the honest `c_0` has individual degree exactly 3 (recomputed) and 3 ≤ 13.

### m16 · Wrong mechanism for "the PCP sampler is 3-level"
§1.5 argues "Direct sums preserve maximum level, so the whole PCP sampler is 3-level, not
18-level". `gt-10:L1919-L1941` defines the 18 maps as a **typed family**: each `L_{Point_i}`,
`L_{ALine_i}`, `L_{DLine_i}` is a single CL function on all of `V^pcp` that zeroes the other
registers, of level 1, 2, 3 respectively; the common level is 3 because a typed family is padded
to the maximum (`gt-04:L322-L327` plus the "`ell`-level is also `k`-level for `k >= ell`"
remark), not by a direct sum. `CLAIMS.md` C4's "product of six such" is wrong for the same
reason and the design does not correct it. **FIX DEMAND** restate; propose the corrected C4
wording as a merge proposal. **SURVIVING** the typed PCP sampler is 3-level and the
answer-reduced typed sampler is `max{ell,3}`-level, both as claimed.

### m17 · Formal (unreduced) polynomials vs. the paper's exponent range
§1.3/DD-5 keeps formal polynomials "not reduced modulo `z_i^q - z_i`" and justifies it by the
checker. `gt-03-prelim.tex:L836-L840` defines an `m`-variate polynomial over `F_q` with
exponents in `{0,…,q-1}`; the two notions coincide exactly when `d <= q-1`, which is the real
content of the design's "`d >= q`" relaxation. **FIX DEMAND** add `d <= q-1` as a named
`ParameterPolicy` predicate and record the exponent-range definition in `definitions.md`.
**SURVIVING** formal polynomials are the correct carrier for `prop:zero-basis` (polynomial
division is not defined in the reduced ring); only the fidelity note is missing.

### m18 · Five equal-length index blocks is a specialization, not the definition
§1.2's `SuccinctDecoupled5SAT(index_blocks=(X1[m],…,X5[m]))` fixes all five blocks to length
`m`. `eq:5sat`/`def:decoupled-5sat` (`gt-10:L948-L979`) allows `N_1..N_5` distinct, and
`def:succinct-descriptions-for-bounded-deciders` (`gt-10:L981-L1006`) uses two blocks of size
`L` and three of size `R`; equality arrives only via
`prop:explicit-padded-succinct-deciders` (`gt-10:L1226-L1246`). **FIX DEMAND** name the
specialization as a DD citing the padding proposition. **SURVIVING** after padding, all five
blocks do have length `m(T,sigma)`, so the fixture is faithful to the padded case.

### m19 · TB1's `chi` mutation is meaningful only if the reference sampler is `chi`-free
§5.3 asserts "Mutate `chi` at a bucket boundary and require histogram mismatch". If the
reference sampler is also written through `chi`, the mutation moves both histograms and the
test stays green. `lem:alnf`/`lem:dlnf` (`gt-07:L243-L287`) characterise the target
distributions by "uniformly random axis `i`", not by `chi`, so a `chi`-free reference exists.
**FIX DEMAND** state that the reference draws `i` uniformly and constructs `line(u_0,e_i)`
directly, independent of `chi`. **SURVIVING** with a `chi`-free reference the mutation is a
valid red test.

### m20 · TB0.5 re-specifies work that already exists in the repository
§5.2 specifies the midpoint diagnostic from scratch (`Z/17`, `f(x)=x+1`, DP recurrence) and §6's
layout files it at `test/tb05_midpoint.jl`. `toys/midpoint/` (commit `b6fa4e9`) already contains
a 278-line implementation with an `Ask`/`Coin`/`Test` term language, exact
`Rational{BigInt}` values, a 98-line test, three mutations, and a Lamport-style `PROOF.md`.
The design cites none of it. I verified the mathematics independently: for a false claim,
`V_n = (1 + V_{n-1}^{false})/2` with `V_0^{false} = 0`, so `V_n = 1 - 2^{-n}` — C6 is right.
**FIX DEMAND** cite `toys/midpoint` and say whether TB0.5 is a port, a wrapper, or a
replacement. **SURVIVING** the recurrence and the claimed optimum are correct.

### m21 · No line-restriction combinator, although that is what `D^ld` actually tests
§2's signature list has no `restrict_to_line`; §1.3 has only a `Restrict` *degree-derivation*
node. `fig:ld-decider` (`gt-07:L348-L392`) compares `f_j(t)` against the point answer, so the
restriction of a `Poly` to `line(u_0,v')` — producing a univariate of degree `<= d` (axis) or
`<= md` (diagonal) — is a first-class transformation. **FIX DEMAND** add
`restrict_to_line(p::Poly, u0, v) :: Checked{UnivariatePoly, RestrictCert}` with the two degree
bounds as certificate facts. **SURVIVING** the derivation node exists; the combinator does not.

### m22 · TB2's stated feasibility risk is mis-targeted
§5.4 calls the padded diagonal answer the reason TB2 is "the least certain sub-60-second rung".
The `DLine_6` answer is `m'+6 = 22` univariates of degree `<= m'd = 208`, i.e. 4598 field
elements — trivial. The honest `c_j` have total degree ≤ 25 (recomputed from the fixture), so
each restriction is a handful of univariate multiplications. The real risks are (i) the fraction
of the `54^2 = 2916` type pairs that trigger no check at all (`fig:decider-pcp`: "In all cases
where no action is indicated, accept"), so 256 uniform seeded questions mostly test nothing, and
(ii) rebuilding the honest strategy per question. **FIX DEMAND** replace the stated risk with
these two and require the seeded questions to be *conditioned on* check-triggering type pairs.
**SURVIVING** TB2 under 45 s is plausible; the design's reason for doubting it is not the
binding one.

### m23 · "Pass a `Closure` where a `QuotedVerifier` is required" is a dispatch test, not a mutation
§5.6 lists it among TB4's mutations. It fails with a `MethodError` regardless of any semantics,
so it is a trivially-green red test in the sense of `rk-light` law 4. **FIX DEMAND** replace
with a semantic mutation, e.g. permute the `Compress` composition order and require the computed
`Levels` to differ from 9 (`5 -> max(5+2,5)=7 -> 7+2=9`). **SURVIVING** the type separation
itself (DD-1) is worth keeping; it is not a test.

### m24 · Elegance: the certificate machinery outweighs the mathematics it certifies (three concrete cuts)
The user's north star is elegance; three parts of the design are heavier than what they carry.
(a) **DD-12 (hash every evidence edge)** exists to prevent stale evidence, but every public
transformation already returns `Checked{T,C}`, so the certificate is never detached from its
term. Replace hashing with: every CHECKED fact is a *function* `check(term)::CheckResult`
recomputed at test time. Strictly stronger (staleness becomes unrepresentable) and deletes the
hash field, the `inputs_hash`/`outputs_hash` in `Computed`, and DD-12.
(b) **DD-1's five code/value types**: `Closure`, `UEval` and `Specialized` appear in no rung.
`Specialized{A}` is definitionally `Checked{Quoted{A}, SubstCert}`, which already exists. Keep
`Quoted` and `CircuitIR` as types; make the other three a three-line remark discharging the
handoff's "distinguish carefully" requirement.
(c) **The symbolic bound grammar** `B ::= … | poly(B*)` with domains and side conditions is
never computed with — only printed. A two-constructor `BoundExpr` (`Concrete(Int)`,
`Opaque(String, params)`) discharges DD-11 at a tenth of the weight.
**SURVIVING** the `Checked{T,C}` idea, the CITED/CHECKED split, and the four-root soundness
decomposition are the genuinely good parts and should absorb the space the above frees.

---

## NOTE

- **n25.** §1.5 "The stage order is coordinate, then direction, then point" holds for `L_DLine`
  (`gt-07:L237`: identity on `V_coord`, then `v -> pi_{i-1}(v)` on `V_dir`, then `L^lnf_{v'}` on
  `V_pt`). `L_ALine` has only two stages: stage 1 projects `V_coord ⊕ V_dir` onto `V_coord`
  (zeroing `V_dir`), stage 2 is `L^lnf_{e_i}` on `V_pt` (`gt-07:L222-L228`).
- **n26.** §1.1's `Prim(halts_within, bound=n, M, n)` uses the runtime value `n` as the *static*
  `Bound`, contradicting the section's own phase separation.
- **n27.** The one place the lambda layer would carry real mathematical weight is the **level
  algebra**, and the design does not exploit it: `Introspect -> 5`,
  `AnswerReduce -> max(5+2,5) = 7`, `Repeat -> 7+2 = 9`, and `thm:compression` both *consumes*
  and *produces* 9-level verifiers (`gt-12:L31`, `L41-L44`) — which is exactly why
  `Introspect(V,lambda,9)` is called with `ell = 9` in `fig:compress`. Making `Levels` the one
  type-level index checked end to end would turn the compression fixed point into a typing fact.
  Recommend this as the design's centrepiece.
- **n28.** `m' | q` is presented as an imported constraint; its content is that `chi` on copy 6
  buckets `F_q` into `m'` equal parts (`eq:chi-func`, `gt-07:L208-L221`, applied with `m'` in
  place of `m` per `gt-10:L1944-L1946`). Saying so makes `def:pcpparams` item 2(d) self-evident.
- **n29.** Two further source typos the design does not list: `alpha_i = g_i(z)` for `g_i(x_i)`
  at `gt-10:L1725`, and `for all z in F_q^m` for `F_q^{m'}` at `gt-10:L1712` (§7 risk 5 flags a
  "`F_q^m`/`F_q^{m'}` mismatch at L1709-L1715" without saying which side is right).
- **n30.** §1.5's `L_lnf(0) = identity` repair is mathematically the right totalization (the
  canonical complement of `S = {0}` is `V`, so the projector onto `V` parallel to `{0}` is the
  identity), and the `SOURCE_REPAIR` grade is appropriate. Recorded so the repair round does not
  weaken it. Note that `v' = 0` is not rare: it occurs with probability `q^{-(m-i+1)}`.
- **n31.** `|Type^ar| = 54`, so `lem:detyping-verifiers`'s soundness factor is `16^54`. Absorbed
  into `thm:ar`'s universal constant `a`, but the design should say so rather than leaving
  `16^{|TypeSet|}` unevaluated next to a 54-type product.

---

## Handoff coverage

| handoff requirement / deliverable | where the design addresses it | assessment |
|---|---|---|
| No raw `Expr`; explicit symbolic IR; macros surface syntax only; pure functions do the work | §1.1 grammar, §2 preamble, DD-1/DD-2 | **inadequate** — the grammar cannot express its own `Psi_M_L` (M7) |
| `Poly[F_q, Variables, IndividualDegree, Dependencies]` | §1.3, DD-3/DD-4/DD-5 | adequate (see m17) |
| `Sampler[DistributionClass, AdaptivityLevels]` | §1.5, DD-7/DD-8 | **inadequate** — register-subspace requirement violated (M6); `V_{6,coord}` wrong (M5) |
| `Verifier[QuestionLength, AnswerLength, Runtime, Gap]` | §1.6, DD-9 | **inadequate** — hypotheses dropped (M8); wrong object typed (M11) |
| Invariant: individual and total degree | §1.3 (structural + support accounts) | adequate |
| Invariant: field size | §1.3, §3 (field-size nodes with `q=2^k`, parity, divisibility) | adequate |
| Invariant: variable-block dependence of each `g_i` | §1.3 `Dependencies`, §2 `build_pcp` | adequate |
| Invariant: **number and form of random queries** | — | **missing** — `table:tpcp` never transcribed (M13) |
| Invariant: whether a sampler is conditionally linear | §1.5 `CLZero`/`CLStep` | **inadequate** (M6) |
| Invariant: description size and runtime of generated terms | §1.1, §1.6, §3 `Bound` | adequate |
| Invariant: completeness and soundness transformations | §1.6, §4 | **inadequate** (M8) |
| `Checked{T,C}` with an explicit derivation tree, not informal comments | §1.6, §3 | adequate but over-built (m24) |
| Distinguish closure / quoted syntax / compiled circuit / universal evaluator / specialization | §1.1, DD-1 | adequate (three of five types unused, m24b) |
| Pipeline `D -> trace -> 3SAT -> decoupled 5SAT -> arith -> LD-PCP -> D_AR` | §2 signatures + evidence extension list | **inadequate** — no `detype`, no `restrict_to_line` (M11, m21) |
| Symbolic `g_i`, `F_arith`, `c_0`, zero-on-cube certificate | §1.3, §1.4 | adequate; the rewrite and its `d-2` bookkeeping verified by me on two examples |
| Symbolic point queries, axis/diagonal line restrictions | §1.5 (maps) | **inadequate** — restriction combinator missing (m21) |
| Formula test, zero-on-subcube test | §2 item 5, §4.1, §5.1 | adequate (faithful to `fig:pcpverifier`) |
| Low-degree tests | §4.2, §5.3 | adequate (`D^ld` executable, `lem:ld-soundness` CITED) |
| Consistency with encoded player answers | §5.4 (steps 1,2,4a named) | **inadequate** — guards unspecified (M13) |
| Demonstrate perfect completeness on a small explicit instance | §5.1 TB0 fixture | **inadequate** — degenerate and vacuous at `q=2` (M1, M3) |
| Soundness separated into (1) LD-proof implication (2) LD enforcement (3) Schwartz–Zippel (4) quantum rigidity | §4.1–§4.4, DD-13 | **adequate — the strongest part of the document** |
| "Do not claim that numerical testing proves soundness" | §4.4, §1.6, DD-9 | adequate in intent, unenforceable as encoded (M9) |
| D1 concise mathematical description of the term language | §1 | inadequate (M7) |
| D2 minimal executable Julia prototype | deferred by brief 01; layout in §6 | adequate for scope |
| D3 at least one explicit small PCP instance passing completeness checks | §5.1 | **inadequate** (M1, M3) |
| D4 automatic degree and dependency reporting | §1.3, §3 trace printer | adequate |
| D5 explicit PCP query sampler + conditional-linearity assessment | §1.5, §8 | inadequate (M5, M6) |
| D6 transformation trace of intermediate symbolic objects | §3 | adequate |
| D7 sober assessment of what became clearer / what remains hard | §7 item 8 | adequate (honest, thin) |
| D8 recommended next step toward the **complete** answer-reduction transformation | §7 item 9 | **inadequate** — §7.9 names only a front-end next step; the gap between TB2 and a complete AR (oracularization, detyping, quantum lifting) is never scoped |
| Broader structural question (algebra `Q`, closure laws) — claim C7 | §8 | adequate as "preliminary", correctly refuses to conclude |
| Diagnostic toy (midpoint), claims C6/N1 | §5.2 | adequate mathematically; duplicates `toys/midpoint` (m20) |
| Language choice / zero dependencies | §6, DD-15 | adequate |

---

VERDICT: FAIL(M1,M2,M3,M4,M5,M6,M7,M8,M9,M10,M11,M12,M13)
