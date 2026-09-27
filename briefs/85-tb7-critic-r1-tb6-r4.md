# Brief 85 — CRITIC: TB7 r1 (Compress, brief 44 + addenda) and TB6 r4 (brief 84 = TB6 repair r3; closing round for C14)

You are the adversarial critic (codex, gpt-6-astra, xhigh). ATTACK; do not summarize. Autonomous; no questions. Lane: write `verdicts/tb7-r1.md` and `verdicts/tb6-r4.md` ONLY; Julia and files only under your scratch dir; never edit repo files; NO git commands that change state. Evaluate the ARCHIVED tree at commit `<SHA>` (`git archive <SHA> | tar -x -C <scratch>/tree`; there `julia --project=. -e 'using Pkg; Pkg.instantiate()'`).

Scratch: `<SCRATCH>/critic-tb7-r1/` (create it). Keep every probe, red test and raw log there and ALSO paste each new red test / mutant definition verbatim (or as a precise diff) into the verdict — scratch does not survive; the verdict must be sufficient to rebuild them.

Environment: 64-core WSL2 machine, Julia 1.12.3. You are the ONLY worker running. Walls are advisory; every gate is a clock-calibrated ratio (`test/calibration.jl`). Report `uptime` before/after each run. `MUTATION_JOBS=4`. Runs one at a time.

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`.
2. `claims/CLAIMS.md` — C15 (TB7 target, CONJECTURE), C14 (TB6 target, row on HOLD), C11–C13 (priors).
3. `docs/DESIGN.md` §§9–13 (esp. §11.4, §12.4–§12.6, §13.1–§13.2); `docs/definitions.md`.
4. TB7: `briefs/44-tb7-compress.md` (+ addenda), `briefs/44-tb7-compress.last.md`, `briefs/44-tb7-compress.certificate.md`; `verdicts/tb6-r2.md` §7 (TB7 obligations).
5. TB6: `verdicts/tb6-r3.md` IN FULL (your prior), `briefs/84-tb6-repair-r3.md`, `briefs/84-tb6-repair-r3.last.md`.
6. Ground truth, recomputed never from memory: `gt-12-compression.tex` (fig:compress, thm:compression, L75–L98, L128–L147, L263–L359); `gt-08-introspection.tex` (L401–L534, L757–L776); `gt-10-answer-reduction.tex` (fig:decider-pcp, L1948–L1965); `gt-11-parallel-repetition.tex` (Repeat/anchoring parameters).
7. Targets: `src/compress/**`, `src/policy/**`, `src/compress.jl`, `src/descriptions/**`, `src/introspect/**`, `test/tb7_compress.jl`, `test/tb6b_introspect.jl`, `test/mutations/**`.

## Obligations — common
- **Run** `julia --project=. test/runtests.jl` (paste summary + every gate line) and `MUTATION_JOBS=4 julia --project=. test/mutations/run.jl` (paste the `MUTATION REGISTRY` line and every non-KILLED disposition).

## Obligations — TB6 r4 (`verdicts/tb6-r4.md`, short)
- R1–R5 discharge table (DISCHARGED / PARTIAL / NOT, with evidence).
- R1: try again to make the intro decider ACCEPT a malformed non-Pauli answer on ANY edge or self-loop of `G^intro`, typed and detyped (schema wrong, length right; out-of-V at any coordinate; equal malformed answers). Is validation one site before dispatch? Did any honest pin move, and if so is the new value derived?
- R2: is the whole tail `s+1..Q` red-capable for every vector slot in the answer key? Write your own weakened `_in_V` variants (e.g. checks only odd tail coordinates; checks all but coordinate Q) and report survivors.
- R3: attack the new kill rule. Construct (a) an error-only mutant inside a `@testset`, (b) a crash outside, (c) a mutant whose run has BOTH an unrelated error and no failed assertion on the owned property, (d) a mutant that makes the test print the literal text `Test Failed` without any assertion failing. Any credited non-assertion kill is MAJOR. Verify the four converted owners now fail by assertion, and that the conversion did not weaken the unmutated assertions.
- C14: authorize the complete replacement row VERBATIM (one line; it must state D1(d)'s test-only scope, the owned TB6 mutant count as YOU count it, and keep any limitation that is still true), or HOLD naming the missing step.

## Obligations — TB7 r1 (`verdicts/tb7-r1.md`)
- **Independent recomputation** (your own code or by hand, from the ground truth and DESIGN formulas, not the package): level chain 9→5→7→9; dimensions 206→624→840→848→1696 including each displayed dimension law; `|Type^ar|`=54, 2916 edges; the certificate census (317 nodes; CONSTRUCTED 34 / CHECKED 133 / CITED 70 / ASSUMED 62 / SOURCE_REPAIR 18) by walking the certificate yourself; the CITED label set == DESIGN §13.2 and every CITED label exists in `ground-truth/`; `sigma_1`=67648; the nested metering `by_depth=[22618,129]` (derive the 129).
- **Composition honesty.** Is the executed object really `Repeat ∘ AnswerReduce ∘ Introspect` applied to DESCRIPTIONS (bytes in, bytes out), with each stage consuming the previous stage's actual output — or are fixtures substituted between stages? Trace one question end to end. Identify every stub, constant or fixture on the executed path and whether the predicate report owns it.
- **Predicate report.** For each of the 13 rows: is the printed status computed by code that can produce the other statuses (red-capable), and is each FAIL/VACUOUS/NOT_EVALUABLE/NOT_EXECUTED honest (neither hiding a pass nor a worse failure)? In particular `P_pcp_encodes_D1 = FAIL(owner=pcpverifier-D1-trace)`: verify the claimed front-end run on the actual D1 (m=3, 10 3SAT / 38 decoupled clauses).
- **Fixed point.** Is `D_{M,λ} = Y Ψ_{M,λ}` a quoted, description-level self-reference (the term receives its own CODE), or a host-language closure? What exactly do the "5/5" checks establish? What does one finite unfold NOT establish?
- **Certificate honesty**: every CHECKED node replays code that can fail (tamper with facts and replay); no node stronger than its children; ASSUMED leaves name their assumption.
- **Deviations** in the report (§DEVIATIONS): rule on each — acceptable scoped limitation, or a defect that blocks TESTED.
- **At least three NEW semantic mutations** on copies aimed at TB7's surface (e.g. swap the composition order with levels patched to still read 9→5→7→9; feed Repeat the pre-detype sampler; make the fixed point unfold use a fresh copy of Ψ's closure instead of its code; drop the anchor's +8; report a stale hash). Survivors are MAJOR with the red test as FIX DEMAND.
- **Lockstep**: DESIGN ↔ code ↔ CLAIMS ↔ report ↔ HANDOFF numbers.
- **C15**: authorize a complete TESTED row VERBATIM (one line, honestly scoped: ToyPolicy only, what is not executed, what is UNCHARGED) or HOLD naming every missing step.
- **Elegance**: the three places where code is more complicated than the mathematics, with a concrete simplification each; and one paragraph on what an author of the paper extending the construction would need from this API that is missing.

## Output
Each verdict: numbered objections (severity FATAL/MAJOR/MINOR/NOTE · exact location · your independent computation · one-line FIX DEMAND · SURVIVING WEAKER STATEMENT); discharge tables; runs + load; your mutations and outcomes (definitions included); per-claim decisions with verbatim authorized rows; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`. Your final assistant message (captured to `briefs/85-tb7-critic-r1-tb6-r4.last.md`) is ≤ 12 lines: both verdict lines, run summary lines, list of authorized rows.
