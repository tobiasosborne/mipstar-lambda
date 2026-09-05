module MIPStarLambda

using Random
import Base: zero
Base.Experimental.@optlevel 1

include("certificates.jl")
include("fields/gf2k.jl")
include("polynomials/sparse.jl")
include("ir/circuits.jl")
include("polynomials/zero_basis.jl")
include("samplers/cl.jl")
include("ir/programs.jl")
include("samplers/typed.jl")
include("samplers/ldt.jl")
include("verifiers/pcp.jl")
include("samplers/pcp_sampler.jl")
include("samplers/oracularize.jl")
include("verifiers/ldt.jl")
include("verifiers/answer_reduce.jl")
include("tb0.jl")
include("frontend/bounded_trace.jl")
include("frontend/cook_levin.jl")
include("frontend/decouple5.jl")
include("traceprint.jl")
include("compress.jl")

export Program, BoundExpr, Concrete, Opaque, Fuel, FuelLiteral, FuelBound,
       BoundVar, Hole, Lambda, Apply, Fix, YCode, If, Prim, Quote, Eval, Specialize,
       is_closed, is_scoped, holes, substitute, term_bytes, term_size,
       decode_term, program_equal, Quoted, decode_program, program, quote_hash,
       quote_program, specialize, Closure, Code, Value, OutOfFuel, SortError,
       Aborted, encoded_size, eval_overhead, eval_program, eval_quoted,
       program_label, value_label, PRIMITIVES, DECLARED_SORTS, FUNCTION_SORTS,
       sort_of, Verifier, description_length, DECIDER_ARITY, DECIDER_ARGUMENT_SORTS,
       decider_input_sorted

export nat, machine_desc, TWO_STATE_HALTING, TWO_STATE_LOOPING, SAMPLER_STUB,
       TRIVIAL_DECIDER, COMPRESS_STUB, COMPRESS_IDENTITY, FIX_TAG_BYTES,
       FIX_UNFOLD_CHARGE, psi_template, fix_specialize, halting_decider,
       fix_unfolding, halting_verifier, bind_parameter, free_parameters,
       StubVerifier, Hypothesis, Contract, INTROSPECT_CONTRACT,
       ANSWER_REDUCE_CONTRACT, REPEAT_CONTRACT, COMPRESS_CONTRACT,
       INDEPENDENT_SAMPLERS_LEMMA, introspect_levels, answer_reduce_levels,
       repeat_levels, COMPRESS_LEVELS, CompressStage, IntrospectStub, RepeatStub,
       AnswerReduceOnFixture, CompressStages, FrontEndFixture, frontend_fixture,
       tb4_stages, AnswerReduceEvidence, Introspect, Repeat, Compress,
       level_chain, runtime_composition_ok

export TraceRow, BoundedTrace, bounded_trace, Clause3, Tableau, Succinct3SAT,
       CompilationRefused, dpll, compile_relation, relation_input, relation_tuples,
       clause_present, present_clauses, satisfies, satisfiable, cook_levin,
       Clause5, SuccinctDecoupled5SAT, PaddedSuccinctDecoupled5SAT,
       clause_present5, literal_blocks, satisfiable5, satisfies5, decouple5,
       pad5, frontend_witness_tables, frontend_c0_estimate, frontend_pcp

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

export AbstractCL, CLZero, CLStep, CLMarginal, apply, level, seed_dim,
       register_indices, marginal_k, sum_stage_outputs, concatenate, direct_sum,
       CLDistribution, distribution, enumerate_seeds, histogram, product, pad_level,
       TypedSampler, sample, edge_index,
       AbstractBranch, QuotedBranch, OpaqueBranch, BranchConst, BranchByAxis,
       BranchLnf, BranchPadded, CL_MEMO_LIMIT, memo_report,
       Dimension, Marginal, Linear, Factor, cl_kth_replay,
       CLDescription, NotDescribable, describe_cl, canonical_bytes,
       description_size, decode_cl, ZERO_MAP_FACTOR_PARTITION, pad_level_evidence

export AffineLine, L_lnf, chi, pi_prefix, L_Point, L_ALine, L_DLine,
       point_value, axis_line, diagonal_line, line_point,
       diagonal_histogram_evidence,
       LDParams, restrict, univariate_degree, ld_decider, ld_off_line_repair,
       ld_honest_answer, ld_honest_sweep, ld_sweep_evidence

export PCPType, PCPRegisterLayout, PCPPointQuestion, PCPALineQuestion,
       PCPDLineQuestion, pcp_sampler, pcp_register_dimensions,
       intrinsic_pcp_levels, sample_pcp_question, pcp_question_from_ambient,
       parse_pcp_question,
       encode_pcp_question, parse_pcp_answer, encode_pcp_answer,
       pcp_ld_question, tb2_parser_roundtrip_report

export ORACULAR_ROLES, AnswerReduceType, trivial_original_sampler,
       oracularize_sampler, typed_sampler_product, tb2_sampler_invariant_report

export PredicateStatus, PASS, FAIL, NOT_EVALUABLE, PCPParams, ParameterPolicy,
       parameter_policy, policy_vector, minimal_checkable_odd_k,
       PCPProof, PCPView, build_c0, build_pcp, ev_z, pcpverifier, upstream_circuit

export TrivialOriginalVerifier, TypedAnswerReducedDecider,
       TypedAnswerReducedVerifier, CitedDetypedVerifier,
       AnswerReduceQuestion, HonestPCPStrategy, PCPGameCall,
       PCPDeciderSpecification, pcp_decider_specification,
       AnswerReduceTraceEntry, AnswerReduceDecision,
       trivial_original_verifier, answer_reduce_pcp, detype, AnswerReduce,
       sample_answer_reduce_questions, honest_pcp_strategy,
       honest_pcp_answer, typed_answer_reduced_decider,
       answer_reduce_guard_branches, answer_reduce_requires_nondegenerate,
       proof_individual_guard_copies

export build_pcp_fixture, tb0_build_fixture, tb0_build_nondegenerate_fixture,
       layout_m2_circuit, LAYOUT_M2_TABLES, layout_m2_point,
       tb0_base_point, tb0_certified_points

export Grade, CONSTRUCTED, CHECKED, CITED, ASSUMED, SOURCE_REPAIR,
       CheckResult, passed, CertNode, Checked, verify_certificate, traceprint

include("precompile.jl")
include("frontend/precompile_frontend.jl")

end
