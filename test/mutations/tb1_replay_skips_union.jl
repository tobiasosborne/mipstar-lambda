const TB1_REPLAY_SKIPS_UNION_MUTANT = Mutant(
    "TB1 M9-replay-skips-union space_sum_ignores_coverage",
    "src/samplers/cl.jl",
    "        space_sum_ok &= all(==(1), coverage)",
    "        space_sum_ok &= true",
    "tb1_space_sum")
