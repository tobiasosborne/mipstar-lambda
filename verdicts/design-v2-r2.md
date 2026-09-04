# Verdict — DESIGN v2 (`docs/DESIGN.md` §9–13, `docs/definitions.md` §§G–H), round 2

Critic: Opus subagent, adversarial lane. Target: **archived tree at commit `d60198f`**
(`git archive d60198f | tar -x`), evaluated against `ground-truth/gt-*.tex` only. No Julia run.
Priors: `verdicts/design-v2-r1.md` (O1–O10 MAJOR, O11–O21 MINOR, six NOTES, three offered
mutations, R(a)–R(d), MERGE adjudication, C12–C15 recommendation) and
`briefs/31-design-v2-repair.md` (the orchestrator's binding directives).
Work order: `docs/design-v2-repair-r1-response.md` (FIXED 32 / RETRACTED 1 / DOWNGRADED 2 / RESIDUE 0).

Round-2 discipline: r1's confirmed recomputations (`9→5→7→9`, `206→840→848→1696`, `26`, `86`,
`6ℓ+110`, `4·16²ε`, `16^{|T|}ε`, `3894`/`42,834`, `k(n)=(λn)^{(1+c')τ}`, the strict `>` at
`gt-11:L219`, `dim_q V^pcp = 2m'+6`) are **not** re-litigated; they are re-confirmed only where a
repair moved a fixture. Attack is scoped to `git diff a403c9b..d60198f -- docs/DESIGN.md
docs/definitions.md` (all 301 changed DESIGN lines fall at or after L1069, i.e. inside §9–13 —
lane respected; `claims/` untouched, verified by the same diff).

**Numbering note.** r1's NOTES were `N1`–`N6`. This round's *new objections* are also `N1`, `N2`
per brief 33. Throughout, r1's notes are written `r1-N1 … r1-N6`; unprefixed `N1`/`N2` are new
MAJOR objections.

---

## 1. Per-row adjudication

Severity legend as in r1. "ACCEPTED" = the fix meets the r1 FIX DEMAND on independent
recomputation. "PARTIAL" = the substance landed but a named residue remains (non-blocking unless
promoted to N*). "REJECTED" = the FIX DEMAND is not met.

### MAJOR rows

| id | r1 disposition claimed | adjudication | one line |
|---|---|---|---|
| O1 | FIXED | **ACCEPTED** | `enu:cl-space-sum`/`enu:cl-map-sum` replay is in §9.2's `LawCert` **and** in §9.4's per-operation contract **and** as a mandatory §9.6 PROVE row over all eight signatures; the zero-map rule is now `rk:higher-level`-exact and tagged with a definitions row. Full list in §2.4. |
| O2 | FIXED | **ACCEPTED** | The `Q`-bit encoding is not a choice but the source's own (`gt-08:L525-L531`); the honest `Hide` answer is exactly `3Q` (`L588-L591`); the literal `≥` rejects it and the operative `>` accepts it; both are printed; counts `10/116` and `22/128` recomputed exactly (§2.1). |
| O3 | FIXED | **ACCEPTED** | `TB6b-M` (`ℓ=3`) makes `enu:hiding-same`'s index set `k ∈ {1,2}` non-empty, `m=2` un-degenerates `L_DLine`, `dm/q=1/4<1/2`, and TB7's `s_0=9` gives nine nonzero factor stages; `M6-factor-prefix` verified red at `z*` (§2.2). |
| O4 | FIXED | **ACCEPTED** | `L^alice ≠ L^bob` verified by explicit computation; `y_A*=e_1+e_3+e_4+e_6 ≠ y_B*=e_2+e_5+e_6`, and the swapped pair is **outside** the honest support, so the asymmetric decider can reject it without breaking value 1 (§2.2). |
| O5 | RETRACTED | **ACCEPTED** | `P_pcp_encodes_D1=FAIL` in §12.5's table, `enu:ar-game=NOT_EXECUTED(owner=pcpverifier-D1-trace)`, the aggregate "16 honest accepts" is gone from §12.5 and §13.1, and §12.4/DD-28 forbids calling a parameter-only PCP content-faithful. Grep results in §2.3. The repair went further than the FIX DEMAND (full removal rather than re-scoping) — correct under law 5. |
| O6 | FIXED | **ACCEPTED** | Independently recomputed: **all 36** `lem:`/`thm:`/`prop:`/`cor:` labels cited in §9–13 are covered by items 1–12 or by the explicit `lem:commute` carve-out; every cited label exists in the source (no phantom citations); the word "exact" is dropped and the audit method is stated (§2.5). |
| O7 | FIXED | **ACCEPTED** | `IntroGap` now carries `max{Ent(V_{2^n},1-δ), (1-δ)2^{2^{λn}}}`, verbatim `thm:introspection` item 3 (`gt-08:L809-L815`); §9.2 grades only the evaluated scalar-floor branch CHECKED and leaves the `Ent` branch and the semantic `max` CITED; `M7-intro-floor` owns the deletion. |
| O8 | FIXED | **ACCEPTED** | The explicit `E^ar` formula is verbatim `gt-10:L1949-L1955`; `type^ora={O,A,B}` complete with loops (`gt-09:L43-L47`) and `E^pcp = type^pcp × type^pcp` on 18 types (`gt-10:L1888-L1894`), so `((O,Point_1),(A,DLine_6))` is in `E^ar` and not in the Cartesian product. Red pair valid; `M7-product-cartesian` owns it. |
| O9 | FIXED | **ACCEPTED** | The four named transcripts are each verified to fire: `T5-game-seed1` kills `M5-anchor-zero` because the *golden* answer `1` is frozen while the mutant's question becomes `0`; `T5-anchor-one` kills `M5-anchor-answer`; `T5-one-corrupt` kills `M5-or` (OR accepts 80/81); `T5-boundary` pins `>` and is realizable because the honest question component is **exactly** `B=9` bits (§2.6). |
| O10 | FIXED | **ACCEPTED** | `SOURCE_REPAIR(intro-decider-fixed-width)` tagged in §12.3 with a `definitions.md` §H row; §13.2 item 10 now states the paper lemma stays CITED "because its length-equality step is a gap" and only the repaired variant has CHECKED dependency; §12.5 requires exact printed `sigma_1`. Residue: the §G *grade gloss* was not widened (see MINOR list). |

### MINOR rows (r1 O11–O21)

| id | adjudication | one line |
|---|---|---|
| O11 | **ACCEPTED** | `SOURCE_REPAIR(intro-boundary-conflict)` is gone from the tree (grep: 0 hits); replaced by a real repair `intro-3Q-guard` with a §H row. |
| O12 | **ACCEPTED** | `TypedSamplerDescription`, `TypedDeciderDescription`, `VerifierDescription` each have a §H row and are declared refinement aliases, not second representations. |
| O13 | **ACCEPTED** | `detype(s,d)` is the sole public arity; §9.4's table row updated; §9.6 states the old `detype(T,G)` notation is deleted (the only remaining occurrence is that deletion sentence). |
| O14 | **ACCEPTED** | All six `DL9-*` are named in C12's statement and in C12's promotion bullet. |
| O15 | **ACCEPTED** | Row renamed `anchored_repeat(v,lambda,tau)`, "pre-anchoring" input stated, double-`+2` composition explicitly forbidden; §12.2's arrow chain now reads `7 --Anchor/detype--> 9 --direct-sum Repeat--> 9`, consistent. |
| O16 | **ACCEPTED** | §9.1 records `Factor: u ∈ L_{<j}(V)` vs `Linear: u ∈ V_{<j}`, exactly `gt-04:L588-L595`. |
| O17 | **ACCEPTED** | Raw typed machine returns source-literal `0` (`gt-06:L133-L136`); only the validated wrapper returns `QueryError`, with the safety argument. |
| O18 | **ACCEPTED** | `eq:re-eps-1`/`eq:re-eps-2` correctly attributed; `mu,gamma` left at `eq:mu-gamma`. |
| O19 | **ACCEPTED** | §10.3 `<2 s` + `<5 s` = §13.1 `<7 s`; §11.6 `<3 s`+`<15 s`+`<25 s` = §13.1 `<43 s`. Arithmetic checks. |
| O20 | **ACCEPTED** | Budget reduced to `<512 MiB` with the payload quantified (`16·1696=27,136` and `2·42,834=85,668` bits ≈ `0.014 MiB`, recomputed and correct) and `representation=structural-evaluator` required against the dense `12^16` route. |
| O21 | **ACCEPTED** | §11.4 now says "canonical linear map with kernel basis `S`" per `def:cl-canonical`, which the source defines as the projector onto `span(F^⊥)` parallel to `span(F)` (`gt-03:L375-L384`) — the design's "merely a coordinate projection when `S` is a register subspace" is exactly right. |

### NOTES (r1 r1-N1 … r1-N6)

| id | adjudication | one line |
|---|---|---|
| r1-N1 | **ACCEPTED** | §10.2 records the `gt-12:L70` short-exponent conflict as a **Source finding** and retains the two agreeing occurrences without using the third. |
| r1-N2 | **ACCEPTED** | §11.1 now reports the source's chain `s(N) ≤ R ≤ M ≤ Q` (`gt-08:L1083`) and states the theorem predicate is `M ≥ R` (`lem:delta-bound`, `gt-07:L1519`), not `Q ≥ R`. |
| r1-N3 | **ACCEPTED** | §9.2: "CHECKED AST equality means only that the emitted AST equals an independently hand-transcribed expected AST; it is a transcription check". |
| r1-N4 | **ACCEPTED** | §10.2 keeps strict `>`; §11.4 displays literal `≥` beside operative `>`. |
| r1-N5 | **ACCEPTED** | `downsize` carries ASSUME `q=p^k`, `k` odd — verified to be the source's hypothesis in **both** `def:cl-downsize` (`gt-04:L395-L397`) and `lem:downsize-cl-dist` (`gt-04:L533-L534`), so the design's attribution is correct. |
| r1-N6 | **ACCEPTED** | §9.1 keeps the four-query boundary and states the zero-stage counterexample that makes `Factor` independent. |

### Offered mutations

| mutation | adjudication | one line |
|---|---|---|
| `M-factor-partition` | **ACCEPTED** (§11.6 #10) | Killer is the §9.2 `enu:cl-space-sum` replay child, exactly r1's demand; enumerated originating constructors match `gt-11:L96`, `gt-07:L1106-L1108`, `gt-08:L333-L345`. |
| `M-detype-view-orientation` | **PARTIAL** (§11.6 #11) | The killer polarity is right and I verified it fires (a reversed-answer `(IntrospectA,IntrospectB)` transcript on which `D_order` rejects: the swapped parse either finds no valid edge and accepts-on-invalid, or reverses the type pair and re-accepts). But unlike TB5's `T5-*`, this negative transcript is **not enrolled in §11.6's mandatory test list** — §11.6 lists "eight branch-directed transcripts plus 512 seeded regressions" and a graph-encoding coverage requirement, neither of which is a reject-preservation test. Fix: name it (e.g. `T6-view-swap`) in §11.6's transcript list. Non-blocking. |
| `M-intro-fuel` | **ACCEPTED as a mutation, but see N1** (§11.6 #12) | "a metered child taking `R+1` steps must be rejected before completion" is exactly r1's demand. Its adoption is what exposes N1: at `R=4`/`R=16` the *honest* child cannot fit in `R` either. |

### MERGE PROPOSALS rows (r1 adjudication → r1 response)

| id | adjudication | one line |
|---|---|---|
| MP-preamble | **ACCEPTED** | `claims/CLAIMS.md` untouched at `d60198f`, verified by diff. |
| MP-C12 | **ACCEPTED** | The r1 mandatory addendum is present verbatim in substance (`lem:cl-kth` disclaimer + `rk:higher-level` + tensor correction), plus the six `DL9-*` names. |
| MP-C13 | **ACCEPTED** | Nonzero-`Anchor`, one-corrupt-component and exact-boundary clauses added, as demanded. |
| MP-C14 | **DOWNGRADED → adjudicated HOLD** | The rewrite is honest and correctly scoped for O2/O3/O4, but its acceptance clause is not established while N1 stands. |
| MP-C15 | **DOWNGRADED → ACCEPTED with two exact edits** | Row text is correctly limited to composition/bookkeeping/hash/fixed-point and makes the PCP failure explicit; `depends-on` cites the nonexistent `C10`, and N2's second non-execution must be named. Verbatim text in §5. |
| MP-missing-steps | **ACCEPTED** | All four r1-demanded bullets present: O1 replay under C12, O9 negatives under C13, O3/O4 fixture + `VACUOUS` under C14, O5 content predicate + owner under C15. |
| MP-DD23–30 | **ACCEPTED** | All eight DDs present with rationale + rejected alternative (§9.6 DD-23–25, §10.3 DD-26, §11.6 DD-27, §12.4 DD-28, §12.6 DD-29, §13.3 DD-30). |
| MP-residue | **ACCEPTED** | See O6. |

**Row count: 32 ACCEPTED, 1 PARTIAL, 0 REJECTED.** No RETRACTED or DOWNGRADED row is an escape:
O5's retraction is compelled by `gt-10:L2060-L2062` (`pcpverifier` is called against the *actual*
`D` description) and is the strictly more honest of the two routes r1 offered; MP-C14/MP-C15's
downgrades are exactly the r1-adjudicated REJECT-wording remedy.

---

## 2. Recomputations, in full

### 2.1 O2 — the encoding, the boundary, and the printed counts

**The `Q`-bit encoding is the source's, not a design choice.** `gt-08:L525-L531`:

> "Since `V` is isomorphic to `F_2^{s(N)}` … the space `V` is identified in a canonical way as the
> register subspace of `F_2^Q` spanned by `e_1,…,e_{s(N)}` … For example, if `τ̂_w = (Read,role)`,
> then syntactically the player's answer is a triple `(y,y^⊥,a)` in `F_2^Q × F_2^Q × {0,1}^*`."

So §11.4's "every vector field `y,z,y_perp,x` is serialized as a full `Q`-bit vector with its final
`Q-s(N)` coordinates zero; there is no `s(N)`-bit wire encoding" is a *transcription*, and the
alternative reading r1 left open is closed by the source itself. The design should say so (it
currently presents the encoding as its own pin); this is cosmetic.

**Honest `Hide` length.** `fig:intro-decider`'s answer key (`gt-08:L406-L419`) gives
`(Hide_k,role) ↦ (y,y^⊥,x) ∈ V × V × V`, and `L588-L591`:

> "the maximum-length answer should be a tuple `(y,y^⊥,a)` … or a tuple `(y,y^⊥,x) ∈ V×V×V` in
> response to question `(Hide_k,v)`. Either way, the maximum answer length should be
> `3Q = 3·2^m·log q = poly(R)` bits long."

Under the `Q`-bit wire format each of the three fields is `Q` bits, so `|â| = 3Q` **exactly**.
The literal guard (`gt-08:L424-L425`, carrying the source's own `\hnote{edited:}` marker) is
`max{|â_A|,|â_B|} ≥ 3·2^m·log q → reject`, so it rejects the honest `Hide` answer; `> 3Q` accepts
it and is the minimal change. **The design's operative guard is correct and its capacity arithmetic
is exact**: literal accepts a `Read` answer iff `2Q+|a| < 3Q ⟺ |a| < Q`; operative iff
`2Q+|a| ≤ 3Q ⟺ |a| ≤ Q`. §11.4 prints precisely these two.

**Printed literal-rejection counts — recomputed from the graph, not from §11.6.**
`G^intro` non-loops (r1 R(c), re-derived): inherited `30`, plus per role
`Sample–Introspect`, `Introspect–Read`, `PauliX–Hide_1`, `PauliZ–Sample`, `Hide_ℓ–Read`,
`Hide_k–Hide_{k+1}` for `k=1..ℓ-1`, plus `IntrospectA–IntrospectB`. Edges incident to a `Hide`
vertex are therefore `2` (`PauliX–Hide_1`) `+ 2` (`Hide_ℓ–Read`) `+ 2(ℓ-1)` (`Hide` chain), and
the `Hide` loops number `2ℓ`.

* `TB6b-E`, `ℓ=1`: `2+2+0 = 4` non-loops, `2` loops ⇒ `2·4+2 = **10**` oriented pairs.
  Total oriented `= 6·1+110 = 116`. **`10/116` confirmed**, and §11.6's parenthetical
  ("four non-loop edges in both orientations plus two loops") is the correct derivation.
* `TB6b-M`, `ℓ=3`: `2+2+4 = 8` non-loops, `6` loops ⇒ `2·8+6 = **22**` oriented pairs.
  Total oriented `= 6·3+110 = 128`. **`22/128` confirmed.**

Both counts are computable: they are functions of `ℓ` alone, and on every such pair at least one
player is `Hide`-typed, whose honest answer is exactly `3Q` (`3Q=6` at `TB6b-E`, `3Q=36` at
`TB6b-M` — both as printed). **Caveat (MINOR):** the counts equal "pairs incident to a `Hide`
vertex" only if no *other* honest answer reaches `3Q`. A `(Read,role)` answer is `2Q+|a|`, so the
count `10` at `TB6b-E` (`Q=2`) additionally requires the child's answer length `|a| ≤ 1`; §11.6
says "deterministic answers" without pinning `|a|`. `TB6b-M`'s "zero answers" pins it there.
Fix: state the child answer length at `TB6b-E`.

### 2.2 O3/O4 — the `TB6b-M` fixture, recomputed end to end

`n=2, N=4, λ=2, ℓ=3, s(N)=6, (q,m,d)=(8,2,1)`:

```
R = N^λ            = 4^2            = 16     (design: 16)      OK
M = 2^m            = 2^2            = 4      (design: 4)       OK
Q = M·log2 q       = 4·3            = 12     (design: 12)      OK
3Q                 = 36                      (design: 36)      OK
|TypeIntro|        = 32+2ℓ = 32+6    = 38     (design: 38)      OK
oriented pairs     = 6ℓ+110 = 18+110 = 128    (design: 128)     OK
  cross-check      = 2(39+2·3)+(32+6) = 90+38 = 128            OK
downsized typed s  = (3m+3)·log2 q = 9·3 = 27  (design: 27)     OK
detyped s          = 27+4·38 = 27+152 = 179   (design: 179)     OK
tableau qubits     = 2(Q+1) = 26              (design: 26)      OK
capacity chain     s(N)=6 ≤ R=16 PASS ; M=4 ≥ R=16 FAIL ; M=4 ≤ Q=12 PASS   (as printed)
low-degree margin  dm/q = 1·2/8 = 1/4 < 1/2                    (design: 1/4)  OK
field admissible   q=8=2^3, k=3 odd (gt-03:L664-L666)          OK
m | q              2 | 8                                        OK
Q ≥ s(N)           12 ≥ 6  (so the F_2^Q answer embedding exists)  OK
```

**`enu:hiding-same` is live.** `gt-08:L464-L473` quantifies `k ∈ {1,…,ℓ-1}`; at `ℓ=3` that is
`{1,2}`, so both `Hide_1–Hide_2` and `Hide_2–Hide_3` edges exist for each role. **Non-empty
confirmed** (it was empty at `ℓ=1`, exactly r1's O3).

**`L^alice ≠ L^bob` and the adaptive schedule, computed explicitly.** Design fixture: basis
`e_1..e_6`; stage-1 factor `⟨e_1⟩`; prefix `0 ↦ (⟨e_2,e_3⟩, ⟨e_4,e_5,e_6⟩)`, prefix
`e_1 ↦ (⟨e_4,e_5⟩, ⟨e_2,e_3,e_6⟩)`; stage-2 matrix `[[1,1],[0,0]]` in the ordered factor basis;
stage-3 identity; Alice's stage-1 map identity, Bob's zero.

* Both partitions satisfy `enu:cl-space-sum`: `{e_1}∪{e_2,e_3}∪{e_4,e_5,e_6}` and
  `{e_1}∪{e_4,e_5}∪{e_2,e_3,e_6}` each exhaust the six coordinates disjointly. **OK.**
* Because `L^bob_1 = 0`, `L^bob_{<2}(V) = {0}` and Bob's only legal stage-2 prefix is `0`; Alice's
  reachable prefixes are `{0, e_1}`. So the prefix-dependent `Factor` branch is genuinely
  exercised on the Alice side. **OK.**
* At `z* = e_1+e_3+e_5+e_6` (`z_1=1,z_2=0,z_3=1,z_4=0,z_5=1,z_6=1`):
  `y_A* = L^A_1(e_1) + [[1,1],[0,0]]·(0,1)^T|_{⟨e_4,e_5⟩} + id|_{⟨e_2,e_3,e_6⟩}(e_3+e_6)
  = e_1 + e_4 + e_3 + e_6`; `y_B* = 0 + [[1,1],[0,0]]·(0,1)^T|_{⟨e_2,e_3⟩} + id(e_5+e_6) =
  e_2 + e_5 + e_6`. **`y_A* ≠ y_B*` confirmed**, and their stage-1 prefixes (`e_1` vs `0`) differ.
* **`M6-game` is red, and the fixture is still value-1.** Bob's question is
  `y_B(z) = (z_2+z_3)e_2 + z_4e_4 + z_5e_5 + z_6e_6` — it has *no* `e_1` or `e_3` component for
  any seed. Since `y_A* = e_1+e_3+e_4+e_6` does have them, **no seed produces the ordered pair
  `(y_B*, y_A*)`**: the swapped pair is outside the honest support, so the diagnostic decider may
  reject it while still accepting every on-support pair. `enu:intro-game` (`gt-08:L481-L485`)
  calls `D(N,y_w,y_w̄,a_w,a_w̄)`, so the mutant evaluates `D(N,y_B*,y_A*,0,0) = reject` where the
  correct call accepts. **Killer verified.** (r1's O4 defect — `L^alice=L^bob=id` making the swap
  a no-op — is genuinely gone.)
* **`M6-factor-prefix` is red.** `gt-08:L649-L654` emphasises that `V^role_{k+1}` "depends on
  `y_w̄` and not `y_w`", with a footnote noting the `Hide_{k+1}` player measures `k` registers
  while the `Hide_k` player measures `k-1`. At `k=1`, `z*`, role alice: correct prefix
  `u = y_{Hide_2,≤1} = e_1 ⇒ V_2 = ⟨e_4,e_5⟩`; the mutant's `u = y_{Hide_1,≤1} = 0 ⇒
  V_2 = ⟨e_2,e_3⟩`. Different factor ⇒ different `(L_{2,u})^⊥` ⇒ the
  `y^⊥_{w̄,k+1} = (L^role_{k+1,u})^⊥(x_{w,k+1})` check fails. **Killer verified.**
* **`M6-perp` is red.** `[[1,1],[0,0]]` has kernel `⟨e_4+e_5⟩`; its transpose `[[1,0],[1,0]]` has
  kernel `⟨e_5⟩`. Different kernel ⇒ different canonical complement ⇒ different canonical linear
  map (`gt-08:L659-L684`, `gt-03:L375-L384`). Dropping one of the two basis-vector `Linear` calls
  is likewise rank-changing. **Killer verified.**
* **`L_DLine` is un-degenerate.** `gt-07:L1000-L1001` sets `v' = π_{i-1}(v)` with `i = χ(s) ∈
  {1,…,m}`. At `m=1` only `i=1`, so `v' = π_0(v) = 0` and `L_DLine` collapses onto `L_ALine`
  (r1's O3). At `m=2`, `i=2` gives `v' = π_1(v) ≠ 0`. **Fixed.**

**`< 25 s` estimate.** The design gives `construction < 5 s` + `520 diagnostic transcripts plus
owned mutants < 20 s` = `< 25 s`, with the state sizes that drive it stated (`179`-bit questions,
`26`-qubit tableau ⇒ a `26 × 53` binary tableau, `O(26³) ≈ 1.8·10⁴` GF(2) ops per elimination,
`8 + 512 = 520` transcripts), and flags them as pre-implementation estimates to be replaced by
measurements. **Arithmetic is behind it (`8+512=520`, `5+20=25`) and the per-transcript cost is
orders of magnitude below the budget**; no cost-per-transcript figure is given, which is
acceptable for a design-stage estimate that is declared as such. **ACCEPTED.**

**TB7's `s_0`.** §12.5 now uses a nine-level, nine-bit coordinate-identity input, "each of its
nine stages owns one nonzero coordinate factor", so the nine-stage `Hide` chain is no longer
vacuous — r1's O3 second half. `s_1 = (3m_I+3)log q_I + 4·50 = 6 + 200 = 206` is unchanged
because Introspect resets its output dimension, so `206→840→848→1696` survives the fixture change.
**Confirmed.** (This change is also what creates N2 below.)

### 2.3 O5 — is the PCP-content failure honestly surfaced?

`grep -n 'end.to.end|honest accept|content-faithful|NOT_EXECUTED|P_pcp_encodes_D1'` over §9–13
returns: `P_pcp_encodes_D1 = FAIL` in §12.5's predicate table; §12.5 prose "marks `enu:ar-game`
`NOT_EXECUTED(owner=pcpverifier-D1-trace)` whenever it is reached … there is no aggregate
'16 honest accepts' result and no parameter-only PCP fixture is described as content-faithful";
§12.4 "Parameter substitution does not substitute PCP content: the instance supplied to
`pcpverifier` must still arithmetize the actual child decider, or `P_pcp_encodes_D1` is `FAIL` and
`enu:ar-game` is not executed"; §13.1's TB7 required-output cell lists both;
§13.2's opening names the exception; C15 names both and disclaims the aggregate; `M7-pcp-content`
makes a forged `PASS` red; §13.1's reuse rule forbids feeding the TB0 fixture to the actual-`D1`
game. The only surviving "16" is "samples 16 final *questions*" (a sampler count, not an accept
count) and "16 honest accepts" appears solely inside the negation. The `§12` heading still reads
"end to end"; that is a title, contradicted three times in its own body. **No sentence in §9–13
implies content-faithful end-to-end execution.** ACCEPTED; the heading is a cosmetic residue.

Grounding re-verified: `gt-10:L2060-L2062` (`enu:ar-game`) rejects unless
`pcpverifier((D,n,T,Q_len,γ,x_{w,A},x_{w,B}),(z,a_w))` accepts with `D` the actual decider
description, so a parameter-only substitution genuinely cannot satisfy it. `definitions.md` §H's
`P_pcp_encodes_D1` row cites `gt-10:L1813-L1828, L1958-L1960, L2060-L2063` — all correct.

### 2.4 O1 — where the `def:sampler` well-formedness replay now appears

Required because `def:sampler` (`gt-04:L577-L582`) and `def:typed-sampler` (`gt-06:L100-L110`)
both require the CL functions to "satisf[y] the conditions of Lemma `lem:cl-kth`", whose items
`enu:cl-space-sum` (`V = ⊕_{i=1}^ℓ V_{i,x^{L_{<i}}}` for all `x`) and `enu:cl-map-sum`
(`L_{≤k}(x) = Σ_{i≤k} x^{L_i}`) are at `gt-04:L167-L173`. Present at:

1. **§9.2** — "Every sampler-producing `LawCert` additionally replays the two well-formedness
   obligations of `lem:cl-kth`", with both displayed and the register-indicator reading spelled
   out (disjoint indicators whose union is the full `Dimension(n)` basis). Universal over
   sampler-producing certificates, hence covers primitive constructors too.
2. **§9.3** (`describe_cl` adapter) — "It also performs the §9.2 direct-sum and telescoping replay."
3. **§9.4** (closure table) — "Each operation in the table returns its field/level/dimension/call
   laws **and** a sampler-validity child replaying `enu:cl-space-sum` and `enu:cl-map-sum`", with
   `DL9-downsize`/`-direct-sum`/`-product` by construction and `DL9-detype`/`-anchor`/`-repeat`
   "after conditional concatenation, zero-map promotion, and block splitting"; and "A constructor
   without that child does not return `Checked{SamplerDescription,…}`."
4. **§9.5** (detyping) — "Its zero child uses the promoted whole-space stage-1 factor rule of §9.4."
5. **§9.6** (PROVE grade table) — a dedicated row "`enu:cl-space-sum` factor partition and
   `enu:cl-map-sum` marginal telescoping | CONSTRUCTED plus CHECKED finite replay", followed by
   "This output-sampler row is mandatory for **every** signature above: `downsize`, `direct_sum`,
   `product`, `detype`, `anchor`, `repeat`, `introspect`, and `compress`. For composites the
   certificate tree retains the replay at every intermediate sampler."
6. **§10.1** (anchor) — `Anchor`'s `Factor` is "the all-ones ambient indicator at stage 1 and
   empty thereafter", tagged `SOURCE_REPAIR(zero-map-factor-partition)` against `gt-11:L96`.
7. **§11.2** (Pauli) — `PauliX`/`PauliZ` "report the whole ambient factor at stage 1 and empty
   factors at stages 2 and 3", against `gt-07:L1106-L1108`.
8. **§11.3** (introspection) — every type in `TypeIntro \ TypePauli` likewise, against
   `gt-08:L333-L345`.
9. **§11.6 #10** — `M-factor-partition` owns the invariant.
10. **`definitions.md` §H** — rows for `QuotedLaw/UpperBoundLaw/LawCert` ("a sampler-producing
    certificate also replays `enu:cl-space-sum` and `enu:cl-map-sum`") and for
    `SOURCE_REPAIR(zero-map-factor-partition)` with the three source conflict sites.

**The padding rule is now source-exact.** `rk:higher-level` (`gt-04:L122-L130`) authorises exactly
"`V_1=V`, `V_{>1}={0}`, `L_1(x)=0`", which the design transcribes as whole-space stage 1 + empty
stages thereafter; `enu:cl-space-sum` then reads `V ⊕ {0} ⊕ … ⊕ {0} = V` and `enu:cl-map-sum`
reads `0 = 0`. Because `def:typed-sampler` imposes `lem:cl-kth` **per type**, the per-type
promotion is the right granularity. **ACCEPTED.** Genuine primitive constructors not in §9.6's
signature list (`pauli_sampler`, `tilde S^intro`, `graph_sampler`) are covered by §9.2's universal
quantifier plus items 6–8; adding them to §9.6's mandatory list would be tidier (MINOR).

### 2.5 O6 — exhaustiveness of the CITED residue, recomputed

Extracted every `lem:|thm:|prop:|cor:` label in `docs/DESIGN.md` lines 1040–1862 and differenced
against §13.2 items 1–12 plus the `lem:commute` carve-out. **36 distinct labels; 36 covered; 0
uncovered.**

```
item 1  prop:standard-succinct-sat, prop:explicit-padded-succinct-deciders
item 2  lem:ld-soundness, lem:ld-complexity
item 3  lem:pauli-completeness, thm:pauli, cor:pauli-binary, lem:delta-bound,
        lem:introparams-complexity, lem:qld-complexity
item 4  lem:detyping-verifiers
item 5  thm:oracle-completeness, thm:oracle-soundness
item 6  thm:pcp-decider
item 7  thm:ar
item 8  lem:intro-sampler-complexity, lem:intro-decider-complexity, thm:introspection
item 9  prop:anchoring, thm:bvy, thm:repetition
item 10 lem:compress-independent-samplers, thm:compression
item 11 lem:dhalt-values, lem:lambda, thm:halting
item 12 lem:cl-kth, lem:cl-concat, lem:cl-func-prod, lem:cl-dist-prod, lem:cl-downsize,
        lem:downsize_sampler, lem:downsize_typed_sampler, lem:downsize-cl-dist, lem:perp_perp
carve   lem:commute  (checked symplectically on every sampled commutator)
```

The remaining §9–13 labels are all construction/definition labels, none soundness-bearing:
`def:cl-canonical, def:decider, def:downsize_sampler, def:introparams, def:sampler,
def:sampler-sample, def:typed-decider, def:typed-sampler, enu:ar-game, enu:cl-map-sum,
enu:cl-space-sum, enu:hiding-same, eq:c_rep, eq:mu-gamma, eq:re-eps-1, eq:re-eps-2, fig:compress,
fig:decider_pauli, fig:type-graph-intro, rk:higher-level`.

I also checked every one of those labels actually exists in `ground-truth/gt-*.tex`
(`\label{…}` present): **no phantom citations**. Spot-checked item 12's new line ranges:
`gt-03:L263-L270` = `lem:perp_perp`, `L300-L313` = `def:canonical-complement`,
`L375-L384` = `def:cl-canonical`, `gt-04:L410` = `lem:cl-downsize`. **All correct.**
The word "exact" is dropped and the audit method (`rg`, sort-unique, classify) is stated.
**ACCEPTED — the list is now genuinely exhaustive for the current text.**

### 2.6 O9 — the four TB5 transcripts, verified against `thm:repetition`

`gt-11:L216-L220` confirms the guard applies to **all four** tuples: "the decider `D^rep` checks
if any component of the tuples `x,y,a,b` have length larger than `(λn)^τ` bits, and if so then it
rejects (this includes the case that `x,y,a,b` are not properly formatted as `k(n)`-tuples)" —
strict "larger than", so the design's `>` is right. At `λ=τ=c'=1, n=9`:
`k = (λn)^{(1+c')τ} = 9² = 81`, `B = (λn)^τ = 9`, `s^anch = 1+8 = 9`, `s^rep = 81·9 = 729`,
levels `1 → 3 → 3`. **All confirmed.** Consequently the honest *question* component is exactly
`9 = B` bits, so `T5-boundary`'s "accept exactly `B=9` bits" half is not only realizable but is
the honest case, and any `≥` mutation of the component guard rejects the honest transcript.
`T5-game-seed1` works because the transcript freezes the *golden* answer `1` rather than
recomputing it, so under `M5-anchor-zero` the question becomes `0` while `a=1`, and
`a=x ∧ b=y` rejects — this repairs precisely r1's "self-consistent echo" defect.
`prop:anchoring` (`gt-11:L118-L131`) confirms `ℓ+2`, `s(n)+8`, `4·16²ε`, and "the sampler
`S^anch` only depends on the sampler `S`", grounding §10.3's dependency-set test.

### 2.7 O7/O10 — spot checks

`thm:introspection` item 3 (`gt-08:L809-L815`) is verbatim
`Ent(V^intro_n,1-ε) ≥ max{Ent(V_{2^n},1-δ(ε,n)), (1-δ(ε,n))·2^{2^{λn}}}`; §9.2's `IntroGap` and
§12.1's recorded chain both now carry the `max` and the floor. `def:lambda` (`gt-05:L641-L653`)
and `eq:intro-complexity-assump` (`gt-08:L983-L985`) are the two anchors used in N1 below.
`definitions.md` §H rows exist and are consistent with DESIGN for **all four** SOURCE_REPAIR tags
used in §9–13 (`AR-field-align`, `zero-map-factor-partition`, `intro-3Q-guard`,
`intro-decider-fixed-width`) — verified by grep in both directions.

---

## 3. New MAJOR objections

### N1 — MAJOR · the introspection decider's `R = N^λ` child-fuel gate cannot pass at either TB6b fixture, and §11.6 simultaneously prints the hypothesis as `FAIL` and requires the gate as a `PASS`

**Location.** `DESIGN.md` §11.4 L1474 ("Every call to the input sampler or decider is fuelled by
exactly `R`; timeout rejects before an over-budget child returns"); §11.6 L1566 ("Also require
every child query below its `R` timeout"); §11.6 mutation 12 (`M-intro-fuel`); §13.3 C14's
acceptance clause. Not reachable from r1: r1's offered `M-intro-fuel` questioned the *budget's
correctness*, never whether `R` is large enough for the honest child, and at `a403c9b` the same
sentence existed but the fixtures were not yet the object of an acceptance claim over all pairs.

**Independent computation / citation.** The gate is executable, not a hypothesis:
`gt-08:L419-L421` — "whenever `S` or `D` is called as a subroutine, `D̂^intro` aborts and rejects
if the subroutine takes more than `N^λ` **time steps**." The source's own completeness proof says
what makes it harmless (`gt-08:L983-L988`, `eq:intro-complexity-assump`):

```
max{ TIME_S(N), TIME_D(N) } <= N^lambda = R
"This assumption on the time complexity of V ensures that D^intro never aborts due to a timeout."
```

and `L521-L522` ties it to λ-boundedness: "We assume that the original verifier `V` is
`λ`-bounded and in particular the running time of the original sampler `S` (and therefore its
dimension) is at most `R = N^λ`." `def:lambda` (`gt-05:L646-L652`) has **two** conditions:
(i) `TIME_S(n), TIME_D(n) ≤ n^λ` for `n ≥ 2`, and (ii) `|V| ≤ λ`.

Now evaluate `R` at the two fixtures:

```
TB6b-E : n=2, N=4, lambda=1  =>  R = 4^1  = 4
TB6b-M : n=2, N=4, lambda=2  =>  R = 4^2  = 16
```

No faithful metering lets an honest child query finish in `4` steps: the sampler must at minimum
consume a five-field input tuple `(N,w,marginal,j,z)` and emit an `s(N)`-bit answer. At `TB6b-M`
the child is a 3-stage, 6-dimensional sampler that must, per query, select a prefix-dependent
factor and apply a `2×2` matrix — far more than `16` steps. So §11.6's required check "every child
query below its `R` timeout" **cannot pass**, and every transcript that reaches steps 2, 3, 5, 6,
7 or 8 of `fig:intro-decider` (i.e. every `Sample`/`Introspect`/`Read`/`Hide` pair — precisely the
pairs C14 quantifies over) rejects at the timeout, *before* the `3Q` guard is ever consulted.

The design is self-contradictory here, which is what makes this MAJOR rather than a fixture nit:
§11.6's own policy report prints `input lambda-bounded description FAIL for the multi-byte toy
quote` — that is `def:lambda` condition (ii). Condition (i), `TIME_S(N) ≤ R`, is the half the
executable gate enforces, and it is **not reported anywhere**, yet the same paragraph demands its
consequence as a PASS. Either alternative is a defect: if the metering unit is a genuine
interpreter step, the required PASS is unachievable; if it is coarse enough that honest calls fit
in `4`/`16` units, then `M-intro-fuel`'s killer ("a metered child taking `R+1` steps") is not a
meaningful over-budget witness and the fuel log is unfalsifiable.

Note the scoping: TB7 is **unaffected** (`λ=32768`, `R = 4^32768`), and TB5 is unaffected (its
guards are length guards, and `TIME_D ≤ B` is correctly left CITED in §10.2). The defect is
confined to TB6b — and it is the second instance of exactly the pattern O2 repaired: a literal
source guard that rejects honest behaviour once the parameters are made tiny.

**FIX DEMAND.** (a) Declare the fuel unit in §11.4 in one clause ("one metered quoted-interpreter
step"), and add `TIME_child(N) ≤ R` to §11.1's reported capacity chain as a separate predicate,
distinct from the `|V| ≤ λ` description predicate. (b) Then either raise `λ` at both TB6b
fixtures until the honest metered cost fits — `λ=8` at `N=4` gives `R = 65,536`, leaves
`R ≥ 4 PASS`, `s(N) ≤ R PASS`, `M ≥ R FAIL`, `Q ≥ s(N) PASS` and `introparams(R)` equality `FAIL`
all unchanged, and requires only that the `|V| ≤ λ` row be re-printed — or add an explicit
`toy_child_fuel` override reported as a **FAILED** production predicate under §12.4, never as a
PASS. (c) Print, per fixture and per query mode, the honest child's exact metered cost beside `R`.
(d) Re-scope C14's acceptance clause to name whichever route is taken.

**SURVIVING WEAKER STATEMENT.** The placement of the timeout before the child returns, the
exact-`R` fuel accounting log, and `M-intro-fuel`'s redness are checkable at any declared fuel
unit; exact-mass-one acceptance over the `116`/`128` oriented pairs is evidence for the operative
`3Q` guard, the hiding/sampling predicates and the stabilizer simulation **only relative to a
declared toy fuel budget**, not under the source's `R = N^λ` gate.

### N2 — MAJOR · the O3 repair (`s_0 = 1 → 9`) makes `Q_I ≥ s_0(N)` fail at TB7, so the introspection answer schema is unrepresentable there — a *second* non-executed layer, while §13.2 asserts `enu:ar-game` is "the explicit exception"

**Location.** `DESIGN.md` §12.5 (`s_0=9` with `(q_I,m_I,d_I)=(2,1,1)`; "The other locally
applicable Introspect, PCP encoding-consistency, low-degree, detype, anchoring, and repetition
sub-tests retain their individual outcomes"); §13.2 first paragraph ("the locally feasible calls
execute … Pauli/introspection predicates … The actual-`D1` `enu:ar-game` call is the explicit
exception"); §13.1's TB7 required-output cell ("local sub-test results").
Genuinely new: at `a403c9b` the TB7 input was the one-bit identity verifier (`s_0 = 1`), so
`Q_I = 2 ≥ 1` held and this defect did not exist. **The repair created it.**

**Independent computation / citation.** At TB7's printed toy tuple,
`M_I = 2^{m_I} = 2` and `Q_I = M_I·log_2 q_I = 2·1 = **2**`, while the new input has
`s_0(N) = **9**`. The source requires the ambient space to embed:

```
gt-08:L525-L531 : "the space V is identified in a canonical way as the register subspace of
                   F_2^Q spanned by e_1,...,e_{s(N)}"
```

which is impossible for `s(N) = 9 > Q = 2`. Two independent consequences follow, both fatal to
the introspection layer *at TB7 only*:

1. every non-Pauli answer field (`y, z, y^⊥, x ∈ V`) needs `9` bits and the wire format provides
   `Q_I = 2`;
2. even granting an oversized field, `3Q_I = 6 < 9`, so **both** the literal `≥ 3Q` guard and the
   design's repaired operative `> 3Q` guard reject every honest non-Pauli introspection answer.

The design *knows* (1): §12.5's table prints `intro Q_I>=s_0(N) … FAIL` and the prose says "print
the resulting failed `Q_I>=s_0(N)` predicate". What it does not do is draw the consequence.
So at TB7: the Pauli-typed introspection sub-tests (answers in `F_2^{Q_I}`) do execute, and the
`Introspect`/`Sample`/`Read`/`Hide_k` sub-tests **cannot**. §13.2 — the normative
residue-boundary document, and the deliverable r1's O6/O5 were about — asserts the singular
"**the** explicit exception". There are two. §12.5's "retain their individual outcomes" leaves
undefined whether these are `FAIL` or `VACUOUS`, although §12.4's own rule makes `VACUOUS`
mandatory "when a source-check guard set is empty". This is the same defect class r1 charged as
MAJOR under O5 (a concealed second non-execution on the boundary document), relocated by the
fixture change.

**FIX DEMAND.** (a) In §12.5 state explicitly that `Q_I = 2 < s_0(N) = 9` and `3Q_I = 6 < 9` make
the non-Pauli introspection answer schemas unrepresentable at TB7, and print those sub-tests
`VACUOUS(owner=Q_I<s_0)` rather than "individual outcomes". (b) In §13.2 replace "the explicit
exception" by an explicit two-item list (`enu:ar-game` on the actual `D1`, and the non-Pauli
introspection answer schema at `Q_I < s_0`), each with its owner, and say that TB6b — not TB7 —
is where the introspection predicates execute. (c) Add a TB7 mutation `M7-intro-schema` that
forges a `PASS` or an executed non-Pauli introspection sub-test at `Q_I < s_0`. (d) Alternatively,
raise `(q_I,m_I)` at TB7 so `Q_I ≥ 9` (e.g. `(q_I,m_I,d_I)=(2,4,1)` gives `M_I=16`, `Q_I=16`) and
re-print `s_1 = (3·4+3)·1 + 200 = 215`, `s_2`, `s_anch`, `s_rep` — note this **changes the
`206→840→848→1696` chain**, so if this route is taken every number in §12.2/§12.5/§13.1/C15 must
move in lockstep.

**SURVIVING WEAKER STATEMENT.** TB7 establishes the composition order, the level chain `9→5→7→9`,
the dimension chain `206→840→848→1696`, the exact canonical description sizes, the fixed-width
two-input sampler-hash independence, the printed predicate report and one finite `Fix`/`OutOfFuel`
unfold; the Pauli-typed introspection predicates execute there, and neither the non-Pauli
introspection answer schema nor `enu:ar-game` on the actual `D1` contributes any TB7 transcript
evidence.

---

## 4. Residual MINOR / NOTES (recorded; not blocking a PASS)

* **m1 (lockstep, `definitions.md` §G).** The `SOURCE_REPAIR` gloss is "A totalizing convention or
  typo repair needed to make the executable interpretation definite." Three of the four uses fit;
  `intro-decider-fixed-width` does not — §12.3 itself says "this is a repaired construction, not a
  presentation convention", and it changes the AnswerReduce input `σ_1`. I demanded that tag in
  r1's O10, so this is my own instruction's residue, not an escape. **Fix:** widen the §G gloss to
  "…or a construction change that closes a source gap, with the changed theorem input named", or
  add a `SOURCE_DEVIATION` grade.
* **m2 (§9.2 notation).** The `enu:cl-map-sum` display writes `Linear(i,prefix_i,…)` without
  defining `prefix_i`. Since substituting the wrong prefix is exactly the `M6-factor-prefix` bug
  class and §9.2 is the normative statement, spell out `prefix_i := Marginal(i-1,x)` (§11.4
  already does this correctly).
* **m3 (§9.2 vs §9.6 coverage).** §9.2 promises the replay "on every exhaustive finite fixture and
  every branch-directed reachable prefix chain" while §9.6 grades it "CHECKED **finite** replay".
  Read literally the former is infeasible for the level-9, 1696-bit TB7 output (the `L_DLine_i`
  stages alone admit `≈ 2^{22}` reachable chains per PCP type, before the `54`-fold type product
  and the `k=2` repetition). **Fix:** say "a declared branch-directed chain set" and print the
  coverage count per sampler in TB7's report.
* **m4 (§11.1 capacity chain).** `Q ≥ s(N)` — the predicate the `F_2^Q` embedding actually needs —
  is derivable from `s(N) ≤ R ≤ M ≤ Q` only while `R ≤ M` holds, and `M ≥ R` **FAILs** at both
  TB6b fixtures. Print `Q ≥ s(N)` as its own link (it holds: `2 ≥ 1`, `12 ≥ 6`). TB7 already
  prints it, inconsistently.
* **m5 (§11.6 `TB6b-E`).** Pin the child answer length `|a|`; the printed count `10/116` is exact
  only if `|a| ≤ 1` at `Q=2` (a `Read` answer of `2Q+|a|` reaches `3Q` at `|a|=Q`).
* **m6 (§11.6 `TB6b-M`).** The `TB6b-M` policy report prints only the capacity chain; the
  admissibility / `m|q` / canonical-`introparams(R)` rows are inherited from §12.4's global rule
  but not shown. For the record they are: `q=8=2^3` admissible, `2|8`, and canonical equality
  **FAIL** (`k=3` forces `c=1`, but `c` is even by `def:introparams`; and `m=2 ≠ 8`). Print them.
* **m7 (§11.6 mutation 11).** Enroll the reject-preservation transcript in the mandatory test list
  (see the `M-detype-view-orientation` row above).
* **m8 (§9.6).** Add `pauli_sampler`, `tilde_S_intro` and `graph_sampler` to the list of
  signatures for which the output-sampler PROVE row is mandatory; today they are covered only by
  §9.2's universal quantifier.
* **m9 (§11.4, cosmetic).** The `Q`-bit encoding is presented as the design's pin; it is the
  source's own (`gt-08:L528-L530`). Say so — it strengthens the section.
* **m10 (§12 heading).** "end to end" survives as a section title; consider "…end to end, with
  two named non-executed layers" once N2 is fixed.
* **m11 (§9.4 / `definitions.md`).** `anchored_repeat` has no §H row, unlike `k_rep`, `B_rep`,
  `anchor`. One row.

---

## 5. MERGE PROPOSALS — C12–C15

| id | decision |
|---|---|
| §13.3 preamble | **AUTHORIZED** (unchanged; `claims/` verified untouched). |
| **C12** | **AUTHORIZED** — paste the §13.3 row text verbatim as `CONJECTURE`. It carries the r1-mandated `lem:cl-kth` disclaimer, the `rk:higher-level` zero-map clause, the `E^ar` tensor correction and all six `DL9-*` names. |
| **C13** | **AUTHORIZED** — paste the §13.3 row text verbatim as `CONJECTURE`. The negatives that `M5-anchor-answer`, `M5-or` and the component boundary need are now entailed by the statement, and the `1,1 → 3,9 → 3,729` / `k=81` / `B=9` arithmetic is re-confirmed against `prop:anchoring` and `thm:repetition`. |
| **C14** | **HOLD.** Missing step, named: **N1**. The clause "every support transcript is accepted by the repaired operative `>3Q` guard" is not established while `R = 4` (`TB6b-E`) and `R = 16` (`TB6b-M`) gate every child query, and while §11.6 prints the `λ`-bounded hypothesis `FAIL` and simultaneously requires the gate to PASS. Everything else in the row is verified and may be promoted the moment N1's fix demand (a)+(b) lands: the counts `34`/`116`/`38`/`128`, level `5`, dimensions `142`/`179`, `Q=2`/`12`, `3Q=6`/`36`, the literal rejection counts `10`/`22`, `L^alice ≠ L^bob` with the swapped pair off-support, the live `k ∈ {1,2}` hiding chain, and `dm/q = 1/4`. |
| **C15** | **AUTHORIZED with two exact edits**, then paste as `CONJECTURE`. (1) `depends-on` must read `C12,C13,C14` — `C10` does not exist in `claims/CLAIMS.md` (present ids: `C1,C2,C3,C4a,C4b,C5,C6,C7,C8,N1`; `C9`/`C10`/`C11` were proposed in briefs 18/23/24 and never authorized), so a verbatim paste would create a dangling DAG edge, violating law 1's addressability. The TB3 front-end dependency is already named in C15's promotion bullet, which is the right place for it until a `C10` row exists. (2) Append this sentence, which is N2's honest scoping and must not be paraphrased upward: *"Two layers are not executed on faithful content at this fixture and are printed with owners: `enu:ar-game` against the actual `D1`, and — because `Q_I = 2 < s_0(N) = 9` and `3Q_I = 6 < 9` — the non-Pauli introspection answer schemas; only the Pauli-typed introspection predicates execute at TB7."* |
| §13.3 "Missing steps" bullets | **AUTHORIZED**, with two additions: to the **C14** bullet append "declare the child fuel unit and either raise `λ` so the honest metered child cost fits `R` or record an explicit failed `toy_child_fuel` production predicate (N1)"; to the **C15** bullet append "print the non-Pauli introspection answer schemas `VACUOUS(owner=Q_I<s_0)` and list both non-executed layers in §13.2 (N2)". |
| DD-23 … DD-30 | **AUTHORIZED** — all eight present with rationale and rejected alternative. DD-24 and DD-28 are now honoured where r1 found them violated (O7, O5); N1 is a DD-28 violation of the same shape (a toy-regime deviation not made machine-visible) and N2 a DD-30 one (a green sub-test list read as broader evidence than it is). |
| §13.2 residue inventory | **AUTHORIZED as the exact residue** for the current §9–13 text (§2.5), conditional on N2's fix to its opening paragraph. |

---

## 6. Assessment

Objection trajectory: **10 MAJOR (r1) → 2 MAJOR (r2)**, with 32 of 33 r1 rows ACCEPTED on
independent recomputation, 1 PARTIAL, 0 REJECTED, and no retraction or downgrade used as an
escape. Both new MAJORs are narrow, source-grounded, and cheap to close — N1 by declaring a unit
and one parameter change, N2 by two sentences (or by a parameter change whose lockstep cost is
stated). Both are second instances of the *same* pattern the repair correctly fixed once: a
literal source guard (`≥ 3Q`; `R = N^λ`; `Q ≥ s(N)`) that stops being satisfiable when the
parameters are shrunk to toy size. The right structural response, beyond the two fixes, is a
single §12.4 rule: **every source guard whose threshold is a function of the paper's parameters
must have its toy-regime evaluation printed against the honest witness it is supposed to admit.**
That rule would have caught O2, N1 and N2 in one pass.

---

VERDICT: FAIL(N1,N2)
