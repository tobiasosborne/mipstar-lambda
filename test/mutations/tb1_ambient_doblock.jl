const TB1_AMBIENT_DOBLOCK_MUTANT = Mutant(
    "TB1 NM3 doblock_constructor_skips_span_check",
    "src/samplers/cl.jl",
    "child_shape, OpaqueBranch(branch);\n            require_ambient=true)",
    "child_shape, OpaqueBranch(branch);\n            require_ambient=false)",
    "tb1_levels")
