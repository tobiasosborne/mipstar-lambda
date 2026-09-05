# verdicts/tb2-r6.md NG7 (the critic's MG5, verbatim): revert N29 variant (b)
# so item 3 of fig:ld-decider compares a zero-direction line at t only
# instead of at every t in F_q; owned by the `degenerate_t0_cheat`
# transcript of `decider_rejections` (the degree-1 cheat 1 + t agrees with
# the point answer at t = 0 alone and must be rejected at location 1).
const TB1_DEGENERATE_ALL_T_MUTANT = Mutant(
    "TB1 NG7-degenerate-all-t admissible_t_only",
    "src/verifiers/ldt.jl",
    "    admissible = all(iszero, line.direction) ? field_elements(F) : (t,)",
    "    admissible = (t,)",
    "tb1_decider_rejections",
    "MUTATION_EXPECTED_RULE degenerate_line off_base=ld_diagonal_point@question t0_cheat_passed=true")
