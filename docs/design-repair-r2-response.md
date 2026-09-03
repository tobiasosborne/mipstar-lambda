# Design repair r2 response

Work order: `verdicts/design-r2.md`. Law 5 is applied by downgrading the general structural parameter inequality instead of treating a
fixture check as a theorem. No claim status is promoted here. Dispositions count all three MAJORs, both MINORs, and four NOTEs:
**FIXED 8 / RETRACTED 0 / DOWNGRADED 1 / RESIDUE 0**.

| id | disposition | exact edit location | repair |
|---|---|---|---|
| R1 | FIXED | `definitions.md` §E (`ParameterPredicateResult`); `DESIGN.md` §2 and §5 | Defined `PASS`/`FAIL`/`NOT_EVALUABLE` once over the whole admissible constant range and cited that definition from the design. The §5 reports now agree with the six predicates: TB0-small is `PASS, FAIL, FAIL, FAIL, FAIL, FAIL`; the sampled rows are `PASS, NOT_EVALUABLE, PASS, PASS, PASS, PASS`. Section 5 also retains the checked smallest-odd-`k` statement for formula plus divisibility. |
| R2 | DOWNGRADED | `definitions.md` §E (`P_formula_paper`, `P_formula_structural`); `DESIGN.md` §2, DD-22, §4.1, §5, §7 risk 5; amended C5 | Regraded `(deg_F+5d)m'/q<1/2` as the EXTRA `P_formula_structural`: TB0-small is CHECKED with result FAIL, TB0-sampled is CHECKED with result PASS, and the general inequality is ASSUMED unless separately discharged. Retained the paper's literal-2 predicate as `P_formula_paper` tagged `SOURCE_REPAIR(C8)`. DD-22 records `deg_F<=2 fanout_max+3`, the copy-gate/degree consequence, and the item-2(a) absorption under `m'=O(s)`. |
| R3 | FIXED | `DESIGN.md` §5, §5.1 items 2/5/6, §5.4, §5.5; amended C3; `DIRECTIVES FOR TB0` | Retained both witnesses. Witness (i) is explicitly degenerate and fast, names the quotient identity, the seven zero/nine nonzero quotients, and the vacuous contracts. Witness (ii) is the specified all-nonconstant witness with budget 2,500,000; it alone supplies C3 block-dependency evidence and TB2 checks 4(a)/4(b). Recorded the critic's measurements as external measurements requiring TB0 confirmation, time, and peak-memory reports. |
| R4 | FIXED | `definitions.md` §A (`MonomialBudget`, `expected_support`); `DESIGN.md` §1.3 and §5 table | Defined the budget per single multiplication as `card(partial support)*card(next factor support)`, not cumulatively; recorded the 54,978 predicted peak for witness (i); and separated estimates from locally measured support in every table cell. |
| R5 | FIXED | `definitions.md` §F (`Pargs`, `Fuel`); `DESIGN.md` §1.1 | Added `Pargs ::= P*`, a concrete `Fuel` grammar, and the nullary-primitive literal convention; the displayed term now spells `true` as `Prim(true,Concrete(1),())`. |
| NOTE (a) | FIXED | `definitions.md` §§D/E; `DESIGN.md` §1.6 | Corrected every `table:tpcp` row-range citation from `L1990-L1999` to `L1987-L1998`. |
| NOTE (b) | FIXED | `DESIGN.md` §1.6 | Replaced the overbroad citation with the guarded continuation wording and cited the literal otherwise-accept convention at `gt-07-ldt.tex:L368`. |
| NOTE (c) | FIXED | `DESIGN.md` §5 | Disclosed that TB0 has three NOT gates although Figure `pcpverifier` describes AND/OR gates, and limited the inference to this fixture. |
| NOTE (d) | FIXED | authorized C1 below | Uses “16 named `GF(8)` coordinate lines `S_j`,” not “coordinate subcube.” |

## MERGE PROPOSALS (authorized verbatim by design-r2)

The orchestrator may paste the following four authorized rows verbatim. Their statuses are unchanged.

```markdown
| C1 | For the explicit real six-gate TB0 instance, the constructed PCP proof Pi is checked by formal coefficient identities, accepted by `pcpverifier` on every one of the 16 named `GF(8)` coordinate lines `S_j` through `b_rho` and on the Boolean subcube, and accepted at at least 10^4 uniformly sampled `z in GF(2^11)^16` plus named branch-directed points. This is completeness evidence, not an exhaustive all-`z` or soundness claim. | CONJECTURE | C2,C3,D1 | — | — | — |
| C2 | (Zero-basis certificate) For `c_0` built from `arith_q(tseitin(C) and w_out)` in TB0, the multilinearization rewrite produces `c_1,...,c_16` with `c_0=sum_i c_i zero(z_i)` as a formal coefficient identity and zero multilinear remainder. Exhaustive Boolean truth tables over all `2^16` assignments and all `2^10` candidate five-block witnesses check the circuit/Tseitin/`phi_C` correspondence for this fixture, including that `r=0` holds for exactly the 512 witnesses satisfying `phi_C`; the general correspondence remains CITED. | CONJECTURE | D1 | — | — | — |
| C4 | (Sampler is CL) `L_Point`, `L_ALine`, and `L_DLine` are 1-, 2-, and 3-level CL functions BY CONSTRUCTION from register-subspace `CLStep`; on small `(q,m)` their induced distributions equal the cited axis/diagonal line-versus-point distributions by a `chi`-independent exact histogram. The 18 PCP maps form one typed family padded to common level 3; the typed answer-reduced product has level `max(ell,3)`. | CONJECTURE | D2 | — | — | — |
| C8 | (Refutation candidate, findings F1/F2) For NW19 Tseitin arithmetized along the formula tree and conjoined with `w_out`, `deg_v(F_arith)<=occ_v`, where an input has occurrence `2 fanout(v)` and gate wire `w_i` has `2+2 fanout(w_i)+indicator(i=out)`. The two-gate regression has degree vector `(2,2,2,4,3)`, in particular `deg_w1=4>2`; TB0 attains its displayed occurrence vector coordinatewise, with equality on all sixteen coordinates. Consequently `deg_v(c_0) <= occ_v(F_arith) + deg_v(prod_i (g_i - o_i))`, which for multilinear `g_i` adds at most 1 per coordinate, and the formula Schwartz--Zippel constant is `deg_F+5d`, not 2+5d, unless the source claim is separately repaired. | CONJECTURE | — | docs/findings.md F1,F2 | — | — |
```

### Amended HOLD rows for adjudication

These C3 and C5 replacements answer the named HOLD reasons without promoting either status.

```markdown
| C3 | (Degree/dependency report) TB0 retains two satisfying witnesses. For the fast degenerate witness `(a_1,...,a_5)=([0,1],[0,0],[0,0],[0,0],[0,0])`, `g_2=...=g_5=0`, so their block-locality contracts and Figure `decider-pcp` checks 4(a)/4(b) are vacuous and are not C3 evidence. Its structural and actual vectors are `(2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)` for `F_arith` and `(3,0,0,0,2,3,1,1,1,1,6,4,4,4,4,3)` for `c_0`; its certificate checks `c_0=sum_i c_i zero(z_i)`, `r=0`, and `max_i inddeg(c_i)=6<=d` (with equality on TB0-small), with exactly `c_2,c_3,c_4,c_7,c_8,c_9,c_10` zero because the corresponding `deg_j(c_0)<=1` and the other nine quotients nonzero. For the non-degenerate witness `([0,1],[1,0],[0,1],[1,0],[0,1])`, every `g_i` is non-constant and support checks `Dependencies(g_i)={X_i}` exactly; only this witness supplies block-dependency evidence. Its `c_0` structural and actual vector is `(3,1,1,1,3,3,1,1,1,1,6,4,4,4,4,3)`, `inddeg(c_0)=6`, and every quotient is checked against the explicit relation `inddeg(c_i)<=6<=d`. | CONJECTURE | D1,C8 | — | — | — |
| C5 | (Soundness vs low-degree proofs) If Pi has individual degree at most `d` and is accepted with probability greater than 1/2, the low-degree-PCP derivation uses formula bound `(deg_F+5d)m'/q` with `deg_F` the checked formula-occurrence bound and zero-test bound `(2+d)m'/q`. The paper's `P_formula_paper=(2+5k)m'/2^k<1/2` is retained with its literal `2` tagged `SOURCE_REPAIR(C8)`. The parameter tuple returned by `def:pcpparams` bounds `(2+5k)m'/2^k`, not `(deg_F+5k)m'/2^k`, so `P_formula_structural` is an additional obligation: its checker is discharged on both TB0 rows, returning FAIL for TB0-small and PASS for TB0-sampled; in general it follows from item 2(a) only under a stated `m'=O(s)` relation and sufficiently large `s`. With copy gates enforcing `fanout_max<=2` while at most doubling circuit size, `deg_F<=2 fanout_max+3<=7`, and `d>=deg_F+1` (hence `d>=8`) suffices for the proof's individual-degree bound. No numerical test establishes soundness. | SKETCH | C2,C8 | — | n/a | — |
```

## DIRECTIVES FOR TB0

1. Implement `ParameterPredicateResult` over the full admissible range: TB0-small must report the six predicates as
   `PASS, FAIL, FAIL, FAIL, FAIL, FAIL`; TB0-sampled must report `PASS, NOT_EVALUABLE, PASS, PASS, PASS, PASS`. Report
   `P_formula_structural` separately (small FAIL, sampled PASS), never as a seventh `def:pcpparams` predicate.
2. Keep witness (i) `([0,1],[0,0],[0,0],[0,0],[0,0])` under `MonomialBudget=160,000` for the fast identity path. Print its named
   quotient relation, zero remainder, exact seven-zero/nine-nonzero quotient split, `max_i inddeg(c_i)=6<=d` (equality on TB0-small), measured support, time, and
   peak memory. Do not use its empty `g_2,...,g_5` dependencies as C3 evidence.
3. Add witness (ii) `([0,1],[1,0],[0,1],[1,0],[0,1])` under `MonomialBudget=2,500,000`. Require every `g_i` to be non-constant and
   `Dependencies(g_i)={X_i}` exactly. This witness alone owns C3 locality evidence and TB2 checks 4(a)/4(b) for `i in {3,4,5}`.
4. Confirm or refute the critic's measured non-degenerate counts (1,773,072 normalized monomials over `Z`, 1,203,552 in characteristic
   two), and always print normalized support, elapsed time, and peak memory. Enforce `MonomialBudget` per multiplication as
   `|partial support|*|next factor support|`, not cumulatively; never raise either budget silently.
5. Assign mutations exactly as §5.1: A to the standalone rewrite replay; B to witness (ii)'s `g_2-o_2` formula separator; C to the output
   truth table; D to field axioms; E to occurrence/support comparison; F to witness (ii)'s all-nonconstant/exact-dependency check.
6. Report both named-fixture `P_formula_structural` checks, but place only TB0-sampled's CHECKED leaf with result PASS in §4.1's soundness tree. The
   general form is ASSUMED unless a direct inequality or DD-22's fan-out, `m'=O(s)`, growth, and sufficiently-large-`s` hypotheses are
   present.

## RESIDUE

None. The general `P_formula_structural` inequality remains visibly ASSUMED unless its extra hypotheses are supplied; that is the explicit
R2 downgrade, not an unaddressed objection.
