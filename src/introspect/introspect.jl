# TB6 (DESIGN 9.6, 11, 12.4): introspect(V, lambda, ell; policy) as a
# Checked{VerifierDescription} and the executable CompressStage
# `ExecutableIntrospect` swappable for TB4's IntrospectStub.

"""
    introspect(V, lambda, ell; tuple::PauliTuple, F_child=0, tracer_index=1, seeds=32) :: Checked{VerifierDescription}

V^intro = detype(hat S^intro, tilde D^intro): sampler chain tilde S^intro ->
downsize -> detype (level 5), the typed introspection decider on V detyped
by the same executable detyper. The tree carries the thm:introspection
ASSUME/PROVE contract audited on V, the toy_override policy report, the
sampler chain's DESIGN 9.6 rows, the decider rows, the SOURCE_REPAIR
disclosures and the CITED leaves; sampler independence of V is CHECKED.
"""
function introspect(V::VerifierDescription, lambda::Integer, ell::Integer; tuple::PauliTuple, F_child::Integer=0,
                    tracer_index::Integer=1, seeds::Integer=32)
    n = Int(tracer_index)
    N = 2 ^ n
    R = Int(big(N) ^ lambda)
    samplers = intro_sampler(lambda, ell; tuple, tracer_index=n, seeds)
    typed_decider = typed_intro_decider(V, lambda, ell; tuple, F_child)
    hat = samplers.hat.term
    decider = detype_decider(typed_decider, hat.typing)
    out = VerifierDescription(samplers.detyped.term, decider.term)
    s_N = Dimension(V.sampler, N)
    s_value = s_N isa QueryError ? -1 : s_N
    policy = pauli_policy_report(tuple; R, s_N=s_value, lambda=Int(lambda), description_bytes=description_length(V), F_child=Int(F_child), ell=Int(ell))
    policy_node = policy_report_nodes(policy, tuple, R, Int(F_child))
    hypotheses, audit = _audit(INTROSPECT_CONTRACT, V, (; lambda=Int(lambda), ell=Int(ell)))
    original_sampler, original_decider = quote_hash(V.sampler), quote_hash(V.decider)
    independence = CertNode(CHECKED, :SamplerIndependence;
        facts=(display="S^intro depends only on (lambda, ell) = ($(lambda), $(ell)) and $(tuple): dependency set = {$(join(sort(string.(collect(out.sampler.dependency_set))), ", "))} contains neither hash(S) = $(original_sampler) nor hash(D) = $(original_decider) (gt-08:L317-L345, L819-L840); the bytes equal a fresh construction from (lambda, ell, tuple) alone",),
        replay=x -> begin
            deps = dependency_walk(canonical_bytes(x.sampler))
            fresh = intro_sampler(lambda, ell; tuple, tracer_index=n, seeds=0).detyped.term
            CheckResult(!(original_sampler in deps) && !(original_decider in deps) &&
                        canonical_bytes(x.sampler) == canonical_bytes(fresh), :sampler_independence; location=:SamplerIndependence)
        end)
    detype_node = CertNode(CONSTRUCTED, :Detype;
        facts=(display="detype(hat S^intro, tilde D^intro) over $(TypeCount(hat.typing)) types: level 3 + 2 = $(out.sampler.level); dimension (3m+3) log2 q + 4|TypeIntro| = $(Dimension(out.sampler, n)) at n = $(n)",),
        children=(CITED_DETYPING, _relocate(samplers.detyped.certificate, x -> x.sampler), _relocate(decider.certificate, x -> x.decider)))
    root = CertNode(CONSTRUCTED, :Introspect;
        facts=(display="V^intro = Introspect(V, lambda = $(lambda), ell = $(ell)) with $(tuple), N = $(N), R = N^lambda = $(R), Q = $(pauli_Q(tuple)); field 2; level 5; dimension $(Dimension(out.sampler, n)) = (3m+3) log2 q + 4(32 + 2 ell); |S^intro| = $(description_size(out.sampler)) bytes, |D^intro| = $(description_size(out.decider)) bytes; child fuel $(F_child == 0 ? "R (production)" : "F_child = $(F_child) (toy)")",),
        children=(hypotheses..., _relocate(audit, x -> V),
                  _cited_leaf(INTROSPECT_CONTRACT), CITED_COMMUTE,
                  policy_node, INTRO_3Q_GUARD, INTRO_HIDE_SUFFIX_REGISTER, INTRO_PERP_ORTHOGONAL, independence, detype_node))
    Checked(out, root)
end

"""
    ExecutableIntrospect(; tuple, F_child=0, tracer_index=1, seeds=32) <: CompressStage

The executable Introspect stage behind `Introspect(stage, V, lambda, ell; params)`,
swappable for TB4's `IntrospectStub`; `params` may carry `:n`, `:tuple`, `:F_child`.
"""
struct ExecutableIntrospect <: CompressStage
    tuple::PauliTuple
    F_child::Int
    tracer_index::Int
    seeds::Int
end
ExecutableIntrospect(; tuple::PauliTuple, F_child::Integer=0, tracer_index::Integer=1, seeds::Integer=32) =
    ExecutableIntrospect(tuple, Int(F_child), Int(tracer_index), Int(seeds))

function Introspect(stage::ExecutableIntrospect, checked::Union{Checked,_VERIFIER_INPUT}, lambda::Integer, ell::Integer;
                    params::NamedTuple=(;))
    input, input_cert = _split(checked)
    V = _verifier_description(input)
    tuple = get(params, :tuple, stage.tuple)
    F_child = get(params, :F_child, stage.F_child)
    tracer_index = get(params, :n, stage.tracer_index)
    result = introspect(V, lambda, ell; tuple, F_child, tracer_index, seeds=stage.seeds)
    I = result.term
    sampler_time = Opaque("TIME_S(n): $(I.sampler.query_time) (poly(n, lambda, ell) CITED); metered steps only", (:n,))
    decider_time = Opaque("TIME_D(n): $(I.decider.time_bound); child calls under the step meter with budget $(F_child == 0 ? "N^lambda" : "F_child = $(F_child) (toy)")", (:n,))
    gap = (Opaque("completeness: value-1 PCC strategy of V_{2^n} => value-1 PCC strategy of V^intro_n", ()),
           Opaque("soundness: val*(V^intro_n) > 1 - eps => val*(V_{2^n}) >= 1 - delta(eps, n)", ()))
    output = StageVerifier(:Introspect, I.sampler.level, sampler_time, decider_time, Concrete(description_length(I)),
                           Opaque(string(I.decider.question_length), (:n,)), Opaque(string(I.decider.answer_length), (:n,)),
                           gap, (:lambda, :ell), input, I)
    node = CertNode(CONSTRUCTED, :Introspect;
        facts=(display="executable Introspect (TB6) behind the CompressStage interface; level 5 for every ell (ell = $(ell)); TIME_S = $(sampler_time.description); TIME_D = $(decider_time.description); sampler depends on (lambda, ell) and the Pauli tuple",),
        children=(_relocate(result.certificate, x -> x.payload), _relocate(input_cert, x -> x.input)))
    Checked(output, node)
end
