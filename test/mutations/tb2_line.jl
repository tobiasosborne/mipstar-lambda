const TB2_LINE_MUTANT = Mutant(
    "TB2 truncate_line_polynomial",
    "src/verifiers/answer_reduce.jl",
    "values = Tuple{F}[]\n    for raw_t in 0:degree_bound",
    "values = Tuple{F}[]\n    for raw_t in 0:0",
    "tb2_line",
    "MUTATION_EXPECTED_RULE ld_axis_point actual=ld_axis_point passed=false")
