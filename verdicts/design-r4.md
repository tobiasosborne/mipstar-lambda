# CRITIC verdict r4 — `docs/DESIGN.md`, `docs/definitions.md` (final adjudication of this design cycle)

Round 4 (adjudicate). Priors: `verdicts/design-r1.md` (FAIL, 13 MAJOR / 11 MINOR / 7 NOTE),
`verdicts/design-r2.md` (FAIL(R1,R2,R3), 3 MAJOR / 2 MINOR / 4 NOTE), `verdicts/design-r3.md`
(FAIL(R6), 1 MAJOR / 2 MINOR / 3 NOTE). Work order under review: `docs/design-repair-r3-response.md`
(3 FIXED / 0 RETRACTED / 0 DOWNGRADED / 0 RESIDUE) and `briefs/13-design-repair-r3.md`.
Scope: `git diff 8f5d3f2^ 8f5d3f2 -- docs/` — 53 changed lines in `DESIGN.md`, 14 in `definitions.md`,
plus the new response document; `git diff 0007701 HEAD -- docs/` adds nothing beyond that on top of
the r2 delta already adjudicated. `src/` and `test/` are another worker's lane and were not read.

**Method note — the recomputation is doubly independent this round.** r3's figures came from my
Julia scratch implementation. For r4 I discarded it and wrote a *new* implementation from scratch in
Python (packed-integer 16-variable sparse arithmetic over `Z` with a `mod 2` image, a fresh
zero-basis divider, and fresh `GF(2^3)`/`GF(2^11)` carry-less arithmetic), driven only by
`DESIGN.md` §5's circuit text and by `gt-10-answer-reduction.tex` (`fig:pcpverifier` step 3,
`prop:zero-basis`). Scratch:
`/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-.../scratchpad/critic-design-r4/`
(`tb0.py`, `tb0b.py`, `out2.txt`). No code from `src/`, from the design, or from my r2/r3 scratch was
used. Where the two implementations overlap they agree to the last digit, so the 788,032 / 534,912
figures the design now carries as "external" are no longer single-implementation.

**Standing credit is preserved.** r1's and r2's resolution of all 95 `gt-NN:Lx-Ly` citations still
holds; this round I resolved only the four citations the repair added or reused
(`gt-12:L26-L39`, `gt-10:L200-L205`, `handoff.md:L21-L35`, `handoff.md:L21-L39`). M1--M13, m14--m24,
n25--n31, R1--R5 and NOTEs (a)--(d) are not re-litigated.

---

## 0. Recomputation (brief obligation)

Fixture re-derived from scratch: **128 present / 896 absent** clauses; **512** satisfying five-block
witnesses, all and only those with `a_1[1]=1`; gadget term counts `[6,6,6,7,7,7]` (three NOT with six
terms, three AND with seven), product bound `6^3*7^3 = 74,088`; `support(F_arith) = 27,489` over `Z`
(18,620 in char 2) and

```
occ(F_arith) = inddeg(F_arith) = (2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3)   over Z and over char 2.
```

### 0.1 The new witness (ii) `([0,1],[0,1],[0,1],[0,1],[0,1])`

| assertion in `DESIGN.md` §5 / §5.1 item 6 / the proposed C3 row | my r4 recomputation | verdict |
|---|---|---|
| is one of the 512 satisfying witnesses | `True` (membership tested against the enumerated set, not against the `a_1[1]=1` rule) | **CONFIRMED** |
| every `g_i = X_i` non-constant | `g_i = X_i`, support 1, for all five `i` | **CONFIRMED** |
| `Dependencies(g_i) = {X_i}` exactly, no other block | support-computed: `g_i` touches coordinate `i` at exponent 1 and nothing else | **CONFIRMED** |
| `c_0` structural = actual = `(3,1,1,1,3, 3,1,1,1,1, 6,4,4,4,4,3)` | identical over `Z` and over char 2 | **CONFIRMED** |
| `inddeg(c_0) = 6` | 6 | **CONFIRMED** |
| `r = 0` and `c_0 = sum_j c_j zero(z_j)` | remainder is the zero polynomial; the identity was verified coefficientwise by re-expanding `sum_j c_j*zero(z_j)` and comparing dictionaries | **CONFIRMED** |
| every quotient `inddeg(c_j) <= 6 <= d` | `inddeg(c_j) = [6,-,-,-,5,5,-,-,-,-,4,4,3,4,3,1]`, `max = 6` | **CONFIRMED** |
| normalized support 788,032 over `Z` / 534,912 in char 2 | **788,032 / 534,912**, measured in 1.2 s by the new implementation | **CONFIRMED (second, independent implementation)** |

Quotient supports for the new witness: `[399616,0,0,0,183600,142776,0,0,0,0,107856,10416,2560,2944,1440,576]`
— the same seven-zero / nine-nonzero split (`c_2,c_3,c_4,c_7,c_8,c_9,c_10` zero) as witness (i), with
all six `W` quotients nonzero.

Witness (i) cross-check (unchanged text, re-measured only to keep the two witnesses comparable):
support 49,252 over `Z` / 33,432 in char 2, `inddeg` vector `(3,0,0,0,2, 3,1,1,1,1, 6,4,4,4,4,3)`,
`r = 0`, quotient supports `[24976,0,0,0,6232,9945,0,0,0,0,7407,713,176,208,90,36]` — byte-for-byte
the r2/r3 numbers, from new code.

### 0.2 Mutation B at `b_rho[O2 <- rho]` — the brief's named obligation

`b_rho = (X=(0,0,0,0,0), O=(1,1,1,1,1), W=(rho,0,0,0,0,rho))`, `O_2` reset to `rho`, `rho = x`
(verified primitive: order 7 in `GF(8)` under `x^3+x+1`, order 2047 in `GF(2^11)` under `x^11+x^2+1`).

Hand derivation, gadget by gadget, as a second path to `F_arith(b_rho)`:
`EQ(NOT x1, w1) = rho`, `EQ(NOT w1, w2) = rho`, `EQ(NOT w1, w3) = rho`, `EQ(w2 AND w3, w4) = 1`,
`EQ(w4 AND o1, w5) = 1`, `EQ(w5 AND x5, w6) = 1-rho`, times the conjoined output literal `w6 = rho`,
giving `rho^4(1-rho) = rho^4(1+rho)` in characteristic two — exactly the design's §5.1 item 5 value.

Machine evaluation of the *expanded* 788,032-term `c_0` (not the factored form) at that point:

| field | `F_arith(b_rho)` | honest `beta_0` | mutated `beta_0` (B removes `g_2-o_2`) | verifier RHS | B red-capable? |
|---|---|---|---|---|---|
| `GF(8)` | `1 = rho^4(1+rho)` | **2** `= rho^5(1+rho)` | **1** | 2 | **yes** — RHS = honest ≠ mutated, both nonzero |
| `GF(2^11)` | `48 = rho^4(1+rho)` | **96** `= rho^5(1+rho)` | **48** | 96 | **yes** |

The two `beta_0` values the brief asks for are therefore **2 (honest) / 1 (mutated) in `GF(8)`** and
**96 (honest) / 48 (mutated) in `GF(2^11)`**, matching `DESIGN.md` §5.1 exactly. The verifier RHS,
recomputed independently from the claimed `alpha_i = g_i(x_i)` rather than from `c_0`, equals the
honest value in both fields, so the mutated proof is rejected.

### 0.3 The R6 collapse is fully cured, not merely relocated

The deeper half of R6 was that under the old tuple `c_0` vanished identically on **all sixteen** named
`GF(8)` coordinate lines `S_j = {z : z_j in GF(8), z_l = (b_rho)_l for l != j}`, making the whole
TB0-small named scope a `0 = 0` check. Re-running that sweep (16 lines x 8 points = 128 points):

- new witness `([0,1])^5`: `c_0` is **not** identically zero on **16 of 16** lines, and
  `c_0(b_rho) = 1 != 0` in `GF(8)` — every line passes through `b_rho`, so non-vanishing there alone
  forces all sixteen;
- old witness `([0,1],[1,0],[0,1],[1,0],[0,1])`, re-run for contrast: **0 of 16**.

`b_rho[O2 <- rho]` lies on `S_7` (the `O_2` line) and `rho in GF(8)`, so mutation B's separator is
inside the named scope §5.1 item 5/6 actually exhausts — the mutation has a checker that visits it.

---

## 1. Disposition audit

| id | claimed | my verification | verdict |
|---|---|---|---|
| **R6** | FIXED | The tuple is `([0,1],[0,1],[0,1],[0,1],[0,1])` at every load-bearing site: §5 bullet (ii) (`DESIGN.md:742`), §5.1 item 6 (`:833`), the mutation-B paragraph (`:845-848`), the DIRECTIVES, and the proposed C3 row. `grep` finds **zero** surviving occurrences of the old tuple, of `a_2=[1,0]`/`a_4=[1,0]`, or of the withdrawn 1,773,072 / 1,203,552 figures anywhere in `docs/`. §5.4 (`:891`) names "witness (ii)" symbolically and so needed no edit. The dead parenthetical "`g_2(0)-O2=1-rho`, while the omitted factor changes it to 1" is gone, replaced by a derivation that is correct in every step I checked: five factors `X_i-O_i`, honest product `rho`, mutated product `1`, `F_arith = rho^4(1+rho) != 0`, hence `beta_0` honest `rho^5(1+rho)` vs mutated `rho^4(1+rho)`, numerically 2/1 and 96/48. All of §0.1--§0.3 above is my own recomputation and every displayed figure matches. | **VERIFIED — the MAJOR is discharged** |
| **R7** | FIXED | The `2^5` is no longer asserted; §1.3 (`:245-248`) now *derives* the factor cardinality from its own bound `support(g_i)+1` — `[0,1]` gives the binomial `X_i-O_i` (support 2), `[1,0]` the trinomial `1-X_i-O_i` (support 3) — and states the counterfactual `2*3*2*3*2 = 72`, `6^3*7^3*72 = 5,334,336`, which is exactly what R7 demanded be written for the *old* tuple. I re-derived all three products: `6^3*7^3 = 74,088`; `74,088*72 = 5,334,336`; `74,088*(1+1)^5 = 2,370,816`. Because R6 was repaired by adopting the binomial-only witness, `2,370,816` is now the correct §1.3 estimate, as R7's fix demand explicitly allowed. R7's second half — record the predicted peak next to the estimate — is honoured in **all four** places the objection named: §1.3 `:252`, §5 `:782-783`, the TB0-small table cell `:789` (`(ii) estimate 2,370,816 / peak 788,032 / measured TBD`), and §5.5 `:914-915`. My incremental candidate sequence in the design's build order is `[6,36,162,756,3927,27489,27489,54978,98504,197008,394016,788032]`, so the **peak single product is 788,032**, 31.5% of the retained `MonomialBudget=2,500,000`; no `ExpansionRefused` occurs. Witness (i)'s retained peak 54,978 (34.4% of 160,000) also re-measured and confirmed. The §1.3 bound itself is sound: with the *measured* `support(F_arith)=27,489` it gives `879,648 >= 788,032`, and the coarse form overshoots the measurement by 3.0x. | **VERIFIED** |
| **R8** | FIXED | R8's fix demand was: declare `M` and `L`, type `FuelBound` accordingly, and use one spelling of `L`. All three are done. `MachineDesc` and `Level` join the finite-serializable-data list (`:21`); `Fuel ::= FuelLiteral(Nat) \| FuelBound(P{Nat},P{Level})` (`:27`); a new sentence (`:73-76`) assigns `M:P{MachineDesc}`, `L:P{Level}`, `n:P{Nat}`, `S_L:ClosedProgram{Sampler}`, `Compress:ClosedProgram{Compressor}` and identifies `halts_within`, `true`, `quoted_pair` as declared `PrimName`s and `self_code` as the typed hole; the redundant `Quote(L)` is gone, so `L` has one spelling in the term (`:83`, `:85`). `definitions.md` gains `MachineDesc`, `Level`, `Compressor` and `L (fixed-point context)` rows and amends `n`, `Fuel`, `S_L`, `M`, `Compress` (`:21`, `:151-153`, `:157`, `:163`, `:167-169`). I checked the free-symbol claim by enumerating the display: `M, L, n, x, y, a, b, S_L, Compress, self_code, halts_within, true, quoted_pair, Concrete, Opaque, Quoted, Decider` — all seventeen are now declared (`Decider` at `definitions.md:57`, `Sampler` at `:93`). Both new citations resolve: `gt-12:L26-L39` is `thm:compression`, whose input is a pair `(V, lambda)` with `lambda > 0` an integer, which is exactly a `Level`; `gt-10:L200-L205` is `def:BoundedHalting`, whose tuple begins with a machine description `alpha`, which is exactly a `MachineDesc`. | **VERIFIED as to the fix demand — but the new `P{A}` discipline is asserted rather than derivable at two nodes: R9, R10** |

**Lockstep audit.** No status moved anywhere. `claims/CLAIMS.md` is untouched since `4ab7d32` and its
C3/C5 rows are byte-identical to the r3 authorizations (diffed). The response promotes nothing and
declares RESIDUE none, which matches the diff. The repair stayed inside its lane
(`docs/DESIGN.md`, `docs/definitions.md`, `docs/design-repair-r3-response.md`) and correctly routed
the C3 change to a MERGE PROPOSAL section instead of editing the DAG itself. One cosmetic
inaccuracy: the response's R6 row lists `§5.4` as an edit location, but no hunk lands there (none was
needed). Not an objection.

---

## 2. New objections (changed text only; 0 MAJOR, 2 MINOR)

Both are in the same family as M7 -> R5 -> R8: the flagship fixed-point display keeps producing one
residual sort obligation per round, each time in a different node. Neither blocks the round — no
claim in the DAG depends on the display, and both fixes are local.

### R9 · MINOR — `n : P{Nat}` is not derivable: `Lambda(arity,P)` carries no argument sorts, so the newly typed `FuelBound(n,L)` is still asserted rather than checked
**Location** `DESIGN.md:73-76` ("`n:P{Nat}` and `x,y,a,b` are the five bound arguments"), `:27`
(`FuelBound(P{Nat},P{Level})`), `:85` (`FuelBound(n,L)`); `definitions.md:21` ("In `Psi_{M,L}`, its
bound occurrence has term sort `P{Nat}`"). Both sentences are new text.

**Independent analysis.** The repair's own definition at `:45` is *"`P{A}` denotes the subset of
program terms whose **constructor/primitive contracts** give result sort `A`."* `n` is not a
constructor application or a primitive: it is the first de Bruijn slot of `Lambda(5, ...)`. The
grammar at `:33`/`:35` is `BoundVar(depth, slot)` and `Lambda(arity, P)` — `arity` is a number, there
is no argument-sort vector, and `BoundVar` carries no sort field. So no rule of the stated system
derives `n : P{Nat}`; the sentence stipulates it. This is load-bearing precisely because it is the
first argument of `FuelBound`, whose well-sortedness was R8's entire object: the repair moved the gap
from `L` (now genuinely a declared literal term) to `n`. The same stipulation is doing the work for
`x,y,a,b` in the `Pargs` slot, where it is harmless because `Pargs ::= P*` is sort-agnostic.

**FIX DEMAND.** Give `Lambda` an argument-sort vector (`Lambda(sorts, P)` with
`sorts : Sort*`, `arity = |sorts|`) so that `BoundVar(d,s)` inherits `P{sorts[s]}`, or state a
typing-context rule for `BoundVar` and extend `P{A}`'s definition beyond "constructor/primitive
contracts" to cover it. One line in the grammar plus one in `definitions.md`'s `Fuel` row.

**SURVIVING STATEMENT.** With `MachineDesc`, `Level`, `Compressor`, `Pargs`, `Fuel`, the nullary-
literal convention and the single spelling of `L`, every *free* symbol of `Psi_{M,L}` is declared and
`FuelBound`'s two argument sorts are fixed — which is what R8 demanded. What remains undischarged is
the derivation that the *bound* occurrence `n` meets the first of them.

### R10 · MINOR — `Apply(Quote(Compress), ...)` applies a value of sort `Quoted{Compressor}`; the repair removed the redundant quote around `L` but left the ill-sorted one around `Compress`
**Location** `DESIGN.md:82-84`, read against the new sort assignment `Compress:ClosedProgram{Compressor}`
at `:73-76` and the new `Compressor` row at `definitions.md:153`.

**Independent analysis.** `Quote(Closed(P))` is defined at `:40`/`:56` as "syntax as a value", with
`Quoted{A} = canonical bytes for a closed P : A`. `Apply(P, P*)` needs a head whose result sort is a
function sort; `Quote(Compress)` has result sort `Quoted{Compressor}`, i.e. bytes. Running bytes is
what `Eval(Pcode, Pargs, Fuel)` exists for — the document's own phase separation ("an evaluator
closure is a runtime value, never accepted by compilation") is exactly the invariant being crossed.
The asymmetry inside the one display makes the slip visible: `Quote(S_L)` is *correct* (Compress
consumes the sampler as a description, per `gt-12:L26-L39`), `Quote(L)` was *removed* by this very
repair as redundant, and `Quote(Compress)` is the third quote — the one that is neither. Before the
repair `Compress` had no declared sort and the node was unfalsifiable; the new sentence is what makes
it checkable, so this is the new text's own obligation, exactly as R8 was.

**FIX DEMAND.** Write `Apply(Compress, Prim(quoted_pair, ...), L)` (Compress is already a
`ClosedProgram`, so no quote is needed to place it in head position), or, if the intent is to run the
compressor from its description, `Eval(Quote(Compress), (pair, L), FuelBound(n,L))`. Pick one and say
which in `definitions.md`'s `Compress` row.

**SURVIVING STATEMENT.** `D_M_L = Fix(Psi_M_L)` is still a finite closed term expressing
`handoff.md:L21-L39`'s fixed point, every free symbol is declared, and the argument positions
(`quoted_pair` over `Quote(S_L)` and `Hole(self_code,Quoted{Decider})`, `Pargs = (n,x,y,a,b)`,
`Fuel = FuelBound(n,L)`) are all well-formed. Only the head of the `Apply` is at the wrong phase.

### NOTEs (no fix demanded)

- **(h) The per-multiplication budget rule is still load-bearing — via witness (i), not witness (ii).**
  R4/R7 worried that the estimate/budget juxtaposition invites a cumulative reading. For the new
  witness (ii) the cumulative candidate sum is **1,592,403 < 2,500,000**, so that witness alone no
  longer discriminates the two readings (the old tuple's 3,217,719 did). Witness (i) still does:
  its cumulative sum is **311,851**, nearly twice its 160,000 budget, while its peak is 54,978. So an
  implementation that read `MonomialBudget` cumulatively would refuse `Pi_deg` and be caught. §1.3's
  sentence "The budget is not a cumulative sum across multiplications" therefore remains testable at
  TB0; worth an explicit assertion in the TB0 harness rather than leaving it implicit.
- **(i)** The new `Compressor` row says the transformation "returns a decider description", while its
  own citation `gt-12:L26-L39` says `Compress` outputs a 9-level normal form verifier
  `V^compr = (S^compr, D^compr)` — a *pair*. The mandate's `D_{Compress((S_L,d),L)}` projects the
  decider, and `lem:compress-independent-samplers` makes `S^compr` verifier-independent, so the
  narrowing is defensible; it is nonetheless a narrowing of the cited interface, not a restatement.
- **(j)** `DESIGN.md:784` tags the external counts `**MEASURED external**`. "MEASURED" is not one of
  §1's five grades (`CONSTRUCTED/CHECKED/CITED/ASSUMED/SOURCE_REPAIR`). The wording is inherited from
  r2 text, and the guard rails around it ("pending TB0 confirmation", "rather than treating those
  figures as locally confirmed") are exactly right; only the tag is off-enumeration.
- **(k) A coverage trade-off I own.** Five identical `[0,1]` tables make the five PCP factors
  identical in form, so the `c_0` path no longer exercises a complement table. §5.1 item 2 still
  extends both `[0,1]` and `[1,0]` in the extension-function test, and mutation F
  (`a_3 = [0,1] -> [0,0]`) still turns the all-nonconstant/exact-dependency checker red, so the loss
  is bounded. I recommended this witness in r3 and record the trade-off rather than object to it.
- **(l)** r3's NOTE (g) is **cured**: `claims/CLAIMS.md` C3 no longer carries the refuted
  "individual degree <= 2 / <= 3" text. NOTEs (e) and (f) stand un-actioned, as intended — neither
  demanded a fix.

---

## 3. Adjudication of the C3 tuple substitution (brief obligation)

**AUTHORIZED — apply the response's row verbatim; no new adjudication is required, exactly as the r3
scoping note provided for.**

I diffed three strings character by character: the r3-authorized C3 row, the row currently committed
in `claims/CLAIMS.md`, and the row proposed in `docs/design-repair-r3-response.md`.

- committed row == r3-authorized row: **True** (byte-identical; `4ab7d32` applied it verbatim);
- proposed row == r3-authorized row with only `([0,1],[1,0],[0,1],[1,0],[0,1])` -> `([0,1],[0,1],[0,1],[0,1],[0,1])`:
  **True**. The character diff is exactly two `1,0` -> `0,1` transpositions and nothing else.

Every figure the row displays for the non-degenerate witness is confirmed by §0.1 above for the new
tuple: `Dependencies(g_i)={X_i}` exactly with all `g_i` non-constant; `c_0` structural = actual =
`(3,1,1,1,3,3,1,1,1,1,6,4,4,4,4,3)`; `inddeg(c_0)=6`; and `inddeg(c_i)<=6<=d` for all sixteen
quotients (`max = 6`, with equality at `d=6` on TB0-small and slack at `d=11` on TB0-sampled). The
witness-(i) half of the row is unchanged and re-measured: `F_arith` vector, `c_0` vector, `r=0`,
`max_i inddeg(c_i)=6<=d`, and exactly `c_2,c_3,c_4,c_7,c_8,c_9,c_10` zero with the stated reason
`deg_j(c_0)<=1`. Status stays **CONJECTURE**; nothing in this round promotes it.

**Orchestrator action (lockstep).** `claims/CLAIMS.md:10` still names the old tuple while `docs/`
names the new one. That divergence is the expected consequence of the repair worker's lane excluding
`claims/`, and it is closed by applying the row above verbatim. Until it is applied, the DAG and the
design disagree about which witness carries C3's block-dependency evidence.

**Directives for TB0 (confirming the response's three, with two additions).** The response's
DIRECTIVES 1--3 are accepted as written. Add: (4) assert the sixteen named `GF(8)` lines are
non-vacuous for witness (ii) — `c_0(b_rho) != 0` suffices, and it is the assertion that would have
caught R6 automatically; (5) assert the cumulative-vs-per-multiplication distinction of NOTE (h) at
witness (i), where alone it is now observable.

---

## 4. Trajectory and verdict

r1: 13 MAJOR / 11 MINOR / 7 NOTE. r2: 3 MAJOR / 2 MINOR / 4 NOTE. r3: 1 MAJOR / 2 MINOR / 3 NOTE.
r4: **0 MAJOR / 2 MINOR / 5 NOTE**, with all three r3 objections verified FIXED by fresh
recomputation on a second independent implementation, both held claim rows already authorized, and
the C3 substitution adjudicated. Severity has fallen monotonically to zero MAJOR: 13 -> 3 -> 1 -> 0.
No FATAL at any round. No status moved up in this round, and none moved down; nothing was
re-overclaimed. The two surviving MINORs are the same recurring sort-discipline residue in the
fixed-point display, now narrowed to one grammar line (`Lambda`'s argument sorts) and one node
(`Apply`'s head) — both local, neither load-bearing for any DAG row.

Per rk-light's convergence rule (a verdict with no FATAL and no MAJOR closes the loop), this design
cycle has converged. R9 and R10 should be filed as tracked issues and folded into the next
substantive edit of §1.1, not made the occasion for another round.

VERDICT: PASS
