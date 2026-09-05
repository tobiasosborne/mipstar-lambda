# verdicts/tb2-r5.md NG2 (the critic's mutant, verbatim in effect): step 4(c)
# never rejects on a diagonal line; owned by the ninth replay case
# (:proof_simultaneous_diagonal, corrupt (:right,7) -> :ld_diagonal_point) at
# three seeds (the guard-key block since brief 73), and by the certificate replay.
const TB2_SIMULTANEOUS_DIAGONAL_NEVER_REJECTS_MUTANT = Mutant(
    "TB2 NG2-simultaneous-diagonal step4c_diagonal_never_rejects",
    "src/verifiers/answer_reduce.jl",
    "                    _ar_entry(4, branch, player, 6, line_kind, result;\n                              ldparams=params), left_type, right_type)\n                rejected === nothing || return rejected",
    "                    _ar_entry(4, branch, player, 6, line_kind, result;\n                              ldparams=params), left_type, right_type)\n                rejected === nothing || line_kind == :DLine || return rejected",
    "tb2_replay_seeds",
    "cases=19 outcomes=57 honest=57 corrupted_rejected=54")
