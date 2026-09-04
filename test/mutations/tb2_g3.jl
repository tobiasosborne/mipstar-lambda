const TB2_G3_MUTANT = Mutant(
    "TB2 g3_plus_one_individual_only",
    "src/verifiers/answer_reduce.jl",
    "_tb2_individual_point_entry(value, copy::Int) = value",
    "_tb2_individual_point_entry(value, copy::Int) = copy == 3 ? value + one(value) : value",
    "tb2_proof_consistency")
