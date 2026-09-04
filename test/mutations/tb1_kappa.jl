const TB1_KAPPA_MUTANT = Mutant(
    "TB1 M-kappa line_point_checks_first_entry_only",
    "src/verifiers/ldt.jl",
    "for j in 1:params.kappa\n        line_value = evaluate(line_answer[j], [t])",
    "for j in 1:1\n        line_value = evaluate(line_answer[j], [t])",
    "tb1_decider_rejections")
