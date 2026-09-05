const TB2_TENSOR_MUTANT = Mutant(
    "TB2 N5 product_graph_cartesian_not_tensor",
    "src/samplers/oracularize.jl",
    "    graph = [(AnswerReduceType(l, r), AnswerReduceType(l2, r2))\n             for (l, l2) in ora_sampler.type_graph\n             for (r, r2) in pcp_sampler_term.type_graph]",
    "    graph = unique(vcat([(AnswerReduceType(l, r), AnswerReduceType(l, r2)) for l in ora_sampler.types for (r, r2) in pcp_sampler_term.type_graph], [(AnswerReduceType(l, r), AnswerReduceType(l2, r)) for (l, l2) in ora_sampler.type_graph for r in pcp_sampler_term.types]))",
    "tb2_sampler",
    "MUTATION_EXPECTED_RULE product_edges actual=1080")
