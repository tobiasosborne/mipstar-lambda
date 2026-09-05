# verdicts/tb1-r3.md N17: the dual of tb1_linear_narrowed — Factor stops
# rejecting prefixes outside L_{<j}(V).
const TB1_FACTOR_REACHABILITY_MUTANT = Mutant(
    "TB1 M9-factor-unreachable-accepted factor_accepts_unreachable_prefix",
    "src/samplers/cl.jl",
    "_prefix_vector(F, u); reachable=true)",
    "_prefix_vector(F, u); reachable=false)",
    "tb1_queries")
