# DESIGN 10.2: anchored parallel repetition. S^rep is the k(n)-fold direct
# sum of the anchored sampler as a compact loop term (DL9-repeat); D^rep
# computes B(n), streams the length guard over x, y, a, b and only then
# calls D^anch exactly k(n) times (DD-26). thm:repetition's runtime, PCC
# completeness under TIME_D(n) <= B(n) and the strict soundness relation
# stay CITED (gt-11-parallel-repetition.tex:229-258).

const _K_REP_OWNER = "tb5-decider-meter"

"The ASSUMED integrality witness of k(n) = (lambda n)^((1 + c')tau) at index n (DESIGN 10.2)."
function _integrality_node(lambda::Int, tau::Int, c_prime::Rational{Int}, n::Int)
    status, detail = try
        (PASS, "k($(n)) = ($(lambda)*$(n))^((1 + $(c_prime))*$(tau)) = $(k_rep(lambda, tau, c_prime, n))")
    catch error
        error isa ArgumentError ? (FAIL, error.msg) : rethrow()
    end
    CertNode(ASSUMED, :KRepIntegrality;
        facts=(display="the source calls k(n) an integer while declaring only c' > 0 (gt-11:200, 237); the stored term is $(K_REP_LAW) with c' = $(c_prime) an explicit toy substitution; $(detail) => $(status)",
               status=status, c_prime=c_prime))
end

const UNIVERSAL_CONSTANT_BOUND = CertNode(ASSUMED, :UniversalConstantBound;
    facts=(display="c' is the universal constant with TIME_{D^anch}(n) <= c' (TIME_D(n))^c' for all n >= 1 (gt-11:200); neither TIME is metered in the source's unit, so the predicate is NOT_EVALUABLE(owner=$(_K_REP_OWNER)); tests substitute c' = 1 and never round the exponent",
           status=NOT_EVALUABLE))

const REPETITION_COUNT_FINDING = CertNode(SOURCE_REPAIR, :RepetitionCountInconsistency;
    facts=(display="gt-12-compression.tex:L70 prints k(n) = (lambda*n)^tau inside ComputeParrepVerifier, conflicting with gt-11-parallel-repetition.tex:L200 and gt-12-compression.tex:L355, which give (lambda*n)^((1+c')*tau); the executable retains the latter two and does not use L70",))

const REPEAT_TUPLE_FRAMING = CertNode(SOURCE_REPAIR, :RepeatTupleFraming;
    facts=(display="the source parses x, y, a, b as k(n)-tuples (gt-11:216-220) without fixing the tuple encoding; the executable frames every component with a $(FRAME_BITS)-bit length field checked against B(n) before its payload is read, so |question|, |answer| <= k(n) * (B(n) + $(FRAME_BITS)) replace the source's k(n) * B(n)",))

"""
    repeat_sampler(S_anch, lambda, tau; c_prime=1//1, tracer_index=1, seeds=32) :: Checked{SamplerDescription}

DL9-repeat on the ALREADY ANCHORED sampler: field 2, level ell' (no level
added), dimension k(n) s'(n), query law O(k(n) C_S(n)); never unrolled.
"""
function repeat_sampler(S::Union{SamplerDescription,Checked}, lambda::Integer, tau::Integer;
                        c_prime::Union{Integer,Rational}=1 // 1, tracer_index::Integer=1, seeds::Integer=32)
    part = _desc(S)
    part.field_size == 2 || throw(ArgumentError("the repeated sampler takes an F_2 (normal form) sampler"))
    part.typing isa Untyped || throw(ArgumentError("the repeated sampler takes an untyped (detyped) sampler"))
    (lambda >= 1 && tau >= 1) || throw(ArgumentError("lambda and tau are positive integers"))
    c = Rational{Int}(c_prime)
    c > 0 || throw(ArgumentError("c' is a positive universal constant"))
    term = (:Repeat, Int(lambda), Int(tau), numerator(c), denominator(c), part.term)
    n = Int(tracer_index)
    k = try
        k_rep(lambda, tau, c, n)
    catch error
        error isa ArgumentError ? 0 : rethrow()
    end
    _composite(Symbol("DL9-repeat"), term, (S,), (CITED_CL_FUNC_PROD, CITED_CL_KTH);
               tracer_index=n, seeds=k == 0 ? 0 : Int(seeds), expected=expected_laws(Symbol("DL9-repeat")),
               expected_calls=k, call_law="O(k(n) C_S(n)), k($(n)) = $(k)",
               extra=(_integrality_node(Int(lambda), Int(tau), c, n),),
               display="k(n)-fold direct sum of the anchored sampler as one compact loop term (never unrolled); k(n) = $(K_REP_LAW) with lambda = $(lambda), tau = $(tau), c' = $(c)")
end

"""
    repeat_decider(D_anch, lambda, tau; c_prime=1//1) :: Checked{DeciderDescription}

D^rep: B(n) = (lambda n)^tau first, the streamed guard on all four tuples
(reject on parse failure or a component longer than B(n) bits, before any
child call), then exactly k(n) calls of D^anch combined by AND.
"""
function repeat_decider(D::Union{DeciderDescription,Checked}, lambda::Integer, tau::Integer;
                        c_prime::Union{Integer,Rational}=1 // 1)
    child = _ddesc(D)
    child.typing isa Untyped || throw(ArgumentError("the repeated decider wraps an untyped (detyped) decider"))
    c = Rational{Int}(c_prime)
    term = (:Repeat, Int(lambda), Int(tau), numerator(c), denominator(c), child.term)
    desc = _decider_from_term(term; parts=(child,))
    replay = x -> begin
        n = 2
        k = k_rep(lambda, tau, c, n)
        B = B_rep(lambda, tau, n)
        empties = [Bool[] for _ in 1:k]
        honest = decide_traced(x, n, frame_components(empties), frame_components(empties), frame_components(empties), frame_components(empties))
        long = copy(empties)
        long[1] = falses(B + 1)
        oversized = decide_traced(x, n, frame_components(long), frame_components(empties), frame_components(empties), frame_components(empties))
        oversized_answer = decide_traced(x, n, frame_components(empties), frame_components(empties), frame_components(empties), frame_components(long))
        short = decide_traced(x, n, frame_components(empties[1:k-1]), frame_components(empties), frame_components(empties), frame_components(empties))
        trailing = decide_traced(x, n, vcat(frame_components(empties), true), frame_components(empties), frame_components(empties), frame_components(empties))
        ok = length(honest[2]) == k && oversized == (false, ChildCall[]) && oversized_answer == (false, ChildCall[]) &&
             short == (false, ChildCall[]) && trailing == (false, ChildCall[])
        CheckResult(ok, :repeat_decider_guard; location=:RepeatDecider, expected=(; k, B, pre_call_rejections=4),
                    actual=(; honest_calls=length(honest[2]), oversized, oversized_answer, short, trailing))
    end
    _decider_certificate(:RepeatDecider, desc,
        "B(n) = $(B_REP_LAW) computed first; x, y, a, b each parsed as exactly k(n) framed components streaming at most B(n) payload bits per component, rejecting before any child call on failure; then exactly k(n) calls of D^anch combined by AND (DD-26)",
        replay, (), (D,))
end

# ---------------------------------------------------------------------------
# The stage carrier (verdicts/tb4-r1.md section 7 A): an executable stage's
# output keeps StubVerifier's bookkeeping and puts the real objects in
# `payload`; StubVerifier stays the CITED-only carrier of DD-9.

struct StageVerifier <: AbstractStageVerifier
    origin::Symbol
    levels::Int
    sampler_time::BoundExpr
    decider_time::BoundExpr
    description::BoundExpr
    question_length::BoundExpr
    answer_length::BoundExpr
    gap::Tuple{BoundExpr,BoundExpr}
    sampler_dependencies::Tuple{Vararg{Symbol}}
    input::Any
    payload::Any
end
Base.show(io::IO, v::StageVerifier) = print(io, "StageVerifier(", v.origin, ", levels=", v.levels, ", payload=", v.payload, ")")

_verifier_description(v::VerifierDescription) = v
_verifier_description(v::StageVerifier) = v.payload isa VerifierDescription ? v.payload :
    throw(ArgumentError("the executable Repeat stage needs a VerifierDescription payload from the previous stage"))
_verifier_description(v) = throw(ArgumentError("the executable Repeat stage needs a VerifierDescription input, got $(typeof(v))"))

"""
    anchored_repeat(V, lambda, tau; c_prime=1//1, tracer_index=1, seeds=32) :: Checked{VerifierDescription}

DESIGN 9.4's public `repeat(v, lambda, tau)`: anchor and detype once, then
the repeated direct sum; level ell + 2, dimension k(n)(s(n) + 8). The
certificate carries thm:repetition's ASSUME/PROVE contract, the integrality
and universal-constant witnesses, the gt-12:70 finding, sampler independence,
and every intermediate sampler's replay row.
"""
function anchored_repeat(V::VerifierDescription, lambda::Integer, tau::Integer;
                         c_prime::Union{Integer,Rational}=1 // 1, tracer_index::Integer=1, seeds::Integer=32)
    n = Int(tracer_index)
    c = Rational{Int}(c_prime)
    anchored = anchor(V; tracer_index=n, seeds)
    A = anchored.term
    sampler = repeat_sampler(A.sampler, lambda, tau; c_prime=c, tracer_index=n, seeds)
    decider = repeat_decider(A.decider, lambda, tau; c_prime=c)
    R = VerifierDescription(sampler.term, decider.term)
    original_sampler = quote_hash(V.sampler)
    original_decider = quote_hash(V.decider)
    expected_dependencies = Set{Any}([original_sampler, :lambda, :tau, :c_prime])
    independence = CertNode(CHECKED, :SamplerIndependence;
        facts=(display="S^rep depends on {hash(S) = $(original_sampler), lambda, tau, c'} and never on hash(D) = $(original_decider) (gt-11:257-258); dependency set = {$(join(sort(string.(collect(R.sampler.dependency_set))), ", "))}",),
        replay=x -> CheckResult(dependency_walk(canonical_bytes(x.sampler)) == expected_dependencies &&
                                x.sampler.dependency_set == expected_dependencies &&
                                !(original_decider in x.sampler.dependency_set), :sampler_independence;
                                location=:SamplerIndependence, expected=expected_dependencies, actual=x.sampler.dependency_set))
    hypotheses, audit = _audit(REPEAT_CONTRACT, V, (; lambda, tau))
    k = Dimension(R.sampler, n) isa QueryError ? "not an integer" : string(k_rep(lambda, tau, c, n))
    root = CertNode(CONSTRUCTED, :Repeat;
        facts=(display="V^rep = repeat(anchor(V), lambda = $(lambda), tau = $(tau)); c' = $(c) (toy substitution); at n = $(n): B = $(B_rep(lambda, tau, n)), k = $(k); field 2; level ell + 2 = $(V.sampler.level) + 2 = $(R.sampler.level); dimension k(n)(s(n) + 8) = $(Dimension(R.sampler, n)); |S^rep| = $(description_size(R.sampler)) bytes, |D^rep| = $(description_size(R.decider)) bytes",),
        children=(hypotheses..., _relocate(audit, x -> VerifierDescription(x.sampler.parts[1].parts[1].parts[1], x.decider.parts[1].parts[1].parts[1])),
                  _cited_leaf(REPEAT_CONTRACT), UNIVERSAL_CONSTANT_BOUND, REPETITION_COUNT_FINDING, REPEAT_TUPLE_FRAMING,
                  independence,
                  _relocate(sampler.certificate, x -> x.sampler),
                  _relocate(decider.certificate, x -> x.decider),
                  _relocate(anchored.certificate, x -> VerifierDescription(x.sampler.parts[1], x.decider.parts[1]))))
    Checked(R, root)
end

"""
    ExecutableRepeat(; c_prime=1//1, tracer_index=1, seeds=32) <: CompressStage

The executable Repeat stage swappable for TB4's `RepeatStub` behind
`Repeat(stage, V, lambda, tau; params)`; its parameters are data (B).
"""
struct ExecutableRepeat <: CompressStage
    c_prime::Rational{Int}
    tracer_index::Int
    seeds::Int
end
ExecutableRepeat(; c_prime::Union{Integer,Rational}=1 // 1, tracer_index::Integer=1, seeds::Integer=32) =
    ExecutableRepeat(Rational{Int}(c_prime), Int(tracer_index), Int(seeds))

function Repeat(stage::ExecutableRepeat, checked::Union{Checked,_VERIFIER_INPUT}, lambda::Integer, tau::Integer;
                params::NamedTuple=(;))
    input, input_cert = _split(checked)
    V = _verifier_description(input)
    c_prime = get(params, :c_prime, stage.c_prime)
    tracer_index = get(params, :n, stage.tracer_index)
    result = anchored_repeat(V, lambda, tau; c_prime, tracer_index, seeds=stage.seeds)
    R = result.term
    k = "k(n) = (lambda*n)^((1+c')*tau)"
    sampler_time = bind_parameter(Opaque("O(k(n) * TIME_S(n)), $(k)", (:n, :lambda, :tau, :c_prime, :TIME_S)),
                                  :tau => tau, :c_prime => Rational{Int}(c_prime), :TIME_S => _sampler_time(V))
    decider_time = bind_parameter(Opaque("O(k(n) * max(TIME_D(n), (lambda*n)^tau)), $(k)", (:n, :lambda, :tau, :c_prime, :TIME_D)),
                                  :tau => tau, :c_prime => Rational{Int}(c_prime), :TIME_D => _decider_time(V))
    gap = (Opaque("completeness: value-1 PCC strategy of V_n and TIME_D(n) <= (lambda n)^tau => value-1 PCC strategy of V^rep_n", ()),
           Opaque("soundness: Ent(V^rep_n, p) >= Ent(V_n, 1 - eps) for p > (4/eps) exp(-c eps^17 k(n)/(lambda n)^(tau c'))", ()))
    output = StageVerifier(:Repeat, R.sampler.level, sampler_time, decider_time, Concrete(description_length(R)),
                           Opaque(string(R.decider.question_length), (:n,)), Opaque(string(R.decider.answer_length), (:n,)),
                           gap, (:S, :lambda, :tau, :c_prime), input, R)
    node = CertNode(CONSTRUCTED, :Repeat;
        facts=(display="executable Repeat (TB5) behind the CompressStage interface; level ell + 2 = $(V.sampler.level) + 2 = $(output.levels); TIME_S = $(sampler_time.description); TIME_D = $(decider_time.description); sampler depends on S, lambda, tau, c'",),
        children=(_relocate(result.certificate, x -> x.payload), _relocate(input_cert, x -> x.input)))
    Checked(output, node)
end
