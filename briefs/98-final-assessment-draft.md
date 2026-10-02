# Brief 98 — WRITER (codex gpt-6-astra xhigh): final assessment DRAFT — mandate deliverables 7 and 8 (bd f7v)

Lane: `docs/assessment.md` (new) ONLY. No Julia. Autonomous; no questions.

The original mandate `handoff.md` (read IN FULL, esp. §Deliverables L263–L274) asks for: (7) a sober assessment of what became clearer and what remains mathematically difficult; (8) a recommended next step toward representing the complete answer-reduction transformation. The north star (`CLAUDE.md`, `HANDOFF.md` top) has since grown to the whole of Compress = Repeat ∘ AnswerReduce ∘ Introspect; one of the paper's authors said such an implementation would help in EXTENDING the construction. Write for that reader (a MIP*=RE author) and for a physicist collaborator.

## Read
`CLAUDE.md`; `HANDOFF.md` (all RESUME sections + "Future directions" + "Findings so far"); `claims/CLAIMS.md` (the ONLY authority on status; rows on HOLD stay HOLD); `docs/findings.md` (F1, F2: discrepancies found against the source); `docs/DESIGN.md` (skim; §§9–13 for Compress); the verdicts that changed the picture (`verdicts/tb2-r8.md`, `tb4-r3.md`, `tb5-r1.md`, `tb6-r4.md`, `tb7-r1.md`, and any `design-*`); `docs/analytic/` part on Compress (§13–§15) for consistency of wording. Ground truth `ground-truth/gt-*.tex` for every mathematical statement — open the lines, cite file:line.

## Write `docs/assessment.md` (plain Markdown, sober English, ≤ ~2500 words), DATED 2026-10-02, headed DRAFT — pending the TB7/TB6 closing round (brief 97)
1. **What was built and at what status** — one table: claim id, one-line content, status exactly as CLAIMS (incl. HOLD notes), evidence pointer. No status stronger than CLAIMS; say what is CITED (soundness theorems) and why.
2. **What became clearer** (deliverable 7a): concrete, each item backed by an artifact or finding — e.g. what representing verifiers as descriptions/terms forced to be explicit; the F1 individual-degree discrepancy and its surviving weaker statement; F2; where the paper's parameters/levels/dimensions were recomputed and agree; conditional linearity of samplers; what the critic rounds repeatedly caught (failure modes of the implementation itself — replay binding, vacuous predicates, zero introspection dispatch at toy scale).
3. **What remains mathematically difficult** (7b): separate (i) genuinely mathematical (soundness/rigidity, parallel-repetition analysis, uniform-in-n runtime bounds), (ii) scale/engineering (toy λ, nothing executes the Pauli predicates at TB7, GF(2^11) sampling bd yqw), (iii) representational (lambda layer sorts, design residue bd ruj R9/R10). Be honest about what the toy fixed point does NOT establish.
4. **Recommended next step(s)** (8): ranked, each with why, what success looks like, and rough size; must serve an author extending the construction (what API or trace they would need that is missing).
5. **Open items** list with bd ids where they exist (f7v, yqw, ruj, n6b, 7jd, fxw).
Every quantitative statement cites its source (CLAIMS row, verdict §, gt file:line, or code file:line). Mark any sentence that depends on brief 97's outcome with `[pending brief 97]`.

Final message ≤ 10 lines: file written, word count, the [pending] sentences count, anything you could not support.
