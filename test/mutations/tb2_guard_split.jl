# verdicts/tb2-r3.md N10: widen the step-2 guard of answer_reduce_guard_branches
# to any copy-matched counterpart type; the eight (oracle Point_6, line_1/2)
# orientations already trigger step 5, so the no-check count stays 2736 and
# only the step-5-alone count moves (92 -> 84).
const TB2_GUARD_SPLIT_MUTANT = Mutant(
    "TB2 M-guard-split input_consistency_guard_widened_to_lines",
    "src/verifiers/answer_reduce.jl",
    "            counterpart.pcp == PCPType(:Point, other_copy) &&",
    "            counterpart.pcp.copy == other_copy &&",
    "tb2_no_check",
    "MUTATION_EXPECTED_RULE guard_split actual=(2736, 180, 107, 84, 54, 53)")
