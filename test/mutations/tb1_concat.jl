const TB1_CONCAT_MUTANT = Mutant(
    "TB1 M-concat drops_left_level",
    "src/samplers/cl.jl",
    "concatenate(L::AbstractCL, R::AbstractCL) = concatenate(L, _ -> R)",
    "concatenate(L::AbstractCL, R::AbstractCL) = R",
    "tb1_levels")
