# Verdict — DESIGN v2 (`docs/DESIGN.md` §9–13, `docs/definitions.md` §H), round 1

Critic: Opus subagent, adversarial lane. Target: **archived tree at commit `a403c9b`**
(`git archive a403c9b | tar -x`), evaluated against `ground-truth/gt-*.tex` only.
Prior: `verdicts/design-r4.md` (§1–8 converged; not re-litigated). No Julia run (no code rung under review).
Scope: the 691 new lines of `docs/DESIGN.md` §§9–13 and the 43-line `docs/definitions.md` delta.

Positive findings established by independent recomputation before the attack, so the
objections below are read as local defects and not as a rejection of the section:
the level chain `9→5→7→9`, the toy dimension chain `206→840→848→1696`, the count
`26` of Pauli types, the graph edge formulas (`86` and `6ℓ+110` oriented pairs), the
`3Q` guard's literal presence, `eq:mu-gamma`, `eq:re-eps-1`, `eq:re-eps-2`, `eq:c_rep`,
`k(n)=(λn)^{(1+c')τ}`, the strict `>` in the repetition threshold, `4·16²ε`, `16^{|T|}ε`,
`dim V_G = 4|T|`, `dim_q V^pcp = 2m'+6`, `m'=5m+5+s`, the `lem:commute` hypothesis
direction, and the `(m'+6)(m'd+1)=22·177=3894` answer size all check out exactly.
No soundness theorem is relabelled CHECKED by execution anywhere in §§9–13 except as
recorded in O7 and O10. Full arithmetic is in §R below.

Severity legend: FATAL (the construction cannot work as written) · MAJOR (a claim or a
promised check is false, unachievable, or unfalsifiable as specified) · MINOR · NOTE.

---

## MAJOR objections

### O1 — MAJOR · the defining well-formedness condition of `def:sampler` is never checked, and §9.4's padding rule is wrong for the zero map

**Location.** `DESIGN.md` §9.1 (`Factor` returns "the length-`dimension(n)` indicator of a
register subspace"); §9.2 (`LawCert` contents); §9.4 ("Shorter levels are padded by
empty zero stages before the calls"); §9.6 (the PROVE grade table); §10.1 ("`Anchor`
returns the zero map on the same ambient space" for *each of the four query modes*);
§11.2 ("`PauliX` and `PauliZ` are zero maps. All maps are padded to common level 3");
§11.3 ("the zero map for every new type").

**Independent computation / citation.** `def:sampler` (`gt-04-cl.tex:L572-L601`) and
`def:typed-sampler` (`gt-06-types.tex:L095-L131`, esp. `L106-L108`) both require the
returned marginals, factor spaces and linear maps to *satisfy the conditions of*
`lem:cl-kth`. Those conditions include (`gt-04-cl.tex:L167-L173`)

* `enu:cl-space-sum`: `V = ⊕_{i=1}^{ℓ} V_{i, x^{L_{<i}}}` for **all** `x ∈ V`;
* `enu:cl-map-sum`: `L_{≤k}(x) = Σ_{i≤k} x^{L_i}` for all `x`.

Now take the anchoring sampler *literally*, as §10.1 says it does. `gt-11-parallel-repetition.tex:L096`:
on `(n,w,factor,j,u,Anchor)` the machine "returns the binary representation of the zero
vector in `F_2^s`" — for **every** `j`. Then `⊕_{j=1}^{ℓ} V_{j,u} = {0} ≠ V`, so
`enu:cl-space-sum` fails and `\hat S^anch` is *not* a `def:sampler`-valid typed sampler
on the `Anchor` type. The same holds for `L_{Pauli,W} = 0` (`gt-07-ldt.tex:L1106-L1108`,
explicitly called a `0`-level CL function) and for every
`τ ∈ type^intro \ type^pauli` (`gt-08-introspection.tex:L333-L335`).

The source's own remedy is `rk:higher-level` (`gt-04-cl.tex:L122-L130`): the `0` function
is viewed as `1`-level "by setting `V_1=V`, `V_{>1}={0}`, `L_1(x)=0`". So the correct
factor report for a zero map padded to level `ℓ` is **all-ones at stage 1** and zero
thereafter — not "empty zero stages" at every stage. §9.4's padding rule is therefore
literally wrong precisely on the maps that anchoring, the Pauli test and introspection use
most (a genuine `k`-level map padded to `ℓ > k` *is* correctly padded by empty stages,
because its own `k` stages already sum to `V`; only `k = 0` breaks).

This is not cosmetic. §11.4's decider consumes `Factor(N,role,1,0)` and then
`Factor(N,role,j,prefix)` and runs Gaussian elimination on the resulting basis
(`gt-08-introspection.tex:L570-L577`, `L659-L684`). A child that reports `{0}` where
`V_1 = V` is required makes every dual-image check vacuous — which is exactly how
`M6-perp` stops being red (see O3).

Compounding this: neither §9.2's `LawCert` list nor §9.6's PROVE table contains **any**
obligation of the form "the reported factor indicators direct-sum to the ambient space
along every reachable prefix chain" or "the reported marginals telescope". §9.3 checks
`marginal_k`/`apply` for the *`CLStep` adapter only*. So the single condition that makes
a four-query surface a sampler at all is unchecked for every transformation output —
`downsize`, `direct_sum`, `product`, `detype`, `anchor`, `repeat`, `\hat S^pauli`,
`\hat S^intro`.

**FIX DEMAND.** Add `enu:cl-space-sum` + `enu:cl-map-sum` replay to §9.2's `LawCert` and to
§9.6's CHECKED row for every constructor; replace §9.4's "padded by empty zero stages"
with the `rk:higher-level` rule (stage 1 = whole space for a `0`-level map, empty stages
thereafter); and tag the literal `gt-11:L096` / `gt-07:L1106` / `gt-08:L333` zero-factor
reports as `SOURCE_REPAIR(zero-map-factor-partition)` with a definitions.md row.

**SURVIVING WEAKER STATEMENT.** The four-query wrappers of §9.4 reproduce the source's
*field, level, dimension, dependency, byte-size and call-count* laws; no claim is made
that their outputs satisfy `lem:cl-kth`, hence none of them is yet asserted to be a
`def:sampler`/`def:typed-sampler` in the source's sense.

---

### O2 — MAJOR · the retained literal `≥ 3Q` guard rejects the honest `Hide` answer, so TB6b's promised acceptance is false under §11.4's own encoding

**Location.** `DESIGN.md` §11.4 (the guard, the answer-schema table, and "chooses toy
answers strictly shorter than `3Q`"); §11.6 ("require the decider to accept every
outcome ... for all 116 oriented typed pairs"); §13.3 claim C14.

**Independent computation / citation.** The guard is literal (`gt-08-introspection.tex:L424-L425`):
reject if `max{|â_A|,|â_B|} ≥ 3·2^m·log q`. But the source *also* fixes the answer
syntax as `Q`-bit strings: `L528-L530` gives the `(Read,v)` answer as
`(y,y^⊥,a) ∈ F_2^Q × F_2^Q × {0,1}^*`, `L533-L534` says the decider rejects if `y,y^⊥`
are "not presented as vectors in the subspace `V`", and — decisively —
`L588-L591` says the maximum-length answer is a `(Read,v)` triple **or** a
`(Hide_k,v)` tuple `(y,y^⊥,x) ∈ V×V×V`, and "either way, the maximum answer length
should be `3Q = 3·2^m·log q` bits long."

So the honest `(Hide_k,role)` answer has length **exactly `3Q`**, and `≥ 3Q` rejects it —
in production, not only in the toy. §11.4 adopts precisely this encoding ("All `y,z,y_perp,x`
are checked to lie in the first `s(N)` coordinates of the **`Q`-bit** Pauli register") and
then claims it can dodge the boundary by choosing shorter answers. It cannot: the length
is forced by the schema, not chosen.

Concretely for TB6b (`§11.6`): `(q,m,d)=(2,1,1)` ⇒ `M=2^m=2`, `log₂q=1`, `Q=M·log q=2`,
`3Q=6`. Honest `Hide_1` answer `=(y,y^⊥,x)` = three `Q=2`-bit strings = `6` bits `= 3Q`
⇒ **reject**. At `ℓ=1` the `Hide` types are incident to `PauliX–Hide_1,{A,B}` and
`Hide_1,{A,B}–Read,{A,B}` (4 non-loops ⇒ 8 oriented) plus 2 self-loops, so **at least 10
of the 116 oriented pairs reject**, falsifying C14 as worded. (Under the alternative
`s(N)`-bit encoding, `3·s(N)=3 < 6` and the guard is harmless — which is why the encoding
must be pinned rather than left ambiguous.)

Two further consequences the design does not record. (i) Under the `Q`-bit reading the
guard implies `|a| < Q` for `(Read,role)` — a *capacity constraint on the original
decider's answer length* that is absent from §11.6's predicate report. (ii) Calling this
`SOURCE_REPAIR(intro-boundary-conflict)` while changing nothing is a mislabel (see O11):
the honest repair is `> 3Q`, and the design's own reasoning shows why.

**FIX DEMAND.** Pin the non-Pauli answer encoding (`Q`-bit vs `s(N)`-bit) in §11.4 in one
sentence; under the `Q`-bit reading, replace the guard by `> 3Q` and record it as a real
`SOURCE_REPAIR(intro-answer-bound)` with a red mutation on the `>`/`≥` boundary and a
reported predicate `|a| < 3Q − 2Q`; under the `s(N)`-bit reading, state that the schema
transmits `s(N)`-bit vectors and drop the "Q-bit register" phrasing.

**SURVIVING WEAKER STATEMENT.** With the guard as the source writes it, the introspection
decider accepts the honest `Introspect`/`Sample`/`Read`/Pauli transcripts whose total
length is `< 3Q`, and rejects the honest `Hide_k` transcript; the boundary is a genuine
defect in `fig:intro-decider` rather than a parameter choice.

---

### O3 — MAJOR · no rung in the ladder exercises a non-degenerate multi-stage factor partition, so `M6-factor-prefix` cannot be killed and the hardest part of §11.4 is never executed

**Location.** `DESIGN.md` §11.6 (TB6b: "`ell=1`", "an identity sampler of dimension 1");
§12.5 (TB7 input: "a quoted nine-level padding of the **one-bit** identity verifier");
§11.6 mutation 5 (`M6-factor-prefix`); §13.1 (TB6b owns the nine `M6-*`).

**Independent computation / citation.** `fig:intro-decider` step `enu:hiding-same`
(`gt-08-introspection.tex:L464-L473`) applies only for
`k ∈ {1,…,ℓ−1}`. At `ℓ = 1` that index set is **empty**: there is no
`(Hide_k,Hide_{k+1})` edge in `G^intro` (my recount in §R(c) gives `39+2ℓ` non-loops,
of which the `Hide`-chain contributes `2(ℓ−1) = 0`), so the check, the adaptive query
schedule of `gt-08:L570-L577` and `L659-L684` (prefix-dependent `Factor`, per-basis-vector
`Linear`, Gaussian elimination, canonical complement) and the `M6-factor-prefix` and
`M6-perp` mutants are all **unreachable in TB6b**. `M6-factor-prefix` is by construction
not red.

TB7 does not rescue it. §12.5 fixes the input at "the one-bit identity verifier" padded
to nine levels, i.e. `s_0 = 1`. Since `V = ⊕_{j=1}^{9} V_{j,u}` and `dim V = 1`, exactly
one stage has a one-dimensional factor space and the other **eight are `{0}`**. So the
nine-level `Hide` chain in TB7 is again vacuous, and no rung anywhere in the ladder ever
runs the decider's adaptive prefix/dual schedule on a genuinely multi-stage CL function.

Second, independent degeneracy at the same fixture: TB6b's `m = 1`. In
`gt-07-ldt.tex:L1000-L1001`, the `(DLine,W)` question sets `v' = π_{i−1}(v)` with
`i = χ(s) ∈ {1,…,m} = {1}`, so `v' = π_0(v) = 0` and `L_DLine` collapses onto
`L_ALine`; with `d=1, q=2` the low-degree test's Schwartz–Zippel margin is `dm/q = 1/2`.
So the six `LD/Pauli` edges of `G^pauli` are exercised only in their degenerate form.
§12.4 promises that every *predicate* is printed `PASS/FAIL/NOT_EVALUABLE`, but
**vacuity is not a predicate** and is therefore invisible — exactly the "silently
bypassed" pattern the toy-boundary policy is supposed to prevent.

**FIX DEMAND.** Give TB6b a second fixture with `ℓ ≥ 2` and an input sampler of
dimension `≥ 2` whose factor spaces are non-trivial at two stages (TB1's `L_ALine` at
`seed_dim 5, ℓ=2` is already built), so that `enu:hiding-same` and `M6-factor-prefix`
have a live edge; give TB7 an input with `s_0 ≥ 9`; and add a `VACUOUS` grade printed
per source check whenever its guard set is empty or its margin is `≥ 1/2`.

**SURVIVING WEAKER STATEMENT.** TB6b as specified is evidence for the Pauli predicate,
the sampling and `Introspect/Read` hiding checks, the detyping parser and the graph/type
counts; it is *no* evidence for the multi-stage hiding chain, the adaptive factor/dual
query schedule, or the low-degree sub-tests.

---

### O4 — MAJOR · TB6b's identity sampler makes `M6-game` unkillable

**Location.** `DESIGN.md` §11.6 (fixture: "an identity sampler of dimension 1"),
mutation 7 (`M6-game`: "swap introspected Alice/Bob questions in the final call;
asymmetric toy decider rejects").

**Independent computation.** `fig:intro-decider` step `enu:intro-game`
(`gt-08-introspection.tex:L481-L485`) calls `D(N, y_w, y_{w̄}, a_w, a_{w̄})`. With an
identity sampler, `L^alice = L^bob = id`, hence `y_A = y_B = z` for every seed. The
mutant computes `D(N, y_B, y_A, a_A, a_B) = D(N, y_A, y_B, a_A, a_B)` — **identically the
same value**, for every transcript, no matter how asymmetric `D` is. The stated killer
("asymmetric toy decider rejects") cannot fire.

**FIX DEMAND.** Require `L^alice ≠ L^bob` in the TB6b fixture (e.g. dimension 2 with
`L^A = ` projection on `e_1` and `L^B = ` projection on `e_2`), and state the mutant's
killer as "the `IntrospectAlice–IntrospectBob` transcript on a seed with `y_A ≠ y_B`".

**SURVIVING WEAKER STATEMENT.** `M6-game` is red only for fixtures whose two CL functions
differ on the sampled support; on TB6b as specified it is dead code.

---

### O5 — MAJOR · TB7's AnswerReduce step substitutes PCP *parameters* but not PCP *content*: the toy PCP is not the arithmetization of `D^{(1)}`, so "16 honest accepts" cannot hold

**Location.** `DESIGN.md` §12.5 (toy tuple `(q_A,m_A,d_A,s_A,m'_A)=(2^11,1,11,6,16)`;
"constructs honest stabilizer/PCP/repeated answers, and calls the final classical
decider. It requires all finite construction checks and toy transcripts to pass");
§13.1 TB7 row ("16 honest accepts"); §12.4 (ToyPolicy "substitutes only parameter values
and repetition count").

**Independent computation / citation.** `fig:decider-pcp` step `enu:ar-game`
(`gt-10-answer-reduction.tex:L2060-L2062`) rejects unless
`pcpverifier((D, n, T, Q_len, γ, x_{w,A}, x_{w,B}), (z, a_w))` accepts — with `D` the
*actual* decider description of the input verifier, here `D^{(1)}`, the introspection
decider. So the honest PCP proof `Π = (g_1..g_5, c_0..c_{m'})` (`def:pcp-proof`,
`gt-10:L1429-L1442`) must be the arithmetized bounded trace of `D^{(1)}`, and
`def:pcpparams` (`gt-10:L1396-L1422`) fixes `m = m(T,σ)`, `s = s(n,t,Q,σ)` from
`prop:explicit-padded-succinct-deciders` with `T(n) = (2^{λn})^μ`, `σ = |D^{(1)}|`
(`eq:ar-params-1`, `gt-10:L1813-L1828`).

At TB7's own parameters (`λ = 32768`, `n = 2`) we have `T(n) = (2^{65536})^μ` and, after
§12.3's fixed-width specialization, `σ = |D^{(1)}| = Θ(λ) = Θ(65536)` bytes. The toy sets
`m_A = 1` and `s_A = 6`, i.e. the *TB0 six-gate fixture's* shape. A succinct instance with
`m = 1` addresses at most `q^m = 2^11` clause indices, which cannot encode a trace of
length `T`; and `s = 6` is not `s(n,t,Q,σ)` for any such `σ`. Consequently the honest PCP
proof for `D^{(1)}` does not exist at the toy tuple, and reusing TB0's `Π` gives a proof
of a *different* decider, which `pcpverifier` is designed to reject. §12.5's predicate
table records only "AR tuple equals `pcpparams(n,T,Q,sigma,gamma)` | FAIL" — a
*parameter* mismatch — which conceals the *content* mismatch. Under §12.4's own rule
("Toy mode changes no constructor or parser. It substitutes only parameter values and
repetition count"), substituting the PCP instance is not a legal toy move at all.

**FIX DEMAND.** Add a printed predicate `P_pcp_encodes_D1` (the PCP instance is the
arithmetized bounded trace of the *actual* `D^{(1)}` at the printed `(T,σ)`), report it
`FAIL` in TB7, and downgrade §13.1's TB7 required output from "16 honest accepts" to
"16 honest accepts on every AR sub-test except `enu:ar-game`, which is reported
`NOT_EXECUTED` with its owner"; alternatively re-scope TB7 so the AR input is a
genuinely tiny decider whose arithmetization is feasible, and say what `λ` that forces.

**SURVIVING WEAKER STATEMENT.** TB7 as specified establishes the composition order, the
level chain, the dimension chain, the description hashes and sampler independence, and
honest acceptance for the Introspect and Repeat layers; the answer-reduction layer's
`Point_6` game check is not executed on the real `D^{(1)}` and therefore contributes no
end-to-end transcript evidence.

---

### O6 — MAJOR · §13.2's "exact set" of CITED leaves omits at least five CL-theory lemmas that §§9–10 explicitly rely on, one of them labelled "cited" in the same document

**Location.** `DESIGN.md` §13.2 ("The following is the **exact set** of paper objects
allowed to remain as CITED leaves … Any additional CITED label in a TB7 trace is a
failure").

**Independent computation.** Enumerating every source label referenced in §§9–13 and
differencing against §13.2's eleven items leaves:

| omitted leaf | where §§9–13 leans on it |
|---|---|
| `lem:downsize-cl-dist` (`gt-04-cl.tex:L533-L550`) | §9.4: "`lem:downsize-cl-dist` supplies the **cited** distribution identity" — a CITED label absent from the exact list, i.e. a direct self-contradiction |
| `lem:cl-func-prod` (`gt-04-cl.tex:L315-L327`) | §10.2: "the maximum-level law follows because direct sums do not increase level"; §9.4's `direct_sum` row |
| `lem:cl-dist-prod` (`gt-04-cl.tex:L365-L373`) | §9.4: "independent seed blocks give the product distribution" |
| `lem:cl-concat` (`gt-04-cl.tex:L282-L313`) | §9.5: "This is conditional concatenation, so the level is `ell+2`" |
| `lem:downsize_sampler` / `lem:downsize_typed_sampler` (`gt-04-cl.tex:L667-L680`; `gt-06-types.tex:L162-L178`) | §9.4's `downsize` row time law `O(C_S log q)` — an asymptotic bound, hence CITED by DD-24 |
| `lem:cl-kth` (`gt-04-cl.tex:L151-L180`) | §9.3, and the whole legality contract of §9.1 |
| `lem:perp_perp` / `def:cl-canonical` / `def:canonical-complement` (`gt-08:L659-L684`) | §11.4's dual-map computation; §11.5's commutation criterion |

§13.2's closing sentence makes the list normative in both directions, so the omission is
a defect of the section, not of taste. Note the asymmetry: §13.2 *does* take the trouble to
argue that `lem:commute` is not a leaf; it simply forgot the CL-theory layer.

**FIX DEMAND.** Add a twelfth item, "CL-function theory used as background: `lem:cl-kth`,
`lem:cl-concat`, `lem:cl-func-prod`, `lem:cl-dist-prod`, `lem:cl-downsize`,
`lem:downsize_sampler`, `lem:downsize_typed_sampler`, `lem:downsize-cl-dist`,
`lem:perp_perp`", with the same construction/theorem split used for item 4.

**SURVIVING WEAKER STATEMENT.** §13.2 lists exactly the *transformation-theorem* residue;
it is not yet the exact residue of the TB7 certificate.

---

### O7 — MAJOR · `IntroGap` drops the entanglement-floor branch of `thm:introspection`, while §9.2 claims the gap AST is CHECKED

**Location.** `DESIGN.md` §9.2 (`GapMap ::= … | IntroGap(delta_intro(epsilon,n)) | …`,
"The formula AST, variable binding, direction of implication, and strict versus weak
inequality are CHECKED"); §12.1 ("The canonical gap AST records `delta_intro`,
`delta_ar`, and the strict Repeat threshold").

**Independent computation / citation.** `thm:introspection` item 3
(`gt-08-introspection.tex:L809-L815`) is

```
Ent(V^intro_n, 1-eps) >= max{ Ent(V_{2^n}, 1-delta(eps,n)),  (1-delta(eps,n)) * 2^(2^(lambda*n)) }
```

and `tab:params` row `V^{(1)}` (`gt-12-compression.tex:L168-L171`) carries the same
`max{ Ent(V_N, 1/2), 2^(N^lambda - 1) }`. The `max` with the doubly-exponential floor is
not decoration: it is the branch that produces `thm:compression`'s
`Ent(V^compr_n, 1/2) >= 2^(N^lambda - 1)` and hence the whole recursive-compression
argument. `IntroGap(delta_intro(epsilon,n))` records only the first branch. §12.1's list
of what the gap AST records likewise omits it. Because §9.2 asserts the AST is CHECKED,
a checker built to this spec would certify a *strictly weaker* relation as faithful —
the exact failure mode DD-24 is meant to prevent. (`CompressGap` does carry an opaque
`EntanglementLowerBound`, so the design is inconsistent with itself as well as with the
source.)

**FIX DEMAND.** Change to
`IntroGap(delta_intro(eps,n), floor = (1-delta_intro)*2^(2^(lambda*n)))` with the `max`
node explicit, add the same floor to §12.1's recorded chain, and own it with a mutation
that deletes the `max` branch.

**SURVIVING WEAKER STATEMENT.** `IntroGap` as specified is a faithful AST of the
*first* argument of `thm:introspection`'s `max`; it does not represent the theorem.

---

### O8 — MAJOR · §9.4 calls `G^ar` a "Cartesian" graph product; the source's `E^ar` is the tensor product, and the two differ on the very type pairs the AR sampler needs

**Location.** `DESIGN.md` §9.4 ("`product` additionally forms the Cartesian type set and
graph when its inputs are typed"); relied on by §12.2's `typed AR` row.

**Independent computation / citation.** `gt-10-answer-reduction.tex:L1949-L1955`:

```
type^ar = type^ora x type^pcp ,  G^ar = G^ora x G^pcp  with
E^ar = { {(t,r),(t',r')} : {t,t'} in E^ora  and  {r,r'} in E^pcp }
```

i.e. the **tensor (categorical)** product: both coordinates must be adjacent. The
Cartesian product `G□H` admits `(u,v)~(u',v')` only when one coordinate is *equal*.
These are different graphs even when both factors are complete-with-loops: the pair
`((O,Point_1),(A,DLine_6))` — both coordinates distinct — is in `E^ar` but **not** in
`G^ora □ G^pcp`. Since `G^ora` is complete with loops on `3` vertices and
`E^pcp = type^pcp × type^pcp` (`gt-10:L1893-L1894`), `E^ar` is complete-with-loops on
`54` vertices, whereas the Cartesian product has degree `≈ 3+18` instead of `54`. A
checker implementing §9.4 literally would build the wrong `neigh_G` vectors, change the
sampled type-pair support, and change the accept/reject behaviour of
`detype_decider` on the AR layer (the dimension `4·54 = 216` happens to be unaffected,
which is why the error would survive a dimension-only law check).

**FIX DEMAND.** Replace the sentence with the explicit `E^ar` formula from
`gt-10:L1951-L1955`, name it the tensor/categorical product, and own it with a mutation
that substitutes the Cartesian rule (killed by an oriented-edge-count assertion:
`2·|E^ar_{non-loop}| + |type^ar|` for the product graph).

**SURVIVING WEAKER STATEMENT.** `product` forms the Cartesian product of the two *type
sets*; its graph is the tensor product of the two type graphs.

---

### O9 — MAJOR · three of the seven TB5 mutations are not red against §10.3's test list, and `M5-anchor-zero`'s stated killer cannot fire on `V_copy`

**Location.** `DESIGN.md` §10.3 (fixture `V_copy`: `ℓ=1`, `s(n)=1`, both CL maps the
identity, decider `a=x and b=y`, honest strategy "returns its one-bit question"; test
steps: four-query replay, 128 accepting transcripts, one 10-bit component rejection);
mutations 1 (`M5-anchor-zero`), 2 (`M5-anchor-answer`), 5 (`M5-or`).

**Independent computation.**

* `M5-anchor-zero` ("map Game to zero; an identity-question transcript rejects"). The
  honest strategy is a *function of the received question*. Under the mutant the `Game`
  question is `0`, the honest answer is `0`, and the decider `a=x and b=y` evaluates
  `0=0 ∧ 0=0` ⇒ **accept**, for every seed. The stated killer never fires. The mutant is
  in fact killed by the §9.6 reference-replay ("Each wrapper is compared with a concrete
  CL reference"), so the mutation's *owner* is misattributed — which matters, because a
  worker who implements only the transcript test reports a false green.
* `M5-anchor-answer` ("accept Anchor answer `1`") requires a transcript in which an
  `Anchor`-typed player answers `1`. §10.3's listed tests contain only accepting
  transcripts plus one length-guard rejection. No such negative exists.
* `M5-or` ("combine repeated decisions by OR") is invisible on any all-honest transcript;
  it needs a transcript with exactly one corrupted component. Not in the list.

**FIX DEMAND.** Add to §10.3 an explicit negative-transcript block — (a) `Anchor` answer
`1` rejects, (b) one corrupted component out of `k` rejects, (c) a component of exactly
`B(n)=9` bits is *accepted* while `10` bits rejects (this last also pins the `>` boundary
that the source states at `gt-11:L219`) — and re-attribute `M5-anchor-zero` to the
reference-replay certificate or replace `V_copy` by a fixture whose honest strategy is
not a self-consistent echo (e.g. decider `a = x ⊕ 1`).

**SURVIVING WEAKER STATEMENT.** TB5's four positive checks (levels, dimensions, query
replay, sampler-hash independence) and its length-guard negative are well specified;
`M5-anchor-zero`, `M5-anchor-answer` and `M5-or` are not yet demonstrably red.

---

### O10 — MAJOR · §12.3's fixed-width `λ`-byte specialization is an undeclared deviation that repairs a real gap in `lem:compress-independent-samplers`, and §13.2 item 10 then overclaims

**Location.** `DESIGN.md` §12.3 ("the universal introspection decider stores the
embedded sampler and decider in two fixed `lambda`-byte component slots … Therefore
`sigma_1` is an exact function only of `lambda` and `ell=9`"); §13.2 item 10 ("For
`lem:compress-independent-samplers`, **only** the asymptotic generation bound is CITED:
fixed-width specialization makes construction dependency CHECKED").

**Independent computation / citation.** `lem:intro-decider-complexity`'s construction
(`gt-08-introspection.tex:L757-L774`) hardwires `V' = V` when `|V| ≤ λ` and `V' = (0,0)`
otherwise, and concludes `|D̂^intro| = |RawIntroDecider| + |V'| + |λ| + |ℓ|`, which is
**bounded by** `poly(λ,ℓ)` but is *not* a function of `(λ,ℓ)` alone. The proof of
`lem:compress-independent-samplers` (`gt-12-compression.tex:L132-L135`) then argues that
`S^{(2)}` depends only on `λ` because "the description length of `D^{(1)}` is **at most**
… polynomial in `λ`". That inference is invalid as written: `thm:ar` says `S^ar` depends
on `|D|` (`gt-10:L2094-L2096`), and two inputs of different lengths give different `|D^{(1)}|`
and hence different `S^{(2)}`. The design *spots* this ("rather than inferring equality of
lengths from a common polynomial upper bound") and fixes it by padding — a genuine and
valuable repair.

But: (i) it is not tagged `SOURCE_REPAIR(...)`, has no `definitions.md` row, and does not
appear in the design's repair registry, so an audit of "how far do we deviate" undercounts
it; (ii) padding changes `D^{(1)}`'s bytes, hence `σ_1 = |D^{(1)}|`, hence
`pcpparams(n,T,Q_len,σ,γ)` — i.e. it changes the *theorem's input*, not the presentation;
and (iii) §13.2 item 10 therefore grades as CHECKED a dependency property of the
**design's modified** construction while presenting it as the paper's. That is precisely
the "a CITED theorem looks PROVED by execution" pattern.

**FIX DEMAND.** Tag it `SOURCE_REPAIR(intro-decider-fixed-width)` with a `definitions.md`
§H row; restate §13.2 item 10 as "`lem:compress-independent-samplers` as stated in the
source remains CITED (its length-equality step is a gap); the *design's* fixed-width
variant has CHECKED dependency"; and record the resulting `σ_1` in §12.5's printed
parameter report.

**SURVIVING WEAKER STATEMENT.** With fixed-width specialization the emitted compressed
sampler bytes are provably independent of the input verifier; the paper's own argument
for that independence is not reproduced and remains CITED with a named gap.

---

## MINOR objections

* **O11 — MINOR (lockstep + taxonomy).** `SOURCE_REPAIR(intro-boundary-conflict)` is
  introduced in §11.4 but has **no** `definitions.md` §H row (only
  `SOURCE_REPAIR(AR-field-align)` does), violating law 2; and it repairs nothing (§11.4
  keeps the literal `≥`), so the tag misclassifies an open question as a repair. **FIX:**
  either make it a real repair (see O2) or rename it `SOURCE_NOTE(intro-answer-bound)` and
  add the row. Surviving: the observation about `L588-L591` vs `L424-L425` is correct and
  valuable.
* **O12 — MINOR.** §9.6's authoritative signatures use `TypedSamplerDescription`,
  `TypedDeciderDescription` and `VerifierDescription`; none has a `definitions.md` row,
  and §9.1 already encodes typedness as a *field* of `SamplerDescription`. Two
  representations of the same distinction. **FIX:** one row each, or drop the nominal types.
* **O13 — MINOR.** `detype` appears with three signatures in three subsections —
  `detype(T,G)` (§9.4 table), `detype_sampler`/`detype_decider` (§9.5), `detype(s,d)`
  returning a `VerifierDescription` (§9.6). **FIX:** one arity, cited from the others.
* **O14 — MINOR.** The named implementation lemmas `DL9-downsize … DL9-repeat` (§9.4)
  appear nowhere else — not in `definitions.md`, not in C12's statement, not in a claims
  row. They are unaddressable in the sense of law 3. **FIX:** list them under C12 or give
  them rows.
* **O15 — MINOR.** §9.4's `repeat` row states `level ell+2`, `dimension k(n)(s(n)+8)`,
  i.e. it *folds anchoring in*, while a separate `anchor` row also states `ell+2`,
  `s(n)+8`. Composed literally that reads as `ℓ+4`. §10.2 and §13.1 (`1→9→729`,
  levels `1→3→3`) show the intended reading. **FIX:** rename the row
  `anchored_repeat(S,λ,τ)` or state "input is the pre-anchoring verifier".
* **O16 — MINOR.** §9.1's legality contract requires prefixes "in the range of the
  preceding marginal" for *all* queries. `def:sampler` requires `u ∈ L^{w,n}_{<j}(V)`
  for `factor` (`gt-04:L592-L595`) but only `u ∈ V^{w,n}_{<j}` for `linear`
  (`gt-04:L588-L590`), and `L_{<j}(V) ⊆ V_{<j}` can be strict. The design's contract is
  therefore *stricter* than the source's for `linear`. Honest, but should be stated.
* **O17 — MINOR.** `def:typed-sampler` specifies that an out-of-range type input makes
  the sampler **return `0`** (`gt-06-types.tex:L133-L136`); §9.1 returns `QueryError`
  instead, undeclared. **FIX:** one sentence recording the substitution and why it is safe
  in a pipeline where types are always in range.
* **O18 — MINOR.** §12.1 attributes `epsilon1` and `epsilon2` to "eq:mu-gamma"
  collectively; they are `eq:re-eps-1` (`gt-12:L229-L232`) and `eq:re-eps-2`
  (`gt-12:L305-L308`). Label them.
* **O19 — MINOR (numbers not in lockstep).** §10.3 sets TB5 targets "construction `<2 s`
  … transcripts `<5 s`" while §13.1's TB5 row says `<5 s` total; §11.6 sets
  "`<3 s` construction, `<15 s` transcripts" while §13.1's TB6b row says `<15 s`.
  **FIX:** make §13.1 the sum, or split the columns.
* **O20 — MINOR (feasibility asserted without numbers).** §12.5's `<2 GiB` budget is
  unexplained: the largest declared object is `16` questions of `1696` bits plus
  `2 × 42,834`-bit answers ≈ `0.1` MiB, plus the PCP fixture. Either state what consumes
  GiB (a materialized `q^{m'}` table would, and DD-29 forbids it) or reduce the budget so
  it can fail. Conversely TB7's `<60 s` is plausible **only** if the `c_j` are evaluated
  structurally; a dense `12^16 ≈ 1.8·10^17`-monomial representation is infeasible, so the
  §12.5 report must print the representation used.
* **O21 — MINOR.** §11.5's "applies the corresponding projection" understates the source,
  which computes "the canonical linear map with kernel basis `S`" per `def:cl-canonical`
  (`gt-08:L680-L683`). These coincide only for register subspaces. Quote the source.

## NOTES

* **N1.** Source inconsistency the design should record as a finding (it silently uses the
  right one): `gt-12-compression.tex:L070` says `ComputeParrepVerifier` uses
  `k(n) = (λn)^τ`, while `gt-11:L200` and `gt-12:L355` say `k(n) = (λn)^{(1+c')τ}`.
* **N2.** §11.1/§11.6 report the capacity predicate as `Q ≥ R`; `lem:delta-bound`
  (`gt-07:L1523`) actually guarantees the *stronger* `2^m = M ≥ R`, and `gt-08:L1083`
  states the chain `s(N) ≤ R ≤ M ≤ Q`. Both FAIL at TB6b, so no consequence, but the
  reported predicate is weaker than the source's.
* **N3.** §9.2's "CHECKED" for `LawCert` means "emitted AST equals a hand-transcribed
  expected AST". That is a transcription check; §9.2 should say so in one clause, as it
  already does for big-O assertions.
* **N4.** Credit where due: the design correctly uses strict `>` for the repetition
  component guard (`gt-11:L219`, "length **larger than** `(λn)^τ`") and `≥` for the
  introspection answer guard (`gt-08:L425`). The asymmetry is the source's; §11.4 is right
  to flag it, and O2 is the consequence it stopped one step short of drawing.
* **N5.** `SOURCE_REPAIR(AR-field-align)` is a genuine and well-cited catch:
  `gt-10:L1957` forms `V^ora ⊕ V^pcp` across `F_2` and `F_{q_A}`, and `def:cl-downsize`
  (`gt-04:L396`) is applicable because `q_A = 2^{11}` has odd exponent. The design should
  add "`k` odd" as an explicit ASSUME on `downsize` in §9.4 (currently only implied via
  admissibility).
* **N6.** The four-query API is **not** decoration, and I could not find a simplification
  that preserves fidelity. `Factor` is genuinely independent of `Marginal`+`Linear`: for a
  stage whose linear map is zero on its factor space, the marginal and linear answers are
  identical to those of a zero-dimensional factor space, so the register support is not
  recoverable. And every transformation the campaign needs — `downsize`
  (`gt-04:L631-L664`), anchoring (`gt-11:L092-L097`), repetition (`gt-11:L201-L215`),
  detyping (`gt-06:L371-L404`), and the introspection decider's child access
  (`gt-08:L554-L577`, `L664-L668`) — is literally written in the source as a wrapper over
  exactly these four calls. Making the interface the rung boundary (DD-23) is the right
  call and is the strongest structural contribution of §9.

---

## Mutations the proposer missed (two required; three offered)

* **`M-factor-partition` (owns O1).** In any one constructor, return a factor indicator
  whose stages do not direct-sum to the ambient space — the natural instance is exactly
  the literal source behaviour: all-zero indicators for the `Anchor` / `(Pauli,W)` /
  `type^intro∖type^pauli` zero maps. Killed only by a new `lem:cl-kth` items 2+3 replay.
  **This mutant is currently unkillable by every check in §§9–13**, which is the argument
  for adding the invariant.
* **`M-detype-view-orientation` (owns §9.5).** Swap `view^alice(t)` and `view^bob(t)` in
  `detype_decider`'s edge parse (`gt-06:L419-L422`). Because the parser *accepts* on an
  invalid encoding (`gt-06:L415`, `L426`), the mutant accepts **everything** and passes
  every positive transcript in §§10.3/11.6/12.5. Killed only by a negative test that a
  typed edge on which the typed decider rejects still rejects after detyping. No such test
  is currently listed anywhere.
* **`M-intro-fuel` (owns §11.4).** Fuel the child sampler/decider with `R^2` instead of
  `R = N^λ`, or place the timeout check after the child returns. `M6-N` catches the wrong
  *index*, nothing catches the wrong *budget*. Killed by a metered fuel-accounting
  assertion plus a child fixture that runs in `(R, R^2]` steps.

---

## R. Required recomputations, in full

### R(a) — the level chain `9 → 5 → 7 → 9`

Recomputed from `thm:compression` and the three contract theorems, not from §12.2.

1. **Input.** `thm:compression` (`gt-12:L026-L053`) takes `(V,λ)` and, for its
   completeness/soundness conclusions, assumes `V` is a `λ`-bounded **9-level** normal
   form verifier (`L040`); it outputs a **9-level** verifier (`L029`). The fixed point
   closes only because output level = input level.
2. **`V^{(1)} = Introspect(V,λ,9)`.** `\tilde S^intro` is a **3**-level typed sampler of
   dimension `3m+3` over `F_q` (`gt-08:L318-L320`). `\hat S^intro = downsize(\tilde S^intro)`
   is still **3**-level, field `2`, dimension `(3m+3)log q`
   (`def:downsize-typed-sampler` + `lem:downsize_typed_sampler`, `gt-06:L153-L178`;
   restated at `gt-08:L340-L345` and `lem:intro-sampler-complexity` item 2).
   `V^{(1)} = detype(\hat V^intro)` adds exactly `+2` (`lem:detyping-verifiers` item 3,
   `gt-06:L461-L462`), giving **5** — confirmed by `thm:introspection` (`gt-08:L789`) and
   its proof (`L839-L840`) and by `tab:params` row 1 (`gt-12:L168`).
   *Note the input level `9` does not enter the output level at all*: it enters only
   through `|type^intro| = 32+2ℓ` and the decider. §12.2's arrow `9 --Introspect--> 5` is
   correct but the mechanism is a reset, not a map.
3. **`V^{(2)} = AnswerReduce(V^{(1)},λ,μ,γ)`.** `\hat S^ans = \hat S^ora ⊕ \hat S^pcp` is
   `max{ℓ,3}`-level (`gt-10:L1964-L1965`) with `\hat S^ora` of level `max{ℓ,1} = 5`
   (`gt-09:L281-L282`, `thm:oracle-completeness` `L148-L149`) and `\hat S^pcp` of level `3`
   (`L_DLine_i` is 3-level, `gt-10:L1933-L1936`); so typed level `= max{5,3} = 5`.
   Detyping ⇒ `max{ℓ+2,5} = max{7,5} = **7**` — exactly `thm:ar` (`gt-10:L2085`) and
   `tab:params` row 2 (`gt-12:L172-L173`, argued at `L276-L277`).
4. **`V^{(3)} = Repeat(V^{(2)},λ,τ)`.** `prop:anchoring` item 3 (`gt-11:L129`) gives
   `\hat S^anch` level `ℓ+2 = **9**`, dimension `s+8`. `S^rep = ⊕_{i=1}^{k(n)} L^{anch}`
   (`gt-11:L274-L276`) and direct sums do not increase level (`lem:cl-func-prod`,
   `gt-04:L315-L327`; applied at `gt-11:L327-L331`), so `V^{(3)}` is `ℓ+2 = **9**`-level
   (`thm:repetition` item 3, `gt-11:L251`) — `tab:params` row 3 (`gt-12:L176-L177`),
   argued at `L339`.

**Result: `9 → 5 → 7 → 9`, confirmed, with `max(5+2,5)=7` exactly as §12.2 writes it.**
Sole caveat: §12.2 renders the last two steps as `7 --Anchor/detype--> 9 --direct-sum
Repeat--> 9`, which double-lists one `+2`; the `+2` of `thm:repetition` *is* the anchoring
`+2`. Cosmetic (folded into O15).

### R(b) — the toy dimensions `206 → 840 → 848 → 1696`

Using §12.5's own overrides `(q_I,m_I,d_I) = (2,1,1)` and
`(q_A,m_A,d_A,s_A,m'_A) = (2^{11},1,11,6,16)`, `ℓ = 9`, `repetitions_toy = 2`.

```
|type^intro|(ell=9) = 26 + 2*(3+9) = 26 + 24 = 50            [gt-08:L219-L223; R(c)]
s_1 = (3*m_I + 3) * log2(q_I) + 4*|type^intro|
    = (3*1 + 3) * 1            + 4*50
    = 6 + 200 = 206                                          [gt-08:L318-L320; gt-06:L403]

dim_q(V^pcp) : from eq:V-pcp (gt-10:L1896-L1905)
    5*(dim V_{i,xpt} + dim V_{i,coord} + dim V_{i,dir}) + dim V_{aux,xpt}
      + dim V_{aux,coord} + dim V_{aux,dir}
  = 5*(m + 1 + m) + (5+s) + 1 + (5+s)
  = 10m + 2s + 16
  = 2*(5m + 5 + s) + 6 = 2*m' + 6                            [m' = 5m+5+s, gt-10:L1406]
  m'_A = 5*1 + 5 + 6 = 16  (a power of two, P_shape)          [def:pcpparams item 1]
  => dim_q(V^pcp) = 2*16 + 6 = 38
  downsized to F_2 (SOURCE_REPAIR(AR-field-align)) : 38 * log2(2^11) = 38 * 11 = 418

|type^ar| = |type^ora| * |type^pcp| = 3 * 18 = 54            [gt-10:L1949; gt-09:L043]
s_2 = s_1 + 418 + 4*54 = 206 + 418 + 216 = 840

s_anch = s_2 + 8 = 848                                        [prop:anchoring, gt-11:L129]
s_rep  = k_toy * s_anch = 2 * 848 = 1696                      [thm:repetition, gt-11:L269]
```

**Result: `206 → 840 → 848 → 1696`, confirmed exactly.** Two independent side checks of
§12.5's arithmetic also pass: `(m'+6)(m'd+1) = 22 * 177 = 3894` field symbols
`= 3894 * 11 = 42,834` bits, and the guard `B = (λn)^τ = (32768*2)^1 = 65,536 > 42,834`,
so the honest toy answer clears the component guard. And `d_A = k = 11`
(`def:pcpparams` item 3), `2^{11} = 2048` divisible by `m' = 16` (`P_divisibility`),
`(2+5*11)*16/2048 = 912/2048 ≈ 0.445 < 1/2` (`P_formula_paper`) — all as §12.5 reports.
What the *numbers* cannot certify is O5: the tuple is arithmetically admissible but the
instance it parameterizes is not `D^{(1)}`.

### R(c) — the count `26`, and the graph edge counts

`eq:pauli-type` (`gt-07:L968-L972`):
`type^pauli = ({Point,ALine,DLine,Pauli,Pair} × {X,Z}) ∪ type^ms ∪ {Pair}`, and
`type^ms = {Constraint_1..6} ∪ {Variable_1..9}` (`gt-07:L550-L557`; 6 equations, 9
variables, `gt-07:L524-L525`). Hence

```
|type^pauli| = 5*2 + (6+9) + 1 = 10 + 15 + 1 = 26      CONFIRMED
```

and `fig:type-graph-pauli` (`gt-07:L1012-L1068`) draws exactly 26 vertices
(6 Constraint + 9 Variable + {DLine,ALine,Point,Pauli}×{X,Z} + Pair + Pair-X + Pair-Z).
Non-loop edges, counted from the TikZ source:

```
MS incidence  : rows  (i=1..3, j=1..3)  9   [L1031-L1033]
                cols  (i=4..6, j=1..3)  9   [L1035-L1037]
foreach list  : ALineX-PointX, DLineX-PointX, PointX-PauliX,
                DLineZ-PointZ, ALineZ-PointZ, PointZ-PauliZ   6
                PointX-Variable1, PointZ-Variable5            2   [L1055-L1058]
pair chains   : PointX-PairX-Pair, PointZ-PairZ-Pair          4   [L1060-L1061]
                                                        total 30
loops         : one per vertex (caption L1064-L1066)          26
oriented pairs: 2*30 + 26 = 86                                     CONFIRMED (§11.1)
```

`type^intro = type^pauli ∪ (({Introspect,Sample,Read} ∪ {Hide_k}_{k=1..ℓ}) × {A,B})`
(`gt-08:L219-L223`) ⇒ `|type^intro| = 26 + 2(3+ℓ) = **32+2ℓ**` (34 at `ℓ=1`, 50 at
`ℓ=9`) — CONFIRMED. Non-loops of `fig:type-graph-intro` (`gt-08:L228-L315`):

```
inherited from G^pauli                                        30
Sample-Introspect, Introspect-Read      (x2 roles)             4   [L296-L297]
IntrospectA-IntrospectB                                        1   [L298]
PauliX-Hide_1                           (x2 roles)             2   [L301-L302]
PauliZ-Sample                           (x2 roles)             2   [L303-L304]
Hide_ell-Read                           (x2 roles)             2   [L305-L306]
Hide_k-Hide_{k+1}, k=1..ell-1           (x2 roles)      2(ell-1)   [L294-L295 + \cdots]
                                                total  39 + 2*ell     CONFIRMED
loops                                                  32 + 2*ell
oriented pairs = 2(39+2ell) + (32+2ell) = 110 + 6*ell                 CONFIRMED
  ell=1 -> 116 oriented, 34 types    (matches §11.6)
  ell=9 -> 164 oriented, 50 types
```

All four of §11.1/§11.3/§11.6's formulas are exactly right. `|type^ar| = 3*18 = 54` is
also right (`gt-10:L1949`, `gt-09:L043`, `gt-10:L1888-L1892`).

### R(d) — is the `≥ 3Q` boundary literally in the source?

**Yes, literally.** `gt-08-introspection.tex:L424-L425`:

> "The decider rejects if `s(N) > N^λ`, or if `max{ |â_A|, |â_B| } ≥ 3 · 2^m · log q`
> where `introparams(N^λ) = (q,m,d)`."

So `3Q = 3·2^m·log q` with the relation `≥`, and §11.4's transcription is faithful.
But the same section states, at `L588-L591`, that the maximum-length answer is a
`(Read,v)` triple or a `(Hide_k,v)` tuple `(y,y^⊥,x) ∈ V×V×V` and that "either way, the
**maximum answer length should be `3Q`** … bits long", with the `Q`-bit syntax fixed at
`L528-L530`/`L533-L534`. The literal guard therefore rejects the maximum-length honest
answer, and the `Hide_k` answer attains that maximum exactly. This is a genuine defect in
`fig:intro-decider`, not a parameter artifact, and the honest repair is `> 3Q`.
Retaining the literal `≥` while asserting that toy answers can be made "strictly shorter
than `3Q`" is not available: for `(Hide_k,role)` the length is `3Q` by schema. See O2 for
the TB6b arithmetic (`Q=2`, `3Q=6`, honest `Hide` answer `= 6` bits ⇒ reject, ≥10 of 116
oriented pairs affected).

---

## MERGE PROPOSALS — adjudication

The only MERGE PROPOSALS section in the target is §13.3's four claim rows; the
`definitions.md` edits were inside the proposer's declared lane (brief 28) and are
adjudicated as ordinary target text above. Per-item:

| item | decision | reason |
|---|---|---|
| §13.3 preamble ("proposals only; `claims/CLAIMS.md` is not edited") | **ACCEPT** | Lane respected; `claims/` untouched at `a403c9b` (verified by diff `1d79081..a403c9b`: only `briefs/28-*.last.md`, `docs/DESIGN.md`, `docs/definitions.md`). |
| C12 row | **ACCEPT with mandatory addendum** | See per-claim below. |
| C13 row | **ACCEPT with mandatory addendum** | See per-claim below. |
| C14 row | **REJECT wording** | O2, O3, O4. |
| C15 row | **REJECT wording** | O5, O10. |
| §13.3 "Missing steps before promotion are exact" list | **ACCEPT, but incomplete** | It is the right instrument and is honestly written; it omits the O1 invariant (C12), the negative transcripts of O9 (C13), the fixture changes of O3/O4 (C14), and the `P_pcp_encodes_D1` predicate of O5 (C15). Add those four bullets verbatim. |
| DD-23 … DD-30 | **ACCEPT** | Each carries a rationale and a rejected alternative, in §1–8 style. DD-24 and DD-30 in particular are exactly the right guards; DD-24 is *violated* by O7 and DD-28/§12.4 by O5, which is an implementation defect of the DDs, not a defect in the DDs. |
| §13.2 residue list as the "what remains difficult" deliverable | **ACCEPT in form, REJECT as exact** | O6. |

## Per-claim recommendation for C12–C15

* **C12 (description-level CL closure) — ADMIT as CONJECTURE, with the statement amended.**
  As worded it claims only that the six operations are definable through the four queries
  and that their field/level/dimension/dependency/size/call laws are replayable — that is
  defensible. It must, however, gain one clause, because otherwise the row silently
  suggests the outputs are samplers: append *"No claim is made that the outputs satisfy
  the `lem:cl-kth` conditions required by `def:sampler`/`def:typed-sampler`
  (`gt-04-cl.tex:L151-L180`, `gt-06-types.tex:L106-L108`) until the factor-partition and
  marginal-telescoping replay of O1 is implemented."* **Missing step named:** the
  `enu:cl-space-sum` / `enu:cl-map-sum` replay and the `rk:higher-level` zero-map padding
  rule (O1); plus the `E^ar` tensor-product correction (O8).
* **C13 (TB5 Repeat fixture) — ADMIT as CONJECTURE, with the statement amended.** The
  levels/dimensions `1,1 → 3,9 → 3,729` and the decider-independent sampler bytes are
  correctly derived (`prop:anchoring` `s+8 = 9`; `k = (λn)^{(1+c')τ} = 9^2 = 81`;
  `81·9 = 729`; `thm:repetition` "Furthermore" at `gt-11:L257`). Amend "accept the named
  classical value-one strategy" to add *"and reject a nonzero `Anchor` answer, and reject
  a transcript with exactly one corrupted component"*, so the row entails the negatives
  that `M5-anchor-answer` and `M5-or` need. **Missing step named:** the three negative
  transcripts and the re-attribution of `M5-anchor-zero` (O9).
* **C14 (TB6 Introspect fixture) — REJECT wording.** The clause "acceptance on every
  support transcript for all 116 oriented typed pairs" is false at the stated fixture
  under the design's own answer encoding (O2: ≥10 of the 116 pairs carry a `Hide` type
  whose honest answer is exactly `3Q` and is rejected), and where it is not false it is
  vacuous (O3: `ℓ=1` deletes `enu:hiding-same`; `m=1` degenerates `L_DLine`; `s=1`
  leaves one non-trivial factor stage). It would additionally be unsupported by two of
  its own mutations (O3 `M6-factor-prefix`, O4 `M6-game`). The type/edge counts
  (`34`, `116`), the level `5` and the dimension `142 = 6 + 4·34` are all correct and can
  be admitted separately. **Missing steps named:** (i) pin the non-Pauli answer encoding
  and settle the `≥ 3Q` boundary; (ii) a second fixture with `ℓ ≥ 2`, `s ≥ 2`,
  `L^alice ≠ L^bob`; (iii) a printed `VACUOUS` grade per source check with an empty guard
  set.
* **C15 (TB7 executable Compress / fixed point) — REJECT wording.** "constructs and
  executes … **all** sampler/decider descriptions" plus §13.1's "16 honest accepts"
  cannot both hold: `enu:ar-game` calls `pcpverifier` against the *actual* `D^{(1)}`
  specification, and at the toy tuple (`m_A=1`, `s_A=6`, `σ_1 = Θ(λ)`, `T = (2^{65536})^μ`)
  no honest PCP proof of `D^{(1)}` exists (O5). The claim also inherits O10's
  grade problem, since its independence-hash evidence is evidence for the design's
  padded construction, not the paper's. The parts that are sound and worth admitting as a
  separate CONJECTURE: the composition order, the checked chain `9→5→7→9`, the exact
  dimensions `206→840→848→1696`, the printed predicate report, the two-input identical
  sampler hash, and one finite `Fix`/`OutOfFuel` unfold. **Missing steps named:**
  (i) `P_pcp_encodes_D1` printed `FAIL` and `enu:ar-game` marked `NOT_EXECUTED` with an
  owner; (ii) `SOURCE_REPAIR(intro-decider-fixed-width)` declared and §13.2 item 10
  restated; (iii) TB7 mutations named `M7-*` with one owner and one expected failing
  assertion each (they are currently a seven-item unnamed prose list, §12.5 last
  paragraph / §13.1 last column, which cannot be reported per-mutant the way TB0's
  `E, F, C8` are).

---

VERDICT: FAIL(O1,O2,O3,O4,O5,O6,O7,O8,O9,O10)
