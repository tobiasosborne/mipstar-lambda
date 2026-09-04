const TB2_MC2_MUTANT = Mutant(
    "TB2 MC2 input_consistency_compares_other_block",
    "src/verifiers/answer_reduce.jl",
    "result = CheckResult(other_answer[1] == current_answer[input_copy],",
    "result = CheckResult(other_answer[1] == current_answer[3 - input_copy],",
    "tb2_branches")
