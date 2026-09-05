const TB2_ND4_MUTANT = Mutant(
    "TB2 ND4 answer_reduce_ld_checks_always_accept",
    "src/verifiers/answer_reduce.jl",
    "    result, (decider.params.q, dimension, decider.params.d, kappa)",
    "    CheckResult(true, :ld_axis_point), (decider.params.q, dimension, decider.params.d, kappa)",
    "tb2_sampler",
    "MUTATION_EXPECTED_RULE certificate rule=typed_answer_reduce_shape passed=false")
