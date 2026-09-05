# PLAN — `docs/tutorial/compress-explained.html`

Brief 64. Design lead + engineer notes, written before the build.

## 0. Read of the request

Editorial treatment. The client (the north-star user) has asked for something that
"makes 3blue1brown look clumsy" — so: opinionated, one continuous visual world, one
real aesthetic risk. But the subject is an rk-light campaign whose first law is
*never overclaim*, so the boldness is spent on the instruments and the machine-room
scene, never on the wording. Every number on the page is copied out of a repo
artefact; every design-only chapter is stamped **designed, not yet executable**.

## 1. Colour tokens

Six semantic hues, verbatim from `docs/analytic/figstyle.tex`, with the SAME meanings
(FIGURES.md §1). They are role colours, not a series ramp.

| token | light | dark | role (figstyle) |
|---|---|---|---|
| `--machine` | `#1F6F78` teal | `#35A0AB` | Turing side: tapes, states, δ, configurations, machine time |
| `--term`    | `#B5561D` rust | `#D4712F` | lambda side: terms, trees, redexes, closures, fuel |
| `--desc`    | `#5B4B8A` violet | `#8172BE` | descriptions as finite data: ⟨M⟩, ser(t), quoted bytes |
| `--check`   | `#3D7A3A` green | `#57A24E` | what the prototype EXECUTES / CHECKS |
| `--cited`   | `#8A857C` slate | `#9A958C` | CITED analytic theorem — always ALSO dashed |
| `--focus`   | `#F2C14E` amber | `#F2C14E` | the one thing the eye lands on; ≤ 1 per figure |
| `--bad`     | `#B03A2E` red | `#D2604F` | error paths, refusals, FAIL |

Three neutrals (chosen, not inherited — cool slate biased toward the machine hue):

| token | light | dark |
|---|---|---|
| `--bench` (page ground) | `#EFEEEA` | `#0F1618` |
| `--panel` (instrument face) | `#FBF8F2` (figstyle `paper`) | `#162023` |
| `--ink` / `--inkmute` / `--rule` | `#22201C` / `#6B665E` / `#D9D3C7` | `#E7E9E6` / `#9AA3A2` / `#2A3639` |

Dark-first: the bench is a dark slate workbench; figstyle's warm `paper` appears as
*inset sheets* — the panels are literally sheets of the PDF lying on the bench. In
light theme the bench becomes paper and the sheets are separated by hairlines only.

**dataviz validation** (`scripts/validate_palette.js`, run before building):
- 4-series chart subset light `#1F6F78,#B5561D,#5B4B8A,#3D7A3A` — lightness PASS,
  CVD PASS (worst adjacent ΔE 12.2 protan), normal-vision PASS (21.9), contrast PASS;
  chroma FAIL on teal only (0.075 vs 0.100 floor).
- dark subset `#35A0AB,#D4712F,#8172BE,#57A24E` — all PASS except the same teal
  (0.096 vs 0.100).
- Full six-role set FAILs the categorical checks *by design*: `cited` is deliberately
  near-grey (ΔE 14.5 to `check`) and `focus` is deliberately a light fill.
- **Relief taken** (required by the skill): every series is direct-labelled AND
  legended; `cited` additionally carries a dashed border everywhere it appears (the
  figstyle `citedbox` rule), `check` a solid one; `focus` is only ever a fill under
  ink-coloured text, never a stroke or a mark on its own. Teal is never the sole
  distinguisher of two adjacent marks.

## 2. Type

Google Fonts, real fallback stacks.

- display `Fraunces` (optical size, `opsz` axis, `SOFT`/`WONK` off) — chapter theses only.
- body `Source Serif 4` — prose at ~65 characters.
- UI/labels `Source Sans 3` — rail, chips, captions, axis labels, uppercase eyebrows
  at `0.08em` tracking.
- data/code `Inconsolata` — the PDF's own mono; every number column
  `font-variant-numeric: tabular-nums`.

Scale (rem, set once): 0.6875 / 0.75 / 0.8125 / 0.9375 / 1 / 1.25 / 1.5 / 2 / 2.75 / 3.75.

## 3. Layout

A long-scroll **instrument bench**. The sticky left rail is the pipeline itself —
TM → λ → descriptions → CL samplers → low-degree test → PCP → answer reduction →
introspection → repetition → Compress → YΨ → Halting → MIP*=RE — drawn as a vertical
rung ladder (the tracer-bullet ladder is real structure, so the numbering is real:
TB0…TB7), doubling as the progress map. Each rung carries its claim-status chip.

Each chapter: eyebrow (gt label) → one-sentence thesis in Fraunces → **one interactive
instrument** (the hero) → **one video** → the real numbers with their claim/verdict
backing → "what the paper says" with the `gt-NN` line reference.

Aesthetic risk: chapters 14/16 share **one continuous three.js scene** ("the machine
room") that the reader flies through — the compression ladder as four stacked
platforms lit by the semantic colours, with the certificate tree growing beside it.
Degrades to a static painted canvas if WebGL is missing.

Corners 2px, hairline rules, no card-shadow stamping: border/fill/radius spent by
role only. No gradient hero, no emoji, no centred everything.

## 4. Videos (matplotlib → PNG → ffmpeg VP9 WebM, ≤ 800 KB each, data-URI embedded)

1. `eq-machine` — M_= on (1,1), the four time rows of part1a §1.2.
2. `beta-cascade` — YF 3 → 6 unfolding, part1b §3 worked example.
3. `cl-sampler` — 32,768 seeds → axis/diagonal histograms (support 512 / 18,432).
4. `ldt-line` — the degree separator: claimed d=1, actual degree 2, rule `ld_axis_degree`.
5. `zero-cube` — c_0 on the Boolean cube; witness (iii) remainder 2 monomials.
6. `compress-ladder` — 9→5→7→9 and 206→840→848→1696.

## 5. Data provenance

- `scratchpad/tutorial-data/suite59q.log` — the whole-suite printout (906 passed,
  1 failed = the TB0 85.2 s wall-clock budget gate; reported honestly).
- `scratchpad/tutorial-data/mut59.log` — `killed=84/84 baselines ok=43/43`.
- `claims/CLAIMS.md` — statuses verbatim.
- `briefs/23-tb3.last.md`, `briefs/*-r*.last.md` — rung reports.
- Three short read-only Julia probes: the 33 canonical bytes of the trivial decider,
  the equality decider's 64, the GF(8) multiplication table, `describe_cl` bytes
  (75/132/156), and the full `apply` table on all 8^5 seeds for `L_Point`/`L_ALine`/
  `L_DLine` (196,608 bytes, base64-embedded) so the CL instruments run on REAL
  question data rather than a re-implementation.

## 6. What must never appear

Any number not traceable to one of the artefacts above; any status stronger than
`claims/CLAIMS.md`; the words "proves soundness"; a design-only chapter without its
"designed, not yet executable" stamp.
