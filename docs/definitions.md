# Definitions and notation

This file is the single source of truth for symbols used by the design and the
later Julia code.  An entry states the project meaning first and then its
ground-truth anchor.  Project-only IR names cite the paper object they encode;
they do not add a second mathematical definition elsewhere.

## A. Fields, dimensions, and degree

| symbol / code name | authoritative meaning | ground-truth anchor |
|---|---|---|
| `F`, `FieldSpec` | A field and its executable specification. | `gt-10-answer-reduction.tex:L1281-L1287` (`prop:zero-basis`). |
| `F_q`, `GF2k{k}` | The finite field with `q` elements; production instances use `q=2^k`. | `gt-03-prelim.tex:L660-L667` (`def:admissible-size`). |
| `q` | Field size.  In paper-faithful rows it is an admissible `2^k`; the parameter object records every relaxation. | `gt-03-prelim.tex:L662-L667` (`def:admissible-size`); `gt-10-answer-reduction.tex:L1409-L1416` (`def:pcpparams`). |
| `k` | Odd extension degree in `q=2^k`; in the PCP parameter choice, also `d=k`.  It is distinct from a CL marginal index or repetition count, which code names `stage` and `repetitions`. | `gt-10-answer-reduction.tex:L1409-L1417` (`def:pcpparams`). |
| `m` | Number of coordinates in each of the five index blocks and in each `g_i` domain; `M=2^m`. | `gt-03-prelim.tex:L873-L897` (`sec:ld-encoding`); `gt-10-answer-reduction.tex:L1430-L1441` (`def:pcp-proof`). |
| `M` | Boolean assignment-block length `2^m`. | `gt-03-prelim.tex:L873-L884` (`sec:ld-encoding`); `gt-10-answer-reduction.tex:L1492-L1502` (`thm:pcp-decider`). |
| `d` | An upper bound on individual degree; in the paper's PCP parameters, `d=k`. | `gt-03-prelim.tex:L835-L846` (`sec:ld-encoding`); `gt-10-answer-reduction.tex:L1416-L1417` (`def:pcpparams`). |
| `m'`, `m_prime` | Total PCP point dimension `5m+5+s`, partitioned as five `m`-blocks, five signs, and `s` Tseitin variables. | `gt-10-answer-reduction.tex:L1406-L1408` (`def:pcpparams`); `L1435-L1441` (`def:pcp-proof`). |
| `s` | Number of circuit gates/Tseitin variables after padding.  A sampler ambient dimension is always named `seed_dim` in code. | `gt-10-answer-reduction.tex:L1233-L1246` (`prop:explicit-padded-succinct-deciders`); `L1400-L1408` (`def:pcpparams`). |
| `n` | External verifier index.  In `prop:zero-basis` only, the paper also uses `n` for polynomial arity; code uses `arity` there. | `gt-10-answer-reduction.tex:L1378-L1387` (`sec:ar-pcp`); `L1281-L1293` (`prop:zero-basis`). |
| `inddeg(p)` | Maximum exponent of any one variable in the formal polynomial `p`; a coordinatewise vector is retained before taking the maximum. | `gt-03-prelim.tex:L835-L846` (`sec:ld-encoding`). |
| `totaldeg(p)` | Maximum sum of exponents in a supported monomial of `p`. | `gt-03-prelim.tex:L835-L846` (`sec:ld-encoding`). |
| `Variables(blocked)`, `VarLayout` | Ordered variables together with named, disjoint blocks such as `X_1,...,X_5,O,W`. | `gt-10-answer-reduction.tex:L1435-L1441` (`def:pcp-proof`). |
| `Dependencies(p)` | Coordinates, and consequently blocks, appearing with nonzero exponent in the normalized support of `p`. | Project IR for the block restriction required at `gt-10-answer-reduction.tex:L1878-L1885` (`sec:ld-compiler`). |

## B. Low-degree encoding and polynomial certificates

| symbol / code name | authoritative meaning | ground-truth anchor |
|---|---|---|
| `ind_{m,y}(x)`, `indicator_basis(m,y,x)` | `product_{i:y_i=1} x_i * product_{i:y_i=0}(1-x_i)`, the multilinear Boolean-point indicator. | `gt-03-prelim.tex:L873-L881` (`sec:ld-encoding`). |
| `ind_m(x)` | Vector `(ind_{m,y}(x))_{y in {0,1}^m}` in lexicographic `y` order. | `gt-03-prelim.tex:L892-L897` (`eq:low-degree-encoding-definition`). |
| `a` | A length-`M` assignment vector; in the PCP theorem the first padded player answer. | `gt-03-prelim.tex:L882-L889` (`eq:ld-encoding`); `gt-10-answer-reduction.tex:L1492-L1506` (`thm:pcp-decider`). |
| `g_a`, `multilinear_extension(a)` | `sum_y a_y ind_{m,y}`, the multilinear low-degree encoding of `a`. | `gt-03-prelim.tex:L885-L897` (`eq:ld-encoding`, `eq:low-degree-encoding-definition`). |
| `g_i` | For `i=1,...,5`, the multilinear extension of witness block `i`, depending only on `X_i`. | `gt-10-answer-reduction.tex:L1669-L1683` (completeness proof of `thm:pcp-decider`). |
| `H` | A decoding alphabet subset of `F_q`; the Boolean decoder uses `H={0,1}`. | `gt-03-prelim.tex:L917-L924` (`sec:ld-encoding`). |
| `dec_H(g)`, `\mathrm{dec}_H(g)`, `decode_H(g)` | Vector indexed by Boolean `y`, equal to `g(y)` when `g(y) in H` and zero otherwise.  The paper's TeX command renders this as `coded_H`. | `gt-03-prelim.tex:L917-L924` (`sec:ld-encoding`). |
| `zero(z)`, `zero_poly(z)` | `z(1-z)`, which vanishes at `0` and `1`. | `gt-10-answer-reduction.tex:L1281-L1292` (`prop:zero-basis`). |
| `F_arith`, `F_{\mathrm{arith}}`, `formula_arith`, `arith_q(formula)` | Polynomial agreeing with a Boolean formula on the Boolean cube.  For a Tseitin formula its individual degree is at most 2. | `gt-10-answer-reduction.tex:L160-L190` (`def:formula-arithmetization`, `prop:tseitin-arith-degree`). |
| `c_0` | `F_arith(x,o,w) * product_{i=1}^5(g_i(x_i)-o_i)`. | `gt-10-answer-reduction.tex:L1685-L1692` (completeness proof of `thm:pcp-decider`). |
| `c_i`, `1<=i<=m'` | Quotient polynomials satisfying `c_0=sum_i c_i zero(z_i)` when `c_0` vanishes on the Boolean subcube. | `gt-10-answer-reduction.tex:L1281-L1322` (`prop:zero-basis`); `L1709-L1717`. |
| `r`, `remainder` | Multilinear remainder after division by every `zero(z_i)`; a zero-on-subcube certificate requires the formal zero polynomial. | `gt-10-answer-reduction.tex:L1329-L1373` (proof of `prop:zero-basis`). |
| `Poly` | Project sparse formal-polynomial IR: field, blocked variables, structural degree derivation, dependency set, and normalized monomial dictionary. | Encodes polynomials as defined at `gt-03-prelim.tex:L835-L846` (`sec:ld-encoding`). |
| `ZeroOnSubcubeCertificate` | Project certificate containing the variable-by-variable rewrite trace, quotient tuple, coefficient identity, and zero remainder. | Encodes `gt-10-answer-reduction.tex:L1281-L1373` (`prop:zero-basis`). |

## C. Circuits, formulas, and bounded computation

| symbol / code name | authoritative meaning | ground-truth anchor |
|---|---|---|
| `D`, `Decider` | A quoted decision-program description.  Transformations consume the description, not an extensional function value. | `gt-10-answer-reduction.tex:L200-L205` (`Bounded Halting`); `L2077-L2081` (`thm:ar`). |
| `description_size(D)` (paper: `\lvert D\rvert`) | Byte length of the canonical serialized decider description; paper notation is the Turing-machine description length. | `gt-10-answer-reduction.tex:L1461-L1469` (`thm:pcp-decider`); `L2094-L2101` (`thm:ar`). |
| `T` | Fuel/time bound for the bounded decider computation; in answer reduction `T(n)=(2^{lambda n})^mu`. | `gt-10-answer-reduction.tex:L200-L205` (`Bounded Halting`); `L1811-L1823` (`eq:ar-params-1`). |
| `Q` | Upper bound on the input sampler runtime in answer reduction. | `gt-10-answer-reduction.tex:L1817-L1825` (`eq:ar-time-assumption`). |
| `sigma` | Upper bound on, and in the PCP specification the value of, the description size of `D`. | `gt-10-answer-reduction.tex:L236-L244` (`prop:standard-succinct-sat`); `L1461-L1469` (`thm:pcp-decider`). |
| `BoundedTrace` | Project IR recording at most `T` transitions of evaluating quoted `D` on fixed inputs. | Encodes the bounded-halting computation at `gt-10-answer-reduction.tex:L200-L205` and the Cook--Levin input at `L236-L260`. |
| `C`, `Circuit` | Boolean circuit which succinctly decides whether an indexed signed clause belongs to the represented formula. | `gt-10-answer-reduction.tex:L130-L138` (`succinct formula`); `L964-L979` (`decoupled 5SAT description`). |
| `phi_C`, `φ_C` | The decoupled 5SAT formula succinctly described by `C`; it is a relation, not materialized as an exponentially long list. | `gt-10-answer-reduction.tex:L981-L1006` (`Succinct descriptions for bounded deciders`). |
| `X_i` | The `i`th `m`-bit clause-index block, `i=1,...,5`; lowercase `x_i` is a value in `F_q^m`. | `gt-10-answer-reduction.tex:L948-L979` (`eq:5sat` and succinct description). |
| `O`, `o=(o_1,...,o_5)` | Five sign-bit variables/values selecting positive (`1`) or negated (`0`) literals. | `gt-10-answer-reduction.tex:L948-L979` (`eq:5sat`). |
| `W`, `w` | The block of `s` Tseitin auxiliary variables/a value in `F_q^s`. | `gt-10-answer-reduction.tex:L151-L158` (`def:tseitin`); `L1435-L1441` (`def:pcp-proof`). |
| `TseitinFormula` | Formula on circuit inputs and one variable per gate, with accepting inputs exactly those admitting an auxiliary assignment. | `gt-10-answer-reduction.tex:L148-L158` (`def:tseitin`). |
| `arith_q` | Pure transformation from a Boolean formula to its polynomial arithmetization over `F_q`. | `gt-10-answer-reduction.tex:L160-L190` (`def:formula-arithmetization`, `prop:tseitin-arith-degree`). |

## D. Lines and conditionally linear samplers

| symbol / code name | authoritative meaning | ground-truth anchor |
|---|---|---|
| `line(u,v)` | Affine set `{u+tv:t in F_q}`; `v=0` is explicitly permitted and gives a singleton. | `gt-07-ldt.tex:L102-L124` (`def:line`). |
| `pi_{i-1}(v)`, `π_{i-1}(v)`, `prefix_zero(v,i-1)` | Vector obtained by zeroing the first `i-1` coordinates of `v`. | `gt-07-ldt.tex:L73-L90` (`sec:ld-game`); `L230-L237` (`eq:cl-dlnf`). |
| `L_v^lnf`, `L^{\mathrm{lnf}}_v`, `canonical_line_map(v)` | Canonical projection with kernel `span(v)` used to compute a canonical line representative.  Project convention at `v=0` is identity and is marked `SOURCE_REPAIR`. | `gt-03-prelim.tex:L375-L384` (`def:cl-canonical`); `gt-07-ldt.tex:L143-L174` (`def:line-representative`). |
| `chi(s)`, `χ(s)` | The unique axis bucket satisfying `s=(chi(s)-1)q/m+r`, `0<=r<q/m`, under the fixed integer representation of `F_q`; requires `m` to divide `q`. | `gt-07-ldt.tex:L208-L221` (`eq:chi-func`). |
| `Point`, `ALine`, `DLine` | Point, axis-parallel-line, and diagonal-line question types in the classical low-degree game. | `gt-07-ldt.tex:L178-L201` (`sec:ld-game`). |
| `V_pt`, `V_coord`, `V_dir` | Complementary point (`F_q^m`), coordinate (`F_q`), and direction (`F_q^m`) registers. | `gt-07-ldt.tex:L192-L201` (`sec:ld-game`). |
| `V_{i,pt}`, `V_{i,coord}`, `V_{i,dir}` | The corresponding registers for PCP copy `i`; copy 6 is the direct sum of the five input blocks and the auxiliary blocks and has point dimension `m'`. | `gt-10-answer-reduction.tex:L1895-L1917` (`eq:V-pcp`). |
| `L_Point` | Level-1 CL projection `(u,s,v)->(u,0,0)`. | `gt-07-ldt.tex:L203-L207` (`eq:cl-ptf`). |
| `L_ALine` | Level-2 CL map `(u,s,v)->(L^lnf_{e_chi(s)}u,s,0)`. | `gt-07-ldt.tex:L208-L228` (`eq:cl-alnf`, `eq:chi-func`). |
| `L_DLine` | Level-3 CL map using `v'=pi_{chi(s)-1}(v)` and returning `(L^lnf_{v'}u,s,v')`. | `gt-07-ldt.tex:L230-L237` (`eq:cl-dlnf`). |
| `CL{ell,V}` | Project inductive datatype for an `ell`-level conditionally linear function on `V`: zero at level 0; a linear first stage plus a value-indexed level-`ell-1` continuation thereafter. | `gt-04-cl.tex:L35-L57` (`def:cl-func`). |
| `mu_{L,R}` | Distribution of `(L(z),R(z))` for one uniformly random shared seed `z`. | `gt-04-cl.tex:L132-L138` (`def:cl-dist`). |
| `marginal_k(L)` | First `k` adaptive stages, with their factor spaces and linear maps. | `gt-04-cl.tex:L150-L178` (`lem:cl-kth`). |
| `concatenate(L,R)` | Conditional concatenation on complementary spaces, with level equal to the sum of levels. | `gt-04-cl.tex:L282-L313` (`lem:cl-concat`). |
| `direct_sum(L_i)` | Register-wise sum of CL functions, with level the maximum input level. | `gt-04-cl.tex:L315-L327` (`lem:cl-func-prod`). |
| `TypeSet`, `TypeGraph` | Finite question labels and the undirected graph whose oriented edges are sampled uniformly before the CL maps are applied. | `gt-06-types.tex:L57-L93` (`Typed conditionally linear functions/distributions`). |
| `Sampler` | Executable access to ambient dimension, marginals, conditional linear maps, and factor spaces for the pair of CL functions. | `gt-04-cl.tex:L553-L601` (`def:sampler`). |
| `TypedSampler` | A type-graph-indexed family of left/right CL maps sharing one ambient space and common maximum level. | `gt-06-types.tex:L95-L151` (`def:typed-sampler`, `def:typed-sampler-sample`). |
| `D^ld`, `ld_decider` | Classical simultaneous low-degree decider: same-type consistency plus axis-line/point and diagonal-line/point checks. | `gt-07-ldt.tex:L320-L392` (`fig:ld-decider`). |
| `delta_ld(epsilon,q,m,d,kappa)`, `δ_ld` | `a(dm kappa)^a(epsilon^b+q^{-b}+2^{-bmd})`, with universal `a>=1`, `0<b<=1`; a cited quantum enforcement error, not a computed test result. | `gt-07-ldt.tex:L413-L440` (`lem:ld-soundness`). |
| `kappa`, `ldc` | Number of polynomials simultaneously tested by `D^ld`; code uses `kappa` to avoid collision with the extension degree `k`. | `gt-07-ldt.tex:L397-L407` (`def:ld-meas`); `L413-L440` (`lem:ld-soundness`). |

## E. PCP proof, view, and answer reduction

| symbol / code name | authoritative meaning | ground-truth anchor |
|---|---|---|
| `PCPParams`, `(q,m,d,m',s)` | Parameter tuple computed from `(n,T,Q,sigma,gamma)`, including odd `k`, two soundness inequalities, and `m'` dividing `q`. | `gt-10-answer-reduction.tex:L1396-L1422` (`def:pcpparams`). |
| `Pi`, `Π`, `PCPProof` | Tuple `(g_1,...,g_5,c_0,...,c_{m'})` of evaluation tables/formal low-degree polynomials. | `gt-10-answer-reduction.tex:L1426-L1442` (`def:pcp-proof`). |
| `z=(x_1,...,x_5,o,w)` | A point of `F_q^{m'}` in the fixed PCP block decomposition. | `gt-10-answer-reduction.tex:L1435-L1447` (`def:pcp-proof`, `def:pcp-eval`). |
| `ev_z(Pi)`, `\mathrm{ev}_z(Π)`, `pcp_eval(Pi,z)` | PCP view `(alpha_1,...,alpha_5,beta_0,...,beta_{m'})` at `z`. | `gt-10-answer-reduction.tex:L1444-L1453` (`def:pcp-eval`). |
| `alpha_i`, `α_i` | `g_i(x_i)`, the `i`th block-polynomial evaluation. | `gt-10-answer-reduction.tex:L1444-L1453` (`def:pcp-eval`). |
| `beta_j`, `β_j` | `c_j(z)`, including `beta_0=c_0(z)`. | `gt-10-answer-reduction.tex:L1444-L1453` (`def:pcp-eval`). |
| `pcpverifier`, `pcp_verifier` | Local verifier performing the formula test and zero-on-subcube test after reconstructing the succinct circuit and its arithmetization. | `gt-10-answer-reduction.tex:L1548-L1585` (`fig:pcpverifier`). |
| `p_soundness` | Low-degree-PCP soundness threshold `1/2`; the premise is strict acceptance probability `>1/2`. | `gt-10-answer-reduction.tex:L1509-L1533` (`thm:pcp-decider`). |
| `V^pcp` | Ambient direct sum for the six-copy PCP sampler. | `gt-10-answer-reduction.tex:L1895-L1913` (`eq:V-pcp`). |
| `Type^pcp` | Eighteen types `{Point_i,ALine_i,DLine_i : i=1,...,6}` with complete type graph. | `gt-10-answer-reduction.tex:L1887-L1894` (`sec:ld-compiler`). |
| `Type^ora` | Oracularization roles `{oracle,alice,bob}` with complete graph including loops. | `gt-09-oracularization.tex:L36-L59` (`sec:orac-def`). |
| `L^alice`, `L^bob` | Original sampler's left and right CL functions; the oracle receives their common seed and can compute both images. | `gt-09-oracularization.tex:L49-L67` (`sec:orac-def`). |
| `D_AR`, `answer_reduced_decider` | Typed decider with global consistency, input consistency, input low-degree, proof-encoding, and game/PCP checks. | `gt-10-answer-reduction.tex:L1973-L2071` (`fig:decider-pcp`). |

## F. Verifier transformations and symbolic bounds

| symbol / code name | authoritative meaning | ground-truth anchor |
|---|---|---|
| `ell`, `Levels` | Number of adaptive CL stages of a sampler. | `gt-04-cl.tex:L35-L57` (`def:cl-func`). |
| `lambda`, `λ` | Bounding/compression parameter; a `lambda`-bounded verifier has description length at most `lambda` and runtimes at most `n^lambda`. | `gt-12-compression.tex:L9-L24` (`sec:compression`). |
| `mu`, `μ` | Universal answer-reduction exponent used in `T(n)=(2^{lambda n})^mu`; the same parameter sets the question-length expression `(lambda n)^mu`. | `gt-10-answer-reduction.tex:L1811-L1825` (`eq:ar-params-1`); `gt-12-compression.tex:L64-L73` (`fig:compress` setup). |
| `gamma`, `γ` | PCP/answer-reduction soundness parameter controlling `q` and the error exponent. | `gt-10-answer-reduction.tex:L1378-L1392` (`sec:ar-pcp`); `L2077-L2102` (`thm:ar`). |
| `tau`, `τ` | Anchored parallel-repetition parameter used by `Repeat` inside `Compress`. | `gt-11-parallel-repetition.tex:L229-L258` (`thm:repetition`); `gt-12-compression.tex:L68-L73`. |
| `epsilon` | Failure probability in theorem premises; always an exact/symbolic real parameter, not a sampled estimate. | `gt-07-ldt.tex:L413-L440` (`lem:ld-soundness`); `gt-10-answer-reduction.tex:L2097-L2114` (`thm:ar`). |
| `delta(epsilon,n)` | Directed soundness-loss function belonging to a particular transformation contract.  It must retain the source theorem and is never conflated with `delta_ld`. | `gt-08-introspection.tex:L798-L815` (`thm:introspection`); `gt-10-answer-reduction.tex:L2097-L2114` (`thm:ar`). |
| `Verifier[QuestionLength,AnswerLength,Runtime,Gap,Levels]` | Project IR for a sampler/decider description and its symbolic contracts. | Encodes the normal-form verifier transformed at `gt-10-answer-reduction.tex:L2077-L2116` (`thm:ar`). |
| `Checked{T,C}` | Project pair of an IR term and inspectable evidence.  Evidence grade may be CONSTRUCTED, CHECKED, CITED, ASSUMED, or SOURCE_REPAIR. | Motivated by the executable/cited split between `gt-10-answer-reduction.tex:L1542-L1786` and `L2077-L2116`. |
| `Introspect` | Description transformation with the exact contract of the introspection theorem; a CITED stub in this campaign. | `gt-08-introspection.tex:L784-L817` (`thm:introspection`). |
| `AnswerReduce` | Description transformation implemented locally only through the PCP/typed-decider layer; full quantum contract remains cited. | `gt-10-answer-reduction.tex:L2077-L2116` (`thm:ar`). |
| `Repeat` | Anchoring and parallel-repetition transformation; a CITED stub in this campaign. | `gt-11-parallel-repetition.tex:L229-L258` (`thm:repetition`). |
| `Compress` | `Repeat o AnswerReduce o Introspect`, with introspection level 9 and universal `mu,gamma,tau`. | `gt-12-compression.tex:L57-L98` (`fig:compress`). |
| `Y`, `YCode` | Description-level fixed-point combinator used to express self-reference without identifying code with a closure. | Project syntax for the fixed-point equation in `handoff.md:L21-L39`; compression consumes descriptions at `gt-12-compression.tex:L26-L39`. |
| `Psi_{M,L}` | Quoted functional whose fixed point accepts if machine `M` halts within `n`, otherwise invokes the compressed verifier built from its own quoted description and `S_L`. | Mandate equation in `handoff.md:L21-L35`; paper compression interface at `gt-12-compression.tex:L26-L39`. |
| `D_{M,L}` | Quoted fixed-point decider `Y Psi_{M,L}`. | Mandate equation in `handoff.md:L31-L39`; corresponding compression machinery `gt-12-compression.tex:L26-L53`. |
| `S_L` | Sampler family paired with the self-referential decider in the halting construction; opaque quoted description at this design stage. | Mandate `handoff.md:L23-L35`; sampler-independence theorem `gt-12-compression.tex:L108-L118` (`lem:compress-independent-samplers`). |
| `M` (machine context) | The Turing machine whose halting is tested.  Code calls it `machine` to avoid collision with assignment length `M=2^m`. | Mandate `handoff.md:L21-L35`; bounded-halting description `gt-10-answer-reduction.tex:L200-L205`. |

## G. Evidence grades

| printed grade | meaning |
|---|---|
| `CONSTRUCTED` | The datatype constructor makes the invariant unavoidable. |
| `CHECKED` | A deterministic checker replayed the attached certificate against exact IR hashes. |
| `CITED` | The statement is imported from the named ground-truth theorem/lemma and is not locally checked. |
| `ASSUMED` | The statement is an explicit hypothesis without a ground-truth discharge. |
| `SOURCE_REPAIR` | A totalizing convention or typo repair needed to make the executable interpretation definite. |

Only `CONSTRUCTED` and `CHECKED` count as machine evidence.  The other grades
remain visible under certificate composition.
