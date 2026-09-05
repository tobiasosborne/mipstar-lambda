# Verdict — analytic document `docs/analytic/`, round 2 (brief 52)

Critic: Opus (vision). Target: the **archived tree at `dcaaf34`**, extracted with
`git archive dcaaf34 | tar -x` into
`…/scratchpad/critic-analytic-doc-r2/tree`; `e3fe341` extracted into a sibling `prev/` and
diffed file-by-file to scope the attack. Compiled there with
`pdflatex -output-directory=…/build` **×3** → **91 pages, 0 errors, 0 overfull, 0 undefined,
110 figures, a figure on every page, 0 backward figure/page pairs** — the repair's claimed gate is
reproduced exactly. Pages rendered with `pdftoppm -r 110 -png` (two figures re-cropped at 300 dpi)
and **looked at**. Every number is recomputed from `ground-truth/gt-*.tex` **in the archived tree**
or derived by hand. Prior verdict `verdicts/analytic-doc-r1.md` is treated as the work order; what
it passed is not re-litigated. No repo file other than this verdict was written; no git state was
changed; no Julia was run (`src/`, `test/`, `toys/` read by `grep` only).

**Counts: FATAL 0 · MAJOR 6 · MINOR 7 · NOTE 2.**
**Adjudication: 34 ACCEPTED · 6 PARTIAL · 0 REJECTED** (of 40 response rows).

The dominant finding is not new error but **three r1 MAJORs reported FIXED that are only
partly fixed in the delivered PDF** (M1→M12, M3→M14, M7→M13) plus **two regressions the repair
itself introduced** (M16, M17). The response table in `briefs/47-analytic-doc-repair-r1.last.md`
is therefore not a reliable record: it names `C-diagonal-five-steps` and `final-accounting` among
the figures where the `L→λ` rename was applied, and neither was touched at those sites.

---

## 1. Adjudication of every response row

### MAJOR (11 rows: 6 ACCEPTED · 5 PARTIAL)

| id | verdict | evidence |
|---|---|---|
| **M1** `L`→`λ` | **PARTIAL** | Text is clean: (10.4)/(10.5), §7.3 item 5, thm 10.4 and Figs 1, 18, 70, 71, 72 all print `λ`. **Residual: 4 sites in 3 figures still print `L`** — `figs/fig-source-obligations.tex:10` (Fig 45, p36), `figs/fig-C-diagonal-five-steps.tex:6,10` (Fig 69, p57), `figs/fig-final-accounting.tex:10` (Fig 109, p90). See **M12**. |
| **M2** 5SAT literal placement | **ACCEPTED** | `part2b.tex:225-231` now reads "first literal to `u_3`, second to `u_4`, third to `u_5`", which is `gt-10-answer-reduction.tex:1105-1107` verbatim (`\varphi_{3SAT}(w_1,w_2,w_3)`: first variable from `w_1`, second from `w_2`, third from `w_3`). Fig 77 (p65) redrawn: `u_3/u_4/u_5` are labelled FIRST/SECOND/THIRD LITERAL, equality gadgets `u_3=u_4`, `u_4=u_5` drawn, copies labelled `(u_3)_1→a`, `(u_3)_2→b` (= `w_{1,1}=a_1`, `w_{1,2}=b_1`, `gt-10:1099-1100`), lengths `L=2^{ℓ_0}`/`R=2^{r_0}` separated. **Fig 77 and Fig 78 now agree on their own page**, and both agree with `eq:5sat` (`gt-10:952-958`: exactly one addressed bit per block). Fig 94 (`D-decider-guards`, p79) is untouched and consistent. |
| **M3** level laws as equalities | **PARTIAL** | Lemma 13.2 (`part2b.tex:670-690`) now says **is a** `(k+ℓ)`-level / **is a** `max_j ℓ_j`-level CL function; both my r1 counterexamples (`id ⊕ id`; zero at level 5) are in the text at `:702-715`; `gt-04-cl.tex:275-280` non-uniqueness added at `:660-668`; Fig 91's caption now reads "an upper bound in the sense of `rk:higher-level`, with no minimality claimed"; `lem:level-laws` labelled. **Residual: `figs/fig-cl-inductive.tex:26` (Fig 90, p75) still prints `level(L‖R)=k+ℓ` and `level(⊕_j L_j)=max_j ℓ_j` as equalities — on the same page as the sentence "neither can be strengthened to an equality".** See **M14**. |
| **M4** ladder ids/rungs | **ACCEPTED** (one omission, m23) | `fig-ladder.tex` verified chip-by-chip against `claims/CLAIMS.md` **at dcaaf34**: TB5 = anchoring+`Repeat`/C13 CONJ, TB6 = Pauli+`Introspect`/C14 CONJ, TB7 = end-to-end `Compress`/C15 CONJ, TB3/TB4 = "NO ROW / C10, C11 PROPOSED" (correct — no C10/C11 rows exist), TB2 = "C4b, C9 TESTED / C5 SKETCH", TB1 = C4a TESTED, TB0.5 = C6, N1 PROVED, DL9 rail = C12 CONJ. §14.6 rows corrected. Chips are now below their own boxes (m17). Only gap: **C2 (TESTED, TB0) has no chip** although the footer says "Chips transcribe `claims/CLAIMS.md`" — m23. |
| **M5** TB5–TB7 invisible | **ACCEPTED** | §14.6 retitled "Compression and fixed point (TB4–TB7)" with six C12–C15 rows (`part2b.tex:1163-1220`); new §14.7 + Fig 105 carries `n=2, λ=32768, s_0=9`, level chain `9→5→7→9`, dims `206→840→848→1696`, `Q_I=2<s_0=9`, `3Q_I=6<9`, `P_pcp_encodes_D1=FAIL`, `enu:ar-game` NOT_EXECUTED, non-Pauli schemas VACUOUS — every one matches C15 verbatim. §15.1 destaled ("no longer undesigned … C12–C15 record that design at CONJECTURE"). I re-derived the chain from ground truth: `ComputeIntroVerifier(V,λ,9)` returns a **5**-level verifier (`gt-08:789`), `V^{(2)}` has **7** levels and `S^{(3)}` has **9** (`gt-12:339`) — the card is faithful. |
| **M6** exponent 6 | **ACCEPTED** | (9.3) now states `C_L(|d|+|u|+f+1)^8`; the proof is one-way multitape then one one-tape conversion; new Fig 63 (p51) makes the doubling explicit: `heap ≤ cN` → `microstep ≤ (cN)²` → `f ≤ N microsteps ⇒ c²N³` → `+decode/serialize/primitives ⇒ C N^{e_0}`, `e_0 = max{4,1+e_max}` [MULTITAPE] → `C_L N^{2e_0}`, `e_0=4` ⇒ **8** [ONE TAPE]. Propagated to (9.4), thm 9.3 (`8+⌈log₂(C_L3^8)⌉`), Fig 64 (p52), Fig 65 (p53), `FIGURES.md`. I recomputed both rescalings: `72c_0n^{3λ} ≤ n^{(3+⌈log₂72c_0⌉)λ}` (uses `n≥2, λ≥1`) and `C_L(λ+n^λ+1)^8 ≤ C_L(3n^λ)^8 ≤ n^{(8+⌈log₂(C_L3^8)⌉)λ}` (uses `λ≤2^λ≤n^λ`) — both correct. Statement and proof now agree. |
| **M7** unratcheted Part II theorems | **PARTIAL → falsified at dcaaf34** | The repair discharged M7 by its *first* option (an explicit unratcheted-status reminder at the head of §8, repeated in the §14 preamble and two captions, plus Fig 47) and offered MP-4 as "the alternative". **The orchestrator then applied MP-4 as well**: C16–C19 exist at dcaaf34 at SKETCH, pointing at exactly `part2a.tex §8.3–8.4 / §9.1–9.3 / §10.1–10.3` and `part2b.tex §11.1–11.3`. The document now asserts, in four places, that these same 13 results "carry **no** row in `claims/CLAIMS.md`" and greps **zero** for C16–C19. See **M13**. |
| **M8** four-layers stratum 1 | **PARTIAL** | Layer 1 correctly split (Fig 84, p70): 1(a) green EXECUTED "evaluate the two identities at `z`", 1(b) slate "CITED — C5 SKETCH". Arrow topology fixed exactly as demanded: 2 and 3 join the `thm:pcp-decider` spine, 1(b) and 4 feed the answer-reduction contract; the legend states "layer 3 is used *inside* layer 1, and layer 4 does not follow from layer 3". S3 also applied (figure moved to the head of §12). **Regression: box 3's text was replaced by the bare Schwartz–Zippel statement while keeping the green `checked` style and gaining a "CHECKED AT THE FIXTURE" tag.** See **M17**. |
| **M9** four non-existent Julia names | **ACCEPTED** | Verified against the archived `src/`: `_pcp_cl_map` at `src/samplers/pcp_sampler.jl:65,153` ✓, `pad_level` at `src/samplers/typed.jl:39` ✓, `typed_sampler_product` (returns `Checked{TypedSampler}`) ✓, `sequential_and_optval` at `toys/midpoint/test.jl:129` ✓ (all three sites). `PCPCLMap`, `PCPPaddedMap`, `TypedProductCL`, `sequential_value` now occur **only** in the uncompiled `docs/analytic/build/orig-backup.tex`. Laziness re-attributed to `CLStep` (`part2b.tex:833-836`). |
| **M10** `ld_decider` under C4a | **PARTIAL** | `fig:ld-decider` → "no current row" ✓ (`part2b.tex:1077`); `lem:cl-concat, lem:cl-func-prod` → "no current row" ✓ (`:1072`); `lem:detyping-verifiers` → "no current row" ✓ (p85). **Regression: the repair re-graded `thm:ar` to "C5 SKETCH"** in the §14.4 table and in Fig 102's caption. C5 governs the low-degree-PCP soundness derivation, not `thm:ar`; nothing in `CLAIMS.md` governs `thm:ar`, and C9's own scope says "every quantum conclusion remains CITED". See **M16**. |
| **M11** certificate grammar absent | **ACCEPTED** | New §8.2 "Certificates and the derivation tree" (`part2a.tex:470-540`) defines `Checked{T,C}`, `CertNode(grade, rule, facts, children, replay)`, the five grades, `verify_certificate` replay, `Concrete`/`Opaque` — checked line-for-line against `docs/DESIGN.md` §3 (`:619-659`): identical grade set, identical node shape, identical "no `poly(·)` is silently given an exponent" rule. Fig 51 (p40) lists the five grades in decreasing obligation; Fig 52 (p41) draws the real `AnswerReduce` tree with node names, grades and facts matching `test/tb2_answer_reduce.jl` and C4b's scope (`3×18=54` types, `54²` graph, `18²` graph, `dim V_6=(16,6,16)` summing to the `seed_dim` 38, `PCPCopy6CoordinateScalar` SOURCE_REPAIR). The four TB5–TB7 predicate outcomes are kept separate from the grades, correctly. |

### MINOR (21 rows: 20 ACCEPTED · 1 PARTIAL)

**m1** ACCEPTED — the "the second." fragment is gone from source and from `pdftotext -f 29 -l 30`.
**m2** ACCEPTED — all seven rows of (8.2) are 5-tuples `⟨q,η,K,H,f⟩`; `η'` named in the prose above.
**m3** ACCEPTED — Fig 88 (p73) draws `b_2` left of `b_1` with "`b_2 < b_1` whenever `d ≥ 1`"; I re-derived `b_1 > b_2 ⟺ deg_F + 4d > 2`, true for every `d ≥ 1`.
**m4** ACCEPTED — 0 backward figure/page pairs over all 110 figures (recomputed from the `.aux`).
**m5** ACCEPTED — Fig 3 (p3) draws five upgrade arrows (`§4 → §§8–10` added); the caption drops "exactly" and explains §2 and §12.
**m6** ACCEPTED — the transition-window function is `ω` throughout §11; `μ, γ, τ, k(n), ε_1, ε_2, C_0` are defined in Fig 43.
**m7** ACCEPTED — forward reference to Definition 13.1 at `part2a.tex:150-153`, plus a `level` row in the symbol table.
**m8** ACCEPTED — "The constant 3 … pays for installing the Eval delimiter, removing it, and the one tag check … It therefore *absorbs* the two delimiter units" (`part2a.tex:744-748`).
**m9** ACCEPTED — `→_β^*` at the multi-step sites, `YF =_β F(YF)`, `ZF =_β F(λu.(ZF)u)`, and "`YF ↠_β F(YF)` is false for Curry's `Y`; Turing's `Θ` … does satisfy `ΘF ↠_β F(ΘF)`" (`part1b.tex:341-349`). Fig 29's label carries `=_β`.
**m10** **PARTIAL** — "hardwiring the string `z` into the first input of the program `z` itself" is now Part I's form ✓ and the size arithmetic `|e_Q| ≤ 2a_s a_1|q| + (2a_s b_1 + b_s)` follows from `|s_{1,k}(p,p)| ≤ a_s(|p|+|p|)+b_s` ✓; but the phrase "for a suitable **(k+2)-input** machine" survives, and two lines later the proof uses `φ_p^{(k+1)}(p,x)` — see m27.
**m11** ACCEPTED — the three DESIGN §1.1 divergences are declared `SOURCE_REPAIR` with proposed reverse edits (`part2a.tex:1417-1432`); (iii) is now stale (see n4).
**m12** ACCEPTED — "In Step 1 of `fig:pcpverifier`, which the answer-reduced decider invokes from its game-check step"; new Fig 46 (p36) separates `D̂^ar`'s five guards from `pcpverifier`'s two steps.
**m13** ACCEPTED — `\gt{def:typed-sampler, def:typed-sampler-sample}{gt-06-types.tex}`; both labels resolve (`gt-06:96`, `gt-06:144`).
**m14** ACCEPTED — `SuccinctDecoupled5SAT` in `fig-D-correspondence-description`.
**m15** ACCEPTED — Fig 98 (p82) now has a Claim column on all six rows and prints `zero_basis_decompose`; row 2 carries **C2, C3, C8 TESTED**.
**m16** ACCEPTED — `y-derivation` and `psi-ml` use rust `copyflow`, not violet `quote`.
**m17** ACCEPTED — verified in the p81 render: every chip sits below its own box.
**m18** ACCEPTED — Fig 77 labels `(u_3)_1→a`, `(u_3)_2→b` and uses `L=2^{ℓ_0}` / `R=2^{r_0}` for the two groups.
**m19** ACCEPTED — `lem:zero-rewrite` (`:450`), `def:cl-func-doc` (`:632`), `lem:level-laws` (`:671`) exist and are cited from §14.
**m20** ACCEPTED — 7 uses of `\degF`, 0 of `δ_F`.
**m21** ACCEPTED — "an integer in binary".

### NOTE (3 rows) and pedagogy suggestions (5 rows)

**n1** ACCEPTED — MP-3 was applied: C4b at dcaaf34 reads "built only from **lazy** `CLStep` stages"; the two false clauses are gone.
**n2, n3** ACCEPTED — no status is inflated by the document text; gate independently reproduced.
**S1** ACCEPTED with a defect — the §11 miniature exists (Fig 79, p66) and does carry one object through all three steps, but its window content is self-contradictory (m22).
**S2** ACCEPTED with a defect — Fig 43 (p34) is accurate: I checked `μ=⌈C_intro⌉`, `γ=⌈2a_1/(b_1b_2)⌉` against `eq:mu-gamma` (`gt-12:268-270`); `τ = min` integer with `τ≥C_ar` and `(λn)^τ ≥ c_3^{-1}ε_2^{-17}ln(8/ε_2)` for all `n≥τ`, all integer `λ≥1` against `eq:c_rep` (`gt-12:350-354`); `k(n)=(λn)^{(1+c_3')τ}` against `gt-12:355`; `9` against `fig:compress` item 1 and `gt-12:339`. Only the footer sentence is wrong (m24).
**S3** ACCEPTED — `fig:four-layers` is at the head of §12 (p70) with §12.1 immediately after.
**S4** ACCEPTED as DOWNGRADED — exactly as my own counter-demand directed; tables not split, the four named §14 defects addressed.
**S5** ACCEPTED — Fig 2 (p2) sits before the TOC and carries all nine quantities (`TIME`, `|M|,|t|`, `f,F`, `κ_p`, `level`, `λ`, `Q`, `R`, `k(n)`) with the place each is fixed. Its `level` row explicitly says "an upper bound, never a minimum", which is the right lockstep with M3.

---

## 2. New objections

### MAJOR

#### M12 — Three figures still print the paper's `λ` as `L`, one of them contradicting itself
**Location:** `figs/fig-source-obligations.tex:10` → **Figure 45, p36**; `figs/fig-C-diagonal-five-steps.tex:6` and `:10` → **Figure 69, p57**; `figs/fig-final-accounting.tex:10` → **Figure 109, p90**.

Printed:
- Fig 45, fifth green branch: `F̄, M̄, L ⟶ D̄ ↪ Compress`. The prose it illustrates, ten lines later at `part2a.tex:292-293`, writes `𝓕(𝓕̄, M̄, λ, n, x, y, a, b)`.
- Fig 69, step 2: `hardwire (𝓕̄, M̄, L)`; step 4: `V̄^compr = Compress((S̄,D̄), L)` — **while step 3 of the same figure writes `S̄ = ComputeSampler(λ)`.** One figure, one argument slot, two symbols.
- Fig 109: `… Hole(self_code, Quoted(Decider))), L), F_C)` — the identical display printed as (10.4) on p57 writes `λ`.

**Ground truth, `gt-12-compression.tex:427-458` (`fig:halt_f`):** `Input: (\desc{R},\desc{M},\lambda,n,x,y,a,b)`; `\overline{\sampler} = \ComputeSampler(\lambda)`; `\overline{\verifier^\compr} = \Compress(\overline{\verifier},\lambda)`. The third slot is the resource bound of `def:lambda`, not a level — this is M1, and MP-1 was accepted on exactly that ground.

**FIX DEMAND:** replace `L` by `\lambda` at those four sites; then `grep -n '\bL\b' figs/*.tex` and confirm the only survivors are `C_L`, `L^{lnf}`, `L_{Point}` &c., the zipper `L`, the CL function `L`, and the 5SAT block length `L=2^{ℓ_0}`.
**Surviving statement:** every affected figure's *structure* is faithful to `fig:halt_f`; only the third argument's name is wrong.

#### M13 — The document says the Part II theorems carry no ratchet row; at `dcaaf34` C16–C19 govern exactly them
**Location (4 sites):** `part2a.tex:332` ("carry *no* row in `claims/CLAIMS.md`"); `figs/fig-three-provenances.tex:24` ("written proofs; no row in `claims/CLAIMS.md`", **Figure 47, p37**); `part2b.tex:936-938` (§14 preamble: "with no ratchet row"); `part2b.tex:963` (Figure 99's caption: "carry no ratchet row"). Plus the "none" entries in the §14.1 Claim column (`part2b.tex:975,983`).

`claims/CLAIMS.md` **at this commit** carries C16 (SKETCH, where-proved `docs/analytic/parts/part2a.tex §8.3--§8.4 (Theorems 8.2--8.4, Lemma 8.5)`), C17 (`§9.1--§9.3 (Theorems 9.1--9.3)`), C18 (`§10.1--§10.3 (Lemma 10.1, Theorems 10.2--10.4)`), C19 (`part2b.tex §11.1--§11.3 (Lemma 11.1, Theorem 11.2)`). That is a partition of exactly the thirteen results the §8 reminder enumerates. `grep -rn "C16\|C17\|C18\|C19" docs/analytic/parts docs/analytic/figs docs/analytic/FIGURES.md` returns **zero hits**.

So the document and the ratchet contradict each other about the ratchet's own contents. This is rk-light law 2's canonical failure (divergence between layers), introduced by applying MP-4 without the matching document edit. The direction is under-claiming, so nothing is inflated — but "no row" is now simply false, and it is asserted in the two places (§8 reminder, §14 preamble) that the document offers as its own honesty guarantee.

**FIX DEMAND:** at all four sites replace "no row in `claims/CLAIMS.md`" / "no ratchet row" with "recorded as **C16–C19** in `claims/CLAIMS.md` at **SKETCH** — written derivations, no machine check, no converged verdict"; put `C16`–`C19` into the Claim column of every §14 row whose analytic statement is a Part II theorem (currently "none"); relabel Fig 47's middle column tag "SKETCH — C16–C19".
**Surviving statement:** the *status* the document asserts (SKETCH, not adversarially verified) is exactly C16–C19's status; only the assertion that no row exists is wrong.

#### M14 — Figure 90 still prints the level laws as equalities, on the page that refutes them
**Location:** `figs/fig-cl-inductive.tex:26` → **Figure 90, p75**; caption `part2b.tex` ("concatenation adds levels, and direct sum takes their maximum").

The green box prints `level(L ‖ R) = k + ℓ` and `level(⊕_j L_j) = max_j ℓ_j`. Fourteen lines below it on the **same page**, the document says "neither can be strengthened to an equality" and Lemma 13.2 states memberships; twenty lines below that it gives the two counterexamples. `gt-04-cl.tex:283-292` (`lem:cl-concat`) and `:316-330` (`lem:cl-func-prod`) say "**is a** (k+ℓ)-level" and "**is an** ℓ-level" — memberships. `claims/CLAIMS.md` C4a and C4b both say the constructed depths are "upper bounds in the sense of `rk:higher-level`, **not minimality claims**", so the figure is also stronger than the ratchet (law 1).

My counterexamples stand unchanged: `U=V=F^1`, `L=id_U`, `R_u=id_V` gives `T=id_{U⊕V}`, level 1 not 2; the zero map on `V^{(1)}` regarded as 5-level direct-summed with the 0-level zero map gives the zero map, level 0 not 5.

**FIX DEMAND:** replace the box contents with `concatenate(L,R)` **is** `(k+ℓ)`-level and `⊕_j L_j` **is** `max_j ℓ_j`-level (or `level ≤ k+ℓ`, `level ≤ max_j ℓ_j`), and rewrite the caption's last clause to "concatenation exhibits `k+ℓ` stages and direct sum `max_j ℓ_j`; neither is claimed minimal".
**Surviving statement:** the `≤` direction and the constructed nesting depths 1/2/3 are unaffected.

#### M15 — Figure 47 (new) overstrikes three of its five evidence tags
**Location:** `figs/fig-three-provenances.tex:11,17,26,33,42,49,55` → **Figure 47, p37** (re-cropped at 300 dpi to confirm).

The three header nodes are placed `anchor=north west` at `y=0` with `minimum height=1.0cm`, but each carries a bold title plus a two-line `\scriptsize` subtitle, so each overflows past `y=-1.15` where its tag node sits. In the delivered PDF:
- "CITED" prints **on top of** "a ground-truth footnote names the source label";
- "SKETCH — NOT VERIFIED" prints **on top of** "written proofs; no row in `claims/`";
- "TESTED / PROVED" prints **on top of** "a converged verdict".

A fourth overlap: the footer `lblsm` at `y=-5.45` collides with the left column's bottom line ("detyping-verifiers"), since `b1` starts at `-1.55` with `minimum height=3.6cm` but is taller.

The three overstruck tags are the figure's entire payload — it exists to sort every Part II result by evidence grade. This also falsifies the repair's stated method ("every figure touched was rendered at 110 dpi and looked at before and after"): the defect is visible at 110 dpi.

**FIX DEMAND:** compute the tag `y` from the node (`below=1mm of h1` &c.) instead of a hard-coded `-1.15`, and place the footer `below=4mm of b1` rather than at a fixed `-5.45`; re-render p37 and confirm no glyph overlap. While there, add **C2** to the right column (see m23).
**Surviving statement:** the three-way classification and its contents are correct.

#### M16 — `thm:ar` is graded "C5 SKETCH"; C5 does not cover it and no row does
**Location:** `part2b.tex:1096` (Figure 102's caption, p84: "`thm:ar` is only C5 SKETCH"); the §14.4 table row `thm:ar` → Grade `CHECKED/CITED`, Claim **`C5 SKETCH`** (p85); `figs/fig-D-correspondence-typed.tex:9` (chip `C5 SKETCH` over a box reading "detyping and `thm:ar` quantum implication").

`claims/CLAIMS.md` C5 is "(Soundness vs low-degree proofs) If `Π` has individual degree at most `d` and is accepted with probability greater than 1/2, the low-degree-PCP derivation uses formula bound `(deg_F+5d)m'/q` … zero-test bound `(2+d)m'/q` … `d ≥ deg_F+1` (hence `d≥8`) suffices". That is `thm:pcp-decider`'s parameter arithmetic. It says nothing about `thm:ar`'s completeness/soundness/entanglement contract (`gt-10:2077-2116`). C9's own scope says the converse explicitly: "Detyping, its `+2` levels and its `16^54` loss, and **every quantum conclusion remain CITED**." The document's own certificate tree (Fig 52, p41) grades that contract `AnswerReduceQuantumContract — CITED`.

The repair introduced this: its response table records "`D-correspondence-typed` · 84 · stale C4b chip → `C5 SKETCH`". The honest value was already available two rows up — `lem:detyping-verifiers` → "no current row".

**FIX DEMAND:** set the `thm:ar` row's Claim column to "no current row"; change Fig 102's chip to "NO ROW — CITED" and its caption to "detyping and `thm:ar` both have no ratchet row and stay CITED".
**Surviving statement:** the grade column (`CHECKED` shape / `CITED` theorem) is right; only the claim id is wrong. No status is inflated above SKETCH.

#### M17 — Figure 84 grades the Schwartz–Zippel lemma green, "CHECKED AT THE FIXTURE"
**Location:** `figs/fig-four-layers.tex:19-24` → **Figure 84, p70**.

Box 3 now reads, in the green `checked` style with the tag **CHECKED AT THE FIXTURE**: *"3 random evaluation — unequal polynomials of total degree `≤ Δ` agree at a uniform `z` with probability `≤ Δ/q`."* That is `lem:schwartz-zippel` (`gt-03-prelim.tex:859`) verbatim, and the document cites it as such at `part2b.tex:548`. The figure's own legend defines green as "executed or finite-checked here".

The document contradicts the figure twice:
- `part2b.tex:552-556` (layer 3's paragraph): *"The analytic theorem turns an acceptance probability into formal identity, provided the degree and field-size premises hold. **No sample count can replace that implication.**"*
- Figure 88's caption two pages later: *"**The bounds themselves are cited analytic input**; only the parameter arithmetic that compares them with `1/2` is executed here."*

This is a **regression**: at `e3fe341` the same box read "finite-instance bounds computed; identity implication uses Schwartz–Zippel", which is true. The repair replaced honest text with the bare lemma while keeping the green. It is the same defect class as M8 (a cited implication painted as executed), one box over.

**FIX DEMAND:** either restore text that names what is executed ("the two bounds are computed and compared with `1/2` on the named instance; the identity implication is `lem:schwartz-zippel`, CITED"), or split box 3 as box 1 was split — green "compute `(deg_F+5d)m'/q`, `(2+d)m'/q` and compare with `1/2`" over a dashed "`lem:schwartz-zippel` ⇒ formal identity (CITED)".
**Surviving statement:** the dependency topology (2 and 3 feed 1(b); 1(b) and 4 feed `thm:ar`) is correct and is the substance of the M8 repair.

### MINOR

**m22** `figs/fig-miniature.tex:35-40` (**Figure 79, p66**) — the window and its description disagree. The drawn window is `fit=(a0)(a2)` = `(⟨q_0,Ap⟩, λ, v)`, and `x_{1,2,s}` is glossed as "row 1, cell 2 carries `⟨q_1,v⟩`", which is the second drawn cell — so cells are 1-indexed and the window at `j=2` is `(1,2,3)`. But the note says `y_w` is the variable for *"row 0 shows **(λ, v, ⊔)** at this window"*, which is cells `(2,3,4)`. **FIX:** write `(⟨q_0,\mathsf{Ap}⟩, λ, v)`, or state the indexing convention once in the figure. (The rest of the figure checks out: the polarity-family argument — for each `(i_1,i_2)` exactly one of the four `(o_1,o_2)` clauses has both answer literals false, so the family is equivalent to the three-literal clause — is correct.)

**m23** `figs/fig-ladder.tex:22` (**Figure 97, p81**) — the TB0 chip reads "C3, C8 TESTED"; **C2 is TESTED (verdict `tb0-r3.md`, PROMOTE) and is a TB0 claim**, and C1 is TB0 CONJECTURE. Neither appears, though the footer says "Chips transcribe `claims/CLAIMS.md`". `fig-correspondence-map` (p82) already gets this right ("C2, C3, C8 TESTED"). Same omission in Fig 47's right column. **FIX:** "C2, C3, C8 TESTED" on the TB0 chip and in Fig 47.

**m24** `figs/fig-parameter-card.tex:31-36` (**Figure 43, p34**) — the footer says *"All eight are universal constants of the source, fixed before any verifier is supplied"*, but the card has eight rows of which the **first is `λ`**, which the same row calls "also `Compress`'s second argument" and the caption calls the one thing "supplied per call". **FIX:** "The other seven are universal constants … `λ` alone is supplied per call."

**m25** `figs/fig-tb7-card.tex:24-25` (**Figure 105, p87**) — the right annotation prints `μ=γ=τ=1`, `c_3'=1` beside "**2 repeated copies**", and the predicate table prints `(λn)^τ = 65,536`. With those constants the card's own Figure 43 formula gives `k(n) = (λn)^{(1+c_3')τ} = 65536² ≈ 4.3×10^9`, not 2. The count 2 is a `ToyPolicy` `repetitions` override (`docs/DESIGN.md:1728`), not a consequence, and the figure does not say so. **FIX:** label it "`repetitions=2` (ToyPolicy override of `k(n)`)".

**m26** The paper's time bound `T` and the document's fuel budget `F` occupy the same argument slot with no declared correspondence: `part2a.tex:250-256` writes `PaddedSuccinctDecider(D̄,n,**T**,Q,σ,x,y)` while Theorem 11.2 writes `(t,n,**F**,Q,σ,x,y)` and §11.3 writes "`2F` reserved bits" where `gt-10:1096-1101` writes `2T`. The symbol table's `f,F` row does not mention `T`. **FIX:** add "`F` plays the paper's `T` in `prop:standard-succinct-sat`" to the symbol table's `f,F` row.

**m27** `part2a.tex:1268-1271` — "for a suitable **(k+2)**-input machine", but the proof two lines later uses `φ_p^{(k+1)}(p,x)`, so `p` is a `(k+1)`-input program and `s_{1,k}` fixes one of its inputs. **FIX:** "(k+1)-input machine", or say that `k+2` counts the universal machine's arguments.

**m28** (ratchet side) `claims/CLAIMS.md` C17 states the compilation fuel as `c_0(|M|+k+1)*2T(T+|x|)`; the document's (9.2) states `c_M T(T+|x|)` with `c_M = c_0(|M|+k+1)` — a factor 2 apart. C17 is the weaker of the two, so nothing is over-claimed, but the row does not transcribe the theorem. **FIX:** drop the `2` from the C17 row, or add it to (9.2).

### NOTE

**n4** (defect in `docs/DESIGN.md`, not in the document — route to the orchestrator) MP-1 was applied to DESIGN §1.1 incompletely: the `Psi_M_lambda` display at `docs/DESIGN.md:86-90` still reads `Apply(Quote(Compress), Prim(quoted_pair, …, Hole(self_code,Quoted{Decider})), **L**)` while everything around it was renamed to `lambda`. Same one-token fix as M12. Separately, MP-2 (iii) *was* applied (§1.1's prose now says `self_code : Quoted{A}`), so the document's third declared `SOURCE_REPAIR` at `part2a.tex:1426-1429` is now stale and should become a note that DESIGN has been brought into line.

**n5** Direction of divergence, unchanged from r1: outside M14, M16 and M17 the document remains consistently *weaker* than the ratchet. No status is inflated anywhere. Of the six MAJORs, three are residuals of r1 MAJORs reported FIXED, two are regressions the repair introduced, and one is a production defect in a new figure — i.e. the failure mode has shifted from staleness to **inaccurate self-reporting**, which is the more expensive kind. The response table should be re-verified against the delivered PDF before the next round is declared converged.

---

## 3. Figure table — 26 figures inspected at 110 dpi (2 re-cropped at 300 dpi)

| # | slug | fig | page | new/redrawn | verdict |
|---|---|---|---|---|---|
| 1 | `symbol-table` | 2 | 2 | **new** | OK — nine quantities, each with the place it is fixed; `level` row says "upper bound, never a minimum" |
| 2 | `parameter-card` | 43 | 34 | **new** | DEFECT (m24) — contents verified against `eq:mu-gamma`, `eq:c_rep`, `gt-12:339,355`; footer miscounts `λ` as universal |
| 3 | `ar-invokes-pcp` | 46 | 36 | **new** | OK — five `D̂^ar` guards, only the last calls `pcpverifier`; Step 1 inside that call |
| 4 | `three-provenances` | 47 | 37 | **new** | **DEFECT (M15, M13, m23)** — three tags overstruck; "no row in claims/" false; C2 missing |
| 5 | `grades` | 51 | 40 | **new** | OK — five grades, decreasing obligation, matches DESIGN §3 exactly |
| 6 | `certificate-tree` | 52 | 41 | **new** | OK — node names, grades and facts match `test/tb2_answer_reduce.jl` and C4b/C9 scope; `54`/`54²`/`18²`/`dim V_6=(16,6,16)` all check |
| 7 | `exponent-ladder` | 63 | 51 | **new** | OK — the five steps are a correct derivation of `2e_0 = 8`; agrees with the proof text |
| 8 | `miniature` | 79 | 66 | **new** | DEFECT (m22) — window content `(λ,v,⊔)` disagrees with the drawn window; polarity argument correct |
| 9 | `tb7-card` | 105 | 87 | **new** | DEFECT (m25) — chain and predicate report match C15 verbatim; "2 repeated copies" unmarked as a ToyPolicy override |
| 10 | `decoupled-5sat` | 77 | 65 | redrawn | OK — M2 discharged; agrees with Fig 78 on its own page and with `gt-10:1105-1107` |
| 11 | `D-five-block-read` | 78 | 65 | — | OK |
| 12 | `four-layers` | 84 | 70 | redrawn | **DEFECT (M17)** — layer 1 split correctly, topology correct, box 3 regressed to green Schwartz–Zippel |
| 13 | `D-threshold-margin` | 88 | 73 | redrawn | OK — m3 discharged; `b_2 < b_1` for every `d ≥ 1` recomputed |
| 14 | `ladder` | 97 | 81 | redrawn | DEFECT (m23) — TB5/TB6/TB7 and C12–C15 all correct; C2 omitted |
| 15 | `correspondence-map` | 98 | 82 | redrawn | OK — four columns, claim column present, `zero_basis_decompose`, `sequential_and_optval`, C2 present |
| 16 | `cl-inductive` | 90 | 75 | untouched | **DEFECT (M14)** — level laws as equalities on the page that refutes them |
| 17 | `source-obligations` | 45 | 36 | untouched | **DEFECT (M12)** — `F̄, M̄, L` |
| 18 | `C-diagonal-five-steps` | 69 | 57 | claimed redrawn | **DEFECT (M12)** — `L` in steps 2 and 4, `λ` in step 3 |
| 19 | `final-accounting` | 109 | 90 | claimed redrawn | **DEFECT (M12)** — `L` in the `Compress` argument |
| 20 | `D-correspondence-typed` | 102 | 84 | redrawn | **DEFECT (M16)** — `C5 SKETCH` chip on `thm:ar` |
| 21 | `halt-f-construction` | 18 | 17 | redrawn | OK — `λ` throughout |
| 22 | `psi-ml` | 71 | 59 | redrawn | OK — `λ`; `copyflow` on the hole; node-for-node against (10.4) |
| 23 | `three-presentations` | 72 | 60 | redrawn | OK — `λ`; hardwire/translate arrowheads now point away from the paper node |
| 24 | `C-closed-verifier` | 70 | 58 | redrawn | OK — `λ` |
| 25 | `y-derivation` | 29 | 23 | redrawn | OK — `copyflow` for "assemble"; `YF =_β F(YF)` |
| 26 | `roadmap` | 3 | 3 | redrawn | OK — five arrows; caption drops "exactly" and names §2 and §12 |
| 27 | `pipeline-glance` | 1 | 1 | redrawn | OK — `Compress(⟨V⟩,λ)` |
| 28 | `resource-dictionary` | 64 | 52 | redrawn | OK — exponent 8 |
| 29 | `lambda-preservation` | 65 | 53 | redrawn | OK — both exponent calculations recomputed and correct |
| 30 | `trace-tableau` | 74 | 62 | redrawn | OK — `ω`; window fixes cell `j` and the moved head |
| 31 | `tseitin-fanout` | 81 | 68 | redrawn | OK — `deg_F ≤ 7`, `d ≥ 8` recomputed from `occ(w_i)=2+2·fanout+1_{out}`, `fanout ≤ 2` |
| 32 | `D-correspondence-description` | 99 | 82 | redrawn | OK — `SuccinctDecoupled5SAT` |
| 33 | `D-correspondence-midpoint` | 103 | 85 | redrawn | OK — `sequential_and_optval` |
| 34 | `D-correspondence-compression` | 104 | 86 | redrawn | OK — C12–C15 CONJ. rows |
| 35 | `D-final-seal` | 110 | 91 | redrawn | OK |
| 36 | `pcp-local-verifier` / `cek-config` / `specialize` | 87 / 53 / 58 | 73 / 42 / 46 | — | OK — (8.2)'s five-register rows and the exact splice identity check out |

**Tally: 27 OK · 6 MAJOR-defect (5 distinct figures) · 4 MINOR-defect.**
(The nine new figures alone: 5 OK, 1 MAJOR-defect, 3 MINOR-defect.)

## 4. Ground-truth fidelity of what the repair rewrote

31 `\gt{}` citations (was 29). The three added are all correct and all resolve in the file cited:
`def:typed-sampler, def:typed-sampler-sample` → `gt-06-types.tex:96, 144`; `rk:higher-level` →
`gt-04-cl.tex:122`; `fig:compress, eq:mu-gamma, eq:c_rep` → `gt-12-compression.tex:97, 268, 352`.
The r1 defects at citations 8, 10, 12 and 25 are discharged. Recomputed and unbroken in the new
material: the `9→5→7→9` level chain against `thm:introspection` (5-level output) and `gt-12:339`
(`V^{(2)}` 7 levels, `S^{(3)}` 9 levels); `μ, γ, τ, k(n)` against `eq:mu-gamma`/`eq:c_rep`/`gt-12:355`;
`(λn)^τ = 65,536` at `λ=32768, n=2, τ=1`; `848 × 2 = 1696`; `3Q_I = 6 < 9 = s_0(N)`;
both `A`-rescaling inequalities at exponent 8; `2e_0 = 8` from `e_0 = max{4, 1+e_max} = 4`;
`b_1 > b_2 ⟺ deg_F + 4d > 2`; the 5SAT literal placement and the `w_{1,1}=a_1`, `w_{1,2}=b_1` copies;
`|s_{1,k}(p,p)| ≤ 2a_s|p| + b_s ⇒ |e_Q| ≤ 2a_sa_1|q| + (2a_sb_1+b_s)`; C16's exact `Specialize`
size identity against the proof at `part2a.tex:820-826`. **No new misstatement of the paper was
found**, and no claim in the document is stronger than `CLAIMS.md` except M14, M16 and M17.

## 5. Pedagogy — do the four new devices do the job?

Yes, with the named repairs. The **symbol table** (p2) is the single highest-value addition: nine
quantities with the place each is fixed, read before the TOC, and it pre-empts m6/m7/m20 at one
stroke. The **parameter card** (p34) is the second: it is the only place where a reader learns that
seven of the eight `Compress` constants are decided before any verifier arrives. The **certificate
grammar** (§8.2 + Figs 51–52) finally grounds §14's grade columns in the document's own formal
system, and Fig 52's `CITED` root over `CHECKED` children is the right shape to teach. The **§11
miniature** is the weakest of the four and needs m22 fixed to earn its place — a figure that exists
to make one object concrete cannot describe that object two ways. Two concrete further demands:
(i) the symbol table should carry `F ≡ the paper's T` (m26); (ii) Fig 47 is the natural home for a
one-line legend saying which claim ids sit in the right column, which would have caught C2's
absence.

---

## 6. Repair plan (≤ 8 lines)

1. **M12** — four one-token edits: `L → \lambda` in `fig-source-obligations.tex:10`, `fig-C-diagonal-five-steps.tex:6,10`, `fig-final-accounting.tex:10`; then re-grep. Also propose the same for `DESIGN.md:88` (n4).
2. **M13** — replace "no row in `claims/CLAIMS.md`" / "no ratchet row" at `part2a.tex:332`, `part2b.tex:936,963` and `fig-three-provenances.tex:24` with "C16–C19, SKETCH"; fill the §14 "none" Claim cells.
3. **M14** — restate Figure 90's green box as memberships (or `≤`) and fix its caption's last clause.
4. **M16 + M17** — `thm:ar` → "no current row" in the §14.4 table and Fig 102; restore or split Figure 84's box 3 so the Schwartz–Zippel lemma is not green.
5. **M15** — anchor Figure 47's tag and footer nodes relatively, re-render p37, confirm no overstrike; add C2 to its right column and to `fig-ladder`'s TB0 chip (m23).
6. **m22, m24, m25, m26, m27** — the miniature's window triple, the card's "All eight", the TB7 card's `repetitions=2`, the `F ≡ T` row, the `(k+2)`-input phrase.
7. **m28 + n4** — orchestrator lane: drop the stray `2` from C17, finish MP-1 in `DESIGN.md`, retire the now-stale third `SOURCE_REPAIR` at `part2a.tex:1426`.
8. **Process** — before the next round, re-verify every response-table row against the delivered PDF, not against the intended edit; three rows this round were wrong.

---

VERDICT: FAIL(M12,M13,M14,M15,M16,M17)
