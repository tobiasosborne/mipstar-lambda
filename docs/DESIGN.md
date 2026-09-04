# Symbolic term language and Julia architecture

All mathematical names in this document have one authoritative entry in [`definitions.md`](definitions.md). A source citation has the form
`file:Lfirst-Llast (label)`. Evidence uses one fixed enumeration:

- **CONSTRUCTED**: true because no IR value of the stated type can be built without the property;
- **CHECKED**: computed from the value and accompanied by a replayable derivation or certificate;
- **CITED**: imported from the named source and not replayed locally;
- **ASSUMED**: an explicit, undischarged hypothesis;
- **SOURCE_REPAIR**: a visible totalization or source correction.

Only CONSTRUCTED and CHECKED leaves can discharge a machine-checkable claim. CITED leaves may occur in an honest derivation tree, but keep
that tree from being reported as a local proof.

## 1. The term language

### 1.1 Program and description sort

The lambda layer is a phase-separated, explicitly represented calculus. It is not `Expr`, and a macro cannot create an IR node except
through the same checked constructors used by ordinary functions.

Let `Name`, `PrimName`, `Nat`, `MachineDesc`, `Level`, and `StaticEnv` be finite serializable data, and let `Sampler` and `Compressor` be
declared program-result sorts. The mutually defined auxiliary sorts are

```text
Pargs ::= P*
Fuel  ::= FuelLiteral(Nat) | FuelBound(P{Nat},P{Level})
```

and the inductive grammar is

```text
P ::= BoundVar(depth, slot)                  variable
    | Hole(name, sort)                       typed specialization hole
    | Lambda(arity, P)                       abstraction
    | Apply(P, P*)                           application
    | Fix(P)                                 fixed-point combinator
    | If(P, P, P)                            conditional
    | Prim(PrimName, Bound, P*)              bounded primitive
    | Quote(Closed(P))                       syntax as a value
    | Eval(Pcode, Pargs, Fuel)               fuel-bounded evaluator
    | Specialize(Pcode, StaticEnv)           code-to-code substitution
```

Here `P{A}` denotes the subset of program terms whose constructor/primitive contracts give result sort `A`. `BoundVar` uses de Bruijn
addresses internally; a side table retains source names for printing. A `PartialProgram` may contain typed holes.
`Closed(P)` means that every `BoundVar` is scoped and no `Hole` remains. `Specialize : PartialProgram x StaticEnv -> ClosedProgram` is
defined only for a total, sort-correct environment covering exactly the remaining holes. Every primitive carries a total input contract and
a symbolic cost bound. Literal values use nullary primitives; in particular, `true` abbreviates `Prim(true,Concrete(1),())`. `Eval` takes
`Pargs : P*`, consumes a value of sort `Fuel`, and returns `Value`, `OutOfFuel`, or `TypeError`, never a host-language exception. `Fix(P)`
requires the distinguished hole `self_code : Quoted{Decider}`, ties it to the quote of the result, and returns closed syntax.

Only the two representations used by the rungs are IR types:

```text
Quoted{A}     = canonical bytes for a closed P : A         -- description
CircuitIR     = finite Boolean DAG                          -- compiled object
```

An evaluator closure is a runtime value, never accepted by compilation; a universal evaluator is an ordinary distinguished `Quoted`
program; and specialization is `Checked{Quoted{A},SubstCert}`, not a third representation. `Quoted{A}` has a canonical serialization and an
exactly computed `description_size`. This is the intensional fact needed by Cook--Levin, whose bounded-halting input
contains a machine description and fuel, and by answer reduction, whose parameters include `|D|` (`gt-10-answer-reduction.tex:L200-L205`,
`L1396-L1422`, `L2077-L2096`). `Compress` likewise receives and returns descriptions (`gt-12-compression.tex:L26-L39`, `L75-L98`).

The description-level fixed-point constructor has the interface

```text
Fix : PartialProgram{self_code::Quoted{A}} -> ClosedProgram{A}
eval(Quote(Fix(P)),u;fuel) = eval(specialize(P,{self_code=>Quote(Fix(P))}),u;fuel)
```

for every fuel at which both sides terminate. It is syntax, not Julia recursion. In the display below, `M:P{MachineDesc}` and
`L:P{Level}` are closed literal terms, `n:P{Nat}` and `x,y,a,b` are the five bound arguments, `S_L:ClosedProgram{Sampler}`, and
`Compress:ClosedProgram{Compressor}`. The names `halts_within`, `true`, and `quoted_pair` are declared `PrimName`s, while `self_code` is
the displayed typed hole; consequently the display has no other free symbols. The halting verifier is the following term:

```text
Psi_M_L = Lambda(5,                         -- n,x,y,a,b
  If(Prim(halts_within, Opaque("n steps",(n,)), M, n),
     Prim(true, Concrete(1), ()),
     Eval(Apply(Quote(Compress),
                Prim(quoted_pair, Concrete(1), Quote(S_L),
                     Hole(self_code,Quoted{Decider})), L),
          (n,x,y,a,b), FuelBound(n,L))))

D_M_L = Fix(Psi_M_L)
```

Thus `D_M_L = Fix(Psi_M_L)` is a finite closed term, matching the fixed-point equation in `handoff.md:L21-L35`. The bounded `quoted_pair`
primitive joins two code values without capture. `Compress` sees the resulting quote `(S_L,d)`, traverses and specializes that body,
computes its byte length, and never attempts to compare or serialize the function computed by `d`.

Program invariants are recorded as follows.

| invariant                        | status            | representation                         |
|----------------------------------|-------------------|----------------------------------------|
| scope and phase correctness      | CONSTRUCTED       | `Closed`, `Quoted`, and typed holes    |
| canonical description size       | CHECKED           | canonical byte count, replay           |
| primitive cost                   | ASSUMED           | a separate CITED node may discharge it |
| bounded evaluation trace         | CHECKED           | transition-by-transition trace         |
| fixed-point extensional behavior | CITED             | never promoted by execution samples    |

**DD-1 — Separate descriptions from compiled objects.** Keep `Quoted` and `CircuitIR` disjoint and make runtime closure, universal evaluator,
and specialization roles explicit without extra wrapper types; rationale: compression is intensional; rejected: accepting `Function` or raw
`Expr` wherever code is expected.

**DD-2 — Fuel every evaluator.** `Eval` is total and returns an explicit out-of-fuel result; rationale: bounded traces must be finite;
rejected: host-language evaluation of arbitrary quoted Julia.

### 1.2 Circuit and formula sort

The Boolean grammar is

```text
BWire ::= Input(BlockName, offset) | Gate(GateId)
BGate ::= Not(BWire) | And(BWire*) | Or(BWire*)
Circuit ::= DAG(InputBlocks, topologically_ordered BGate*, output)
Formula ::= Lit(BWire, sign) | FAnd(Formula*) | FOr(Formula*)
```

Fan-in is explicit and normalized to at most two. The private `Circuit` constructor checks unique gate identifiers, topological references,
block extents, and the output wire. Its gate count `s`, fan-out vector, and block lengths are computed fields.

The front-end IR values are:

```text
BoundedTrace(program, input, T, configurations, result)
Succinct3SAT(C3, variable_count=M, index_width=m)
SuccinctDecoupled5SAT(C5,
  index_blocks=(X1[N1],...,X5[N5]), sign_block=O[5], clause_shape)
PaddedSuccinctDecoupled5SAT(C5,index_blocks=(X1[m],...,X5[m]),...)
TseitinFormula(formula, input_blocks, gate_block=W[s], occurrences)
```

`C5(x1,...,x5,o1,...,o5)=1` exactly when the clause `x1[x1]^o1 or ... or x5[x5]^o5` is present. The five possibly unequal index blocks and
five sign bits are structural fields, not a naming convention; this is the paper's decoupled clause shape
(`gt-10-answer-reduction.tex:L920-L979`). Equal `m`-bit blocks are the explicitly padded specialization supplied by
`prop:explicit-padded-succinct-deciders` (`gt-10-answer-reduction.tex:L1226-L1246`). The full formula `phi_C` is intentionally not
materialized.

Tseitin adds one Boolean variable `w_i` for each gate, forms the NW19 equivalence formula
`z_i=(g_i and w_i) or (not g_i and not w_i)`, conjoins the `z_i` in the stored binary tree, **and conjoins the output literal `w_out`**.
That last conjunct repairs NW19's omitted output constraint (finding F2). The result has `n+s` variables, size `O(s)`, and satisfiable
extensions exactly for accepting circuit inputs (`gt-10-answer-reduction.tex:L148-L158`, correcting `formula(x,s)` to `formula(x,w)`).
`occurrences` is computed by traversing the formula tree; sharing in the circuit is duplicated as leaf occurrences in the formula.

`arith_q` recursively maps Boolean values to a polynomial over `F_q`:

```text
false -> 0              not(a) -> 1-a
true  -> 1              and(a,b) -> a*b
                         or(a,b) -> a+b-a*b
```

and extends variadic gates by a fixed binary bracketing stored in the trace. Agreement with the Boolean formula on `{0,1}` is checked on
tracer instances and has grade CITED outside them. The known source typo gives the domain as `F_q^{m'}` for an
`m`-variable formula; the design uses the number of formula variables (`gt-10-answer-reduction.tex:L160-L171`).

Arithmetization is multilinear in leaf occurrences, hence
`deg_v(F_arith) <= occurrences[v]`. For the NW19 equality gadget,
`occ(x)=2*fanout(x)` for a circuit input and
`occ(w_i)=2+2*fanout(w_i)+indicator(i=out)` for a gate wire. This replaces the disputed source claim that every variable occurs at most twice
(`gt-10-answer-reduction.tex:L173-L191`); it is a structural upper bound, checked against support on TB0 and the F1 two-gate regression.

| invariant                                      | status         | representation              |
|------------------------------------------------|----------------|-----------------------------|
| DAG and named block shape                      | CONSTRUCTED    | private constructors        |
| gate count `s` and formula occurrences         | CHECKED        | traversals                  |
| decoupled five-block clause form               | CONSTRUCTED    | fixed product type          |
| trace/formula faithfulness on a finite fixture | CHECKED        | exhaustive table            |
| general Cook--Levin faithfulness/size          | CITED          | cited proposition leaf      |
| per-variable formula occurrences               | CHECKED        | formula-tree traversal      |
| `deg_v(arith_q(F)) <= occurrences[v]`           | CHECKED        | structural derivation       |

**DD-3 — Make blocks first-class.** Store block identities and extents on every wire; rationale: dependency and decoupling checks then
require no name parsing; rejected: flat integer variable identifiers with prefixes.

**DD-17 — Equal blocks mean padded instances.** Represent unequal `N_1,...,N_5` in the general sort and expose five equal `m`-bit blocks
only through the cited padding transformation; rationale: equality is a specialization, not `def:decoupled-5sat`; rejected: baking padding
into the base datatype.

**DD-18 — Bound arithmetization by occurrences.** Compute the full occurrence vector and treat the paper's uniform bound 2 as
`SOURCE_REPAIR(C8)`; rationale: the formula-tree bound survives fan-out and is red-capable; rejected: an occurrence-at-most-two
constructor that rejects every genuine fan-out-one Tseitin circuit.

### 1.3 Polynomial sort

The mathematical sort is

```text
Poly[F_q, Variables(blocked), IndividualDegreeBound, Dependencies]
```

and the payload is a sparse formal polynomial

```text
Dict{ExponentVector,FieldElement}
```

with zero coefficients removed and monomials in canonical lexicographic order when serialized. `FieldElement` is generic; the first
implementation supplies `GF2k{K,Modulus}` and a small prime-field test type. Formal polynomials are not reduced modulo the
polynomial-function identities `z_i^q-z_i`, because the zero-basis checker needs coefficient-wise equality.

Every polynomial carries two independent degree accounts:

1.  `structural::DegreeDerivation`, computed while constructing the expression;
2.  `actual::SupportReport`, recomputed only from nonzero dictionary support.

A bound is a coordinate vector, with derived maximum individual and total degree. The derivation constructors are:

```text
Constant(0)                         Variable(j, 1)
Sum(max_coordinatewise, children)   Product(sum_coordinatewise, children)
Restrict(substitute and project)     MultilinearExtension(bound=1; bound=0 for a constant table)
    ArithFormula(occurrence vector)
RewriteQuotient(input bound, divided coordinate)
Weaken(old_bound, stated_bound)
```

`Product` adds only bounds on the same coordinate. Consequently the disjoint dependencies of `g_1,...,g_5` are visible rather than discarded
by a scalar `5d` bound. `dependencies` is both a set of coordinates and its projection to named blocks. A report is valid only when actual
support is coordinatewise below the structural bound. For C3, the explicit fixture additionally requires the exact structural vector after
normalization to equal the support-computed vector; changing either computation turns the test red.

The paper defines individual and total degree and the multilinear code at `gt-03-prelim.tex:L832-L897`. `g_a` is constructed as

```text
sum(a[y] * product(x[i] if y[i]=1 else 1-x[i]) for y in {0,1}^m)
```

and receives a `MultilinearExtension` leaf with dependency contained in its own `X_i` block; a recognized constant table has bound zero and
empty dependency. `dec_H` is evaluation on the Boolean subcube
followed by the paper's membership-or-zero rule (`gt-03-prelim.tex:L917-L924`).

Sparse expansion is intentionally small-scope. Before coefficient merging,

```text
support(c0) <= support(F_arith) * product_i (support(g_i)+1).
```

At `m=2`, dense multilinear `g_i` already give the factor `5^5=3125`; expanding a Tseitin arithmetization over 16--32 variables can dominate
memory. Constructors therefore accept a `MonomialBudget`. Immediately before each sparse multiplication they compute the single-product
candidate count `|partial support|*|next factor support|`; they return `ExpansionRefused(estimate,budget)` without partial output if that
one product would exceed the budget. The budget is not a cumulative sum across multiplications. The factor count is derived from the
displayed formula, not assumed to be `2^5`: table `[0,1]` gives `g_i=X_i` and a two-term `g_i-O_i`, whereas `[1,0]` gives
`g_i=1-X_i` and the three-term factor `1-X_i-O_i`. Thus a tuple with complement tables in positions 2 and 4 would have factor product
`2*3*2*3*2=72` and coarse estimate `6^3*7^3*72=5,334,336`, not the binomial-only estimate. TB0's fast degenerate witness has the
coarse pre-normalization estimate `7^3*6^3*2 = 148,176` candidates (three AND and three NOT equality gadgets, then one two-term and four
one-term PCP factors), with `MonomialBudget=160,000`; the r2 critic's incremental sequence predicts a peak single-product count of 54,978.
The retained all-nonconstant witness uses five `[0,1]` tables, so §1.3's formula gives the pre-normalization estimate
`7^3*6^3*(1+1)^5 = 2,370,816`; the r3 critic's incremental construction predicts a peak single-product count of 788,032. Because that
peak is below 2,500,000 under the per-multiplication rule, its separate `MonomialBudget=2,500,000` is retained. A normalized monomial count
is always reported as a measurement, never as either estimate. The sparse representation is an experiment, not a claim of scalability.

| invariant                             | status                          | representation                      |
|---------------------------------------|---------------------------------|-------------------------------------|
| coefficient field and variable layout | CONSTRUCTED                     | type parameters/value tags          |
| zero-free normalized support          | CONSTRUCTED                     | private polynomial constructor      |
| structural degree/dependency bound    | CHECKED                         | replayed derivation tree            |
| actual degree/dependency              | CHECKED                         | support traversal                   |
| equality of two polynomials           | CHECKED                         | normalized coefficient dictionaries |
| paper-scale feasibility               | ASSUMED                         | must be measured before use         |

**DD-4 — Keep both degree accounts.** Retain construction bounds and support-computed degrees; rationale: their disagreement is a
red-capable test; rejected: trusting annotations or computing only after expansion.

**DD-5 — Use sparse formal polynomials first.** Bound expansion and fail explicitly; rationale: it makes C1--C3 transparent on small
instances; rejected: an evaluator-only polynomial that cannot certify coefficient identities.

### 1.4 Zero-on-subcube certificate

Let `zero(z_i)=z_i(1-z_i)`. `zero_basis_decompose(c0, order)` always returns a division trace, possibly with a nonzero remainder. For each
variable in the fixed order and each current monomial `a*u*z_i^e`, `e>=2`, it applies exactly

```text
a*u*z_i^e
  -> a*u*z_i^(e-1) - a*u*z_i^(e-2) * zero(z_i).
```

The identity follows because `z_i^(e-1)-z_i^(e-2)(z_i-z_i^2)=z_i^e`. The coefficient `-a*u*z_i^(e-2)` is accumulated in `c_i`; the first
term remains in the running remainder. Sorting variables and monomials makes the trace deterministic. This is executable polynomial division
from the proof of `prop:zero-basis` (`gt-10-answer-reduction.tex:L1281-L1327`).

After variable `i`, the remainder is multilinear in variables `1,...,i`. At the end it is a multilinear polynomial `r` and the checker
independently normalizes both sides of

```text
c0 == sum(c_i * zero(z_i), i=1:m') + r.
```

It then checks `support(r)==empty`. Only then may `DivisionCertificate` be promoted to `ZeroOnSubcubeCertificate`. This is strictly
coefficient-wise; evaluations are diagnostic only. The mathematical reason a multilinear remainder vanishing on the cube is identically zero
is given at `gt-10-answer-reduction.tex:L1329-L1373`; explicit fixtures also check all Boolean points.

For input coordinate bounds `D_j`, the trace certifies

```text
deg_j(c_i) <= D_j                         for all j,
deg_i(c_i) <= max(D_i-2, -infinity),
deg_j(c_i) <= 1                           for j < i.
```

Thus if `c0` has individual degree at most `d`, every `c_i` has individual degree at most `d`, and the divided variable has degree at most `d-2`,
exactly the stronger remark in the paper (`gt-10-answer-reduction.tex:L1311-L1322`). Both the general bound and these coordinatewise
stronger bounds are checked from support. TB0 has `inddeg(c_0)=6` and uses `d=6` on the small-field structural row and the paper parameter
`d=11` on the sampled row; its quotient bounds are measured rather than predeclared (`gt-10-answer-reduction.tex:L1685-L1717`).

For C2, `r==0 iff the witness satisfies phi_C` is not baked into the division type. The explicit instance checks both directions by
enumerating its finite clause relation and Boolean assignments. The general implication uses the succinct-decider contract and remains
CITED.

**DD-6 — A failed zero proof is data.** Return the nonzero multilinear remainder rather than throwing it away; rationale: the mutation
explains its own failure; rejected: a Boolean `is_zero_on_cube` flag.

### 1.5 Sampler sort

Sections 9--12 refine this in-memory algebra into the canonical `SamplerDescription`
boundary used by executable `Introspect`, `Repeat`, and `Compress`; the four-query
interface there is the authoritative cross-transformation API.

The sampler sort is

```text
Sampler[DistributionClass, AdaptivityLevels]
```

where conditional linearity is witnessed by the following inductive datatype, which mirrors `def:cl-func` (`gt-04-cl.tex:L35-L57`):

```text
CLZero(V) :: CL{0,V}                       -- the zero function

CLStep(V1, Vrest, A,
       branch : image(A) -> CL{ell-1,Vrest}) :: CL{ell,V1 direct_sum Vrest}
```

`V1` and `Vrest` are disjoint coordinate-index sets spanning the ambient standard basis: register subspaces, full stop. This is the paper's
requirement (`gt-03-prelim.tex:L231-L239`; `gt-04-cl.tex:L35-L57`) and the bit-vector form required of a sampler
(`gt-04-cl.tex:L590-L595`). `A` is a matrix acting on `V1`, so linearity is CONSTRUCTED. A branch is genuinely a function of the previous
value, not a preselected child. Its codomain level and remaining ambient register are fixed by the type. Therefore “is CL of level ell” is
CONSTRUCTED, not discovered by sampling.

The defining evaluator is

```text
apply(CLZero(V), x) = 0
apply(CLStep(V1,Vr,A,b), x) = A(project(V1,x))
                             + apply(b(A(project(V1,x))), project(Vr,x)).
```

`level`, `apply`, and `marginal_k` are total. `marginal_k` returns the first `k` stages and their factor spaces/linear maps, matching
`lem:cl-kth` (`gt-04-cl.tex:L150-L178`). The algebra contains:

```text
concatenate(CL{k,U}, u -> CL{ell,V}) -> CL{k+ell,U direct_sum V}
direct_sum(CL{ell_1,V1},...,CL{ell_r,Vr}) -> CL{max ell_i,direct_sum Vi}
distribution(L,R) -> UniformSeedPushforward(mu_L_R)
product(S1,S2) -> direct sums of left maps and of right maps
```

These are datatype transformations with derivations of the level equations. They implement `lem:cl-concat` and direct sums
(`gt-04-cl.tex:L282-L327`), while `distribution` is exactly the shared-uniform-seed definition (`gt-04-cl.tex:L132-L138`).
Runtime metadata imports the bounds in `gt-07-ldt.tex:L465-L490 (lem:ld-complexity)` as CITED bounds.

A typed sampler is

```text
TypedSampler(TypeSet, TypeGraph,
  left::Dict{Type,CL{<=ell,V}}, right::Dict{Type,CL{<=ell,V}})
```

with functions padded to the common maximum level. Sampling first chooses an oriented edge of the type graph and then pushes one uniform
ambient seed through the selected pair. This is the typed-CL notion, not an independent mixture (`gt-06-types.tex:L57-L93`, `L95-L151`).
Detyping is a separate CITED transformation which adds two levels and has a `16^|TypeSet|` soundness loss (`gt-06-types.tex:L435-L475`).

For `V=V_pt direct_sum V_coord direct_sum V_dir`, write `u in F_q^m`, `s_coord in F_q`, and `v in F_q^m`. The concrete values are:

```text
L_Point(u,s_coord,v) = (u,0,0)                                      level 1
L_ALine(u,s_coord,v) = (L_lnf(e_chi(s_coord))*u, s_coord, 0)        level 2
L_DLine(u,s_coord,v) = (L_lnf(pi_(chi(s_coord)-1)(v))*u,
                         s_coord, pi_(chi(s_coord)-1)(v))            level 3
```

`chi(s_coord)=1+floor(integer_representation(s_coord)/(q/m))`, requiring `m | q`. `L_lnf(v)` is the canonical projection whose kernel is `span(v)` and
whose image is the canonical complement (`gt-03-prelim.tex:L375-L384`; `gt-07-ldt.tex:L143-L174`). For `v=0`, where the cited kernel-basis
definition does not apply although singleton lines are explicitly allowed, the IR uses `L_lnf(0)=identity` and marks the node
`SOURCE_REPAIR` (`gt-07-ldt.tex:L106-L124`). `L_ALine` has two stages: project `V_coord direct_sum V_dir` onto `V_coord` while zeroing
`V_dir`, then apply `L_lnf(e_chi(s_coord))` on `V_pt`. `L_DLine` has three stages: coordinate, direction, then point
(`gt-07-ldt.tex:L203-L237`). Exact histogram comparison tests the induced line-point distributions stated in
`lem:alnf` and `lem:dlnf` (`gt-07-ldt.tex:L243-L287`).

The typed PCP sampler has 18 types `Point_i`, `ALine_i`, `DLine_i`, `i=1,...,6`, and a complete type graph. Its registers are five
`m`-dimensional point/direction triples plus auxiliary point/direction blocks of dimension `5+s`; hence
`dim(V_{6,pt})=dim(V_{6,dir})=m'=5m+5+s`. Equation `eq:V-pcp` instead gives `dim(V_{6,coord})=6`, while `table:tpcp` supplies one scalar to
copy 6. The IR preserves the six-dimensional register and records a `SOURCE_REPAIR`: `L_ALine_6` and `L_DLine_6` read `s_aux`, the
`V_aux,coord` component, and zero/ignore the five other coordinate components. This convention is explicit and not attributed to the paper.
Copies 1--5 test `g_i` separately and copy 6 tests `(g_1,...,g_5,c_0,...,c_m')` simultaneously
(`gt-10-answer-reduction.tex:L1870-L1946`). The 18 maps form one typed family; each is level 1, 2, or 3 on all of `V^pcp`, zeroing other
registers, and is padded to the common maximum level 3. It is not a product of six samplers.

The answer-reduced typed sampler is the product of this sampler and the oracularized sampler. Oracularization uses types
`{alice,bob,oracle}`, maps the isolated types by `L^alice,L^bob`, and maps `oracle` by the identity (`gt-09-oracularization.tex:L36-L86`).
Product means direct-summing their ambient spaces and CL functions and taking the product type graph; its typed level is `max(ell,3)`
(`gt-10-answer-reduction.tex:L1948-L1965`).

| invariant                       | status                 | representation                    |
|---------------------------------|------------------------|-----------------------------------|
| CL level                        | CONSTRUCTED            | `CLZero`/`CLStep` nesting         |
| linearity of a stage            | CONSTRUCTED            | field matrix                      |
| complementary spaces            | CONSTRUCTED            | disjoint coordinate-index sets    |
| `apply`/marginal agreement      | CHECKED                | exhaustive small-field replay     |
| typed graph and product         | CONSTRUCTED            | finite graph/product constructors |
| equality to paper distributions | CHECKED                | TB1 exact histograms              |
| low-degree-test soundness       | CITED                  | theorem leaf only                 |

**DD-7 — Encode CL inductively.** Make the conditional continuation a field of `CLStep`; rationale: level is then impossible to forge;
rejected: arbitrary functions plus an `is_cl=true` tag.

**DD-8 — Keep typing until the boundary.** Build and test the typed PCP product before detyping; rationale: Figure `decider-pcp` reasons in
those types; rejected: flattening type tags into question bytes at construction time.

**DD-19 — CL stages use register subspaces only.** Store disjoint coordinate-index sets and delete the general-subspace/rank-certificate
branch; rationale: this is exactly `def:register-subspace`; rejected: general complementary subspaces that witness a broader notion than CL.

**DD-20 — Totalize copy 6's coordinate conflict visibly.** Preserve `dim(V_{6,coord})=6` from `eq:V-pcp`, let `chi` read `s_aux`, and mark
the choice `SOURCE_REPAIR`; rationale: it exposes rather than erases the conflict with scalar `table:tpcp`; rejected: the previous incorrect
dimension `m'`.

### 1.6 Verifier sort and contracts

The stub status recorded in this section describes TB4.  Sections 9--12 supersede
only that implementation status: the constructions become executable description
transformers, while their theorem-level completeness and soundness leaves remain
CITED.

The verifier sort is

```text
Verifier[QuestionLength, AnswerLength, Runtime, Gap, Levels]
```

with payload `(sampler,decider,description)` and symbolic measures for sampler and decider separately. `Gap` is a directed implication
between value thresholds, not one floating-point number. Every public transformation returns

```julia
struct Checked{T,C}
    term::T
    certificate::C
end
```

The word `Checked` means “paired with inspectable evidence,” not “proved.” Its certificate grade is always printed.

| verifier invariant | grade | representation |
|---|---|---|
| question/answer lengths and parser shapes | CHECKED | sampler/decider traversal |
| CL levels | CONSTRUCTED | sampler datatype |
| local runtime and description size | CHECKED | exact local counters |
| asymptotic runtime/size bounds | CITED | theorem node |
| gap/completeness/entanglement transform | CITED | theorem node |
| finite-fixture completeness | CHECKED | named tracer checker |
| executable versus stub | CONSTRUCTED | `VerifierIR` versus `StubVerifier` |

The transformation contracts are conditional and their `CITED` nodes retain every hypothesis:

- `Introspect(V,lambda,ell)`: **ASSUME** `V` is a `lambda`-bounded `ell`-level verifier. **PROVE** the 5-level result, sampler time
  `poly(n,lambda,ell)`, decider time `poly(2^(lambda*n),ell)`, description `poly(lambda,ell)`, and the stated completeness, soundness, and
  entanglement implications (`gt-08-introspection.tex:L784-L817`). It is a `StubVerifier` with a CITED `thm:introspection` node.
- `answer_reduce_pcp(V,lambda,mu,gamma)`: **ASSUME** `V` is an `ell`-level normal-form verifier,
  `T(n)=(2^(lambda*n))^mu`, `Q_len(n)=Q_time(n)=(lambda*n)^mu`, `TIME_D(n)<=T(n)`, and `TIME_S(n)<=Q_time(n)`.
  **PROVE** the typed construction has level `max(ell,3)`; its finite PCP checks are executable, while oracularization soundness and quantum
  lifting are CITED. `detype` then **PROVES, CITED**, level `max(ell,3)+2=max(ell+2,5)`, the `16^|Type^ar|=16^54` soundness loss, and the
  theorem's complexity, completeness, soundness, and entanglement implications for `n>=2`
  (`gt-10-answer-reduction.tex:L2077-L2116`). The fixed `16^54` factor is absorbed only into the universal constant `a` of that CITED
  theorem; it is never omitted from the detyping certificate.
- `Repeat(V,lambda,tau)`: **ASSUME** `V` is an `ell`-level normal-form verifier. **PROVE** `k(n)=(lambda*n)^((1+c')*tau)`, level `ell+2`,
  the stated runtime and soundness/entanglement implication; completeness additionally assumes `TIME_D(n)<=(lambda*n)^tau`
  (`gt-11-parallel-repetition.tex:L229-L258`). It remains a CITED stub.
- `Compress(V,lambda)`: unconditionally **PROVES, CITED**, a 9-level normal-form output, `poly(n,lambda)` runtimes, and sampler-description
  independence. For completeness and soundness additionally **ASSUME** `V` is a `lambda`-bounded 9-level normal-form verifier,
  `n>=C_0`, and `N=2^n`; **PROVE** only the theorem's stated implications (`gt-12-compression.tex:L26-L53`, `L75-L118`). It remains a
  composition skeleton.

An ASSUMED parameter cannot be silently converted to a Julia type parameter. Construction bounds may be propagated, while theorem
conclusions remain certificate leaves. `verify_certificate` prints every undischarged hypothesis carried by a `CITED` node.

#### Figure `decider-pcp`: complete executable specification

For `i=1,...,5`, copy `i` uses dimension `m`; copy 6 uses point/direction dimension `m'`. The parsers transcribe `table:tpcp`
(`gt-10-answer-reduction.tex:L1987-L1998`):

| PCP type | question | answer |
|---|---|---|
| `Point_i`, `i=1,...,5` | `y_i in F_q^m` | `alpha_i in F_q` |
| `ALine_i`, `i=1,...,5` | `v_i in F_q^m x F_q` | `h_i : F_q -> F_q` |
| `DLine_i`, `i=1,...,5` | `v_i in F_q^m x F_q x F_q^m` | `h_i : F_q -> F_q` |
| `Point_6` | `z=(y,o,w) in F_q^{m'}` | `(alpha'_1,...,alpha'_5,beta_0,...,beta_{m'}) in F_q^{m'+6}` |
| `ALine_6` | `v in F_q^{m'} x F_q` | `(h'_1,...,h'_5,f_0,...,f_{m'}) : F_q -> F_q^{m'+6}` |
| `DLine_6` | `v in F_q^{m'} x F_q x F_q^{m'}` | `(h'_1,...,h'_5,f_0,...,f_{m'}) : F_q -> F_q^{m'+6}` |

Parse each product type as `(t_Q,t_Pi) in Type^ora x Type^pcp` and each question as `(x_Q,x_Pi)`. For each
`w in {alice,bob}` in sequence, with `bar(w)` the other player and `alice<->1`, `bob<->2`, perform exactly these five top-level checks,
continuing past an untriggered guard (`gt-10-answer-reduction.tex:L2001-L2071 (fig:decider-pcp)`). The corresponding low-degree subroutine
states its otherwise-accept convention explicitly (`gt-07-ldt.tex:L368 (fig:ld-decider)`):

| step | exact type-pair guard | check and parameters |
|---|---|---|
| 1 global consistency | `t_alice=t_bob` (equality of both product types) | reject iff `a_alice != a_bob` |
| 2 input consistency | `t_Q,w=oracle`, `t_Q,bar(w)=v in {alice,bob}`, and `(t_Pi,w,t_Pi,bar(w))=(Point_6,Point_v)` | reject iff `alpha_v != alpha'_v` |
| 3 input low degree | `t_Q,w=t_Q,bar(w)=v in {alice,bob}` and `(t_Pi,w,t_Pi,bar(w))=(Point_v,ALine_v)` or `(Point_v,DLine_v)` | run `D^ld_(q,m,d,1)` with the matching line type; reject iff it rejects |
| 4 proof encoding | `t_Q,w=t_Q,bar(w)=oracle`; then (a) `(Point_i,Point_6)`, `i in {3,4,5}`: require `alpha_i=alpha'_i`; (b) `(Point_i,ALine_i)` or `(Point_i,DLine_i)`, `i in {3,4,5}`: run `D^ld_(q,m,d,1)`; (c) `(Point_6,ALine_6)` or `(Point_6,DLine_6)`: run `D^ld_(q,m',d,m'+6)` | reject on the named inequality or low-degree rejection |
| 5 game | `t_Q,w=oracle`; compute `x_(w,v)=L^v(x_Q,w)` for both `v in {alice,bob}`; additionally `t_Pi,w=Point_6` | run `pcpverifier((D,n,T,Q_len,gamma,x_(w,alice),x_(w,bob)),(z,a_w))`; reject iff it rejects, otherwise accept |

Thus `ldparams=(q,m,d,kappa=1)` in steps 3 and 4b, while `ldparams'=(q,m',d,kappa=m'+6)` in step 4c. The source's game-call omission of
`sigma=|D|` remains a visible typo; the executable specification reconstructs it from the quoted `D`, as recorded in risk 5.

**DD-9 — Let stubs have a distinct term type.** A theorem-backed placeholder is `Checked{StubVerifier,Cited}`; rationale: no caller can
mistake it for an executable verifier; rejected: a no-op function returning its input with a “proved” flag.

**DD-21 — Make `Levels` the compression index.** Check the chain `Introspect: _ -> 5`, `AnswerReduce: 5 -> 7`, `Repeat: 7 -> 9`, and
`Compress: 9 -> 9` at the type boundary; rationale: the fixed point's level closure becomes an executable typing fact; rejected: treating
levels as printable metadata only.

## 2. The combinator algebra

The signatures in this section are the TB0--TB4 surface.  Their description-level
replacements and the compatibility adapter are specified in §9.6.

All transformations below are pure functions on immutable IR values. A macro, if later added, may only parse surface syntax and call these
functions.

Illustrative Julia signatures are:

```julia
quote_program(p::ClosedProgram) :: Checked{QuotedProgram, ScopeAndSizeCert}
specialize(p::PartialProgram, env::StaticEnv) :: Checked{QuotedProgram, SubstCert}
bounded_trace(p::QuotedProgram, input, T::Nat) :: Checked{BoundedTrace, TraceCert}

cook_levin(t::BoundedTrace) :: Checked{Succinct3SAT, CookLevinCert}
decouple5(x::Succinct3SAT) :: Checked{SuccinctDecoupled5SAT, DecoupleCert}
tseitin(c::Circuit) :: Checked{TseitinFormula, TseitinCert}
arith_q(f::TseitinFormula, F::FieldSpec) :: Checked{Poly, ArithCert}

multilinear_extension(a::BlockAssignment, vars::VarBlock, F::FieldSpec)
    :: Checked{Poly, MultilinearCert}
build_c0(Farith::Poly, gs::NTuple{5,Poly}) :: Checked{Poly, DegreeCert}
zero_basis_decompose(c0::Poly, order::Vector{Variable})
    :: Checked{ZeroDecomposition, RewriteTrace}
build_pcp(s5::SuccinctDecoupled5SAT, witness::Witness5, params::PCPParams)
    :: Checked{PCPProof, PCPCert}
pcp_eval(Pi::PCPProof, z::Point) :: Checked{PCPView, EvaluationCert}
pcp_verifier(spec::DeciderSpec, view::PCPView) :: CheckResult
restrict_to_line(p::Poly, u0::Point, v::Direction)
    :: Checked{UnivariatePoly, RestrictCert}

low_degree_sampler(params::LDParams) :: Checked{TypedSampler, CLCert}
pcp_sampler(params::PCPParams) :: Checked{TypedSampler, CLCert}
oracularize_sampler(s::Sampler) :: Checked{TypedSampler, Cited}
answer_reduce_pcp(v::Verifier, lambda, mu, gamma)
    :: Checked{TypedVerifier, CompositeCert}
detype(v::TypedVerifier) :: Checked{VerifierIR, CitedCert}

Introspect(v::QuotedVerifier, lambda, ell) :: Checked{StubVerifier, Cited}
AnswerReduce(v::QuotedVerifier, lambda, mu, gamma) = detype(answer_reduce_pcp(v,lambda,mu,gamma))
Repeat(v::QuotedVerifier, lambda, tau) :: Checked{StubVerifier, Cited}
Compress(v::QuotedVerifier, lambda) :: Checked{StubVerifier, CompositeCert}
```

The pipeline extends evidence as follows.

1.  `D -> bounded_trace`: preserves the canonical quoted bytes, description size, input, and fuel `T`; appends every transition and the
    terminal result.
2.  `bounded_trace -> succinct 3SAT`: preserves `T` and input blocks; appends a trace/formula equivalence check for the fixture or a CITED
    Cook--Levin leaf generally. The paper's succinct contract is at `gt-10-answer-reduction.tex:L229-L260`.
3.  `succinct 3SAT -> succinct decoupled 5SAT`: records the map into five independent `m`-bit blocks plus five signs and checks the clause
    relation.
4.  `decoupled 5SAT -> Tseitin -> arith_q`: propagates `s`, the block layout, fan-out and occurrence vectors; appends Boolean-agreement and
    coordinatewise occurrence-bound derivations.
5.  `arithmetization -> low-degree PCP`: constructs five block-local `g_i`, `c0`, and the rewrite-certified `c_i`; appends degree/dependency
    support reports and the `pcpverifier` formula/zero checks (`gt-10-answer-reduction.tex:L1548-L1585`).
6.  `low-degree PCP -> D_AR`: constructs the six-copy typed CL sampler, products it with the oracularized sampler, installs the fully
    specified Figure `decider-pcp` checks, then applies the CITED `detype` transformation (`gt-10-answer-reduction.tex:L1973-L2071`).
    Quantum conclusions append CITED leaves; they are not inferred from passing samples.

`restrict_to_line` substitutes `u0+t*v` coefficientwise. `RestrictCert` records degree at most `d` for an axis direction and at most `m*d`
for a general diagonal direction, which are the formats checked by `D^ld` (`gt-07-ldt.tex:L348-L392`).

`build_pcp` checks the five dependency blocks and a `ParameterPolicy`. After the input preconditions `Q_len<=T` and `|D|<=sigma`, the six
named `def:pcpparams` obligations are:

1. `P_shape`: `m'=5m+5+s` and `m'` is a power of two;
2. `P_growth`: `k>=((gamma*b'+3a')/b')*log(s)`;
3. `P_formula_paper`: `(2+5k)*m'/2^k < 1/2`;
4. `P_tail`: `k*m'/2^k <= s^(-b'*gamma)`;
5. `P_divisibility`: `m'` divides `2^k` (and the sampler separately checks `m` divides `q`);
6. `P_degree`: `d=k`.

The tuple-formation rule additionally requires `q=2^k` for the smallest odd `k` satisfying obligations 2--5. These are individually
printable predicates from `gt-10-answer-reduction.tex:L1396-L1422`. Results involving the unknown constants—especially obligations 2 and
4—use the single `PASS`/`FAIL`/`NOT_EVALUABLE` semantics in [`definitions.md`](definitions.md#e-pcp-proof-view-and-answer-reduction);
there is no blanket result for either predicate. Separately, `P_formula_structural` checks `(deg_F+5d)*m'/q<1/2` with the computed
occurrence bound `deg_F`. It is an EXTRA obligation, not a consequence of `def:pcpparams`; the paper's literal-2 obligation 3 remains
`P_formula_paper` and is tagged `SOURCE_REPAIR(C8)`. `P_exponent_range: d<=q-1` records when formal sparse polynomials also meet the paper's
exponent range (`gt-03-prelim.tex:L836-L840`). Relaxations and extra obligations cannot disappear from the trace.

**DD-10 — One transformation, one evidence extension.** Each combinator retains its child's certificate and adds one node; rationale:
printed traces mirror the mathematics; rejected: rebuilding a flat metadata record at the end.

**DD-22 — Keep the structural formula inequality separate.** `def:pcpparams` chooses `k` using the literal-2
`P_formula_paper`, so every finite fixture checks `P_formula_structural` separately and a general derivation carries it as ASSUMED until
additional hypotheses discharge it. For the repaired NW19 formula, `deg_F<=2*fanout_max+3`. Copy gates can enforce
`fanout_max<=2` while at most doubling circuit size, so `deg_F<=7`; because the five block factors add at most one
to any coordinate, `d>=deg_F+1`, hence `d>=8`, suffices for the proof's individual-degree bound. For the inequality itself,
`P_growth` gives `k>4 log s`; with the explicit hypothesis `m'=O(s)`, this makes
`(deg_F+5k)m'/2^k=O(s^2/s^2.77)` even under natural-log convention (and `O(s^2/s^4)` in base 2), so
`P_formula_structural` follows for all sufficiently large `s`. This is the surviving absorption statement, not a property of item 2(b).

## 3. Invariant tracking and the derivation tree

The generic certificate core is deliberately smaller than the polynomial-plus-sampler algebra (target: at most half its source lines):

```text
@enum Grade CONSTRUCTED CHECKED CITED ASSUMED SOURCE_REPAIR
CertNode(grade::Grade, rule, facts, children, replay)
Checked(term, certificate::CertNode)
```

Every constructor, including composition, bounds, rewrites, Schwartz--Zippel, citations, assumptions, and repairs, is only a `CertNode` with
one of those five grades. A CHECKED node must carry `replay = term -> CheckResult`; verification fails if it is missing and recomputes it
against the attached term at test time. This makes stale evidence unrepresentable without detached caches. CITED nodes carry source, statement, and
theorem hypotheses; ASSUMED and SOURCE_REPAIR nodes carry their visible residue. `verify_certificate` returns structured failures and never
uses bare `@assert`. This machinery is retained because grade/replay mutation tests must be able to turn red; no detached evidence cache is
retained.

Symbolic bounds use only

```text
BoundExpr ::= Concrete(Int) | Opaque(description, parameters)
```

Exact degree and field arithmetic stays in the relevant polynomial/parameter checker; unspecified theorem polynomials remain `Opaque` with
their parameter names and hypotheses. Description sizes are `Concrete`; runtime and gap statements remain opaque when the source gives no
exponent. No `poly(...)` is silently assigned an exponent.

A concise trace printer emits, for example:

```text
[CHECKED] Quote                  |D| = 73 bytes
[CHECKED] BoundedTrace           T = 1; accepted
[CHECKED] Decoupled5SAT          blocks = 5x1 + 5 signs
[CHECKED] ArithTseitin           degrees = occurrences; inddeg = 6
[CHECKED] BuildC0                inddeg = 6; monomials = measured value
[CHECKED] ZeroBasis              remainder = 0; coefficient identity = true
[CHECKED] PCPVerifier            formula + zero tests = accept
[CONSTRUCTED] PCPSampler         typed CL level = 3
[CITED] LowDegreeEnforcement     gt-07-ldt.tex:413-440 (lem:ld-soundness)
[CITED] QuantumAnswerReduction   gt-10-answer-reduction.tex:2077-2116 (thm:ar)
```

Tests inspect the tree, not its prose: node sequence, grade, rule name, bound value/description, dependency set, and source label are all
matched. C1--C4 and C6 require no ASSUMED/CITED leaf in their machine-tested portion. C5 is a derivation tree whose two
Schwartz--Zippel nodes are explicit; its general Cook--Levin and theorem-level leaves remain visibly CITED.

**DD-11 — Keep bounds concrete or honestly opaque.** Use `Concrete(Int)` and `Opaque(description,parameters)` only; rationale: the paper
often does not expose exponents; rejected: an unused symbolic-expression language or invented exponents.

## 4. Soundness: what is and is not claimed

### 4.1 Soundness assuming low-degree proofs

This layer is a derivation, not a numerical experiment. Given a well-formed low-degree PCP proof `Pi` of individual degree at most `d` and
acceptance probability greater than `1/2`, construct:

```text
LowDegreePCPSoundness
|- FormulaTestOccursOnEveryAcceptedView                         [CHECKED]
|- FormulaAgreementProbability > 1/2                           [CHECKED]
|- Degree(formula difference) <= (deg_F+5d)m'                  [CHECKED]
|- SZ_Formula(total_degree=(deg_F+5d)m', field=q)               [CITED]
|- P_formula_structural on TB0-sampled: PASS (EXTRA obligation)[CHECKED]
|  `- ParameterInequality((deg_F+5d)m'/q < 1/2)
|- P_formula_structural for a general circuit                   [ASSUMED]
|  `- discharge requires a direct inequality or DD-22's fan-out,
|     m'=O(s), growth, and sufficiently-large-s hypotheses
|- FormulaPolynomialIdentity                                   [CHECKED]
|- ZeroTestOccursOnEveryAcceptedView                            [CHECKED]
|- ZeroAgreementProbability > 1/2                              [CHECKED]
|- Degree(zero difference) <= (2+d)m'                          [CHECKED]
|- SZ_Zero(total_degree=(2+d)m', field=q)                       [CITED]
|- ParameterInequality((2+d)m'/q < 1/2)                         [CHECKED]
|- ZeroPolynomialIdentity                                      [CHECKED]
|- BooleanCubeVanishes -> decoded assignments satisfy phi_C    [CITED]
|- SuccinctDeciderFaithfulness -> D accepts within T            [CITED]
```

The zero-test bound is the paper's. For the formula test, the source literally uses `(2+5d)m'`; the occurrence computation gives the
separate structural bound `(deg_F+5d)m'` (`gt-10-answer-reduction.tex:L1733-L1771`). The literal-2 predicate is retained as
`P_formula_paper` and tagged `SOURCE_REPAIR(C8)`; `P_formula_structural` is the EXTRA obligation defined in §2, evaluated with an explicit
PASS/FAIL result for each named fixture and ASSUMED in the general tree unless DD-22's hypotheses are supplied. Only the passing
TB0-sampled check appears in this soundness tree. Dependency-aware bounds may be printed diagnostically but do not replace this repaired
uniform bound. The final decoding argument is grounded at `gt-10-answer-reduction.tex:L1774-L1785`.

### 4.2 Enforcement via low-degree tests

The certificate stores

```text
delta_ld(epsilon,q,m,d,kappa)
  = a*(d*m*kappa)^a*(epsilon^b + q^(-b) + 2^(-b*m*d))
```

with side conditions and universal constants left symbolic. The claim that a strategy succeeding in the simultaneous low-degree game is
close to global individual-degree-`d` polynomial measurements is one CITED leaf, `gt-07-ldt.tex:L413-L440 (lem:ld-soundness)`. The classical
decider's consistency, axis-line, and diagonal-line checks are executable (`gt-07-ldt.tex:L348-L392`); executing them does not prove that
cited quantum theorem.

### 4.3 The Schwartz--Zippel step

`SchwartzZippelLemma` is a lemma object with fields `lhs`, `rhs`, `difference_nonzero`, `total_degree_bound`, `field_size`,
`uniform_domain`, and `bound=degree/q`. Its source is `gt-03-prelim.tex:L856-L864 (lem:schwartz-zippel)`. Applying it requires a checked
formal inequality for the total degree and records the hypothesis that the two formal polynomials are unequal. The contradiction node also
records the strict observed threshold and `degree/q < 1/2`; absent any field condition, the derivation stops rather than asserting identity.

### 4.4 Quantum consistency and rigidity

Oracularization soundness, low-degree rigidity/consistency, measurement consolidation, detyping soundness, and the lifting from PCP checks
to the entangled-value statement of `thm:ar` are CITED only. No matrix experiment, commuting-operator sample, or successful honest strategy
upgrades them. The trace printer groups these in a red-bordered `CITED QUANTUM` subtree so that a critic can distinguish them immediately
from coefficient checks.

**DD-13 — Split PCP soundness into four roots.** Keep low-degree implication, enforcement, Schwartz--Zippel, and quantum rigidity separate;
rationale: each has a different evidence grade; rejected: one `sound=true` field.

## 5. Tracer-bullet ladder

Every rung is a separately runnable test target, is scoped to one focused implementation session, prints its complete transformation trace,
and has a semantic or textual mutation expected to exit nonzero. The 60-second limit is checked by the test harness, with a 45-second
warning.

TB0 uses a real circuit on `(x_1,...,x_5,o_1,...,o_5)`, with exactly six gates, all fan-in at most two:

```text
w1 = NOT x1             w2 = NOT w1
w3 = NOT w1             w4 = w2 AND w3
w5 = w4 AND o1          w6 = w5 AND x5       (output)
```

Thus `w1` has fan-out two and `C=x1 AND o1 AND x5`. Among the `2^10` indexed signed clauses, exactly 128 are present and 896 absent; for
example `(x1,x5,o1)=(1,1,1)` with any remaining seven bits is present, while the all-zero input is absent. Exhaustive search over the
`2^10` five-block witnesses returns 512 satisfying witnesses: all and only those with the index-1 entry `a_1[1]=1`. TB0 retains two of them:

- **(i) fast degenerate witness:** `a_1=[0,1]`, `a_2=...=a_5=[0,0]`, so `g_1=X_1` and `g_2=...=g_5=0`;
- **(ii) all-nonconstant witness:** `(a_1,...,a_5)=([0,1],[0,1],[0,1],[0,1],[0,1])`, so every `g_i=X_i` is non-constant.

Every present clause has positive first literal at index 1, so both witnesses satisfy the relation `phi_C`, not a one-clause proxy. Witness
(i) is retained as a fast coefficient-identity path, but its locality claims for `i=2,...,5` and Figure `decider-pcp` checks 4(a)/4(b) for
`i in {3,4,5}` are vacuous; it is never evidence for C3 block dependency or TB2 proof encoding. Witness (ii) owns that evidence.

This finite circuit contains three NOT gates even though Figure `pcpverifier` describes the padded circuit as containing AND and OR gates.
The fixture-local divergence is explicit: `s=6` counts all six gates, `m'=16` remains consistent, and no general source-faithfulness claim
is inferred from the NOT-gate fixture.

Tseitin uses all six NW19 equality gadgets, conjoins them along the stored formula tree, and adds `w6`. In variable order
`(X1,...,X5,O1,...,O5,W1,...,W6)`, the formula occurrence vector is

```text
(2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3).
```

The actual individual-degree vector of `F_arith` is the same vector: every used-input and target-wire leading coefficient in an AND/NOT
equality gadget is nonzero, so the displayed degrees add in the integral domain `F_q[X,O,W]`. With witness (i), the structural and actual
vector of `c_0=F_arith*product_i(g_i(X_i)-O_i)` is

```text
(3,0,0,0,2, 3,1,1,1,1, 6,4,4,4,4,3)
```

Its zero-basis certificate names the quotient relation
`c_0=sum_{j=1}^{16} c_j*zero(z_j)` with `r=0`. Exactly
`c_2,c_3,c_4,c_7,c_8,c_9,c_10` vanish because the corresponding `deg_j(c_0)<=1`; the other nine quotients, including all six `W`
quotients, are nonzero, and `max_j inddeg(c_j)=6`, hence at most `d` on both rows and equal to `d` on TB0-small. Thus `inddeg(c_0)=6` and every PCP polynomial requires `d>=6`, but the four constant
`g_i` make most block-locality checks vacuous.

With witness (ii), every `g_i` has support dependency exactly `X_i`, and the structural and actual vector of `c_0` is

```text
(3,1,1,1,3, 3,1,1,1,1, 6,4,4,4,4,3)
```

again with `inddeg(c_0)=6`. C3's block-dependency evidence comes only from this all-nonconstant witness. Three NOT equality gadgets have at
most six terms and three AND gadgets at most seven. Witness (i) has
`expected_support(c_0)<=6^3*7^3*2=148,176`, a predicted peak single-product count 54,978, and `MonomialBudget=160,000`. Witness (ii) has
five binomial factors, so §1.3 gives `expected_support(c_0)<=6^3*7^3*(1+1)^5=2,370,816`; its predicted peak single-product count is
788,032, which fits the retained per-multiplication `MonomialBudget=2,500,000`. The r3 critic re-measured 788,032 normalized monomials over
`Z` (534,912 in characteristic two) for witness (ii); these are **MEASURED external** design figures pending TB0 confirmation. TB0 must
report its own normalized support, elapsed time, and peak memory. Neither pre-normalization estimate is reported as measured support.

| rung | `q` | `k` | `m` | `d` | `s` | `m'` | `seed_dim` | field-point scope | `c_0` / target time |
|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| TB0-small | 8 | 3 | 1 | 6 | 6 | 16 | n/a | 16 named coordinate lines and Boolean subcube | (i) estimate 148,176 / peak 54,978 / measured TBD; (ii) estimate 2,370,816 / peak 788,032 / measured TBD; report time/peak memory |
| TB0-sampled | `2^11` | 11 | 1 | 11 | 6 | 16 | n/a | >=10,000 seeded uniform `z` | both witness supports measured TBD; report time/peak memory |
| TB0.5 midpoint | n/a | n/a | n/a | n/a | n/a | n/a | n/a | exact DP | no polynomial / <1 s |
| TB1 low degree | 8 | 3 | 2 | 1 | n/a | n/a | 5 | all `8^5=32,768` seeds | no `c_0` / <10 s |
| TB2 typed AR | `2^11` | 11 | 1 | 11 | 6 | 16 | computed | branch-directed plus seeded | witness (ii) measured support TBD / report time/peak memory |
| TB3 front end | `2^11` | 11 | 1 | 11 | 6 | 16 | n/a | generated fixture | both witness supports measured TBD / report time/peak memory |
| TB4 Compress IR | n/a | n/a | n/a | n/a | n/a | n/a | n/a | no field sweep | no expansion / <1 s |

All PCP rows fix `gamma=1` and apply the predicate-result semantics cited in §2. No row has `d>=q`. TB0-small is explicitly not a
`def:pcpparams` tuple: its six-predicate report is `P_shape=PASS`, `P_growth=FAIL`, `P_formula_paper=FAIL`, `P_tail=FAIL`,
`P_divisibility=FAIL`, `P_degree=FAIL`; it does satisfy `m|q`, odd `k`, and `P_exponent_range` (`6<=7`). For
TB0-sampled/TB2/TB3 the six-predicate report is
`P_shape=PASS`, `P_growth=NOT_EVALUABLE`, `P_formula_paper=PASS`, `P_tail=PASS`, `P_divisibility=PASS`, `P_degree=PASS`.
Thus `q=2^11`, odd `k`, `d=k`, `m|q`, and `m'|q` hold, but unknown `a',b'` prevent a claim about `P_growth` or smallest-odd minimality for
the full formation rule.

For the checkable formula/divisibility conditions, `k=11` is the smallest odd `k` satisfying `P_divisibility` together with either formula
constant. With `deg_F=6`,
`(6+5*11)*16/2048=976/2048<1/2`, whereas `k=9` gives `816/512>1/2`. The source's literal condition also first passes at 11:
`(2+5*11)*16/2048=912/2048<1/2`, while at 9 it is `752/512>1/2`. The zero-test bound is
`(2+11)*16/2048=208/2048<1/2`. `P_formula_structural` is separately evaluated on both TB0 rows: it FAILS at `q=8` and PASSES at
`q=2^11`. The literal-2 `P_formula_paper` is retained as the paper's predicate and tagged `SOURCE_REPAIR(C8)`.

### 5.1 TB0 — field, encoding, zero basis, and PCP core

Concrete instances:

1.  Check field axioms, inverses, serialization, and distributivity exhaustively in `GF(2^3)` and on 10,000 seeded triples in `GF(2^11)`.
2.  For `m=1`, extend both non-constant tables `[0,1]` and `[1,0]`; for `m=2`, extend `[0,1,1,0]`. Verify every Boolean value and compare
    symbolic evaluation with `a dot ind_m(x)` on all points of `GF(8)^m`, then on seeded `GF(2^11)` points.
3.  Over `GF(8)`, decompose `f=x^3-x^2+x*y^2-x*y`; replay every rewrite and check the formal coefficient identity. The retained rewrite
    trace is justified because mutation A below directly exercises it.
4.  Exhaust the `2^10` circuit inputs (128 present/896 absent), all `2^16` Boolean `(x,o,w)` assignments for circuit/Tseitin/output-literal
    equivalence and arithmetization agreement, and all `2^10` witnesses for `phi_C`. These are named finite domains; there is no claim of
    exhausting `F_8^16` or `F_2048^16`.
5.  Fix the declared primitive element `rho` and
    `b_rho=(X=(0,0,0,0,0),O=(1,1,1,1,1),W=(rho,0,0,0,0,rho))`; direct substitution gives
    `F_arith(b_rho)=rho^4*(1+rho) != 0`. Build the fast witness-(i) proof `Pi_deg=(g_1,...,g_5,c_0,...,c_16)` with
    `MonomialBudget=160,000`. Over `GF(8)`, exhaust the 16 named coordinate lines
    `S_j={z:z_j in GF(8), z_l=(b_rho)_l for l!=j}` and the Boolean subcube. Over `GF(2^11)`, run `pcpverifier` at at least 10,000 seeded
    uniform `z` plus explicit separators on analogous lines. Assert acceptance, `r=0`, the formal quotient relation
    `c_0=sum_j c_j*zero(z_j)`, the witness-(i) degree vector, structural equality on every coordinate,
    `max_j inddeg(c_j)=6<=d` (with equality on TB0-small), and exactly the seven named zero/nine named nonzero quotients. Do not credit its empty dependencies for
    `g_2,...,g_5` as block-locality evidence.
6.  Build witness-(ii) `([0,1],[0,1],[0,1],[0,1],[0,1])` proof `Pi_nd` with `MonomialBudget=2,500,000`. Assert every `g_i` is non-constant and
    `Dependencies(g_i)={X_i}` exactly, with no other block; this is the sole C3 block-dependency evidence. Check its displayed `c_0`
    degree vector, `r=0`, the formal coefficient identity, structural bounds versus actual support, and every quotient's
    `inddeg(c_j)<=6<=d`. Run the same named GF(8) and sampled GF(2^11) completeness checks needed by TB2. Report normalized monomials,
    elapsed time, and peak memory, explicitly comparing the result with the critic's re-measured 788,032-over-`Z` / 534,912-in-char-2
    figures rather than treating those figures as locally confirmed.
7.  Make C8 a permanent test: the fixture must report the displayed `F_arith` vector, and `docs/findings-F1-check.jl`'s two-gate circuit
    must report `(2,2,2,4,3)` for `(x1,x2,x3,w1,w2)`, in particular `deg_w1=4`. In both, the occurrence vector bounds support degree
    coordinatewise and equality holds on the named variables.

Print field parameters, all six policy predicates plus the separately labeled `P_formula_structural`, measured monomial/dependency tables
for both witnesses, remainder, both PCP equations, slice/sample coverage, elapsed time, peak memory, and the trace. Every mutation has one
owner and checker: A, `e-2 -> e-1`, is owned by item 3's GF(8) coefficient-identity replay; B, remove `g_2-o_2`, is owned by witness (ii)'s
formula test at `b_rho[O2 <- rho]`. Here all five `g_i=X_i`, the honest factor product is `rho`, and deleting `g_2-o_2` changes it to 1,
while `F_arith=rho^4*(1+rho)!=0`. Thus honest `beta_0=rho^5*(1+rho)` and mutated `beta_0=rho^4*(1+rho)`; numerically these are respectively
2 and 1 in `GF(8)`, and 96 and 48 in `GF(2^11)`, while the verifier RHS is the honest value. C, omit output literal `w6`, is owned by
the exhaustive circuit/Tseitin truth table; D, corrupt field reduction, is owned by
the GF(8) field-axiom sweep; E, change `w1` fan-out accounting from 2 to 1, is owned by the occurrence/support degree comparison; F, replace
witness (ii)'s `a_3=[0,1]` by `[0,0]`, is owned by its all-nonconstant/exact-dependency checker. No mutation is credited merely because an
unrelated test fails.

Confidence is medium. Measure normalized support and peak allocation first; an `ExpansionRefused` result is an honest TB0 residue, not a
license to raise the budget silently.

### 5.2 TB0.5 — midpoint diagnostic (C6/N1)

This rung is a thin wrapper around the existing `toys/midpoint/` implementation, tests, three mutations, and Lamport proof; it is neither a
port nor a replacement. On `Z/17Z`, with `f(x)=x+1 mod 17`, it invokes that implementation for every `0<=n<=8` and false pair `(x,y)` and
checks the exact-rational recurrence

```text
p[0,x,y] = indicator(y=f(x))
p[n,x,y] = max_z (p[n-1,x,z]+p[n-1,z,y])/2.
```

Assert the optimum is `1-2^-n` for every false claim and 1 for every true claim. Print the recurrence table and the inferred repetition
count to reach a fixed constant gap. Reuse its averaging and omitted-branch mutations; the exact rational comparison must fail. This is
fully independent of PCP parameters and runs in roughly `9*17^3` scalar operations.

### 5.3 TB1 — classical low-degree test sampler

Use `q=8`, `m=2`, `d=1`; `m|q` and odd extension degree 3 satisfy the paper's field policy. Enumerate all `q^(2m+1)=32,768` seeds. Compare
exact histograms of `(L_ALine,L_Point)` and `(L_DLine,L_Point)` with direct samplers from `lem:alnf`/`lem:dlnf`, including zero directions.
Assert levels 1, 2, 3 from the datatype and replay every marginal.

Use the honest polynomial `g=1+x_1+x_1*x_2`; construct every axis and diagonal restriction and assert `D^ld` accepts every applicable pair
and consistency case. The reference histogram is `chi`-free: it draws the axis `i` uniformly and constructs `line(u_0,e_i)` directly from
`lem:alnf`/`lem:dlnf`. Mutate `chi` at a bucket boundary only in the CL implementation and require mismatch against that independent
reference. Also submit `g=x_1^2` while claiming `d=1`; an axis-line format/consistency check must reject at a deterministically located
point. Print histogram support/counts, levels, line representatives, and the verifier trace.

Confidence is high; the first measurement is the cost of canonical projection for all 32,768 seeds.

### 5.4 TB2 — full typed answer-reduced decider

Use the `q=2^11` PCP row and a trivial 1-level original sampler. Form its three-role oracularization, the 18-type PCP sampler, and their
54-type product. Assert typed level 3, the register dimensions in `V^pcp`, and every question and answer parser. Construct the honest
strategy from the all-nonconstant `Pi_nd`; execute all five checks of Figure `decider-pcp` on a branch-covering deterministic suite plus 256
seeded questions conditioned on check-triggering type pairs. In particular, checks 4(a)/4(b) for `i in {3,4,5}` must use witness (ii), never
the degenerate `Pi_deg`. Report the unconditioned fraction of the `54^2=2916` ordered type pairs that triggers no check. Every honest check
must accept, and report construction/check time and peak memory.

Mutate `c0` by `+1` and target the formula test; mutate the separate `g_3` by `+1` while leaving its bundled copy unchanged and target the
proof-consistency check; truncate one line polynomial and target `D^ld`. Each must produce at least one named rejection. Print the
type-product construction, dimensions, branch coverage, and nested PCP/low-degree traces.

The padded `DLine_6` answer has `m'+6=22` univariates of degree at most `m'd=176`, only 3,894 field elements. The actual risks are that most
uniform type pairs may trigger no check and that an honest strategy could be rebuilt per question. Cache the strategy once and condition
seeded coverage on triggering guards; never remove branch-directed checks.

### 5.5 TB3 — quoted front end

Use the closed program `lambda n x y a b. true`, fuel `T=1`, and an explicit accepting one-transition trace. The intentionally small honest
front end emits a decoupled relation extensionally equal to TB0's 128-clause relation and compiles it to TB0's six-gate circuit. This is not
claimed to meet the asymptotic construction of `prop:explicit-padded-succinct-deciders`.

Exhaustively compare program result, bounded-trace acceptance, the small 3SAT relation, the 128/896 decoupled relation table, and all 1,024
witnesses. Feed the generated—not hard-coded—circuit and both retained witnesses into TB0's Tseitin/PCP builder; feed only witness (ii) into
TB2's typed decider. Assert canonical quote-size propagation and print every intermediate object. Mutate the accepting transition to
rejecting without changing the formula; trace/formula equivalence must fail before PCP construction.

Expected `c_0` candidates remain at most 148,176 for witness (i) and 2,370,816 for witness (ii); their predicted per-multiplication peaks
are 54,978 and 788,032, respectively, so the 160,000 and 2,500,000 budgets fit. Both actual supports, elapsed times, and peak memory are
measured. Confidence is medium: measure whether the front-end circuit normalization preserves the exact six-gate fixture before proceeding.

### 5.6 TB4 — `Compress` skeleton and quoted fixed point

Construct `D_M_L=Fix(Psi_M_L)` for a two-state machine `M` and a symbolic `L`. Specialize its quoted body and pass it through
`Compress = Repeat o AnswerReduce o Introspect`. Assert the outer result is a 9-level `StubVerifier`, that `|D_M_L|` is computed from
canonical bytes, and that the trace has CHECKED program/specialization nodes, the CHECKED PCP subtree, and exactly named CITED leaves for
introspection, quantum answer reduction, repetition, and compression.

Print the quoted term, size, specialization substitutions, contract bounds, and certificate-grade summary. Mutate composition order, pass a
5-level result directly to `Repeat`, and require the computed chain to differ from `5 -> 7 -> 9`; separately relabel a CITED leaf as CHECKED
without a replay and require certificate verification to fail. The old closure/quote dispatch check is deleted because it tested only host
dispatch, not semantics. No theorem stub is executed.

**DD-14 — Optimize rungs for falsifiability.** Prefer exhaustive tiny fields, branch-directed questions, and exact rationals; rationale:
every green result has a demonstrated red neighbor; rejected: only large random demos.

## 6. Package layout and test discipline

The future Julia module is `MIPStarLambda`. Brief 01 creates no Julia files; the intended layout is:

```text
Project.toml
src/MIPStarLambda.jl
src/ir/{programs,circuits}.jl
src/fields/gf2k.jl
src/polynomials/{sparse,zero_basis}.jl
src/samplers/{cl,typed}.jl
src/verifiers/{pcp,answer_reduce}.jl
src/{combinators,certificates,traceprint}.jl
test/runtests.jl
test/{tb0_core,tb05_midpoint,tb1_ld_sampler}.jl
test/{tb2_answer_reduce,tb3_frontend,tb4_compress_ir}.jl
test/instances/
test/mutations/run.jl
test/mutations/*.jl
```

There are zero non-stdlib dependencies. `Test` and `Random` suffice; finite fields and sparse formal polynomials are small enough to
implement directly. A dependency may be proposed later only with a benchmark showing it decisively moves TB2 below the time limit without
obscuring certificates.

For each rung: write the green specification and mutation first, run it red for the missing constructor, implement the minimum IR, run
green, then run the mutation and require nonzero exit. Mutation scripts copy the repository fixture to a temporary directory, apply one
named textual or semantic change there, run only the targeted test, and fail if the mutated run exits zero. They never edit the working
tree.

Checkers return `CheckResult{Pass}` or `CheckResult{Fail}` with rule, location, expected, and actual. Tests use `@test`;
library checkers contain no bare `@assert`, so checks remain active regardless of compilation settings. Random tests use printed seeds;
exhaustive tests print cardinalities.

**DD-15 — No algebra dependency initially.** Implement only the required characteristic-two and tiny-prime operations; rationale:
certificate behavior is part of the experiment; rejected: committing to a general CAS before TB2 is measured.

## 7. Risks, failure modes, and open questions

1.  **Monomial blow-up.** Tseitin arithmetization followed by five low-degree factors can exceed memory long before paper-sized parameters.
    The budgeted constructor makes this an explicit negative result. If witness (i) approaches its 160,000-candidate budget, witness (ii)
    approaches its 2,500,000-candidate budget, or TB3 exceeds either applicable budget, measure factored-polynomial DAGs while retaining a
    separate coefficient-identity checker on reductions.
2.  **Field policy.** The paper uses admissible `q=2^k` with odd `k` (`gt-03-prelim.tex:L662-L667`), the low-degree sampler assumes `m|q`
    (`gt-07-ldt.tex:L31-L37`), and PCP parameters require `m'|q` (`gt-10-answer-reduction.tex:L1406-L1416`). The `q=2^11` rows retain those
    checkable facts; their constant-dependent results are exactly the six-predicate reports in §5 under the semantics cited in §2, with
    only sampled-row `P_growth` unresolved. `m'|q` is operational: copy 6 applies `chi` with `m'` buckets of equal size
    (`gt-10-answer-reduction.tex:L1944-L1946`). TB0-small uses `q=8,d=6<q` only for named subcube exhaustions and prints every failed
    predicate.
3.  **No vacuous exhaustive-PCP claim.** Neither `F_8^16` nor `F_2048^16` is exhausted. Formal coefficient identities are exact; Boolean
    truth tables and named coordinate slices have explicitly printed domains; PCP acceptance over `q=2^11` is sampled and is completeness
    evidence only. No all-field acceptance experiment is promoted to soundness.
4.  **Canonical zero direction.** `def:line` permits `v=0`, while `def:cl-canonical` asks for a linearly independent kernel basis. The
    identity totalization is natural for a singleton but is a `SOURCE_REPAIR`, not a theorem from the text. Exact histograms must reveal
    whether this convention matches all downstream uses.
5.  **Ground-truth repairs.** Apply the two corrections recorded in `CLAUDE.md:L5-L6`: `formula(x,s)` becomes `formula(x,w)` in Tseitin,
    and the arithmetization domain uses the formula's actual variable count. Mark, without silent repair: `F_q^m` should be `F_q^{m'}` at
    `gt-10-answer-reduction.tex:L1709-L1715`; `alpha_i=g_i(z)` should read `g_i(x_i)` at L1725; `sigma` is omitted from Figure
    `decider-pcp`'s PCP call at L2058-L2062; `eq:V-pcp`'s six-dimensional coordinate sum conflicts with scalar `table:tpcp`; and the
    individual-degree-2 claim conflicts with C8. Accordingly, `P_formula_paper` retains the literal `2` as a `SOURCE_REPAIR(C8)` source
    predicate, while `P_formula_structural` is an extra obligation and not a `def:pcpparams` consequence. NW19's missing output literal is
    repaired by construction and marked F2.
6.  **Oracularization is not optional.** Figure `decider-pcp` step 5 evaluates `L^alice,L^bob` on an oracle seed before invoking the PCP
    verifier (`gt-10-answer-reduction.tex:L2058-L2063`). A trivial product suffices for TB2 plumbing, but cannot support the theorem's
    consistency claim.
7.  **Degree-bound ambiguity.** The source sometimes says “individual degree `d`” where “at most `d`” is intended. The IR always stores
    inequalities. It certifies the stronger own-variable quotient bound `d-2`, but does not infer a smaller uniform bound for every other
    variable.
8.  **Homoiconicity's real gain.** Quotation and specialization remove an external Gödel-number/source-reconstruction layer: fixed points,
    description size, and pipeline traces share one syntax. They also make circuit and PCP transformations inspectable pure functions. They
    do not shorten the zero-basis algebra, either Schwartz--Zippel estimate, low-degree enforcement, or operator-algebraic consistency
    argument. Those estimates remain exactly where the paper places them.
9.  **Path from TB2 to complete answer reduction.** TB3's always-accept trace remains a weak Cook--Levin slice, but front-end growth is not
    the only next step. Completion requires, in order: a nontrivial quoted decider front end; executable oracularization plumbing; all guarded
    Figure `decider-pcp` branches; the cited `detype` wrapper with its `+2`/`16^54` accounting; and then the still-CITED quantum lifting from
    low-degree enforcement and consistency to `thm:ar`. Snapshot gate/monomial growth at each executable step and stop on the budget; do not
    call the result complete while the quantum leaves remain CITED.
10. **Strict probability thresholds.** C5 uses acceptance `>1/2`, as does the cited theorem. Replacing it with `>=1/2` invalidates the
    contradiction and is a required future mutation.

**DD-16 — Record repairs and relaxations in-band.** Put source repairs and parameter exceptions in certificate nodes; rationale: a
successful run must not hide distance from the paper; rejected: footnotes only in test code.

## 8. Assessment of the structural hypothesis (C7) — preliminary

The paper actually uses concatenation, direct sums of CL functions, products of samplers via direct sums, and typed families indexed by a
type graph. The level laws are additive for conditional concatenation and maximum for direct sum; typing adds an external graph choice and
detyping later costs two levels (`gt-04-cl.tex:L282-L327`; `gt-06-types.tex:L57-L93`, `L444-L474`). The six PCP copies and the oracularized
sampler use precisely those operations, so the IR makes their closure bookkeeping local rather than a global sampler proof.

Within the PCP, affine line restriction is a linear map after earlier values choose a coordinate/direction, the random-point identity test
is a shared uniform seed pushed through a pair of CL maps, and product is direct sum. These operations are visibly CL-preserving in
`CLStep`; generic PCPP queries are not thereby shown representable. This supports testing C7 as a structural hypothesis, but proves no
characterization and says nothing new about quantum rigidity.

## 9. Sampler descriptions as the transformation API

Sections 1--8 use concrete CL values where that made the first tracer bullets small. The complete pipeline cannot use a host closure or inspect a particular CL representation: every later transformation receives code.  This section therefore makes the machine interface of `def:sampler` the only
boundary between rungs (`gt-04-cl.tex:L572-L601 (def:sampler)`).

### 9.1 The description sorts

`SamplerDescription` is canonical quoted program data with the following public surface and no public `left`, `right`, branch-table, or distribution field:

```text
SamplerDescription := {
  code             :: Quoted{SamplerMachine},
  field_size       :: QuotedLaw{Nat},       -- q(n)
  level            :: Nat,                  -- ell
  typing           :: Untyped | Typed(TypeSet,TypeGraph),
  query_time       :: UpperBoundLaw,
  description_size :: Nat,
  dependency_set   :: Set{DescriptionId}
}

SamplerQuery ::= Dimension(n)
               | Marginal(n,w,j,z[,type])
               | Linear(n,w,j,u,y[,type])
               | Factor(n,w,j,u[,type])
```

The four variants are exactly the dimension, marginal, conditional-linear-map, and factor-space calls of the six-input sampler machine.  The optional type is the seventh logical input of a typed sampler; it does not add a fifth operation (`gt-06-types.tex:L95-L140 (def:typed-sampler)`).  `Factor`
returns the length-`dimension(n)` indicator of a register subspace.  `Marginal` and `Linear` return canonical vectors over `F_{q(n)}`.  The header functions `field_size` and `level` are metadata required to parse those vectors, not alternative access to the CL map.

All code paths halt.  A malformed mode, player, stage, vector, type, or prefix returns `QueryError` with no mathematical promise.  Certificates quantify only over legal calls: `w in {alice,bob}`, `1<=j<=ell`, correctly sized vectors, and prefixes in the range of the preceding marginal. This
preserves the source contract without pretending that arbitrary bit strings denote valid field data.

There is deliberately no `sample` operation.  It is derived by choosing uniform `z in F_q^s` and asking for the last marginal on both sides:

```text
sample_questions(S,n,z) =
  (query(S,Marginal(n,alice,S.level,z)),
   query(S,Marginal(n,bob,  S.level,z)))
```

For a typed description, an oriented edge of the stored graph distribution is chosen first and supplied to the two marginal calls.  These are precisely `def:sampler-sample` and its typed analogue (`gt-04-cl.tex:L614-L626`; `gt-06-types.tex:L143-L151`).

`DeciderDescription` is similarly intensional:

```text
DeciderDescription := {
  code             :: Quoted{TotalPredicate},
  typing           :: Untyped | Typed(TypeSet),
  time_bound       :: UpperBoundLaw,
  question_length  :: UpperBoundLaw,
  answer_length    :: UpperBoundLaw,
  description_size :: Nat,
  dependency_set   :: Set{DescriptionId}
}
```

Its untyped program accepts `(n,x,y,a,b)` and its typed program accepts `(n,tA,x,tB,y,a,b)`, always halting with one bit as required by `def:decider` and `def:typed-decider` (`gt-05-games-normalform.tex:L612-L622`; `gt-06-types.tex:L185-L195`).  The quoted TIME and length laws are data used by
guards; a theorem about their asymptotics is a separate certificate leaf.

### 9.2 Checked laws, sizes, and gap maps

`QuotedLaw{Nat}` is a closed term in the program language, not an extension of `BoundExpr`.  It can contain the variables named in its signature and exact arithmetic, `max`, tuple length, and calls to child laws. Thus §3's rule against invented exponents remains intact.  Universal polynomials
whose coefficients are not in the source remain `Opaque`; exact construction laws remain executable.

Every transformation emits a `LawCert` containing the expected law AST, the actual law AST, and evaluations on the tracer indices.  AST equality and evaluations are CHECKED.  A metered interpreter also counts wrapper operations and child calls on each test query.  A cited big-O assertion is CITED
even when the generated formula and finite measurements agree with it.

Description size is never an asymptotic guess:

```text
description_size(X) = length(canonical_bytes(X.code))
```

The checker reserializes the term and recomputes that integer. A compact loop in a repetition description is not charged as `k` copies of its code, while a returned question is charged its full materialized length.  Dependency sets are computed by a syntax walk over quoted child identifiers and
replayed against the bytes.

Soundness bookkeeping uses canonical quoted relations rather than floating-point numbers:

```text
GapMap ::= DetypeGap(types, epsilon -> 16^types * epsilon)
         | AnchorGap(epsilon -> 4 * 16^2 * epsilon)
         | IntroGap(delta_intro(epsilon,n))
         | AnswerReduceGap(delta_ar(epsilon,n))
         | RepeatGap(epsilon,p,n, strict_threshold)
         | CompressGap(1/2 -> 1/2, EntanglementLowerBound)
```

The formula AST, variable binding, direction of implication, and strict versus weak inequality are CHECKED.  The semantic implication is CITED from the named theorem. This is how gap maps are carried symbolically without being mislabeled as local soundness proofs.

### 9.3 Adapter from lazy `CLStep`

`describe_cl(LA,LB,q)` compiles the existing lazy datatype to a universal sampler interpreter plus serializable CL payload.  `Dimension` returns `seed_dim`.  A `Marginal` walks exactly the first `j` nodes, evaluating only the selected branch. `Factor` walks the prefix to stage `j` and returns that
node's coordinate indicator. `Linear` walks the same prefix and multiplies the stage matrix by the projection of `y`.  None enumerates `image(A)`.

An arbitrary Julia `Function` is not serializable.  The description adapter accepts only branches built from a named pure `QuotedBranch` constructor with canonical captured data.  Existing in-memory `CLStep` values remain usable inside TB1/TB2, but an opaque host branch returns `NotDescribable`;
transformations never fall back to serializing a closure.      This is the remaining adapter work after the lazy-branch repair described by Brief 21.

The adapter certificate checks, on a finite fixture, every legal `j`, every seed, every reachable prefix, and every factor basis vector against `marginal_k`, `apply`, and the stored matrix.  Generally, level is CONSTRUCTED by nesting and the query compiler is proved by structural recursion in code.
 The source marginal decomposition is `lem:cl-kth`; the machine interface exposing it is `def:sampler` (`gt-04-cl.tex:L572-L595`).

### 9.4 Query-only closure lemmas

The following named implementation lemmas—`DL9-downsize`, `DL9-direct-sum`, `DL9-product`, `DL9-detype`, `DL9-anchor`, and `DL9-repeat`—are each owned by a constructor and a red mutation.  “Definable” means that the wrapper embeds the child description and may invoke only its four query variants and header laws; it may not inspect child CL IR.

| operation | field | level | dimension at `n` | metered query law |
|---|---:|---:|---:|---|
| `downsize(S)` | `2` | `ell` | `s(n) log2 q(n)` | `O(C_S(n) log q(n))` |
| `direct_sum(S_1,...,S_r)` | common `q` | `max_i ell_i` | `sum_i s_i(n)` | `O(r+sum_i C_i(n))` |
| `product(S_1,S_2)` | common `q` | `max(ell_1,ell_2)` | `s_1(n)+s_2(n)` | `O(C_1(n)+C_2(n))` |
| `detype(T,G)` | `2` | `ell+2` | `s(n)+4*TypeCount` | `poly(TypeCount,C_S(n))` |
| `anchor(S)` | `2` | `ell+2` | `s(n)+8` | `poly(C_S(n))` |
| `repeat(S,lambda,tau)` | `2` | `ell+2` | `k(n)(s(n)+8)` | `O(k(n) C_S(n))` |

For `downsize`, `Dimension` multiplies by `log2 q`; marginal and linear calls reinterpret binary field encodings through the fixed basis; and `Factor` replaces each child indicator bit by `log2 q` copies.  The output CL functions are the conjugates `downsize o L o downsize^-1`. Level, field,
dimension, distribution, and runtime are the laws in `def:downsize_sampler` and `lem:downsize_sampler` (`gt-04-cl.tex:L628-L680`).

For `direct_sum`, every vector and prefix is split into its registered blocks, the same query is sent to each child, and results or factor indicators are concatenated. Shorter levels are padded by empty zero stages before the calls.  The maximum level law is `lem:cl-func-prod`, and independent seed
blocks give the product distribution (`gt-04-cl.tex:L315-L383`).    `product` additionally forms the Cartesian type set and graph when its inputs are typed; for untyped descriptions it is the same map constructor as `direct_sum`.

Mismatched fields are rejected.  In particular, a large-field PCP sampler must be explicitly downsized before it is combined with a normal-form `F_2` sampler. The answer-reduction prose directly sums those spaces without spelling out this conversion (`gt-10-answer-reduction.tex:L1948-L1965`); the
executable pipeline inserts `downsize(PCPSampler)` and records `SOURCE_REPAIR(AR-field-align)`.  The questions retain the same canonical binary representation, and `lem:downsize-cl-dist` supplies the cited distribution identity (`gt-04-cl.tex:L533-L550`).

### 9.5 Executable detyping

`detype_sampler` first builds the two-level graph maps `L_G^alice,L_G^bob` over

```text
V_G = V_vertex,A (+) V_edge,A (+) V_vertex,B (+) V_edge,B,
dim(V_G)=4|Type|.
```

The first stage returns the player's two raw graph registers; only when they equal `(e_t,neigh_G(t))` do they encode a type.  The second stage returns the opposite edge bit selected by `t`, or zero when the first stage is not a vertex encoding.  This is Figure `graph-distribution` (`gt-06-types.tex:L234-L339`). It then conditionally concatenates
the graph map with the child map for the revealed type, or with the zero map when the selected opposite edge register is zero:

```text
R^w(z_G,z_V) = L_G^w(z_G) +
  if edge_view(L_G^w(z_G)) then L^w_type(z_V) else 0.
```

Each of the four output queries is implemented by splitting the graph and child coordinates.  Stages `1,2` answer from the graph sampler.  Later stages derive the type from the preceding graph marginal and forward stage `j-2` to the typed child, with its prefix and vector restricted to `V`.  This
is conditional concatenation, so the level is `ell+2` and the dimension is `4|Type|+s(n)` by construction (`gt-06-types.tex:L371-L404`; `gt-04-cl.tex:L282-L313`).

`detype_decider(D,G)` parses `x=(x_G,x_body)` and `y=(y_G,y_body)`.  If parsing fails, or the graph views do not encode an edge in `G`, it accepts.  On a valid edge `{tA,tB}`, it returns `D(n,tA,x_body,tB,y_body,a,b)`.  This accept-on-invalid behavior is literal, including its adversarial tests
(`gt-06-types.tex:L409-L427`).

The construction, `+2`, `4|Type|`, parser, exact bytes, and child-call costs are CONSTRUCTED or CHECKED.  Value-one preservation, the implication with `16^|Type| epsilon`, the Ent map, and the theorem-level polynomial time bounds remain CITED from `lem:detyping-verifiers`
(`gt-06-types.tex:L444-L475`).

### 9.6 Transformation contracts and compatibility surface

The authoritative signatures after TB4 are:

```julia
downsize(s::SamplerDescription) :: Checked{SamplerDescription,CompositeCert}
direct_sum(ss::SamplerDescription...) :: Checked{SamplerDescription,CompositeCert}
product(s1::SamplerDescription,s2::SamplerDescription) :: Checked{SamplerDescription,CompositeCert}
detype(s::TypedSamplerDescription,d::TypedDeciderDescription) :: Checked{VerifierDescription,CompositeCert}
anchor(v::VerifierDescription) :: Checked{VerifierDescription,CompositeCert}
repeat(v::VerifierDescription,lambda,tau) :: Checked{VerifierDescription,CompositeCert}
introspect(v::VerifierDescription,lambda,ell; policy) :: Checked{VerifierDescription,CompositeCert}
compress(v::VerifierDescription,lambda; policy) :: Checked{VerifierDescription,CompositeCert}
```

Capitalized TB4 functions remain deprecated adapters that return a structured `ConstructionUnavailable` until their payload is a `VerifierDescription`; they may not return `StubVerifier` from the v2 surface.

Every result has an ASSUME/PROVE contract.  ASSUME nodes contain field alignment, well-formed graph, legal child laws, normal-form status, timeout bounds, and any theorem hypotheses. PROVE nodes separate construction facts from theorem facts:

| fact | required grade |
|---|---|
| canonical output code and exact byte length | CHECKED |
| query purity and child dependency set | CHECKED |
| field, level, dimension, parser, and tuple lengths | CONSTRUCTED/CHECKED |
| metered wrapper call count on named instances | CHECKED |
| formula AST for runtime and gap bookkeeping | CHECKED |
| asymptotic bound, completeness, soundness, or Ent implication | CITED |

The decider constructors carry equally explicit local laws:

| constructor | child calls after parsing | question/answer law |
|---|---:|---|
| `detype_decider(D,G)` | at most one `D` | questions add `4*TypeCount` graph bits; answers unchanged |
| `anchor_decider(D)` | at most one `D` through typed anchor and detype | questions add 8 bits; answer maximum is `max(A,1)` |
| `repeat_decider(D,k,B)` | zero on guard failure, otherwise exactly `k` | exactly `k` components, each at most `B=(lambda*n)^tau` bits |

The query-purity test uses an opaque recording sampler which exposes only the four operations. Each wrapper is compared with a concrete CL reference and its call log is checked.  A mutation that reaches for `child.left`, enumerates an image, changes a factor bit, or calls a fifth operation fails
before a probability experiment.

**DD-23 — Put descriptions at every transformation boundary.** Preserve `CLStep`
as an implementation and test carrier, but require canonical sampler/decider code between rungs; rationale: `Compress` consumes descriptions and hash independence is intensional; rejected: passing Julia closures through Repeat and Introspect.

**DD-24 — Make construction laws executable and theorem laws cited.** Check law
syntax, exact sizes, metered calls, and finite evaluations while retaining CITED semantic leaves; rationale: bookkeeping must be falsifiable without claiming a new soundness proof; rejected: assigning CHECKED to a copied big-O statement.

**DD-25 — Execute detyping once, reuse it everywhere.** Use the graph sampler,
conditional concatenation, and parser as ordinary constructors for AnswerReduce, Anchor, and Introspect; rationale: all three need the same `+2` operation; rejected: three theorem-named wrappers with no query implementation.

## 10. TB5 — executable anchoring and repetition

### 10.1 Anchoring transcription

`typed_anchor_sampler(S)` requires an untyped normal-form sampler over `F_2` and creates type set `{Game,Anchor}` with the complete graph including both self-loops. For each player and each of the four query modes, `Game` delegates to `S` and `Anchor` returns the zero map on the same ambient space.
     The typed sampler has the same dimension and level as `S` (`gt-11-parallel-repetition.tex:L89-L97`, `L139-L159`).

`typed_anchor_decider(D)` accepts a Game/Game pair exactly when `D` accepts.  If either type is Anchor, every Anchor-typed player must answer the canonical bit `0`; Game-typed answers are ignored on such a pair.  Malformed answers reject. Applying the executable detyper gives `(S^anch,D^anch)`
with field 2, level `ell+2`, and dimension `s(n)+8` (`gt-11-parallel-repetition.tex:L98-L103`, `L112-L136`).

The finite honest strategy maps an Anchor question to answer `0`, maps a Game question through the child's honest strategy, and implements the detyped graph view as in §9.5. Its acceptance is CHECKED.  The general PCC completeness statement and the Ent map

```text
Ent(V^anch_n,1-epsilon) >= Ent(V_n,1-4*16^2*epsilon)
```

remain CITED from `prop:anchoring` (`gt-11-parallel-repetition.tex:L112-L136`).

### 10.2 Repetition transcription

Let `c_prime` be the universal constant attached to the polynomial bound on `D^anch`, and store the exact source function

```text
k(n) = (lambda*n)^((1+c_prime)*tau).
```

The description is valid only when this expression denotes a positive integer. The source calls `k(n)` an integer while declaring only `c_prime>0`; production keeps the symbolic term and an ASSUMED integrality witness until a concrete universal constant is supplied.  Tests use the explicit integer toy substitution `c_prime=1`, report the universal-bound predicate `NOT_EVALUABLE`, and do not silently round the exponent (`gt-11-parallel-repetition.tex:L200-L215`, `L229-L258`).

`repeat_sampler` is the `k(n)`-fold direct sum of the already anchored sampler. Each query computes `s'=dimension(S^anch,n)`, splits the seed, prefix, and linear input into `k` blocks, makes the corresponding child query on every block, and concatenates the result.    It never unrolls `k` in
the description.  Consequently:

```text
field       = 2
level       = ell+2
dimension   = k(n)*(s(n)+8)
query time  = O(k(n)*TIME_S(n))
question bits <= k(n)*(s(n)+8)
```

The maximum-level law follows because direct sums do not increase level (`gt-11-parallel-repetition.tex:L268-L292`; `gt-04-cl.tex:L315-L327`).

`repeat_decider` first computes `B(n)=(lambda*n)^tau` without reading the supplied payloads.  It parses each of `x,y,a,b` as exactly `k(n)` canonically framed components while streaming no more than the declared total bound.  It rejects if parsing fails or if any component has more than `B(n)`
bits.  Otherwise it runs `D^anch` on each aligned quadruple and returns their logical AND.  This ordering is part of the time certificate: an attacker cannot force an unbounded scan with a malformed length prefix (`gt-11-parallel-repetition.tex:L216-L220`).

The checked metadata are

```text
question_length(n), answer_length(n) <= k(n)*B(n)
TIME_Drep(n) = O(k(n)*max(TIME_D(n),B(n))).
```

The general runtime, PCC completeness under `TIME_D(n)<=B(n)`, and the strict soundness relation

```text
p > (4/epsilon) * exp(-c*epsilon^17*k(n)/(lambda*n)^(tau*c_prime))
implies Ent(Vrep_n,p) >= Ent(V_n,1-epsilon)
```

are CITED from `thm:repetition`; strict `>` is retained in the AST (`gt-11-parallel-repetition.tex:L229-L258`).

### 10.3 TB5 instance, measurements, and mutations

The child fixture `V_copy` has `F_2`, `ell=1`, `s(n)=1`, both CL maps equal to the identity, and decider `a=x and b=y`.  Its classical value-one strategy returns its one-bit question.  TB5 uses `lambda=1`, `tau=1`, `c_prime=1`, and index `n=9`:

```text
B=9; k=9^2=81
anchor: level 3, dimension 1+8=9
repeat: level 3, dimension 81*9=729
question bound: 81*9=729 bits; answer bound: 81*9 bits
```

The test constructs both descriptions, replays all four sampler query modes on one branch-directed seed per stage, then samples 128 seeded repeated question pairs. It builds the classical anchored/repeated answers and requires all 128 decisions to accept.  It separately submits a 10-bit component
and requires rejection before a child call.  Construction target is `<2 s`, the 128 transcript target is `<5 s`, and peak allocation target is `<256 MiB`; measured values replace targets in the TB5 report.

Sampler independence is an intensional test.  Two verifiers with byte-distinct deciders but the same sampler, `lambda`, and `tau` must have identical canonical `S^rep` hashes.  The output sampler dependency set must be exactly `{hash(S),lambda,tau,c_prime}`, never `hash(D)`; this is the
construction statement at `gt-11-parallel-repetition.tex:L257-L258`.

TB5 owns these mutations:

1. `M5-anchor-zero`: map Game to zero; an identity-question transcript rejects.
2. `M5-anchor-answer`: accept Anchor answer `1`; the negative transcript survives
   only in the mutant and kills it.
3. `M5-detype-level`: report `ell+1` or omit four type registers; law replay fails.
4. `M5-shared-seed`: reuse block 1 in all repetitions; blockwise sample replay fails.
5. `M5-or`: combine repeated decisions by OR; one corrupted component kills it.
6. `M5-no-guard`: read or accept an oversized component; the pre-call log kills it.
7. `M5-decider-hash`: include `D` in sampler code; the two-decider hash test fails.

**DD-26 — Stream the length guard before child evaluation.** Parse bounded frames,
reject overlong components, and only then call `D^anch`; rationale: this realizes the stated decider time bound on hostile strings; rejected: generic tuple parsing whose cost depends on the claimed payload length.

## 11. TB6 — executable Pauli test and introspection

### 11.1 Parameters, Pauli types, and graph

For `R=N^lambda`, canonical Pauli parameters are

```text
c = the smallest even integer >= (b+a)/b
q = 2^(c*ceil(log log R)+1)
m = largest power of two <= c*ceil(log R)+1
d = 1
M = 2^m
Q = M*log2(q).
```

The unknown `a,b` are the universal constants of `thm:pauli`; they remain symbols. The parameter constructor can still build and compare this AST.  A production numeric instance is `NOT_EVALUABLE` until constants are supplied.  Admissibility, `m|q`, and `Q>=R` are separately reported predicates
(`gt-07-ldt.tex:L1492-L1569 (def:introparams, lem:delta-bound)`).

The Pauli type set is

```text
TypePauli = ({Point,ALine,DLine,Pauli,Pair} x {X,Z})
            union {Constraint_1,...,Constraint_6}
            union {Variable_1,...,Variable_9}
            union {Pair}.
```

It has 26 types.  `G^pauli` contains every self-loop, the six low-degree/Pauli chain edges, the 18 Magic-Square incidence edges, `PointX--Variable1`, `PointZ--Variable5`, and the two chains `PointW--PairW--Pair`. Thus the graph checker expects 30 non-loop plus 26 loop edges, or 86 oriented
pairs. This is a literal finite reconstruction of Figures `type-graph-ms` and `type-graph-pauli` (`gt-07-ldt.tex:L550-L610`, `L1012-L1068`).

### 11.2 Pauli sampler and classical predicate

Before downsizing, the ambient space is

```text
V^pauli = V_xpt (+) V_zpt (+) V_coord (+) V_dir (+) V_rxpt (+) V_rzpt
dim_q(V^pauli) = 3m+3.
```

For each `W in {X,Z}`, `PointW`, `ALineW`, and `DLineW` embed the existing level 1, 2, and 3 low-degree maps on `(u_W,s,v)` and zero the other basis and `r` registers.  Magic-Square, `Pair`, `PairX`, and `PairZ` types project `(u_x,u_z,r_x,r_z)` and have level 1.  `PauliX` and `PauliZ` are zero
maps.  All maps are padded to common level 3.  The four-query compiler exposes them as a typed description (`gt-07-ldt.tex:L1070-L1120`).

`pauli_decider(q,m,d)` parses the exact table in Figure `decider_pauli` and applies all applicable guards in both player orders:

1. equal types require equal answers;
2. Point/ALine and Point/DLine call `ld_decider(q,m,d,1)`;
3. Point/Pauli requires `g_h(point)=point_answer`;
4. compute `gamma_pauli=tr((ind_m(u_x)r_x)*(ind_m(u_z)r_z))`;
5. PairW/Pair requires the selected pair bit when `gamma_pauli=0`;
6. PointW/PairW requires `tr(answer*r_W)` when `gamma_pauli=0`;
7. Constraint/Variable requires the five even-parity or last odd-parity
   Magic-Square equation and the shared variable when `gamma_pauli=1`;
8. PointW/Variable requires the special `(j,W)=(1,X)` or `(5,Z)` trace equality
   when `gamma_pauli=1`.

If no guard applies it accepts; malformed applicable data rejects.  These are ordinary field, polynomial-evaluation, parity, equality, and low-degree predicate calls, so the decider is executable.  The question/answer formats and guards are at `gt-07-ldt.tex:L1126-L1227 (fig:decider_pauli)`.
Quantum rigidity is not part of this predicate and remains CITED from `thm:pauli` (`gt-07-ldt.tex:L1426-L1447`).

### 11.3 Introspection sampler

For an input level `ell`, define

```text
TypeIntro = TypePauli union
  ({Introspect,Sample,Read,Hide_1,...,Hide_ell} x {alice,bob}).
```

The checker expects `|TypeIntro|=32+2ell`.  `G^intro` retains `G^pauli`, adds a self-loop at every new type, and adds exactly these non-loop edges for each role:

```text
Sample--Introspect--Read
PauliZ--Sample
PauliX--Hide_1--Hide_2--...--Hide_ell--Read
```

plus `IntrospectAlice--IntrospectBob`. Hence it has `2ell+39` non-loops, `32+2ell` loops, and `6ell+110` oriented pairs.  The formulas are checked against the explicit finite graph of `fig:type-graph-intro` (`gt-08-introspection.tex:L217-L315`).

`tilde S^intro` uses the Pauli maps for Pauli types and the zero map for every new type.  It is a typed level-3 sampler over `F_q` with dimension `3m+3`.  Apply the query-only downsize constructor, then executable detyping:

```text
hat S^intro : typed, field 2, level 3,
              dimension (3m+3)*log2(q)
S^intro     : untyped, field 2, level 5,
              dimension (3m+3)*log2(q) + 4*(32+2ell).
```

The level 5 and exact dimension are CONSTRUCTED.  The sampler description depends only on `(lambda,ell)` and the universal Pauli-parameter symbols, never on the input verifier (`gt-08-introspection.tex:L317-L360`; `L819-L840`).  Its metered operation DAG contains only loops bounded by `m`, `log q`, `ell`, and the output dimension; the classifier CHECKS that canonical substitution makes this polynomial in `log R=lambda*n` and `ell`, and finite calls are timed.  The paper-TM `poly(n,lambda,ell)` and description-generation claims remain CITED from `lem:intro-sampler-complexity` (`gt-08-introspection.tex:L347-L392`).

### 11.4 Introspection decider and its child queries

`typed_intro_decider(V,lambda,ell)` computes `N=2^n`, `R=N^lambda`, and the Pauli parameters.  Every call to the input sampler or decider is fuelled by `R`; timeout rejects.  It first asks only `Dimension(N)`, rejects if `s(N)>R`, and applies the literal answer-length guard `max(|a_hat|)>=3Q ->
reject` (`gt-08-introspection.tex:L417-L426`). The explanatory prose calls `3Q` a maximum, so the boundary is suspicious; v2 keeps the literal `>=`, tags `SOURCE_REPAIR(intro-boundary-conflict)`, and chooses toy answers strictly shorter than `3Q` rather than changing the theorem input.

Non-Pauli answers have these exact schemas:

| type | answer |
|---|---|
| `(Introspect,role)` | `(y,a)` |
| `(Sample,role)` | `(z,a)` |
| `(Read,role)` | `(y,y_perp,a)` |
| `(Hide_k,role)` | `(y,y_perp,x)` |

All `y,z,y_perp,x` are checked to lie in the first `s(N)` coordinates of the `Q`-bit Pauli register (`gt-08-introspection.tex:L401-L416`, `L501-L538`).

The predicate applies all applicable tests:

1. two Pauli types call `pauli_decider`;
2. PauliZ/Sample compares the Pauli answer projected to `V` with `z`;
3. Introspect/Sample asks `Marginal(N,role,ell,z)` and compares it with `y`, then
   compares original answers;
4. Introspect/Read compares `y` and `a`;
5. Hide_ell/Read compares `y_<ell` and all of `y_perp`;
6. Hide_k/Hide_(k+1) compares the shared prefix, dual prefix, and `x_>k+1`, then
   checks the dual image at stage `k+1`;
7. PauliX/Hide_1 checks the first dual image and the untouched suffix;
8. IntrospectAlice/IntrospectBob calls the original
   `D(N,y_A,y_B,a_A,a_B)`;
9. equal types require the entire answers to be equal.

If none applies, it accepts.  This ordering and the equal-type check are the classical predicate in Figure `intro-decider` (`gt-08-introspection.tex:L429-L498`).

To form `y_<k` and its register partition, the decider asks `Factor(N,role,1,0)`, then for each later stage asks `Marginal(N,role,j-1,y)` and `Factor(N,role,j,prefix)`.  To compute `(L_{j,prefix})^perp(x_j)`, it asks `Linear` once on every canonical basis vector of that factor, forms the matrix,
computes its kernel by canonical Gaussian elimination, takes the canonical complement, and applies the corresponding projection.  There is no access to the input CL object.  This query schedule is the construction at `gt-08-introspection.tex:L550-L579` and `L641-L684`.

After typed construction, the same executable detyper from §9.5 produces the untyped five-level decider.  Parser behavior, timeout placement, query log, exact description bytes, and synthetic predicate results are CHECKED. The general decider runtime/description bound is CITED from
`lem:intro-decider-complexity` (`gt-08-introspection.tex:L694-L776`).  The completeness, soundness, and Ent maps remain CITED from `thm:introspection` (`gt-08-introspection.tex:L784-L817`).

### 11.5 Exact tiny honest-strategy simulation

The honest strategy is quantum, not a pair of classical response functions.  It uses `Q+1` EPR pairs and the original PCC auxiliary strategy (`gt-08-introspection.tex:L1070-L1096`).  TB6b chooses a toy verifier whose value-one strategy is deterministic, so the auxiliary register contributes no
non-stabilizer measurement.  Everything else is simulated exactly by a binary stabilizer tableau on `2(Q+1)` physical qubits:

1. initialize each EPR pair with stabilizers `X_AX_B` and `Z_AZ_B`;
2. translate every requested coarse Pauli measurement into commuting binary
   symplectic rows;
3. solve the stabilizer linear system for forced outcomes and sample each free
   outcome with one seeded fair bit;
4. update the tableau, then derive low-degree, pair, and Magic-Square answer fields;
5. for adaptive Hide measurements, use each sampled prefix to obtain the next
   factor and linear map through the four-query API before adding its rows.

This is an exact classical sampling algorithm for this fixture, not a local hidden-variable strategy. It is valid when each simultaneously requested family is a commuting Pauli family.  For `Read`, the Z measurement of `L` commutes with the X measurement of `L_j^perp` because `ker(L_j^perp)^perp
subseteq ker(L_j)`; the source proves precisely this criterion in `lem:commute` (`gt-08-introspection.tex:L923-L953`).       Figure `intro-honest` specifies the measurement families and order (`gt-08-introspection.tex:L1002-L1050`, `L1106-L1172`).  The simulator rejects a nonzero symplectic
commutator instead of sampling an invalid joint distribution.

Passing transcripts show only finite completeness.  They do not execute an arbitrary quantum strategy, prove rigidity, estimate entangled value, or discharge `thm:introspection`.

### 11.6 TB6 instances and mutations

TB6a is the design audit: instantiate the finite type/edge formulas for `ell in {1,3,9}`, generate every parser schema and guard, and compare the emitted query plan with the source tables.  It performs no quantum claim and targets `<1 s`.

TB6b uses `n=2`, `N=4`, `lambda=1`, `ell=1`, an identity sampler of dimension 1, and deterministic answers.  The explicit toy Pauli tuple is `(q,m,d)=(2,1,1)`, so `M=2`, `Q=2`, `|TypeIntro|=34`, 116 oriented type pairs, and

```text
typed downsized sampler dimension = (3*1+3)*1 = 6
detyped sampler dimension = 6 + 4*34 = 142
physical stabilizer qubits = 2*(Q+1) = 6.
```

The policy report is: `R>=4 PASS`, admissible odd-extension field `PASS`, `m|q PASS`, `d=1 PASS`, actual capacity `Q>=s(N) PASS`, theorem capacity `Q>=R FAIL`, canonical `introparams(R)` equality `FAIL`, and input `lambda`-bounded description `FAIL` for the multi-byte toy quote.  Therefore no
theorem conclusion is invoked.

For every oriented edge, enumerate every nonzero-support stabilizer outcome with an exact dyadic probability, require total mass one, and require the decider to accept every outcome; this checks acceptance probability exactly one on the typed toy game.  Cover the detyped decision tree by every valid graph encoding plus its unconditional invalid-encoding branch, then run 256 seeded draws as a secondary distribution regression.  Also require every child query below its `R` timeout, sampler level 5, dimension 142, and stable bytes.  Targets are `<3 s` for construction, `<15 s` for transcripts, and `<512 MiB`; a dense state vector is forbidden.

TB6 owns these mutations:

1. `M6-pauli-edge`: remove `PointX--PauliX`; graph equality fails.
2. `M6-pauli-gamma`: flip the trace bit; a commutation/Magic-Square transcript fails.
3. `M6-sampler-nonzero`: give `Introspect` a content map; zero-map query replay fails.
4. `M6-N`: call the child at `n` instead of `2^n`; the recording query log fails.
5. `M6-factor-prefix`: use the earlier player's prefix in Hide `k+1`; a divergent
   adaptive branch fails.
6. `M6-perp`: transpose or skip one basis-vector `Linear` call; dual check fails.
7. `M6-game`: swap introspected Alice/Bob questions in the final call; asymmetric
   toy decider rejects.
8. `M6-boundary`: change the literal `>=3Q` guard; the boundary negative test fails.
9. `M6-noncommuting`: allow an anticommuting simultaneous family; the symplectic
   precheck fails before sampling.

**DD-27 — Simulate only the stabilizer slice of the honest strategy.** Execute EPR
Pauli transcript distributions exactly for the deterministic-child fixture and refuse noncommuting or non-stabilizer measurements; rationale: this tests the constructed predicate honestly; rejected: calling a hand-written accepting tuple a simulation of the quantum strategy.

## 12. TB7 — Compress and the halting fixed point end to end

### 12.1 Production composition and universal constants

The executable constructor is the exact order in Figure `compress`:

```text
V1 = introspect(V,lambda,9)
V2 = answer_reduce(V1,lambda,mu,gamma)
V3 = repeat(V2,lambda,tau)
return V3
```

(`gt-12-compression.tex:L75-L98 (fig:compress)`).  It carries, without choosing numerical values, the source equations

```text
mu = ceil(C_intro)
gamma = ceil(2*a1/(b1*b2))

epsilon1(n) = (1/(8*a1*(lambda*n)^a1))^(1/b1)
epsilon2(n) = (epsilon1/(8*a2*(lambda*n)^a2))^(1/b2)

tau = least integer with tau>=C_ar and
      (lambda*n)^tau >= (1/(c3*epsilon2(n)^17))*ln(8/epsilon2(n))
      for every n>=tau and integer lambda>=1.
```

The first two equations are `eq:mu-gamma`; the last is `eq:c_rep` (`gt-12-compression.tex:L263-L271`, `L289-L307`, `L347-L359`).  `a1,b1,a2,b2, C_intro,C_ar,c3,c3_prime` are symbol identifiers with their source constraints. They cannot be replaced by convenient literals in production. `k(n)` is
then `(lambda*n)^((1+c3_prime)*tau)`.

The canonical gap AST records `delta_intro`, `delta_ar`, and the strict Repeat threshold, then the substitutions of `epsilon1`, `epsilon2`, and `tau` which make the last threshold less than `1/2`.  Algebraic substitution and variable capture are CHECKED. Each inequality and the final Ent
implication are CITED from the three transformation theorems and `thm:compression`.

### 12.2 Full structural bookkeeping

Let the input have field 2, level 9, dimension `s_0(n)`, sampler time `S_0`, decider time `D_0`, and exact quote sizes.  The construction produces:

| stage | field | level | exact dimension law | description dependency |
|---|---:|---:|---|---|
| input `V` | 2 | 9 | `s_0(n)` | `S_0,D_0` |
| `V1=Intro(V,lambda,9)` | 2 | 5 | `(3m_I+3)log q_I+200` | sampler: `lambda`; decider: `V,lambda` |
| typed AR | 2 | 5 | `s_1+(2m'_A+6)log q_A` | `S_1,lambda,mu,gamma,sigma_1` |
| `V2=detype(typed AR)` | 2 | 7 | `s_1+(2m'_A+6)log q_A+216` | same sampler dependencies |
| anchored `V2` | 2 | 9 | `s_2+8` | sampler: `S_2`; decider: `D_2` |
| `V3=repeat` | 2 | 9 | `k(n)(s_2+8)` | sampler: `S_2,lambda,tau` |

Here `|TypeIntro|=50` at `ell=9`, `|TypeAR|=3*18=54`, and the PCP ambient large-field dimension is `2m'_A+6`; its explicit downsize accounts for the factor `log q_A`. Every arithmetic equality is a `LawCert`.  The level chain

```text
9 --Introspect--> 5 --AnswerReduce/detype--> max(5+2,5)=7
  --Anchor/detype--> 9 --direct-sum Repeat--> 9
```

is CONSTRUCTED and checked against the parameter table (`gt-12-compression.tex:L156-L187`, `L263-L285`, `L332-L359`).

At every row the trace also prints question length, answer schema maximum, sampler and decider call-count laws, exact canonical description sizes, and all parameter predicates.  No symbolic dimension may be coerced to a host `Int` before a budget check.

### 12.3 Sampler independence as code dependency

The sampler emitted by Introspect contains no input-verifier identifier.  To make AnswerReduce's dependence on `|D1|` itself independent of the input bytes, the universal introspection decider stores the embedded sampler and decider in two fixed `lambda`-byte component slots (or stores canonical trivial code when either bound fails) and pads its parameter slots canonically.  Therefore `sigma_1` is an exact function only of `lambda` and `ell=9`, while evaluation ignores padding.  This makes the source independence argument executable rather than inferring equality of lengths from a common polynomial upper bound
(`gt-08-introspection.tex:L757-L776`; `gt-12-compression.tex:L128-L147`).

Static dependency analysis must return

```text
dependencies(S_compress) = {lambda, universal_constant_ids}
```

and two byte-distinct input verifier pairs at the same `lambda` must yield identical sampler bytes and hashes. A second pair straddles the `|V|<=lambda` branch; both still use the same fixed-width sampler because the input appears only in the decider. This is finite adversarial evidence for
`lem:compress-independent-samplers` (`gt-12-compression.tex:L108-L118`); the AST dependency theorem is CHECKED by construction.

### 12.4 Toy-regime policy

Paper parameters are too large to materialize even at small `n`: `N=2^n`, `R=N^lambda`, `M=2^m`, PCP proof tables, and the repetition count compound. `ConstructionPolicy` therefore has two modes:

```text
ProductionPolicy(symbols,budgets)  -- exact source laws; refuse over budget
ToyPolicy(intro_tuple,pcp_tuple,mu,gamma,tau,c_prime,repetitions)
                                    -- explicit overrides plus failed-law report
```

Toy mode changes no constructor or parser.  It substitutes only parameter values and repetition count, attaches an ASSUMED `toy_override` child, evaluates every production equality/admissibility/divisibility/capacity predicate, and prints each as `PASS`, `FAIL`, or `NOT_EVALUABLE`.  A toy
result can establish construction behavior but cannot satisfy a theorem contract when any required predicate fails. Production mode may construct compact descriptions with symbolic laws even when a query would return `BudgetExceeded`; it never silently caps a dimension or loop.

**DD-28 — Permit parameter overrides only through an ineligible toy policy.** Keep
the code path identical and make every deviation machine-visible; rationale: tiny end-to-end executions are useful only if their distance from the theorem regime is part of the result; rejected: scattering `min(k,2)` and small fields through the constructors.

### 12.5 TB7 concrete execution

Use a quoted nine-level padding of the one-bit identity verifier, with deterministic value-one answers, `n=2`, `N=4`, and `lambda=32768`.  Its exact description size is checked to be below `lambda`, and its constant runtimes are below `n^lambda`; thus the input's level and lambda-bounded predicates
pass.     Toy substitutions are:

```text
intro: (q_I,m_I,d_I)=(2,1,1)
answer reduction: (q_A,m_A,d_A,s_A,m'_A)=(2^11,1,11,6,16)
mu_toy=gamma_toy=tau_toy=1; c_prime_toy=1
repetitions_toy=2
```

The exact dimensions are `s_1=6+200=206`, `s_2=206+38*11+216=840`, anchored dimension `848`, and final dimension `1696`.  The largest TB2 line answer has `(m'+6)(m'd+1)=22*177=3894` field symbols, or 42,834 bits over `F_{2^11}`; the Repeat component guard is `(lambda*n)^tau=65,536`, so the honest
toy answer is not rejected by the guard.

The policy must print at least this predicate report:

| predicate | result |
|---|---|
| input field/level/lambda bounded; `n>=2` | PASS |
| intro field admissible, `m_I divides q_I`, `d_I=1`, `Q_I>=s_0(N)` | PASS |
| intro canonical tuple equality; `Q_I>=R` | FAIL |
| AR `P_shape`, `P_formula_paper`, `P_tail`, `P_divisibility`, `P_degree`, structural formula check | PASS |
| AR `P_growth`, universal `mu/gamma/tau`, `n>=C_0` | NOT_EVALUABLE |
| AR tuple equals `pcpparams(n,T,Q,sigma,gamma)` | FAIL |
| repeat `k_toy=(lambda*n)^((1+c')tau)` | FAIL |
| repeat question and answer component guard | PASS |

TB7 constructs every description, executes all four final sampler queries on branch-directed vectors, samples 16 final questions, constructs honest stabilizer/ PCP/repeated answers, and calls the final classical decider.  It requires all finite construction checks and toy transcripts to pass while
the overall theorem-eligibility bit remains false.  Target is `<60 s` warm and `<2 GiB`; the report breaks out Introspect, AnswerReduce, Repeat, and transcript walls.

Mutations are composition order, omit PCP downsize, change any one of `5,7,9`, use unpadded `|D1|` in the sampler, change one universal-constant AST, cap `k` outside ToyPolicy, or label a failed predicate PASS.  Each has a named law, hash, parser, or certificate-grade owner.

### 12.6 Executing `D_{M,L}=Y Psi_{M,L}`

Use the TB4 description-level `Fix`/`YCode`, set `L=lambda=32768`, and use a two-state machine `M_loop` whose start state loops and whose halt state is unreachable.  Index `n=2` is the smallest shared index for the lambda-bound and answer-reduction contracts.  The input transcript is deliberately a
legal repeated anchor/typed pair on which no introspection game guard calls the child decider.

The run must:

1. construct and reserialize `D_{M,L}=Fix(Psi_{M,L})`;
2. check that the embedded `self_code` hash equals the outer quote hash;
3. simulate exactly two steps of `M_loop` and take the nonhalting branch;
4. construct `S_L` from `lambda`, construct `Compress((S_L,D_{M,L}),lambda)` under
   the same ToyPolicy, and compare its sampler hash with TB7's independent hash;
5. execute the compressed decider on the supplied transcript and terminate without
   recursive host evaluation.

This exercises one description-level self-reference and the full constructor.  It does not establish the infinite fixed-point value argument.  A second fuel-limited transcript which reaches the final introspection game call must return `OutOfFuel` at the declared boundary, never Julia recursion.
The source's corresponding self-description construction and halting branches are `gt-12-compression.tex:L426-L492`; its general value and lambda-bounded conclusions remain cited (`L502-L519`, `L569-L576`).

**DD-29 — Separate compact construction from materialization.** Allow a symbolic
description to exist when its indexed question is beyond budget, and make the query return `BudgetExceeded`; rationale: this is necessary to represent paper-scale Compress without pretending it ran; rejected: allocating `k*s` coordinates before checking the law.

## 13. Ladder, claims, and the exact cited residue

### 13.1 Tracer-bullet ladder v2

Each new rung runs alone, prints canonical hashes and the complete certificate tree, then runs its owned mutants in isolated copies.

| rung | executable instance | required output | target | owned mutations |
|---|---|---|---:|---|
| TB5 Repeat | `V_copy`; `n=9,lambda=tau=1,c'=1,k=81`; dimensions `1->9->729` | four-query replay, 128 classical honest accepts, guard rejection, sampler hash | `<5 s`, `<256 MiB` | seven `M5-*` in §10.3 |
| TB6a design audit | `ell=1,3,9`; type/edge and parser generation | counts, schemas, source-query plan, no theorem claim | `<1 s` | missing edge, wrong count, missing guard |
| TB6b Introspect | `n=2,N=4,ell=1,(q,m,d)=(2,1,1)`; dimension 142; six tableau qubits | exact support/mass-one acceptance over 116 oriented types, detype branches, 256 seeded draws, query log | `<15 s`, `<512 MiB` | nine `M6-*` in §11.6 |
| TB7 Compress/fix | `n=2,lambda=32768`; dimensions `206->840->848->1696`; `k_toy=2` | `9->5->7->9`, 16 honest accepts, independence hashes, one fixed-point unfold, all failed predicates | `<60 s`, `<2 GiB` | order, field, level, size/hash, constants, cap, grade |

The implementation order is TB5, TB6a, TB6b, then TB7. TB6a freezes the source transcription before stabilizer code is admitted.  TB7 may reuse immutable PCP fixture data but must include its construction certificate and exact description hash; a cached green boolean is not evidence.

### 13.2 What remains mathematically difficult after TB7

At the end of TB7 all named sampler and decider constructions in §§9--12 are executed, including downsize, graph sampler, detype, anchor, direct-sum repetition, Pauli predicate, introspection predicate, composition, and finite fixed-point evaluation.  The following is the exact set of paper
objects allowed to remain as CITED leaves in the TB7 certificate; no construction may hide under one of them:

1. `prop:standard-succinct-sat` and `prop:explicit-padded-succinct-deciders`:
   general Cook--Levin/succinct-decider faithfulness and asymptotics
   (`gt-10-answer-reduction.tex:L237-L276`, `L1226-L1275`).
2. `lem:ld-soundness` and `lem:ld-complexity`: quantum low-degree enforcement and its general asymptotic implementation bound (`gt-07-ldt.tex:L413-L490`).
3. `lem:pauli-completeness`, `thm:pauli`, `cor:pauli-binary`, `lem:delta-bound`, `lem:introparams-complexity`, and `lem:qld-complexity`: general honest strategy, rigidity, canonical-parameter, and asymptotic facts beyond the exact tiny simulation (`gt-07-ldt.tex:L1232-L1617`).
4. `lem:detyping-verifiers`, completeness/soundness/Ent portions only; its sampler,
   decider, level, and dimension construction is executed
   (`gt-06-types.tex:L444-L475`).
5. `thm:oracle-completeness` and `thm:oracle-soundness`: quantum strategy transfer
   for oracularization (`gt-09-oracularization.tex:L125-L169`, `L296-L329`).
6. `thm:pcp-decider`, general completeness/soundness only; the concrete predicate,
   polynomial identities, and TB fixture are executed
   (`gt-10-answer-reduction.tex:L1455-L1533`).
7. `thm:ar`: the general quantum completeness, soundness, Ent, and asymptotic
   answer-reduction contract (`gt-10-answer-reduction.tex:L2077-L2116`).
8. `lem:intro-sampler-complexity`, `lem:intro-decider-complexity`, and `thm:introspection`: general asymptotic, PCC completeness, soundness, and Ent contracts (`gt-08-introspection.tex:L347-L392`, `L694-L817`).
9. `prop:anchoring`, theorem portions only, and `thm:bvy`/`thm:repetition`:
   quantum completeness and anchored parallel-repetition decay
   (`gt-11-parallel-repetition.tex:L51-L61`, `L112-L136`, `L229-L258`).
10. `lem:compress-independent-samplers` and `thm:compression`: the former's `polylog(lambda)` generation bound, and the production-regime `C_0`, polynomial bounds, value-one transfer, and Ent lower bound (`gt-12-compression.tex:L26-L53`, `L108-L147`).
11. `lem:dhalt-values`, `lem:lambda`, and `thm:halting`: the general fixed-point
    value argument, lambda selection, and undecidability conclusion
    (`gt-12-compression.tex:L502-L519`, `L569-L576`, `L643-L720`).

For `lem:compress-independent-samplers`, only the asymptotic generation bound is CITED: fixed-width specialization makes construction dependency CHECKED.  `lem:commute` is a source anchor, but the simulator checks every finite symplectic commutator it samples, so it is not a TB7 CITED leaf.

Any additional CITED label in a TB7 trace is a failure.  Conversely, relabeling any item above CHECKED without a replayable proof is a certificate failure.  This list, rather than the existence of green toy transcripts, is the boundary of the local mathematical result.

### 13.3 MERGE PROPOSALS

The following rows are proposals only; `claims/CLAIMS.md` is not edited.

| id | statement (quantifiers included) | status | depends-on | where-proved | where-tested | verdict |
|---|---|---|---|---|---|---|
| C12 | (Description-level CL closure) For every well-formed `SamplerDescription`, `downsize`, `direct_sum`, `product`, executable `detype`, `anchor`, and symbolic `repeat` are definable using only field/level headers and the four sampler queries; their output field, level, dimension, dependency, exact-description-size, and metered call laws are replayable, while all semantic soundness implications remain CITED. | CONJECTURE | C4a,C4b | — | — | — |
| C13 | (TB5 Repeat fixture) For `V_copy` at `n=9,lambda=tau=1,c'=1`, executable anchoring and 81-fold repetition have checked levels/dimensions `1,1 -> 3,9 -> 3,729`, reject an overlong component before a child call, accept the named classical value-one strategy on all branch-directed and 128 seeded transcripts, and produce sampler bytes independent of the decider. | CONJECTURE | C12 | — | — | — |
| C14 | (TB6 Introspect fixture) For the explicitly ineligible toy tuple `n=2,N=4,lambda=1,ell=1,(q,m,d)=(2,1,1)`, the Pauli and introspection samplers and classical predicates are executable through the four-query API; the detyped sampler has checked level 5 and dimension 142, and exact stabilizer enumeration on six physical qubits gives total mass one and acceptance on every support transcript for all 116 oriented typed pairs. This is finite completeness evidence; `thm:pauli` and `thm:introspection` remain CITED. | CONJECTURE | C12,C4a | — | — | — |
| C15 | (TB7 executable Compress/fixed point) Under the printed ToyPolicy at `n=2,lambda=32768`, `Compress=Repeat o AnswerReduce o Introspect` constructs and executes the level chain `9->5->7->9`, dimensions `206->840->848->1696`, all sampler/decider descriptions and one finite unfold of `D_{M,L}=Y Psi_{M,L}`; two distinct input verifiers yield identical compressed-sampler hashes. Every failed production predicate and every remaining theorem leaf in §13.2 stays visible, so no production soundness claim is made. | CONJECTURE | C10,C12,C13,C14 | — | — | — |

Missing steps before promotion are exact:

- **C12:** implement canonical `QuotedBranch`, all query-only wrappers, the fixed-width introspection specialization, exhaustive small adapters, spy-query tests, and all law/size/hash mutations; obtain a critic verdict.
- **C13:** implement TB5, demonstrate every `M5-*` red result, measure walls and allocation, and obtain a critic verdict.
- **C14:** complete TB6a source audit, implement Pauli/Magic-Square predicates, adaptive factor/dual queries, stabilizer simulation and executable detyping, demonstrate every `M6-*` red result, and obtain a critic verdict.
- **C15:** land the nontrivial TB3 front end and C12--C14, implement the `AR-field-align` downsize and ToyPolicy, run the full end-to-end descriptions and fixed point within budget, demonstrate all TB7 mutations, and obtain a critic verdict.  Production constants and all §13.2 mathematical leaves remain outside promotion even after this finite claim becomes TESTED.

**DD-30 — Close the executable ladder without closing the theorems.** Treat a green
TB7 as evidence for construction, bookkeeping, finite honest transcripts, and fixed-point execution only; rationale: these are the reusable engineering objects the campaign can adversarially verify; rejected: calling the complete pipeline a local proof of compression soundness.
