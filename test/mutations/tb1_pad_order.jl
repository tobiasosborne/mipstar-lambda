const TB1_PAD_ORDER_MUTANT = Mutant(
    "TB1 N5-pad-order pad_level_prepends_empty_stages",
    "src/samplers/typed.jl",
    "    result = _pad_top(L, target_level - level(L))",
    "    result = L\n    for _ in 1:(target_level - level(L))\n        result = _clstep(F, seed_dim(result), Int[], _register(result), zeros(F, 0, 0), result, BranchConst(result); require_ambient=false)\n    end",
    "tb1_levels")
