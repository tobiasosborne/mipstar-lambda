const TB1_LEVEL_MUTANT = Mutant(
    "TB1 M-level omit_inductive_increment",
    "src/samplers/cl.jl",
    "level(L::CLStep) = 1 + level(first(values(L.branches)))",
    "level(L::CLStep) = level(first(values(L.branches)))",
    "tb1_levels")
