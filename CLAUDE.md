# mipstar-lambda — symbolic (lambda-calculus / Julia) reformulation of MIP*=RE compression

**North star (user, 2026-09-04):** a COMPLETE executable implementation of Compress = Repeat ∘ AnswerReduce ∘ Introspect on descriptions, with every invariant tracked and adversarially verified; Introspect (§8) and Repeat (§11) are to be built as rungs (TB5–TB7), not left as CITED stubs. One of the paper's authors indicated such an implementation would be useful for extending the construction. Deliverables also include the analytic document (docs/analytic/) and an HTML tutorial for physicists.

Read `handoff.md` first (the mandate), then `claims/CLAIMS.md` (what is currently claimed and at what status), then `worklog/` (latest file).

## Ground truth
`ground-truth/gt-*.tex` are verbatim slices of the arXiv:2001.04383v3 TeX source (`ground-truth/tex/`). They are the ONLY authority on the construction. Do not work from memory of the paper; cite `gt-NN-*.tex` line ranges. Known typos in the source: Def. `def:tseitin` writes $\formula(x,s)$ for $\formula(x,w)$; Def. `def:formula-arithmetization` writes $\F_q^{m'}$ for $\F_q^{m}$.

Key locations:
- low-degree code, Schwartz–Zippel: `gt-03-prelim.tex` (sec:ld-encoding)
- CL functions/distributions/samplers: `gt-04-cl.tex`
- classical low-degree test (L_Point, L_ALine, L_DLine, decider D^ld): `gt-07-ldt.tex`
- Tseitin, arithmetization, succinct 5SAT, the PCP (prop:zero-basis, fig:pcpverifier, thm:pcp-decider), the answer-reduced verifier (fig:decider-pcp, thm:ar): `gt-10-answer-reduction.tex`
- Compress skeleton (fig:compress, thm:compression): `gt-12-compression.tex`

## Method: rk-light (see ~/.claude/skills/rk-light/SKILL.md)
- Claims ratchet in `claims/CLAIMS.md`. Status ∈ {PROVED, TESTED, SKETCH, CONJECTURE, REFUTED}. Status goes UP only via a converged critic verdict in `verdicts/`. Never by the author.
- Single-source definitions: `docs/DESIGN.md` (term language) and `docs/definitions.md`. Code cites; never redefines.
- Every machine-checkable claim has a test in `test/` AND a mutation (red) test proving the test can fail (`test/mutations/`).
- Hard cognition (design, proofs, implementation, review) is delegated to `codex exec` (gpt-5.6-sol, xhigh). Claude subagents, when used, are Opus (never Fable). Briefs live in `briefs/`, verdicts in `verdicts/`.
- Red/green TDD: tests are written and shown RED before implementation; mutation testing after GREEN.

## Build & test
```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. test/runtests.jl            # must exit 0
julia --project=. test/mutations/run.jl       # every mutation must exit NONZERO
```

## Beads
`bd` is the issue tracker (prefix `mipstar-lambda-`). No git remote exists: the "push" steps in the bd session protocol do NOT apply; commit locally with status-bearing messages.
