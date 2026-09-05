const TB1_REPLAY_SKIPS_K_MUTANT = Mutant(
    "TB1 M9-replay-skips-k map_sum_checked_at_last_stage_only",
    "src/samplers/cl.jl",
    "        for k in 1:ell\n            projected",
    "        for k in ell:ell\n            projected",
    "tb1_space_sum")
