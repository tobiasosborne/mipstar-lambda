# briefs/24-tb4.md: the TB4 mutants (composition order, CITED->CHECKED
# relabel accepted, YCode by host materialisation, a dropped Introspect
# hypothesis) and one per new check family (audit, level rule, bound
# binding, explicit sigma, Level sort, size law, CITED replay, sampler
# independence). Each is KILLED by the named tb4_* target.

# Composition order: Repeat before AnswerReduce. The LEVEL chain is still
# 9 -> 5 -> 7 -> 9 (both rules map 5 to 7), so only the fig:compress
# origin order in LevelChain's replay and test (d) can see it.
const TB4_ORDER_SWAP_MUTANT = Mutant(
    "TB4 M-order repeat_before_answer_reduce",
    "src/compress.jl",
    "    v2 = AnswerReduce(stages.answer_reduce, v1, lambda, mu, gamma; params=stage_params)\n    v3 = Repeat(stages.repeat, v2, lambda, tau; params=stage_params)",
    "    v2 = Repeat(stages.repeat, v1, lambda, tau; params=stage_params)\n    v3 = AnswerReduce(stages.answer_reduce, v2, lambda, mu, gamma; params=stage_params)",
    "tb4_compress")

# Composition order: Introspect last; the chain becomes 9 -> 11 -> 13 -> 5.
const TB4_ORDER_INTRO_LAST_MUTANT = Mutant(
    "TB4 M-order introspect_last",
    "src/compress.jl",
    "    v1 = Introspect(stages.introspect, checked, lambda, COMPRESS_LEVELS; params=stage_params)\n    v2 = AnswerReduce(stages.answer_reduce, v1, lambda, mu, gamma; params=stage_params)\n    v3 = Repeat(stages.repeat, v2, lambda, tau; params=stage_params)",
    "    v1 = AnswerReduce(stages.answer_reduce, checked, lambda, mu, gamma; params=stage_params)\n    v2 = Repeat(stages.repeat, v1, lambda, tau; params=stage_params)\n    v3 = Introspect(stages.introspect, v2, lambda, COMPRESS_LEVELS; params=stage_params)",
    "tb4_levels")

# verify_certificate accepts a CHECKED node without a replay: the relabelled
# CITED leaf passes.
const TB4_RELABEL_MUTANT = Mutant(
    "TB4 M-relabel verify_accepts_replayless_checked",
    "src/certificates.jl",
    "        node.replay === nothing &&\n            return CheckResult(false, :certificate_replay;",
    "        node.replay === nothing &&\n            return CheckResult(true, :certificate_replay;",
    "tb4_relabel")

# YCode materialises the unfolding on the host instead of returning Fix.
const TB4_YCODE_MUTANT = Mutant(
    "TB4 M-ycode host_materialised_unfolding",
    "src/ir/programs.jl",
    "YCode(body::Program) = Fix(body)",
    "YCode(body::Program) = _fix_unfold(Fix(body))",
    "tb4_ycode")

# The lambda-boundedness (description) hypothesis is dropped from the
# Introspect contract.
const TB4_HYPOTHESIS_MUTANT = Mutant(
    "TB4 M-hyp drop_lambda_bounded_description",
    "src/compress.jl",
    "    (Hypothesis(:lambda_bounded_description, \"(completeness/soundness only) V is lambda-bounded: |V| = max(|S|, |D|) <= lambda\",\n                _DEF_LAMBDA, (v, p) -> _description_status(v, p.lambda)),\n     Hypothesis(:lambda_bounded_time, \"(completeness/soundness only) V is lambda-bounded: TIME_S(n), TIME_D(n) <= n^lambda for n >= 2\",",
    "    (Hypothesis(:lambda_bounded_time, \"(completeness/soundness only) V is lambda-bounded: TIME_S(n), TIME_D(n) <= n^lambda for n >= 2\",",
    "tb4_hypotheses")

# The audit's replay never refuses a FAIL.
const TB4_AUDIT_MUTANT = Mutant(
    "TB4 M-audit hypothesis_audit_ignores_fail",
    "src/compress.jl",
    "                status == FAIL && return CheckResult(false, :hypothesis_violated;",
    "                false && return CheckResult(false, :hypothesis_violated;",
    "tb4_hypotheses")

# thm:ar's level rule loses its max with 5.
const TB4_LEVEL_RULE_MUTANT = Mutant(
    "TB4 M-level answer_reduce_levels_drops_max",
    "src/compress.jl",
    "answer_reduce_levels(ell::Integer) = max(ell + 2, 5)",
    "answer_reduce_levels(ell::Integer) = ell + 2",
    "tb4_levels")

# mu is left free in the answer-reduced bound: the composed runtime is not
# poly(n, lambda).
const TB4_BIND_MUTANT = Mutant(
    "TB4 M-bind mu_left_free",
    "src/compress.jl",
    "(:n, :lambda, :mu, :D_size, :gamma)),\n                :mu => mu, :gamma => gamma, :D_size => _description_bound(input))\n    description",
    "(:n, :lambda, :mu, :D_size, :gamma)),\n                :gamma => gamma, :D_size => _description_bound(input))\n    description",
    "tb4_levels")

# sigma is a literal instead of the fixture decider's canonical byte length.
const TB4_SIGMA_MUTANT = Mutant(
    "TB4 M-sigma sigma_not_from_canonical_bytes",
    "src/compress.jl",
    "FrontEndFixture(quoted, input, T, padded, pcp, params, description_size(quoted.term))",
    "FrontEndFixture(quoted, input, T, padded, pcp, params, 1)",
    "tb4_compress")

# The Level sort admits every term.
const TB4_LEVEL_SORT_MUTANT = Mutant(
    "TB4 M-level-sort level_admits_everything",
    "src/ir/programs.jl",
    "sort == :Level && return _literal(p, Int) && p.name >= 1",
    "sort == :Level && return true",
    "tb4_psi")

# The size law forgets the Fix tag bytes.
const TB4_CFIX_MUTANT = Mutant(
    "TB4 M-cfix size_law_without_fix_bytes",
    "src/compress.jl",
    "expected = _specialization_size(template, bindings) + FIX_TAG_BYTES",
    "expected = _specialization_size(template, bindings)",
    "tb4_specialize")

# A CITED leaf carries a replay (and would be replayable if relabelled).
const TB4_CITED_REPLAY_MUTANT = Mutant(
    "TB4 M-cited cited_leaf_carries_replay",
    "src/compress.jl",
    "               hypotheses=Tuple(h.name for h in contract.hypotheses)))\nend",
    "               hypotheses=Tuple(h.name for h in contract.hypotheses)),\n        replay=x -> CheckResult(true, :cited))\nend",
    "tb4_compress")

# The answer-reduced sampler is recorded as depending on the input decider.
const TB4_INDEPENDENCE_MUTANT = Mutant(
    "TB4 M-independence sampler_depends_on_decider",
    "src/compress.jl",
    "dependencies = Tuple(unique((_sampler_dependencies(input)..., :lambda, :mu, :gamma, :D1_size)))",
    "dependencies = Tuple(unique((_sampler_dependencies(input)..., :lambda, :mu, :gamma, :D1_size, :D)))",
    "tb4_compress")

# ---------------------------------------------------------------------------
# verdicts/tb4-r1.md (brief 72): the critic's two survivors and one owner per
# new assertion.

# O1, CRITIC-2 verbatim: the fig:compress ORDER conjunct of :LevelChain is
# blind to the order (a set comparison); the hand-built Introspect ->
# Repeat -> AnswerReduce chain in (f) has the same levels and must be refused.
const TB4_ORDER_BLIND_MUTANT = Mutant(
    "TB4 M-order-blind levelchain_order_blind",
    "src/compress.jl",
    "    origins == [:Introspect, :AnswerReduce, :Repeat, :Compress] || return false",
    "    Set(origins) == Set([:Introspect, :AnswerReduce, :Repeat, :Compress]) || return false",
    "tb4_levels")

# O2, CRITIC-1 verbatim: Compress hands Introspect the input's own level
# instead of fig:compress's literal 9; (f)'s 5-level input then prints
# `ell = 5 => PASS` at ell_level.
const TB4_ELL_FROM_INPUT_MUTANT = Mutant(
    "TB4 M-ell-from-input compress_ell_from_input_not_9",
    "src/compress.jl",
    "    v1 = Introspect(stages.introspect, checked, lambda, COMPRESS_LEVELS; params=stage_params)",
    "    v1 = Introspect(stages.introspect, checked, lambda, _levels(input); params=stage_params)",
    "tb4_levels")

# O3: the inlined compressor stub is no longer disclosed.
const TB4_STUB_UNDISCLOSED_MUTANT = Mutant(
    "TB4 M-stub-undisclosed compress_stub_not_in_tree",
    "src/compress.jl",
    "                  _relocate(decider.certificate, x -> x.decider), stub_node))",
    "                  _relocate(decider.certificate, x -> x.decider)))",
    "tb4_psi")

# O4: the FuelBound construction change is no longer disclosed.
const TB4_FUELBOUND_UNDISCLOSED_MUTANT = Mutant(
    "TB4 M-fuelbound-undisclosed halt_decider_fuel_bound_not_in_tree",
    "src/compress.jl",
    "                                   children=(node.children..., repair), replay=node.replay))",
    "                                   children=node.children, replay=node.replay))",
    "tb4_psi")

# O7: one Introspect hypothesis loses its completeness/soundness scope.
const TB4_INTRO_UNSCOPED_MUTANT = Mutant(
    "TB4 M-intro-unscoped ell_level_hypothesis_unscoped",
    "src/compress.jl",
    "     Hypothesis(:ell_level, \"(completeness/soundness only) V is an ell-level verifier\",",
    "     Hypothesis(:ell_level, \"V is an ell-level verifier\",",
    "tb4_hypotheses")

# O8: the build-time reproduction child is dropped from :UpstreamEvidence.
const TB4_REPRODUCTION_UNDISCLOSED_MUTANT = Mutant(
    "TB4 M-reproduction-undisclosed upstream_reproduction_not_in_tree",
    "src/verifiers/pcp.jl",
    "        children=(_bind_certificate(checked.certificate, checked.term, tf, proof -> proof.tf),\n                  reproduction),",
    "        children=(_bind_certificate(checked.certificate, checked.term, tf, proof -> proof.tf),),",
    "tb4_compress")

# O9: the :SamplerIndependence display leaks the input decider's hash, so
# the two-verifier traces differ in a second line.
const TB4_INDEPENDENCE_LEAK_MUTANT = Mutant(
    "TB4 M-independence-leak trace_leaks_input_hash",
    "src/compress.jl",
    "        facts=(display=\"S^compr depends on \$(join(String.(output.sampler_dependencies), \", \")) and on nothing of V's content; allowed = \$(join(String.(_INDEPENDENCE_ALLOWED), \", \"))\",),",
    "        facts=(display=\"S^compr depends on \$(join(String.(output.sampler_dependencies), \", \")) and on nothing of V's content; allowed = \$(join(String.(_INDEPENDENCE_ALLOWED), \", \")); V = \$(input isa Verifier ? quote_hash(input.decider) : :stage)\",),",
    "tb4_two_verifiers")

# O10: the surrogate goes back to being a childless sibling of the fixture
# evidence.
const TB4_SURROGATE_SIBLING_MUTANT = Mutant(
    "TB4 M-surrogate-sibling surrogate_beside_fixture_evidence",
    "src/compress.jl",
    "        children=(_relocate(detyped.certificate, x -> x.payload.typed.term),\n                  _relocate(fixture.pcp.certificate, x -> x.payload.fixture.pcp.proof)))\n    node = CertNode(CONSTRUCTED, :AnswerReduce;\n        facts=(display=\"detype o answer_reduce_pcp; level max(ell + 2, 5) = max(\$(ell) + 2, 5) = \$(levels); TIME_S = TIME_D = \$(time.description); |D^ar| = \$(description.description); sampler depends on \$(join(String.(dependencies), \", \"))\",),\n        children=(hypotheses..., _relocate(audit, x -> x.input), _cited_leaf(ANSWER_REDUCE_CONTRACT),\n                  surrogate,\n",
    "        )\n    node = CertNode(CONSTRUCTED, :AnswerReduce;\n        facts=(display=\"detype o answer_reduce_pcp; level max(ell + 2, 5) = max(\$(ell) + 2, 5) = \$(levels); TIME_S = TIME_D = \$(time.description); |D^ar| = \$(description.description); sampler depends on \$(join(String.(dependencies), \", \"))\",),\n        children=(hypotheses..., _relocate(audit, x -> x.input), _cited_leaf(ANSWER_REDUCE_CONTRACT),\n                  surrogate,\n                  _relocate(detyped.certificate, x -> x.payload.typed.term),\n                  _relocate(fixture.pcp.certificate, x -> x.payload.fixture.pcp.proof),\n",
    "tb4_compress")

# O11: the :Detype leaf loses its locatable citation.
const TB4_DETYPE_UNLOCATED_MUTANT = Mutant(
    "TB4 M-detype-unlocated detype_leaf_without_source",
    "src/verifiers/answer_reduce.jl",
    "               source=\"gt-06-types.tex\", lines=445:475, label=\"lem:detyping-verifiers\"),",
    "               ),",
    "tb4_compress")

# O12: the enu:pr-completeness range excludes its own label again.
const TB4_OFF_BY_ONE_MUTANT = Mutant(
    "TB4 M-offbyone pr_completeness_range_excludes_label",
    "src/compress.jl",
    "                \"gt-11-parallel-repetition.tex:L239-L243 (enu:pr-completeness)\",",
    "                \"gt-11-parallel-repetition.tex:L240-L243 (enu:pr-completeness)\",",
    "tb4_hypotheses")

# O13: the calibration kernel's measured time is replaced by a constant, so
# the ratio gate cannot see the clock it is calibrated against.
const TB4_GATE_UNCALIBRATED_MUTANT = Mutant(
    "TB4 M-gate-uncalibrated ratio_gate_without_calibration",
    "test/tb4_compress_ir.jl",
    "const TB4_CALIBRATION = @elapsed tb4_calibration_kernel()",
    "const TB4_CALIBRATION = 1e-9",
    "tb4_gate")

# O14 (a): specialize accepts an open replacement (capture-freedom's guard).
const TB4_SPECIALIZE_OPEN_MUTANT = Mutant(
    "TB4 M-specialize-open specialize_accepts_open_replacement",
    "src/ir/programs.jl",
    "    for (name, term) in env\n        is_closed(term) || throw(ArgumentError(\"replacement for \$name is not closed\"))\n    end\n    result = substitute(p, Dict{Symbol,Program}(env...))",
    "    for (name, term) in env\n        true || throw(ArgumentError(\"replacement for \$name is not closed\"))\n    end\n    result = substitute(p, Dict{Symbol,Program}(env...))",
    "tb4_specialize")

# O14 (b): specialize's :Specialize replay is unbound again (a borrowed
# byte-identical Quoted passes).
const TB4_SPECIALIZE_UNBOUND_MUTANT = Mutant(
    "TB4 M-specialize-unbound specialize_replay_unbound",
    "src/ir/programs.jl",
    "        replay=_bound_replay(q, :Specialize, quoted -> begin\n            decoded = decode_program(quoted.bytes)",
    "        replay=(quoted -> begin\n            decoded = decode_program(quoted.bytes)",
    "tb4_specialize")

const TB4_MUTANTS = (TB4_ORDER_SWAP_MUTANT, TB4_ORDER_INTRO_LAST_MUTANT, TB4_RELABEL_MUTANT,
                     TB4_YCODE_MUTANT, TB4_HYPOTHESIS_MUTANT, TB4_AUDIT_MUTANT,
                     TB4_LEVEL_RULE_MUTANT, TB4_BIND_MUTANT, TB4_SIGMA_MUTANT,
                     TB4_LEVEL_SORT_MUTANT, TB4_CFIX_MUTANT, TB4_CITED_REPLAY_MUTANT,
                     TB4_INDEPENDENCE_MUTANT,
                     TB4_ORDER_BLIND_MUTANT, TB4_ELL_FROM_INPUT_MUTANT,
                     TB4_STUB_UNDISCLOSED_MUTANT, TB4_FUELBOUND_UNDISCLOSED_MUTANT,
                     TB4_INTRO_UNSCOPED_MUTANT, TB4_REPRODUCTION_UNDISCLOSED_MUTANT,
                     TB4_INDEPENDENCE_LEAK_MUTANT, TB4_SURROGATE_SIBLING_MUTANT,
                     TB4_DETYPE_UNLOCATED_MUTANT, TB4_OFF_BY_ONE_MUTANT,
                     TB4_GATE_UNCALIBRATED_MUTANT, TB4_SPECIALIZE_OPEN_MUTANT,
                     TB4_SPECIALIZE_UNBOUND_MUTANT)
