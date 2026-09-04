const TB1_CHI_MUTANT = Mutant(
    "TB1 M-χ shift_bucket_boundary",
    "src/samplers/ldt.jl",
    "1 + div(Int(s.bits), q ÷ dimension)",
    "1 + div(mod(Int(s.bits) + 1, q), q ÷ dimension)",
    "tb1_histogram_axis")
