# Brief 59 — TB1 + TB2 repair r4 (work orders: verdicts/tb1-r4.md N23 MAJOR, N24–N26 MINOR, N27–N28 NOTE; verdicts/tb2-r4.md NF1, NF2 MAJOR, N23–N26 NOTE) — small closing round

Proposer (Fable). Autonomous; no questions; **no git**. Lane: `src/samplers/**`, `src/verifiers/ldt.jl`, `src/verifiers/answer_reduce.jl`, `test/tb1_ld_sampler.jl`, `test/tb2_answer_reduce.jl`, `test/mutations/tb1_*.jl`, `test/mutations/tb2_*.jl`, `test/mutations/run.jl` (additively). Report: `briefs/59-tb1-tb2-repair-r4.last.md` (≤ 20 lines).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/tb1-tb2-r4/`

Read `verdicts/tb1-r4.md` and `verdicts/tb2-r4.md` IN FULL — every FIX DEMAND is binding:
- **TB1 N23**: assert `off_line.location == :question` on the fixture; register `tb1_off_line.jl` (`(line_point(line,t)==point,t)` → `(false,t)`, target `tb1_decider`) KILLED — this is C4c's missing step (the critic pre-wrote the row; do not change CLAIMS).
- **TB1 N24** (assert one off-diagonal matrix entry's position — pins row-major order before TB6b-M's nonsymmetric stage), **N25** (decide and pin `_pad_top`'s rule for a proper sub-register; DESIGN wording proposal), **N26** (`register_indices(decode_cl(canonical_bytes(describe_cl(CLZero(F,5,(2,)))))) == (2,)`); N27/N28 one-line dispositions.
- **TB2 NF1**: a lockstep testset running `typed_answer_reduced_decider` over ALL 2916 ordered type pairs with honest answers and asserting agreement with `answer_reduce_guard_branches` (accept where the enumerator says check-free; step reached otherwise); the critic's step-4(b) widening mutant registered and KILLED.
- **TB2 NF2**: step 1 equal-type comparison covers every entry — corrupt entries 7 and 22 on the four copy-6 equal-type pairs must reject; the first-entry-narrowing mutant registered and KILLED.
- **TB2 N23–N26 NOTEs**: one-line dispositions (N26 — `decode_cl` re-imposes `factor ⊎ rest = {1..n}`: do it, it is one call).
Rules: red/green with the critics' survivors as red witnesses; baseline-first runner exit 0, every mutant KILLED; suite under the TB0 gate quiet; quiet and loaded walls. Report: response table with file:line; runs; CROSS-LANE EDITS; MERGE PROPOSALS (C4a/C4b/C9 scope clauses struck where fixed; C4c unchanged from the critic's pre-written text).
