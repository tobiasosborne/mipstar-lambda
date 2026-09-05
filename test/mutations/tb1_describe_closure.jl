const TB1_DESCRIBE_CLOSURE_MUTANT = Mutant(
    "TB1 M9-describe-closure describe_accepts_opaque_closure",
    "src/samplers/cl.jl",
    "_describe_branch(branch::OpaqueBranch) = throw(_OpaqueBranchError(branch))",
    "_describe_branch(branch::OpaqueBranch) = (:Const, (:Zero, 0, Int[]))",
    "tb1_describe")
