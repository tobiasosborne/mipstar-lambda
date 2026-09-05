# verdicts/tb2-r7.md NG10 (the critic's MH5, verbatim): step 3's input
# low-degree rejection is disarmed exactly at axis@copy2 and
# diagonal@copy1 -- the two copies the nine-case list never corrupted;
# owned by the guard-key block of `replay_seeds` (cases :input_axis_c2 and
# :input_diagonal_c1, three seeds, both orientations).
const TB2_STEP3_CROSSED_COPIES_MUTANT = Mutant(
    "TB2 NG10-step3 step3_crossed_copies",
    "src/verifiers/answer_reduce.jl",
    "                _ar_entry(3, branch, player, input_role_copy, line_kind,\n                          result; ldparams=params), left_type, right_type)\n            rejected === nothing || return rejected",
    "                _ar_entry(3, branch, player, input_role_copy, line_kind,\n                          result; ldparams=params), left_type, right_type)\n            rejected === nothing || (line_kind == :ALine) == (input_role_copy == 2) || return rejected",
    "tb2_replay_seeds",
    "TB2 replay at 3 seeds (zero, tb2_seed 5, rng 0x9E): cases=19 outcomes=57 honest=57 corrupted_rejected=51")
