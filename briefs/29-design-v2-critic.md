# Brief 29 — CRITIC verdict r1 on DESIGN v2 (docs/DESIGN.md §9–13: SamplerDescription API, TB5 Repeat, TB6 Introspect, TB7 end-to-end)

You are the adversarial critic. ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/design-v2-r1.md` ONLY. You may create files ONLY under the scratch dir below; never edit repo files. Evaluate the ARCHIVED tree at commit a403c9b (`git archive a403c9b | tar -x -C <scratch>/tree`), because other workers edit the live tree.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/03b2c3d3-f2b5-4e3b-8e73-afff562cb7ae/scratchpad/critic-design-v2-r1/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md` (the five laws; you enforce them)
2. `CLAUDE.md`, `HANDOFF.md`, `handoff.md` (the mandate; north star = COMPLETE executable Compress incl. Introspect and Repeat as built rungs)
3. `claims/CLAIMS.md`; `verdicts/design-r4.md` (the converged verdict on §1–8 — treat as prior; do not re-litigate §1–8)
4. `briefs/28-design-v2-full-compress.md` (what the proposer was asked) and `briefs/28-design-v2-full-compress.last.md` (the proposer's report, incl. proposed claims C12–C15 and MERGE PROPOSALS)
5. Ground truth — you MUST recompute from it, never from memory: `ground-truth/gt-04-cl.tex` (def:sampler: the four queries dimension/marginal/linear/factor; def:cl-func, def:cl-dist), `gt-07-ldt.tex` (sec:pauli — Pauli basis test, its types and predicate), `gt-08-introspection.tex` (the introspective verifier, question-length reduction, level bookkeeping), `gt-11-parallel-repetition.tex` (sec:anchoring, sec:parrep; thm:repetition contract, level ℓ+2), `gt-12-compression.tex` (fig:compress, thm:compression: level chain and the universal constants), `gt-10-answer-reduction.tex` (for the AR interface the introspected verifier must feed).
6. The target: `docs/DESIGN.md` §9–13 and the updated rows of `docs/definitions.md`.

## Obligations
- **Fidelity audit, line by line.** Every construction element in §9–13 (the four sampler queries and their contracts; downsize/detype/anchor/repeat/product laws in §9.4–9.6; anchoring transcription §10.1 and repetition transcription §10.2 incl. `k(n)` and the length guard; the 26 Pauli types and predicate §11.1–11.2; the introspection sampler and decider §11.3–11.4 and the "5-level dimension law"; the stabilizer transcript simulation §11.5; the production composition and universal constants §12.1; the `9→5→7→9` level chain and the `206→840→848→1696` toy dimensions §12.2–12.5; the `D_{M,L} = Y Psi_{M,L}` unfold §12.6) must be checked against the cited ground-truth label. Any deviation is either a named DESIGN DECISION / SOURCE_REPAIR or an objection.
- **Recompute** independently: (a) the level chain 9→5→7→9 from thm:compression and the three contract theorems; (b) the toy dimensions 206→840→848→1696 from the design's own parameter table — show your arithmetic; (c) the count 26 of Pauli types against sec:pauli; (d) the `≥3Q` introspection boundary the proposer retained as a visible repair — is it literally in the source?
- **Quantifier and honesty audit.** Every place §9–13 says "checked", "certificate", "exact", "executable": is that literally what the proposed datatype/test would establish? Anything that would let Introspect/Repeat soundness (a CITED theorem) look PROVED by execution is MAJOR. Check §13.2's list of the cited residue for completeness.
- **Toy-boundary audit (§12.4).** The proposer says some production predicates "visibly FAIL" in the toy regime. Is every such failure surfaced as a CHECKED node that reports FAIL rather than silently skipped? A predicate that is bypassed in toy mode without a visible marker is MAJOR.
- **Lockstep audit.** DESIGN §9–13 vs definitions.md vs CLAIMS.md vs the proposer's C12–C15 proposals: symbols defined twice or differently; claims the design cannot make testable; design claims absent from the proposals.
- **Feasibility audit of TB5–TB7.** Recompute instance sizes and whether < 60 s warm is plausible for each; attack any rung whose feasibility is asserted without numbers.
- **Test discipline.** Are the proposed mutations (7 for TB5, 9 for TB6, TB7's) semantic and specific enough that a worker cannot fake green? Any "runs without error" test is an objection. Propose at least two mutations the proposer missed.
- **Elegance audit.** Where is §9–13 more complicated than the mathematics? Does the four-query API carry real weight, or is it decoration? Propose the simplification, concretely.

## Output: `verdicts/design-v2-r1.md`
Numbered objections, each: severity FATAL/MAJOR/MINOR/NOTE · exact location (DESIGN § / definitions row) · your independent computation or citation (gt file + label/line) · one-line FIX DEMAND · SURVIVING WEAKER STATEMENT. Then: your recomputations (a)–(d) in full; the MERGE PROPOSALS adjudication (ACCEPT/REJECT per item with reason); per-claim recommendation for C12–C15 (ADMIT as CONJECTURE / REJECT wording, with the missing step named). Final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)` where PASS means no FATAL/MAJOR.
