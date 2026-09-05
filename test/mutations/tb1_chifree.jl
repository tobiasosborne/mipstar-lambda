const TB1_CHIFREE_MUTANT = Mutant(
    "TB1 M-chifree pi_prefix_off_by_one",
    "test/tb1_ld_sampler.jl",
    "        v_prime = ntuple(j -> j < i ? zero(TB1_F) : v[j], TB1_M)\n        axis_key",
    "        v_prime = ntuple(j -> j <= i ? zero(TB1_F) : v[j], TB1_M)\n        axis_key",
    "tb1_chifree")
