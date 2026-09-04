"Finite original-verifier fixture sufficient for the executable TB2 boundary."
struct TrivialOriginalVerifier{F,T}
    sampler::CLDistribution{F}
    params::PCPParams
    formula::T
    n::Int
    T_bound::Int
    Q_len::Int
    sigma::Int
    label::Symbol
end

function trivial_original_verifier(::Type{F}, params::PCPParams, formula;
                                   n::Integer, T::Integer, Q_len::Integer,
                                   sigma::Integer, label::Symbol=:trivial) where {F<:GF2k}
    field_size(F) == params.q || throw(ArgumentError("field size does not match parameters"))
    TrivialOriginalVerifier(trivial_original_sampler(F), params, formula,
                            Int(n), Int(T), Int(Q_len), Int(sigma), label)
end

const _PROOF_INDIVIDUAL_COPIES = (3, 4, 5)
const _POINT_AXIS_GUARD = :ALine

struct TypedAnswerReducedDecider{F,T}
    params::PCPParams
    formula::T
    original_sampler::CLDistribution{F}
    original_label::Symbol
    n::Int
    T_bound::Int
    Q_len::Int
    sigma::Int
    gamma::Int
    individual_copies::Tuple{Vararg{Int}}
end

struct TypedAnswerReducedVerifier{F,D}
    sampler::TypedSampler{F}
    oracularized_sampler::TypedSampler{F}
    pcp_sampler::TypedSampler{F}
    original_sampler::CLDistribution{F}
    decider::D
end

function _answer_reduce_replay(verifier::TypedAnswerReducedVerifier)
    CheckResult(length(verifier.sampler.types) == 54 &&
                length(verifier.sampler.type_graph) == 54^2 &&
                level(verifier.sampler) == max(
                    level(verifier.oracularized_sampler),
                    level(verifier.pcp_sampler)),
                :typed_answer_reduce_shape;
                expected=(types=54, edges=2916, level=3),
                actual=(types=length(verifier.sampler.types),
                        edges=length(verifier.sampler.type_graph),
                        level=level(verifier.sampler)))
end

"Executable typed construction; quantum lifting and detyping remain certificate leaves."
function answer_reduce_pcp(original::TrivialOriginalVerifier{F},
                           lambda::Integer, mu::Integer,
                           gamma::Integer) where {F<:GF2k}
    lambda > 0 || throw(ArgumentError("lambda must be positive"))
    mu > 0 || throw(ArgumentError("mu must be positive"))
    gamma > 0 || throw(ArgumentError("gamma must be positive"))
    ora = oracularize_sampler(original.sampler)
    pcp = pcp_sampler(F, original.params)
    combined = typed_sampler_product(ora, pcp)
    decider = TypedAnswerReducedDecider(
        original.params, original.formula, original.sampler,
        original.label, original.n, original.T_bound, original.Q_len,
        original.sigma, Int(gamma), _PROOF_INDIVIDUAL_COPIES)
    verifier = TypedAnswerReducedVerifier(
        combined.term, ora.term, pcp.term, original.sampler, decider)
    assumptions = CertNode(ASSUMED, :AnswerReduceHypotheses;
        facts=(display="normal form, T(n)=(2^(lambda*n))^mu, Q=(lambda*n)^mu, and time bounds; lambda=$(lambda), mu=$(mu)",))
    quantum = CertNode(CITED, :AnswerReduceQuantumContract;
        facts=(display="thm:ar completeness/soundness/entanglement implications; gt-10:2077-2116",))
    root = CertNode(CHECKED, :TypedAnswerReduce;
        facts=(display="finite Figure decider-pcp executable; typed level=max(ell,3)=3",),
        children=(combined.certificate, assumptions, quantum),
        replay=_answer_reduce_replay)
    Checked(verifier, root)
end

struct CitedDetypedVerifier{V}
    typed::V
    level::Int
    soundness_factor::BigInt
end

"CITED only: gt-06:435-475 adds two levels and a 16^|Type| loss."
function detype(checked::Checked{<:TypedAnswerReducedVerifier})
    term = CitedDetypedVerifier(checked.term, level(checked.term.sampler) + 2,
                                big(16)^length(checked.term.sampler.types))
    certificate = CertNode(CITED, :Detype;
        facts=(display="lem:detyping-verifiers; +2 levels; factor=16^54",),
        children=(checked.certificate,))
    Checked(term, certificate)
end

AnswerReduce(original::TrivialOriginalVerifier, lambda, mu, gamma) =
    detype(answer_reduce_pcp(original, lambda, mu, gamma))

struct AnswerReduceQuestion{O,P<:AbstractPCPQuestion}
    original::O
    pcp::P
end

function sample_answer_reduce_questions(verifier::TypedAnswerReducedVerifier,
                                        left_type::AnswerReduceType,
                                        right_type::AnswerReduceType, seed)
    length(seed) == seed_dim(verifier.sampler) ||
        throw(ArgumentError("answer-reduced seed has wrong dimension"))
    original_dimension = seed_dim(verifier.original_sampler.left)
    original_seed = ntuple(i -> seed[i], original_dimension)
    pcp_seed = ntuple(i -> seed[original_dimension + i],
                      seed_dim(verifier.pcp_sampler))
    left_original = apply(
        verifier.oracularized_sampler.left[left_type.role], original_seed)
    right_original = apply(
        verifier.oracularized_sampler.right[right_type.role], original_seed)
    left_pcp = sample_pcp_question(verifier.pcp_sampler, left_type.pcp, pcp_seed)
    right_pcp = sample_pcp_question(verifier.pcp_sampler, right_type.pcp, pcp_seed)
    (AnswerReduceQuestion(left_original, left_pcp),
     AnswerReduceQuestion(right_original, right_pcp))
end

struct HonestPCPStrategy{P}
    proof::P
    params::PCPParams
    cache::Dict{Any,Any}
end

const _HONEST_PCP_CACHES = IdDict{Any,Dict{Any,Any}}()

function honest_pcp_strategy(proof, params::PCPParams)
    cache = get!(_HONEST_PCP_CACHES, proof) do
        Dict{Any,Any}()
    end
    HonestPCPStrategy(proof, params, cache)
end

_proof_field(::PCPProof{F}) where {F} = F
_proof_dimension(::PCPProof{F,N}) where {F,N} = N
_proof_source(proof::PCPProof) = proof

function _individual_point(proof, copy::Int, point)
    source = _proof_source(proof)
    coordinates = block_coordinates(source.gs[copy].layout, Symbol("X", copy))
    length(coordinates) == length(point) ||
        throw(ArgumentError("individual PCP question has wrong dimension"))
    F = _proof_field(proof)
    full = fill(zero(F), _proof_dimension(proof))
    for (coordinate, value) in zip(coordinates, point)
        full[coordinate] = value
    end
    full
end

function _evaluate_individual(proof::PCPProof, copy::Int, point)
    evaluate(proof.gs[copy], _individual_point(proof, copy, point))
end

_tb2_bundle_point_entries(view::PCPView) =
    (view.alpha..., view.beta0, view.beta...)
_tb2_individual_point_entry(value, copy::Int) = value
_tb2_finalize_line_answers(answers::Tuple) = answers

function _univariate_from_coefficients(::Type{F}, coefficients) where {F}
    layout = VarLayout((:t,), (VarBlock(:LineParameter, 1:1),))
    terms = Dict{NTuple{1,UInt8},F}()
    for (exponent, coefficient) in enumerate(coefficients)
        iszero(coefficient) || (terms[(UInt8(exponent - 1),)] = coefficient)
    end
    degree = isempty(terms) ? -1 : maximum(Int(first(key)) for key in keys(terms))
    derivation = DegreeDerivation(:Interpolation, (max(degree, 0),), (), ())
    _poly(layout, terms, derivation, length(terms), 0; normalized=true)
end

function _interpolate_outputs(::Type{F}, values::Vector{<:Tuple}) where {F}
    count = length(values)
    count > 0 || throw(ArgumentError("interpolation needs at least one value"))
    width = length(first(values))
    all(value -> length(value) == width, values) ||
        throw(ArgumentError("interpolation output arity changed"))
    points = F.(0:count-1)
    divided = [collect(value) for value in values]
    for order in 1:count-1
        for i in count:-1:order+1
            scale = inv(points[i] - points[i-order])
            for component in 1:width
                divided[i][component] =
                    (divided[i][component] - divided[i-1][component]) * scale
            end
        end
    end

    monomial = [fill(zero(F), count) for _ in 1:width]
    basis = F[one(F)]
    for i in 1:count
        for component in 1:width, exponent in eachindex(basis)
            monomial[component][exponent] += divided[i][component] * basis[exponent]
        end
        i == count && continue
        next_basis = fill(zero(F), length(basis) + 1)
        for exponent in eachindex(basis)
            next_basis[exponent] -= points[i] * basis[exponent]
            next_basis[exponent + 1] += basis[exponent]
        end
        basis = next_basis
    end
    Tuple(_univariate_from_coefficients(F, coefficients)
          for coefficients in monomial)
end

function _question_line(question::PCPALineQuestion{F,N}) where {F,N}
    axis = chi(question.coordinate, N)
    AffineLine(question.base, ntuple(i -> F(i == axis), N))
end
_question_line(question::PCPDLineQuestion) =
    AffineLine(question.base, question.direction)

function _honest_individual_line(strategy::HonestPCPStrategy,
                                 kind::PCPType, question)
    proof = strategy.proof
    F = _proof_field(proof)
    line = _question_line(question)
    degree_bound = kind.kind == :ALine ? strategy.params.d :
                                         strategy.params.m * strategy.params.d
    values = Tuple{F}[]
    for raw_t in 0:degree_bound
        point = line_point(line, F(raw_t))
        push!(values, (_evaluate_individual(proof, kind.copy, point),))
    end
    _interpolate_outputs(F, values)
end

function _honest_bundle_line(strategy::HonestPCPStrategy,
                             kind::PCPType, question)
    proof = strategy.proof
    F = _proof_field(proof)
    line = _question_line(question)
    degree_bound = kind.kind == :ALine ? strategy.params.d :
        strategy.params.m_prime * strategy.params.d
    width = strategy.params.m_prime + 6
    values = Vector{NTuple{width,F}}()
    for raw_t in 0:degree_bound
        point = collect(line_point(line, F(raw_t)))
        view = ev_z(proof, point)
        push!(values, _tb2_bundle_point_entries(view))
    end
    _interpolate_outputs(F, values)
end

function _honest_pcp_answer_uncached(strategy::HonestPCPStrategy,
                                     kind::PCPType,
                                     question::AbstractPCPQuestion)
    if kind.kind == :Point
        question isa PCPPointQuestion || throw(ArgumentError("point type/question mismatch"))
        if kind.copy == 6
            return _tb2_bundle_point_entries(ev_z(strategy.proof,
                                                    collect(question.point)))
        end
        value = _evaluate_individual(strategy.proof, kind.copy, question.point)
        return (_tb2_individual_point_entry(value, kind.copy),)
    end
    kind.kind == :ALine && !(question isa PCPALineQuestion) &&
        throw(ArgumentError("axis-line type/question mismatch"))
    kind.kind == :DLine && !(question isa PCPDLineQuestion) &&
        throw(ArgumentError("diagonal-line type/question mismatch"))
    answers = kind.copy == 6 ? _honest_bundle_line(strategy, kind, question) :
                               _honest_individual_line(strategy, kind, question)
    _tb2_finalize_line_answers(answers)
end

"Honest table:tpcp response obtained from one cached PCP proof."
function honest_pcp_answer(strategy::HonestPCPStrategy,
                           kind::PCPType, question::AbstractPCPQuestion)
    get!(strategy.cache, (kind, question)) do
        _honest_pcp_answer_uncached(strategy, kind, question)
    end
end

function _truncate_univariate(poly::Poly{F,1}) where {F}
    isempty(poly.terms) && return poly
    top = maximum(Int(first(key)) for key in keys(poly.terms))
    terms = Dict(key => coefficient for (key, coefficient) in poly.terms
                 if Int(first(key)) < top)
    degree = isempty(terms) ? -1 : maximum(Int(first(key)) for key in keys(terms))
    derivation = DegreeDerivation(:Truncated, (max(degree, 0),), (), ())
    _poly(poly.layout, terms, derivation, length(terms), 0; normalized=true)
end

struct PCPGameCall{T,O}
    D::Symbol
    n::Int
    T_bound::Int
    Q_len::Int
    sigma::Int
    gamma::Int
    x_alice::O
    x_bob::O
    formula::T
end

pcpverifier(call::PCPGameCall, view::PCPView) = pcpverifier(call.formula, view)

struct AnswerReduceTraceEntry
    step::Int
    branch::Symbol
    player::Symbol
    index::Int
    line_kind::Symbol
    ldparams::Any
    result::CheckResult
    game_call::Any
end

struct AnswerReduceDecision
    result::CheckResult
    trace::Vector{AnswerReduceTraceEntry}
    left_type::AnswerReduceType
    right_type::AnswerReduceType
end

passed(decision::AnswerReduceDecision) = passed(decision.result)

function _ar_entry(step, branch, player, index, line_kind, result;
                   ldparams=nothing, game_call=nothing)
    AnswerReduceTraceEntry(step, branch, player, index, line_kind,
                           ldparams, result, game_call)
end

_ar_other(player::Symbol) = player == :alice ? :bob : :alice
_ar_type(player::Symbol, left, right) = player == :alice ? left : right
_ar_question(player::Symbol, left, right) = player == :alice ? left : right
_ar_answer(player::Symbol, left, right) = player == :alice ? left : right
_role_copy(role::Symbol) = role == :alice ? 1 : role == :bob ? 2 : 0

function _ar_finish(result, trace, left_type, right_type)
    AnswerReduceDecision(result, trace, left_type, right_type)
end

function _ar_record!(trace, entry, left_type, right_type)
    push!(trace, entry)
    passed(entry.result) ? nothing :
        _ar_finish(entry.result, trace, left_type, right_type)
end

function _ar_ld_check(decider::TypedAnswerReducedDecider{F}, dimension,
                      kappa, point_question, line_question,
                      point_answer, line_answer, line_kind) where {F}
    params = LDParams(F, dimension, decider.params.d, kappa)
    result = ld_decider(params, :Point, pcp_ld_question(point_question),
                        line_kind, pcp_ld_question(line_question),
                        point_answer, line_answer)
    result, (decider.params.q, dimension, decider.params.d, kappa)
end

function _pcp_view_from_answer(question::PCPPointQuestion{F,N}, answer) where {F,N}
    length(answer) == N + 6 || throw(ArgumentError("bundled point answer has wrong arity"))
    PCPView(collect(question.point), ntuple(i -> answer[i], 5), answer[6],
            ntuple(i -> answer[6 + i], N))
end

"The five sequential guarded checks of Figure fig:decider-pcp."
function typed_answer_reduced_decider(decider::TypedAnswerReducedDecider{F},
        left_type::AnswerReduceType, left_question::AnswerReduceQuestion,
        right_type::AnswerReduceType, right_question::AnswerReduceQuestion,
        left_answer, right_answer) where {F}
    Base.@nospecialize left_question right_question left_answer right_answer
    trace = AnswerReduceTraceEntry[]
    left_parsed = try
        parse_pcp_answer(left_type.pcp, left_answer, decider.params)
    catch error
        result = CheckResult(false, :pcp_answer_format;
                             location=:alice, expected=left_type.pcp,
                             actual=sprint(showerror, error))
        return _ar_finish(result, trace, left_type, right_type)
    end
    right_parsed = try
        parse_pcp_answer(right_type.pcp, right_answer, decider.params)
    catch error
        result = CheckResult(false, :pcp_answer_format;
                             location=:bob, expected=right_type.pcp,
                             actual=sprint(showerror, error))
        return _ar_finish(result, trace, left_type, right_type)
    end

    # Step 1: the equality is of the full product type.
    if left_type == right_type
        equal = _answers_equal(left_parsed, right_parsed)
        result = CheckResult(equal, :global_consistency;
                             expected=left_parsed, actual=right_parsed)
        rejected = _ar_record!(trace,
            _ar_entry(1, :global_consistency, :both, 0, :none, result),
            left_type, right_type)
        rejected === nothing || return rejected
    end

    for player in (:alice, :bob)
        other = _ar_other(player)
        current_type = _ar_type(player, left_type, right_type)
        other_type = _ar_type(other, left_type, right_type)
        current_question = _ar_question(player, left_question, right_question)
        other_question = _ar_question(other, left_question, right_question)
        current_answer = _ar_answer(player, left_parsed, right_parsed)
        other_answer = _ar_answer(other, left_parsed, right_parsed)

        # Step 2: oracle bundle versus an isolated input block.
        input_copy = _role_copy(other_type.role)
        if current_type.role == :oracle && input_copy in (1, 2) &&
           current_type.pcp == PCPType(:Point, 6) &&
           other_type.pcp == PCPType(:Point, input_copy)
            result = CheckResult(other_answer[1] == current_answer[input_copy],
                :input_consistency; location=input_copy,
                expected=current_answer[input_copy], actual=other_answer[1])
            rejected = _ar_record!(trace,
                _ar_entry(2, :input_consistency, player, input_copy, :none,
                          result), left_type, right_type)
            rejected === nothing || return rejected
        end

        # Step 3: the two original-player roles agree and select copy 1 or 2.
        input_role_copy = _role_copy(current_type.role)
        if input_role_copy in (1, 2) && current_type.role == other_type.role &&
           current_type.pcp == PCPType(:Point, input_role_copy) &&
           other_type.pcp.copy == input_role_copy &&
           other_type.pcp.kind in (_POINT_AXIS_GUARD, :DLine)
            line_kind = other_type.pcp.kind
            result, params = _ar_ld_check(decider, decider.params.m, 1,
                current_question.pcp, other_question.pcp,
                current_answer, other_answer, line_kind)
            branch = line_kind == :ALine ? :input_axis : :input_diagonal
            rejected = _ar_record!(trace,
                _ar_entry(3, branch, player, input_role_copy, line_kind,
                          result; ldparams=params), left_type, right_type)
            rejected === nothing || return rejected
        end

        if current_type.role == :oracle && other_type.role == :oracle
            i = current_type.pcp.copy
            # Step 4(a): only copies 3,4,5 are separate proof polynomials.
            if current_type.pcp.kind == :Point &&
               i in decider.individual_copies &&
               other_type.pcp == PCPType(:Point, 6)
                result = CheckResult(current_answer[1] == other_answer[i],
                    :proof_consistency; location=i,
                    expected=other_answer[i], actual=current_answer[1])
                rejected = _ar_record!(trace,
                    _ar_entry(4, :proof_consistency, player, i, :none,
                              result), left_type, right_type)
                rejected === nothing || return rejected
            end

            # Step 4(b): individual low-degree tests, again only i=3,4,5.
            if current_type.pcp.kind == :Point &&
               i in decider.individual_copies &&
               other_type.pcp.copy == i &&
               other_type.pcp.kind in (_POINT_AXIS_GUARD, :DLine)
                line_kind = other_type.pcp.kind
                result, params = _ar_ld_check(decider, decider.params.m, 1,
                    current_question.pcp, other_question.pcp,
                    current_answer, other_answer, line_kind)
                branch = line_kind == :ALine ? :proof_individual_axis :
                                               :proof_individual_diagonal
                rejected = _ar_record!(trace,
                    _ar_entry(4, branch, player, i, line_kind, result;
                              ldparams=params), left_type, right_type)
                rejected === nothing || return rejected
            end

            # Step 4(c): one simultaneous test for all m'+6 polynomials.
            if current_type.pcp == PCPType(:Point, 6) &&
               other_type.pcp.copy == 6 &&
               other_type.pcp.kind in (:ALine, :DLine)
                line_kind = other_type.pcp.kind
                result, params = _ar_ld_check(decider, decider.params.m_prime,
                    decider.params.m_prime + 6, current_question.pcp,
                    other_question.pcp, current_answer, other_answer, line_kind)
                branch = line_kind == :ALine ? :proof_simultaneous_axis :
                                               :proof_simultaneous_diagonal
                rejected = _ar_record!(trace,
                    _ar_entry(4, branch, player, 6, line_kind, result;
                              ldparams=params), left_type, right_type)
                rejected === nothing || return rejected
            end
        end

        # Step 5: reconstruct both original questions from the oracle seed.
        if current_type.role == :oracle &&
           current_type.pcp == PCPType(:Point, 6)
            x_alice = apply(decider.original_sampler.left,
                            current_question.original)
            x_bob = apply(decider.original_sampler.right,
                          current_question.original)
            call = PCPGameCall(decider.original_label, decider.n,
                decider.T_bound, decider.Q_len, decider.sigma, decider.gamma,
                x_alice, x_bob, decider.formula)
            view = _pcp_view_from_answer(current_question.pcp, current_answer)
            result = pcpverifier(call, view)
            rejected = _ar_record!(trace,
                _ar_entry(5, :game, player, 6, :none, result;
                          game_call=call), left_type, right_type)
            rejected === nothing || return rejected
        end
    end
    _ar_finish(CheckResult(true, :answer_reduce_accept), trace,
               left_type, right_type)
end

proof_individual_guard_copies(decider::TypedAnswerReducedDecider) =
    decider.individual_copies

function answer_reduce_guard_branches(decider::TypedAnswerReducedDecider,
                                      left::AnswerReduceType,
                                      right::AnswerReduceType)
    branches = Symbol[]
    left == right && push!(branches, :global_consistency)
    for player in (:alice, :bob)
        other = _ar_other(player)
        current = _ar_type(player, left, right)
        counterpart = _ar_type(other, left, right)
        other_copy = _role_copy(counterpart.role)
        current.role == :oracle && other_copy in (1, 2) &&
            current.pcp == PCPType(:Point, 6) &&
            counterpart.pcp == PCPType(:Point, other_copy) &&
            push!(branches, :input_consistency)
        input_copy = _role_copy(current.role)
        input_copy in (1, 2) && current.role == counterpart.role &&
            current.pcp == PCPType(:Point, input_copy) &&
            counterpart.pcp.copy == input_copy &&
            counterpart.pcp.kind in (_POINT_AXIS_GUARD, :DLine) &&
            push!(branches, :input_low_degree)
        if current.role == :oracle && counterpart.role == :oracle
            i = current.pcp.copy
            current.pcp.kind == :Point && i in decider.individual_copies &&
                counterpart.pcp == PCPType(:Point, 6) &&
                push!(branches, :proof_consistency)
            current.pcp.kind == :Point && i in decider.individual_copies &&
                counterpart.pcp.copy == i &&
                counterpart.pcp.kind in (_POINT_AXIS_GUARD, :DLine) &&
                push!(branches, :proof_individual_low_degree)
            current.pcp == PCPType(:Point, 6) &&
                counterpart.pcp.copy == 6 &&
                counterpart.pcp.kind in (:ALine, :DLine) &&
                push!(branches, :proof_simultaneous_low_degree)
        end
        current.role == :oracle && current.pcp == PCPType(:Point, 6) &&
            push!(branches, :game)
    end
    Tuple(unique(branches))
end

function answer_reduce_requires_nondegenerate(decider::TypedAnswerReducedDecider,
                                              left::AnswerReduceType,
                                              right::AnswerReduceType)
    any(branch -> branch in (:proof_consistency, :proof_individual_low_degree),
        answer_reduce_guard_branches(decider, left, right))
end

const _TB2_PROOF_TYPE = PCPProof{GF2048,16}
const _TB2_STRATEGY_TYPE = HonestPCPStrategy{_TB2_PROOF_TYPE}
precompile(_interpolate_outputs, (Type{GF2048}, Vector{NTuple{1,GF2048}}))
precompile(_interpolate_outputs, (Type{GF2048}, Vector{NTuple{22,GF2048}}))
for question_type in (PCPPointQuestion{GF2048,1},
                      PCPALineQuestion{GF2048,1},
                      PCPDLineQuestion{GF2048,1},
                      PCPPointQuestion{GF2048,16},
                      PCPALineQuestion{GF2048,16},
                      PCPDLineQuestion{GF2048,16})
    precompile(honest_pcp_answer,
               (_TB2_STRATEGY_TYPE, PCPType, question_type))
end
