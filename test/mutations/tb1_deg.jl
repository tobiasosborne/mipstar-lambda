const TB1_DEG_MUTANT = Mutant(
    "TB1 M-deg axis_accepts_md",
    "src/verifiers/ldt.jl",
    "if kind == :ALine\n        params.d",
    "if kind == :ALine\n        params.m * params.d",
    "tb1_degree")
