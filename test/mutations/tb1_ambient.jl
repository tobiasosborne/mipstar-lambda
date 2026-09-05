const TB1_AMBIENT_MUTANT = Mutant(
    "TB1 M-ambient constructor_skips_span_check",
    "src/samplers/cl.jl",
    "matrix, child, BranchConst(child);\n            require_ambient=true)",
    "matrix, child, BranchConst(child);\n            require_ambient=false)",
    "tb1_levels")
