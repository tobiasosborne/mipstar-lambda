# Design repair r1 response

Work order: `verdicts/design-r1.md`. No claim status is promoted here. Dispositions count objections, including every NOTE:
**FIXED 27 / RETRACTED 1 / DOWNGRADED 3 / RESIDUE 0**.

| id | disposition | exact edit location | repair |
|---|---|---|---|
| M1 | DOWNGRADED | `DESIGN.md` §5, §5.1, DD-14; merge proposal C1 | Deleted `q=2` and the claim of exhaustive PCP evidence. `q=8` exhausts only named Boolean/coordinate subcubes; `q=2^11` uses sampled `z`. |
| M2 | FIXED | `DESIGN.md` §5.1, DD-14 | Assigned each mutation to one rung/checker: rewrite/coefficient identity, omitted factor/formula test at a stored off-cube separator, output literal/truth table, modulus/field axioms, fan-out/degree comparison. |
| M3 | RETRACTED | `DESIGN.md` §1.2, §1.3, §5, §5.1; DD-18; merge proposals C2/C3 | Removed the `(product x_i o_i)^2` fixture entirely. TB0 now uses `arith_q(tseitin(C) and w_out)` for an explicit six-gate circuit and all 16 quotient coordinates. |
| M4 | DOWNGRADED | `DESIGN.md` §1.2, §1.3, §4.1, §5.1, DD-18; `definitions.md` §§A/B; merge proposals C3/C5/C8 | Replaced occurrence-at-most-two with the computed occurrence vector and `deg_v(F_arith)<=occ_v`; propagated `deg_F=6`, `inddeg(c_0)=6`, required `d>=6`, and the repaired SZ constant. |
| M5 | FIXED | `DESIGN.md` §1.5, §5.4, DD-20; `definitions.md` §D | Set `dim V_{6,coord}=6`, recorded the conflict with scalar `table:tpcp`, and made `chi` read `V_aux,coord` under a visible `SOURCE_REPAIR`. |
| M6 | FIXED | `DESIGN.md` §1.5, DD-19 | Deleted the general-subspace/rank-certificate branch. `CLStep` accepts disjoint coordinate-index sets spanning the standard basis only. |
| M7 | FIXED | `DESIGN.md` §1.1, DD-1; `definitions.md` §F | Added typed `Hole`, defined `PartialProgram`, `Closed`, and total specialization, and rewrote the flagship term as `D_M_L=Fix(Psi_M_L)`. |
| M8 | FIXED | `DESIGN.md` §1.6 | Restated all four contracts as ASSUME/PROVE and required CITED nodes to retain and print undischarged hypotheses. |
| M9 | FIXED | `DESIGN.md` header and §3; `definitions.md` §§F/G | Defined exactly five `Grade` values. Every certificate node carries one grade; CHECKED requires a term-indexed replay function. Removed mixed pseudo-grades. |
| M10 | DOWNGRADED | `DESIGN.md` §2 and §5; `definitions.md` §§A/E | Listed all six `def:pcpparams` predicates and separate tuple-formation rule. With `gamma=1`, five pass at `q=2^11`; `P_growth` and therefore full smallest-odd minimality remain unevaluable from unknown `a',b'`. |
| M11 | FIXED | `DESIGN.md` §1.6 and §2; `definitions.md` §§E/F | Added CITED `detype`; `AnswerReduce=detype o answer_reduce_pcp`. Recorded typed `max(ell,3)`, detyped `max(ell+2,5)`, `+2` levels, and `16^54` loss. |
| M12 | FIXED | `DESIGN.md` §§1.6, 2, 5; `definitions.md` §C | Split `Q_len` from `Q_time`, noted their equality only in `eq:ar-params-1`, and used `Q_len` in PCP tuples/calls. |
| M13 | FIXED | `DESIGN.md` §1.6 “Figure `decider-pcp`” and §5.4; `definitions.md` §E | Transcribed all six question/answer formats, all five sequential checks with exact guards, both LD tuples, and `i in {3,4,5}`. |
| m14 | FIXED | `DESIGN.md` §5 table | Replaced TB1's overloaded `s` with `seed_dim=5`. |
| m15 | FIXED | `DESIGN.md` §§1.4, 5; `definitions.md` §A | Reserved `d` for a claimed parameter bound and printed measured `inddeg(c_0)` separately. |
| m16 | FIXED | `DESIGN.md` §1.5; merge proposal C4 | Described 18 padded CL maps as one typed family of common level 3, not a product/direct sum of six samplers. |
| m17 | FIXED | `DESIGN.md` §2 and §5; `definitions.md` §A | Added `P_exponent_range: d<=q-1`; both concrete rows satisfy it. |
| m18 | FIXED | `DESIGN.md` §1.2, DD-17 | General decoupled 5SAT now permits unequal `N_1,...,N_5`; equal `m` blocks belong to the cited padded subtype. |
| m19 | FIXED | `DESIGN.md` §5.3 | Made the reference histogram `chi`-free: uniform axis and direct `line(u_0,e_i)` construction. |
| m20 | FIXED | `DESIGN.md` §5.2 | TB0.5 is now explicitly a wrapper around `toys/midpoint/`, reusing its implementation, tests, proof, and mutations. |
| m21 | FIXED | `DESIGN.md` §2 and §5.3 | Added `restrict_to_line` with certificate bounds `<=d` for axis and `<=m*d` for diagonal restrictions. |
| m22 | FIXED | `DESIGN.md` §5.4 | Replaced the padded-answer risk with no-op type-pair frequency and per-question strategy rebuild; conditioned seeded coverage on triggering guards. |
| m23 | FIXED | `DESIGN.md` §5.6 | Deleted the dispatch-only closure mutation; composition-order/level-chain and missing-replay mutations are semantic. |
| m24 | FIXED | `DESIGN.md` §§1.1, 3, 6; DD-1, DD-11; DD-12 deleted | Applied all three cuts: no evidence hashes, no unused wrapper types, and two-constructor `BoundExpr`. The remaining certificate core is budgeted at no more than half the polynomial+sampler source lines. |
| n25 | FIXED | `DESIGN.md` §1.5 | Distinguished ALine's two stages from DLine's coordinate/direction/point three-stage order. |
| n26 | FIXED | `DESIGN.md` §1.1 | `halts_within` now carries `Opaque("n steps",(n,))`; runtime `n` is not a static host bound. |
| n27 | FIXED | `DESIGN.md` §1.6, DD-21; §5.6 | Made `Levels` the end-to-end index and tests the chain `5 -> 7 -> 9`, with `Compress: 9 -> 9`. |
| n28 | FIXED | `DESIGN.md` §§2, 7; `definitions.md` §E | Explained `m'|q` as the equal-bucket requirement for copy 6's `chi`. |
| n29 | FIXED | `DESIGN.md` §7 risk 5 | Listed the correct sides of both further typos: `F_q^{m'}` and `alpha_i=g_i(x_i)`. |
| n30 | FIXED | `DESIGN.md` §§1.5, 7 risk 4 | Preserved `L_lnf(0)=identity` as `SOURCE_REPAIR` and retained the zero-direction histogram check. |
| n31 | FIXED | `DESIGN.md` §1.6 and §7 risk 9; `definitions.md` §F | Evaluated the detyping factor as `16^54` and located its absorption only in the cited theorem constant. |

## Handoff coverage closure

| previously inadequate item | repaired location |
|---|---|
| explicit symbolic IR / D1 | §1.1 and DD-1 (`Hole`, `Fix`, closedness) |
| sampler representation / D2 / D5 | §1.5, DD-19, DD-20 |
| verifier contracts | §1.6 conditional ASSUME/PROVE contracts |
| query number and form | §1.6 `table:tpcp` transcription and guarded-check table |
| pipeline completeness | §2 (`restrict_to_line`, `detype`) |
| explicit PCP completeness slice / D3 | §5 and §5.1 real six-gate Tseitin fixture |
| consistency checks | §1.6 exact Figure `decider-pcp` guards |
| next step to complete AR / D8 | §7 risk 9, including oracularization, guarded checks, detyping, and the remaining CITED quantum lift |

## MERGE PROPOSALS

Replace the named `claims/CLAIMS.md` rows verbatim; these are proposals only and were not applied.

```markdown
| C1 | For the explicit real six-gate TB0 instance, the constructed PCP proof Pi is checked by formal coefficient identities, accepted by `pcpverifier` on every named `GF(8)` coordinate subcube in the fixture, and accepted at at least 10^4 uniformly sampled `z in GF(2^11)^16` plus named branch-directed points. This is completeness evidence, not an exhaustive all-`z` or soundness claim. | CONJECTURE | C2,C3,D1 | — | — | — |
| C2 | (Zero-basis certificate) For `c_0` built from `arith_q(tseitin(C) and w_out)` in TB0, the multilinearization rewrite produces `c_1,...,c_16` with `c_0=sum_i c_i zero(z_i)` as a formal coefficient identity and zero multilinear remainder. Exhaustive Boolean truth tables and all 2^10 candidate five-block witnesses check the circuit/Tseitin/`phi_C` correspondence for this fixture; the general correspondence remains CITED. | CONJECTURE | D1 | — | — | — |
| C3 | (Degree/dependency report) Each `g_i` is multilinear in block `X_i` only. For TB0, the structural occurrence bound and actual degree vector of `F_arith` are both `(2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)`; those of `c_0` are both `(3,0,0,0,2,3,1,1,1,1,6,4,4,4,4,3)`, so `inddeg(c_0)=6`, and each quotient is checked against `d`. | CONJECTURE | D1,C8 | — | — | — |
| C4 | (Sampler is CL) `L_Point`, `L_ALine`, and `L_DLine` are 1-, 2-, and 3-level CL functions BY CONSTRUCTION from register-subspace `CLStep`; on small `(q,m)` their induced distributions equal the cited axis/diagonal line-versus-point distributions by a `chi`-independent exact histogram. The 18 PCP maps form one typed family padded to common level 3; the typed answer-reduced product has level `max(ell,3)`. | CONJECTURE | D2 | — | — | — |
| C5 | (Soundness vs low-degree proofs) If Pi has individual degree at most `d` and is accepted with probability greater than 1/2, the low-degree-PCP derivation uses formula bound `(deg_F+5d)m'/q` with `deg_F` the checked formula-occurrence bound and zero-test bound `(2+d)m'/q`. The source's literal formula constant 2 is retained as a `SOURCE_REPAIR(C8)` discrepancy; no numerical test establishes soundness. | SKETCH | C2,C8 | — | n/a | — |
| C8 | (Refutation candidate, findings F1/F2) For NW19 Tseitin arithmetized along the formula tree and conjoined with `w_out`, `deg_v(F_arith)<=occ_v`, where an input has occurrence `2 fanout(v)` and gate wire `w_i` has `2+2 fanout(w_i)+indicator(i=out)`. The two-gate regression has degree vector `(2,2,2,4,3)`, in particular `deg_w1=4>2`; TB0 attains its displayed occurrence vector. Consequently `c_0` is bounded coordinatewise by adding the five block-factor occurrences, and the formula Schwartz--Zippel constant is `deg_F+5d`, not 2+5d, unless the source claim is separately repaired. | CONJECTURE | — | docs/findings.md F1,F2 | — | — |
```

## RESIDUE

None. The two source conflicts and unevaluable universal-constant predicates remain visible as `SOURCE_REPAIR`/`CITED` facts, but no verdict objection is left unaddressed in the design.
