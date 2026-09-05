using MIPStarLambda
P = PCPParams(2048, 11, 1, 11, 6, 16, 1)
fix = tb0_build_fixture(GF8, 6, ((0,1),(0,0),(0,0),(0,0),(0,0)), MonomialBudget(160_000))
orig = trivial_original_verifier(GF2048, P, fix.tf; n=2, T=1, Q_len=1, sigma=1, label=:tb0_trivial)
red = answer_reduce_pcp(orig, 1, 1, 1).term
types = red.sampler.types
println("NTYPES=", length(types))
println("TYPES=", join(string.(types), "|"))
sets = String[]
idx = Int[]
for l in types, r in types
    b = answer_reduce_guard_branches(red.decider, l, r)
    key = join(string.(b), "+")
    k = findfirst(==(key), sets)
    if k === nothing
        push!(sets, key); k = length(sets)
    end
    push!(idx, k - 1)
end
println("SETS=", join(sets, "|"))
println("IDX=", join(idx, ","))
