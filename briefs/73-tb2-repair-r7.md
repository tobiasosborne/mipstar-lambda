# Brief 73 — TB2 repair r7 (work order = verdicts/tb2-r7.md: NG10 MAJOR; NG12 NOTE) — closing

Proposer (Fable). Autonomous; no questions; **no git**. Lane: `test/tb2_answer_reduce.jl`, `test/mutations/tb2_*.jl`, `test/mutations/run.jl` (additively). Report: `briefs/73-tb2-repair-r7.last.md` (≤ 12 lines).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/tb2-r7/`

Read `verdicts/tb2-r7.md` IN FULL. **NG10**: the trace key's `index` (copy) coordinate has no corrupted-reject witness at 19 of 37 keys — add the critic's block: one case per guard key (19) × 3 seeds × 2 orientations = 114 outcomes covering all 37 keys (the critic ran it 114/114 green on clean code, red under each of MH1/MH2/MH3/MH5); register the four one-line mutants (steps 4(a)/4(b) at copies 4/5, step 2 at copy 2, step 3 at axis@copy2 + diagonal@copy1) targeting the new testset and show them KILLED. NG12: one-line disposition. Baseline-first runner exit 0, every mutant KILLED; suite quiet (`uptime`). MERGE PROPOSAL: C9 with the "Scope (copy index)" sentence deleted (verbatim; proposal only).
