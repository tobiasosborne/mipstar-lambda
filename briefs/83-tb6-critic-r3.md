# Brief 83 — CRITIC verdict r3 on rung TB6 (brief 82 = TB6 repair r2) — closing round; plus the TB4 r3 ruling on C11's three stale clauses

You are the adversarial critic (codex, gpt-6-astra, xhigh). ATTACK; do not summarize. Autonomous; no questions. Lane: write `verdicts/tb6-r3.md` and `verdicts/tb4-r3.md` ONLY; Julia and files only under your scratch dir; never edit repo files; NO git commands that change state. Evaluate the ARCHIVED tree at commit `2eff253` (`git archive 2eff253 | tar -x -C <scratch>/tree`; there `julia --project=. -e 'using Pkg; Pkg.instantiate()'`; cold precompile takes a few minutes). Never read `src/`/`test/` from the live tree — another worker (brief 44, TB7) is editing it concurrently; `claims/CLAIMS.md`, `verdicts/`, `briefs/`, `docs/` may be read live (they are not in TB7's lane except `docs/DESIGN.md` §12, which you may read from the archive).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/74478cf7-c75e-46db-bc49-bfda0ac1586c/scratchpad/critic-tb6-r3/` (create it).

Environment: 12-core workstation, `balanced` power profile, ANOTHER Julia worker runs concurrently. Wall numbers are advisory; every gate is a clock-calibrated ratio (`test/calibration.jl`) — report `uptime` before/after each run and do not spend the round on calibration beyond checking the gates are honest and red-capable. Use `MUTATION_JOBS=4`.

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md` §Method.
2. `claims/CLAIMS.md` — C14 (target; the row currently carries N1/N2/N3 scope sentences), C13, C12, C11 (for the TB4 part).
3. `verdicts/tb6-r2.md` IN FULL — your prior. Adjudicate ONLY the deltas of brief 82 (N1–N8, §7 readiness); do not re-litigate O1–O10 or the session-5 changes (a)–(f), all ACCEPTED in r2.
4. `briefs/82-tb6-repair-r2.md` (work order) and `briefs/82-tb6-repair-r2.last.md` (report, incl. the "C14 scope proposals" paragraph).
5. `docs/DESIGN.md` §§10.3, 11.4 (the new charge-site table and the restated "Nested typed deciders"), 11.6, 12.1, 13.1; `docs/definitions.md` §H.
6. Ground truth, recomputed never from memory: `gt-08-introspection.tex` L401–L498 (esp. L417–L419, L451–L455, L462–L473, L531–L534 — the `V`-membership rejection), L550–L579, L641–L684; `gt-03-prelim.tex` L307–L318.
7. The diff `git diff 2a1510c 2eff253 -- src test docs` (2a1510c = the r2 verdict commit; everything after it is brief 82's).
8. For the TB4 part: `verdicts/tb4-r2.md` §C11, `HANDOFF.md` "(session 4) RESUME" item "C11 warning (triage §C)", `test/tb4_compress.jl`, `test/mutations/tb4_*.jl`, `test/calibration.jl`.

## Obligations (TB6 r3)
- **Run** `julia --project=. test/runtests.jl` (paste the summary line, the TB0/TB5/TB6 gate lines, `uptime`) and `MUTATION_JOBS=4 julia --project=. test/mutations/run.jl` (paste the `MUTATION REGISTRY` line; the report claims `killed=218/218 baselines ok=85/85`, no KILLED-BY-CRASH). One at a time.
- **N1–N8 discharge table**: for each, DISCHARGED / PARTIAL / NOT with evidence. Specifically:
  - N1: verify from gt-08:L531–L534 and your own transcription of `V` that each of V1–V4 (and the replay's `bit5`) is genuinely outside `V` and corrupts exactly ONE field; that rejection happens at the parse with trace `[:Dimension]` only; that `M6-in-V` is killed by the out-of-V test and not by an unrelated assertion (read the runner's evidence string). Try to construct an out-of-`V` answer that the parse still ACCEPTS (e.g. a vector in the right span but wrong coset, a `y⊥` that is orthogonal but not in the declared subspace, a `z` on the boundary) — a survivor is MAJOR.
  - N2: recompute the boundaries 22,632 → `(22631, [22618, 13])` and 22,622 → `(22622, [22618, 4])` from the §11.4 charge-site table by hand (show the arithmetic). Is `M6-nested-timeout-uncharged` killed at the sampler-query site only, or does the decider-call site have the same bug class uncovered? If uncovered: MAJOR with the red test as FIX DEMAND.
  - N3: is the restated §11.4 now TRUE of the code (nothing metered is claimed unmetered and vice versa)? Is the `UNCHARGED(owner=tb7-nested-own-steps)` gap printed by code or only written in prose? Confirm `by_depth[2] == 15 == 5 + 10` is pinned.
  - N4: rule on the D1(d) DOWNGRADE — is "red capability lives at test level with the diagonal kill matrix" an honest weaker statement, and does CLAIMS C14 say so?
  - N5: recompute `child_calls == dim + 6` at 206 from the schedule; is `(155_631, 212)` reproducible on your archive?
  - N6: each of the five corrections landed, and nothing in DESIGN still states the old walls/targets/"≥ 12×" (grep).
  - N7: independently derive the four `TB6b-M` charge-table values (Dimension 5, Marginal(3) 53, Factor(2,e1) 39, Linear(2,e1,e4) 40) from the 15-row charge-site table with YOUR OWN elimination-cost count; a test that "re-derives from the table" is only evidence if the table and the meter are independent — check whether the test's derivation shares code with the meter.
  - N8: on a copy, register a mutant that CRASHES the test file (e.g. a `MethodError` in the test's setup) and show the runner scores it `KILLED-BY-CRASH (not credited)` and exits nonzero.
- **Two NEW semantic mutations** on copies, aimed at brief 82's new surface (not O1–O10's). Survivors are MAJOR with the red test as FIX DEMAND.
- **Claims.** C14: the report proposes striking the N1 sentence and the N2 clause and KEEPING the N3 clause until brief 44. Authorize the replacement C14 row VERBATIM (paste the complete row text, one line, as it should appear in `claims/CLAIMS.md`) or HOLD with the missing step named. C13/C12: confirm or name the delta.
- **Elegance**: r2 §8 named three simplifications; say whether brief 82 made any of them harder, and name the single one brief 44 should be told to do.

## Obligations (TB4 r3 — ≤ 25 lines, `verdicts/tb4-r3.md`)
The authorized C11 row pasted in 5f2e091 has three clauses now stale against the repaired tree: (i) "26/26 registered mutants" (the TB4 registry now has more — count them yourself from `test/mutations/`), (ii) the NOT-red-capable list (both items are said to be owned and KILLED now — verify each has a registered mutant and its evidence string), (iii) "gated at `elapsed / calibration < 42` … 6.5–8.0 s" (now a calibrated ratio gate with a different K — read the value from `CALIBRATED_GATES`). For each: your verification; then authorize the corrected C11 row VERBATIM (complete row, one line) or HOLD naming the missing step. Final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.

## Output: `verdicts/tb6-r3.md`
Numbered objections (severity FATAL/MAJOR/MINOR/NOTE · exact location · your independent computation · one-line FIX DEMAND · SURVIVING WEAKER STATEMENT); the N1–N8 discharge table; runs + load; your mutations and outcomes; per-claim decisions with verbatim authorized rows; elegance; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`. Your final assistant message (captured to `briefs/83-tb6-critic-r3.last.md`) is ≤ 10 lines: both verdict lines, the run summary lines, and the list of authorized rows.
