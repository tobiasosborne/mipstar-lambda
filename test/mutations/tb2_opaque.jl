const TB2_OPAQUE_MUTANT = Mutant(
    "TB2 M9-pcp-opaque-branch dline_direction_stage_uses_closure",
    "src/samplers/pcp_sampler.jl",
    "                             BranchLnf(n, point, tail); require_ambient=false))",
    "                             OpaqueBranch(v_prime -> _clstep(F, n, point, Int[], L_lnf(v_prime), tail, BranchConst(tail); require_ambient=false)); require_ambient=false))",
    "tb2_describe",
    "MUTATION_EXPECTED_RULE describable actual=12/18")
