const TB1_QUESTION_ARITY_MUTANT = Mutant(
    "TB1 N5 question_format_accepts_any_arity",
    "src/verifiers/ldt.jl",
    "length(raw) == 2 * params.m + 1 && all(value -> value isa F, raw)",
    "length(raw) >= 0 && all(value -> value isa F, raw)",
    "tb1_decider_rejections")
