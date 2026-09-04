# Verdict — analytic document `docs/analytic/`, round 1 (brief 45)

Critic: Opus (vision). Target: **archived tree at `e3fe341`**, extracted with `git archive` into
`…/scratchpad/critic-analytic-doc-r1/tree`. Compiled there with `pdflatex -output-directory=…/build`
×2 → **82 pages, 0 overfull, 0 undefined, 0 errors, 101 figures, a figure on every page** (my rebuild
reproduces the claimed gate exactly). Pages rendered with `pdftoppm -r 110 -png` and **looked at**.
Every number below is recomputed from `ground-truth/gt-*.tex` **in the archived tree**, or derived by
hand. No repo file other than this verdict was written; no git state was changed.

**Counts: FATAL 0 · MAJOR 11 · MINOR 21 · NOTE 3.**

---

## MAJOR

### M1 — The paper's `λ` is renamed to a *level* `L`, and used inconsistently with the document's own §7.3
**Location:** `part1a.tex:550,559,585-590`; `part2b`-side `part2a.tex:1287-1300` (§10.3 `L:P{Level}`,
`S_L=ComputeSampler(L)`, `V_{M,L}`), `part2a.tex:1330` (thm 10.4 item 1), (10.4)/(10.5); figures
`halt-f-construction` (p16), `psi-ml` (p55), `three-presentations` (p56). Citation `part2a.tex:1354`
`\gt{fig:halt_f}{gt-12-compression.tex}`.

**Ground truth, `gt-12-compression.tex:435-458` (`fig:halt_f`), verbatim:**
> `Input: (\desc{R}, \desc{M}, \lambda, n, x, y, a, b)` … `\decider(n',x',y',a',b') = \cal{R}(\desc{R}, \desc{M}, \lambda, n', …)` …
> `Compute the description \overline{\sampler} = \ComputeSampler(\lambda).` …
> `\overline{\verifier^\compr} = \Compress(\overline{\verifier}, \lambda)`

and `gt-12:467-470`: `\decider^\halt_{\cal{M},\lambda}(n,x,y,a,b) = \cal{F}(\desc{F},\desc{M},\lambda,n,x,y,a,b)`.

The third slot is **λ, the resource bound of `def:lambda`** — which this document itself defines at
`part2a.tex:130-146` — **not a level**. `ComputeSampler` takes λ, not a level; `Compress` takes
(V̄, λ). Renaming it `L : P{Level}` collides head-on with the document's *other* use of "level"
(`level(V)=level(S)`, "nine-level verifier", `ComputeIntroVerifier(V,λ,9)`), and invites the reader to
think Compress's second argument is the verifier's level. It also makes `|D_{M,L}|=O(|M|+\log L+1)`
read as a bound in the level rather than in the bound.

Worse, the document is **internally inconsistent**: `part2a.tex:275` writes
`\mathcal F(\overline{\mathcal F},\overline M,\lambda,n,x,y,a,b)` (correct) while `part2a.tex:1330`
writes the same object with `L`; Figure 1 (p1) prints `Compress(⟨S_L,d⟩,λ)` while Figure 17 (p16)
prints `Compress on (⟨V⟩,L)` — **two different symbols for the same argument, two pages of each
other.** `docs/DESIGN.md:76-88` carries the same rename, so this is a lockstep fix, not a local typo.

**FIX DEMAND:** rename `L → λ` everywhere the paper's `fig:halt_f` third argument is meant (Part I §3.1,
§6; Part II §10.3, (10.4), (10.5), thm 10.4; figures `halt-f-construction`, `psi-ml`,
`three-presentations`, `C-diagonal-five-steps`, `C-closed-verifier`, `final-accounting`, `D-final-seal`),
and propose the same edit for `DESIGN.md §1.1`.
**Surviving statement:** the *structure* of `Ψ_{M,L}` is faithful to `fig:halt_f`; only the name and
declared sort of the third argument are wrong.

### M2 — The decoupled-5SAT construction is misdescribed: the three 3SAT literals go to three blocks, not one
**Location:** `part2b.tex:215-217`, immediately above `\gt{sec:succinct-deciders}` at `:225`; and
**Figure 70** (`decoupled-5sat`, p60), whose block `u_3` is captioned "original 3SAT clauses live here"
while `u_4`,`u_5` are "copy of `u_3` / equality-gadget coordinates".

Document: *"The original 3SAT clauses are applied to `u_3`; constant-size five-literal gadgets enforce
`u_3=u_4=u_5` …"*

**Ground truth, `gt-10-answer-reduction.tex:1105-1107`:**
> "we write `\varphi_{\mathrm{3SAT}}(w_1, w_2, w_3)` for the formula in which, for each constraint in
> `\varphi_{\mathrm{3SAT}}`, **the first variable is taken from `w_1`, the second from `w_2`, and the
> third from `w_3`**."

and the succinct clause `gt-10:1051` reads `\circuit_{\mathrm{3SAT}}(i_3,i_4,i_5,o_3,o_4,o_5)=1`, i.e.
one index per block. `eq:5sat` (`gt-10:952-958`) allows **exactly one literal per block**, so "the 3SAT
clauses are applied to `u_3`" is not even expressible in the clause form the same paragraph displays
at (11.2). The figure therefore **contradicts Figure 71 on the same page** ("one five-literal clause:
exactly one addressed bit from each block"). This inverts the stated purpose of decoupling
(`gt-10:876-895`): three separate blocks exist precisely because three low-degree answers need not be
restrictions of one assignment.

**FIX DEMAND:** replace with "each original 3SAT clause contributes its first, second and third literal
to `u_3`, `u_4`, `u_5` respectively; the equality gadgets `u_3=u_4=u_5` then make the five-block
instance equivalent to the shared-assignment one", and redraw Figure 70 so all three of `u_3,u_4,u_5`
carry "one 3SAT literal each".
**Surviving statement:** satisfiability equivalence and the size bound (11.1) are unaffected; only the
description of where the literals live is wrong.

### M3 — "Level laws" are stated as equalities; they are false, and C4a explicitly disclaims minimality
**Location:** `part2b.tex:632-640` (Lemma, unlabelled), and `part2b.tex:704-705` ("Their levels are
respectively one, two, and three"); **Figure 83** caption (p70): *"which is exactly why `L_ALine` is
conditionally linear of level two **rather than one**"*.

Document:
`level(concatenate(L,R)) = k+ℓ`, `level(⊕_j L_j) = max_j ℓ_j`.

**Ground truth gives membership, never an invariant.** `gt-04-cl.tex:283-292` (`lem:cl-concat`): the
concatenation *"**is a** (k+ℓ)-level conditionally linear function"*. `gt-04-cl.tex:316-330`
(`lem:cl-func-prod`): the direct sum *"**is an** ℓ-level CL function … for ℓ = max_j{ℓ_j}"*. And
`gt-04-cl.tex:271-277` says so explicitly:
> "the marginal functions, factor spaces, and linear maps of a given CL function `L` may not be unique;
> for example … the identity function … is clearly a 1-level CL function, but it can also be viewed as
> a `k`-level CL function for `k ∈ {2,…,n}`."
plus `rk:higher-level` (`gt-04:245-253`): every (ℓ−1)-level function is ℓ-level.

**My counterexamples.** (i) `U=V=F^1`, `L=id_U` (level 1), `R_u=id_V` for every `u` (level 1). Then
`T(x)=x^U+x^V=x` = the identity on `U⊕V`, which is **linear, hence level 1**, not `1+1=2`. (ii)
`L_1 = 0` on `V^{(1)}` regarded as 5-level (legal by `rk:higher-level`), `L_2 = 0` on `V^{(2)}` at
level 0: `⊕ = 0`, which is **level 0**, not `max = 5`. The document's own proof (`part2b.tex:645-660`)
establishes only "≤"; it never argues "≥".

This is also **stronger than the ratchet**: `claims/CLAIMS.md:11` (C4a) says the levels 1/2/3 are
*"upper bounds in the sense of `rk:higher-level`, **not minimality claims**"*.

**FIX DEMAND:** restate as `concatenate(L,R)` **is** a `(k+ℓ)`-level CL function and `⊕_j L_j` **is** a
`max_j ℓ_j`-level CL function; delete "rather than one" from Figure 83's caption or replace it with
"by its stage factorization (`rk:higher-level` upper bound; minimality is not claimed)"; add the
`gt-04:271-277` non-uniqueness remark to §13.1.
**Surviving statement:** the ≤-direction of both laws, exactly as the source states them, and the
constructed nesting depths 1/2/3, survive.

### M4 — `fig:ladder` swaps TB5 and TB6 and attributes four rungs to the wrong claim, while its caption says it is transcribed from `CLAIMS.md`
**Location:** `figs/fig-ladder.tex:9-11,23-26,28`; caption `part2b.tex:877-882`; **Figure 89**, p74.

Figure prints **TB5 = "introspection compiler"**, **TB6 = "repeat compiler"**. Every authority in the
same commit says the opposite:
- `claims/CLAIMS.md:19` — "C13 | (**TB5 Repeat** fixture)"
- `claims/CLAIMS.md:20` — "C14 | (**TB6 Introspect** fixtures …)"
- `docs/DESIGN.md:1281` — "## 10. **TB5 — executable anchoring and repetition**"
- `docs/DESIGN.md:1384` — "## 11. **TB6 — executable Pauli test and introspection**"

Second defect: the chips for TB4/TB5/TB6/TB7 all read **"C7 CONJECTURE"**. `CLAIMS.md` has dedicated
rows for exactly these rungs — **C12** (`:18`, description-level CL closure), **C13** (`:19`, TB5
Repeat), **C14** (`:20`, TB6 Introspect), **C15** (`:21`, TB7 Compress/fixed point). C7 (`:15`) is the
𝒬-algebra hypothesis, a different statement. The same mis-attribution recurs at `part2b.tex:1107,1111`
(§14.6 claim column: `fig:compress` / `thm:compression` → "C7 Conj.", now governed by C15).

The figure's own footer and caption assert "claim statuses transcribed from `claims/CLAIMS.md`" —
false for six chips.

**FIX DEMAND:** swap the TB5/TB6 labels; replace the four C7 chips with C12/C13/C14/C15 (all
CONJECTURE, all citing `verdicts/design-v2-r2.md` / `-r3.md`); update `part2b.tex:1107,1111`.
**Surviving statement:** no *status* is inflated — C7 and C12–C15 are all CONJECTURE. The ids and the
rung names are wrong, not the grades.

### M5 — Lockstep failure: the whole TB5–TB7 layer of the ratchet is invisible in the document
**Location:** whole document. `grep -rn "C12\|C13\|C14\|C15\|TB7\|9->5\|206\|840\|848\|1696"
docs/analytic/parts/*.tex docs/analytic/figs/*.tex` returns **zero hits** except the three TB5/TB6/TB7
box labels in `fig-ladder.tex`.

At `e3fe341` the ratchet already carries C12 (DL9 sampler-description closure), C13 (TB5 Repeat
fixture: levels/dimensions `1,1 → 3,9 → 3,729`), C14 (TB6 Introspect: type/edge counts 34/116 and
38/128, detyped level 5, `Q=12`, the `3Q` boundary), C15 (TB7 executable `Compress`: level chain
`9→5→7→9`, dimensions `206→840→848→1696`, `s_0=9`, `λ=32768`). `DESIGN.md:1834` prints those exact
numbers. `FIGURES.md` §1 rule 2 lists "level chain 9→5→7→9, dims 206→840→848→1696" as **"the
document's numbers"**.

Yet §14.6 is still titled "**Compression and fixed point (planned TB4)**" with rows graded "CITED;
absent" and "no current implementation" (`part2b.tex:1100-1115`), and §15.1 still says *"Anchoring and
parallel repetition are combined in `Repeat` and are theorem-backed **rather than executed here**"*
(`part2b.tex:1204`). The brief's north star (the executable `Compress`, the four transformations, the
fixed point) is therefore *narrated as absent* in a document shipped alongside a ratchet that admits
it as CONJECTURE.

**FIX DEMAND:** add §14.6 rows for C12/C13/C14/C15 and a §13.5-or-§14.7 subsection carrying the TB7
parameter card (`n=2, λ=32768, s_0=9`, chain `9→5→7→9`, dims `206→840→848→1696`, `Q_I=2 < s_0=9`,
`P_pcp_encodes_D1=FAIL`) with its two printed non-executed layers named; retitle §14.6.
**Surviving statement:** every §14 row as printed is *weaker* than the ratchet, so nothing is
over-claimed — the document is stale, not inflated.

### M6 — Theorem 9.2's exponent `6` is asserted, not derived, and its proof contradicts itself
**Location:** `part2a.tex:857-861` (statement (9.3)), proof `part2a.tex:875-895`; propagated into (9.4),
thm 9.3's `6+⌈log₂(C_L3⁶)⌉`, Figure 57 (p47) and Figure 58 (p48).

Proof text: *"A **conservative single-tape implementation** finds a record by a full scan … in at most
the square of that length."* → per-step cost `≈ c²(|d|+|u|+f+1)²`, times `≤ f ≤ (|d|+|u|+f+1)` steps
→ cube; with decode and serialize, *"bounded by … the **fourth power** of the length"*. Then:
*"Converting the **fixed multitape implementation** to the paper's one-tape convention … is bounded by
the **sixth power** after increasing `C_L`."*

Two sentences apart the same machine is described as single-tape and as multitape. If the fourth-power
bound is already one-tape, no conversion is needed and the theorem should state 4. If it is multitape,
the standard quadratic one-tape simulation takes the fourth power to the **eighth**, not the sixth.
Neither reading yields 6. `docs/DESIGN.md` and `docs/definitions.md` contain no `C_L` and no exponent
6, so there is no single source to appeal to.

**FIX DEMAND:** either (a) state the exponent the argument actually gives and say so ("`C_L(·)^8`;
any fixed exponent suffices"), or (b) supply the missing step that converts 4 → 6 (e.g. a two-tape
implementation with an explicit `O(n log n)` conversion), and make the *one*-tape/*multi*-tape wording
consistent.
**Surviving statement:** "there is a fixed universal exponent `e` and constant `C_L` with
`TIME_{U_L}(d,u,f) ≤ C_L(|d|+|u|+f+1)^e`" — which is all thm 9.3 and the `A`-rescaling actually use.

### M7 — Nine proved theorems/lemmas of Part II have no row in `claims/CLAIMS.md`
**Location:** `thm:l-determinism` (8.2), `thm:fuel-monotonicity` (8.3), `thm:quote-eval` (8.4),
`lem:specialization` (8.5), `thm:tm-to-l` (9.1), `thm:l-to-tm` (9.2), `thm:lambda-preservation` (9.3),
`lem:smn` (10.1), `thm:kleene-two` (10.2), `thm:ycode` (10.3), `thm:fixed-point-equivalence` (10.4),
`lem:transition-window` (11.1), `thm:l-succinct-sat` (11.2).

Each is stated as a **theorem with a proof** carrying project-specific constants
(`a_0,b_0,c_0,a_U,b_U,C_L,c_Y=3,a_s,b_s,a_K,b_K`) and exponents (6, `3+⌈log₂72c_0⌉`). None appears in
the claims DAG at any status. `claims/CLAIMS.md:4` says every claim is an addressable row; §14.1 grades
them "analytic only; absent" with claim column "**none**" — i.e. the document itself records that they
are unratcheted, while typesetting them as proved theorems. This is exactly the "summary moment"
strengthening rk-light law 1 guards against.

**FIX DEMAND:** either add rows C16–C2x at status **SKETCH** for the Part II theorems (with
`where-proved = docs/analytic/parts/part2a.tex:<line>`), or add one explicit sentence at the head of
§8 stating that every theorem in Part II is a written derivation at SKETCH status carrying no ratchet
row, and repeat it in the §14.1 caption.
**Surviving statement:** the derivations as written; only their unratcheted presentation as
"Theorem … \begin{proof}" is at issue.

### M8 — Figure 79 grades the four-soundness-layers stratum 1 as EXECUTED, contradicting the text 20 lines below it
**Location:** `figs/fig-four-layers.tex`, **Figure 79**, p67; text `part2b.tex:509-540`.

§12.4's layer 1 is *"Algebraic soundness under a low-degree premise"* — the conditional implication
"acceptance > 1/2 ⇒ polynomial identity ⇒ an accepting bounded computation". The same page says:
*"This conditional theorem is `thm:pcp-decider` … Its current project status is **C5: SKETCH, not
CHECKED**"* (`part2b.tex:538-540`). The figure renames stratum 1 to "algebraic identities under degree
≤ d" and paints it **green / EXECUTED**.

Second defect in the same figure: the strata are joined by a downward `xform` chain 1→2→3→4. That
asserts a dependency order the text denies — layer 3 (*"This is exactly the Schwartz–Zippel step
**above**, used twice"*, `part2b.tex:552`) is used **inside** layer 1, and layer 4 does not follow from
layer 3.

**FIX DEMAND:** split stratum 1 into a green "evaluate the two identities at `z`" box and a slate
dashed "⇒ accepting trace (`thm:pcp-decider`, C5 SKETCH)" box; replace the 1→2→3→4 chain with the real
dependency (2 and 3 feed 1; 1 and 4 feed `thm:ar`).
**Surviving statement:** the four-way *classification* (executed / cited / checked / cited) is right;
only the colour of stratum 1 and the arrow topology are wrong.

### M9 — §13.3 and §14 name four Julia objects that are not in the tree, one of them under an assertion about "the current code"
**Location and verification (`grep -rn` over the archived `src/`, `test/`, `toys/`, `docs/`):**

| printed at | identifier | in tree? |
|---|---|---|
| `part2b.tex:759`, `:774`, `:1036` | `PCPCLMap` | **absent**; nearest is the private function `_pcp_cl_map` at `src/samplers/pcp_sampler.jl:65` — a function, not an IR sort |
| `part2b.tex:760` | `PCPPaddedMap` | **absent**; padding is `pad_level`, `src/samplers/typed.jl:3`, applied at `:57-61` |
| `part2b.tex:1041` | `TypedProductCL` | **absent**; `typed_sampler_product` (`src/samplers/oracularize.jl:94`) returns `Checked{TypedSampler}` |
| `part2b.tex:1082`, `figs/fig-correspondence-map.tex:23`, `figs/fig-D-correspondence-midpoint.tex:4` | `sequential_value` | **RENAMED** → `sequential_and_optval`, `toys/midpoint/midpoint.jl:260` |

`part2b.tex:759` states as fact: *"**The current code uses** `PCPType`, `PCPRegisterLayout`,
`PCPCLMap`, `PCPPaddedMap`, and `pcp_sampler`"* — three of five exist. `part2b.tex:774` attributes
laziness to `PCPCLMap`; the laziness is real but belongs to `CLStep` (`src/samplers/cl.jl:10-26`,
memoised `branch::Function` + `children::Dict`). `sequential_value` is the **only** implementation
pointer on the two rows graded **PROVED** (C6, N1), so the strongest-graded rows in §14 point at a
symbol that is not in the repository.

**FIX DEMAND:** replace `PCPCLMap`→`_pcp_cl_map` (or `CLStep`), `PCPPaddedMap`→`pad_level`,
`TypedProductCL`→`TypedSampler`, `sequential_value`→`sequential_and_optval` (all three sites); rewrite
`:774` to name `CLStep` as the lazy object.

### M10 — §14.3 grades `ld_decider` under C4a, which disowns it by name
**Location:** `part2b.tex:1003-1006`: row `fig:ld-decider` → `ld_decider`, `restrict` → "CHECKED
fixture" → **C4a TESTED**.

`claims/CLAIMS.md:11` (C4a) ends verbatim: *"**No claim is made here about `D^ld`**, about
`concatenate`/`direct_sum`/`product`/`TypedSampler`, or about any other `(q,m)`."* And
`src/verifiers/ldt.jl:166` is literally `const D_ld = ld_decider`. The document's own prose gets this
right at `part2b.tex:564-565` (*"Running `ld_decider` on honest finite inputs does not prove this
extraction theorem"*), and the table format already supports the honest answer — `part2b.tex:1047`
uses "**no current row**".

Same defect, lower severity, at `part2b.tex:997-999`: `concatenate`/`direct_sum`/`product` are graded
under **C7**, but C7 is the 𝒬-algebra hypothesis, not `lem:cl-concat`/`lem:cl-func-prod` (status
unaffected: both CONJECTURE).

**FIX DEMAND:** change the `fig:ld-decider` row's claim column to "no current row" and the
`lem:cl-concat, lem:cl-func-prod` row to "no current row"; or open ratchet rows for them.

### M11 — The certificate grammar required by the north star is absent
**Location:** whole document. `grep` finds `Checked{...}` **once**, in passing, at `part2b.tex:288`
(`tseitin` returns `Checked{TseitinFormula,CertNode}`); "derivation tree" and "inspectable derivation"
appear **zero** times.

`handoff.md:214-223` ("Representation requirements") asks explicitly for
`struct Checked{T,C}; term::T; certificate::C; end` and for *"an explicit derivation tree rather than
an informal comment"* behind every claimed bound. `docs/DESIGN.md §3` is titled "Invariant tracking and
the derivation tree". The document builds the whole `\mathcal L` grammar, the CEK semantics, the fuel
account, and six correspondence tables — and never defines the certificate/derivation-tree layer that
carries its evidence grades. §14's `\grade{CHECKED}` column is therefore ungrounded in the document's
own formal system.

**FIX DEMAND:** add a subsection to §8 (after Definition 8.1) defining `Checked{T,C}`, the `CertNode`
grammar, and the replay relation, with one figure showing a real certificate tree (e.g. the `BuildC0`
/ `ZeroDecomposition` replay already described at `part2b.tex:400-415`), and cite `DESIGN.md §3` as
the single source.

---

## MINOR

**m1** `part1b.tex:671-673` — orphaned clause survives into the PDF. `pdftotext -f 29 -l 29` gives:
*"…records exactly where it must call the second. **upon the cited second layer, as Figure 37 makes
explicit.**"* (Commit `b0241ea` claims this fragment was reattached; it was not.) **FIX:** delete
`part1b.tex:672` ("the second.") and merge into one sentence.

**m2** `part2a.tex:452-472`, display **(8.2)** — configuration arity is inconsistent. Rows 1–2 are
5-tuples `⟨q,η,K,H,f⟩` matching the definition at `part2a.tex:432` and **Figure 47** (p38, five
labelled registers); rows 3–7 are 4-tuples with the environment silently dropped, and **row 3 has 4
slots on the left and 5 on the right**. The stated convention covers only "continuations and heaps not
shown", not environments. **FIX:** print `η` in every row, or state the environment elision.

**m3** `figs/fig-D-threshold-margin.tex`, **Figure 80** (p67) — `b_1` is drawn to the **left** of `b_2`,
i.e. `b_1 < b_2`. But `b_1=(δ_F+5d)m'/q` and `b_2=(2+d)m'/q`, and with `d ≥ 8` (the document's own
bound, `part2b.tex:376`) `δ_F+5d ≥ 41 > 10 ≥ 2+d`, so `b_1 > b_2` **always**. **FIX:** swap the two
marks.

**m4** Float placement — figure numbers run backwards across pages: **Fig 66** sits on p54 while
**Fig 64** is on p55 and **Fig 65** on p56 (caused by `[H]` on `C-selfref-boundary` at
`part2a.tex:1371` against `[t]` on the two earlier floats); likewise **Fig 74** (p62) precedes **Fig
73** (p63). Pages 54, 55, 56 are each 70–85 % white. **FIX:** give `psi-ml` and `three-presentations`
`[H]` too, or move `C-selfref-boundary` after them.

**m5** `figs/fig-roadmap.tex`, **Figure 2** (p2) — only four vertical arrows are drawn
(`s1→s7`, `s3→s810`, `s5→s11`, `s6→s1315`). **§12 PCP has no incoming upgrade arrow**, and §2, §4 have
no outgoing arrow, yet the caption says the arrows identify *"**exactly** which qualitative refresher
each resource-accounted construction upgrades"*. **FIX:** add `s4→s12` (λ-terms → PCP algebra) or
soften the caption.

**m6** Symbol `τ` is overloaded: the paper's repetition constant at `part2a.tex:193`
(`ComputeParrepVerifier(V̄^{(2)},λ,τ)`) and the transition-window Boolean function at
`part2b.tex:47,56,71,131`. Neither is disambiguated. Separately **`μ`, `γ`, `τ` are never defined
anywhere in the document** (used at `part2a.tex:191-193`, `part2b.tex:799`). **FIX:** rename the window
function (`w`, `Δ`) and add the three constants to the parameter card of suggestion 2.

**m7** `level` is used from `part2a.tex:139` and `:181` ("nine-level verifier") but the CL notion is
only defined at Definition 13.1, `part2b.tex:602` — 65 pages later. **FIX:** forward-reference at
`part2a.tex:139`, or move a one-paragraph CL-level definition into §7.1.

**m8** `part2a.tex:611-625` — fuel double-count ambiguity. `Eval` is said to charge **two units** for
installing/removing the delimiter (`part2a.tex:519-521`), while `h(d,u)=3+|d|+|enc(u)|` is said to be
"the front-end scan" and thm 8.4 asserts the left side uses **exactly** `h(d,u)+c`. Whether the 3
absorbs the 2 is never stated. **FIX:** say "the 3 covers delimiter install/remove plus the tag check".

**m9** Part I reduction arrows are imprecise. `part1b.tex:159-161` `if false A B →_β false A B →_β B`
is 3 + 2 steps; `:196-198` `fst⟨A,B⟩ →_β true A B →_β A` is 1 + 2; `:135` `true A B →_β A` is 2.
More seriously, `part1b.tex:331-341` writes `Y F →_β … →_β F((λx.F(xx))(λx.F(xx))) **=** F(YF)` and
`:390` `ZF →_β F(λu.(ZF)u)`: `(λx.F(xx))(λx.F(xx))` is a *reduct* of `YF`, not `YF`, so these are
β-**conversions**, not reductions — `Y F ↠ F(Y F)` is false for Curry's `Y` (it holds for Turing's
`Θ`). **FIX:** use `→_β^*` for multi-step and `=_β` for the two fixed-point equations, with one
sentence noting Turing's `Θ` as the combinator that does reduce.

**m10** `part2a.tex:1092-1093` — *"let `s(z,z)` denote the description obtained by hardwiring **two
copies of `z` into the first two inputs of a suitable `(k+2)`-input machine**"* conflicts with (a)
Part I's own correct form `part1a.tex:491-496` (`s(z,w)` fixes the **first input of program `z`**), and
(b) the size arithmetic four lines later, `|e_Q| ≤ 2a_s a_1|q| + (2a_s b_1 + b_s)`, which is exactly
`a_s(|p|+|p|)+b_s` — the Part I form. **FIX:** restate as Part I does.

**m11** Divergence from the single source `docs/DESIGN.md §1.1`, undeclared. (i) `DESIGN.md:79-86`
gives `Psi_M_L` with **one** `Eval` and no `ans`/`F_C`; the document's (10.4) has two nested `Eval`s,
an `ans` selector and a fuel symbol `F_C` (`grep "F_C\|ans(" docs/DESIGN.md` → 0 hits). (ii)
`DESIGN.md:70-73` writes `eval(Quote(Fix(P)),u;fuel) = eval(specialize(…),u;fuel)` with the **same**
fuel; thm 10.3 charges `f − c_Y`, `c_Y=3`. (iii) `DESIGN.md:52` fixes the hole sort to
`Quoted{Decider}`; `part2a.tex:352-355` generalises it to `Quoted(A)`. All three look like
*improvements*, but none is marked. **FIX:** mark each `SOURCE_REPAIR` against `DESIGN.md`, or propose
the reverse edits to `DESIGN.md` so the two move in lockstep.

**m12** `part2a.tex:250-257` — *"In **Step 1 of `fig:pcpverifier`**, the **answer-reduced decider**
computes `Circuit = PaddedSuccinctDecider(D̄,n,T,Q,σ,x,y)`"*. In the source Step 1 is a step of
`pcpverifier` (`gt-10:1568`); the answer-reduced decider `D̂^ar` (`fig:decider-pcp`) only *invokes*
`pcpverifier`, in its game-check step (`gt-10:2059-2062`). The argument tuple itself is exact.
`part2b.tex:781` gets the distinction right. **FIX:** "In Step 1 of `fig:pcpverifier`, which the
answer-reduced decider invokes, …".

**m13** `part2b.tex:733-737` — the behaviour *"first samples an oriented type edge and then pushes one
uniform seed through the selected left/right maps"* is `def:typed-sampler-sample` (`gt-06:143-152`),
not `def:typed-sampler` (a 7-input TM, `gt-06:96`). The next sentence names the right label, so the
citation is split rather than wrong. **FIX:** move the `\gt` footnote one sentence later.

**m14** `figs/fig-D-correspondence-description.tex:4` prints the IR sort **`Succinct5SAT`**, which
occurs neither in the table it summarises (`part2b.tex:919,923` → `Succinct3SAT`,
`SuccinctDecoupled5SAT`) nor anywhere in `DESIGN.md`. **FIX:** use `SuccinctDecoupled5SAT`.

**m15** `figs/fig-correspondence-map.tex:14` prints **`zero_basis`** in a column headed "Julia object";
that is a file stem (`src/polynomials/zero_basis.jl`), the objects being `zero_basis_decompose` and
`verify_zero_decomposition`. Same figure, `:15`: it is the **only** §14 artefact with no claim column,
and it paints "Tseitin / arithmetization / zero basis" as a green `checked` leaf — but the governing
rows are **C2 CONJECTURE** and **C1 CONJECTURE**. The §14 preamble's safeguard
(`part2b.tex:862-864`, "the claim column … can remain weaker than a certificate label") cannot operate
without that column. **FIX:** add a claim column, as `fig-ladder` and the five `fig-D-correspondence-*`
figures already have.

**m16** Reserved-style misuse. `FIGURES.md` §1 rules 7 and 9b reserve the **violet wavy `quote`** arrow
for object→bytes and give rust `copyflow` to copy/substitute. `fig-y-derivation` (Fig 28, p22) uses a
violet wavy arrow labelled "**assemble**" from `h = λx.F(x x)` to the `Y` syntax — a construction step;
`fig-psi-ml` (Fig 64, p55) uses one from the `Hole` to `D_{M,L}=YCode(Ψ)` — a hole-closing step. **FIX:**
use `copyflow` or a plain `xform` for both.

**m17** `figs/fig-ladder.tex:23-26` — the four `tag cited` chips are placed `above=2mm` of the *second*
row's boxes, which puts them ~14 px below row 1's chips and ~14 px above row 2's boxes. In the render
(p74) they read as **second chips for TB0/TB0.5/TB1/TB2**. **FIX:** attach them below the row-2 boxes,
or widen `row sep`.

**m18** `figs/fig-decoupled-5sat.tex` (Fig 70, p60), two further defects beyond M2: (i) the rust arrow
"copy of the first `2F` answer cells" feeds **both** `a` and `b`, but `gt-10:1100` sets `a_1 = w_{1,1}`
(first `2T` bits) and `b_1 = w_{1,2}` (**second** `2T` bits) — different sub-blocks; (ii) the label
"one common padded length `M = 2^m`" reuses `M = 2^m`, which §12.1 (`part2b.tex:355`) defines as the
Boolean-subcube size. **FIX:** label the two copies `w_{1,1}`/`w_{1,2}` and rename the padded length
`N = 2^{n_i}`, as `gt-10:963`.

**m19** Three theorem-counter environments carry **no `\label`**: Lemma 12.1 `part2b.tex:417`
(zero-basis rewrite), Definition 13.1 `:602` (CL function), Lemma 13.2 `:632` (level laws). §14.2 and
§14.3 have rows describing exactly these objects and cannot cite them. **FIX:** add
`lem:zero-rewrite`, `def:cl-func-doc`, `lem:level-laws` and cite them from the tables.

**m20** `part2b.tex:366-376` writes **`δ_F`** for the occurrence bound; `claims/CLAIMS.md` C5 and C8
call it **`deg_F`**. Single-source violation. **FIX:** use one symbol.

**m21** `part2a.tex:88-90` (Definition 7.2) says *"`n` is a **positive** integer in binary"*;
`gt-05-games-normalform.tex:613-620` says only *"`n` is an integer"*. Harmless but it is a
strengthening of a transcribed definition. **FIX:** match the source or mark the restriction.

---

## NOTE

**n1** (defect in the ratchet, not the document) `claims/CLAIMS.md:12` (C4b) says *"`CLStep` materialises
its branch table eagerly"* and that the 18-map family is *"not built at any parameter"*. Against this
tree that is false: `src/samplers/cl.jl:10-26` is lazy and memoised, and `test/tb2_answer_reduce.jl:69-77`
builds the family at `q = 2^11` and asserts `pcp_types=18, pcp_edges=324, pcp_level=3,
product_types=54, product_edges=2916`. §13.3's grades are backed by executed code while the claim they
cite denies the construction exists. Route to the orchestrator: `CLAIMS.md` C4b needs the update, not
the document.

**n2** Direction of divergence. With the exceptions of M3, M8 and M10, the document is consistently
*weaker* than the ratchet, not stronger. No status is inflated anywhere; the dominant failure mode is
staleness (M5).

**n3** Build gate independently reproduced from the archived tree: 82 pages, 101 figures, every page
carries at least one figure, 0 overfull, 0 undefined, 0 errors. §1's five semantic colours are used
consistently outside m16.

---

## Fidelity table — every `\gt{}` citation

29 citations. **All 29 labels resolve in the file they are cited to** (0 wrong-file defects).
**Defect count: 4** (1 MAJOR, 3 MINOR); 25 OK.

| # | label(s) | cited file | resolves at | verdict |
|---|---|---|---|---|
| 1 | `sec:tms` | gt-03-prelim | gt-03:38 | OK — `C(k|α||x|T)^c`, `enc` dual-rail, `O(T log T)` timeout, `O(|a|+|M|)` hardwire all match gt-03:105-124,159-161,200-201 |
| 2 | `def:decider` | gt-05 | gt-05:613 | OK (see m21) |
| 3 | `def:sampler` | gt-04-cl | gt-04:573 | OK — four modes + "at most 6 arguments" verbatim, gt-04:580-614 |
| 4 | `def:normal-ver`, `def:lambda` | gt-05 | gt-05:625, :642 | OK — `q(n)=2`, `|V|≤λ`, `n^λ` for `n≥2`, footnote on `n=1` all exact |
| 5 | `fig:compress`, `thm:compression` | gt-12 | gt-12:97, :27 | OK — the three calls, their argument tuples and "9-level" exact (gt-12:31,82-92) |
| 6 | `thm:ar` | gt-10 | gt-10:2077 | OK — `max{ℓ+2,5}`, `T(n)=(2^{λn})^μ`, `Q(n)=(λn)^μ` exact (gt-10:1816,1822) |
| 7 | `lem:intro-decider-complexity`, `thm:introspection` | gt-08 | gt-08:704, :785 | OK — constant-size raw decider, hardwire first three tapes, `|V|` scan / trivial-verifier fallback: gt-08:718,766-778 |
| 8 | `fig:pcpverifier`, `prop:standard-succinct-sat` | gt-10 | gt-10:1585, :237 | **DEFECT (m12)** — Step 1 belongs to `pcpverifier`, not to the answer-reduced decider (gt-10:1568 vs :2059-2062) |
| 9 | `fig:halt_f` | gt-12 | gt-12:455 | OK — §7.3 item 5 writes `λ`, matching gt-12:427,467-470 |
| 10 | `fig:halt_f` | gt-12 | gt-12:455 | **DEFECT (M1)** — surrounding §10.3 renames the paper's `λ` to a level `L`; gt-12:435-440 has `(R̄,M̄,λ,…)`, `ComputeSampler(λ)`, `Compress(V̄,λ)` |
| 11 | `prop:standard-succinct-sat` | gt-10 | gt-10:237 | OK — `2T` reserve and `poly(log n, log T, Q, σ)` exact (gt-10:249,273) |
| 12 | `sec:succinct-deciders` | gt-10 | gt-10:864 | **DEFECT (M2)** — gt-10:1105-1107 spreads the three 3SAT literals over `w_1,w_2,w_3` |
| 13 | `def:tseitin` | gt-10 | gt-10:152 | OK — `O(s)` size/time; the added output literal is self-declared `SOURCE_REPAIR` |
| 14 | `def:formula-arithmetization` | gt-10 | gt-10:161 | OK — the cited claim is cube agreement; the recursion is attributed to NW19 in the next sentence |
| 15 | `prop:tseitin-arith-degree` | gt-10 | gt-10:174 | OK — "individual degree at most 2" exact (gt-10:177-178); F1 framing soft throughout ("as we read", "our reading may be wrong") |
| 16 | `sec:ld-encoding` | gt-03 | gt-03:833 | OK — `ind_{m,y}`, `g_a`, linearity verbatim (gt-03:875-895) |
| 17 | `thm:pcp-decider` | gt-10 | gt-10:1455 | OK — `c_0 = F_arith ∏(g_i(x_i)−o_i)` verbatim gt-10:1687-1690 |
| 18 | `prop:zero-basis` | gt-10 | gt-10:1281 | OK — `zero(x)=x(1−x)`; `deg_i(c_i) ≤ d−2` matches gt-10:1319 |
| 19 | `fig:pcpverifier` | gt-10 | gt-10:1585 | OK — both checks verbatim (gt-10:1578,1581) |
| 20 | `lem:schwartz-zippel` | gt-03 | gt-03:859 | OK — `Δ/q` exact; `(2+5d)m'` and `(2+d)m'` match gt-10:1746-1751,1766-1768; `def:pcpparams` (b) is `(2+5k)m'/2^k < 1/2` with `d=k` (gt-10:1428,1433) |
| 21 | `fig:ld-decider` | gt-07 | gt-07:391 | OK |
| 22 | `def:cl-canonical` | gt-03 | gt-03:376 | OK — the `v=0` gap is real (the source needs `F` linearly independent) and correctly declared `SOURCE_REPAIR` |
| 23 | `sec:ld-game` | gt-07 | gt-07:31 | OK — the three maps and levels 1/2/3 verbatim (gt-07:205-239); `χ` matches `eq:chi-func` gt-07:214-218; my recomputation `q=8, m=2, s=5 ⇒ χ=2 ⇒ e_2` agrees with Figure 83 |
| 24 | `def:cl-dist` | gt-04 | gt-04:133 | OK |
| 25 | `def:typed-sampler` | gt-06 | gt-06:96 | **DEFECT (m13)** — the described behaviour is `def:typed-sampler-sample`, gt-06:143-152 |
| 26 | `lem:detyping-verifiers` | gt-06 | gt-06:445 | OK — `ℓ+2` levels and `16^{|type|}` exact (gt-06:459-470); `16^{54}` consistent with `|type^ar| = 3 × 18` |
| 27 | `sec:orac-def` | gt-09 | gt-09:34 | OK — roles and identity-on-oracle exact (gt-09:53-70) |
| 28 | `fig:decider-pcp` | gt-10 | gt-10:2071 | OK — five guards in order; `(q,m,d,1)` and `(q,m',d,m'+6)` exact (gt-10:2029,2051); `m'+6 = 5 + (m'+1)` checks out |
| 29 | `thm:introspection` | gt-08 | gt-08:785 | OK |

**Recomputed and unbroken:** `|enc_k(x)| = 2Σ|x_i| + 2k`; `ν(5)=1110110`, `|ν(m)|=2ℓ+1`;
`M_=` three-step trace and `TIME=3`; the Kleene four-equality chain; the `pred` ladder
`⟨0,0⟩→⟨0,1⟩→⟨1,2⟩→⟨2,3⟩`, `fst = 2`; `72c_0 n^{3λ} ≤ n^{(3+⌈log₂72c_0⌉)λ}` and
`C_L(3n^λ)^6 ≤ n^{(6+⌈log₂C_L3^6⌉)λ}` (both correct, using `λ ≤ 2^λ ≤ n^λ`, `n≥2`);
`|x|+T+1, T ≤ 2T(T+|x|)` for `T≥1`; the zipper rung `([0],1,[⊔]) → ([0,0],⊔,[])`;
`occ(x_j)=2·fanout`, `occ(w_i)=2+2·fanout+1_{i=out}` giving the two-gate vector `(2,2,2,4,3)`
and TB0's `(2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)` — both match C8/C3 exactly; `fanout_max ≤ 2 ⇒ δ_F ≤ 7`,
`d ≥ 8`; `p_n = 1−2^{-n} = .5,.75,.88,.94,.97,.98` and `r(n) = 1,3,6,11,22,45` (Figure 98, all six
recomputed against `(1−2^{-n})^r ≤ 1/2`); the `3Q` boundary and `m'+6` answer width.

---

## Figure table — 31 figures inspected at 110 dpi across all four parts

| # | slug | page | verdict |
|---|---|---|---|
| 1 | `pipeline-glance` | 1 | OK — chain matches `fig:compress`; but prints `λ` where Fig 17 prints `L` (M1) |
| 2 | `roadmap` | 2 | **DEFECT (m5)** — §12 has no upgrade arrow; caption says "exactly" |
| 6 | `eq-machine-states` | 6 | OK — five numbered paths = the five table rows; copy row `q_1→q_0`, halt row `q_0→q_h`, catch-all from both |
| 7 | `eq-machine-trace` | 7 | OK — I re-derived all four rows and both head positions; `M_=(1,1)=1`, `TIME=3` |
| 15 | `kleene-square` | 14 | OK — the five expressions and four equalities are exactly the proof's chain |
| 17 | `halt-f-construction` | 16 | **DEFECT (M1)** — `Compress on (⟨V⟩,L)`, `ComputeSampler(L)`; gt-12:435-440 has λ |
| 22 | `normal-vs-cbv` | 19 | OK |
| 23 | `church-bool-if` | 19 | OK — `if false A B` selects `B` |
| 28 | `y-derivation` | 22 | **DEFECT (m16)** — violet `quote` arrow used for "assemble" |
| 30 | `y-vs-z-cbv` | 24 | OK — η-delay located exactly at `λu` |
| 31 | `de-bruijn` | 24 | OK — "cross 1" from the outer λ, "cross 0" from the inner; frames `[B],[A]` resolve `0,1` |
| 45 | `serialization` | 36 | OK — `1110` + payload `110` is `ν(5)`; node layout matches Definition 8.1 |
| 47 | `cek-config` | 38 | OK — all five registers correct; it is the *display* (8.2) that is wrong (m2) |
| 55 | `simulation-ladder` | 45 | OK — I verified the zipper right-move rule against `part2a.tex:733-737` |
| 57 | `resource-dictionary` | 47 | OK — compile/interpret arrow directions and both linear size boxes correct |
| 64 | `psi-ml` | 55 | OK against (10.4) node-for-node; carries M1's `L` and m16's violet arrow |
| 65 | `three-presentations` | 56 | **DEFECT** — M1's `L`; also the "hardwire"/"translate" arrowheads point *into* `F(F̄,M̄,L,…)`, so hardwiring reads backwards |
| 66 | `C-selfref-boundary` | 54 | OK — but out of order (m4) |
| 67 | `trace-tableau` | 57 | OK — window `(j−1,j,j+1)` fixes cell `j` and the moved head; `F+1` rows via the `⟨q_h,1⟩` self-loop |
| 70 | `decoupled-5sat` | 60 | **DEFECT (M2, m18)** — 3SAT clauses shown only in `u_3`; contradicts Fig 71 on the same page |
| 71 | `D-five-block-read` | 60 | OK — and it is the figure that refutes Fig 70 |
| 73 | `tseitin-fanout` | 63 | OK — `occ(w_i)=2+2f`, `δ_F≤7`, `d≥8` all recomputed |
| 74 | `occurrence-vs-degree` | 62 | OK — `2+2·1=4`; three accounts correctly separated (cited ≤2 / bound ≤4 / measured =4); F1 framing soft |
| 79 | `four-layers` | 67 | **DEFECT (M8)** — stratum 1 green/EXECUTED though the text calls it C5 SKETCH; 1→2→3→4 chain asserts a false order |
| 80 | `D-threshold-margin` | 67 | **DEFECT (m3)** — `b_1` drawn below `b_2`; `b_1 > b_2` always |
| 83 | `chi-axis-buckets` | 70 | OK arithmetically (`q=8,m=2,s=5 ⇒ χ=2 ⇒ e_2`); caption's "rather than one" over-claims (M3) |
| 84 | `point-line-maps` | 70 | OK — the three register maps match `gt-07:205-239`; `L^lnf_0=I` visibly marked `SOURCE_REPAIR` |
| 86 | `D-decider-guards` | 72 | OK — five guards in `fig:decider-pcp` order; amber fall-through correct; `(q,m,d,1)`/`(q,m',d,m'+6)` exact |
| 88 | `structural-hypothesis` | 74 | OK — local laws green, C7 dashed |
| 89 | `ladder` | 74 | **DEFECT (M4, m17)** — TB5/TB6 swapped; four wrong claim ids; chips visually ambiguous |
| 98 | `midpoint-diagnostic` | 80 | OK — all twelve bar values recomputed and correct |

**Tally: 23 OK · 4 MAJOR-defect · 4 MINOR-defect.**

---

## Adjudication of the five brief-37 pedagogy suggestions

**S1 — worked miniature for §11.1–11.3. ACCEPT.** Confirmed: §11.1–11.3 contains no concrete instance;
Figures 67, 68, 70, 71 are all schematic (`γ_j`, `a`, `b'`, `⟨q,b⟩`, `N_i`). **Location:** insert after
(11.2), `part2b.tex:220`, a `2 × 4`-cell toy: one `Apply` microstep of a 3-node `\mathcal L` term,
carried through Lemma 11.1's window, Theorem 11.2's clause index, and the five blocks. Reuse Fig 67's
window as its first panel so the reader sees one object three times.

**S2 — parameter card. ACCEPT.** Confirmed: `μ`, `γ`, `τ` appear at `part2a.tex:191-193` and
`part2b.tex:799` and are **never defined**; `λ`, `A`, `C_0`, `C_L`, `c_U`, `c_Y`, `δ_F`, `d`, `q=2^k`,
`m`, `m'` are scattered. **Location:** a boxed card in §7.1 immediately after Definition 7.4
(`part2a.tex:151`), listing λ / μ / γ / τ / `9` / `C_0` with their source labels; fold m6 and m20 into
it. (The card should also carry the TB7 chain from M5.)

**S3 — move the four-layers figure to the head of §12. ACCEPT, figure only.** The layer taxonomy is the
argumentative core and currently arrives on p67 after 4 pages of algebra. **Location:** move
`fig:four-layers` to `part2b.tex:346` (head of §12, before §12.1), retitled as the section roadmap,
leaving §12.4's prose in place. **Precondition: fix M8 first** — moving a figure that mislabels layer 1
as EXECUTED to the head of §12 makes the error worse, not better.

**S4 — split each §14 longtable into "constructs" vs "labels". REJECT as stated.** The six tables
already carry both a **Grade** column (`CONSTRUCTED`/`CHECKED`/`CITED`) and a **Claim** column, and
each is paired with a `fig-D-correspondence-*` figure that already performs the split visually
(green vs dashed slate). Splitting each table doubles the header rows in a `\scriptsize` longtable
whose columns are already 0.08–0.21`\textwidth`. **Counter-demand:** the real §14 defects are M4/M5
(wrong claim ids, missing C12–C15), M9 (four non-existent identifiers), M10 (`ld_decider` under C4a)
and m15 (`fig:correspondence-map` has no claim column). Fix those; then, if more separation is still
wanted, sort rows within each table by grade so `CITED; absent` rows cluster at the bottom.

**S5 — symbol table after the abstract. ACCEPT.** Confirmed: no such table exists (`grep -n "symbol
table\|Notation"` → 0 hits), and the five symbols really are spread: `TIME` (`part1a.tex:97` and
Definition 7.1), fuel (§8.2), charge (`part2a.tex:335`, `:451`, `:500`), level (`part2a.tex:139` **and**
Definition 13.1, 65 pages apart — m7), description size (`part1a.tex:251` and Definition 8.1).
**Location:** one page between the abstract and the TOC in `analytic-underpinnings.tex:88`, before
`\tableofcontents`; it also fixes m6 (`τ`), m7 and m20 at one stroke.

---

## Prioritised repair plan (≤ 12 lines)

1. **M2** — rewrite `part2b.tex:215-217` and redraw `fig-decoupled-5sat` (3SAT literals → `u_3,u_4,u_5`); it currently contradicts Fig 71 on its own page.
2. **M4 + M5** — swap TB5/TB6 in `fig-ladder.tex`, replace the four C7 chips with C12–C15, retitle §14.6, add the TB7 rows and the `9→5→7→9` / `206→840→848→1696` card. Biggest lockstep gap.
3. **M1** — global `L → λ` for `fig:halt_f`'s third argument (Part I §3.1/§6, §10.3, (10.4)/(10.5), 7 figures), with a matching merge proposal for `DESIGN.md §1.1`.
4. **M3** — downgrade the level laws from equalities to memberships; strike "rather than one" from Fig 83; add `gt-04:271-277` non-uniqueness.
5. **M9 + M10** — fix the four bad identifiers (`PCPCLMap`, `PCPPaddedMap`, `TypedProductCL`, `sequential_value`) and move `ld_decider` off C4a to "no current row".
6. **M8** — split stratum 1 of `fig-four-layers`, then (S3) move the figure to the head of §12.
7. **M6** — repair or downgrade the exponent-6 derivation in thm 9.2; the whole `A`-rescaling depends on it.
8. **M7** — add SKETCH rows for the Part II theorems, or one explicit unratcheted-status sentence at the head of §8.
9. **M11** — add the `Checked{T,C}` / `CertNode` subsection and figure to §8; it is the one north-star item with no home.
10. **m1, m2, m3, m4** — the orphan sentence on p29, display (8.2)'s arity, Fig 80's swapped bounds, and the p54–56 float order/whitespace. Cheap, all visible in the delivered PDF.
11. **S2 + S5** — parameter card in §7.1 and symbol table after the abstract; these subsume m6, m7, m20.
12. **S1** — the §11 worked miniature; last, because it needs new figure work rather than edits.

---

VERDICT: FAIL(M1,M2,M3,M4,M5,M6,M7,M8,M9,M10,M11)
