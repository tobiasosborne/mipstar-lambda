# verdicts/tb2-r6.md NG3 (the critic's MG3, verbatim in effect): step 3's
# input low-degree rejection is disarmed when the line type is the LEFT
# type (player = :bob); owned by the swapped-orientation half of
# `replay_seeds` (cases :input_{axis,diagonal}_c1/_c2, three seeds each; 19-case block since brief 73).
const TB2_INPUT_LD_ONLY_ALICE_MUTANT = Mutant(
    "TB2 NG3-input-ld step3_only_alice",
    "src/verifiers/answer_reduce.jl",
    "                _ar_entry(3, branch, player, input_role_copy, line_kind,\n                          result; ldparams=params), left_type, right_type)\n            rejected === nothing || return rejected",
    "                _ar_entry(3, branch, player, input_role_copy, line_kind,\n                          result; ldparams=params), left_type, right_type)\n            rejected === nothing || player == :bob || return rejected",
    "tb2_replay_seeds",
    "SWAP orientation (right,left) at the same 3 seeds: cases=19 outcomes=57 honest=57 corrupted_rejected=45")
