module MIPStarLambda

using Random
import Base: zero
Base.Experimental.@optlevel 1

include("certificates.jl")
include("fields/gf2k.jl")
include("polynomials/sparse.jl")
include("ir/circuits.jl")
include("polynomials/zero_basis.jl")
include("verifiers/pcp.jl")
include("tb0.jl")
include("traceprint.jl")

export GF2k, GF8, GF2048, field_size, field_elements, field_bytes,
       field_from_bytes, modulus_polynomial, is_irreducible_modulus,
       primitive_element, multiplicative_order

export VarBlock, VarLayout, DegreeDerivation, SupportReport, Poly,
       MonomialBudget, ExpansionRefused, polyvar, constant_poly, zero_poly,
       mul_poly, evaluate, polynomial_equal, monomial_count, expected_support,
       multiplication_peak, block_coordinates,
       structural_degrees, actual_degrees, degree_accounts_valid,
       dependency_coordinates, dependency_blocks, change_field, ind, g_a, dec, zero

export BWire, Input, Gate, NotGate, AndGate, OrGate, Circuit,
       Lit, FNot, FAnd, FOr, TseitinFormula, tb0_circuit,
       c8_two_gate_circuit, evaluate_circuit, gate_trace, phi_C, fanout,
       tseitin, evaluate_formula, evaluate_arith_formula, occurrences,
       tseitin_occurrence_account, arith_q

export RewriteStep, ZeroDecomposition, zero_basis_decompose,
       verify_rewrite_step, verify_zero_decomposition

export PredicateStatus, PASS, FAIL, NOT_EVALUABLE, PCPParams, ParameterPolicy,
       parameter_policy, policy_vector, minimal_checkable_odd_k,
       PCPProof, PrimeFieldPCPProof, PCPView, build_c0, build_pcp, lift_pcp,
       ev_z, pcp_eval, pcpverifier

export tb0_build_fixture, tb0_build_nondegenerate_fixture, tb0_base_point,
       pcp_coordinate_line_report, pcp_seeded_report, pcp_boolean_cube_report,
       pcp_agreement_report, tb0_layout_m2_report
export pcp_seeded_pair_report
export tb0_encoding_report
export tb0_truth_report
export tb0_pcp_certificate_report
export tb0_lift_direct_report
export tb0_c8_report
export tb0_print_degenerate_report
export tb0_degenerate_core_report

export Grade, CONSTRUCTED, CHECKED, CITED, ASSUMED, SOURCE_REPAIR,
       CheckResult, passed, CertNode, Checked, verify_certificate, traceprint

include("precompile.jl")

end
