const TB1_LNF_MUTANT = Mutant(
    "TB1 M-lnf noncanonical_complement",
    "src/samplers/ldt.jl",
    "pivot = findfirst(!iszero, v)",
    "pivot = findlast(!iszero, v)",
    "tb1_histogram_diagonal")
