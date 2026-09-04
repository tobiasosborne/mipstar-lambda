const TB1_PI_MUTANT = Mutant(
    "TB1 M-π omit_prefix_projection",
    "src/samplers/ldt.jl",
    "for j in axis:dimension\n                projection[j, j] = one(F)",
    "for j in 1:dimension\n                projection[j, j] = one(F)",
    "tb1_histogram_diagonal")
