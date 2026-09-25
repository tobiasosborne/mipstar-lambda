# Compress(TB7) certificate tree

Construction: Repeat ∘ AnswerReduce ∘ Introspect; λ=32768, n=2; ToyPolicy; `P_pcp_encodes_D1=FAIL`, non-Pauli schemas `VACUOUS`.
Census: 317 nodes; CONSTRUCTED=34, CHECKED=133, CITED=70, ASSUMED=62, SOURCE_REPAIR=18.
CITED theorem-like labels: cor:pauli-binary, lem:cl-concat, lem:cl-dist-prod, lem:cl-downsize, lem:cl-func-prod, lem:cl-kth, lem:compress-independent-samplers, lem:delta-bound, lem:detyping-verifiers, lem:dhalt-values, lem:downsize-cl-dist, lem:downsize_sampler, lem:downsize_typed_sampler, lem:intro-decider-complexity, lem:intro-sampler-complexity, lem:introparams-complexity, lem:lambda, lem:ld-complexity, lem:ld-soundness, lem:pauli-completeness, lem:perp_perp, lem:qld-complexity, prop:anchoring, prop:explicit-padded-succinct-deciders, prop:standard-succinct-sat, thm:ar, thm:bvy, thm:compression, thm:halting, thm:introspection, thm:oracle-completeness, thm:oracle-soundness, thm:pauli, thm:pcp-decider, thm:repetition.
Actual fixed-width D1 front end: sigma_1=67648 bytes; Cook–Levin index width=3, 3SAT clauses=10, decoupled 5SAT clauses=38; fixture index width=1.

## Complete tree

```text
CONSTRUCTED CompressOnDescriptions
├─ CHECKED ConstructorOrder
├─ CHECKED UniversalConstants
├─ CHECKED IntroGap
│  ├─ CHECKED IntroGapFloor
│  └─ CITED thm:introspection  [gt-08-introspection.tex:809-815]
├─ CHECKED Bookkeeping
│  ├─ CHECKED LawCert
│  ├─ CHECKED LawCert
│  ├─ CHECKED LawCert
│  ├─ CHECKED LawCert
│  ├─ CHECKED LawCert
│  └─ CHECKED LawCert
├─ CHECKED FixedWidthSigma
├─ SOURCE_REPAIR IntroDeciderFixedWidth
├─ CHECKED CodeDependencyIndependence
├─ ASSUMED toy_override
│  ├─ ASSUMED input_field_level_lambda_bounded_n_2
│  ├─ ASSUMED intro_field_admissible_m_I_divides_q_I_d_I_1
│  ├─ ASSUMED intro_embedding_Q_I_s_0_N_2_9
│  ├─ ASSUMED intro_canonical_tuple_equality_source_M_I_R
│  ├─ ASSUMED non_Pauli_introspection_answer_schemas_Introspect_Sample_Read_every_Hide_stage_both_roles_
│  ├─ ASSUMED AR_P_shape_P_formula_paper_P_tail_P_divisibility_P_degree_structural_formula_check
│  ├─ ASSUMED AR_P_growth_universal_mu_gamma_tau_n_C_0
│  ├─ ASSUMED AR_tuple_equals_pcpparams_n_T_Q_sigma_gamma_
│  ├─ ASSUMED P_pcp_encodes_D1_PCP_instance_arithmetizes_the_actual_fixed_width_D1_trace_at_printed_T_sigma_1_
│  ├─ ASSUMED enu_ar_game_against_the_actual_D1
│  ├─ ASSUMED fixed_width_sigma_1_length_canonical_bytes_D1_printed_as_an_exact_integer
│  ├─ ASSUMED repeat_k_toy_lambda_n_1_c_tau_
│  ├─ ASSUMED repeat_question_and_answer_component_guard
│  ├─ CHECKED PolicyGradeValidation
│  └─ CHECKED ToyContractAudit
├─ CHECKED ChainCoverage
├─ CONSTRUCTED ResidueFilter
├─ CONSTRUCTED ResidueLeaves
│  ├─ CITED lem:pauli-completeness  [gt-07-ldt.tex:1232-1330]
│  ├─ CITED cor:pauli-binary  [gt-07-ldt.tex:1470-1490]
│  ├─ CITED lem:delta-bound  [gt-07-ldt.tex:1521-1560]
│  ├─ CITED lem:introparams-complexity  [gt-07-ldt.tex:1565-1576]
│  ├─ CITED lem:qld-complexity  [gt-07-ldt.tex:1577-1600]
│  ├─ CITED thm:bvy  [gt-11-parallel-repetition.tex:51-61]
│  ├─ CITED lem:dhalt-values  [gt-12-compression.tex:502-519]
│  ├─ CITED lem:lambda  [gt-12-compression.tex:569-576]
│  └─ CITED thm:halting  [gt-12-compression.tex:643-720]
├─ CHECKED OutputBinding
├─ CONSTRUCTED Compress
│  ├─ CHECKED LevelChain
│  ├─ CHECKED RuntimeComposition
│  ├─ CHECKED SamplerIndependence
│  ├─ SOURCE_REPAIR IntroDeciderFixedWidth
│  ├─ ASSUMED ToyUniversalConstants
│  ├─ ASSUMED lambda_bounded_description
│  ├─ ASSUMED lambda_bounded_time
│  ├─ ASSUMED nine_level
│  ├─ ASSUMED normal_form
│  ├─ ASSUMED n_at_least_C0
│  ├─ CHECKED HypothesisAudit
│  ├─ CITED thm:compression  [gt-12-compression.tex:26-53]
│  ├─ CITED lem:compress-independent-samplers  [gt-12-compression.tex:108-118]
│  └─ CONSTRUCTED Repeat
│     ├─ CONSTRUCTED Repeat
│     │  ├─ ASSUMED normal_form
│     │  ├─ ASSUMED completeness_decider_time
│     │  ├─ CHECKED HypothesisAudit
│     │  ├─ CITED thm:repetition  [gt-11-parallel-repetition.tex:229-258]
│     │  ├─ ASSUMED UniversalConstantBound
│     │  ├─ SOURCE_REPAIR RepetitionCountInconsistency
│     │  ├─ SOURCE_REPAIR RepeatGuardExponent
│     │  ├─ SOURCE_REPAIR RepeatTupleFraming
│     │  ├─ CHECKED SamplerIndependence
│     │  ├─ CONSTRUCTED DL9-repeat-toy
│     │  │  ├─ CHECKED LawCert
│     │  │  ├─ CHECKED DescriptionSize
│     │  │  ├─ CHECKED DependencySet
│     │  │  ├─ CHECKED SamplerValidity
│     │  │  ├─ CHECKED MeteredCalls
│     │  │  ├─ ASSUMED KRepIntegrality
│     │  │  ├─ ASSUMED ToyRepetitionCount
│     │  │  ├─ CITED lem:cl-func-prod  [gt-04-cl.tex:315-327]
│     │  │  └─ CITED lem:cl-kth  [gt-04-cl.tex:151-180]
│     │  ├─ CONSTRUCTED RepeatDeciderDescription
│     │  │  ├─ CHECKED RepeatDecider
│     │  │  ├─ CHECKED DescriptionSize
│     │  │  └─ CHECKED DependencySet
│     │  └─ CONSTRUCTED Anchor
│     │     ├─ CITED prop:anchoring  [gt-11-parallel-repetition.tex:112-136]
│     │     └─ CONSTRUCTED Detype
│     │        ├─ CITED lem:detyping-verifiers  [gt-06-types.tex:444-475]
│     │        ├─ CONSTRUCTED DL9-detype
│     │        │  ├─ CHECKED LawCert
│     │        │  ├─ CHECKED DescriptionSize
│     │        │  ├─ CHECKED DependencySet
│     │        │  ├─ CHECKED SamplerValidity
│     │        │  ├─ CHECKED MeteredCalls
│     │        │  ├─ CITED lem:detyping-verifiers  [gt-06-types.tex:444-475]
│     │        │  ├─ CITED lem:cl-concat  [gt-04-cl.tex:282-292]
│     │        │  ├─ CITED lem:cl-kth  [gt-04-cl.tex:151-180]
│     │        │  └─ CONSTRUCTED DL9-anchor
│     │        │     ├─ CHECKED LawCert
│     │        │     ├─ CHECKED DescriptionSize
│     │        │     ├─ CHECKED DependencySet
│     │        │     ├─ CHECKED SamplerValidity
│     │        │     │  └─ SOURCE_REPAIR zero_map_factor_partition
│     │        │     ├─ CHECKED MeteredCalls
│     │        │     ├─ SOURCE_REPAIR AnchorFactorReport
│     │        │     ├─ CHECKED pad_level
│     │        │     │  └─ SOURCE_REPAIR zero_map_factor_partition
│     │        │     ├─ CITED def:typed-sampler  [gt-06-types.tex:95-140]
│     │        │     └─ CITED lem:cl-kth  [gt-04-cl.tex:151-180]
│     │        └─ CONSTRUCTED DetypeDeciderDescription
│     │           ├─ CHECKED DetypeDecider
│     │           ├─ CHECKED DescriptionSize
│     │           ├─ CHECKED DependencySet
│     │           └─ CONSTRUCTED TypedAnchorDeciderDescription
│     │              ├─ CHECKED TypedAnchorDecider
│     │              ├─ CHECKED DescriptionSize
│     │              └─ CHECKED DependencySet
│     └─ CONSTRUCTED AnswerReduce
│        ├─ CONSTRUCTED AnswerReduce
│        │  ├─ ASSUMED normal_form
│        │  ├─ ASSUMED decider_time_T
│        │  ├─ ASSUMED sampler_time_Q
│        │  ├─ CHECKED HypothesisAudit
│        │  ├─ CITED thm:ar  [gt-10-answer-reduction.tex:2077-2116]
│        │  ├─ SOURCE_REPAIR AR_field_align
│        │  ├─ ASSUMED toy_override
│        │  │  ├─ ASSUMED AR_P_shape_P_formula_paper_P_tail_P_divisibility_P_degree_structural_formula_check
│        │  │  ├─ ASSUMED AR_P_growth_universal_mu_gamma_tau_n_C_0
│        │  │  ├─ ASSUMED AR_tuple_equals_pcpparams_n_T_Q_sigma_gamma_
│        │  │  └─ ASSUMED fixed_width_sigma_1_length_canonical_bytes_D1_printed_as_an_exact_integer
│        │  ├─ ASSUMED ARGameNotExecuted
│        │  ├─ ASSUMED P_pcp_encodes_D1
│        │  │  └─ CHECKED Decouple5
│        │  │     ├─ CHECKED CookLevin
│        │  │     │  ├─ CHECKED BoundedTrace
│        │  │     │  │  └─ CHECKED Quote
│        │  │     │  └─ CITED CookLevinGeneral  [gt-10-answer-reduction.tex:237-273]
│        │  │     ├─ ASSUMED RawAnswerBlocks
│        │  │     └─ ASSUMED PerIndexEqualityGadgets
│        │  ├─ CHECKED AnswerReduceStepsAgreement
│        │  ├─ ASSUMED PCPFixtureLocalOnly
│        │  │  └─ CHECKED PCPProof
│        │  │     ├─ CHECKED UpstreamEvidence
│        │  │     │  ├─ CHECKED Pad5
│        │  │     │  │  └─ CHECKED Decouple5
│        │  │     │  │     ├─ CHECKED CookLevin
│        │  │     │  │     │  ├─ CHECKED BoundedTrace
│        │  │     │  │     │  │  └─ CHECKED Quote
│        │  │     │  │     │  └─ CITED CookLevinGeneral  [gt-10-answer-reduction.tex:237-273]
│        │  │     │  │     ├─ ASSUMED RawAnswerBlocks
│        │  │     │  │     └─ ASSUMED PerIndexEqualityGadgets
│        │  │     │  └─ CONSTRUCTED UpstreamReproduction
│        │  │     ├─ CHECKED Tseitin
│        │  │     ├─ CHECKED ArithTseitin
│        │  │     ├─ CHECKED MultilinearExtension
│        │  │     ├─ CHECKED MultilinearExtension
│        │  │     ├─ CHECKED MultilinearExtension
│        │  │     ├─ CHECKED MultilinearExtension
│        │  │     ├─ CHECKED MultilinearExtension
│        │  │     ├─ CHECKED BuildC0
│        │  │     ├─ CHECKED ZeroBasis
│        │  │     └─ CHECKED PCPVerifier
│        │  ├─ CITED lem:cl-dist-prod  [gt-04-cl.tex:366-383]
│        │  ├─ CITED lem:cl-downsize  [gt-04-cl.tex:410-438]
│        │  ├─ CITED lem:downsize_typed_sampler  [gt-06-types.tex:153-178]
│        │  ├─ CITED lem:downsize-cl-dist  [gt-04-cl.tex:533-550]
│        │  ├─ CITED lem:perp_perp  [gt-03-prelim.tex:263-270]
│        │  ├─ CONSTRUCTED DL9-detype
│        │  │  ├─ CHECKED LawCert
│        │  │  ├─ CHECKED DescriptionSize
│        │  │  ├─ CHECKED DependencySet
│        │  │  ├─ CHECKED SamplerValidity
│        │  │  ├─ CHECKED MeteredCalls
│        │  │  ├─ CITED lem:detyping-verifiers  [gt-06-types.tex:444-475]
│        │  │  ├─ CITED lem:cl-concat  [gt-04-cl.tex:282-292]
│        │  │  ├─ CITED lem:cl-kth  [gt-04-cl.tex:151-180]
│        │  │  └─ CONSTRUCTED DL9-product
│        │  │     ├─ CHECKED LawCert
│        │  │     ├─ CHECKED DescriptionSize
│        │  │     ├─ CHECKED DependencySet
│        │  │     ├─ CHECKED SamplerValidity
│        │  │     ├─ CHECKED MeteredCalls
│        │  │     ├─ CITED lem:cl-func-prod  [gt-04-cl.tex:315-327]
│        │  │     ├─ CITED thm:ar  [gt-10-answer-reduction.tex:2077-2116]
│        │  │     ├─ CITED lem:cl-kth  [gt-04-cl.tex:151-180]
│        │  │     ├─ CONSTRUCTED DL9-oracularize
│        │  │     │  ├─ CHECKED LawCert
│        │  │     │  ├─ CHECKED DescriptionSize
│        │  │     │  ├─ CHECKED DependencySet
│        │  │     │  ├─ CHECKED SamplerValidity
│        │  │     │  ├─ CHECKED MeteredCalls
│        │  │     │  ├─ CITED sec:orac-def  [gt-09-oracularization.tex:34-86]
│        │  │     │  ├─ CITED thm:oracle-completeness  [gt-09-oracularization.tex:125-169]
│        │  │     │  ├─ CITED thm:oracle-soundness  [gt-09-oracularization.tex:296-329]
│        │  │     │  └─ CITED lem:cl-kth  [gt-04-cl.tex:151-180]
│        │  │     └─ CONSTRUCTED DL9-pad
│        │  │        ├─ CHECKED LawCert
│        │  │        ├─ CHECKED DescriptionSize
│        │  │        ├─ CHECKED DependencySet
│        │  │        ├─ CHECKED SamplerValidity
│        │  │        ├─ CHECKED MeteredCalls
│        │  │        ├─ CITED rk:higher-level  [gt-04-cl.tex:122-130]
│        │  │        ├─ CITED lem:cl-kth  [gt-04-cl.tex:151-180]
│        │  │        └─ CONSTRUCTED DL9-downsize
│        │  │           ├─ CHECKED LawCert
│        │  │           ├─ CHECKED DescriptionSize
│        │  │           ├─ CHECKED DependencySet
│        │  │           ├─ CHECKED SamplerValidity
│        │  │           ├─ CHECKED MeteredCalls
│        │  │           ├─ CITED lem:downsize_sampler  [gt-04-cl.tex:628-680]
│        │  │           ├─ CITED lem:cl-kth  [gt-04-cl.tex:151-180]
│        │  │           └─ CONSTRUCTED PCPSampler
│        │  │              ├─ CHECKED LawCert
│        │  │              ├─ CHECKED DescriptionSize
│        │  │              ├─ CHECKED DependencySet
│        │  │              ├─ CHECKED SamplerValidity
│        │  │              ├─ CHECKED MeteredCalls
│        │  │              ├─ CITED thm:pcp-decider  [gt-10-answer-reduction.tex:1455-1533]
│        │  │              ├─ CITED lem:ld-soundness  [gt-07-ldt.tex:413-490]
│        │  │              ├─ CITED lem:ld-complexity  [gt-07-ldt.tex:413-490]
│        │  │              ├─ CITED prop:explicit-padded-succinct-deciders  [gt-10-answer-reduction.tex:1226-1275]
│        │  │              ├─ CITED prop:standard-succinct-sat  [gt-10-answer-reduction.tex:237-276]
│        │  │              ├─ CITED def:typed-sampler  [gt-06-types.tex:95-140]
│        │  │              └─ CITED lem:cl-kth  [gt-04-cl.tex:151-180]
│        │  └─ CONSTRUCTED DetypeDeciderDescription
│        │     ├─ CHECKED DetypeDecider
│        │     ├─ CHECKED DescriptionSize
│        │     ├─ CHECKED DependencySet
│        │     └─ CONSTRUCTED AnswerReduceDeciderDescription
│        │        ├─ CHECKED AnswerReduceDecider
│        │        ├─ CHECKED DescriptionSize
│        │        ├─ CHECKED DependencySet
│        │        ├─ CITED thm:ar  [gt-10-answer-reduction.tex:2077-2116]
│        │        └─ CITED thm:pcp-decider  [gt-10-answer-reduction.tex:1455-1533]
│        └─ CONSTRUCTED Introspect
│           ├─ CONSTRUCTED Introspect
│           │  ├─ ASSUMED lambda_bounded_description
│           │  ├─ ASSUMED lambda_bounded_time
│           │  ├─ ASSUMED ell_level
│           │  ├─ CHECKED HypothesisAudit
│           │  ├─ CITED thm:introspection  [gt-08-introspection.tex:784-817]
│           │  ├─ ASSUMED toy_override
│           │  │  ├─ ASSUMED R_at_least_4
│           │  │  ├─ ASSUMED admissible_field
│           │  │  ├─ ASSUMED m_divides_q
│           │  │  ├─ ASSUMED d_equals_1
│           │  │  ├─ ASSUMED capacity_s_le_R
│           │  │  ├─ ASSUMED capacity_M_ge_R
│           │  │  ├─ ASSUMED capacity_M_le_Q
│           │  │  ├─ ASSUMED consequent_Q_ge_R
│           │  │  ├─ ASSUMED embedding_Q_ge_s
│           │  │  ├─ ASSUMED canonical_introparams
│           │  │  ├─ ASSUMED description_le_lambda
│           │  │  ├─ ASSUMED TIME_child_Dimension_le_R
│           │  │  ├─ ASSUMED TIME_child_Marginal_le_R
│           │  │  ├─ ASSUMED TIME_child_Factor_le_R
│           │  │  ├─ ASSUMED TIME_child_Linear_le_R
│           │  │  ├─ ASSUMED TIME_child_Decider_le_R
│           │  │  ├─ ASSUMED low_degree_margin
│           │  │  └─ ASSUMED hiding_same_guard_set
│           │  ├─ SOURCE_REPAIR intro_3Q_guard
│           │  ├─ SOURCE_REPAIR intro_hide_suffix_register
│           │  ├─ SOURCE_REPAIR intro_perp_orthogonal
│           │  ├─ CHECKED SamplerIndependence
│           │  └─ CONSTRUCTED Detype
│           │     ├─ CITED lem:detyping-verifiers  [gt-06-types.tex:444-475]
│           │     ├─ CONSTRUCTED DL9-detype
│           │     │  ├─ CHECKED LawCert
│           │     │  ├─ CHECKED DescriptionSize
│           │     │  ├─ CHECKED DependencySet
│           │     │  ├─ CHECKED SamplerValidity
│           │     │  ├─ CHECKED MeteredCalls
│           │     │  ├─ CITED lem:detyping-verifiers  [gt-06-types.tex:444-475]
│           │     │  ├─ CITED lem:cl-concat  [gt-04-cl.tex:282-292]
│           │     │  ├─ CITED lem:cl-kth  [gt-04-cl.tex:151-180]
│           │     │  └─ CONSTRUCTED DL9-downsize
│           │     │     ├─ CHECKED LawCert
│           │     │     ├─ CHECKED DescriptionSize
│           │     │     ├─ CHECKED DependencySet
│           │     │     ├─ CHECKED SamplerValidity
│           │     │     ├─ CHECKED MeteredCalls
│           │     │     ├─ CITED lem:downsize_sampler  [gt-04-cl.tex:628-680]
│           │     │     ├─ CITED lem:cl-kth  [gt-04-cl.tex:151-180]
│           │     │     └─ CONSTRUCTED TildeSIntro
│           │     │        ├─ CHECKED LawCert
│           │     │        ├─ CHECKED DescriptionSize
│           │     │        ├─ CHECKED DependencySet
│           │     │        ├─ CHECKED SamplerValidity
│           │     │        │  └─ SOURCE_REPAIR zero_map_factor_partition
│           │     │        ├─ CHECKED MeteredCalls
│           │     │        ├─ CHECKED GraphTranscription
│           │     │        ├─ SOURCE_REPAIR zero_map_factor_report
│           │     │        ├─ CHECKED pad_level
│           │     │        │  └─ SOURCE_REPAIR zero_map_factor_partition
│           │     │        ├─ CITED lem:intro-sampler-complexity  [gt-08-introspection.tex:347-392]
│           │     │        ├─ CITED fig:type-graph-pauli  [gt-07-ldt.tex:1012-1068]
│           │     │        ├─ CITED def:typed-sampler  [gt-06-types.tex:95-140]
│           │     │        └─ CITED lem:cl-kth  [gt-04-cl.tex:151-180]
│           │     └─ CONSTRUCTED DetypeDeciderDescription
│           │        ├─ CHECKED DetypeDecider
│           │        ├─ CHECKED DescriptionSize
│           │        ├─ CHECKED DependencySet
│           │        └─ CONSTRUCTED IntroDeciderDescription
│           │           ├─ CHECKED IntroDecider
│           │           ├─ CHECKED DescriptionSize
│           │           ├─ CHECKED DependencySet
│           │           ├─ CITED fig:intro-decider  [gt-08-introspection.tex:394-500]
│           │           ├─ CITED lem:intro-decider-complexity  [gt-08-introspection.tex:694-776]
│           │           ├─ CITED fig:decider_pauli  [gt-07-ldt.tex:1126-1227]
│           │           ├─ CITED thm:pauli  [gt-07-ldt.tex:1426-1447]
│           │           ├─ CITED def:cl-canonical  [gt-03-prelim.tex:375-384]
│           │           ├─ CITED def:Lperp  [gt-03-prelim.tex:386-392]
│           │           ├─ SOURCE_REPAIR intro_3Q_guard
│           │           ├─ SOURCE_REPAIR intro_hide_suffix_register
│           │           └─ SOURCE_REPAIR intro_perp_orthogonal
│           └─ CONSTRUCTED Verifier
└─ CHECKED ResidueInventory
```

## Predicate report

```text
input field/level/lambda bounded; n>=2 | PASS
intro field admissible, m_I divides q_I, d_I=1 | PASS
intro embedding Q_I>=s_0(N): 2>=9 | FAIL(owner=Q_I<s_0)
intro canonical tuple equality; source M_I>=R | FAIL
non-Pauli introspection answer schemas: Introspect, Sample, Read, every Hide stage (both roles) | VACUOUS(owner=Q_I<s_0)
AR P_shape, P_formula_paper, P_tail, P_divisibility, P_degree, structural formula check | PASS
AR P_growth, universal mu/gamma/tau, n>=C_0 | NOT_EVALUABLE
AR tuple equals pcpparams(n,T,Q,sigma,gamma) | FAIL
P_pcp_encodes_D1: PCP instance arithmetizes the actual fixed-width D1 trace at printed (T,sigma_1) | FAIL(owner=pcpverifier-D1-trace)
enu:ar-game against the actual D1 | NOT_EXECUTED(owner=pcpverifier-D1-trace)
fixed-width sigma_1=length(canonical_bytes(D1)) printed as an exact integer | PASS
repeat k_toy=(lambda*n)^((1+c')tau) | FAIL
repeat question and answer component guard | PASS
```

## Per-sampler chain/replay counts

```text
    DL9-repeat-toy 232697784bfd7f0c tb5-rng4(0x5a)@n=2                           selected=4 views=2 distinct=8 replayed=8
        DL9-detype 5c450e5fe8ecc354 tb5-rng4(0x5a)@n=2                           selected=4 views=2 distinct=7 replayed=8
        DL9-anchor 3ea107609a57499e tb5-rng4(0x5a)@n=2                           selected=4 views=4 distinct=10 replayed=16
        DL9-detype 7f20dfc11d58133f tb5-rng4(0x5a)@n=2                           selected=4 views=2 distinct=8 replayed=8
       DL9-product 26e23c09952aa7bd tb5-rng4(0x5a)@n=2                           selected=4 views=108 distinct=432 replayed=432
   DL9-oracularize 8674eb43a4b363cf tb5-rng4(0x5a)@n=2                           selected=4 views=6 distinct=24 replayed=24
           DL9-pad 60eacc53ca7df175 tb5-rng4(0x5a)@n=2                           selected=4 views=36 distinct=144 replayed=144
      DL9-downsize 10293b8e70a9235c tb5-rng4(0x5a)@n=2                           selected=4 views=36 distinct=144 replayed=144
        PCPSampler 6fd3bfa11a9d0968 tb5-rng4(0x5a)@n=2                           selected=4 views=36 distinct=144 replayed=144
        DL9-detype 39d94d514cdd2d47 tb5-rng4(0x5a)@n=2                           selected=4 views=2 distinct=8 replayed=8
      DL9-downsize 83df2baae19d407d tb5-exhaustive-2^6@n=2                       selected=64 views=100 distinct=660 replayed=6400
       TildeSIntro 51fdc294004e2929 tb5-exhaustive-2^6@n=2                       selected=64 views=100 distinct=660 replayed=6400
```
