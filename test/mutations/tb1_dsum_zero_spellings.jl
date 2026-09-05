# verdicts/tb1-r5.md N30: `direct_sum` no longer normalises whole-space zero
# summands, so full (+) empty lands on the proper sub-register (1,2,3) of
# F^5 and `pad_level` refuses it; owned by the N30 pins in `levels`.
const TB1_DSUM_ZERO_SPELLINGS_MUTANT = Mutant(
    "TB1 N30-dsum-zero-spellings direct_sum_keeps_concatenated_register",
    "src/samplers/cl.jl",
    "    if all(L -> L isa CLZero{F} && _whole_space_zero(L), functions)",
    "    if false",
    "tb1_levels",
    "MUTATION_EXPECTED_RULE dsum_zero_spellings promoted=false")
