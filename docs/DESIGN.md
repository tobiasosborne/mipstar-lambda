# Symbolic term language and Julia architecture

All mathematical names in this document have one authoritative entry in [`definitions.md`](definitions.md). A source citation has the form
`file:Lfirst-Llast (label)`. The status words used below are:

- **CONSTRUCTED**: true because no IR value of the stated type can be built without the property;
- **CHECKED**: computed from the value and accompanied by a replayable derivation or certificate;
- **ASSERTED**: not established locally. A sourced assertion is printed **CITED**; an unsourced one is printed **ASSUMED**.

Only CONSTRUCTED and CHECKED leaves can discharge a machine-checkable claim. CITED leaves may occur in an honest derivation tree, but keep
that tree from being reported as a local proof.

## 1. The term language

### 1.1 Program and description sort

The lambda layer is a phase-separated, explicitly represented calculus. It is not `Expr`, and a macro cannot create an IR node except
through the same checked constructors used by ordinary functions.

Let `Name`, `PrimName`, `Nat`, and `StaticEnv` be finite serializable data. The inductive grammar is

```text
P ::= BoundVar(depth, slot)                  variable
    | Lambda(arity, P)                       abstraction
    | Apply(P, P*)                           application
    | Fix(P)                                 fixed-point combinator
    | If(P, P, P)                            conditional
    | Prim(PrimName, Bound, P*)              bounded primitive
    | Quote(Closed(P))                       syntax as a value
    | Eval(Pcode, Pargs, Fuel)               fuel-bounded evaluator
    | Specialize(Pcode, StaticEnv)           code-to-code substitution
```

`BoundVar` uses de Bruijn addresses internally; a side table retains source names for printing. `Closed(P)` is available only after a scope
traversal. Every primitive carries a total input contract and a symbolic cost bound. `Eval` consumes fuel and returns `Value`, `OutOfFuel`,
or `TypeError`, never a host-language exception. `Fix(P)` is syntax even when its evaluation would not terminate.

The semantic objects are deliberately distinct:

```text
Closure       = (ClosedProgram body, RuntimeEnv env)       -- runtime value
Quoted{A}     = canonical bytes for a closed P : A         -- description
CircuitIR     = finite Boolean DAG                          -- compiled object
UEval         = a particular quoted universal evaluator    -- program
Specialized{A}= Quoted{A} plus a substitution certificate  -- description
```

`Quoted{A}` has a canonical serialization and an exactly computed `description_size`; `Closure` has neither. Compilation accepts `Quoted`,
not a closure and not an extensional Julia function. This is the intensional fact needed by Cook--Levin, whose bounded-halting input
contains a machine description and fuel, and by answer reduction, whose parameters include `|D|` (`gt-10-answer-reduction.tex:L200-L205`,
`L1396-L1422`, `L2077-L2096`). `Compress` likewise receives and returns descriptions (`gt-12-compression.tex:L26-L39`, `L75-L98`).

The description-level fixed-point combinator has the interface

```text
YCode : (Quoted{A} -> Quoted{A}) -> Quoted{A}
eval(YCode(f), u; fuel) = eval(f(YCode(f)), u; fuel)
```

for every fuel at which both sides terminate. It is represented by `Fix`, not implemented by Julia recursion. With holes filled only by
`Specialize`, the halting verifier is the following term:

```text
Psi_M_L = Lambda(d::Quoted{Decider},
  Specialize(
    Quote(Lambda(self_code, n, x, y, a, b,
      If(Prim(halts_within, bound=n, M, n), true,
         Eval(Specialize(Quote(Compress),
                {verifier => Prim(quoted_pair, constant, Quote(S_L), self_code),
                 lambda => Quote(L)}),
              (n, x, y, a, b), FuelBound(n, L))))),
    {self_code => d}))

D_M_L = Apply(YCode, Psi_M_L)
```

Thus `D_M_L = Y Psi_M_L` is a finite quoted term, matching the fixed-point equation in `handoff.md:L21-L35`. The bounded `quoted_pair`
primitive joins two code values without capture. `Compress` sees the resulting quote `(S_L,d)`, traverses and specializes that body,
computes its byte length, and never attempts to compare or serialize the function computed by `d`.

Program invariants are recorded as follows.

| invariant                        | status            | representation                         |
|----------------------------------|-------------------|----------------------------------------|
| scope and phase correctness      | CONSTRUCTED       | `Closed`, `Quoted`, and typed holes    |
| canonical description size       | CHECKED           | serialization hash, byte count, replay |
| primitive cost                   | ASSERTED or CITED | `Bound` leaf names its source          |
| bounded evaluation trace         | CHECKED           | transition-by-transition trace         |
| fixed-point extensional behavior | ASSERTED/CITED    | never promoted by execution samples    |

**DD-1 — Separate code from values.** Use `Quoted`, `Closure`, `CircuitIR`, `UEval`, and `Specialized` as disjoint types; rationale:
compression is intensional; rejected: accepting `Function` or raw `Expr` wherever code is expected.

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

Fan-in is explicit. Production compilation normalizes to fan-in two; the tiny tracer fixture may retain one bounded fan-in gate and records
that relaxation. The private `Circuit` constructor checks unique gate identifiers, topological references, block extents, and the output
wire. Its gate count `s` and block lengths are computed fields.

The front-end IR values are:

```text
BoundedTrace(program, input, T, configurations, result)
Succinct3SAT(C3, variable_count=M, index_width=m)
SuccinctDecoupled5SAT(C5,
  index_blocks=(X1[m],...,X5[m]), sign_block=O[5], clause_shape)
TseitinFormula(formula, input_blocks, gate_block=W[s], occurrences)
```

`C5(x1,...,x5,o1,...,o5)=1` exactly when the clause `x1[x1]^o1 or ... or x5[x5]^o5` is present. The five index blocks and five sign bits are
structural fields, not a naming convention; this is the paper's decoupled clause shape (`gt-10-answer-reduction.tex:L920-L979`). The full
formula `phi_C` is intentionally not materialized.

Tseitin adds one Boolean variable for each gate and a formula relating the inputs and gate values. The relevant contract is: `n+s`
variables, size `O(s)`, satisfiable extensions exactly for accepting circuit inputs (`gt-10-answer-reduction.tex:L148-L158`, correcting
`formula(x,s)` to `formula(x,w)`). `occurrences` is computed from the formula. The specialized constructor required by this project refuses
a result unless every variable occurs at most twice; this certifies the arithmetization's individual-degree-2 bound
(`gt-10-answer-reduction.tex:L173-L191`).

`arith_q` recursively maps Boolean values to a polynomial over `F_q`:

```text
false -> 0              not(a) -> 1-a
true  -> 1              and(a,b) -> a*b
                         or(a,b) -> a+b-a*b
```

and extends variadic gates by a fixed binary bracketing stored in the trace. Agreement with the Boolean formula on `{0,1}` is checked on
tracer instances and represented as a construction derivation generally. The known source typo gives the domain as `F_q^{m'}` for an
`m`-variable formula; the design uses the number of formula variables (`gt-10-answer-reduction.tex:L160-L171`).

| invariant                                      | status         | representation              |
|------------------------------------------------|----------------|-----------------------------|
| DAG and named block shape                      | CONSTRUCTED    | private constructors        |
| gate count `s` and formula occurrences         | CHECKED        | traversals                  |
| decoupled five-block clause form               | CONSTRUCTED    | fixed product type          |
| trace/formula faithfulness on a finite fixture | CHECKED        | exhaustive table            |
| general Cook--Levin faithfulness/size          | ASSERTED/CITED | cited proposition leaf      |
| each variable occurs at most twice             | CHECKED        | occurrence certificate      |
| `arith_q` individual degree at most 2          | CHECKED        | derivation from occurrences |

**DD-3 — Make blocks first-class.** Store block identities and extents on every wire; rationale: dependency and decoupling checks then
require no name parsing; rejected: flat integer variable identifiers with prefixes.

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
Restrict(substitute and project)     MultilinearExtension(bound=1 on one block)
ArithTseitin(occurrence vector <= 2)
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

and receives a `MultilinearExtension` leaf with dependency exactly its own `X_i` block. `dec_H` is evaluation on the Boolean subcube
followed by the paper's membership-or-zero rule (`gt-03-prelim.tex:L917-L924`).

Sparse expansion is intentionally small-scope. Before coefficient merging,

```text
support(c0) <= support(F_arith) * product_i (support(g_i)+1).
```

At `m=2`, dense multilinear `g_i` already give the factor `5^5=3125`; expanding a Tseitin arithmetization over 16--32 variables can dominate
memory. Constructors therefore accept a `MonomialBudget`, estimate before multiplying, and return `ExpansionRefused(estimate,budget)`
without partial output. TB0/TB2 use a one-monomial `F_arith` and `g_i=x_i`, hence exactly `2^5=32` monomials in `c0`. The sparse
representation is an experiment, not a claim of scalability.

| invariant                             | status                          | representation                      |
|---------------------------------------|---------------------------------|-------------------------------------|
| coefficient field and variable layout | CONSTRUCTED                     | type parameters/value tags          |
| zero-free normalized support          | CONSTRUCTED                     | private polynomial constructor      |
| structural degree/dependency bound    | CHECKED                         | replayed derivation tree            |
| actual degree/dependency              | CHECKED                         | support traversal                   |
| equality of two polynomials           | CHECKED                         | normalized coefficient dictionaries |
| paper-scale feasibility               | ASSERTED (false until measured) | never a certificate                 |

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

Thus if `c0` has individual degree `d`, every `c_i` has individual degree at most `d`, and the divided variable has degree at most `d-2`,
exactly the stronger remark in the paper (`gt-10-answer-reduction.tex:L1311-L1322`). Both the general bound and these coordinatewise
stronger bounds are checked from support. For the honest PCP `d=3`, each `c_i` is certified at most 3 overall and at most 1 in its own
variable (`gt-10-answer-reduction.tex:L1685-L1717`).

For C2, `r==0 iff the witness satisfies phi_C` is not baked into the division type. The explicit instance checks both directions by
enumerating its finite clause relation and Boolean assignments. The general implication uses the succinct-decider contract and remains
CITED.

**DD-6 — A failed zero proof is data.** Return the nonzero multilinear remainder rather than throwing it away; rationale: the mutation
explains its own failure; rejected: a Boolean `is_zero_on_cube` flag.

### 1.5 Sampler sort

The sampler sort is

```text
Sampler[DistributionClass, AdaptivityLevels]
```

where conditional linearity is witnessed by the following inductive datatype, which mirrors `def:cl-func` (`gt-04-cl.tex:L35-L57`):

```text
CLZero(V) :: CL{0,V}                       -- the zero function

CLStep(V1, Vrest, A,
       branch : image(A) -> CL{ell-1,Vrest},
       complement_certificate) :: CL{ell,V1 direct_sum Vrest}
```

`A` is a matrix acting on `V1`. Matrix representation makes linearity CONSTRUCTED. Coordinate-register direct sums carry disjointness by
datatype; general subspaces require a checked rank/decomposition certificate before the private constructor returns `CLStep`. A branch is
genuinely a function of the previous value, not a preselected child. Its codomain level and remaining ambient space are fixed by the type.
Therefore “is CL of level ell” is CONSTRUCTED, not discovered by sampling.

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

For `V=V_pt direct_sum V_coord direct_sum V_dir`, write `u in F_q^m`, `s in F_q`, and `v in F_q^m`. The concrete values are:

```text
L_Point(u,s,v) = (u,0,0)                                  level 1
L_ALine(u,s,v) = (L_lnf(e_chi(s))*u, s, 0)                level 2
L_DLine(u,s,v) = (L_lnf(pi_(chi(s)-1)(v))*u,
                    s, pi_(chi(s)-1)(v))                  level 3
```

`chi(s)=1+floor(integer_representation(s)/(q/m))`, requiring `m | q`. `L_lnf(v)` is the canonical projection whose kernel is `span(v)` and
whose image is the canonical complement (`gt-03-prelim.tex:L375-L384`; `gt-07-ldt.tex:L143-L174`). For `v=0`, where the cited kernel-basis
definition does not apply although singleton lines are explicitly allowed, the IR uses `L_lnf(0)=identity` and marks the node
`SOURCE_REPAIR` (`gt-07-ldt.tex:L106-L124`). The stage order is coordinate, then direction, then point, exactly exposing why `ALine` is
level 2 and `DLine` level 3 (`gt-07-ldt.tex:L203-L237`). Exact histogram comparison tests the induced line-point distributions stated in
`lem:alnf` and `lem:dlnf` (`gt-07-ldt.tex:L243-L287`).

The typed PCP sampler has 18 types `Point_i`, `ALine_i`, `DLine_i`, `i=1,...,6`, and a complete type graph. Its
`V_{i,pt}/V_{i,coord}/V_{i,dir}` registers are five `m`-dimensional point/direction triples plus auxiliary blocks of dimension `5+s`; the sixth point, coordinate, and
direction registers are the direct sums and have dimension `m'=5m+5+s`. Thus copies 1--5 test `g_i` separately and copy 6 tests
`(g_1,...,g_5,c_0,...,c_m')` simultaneously (`gt-10-answer-reduction.tex:L1870-L1946`). Direct sums preserve maximum level, so the whole PCP
sampler is 3-level, not 18-level: at most three adaptive linear stages are taken on one seed.

The answer-reduced typed sampler is the product of this sampler and the oracularized sampler. Oracularization uses types
`{alice,bob,oracle}`, maps the isolated types by `L^alice,L^bob`, and maps `oracle` by the identity (`gt-09-oracularization.tex:L36-L86`).
Product means direct-summing their ambient spaces and CL functions and taking the product type graph; its typed level is `max(ell,3)`
(`gt-10-answer-reduction.tex:L1948-L1965`).

| invariant                       | status                 | representation                    |
|---------------------------------|------------------------|-----------------------------------|
| CL level                        | CONSTRUCTED            | `CLZero`/`CLStep` nesting         |
| linearity of a stage            | CONSTRUCTED            | field matrix                      |
| complementary spaces            | CONSTRUCTED or CHECKED | register sum/rank certificate     |
| `apply`/marginal agreement      | CHECKED                | exhaustive small-field replay     |
| typed graph and product         | CONSTRUCTED            | finite graph/product constructors |
| equality to paper distributions | CHECKED on TB1         | exact histograms                  |
| low-degree-test soundness       | ASSERTED/CITED         | theorem leaf only                 |

**DD-7 — Encode CL inductively.** Make the conditional continuation a field of `CLStep`; rationale: level is then impossible to forge;
rejected: arbitrary functions plus an `is_cl=true` tag.

**DD-8 — Keep typing until the boundary.** Build and test the typed PCP product before detyping; rationale: Figure `decider-pcp` reasons in
those types; rejected: flattening type tags into question bytes at construction time.

### 1.6 Verifier sort and contracts

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

| verifier invariant | status |
|---|---|
| question/answer lengths and parser shapes | CHECKED from the sampler/decider IR |
| CL levels | CONSTRUCTED by the sampler datatype |
| local runtime and description size | CHECKED; asymptotic theorem bounds are CITED |
| gap/completeness/entanglement transform | ASSERTED/CITED except finite completeness tests |
| executable versus stub | CONSTRUCTED by `VerifierIR` versus `StubVerifier` |

The transformation contracts are:

- `Introspect(V,lambda,ell)`: 5-level; sampler time `poly(n,lambda,ell)`, decider time `poly(2^(lambda*n),ell)`, decider description
  `poly(lambda,ell)`, with the stated completeness, soundness map, and entanglement bound (`gt-08-introspection.tex:L784-L817`).
  Implementation status: `StubVerifier` with one CITED `thm:introspection` certificate.
- `AnswerReduce(V,lambda,mu,gamma)`: detyped level `max(ell+2,5)`, the stated polynomial time bounds, sampler dependency, completeness,
  soundness map, and entanglement inequality (`gt-10-answer-reduction.tex:L2077-L2116`). Implementation status: the PCP proof, typed
  sampler, and Figure `decider-pcp` checks are implemented by TB0--TB2; oracularization soundness, detyping soundness, and quantum lifting
  remain CITED.
- `Repeat(V,lambda,tau)`: anchored repetition with `k(n)=(lambda*n)^((1+c')*tau)`, level `ell+2`, the stated runtime, completeness, and
  entanglement/soundness implication (`gt-11-parallel-repetition.tex:L229-L258`). Implementation status: `StubVerifier` with one CITED
  `thm:repetition` certificate.
- `Compress(V,lambda) = Repeat(AnswerReduce(Introspect(V,lambda,9), lambda,mu,gamma),lambda,tau)`: 9-level with both runtimes
  `poly(n,lambda)`, sampler description independent of `V`, and the theorem's completeness and entanglement lower bound
  (`gt-12-compression.tex:L26-L53`, `L75-L118`). Implementation status: composition skeleton only; its non-PCP leaves are visibly CITED.

An `ASSERTED` parameter cannot be silently converted to a Julia type parameter. Construction bounds may be propagated, while theorem
conclusions remain certificate leaves.

**DD-9 — Let stubs have a distinct term type.** A theorem-backed placeholder is `Checked{StubVerifier,Cited}`; rationale: no caller can
mistake it for an executable verifier; rejected: a no-op function returning its input with a “proved” flag.

## 2. The combinator algebra

All transformations below are pure functions on immutable IR values. A macro, if later added, may only parse surface syntax and call these
functions.

Illustrative Julia signatures are:

```julia
quote_program(p::Program) :: Checked{QuotedProgram, ScopeAndSizeCert}
specialize(p::QuotedProgram, env::StaticEnv) :: Checked{QuotedProgram, SubstCert}
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

low_degree_sampler(params::LDParams) :: Checked{TypedSampler, CLCert}
pcp_sampler(params::PCPParams) :: Checked{TypedSampler, CLCert}
oracularize_sampler(s::Sampler) :: Checked{TypedSampler, Cited}
answer_reduce_pcp(v::Verifier, lambda, mu, gamma)
    :: Checked{TypedVerifier, CompositeCert}

Introspect(v::QuotedVerifier, lambda, ell) :: Checked{StubVerifier, Cited}
AnswerReduce(v::QuotedVerifier, lambda, mu, gamma) :: Checked{VerifierIR, CompositeCert}
Repeat(v::QuotedVerifier, lambda, tau) :: Checked{StubVerifier, Cited}
Compress(v::QuotedVerifier, lambda) :: Checked{StubVerifier, CompositeCert}
```

The pipeline extends evidence as follows.

1.  `D -> bounded_trace`: preserves the quote hash, description size, input, and fuel `T`; appends every transition and the terminal result.
2.  `bounded_trace -> succinct 3SAT`: preserves `T` and input blocks; appends a trace/formula equivalence check for the fixture or a CITED
    Cook--Levin leaf generally. The paper's succinct contract is at `gt-10-answer-reduction.tex:L229-L260`.
3.  `succinct 3SAT -> succinct decoupled 5SAT`: records the map into five independent `m`-bit blocks plus five signs and checks the clause
    relation.
4.  `decoupled 5SAT -> Tseitin -> arith_q`: propagates `s`, the block layout, and occurrence counts; appends Boolean-agreement and degree-2
    derivations.
5.  `arithmetization -> low-degree PCP`: constructs five block-local `g_i`, `c0`, and the rewrite-certified `c_i`; appends degree/dependency
    support reports and the `pcpverifier` formula/zero checks (`gt-10-answer-reduction.tex:L1548-L1585`).
6.  `low-degree PCP -> D_AR`: constructs the six-copy typed CL sampler, products it with the oracularized sampler, and installs the five
    checks in Figure `decider-pcp` (`gt-10-answer-reduction.tex:L1973-L2071`). Quantum conclusions append CITED leaves; they are not
    inferred from passing samples.

`build_pcp` checks the exact relation `m'=5m+5+s`, the five dependency blocks, and the field/divisibility policy selected by the caller.
Relaxations are values in `ParameterPolicy`; they cannot disappear from the trace.

**DD-10 — One transformation, one evidence extension.** Each combinator retains its child's certificate and adds one node; rationale:
printed traces mirror the mathematics; rejected: rebuilding a flat metadata record at the end.

## 3. Invariant tracking and the derivation tree

The certificate algebra is itself explicit IR:

```text
Certificate ::= Constructed(rule, facts)
              | Computed(rule, inputs_hash, outputs_hash, facts)
              | Rewrite(rule, before, after, local_identity)
              | Bound(rule, expression, children*)
              | SchwartzZippel(total_degree, field_size, event, source)
              | Compose(rule, children*)
              | Cited(file, lines, label, statement)
              | Assumed(statement, reason)
              | SourceRepair(file, lines, repair)
```

Every node has a stable identifier, input/output hashes, and a `replay` method when its grade is CHECKED. `Cited`, `Assumed`, and
`SourceRepair` deliberately have no replay method. `verify_certificate` returns a structured list of failures; it never uses bare `@assert`.

Symbolic bounds use a normalized expression grammar

```text
B ::= integer | parameter | B+B | B*B | B^B | log(B) | max(B*) | poly(B*)
```

with domains and side conditions. Degree bounds compose coordinatewise; field-size nodes retain `q=2^k`, parity of `k`, and divisibility
obligations; description sizes compose under canonical serialization; runtime bounds compose by substitution and addition; gap implications
compose by function composition in the contravariant direction. No `poly(...)` is silently assigned an exponent.

A concise trace printer emits, for example:

```text
[CHECKED] Quote                  |D| = 73 bytes
[CHECKED] BoundedTrace           T = 1; accepted
[CHECKED] Decoupled5SAT          blocks = 5x1 + 5 signs
[CHECKED] ArithTseitin           inddeg(F_arith) = 2
[CHECKED] BuildC0                structural = actual = 3; monomials = 32
[CHECKED] ZeroBasis              remainder = 0; coefficient identity = true
[CHECKED] PCPVerifier            formula + zero tests = accept
[CONSTRUCTED] PCPSampler         typed CL level = 3
[CITED] LowDegreeEnforcement     gt-07-ldt.tex:413-440 (lem:ld-soundness)
[CITED] QuantumAnswerReduction   gt-10-answer-reduction.tex:2077-2116 (thm:ar)
```

Tests inspect the tree, not its prose: node sequence, grade, rule name, normalized bound expression, dependency set, source label, and
hashes are all matched. C1--C4 and C6 require no ASSUMED/CITED leaf in their machine-tested portion. C5 is a derivation tree whose two
Schwartz--Zippel nodes are explicit; its general Cook--Levin and theorem-level leaves remain visibly CITED.

**DD-11 — Preserve opaque polynomial bounds.** Store `poly(parameters)` as a symbolic constructor; rationale: the paper often does not
expose exponents; rejected: inventing concrete exponents for executable-looking metadata.

**DD-12 — Hash every evidence edge.** Bind certificates to exact IR inputs and outputs; rationale: mutations cannot reuse stale evidence;
rejected: detached human-readable logs.

## 4. Soundness: what is and is not claimed

### 4.1 Soundness assuming low-degree proofs

This layer is a derivation, not a numerical experiment. Given a well-formed low-degree PCP proof `Pi` of individual degree at most `d` and
acceptance probability greater than `1/2`, construct:

```text
LowDegreePCPSoundness
|- FormulaTestOccursOnEveryAcceptedView                         [CHECKED logic]
|- FormulaAgreementProbability > 1/2                           [CHECKED logic]
|- Degree(formula difference) <= (2+5d)m'                      [CHECKED bound]
|- SZ_Formula(total_degree=(2+5d)m', field=q)                   [SZ lemma]
|- ParameterInequality((2+5d)m'/q < 1/2)                       [CHECKED arithmetic]
|- FormulaPolynomialIdentity                                   [DERIVED]
|- ZeroTestOccursOnEveryAcceptedView                            [CHECKED logic]
|- ZeroAgreementProbability > 1/2                              [CHECKED logic]
|- Degree(zero difference) <= (2+d)m'                          [CHECKED bound]
|- SZ_Zero(total_degree=(2+d)m', field=q)                       [SZ lemma]
|- ParameterInequality((2+d)m'/q < 1/2)                         [CHECKED arithmetic]
|- ZeroPolynomialIdentity                                      [DERIVED]
|- BooleanCubeVanishes -> decoded assignments satisfy phi_C    [CHECKED/CITED]
|- SuccinctDeciderFaithfulness -> D accepts within T            [CITED generally]
```

The two deliberately loose total-degree bounds are exactly those used in the paper (`gt-10-answer-reduction.tex:L1733-L1771`). Tighter
dependency-aware bounds may be printed alongside them but may not replace them in C5. The final decoding argument is grounded at
`gt-10-answer-reduction.tex:L1774-L1785`.

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

The fixed PCP fixture has five one-bit index blocks, five sign bits, six padded gate variables, `s=6`, and `m'=5m+5+s=16`. It describes the
single all-positive clause at index 1. Its arithmetization is the duplicated-literal formula `F_arith=(product_i x_i*o_i)^2`, so each input
occurs twice and its individual degree is 2. Padding variables are unused and visibly tagged. With witness blocks `[0,1]`, `g_i(x_i)=x_i`;
therefore `c0` has exactly `2^5=32` nonzero monomials and actual individual degree 3. This deliberately tiny formula fixture tests the PCP
algebra, not the full Tseitin compiler.

| rung            |    `q` | `m` | `d` |                   `s` | `m'` | does `m'` divide `q`? | expected `c0` support / wall time     |
|-----------------|-------:|----:|----:|----------------------:|-----:|-----------------------|---------------------------------------|
| TB0-tiny        |      2 |   1 |   3 |                     6 |   16 | no (flagged)          | exactly 32 / under 15 s for 65,536 points |
| TB0-paper-field | `2^13` |   1 |  13 |                     6 |   16 | yes                   | exactly 32 / under 15 s for 10,000 points |
| TB0.5 midpoint  |    n/a | n/a | n/a |                   n/a |  n/a | n/a                   | no polynomial / under 1 s                 |
| TB1 low degree  |      8 |   2 |   1 | 5 (ambient dimension) |  n/a | n/a                   | no `c0` / under 10 s for 32,768 seeds     |
| TB2 typed AR    | `2^13` |   1 |  13 |                     6 |   16 | yes                   | exactly 32 / target under 45 s            |
| TB3 front end   | `2^13` |   1 |  13 |                     6 |   16 | yes                   | exactly 32 / target under 30 s            |
| TB4 Compress IR |    n/a | n/a | n/a |                   n/a |  n/a | n/a                   | no expansion / under 1 s                  |

Here `s=5` in TB1 is the ambient seed-space dimension `2m+1`, not a gate count. In all PCP rows `m | q`; TB0-tiny violates only `m' | q` and
also uses `d>=q`, so it is a completeness/rewrite exhaustive check with no soundness interpretation. TB0-paper-field, TB2, and TB3 satisfy
`q=2^k` with odd `k`, `m|q`, and `m'|q`.

### 5.1 TB0 — field, encoding, zero basis, and PCP core

Concrete instances:

1.  Check field axioms, inverses, serialization, and distributivity exhaustively in `GF(2^3)` and on 10,000 seeded triples in `GF(2^13)`.
2.  For `m=1`, extend `[0,1]`; for `m=2`, extend `[0,1,1,0]`. Verify every Boolean value and compare symbolic evaluation with
    `a dot ind_m(x)` on all points of `GF(8)^m`, then on seeded `GF(2^13)` points.
3.  Over `GF(5)` only, decompose the two-variable formal polynomial `f=x^3-x^2+x*y^2-x*y`; check every rewrite and coefficient identity.
    This non-paper field makes the minus sign mutation observable. Repeat over `GF(8)` to exercise the implementation used later.
4.  Build the fixture `Pi=(g_1,...,g_5,c_0,...,c_16)`. Run `pcpverifier` at all `2^16` points for `q=2`, and at at least 10,000 seeded
    uniform points for `q=2^13`. Assert both tests accept, `r=0`, coefficient identity, dependency blocks, `F_arith<=2`, `c0<=3`, every
    `c_i<=3`, and equality of structural and actual degree vectors.

Print field parameters, monomial/dependency table, certificate remainder, all two PCP check equations, sample coverage, and the full trace.
Mutations: replace `e-2` by `e-1` in the rewrite; remove one `g_i-o_i` factor; and corrupt one field modulus reduction. Each must make its
dedicated test nonzero.

Confidence is high. Measure sparse-dictionary normalization first; if the 65,536-point loop exceeds 10 seconds, evaluation—not
construction—is the first optimization target.

### 5.2 TB0.5 — midpoint diagnostic (C6/N1)

Place this between TB0 and TB1. On the domain `Z/17Z`, use `f(x)=x+1 mod 17`. For every `0<=n<=8` and every false pair `(x,y)`, dynamic
programming computes the exact rational optimum

```text
p[0,x,y] = indicator(y=f(x))
p[n,x,y] = max_z (p[n-1,x,z]+p[n-1,z,y])/2.
```

Assert the optimum is `1-2^-n` for every false claim and 1 for every true claim. Print the recurrence table and the inferred repetition
count to reach a fixed constant gap. Mutate averaging to `max` or omit one branch; the exact rational comparison must fail. This is fully
independent of PCP parameters and runs in roughly `9*17^3` scalar operations.

### 5.3 TB1 — classical low-degree test sampler

Use `q=8`, `m=2`, `d=1`; `m|q` and odd extension degree 3 satisfy the paper's field policy. Enumerate all `q^(2m+1)=32,768` seeds. Compare
exact histograms of `(L_ALine,L_Point)` and `(L_DLine,L_Point)` with direct samplers from `lem:alnf`/`lem:dlnf`, including zero directions.
Assert levels 1, 2, 3 from the datatype and replay every marginal.

Use the honest polynomial `g=1+x_1+x_1*x_2`; construct every axis and diagonal restriction and assert `D^ld` accepts every applicable pair
and consistency case. Mutate `chi` at a bucket boundary and require histogram mismatch. Also submit `g=x_1^2` while claiming `d=1`; an
axis-line format/consistency check must reject at a deterministically located point. Print histogram support/counts, levels, line
representatives, and the verifier trace.

Confidence is high; the first measurement is the cost of canonical projection for all 32,768 seeds.

### 5.4 TB2 — full typed answer-reduced decider

Use the paper-field PCP row and a trivial 1-level original sampler. Form its three-role oracularization, the 18-type PCP sampler, and their
54-type product. Assert typed level 3, the register dimensions in `V^pcp`, and every question and answer parser. Construct the honest
strategy from `Pi`; execute all five checks of Figure `decider-pcp` on a branch-covering deterministic suite plus 256 seeded sampler
questions. Every honest check must accept.

Mutate `c0` by `+1` and target the formula test; mutate the separate `g_3` by `+1` while leaving its bundled copy unchanged and target the
proof-consistency check; truncate one line polynomial and target `D^ld`. Each must produce at least one named rejection. Print the
type-product construction, dimensions, branch coverage, and nested PCP/low-degree traces.

This is the least certain sub-60-second rung: a diagonal answer at `m'=16` and `d=13` is padded to many coefficients. Measure allocations
for one `DLine_6` restriction first; use sparse univariate coefficients and lower the random sample count, but never remove branch-directed
checks.

### 5.5 TB3 — quoted front end

Use the closed program `lambda n x y a b. true`, fuel `T=1`, and the explicit accepting one-transition trace. The intentionally small,
honest Cook--Levin fixture maps the always-accept trace to `true` 3SAT, then to the single decoupled clause whose third witness block can
always satisfy it. Its succinct membership circuit uses one bounded-fan-in live gate and five padding slots, giving the table's
`m=1,s=6,m'=16`; this is not claimed to meet the asymptotic construction of `prop:explicit-padded-succinct-deciders`.

Exhaustively compare program result, bounded trace acceptance, 3SAT satisfiability, and decoupled-5SAT satisfiability over the two one-bit
answer blocks. Feed the generated—not hard-coded—description and witness into TB0's PCP builder and TB2's typed decider. Assert quote
hash/size propagation and print every intermediate symbolic object. Mutate the accepting transition to a rejecting one without changing the
formula; trace/formula equivalence must fail before the PCP stage.

Expected `c0` support remains exactly 32. Confidence is medium: measure whether the chosen duplicated-literal arithmetization arises from
the fixture's canonical formula printer; freeze that printer before implementation proceeds.

### 5.6 TB4 — `Compress` skeleton and quoted fixed point

Construct `D_M_L=YCode(Psi_M_L)` for a two-state machine `M` and a symbolic `L`. Specialize its quoted body and pass it through
`Compress = Repeat o AnswerReduce o Introspect`. Assert the outer result is a 9-level `StubVerifier`, that `|D_M_L|` is computed from
canonical bytes, and that the trace has CHECKED program/specialization nodes, the CHECKED PCP subtree, and exactly named CITED leaves for
introspection, quantum answer reduction, repetition, and compression.

Print the quoted term, size, specialization substitutions, contract bounds, and certificate-grade summary. Mutate composition order, pass a
`Closure` where a `QuotedVerifier` is required, or relabel a CITED leaf as CHECKED; construction or certificate verification must fail. No
theorem stub is executed.

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

There are zero non-stdlib dependencies. `Test`, `Random`, and `SHA` suffice; finite fields and sparse formal polynomials are small enough to
implement directly. A dependency may be proposed later only with a benchmark showing it decisively moves TB2 below the time limit without
obscuring certificates.

For each rung: write the green specification and mutation first, run it red for the missing constructor, implement the minimum IR, run
green, then run the mutation and require nonzero exit. Mutation scripts copy the repository fixture to a temporary directory, apply one
named textual or semantic change there, run only the targeted test, and fail if the mutated run exits zero. They never edit the working
tree.

Checkers return `CheckResult{Pass}` or `CheckResult{Fail}` with rule, location, expected, actual, and evidence hash. Tests use `@test`;
library checkers contain no bare `@assert`, so checks remain active regardless of compilation settings. Random tests use printed seeds;
exhaustive tests print cardinalities.

**DD-15 — No algebra dependency initially.** Implement only the required characteristic-two and tiny-prime operations; rationale:
certificate behavior is part of the experiment; rejected: committing to a general CAS before TB2 is measured.

## 7. Risks, failure modes, and open questions

1.  **Monomial blow-up.** Tseitin arithmetization followed by five low-degree factors can exceed memory long before paper-sized parameters.
    The budgeted constructor makes this an explicit negative result. If TB3's next nontrivial circuit exceeds 500,000 monomials, measure
    factored-polynomial DAGs while retaining a separate coefficient-identity checker on reductions.
2.  **Field policy.** The paper uses admissible `q=2^k` with odd `k` (`gt-03-prelim.tex:L662-L667`), the low-degree sampler assumes `m|q`
    (`gt-07-ldt.tex:L31-L37`), and PCP parameters require `m'|q` (`gt-10-answer-reduction.tex:L1406-L1416`). TB0-paper-field/TB2/TB3 retain
    all three. TB0-tiny deliberately violates `m'|q` and `d<q` solely to exhaust all field points. `GF(5)` appears only to distinguish
    subtraction in the generic rewrite. Every relaxation is printed.
3.  **Canonical polynomial versus polynomial function.** At `q=2,d=3`, distinct formal polynomials can induce the same function. TB0-tiny
    claims formal coefficient identity and exhaustive acceptance separately, never uniqueness or Schwartz--Zippel soundness.
4.  **Canonical zero direction.** `def:line` permits `v=0`, while `def:cl-canonical` asks for a linearly independent kernel basis. The
    identity totalization is natural for a singleton but is a `SOURCE_REPAIR`, not a theorem from the text. Exact histograms must reveal
    whether this convention matches all downstream uses.
5.  **Ground-truth typos.** Apply only the two corrections recorded in `CLAUDE.md:L5-L6`: `formula(x,s)` becomes `formula(x,w)` in Tseitin,
    and the arithmetization domain uses the formula's actual variable count. Also flag, without silently repairing, the likely
    `F_q^m`/`F_q^{m'}` mismatch at `gt-10-answer-reduction.tex:L1709-L1715` and the omitted `sigma` in the Figure `decider-pcp` call at
    `L2058-L2062`.
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
9.  **Front-end representativeness.** TB3's always-accept trace is an honest but weak Cook--Levin slice. The next experiment should add a
    two-step equality decider, snapshot its gate/monomial growth, and stop if the sparse design crosses its budget. No asymptotic claim
    follows from TB3.
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
