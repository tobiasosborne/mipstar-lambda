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
| `d` | The claimed upper bound on individual degree; it is never the measured degree. In the paper's PCP parameters, `d=k`. | `gt-03-prelim.tex:L835-L846` (`sec:ld-encoding`); `gt-10-answer-reduction.tex:L1416-L1417` (`def:pcpparams`). |
| `m'`, `m_prime` | Total PCP point dimension `5m+5+s`, partitioned as five `m`-blocks, five signs, and `s` Tseitin variables. | `gt-10-answer-reduction.tex:L1406-L1408` (`def:pcpparams`); `L1435-L1441` (`def:pcp-proof`). |
| `s` | Number of circuit gates/Tseitin variables after padding.  A sampler ambient dimension is always named `seed_dim` in code. | `gt-10-answer-reduction.tex:L1233-L1246` (`prop:explicit-padded-succinct-deciders`); `L1400-L1408` (`def:pcpparams`). |
| `n` | External verifier index. In `Psi_{M,L}`, its bound occurrence has term sort `P{Nat}`. In `prop:zero-basis` only, the paper also uses `n` for polynomial arity; code uses `arity` there. | `gt-10-answer-reduction.tex:L1378-L1387` (`sec:ar-pcp`); `L1281-L1293` (`prop:zero-basis`). |
| `inddeg(p)` | Maximum exponent of any one variable in the formal polynomial `p`; a coordinatewise vector is retained before taking the maximum. | `gt-03-prelim.tex:L835-L846` (`sec:ld-encoding`). |
| `totaldeg(p)` | Maximum sum of exponents in a supported monomial of `p`. | `gt-03-prelim.tex:L835-L846` (`sec:ld-encoding`). |
| `Variables(blocked)`, `VarLayout` | Ordered variables together with named, disjoint blocks such as `X_1,...,X_5,O,W`. | `gt-10-answer-reduction.tex:L1435-L1441` (`def:pcp-proof`). |
| `Dependencies(p)` | Coordinates, and consequently blocks, appearing with nonzero exponent in the normalized support of `p`. | Project IR for the block restriction required at `gt-10-answer-reduction.tex:L1878-L1885` (`sec:ld-compiler`). |
| `occurrences(F)`, `occ_v(F)` | Number of leaf occurrences of each variable in the Boolean formula tree; `deg_v(arith_q(F))<=occ_v(F)`. | Structural replacement for the disputed claim at `gt-10-answer-reduction.tex:L173-L191` (`prop:tseitin-arith-degree`); finding F1/C8. |
| `fanout(v)`, `fanout_max` | Number of circuit gates that directly consume wire/input `v`, and its maximum over circuit wires/inputs. In NW19 Tseitin, input occurrence is `2 fanout(v)` and gate-wire occurrence is `2+2 fanout(v)`, plus one for the output literal. | `ground-truth/nw19/nw19-tseitin-arith.tex` (`def:Tseitin transformation`); finding F1/F2. |
| `MonomialBudget` | Limit on the candidate count of one sparse multiplication, computed as `card(partial support)*card(next factor support)` before coefficient merging; expansion returns `ExpansionRefused` before a single product exceeds it. It is not a cumulative-work counter. | Project safety policy for the formal polynomial carrier. |
| `expected_support(p)` | A pre-normalization upper estimate on candidate monomials for a named product, never the measured normalized support. | Project expansion-budget diagnostic. |
| `deg_F` | Maximum coordinate of the checked occurrence bound for `F_arith`; TB0 has `deg_F=6`. | Finding F1/C8 and `DESIGN.md` §5. |
| `rho`, `b_rho`, `S_j` | Declared primitive field element, TB0's printed off-cube base point, and its 16 named one-coordinate lines. | Project TB0 fixture; not paper notation. |
| `P_exponent_range` | Predicate `d<=q-1`; when true, formal exponents lie in the paper's range `{0,...,q-1}`. | `gt-03-prelim.tex:L836-L840` (polynomial definition). |

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
| `F_arith`, `F_{\mathrm{arith}}`, `formula_arith`, `arith_q(formula)` | Polynomial obtained by arithmetizing along the Boolean formula tree and agreeing on the Boolean cube. Its checked coordinate bound is the formula occurrence vector; the source's Tseitin bound 2 is retained as `SOURCE_REPAIR(C8)`. | `gt-10-answer-reduction.tex:L160-L190` (`def:formula-arithmetization`, disputed `prop:tseitin-arith-degree`). |
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
| `Q_len`, paper `Q`/`\qlen` | Question-length bound supplied to `pcpparams` and `pcpverifier`, with `Q_len<=T`. | `gt-10-answer-reduction.tex:L1379-L1383`, `L1397-L1399` (`def:pcpparams`). |
| `Q_time`, paper `Q` in `eq:ar-time-assumption` | Upper bound on input-sampler runtime. Outside answer reduction it need not equal `Q_len`; `eq:ar-params-1` sets both to `(lambda n)^mu`. | `gt-10-answer-reduction.tex:L1811-L1825` (`eq:ar-params-1`, `eq:ar-time-assumption`). |
| `sigma` | Upper bound on, and in the PCP specification the value of, the description size of `D`. | `gt-10-answer-reduction.tex:L236-L244` (`prop:standard-succinct-sat`); `L1461-L1469` (`thm:pcp-decider`). |
| `BoundedTrace` | Project IR recording at most `T` transitions of evaluating quoted `D` on fixed inputs. | Encodes the bounded-halting computation at `gt-10-answer-reduction.tex:L200-L205` and the Cook--Levin input at `L236-L260`. |
| `C`, `Circuit` | Boolean circuit which succinctly decides whether an indexed signed clause belongs to the represented formula. | `gt-10-answer-reduction.tex:L130-L138` (`succinct formula`); `L964-L979` (`decoupled 5SAT description`). |
| `phi_C`, `φ_C` | The decoupled 5SAT formula succinctly described by `C`; it is a relation, not materialized as an exponentially long list. | `gt-10-answer-reduction.tex:L981-L1006` (`Succinct descriptions for bounded deciders`). |
| `X_i` | The `i`th `m`-bit clause-index block, `i=1,...,5`; lowercase `x_i` is a value in `F_q^m`. | `gt-10-answer-reduction.tex:L948-L979` (`eq:5sat` and succinct description). |
| `O`, `o=(o_1,...,o_5)` | Five sign-bit variables/values selecting positive (`1`) or negated (`0`) literals. | `gt-10-answer-reduction.tex:L948-L979` (`eq:5sat`). |
| `W`, `w` | The block of `s` Tseitin auxiliary variables/a value in `F_q^s`. | `gt-10-answer-reduction.tex:L151-L158` (`def:tseitin`); `L1435-L1441` (`def:pcp-proof`). |
| `w_out` | Tseitin variable for the circuit's output gate, conjoined as a literal to repair NW19's omitted acceptance constraint. | Finding F2; `ground-truth/nw19/nw19-tseitin-arith.tex` (`def:Tseitin transformation`). |
| `TseitinFormula` | NW19 gate-equivalence formula on circuit inputs and one variable per gate, conjoined with the output literal so accepting inputs are exactly those admitting an auxiliary assignment. | `gt-10-answer-reduction.tex:L148-L158` (`def:tseitin`); finding F2. |
| `arith_q` | Pure transformation from a Boolean formula to its polynomial arithmetization over `F_q`. | `gt-10-answer-reduction.tex:L160-L190` (`def:formula-arithmetization`, `prop:tseitin-arith-degree`). |

## D. Lines and conditionally linear samplers

| symbol / code name | authoritative meaning | ground-truth anchor |
|---|---|---|
| `line(u,v)` | Affine set `{u+tv:t in F_q}`; `v=0` is explicitly permitted and gives a singleton. | `gt-07-ldt.tex:L102-L124` (`def:line`). |
| `pi_{i-1}(v)`, `π_{i-1}(v)`, `prefix_zero(v,i-1)` | Vector obtained by zeroing the first `i-1` coordinates of `v`. | `gt-07-ldt.tex:L73-L90` (`sec:ld-game`); `L230-L237` (`eq:cl-dlnf`). |
| `L_v^lnf`, `L^{\mathrm{lnf}}_v`, `canonical_line_map(v)` | Canonical projection with kernel `span(v)` used to compute a canonical line representative.  Project convention at `v=0` is identity and is marked `SOURCE_REPAIR`. | `gt-03-prelim.tex:L375-L384` (`def:cl-canonical`); `gt-07-ldt.tex:L143-L174` (`def:line-representative`). |
| `chi(s_coord)`, `χ(s_coord)` | The unique axis bucket satisfying `s_coord=(chi(s_coord)-1)q/m+r`, `0<=r<q/m`, under the fixed integer representation of `F_q`; requires `m` to divide `q`. | `gt-07-ldt.tex:L208-L221` (`eq:chi-func`). |
| `Point`, `ALine`, `DLine` | Point, axis-parallel-line, and diagonal-line question types in the classical low-degree game. | `gt-07-ldt.tex:L178-L201` (`sec:ld-game`). |
| `V_pt`, `V_coord`, `V_dir` | Complementary point (`F_q^m`), coordinate (`F_q`), and direction (`F_q^m`) registers. | `gt-07-ldt.tex:L192-L201` (`sec:ld-game`). |
| `V_{i,pt}`, `V_{i,coord}`, `V_{i,dir}` | PCP-copy registers. Copy 6 has point/direction dimension `m'` and coordinate dimension 6 by `eq:V-pcp`; scalar `table:tpcp` conflicts, so the IR marks its convention that `chi` reads `V_aux,coord` as `SOURCE_REPAIR`. | `gt-10-answer-reduction.tex:L1895-L1917` (`eq:V-pcp`); `gt-10-answer-reduction.tex:L1987-L1998` (`table:tpcp`). |
| `L_Point` | Level-1 CL projection `(u,s_coord,v)->(u,0,0)`. | `gt-07-ldt.tex:L203-L207` (`eq:cl-ptf`). |
| `L_ALine` | Level-2 CL map `(u,s_coord,v)->(L^lnf_{e_chi(s_coord)}u,s_coord,0)`. | `gt-07-ldt.tex:L208-L228` (`eq:cl-alnf`, `eq:chi-func`). |
| `L_DLine` | Level-3 CL map using `v'=pi_{chi(s_coord)-1}(v)` and returning `(L^lnf_{v'}u,s_coord,v')`. | `gt-07-ldt.tex:L230-L237` (`eq:cl-dlnf`). |
| `CL{ell,V}` | Project inductive datatype for an `ell`-level conditionally linear function on `V`: zero at level 0; a linear first stage plus a value-indexed level-`ell-1` continuation thereafter. | `gt-04-cl.tex:L35-L57` (`def:cl-func`). |
| `mu_{L,R}` | Distribution of `(L(z),R(z))` for one uniformly random shared seed `z`. | `gt-04-cl.tex:L132-L138` (`def:cl-dist`). |
| `marginal_k(L)` | First `k` adaptive stages, with their factor spaces and linear maps. | `gt-04-cl.tex:L150-L178` (`lem:cl-kth`). |
| `concatenate(L,R)` | Conditional concatenation on complementary spaces, with level equal to the sum of levels. | `gt-04-cl.tex:L282-L313` (`lem:cl-concat`). |
| `direct_sum(L_i)` | Register-wise sum of CL functions, with level the maximum input level. | `gt-04-cl.tex:L315-L327` (`lem:cl-func-prod`). |
| `TypeSet`, `TypeGraph` | Finite question labels and the undirected graph whose oriented edges are sampled uniformly before the CL maps are applied. | `gt-06-types.tex:L57-L93` (`Typed conditionally linear functions/distributions`). |
| `Sampler` | Executable access to ambient dimension, marginals, conditional linear maps, and factor spaces for the pair of CL functions; §9 represents this interface intensionally as `SamplerDescription`. | `gt-04-cl.tex:L553-L601` (`def:sampler`). |
| `TypedSampler` | A type-graph-indexed family of left/right CL maps sharing one ambient space and common maximum level. | `gt-06-types.tex:L95-L151` (`def:typed-sampler`, `def:typed-sampler-sample`). |
| `D^ld`, `ld_decider` | Classical simultaneous low-degree decider: same-type consistency plus axis-line/point and diagonal-line/point checks. | `gt-07-ldt.tex:L320-L392` (`fig:ld-decider`). |
| `delta_ld(epsilon,q,m,d,kappa)`, `δ_ld` | `a(dm kappa)^a(epsilon^b+q^{-b}+2^{-bmd})`, with universal `a>=1`, `0<b<=1`; a cited quantum enforcement error, not a computed test result. | `gt-07-ldt.tex:L413-L440` (`lem:ld-soundness`). |
| `kappa`, `ldc` | Number of polynomials simultaneously tested by `D^ld`; code uses `kappa` to avoid collision with the extension degree `k`. | `gt-07-ldt.tex:L397-L407` (`def:ld-meas`); `L413-L440` (`lem:ld-soundness`). |

## E. PCP proof, view, and answer reduction

| symbol / code name | authoritative meaning | ground-truth anchor |
|---|---|---|
| `PCPParams`, `(q,m,d,m',s)` | Tuple computed from `(n,T,Q_len,sigma,gamma)`. Its six named obligations are `P_shape`, `P_growth`, `P_formula_paper`, `P_tail`, `P_divisibility`, and `P_degree`; unknown universal constants may leave a proposed concrete tuple unresolved. | `gt-10-answer-reduction.tex:L1396-L1422` (`def:pcpparams`). |
| `ParameterPredicateResult`, `PASS`, `FAIL`, `NOT_EVALUABLE` | For a predicate containing unknown universal constants, `PASS` means it holds for every admissible choice, `FAIL` means it fails for every admissible choice, and `NOT_EVALUABLE` means neither conclusion follows over the whole admissible range. This rule applies in particular to predicates 2 (`P_growth`) and 4 (`P_tail`): neither has a blanket result, and interval bounds may determine either `PASS` or `FAIL`. | Project evaluation policy for the universal constants constrained in `gt-10-answer-reduction.tex:L1402-L1403`, `L1409-L1414` (`def:pcpparams`). |
| `P_shape` | `m'=5m+5+s` and `m'` is a power of two. | `gt-10-answer-reduction.tex:L1404-L1408` (`def:pcpparams`, item 1). |
| `P_growth` | `k>=((gamma*b'+3a')/b') log s`; the tuple rule separately chooses the smallest odd `k` satisfying items 2a--2d. | `gt-10-answer-reduction.tex:L1409-L1412` (`def:pcpparams`, item 2a). |
| `P_formula_paper` | The source predicate `(2+5k)m'/2^k<1/2`, retained literally as the paper's item 2(b); its constant `2` conflicts with the checked occurrence bound and is tagged `SOURCE_REPAIR(C8)`. | `gt-10-answer-reduction.tex:L1412-L1413` (`def:pcpparams`, item 2b). |
| `P_formula_structural` | Extra project obligation `(deg_F+5d)m'/q<1/2` using the checked occurrence bound. It is not a consequence of `def:pcpparams`: named fixtures check it directly, while a general circuit must assume it or derive it from additional fan-out and growth hypotheses. | Finding F1/C8; `DESIGN.md` §§2 and 4.1. |
| `P_tail` | `k*m'/2^k<=s^(-b'*gamma)`. | `gt-10-answer-reduction.tex:L1413-L1414` (`def:pcpparams`, item 2c). |
| `P_divisibility` | `m'` divides `2^k`; operationally this permits `chi` to form `m'` equal buckets for PCP copy 6. | `gt-10-answer-reduction.tex:L1414-L1416` (`def:pcpparams`, item 2d). |
| `P_degree` | `d=k`; tuple formation also records `q=2^k` and the smallest-odd-`k` rule rather than treating them as a seventh predicate. | `gt-10-answer-reduction.tex:L1409-L1417` (`def:pcpparams`, items 2--3). |
| `Pi`, `Π`, `PCPProof` | Tuple `(g_1,...,g_5,c_0,...,c_{m'})` of evaluation tables/formal low-degree polynomials. | `gt-10-answer-reduction.tex:L1426-L1442` (`def:pcp-proof`). |
| `z=(x_1,...,x_5,o,w)` | A point of `F_q^{m'}` in the fixed PCP block decomposition. | `gt-10-answer-reduction.tex:L1435-L1447` (`def:pcp-proof`, `def:pcp-eval`). |
| `ev_z(Pi)`, `\mathrm{ev}_z(Π)`, `pcp_eval(Pi,z)` | PCP view `(alpha_1,...,alpha_5,beta_0,...,beta_{m'})` at `z`. | `gt-10-answer-reduction.tex:L1444-L1453` (`def:pcp-eval`). |
| `alpha_i`, `α_i` | `g_i(x_i)`, the `i`th block-polynomial evaluation. | `gt-10-answer-reduction.tex:L1444-L1453` (`def:pcp-eval`). |
| `alpha'_i`, `α'_i` | Copy-6 bundled evaluation of `g_i`, compared with the individual-copy `alpha_i` under the guarded consistency checks. | `gt-10-answer-reduction.tex:L1987-L1998`, `L2014-L2040` (`table:tpcp`, `fig:decider-pcp`). |
| `beta_j`, `β_j` | `c_j(z)`, including `beta_0=c_0(z)`. | `gt-10-answer-reduction.tex:L1444-L1453` (`def:pcp-eval`). |
| `h_i`, `h'_i`, `f_j` | Univariate line restrictions returned by individual copy `i` and bundled copy 6 for `g_i` and `c_j`. | `gt-10-answer-reduction.tex:L1987-L1998` (`table:tpcp`). |
| `pcpverifier`, `pcp_verifier` | Local verifier performing the formula test and zero-on-subcube test after reconstructing the succinct circuit and its arithmetization. | `gt-10-answer-reduction.tex:L1548-L1585` (`fig:pcpverifier`). |
| `p_soundness` | Low-degree-PCP soundness threshold `1/2`; the premise is strict acceptance probability `>1/2`. | `gt-10-answer-reduction.tex:L1509-L1533` (`thm:pcp-decider`). |
| `V^pcp` | Ambient direct sum for the six-copy PCP sampler. | `gt-10-answer-reduction.tex:L1895-L1913` (`eq:V-pcp`). |
| `Type^pcp` | Eighteen types `{Point_i,ALine_i,DLine_i : i=1,...,6}` with complete type graph. | `gt-10-answer-reduction.tex:L1887-L1894` (`sec:ld-compiler`). |
| `Type^ora` | Oracularization roles `{oracle,alice,bob}` with complete graph including loops. | `gt-09-oracularization.tex:L36-L59` (`sec:orac-def`). |
| `L^alice`, `L^bob` | Original sampler's left and right CL functions; the oracle receives their common seed and can compute both images. | `gt-09-oracularization.tex:L49-L67` (`sec:orac-def`). |
| `ldparams` | `(q,m,d,kappa=1)`, used by input low-degree and individual proof low-degree checks. | `gt-10-answer-reduction.tex:L2027-L2047` (`fig:decider-pcp`). |
| `ldparams'` | `(q,m',d,kappa=m'+6)`, used by the simultaneous bundled-proof low-degree check. | `gt-10-answer-reduction.tex:L2048-L2053` (`fig:decider-pcp`). |
| `hat D_AR`, `typed_answer_reduced_decider` | Typed decider with the five guarded Figure `decider-pcp` checks; proof consistency/individual low degree restrict `i` to `{3,4,5}`. | `gt-10-answer-reduction.tex:L1973-L2071` (`fig:decider-pcp`). |
| `D_AR`, `answer_reduced_decider` | Untyped verifier/decider obtained only after applying the cited `detype` transformation to the typed answer-reduced object. | `gt-10-answer-reduction.tex:L2077-L2116` (`thm:ar`); `gt-06-types.tex:L435-L475` (`lem:detyping-verifiers`). |

For TB0, this is the sole evaluability calculation for predicates 2 and 4. With `gamma=1`, `s=6`, `m'=16`, `a'>1`, and `0<b'<1`,
`a'/b'>1`. At `k=3`, the right side of `P_growth` exceeds `4 log 6` (about 10.34 in base 2 and 7.17 with natural log), so the predicate
FAILS for every admissible pair; at `k=11`, admissible ratios exist on both sides of the threshold, so it is `NOT_EVALUABLE`. Also
`6^(-b')` lies strictly between `1/6` and `1`: `P_tail` FAILS at `k=3` because `3*16/8=6>1`, and PASSES at `k=11` because
`11*16/2048=11/128<1/6`.

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
| `Grade` | Fixed enumeration `{CONSTRUCTED,CHECKED,CITED,ASSUMED,SOURCE_REPAIR}` carried by every certificate node. | Project evidence boundary motivated by the executable/cited split at `gt-10-answer-reduction.tex:L1542-L1786` and `L2077-L2116`. |
| `Checked{T,C}` | Project pair of an IR term and inspectable evidence. A CHECKED node is a function recomputed against the attached term; evidence is never detached or cached. | Same executable/cited split as the preceding row. |
| `BoundExpr` | Either `Concrete(Int)` or `Opaque(description,parameters)`; an opaque theorem polynomial is printed, never assigned an invented exponent. | Project representation of source bounds. |
| `MachineDesc` | Finite serializable machine-description data. In the fixed-point term, mathematical `M` is represented by a closed literal term of sort `P{MachineDesc}`; this local machine parameter is distinct from assignment length `M=2^m`. | Mandate `handoff.md:L21-L35`; bounded-halting description `gt-10-answer-reduction.tex:L200-L205`. |
| `Level` | Finite serializable compression-level data. The fixed-point parameter `L` is a closed literal term of sort `P{Level}` and is passed unchanged both to `Compress` and to `FuelBound`. | Mandate `handoff.md:L21-L35`; compression interface `gt-12-compression.tex:L26-L39`. |
| `Compressor` | Program-result sort for a transformation that accepts the quoted sampler/decider pair and a `Level`, and returns a decider description. | Project sort for the compression interface at `gt-12-compression.tex:L26-L39`. |
| `PartialProgram`, `Hole(name,sort)` | Program syntax with explicit typed specialization holes. | Project syntax needed to express the fixed point in `handoff.md:L21-L39`. |
| `ClosedProgram` | Program with all de Bruijn variables scoped and no remaining holes. | Project scope/phase invariant. |
| `Pargs` | A finite sequence `P*` of program terms supplied to `Eval`. | Project surface sort for the fixed-point term in `handoff.md:L21-L39`. |
| `Fuel` | Evaluator-fuel syntax `FuelLiteral(Nat)` or `FuelBound(P{Nat},P{Level})`; evaluation interprets it to a finite bound or returns `TypeError`. Thus `FuelBound(n,L)` in `Psi_{M,L}` is well-sorted. | Project surface sort for bounded evaluation at `gt-10-answer-reduction.tex:L200-L205`. |
| `Introspect`, `introspect` | Description transformation which constructs the Pauli/introspection typed sampler and classical predicate, downsizes and detypes them, and returns an executable five-level verifier description. Its general completeness, soundness, Ent, and asymptotic conclusions remain CITED. | `gt-08-introspection.tex:L164-L359`, `L394-L817` (`sec:intro-verifier`, `thm:introspection`). |
| `answer_reduce_pcp` | Executable-through-TB2 construction of the typed verifier `hat V^ar`, of typed level `max(ell,3)`; quantum conclusions remain cited. | `gt-10-answer-reduction.tex:L1860-L1965` (`sec:ld-compiler`). |
| `detype` | Executable graph-sampler/conditional-concatenation/parser construction from a typed normal-form verifier to an untyped one. Its `+2` levels and `+4*TypeCount` dimension are constructed; value-one preservation and the `16^TypeCount` soundness/Ent map remain CITED. For answer reduction `TypeCount=54`. | `gt-06-types.tex:L225-L475` (`def:graph-sampler`, `def:detyped-CL`, `lem:detyping-verifiers`). |
| `AnswerReduce` | Composite `detype o answer_reduce_pcp`; only this detyped object carries the `max(ell+2,5)` and `thm:ar` contract. | `gt-10-answer-reduction.tex:L2077-L2116` (`thm:ar`). |
| `Repeat`, `repeat` | Executable anchoring, detyping, `k(n)`-fold direct-sum sampler, and guarded-AND decider transformation. The general PCC/Ent repetition theorem remains CITED. | `gt-11-parallel-repetition.tex:L80-L258` (`sec:anchoring`, `sec:anchored-repetition`, `thm:repetition`). |
| `Compress`, `compress` | Closed description transformer implementing `Repeat o AnswerReduce o Introspect`, with introspection parameter 9 and symbolic universal `mu,gamma,tau`; construction bookkeeping is executable and the compression theorem remains CITED. | `gt-12-compression.tex:L57-L98` (`fig:compress`). |
| `Fix` | Description-level fixed-point constructor that binds the distinguished `self_code` hole without identifying code with a closure. | Project syntax for the fixed-point equation in `handoff.md:L21-L39`; compression consumes descriptions at `gt-12-compression.tex:L26-L39`. |
| `Psi_{M,L}` | Quoted functional whose fixed point accepts if machine `M` halts within `n`, otherwise invokes the compressed verifier built from its own quoted description and `S_L`. | Mandate equation in `handoff.md:L21-L35`; paper compression interface at `gt-12-compression.tex:L26-L39`. |
| `D_{M,L}` | Closed fixed-point decider `Fix(Psi_{M,L})`. | Mandate equation in `handoff.md:L31-L39`; corresponding compression machinery `gt-12-compression.tex:L26-L53`. |
| `S_L` | Canonical executable compressed-sampler description computed from `L` alone and paired with the self-referential decider in the halting construction. Its static dependency set excludes the input verifier. | Mandate `handoff.md:L23-L35`; `gt-12-compression.tex:L108-L147` (`lem:compress-independent-samplers`). |
| `M` (machine context) | The Turing machine whose halting is tested, with term sort `P{MachineDesc}` inside `Psi_{M,L}`. Code calls it `machine` to avoid collision with assignment length `M=2^m`. | Mandate `handoff.md:L21-L35`; bounded-halting description `gt-10-answer-reduction.tex:L200-L205`. |
| `L` (fixed-point context) | The compression-level parameter, with term sort `P{Level}` inside `Psi_{M,L}`; the same term is supplied to `Compress` and `FuelBound`. | Mandate `handoff.md:L21-L35`; compression interface `gt-12-compression.tex:L26-L39`. |

## G. Evidence grades

| printed grade | meaning |
|---|---|
| `CONSTRUCTED` | The datatype constructor makes the invariant unavoidable. |
| `CHECKED` | A deterministic check function recomputed against the attached IR term. |
| `CITED` | The statement is imported from the named ground-truth theorem/lemma and is not locally checked. |
| `ASSUMED` | The statement is an explicit hypothesis without a ground-truth discharge. |
| `SOURCE_REPAIR` | A totalizing convention or typo repair needed to make the executable interpretation definite. |

Only `CONSTRUCTED` and `CHECKED` count as machine evidence.  The other grades
remain visible under certificate composition.

## H. Description-level compression API

| symbol / code name | authoritative meaning | ground-truth anchor |
|---|---|---|
| `SamplerDescription` | Canonical quote of a sampler machine, together with executable field-size and dimension laws, constructed level, exact byte size, typing graph, query-time law, and static description dependencies. Its only behavioral operations are the four `SamplerQuery` variants. | `gt-04-cl.tex:L572-L601` (`def:sampler`); DESIGN §9.1. |
| `TypeCount` | Cardinality of the finite type set stored in a typed sampler description; it is the code spelling of the paper's type-set cardinality. | `gt-06-types.tex:L461-L473` (`lem:detyping-verifiers`). |
| `Dimension`, `Marginal`, `Linear`, `Factor` | The four sampler query variants. `Factor` returns a standard-basis indicator and `Linear` evaluates the prefix-selected stage map; a typed query adds a type argument without adding an operation. | `gt-04-cl.tex:L583-L595` (`def:sampler`); `gt-06-types.tex:L109-L125` (`def:typed-sampler`). |
| `DeciderDescription` | Canonical quote of a total five-input, or typed seven-input, bit predicate with TIME, question/answer-length, exact-size, and dependency metadata. | `gt-05-games-normalform.tex:L612-L622` (`def:decider`); `gt-06-types.tex:L185-L195` (`def:typed-decider`). |
| `QuotedLaw{Nat}`, `UpperBoundLaw`, `LawCert` | Closed law program and its replay certificate. AST equality and finite evaluations are CHECKED; an unspecified theorem polynomial stays opaque and CITED. This is separate from `BoundExpr`. | Project v2 representation for the parameter laws in `gt-12-compression.tex:L156-L187` (`tab:params`). |
| `GapMap` | Canonical directed threshold relation for detyping, anchoring, introspection, answer reduction, repetition, or compression. Its syntax is CHECKED and its semantic implication remains attached to the source theorem as CITED. | `gt-06-types.tex:L454-L460`; `gt-08-introspection.tex:L798-L815`; `gt-11-parallel-repetition.tex:L243-L258`; `gt-12-compression.tex:L40-L52`. |
| `QuotedBranch` | Serializable pure continuation used by the lazy `CLStep` description adapter; it computes only the branch selected by the preceding value. Opaque host functions are not descriptions. | `gt-04-cl.tex:L35-L57` (`def:cl-func`); `L586-L594` (`def:sampler`). |
| `QueryError`, `BudgetExceeded`, `NotDescribable` | Total non-success results for malformed sampler calls, over-budget materialization, and opaque host branches. They carry no sampler-law conclusion. | Project totalization policy; sampler promises are restricted to legal calls in `gt-04-cl.tex:L581-L595`. |
| `downsize(S)` | Query-only conjugation of a sampler to field 2: level is unchanged, dimension becomes `s(n)log2 q(n)`, and factor indicators are expanded coordinatewise. | `gt-04-cl.tex:L628-L680` (`def:downsize_sampler`, `lem:downsize_sampler`). |
| `graph_sampler(G)` | Pair of level-2 CL maps on four `TypeCount`-dimensional registers which exposes vertex/neighbor encodings and the selected opposite edge bit. | `gt-06-types.tex:L225-L339` (`def:graph-sampler`, `prop:simulating-graph`). |
| `detype_sampler`, `detype_decider` | Query-only concatenation of `graph_sampler(G)` with the selected typed child map, and the matching accept-on-invalid parser. Output dimension is `s+4*TypeCount` and level `ell+2`. | `gt-06-types.tex:L359-L427` (`def:detyped-CL`, detyped samplers/deciders). |
| `Game`, `Anchor`, `anchor` | Two anchoring types and the composite typed-anchor-then-detype construction. `Game` delegates to the child; `Anchor` asks zero and requires answer zero. | `gt-11-parallel-repetition.tex:L80-L136` (`sec:anchoring`, `prop:anchoring`). |
| `c_prime`, `c'` | Universal repetition exponent constant associated with the polynomial slowdown of the anchored decider. It remains symbolic until supplied; tests use an explicit legal substitution. | `gt-11-parallel-repetition.tex:L200-L220`, `L229-L258` (`thm:repetition`). |
| `k_rep(n)`, `k(n)` | Repetition count `(lambda*n)^((1+c_prime)*tau)`. Code names it `k_rep` to distinguish it from a field extension degree and CL stage. | `gt-11-parallel-repetition.tex:L200-L215`, `L237-L258`. |
| `B_rep(n)` | Per-component repeated-decider length guard `(lambda*n)^tau`; malformed tuples or components longer than this are rejected before a child call. | `gt-11-parallel-repetition.tex:L216-L220`. |
| `TypePauli`, `G^pauli` | The 26 Pauli-basis-test types and their 56-edge graph (26 loops and 30 non-loops), represented with 86 oriented pairs. | `gt-07-ldt.tex:L964-L1120` (`eq:pauli-type`, `fig:type-graph-pauli`). |
| `pauli_decider` | Executable classical predicate combining equality, classical low-degree, Pauli-answer encoding, commutation, and Magic-Square checks. Pauli rigidity is not part of this predicate. | `gt-07-ldt.tex:L1126-L1227` (`fig:decider_pauli`). |
| `introparams(R)` | Canonical symbolic Pauli tuple `(q,m,d)` with `q=2^(c ceil(log log R)+1)`, `m` the specified power of two, and `d=1`; it is numeric only when the universal Pauli constants are supplied. | `gt-07-ldt.tex:L1492-L1569` (`def:introparams`, `lem:introparams-complexity`). |
| `Q_EPR` (paper `Q`) | Number `2^m log2 q` of EPR pairs/qubits certified and used as the introspection randomness register; code distinguishes it from answer reduction's `Q_len`. | `gt-08-introspection.tex:L195-L202`; `L991-L995`. |
| `TypeIntro`, `G^intro` | `TypePauli` plus `(Introspect,Sample,Read,Hide_1,...,Hide_ell) x {alice,bob}` and Figure `type-graph-intro`; its size is `32+2ell`. | `gt-08-introspection.tex:L217-L315`. |
| `typed_intro_decider` | Executable seven-input predicate implementing Pauli, sampling, hiding, original-game, and equal-type consistency tests at child index `N=2^n`, with every child call timed out at `N^lambda`. | `gt-08-introspection.tex:L394-L692` (`fig:intro-decider`). |
| `StabilizerTranscriptSimulator` | Exact tiny-fixture simulator for the honest EPR/Pauli transcript distribution. It accepts only commuting stabilizer measurement families and does not estimate entangled value. | `gt-08-introspection.tex:L923-L953` (`lem:commute`); `L1002-L1172` (`fig:intro-honest`). |
| `CompressionConstants` | Symbolic record for `C_intro,a1,b1,a2,b2,C_ar,c3,c3_prime,mu,gamma,tau`, including the exact `eq:mu-gamma` and `eq:c_rep` definitions. | `gt-12-compression.tex:L197-L215`, `L222-L307`, `L332-L359`. |
| `ProductionPolicy`, `ToyPolicy` | Production retains exact symbolic paper laws and refuses over-budget materialization; toy mode supplies explicit parameter/count overrides and reports every violated production predicate, making theorem eligibility false. | Project v2 execution policy motivated by the growth in `gt-12-compression.tex:L15-L24`, `L156-L187`. |
| `SOURCE_REPAIR(AR-field-align)` | Explicit `downsize` of the large-field PCP sampler before its direct sum with a field-2 normal-form sampler. The source specifies both ingredients and the direct sum but omits this field-alignment call. | `gt-04-cl.tex:L628-L680`; `gt-05-games-normalform.tex:L624-L634`; `gt-10-answer-reduction.tex:L1948-L1965`. |
| `M_loop` | Two-state toy machine whose halt state is unreachable, used to exercise the nonhalting branch and one finite description-level unfold of `D_{M,L}`. | Project TB7 fixture for `gt-12-compression.tex:L426-L492` (`fig:halt_f`). |
