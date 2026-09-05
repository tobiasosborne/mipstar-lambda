const TB1_SPACE_SUM_MUTANT = Mutant(
    "TB1 N3 L_Point_sub_ambient_factor",
    "src/samplers/ldt.jl",
    "    ambient = collect(1:n)\n    CLStep(F, n, ambient, Int[], _projector_matrix(F, n, 1:dimension),\n           CLZero(F, n, Int[]))",
    "    CLStep(F, n, 1:dimension, dimension+1:n, _identity_matrix(F, dimension),\n           CLZero(F, n, dimension+1:n))",
    "tb1_space_sum")
