const TB2_MC3_MUTANT = Mutant(
    "TB2 MC3 simultaneous_test_uses_ldparams_not_ldparams_prime",
    "src/verifiers/answer_reduce.jl",
    "result, params = _ar_ld_check(decider, decider.params.m_prime,\n                    decider.params.m_prime + 6,",
    "result, params = _ar_ld_check(decider, decider.params.m_prime,\n                    1,",
    "tb2_branches",
    "MUTATION_EXPECTED_RULE branches first_failure=ld_answer_arity")
