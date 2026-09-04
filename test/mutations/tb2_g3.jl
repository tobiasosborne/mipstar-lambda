const TB2_G3_MUTANT = Mutant(
    "TB2 g3_plus_one_individual_only",
    "src/verifiers/answer_reduce.jl",
    "value = _evaluate_individual(strategy.proof, kind.copy, question.point)\n        return (value,)",
    "value = _evaluate_individual(strategy.proof, kind.copy, question.point)\n        return (kind.copy == 3 ? value + one(value) : value,)",
    "tb2_proof_consistency",
    "MUTATION_EXPECTED_RULE proof_consistency actual=proof_consistency passed=false")
