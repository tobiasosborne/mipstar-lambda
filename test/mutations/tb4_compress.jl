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
    "    (Hypothesis(:lambda_bounded_description, \"V is lambda-bounded: |V| = max(|S|, |D|) <= lambda\",\n                _DEF_LAMBDA, (v, p) -> _description_status(v, p.lambda)),\n     Hypothesis(:lambda_bounded_time, \"V is lambda-bounded: TIME_S(n), TIME_D(n) <= n^lambda for n >= 2\",",
    "    (Hypothesis(:lambda_bounded_time, \"V is lambda-bounded: TIME_S(n), TIME_D(n) <= n^lambda for n >= 2\",",
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

const TB4_MUTANTS = (TB4_ORDER_SWAP_MUTANT, TB4_ORDER_INTRO_LAST_MUTANT, TB4_RELABEL_MUTANT,
                     TB4_YCODE_MUTANT, TB4_HYPOTHESIS_MUTANT, TB4_AUDIT_MUTANT,
                     TB4_LEVEL_RULE_MUTANT, TB4_BIND_MUTANT, TB4_SIGMA_MUTANT,
                     TB4_LEVEL_SORT_MUTANT, TB4_CFIX_MUTANT, TB4_CITED_REPLAY_MUTANT,
                     TB4_INDEPENDENCE_MUTANT)
