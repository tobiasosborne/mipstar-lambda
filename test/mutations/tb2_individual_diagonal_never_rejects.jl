# verdicts/tb2-r5.md NG1 (the critic's mutant, verbatim in effect): step 4(b)
# never rejects on a diagonal line; owned by the eighth replay case
# (:proof_individual_diagonal, corrupt (:right,1) -> :ld_diagonal_point) at
# three seeds (the guard-key block since brief 73), and by the certificate replay.
const TB2_INDIVIDUAL_DIAGONAL_NEVER_REJECTS_MUTANT = Mutant(
    "TB2 NG1-individual-diagonal step4b_diagonal_never_rejects",
    "src/verifiers/answer_reduce.jl",
    "                    _ar_entry(4, branch, player, i, line_kind, result;\n                              ldparams=params), left_type, right_type)\n                rejected === nothing || return rejected",
    "                    _ar_entry(4, branch, player, i, line_kind, result;\n                              ldparams=params), left_type, right_type)\n                rejected === nothing || line_kind == :DLine || return rejected",
    "tb2_replay_seeds",
    "cases=19 outcomes=57 honest=57 corrupted_rejected=48")
