const TB1_FACTOR_INDICATOR_MUTANT = Mutant(
    "TB1 M9-factor-not-indicator factor_returns_index_list",
    "src/samplers/cl.jl",
    "    indicator = zeros(Int, seed_dim(L))\n    for c in node.factor\n        indicator[c] = 1\n    end\n    indicator\n",
    "    copy(node.factor)\n",
    "tb1_queries")
