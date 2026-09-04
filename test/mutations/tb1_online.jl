const TB1_ONLINE_MUTANT = Mutant(
    "TB1 N4 drop_point_on_line_verification",
    "src/verifiers/ldt.jl",
    "(line_point(line, t) == point, t)",
    "(true, t)",
    "tb1_decider_rejections")
