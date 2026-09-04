const TB1_AGREEMENT_MUTANT = Mutant(
    "TB1 N1 line_point_test_always_agrees",
    "src/verifiers/ldt.jl",
    "line_value == point_value_j ||\n            return CheckResult(false, rule;",
    "true ||\n            return CheckResult(false, rule;",
    "tb1_decider_rejections")
