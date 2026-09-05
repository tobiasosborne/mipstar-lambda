# verdicts/tb1-r5.md N29 (the critic's NM15): every point counts as lying on
# a zero-direction diagonal line, so a point off a degenerate line is
# compared at t (rejected at location 1 by the honest constant answer)
# instead of being refused at location :question; owned by the degenerate
# off-base fixture of `decider_rejections`.
const TB1_DEGENERATE_LINE_MUTANT = Mutant(
    "TB1 N29-degenerate-line every_point_on_degenerate_line",
    "src/verifiers/ldt.jl",
    "        return point == line.base ? (true, zero(F)) : (false, zero(F))",
    "        return (true, zero(F))",
    "tb1_decider_rejections",
    "MUTATION_EXPECTED_RULE degenerate_line off_base=ld_diagonal_point@1")
