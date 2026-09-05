# Brief 64 — the tutorial artifact: report (Opus, 2026-09-05; no git)

**Deliverable** `docs/tutorial/compress-explained.html` — **1,950,316 B = 1.86 MB** (limit 12 MB), self-contained: no `<!DOCTYPE>/<html>/<head>/<body>`, first line `<title>Compress, Explained</title>`; the only external refs are `cdnjs.cloudflare.com/.../three.js/r128/three.min.js` and `fonts.googleapis.com` + `fonts.gstatic.com`; 0 fetch/XHR/WebSocket. Three-state theme tokens (bare `:root` light, `@media` dark guarded `:root:not([data-theme="light"])`, `:root[data-theme="dark"]`), explicit token `body` background, `prefers-reduced-motion` honoured, visible focus rings, wide content in `overflow-x` scrollers. Build: `docs/tutorial/build/{PLAN.md,FACTS.md,frames.py,encode.sh,build.py,part-*.html,data/,video/}`. Palette = `figstyle.tex`'s six roles with the same meanings; type = Fraunces / Source Serif 4 / Source Sans 3 / Inconsolata; layout = the instrument bench with the sticky pipeline-ladder rail. Validated: tags balanced (355 div, 17 section, 22 svg, 12 table…), `node --check` clean, dataviz palette validator run (see PLAN §1 for the two documented near-misses and the relief taken).

| § | chapter | instrument | data source | backing |
|---|---|---|---|---|
| 0 | The shape of the thing | fig:compress SVG, executed-vs-cited colouring | gt-12 fig:compress | 906/907, 84/84, 3 open lanes |
| 1 | Turing machines | live M₌ tape simulator, step/run/scrub, configurations (q,(L,s,R)) | part1a §1.2, five rows verbatim | expository |
| 2 | Lambda terms & quotation | de Bruijn β-reducer (3 terms) + the **real 33 bytes**, field-labelled | probe.jl; programs.jl codec | C18 SKETCH |
| 3 | Fuel & the CEK machine | fuel meter (Value / OutOfFuel / SortError) + the charge table | probe.jl measurements; PRIMITIVES | C16 SKETCH |
| 4 | Descriptions, not closures | the four-query sampler API, clickable | tb1 suite printout | C4a TESTED |
| 5 | CL samplers | three.js F₈² scene over **all 32,768 real questions** + both exact histograms | `data/cl_table.b64` (extract.jl) | C4a TESTED |
| 6 | The low-degree test | degree slider + bend-an-entry on the real g = 1+x₁+x₁x₂ | tb1 sweep; verdicts/tb1-r4 §1.6 | **C4c HELD — no claim row** |
| 7 | Tseitin & arithmetization | the real six-gate circuit; click a wire for occ = 2+2·fanout | circuits.jl; suite occurrence vector | C8 TESTED (soft F1 framing) |
| 8 | The zero basis | three witnesses × the 65,536-point cube + the identity | tb0 suite | C2, C1 TESTED |
| 9 | The PCP verifier | five-step walk of fig:pcpverifier, both fields | tb0 suite (β₀ 2 / 96, 1 / 48) | C1 TESTED |
| 10 | Answer reduction | **the real 54×54 guard map**, 2,916 cells, filterable, hoverable | `data/tb2-guard-map.txt` (guards.jl) | C9, C4b TESTED |
| 11 | The quoted front end | the pipeline on both deciders incl. `ExpansionRefused(279,936>160,000)` | tb3 suite; briefs/23-tb3.last.md | **no claim row; tb3-r1 FAIL(N1,N2,N3)** |
| 12 | Introspection | Pauli/EPR figure + the counted type graph + the fuel gate | DESIGN §11 | C14 CONJECTURE — *designed, not yet executable* |
| 13 | Anchoring & repetition | 81-fold direct sum, corrupt-one-component | DESIGN §10.3 | C13 CONJECTURE — *designed, not yet executable* |
| 14 | Compress, YΨ, Halting | **the machine room** (three.js flythrough: ladder + certificate tree) + the fail-visible predicate report | DESIGN §12 | C15 CONJECTURE — *designed, not yet executable* |
| 15 | How the claims were earned | 8 objection-trajectory small multiples + the live claims ratchet | 25 verdict files; mut59.log | statuses verbatim |
| 16 | The certificate tree | both real printed trees, node-clickable to grade + authority | suite59q.log | grades CHECKED/CITED/ASSUMED |

**Videos** (matplotlib → ffmpeg VP9 `-b:v 0 -crf 34`, 800×450 @ 25 fps, data-URI embedded with JPEG posters; all ≤ 800 KB): `eq-machine` 33.6 KB / 6.7 s · `beta-cascade` 74.0 KB / 8.4 s · `cl-sampler` 187.2 KB / 8.6 s · `ldt-line` 58.6 KB / 8.4 s · `zero-cube` 523.1 KB / 8.0 s · `compress-ladder` 64.1 KB / 8.6 s. **WebM total 940.6 KB**, posters 161.7 KB.

**Two extracted datasets, both cross-checked against the suite's own printout.** `cl_table.b64` = `apply(L,z)` for all 8⁵ seeds × 3 maps (196,608 B) — reproduces support 512 (mass 64), 18,432 (masses 1, 8) and zero-direction 512 / mass 2,304 exactly. `tb2-guard-map.txt` = `answer_reduce_guard_branches` on all 2,916 ordered pairs — reproduces `guard_split (2736, 180, 107, 92, 54, 53)` exactly. Julia use was three short read-only prints (`probe.jl`, `extract.jl`, `guards.jl`); the suite was never run.

**Not grounded in a real object, and therefore labelled or left out.**
1. **C4c does not exist** — `verdicts/tb1-r4.md` HOLDs it; §6 carries a red bar saying so and presents the 71,360 / 40,768 / 0 numbers as suite printout, not as a claim.
2. **TB3 has no claim row** — C10 is a merge *proposal* and `tb3-r1` is FAIL(N1,N2,N3); §11 says so in a red bar.
3. **TB5/TB6/TB7 do not exist as code.** §§12–14 are DESIGN.md transcription only, each stamped *designed, not yet executable*; the Pauli/EPR drawing is a schematic of the protocol, not of computed data, and the numeric Pauli parameters are omitted because `a, b` are symbols (NOT_EVALUABLE).
4. **Witness (iii) has no per-point cube data** — only witness (i)'s 65,536 vanishing points were computed, so §8 shows the algebraic facts (|c₀| = 18,620, |r| = 2, identity false) instead of a pixel map for (iii).
5. **The `ldt-line` clip's polynomial is illustrative** (rendered before `g = 1+x₁+x₁x₂` was found in the held C4c text); the clip states this on screen, and the *interactive* instrument uses the real g. The separator point, degrees and both rule names are the suite's throughout.
6. **The certificate tree in the three.js scene is structural** — node names and grades are real, the geometry is not data.
7. **The one suite failure is reported, not hidden**: 906/907, the failure being the TB0 body at 85.199 s against a 60 s wall-clock gate.

**Look-once**: no Chromium; one full-page Firefox headless render (38,839 px tall) reviewed, then one fix pass — the tape head markers (blown up by the global `svg{height:auto}` rule) rebuilt as CSS triangles, the F1 panel given two columns, and both three.js scenes given an always-painted 2D layer underneath plus a `readPixels` probe that keeps it visible if the WebGL context never paints. Headless Firefox does not composite WebGL into screenshots, so the scenes themselves are unverified by picture; the 2D layer is the guaranteed floor.
