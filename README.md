# mipstar-lambda

**The compression step of MIP\* = RE, rebuilt as a small algebra of executable, certified transformations in Julia.**

The compression theorem of [Ji, Natarajan, Vidick, Wright and Yuen (2020)](https://arxiv.org/abs/2001.04383) is the engine of MIP\* = RE. Inside it, the crux is *answer reduction*: a bespoke low-degree PCP whose query distribution must stay *conditionally linear* so the construction can be iterated. This repository asks a concrete question about that crux:

> Can the verifier transformations of answer reduction be written as a small set of pure functions on symbolic programs, with every invariant the proof depends on (degrees, field size, variable dependence, query levels) tracked as data and checked by machine?

The answer so far: **yes for the combinatorial skeleton.** The soundness estimates (Schwartz–Zippel, low-degree testing, quantum rigidity) stay exactly where the paper puts them and are carried as explicitly cited leaves, never as proofs.

---

## What is here

Everything below runs on Julia 1.12 with no dependencies beyond the standard library.

| Rung | What it implements | Ground truth | Status |
|---|---|---|---|
| **TB0** | GF(2ᵏ); sparse multivariate polynomials with *two* degree accounts (structural derivation and support-computed); multilinear extension `g_a`; NW19 Tseitin transform and formula-tree arithmetization; the zero-on-subcube certificate `c₀ = Σᵢ cᵢ·zero(zᵢ)` as an executable rewrite; the paper's `pcpverifier` on a real 6-gate circuit with m′ = 16 over GF(8) and GF(2¹¹) | §10.4 | green, 14 mutants killed, critic round 2 |
| **TB1** | Conditionally linear functions as an inductive datatype (the level *is* the nesting depth); the low-degree-test sampler L_Point, L_ALine, L_DLine with canonical line representatives; exact histograms over all 32,768 seeds against the paper's lemmas; the decider D^ld | §4, §7.1 | green, 5 mutants killed, critic round 1 |
| **TB2** | The 18-type PCP sampler with the paper's register layout, the oracularized 54-type product, and all five checks of the answer-reduced decider (fig. decider-pcp) | §10.5 | green, 5 mutants killed, critic round 1 |
| **TB3** | Quoted program IR, fuel-bounded evaluator, bounded trace → succinct 3SAT → decoupled 5SAT | §10.2–10.3 | brief written |
| **TB4** | `Compress = Repeat ∘ AnswerReduce ∘ Introspect` with ASSUME/PROVE contracts; the halting verifier as a quoted fixed point `D = Y Ψ` | §12 | brief written |
| toy | The recursive midpoint protocol: optimal cheating probability exactly 1 − 2⁻ⁿ, sequential repetition needs Θ(2ⁿ) copies | handoff | **proved**, 13 mutants killed |

The rungs are *tracer bullets*: each is a thin end-to-end slice, smoke-tested before the next is started.

## How the work is verified

This is not a demo. Every claim lives in [`claims/CLAIMS.md`](claims/CLAIMS.md) with a status that only an adversarial critic may raise:

- **Proposer** (gpt-5.6, xhigh reasoning) writes code and proofs from written briefs in [`briefs/`](briefs/), red test first.
- **Critic** (Claude Opus, a different model family) recomputes every number independently, writes new mutants, and files a verdict in [`verdicts/`](verdicts/) with a fix demand and a surviving weaker statement for every objection.
- **Mutation tests** in `test/mutations/` prove each checker can fail: a copy of the code is broken in a named way and the targeted test must go red.
- The loop runs until a verdict has no MAJOR objection. The design took four rounds (13 → 3 → 1 → 0). Refuted claims are kept as negative results.

The method is `rk-light`; the laws are summarized at the top of [`CLAUDE.md`](CLAUDE.md).

## Run it

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. test/runtests.jl            # all rungs; prints the transformation traces
julia --project=. test/mutations/run.jl       # every mutant must be killed (slow: minutes)
julia toys/midpoint/test.jl                    # the midpoint toy, exact rationals
```

The first run precompiles for a minute or two. The test suite prints a certificate trace for each rung, for example:

```
[CHECKED] ArithTseitin   inddeg(F_arith) = (2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3)
[CHECKED] BuildC0        structural = actual; inddeg = 6; monomials = 534912
[CHECKED] ZeroBasis      remainder = 0; coefficient identity = true
[CHECKED] PCPVerifier    formula + zero tests = accept
[CONSTRUCTED] PCPSampler typed CL level = 3
[CITED] gt-07-ldt.tex (lem:ld-soundness)
[CITED] gt-10-answer-reduction.tex (thm:ar)
```

`CHECKED` means a replayable computation, `CONSTRUCTED` means the datatype cannot express a violation, `CITED` means the paper carries it and we do not.

## Read it

- [`handoff.md`](handoff.md): the mandate. What the question is and what it is not.
- [`docs/DESIGN.md`](docs/DESIGN.md): the term language and the 22 design decisions, each with its rejected alternative.
- [`docs/definitions.md`](docs/definitions.md): every symbol, once, with its citation into the source.
- [`ground-truth/`](ground-truth/): the paper's TeX, sliced per section, plus the NW19 Tseitin definition. The only authority on the construction.
- [`worklog/`](worklog/): what happened, in order.

## Contributing

Open an issue with a concrete objection: a file, a line, a recomputation, and what you think survives. That is the format the critics use and it is the fastest way to get a claim changed. Pull requests that raise a claim's status without a verdict will be declined on principle; pull requests that add a red test are always welcome.

## License

[AGPL-3.0](LICENSE). The paper excerpts in `ground-truth/` are © their authors and are included as verbatim reference material under the arXiv license.
