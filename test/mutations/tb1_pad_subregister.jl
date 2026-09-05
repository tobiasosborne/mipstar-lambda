# verdicts/tb1-r4.md N25: `_pad_top` promotes a top-level zero map on a
# proper sub-register instead of refusing it; owned by the @test_throws in
# the levels testset.
const TB1_PAD_SUBREGISTER_MUTANT = Mutant(
    "TB1 N25-pad-subregister top_level_subregister_zero_promoted",
    "src/samplers/typed.jl",
    "    _register(L) == 1:seed_dim(L) ||",
    "    true ||",
    "tb1_levels",
    "MUTATION_EXPECTED_RULE pad_subregister refused=false")
