# Brief 54 — TB1 + TB2 repair r3 (work orders: verdicts/tb1-r3.md N12, N13 MAJOR, N4 PARTIAL, N14–N16 MINOR, N17–N22 NOTE; verdicts/tb2-r3.md N6 MAJOR, N7, N9, N10 MINOR/NOTE) — the serializer must be tied to the map

Proposer (Fable). Autonomous; no questions; **no git**. Lane: `src/samplers/**`, `src/verifiers/ldt.jl`, `test/tb1_ld_sampler.jl`, `test/tb2_answer_reduce.jl`, `test/mutations/tb1_*.jl`, `test/mutations/tb2_*.jl`, `test/mutations/run.jl` (additively). Report: `briefs/54-tb1-tb2-repair-r3.last.md` (≤ 30 lines).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/tb1-tb2-r3/`

Read `verdicts/tb1-r3.md` and `verdicts/tb2-r3.md` IN FULL — every FIX DEMAND is binding:
- **N12 (TB1) = N6 (TB2) — canonical bytes are not tied to the map.** (a) Fix the serializer so stage matrices and every `QuotedBranch` table are encoded; (b) implement `decode(bytes) :: AbstractCL` and assert the round trip `apply(decode(canonical_bytes(describe_cl(L))), z) == apply(L, z)` on the declared chain sets for all 21 maps (the deserializer brief 46 left missing); (c) injectivity on the named separator pair (`L_Point` vs the complementary projector: bytes differ, size 75 both) and the 18 PCP bytes pairwise distinct; (d) assert the five exact PCP sizes and the three TB1 sizes (or their new values after (a), printed and justified); (e) an exact byte-window assertion for one matrix entry. Mutants: `tb1_describe_matrix.jl`, `tb2_describe_byaxis_collapse.jl` (NE1) KILLED.
- **N13 (TB1)**: register `tb1_prefix_walk.jl` (walk ignores the prefix) and show it KILLED — `map_sum_ok` becomes red-capable.
- **N14 (TB1) / G3**: `Marginal(L,0,z)` rejected (`ArgumentError`) and `cl_kth_replay` uses the explicit zero prefix internally; asserted in `queries`.
- **N4 (TB1) PARTIAL**: attach `:ld_off_line_rejects` and the sweep node to a `Checked` the suite verifies (like `diagonal_histogram_evidence`); MERGE PROPOSAL for a `C4c` row (TB1 `D^ld`: off-line reading, `d`/`md` bounds, `kappa=2`, the 2,880/37,888 split) — proposal only.
- **N15 (TB1)**: `_pad_tail(CLZero)` promotes to the value's AMBIENT register in both cases (or rejects the empty-register pad); assert `cl_kth_replay(pad_level(CLZero(F,5,Int[]),3),…).space_sum_ok`; DESIGN §1.5/§9.4 reconciled (wording proposal).
- **N7 (TB2)**: `ZERO_MAP_FACTOR_PARTITION` is a child of the sampler certificate whenever the promotion runs, and one TB2 path reaches it (or state honestly that TB2 never pads a zero map and test it at TB1 only).
- **N9 (TB2)**: the 7-case replay runs at ≥ 3 seeds incl. a nonzero one; **N10 (TB2)**: `no_check` asserts the four-number split (107 any/92 only step 5; 54 any/53 only step 1).
- N16–N22 (TB1) and the remaining TB2 NOTEs: one-line dispositions each.
- Do NOT build `SamplerDescription`, the pair adapter, or description-level `direct_sum` (G1/G2/G5) — those are brief 39 (TB5). Keep this round small.
Rules: red/green per objection with the critics' mutants as red witnesses; baseline-first runner exit 0, every mutant KILLED; whole suite under the TB0 gate on a quiet machine; quiet and loaded walls. Report: response table with file:line; test/runner lines; description sizes after the serializer fix; CROSS-LANE EDITS; MERGE PROPOSALS (C4a/C4b/C9 scope clauses for N12/N13/N14 struck where fixed — verbatim; C4c; DESIGN §1.5/§9.4 wording).
