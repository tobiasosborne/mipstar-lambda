# Verdict — DESIGN v2 (`docs/DESIGN.md` §9–13, `docs/definitions.md` §§G–H), round 3

Critic: Opus subagent, adversarial lane. Target: **archived tree at commit `dd4cf82`**
(`git archive dd4cf82 | tar -x`), evaluated against `ground-truth/gt-*.tex` in that same tree
only. No Julia run; no repo file other than this verdict written; no state-changing git command.

Priors: `verdicts/design-v2-r2.md` (N1, N2 MAJOR; m1–m11; §4 C14 HOLD conditions; §5 C12/C13/C15
authorizations). Work order: `docs/design-v2-repair-r2-response.md` (FIXED 12 / DOWNGRADED 1 /
RESIDUE 0) under the binding directives of `briefs/34-design-v2-repair-r2.md`.

**Round-3 discipline.** r2's ACCEPTED rows (O1–O10, O11–O21, r1-N1…r1-N6, the three offered
mutations, MP-*) are *not* re-litigated. Attack is scoped to
`git diff d60198f..dd4cf82 -- docs/DESIGN.md docs/definitions.md` (312 diff lines; every changed
DESIGN line is at or after L1108, i.e. inside §9–13 — lane respected) plus
`claims/CLAIMS.md` as it stands after the orchestrator's merge commit `83726be`. Lane audit:
`dd4cf82` touches exactly `briefs/34-design-v2-repair-r2.last.md`, `docs/DESIGN.md`,
`docs/definitions.md`, `docs/design-v2-repair-r2-response.md` — the proposer did **not** edit
`claims/`, `src/`, `test/`, or `docs/analytic/`. Confirmed by `git show --name-only dd4cf82`.

**Numbering.** r2's residual minors were `m1`–`m11`; this round continues at `m12`. New MAJOR
objections would be `N3`, `N4`, …; **there are none** (§3).

---

## 1. Per-row adjudication

"ACCEPTED" = the r2 FIX DEMAND is met on independent recomputation. "PARTIAL" = substance landed,
named residue remains. "REJECTED" = the FIX DEMAND is not met.

### MAJOR rows

| id | claimed disposition | adjudication | one line |
|---|---|---|---|
| **N1** | DOWNGRADED | **ACCEPTED as a faithful weaker statement (law 5), not an escape** | Fix demand (a) landed verbatim — §11.4 L1477 declares the unit ("one metered quoted-interpreter step", with input decoding / control flow / primitive bit ops / output serialization charged, and explicitly *not* a whole vector op, matrix multiply, or child call) and pins the boundary ("rejects before executing step `R+1`; a return at step `R` is permitted"). Fix demand (b) took the second of the two routes r2 itself offered: `F_child=65,536` with `toy_child_fuel=FAIL(owner=tb6-child-meter)` printed for the failed production equality `F_child=R` at both fixtures, never a PASS. (c) is converted into a *required report slot* (§11.6 L1591–L1603, ten fixture×mode rows) whose values are `NOT_EVALUABLE(owner=tb6-child-meter)` because no metered interpreter exists — the only truthful option; inventing a number would have been the escape. (d) landed: C14's acceptance clause is now explicitly conditional. Escape audit in §2.5: **no PASS anywhere in §11.6, §12.4 or §13.3-C14 depends on an unmeasured cost.** The repair also implements r2's own SURVIVING WEAKER STATEMENT precisely — timeout placement, exact-`R` fuel log and `M-intro-fuel` redness are retained as *production*-mode counter tests separate from toy honest acceptance (§11.6 mutation 12). |
| **N2** | FIXED | **ACCEPTED** | (a) §12.5 L1759/L1761 print `intro embedding Q_I>=s_0(N): 2>=9 | FAIL(owner=Q_I<s_0)` and `non-Pauli introspection answer schemas: Introspect, Sample, Read, every Hide stage (both roles) | VACUOUS(owner=Q_I<s_0)`; L1771 states `M_I=2`, `Q_I=2<s_0=9`, `3Q_I=6<9` and draws the consequence. (b) §13.2 L1842–L1846 replaces "the explicit exception" (grep: 0 hits tree-wide) with a **two-item bulleted list**, each with its owner, and says TB6b — not TB7 — is where the non-Pauli introspection predicates are exercised. (c) `M7-intro-schema` added (§12.5 #11) with a checkable killer ("zero executed-schema count"). §12 heading now reads "…with two named non-executed layers"; §12.6's `OutOfFuel` test is re-scoped as "a separately labelled synthetic evaluator-entry test, not a faithful non-Pauli transcript", closing the one route by which the VACUOUS layer could have been bypassed and counted. Coverage is exhaustive: `TypeIntro \ TypePauli = {Introspect,Sample,Read,Hide_1..Hide_ell} × {alice,bob}` is exactly the enumerated set (§2.6). |

### MINOR rows (r2 m1–m11)

| id | adjudication | one line |
|---|---|---|
| m1 | **ACCEPTED** | `definitions.md` §G: `SOURCE_REPAIR` widened to "…or a construction change that closes a source gap, **with the changed theorem input named**". §12.3 names the changed input (`sigma_1`) explicitly, so the widened gloss is discharged, not merely broadened. |
| m2 | **ACCEPTED** | §9.2 now writes `prefix_i := Marginal(i-1,x)  -- prefix_1 is the zero marginal`, and adds "the zero marginal in this notation is mathematical shorthand, not a stage-0 machine query". Verified against `gt-04-cl.tex:L169-L173`: `x^{L_{<i}} = L_{<i}(x) = L_{≤ i-1}(x)`, and `L_{<1}(x)=0` as the empty sum. Exactly right, and it avoids inventing an illegal stage-0 query. |
| m3 | **ACCEPTED** | §9.2 replaces "every branch-directed reachable prefix chain" by "a declared branch-directed chain set for larger fixtures", with "finite coverage does not quantify over unselected reachable chains"; §12.5 L1776 requires per-sampler `sampler_id`, `chain_set_id`, selected-query count, distinct-chain count and completed-replay count, with an empty set graded `VACUOUS(owner=chain-coverage)`; §13.1's TB7 cell lists the counts as required output. |
| m4 | **ACCEPTED** | §11.1 L1401 prints `Q>=s(N)` independently, with the reason ("it cannot be inferred from a capacity chain containing a failed `M>=R` link"), and both §11.6 fixtures print it: `2>=1` and `12>=6`. The same paragraph splits `TIME_child(N)<=R` from `|V|<=lambda` and cites `gt-05:L641-L653` + `gt-08:L419-L421,L983-L988` — the two-condition structure of `def:lambda` re-verified below. |
| m5 | **ACCEPTED** | `TB6b-E` now pins "deterministic one-bit child answers (`|a|=1`)", and §11.6 draws the consequence: `2Q+1 = 5 < 6 = 3Q`, so no `Read` pair joins the literal-rejection count. Recomputed in §2.1 over *all* type schemas, not just `Read`. |
| m6 | **ACCEPTED** | §11.6 L1574 prints `TB6b-M`'s admissibility (`8=2^3`), `m|q` (`2|8`), `d=1`, embedding (`12>=6`) and the canonical obstruction *with the derivation*: `ceil(log2 log2 16)=2` ⇒ `2c+1=3` ⇒ `c=1` (forbidden, odd), and even at `c=1`, `m=4≠2`; at the least allowed `c=2`, `m=8≠2`. Independently recomputed in §2.2 — the design's numbers are exact and strictly more complete than r2's own m6 note. |
| m7 | **ACCEPTED** | `T6-view-swap` is enrolled in §11.6's mandatory negative set (L1585) with its exact construction, mutation 11 now cites it, and §13.1's TB6b required-output cell lists it. Killer re-verified in §2.7. |
| m8 | **ACCEPTED** | §9.6 L1258 adds `pauli_sampler`, `tilde_S_intro`, `graph_sampler` to the signatures for which the output-sampler PROVE row is mandatory. |
| m9 | **ACCEPTED** | §11.4 L1481: "The non-Pauli encoding **transcribes the source's own wire format** (`gt-08-introspection.tex:L525-L531`)", and the `IntroAnswerEncoding` §H row is rewritten to match, adding the `Q_EPR>=s(N)` requirement and the TB7 violation. |
| m10 | **ACCEPTED** | §12 heading: "TB7 — Compress and the halting fixed point, **with two named non-executed layers**". Tree-wide grep: the only surviving "end-to-end" is inside DD-28's rationale sentence, where it is descriptive of the ambition, not a result claim. |
| m11 | **ACCEPTED** | `anchored_repeat(v,lambda,tau)` §H row added; its content (pre-anchoring input, `ell+2`, `k(n)(s(n)+8)`, "internal `repeat_sampler` … adds no level") matches DESIGN §9.4 L1170–L1172 word for word in substance. |

**Row count: 13 ACCEPTED, 0 PARTIAL, 0 REJECTED.** The single DOWNGRADE (N1) is one of the two
routes r2's own FIX DEMAND authorized and is the strictly weaker of them (it never claims a
source-fuel acceptance, whereas the `lambda=8` route would have). Law 5 satisfied; the stronger
statement is filed under owner `tb6-child-meter` / issue `mipstar-lambda-9w7`.

---

## 2. Recomputations, in full

Everything below is recomputed from the archived `ground-truth/gt-*.tex`, not from r1/r2 and not
from memory.

### 2.0 The ground truth cited by N1/N2, re-read

```
gt-08-introspection.tex:L417-L419   "In the following, whenever S or D is called as a subroutine,
                                     D-hat^intro aborts and rejects if the subroutine takes more
                                     than N^lambda time steps."
gt-08-introspection.tex:L424-L425   "The decider rejects if s(N) > N^lambda, or if [edited:]
                                     max{|a_A|,|a_B|} >= 3 * 2^m * log q"
gt-08-introspection.tex:L524-L530   "Since V is isomorphic to F_2^{s(N)} ... the space V is
                                     identified in a canonical way as the register subspace of
                                     F_2^Q spanned by e_1,...,e_{s(N)} ... For example, if
                                     tau_w = (Read,role), then syntactically the player's answer
                                     is a triple (y,y^perp,a) in F_2^Q x F_2^Q x {0,1}^*."
gt-08-introspection.tex:L588-L591   "...Either way, the maximum answer length should be
                                     3Q = 3 * 2^m * log q = poly(R) bits long."
gt-08-introspection.tex:L983-L988   eq:intro-complexity-assump:
                                     max{TIME_S(N), TIME_D(N)} <= N^lambda = R ;
                                     "This assumption ... ensures that D^intro never aborts due
                                     to a timeout."
gt-05-games-normalform.tex:L641-L653 def:lambda, TWO conditions:
                                     (i) TIME_S(n), TIME_D(n) <= n^lambda for n >= 2;
                                     (ii) |V| <= lambda.
gt-07-ldt.tex:L1503-L1514           def:introparams: c = smallest EVEN integer >= (b+a)/b;
                                     q = 2^k, k = c*ceil(log log R)+1;
                                     m = 2^j with 2^j <= c*ceil(log R)+1 < 2^{j+1}; d = 1.
```

Two consequences I re-derive rather than accept:

* The fuel gate is **executable and separate from `def:lambda`(ii)**: `L417-L419` is a runtime
  abort, `L652` is a byte-size condition. §11.1's insistence that "neither a size check nor
  `s(N)<=R` discharges a child timeout" is therefore exactly right, and the design's split of the
  two into distinct printed predicates is the correct transcription. **Confirmed.**
* `def:introparams` forces `c` **even** and `c >= 2` (since `(b+a)/b = 1 + a/b > 1`). Both TB6b
  canonical-equality FAILs below turn on this. **Confirmed.**

*Citation nit (see m16):* DESIGN and definitions cite the fuel gate as `L419-L421`; the sentence
is `L417-L419` (`L419` alone holds only "`$N^\lambda$ time steps.`"). Likewise the wire format is
`L524-L530`, not `L525-L531`. Both ranges were inherited verbatim from my own r2 verdict, so this
is my residue, not the proposer's; it is off by ≤ 2 lines and points at the right sentence.

### 2.1 `TB6b-E`, recomputed end to end

`n=2, N=4, lambda=1, ell=1, s(N)=1, (q,m,d)=(2,1,1)`:

```
R  = N^lambda      = 4^1              = 4      (design: 4)     OK
M  = 2^m           = 2^1              = 2      (design: 2)     OK
Q  = M*log2 q      = 2*1              = 2      (design: 2)     OK
3Q                 = 6                          (design: 6)     OK
|TypeIntro|        = 32+2*ell = 32+2  = 34      (design: 34)    OK
oriented pairs     = 6*ell+110 = 116            (design: 116)   OK
typed downsized s  = (3m+3)*log2 q = 6*1 = 6    (design: 6)     OK
detyped s          = 6 + 4*34 = 142             (design: 142)   OK
tableau qubits     = 2(Q+1) = 6                 (design: 6)     OK
R>=4               4>=4   PASS   (def:introparams requires R>=4)           OK
admissible field   q=2=2^1, k=1 odd (gt-03 L664-L666)  PASS                OK
m|q                1|2    PASS                                             OK
s(N)<=R            1<=4   PASS                                             OK
M>=R               2<4    FAIL   (lem:delta-bound predicate)               OK
M<=Q               2<=2   PASS                                             OK
Q>=R               2<4    FAIL                                             OK
Q>=s(N)            2>=1   PASS   (the F_2^Q embedding, printed separately) OK
canonical introparams(4):  ceil(log2 log2 4)=1 => k=c+1; q=2 => k=1 => c=0,
                           forbidden (c even, c>=2).                FAIL   OK
```

**Literal-rejection count `10/116`, recomputed from the graph and from *every* answer schema.**
`G^intro` non-loop edges at `ell`: inherited Pauli `30`, plus per role
`{Sample–Introspect, Introspect–Read, PauliX–Hide_1, PauliZ–Sample, Hide_ell–Read}` and
`Hide_k–Hide_{k+1}` for `k=1..ell-1`, plus the single `IntrospectA–IntrospectB`; total
`30 + 2(ell+4) + 1 = 2ell+39`. Loops `= |TypeIntro| = 32+2ell`. Oriented
`= 2(2ell+39) + 32+2ell = 6ell+110`. At `ell=1`: `116`. **Confirmed.**
`Hide`-incident non-loops: `PauliX–Hide_1` (2) + `Hide_1–Read` (2) + chain (0) `= 4`; `Hide`
loops `= 2ell = 2`; oriented `= 2*4 + 2 = 10`. **Confirmed.**

The count is *exactly* 10 only if no other honest answer reaches `3Q=6` at `Q=2`. Checking every
schema at `|a|=1`: `(Hide_k,role) = 3Q = 6` (rejected by literal `>=`); `(Read,role) = 2Q+|a| = 5`;
`(Introspect,role) = (Sample,role) = Q+|a| = 3`; Pauli-typed answers live in `F_2^{M log q} = F_2^2`
(`cor:pauli-binary`), and a degree-`d=1` line answer over `F_2` is 2 bits; Magic-Square /
Constraint / Variable answers are ≤ 3 bits. **All `< 6`; the count is exactly 10.** r2's m5 caveat
is fully discharged.

### 2.2 `TB6b-M`, recomputed end to end

`n=2, N=4, lambda=2, ell=3, s(N)=6, (q,m,d)=(8,2,1)`:

```
R = 4^2 = 16 (design 16) ; M = 2^2 = 4 (4) ; Q = 4*3 = 12 (12) ; 3Q = 36 (36)
|TypeIntro| = 32+6 = 38 (38) ; oriented = 6*3+110 = 128 (128)
  cross-check 2(2*3+39) + 38 = 90+38 = 128                            OK
typed downsized s = (3*2+3)*log2 8 = 9*3 = 27 (27)
detyped s = 27 + 4*38 = 179 (179) ; tableau = 2(12+1) = 26 (26)
R>=4 16>=4 PASS ; admissible q=8=2^3, k=3 odd PASS ; m|q 2|8 PASS ; d=1 PASS
s(N)<=R 6<=16 PASS ; M>=R 4<16 FAIL ; M<=Q 4<=12 PASS ; Q>=R 12<16 FAIL
Q>=s(N) 12>=6 PASS ; dm/q = 1*2/8 = 1/4 < 1/2  (margin live)
```

**Canonical `introparams(16)` obstruction, recomputed exactly as the brief requires.**
`ceil(log2 log2 16) = ceil(log2 4) = 2`, so `k = 2c+1`. The fixture has `q=8=2^3`, i.e. `k=3`,
which forces `c=1` — **odd, hence forbidden**. Evaluating `m` anyway:

* at `c=1`: `c*ceil(log2 16)+1 = 1*4+1 = 5`; largest power of two `<= 5` is `4`, so **`m=4`**, not 2.
* at `c=2` (least allowed even): `2*4+1 = 9`; largest power of two `<= 9` is `8`, so **`m=8`**, not 2.

**Both branches contradict `m=2`.** The design's sentence and the response's arithmetic paragraph
are exactly this. `c=1 -> m=4`, `c=2 -> m=8`: **confirmed, no disagreement.**

**Literal-rejection count `22/128`.** `Hide`-incident non-loops: `PauliX–Hide_1` (2) +
`Hide_3–Read` (2) + `Hide_k–Hide_{k+1}`, `k∈{1,2}`, per role (4) `= 8`; `Hide` loops `= 2ell = 6`;
oriented `= 2*8 + 6 = 22`. **Confirmed.** With `TB6b-M`'s zero child answers, `Read = 2Q = 24 < 36`,
Pauli answers `= 12 < 36`, a degree-1 line answer over `F_8` is `2*3 = 6 < 36`; so 22 is exact.

### 2.3 TB7, recomputed end to end

Toy tuple (§12.5 L1744–L1748): `intro (q_I,m_I,d_I)=(2,1,1)`;
`AR (q_A,m_A,d_A,s_A,m'_A) = (2^11,1,11,6,16)`; `mu=gamma=tau=c'=1`; `repetitions_toy=2`;
`s_0=9`, `n=2`, `N=4`, `lambda=32768`.

```
M_I = 2^1 = 2 ; Q_I = 2*log2 2 = 2 ; 3Q_I = 6 ; s_0(N) = 9
  => Q_I >= s_0 is 2>=9 FAIL ; 3Q_I = 6 < 9                             OK
|TypeIntro| at ell=9 = 32+18 = 50 ; |TypeAR| = 3*18 = 54
s_1 = (3m_I+3)log q_I + 4*50 = 6 + 200            = 206                 OK
s_2 = s_1 + (2m'_A+6)*log2 q_A + 4*54
    = 206 + (2*16+6)*11 + 216 = 206 + 38*11 + 216 = 206+418+216 = 840    OK
anchored = s_2 + 8                                = 848                  OK
final    = k_toy*(s_2+8) = 2*848                  = 1696                 OK
levels   9 --Introspect--> 5 --AR/detype--> max(5+2,5)=7 --Anchor/detype--> 9
           --direct-sum Repeat--> 9                                      OK
largest line answer (m'+6)(m'd+1) = 22*177 = 3894 symbols = 3894*11
                                            = 42,834 bits               OK
16 questions 16*1696 = 27,136 bits ; 2*42,834 = 85,668 bits ;
   total 112,804 bits = 14,100.5 B ~= 0.0134 MiB ("about 0.014 MiB")     OK
Repeat component guard B = (lambda*n)^tau = 65,536 > 42,834               OK
k_toy = 2 vs production (lambda*n)^((1+c')tau) = 65,536^2  => FAIL        OK
dense c_j route 12^16 = 1.848e17 ("~= 1.8e17")                           OK
```

**`9->5->7->9` and `206->840->848->1696` confirmed; no disagreement with the response.** Note the
chain survives the `s_0 = 1 -> 9` fixture change precisely because Introspect resets the output
dimension (`s_1` is a function of `(q_I,m_I)` and `ell` only) — which is also why N2 could arise
without moving any dimension.

### 2.4 Verification that the N1 route does not weaponize a *hidden* parameter change

§11.6 L1587 asserts "All field, graph, dimension, margin, embedding, capacity, and
canonical-parameter results above are unchanged because no paper parameter changed." **Verified:**
`F_child` is not a source parameter of the introspection construction; `R=N^lambda` is retained at
`4` and `16` in every printed predicate (`s(N)<=R`, `M>=R`, `Q>=R`, `introparams(R)`), and only the
meter budget is overridden — through `ToyPolicy(...,child_fuel=R)` (§12.4 L1722), i.e. through the
DD-28 machine-visible channel. §12.4 L1731 further pins "TB7 leaves this parameter at source `R`;
only TB6b substitutes it", so the substitution cannot leak into TB7. The design also explicitly
refuses the tempting inference: "although `4^8=65,536`, that arithmetic alone supplies no honest
runtime certificate."

### 2.5 N1 escape audit — every `PASS` in §11.6, §12.4 and §13.3-C14

I enumerated all 32 occurrences of `PASS` in DESIGN L1383–L1920 and classified each:

| where | PASS | depends on a measured child cost? |
|---|---|---|
| §11.6 L1566 (E) | `R>=4`, admissible field, `m|q`, `d=1`, `s(N)<=R`, `M<=Q`, `Q>=s(N)` | **No** — closed-form parameter arithmetic |
| §11.6 L1574 (M) | same seven | **No** — same |
| §11.6 L1568 | total stabilizer mass one | **No** — a property of the honest measurement distribution, computed by the §11.5 tableau; correctly *split* from acceptance |
| §11.6 L1568–L1570 | literal-guard rejection counts `10`/`22`, operative-guard admission of the `3Q` answer | **No** — length comparisons on answer schemas |
| §11.6 L1568 | **acceptance probability one** | **conditional and never a PASS**: "a target only for the operative toy decider supplied with `F_child`, after every honest child cost has been measured and shown to fit that budget; an absent trace or a timeout prevents an acceptance PASS. Acceptance under the source `R=4` gate is withdrawn." |
| §11.6 L1589/L1604 | — | ten cost slots are `NOT_EVALUABLE(owner=tb6-child-meter)`, with "`NE` … not zero, a runtime bound, or a PASS" |
| §12.4 L1731 | — | "If it differs, print `FAIL(owner=tb6-child-meter)` even if a later measured honest call fits the substituted budget. … Neither missing cost data nor missing honest schemas may be inferred to pass." |
| §13.3 C14 | the enumerated counts/dimensions/guards | **No**; acceptance is stated as conditional and "unavailable cost or fit remains NOT_EVALUABLE and cannot enable acceptance PASS" |

Grep also confirms the r2-flagged sentence "**require every child query below its `R` timeout**"
is **gone** from the tree (0 hits) and replaced by "require the per-call fuel records specified
below". **The contradiction r2 charged — a printed `FAIL` hypothesis with a required `PASS`
consequence — no longer exists anywhere in §9–13.** The DOWNGRADE is faithful, not an escape.

### 2.6 N2 completeness audit — is `VACUOUS(owner=Q_I<s_0)` printed for *every* non-Pauli schema?

`TypeIntro \ TypePauli = ({Introspect, Sample, Read, Hide_1, …, Hide_ell}) × {alice,bob}`
(`gt-08:L217-L315`; `|TypeIntro| = 32+2ell`, `|TypePauli| = 26`, difference `6+2ell = 2(3+ell)`).
§12.5's row enumerates "Introspect, Sample, Read, **every Hide stage (both roles)**" — that is the
whole difference set, with no residue. §12.5 L1771, §13.2 L1845 and CLAIMS.md C15 all carry the
same scoping sentence. `M7-intro-schema` makes a forged executed sub-test red. **Exhaustive.**

I also checked for a *third* undeclared non-executed layer and found none: `enu:hiding-same` at
TB7 is inside the VACUOUS block; AR `P_growth`/universal constants are already `NOT_EVALUABLE`;
`k_toy` is already `FAIL`; §12.6's fixed-point unfold is explicitly re-scoped; TB7 makes no quantum
transcript claim. §13.2's list of **two** is exact for the current text.

### 2.7 The other two things the brief asks me to check

**Does §12.4/DD-31 cover O2, N1 and N2 uniformly?** DD-31's rationale names exactly the three:
"the `3Q` boundary, child fuel, and `Q>=s(N)` embedding must expose their consequences at toy
size", and its body supplies the three-way grading (`FAIL` when the guard stops admitting the
witness, `VACUOUS` when no representable honest schema or applicable guard set remains,
`NOT_EVALUABLE` when the cost is unmeasured, with "preventing any dependent acceptance PASS").
This is r2 §6's proposed rule adopted essentially verbatim, and it would indeed have caught O2, N1
and N2 in one pass. **Uniform** — with one shape mismatch recorded as `m15`.

**Does the §12 heading, and do C15's "Missing steps", name both layers?** Heading: "…with two
named non-executed layers" (the r2 m10 wording). C15's Missing-steps bullet names both — the
`enu:ar-game`/`NOT_EXECUTED`/owner half and the "print the non-Pauli introspection answer schemas
`VACUOUS(owner=Q_I<s_0)` and list both non-executed layers in §13.2 (N2)" half. C14's bullet
carries the authorized N1 addition verbatim in substance and then specifies which route was
taken. **Both authorized additions landed.**

**`T6-view-swap` killer, re-verified.** The transcript is the valid oriented
`(IntrospectAlice,IntrospectBob)` encoding with reversed answers `(y_B*,y_A*,0,0)` at `z*`. Step 8
of `fig:intro-decider` calls `D(N,y_A,y_B,a_A,a_B)`; the asymmetric diagnostic decider rejects the
ordered pair `(y_B*,y_A*)` and accepts `(y_A*,y_B*)`. Under `M-detype-view-orientation` the parse
swaps the two views, so the mutant reads the pair in the accepting order (or fails to find a valid
edge and accepts-on-invalid) — **the mutant accepts where the correct decider rejects. Red.**
The pair is off the honest support (`y_B(z)` carries no `e_1` or `e_3` component for any seed,
while `y_A* = e_1+e_3+e_4+e_6` does), so requiring rejection costs no value-1 acceptance.

### 2.8 Lockstep audit

**`claims/CLAIMS.md` vs the r2-authorized text — compared field by field, programmatically.**

| row | statement | status | depends-on |
|---|---|---|---|
| C12 | **byte-identical** to §13.3 at `d60198f` | `CONJECTURE` | `C4a,C4b` ✓ |
| C13 | **byte-identical** to §13.3 at `d60198f` | `CONJECTURE` | `C12` ✓ |
| C15 | identical **plus exactly the one authorized appended sentence**, which I compared character-for-character against the italicized text in `verdicts/design-v2-r2.md` §5: **equal** | `CONJECTURE` | `C12,C13,C14` — the authorized edit (1); `C10` correctly removed |

No status wording beyond `CONJECTURE` appears in any of the three rows; the `verdict` column reads
"`verdicts/design-v2-r2.md` (AUTHORIZED as CONJECTURE; C14 HOLD pending N1)", which is a pointer,
not a status. **Law 1 satisfied. No silent strengthening.** DESIGN §13.3's MERGED table
("dependencies are `C12,C13,C14`; both non-executed TB7 layers and their scope are included")
agrees with the file. `claims/` was not edited by `dd4cf82`.

**One real DAG defect, `L1` below:** `C15 -> C14` is currently a **dangling edge** — `C14` is not a
row in `claims/CLAIMS.md` (present ids: `C1,C2,C3,C4a,C4b,C5,C6,C7,C8,N1,C12,C13,C15`). This is my
own r2 instruction's residue: I ordered `depends-on = C12,C13,C14` while simultaneously holding
C14. It is repaired by merging C14, which §4 now authorizes.

**`definitions.md` §§G–H vs DESIGN.** All four `SOURCE_REPAIR` tags used in §9–13
(`AR-field-align`, `intro-3Q-guard`, `intro-decider-fixed-width`, `zero-map-factor-partition`)
have §H rows, and no §H `SOURCE_REPAIR` row is unused in §9–13 (`C8` belongs to §5). The new/edited
rows are consistent with DESIGN: `anchored_repeat` (level `ell+2`, dimension `k(n)(s(n)+8)`,
pre-anchoring input, no double `+2`) matches §9.4 L1170–L1172; `TIME_child/F_child/toy_child_fuel`
matches §§11.1/11.4/11.6/12.4 including the `65,536` vs `4/16` figures; `IntroAnswerEncoding`
matches §11.4 and §12.5; `typed_intro_decider` and `ProductionPolicy/ToyPolicy` match §12.4/DD-31.

**Cited-residue inventory, re-extracted.** Every `lem:|thm:|prop:|cor:` label in DESIGN L1040–end:
**36 distinct labels, 36 covered by §13.2's items 1–12 plus the `lem:commute` carve-out, 0
uncovered.** All 36, and all 20 non-theorem labels (`def:`/`enu:`/`eq:`/`fig:`/`rk:`), have a real
`\label{}` in `ground-truth/gt-*.tex`: **0 phantom citations.** The repair introduced no new
uncovered soundness-bearing label.

**Ladder-arithmetic lockstep.** §10.3 `<2 s` + `<5 s` = §13.1 `<7 s`; §11.6 `<3 s` + `<15 s`
(E) and `<25 s` (M) = §13.1 `<43 s`; §11.6 lists 12 mutations and §13.1 says "twelve"; §12.5 lists
11 `M7-*` and §13.1 says "eleven". **All consistent.**

---

## 3. New objections

**None reach MAJOR.** No new FATAL or MAJOR objection is filed; there is no `N3`. Both r2 MAJORs
are closed, and I could construct no counterexample, no false `PASS`, and no unestablished claim
in the changed text. The following are MINOR/NOTE and continue r2's numbering; none blocks a PASS,
and none blocks C14.

* **`L1` (lockstep, MINOR, with a mandatory remedy).** `claims/CLAIMS.md` C15 `depends-on` names
  `C14`, which is not a row — the exact addressability defect r2 struck `C10` for, created by r2's
  own edit while C14 was held. **FIX DEMAND:** apply §4's C14 row to `claims/CLAIMS.md` in the same
  commit that records this verdict; the edge then resolves. Do not "fix" it by weakening C15's
  dependency list. **SURVIVING WEAKER STATEMENT:** until C14 is merged, C15's TB6-dependency is
  documentary (§13.3) rather than addressable.
* **`m12` (§12.5 predicate table, MINOR).** §11.1 now mandates that `TIME_child(N)<=R` and
  `|V|<=lambda` be printed as *separate* predicates, and DD-31 mandates a printed witness cost.
  TB7's table still lumps them: "input field/level/lambda **bounded**; `n>=2` | PASS" — a single
  `PASS` covering an unmeasured runtime, which is the very shape N1 attacked (here harmlessly,
  since `n^lambda = 2^32768` admits any terminating cost). The table also omits
  `toy_child_fuel` (which is `PASS` at TB7, `child_fuel=R` per §12.4) and the intro low-degree
  margin `d_I*m_I/q_I = 1*1/2 = 1/2`, which is `>=1/2` and therefore `VACUOUS` by §12.4's own
  mandatory rule — and at `m_I=1`, `L_DLine` is degenerate (`v' = pi_{i-1}(v)` has only `i=1`, so
  `v'=0`; `gt-07:L1000-L1001`). **FIX DEMAND:** add three rows to §12.5 — split
  `TIME_child(N)<=R` from `|V|<=lambda` with a printed (or crudely bounded) cost;
  `toy_child_fuel PASS (child_fuel=R)`; and `intro low-degree margin d_I m_I/q_I = 1/2 VACUOUS
  (owner=…)`. **SURVIVING WEAKER STATEMENT:** "only the Pauli-typed introspection predicates
  execute at TB7" stays true — `execute` is not `non-vacuous` — but TB7's Pauli sub-tests carry a
  void low-degree margin, which only `TB6b-M` (`dm/q=1/4`) makes live.
* **`m13` (DD-31 scope, MINOR).** DD-31's protective clause forbids only a "dependent **acceptance**
  PASS". A fuel timeout also makes every *negative* assertion (`T6-view-swap` reject-preservation,
  the `T5-*` negatives, the reject expectations inside `M6-*`) pass **for the wrong reason**, since
  a timed-out decider rejects everything. The mutation discipline catches this on the mutant side
  (the mutant would also reject, so the mutation fails to be red — a visible failure, not a silent
  green), which is why this is MINOR and not MAJOR. **FIX DEMAND:** require each negative
  transcript to record *which branch* produced the rejection and assert it is the intended guard,
  not the fuel counter.
* **`m14` (§12.6, MINOR).** "must return `OutOfFuel` at **the declared boundary**" does not declare
  a number, and at TB7 `child_fuel = R = 4^32768` cannot be exhausted. **FIX DEMAND:** pin the
  evaluator-entry test fuel explicitly and state that it is not `child_fuel`, so the synthetic
  `OutOfFuel` event is not read as a child-timeout.
* **`m15` (DD-31 shape uniformity, MINOR).** Of DD-31's three named cases, child fuel gets
  `FAIL(owner=tb6-child-meter)` and the embedding gets `FAIL(owner=Q_I<s_0)` /
  `VACUOUS(owner=Q_I<s_0)`, but the `3Q` boundary is surfaced only as a rejection count plus
  `SOURCE_REPAIR(intro-3Q-guard)` — no named predicate. **FIX DEMAND:** print
  `P_intro_literal_admits_honest = FAIL(owner=intro-3Q-guard)` beside the `10`/`22` counts so all
  three DD-31 cases have the same machine-readable shape.
* **`m16` (citations + process, NOTE).** (a) Retarget the two inherited line ranges: the fuel gate
  is `gt-08-introspection.tex:L417-L419` (not `L419-L421`) and the wire format is `L524-L530` (not
  `L525-L531`) — in DESIGN §§11.1/11.4 and in the `IntroAnswerEncoding`,
  `TIME_child/F_child/toy_child_fuel` §H rows. My r2 verdict is the source of both. (b)
  `briefs/34-design-v2-repair-r2.last.md` is 4 lines and omits two of the three items brief 34
  required of the report (the `lambda` chosen with its `R` value; the honest child cost);
  `docs/design-v2-repair-r2-response.md` does supply them. Non-blocking.
* **NOTE (budget interaction).** `F_child = 65,536` is a *cap*: a timing-out call may burn all
  65,536 steps, and 520 transcripts × many child calls could dominate the `<20 s` / `<25 s`
  targets. Have the TB6b report print total fuel consumed alongside the wall clock, so the
  estimate is replaced by a measurement in the same pass (§11.6 already flags the targets as
  pre-implementation estimates).

---

## 4. C14 — decision

**C14: AUTHORIZED as `CONJECTURE`, with one exact edit.**

Every clause of the amended row was re-derived above: `34`/`116`, level `5`, dimension `142`,
`Q=2`, `3Q=6`, literal count `10` (now exact, given `|a|=1`); `38`/`128`, level `5`, dimension
`179`, `Q=12`, literal count `22`, `dm/q=1/4`; `L^alice != L^bob` with the swapped pair off the
honest support; the live `k ∈ {1,2}` hiding chain; the even-`c` canonical obstruction. The clause
that N1 blocked in r2 — "every support transcript is accepted by the repaired operative `>3Q`
guard" — has been correctly **split** into an unconditional length-guard fact (which holds) and a
conditional toy-acceptance statement (which is scoped by measured fit and never asserts source-fuel
acceptance). `depends-on = C12,C4a`: both rows exist, so no dangling edge is created.

The one edit: the row says "fitting the supplied `F_child=65,536` **steps**" without naming the
unit, which is precisely the ambiguity N1(a) was about, and a claim row must be falsifiable
standing alone. Name the unit inline. The `verdict` column must also stop saying `HOLD`.

**Paste this row verbatim into `claims/CLAIMS.md`** (it is the §13.3 row with those two edits and
nothing else):

```
| C14 | (TB6 Introspect fixtures, explicit toy child fuel) For the explicitly ineligible `TB6b-E` tuple `n=2,N=4,lambda=1,R=4,ell=1,(q,m,d)=(2,1,1)`, with deterministic one-bit child answers, the constructed type/edge counts are 34 and 116 and the detyped sampler has level 5 and dimension 142. Under the source's single `Q`-bit encoding, exact stabilizer enumeration has total mass one. Operative toy acceptance of every support transcript is conditional on exact metered child traces fitting the supplied `F_child=65,536` steps in the one-metered-quoted-interpreter-step fuel unit fixed in DESIGN §11.4, with `toy_child_fuel=FAIL(owner=tb6-child-meter)` because `F_child!=R`; acceptance under source fuel is not asserted. The operative `>3Q` length guard admits the honest `Hide_1` answer of length `3Q=6`, while the separately printed paper-literal `>=3Q` guard rejects exactly 10 of 116 oriented pairs. For `TB6b-M` at `n=2,N=4,lambda=2,R=16,ell=3,s=6,(q,m,d)=(8,2,1)`, the same explicit fuel override and measured-fit condition scope the live adaptive factor/dual/Gaussian and ordered-game checks; prefix-dependent nonzero factors, a nonsymmetric stage map, and `L^alice != L^bob` are retained. Its type/edge counts are 38/128, detyped level/dimension 5/179, `Q=12`, literal Hide rejection count 22, and `dm/q=1/4`; `T6-view-swap` requires reject preservation. Each fixture prints per-mode honest costs, source and supplied budgets, independent runtime/description/embedding predicates, and owners; unavailable cost or fit remains NOT_EVALUABLE and cannot enable acceptance PASS. Empty guards and margins `>=1/2` are VACUOUS; `thm:pauli` and `thm:introspection` remain CITED. | CONJECTURE | C12,C4a | — | — | `verdicts/design-v2-r3.md` (AUTHORIZED as CONJECTURE) |
```

Merging it is also the remedy for `L1`. §13.3's C14 "Missing steps" bullet is **AUTHORIZED
unchanged** — it already carries the r2-authorized addition plus the route actually taken and the
owner's outstanding obligations. C12, C13, C15 are **MERGED and correct**; nothing about them
changes this round. DD-31 is **AUTHORIZED** as a numbered DD alongside DD-23–DD-30.

---

## 5. TB5 readiness (next rung, `briefs/` has none yet)

1. **Yes — §10 plus §13.1 are sufficient for an implementer to build TB5 with no further design
   round.** Everything load-bearing is pinned numerically and re-derived below.
2. Fixture and parameters are complete: `V_copy` (`F_2`, `ell=1`, `s(n)=1`, both CL maps identity,
   decider `a=x and b=y`), `lambda=tau=c'=1`, `n=9`. Recomputed from `gt-11`: `B=(lambda n)^tau=9`,
   `k=(lambda n)^{(1+c')tau}=81`, anchor `level 3, dim 1+8=9`, repeat `level 3, dim 81*9=729`.
3. Contracts are source-exact: `thm:repetition` item 1's completeness hypothesis really is
   `TIME_D(n) <= (lambda n)^tau` (`gt-11:L240`), item 3's `O(k*max(TIME_D,(lambda n)^tau))` and
   `ell+2` (`L251-L254`), the strict `>` in soundness (`L246`), and "`S^rep` only depends on `S`
   and `lambda,tau`" (`L257`) — all transcribed correctly in §10.2.
4. The component guard is source-exact and its ordering is a DD: `gt-11:L219` covers **all four**
   tuples `x,y,a,b` with strict "larger than", and DD-26 fixes parse-before-call.
5. Tests are fully named: four-query replay, 128 seeded positives, `T5-game-seed1`,
   `T5-anchor-one`, `T5-one-corrupt`, `T5-boundary`, the intensional sampler-hash test with
   dependency set `{hash(S),lambda,tau,c_prime}`, and seven `M5-*` each with a named killer.
6. **NOTE-A (gap).** §10.3 names no `enu:cl-space-sum` assertion or mutation for `Anchor`'s
   promoted whole-space stage-1 factor, although `SOURCE_REPAIR(zero-map-factor-partition)` is
   *first observable at TB5* (§10.1, `gt-11:L96`); its owning mutation `M-factor-partition` is
   enrolled at §11.6 #10 — one rung late. Enroll an Anchor-scoped instance in the TB5 brief.
7. **NOTE-B (gap).** §13.1's TB5 required-output cell omits the per-sampler `chain_set_id` /
   distinct-chain / completed-replay counts that §9.2 (as amended by m3) now requires of every
   sampler, `S^anch` and `S^rep` included. Add them to the TB5 report spec.
8. **NOTE-C (uniformity, the N1 pattern one rung earlier).** `TIME_D(n) <= B(n) = 9` at `n=9` is
   as implausible in the §11.4 fuel unit as `R=4` was — but at TB5 it is a *hypothesis of a CITED
   theorem*, not an executable gate (`repeat_decider` length-guards, never times out), and §10.1
   already keeps PCC completeness CITED while grading only finite acceptance CHECKED. So there is
   no N1 recurrence. Still, print it `NOT_EVALUABLE(owner=…)` per DD-31 so 128 green transcripts
   are never read as completeness evidence.
9. **NOTE-D (ambiguity).** §10.3 does not say which of `x,y,a,b` carries `T5-boundary`'s exactly-9-bit
   component. The honest *question* component is exactly `s(n)+8 = 9 = B` while the honest *answer*
   component is 1 bit, so the "accept exactly `B` bits" half is realizable only on the question
   side; say so in the brief.
10. None of NOTE-A…NOTE-D changes a number, a contract, or a claim row; all four are brief-level
    additions. **TB5 is ready to implement.**

---

## 6. Assessment

Objection trajectory: **10 MAJOR (r1) → 2 MAJOR (r2) → 0 MAJOR (r3)**, with 13 of 13 r2 rows
ACCEPTED on independent recomputation, 0 PARTIAL, 0 REJECTED. Severity is falling monotonically
and the loop has reached its fixed point for `docs/DESIGN.md` §9–13 and `docs/definitions.md`
§§G–H.

The round's substantive product is a *negative* one, and it is worth stating plainly: the design
now says, in machine-readable form, that at TB6b the source's `R = N^lambda` child-fuel gate cannot
admit an honest child; that at TB7 the source's `F_2^Q` answer embedding cannot represent the input
space; and that neither the actual-`D1` `enu:ar-game` call nor the non-Pauli introspection answer
schemas execute on faithful content at TB7. Three separate places where shrinking the paper's
parameters to executable size breaks a source guard, each one printed with an owner rather than
absorbed into a green transcript count. DD-31 generalizes the pattern so the next fixture change
cannot recreate it silently — which is the structural response r2 asked for, and the reason this
round produced no `N3`.

The one thing the orchestrator must not skip: **C14 has to be pasted now**, both because it is
authorized and because `claims/CLAIMS.md` currently carries a dangling `C15 -> C14` edge (`L1`).

---

VERDICT: PASS
