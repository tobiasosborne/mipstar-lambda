const TB2_LINE_MUTANT = Mutant(
    "TB2 truncate_line_polynomial",
    "src/verifiers/answer_reduce.jl",
    "_tb2_finalize_line_answers(answers::Tuple) = answers",
    "_tb2_finalize_line_answers(answers::Tuple) = Base.setindex(answers, _truncate_univariate(answers[1]), 1)",
    "tb2_line")
