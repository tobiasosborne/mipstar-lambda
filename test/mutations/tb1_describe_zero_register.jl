# verdicts/tb1-r4.md N26 (NM13): a CLZero term drops its register; owned by
# the CLZero(F,5,(2,)) register round trip and the full/empty byte separation.
const TB1_DESCRIBE_ZERO_REGISTER_MUTANT = Mutant(
    "TB1 N26-describe-zero-register zero_term_drops_register",
    "src/samplers/cl.jl",
    "_describe_term(L::CLZero) = (:Zero, L.seed_dim, copy(L.indices))",
    "_describe_term(L::CLZero) = (:Zero, L.seed_dim, Int[])",
    "tb1_describe",
    "MUTATION_EXPECTED_RULE describe_zero_register ok=false")
