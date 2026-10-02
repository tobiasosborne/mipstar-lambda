# Session rules (2026-10-02, read first; they override any conflicting line below)
- The machine RUNS ON BATTERY and is compute-starved. Up to three codex workers share it; each works in its own lane.
- NO full `test/runtests.jl`, NO `test/mutations/run.jl` registry, no benchmark, no clean rebuild. Prefix every Julia command with `nice -n 10 timeout 240 env JULIA_NUM_THREADS=2`; at most FIVE Julia processes in your whole session; reuse the existing depot (no `Pkg.instantiate` unless a run fails for missing deps). pdflatex is fine (twice, a third pass if "Rerun").
- Wall-clock gates are load-sensitive and meaningless today: never treat a timing number as evidence.
- Other workers write in other lanes of this tree right now: never edit, move or reformat a file outside your lane. No git command that changes state; no `bd`. The orchestrator commits.
- Write incrementally so an interruption loses little. Your final message is captured as `briefs/<NN>-*.last.md` and must be TRUE and complete (what was done, files, every command run with its result as numbers, what is NOT done).
- Ground truth is `ground-truth/gt-*.tex` only; cite file:line ranges you opened yourself, never memory.
