const TB1_DSUM_MUTANT = Mutant(
    "TB1 M-dsum direct_sum_forgets_stages",
    "src/samplers/cl.jl",
    "active = findall(node -> node isa CLStep{F}, nodes)",
    "active = findall(node -> false, nodes)",
    "tb1_levels")
