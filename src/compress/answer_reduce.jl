# TB7 (DESIGN 12.1-12.5; briefs/44 addendum): AnswerReduce on descriptions.
#
#   S^ar_typed = product(oracularize(S1), pad(downsize(PCP(pcpparams, sigma_1)), extra))
#   D^ar_typed = (:TypedDecider, Type^ora x Type^pcp, (:AnswerReduce, lambda, mu, gamma, sigma_1, q, m, d, s, m', S1, D1))
#   V2         = detype(S^ar_typed, D^ar_typed)                       level max(ell+2, 5), dimension s_1 + (2m'+6) log q + 4*54
#
# The explicit `downsize` before the product is SOURCE_REPAIR(AR-field-align)
# (gt-10-answer-reduction.tex:L1948-L1965 sums V^ora (+) V^pcp without the
# field conversion). The typed decider is fig:decider-pcp (L1997-L2063):
# steps 1-4 execute on the bit-decoded questions and answers through TB2's
# guard functions; step 5 (enu:ar-game, L2060-L2063) calls pcpverifier on an
# instance that must arithmetize the ACTUAL D1 -- at TB7 no such instance
# exists (P_pcp_encodes_D1 = FAIL), so reaching it records
# NOT_EXECUTED(owner=pcpverifier-D1-trace) and REJECTS: an unexecuted layer
# is never counted as transcript evidence (DD-31).

const AR_GAME_OWNER = "pcpverifier-D1-trace"

"The record a reached enu:ar-game leaves in the decider trace (never executed at TB7)."
struct ARGameNotExecuted
    D1_hash::String
    n::Int
    T_law::String
    Q_len::Int
    sigma::Int
    gamma::Int
    owner::String
end
Base.show(io::IO, r::ARGameNotExecuted) = print(io, "ARGameNotExecuted(enu:ar-game on D1 ", r.D1_hash, " at n = ", r.n, ", T = ", r.T_law,
                                                 ", Q = ", r.Q_len, ", sigma = ", r.sigma, ": NOT_EXECUTED(owner=", r.owner, "))")
"One executed fig:decider-pcp step of the description-level decider."
struct ARStep
    step::Int
    branch::Symbol
    player::Symbol
    rule::Symbol
    passed::Bool
end

# --- the answer-reduced type labels ----------------------------------------------------
_ar_label(role::String, kind::PCPType) = role * "," * string(kind)
"The 54 product labels in the ProductMachine's order: roles x (Point/ALine/DLine x copies 1..6)."
answer_reduce_labels(pcp_term) = String[_ar_label(l, t) for l in ORACULARIZE_LABELS for t in pcp_family(pcp_term).types]
function _parse_ar_label(label::AbstractString)
    parts = split(label, ",")
    length(parts) == 2 || return nothing
    role = Symbol(parts[1])
    role in ORACULAR_ROLES || return nothing
    kind = split(parts[2], "_")
    length(kind) == 2 || return nothing
    k = Symbol(kind[1])
    k in (:Point, :ALine, :DLine) || return nothing
    copy = tryparse(Int, kind[2])
    (copy === nothing || !(1 <= copy <= 6)) && return nothing
    AnswerReduceType(role, PCPType(k, copy))
end

# --- the bit codecs of questions and answers ---------------------------------------------
# A field element of F_{2^kappa} is kappa big-endian bits in the fixed
# polynomial basis (the downsize convention, machines.jl); a Point answer is
# its `count` elements, a line answer `count` univariate polynomials of
# degree <= bound as bound + 1 coefficients each (table:tpcp shapes).
function _ar_answer_shape(kind::PCPType, params::PCPParams)
    count = kind.copy == 6 ? params.m_prime + 6 : 1
    kind.kind == :Point && return (count, 0)
    dimension = kind.copy == 6 ? params.m_prime : params.m
    bound = kind.kind == :ALine ? params.d : dimension * params.d
    (count, bound)
end
"The bit length of an honest answer of the given type (the largest is (m'+6)(m'd+1) log q, DESIGN 12.5)."
function answer_bit_length(kind::PCPType, params::PCPParams)
    count, bound = _ar_answer_shape(kind, params)
    count * (bound + 1) * params.k
end
function _decode_pcp_answer_bits(::Type{F}, kind::PCPType, bits::Vector{Bool}, params::PCPParams) where {F}
    count, bound = _ar_answer_shape(kind, params)
    length(bits) == count * (bound + 1) * params.k || return nothing
    elements = _field_from_bits(F, _bits_gf2(bits), params.k)
    kind.kind == :Point && return Tuple(elements)
    Tuple(_univariate_from_coefficients(F, elements[(i-1)*(bound+1)+1:i*(bound+1)]) for i in 1:count)
end
function encode_pcp_answer_bits(kind::PCPType, answer, params::PCPParams)
    count, bound = _ar_answer_shape(kind, params)
    entries = parse_pcp_answer(kind, answer, params)
    elements = if kind.kind == :Point
        collect(entries)
    else
        vcat((poly_coefficients(p, bound) for p in entries)...)
    end
    Bool[x == one(GF2) for x in field_bit_vector(elements)]
end
"The question bits of the product sampler: the oracularized S1 question followed by the downsized PCP register."
function _decode_pcp_question(::Type{F}, pcp_term, kind::PCPType, bits::Vector{Bool}, params::PCPParams) where {F}
    ambient = _field_from_bits(F, _bits_gf2(bits), params.k)
    pcp_question_from_ambient(pcp_family(pcp_term), kind, ambient)
end

# --- fig:decider-pcp on descriptions -----------------------------------------------------
const _S1_MACHINE_CACHE = Dict{Vector{UInt8},Any}()
function _s1_dimension(S1_term, n::Int)
    bytes = sampler_term_bytes(S1_term)
    m = get!(_S1_MACHINE_CACHE, bytes) do
        compile_sampler(S1_term)
    end
    _dimension(m, n, Meter())
end

function _ar7_ld_check(::Type{F}, params::PCPParams, dimension::Int, kappa::Int, point_question, line_question,
                       point_answer, line_answer, line_kind::Symbol) where {F}
    ld = LDParams(F, dimension, params.d, kappa)
    ld_decider(ld, :Point, pcp_ld_question(point_question), line_kind, pcp_ld_question(line_question), point_answer, line_answer)
end

"""
    _decide_answer_reduce(labels, body, n, tA, x, tB, y, a, b, trace) -> Bool

The typed answer-reduced decider of fig:decider-pcp (gt-10:L1997-L2063) on
bit-string questions/answers. Steps 1-4 execute; step 5 records
ARGameNotExecuted and rejects (P_pcp_encodes_D1 = FAIL at TB7).
"""
function _decide_answer_reduce(labels::Vector{String}, body, n::Int, tA::String, x::AbstractVector{Bool}, tB::String, y::AbstractVector{Bool},
                               a::AbstractVector{Bool}, b::AbstractVector{Bool}, trace::Vector)
    lambda, mu, gamma, sigma, q, m, d, s, m_prime, S1_term, D1_term = body[2:12]
    (tA in labels && tB in labels) || return false
    left_type, right_type = _parse_ar_label(tA), _parse_ar_label(tB)
    (left_type === nothing || right_type === nothing) && return false
    params = PCPParams(q, round(Int, log2(q)), m, d, s, m_prime, gamma)
    F = _field_type(q)
    pcp_term = (:PCP, q, m, d, s, m_prime, gamma, sigma)
    s1 = _s1_dimension(S1_term, n)
    pcp_bits = params.k * (2 * m_prime + 6)
    x, y, a, b = Vector{Bool}(x), Vector{Bool}(y), Vector{Bool}(a), Vector{Bool}(b)
    (length(x) == s1 + pcp_bits && length(y) == s1 + pcp_bits) || return false
    left_question = _decode_pcp_question(F, pcp_term, left_type.pcp, x[s1+1:end], params)
    right_question = _decode_pcp_question(F, pcp_term, right_type.pcp, y[s1+1:end], params)
    left_answer = _decode_pcp_answer_bits(F, left_type.pcp, a, params)
    right_answer = _decode_pcp_answer_bits(F, right_type.pcp, b, params)
    if left_answer === nothing || right_answer === nothing
        push!(trace, ARStep(0, :pcp_answer_format, left_answer === nothing ? :alice : :bob, :pcp_answer_format, false))
        return false
    end
    record!(step, branch, player, result) = (push!(trace, ARStep(step, branch, player, result.rule, passed(result))); passed(result))
    # Step 1: equal product types must answer identically.
    if left_type == right_type
        record!(1, :global_consistency, :both, CheckResult(_answers_equal(left_answer, right_answer), :global_consistency)) || return false
    end
    for player in (:alice, :bob)
        other = player == :alice ? :bob : :alice
        current_type = player == :alice ? left_type : right_type
        other_type = player == :alice ? right_type : left_type
        current_question = player == :alice ? left_question : right_question
        other_question = player == :alice ? right_question : left_question
        current_answer = player == :alice ? left_answer : right_answer
        other_answer = player == :alice ? right_answer : left_answer
        # Step 2: the oracle bundle against an isolated input block.
        input_copy = _role_copy(other_type.role)
        if current_type.role == :oracle && input_copy in (1, 2) && current_type.pcp == PCPType(:Point, 6) &&
           other_type.pcp == PCPType(:Point, input_copy)
            record!(2, :input_consistency, player, CheckResult(other_answer[1] == current_answer[input_copy], :input_consistency)) || return false
        end
        # Step 3: an original-player role's point against its own line (copy 1 or 2).
        role_copy = _role_copy(current_type.role)
        if role_copy in (1, 2) && current_type.role == other_type.role && current_type.pcp == PCPType(:Point, role_copy) &&
           other_type.pcp.copy == role_copy && other_type.pcp.kind in (:ALine, :DLine)
            result = _ar7_ld_check(F, params, params.m, 1, current_question, other_question, current_answer, other_answer, other_type.pcp.kind)
            record!(3, other_type.pcp.kind == :ALine ? :input_axis : :input_diagonal, player, result) || return false
        end
        if current_type.role == :oracle && other_type.role == :oracle
            i = current_type.pcp.copy
            # Step 4(a): proof consistency for the individual copies 3, 4, 5.
            if current_type.pcp.kind == :Point && i in _PROOF_INDIVIDUAL_COPIES && other_type.pcp == PCPType(:Point, 6)
                record!(4, :proof_consistency, player, CheckResult(current_answer[1] == other_answer[i], :proof_consistency)) || return false
            end
            # Step 4(b): the individual low-degree tests.
            if current_type.pcp.kind == :Point && i in _PROOF_INDIVIDUAL_COPIES && other_type.pcp.copy == i &&
               other_type.pcp.kind in (:ALine, :DLine)
                result = _ar7_ld_check(F, params, params.m, 1, current_question, other_question, current_answer, other_answer, other_type.pcp.kind)
                record!(4, other_type.pcp.kind == :ALine ? :proof_individual_axis : :proof_individual_diagonal, player, result) || return false
            end
            # Step 4(c): the simultaneous test of all m'+6 polynomials.
            if current_type.pcp == PCPType(:Point, 6) && other_type.pcp.copy == 6 && other_type.pcp.kind in (:ALine, :DLine)
                result = _ar7_ld_check(F, params, params.m_prime, params.m_prime + 6, current_question, other_question, current_answer, other_answer, other_type.pcp.kind)
                record!(4, other_type.pcp.kind == :ALine ? :proof_simultaneous_axis : :proof_simultaneous_diagonal, player, result) || return false
            end
        end
        # Step 5 (enu:ar-game): pcpverifier((D1, n, T, Q, gamma, x_alice, x_bob), (z, a_w)) on an
        # instance arithmetizing the ACTUAL D1 -- NOT_EXECUTED(owner=pcpverifier-D1-trace).
        if current_type.role == :oracle && current_type.pcp == PCPType(:Point, 6)
            push!(trace, ARGameNotExecuted(quote_hash(decider_term_bytes(D1_term)), n, "(2^(lambda*n))^mu = (2^($(lambda)*$(n)))^$(mu)",
                                           Int(big(lambda * n)^mu > typemax(Int) ? -1 : (lambda * n)^mu), sigma, gamma, AR_GAME_OWNER))
            return false
        end
    end
    true
end

# --- the description-level stage ---------------------------------------------------------
const CITED_AR_INTERFACE = _cited("thm:ar", "gt-10-answer-reduction.tex", 2077:2116,
    "ComputeAnsVerifier(V, lambda, mu, gamma): V^ar is max{ell + 2, 5}-level, TIME poly((lambda n)^mu, |D|, gamma), S^ar depends on S, (lambda, mu, gamma) and |D| (L2094-L2096); completeness, soundness and Ent stay CITED")
const AR_FIELD_ALIGN = CertNode(SOURCE_REPAIR, :AR_field_align;
    facts=(display="gt-10-answer-reduction.tex:L1948-L1965 forms V^ar = V^ora (+) V^pcp as a direct sum without spelling out the field conversion between the F_2 oracularized sampler and the F_q PCP sampler; the executable inserts downsize(PCP) (an explicit (:Downsize) node, then an explicit (:Pad) to the common level) before the product, with lem:downsize-cl-dist supplying the distribution identity (gt-04-cl.tex:L533-L550): SOURCE_REPAIR(AR-field-align)",
           source="gt-10-answer-reduction.tex", lines=1948:1965))
const CITED_CL_DIST_PROD = _cited("lem:cl-dist-prod", "gt-04-cl.tex", 366:383,
    "the product of CL distributions on complementary registers is the CL distribution of the direct sum (never executed beyond the finite replays)")
const CITED_CL_DOWNSIZE = _cited("lem:cl-downsize", "gt-04-cl.tex", 410:438,
    "downsizing a CL function through the fixed basis gives a CL function of the same level (the finite conjugation is executed)")
const CITED_DOWNSIZE_CL_DIST = _cited("lem:downsize-cl-dist", "gt-04-cl.tex", 533:550,
    "the distribution identity of the downsized sampler (the field-alignment repair's cited identity)")
const CITED_PERP_PERP = _cited("lem:perp_perp", "gt-03-prelim.tex", 263:270,
    "(V^perp)^perp = V for the canonical dual; the finite canonical-dual computation is executed")

"""
    answer_reduce(V1, lambda, mu, gamma; policy, tracer_index=2, seeds=4) :: Checked{VerifierDescription}

DESIGN 9.6's `answer_reduce` on descriptions with thm:ar's contract audited
on V1, the AR policy predicates, the honest P_pcp_encodes_D1 = FAIL evidence,
the NOT_EXECUTED enu:ar-game disclosure, the fixture's local PCP sub-tests,
the sampler chain and decider rows, and the CITED residue leaves.
"""
function answer_reduce(V1::VerifierDescription, lambda::Integer, mu::Integer, gamma::Integer;
                       policy::ConstructionPolicy=TB7_TOY_POLICY, tracer_index::Integer=2, seeds::Integer=4,
                       fixture::Union{Nothing,FrontEndFixture}=nothing)
    policy isa ToyPolicy || throw(ArgumentError("production answer reduction needs pcpparams(n, T, Q, sigma, gamma), whose m(T, sigma) and s(...) are NOT_EVALUABLE without the universal constants of prop:explicit-padded-succinct-deciders; supply a ToyPolicy"))
    n = Int(tracer_index)
    V1.sampler.typing isa Untyped || throw(ArgumentError("answer reduction takes an untyped normal-form verifier"))
    V1.sampler.field_size == 2 || throw(ArgumentError("answer reduction takes a sampler over F_2"))
    params = PCPParams(policy.pcp_tuple.q, policy.pcp_tuple.k, policy.pcp_tuple.m, policy.pcp_tuple.d, policy.pcp_tuple.s, policy.pcp_tuple.m_prime, Int(gamma))
    sigma = description_size(V1.decider)
    # The sampler chain: oracularize(S1) x pad(downsize(PCP)) to the common level, then detype.
    ora = oracularize(V1.sampler; tracer_index=n, seeds)
    pcp = pcp_description(params, sigma; tracer_index=n, seeds)
    down = downsize(pcp; tracer_index=n, seeds)
    left, right = ora, down
    extra = ora.term.level - down.term.level
    extra >= 0 || throw(ArgumentError("an input of level < 3 is padded on the oracularized side: not needed at TB7 (ell = 5)"))
    padded = extra == 0 ? down : pad(down, extra; tracer_index=n, seeds)
    typed_sampler = product(ora, padded; tracer_index=n, seeds)
    labels = answer_reduce_labels(pcp.term.term)
    labels == typed_sampler.term.typing.labels || error("the product labels do not match the answer-reduced type order")
    body = (:AnswerReduce, Int(lambda), Int(mu), Int(gamma), sigma, params.q, params.m, params.d, params.s, params.m_prime,
            V1.sampler.term, V1.decider.term)
    typed_term = (:TypedDecider, labels, body)
    typed_decider = _decider_from_term(typed_term; parts=(V1.decider,))
    F = _field_type(params.q)
    s1 = Dimension(V1.sampler, n)
    pcp_bits = params.k * (2 * params.m_prime + 6)
    # The replay: an out-of-range type rejects; a malformed answer rejects with a format record; an
    # equal-type pair with equal honest (zero) answers reaches no game and accepts; the (oracle, Point_6)
    # bundle against (alice, Point_1) reaches step 5 and records NOT_EXECUTED.
    replay = x -> begin
        zero_q = falses(s1 + pcp_bits)
        bit1 = decide(x, n, "Referee", zero_q, labels[1], zero_q, Bool[], Bool[])
        bit2, tr2 = decide_traced(x, n, "alice,Point_1", zero_q, "alice,Point_1", zero_q, falses(3), falses(3))
        bit3, tr3 = decide_traced(x, n, "alice,Point_1", zero_q, "alice,Point_1", zero_q, falses(params.k), falses(params.k))
        bit4, tr4 = decide_traced(x, n, "oracle,Point_6", zero_q, "alice,Point_1", zero_q, falses(answer_bit_length(PCPType(:Point, 6), params)), falses(params.k))
        ok = !bit1 && !bit2 && any(r -> r isa ARStep && r.rule == :pcp_answer_format, tr2) && bit3 &&
             !bit4 && any(r -> r isa ARGameNotExecuted && r.owner == AR_GAME_OWNER, tr4)
        CheckResult(ok, :answer_reduce_decider; location=:AnswerReduceDecider, actual=(; bit1, bit2, bit3, bit4, game=[r for r in tr4 if r isa ARGameNotExecuted]))
    end
    decider = _decider_certificate(:AnswerReduceDecider, typed_decider,
        "fig:decider-pcp (gt-10:L1997-L2063) on the $(length(labels)) product types: questions = S1 question ($(s1) bits) then the downsized PCP register ($(pcp_bits) bits); answers decoded as $(params.k)-bit field elements / line polynomials (largest (m'+6)(m'd+1) log q = $(answer_bit_length(PCPType(:DLine, 6), params)) bits); steps 1-4 execute through TB2's guards; step 5 (enu:ar-game) records NOT_EXECUTED(owner=$(AR_GAME_OWNER)) and rejects; sigma_1 = $(sigma); T = (2^(lambda n))^mu symbolic",
        replay, (CITED_AR_INTERFACE, CITED_PCP_DECIDER), (V1.decider,))
    detyped_sampler = detype_sampler(typed_sampler; tracer_index=n, seeds)
    detyped_decider = detype_decider(decider, typed_sampler.term.typing)
    V2 = VerifierDescription(detyped_sampler.term, detyped_decider.term)
    # Contract, policy predicates and the two named non-executed layers.
    hypotheses, audit = _audit(ANSWER_REDUCE_CONTRACT, V1, (; lambda=Int(lambda), mu=Int(mu), gamma=Int(gamma)))
    fx = fixture === nothing ? frontend_fixture() : fixture
    predicates = answer_reduce_predicates(V1, params, sigma, Int(lambda), Int(mu), Int(gamma), n, policy, fx)
    encodes = pcp_encodes_D1_evidence(V1.decider, fx, Int(lambda), Int(mu), sigma, n)
    agreement = answer_reduce_agreement_node(typed_decider, params, s1, pcp_bits, fx, Int(lambda), Int(mu), Int(gamma))
    local_pcp = CertNode(ASSUMED, :PCPFixtureLocalOnly;
        facts=(display="separately labelled LOCAL PCP algebra/predicate sub-tests on the immutable fixture (trivial decider |D| = $(fx.sigma) bytes, fnv1a64 $(quote_hash(fx.quoted.term)), T = $(fx.T)): its construction certificate replays on the fixture's own PCP proof (bound by identity to that object, not reached from V^ar); its content is NOT the actual D1 and is never fed to enu:ar-game or P_pcp_encodes_D1 (DESIGN 13.1)",
               fixture_hash=quote_hash(fx.quoted.term), fixture_sigma=fx.sigma),
        children=(_relocate(fx.pcp.certificate, x -> fx.pcp.proof),))
    game = CertNode(ASSUMED, :ARGameNotExecuted;
        facts=(display="enu:ar-game against the actual D1 (gt-10:L2060-L2063): NOT_EXECUTED(owner=$(AR_GAME_OWNER)) whenever step 5 is reached, because P_pcp_encodes_D1 = FAIL; the decider rejects there and no accept is counted as transcript evidence (DD-31)",
               status="NOT_EXECUTED", owner=AR_GAME_OWNER, source="gt-10-answer-reduction.tex", lines=2060:2063))
    root = CertNode(CONSTRUCTED, :AnswerReduce;
        facts=(display="V^ar = detype(product(oracularize(S1), pad(downsize(PCP))), D^ar) at lambda = $(lambda), mu = $(mu), gamma = $(gamma); pcpparams tuple $(params.q)/$(params.m)/$(params.d)/$(params.s)/$(params.m_prime) (ToyPolicy), sigma_1 = |D1| = $(sigma); field 2; level max(ell + 2, 5) = max($(V1.sampler.level) + 2, 5) = $(V2.sampler.level); dimension s_1 + (2m'+6) log q + 4|Type^ar| = $(s1) + $(pcp_bits) + $(4 * length(labels)) = $(Dimension(V2.sampler, n)); |S^ar| = $(description_size(V2.sampler)) bytes, |D^ar| = $(description_size(V2.decider)) bytes",),
        children=(hypotheses..., _relocate(audit, x -> V1), CITED_AR_INTERFACE, AR_FIELD_ALIGN,
                  toy_override_node(policy, predicates), game, encodes, _relocate(agreement, x -> x.decider.parts[1]), local_pcp,
                  CITED_CL_DIST_PROD, CITED_CL_DOWNSIZE, CITED_DOWNSIZE_TYPED, CITED_DOWNSIZE_CL_DIST, CITED_PERP_PERP,
                  _relocate(detyped_sampler.certificate, x -> x.sampler),
                  _relocate(detyped_decider.certificate, x -> x.decider)))
    Checked(V2, root)
end

# --- policy predicates of the AR stage (DESIGN 12.5 rows 6-11) ---------------------------------
function answer_reduce_predicates(V1::VerifierDescription, params::PCPParams, sigma::Int, lambda::Int, mu::Int, gamma::Int, n::Int,
                                  policy::ToyPolicy, fx::FrontEndFixture)
    degree_formula = maximum(occurrences(fx.pcp.tf.formula, length(fx.pcp.tf.layout.names)))
    pol = parameter_policy(params, degree_formula)
    six = (pol.P_shape, pol.P_formula_paper, pol.P_tail, pol.P_divisibility, pol.P_degree, pol.P_formula_structural)
    row6 = all(==(PASS), six) ? :PASS : any(==(FAIL), six) ? :FAIL : :NOT_EVALUABLE
    p6 = PolicyPredicate("AR P_shape, P_formula_paper, P_tail, P_divisibility, P_degree, structural formula check", row6;
                         detail="parameter_policy at (q, k, m, d, s, m') = ($(params.q), $(params.k), $(params.m), $(params.d), $(params.s), $(params.m_prime)), gamma = $(gamma), degree_formula = $(degree_formula): shape $(pol.P_shape), formula_paper $(pol.P_formula_paper), tail $(pol.P_tail), divisibility $(pol.P_divisibility), degree $(pol.P_degree), structural $(pol.P_formula_structural)")
    p7 = PolicyPredicate("AR P_growth, universal mu/gamma/tau, n>=C_0", :NOT_EVALUABLE;
                         detail="P_growth = $(pol.P_growth) (a', b' of lem:ld-soundness are symbols); mu = ceil(C_intro), gamma = ceil(2a_1/(b_1 b_2)), tau of eq:c_rep are universal constants (toy literals $(mu), $(gamma), $(policy.tau)); C_0 of thm:compression is not exposed")
    # def:pcpparams (gt-10:L1396-L1422) with prop:explicit-padded-succinct-deciders (L1226-L1275): 2^m >= 2T is explicit.
    logT = lambda * n * mu                          # log2 T = log2 (2^(lambda n))^mu
    m_bound_ok = params.m >= logT + 1
    p8 = PolicyPredicate("AR tuple equals pcpparams(n,T,Q,sigma,gamma)", :FAIL;
                         detail="pcpparams(n = $(n), T = 2^$(logT), Q = (lambda n)^mu = $(big(lambda * n)^mu), sigma = $(sigma), gamma = $(gamma)) requires 2^m >= 2T, i.e. m >= $(logT + 1) (prop:explicit-padded-succinct-deciders item 1), but the toy m = $(params.m)$(m_bound_ok ? "" : " < $(logT + 1)"); m(T, sigma), s(n, T, Q, sigma) and the a', b' conditions on k are otherwise NOT_EVALUABLE")
    p11 = PolicyPredicate("fixed-width sigma_1=length(canonical_bytes(D1)) printed as an exact integer", :PASS;
                          detail="sigma_1 = $(sigma) = length(canonical_bytes(D1)), fnv1a64 $(quote_hash(V1.decider)); $(V1.decider.term[1] == :Detype && V1.decider.term[4][1] == :TypedDecider && V1.decider.term[4][3][1] == :IntroFixed ? "two fixed lambda-byte slots (DESIGN 12.3)" : "NOT a fixed-width decider (unpadded)")")
    [p6, p7, p8, p11]
end

# --- P_pcp_encodes_D1: the honest FAIL ---------------------------------------------------------
"""
    pcp_encodes_D1_evidence(D1, fixture, lambda, mu, sigma, n) :: CertNode

Runs TB3's front end on the ACTUAL D1 (lowered into the program IR) at the
number of body transitions it actually takes on a sorted input, compares the
resulting succinct instance with the PCP fixture's, and records FAIL with
the printed (T, sigma_1): the fixture arithmetizes a 33-byte trivial decider
at T = 1, never D1 at T = (2^(lambda n))^mu.
"""
function pcp_encodes_D1_evidence(D1::DeciderDescription, fx::FrontEndFixture, lambda::Int, mu::Int, sigma::Int, n::Int)
    program = lower_decider(D1)
    quoted = quote_program(program; sort=:Decider)
    # A sorted input on which the detyped parser takes its shortest path (the
    # graph views cannot be parsed from empty questions: accept-on-invalid,
    # gt-06:L409-L427); the probe fuel covers the metered primitive's charge.
    input = (n, Bool[], Bool[], Bool[true], Bool[false])
    probe = bounded_trace(quoted, input, 256)
    halting_row = findfirst(r -> r.outcome != :running, probe.term.configurations)
    T_actual = halting_row === nothing ? 256 : halting_row - 1
    trace = bounded_trace(quoted, input, T_actual)
    sat = cook_levin(trace; gate_budget=1 << 20)
    actual = sat isa CompilationRefused ? (; m=nothing, M=nothing, clauses=nothing, refused=string(sat)) :
             (; m=sat.term.index_width, M=sat.term.variable_count, clauses=length(sat.term.clauses), refused=nothing)
    fixture_sat = fx.padded.term
    fixture_m = fx.params.m
    fixture_hash = quote_hash(fx.quoted.term)
    logT = lambda * n * mu
    detail = "the instance supplied to pcpverifier arithmetizes the fixture decider $(fixture_hash) (|D| = $(fx.sigma) bytes) at T = $(fx.T) with index width m = $(fixture_m), while the ACTUAL fixed-width D1 (fnv1a64 $(quote_hash(D1)), sigma_1 = $(sigma) bytes) lowered into the program IR halts after $(T_actual) body transitions on a sorted input and TB3's front end gives $(actual.refused === nothing ? "index width m = $(actual.m), M = $(actual.M) variables, $(actual.clauses) clauses" : "CompilationRefused ($(actual.refused))"); at the printed (T = 2^$(logT), sigma_1 = $(sigma)) no instance of index width $(fixture_m) indexes a trace of 2^$(logT) rows (prop:explicit-padded-succinct-deciders: 2^m >= 2T)"
    CertNode(ASSUMED, :P_pcp_encodes_D1;
        facts=(display="P_pcp_encodes_D1 | FAIL(owner=$(AR_GAME_OWNER)): $(detail)", status="FAIL", owner=AR_GAME_OWNER,
               D1_hash=quote_hash(D1), sigma_1=sigma, T_actual=T_actual, actual=actual, fixture_m=fixture_m, fixture_hash=fixture_hash,
               used_fuel=trace.term.result isa Value ? "halted" : string(trace.term.result)),
        children=(_relocate(trace.certificate, x -> trace.term),))
end

# --- the PCP encoding-consistency sub-test -------------------------------------------------------
# TB2's nine fig:decider-pcp replay cases (honest zero answers accept, one
# corrupted entry rejects by the named rule) run through THIS bit-level
# decider on the fixture's product questions at the zero seed: steps 1-4
# must agree with TB2's typed decider; the game case reaches step 5 and
# must record NOT_EXECUTED instead of TB2's pcpverifier.
function answer_reduce_agreement_node(typed_decider::DeciderDescription, params::PCPParams, s1::Int, pcp_bits::Int,
                                      fx::FrontEndFixture, lambda::Int, mu::Int, gamma::Int)
    F = _field_type(params.q)
    original = trivial_original_verifier(F, fx.params, fx.pcp.tf; n=2, T=fx.T, Q_len=1, sigma=fx.sigma, label=:tb7_agreement)
    tb2 = answer_reduce_pcp(original, lambda, mu, gamma).term
    run(x) = begin
        outcomes = NamedTuple[]
        seed = ntuple(_ -> zero(F), seed_dim(tb2.sampler))
        for case in _answer_reduce_replay_cases()
            lq, rq = sample_answer_reduce_questions(tb2, case.left, case.right, seed)
            la = _answer_reduce_replay_answer(F, case.left.pcp, tb2.decider.params)
            ra = _answer_reduce_replay_answer(F, case.right.pcp, tb2.decider.params)
            honest_tb2 = typed_answer_reduced_decider(tb2.decider, case.left, lq, case.right, rq, la, ra)
            side, entry = case.corrupt
            cl = side == :left ? _corrupt_replay_answer(la, entry) : la
            cr = side == :right ? _corrupt_replay_answer(ra, entry) : ra
            corrupt_tb2 = typed_answer_reduced_decider(tb2.decider, case.left, lq, case.right, rq, cl, cr)
            xq = falses(s1 + pcp_bits)          # the zero seed: every product question is the zero vector
            yq = copy(xq)
            tl, tr = _ar_label(String(case.left.role), case.left.pcp), _ar_label(String(case.right.role), case.right.pcp)
            honest = decide_traced(x, 2, tl, xq, tr, yq, encode_pcp_answer_bits(case.left.pcp, la, params), encode_pcp_answer_bits(case.right.pcp, ra, params))
            corrupt = decide_traced(x, 2, tl, xq, tr, yq, encode_pcp_answer_bits(case.left.pcp, cl, params), encode_pcp_answer_bits(case.right.pcp, cr, params))
            game = any(r -> r isa ARGameNotExecuted, honest[2])
            rule = isempty(corrupt[2]) ? :none : (last(corrupt[2]) isa ARStep ? last(corrupt[2]).rule : :not_executed)
            push!(outcomes, (; case.case, case.step, game,
                               honest_here=honest[1], honest_tb2=passed(honest_tb2),
                               corrupt_here=corrupt[1], corrupt_tb2=passed(corrupt_tb2), rule, case.expected_rule))
        end
        outcomes
    end
    check(x) = begin
        outcomes = run(x)
        ok = all(o.case == :game ? (o.game && !o.honest_here && !o.corrupt_here) :
                                   (o.honest_here == o.honest_tb2 == true && o.corrupt_here == o.corrupt_tb2 == false && o.rule == o.expected_rule)
                 for o in outcomes)
        CheckResult(ok, :answer_reduce_agreement; location=:AnswerReduceStepsAgreement, expected=:agreement, actual=outcomes)
    end
    result = check(typed_decider)
    executed = count(o -> !o.game, result.actual)
    CertNode(CHECKED, :AnswerReduceStepsAgreement;
        facts=(display="PCP encoding-consistency sub-test (local, fixture questions at the zero seed): $(executed) of $(length(result.actual)) fig:decider-pcp guard cases -- steps 1-4 -- agree with TB2's typed decider on honest accept and corrupted reject by the named rule through the bit codecs; the :game case reaches step 5 and records NOT_EXECUTED(owner=$(AR_GAME_OWNER)) and rejects", outcomes=result.actual),
        replay=_bound_replay(typed_decider, :AnswerReduceStepsAgreement, check))
end
