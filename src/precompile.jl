# Keep the heavy TB0 inference outside the body clock. Copied mutation projects
# disable this list because each one exercises only one narrow target.
if get(ENV, "MIPSTAR_SKIP_EXPLICIT_PRECOMPILE", "0") != "1"
    const _TB0_TABLE_TYPE = NTuple{5,NTuple{2,Int}}
    precompile(tb0_build_fixture,
               (Type{GF8}, Int, _TB0_TABLE_TYPE, MonomialBudget))
    precompile(tb0_build_nondegenerate_fixture,
               (Int, _TB0_TABLE_TYPE, MonomialBudget))
    precompile(change_field, (PCPProof{GF8,16}, Type{GF2048}, Int))
    precompile(ev_z, (PCPProof{GF8,16}, Vector{GF8}))
    precompile(ev_z, (PCPProof{GF2048,16}, Vector{GF2048}))
end
