const TB1_VERIFIER_PI_MUTANT = Mutant(
    "TB1 N3 verifier_diagonal_line_skips_pi",
    "src/samplers/ldt.jl",
    "pi_prefix(direction, axis - 1))",
    "direction)",
    "tb1_decider_rejections")
