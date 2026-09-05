const TB1_DLINE_DEGREE_MUTANT = Mutant(
    "TB1 NM1 diagonal_answer_accepts_any_degree",
    "src/verifiers/ldt.jl",
    "elseif kind == :DLine\n        params.m * params.d",
    "elseif kind == :DLine\n        typemax(Int)",
    "tb1_decider_rejections",
    "MUTATION_EXPECTED_RULE ld_diagonal_degree actual=ld_diagonal_point")
