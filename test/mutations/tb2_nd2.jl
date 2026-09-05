const TB2_ND2_MUTANT = Mutant(
    "TB2 ND2 product_direct_sum_order_swapped",
    "src/samplers/oracularize.jl",
    "        left[kind] = direct_sum(ora_sampler.left[kind.role],\n                                pcp_sampler_term.left[kind.pcp])\n        right[kind] = direct_sum(ora_sampler.right[kind.role],\n                                 pcp_sampler_term.right[kind.pcp])",
    "        left[kind] = direct_sum(pcp_sampler_term.left[kind.pcp],\n                                ora_sampler.left[kind.role])\n        right[kind] = direct_sum(pcp_sampler_term.right[kind.pcp],\n                                 ora_sampler.right[kind.role])",
    "tb2_sampler",
    "MUTATION_EXPECTED_RULE product_projection agrees=false")
