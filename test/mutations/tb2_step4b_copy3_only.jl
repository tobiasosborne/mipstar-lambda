# verdicts/tb2-r7.md NG10 (the critic's MH2, verbatim): step 4(b)'s
# individual low-degree rejection is disarmed at proof copies 4 and 5;
# owned by the guard-key block of `replay_seeds` (cases
# :proof_individual_{axis,diagonal}_i4/_i5, three seeds, both orientations).
const TB2_STEP4B_COPY3_ONLY_MUTANT = Mutant(
    "TB2 NG10-step4b step4b_copy3_only",
    "src/verifiers/answer_reduce.jl",
    "                    _ar_entry(4, branch, player, i, line_kind, result;\n                              ldparams=params), left_type, right_type)\n                rejected === nothing || return rejected",
    "                    _ar_entry(4, branch, player, i, line_kind, result;\n                              ldparams=params), left_type, right_type)\n                rejected === nothing || i != 3 || return rejected",
    "tb2_replay_seeds",
    "TB2 replay at 3 seeds (zero, tb2_seed 5, rng 0x9E): cases=19 outcomes=57 honest=57 corrupted_rejected=45")
