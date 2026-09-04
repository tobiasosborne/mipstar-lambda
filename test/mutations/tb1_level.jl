const TB1_LEVEL_MUTANT = Mutant(
    "TB1 M-level omit_inductive_increment",
    "src/samplers/cl.jl",
    "level(L::CLStep) = 1 + level(L.child_shape)",
    "level(L::CLStep) = level(L.child_shape)",
    "tb1_levels")
