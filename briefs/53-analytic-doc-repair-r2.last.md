# Brief 53 — analytic document repair r2 — report

Built with `pdflatex ×3` into `docs/analytic/build/rep2/`; final PDF copied to
`docs/analytic/analytic-underpinnings.pdf`. **Every page cited below was rendered at 110 dpi
from the FINAL PDF and looked at**; the 19 touched pages were re-rendered after the last compile
and byte-compared with the renders I inspected (18 identical, the one that differed re-inspected).

## Gate
**92 pages · 110 figures · a figure on every page (`figcoverage.py` exit 0, lists no page) ·
0 errors · 0 overfull · 0 undefined · 0 LaTeX warnings · 0 backward figure/page pairs.**

## Response table (page = FINAL-PDF page where the fix is visible)

| id | page(s) | disposition |
|---|---|---|
| **M12** `L`→`λ` | 36, 58, 91 | FIXED — Fig 45 `F̄,M̄,λ`; Fig 69 steps 2/4 now `λ`, agreeing with step 3; Fig 109 `…Quoted(Decider))),λ),F_C)` = (10.4). `grep '\bL\b' figs/*.tex parts/*.tex`: only `C_L`, `\mathcal L`, `L^{lnf}`, `L_{Point}`, zipper `L`, CL `L`, move `{L,S,R}`, 5SAT `L=2^{ℓ_0}`, marginal `L^{w,n}` survive. |
| **M13** C16–C19 | 37, 38, 82, 83, 84 | FIXED — all four "no row" sites replaced; §8 reminder (p38) and §14 preamble (p82) name C16 §8 / C17 §9 / C18 §10 / C19 §11; Fig 47 tag `SKETCH — C16–C19`, its four groups labelled C16–C19; Fig 99 caption (p83); the five §14.1 "none" cells now C17/C17/C16/C19/C19 (p83, 84); §14.6 `fig:halt_f` row gains C18 (p87). |
| **M14** Fig 90 laws | 76 | FIXED — box reads `L‖R` *is* `(k+ℓ)`-level, `⊕_j L_j` *is* `max_j ℓ_j`-level + "upper bounds (rk:higher-level); minimality is never claimed"; caption's last clause rewritten. |
| **M15** Fig 47 overstrike | 37 | FIXED — tags and bodies placed by `[yshift]` off their own node's `.south west`, footer under a `fit` node over the three bodies. No glyph overlap at 110 dpi. |
| **M16** `thm:ar` grade | 85, 86 | FIXED — §14.4 `thm:ar` Claim = "no current row" (p86); Fig 102 chip `NO ROW — CITED` and caption rewritten (p85). C5 sweep: 12 C5 sites checked against C5's row text; one further mis-grade found and fixed — §14.3 `lem:ld-soundness` was "C5 SKETCH", now "no current row" (p85), matching the prose "It is CITED". |
| **M17** Fig 84 box 3 | 71 | FIXED (verdict's option 1) — box 3 stays green for the two bounds it computes and says inside the box "the identity they then imply is `lem:schwartz-zippel`, CITED"; tag `BOUNDS CHECKED; IMPLICATION CITED`; its arrow into the spine is now dashed/cited. Agrees with §12.4 ¶3 and Fig 88. (The full 3(a)/3(b) split was built and rendered first; it cost 2 pages of figure coverage, so option 1 was taken.) |
| **M1** (PARTIAL→) | 36, 58, 91 | FIXED via M12. |
| **M3** (PARTIAL→) | 76 | FIXED via M14. |
| **M7** (PARTIAL→) | 37, 38, 82–84, 87 | FIXED via M13. |
| **M8** (PARTIAL→) | 71 | FIXED via M17; layer-1 split and arrow topology unchanged. |
| **M10** (PARTIAL→) | 85, 86 | FIXED via M16. |
| **m10** (PARTIAL→) | 56 | FIXED via m27. |
| **m22** miniature window | 67 | FIXED — "Cells are numbered from 1, so the window at j=2 is cells 1,2,3"; `y_w` window content is `(⟨q_0,Ap⟩,λ,v)`, matching the drawn box. |
| **m23** C2 chip | 37, 82 | FIXED — Fig 97 TB0 chip "C2, C3, C8 TESTED"; Fig 47 right column likewise. |
| **m24** "All eight" | 34 | FIXED — "The other seven are universal constants … λ alone is supplied per call." |
| **m25** `repetitions=2` | 88 | FIXED — "repetitions = 2: a ToyPolicy override of k(n)=(λn)^{(1+c_3')τ}". |
| **m26** `F ≡ T` | 2 | FIXED — symbol table `f,F` row: "F plays the role of the paper's time bound T in `prop:standard-succinct-sat`". |
| **m27** `(k+2)`-input | 56 | FIXED — "(k+1)-input machine", consistent with `φ_p^{(k+1)}(p,x)` two lines below. |
| **m28** C17 factor 2 | 49 (9.2) | **MERGE PROPOSAL** — ratchet lane; (9.2) is unchanged because the document's own proof gives `c_M T(T+|x|)`. See MP-A. |
| **n4** DESIGN `L`; stale repair | 59 | HALF FIXED + **MERGE PROPOSAL** — the document's third `SOURCE_REPAIR` now records that DESIGN §1.1 has been brought into line (`self_code : Quoted{A}`); the `L` at `DESIGN.md:88` is MP-B. |
| **n5** direction / self-reporting | — | ACKNOWLEDGED — every row above cites a page rendered from the final PDF and looked at; no row was reported from the intended edit. |

## Figures touched (slug · fig · page · what)
`source-obligations` 45 p36 `L→λ` · `C-diagonal-five-steps` 69 p58 `L→λ` ×2 · `final-accounting` 109 p91 `L→λ` ·
`three-provenances` 47 p37 relative anchoring, C16–C19 tag + group labels, C2 · `cl-inductive` 90 p76 memberships ·
`four-layers` 84 p71 box 3 honest text/tag/arrow · `D-correspondence-typed` 102 p85 `NO ROW — CITED` ·
`ladder` 97 p82 C2 · `miniature` 79 p67 window triple + indexing convention · `parameter-card` 43 p34 "the other seven" ·
`tb7-card` 105 p88 ToyPolicy override · `symbol-table` 2 p2 `F ≡ T`.
`FIGURES.md` updated: F67/F68/F76 plan lines corrected (F67 no longer says "Schwartz–Zippel — CHECKED at finite instance"; F76 no longer says `D_{M,L}`) plus a "Changed in brief 53" section.
One cosmetic fix outside the work order: §14.4 printed `Checked\{TypedSampler\}` with literal backslashes; now `Checked{TypedSampler}` (p85).

## MERGE PROPOSALS (orchestrator lane — no file outside `docs/analytic/` was touched)
- **MP-A (m28)** `claims/CLAIMS.md` C17: drop the stray `2` — `c_0(|M|+k+1)*2T(T+|x|)` → `c_0(|M|+k+1)T(T+|x|)`, which is what Theorem 9.1 (9.2) proves with `c_M=c_0(|M|+k+1)`.
- **MP-B (n4)** `docs/DESIGN.md:88`: `Hole(self_code,Quoted{Decider})), L)` → `…, lambda)`, finishing MP-1 (same one-token fix as M12).
