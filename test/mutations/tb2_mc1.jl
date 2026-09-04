const TB2_MC1_MUTANT = Mutant(
    "TB2 MC1 sampler_dline_skips_pi",
    "src/samplers/pcp_sampler.jl",
    "for i in axis:length(direction)\n            projection[i, i] = one(F)",
    "for i in 1:length(direction)\n            projection[i, i] = one(F)",
    "tb2_branches")
