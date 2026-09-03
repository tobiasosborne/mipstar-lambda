# Brief 01 — DESIGN of the symbolic term language and Julia architecture

You are the proposer (gpt-5.6-sol, xhigh). Work fully autonomously; do not ask questions. Your lane: create `docs/DESIGN.md` and `docs/definitions.md` ONLY. Do not create Julia files yet (that is a later brief), except you MAY put illustrative Julia signatures inside DESIGN.md.

## Read order (all paths relative to repo root `/home/tobias/Projects/discussions`)
1. `CLAUDE.md` (method + ground-truth map + known typos)
2. `handoff.md` (the mandate; every "Representation requirements" and "Deliverables" item is binding)
3. `claims/CLAIMS.md` (what will be claimed; your design must make C1–C4, C6 machine-checkable and C5 derivable as a derivation tree)
4. Ground truth, in this order, citing line ranges when you rely on them:
   - `ground-truth/gt-03-prelim.tex` — search `sec:ld-encoding` (low-degree code, ind_{m,y}, g_a, dec_H, Schwartz–Zippel)
   - `ground-truth/gt-04-cl.tex` — `def:cl-func`, `def:cl-dist`, `lem:cl-kth`, `lem:cl-concat`, and the sampler subsection (`def:sampler` region)
   - `ground-truth/gt-07-ldt.tex` — `sec:ld-game`: def:line, canonical representative L^lnf_v (needs `def:cl-canonical` from gt-04), eq:cl-ptf / eq:cl-alnf / eq:cl-dlnf, eq:chi-func, lem:alnf, lem:dlnf, fig:ld-decider, lem:ld-soundness (statement only), lem:ld-complexity
   - `ground-truth/gt-10-answer-reduction.tex` — def:tseitin, def:formula-arithmetization, prop:tseitin-arith-degree, prop:standard-succinct-sat (statement), sec:succinct-deciders (skim; note decoupled 5SAT clause form a^{o1}∨b^{o2}∨w1^{o3}∨w2^{o4}∨w3^{o5}), prop:explicit-padded-succinct-deciders (statement), prop:zero-basis (full proof), def:pcpparams, def:pcp-proof, def:pcp-eval, thm:pcp-decider (full statement + full proof incl. fig:pcpverifier), sec:ld-compiler (sampler: type set, V^pcp registers, L_{Point_i}/L_{ALine_i}/L_{DLine_i}; fig:decider-pcp the decider; thm:ar statement)
   - `ground-truth/gt-12-compression.tex` — fig:compress, thm:compression statement, lem:compress-independent-samplers
   - `ground-truth/gt-06-types.tex` — typed samplers and detyping (skim; only to get the typed-CL notion right)
   - `ground-truth/gt-09-oracularization.tex` — skim: what the oracularized sampler/decider is (types alice/bob/oracle, L^alice, L^bob), needed for fig:decider-pcp step 5

## North star (from the user)
"An amazingly elegant and compelling reformulation of the hard part of the MIP*=RE paper in lambda calculus as implemented by Julia." The authors say Compress is the hardest part; the handoff isolates answer reduction / the bespoke low-degree PCP (Sec. 10.4–10.5) as the crux. The central hypothesis is to be TESTED not assumed: homoiconicity may remove universal-machine/source-description bookkeeping and expose answer reduction as a small composition of symbolic transformations, while the low-degree and operator-algebraic soundness estimates remain unchanged.

## What DESIGN.md must contain (numbered sections, in this order)

### 1. The term language (mathematical description — handoff deliverable 1)
An explicit symbolic intermediate language (NOT raw `Expr`, NOT hidden in macros). Give an inductive grammar for each of the following sorts, with the invariants each carries as *data*, and say for each invariant whether it is (i) true by construction (datatype), (ii) computed and certified (derivation tree), or (iii) only asserted.
- **Program / description sort** (the "lambda" layer): a minimal quoted language for deciders: variables, λ, application, a fixed-point combinator, conditionals, bounded primitives, and `quote`/`eval`/`specialize`. Distinguish, as the handoff demands: closure vs quoted syntax vs compiled circuit vs universal evaluator vs specialization. Explain where the compression machine consumes *descriptions* (|D|, the size) and never extensional values. Show the Halting-problem fixed point D_{M,L} = Y Ψ_{M,L} as a term in this language, and explain what `Compress` must do with the *quoted* body. Keep this layer small; it is not the crux, but it is the bridge to the crux (Cook–Levin consumes a description + fuel T and produces a circuit).
- **Circuit / formula sort**: Boolean circuits with named input blocks; succinct decoupled 5SAT descriptions (5 m-bit blocks + 5 sign bits); Tseitin formula; the arithmetization map `arith_q`. Track: number of gates s, block structure, "each variable occurs ≤2 times ⇒ individual degree ≤2".
- **Polynomial sort** `Poly[F_q, Variables(blocked), IndividualDegreeBound, Dependencies]`: with BOTH a structural bound (derivation tree from the construction: e.g. `Product(deg bounds add)`, `MultilinearExtension ⇒ 1`, `Arith(Tseitin) ⇒ 2`) AND an actual support-computed degree, so that agreement is a red-capable test (claim C3). Representation: sparse monomial dictionary over a generic field element type; explain the blow-up risk for c₀ on 16–32 variables and how the chosen instance sizes avoid it (see §5).
- **Zero-on-subcube certificate**: prop:zero-basis as a REWRITE. Hint (verify it, do not take it for granted): dividing by zero(zᵢ)=zᵢ(1−zᵢ) is the rewrite zᵢ^e → zᵢ^{e−1} − zᵢ^{e−2}·zero(zᵢ) (e ≥ 2) applied variable by variable; the collected quotients are c₁..c_{m'}; the multilinear remainder r must be the zero polynomial. The certificate is the rewrite trace; its checker is coefficient-wise equality c₀ = Σ cᵢ zero(zᵢ) + r and r ≡ 0. State the individual-degree bookkeeping (paper: each cᵢ has ind. degree ≤ d; check the paper's remark "degree of x_{k+1} in c_{k+1} at most d−2" and decide what you can certify).
- **Sampler sort** `Sampler[DistributionClass, AdaptivityLevels]`: CL functions as an inductive datatype mirroring def:cl-func exactly (level-0 zero; level-ℓ = register subspace V₁ + linear map L₁ + a *function* v ↦ (ℓ−1)-level CL on V_{>1}), so that "is conditionally linear, ℓ-level" is true by construction, with `level`, `apply`, `marginal_k`, concatenation (lem:cl-concat), direct sum/product, and typed samplers (type graph). Give L_Point, L_ALine, L_DLine in this datatype, including the canonical linear map L^lnf_v (def:cl-canonical) and χ(s). Say how the six-copy PCP sampler and the product with the oracularized sampler are formed, and what "3-level" means concretely.
- **Verifier sort** `Verifier[QuestionLength, AnswerLength, Runtime, Gap, Levels]` with `Checked{T,C}` (term + certificate/derivation tree). Contracts for Introspect, AnswerReduce, Repeat as *stated* contracts (from thm:introspection/thm:ar/thm:repetition/thm:compression) — implemented only for AnswerReduce at the PCP level in this campaign; the others are stubs whose certificate says CITED(paper theorem) and nothing more. Never let a stub look like a proof.

### 2. The combinator algebra
Signatures (Julia, but language-agnostic in meaning) for every transformation in the pipeline
`D ↦ bounded trace ↦ succinct 3SAT ↦ succinct decoupled 5SAT ↦ arithmetization ↦ low-degree PCP ↦ D_AR`
plus `Compress = Repeat ∘ AnswerReduce ∘ Introspect`. For each: input sort, output sort, what invariants it *propagates* and how the derivation tree is extended. Every function is a pure function on IR values. Macros, if any, are surface syntax only.

### 3. Invariant tracking and the derivation tree
The `Checked{T,C}` design: the certificate datatype, how bounds compose (degree, field size, description size, runtime as symbolic polynomial bounds in the paper's parameters, gap), how to *print* a transformation trace (handoff deliverable 6), and how the trace is inspected in tests.

### 4. Soundness — what is and is not claimed
Separate exactly as the handoff demands: (1) soundness assuming low-degree proofs [derivation tree with named Schwartz–Zippel steps and the two degree bounds (2+5d)m' and (2+d)m']; (2) enforcement via low-degree tests [CITED lem:ld-soundness; the δ_ld formula carried as data]; (3) the Schwartz–Zippel step [a lemma object with its hypothesis (total degree bound, field size) recorded]; (4) the quantum consistency/rigidity argument [CITED only]. Design the certificate so that a critic can see at a glance which leaves are CITED and which are CHECKED.

### 5. Tracer-bullet ladder (MANDATORY — user directive: "smoke test on progressively more complex tracer bullets")
Define an ordered ladder of thin end-to-end slices. Each rung = concrete instance + the exact smoke test (what runs, what is asserted, what is printed) + at least one mutation that must turn the test red. Rungs must be individually implementable in one focused session and each must run in < 60 s on a laptop. Proposed shape (refine, do not merely accept):
- **TB0** GF(2^k) arithmetic (k small AND k=13) + multilinear extension g_a for m=1 and m=2 + rewrite-certificate on a 2-variable polynomial + `pcpverifier` on a ONE-clause "circuit" (s minimal) with m=1: exhaustive acceptance over all z ∈ F_q^{m'} for tiny q, sampled for q=2^13. Prints degree/dependency report and the transformation trace.
- **TB1** the classical low-degree test sampler: CL datatype, L_Point/L_ALine/L_DLine, exact histogram check of lem:alnf/lem:dlnf on small (q,m) (m | q!), D^ld on honest strategies from a low-degree polynomial: accept w.p. 1; mutation: a non-low-degree g fails an axis-line test somewhere.
- **TB2** the full typed answer-reduced decider fig:decider-pcp on the toy (product with a trivial oracularized sampler), honest strategy from Π accepted at all sampled questions; mutations: tamper one polynomial → some check rejects.
- **TB3** front end: a quoted decider program (tiny language) + fuel T → bounded trace → circuit → decoupled 5SAT (your own small, honest Cook–Levin; faithfulness to prop:explicit-padded-succinct-deciders parameters is NOT required, but the block/clause *shape* is) → feeds TB0/TB2.
- **TB4** Compress skeleton with contracts and the Y-combinator halting verifier as a quoted term; stubs clearly CITED.
- Also: the midpoint toy (claim C6/N1) as a separate, tiny rung (exact optimal cheating probability by dynamic programming for n ≤ 8) — say where it fits.
For each rung state the instance parameters (q, m, s, m'), whether m' | q holds, and the *expected sizes* (number of monomials of c₀; time). Flag any rung where you are not confident of feasibility and say what to measure first.

### 6. Package layout and test discipline
Module name, file layout (`src/`, `test/`, `test/mutations/`), zero non-stdlib dependencies unless you argue one is decisive. Red/green TDD: tests are written first per rung. Mutation tests live in `test/mutations/` as scripts that apply a specific textual/semantic mutation on a COPY and assert nonzero exit. No bare `@assert` in checkers.

### 7. Risks, failure modes, open questions
Including: monomial blow-up; GF(2^k) vs prime-field choice (paper: q=2^k, k odd, m | q, m' | q — what do you keep for the toy and what do you deliberately relax, each relaxation flagged); the paper's typos; the oracularization dependency in fig:decider-pcp; where the lambda layer genuinely simplifies bookkeeping and where it demonstrably does not (this is the hypothesis under test — be honest and specific).

### 8. Assessment of the structural hypothesis (claim C7) — preliminary
Two paragraphs max: what closure laws of CL distributions the paper actually uses (products, direct sums, concatenation, typed graphs), and which specific PCP operations (affine restriction, random-point identity test, product) are visibly CL-preserving in your datatype. No conclusions beyond what the datatype makes visible.

## `docs/definitions.md`
Single-source glossary: every symbol used in DESIGN.md and later code (q, m, d, m', s, M, ind_{m,y}, g_a, dec_H, zero, χ, π_{i−1}, L^lnf_v, Point/ALine/DLine, V_{i,pt}/V_{i,coord}/V_{i,dir}, Π, ev_z, α_i, β_j, F_arith, φ_C, T, Q, λ, μ, γ, τ, δ_ld …) with the ground-truth citation (file + label). Code will cite these names; nothing else may redefine them.

## Style
Terse, mathematical, addressable (numbered sections and numbered design decisions DD-1, DD-2, … each with a one-line rationale and the alternative rejected). No introductory exposition of MIP*=RE. Length target: DESIGN.md 400–800 lines. Write the files; your final message should be a 10-line summary plus the list of decisions you are least sure of.
