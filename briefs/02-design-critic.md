# Brief 02 — CRITIC verdict r1 on docs/DESIGN.md and docs/definitions.md

You are the adversarial critic. ATTACK; do not summarize. Work fully autonomously; do not ask questions. Your lane: write `verdicts/design-r1.md` ONLY. Do not edit any other file.

## Read order
1. `~/.claude/skills/rk-light/SKILL.md` (the five laws; you enforce them)
2. `CLAUDE.md`, `handoff.md` (the mandate — every "Representation requirements" and "Deliverables" item is a requirement the design must meet)
3. `claims/CLAIMS.md`
4. `briefs/01-design.md` (what the proposer was asked to do)
5. Ground truth, and you MUST recompute from it, not from memory: `ground-truth/gt-03-prelim.tex` (sec:ld-encoding), `gt-04-cl.tex` (def:cl-func, def:cl-dist, def:cl-canonical, lem:cl-concat), `gt-07-ldt.tex` (sec:ld-game through lem:ld-complexity), `gt-10-answer-reduction.tex` (def:tseitin … thm:ar; especially prop:zero-basis proof, fig:pcpverifier, thm:pcp-decider proof, sec:ld-compiler sampler and fig:decider-pcp), `gt-12-compression.tex` (fig:compress, thm:compression).
6. The target: `docs/DESIGN.md`, `docs/definitions.md`.

## Obligations
- **Fidelity audit.** For every construction element in the design (ind_{m,y}, g_a, dec, zero, the rewrite certificate, F_arith degree claim, c₀ definition and degree, the six-copy sampler, register spaces V_{i,pt}/V_{i,coord}/V_{i,dir}, L_Point/L_ALine/L_DLine, χ(s), π_{i−1}, L^lnf_v, each step of fig:pcpverifier and fig:decider-pcp, the parameter constraints of def:pcpparams), check it against the ground truth line by line. Any deviation must be either flagged as a DESIGN DECISION with the relaxation explicitly named in the design, or is an objection.
- **Recompute** the zero-basis rewrite claim by hand on a 2-variable example (e.g. f = x₁²x₂ + x₁x₂² − 2x₁x₂ over some small field): does the proposed rewrite zᵢ^e → zᵢ^{e−1} − zᵢ^{e−2}·zero(zᵢ) yield c₁, c₂ with f = c₁ zero(x₁) + c₂ zero(x₂) and remainder 0? Check the individual-degree bookkeeping the design claims for cᵢ against prop:zero-basis's proof (d, and the remark "at most d−2").
- **Feasibility audit** of the tracer-bullet ladder: for each rung, recompute the instance parameters (q, m, s, m', does m | q, m' | q, does the paper's constraint (2+5d)m'/q < 1/2 hold for the paper-faithful rung), the monomial-count estimate for c₀, and whether < 60 s is plausible. Attack any rung whose feasibility is asserted without numbers.
- **Quantifier and honesty audit.** Every place the design says "certified", "by construction", "checked": is that literally what the datatype/test would establish? Anything that would let a stub (Introspect, Repeat, LDT soundness, rigidity) look like a proof is MAJOR.
- **Lockstep audit.** DESIGN.md vs definitions.md vs claims/CLAIMS.md: any symbol defined twice or differently, any claim in CLAIMS.md the design cannot make testable, any design claim absent from CLAIMS.md.
- **Handoff coverage.** Table: each handoff requirement/deliverable → where the design addresses it → adequate / inadequate / missing.
- **Elegance audit** (the user's north star). Where is the design more complicated than the mathematics? Where does the "lambda layer" carry real weight vs decoration? Propose the simplification, concretely.
- **Test discipline.** Are the red tests and mutations specific enough that a worker cannot fake green? Any "runs without error" test is an objection.

## Output: `verdicts/design-r1.md`
Numbered objections, each: severity FATAL/MAJOR/MINOR/NOTE · exact location (file + section/DD id) · your independent computation or citation (gt file + label/line) · one-line FIX DEMAND · SURVIVING WEAKER STATEMENT. Then the handoff coverage table. Final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)` where PASS means no FATAL/MAJOR.
