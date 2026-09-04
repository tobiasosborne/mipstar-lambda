# Cache the concrete TB0 hot path so every targeted test process does not pay
# the same sparse-algebra compilation cost.
for F in (Int, GF8, GF2048)
    P = Poly{F,16}
    precompile(_support_report, (Dict{NTuple{16,UInt8},F},))
    precompile(_multiply_terms, (Dict{NTuple{16,UInt8},F},
                                 Dict{NTuple{16,UInt8},F}))
    precompile(mul_poly, (P, P, MonomialBudget))
    precompile(zero_basis_decompose, (P, NTuple{16,Int}))
    precompile(arith_q, (TseitinFormula{16}, Type{F}, MonomialBudget))
    precompile(g_a, (Vector{F}, VarLayout{16}, Tuple{Int}))
    precompile(build_c0, (P, NTuple{5,P}, MonomialBudget))
end

precompile(verify_zero_decomposition,
           (Poly{GF8,16}, ZeroDecomposition{GF8,16}))
precompile(_verify_node, (CertNode, PCPProof{GF8,16}))
precompile(verify_certificate,
           (Checked{PCPProof{GF8,16},CertNode},))
for replay in (_replay_pcp_c0, _replay_pcp_zero,
               _replay_pcp_shape, _replay_pcp_degree)
    precompile(replay, (PCPProof{GF8,16},))
end
precompile(_shared_eval_plan, (NTuple{16,Poly{GF8,16}},))
precompile(_shared_eval_plan, (NTuple{16,Poly{GF2048,16}},))
precompile(build_pcp,
           (NTuple{5,Poly{GF8,16}}, Poly{GF8,16},
            Checked{ZeroDecomposition{GF8,16},CertNode}, Int))
precompile(build_pcp,
           (NTuple{5,Poly{GF2048,16}}, Poly{GF2048,16},
            Checked{ZeroDecomposition{GF2048,16},CertNode}, Int))
precompile(_evaluate_shared, (SharedEvalPlan{GF8,16}, Vector{GF8}))
precompile(_evaluate_shared_as,
           (SharedEvalPlan{GF8,16}, Vector{GF2048}))
precompile(ev_z, (PCPProof{GF8,16}, Vector{GF8}))
precompile(ev_z,
           (PrimeFieldPCPProof{GF2048,GF8,16}, Vector{GF2048}))
precompile(lift_pcp, (PCPProof{GF8,16}, Type{GF2048}, Int))
precompile(pcpverifier, (TseitinFormula{16}, PCPView{GF8,16}))
precompile(pcpverifier, (TseitinFormula{16}, PCPView{GF2048,16}))

const _TB0_TABLE_TYPE = NTuple{5,NTuple{2,Int}}
precompile(tb0_build_fixture,
           (Type{GF8}, Int, _TB0_TABLE_TYPE, MonomialBudget))
precompile(tb0_build_fixture,
           (Type{GF2048}, Int, _TB0_TABLE_TYPE, MonomialBudget))
precompile(tb0_build_nondegenerate_fixture,
           (Int, _TB0_TABLE_TYPE, MonomialBudget))
precompile(pcp_coordinate_line_report,
           (TseitinFormula{16}, PCPProof{GF8,16}, Vector{GF8}))
precompile(pcp_seeded_report,
           (TseitinFormula{16}, PrimeFieldPCPProof{GF2048,GF8,16},
            Type{GF2048}, Int, UInt64))
precompile(pcp_seeded_pair_report,
           (TseitinFormula{16}, PrimeFieldPCPProof{GF2048,GF8,16},
            PrimeFieldPCPProof{GF2048,GF8,16}, Int, UInt64))
precompile(pcp_boolean_cube_report,
           (TseitinFormula{16}, PCPProof{GF8,16}))
precompile(pcp_agreement_report,
           (PrimeFieldPCPProof{GF2048,GF8,16}, PCPProof{GF2048,16},
            Int, UInt64))
precompile(tb0_layout_m2_report, ())
precompile(tb0_encoding_report, ())
precompile(tb0_truth_report, ())
precompile(tb0_pcp_certificate_report,
           (Poly{GF8,16}, NTuple{5,Poly{GF8,16}}, Poly{GF8,16},
            ZeroDecomposition{GF8,16}, PCPProof{GF8,16}, CertNode))
precompile(tb0_lift_direct_report,
           (PCPProof{GF8,16}, _TB0_TABLE_TYPE, MonomialBudget,
            Int, UInt64))
precompile(tb0_c8_report, ())
precompile(tb0_print_degenerate_report,
           (Poly{GF8,16}, NTuple{5,Poly{GF8,16}}, Poly{GF8,16},
            ZeroDecomposition{GF8,16}, PCPProof{GF8,16}, CertNode,
            ParameterPolicy, ParameterPolicy, Float64, UInt64))
precompile(tb0_degenerate_core_report,
           (TseitinFormula{16}, Poly{GF8,16}, NTuple{5,Poly{GF8,16}},
            Poly{GF8,16}, ZeroDecomposition{GF8,16}))

const _TB0_M2_POLY = Poly{GF8,15}
precompile(zero_basis_decompose, (_TB0_M2_POLY, NTuple{15,Int}))
precompile(build_c0,
           (_TB0_M2_POLY, NTuple{5,_TB0_M2_POLY}, MonomialBudget))
precompile(_shared_eval_plan, (NTuple{15,_TB0_M2_POLY},))
precompile(build_pcp,
           (NTuple{5,_TB0_M2_POLY}, _TB0_M2_POLY,
            Checked{ZeroDecomposition{GF8,15},CertNode}, Int))
precompile(ev_z, (PCPProof{GF8,15}, Vector{GF8}))
precompile(pcpverifier, (TseitinFormula{15}, PCPView{GF8,15}))
