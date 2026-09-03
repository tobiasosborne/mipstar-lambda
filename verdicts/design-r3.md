# CRITIC verdict r3 — `docs/DESIGN.md`, `docs/definitions.md` (adjudication round)

Round 3 (adjudicate). Priors: `verdicts/design-r1.md` (FAIL, 13 MAJOR / 11 MINOR / 7 NOTE),
`verdicts/design-r2.md` (FAIL(R1,R2,R3), 3 MAJOR / 2 MINOR / 4 NOTE).
Work order under review: `docs/design-repair-r2-response.md` (8 FIXED / 1 DOWNGRADED / 0 RESIDUE)
and `briefs/11-design-repair-r2.md`. Scope: `git diff 0007701 HEAD -- docs/` (210 changed lines in
`DESIGN.md`, 26 in `definitions.md`, plus the response document). `src/` and `test/` are another
worker's lane and were not read.

Every number below is my own recomputation. Scratch:
`/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-.../scratchpad/critic-design-r3/`
(`tb0.jl` carried over from r2, plus `w2.jl`, `w2b.jl`, `zb.jl`, `mutB.jl`, `lines.jl`, `w3.jl`) —
independent 16-variable sparse polynomial arithmetic over `Z` with a `mod 2` image, plus `GF(2^3)`
and `GF(2^11)` evaluation (`x^3+x+1`, `x^11+x^2+1`, `rho = x`). No code from the design or from
`src/` was used.

**Standing credit is preserved.** r1's and r2's resolution of all 95 `gt-NN:Lx-Ly` citations still
holds; I re-resolved only the three the repair touched (`gt-10:L1987-L1998`, `gt-07:L368`,
`gt-10:L200-L205`). I did not re-litigate M1--M13, m14--m24 or n25--n31.

---

## 0. Recomputation (brief obligation 2)

Circuit, occurrence law, and witness enumeration re-run from scratch: 128 present / 896 absent
clauses; **512** satisfying five-block witnesses, all and only those with `a_1[1]=1`;
`occ(F_arith) = (2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3)` and the actual individual-degree vector equal to
it over `Z` and over char 2.

### The named non-degenerate witness — brief obligation, discharged

| assertion about witness (ii) `([0,1],[1,0],[0,1],[1,0],[0,1])` | my recomputation | verdict |
|---|---|---|
| is one of the 512 satisfying witnesses | `true` (membership tested against the enumerated set, not against the `a_1[1]=1` rule) | **CONFIRMED** |
| every `g_i` non-constant | `g_1=X_1`, `g_2=1-X_2`, `g_3=X_3`, `g_4=1-X_4`, `g_5=X_5` | **CONFIRMED** |
| `Dependencies(g_i)={X_i}` exactly | support-computed; each `g_i` has exactly coordinate `i` at exponent 1 and no other | **CONFIRMED** |
| `c_0` structural = actual = `(3,1,1,1,3, 3,1,1,1,1, 6,4,4,4,4,3)` | identical over `Z` and over char 2 | **CONFIRMED** |
| `inddeg(c_0)=6` | 6 | **CONFIRMED** |
| `r=0`, coefficient identity `c_0=sum_j c_j zero(z_j)` | remainder is the zero polynomial; identity holds coefficientwise | **CONFIRMED** |
| every quotient `inddeg(c_j)<=6<=d` | `inddeg(c_j) = [6,-,-,-,5,5,-,-,-,-,4,4,3,4,3,1]`, `max = 6` | **CONFIRMED** |
| **predicted support** (brief: recompute if within 10 minutes) | **measured in 15 s: 1,773,072 normalized monomials over `Z`, 1,203,552 in char 2** — exactly the two figures the design attributes to the r2 critic | **CONFIRMED (independently re-measured, not carried over)** |

Incremental single-product candidate counts for witness (ii), in the design's build order:
`[6, 36, 162, 756, 3927, 27489, 27489, 54978, 147756, 295512, 886536, 1773072]`.
**Peak single product 1,773,072** (71% of the stated 2,500,000 budget); cumulative sum **3,217,719**
(which the budget would *not* cover — the per-multiplication rule of §1.3 is load-bearing).
Witness (ii)'s zero/nonzero quotient split is the same seven/nine as witness (i)
(`c_2,c_3,c_4,c_7,c_8,c_9,c_10` zero, exactly the coordinates with `deg_j(c_0)<=1`).

My fast closed-form zero-basis (`z^e = z - (z^{e-2}+...+z^0)*zero(z)`) reproduces r2's
witness-(i) quotient supports `[24976,0,0,0,6232,9945,0,0,0,0,7407,713,176,208,90,36]` exactly, so
the two decompositions agree and the r3 numbers are comparable with the r2 numbers.

---

## 1. Disposition audit (brief obligation 1)

| id | claimed | my verification | verdict |
|---|---|---|---|
| R1 | FIXED | `definitions.md` §E now defines `ParameterPredicateResult` as PASS = holds for every admissible constant choice, FAIL = fails for every choice, `NOT_EVALUABLE` = neither — exactly the demanded semantics — and §2's blanket "2 and 4 ... never PASS" is gone (grepped; the replacement says "there is no blanket result for either predicate"). I recomputed all twelve report entries. TB0-small (`gamma=1,s=6,m'=16,k=3,d=6`): `P_shape` `16=5+5+6`, power of two → PASS; `P_growth` RHS `>4 log 6` = 10.34 (base 2) / 7.17 (ln) / **3.11 (base 10)** > 3 → FAIL under *every* log convention; `P_formula_paper` `17*2=34` → FAIL; `P_tail` `6>1>=6^{-b'}` → FAIL; `P_divisibility` `16∤8` → FAIL; `P_degree` `6≠3` → FAIL. TB0-sampled (`k=11,d=11`): PASS; `P_growth` threshold ratio `a'/b' = 1.085` (base 2) / `1.713` (ln) / `4.38` (base 10), and `a'/b'` ranges over all of `(1,∞)`, so both outcomes are admissible → NOT_EVALUABLE; `912/2048<1/2` → PASS; `11/128 = 0.0859 < 1/6` → PASS; `16 | 2048` → PASS; `11=11` → PASS. Both printed reports match. `a'>1`, `0<b'<1` re-read at `gt-10:L1402-L1403`. | **VERIFIED** |
| R2 | DOWNGRADED | §4.1 now carries two nodes: `P_formula_structural on TB0-sampled: PASS (EXTRA obligation) [CHECKED]` and `P_formula_structural for a general circuit [ASSUMED]` — the demanded "CHECKED (fixture) / ASSUMED (general)" split. DD-22 exists and records all three demanded items. I re-derived each: `occ(w_i)=2+2 fanout(w_i)+[i=out]` gives `deg_F<=2 fanout_max+3`; a fan-out tree costs `sum_v (f_v-1) <= 2s-s = s` extra gates, so copy gates give `fanout_max<=2`, `deg_F<=7`, at most doubling size; `deg_v(c_0)<=occ_v+1` for multilinear `g_i`, so `d>=deg_F+1=8` suffices; `P_growth` with `a'/b'>1` gives `k>4 log s`, hence `2^k>s^4` (base 2) / `s^{2.77}` (ln), and `(deg_F+5k)m' = O(s^2)` under `m'=O(s)` — the absorption is correct and is *not* folded into C8. The `SOURCE_REPAIR(C8)` tag moved to `P_formula_paper` and `disputed` was dropped from DD-18's tag. Downgrade is real: the general inequality is now visibly ASSUMED. | **VERIFIED (honest downgrade, law 5 applied)** |
| R3 | FIXED | All three demanded items are in §5: (i) "so `g_1=X_1` and `g_2=...=g_5=0`" plus the explicit vacuity of block locality for `i≠1` and of `fig:decider-pcp` 4(a)/4(b) for `i∈{3,4,5}`, and "it is never evidence for C3 block dependency or TB2 proof encoding"; (ii) the seven vanishing quotients named with the reason `deg_j(c_0)<=1` and the nine nonzero ones including all six `W`; (iii) the non-degenerate alternative is not merely costed but **retained as witness (ii)** with its own budget, its own rung assertions (§5.1 item 6), its own mutation (F), and sole ownership of C3/TB2 4(a)/4(b) evidence. Everything the design displays for witness (ii) I reproduced above. This exceeds the fix demand. | **VERIFIED — but the *choice* of non-degenerate witness introduces a new defect, R6** |
| R4 | FIXED | `MonomialBudget` is now defined once (`definitions.md` §A) as the candidate count of **one** multiplication, `card(partial support)*card(next factor support)`, "not a cumulative-work counter", and §1.3 says the same and adds "The budget is not a cumulative sum across multiplications." The peak 54,978 is recorded for witness (i) (I re-measured: 54,978). The table cell no longer shares a slot: `(i) estimate 148,176 / measured TBD`. `expected_support` is redefined as an estimate "for a named product, never the measured normalized support". | **VERIFIED (with the witness-(ii) residue, R7)** |
| R5 | FIXED | `Pargs ::= P*` and `Fuel ::= FuelLiteral(Nat) | FuelBound(P,P)` are declared as auxiliary sorts ahead of the grammar, both appear in `definitions.md` §F, and the literal convention is stated ("Literal values use nullary primitives; in particular, `true` abbreviates `Prim(true,Concrete(1),())`") and applied in the displayed `Psi_M_L`. All three named symbols are discharged. | **VERIFIED (with residue R8)** |
| NOTE (a) | FIXED | `table:tpcp` spans `gt-10:L1987-L1998` (I counted the rows: L1980 `\begin{table}`, L1987 the `Point_i` row, L1998 the last `DLine_6` continuation, L1999 `\bottomrule`). All four occurrences of the old range are corrected in both files; `grep` finds zero remaining `L1990-L1999`. | **VERIFIED** |
| NOTE (b) | FIXED | §1.6 now reads "continuing past an untriggered guard" and cites the literal convention separately: `gt-07-ldt.tex:L368` is exactly "In all cases where no action is indicated, accept." | **VERIFIED (citation lands on the literal sentence)** |
| NOTE (c) | FIXED | §5 discloses the three NOT gates against `fig:pcpverifier`'s AND/OR wording, keeps `s=6` and `m'=16`, and states that no general source-faithfulness claim is drawn from the fixture. | **VERIFIED** |
| NOTE (d) | FIXED | `claims/CLAIMS.md` C1 carries "16 named `GF(8)` coordinate lines `S_j`"; "coordinate subcube" occurs nowhere in the row. C1, C2, C4 and C8 were applied verbatim as authorized (diffed against the r2 authorization: byte-identical). | **VERIFIED** |

**Lockstep audit.** All four authorized rows landed verbatim with statuses unchanged (`0efdb49`); no
status moved up anywhere; the response promotes nothing. `docs/design-repair-r2-response.md`'s
RESIDUE section correctly names the surviving ASSUMED general inequality as the R2 downgrade rather
than as an unaddressed objection.

---

## 2. New objections (changed text only; 1 MAJOR, 2 MINOR)

### R6 · MAJOR — mutation B is dead under the newly chosen witness (ii): two of its five PCP factors vanish at `b_rho`, so `beta_0 = 0 = ` verifier RHS for the honest *and* the mutated proof
**Location** `DESIGN.md` §5.1, mutation-assignment paragraph ("B, remove `g_2-o_2`, is owned by
witness (ii)'s GF(2^11) formula test at `b_rho` with `O2=rho`"); §5.1 item 6; §5 table row TB0-small
("16 named coordinate lines and Boolean subcube"); §5.4.

**Independent computation.** `b_rho = (X=(0,0,0,0,0), O=(1,1,1,1,1), W=(rho,0,0,0,0,rho))`.
Witness (ii) sets `a_2=a_4=[1,0]`, so `g_2 = 1-X_2` and `g_4 = 1-X_4`, and at `b_rho`

```
g_2(0) - O_2 = 1 - 1 = 0        g_4(0) - O_4 = 1 - 1 = 0
```

Two of the five factors of `c_0 = F_arith * prod_i (g_i(x_i)-o_i)` vanish. Setting `O_2 = rho`
un-zeroes only the first of them. I evaluated both proofs at the design's named separator:

| field | witness | point | honest `beta_0` | mutated `beta_0` | verifier RHS | B killed? |
|---|---|---|---|---|---|---|
| `GF(8)` | (i) | `b_rho`, `O_2=rho` | 2 | 1 | 2 | **yes** (r2's assignment) |
| `GF(2^11)` | (i) | `b_rho`, `O_2=rho` | 96 | 48 | 96 | **yes** |
| `GF(8)` | (ii) | `b_rho`, `O_2=rho` | **0** | **0** | **0** | **NO** |
| `GF(2^11)` | (ii) | `b_rho`, `O_2=rho` | **0** | **0** | **0** | **NO** |

The design's own parenthetical is where the slip is visible: it says "`g_2(0)-O2=1-rho`, while the
omitted factor changes it to 1" — true, but multiplying a product that already contains the factor
`g_4(0)-O_4 = 0` by `1-rho` instead of `1` changes nothing. The repair moved B's ownership from
witness (i), where r2 verified it separates, to witness (ii), where it cannot. This is a law-4
violation: the mutation has an owner whose checker is provably unable to turn red.

It is worse than one dead mutation. Because each named line `S_j` varies exactly one coordinate away
from `b_rho`, at most one of the two vanishing factors can be revived on any line, so **`c_0` is
identically zero on all sixteen named `GF(8)` coordinate lines for witness (ii)** — I checked all
`16 x 8 = 128` points, and the set of lines on which `c_0` is not identically zero is empty (it is
all sixteen for witness (i)). The whole `TB0-small` named-`GF(8)` scope that §5.1 item 6 assigns to
witness (ii) is therefore a `0 = 0` check that no `c_0`-only mutation can fail. (Completeness still
holds, and the all-zero-proof separation of r1's M1 is *not* reintroduced, because the verifier's RHS
is built from the claimed `alpha_i`, not from the honest `g_i`.)

**FIX DEMAND.** Choose a non-degenerate witness whose five factors are all nonzero at `b_rho`. The
cheapest is `a_2=a_4=[0,1]`, i.e. witness (iii) `([0,1],[0,1],[0,1],[0,1],[0,1])` — I verified it is
among the 512, every `g_i = X_i` is non-constant with `Dependencies(g_i)={X_i}` exactly, and **every
figure the design and the C3 row display for witness (ii) is unchanged**: `c_0` vector
`(3,1,1,1,3, 3,1,1,1,1, 6,4,4,4,4,3)`, `inddeg(c_0)=6`, `r=0`, coefficient identity, same
seven-zero/nine-nonzero quotient split, `max_j inddeg(c_j)=6`. It is also *cheaper*: normalized
support **788,032** over `Z` / **534,912** in char 2 and peak single product **788,032**, less than
half of witness (ii). And B separates again: `GF(8)` honest 2 / mutated 1 / RHS 2; `GF(2^11)` honest
96 / mutated 48 / RHS 96. Alternatively keep witness (ii) and move B's separator to a point where
all five factors are nonzero (e.g. set `O_2 = O_4 = rho`; `F_arith` does not depend on `O_2..O_5`, so
`F_arith(b_rho)=rho^4(1+rho)` is unchanged and honest `F(1+rho)^2` vs mutated `F(1+rho)` separate).
Either way the §5.1 mutation paragraph, item 6, §5.4 and the C3 row must name the same witness.

**SURVIVING STATEMENT.** Everything R3 demanded is delivered and correct: TB0 now retains a
genuinely all-non-constant witness, its degree/dependency/quotient report is exact on all sixteen
coordinates, and witness (i)'s degeneracy is fully disclosed. What fails is only the *choice of
tuple*: with `a_2=a_4=[1,0]` the fixture's designated separator `b_rho` lies on the zero set of two
PCP factors, so witness (ii) supplies valid C3 block-dependency evidence but no `GF(8)` separation
evidence and no home for mutation B. Mutation B remains demonstrably red-capable under witness (i)
and under witness (iii).

---

### R7 · MINOR — witness (ii)'s monomial estimate `2^5` is mis-derived, and R4's demanded peak prediction is recorded for witness (i) only
**Location** `DESIGN.md` §1.3 ("The all-nonconstant witness has estimate `7^3*6^3*2^5 = 2,370,816`
and its separate budget is 2,500,000"), §5 (same figure), §5 table cell "(ii) estimate 2,370,816",
§5.5 ("Expected `c_0` candidates remain at most 148,176 for witness (i) and 2,370,816 for witness
(ii)").

**Independent computation.** The `2^5` assumes all five `(g_i - o_i)` are binomials. For witness (ii)
they are not: `g_2 - o_2 = 1 - X_2 - O_2` and `g_4 - o_4 = 1 - X_4 - O_4` have **three** terms, so
the factor supports are `[2,3,2,3,2]` and their product is **72**, not 32. The design's own §1.3
bound `support(c0) <= support(F_arith) * prod_i (support(g_i)+1)` therefore gives `6^3*7^3*72 =
5,334,336` pre-normalization, or `27,489 * 72 = 1,979,208` with the measured `support(F_arith)`.
`2,370,816` is neither; it is the estimate for a witness with five binomial factors — i.e. exactly
the witness (iii) that R6 recommends, for which it is correct. Separately, R4's fix demand was to
"record the peak ... as the design-time prediction"; §1.3 does this for witness (i) (54,978, which I
re-measured) but records no peak for witness (ii). I measure it at **1,773,072**, against a budget
of 2,500,000; the cumulative candidate sum is 3,217,719, so the budget is adequate *only* under the
per-multiplication rule §1.3 now mandates — the estimate/budget juxtaposition still invites the
cumulative reading R4 asked to be closed.

**FIX DEMAND.** Replace `7^3*6^3*2^5 = 2,370,816` in all four places with the estimate actually
implied by §1.3 for the witness finally chosen (`5,334,336` for witness (ii); `2,370,816` is correct
as written if R6 is repaired by adopting witness (iii)), and record the predicted peak single-product
count next to it, as §1.3 already does for witness (i).

**SURVIVING STATEMENT.** The budget is operationally sound: peak single product 1,773,072 <
2,500,000 for witness (ii) and 788,032 for witness (iii), so no `ExpansionRefused` occurs either way,
and the design is right that the normalized count must be measured — the correct §1.3 estimate
overshoots the measured `Z` count by 3.0x for witness (ii) and by 3.0x for witness (iii).

---

### R8 · MINOR — the new `Fuel ::= FuelBound(P,P)` production creates a sort obligation the flagship term still does not meet (relocated residue of M7/R5)
**Location** `DESIGN.md` §1.1 auxiliary-sort block and the `Psi_M_L` display.

**Independent analysis.** R5's three named symbols are fixed. But the *new* production
`FuelBound(P,P)` requires both arguments to be program terms, and the displayed term writes
`FuelBound(n,L)` while the same term embeds `L` as `Quote(L)` two lines above — so either `L` is a
`P` (and `Quote(L)` is redundant) or it is data (and `FuelBound(n,L)` is ill-sorted). The same holds
for `M` in `Prim(halts_within, Opaque("n steps",(n,)), M, n)`, whose grammar slot is `P*`. Neither
`M` nor `L` has a production or a declared data sort; in `handoff.md:L21-L39` they are a machine and
a level index, i.e. data, which makes the second reading the intended one and the term ill-sorted.
Before the repair `Fuel` was simply undeclared, so this obligation is new text's own.

**FIX DEMAND.** Declare `M` and `L` (as data, with `FuelBound : Nat x Data -> Fuel` or a `Lit`
production lifting them into `P`), and use one spelling of `L` throughout the term.

**SURVIVING STATEMENT.** With `Hole`, `Closed`, total `Specialize`, `Pargs`, `Fuel`, the nullary-
primitive literal convention and `D_M_L = Fix(Psi_M_L)`, the fixed-point equation of
`handoff.md:L21-L39` is expressible and every symbol r2 named is now derivable; two constants
inherited from the source notation remain undeclared.

### NOTEs (no fix demanded)

- **(e)** §3 still says "C5 is a derivation tree whose two Schwartz--Zippel nodes are explicit; its
  general Cook--Levin and theorem-level leaves remain visibly CITED." §4.1 now also puts an
  `[ASSUMED]` leaf in that tree. The sentence is not false (it enumerates the CITED leaves, it does
  not deny ASSUMED ones), but it is an incomplete inventory of C5's undischarged leaves after the R2
  downgrade.
- **(f)** `definitions.md`'s `Fuel` row is anchored to `gt-10:L200-L205`, which is
  `def:BoundedHalting` ("accepts input ... in at most `T` time steps"). That is a step bound, not a
  fuel sort; the anchor is a reading, like NOTE (b)'s, and the row does label it "Project surface
  sort".
- **(g)** `claims/CLAIMS.md`'s committed C3 row still reads "`F_arith` has individual degree ≤2;
  `c_0` has individual degree ≤3; each `c_j` has individual degree ≤3", every clause of which the
  design's own measurements (and mine: 6, 6, 6) refute. It is stale because r2 held C3, not because
  of anything the repair did; §3 below unblocks it.

---

## 3. Adjudication of the amended HOLD rows (brief obligation 3)

No status is promoted in this round. Both rows stay at the status the response proposes.

**C3 — PROMOTE THE ROW TEXT (AUTHORIZED verbatim).** My r2 HOLD named two missing steps: the
witness (i) degeneracy, and *which* relation "each quotient is checked against `d`" means. Both are
now in the row, and I recomputed every figure it displays: both `F_arith`/`c_0` vectors for witness
(i); `r=0` and the coefficient identity; the seven vanishing quotients
`c_2,c_3,c_4,c_7,c_8,c_9,c_10` with the stated reason `deg_j(c_0)<=1` and the nine nonzero ones;
`max_i inddeg(c_i)=6<=d` with equality on TB0-small; and for the non-degenerate witness, every `g_i`
non-constant with `Dependencies(g_i)={X_i}` exactly, `c_0` vector
`(3,1,1,1,3, 3,1,1,1,1, 6,4,4,4,4,3)`, `inddeg(c_0)=6`, and `inddeg(c_i)<=6<=d` for all sixteen
quotients. The HOLD is discharged. Exact row text:

```markdown
| C3 | (Degree/dependency report) TB0 retains two satisfying witnesses. For the fast degenerate witness `(a_1,...,a_5)=([0,1],[0,0],[0,0],[0,0],[0,0])`, `g_2=...=g_5=0`, so their block-locality contracts and Figure `decider-pcp` checks 4(a)/4(b) are vacuous and are not C3 evidence. Its structural and actual vectors are `(2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)` for `F_arith` and `(3,0,0,0,2,3,1,1,1,1,6,4,4,4,4,3)` for `c_0`; its certificate checks `c_0=sum_i c_i zero(z_i)`, `r=0`, and `max_i inddeg(c_i)=6<=d` (with equality on TB0-small), with exactly `c_2,c_3,c_4,c_7,c_8,c_9,c_10` zero because the corresponding `deg_j(c_0)<=1` and the other nine quotients nonzero. For the non-degenerate witness `([0,1],[1,0],[0,1],[1,0],[0,1])`, every `g_i` is non-constant and support checks `Dependencies(g_i)={X_i}` exactly; only this witness supplies block-dependency evidence. Its `c_0` structural and actual vector is `(3,1,1,1,3,3,1,1,1,1,6,4,4,4,4,3)`, `inddeg(c_0)=6`, and every quotient is checked against the explicit relation `inddeg(c_i)<=6<=d`. | CONJECTURE | D1,C8 | — | — | — |
```

*Scoping note carried with the authorization, not a new HOLD:* if R6 is repaired by adopting
`([0,1],[0,1],[0,1],[0,1],[0,1])`, replace the tuple in this row and change nothing else — I verified
that every other figure in the row is identical for that witness. That substitution needs no new
adjudication. Adopting a different witness than those two does.

**C5 — PROMOTE THE ROW TEXT (AUTHORIZED verbatim).** My r2 HOLD demanded the sentence recording that
`def:pcpparams` selects `k` from the literal-2 predicate, so `P_formula_structural` is an additional
obligation. The row now carries it, in the sharper form "its checker is discharged on both TB0 rows,
returning FAIL for TB0-small and PASS for TB0-sampled" — which I verified: at `q=8`,
`(6+30)*16/8 = 72 >= 1/2` FAIL; at `q=2^11`, `976/2048 < 1/2` PASS. The added fan-out clause is also
correct (`deg_F<=2 fanout_max+3<=7` under copy gates that at most double size; `deg_v(c_0)<=occ_v+1`
so `d>=8` suffices), and it is a *scoping* addition to a SKETCH row, not an upward move. Status stays
SKETCH. Exact row text:

```markdown
| C5 | (Soundness vs low-degree proofs) If Pi has individual degree at most `d` and is accepted with probability greater than 1/2, the low-degree-PCP derivation uses formula bound `(deg_F+5d)m'/q` with `deg_F` the checked formula-occurrence bound and zero-test bound `(2+d)m'/q`. The paper's `P_formula_paper=(2+5k)m'/2^k<1/2` is retained with its literal `2` tagged `SOURCE_REPAIR(C8)`. The parameter tuple returned by `def:pcpparams` bounds `(2+5k)m'/2^k`, not `(deg_F+5k)m'/2^k`, so `P_formula_structural` is an additional obligation: its checker is discharged on both TB0 rows, returning FAIL for TB0-small and PASS for TB0-sampled; in general it follows from item 2(a) only under a stated `m'=O(s)` relation and sufficiently large `s`. With copy gates enforcing `fanout_max<=2` while at most doubling circuit size, `deg_F<=2 fanout_max+3<=7`, and `d>=deg_F+1` (hence `d>=8`) suffices for the proof's individual-degree bound. No numerical test establishes soundness. | SKETCH | C2,C8 | — | n/a | — |
```

**Also for the orchestrator (NOTE (g)):** applying the C3 row above removes the last DAG row whose
statement the campaign's own measurements refute.

---

## 4. Trajectory

r1: 13 MAJOR / 11 MINOR / 7 NOTE. r2: 3 MAJOR / 2 MINOR / 4 NOTE. r3: **1 MAJOR / 2 MINOR / 3 NOTE**,
with all five r2 objections and all four r2 NOTEs verified as claimed, and both held claim rows now
authorized. Severity is still falling monotonically and the single MAJOR is not a re-overclaim: it is
a defect *created by* an over-delivery on R3 (retaining a second witness rather than merely costing
it), and its fix is a two-character change to two witness entries that also halves the fixture's
cost and repairs R7's arithmetic at the same time. No FATAL. Nothing in this round required a status
to move down.

VERDICT: FAIL(R6)
