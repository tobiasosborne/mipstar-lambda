const TB2_FORMULA_MUTANT = Mutant(
    "TB2 c0_plus_one_formula",
    "src/verifiers/answer_reduce.jl",
    "_tb2_bundle_point_entries(view::PCPView) =\n    (view.alpha..., view.beta0, view.beta...)",
    "_tb2_bundle_point_entries(view::PCPView) =\n    (view.alpha..., view.beta0 + one(view.beta0), view.beta...)",
    "tb2_formula")
