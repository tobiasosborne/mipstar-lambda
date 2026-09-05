# FIGURES.md — visual system and figure plan for the analytic document

Mandate (user, 2026-09-04): **at least one excellent figure on every page** of
`analytic-underpinnings.pdf`. Turing machines, lambda terms, descriptions,
traces, the fixed point, the Cook–Levin tableau, the PCP and the CL layer are
all *drawn*, not merely described. Figures are built from the document's own
objects (the equality machine M_=, the three-step trace, Ψ_{M,λ}, the toy
dimensions), never generic clip-art.

## 1. Visual system (single source: `figstyle.tex`)

Five semantic colours, used consistently across all 60+ figures so a reader
learns them once:

| role | colour | meaning |
|---|---|---|
| `machine` | teal | Turing side: tapes, states, δ, configurations, machine time |
| `term` | rust | lambda side: terms, trees, redexes, closures, fuel |
| `desc` | violet | descriptions as finite data: ⟨M⟩, ser(t), quoted code, bytes |
| `check` | green | what the prototype EXECUTES / CHECKS |
| `cited` | slate, dashed border | what remains a CITED analytic theorem |
| `focus` | amber | the one thing the eye must land on: scanned cell, current redex, the hole |
| `bad` | red | error paths: TypeError, capture, the wrong reduction |

Rules:
1. **One idea per figure.** If a figure needs a paragraph to explain, split it.
2. **Draw the real object.** M_= has exactly the five rows in §1.2; the trace has
   exactly 4 time rows × 4 tapes; Ψ_{M,λ} has exactly the constructors of (10.4).
   Numbers in figures are the document's numbers (fuel constants c_Y=3,
   h(d,u)=3+|d|+|enc(u)|, exponent 8, level chain 9→5→7→9, dims 206→840→848→1696).
3. **Before/after and side-by-side** are the two workhorse layouts: a machine
   step, a beta step, Y vs Z, TM vs λ, normal order vs call-by-value, executed vs cited.
4. **Sans-serif labels** (`lbl`/`lblsm`), maths in the text font. No emoji, no
   dingbats, no clip-art icons; draw glyphs with TikZ paths.
5. **Tapes** are rows of `cell` nodes, head marked with `cell head` fill plus a
   `head` triangle below; blanks are `⊔` in `cell blank`. Time runs downward.
6. **Lambda terms** are trees (`tnode`/`tleaf`, `tedge`), binders point to their
   variables with `bind` arcs, the redex is `redex`, a beta step is a `beta` arrow
   between two trees.
7. **Descriptions** are `descbox` or a `bytes` strip (`0 1 1 0 …` with
   `byteslbl` field labels under prefix-free fields). Quotation is a `quote`
   (wavy violet) arrow from a term/machine to its bytes.
8. **Pipeline / transformation** figures use `stage` boxes and `xform` arrows with
   bold `xformlbl` labels; green `checked` and slate dashed `citedbox` mark the
   evidence boundary — every figure that touches soundness MUST show it.
9. **Captions**: one sentence on what to see, one on why it matters for the
   argument. Never "Figure shows". Use `\chip{machine}` etc. when a legend is needed.
9b. **Styles live only in `figstyle.tex`.** No figure file defines a `\tikzset`. Promoted
    in brief 37: `copyflow` (rust wavy "copy/substitute this subterm", distinct from the
    violet `quote` reserved for object→bytes), `inlineredex` (tight amber box for a
    highlighted subterm *inside* a maths node, where the circular `redex` balloons), and
    `tag machine` / `tag desc` / `tag bad` beside `tag check` / `tag cited` / `tag focus`.
10. **Width**: full text width for hero figures (`[t]` or `[h]`), `0.6\linewidth`
    wrapped figures are NOT used (no wrapfig) — keep placement predictable.
11. Each figure lives in `figs/fig-<slug>.tex` (the `tikzpicture` only) and is
    `\input` inside a `figure` environment in the part file, placed at the first
    paragraph that discusses the object, with `\label{fig:<slug>}` and a
    `Figure~\ref{fig:<slug>}` mention in the prose.
12. **Fidelity**: any figure depicting a paper construction (fig:compress,
    fig:decider-pcp, def:sampler, sec:pauli, Tseitin) must be checked against the
    ground-truth TeX in `ground-truth/gt-*.tex`, and its caption carries the label
    (e.g. "after fig:compress"). Keep the F1 framing soft: "as we read the
    gadget", never "error in the paper".

## 2. Coverage gate

    pdflatex ×2; python3 tools/figcoverage.py --from A --to B

must report **no page without a figure** in the lane's page range. Figures add
pages; re-run after every batch. Overfull hboxes in figure files: zero.

## 3. Figure plan (by lane; ~75 figures; hero figures marked ★)

### Lane A — front matter + Part I §1–3 (`parts/part1a.tex`)
- F0 ★ (after abstract, p.1) `pipeline-glance`: ⟨V⟩ →Introspect→ ⟨V¹⟩ →AnswerReduce→ ⟨V²⟩ →Repeat→ ⟨V³⟩ = Compress(⟨V⟩,λ), with the fixed-point loop (the Halting verifier feeds its own decider code back in). Stages coloured by what is executed (`checked`) vs cited (`citedbox`).
- F0b (TOC page) `roadmap`: reading map of Parts I/II as a dependency graph of sections (§1–6 → §7–15), arrows "refresher → resource-accounted version".
- F1 ★ `tm-anatomy`: multitape machine — k read-only input tapes, work tape, output tape, finite control with δ; heads; (Q,Σ,Γ,δ,q₀,q_h) labelled.
- F2 `one-step`: before/after configuration for δ(q,0)=(q′,1,R): only state, scanned cell, head change (highlight the three changes).
- F3 `config-path`: the unique path C₀⊢C₁⊢C₂⊢… as a chain; branch to q_h (halt, Time_{M,x}=T) versus a path fading into the horizon (“has not halted yet” ≠ “never halts”).
- F4 ★ `eq-machine-states`: M_= as a state diagram (q₀,q₁,q_h) with the five rows as labelled edges (equal-input, unequal-input, copy, halt, catch-all).
- F5 ★ `eq-machine-trace`: the 3-step trace for A=B=1 as four tape strips × four time rows, head cells amber, rule used at right. Time_{M_=,(1,1)}=3.
- F6 `verifier-normal-form`: V=(S,D): sampler S emits questions x,y to two provers, answers a,b return, decider D(n,x,y,a,b) with five input tapes outputs one bit.
- F7 `description-bits`: ⟨M_=⟩ as a prefix-free byte strip: fields for Q, Γ, the five δ rows; “Hamiltonian, not spectrum”.
- F8 `timeout-wrapper`: code box “run this code, but reject after 3 steps” wrapping the ⟨M_=⟩ box; a compiler produces new finite code without deciding behaviour.
- F9 ★ `universal-machine`: U_k with read-only code region ⟨M⟩, encoded simulated configuration, lookup loop; the overhead polynomial C_U(k|⟨M⟩||x|T)^{c_U} as a callout.
- F10 `smn`: program with r+k slots → hardwire first r → wrapper with literal copy of e,z₁..z_r; live inputs x₁..x_k enter at run time.
- F11 ★ `diagonal`: the H(z,z) table with the diagonal highlighted; D flips the diagonal bit; both cases contradict.
- F12 `semidecision`: stages t=0,1,2,… along a timeline; a halting witness at stage T vs a search that never returns (RE side).
- F13 ★ `kleene-square`: the proof of Thm 3.1 as a diagram: p → s(p,p)=e_Q; e_Q runs as p(p,x) → Q(s(p,p)) → universal simulation; the four displayed equalities as a commuting chain.
- F14 `quine`: Q(z) = “print z”; e_Q prints e_Q.
- F15 ★ `halt-f-construction`: the eight-input F(f,m,λ,n,x,y,a,b): hardwire (f,m,λ) → d; pair with sampler; Compress; run returned decider on (n,x,y,a,b); the arrow from d back into the verifier fed to Compress.

### Lane B — Part I §4–6 (`parts/part1b.tex`)
- F16 ★ `term-tree-scope`: λx.(x y) as a tree; bound x with `bind` arc to its λ; free y marked.
- F17 ★ `beta-tree-surgery`: (λx.t) u → t[x:=u] as tree surgery, redex amber.
- F18 `capture`: (λx.λy.x) y — the wrong substitution (red, y captured) vs alpha-rename then reduce (correct).
- F19 `normal-vs-cbv`: K I Ω — normal order reaches I in one step; call-by-value loops on Ω (Ω→Ω cycle drawn as a loop).
- F20 `confluence`: Church–Rosser diamond.
- F21 `church-bool-if`: true/false as two-slot selectors; if b t e collapsing to the selected branch.
- F22 `church-pair`: pair a b p = p a b; fst/snd as selectors.
- F23 `church-numeral`: n̄ = λf.λx.fⁿx as an iteration tower; succ wraps one more f.
- F24 ★ `pred-ladder`: ⟨0,0⟩→⟨0,1⟩→⟨1,2⟩→⟨2,3⟩→fst=2.
- F25 `list-fold`: [A,B] C Z ⇝ C A (C B Z) as a right-leaning spine.
- F26 ★ `y-derivation`: f = F f with a hole; h h = F(h h); h = λx.F(x x); Y F → F(Y F) → F(F(Y F)) as a growing tree, no recursive name in Y.
- F27 `factorial-unfold`: Y F 3̄ unfolding under normal order: 3·(YF 2) → 3·2·(YF 1) → … = 6, one unfolding per level.
- F28 ★ `y-vs-z-cbv`: side by side: Y F under call-by-value expands forever; Z’s η-delay λu.xxu keeps the recursion “under a lambda” until an argument arrives.
- F29 ★ `de-bruijn`: λx.λy.x y vs λ.λ.(1 0); binder-distance counts; environment frames [B],[A]; index 0 → B, index 1 → A.
- F30 ★ `quotation`: tree Lambda(BoundVar(0)) → wavy quote arrow → canonical bytes; evaluating the bytes on A returns A; copying returns code.
- F31 ★ `tm-to-lambda-zipper`: a tape as a zipper (L, s, R) with the head at s; right move re-threads one cell; the loop reading the hardwired table.
- F32 `lambda-to-tm-layout`: the evaluator’s work tape: parsed syntax tree | environment | continuation stack | fuel counter, each region as a tape segment.
- F33 ★ `dictionary-bridge`: the seven-row dictionary of §5 as a two-bank bridge (machine bank teal, lambda bank rust) with a labelled span for each row.
- F34 `pipeline-stages`: the three arrows of §6 with one-line glosses (embed a description / bounded-trace circuit → PCP verifier / coordinated copies).
- F35 ★ `two-layers`: concentric: outer ring = computability with polynomial bookkeeping (executed, green), inner disc = quantum analytic theorems (cited, slate): LDT soundness, rigidity, oracularization, entanglement bounds.

### Lane C — Part II §7–10 (`parts/part2a.tex`)
- F36 `dual-rail`: the paper’s tuple encoding on a tape (dual-rail bits, separators) for (n,x,y,a,b).
- F37 ★ `sampler-four-queries`: the CL sampler as a machine with a mode input answering dimension / marginal / linear / factor (def:sampler), each query as an arrow with its answer type.
- F38 `lambda-bounded`: what ⟨V⟩=(⟨S⟩,⟨D⟩) means: size ≤ λ box, time ≤ n^λ ruler, threshold n ≥ C₀.
- F39 `source-obligations`: the universal and source-level obligations of §7.3 as a checklist of arrows from ⟨V⟩ (scan, measure, hardwire, simulate).
- F40 ★ `l-grammar-gallery`: the ten constructors of (8.1) each as a small tree with its sort; holes drawn as typed sockets; affine-hole discipline (each hole once).
- F41 ★ `serialization`: ν(m)=1^ℓ0b prefix-free layout; a term node → 4-bit tag | ν-fields | child count | children, as a byte strip.
- F42 `representations`: closure vs quoted syntax vs circuit vs universal evaluator vs specialization, with their legitimate consumers (the §8.1 table as a diagram).
- F43 ★ `cek-config`: ⟨q,η,K,H,f⟩ drawn as five registers; one transition of (8.2) with charge k and fuel f → f−k; the Apply rule shown pushing a frame.
- F44 `trichotomy`: Value(v) / OutOfFuel / TypeError as the three leaves of the run tree.
- F45 ★ `fuel-monotonicity`: two runs side by side, same trajectory, fuel curves offset by g; the terminating run at c ≤ f.
- F46 `eval-delimiter`: nested inner/ambient budgets; each inner microstep decrements both.
- F47 ★ `quote-eval`: left machine decodes bytes (cost h(d,u)=3+|d|+|enc(u)|) then the two trajectories coincide.
- F48 ★ `specialize`: prefix traversal replacing Hole(h,A) by σ(h) (closed subtree); size |P| − |Hole| + |σ(h)|.
- F49 ★ `loop-term`: the term (9.1) loop_m = Fix(λC. If(halt C, out C, self(move(C, TMDelta(m, view C))))) as a tree, TMDelta charge ≤ 8(|m|+k+2).
- F50 ★ `simulation-ladder`: machine configuration after i steps ↔ functional configuration (commuting ladder), views agree, one iteration ≤ c₀(|M|+k+1) units.
- F51 `u-l-heap`: U_L work-tape heap: node records, environment frames, continuation records, binary fuel; lazy input handles reading at most f symbols.
- F52 ★ `resource-dictionary`: the quantitative bridge: Time_D(n) ≤ C_L(|D_L|+f_D(n)+1)^8 one way, fuel c_D T(T+|u|) the other; sizes linear both ways.
- F53 `lambda-preservation`: λ → Aλ both directions, with the two exponent computations 3+⌈log₂72c₀⌉ and 8+⌈log₂C_L3⁸⌉.
- F54 `smn-sizes`: Lemma 10.1 wrapper with its size bound.
- F55 ★ `kleene-sizes`: Kleene with size accounting: |e_Q| in terms of |p|.
- F56 ★ `ycode-link`: runtime: a constant-size heap link self_code ↦ Code(Fix P) (c_Y=3) versus the materialised unfold Specialize(P,{self_code↦d_P}) as a big tree.
- F57 ★ `psi-ml`: Ψ_{M,λ} of (10.4) as a term tree: If(halts_within(M,n), true, Eval(ans(Eval(Quote(Compress), (quoted_pair(Quote(S_L), Hole(self_code)), L), F_C)), (n,x,y,a,b), FuelBound(n,L))); the hole amber; D_{M,L}=YCode(Ψ).
- F58 ★ `three-presentations`: triangle: paper’s F(F̄,M̄,L,…) — Kleene fixed point — D_{M,L}; all edges “same partial function, sizes O(|M|+log L+1)”.

### Lane D — Part II §11–15 (`parts/part2b.tex`)
- F59 ★ `trace-tableau`: rows C₀..C_F × cells; the radius-one window (j−1,j,j+1) of row i determining cell j of row i+1 (Lemma 11.1); head marker pairing; padding rows.
- F60 `succinct-circuit`: index bits (i,j) → the clause for window (i,j); size bound (11.1).
- F61 ★ `decoupled-5sat`: five blocks a,b,u₃,u₄,u₅ of one power-of-two length; original 3SAT clauses on u₃; equality gadgets u₃=u₄=u₅; copy of the first 2F answer bits to a,b; padding.
- F62 ★ `tseitin-fanout`: a gate wire with fan-out f and the auxiliary variable; individual degree 2+2f as we read the gadget (soft framing, F1), versus 2; “theorem survives with deg_F+5d, d ≥ 8”.
- F63 `occurrence-vector`: the discrepancy of §11.5 as two side-by-side tallies.
- F63b ★ `occurrence-vs-degree` (added, brief 37): the F1 finding drawn on the two-gate
  fixture — the amber wire `w_1`, its four literal occurrences as a ledger, and the three
  accounts of `deg_{w_1}` side by side (source proposition ≤ 2, occurrence bound = 4,
  `arith_q` sparse support = 4). Soft framing: "our reading of the gadget may be at fault",
  citing `docs/findings.md` F1.
- F64 ★ `interpolation-subcube`: the subcube {0,1}^m inside F_q^m; interpolation of a Boolean function; the vanishing polynomial zero(z)=z(z−1) on the axis.
- F65 `boolean-ideal-rewrite`: z^e → z^{e−1} − z^{e−2}·zero(z); a 2-variable example reduced to remainder 0 with c₁ zero(x₁) + c₂ zero(x₂).
- F66 ★ `pcp-local-verifier`: proof oracle as a table of point/line evaluations; the local verifier’s queries (points, axis-parallel line, diagonal line) landing in it; the accept predicate.
- F67 ★ `four-layers`: the four soundness layers of §12.4 as strata: (1) algebraic soundness under low degree — EXECUTED identity; (2) low-degree enforcement — CITED; (3) Schwartz–Zippel — CHECKED at finite instance; (4) quantum consistency and rigidity — CITED. Evidence boundary drawn explicitly.
- F68 ★ `cl-inductive`: a conditionally linear function as levels: V = V₁ ⊕ V₂ ⊕ …, the linear map on level i conditioned on the output of levels < i (def:cl-func); level laws.
- F68b `chi-axis-buckets` (added, brief 37): the fixed integer representatives of F_q split
  into m equal buckets for (q,m)=(8,2); the sampled s=5 picks bucket 2, so χ(s)=2 and the
  axis-line map's direction is e_2 — hence the two CL stages that make L_ALine level two.
- F69 `point-line-maps`: L_Point, L_ALine, L_DLine as register maps on V_pt/V_coord/V_dir (gt-07), projections π_{i−1}.
- F70 ★ `six-copy-sampler`: types and the six-copy sampler: the type set, which copies are compared, marginal laws.
- F70b ★ `D-decider-guards` (added, brief 37): the five guarded checks of `fig:decider-pcp`
  in order (global consistency, input consistency, input low degree, proof encoding, game
  check), each dropping out downwards into one rejection bar, with the amber fall-through
  showing that a type pair firing no trigger is accepted.
- F71 `structural-hypothesis`: the C7 hypothesis as a diagram of what is assumed versus derived.
- F72 ★ `ladder`: the tracer-bullet ladder TB0 → TB0.5 → TB1 → TB2 → TB3 → TB4 → TB5 → TB6 → TB7 as rungs with status chips (PROVED/TESTED/SKETCH/CONJECTURE from claims/CLAIMS.md at the time of writing, cite the file) and what each rung executes.
- F73 `correspondence-map`: each correspondence table (§14.1–14.6) gets a compact figure: the paper object → the Julia object → the evidence grade (`checked`/`citedbox`). At least one figure per page of §14 (the longtables are long; interleave).
- F74 ★ `evidence-boundary`: EXECUTED / CHECKED / CITED as a horizontal boundary through the whole pipeline of F0, every stage placed on the correct side.
- F75 `midpoint-diagnostic`: the midpoint toy (C6/N1): what it measured, as a small pgfplots histogram or bar chart if the numbers are in the text; otherwise a diagram.
- F76 ★ `final-accounting`: closing figure: the fixed point D_{M,L} = YCode(Ψ_{M,λ}) drawn once more with the three cited leaves (LDT soundness, rigidity, gap-preserving compression) marked slate.

Lanes may add figures beyond the plan; they may not drop a ★ figure. If a
plan item does not match the text (the text has no such object), replace it
with a figure of what the text actually has and say so in the report.

### Added in brief 47 (repair round 1)

Nine figures were added, all outside the original plan; no ★ item was dropped.

- `symbol-table` (front matter, before the TOC) — S5: the nine quantities that travel through both parts, with where each is fixed.
- `parameter-card` (§7.1) — S2: the eight universal constants of `Compress` (λ, 9, μ, γ, τ, k(n), ε₁/ε₂, C₀) with their ground-truth labels.
- `ar-invokes-pcp` (§7.3) — m12: which of `fig:decider-pcp` and `fig:pcpverifier` owns Step 1.
- `three-provenances` (§8 head) — M7: every named Part II result sorted into cited / derived-here-unverified / executed-and-ratcheted.
- `grades` (§8.2) — M11: the five `CertNode` grades and what each obliges its author to supply.
- `certificate-tree` (§8.2) — M11: the real `AnswerReduce` certificate tree of `test/tb2_answer_reduce.jl`.
- `exponent-ladder` (§9.2) — M6: the five-step cost ladder ending at the one-tape conversion that squares the bound.
- `miniature` (§11.3) — S1: one `Apply` microstep carried through window → clause index → five blocks.
- `tb7-card` (§14.7) — M5: the TB7 toy instantiation, its level/dimension chains, and its printed predicate report.

Redrawn: `decoupled-5sat` (M2, m18), `four-layers` (M8, moved to the head of §12 per S3), `ladder` (M4, m17), `correspondence-map` (m15), `D-threshold-margin` (m3), `three-presentations`, `psi-ml`, `halt-f-construction`, `C-closed-verifier` (M1), `y-derivation` (m16, m9), `roadmap` (m5), `D-correspondence-description` (m14), `D-correspondence-typed`, `D-correspondence-midpoint`, `tseitin-fanout`, `succinct-circuit`, `trace-tableau` (m6, m20).
