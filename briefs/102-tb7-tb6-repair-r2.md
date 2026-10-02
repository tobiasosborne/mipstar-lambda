# Brief 102 — PROPOSER (codex gpt-6-astra xhigh): TB7 repair r2 + TB6 repair r5 — verdicts/tb7-r2-pre.md DEFECTS(P97-1…P97-7)

You repair the brief 93 checkpoint (HEAD; report `briefs/93-tb7-repair-r1-tb6-repair-r4.last.md`) against the static pre-review `verdicts/tb7-r2-pre.md`. This is ordinary test-suite QA on a local mathematical research codebase. Autonomous; no questions.

Lane: `src/**`, `test/**` (incl. `test/mutations/**`), `docs/DESIGN.md` §12–§13 only, `briefs/102-tb7-tb6-repair-r2.last.md`, scratch `/tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b102/`. NOT: CLAIMS, verdicts/, docs/analytic/, docs/assessment.md (other workers), HANDOFF. No git state changes, no bd.

**Julia budget (battery, overrides the preamble's five):** you are the ONLY Julia user today. At most 10 Julia processes, each `nice -n 10 timeout 300 env JULIA_NUM_THREADS=2`, running ONE TEST TARGET at a time (single test file or a small driver that includes just the testset you need), never `test/runtests.jl` whole and never the mutation registry. To show a registered mutant is killed, run the runner for THAT mutant only if the runner supports selection (read `test/mutations/run.jl`); otherwise apply the mutation on a scratch copy and run its owning target. Timing gates are meaningless today: do not change any K or calibration to make a gate pass.

## Read
`CLAIMS.md` C14/C15; `verdicts/tb7-r1.md`, `verdicts/tb6-r4.md` (priors); `verdicts/tb7-r2-pre.md` IN FULL incl. its verbatim reproducers (§"Verbatim scratch reproducers") and §"For brief 97"; brief 93's report.

## Work (red first: each reproducer from the verdict becomes a permanent test, shown failing on HEAD, then passing)
1. **P97-1 (test accounting):** a mutation run counts as KILLED only when the driver epilogue actually ran and recorded a failed owned assertion; an early process exit after a child writes its own record must count as NOT KILLED. Register the verdict's runner_probe case as a permanent runner self-test.
2. **P97-2 (certificate binding):** CHECKED replays must re-derive from the node's actual (frozen/immutable) facts and required child rules; validation must survive `_relocate` and `unbound` reconstruction; a FAIL audit with its failure list emptied must not read PASS. Keep all six certificate_probe reds as tests.
3. **P97-3:** register the even-parity `_in_V` variant as a mutant and add a multi-bit outside-vector witness (e.g. e7+e8 on an `Introspect_bob` self-loop) through parser, typed and valid-detyped paths.
4. **P97-4:** `P_pcp_encodes_D1` must not be PASS from headers: authenticate the encoded formula/proof's construction chain and bound parameters, or let the header checks only refute (positive → NOT_EVALUABLE). Keep the semantic_probe red. Report honestly which you chose.
5. **P97-5:** derive executable-check expectations and dispatch/schema reporting from the EFFECTIVE pair (intro_effective_pair), keeping original-input hypotheses separately; add the verdict's straddling-node replay regression (fallback_red_NOT_RUN.jl) and RUN it.
6. **P97-6:** gate raw elapsed (round only display values) in TB5/TB6a/TB6b, with synthetic boundary tests (no measured timing).
7. **P97-7:** DESIGN §13.3 `ndigits(2; base=2)`.
8. Update DESIGN §12–§13 where behaviour changed; new mutants registered for 1, 3, 4, 5 where a permanent semantic mutant is meaningful.

## Report (final message, also the .last.md)
Per item: DONE / PARTIAL / NOT, file:line, red→green numbers for each target run (pass/fail/error), new mutants and how each was shown killed. List every Julia command with exit code. State plainly what remains for brief 97 on mains power (full suite expected count, registry). Note any disagreement with the pre-verdict with evidence.
