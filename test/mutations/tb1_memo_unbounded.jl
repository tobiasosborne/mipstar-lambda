const TB1_MEMO_UNBOUNDED_MUTANT = Mutant(
    "TB1 M9-memo-unbounded child_memo_never_evicts",
    "src/samplers/cl.jl",
    "    length(L.children) >= CL_MEMO_LIMIT && empty!(L.children)",
    "    false && empty!(L.children)",
    "tb1_memo")
