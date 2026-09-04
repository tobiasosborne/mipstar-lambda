# Brief 21 — TB1 repair r1 (work order = verdicts/tb1-r1.md: O1, O2, O3, O5 MAJOR; MINOR/NOTE)

Proposer (gpt-5.6-sol, xhigh). Autonomous; no questions; no git. Lane: `src/samplers/cl.jl`, `src/samplers/typed.jl`, `src/samplers/ldt.jl`, `src/verifiers/ldt.jl`, `test/tb1_ld_sampler.jl`, `test/mutations/tb1_*.jl`, TB1 entries of `test/mutations/run.jl`. TB2 files (`src/samplers/pcp_sampler.jl`, `src/samplers/oracularize.jl`, `src/verifiers/answer_reduce.jl`, `test/tb2_*`) may be adapted ONLY where your API change forces it; list every such line under "CROSS-LANE EDITS" and keep TB2 tests green. Report: `briefs/21-tb1-repair.last.md` with a response table.

Read `verdicts/tb1-r1.md` IN FULL, `briefs/18-tb2.last.md` (how TB2 worked around eager CLStep), `docs/DESIGN.md` §1.5, `ground-truth/gt-04-cl.tex` L590-595 (lazy sampler interface the critic cites).

Binding fix demands:
- O5 (do first): make `CLStep` branches LAZY — the continuation is a function of the previous stage's value evaluated on demand; `apply` never enumerates an image; keep the level CONSTRUCTED by nesting depth; `distribution`/histogram enumeration remains available for small (q,m) via an explicit `enumerate_seeds` helper. Measure `apply` cost at q=2^11, m'=16 for L_DLine_6 (must be microseconds, not days). Refactor TB2's workaround onto the lazy datatype if TB2 landed (if the TB2 worker is still running, do NOT edit TB2 files; note it).
- O1: replace the "χ-free reference" claim honestly — implement the critic's finding: state in the test that M-χ cannot be detected by any lem:alnf/lem:dlnf marginal; instead make M-χ's owner a test of eq:chi-func directly (bucket boundaries) plus the joint (line, point) histogram; retitle DESIGN-facing comments accordingly (put a MERGE PROPOSAL for DESIGN §5.3 in the report).
- O2: paste the critic's ready-made red testset that kills "items 2 and 3 replaced by `true`"; add cheating-answer tests in both orders; add those five surviving mutants as permanent mutants and show them KILLED. Count and print non-noop decisions.
- O3 and MINOR/NOTE: as adjudicated; the mutation runner must not re-precompile the package 12 times (share a compiled depot or run mutants in-process on copies) — target < 5 min total.
Run the full suite (cold/warm walls) and the mutation registry (all lines). Report ≤ 30 lines; MERGE PROPOSAL for C4b if TB2 evidence exists — proposals only.
