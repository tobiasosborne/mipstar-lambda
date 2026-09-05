# verdicts/tb2-r6.md NG3 (the critic's MG1, verbatim in effect): step 4(b)'s
# individual low-degree rejection is disarmed when the line type is the
# LEFT type (player = :bob); owned by the swapped-orientation half of
# `replay_seeds` (case :proof_individual_diagonal, three seeds).
const TB2_INDIVIDUAL_LD_ONLY_ALICE_MUTANT = Mutant(
    "TB2 NG3-individual-ld step4b_only_alice",
    "src/verifiers/answer_reduce.jl",
    "                    _ar_entry(4, branch, player, i, line_kind, result;\n                              ldparams=params), left_type, right_type)\n                rejected === nothing || return rejected",
    "                    _ar_entry(4, branch, player, i, line_kind, result;\n                              ldparams=params), left_type, right_type)\n                rejected === nothing || player == :bob || return rejected",
    "tb2_replay_seeds",
    "SWAP orientation (right,left) at the same 3 seeds: cases=19 outcomes=57 honest=57 corrupted_rejected=39")
