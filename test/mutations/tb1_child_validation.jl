const TB1_CHILD_VALIDATION_MUTANT = Mutant(
    "TB1 NM2 child_skips_continuation_level_check",
    "src/samplers/cl.jl",
    "level(child) == level(L.child_shape) ||",
    "true ||",
    "tb1_levels")
