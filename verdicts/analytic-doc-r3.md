# Verdict — analytic document `docs/analytic/`, round 3 (brief 56), closing round

Critic: Opus (vision). Target: the **archived tree at `44160d1`**, extracted with
`git archive 44160d1 | tar -x` into
`…/scratchpad/critic-analytic-doc-r3/tree`. Compiled there with
`pdflatex -interaction=nonstopmode -halt-on-error -output-directory=…/build` **×3**.
`dcaaf34` (the r2 target) was extracted alongside as `prev/` and diffed file-by-file to scope
the attack. All 92 pages rendered with `pdftoppm -r 110 -png`; 25 pages **looked at**, three
regions re-cropped at 300 dpi. Claim statuses read from the **live** `claims/CLAIMS.md`
(orchestrator-owned; identical statuses at `44160d1`, re-derived independently in both trees).
Prior verdict `verdicts/analytic-doc-r2.md` is the work order; what it accepted is not
re-litigated. No repo file other than this verdict was written; no git state was changed; no
Julia was run (`src/` read by `grep` only).

**Gate reproduced exactly, and the delivered PDF is the one I compiled.**
92 pages · 110 figures · `tools/figcoverage.py` exit 0, lists no page · 0 errors · 0 overfull ·
0 undefined references · 0 `LaTeX Warning` lines · **0 backward figure/page pairs** (recomputed
over all 110 `lof` entries from the `.aux`). `pdftotext` of my build and of the committed
`docs/analytic/analytic-underpinnings.pdf` differ in **zero** lines.

**Adjudication: 21 ACCEPTED · 0 PARTIAL · 0 REJECTED** (of 21 response rows).
**Regression sweep: 1 DEFECT (MINOR) · 0 MAJOR.**
**Counts: FATAL 0 · MAJOR 0 · MINOR 1 · NOTE 5.**

Every page number in `briefs/53-analytic-doc-repair-r2.last.md` is correct in the delivered PDF.
The r2 process finding — "the response table is not a reliable record" — is **discharged**: I
checked all 21 rows against the rendered page the row names, and every one is where it says it is.

---

## 1. Adjudication of every response row

### The six r2 MAJORs

| id | verdict | evidence (page looked at) |
|---|---|---|
| **M12** `L`→`λ` | **ACCEPTED** | **p36** Fig 45 fifth branch prints `F̄, M̄, λ ⟶ D̄ ↪ Compress`. **p58** Fig 69 step 2 `hardwire (F̄,M̄,λ)` and step 4 `Compress((S̄,D̄),λ)` — now agreeing with step 3's `ComputeSampler(λ)`; the self-contradiction is gone. **p91** Fig 109 prints `…Quoted(Decider))),λ),F_C)`, identical to (10.4) on p58. Sweep: `(?<![A-Za-z_\\{])L(?![A-Za-z_0-9}])` over `figs/*.tex parts/*.tex` returns 48 hits, **all legitimate** — `C_L`, `\mathcal L`, `L^{lnf}`, `L_{Point}`, the zipper `(L,s,R)`, the CL function `L`, the marginal `L^{w,n}`, the 5SAT block length `L=2^{ℓ_0}`, and one TikZ *node name* `L` whose printed label is `$\lambda$` (`fig-C-closed-verifier.tex:13`). Ground truth `gt-12:427-458` (`fig:halt_f`) confirms the third slot is `\lambda`. |
| **M13** C16–C19 provenance | **ACCEPTED** | All four "no row" sites replaced and a fifth site added. **p38** §8 reminder: the 13 results are "recorded as `C16`–`C19` in `claims/CLAIMS.md` at SKETCH — not yet adversarially verified: a written derivation, no machine check, no converged verdict", with the four-way partition spelled out. **p82** §14 preamble likewise. **p37** Fig 47's middle tag is `SKETCH — C16–C19` and its four groups carry bold `C16`/`C17`/`C18`/`C19`. **p83** Fig 99's caption. **p84** the five former "none" cells now read `C17/C17/C16/C19/C19 SKETCH`. **p87** the §14.6 `fig:halt_f` row gained `C18 SKETCH` beside `C15 Conj.` I checked the partition against the four `where-proved` cells: C16 = `part2a §8.3–§8.4` (Thms 8.2–8.4, Lem 8.5), C17 = `§9.1–§9.3` (Thms 9.1–9.3), C18 = `§10.1–§10.3` (Lem 10.1, Thms 10.2–10.4), C19 = `part2b §11.1–§11.3` (Lem 11.1, Thm 11.2) — exactly the reminder's list, no result twice, none missing. `grep -c "C1[6-9]"` over `parts/` + `figs/` is now 21, not 0. Row-text spot-check: the §14.1 `sec:succinct-deciders` cell is `C19`, and C19's row does explicitly cover "the decoupled five-block form … first, second and third literal in `u_3,u_4,u_5`", so that attribution is right and not a stretch. |
| **M14** Fig 90 level laws | **ACCEPTED** | **p76**: the green box now prints `L ∥ R` ***is*** `(k+ℓ)`-level, `⊕_j L_j` ***is*** `max_j ℓ_j`-level, over a second line "upper bounds (`rk:higher-level`); minimality is never claimed". The caption's last clause is now "concatenation exhibits `k+ℓ` stages and direct sum `max_j ℓ_j`; neither is claimed minimal". Figure, Lemma 13.2, the "neither can be strengthened to an equality" sentence and the two counterexamples now say the same thing on one page. Ground truth re-read: `gt-04-cl.tex:282-292` "is a `(k+ℓ)`-level conditionally linear function"; `:315-327` "is an `ℓ`-level CL function for `ℓ = max_j{ℓ_j}`" — memberships, as printed. Consistent with C4a/C4b's "upper bounds … not minimality claims". |
| **M15** Fig 47 overstrike | **ACCEPTED** | **p37**, looked at at 110 dpi and re-cropped: `CITED`, `SKETCH — C16–C19` and `TESTED / PROVED` each sit cleanly **below** their own header box; no glyph touches another. The fix is structural, not a nudge — the tags are `at ([yshift=-1.2mm]h*.south west)` and the bodies `([yshift=-1.2mm]t*.south west)`, and the footer hangs `([yshift=-4mm]bodies.south west)` off a `fit` node over all three bodies, so the layout cannot break again under a text edit. The footer no longer collides with column 1. |
| **M16** `thm:ar` grade | **ACCEPTED** | **p86** §14.4 `thm:ar` row: Grade `CHECKED/CITED`, Claim **"no current row"**. **p85** Fig 102's chip is `NO ROW — CITED` and the caption now says "Detyping and `thm:ar` stay dashed: both have no ratchet row and stay CITED. Only the executable classical part … is ratcheted, by C9 at TESTED; C5 governs `thm:pcp-decider`'s parameter arithmetic, not `thm:ar`'s completeness, soundness, and entanglement contract." The promised C5 sweep really was done and found one more: §14.3's `lem:ld-soundness` row moved from `C5 SKETCH` to "no current row" (**p85**), which agrees with the prose "It is CITED" and with C5's row text (a parameter-arithmetic claim, not a quantum one). The one surviving C5 cell, §14.2's `thm:pcp-decider` (**p84**), is the correct one. |
| **M17** Fig 84 box 3 | **ACCEPTED** (verdict's option 1, exercised honestly) | **p71**: box 3 now reads "the two bounds `(deg_F+5d)m'/q` and `(2+d)m'/q` are computed here and compared with `1/2`; the identity they then imply is `lem:schwartz-zippel`, CITED"; its tag is `BOUNDS CHECKED; IMPLICATION CITED`; **its arrow into the `thm:pcp-decider` spine changed from solid-green to dashed-cited**; and the legend gained "in layer 3 only the two bounds are executed — the step from a random agreement to a formal identity is `lem:schwartz-zippel`, which no sample count can replace". That is verbatim the surviving-statement language of §12.4 ¶1 and Fig 88's caption, so the three now agree. `gt-03-prelim.tex:859-864` re-read: the lemma is the `Δ/q` agreement bound, imported, exactly as the box now says. The two bounds it *does* compute are C5's own `(deg_F+5d)m'/q` and `(2+d)m'/q`. |

### The six r1 PARTIALs carried forward

| id | verdict | evidence |
|---|---|---|
| **M1** | **ACCEPTED** | closed by M12; the four residual sites are gone and the re-grep is clean. |
| **M3** | **ACCEPTED** | closed by M14. |
| **M7** | **ACCEPTED** | closed by M13; the document and the ratchet now agree about the ratchet's own contents. |
| **M8** | **ACCEPTED** | **p71**: the layer-1 split (green 1(a) `EXECUTED`, slate 1(b) `CITED — C5 SKETCH`) and the arrow topology (2 and 3 → 1(b); 1 and 4 → the answer-reduction contract) survive M17's edit unchanged; the figure is still at the head of §12 (S3). |
| **M10** | **ACCEPTED** | closed by M16; `fig:ld-decider`, `lem:cl-concat/lem:cl-func-prod`, `lem:detyping-verifiers`, `lem:ld-soundness` and `thm:ar` all now read "no current row", and none of those five is inside `C16`–`C19`'s scope (Lemma 13.2 lives in §13, outside §§8–11). |
| **m10** | **ACCEPTED** | **p56**: "for a suitable `(k+1)`-input machine", consistent with `φ_p^{(k+1)}(p,x)` two lines below and with Fig 67's `|e_Q| ≤ 2a_s|p|+b_s ≤ 2a_sa_1|q|+(2a_sb_1+b_s)`. |

### MINOR and NOTE rows

| id | verdict | evidence |
|---|---|---|
| **m22** | **ACCEPTED** | **p67**: "Cells are numbered from 1, so the window at `j=2` is cells 1,2,3: `y_w` is the Tseitin variable for 'row 0 shows `(⟨q_0,Ap⟩, λ, v)` at this window'". That triple is now exactly the drawn amber window. The polarity-family argument below is untouched and still correct. |
| **m23** | **ACCEPTED** | **p82** Fig 97's TB0 chip is `C2, C3, C8 TESTED`; **p37** Fig 47's right column likewise. Both now match `fig-correspondence-map`. |
| **m24** | **ACCEPTED** | **p34**: "The other seven are universal constants of the source, fixed before any verifier is supplied; `λ` alone is supplied per call." The caption agrees ("only `λ` is supplied per call; the rest are decided once and for all"), and the card really does have eight rows. |
| **m25** | **ACCEPTED** | **p88**: "`repetitions`=2: a `ToyPolicy` override of `k(n)=(λn)^{(1+c_3')τ}`". Verified against `docs/DESIGN.md:1735` (`ToyPolicy(…,repetitions,…)`) and `:1760` (`repetitions_toy=2`). The number is now marked as a policy input, not a consequence. |
| **m26** | **ACCEPTED** | **p2**: the symbol table's `f,F` row reads "`F` plays the role of the paper's time bound `T` in `prop:standard-succinct-sat`". Checked against `gt-10:237-260`: the algorithm takes `(D, n, T, Q, σ, x, y)` and reserves `2T` bits per answer block — the same slot the document writes `F`/`2F`. |
| **m27** | **ACCEPTED** | as m10. |
| **m28** | **ACCEPTED** (MP-A applied) | `claims/CLAIMS.md` C17 at `44160d1` and in the live tree reads `c_0(|M|+k+1)*T(T+|x|)` — the stray `2` is gone, and the row now transcribes (9.2) with `c_M=c_0(|M|+k+1)`. The document was correctly left unchanged. |
| **n4** | **ACCEPTED** (MP-B applied + document half) | `docs/DESIGN.md:84` now reads `Hole(self_code,Quoted{Decider})), lambda)` in both the archived and the live tree — MP-1 is finished. The stale third `SOURCE_REPAIR` at `part2a.tex:1435-1445` now records that "that repair has since been applied, and `DESIGN.md` §1.1 now declares `self_code : Quoted{A}`, so on this point the two agree", with the other two kept open. I confirmed `DESIGN.md:51,69` do declare `Quoted{A}`, so the sentence is true. |
| **n5** | **ACCEPTED** | The failure mode r2 named — inaccurate self-reporting — did not recur. All 21 cited pages are correct in the delivered PDF; the `figcoverage`/overfull/undefined/backward-pair numbers are reproduced to the digit; and the one edit made outside the work order (the literal-backslash `Checked\{TypedSampler\}` → `Checked{TypedSampler}` at §14.4, **p85**) is declared in the report and is visibly correct. |

---

## 2. Regression sweep

### 2.1 Claim-id chips against `claims/CLAIMS.md`

Statuses re-derived from the live file (identical at `44160d1`): C1 CONJECTURE · C2, C3, C4a, C4b,
C8, C9 TESTED · C5 SKETCH · C6, N1 PROVED · C7 CONJECTURE · C12–C15 CONJECTURE · C16–C19 SKETCH ·
no C10 or C11 row exists.

| site (group) | chip / cell printed | ratchet status | verdict |
|---|---|---|---|
| `fig-ladder` TB0/TB0.5/TB1/TB2 | `C2,C3,C8 TESTED` · `C6,N1 PROVED` · `C4a TESTED` · `C4b,C9 TESTED` + `C5 SKETCH` | TESTED×5, PROVED×2, SKETCH | **OK** |
| `fig-ladder` TB3/TB4 | `NO ROW / C10 PROPOSED` · `NO ROW / C11 PROPOSED` | no C10, C11 rows; footer names the briefs | **OK** |
| `fig-ladder` TB5/TB6/TB7/DL9 | `C13` · `C14` · `C15` · `C12` CONJECTURE | CONJECTURE ×4 | **OK** |
| `fig-three-provenances` (11 sites) | `CITED` · `SKETCH — C16–C19` + four group labels · `TESTED / PROVED` + `C2,C3,C8` / `C4a` / `C4b,C9` / `C6,N1` | SKETCH ×4, TESTED ×5, PROVED ×2 | **OK** |
| `fig-correspondence-map` row 1 | **`NO ROW`** over `bounded_trace`, `decouple5` | **C19 SKETCH** — the §14.1 table one page later gives exactly these objects `C19 Sketch` | **DEFECT — m29 (MINOR, stale weaker chip)** |
| `fig-correspondence-map` rows 2–6 | `C2,C3,C8 TESTED` · `C4a TESTED` · `C4b,C9 TESTED` · `C6,N1 PROVED` · `C15 CONJ.` | matches | **OK** |
| `fig-four-layers` · `fig-D-correspondence-polynomial` | `CITED — C5 SKETCH` · "PCP soundness remains C5 Sketch" | SKETCH; both sit on `thm:pcp-decider`, which is C5's actual scope | **OK** |
| `fig-D-correspondence-typed` | `NO ROW — CITED` | `thm:ar` and detyping are ungoverned; C9 explicitly leaves "every quantum conclusion CITED" | **OK** |
| `fig-structural-hypothesis` · `fig-D-closure-gap` | `C7 CONJECTURE` ×2 | CONJECTURE | **OK** |
| `fig-D-correspondence-cl` · `-midpoint` · `fig-tb7-card` | `C4a TESTED` · `C6,N1 PROVED` · `C15 Conjecture` | matches | **OK** |
| `fig-tseitin-fanout` · `fig-occurrence-vector` | bare `TESTED` tags on the `deg_F ≤ 7` / occurrence fixtures | C8, C2/C3 TESTED | **OK** |
| `part2b` §14.1 (5 cells) | `C17/C17/C16/C19/C19 SKETCH` | SKETCH ×4; each cell's analytic statement lies in the cited row's `where-proved` range | **OK** |
| `part2b` §14.2 (6 cells) | `C2/C8/C3/C2 Tested`, `C1 Conj.`, `C5 Sketch` | matches | **OK** |
| `part2b` §14.3 (6 cells) | `C4a Tested` ×3, "no current row" ×3 | Lemma 13.2 / `fig:ld-decider` / `lem:ld-soundness` are outside C16–C19 (§13) and ungoverned | **OK** |
| `part2b` §14.4 (6 cells) | `C4b Tested` ×3, `C9 Tested`, "no current row" ×2 | matches | **OK** |
| `part2b` §14.5–§14.6 (8 cells) | `C6/N1 Proved`, `C12/C13/C14/C15 Conj.`, `C15 Conj. + C18 Sketch` | matches | **OK** |
| `part2b` `\claim{}{}` (6 uses) | `C8 TESTED`, `C5 SKETCH` ×2, `C4a TESTED`, `C4b TESTED`, `C7 CONJECTURE` | matches | **OK** |
| `part2a` §8 reminder + `part2b` §14 preamble | `C16`–`C19` at SKETCH, four-way partition | matches the four `where-proved` cells | **OK** |

**~80 claim-id sites checked; 79 OK, 1 DEFECT.** No chip anywhere is *stronger* than its row —
so no MAJOR. The single defect is *weaker* than its row, i.e. under-claiming, which the brief
calibrates as MINOR.

#### m29 (MINOR) — Figure 98's first row still says `NO ROW` where the table below it says `C19 SKETCH`
`figs/fig-correspondence-map.tex:16` → **Figure 98, p83**, claim column: `NO ROW` over the paper
object "bounded decider trace / succinct 5SAT", Julia `bounded_trace`, `decouple5`. On **p84**, the
§14.1 rows for `prop:standard-succinct-sat` (`bounded_trace, cook_levin`) and `sec:succinct-deciders`
(`decouple5`) both read `C19 Sketch`. This is the *fifth* M13 site: at `dcaaf34` those cells read
"none" and the figure agreed with them; the repair changed the cells and left the figure, so a
figure and the table it summarises now contradict each other one page apart, in the direction of
under-claiming. `fig-correspondence-map.tex` is not in the repair's touched list, which is exactly
why it was missed.
**FIX:** `NO ROW` → `C19 SKETCH` in that cell. Nothing else in the figure changes.

### 2.2 `L`-for-`λ` (the r2 pattern)
0 survivors. See M12 above for the full enumeration of the 48 legitimate bare `L`s.

### 2.3 `\gt{}` label resolution
31 citations, 30 distinct label sets, **31/31 resolve** — each label was checked to occur as
`\label{…}` in the very file the citation names (`ground-truth/gt-03,04,05,06,07,08,09,10,12`).
0 defects. The three added at r1 (`def:typed-sampler`, `rk:higher-level`, `fig:compress/eq:mu-gamma/eq:c_rep`)
still resolve; no citation was broken by two repair rounds.

### 2.4 Other regression checks
- `& none` cells in `parts/`: **0** remaining (the §14 preamble's "reading `none` or `no current row`"
  wording was correctly reduced to "`no current row`").
- Green (`tag check`) tags scanned across all 110 figure files for a second M17-class mis-grade:
  none found. `fig-structural-hypothesis`'s `DERIVED LOCALLY` sits below a `C7 CONJECTURE` cited box,
  which is the correct split.
- §14.6's assertion "No line of `src/` implements them": verified — `grep -ri 'introspect|repeat|compress'`
  over the archived `src/` returns only `_bind_certificate`'s unrelated `anchor` variable.
- Sparse-page check: only pp. 62 and 92 fall below 160 words; the figure-per-page rule is not
  distorting pagination.

---

## 3. Figure spot-checks

**30 figures inspected on 25 pages at 110 dpi; 3 regions re-cropped at 300 dpi.**
All **12** figure files the repair touched were rendered and looked at.

| # | slug | fig | page | verdict |
|---|---|---|---|---|
| 1 | `symbol-table` | 2 | 2 | **OK** — `F ≡` the paper's `T` row present (m26) |
| 2 | `parameter-card` | 43 | 34 | **OK** — "the other seven … `λ` alone is supplied per call" (m24) |
| 3 | `source-obligations` | 45 | 36 | **OK** — `F̄, M̄, λ` (M12) |
| 4 | `three-provenances` | 47 | 37 | **OK** — no overstrike, `SKETCH — C16–C19`, C2 present (M15, M13, m23) |
| 5 | `C-diagonal-five-steps` | 69 | 58 | **OK** — steps 2/3/4 all `λ` (M12) |
| 6 | `miniature` | 79 | 67 | **OK** — indexing convention stated; window `(⟨q_0,Ap⟩,λ,v)` matches the drawing (m22) |
| 7 | `four-layers` | 84 | 71 | **OK** — box 3 honest text + tag + dashed arrow (M17); layer-1 split and topology intact (M8) |
| 8 | `cl-inductive` | 90 | 76 | **OK** — memberships, "minimality is never claimed" (M14) |
| 9 | `ladder` | 97 | 82 | **OK** — TB0 chip `C2, C3, C8 TESTED` (m23) |
| 10 | `D-correspondence-typed` | 102 | 85 | **OK** — `NO ROW — CITED` (M16) |
| 11 | `tb7-card` | 105 | 88 | **OK** — `repetitions=2` labelled a `ToyPolicy` override (m25) |
| 12 | `final-accounting` | 109 | 91 | **OK** — `…),λ),F_C)` matches (10.4) (M12) |
| 13 | `correspondence-map` | 98 | 83 | **DEFECT (m29)** — row 1 `NO ROW` vs `C19 SKETCH` on p84 |
| 14–30 | `pipeline-glance` 1 p1 · `quine` 17 p16 · `two-layers` 38 p30 · `lambda-bounded` 42 p34 · `ar-invokes-pcp` 46 p36 · `l-grammar-gallery` 48 p38 · `kleene-sizes` 67 p56 · `trace-tableau` 74 p63 · `pcp-local-verifier` 87 p74 · `D-threshold-margin` 88 p74 · `D-correspondence-description` 99 p83 · `D-correspondence-polynomial` 100 p84 · `D-correspondence-cl` 101 p85 · `D-correspondence-midpoint` 103 p86 · `D-correspondence-compression` 104 p87 · `evidence-boundary` 106 p89 · `D-final-seal` 110 p92 | | | **OK** — all 17 unchanged and uncorrupted; Fig 88's `b_1 > b_2 ⟺ deg_F+4d > 2` and its `SCHWARTZ–ZIPPEL BOUNDS, CITED` tag still agree with the repaired Fig 84 |

**Tally: 30 inspected · 29 OK · 1 MINOR-defect · 0 MAJOR-defect.** Two cosmetic blemishes are
recorded as NOTEs (n8, n10) rather than defects.

---

## 4. Ground-truth fidelity of what the repairs rewrote

Every statement about the paper that changed between `dcaaf34` and `44160d1` was re-checked in the
archived `ground-truth/`:

- `fig:halt_f` third argument (`gt-12:427-458`): `\lambda`, the resource bound of `def:lambda`, not
  a level — the M12 rename is faithful in all three figures.
- `lem:cl-concat` (`gt-04:282-292`) and `lem:cl-func-prod` (`gt-04:315-327`): both are
  **memberships** ("is a `(k+ℓ)`-level", "is an `ℓ`-level for `ℓ = max_j ℓ_j`") — Fig 90's new box
  and caption transcribe them exactly, and `gt-04:275-280`'s non-uniqueness remark is what the
  "minimality is never claimed" line rests on.
- `lem:schwartz-zippel` (`gt-03:859-864`): unequal polynomials of total degree `≤ d` agree at a
  uniform point with probability `≤ d/q` — an imported analytic implication, as Fig 84 box 3 now
  says; the two things the box claims to *compute* are C5's `(deg_F+5d)m'/q` and `(2+d)m'/q`.
- `prop:standard-succinct-sat` (`gt-10:237-260`): the algorithm's signature is
  `(D, n, T, Q, σ, x, y)` with `2T` reserved bits per answer block — the symbol table's new
  `F ≡ T` sentence is exact, and it retro-fixes m26's complaint about `2F`.
- C19's row text covers the decoupled five-block form, so the §14.1 `decouple5` cell's `C19` is
  a correct attribution, not a convenient one.
- `docs/DESIGN.md` §1.1: `self_code : Quoted{A}` at `:51` and `:69`, and `:84` now reads `lambda` —
  both halves of the third `SOURCE_REPAIR`'s new sentence are true.

**No new misstatement of the paper was introduced, and after M14/M16/M17 no claim anywhere in the
document is stronger than `claims/CLAIMS.md`.** Direction of divergence is now uniformly *weaker*
than the ratchet, with m29 the only remaining instance.

---

## 5. Pedagogy — can a physicist read this front to back?

**Yes.** I sampled Part I (pp. 1, 2, 16, 30), the bridge (pp. 34, 36, 37, 38), the technical core
(pp. 56, 58, 63, 67, 71, 74, 76) and the accounting (pp. 82–92). The document has a working
pedagogical machine: a notation table *before* the TOC that fixes all nine travelling quantities;
`Reminder` boxes that re-state the Part I idea just before it is used in anger; "Why this matters
here" paragraphs; worked reductions; and one figure per page, each captioned as a claim rather than
a label. The `three-provenances` / `grades` / `certificate-tree` / `ladder` quartet means a reader
can, at any point, ask "what kind of evidence is this?" and get an answer on the same page. The
§11 miniature (p67) now works as intended: one clause carried through window → index → five-block
family, with the indexing convention stated.

Five concrete improvements for a future round, as NOTEs, **not objections**:

**n6 — carry the status stamp onto the theorem itself.** A reader who opens at Theorem 9.2 or
Lemma 11.1 sees a theorem environment with no evidence marker; the C16–C19 provenance lives only
in the §8 reminder (p38) and the §14 preamble (p82). A one-word margin or trailing chip on each of
the 13 Part II environments (`C17 · SKETCH`) would make the honesty local instead of remembered.
This is the cheapest remaining upgrade and it would have prevented M7/M13 structurally.

**n7 — fix m29 and then state the invariant.** After the `NO ROW → C19 SKETCH` cell fix, add one
line to Figure 98's caption saying the claim column is the same value as the §14.x table's Claim
column for the same object. Two rounds have now produced a figure/table divergence in this exact
pair; an asserted invariant is what stops a third.

**n8 — the `(10.4)` tag overprints `F_C))` (p58).** Confirmed at 300 dpi, and present identically
at `dcaaf34`, so it is a pre-existing production blemish rather than a repair regression, and the
next sentence does define `F_C`. The display is `\begin{equation}`-numbered inside a narrow
`\hspace`-aligned body; giving the last line an `\hphantom` or moving to `align`/`\notag` + a
manual tag would clear it. The same pass should nudge Figure 88's green "choose `q=2^k`" box
(p74), whose left border currently sits on the dashed box's border and grazes the `m'` of `(2+d)m'`.

**n9 — the ladder still grades only what passed.** Figure 97's TB0 chip lists `C2, C3, C8 TESTED`,
but C1 (TB0, CONJECTURE) and C7 (CONJECTURE) appear nowhere on the ladder, although the footer
promises "Chips transcribe `claims/CLAIMS.md`". A second, slate-coloured chip under TB0 reading
`C1 CONJECTURE` — and C7 attached wherever the structural hypothesis enters — would make the
ladder show the claims that did *not* land, which is the more informative half.

**n10 — typographic pass on the two widest figures.** Figure 47's three bold column headers
hyphenate across lines ("transcribed from the pa-per", "derived here, in this docu-ment"); at
`text width=3.9cm` a `\raggedright\hyphenpenalty=10000` or a 0.3 cm widening removes it. It is the
first figure a reader meets in Part II and the only one whose headers break mid-word.

---

## 6. Repair plan (≤ 3 lines)

1. **m29** — one cell: `figs/fig-correspondence-map.tex:16`, `NO ROW` → `C19 SKETCH`; re-render p83.
2. **n6–n10** — optional, at the orchestrator's discretion; none blocks convergence.
3. No further critic round is required for the six r2 MAJORs or the six r1 PARTIALs: all twelve are
   closed in the delivered PDF, and both merge proposals (MP-A, MP-B) are applied in the ratchet and
   in `DESIGN.md`.

---

VERDICT: PASS
