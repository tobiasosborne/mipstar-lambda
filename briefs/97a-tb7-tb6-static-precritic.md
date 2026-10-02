# Brief 97a — CRITIC (codex gpt-6-astra xhigh): STATIC pre-review of the brief 93 checkpoint (TB7 repair r1 + TB6 repair r4) at 78b2dce

You are a rigorous reviewer of a mathematical-software test suite. Look for real defects; do not summarize. Autonomous; no questions. This is a STATIC round on battery: it cannot raise any status and authorizes NO CLAIMS row. Its job is to find every defect in brief 93 BEFORE the expensive closing round (brief 97, full suite + registry on mains power), so a repair can land first.

Note: a previous run of this brief was interrupted; the stub `verdicts/tb7-r2-pre.md` and any scripts under the scratch dir `b97a/` are yours to reuse or overwrite.

Lane: write `verdicts/tb7-r2-pre.md` ONLY (+ scratch `/tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/`). The live tree's `src/`, `test/`, `docs/DESIGN.md` are exactly commit 78b2dce and stay frozen today (other workers write only under `docs/analytic/` and `docs/assessment.md`), so read them in place and reuse the existing precompiled depot. Probes and red tests go in scratch as standalone scripts that `include` or `using MIPStarLambda`; never edit repo files outside your lane. Paste every red test / mutant definition verbatim into the verdict (scratch does not survive).

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `claims/CLAIMS.md` C11–C15 (C14/C15 rows carry HOLD annotations).
2. Your priors, IN FULL: `verdicts/tb7-r1.md` (T7-1…T7-9) and `verdicts/tb6-r4.md` (T6-1, T6-2).
3. `briefs/93-tb7-repair-r1-tb6-repair-r4.md` (the repair brief) and its report `briefs/93-tb7-repair-r1-tb6-repair-r4.last.md` (claims A–K DONE; registry NOT run; two caveats; proposed C14/C15 rows).
4. The change: `git diff 2fa15e4 78b2dce -- src test docs/DESIGN.md` (2fa15e4 is the tree tb7-r1/tb6-r4 judged).
5. Ground truth as needed, opened yourself: `gt-12-compression.tex`, `gt-08-introspection.tex` (L401–L534, L757–L776), `gt-10-answer-reduction.tex` (fig:decider-pcp, L1948–L1965), `gt-11-parallel-repetition.tex`.

## Obligations
1. **Discharge table** for T7-1…T7-9 and T6-1, T6-2: DISCHARGED-STATICALLY / PARTIAL / NOT, each with file:line evidence and what only a full run can still decide.
2. **Check each repair by reading and by small probes** (Julia budget in the preamble): 
   - A/T6-2 (test-accounting correctness): can a mutation run be counted as KILLED although no owned assertion failed — e.g. a stale `tally.result` left over from an earlier mutant, a nonce shared between parallel jobs under MUTATION_JOBS=4, a process that exits after the tally is written, a test that only prints text resembling a tally? Does `runner_selftest.jl` itself fail when its check is removed? Keep this to reading the runner plus at most one small local probe; describe any finding in plain test-accounting terms ("spurious credit") — this is ordinary test-harness QA on a local research repo.
   - B/T6-1: write at least two NEW weakened `_in_V` variants not in the registry (e.g. checks the tail only on detyped answers; checks only the first answer of a pair; off-by-one at s+1) and decide by reading/probing whether `tb6b_negative`/`tb6b_tail_edges` kills them.
   - C/T7-7: does waiting on measured elapsed make every gate mutant killable regardless of load, or can a gate pass under a fast kernel? Are K values untouched?
   - D/T7-3, E/T7-2: modify a CHECKED certificate node's facts/children AFTER construction, and the function it replays; does `verify_local`/`BoundReplay` reject the inconsistent node? Is the worker's caveat ("binds to construction-time facts, not to re-running the constructing code") a real gap in the certificate logic — give the concrete counterexample if so. Is the fixed-point re-evaluation red-capable for a constant-true evaluator and for discarded decider code (the two tb7-r1 survivors)?
   - H/T7-5: re-derive the source rule at gt-08:L757–L763 yourself and check `intro_effective_pair` against it, including the boundary `max(|S|,|D|) = λ`.
   - I/T7-6: is "0 of 164 oriented pairs" honest everywhere it is stated (code, DESIGN §12.5/§13.2, proposed C15 row)? Any remaining text that claims Pauli predicates execute?
   - K/T7-4: rule on the caveat that "every reached chain" honours T7-4 (8 rows zero below the AR detype). Acceptable scoped limitation or defect?
   - F/T7-1, G/T7-8: can `group_status`/ToyContractAudit report PASS with a FAIL/VACUOUS premise? Is the 4-agreements + 4-prefix + NOT_EXECUTED grading honest, and is the old "4 of 9" text corrected everywhere in DESIGN?
3. **New findings** outside T7/T6: anything the diff broke or newly overclaims (numbers, counts 45 owned mutants, 22747=[22618,129], DESIGN §13.3).
4. **Proposed rows**: pre-rule the worker's proposed C14 and C15 texts — which clauses you would accept, which you would cut — as advice to brief 97 (not an authorization).
5. **List exactly** what brief 97 must still RUN (commands, expected numbers, which mutants), so the mains-power round is short.

## Output
`verdicts/tb7-r2-pre.md`: numbered objections (severity FATAL/MAJOR/MINOR/NOTE · location · evidence · one-line FIX DEMAND), discharge table, probes run (command + result), section "For brief 97", final line exactly `PRE-VERDICT: CLEAN` or `PRE-VERDICT: DEFECTS(<ids>)`. Final message ≤ 12 lines.
