# Brief 102 — WIP report (orchestrator, from the worker log; worker STOPPED at wind-up 2026-10-03 00:10, ~9.5 h in)

Status: UNFINISHED, UNVERIFIED, package DOES NOT LOAD: ParseError at src/compress/answer_reduce.jl:453:14 (mid-edit). Lives on branch wip/brief102-repair-r2 only; main keeps 78b2dce code.

Worker narrative (verbatim, codex log):
- I’ll read the review and checkpoint report, turn the reproducers into permanent tests, and establish the reds before changing production code. I’ll stay within the assigned lane and use at most 10 targeted Julia processes.
- The review identifies two integrity gaps: a child can forge the runner’s result file before exiting, and certificate bindings retain mutable facts. I’ll also take the conservative PCP option: matching headers will yield `NOT_EVALUABLE`; a demonstrated mismatch will still yield `FAIL`.
- I’ve checked the relevant source passages. Membership requires every tail coordinate to be zero, and the size rule replaces both machines when the maximum description length exceeds λ. I’ll group the related certificate, PCP and fallback regressions into one targeted test file to conserve Julia starts.
- The runner reproducer is red on the checkpoint: the child’s actual assertions are 1 pass / 0 fail / 0 errors, but its forged record earns kill credit. The permanent regression reports 2 pass / 1 fail. The other new regressions are running against the unchanged production code now.
- The combined regression is red: 29 pass / 23 fail / 0 errors. That includes all six certificate attacks, the PCP header forgery, four fallback replay/report failures, and twelve rounding failures. I’m now adding immutable fact seals, preserving validation through reconstruction, and separating effective-pair checks from original-input hypotheses.

Diff:  19 files changed, 222 insertions(+), 62 deletions(-); new files: test/tb7_review_regressions.jl (combined P97-2/4/5/6 regressions), test/mutations/runner_channel.jl, test/mutations/runner_process_selftest.jl.

Resume: fix the parse error, re-run test/tb7_review_regressions.jl (was RED 29/23/0 on 78b2dce), finish items 1–8 of briefs/102-tb7-tb6-repair-r2.md, then brief 97 on mains power.
