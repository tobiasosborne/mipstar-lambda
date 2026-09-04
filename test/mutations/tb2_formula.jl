const TB2_FORMULA_MUTANT = Mutant(
    "TB2 c0_plus_one_formula",
    "src/verifiers/answer_reduce.jl",
    "view = ev_z(strategy.proof, collect(question.point))\n            return (view.alpha..., view.beta0, view.beta...)",
    "view = ev_z(strategy.proof, collect(question.point))\n            return (view.alpha..., view.beta0 + one(view.beta0), view.beta...)",
    "tb2_formula",
    "MUTATION_EXPECTED_RULE pcpverifier actual=pcpverifier passed=false")
