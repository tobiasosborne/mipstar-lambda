# verdicts/tb2-r4.md N26: decode_cl stops re-imposing the top stage's
# ambient partition; owned by the nonspanning-description refusal.
const TB1_DECODE_AMBIENT_MUTANT = Mutant(
    "TB1 N26-decode-ambient decode_skips_ambient_partition",
    "src/samplers/cl.jl",
    "    (L isa CLZero || _register(L) == 1:n) ||",
    "    true ||",
    "tb1_describe",
    "MUTATION_EXPECTED_RULE decode_ambient refused=false")
