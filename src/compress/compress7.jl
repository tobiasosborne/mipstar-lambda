# TB7 (DESIGN 12; briefs/44 + addendum): Compress = Repeat o AnswerReduce o
# Introspect on descriptions with no stub on the composition path. TB4's
# `Compress` (src/compress.jl) is the composition -- its contracts, level
# chain, runtime composition and independence nodes stay the interface --
# with the three EXECUTABLE stages (TB6 Introspect, this file's AnswerReduce,
# TB5 Repeat) behind the CompressStage dispatch. `compress(V, lambda; policy)`
# is DESIGN 9.6's signature: it wraps the skeleton and adds the TB7 evidence
# (12.1 constructor order and universal-constant ASTs, the IntroGap AST,
# 12.2 bookkeeping, 12.3 fixed-width sigma_1 and code-dependency
# independence, 12.4 the predicate report, 12.5 chain coverage, 13.2 the
# residue inventory). `compress_terms` is the certificate-free construction
# of the same descriptions (the Compressor primitive of the halting fixed
# point and the independent hash of 12.6 step 4).

# --- the executable AnswerReduce stage -------------------------------------------------
"""
    ExecutableAnswerReduce(policy; tracer_index=2, seeds=4) <: CompressStage

The description-level AnswerReduce behind `AnswerReduce(stage, V, lambda, mu, gamma; params)`.
"""
struct ExecutableAnswerReduce <: CompressStage
    policy::ConstructionPolicy
    tracer_index::Int
    seeds::Int
    fixture::Ref{Any}
end
ExecutableAnswerReduce(policy::ConstructionPolicy; tracer_index::Integer=2, seeds::Integer=4) =
    ExecutableAnswerReduce(policy, Int(tracer_index), Int(seeds), Ref{Any}(nothing))
function _stage_fixture(stage::ExecutableAnswerReduce)
    stage.fixture[] === nothing && (stage.fixture[] = frontend_fixture())
    stage.fixture[]::FrontEndFixture
end

function AnswerReduce(stage::ExecutableAnswerReduce, checked::Union{Checked,_VERIFIER_INPUT},
                      lambda::Integer, mu::Integer, gamma::Integer; params::NamedTuple=(;))
    input, input_cert = _split(checked)
    V1 = _verifier_description(input)
    tracer_index = get(params, :n, stage.tracer_index)
    result = answer_reduce(V1, lambda, mu, gamma; policy=stage.policy, tracer_index, seeds=stage.seeds, fixture=_stage_fixture(stage))
    A = result.term
    time = Opaque("TIME_S(n) = TIME_D(n): $(A.decider.time_bound) (poly((lambda n)^mu, |D|, gamma) CITED); the fig:decider-pcp steps 1-4 execute, step 5 is NOT_EXECUTED(owner=$(AR_GAME_OWNER))", (:n,))
    dependencies = Tuple(unique((_sampler_dependencies(input)..., :lambda, :mu, :gamma, :sigma_1, :pcpparams)))
    gap = (Opaque("completeness: value-1 PCC strategy of V_n => value-1 SPCC strategy of V^ar_n", ()),
           Opaque("soundness: val*(V^ar_n) > 1 - eps => val*(V_n) >= 1 - delta(eps, n)", ()))
    output = StageVerifier(:AnswerReduce, A.sampler.level, time, time, Concrete(description_length(A)),
                           Opaque(string(A.decider.question_length), (:n,)), Opaque(string(A.decider.answer_length), (:n,)),
                           gap, dependencies, input, A)
    node = CertNode(CONSTRUCTED, :AnswerReduce;
        facts=(display="executable AnswerReduce (TB7) behind the CompressStage interface; level max(ell + 2, 5) = $(output.levels); TIME_S = TIME_D = $(time.description); sampler depends on $(join(String.(dependencies), ", "))",),
        children=(_relocate(result.certificate, x -> x.payload), _relocate(input_cert, x -> x.input)))
    Checked(output, node)
end

"A timing wrapper around one executable CompressStage; it preserves TB4 dispatch and its certificates."
struct TimedStage{S<:CompressStage} <: CompressStage
    inner::S
    label::Symbol
    walls::Dict{Symbol,Float64}
end
function Introspect(stage::TimedStage{<:ExecutableIntrospect}, checked::Union{Checked,_VERIFIER_INPUT}, lambda::Integer, ell::Integer; params::NamedTuple=(;))
    started = time()
    result = Introspect(stage.inner, checked, lambda, ell; params)
    stage.walls[stage.label] = time() - started
    result
end
function AnswerReduce(stage::TimedStage{<:ExecutableAnswerReduce}, checked::Union{Checked,_VERIFIER_INPUT}, lambda::Integer, mu::Integer, gamma::Integer; params::NamedTuple=(;))
    started = time()
    result = AnswerReduce(stage.inner, checked, lambda, mu, gamma; params)
    stage.walls[stage.label] = time() - started
    result
end
function Repeat(stage::TimedStage{<:ExecutableRepeat}, checked::Union{Checked,_VERIFIER_INPUT}, lambda::Integer, tau::Integer; params::NamedTuple=(;))
    started = time()
    result = Repeat(stage.inner, checked, lambda, tau; params)
    stage.walls[stage.label] = time() - started
    result
end

"The TB7 stage table: executable Introspect (fixed-width), AnswerReduce and Repeat under one policy."
function tb7_stages(policy::ToyPolicy; tracer_index::Integer=2, seeds::Integer=4, walls::Union{Nothing,Dict{Symbol,Float64}}=nothing)
    I = ExecutableIntrospect(; tuple=policy.intro_tuple, F_child=policy.child_fuel, tracer_index, seeds, fixed_width=true)
    A = ExecutableAnswerReduce(policy; tracer_index, seeds)
    R = ExecutableRepeat(; c_prime=policy.c_prime, tracer_index, seeds, repetitions=policy.repetitions)
    walls === nothing ? CompressStages(I, A, R) :
        CompressStages(TimedStage(I, :Introspect, walls), TimedStage(A, :AnswerReduce, walls), TimedStage(R, :Repeat, walls))
end

# --- DESIGN 12.1: the constructor order and the universal constants ------------------------------
"fig:compress (gt-12-compression.tex:L75-L98) as an AST: V3 = Repeat(AnswerReduce(Introspect(V, lambda, 9), lambda, mu, gamma), lambda, tau)."
const COMPRESS_ORDER_AST = :(Repeat(AnswerReduce(Introspect(V, lambda, 9), lambda, mu, gamma), lambda, tau))
function _order_ast_of(chain::Vector)
    ast = :V
    for stage in chain
        ast = stage.origin == :Introspect ? :(Introspect($(ast), lambda, 9)) :
              stage.origin == :AnswerReduce ? :(AnswerReduce($(ast), lambda, mu, gamma)) :
              stage.origin == :Repeat ? :(Repeat($(ast), lambda, tau)) : :(Unknown($(ast)))
    end
    ast
end
"The constructor-order AST read off a compressed verifier's stage chain."
constructor_order(C::Checked) = C.certificate.facts.order_ast

"""
    universal_constants_ast()

eq:mu-gamma, eq:re-eps-1, eq:re-eps-2, eq:c_rep and k(n) as ASTs in the
symbols a1, b1, a2, b2, C_intro, C_ar, c3, c3_prime (gt-12-compression.tex:
L229-L232, L263-L271, L289-L308, L347-L359); never replaced by literals.
"""
universal_constants_ast() = (;
    mu=:(ceil(C_intro)),
    gamma=:(ceil((2 * a1) / (b1 * b2))),
    epsilon1=:((1 / (8 * a1 * (lambda * n) ^ a1)) ^ (1 / b1)),
    epsilon2=:((epsilon1 / (8 * a2 * (lambda * n) ^ a2)) ^ (1 / b2)),
    tau=:(least_integer(tau, tau >= C_ar && forall((n, lambda), n >= tau && lambda >= 1, (lambda * n) ^ tau >= (1 / (c3 * epsilon2 ^ 17)) * ln(8 / epsilon2)))),
    k=:((lambda * n) ^ ((1 + c3_prime) * tau)))

# The hand transcription the emitted ASTs are compared with (a transcription
# check, DESIGN 9.2): the same equations written out independently.
const EXPECTED_UNIVERSAL_CONSTANTS = (;
    mu=Expr(:call, :ceil, :C_intro),
    gamma=Expr(:call, :ceil, Expr(:call, :/, Expr(:call, :*, 2, :a1), Expr(:call, :*, :b1, :b2))),
    epsilon1=Expr(:call, :^, Expr(:call, :/, 1, Expr(:call, :*, 8, :a1, Expr(:call, :^, Expr(:call, :*, :lambda, :n), :a1))), Expr(:call, :/, 1, :b1)),
    epsilon2=Expr(:call, :^, Expr(:call, :/, :epsilon1, Expr(:call, :*, 8, :a2, Expr(:call, :^, Expr(:call, :*, :lambda, :n), :a2))), Expr(:call, :/, 1, :b2)),
    tau=Expr(:call, :least_integer, :tau,
             Expr(:&&, Expr(:call, :>=, :tau, :C_ar),
                  Expr(:call, :forall, Expr(:tuple, :n, :lambda), Expr(:&&, Expr(:call, :>=, :n, :tau), Expr(:call, :>=, :lambda, 1)),
                       Expr(:call, :>=, Expr(:call, :^, Expr(:call, :*, :lambda, :n), :tau),
                            Expr(:call, :*, Expr(:call, :/, 1, Expr(:call, :*, :c3, Expr(:call, :^, :epsilon2, 17))), Expr(:call, :ln, Expr(:call, :/, 8, :epsilon2))))))),
    k=Expr(:call, :^, Expr(:call, :*, :lambda, :n), Expr(:call, :*, Expr(:call, :+, 1, :c3_prime), :tau)))

"""
    intro_gap_ast(lambda, n)

thm:introspection's entanglement bound (gt-08-introspection.tex:L809-L815) as
the max AST with its two branches, and the scalar floor branch with the
tracer values substituted SYMBOLICALLY (2^(2^(lambda n)) is never materialized).
"""
function intro_gap_ast(lambda::Integer, n::Integer)
    full = :(max(Ent(V_{2 ^ n}, 1 - delta_intro(epsilon, n)), (1 - delta_intro(epsilon, n)) * 2 ^ (2 ^ (lambda * n))))
    floor_branch = :((1 - delta_intro(epsilon, n)) * 2 ^ (2 ^ (lambda * n)))
    substituted = :((1 - delta_intro(epsilon, $(Int(n)))) * 2 ^ (2 ^ $(Int(lambda) * Int(n))))
    (; full, floor_branch, substituted, ent_branch=:(Ent(V_{2 ^ n}, 1 - delta_intro(epsilon, n))))
end

# --- DESIGN 13.2: the residue inventory -----------------------------------------------------------
"The audited inventory of theorem-like labels (lem:/thm:/prop:/cor:) allowed to remain CITED in the TB7 certificate (DESIGN 13.2 items 1-12)."
const TB7_RESIDUE_INVENTORY = Set([
    "prop:standard-succinct-sat", "prop:explicit-padded-succinct-deciders",
    "lem:ld-soundness", "lem:ld-complexity",
    "lem:pauli-completeness", "thm:pauli", "cor:pauli-binary", "lem:delta-bound", "lem:introparams-complexity", "lem:qld-complexity",
    "lem:detyping-verifiers",
    "thm:oracle-completeness", "thm:oracle-soundness",
    "thm:pcp-decider",
    "thm:ar",
    "lem:intro-sampler-complexity", "lem:intro-decider-complexity", "thm:introspection",
    "prop:anchoring", "thm:bvy", "thm:repetition",
    "lem:compress-independent-samplers", "thm:compression",
    "lem:dhalt-values", "lem:lambda", "thm:halting",
    "lem:cl-kth", "lem:cl-concat", "lem:cl-func-prod", "lem:cl-dist-prod", "lem:cl-downsize",
    "lem:downsize_sampler", "lem:downsize_typed_sampler", "lem:downsize-cl-dist", "lem:perp_perp"])
_theorem_like(label::AbstractString) = any(startswith(label, p) for p in ("lem:", "thm:", "prop:", "cor:"))

const CITED_PAULI_COMPLETENESS = _cited("lem:pauli-completeness", "gt-07-ldt.tex", 1232:1330,
    "the honest (EPR) strategy passes the Pauli basis test with certainty; general statement CITED beyond the exact tiny simulation")
const CITED_PAULI_BINARY = _cited("cor:pauli-binary", "gt-07-ldt.tex", 1470:1490,
    "the binary (self-dual basis) form of the Pauli rigidity statement; CITED")
const CITED_DELTA_BOUND = _cited("lem:delta-bound", "gt-07-ldt.tex", 1521:1560,
    "the canonical-parameter bound delta(eps, R) at introparams(R); CITED")
const CITED_INTROPARAMS_COMPLEXITY = _cited("lem:introparams-complexity", "gt-07-ldt.tex", 1565:1576,
    "introparams(R) is computable in polylog(R); CITED")
const CITED_BVY = _cited("thm:bvy", "gt-11-parallel-repetition.tex", 51:61,
    "the anchored parallel repetition decay (Bavarian-Vidick-Yuen); CITED")
const CITED_DHALT_VALUES = _cited("lem:dhalt-values", "gt-12-compression.tex", 502:519,
    "the value of V^halt_n: 1 if M halts in n steps, else the value of V^compr_n (the general fixed-point value argument; CITED)")
const CITED_LEM_LAMBDA = _cited("lem:lambda", "gt-12-compression.tex", 569:576,
    "the existence of lambda = poly(|M|) making V^halt lambda-bounded; CITED (the executable's lambda is a fixture literal)")
const CITED_THM_HALTING = _cited("thm:halting", "gt-12-compression.tex", 643:720,
    "the undecidability conclusion (MIP* = RE); CITED")
const CITED_COMPRESSION = _cited("thm:compression", "gt-12-compression.tex", 26:53,
    "the compression theorem's production-regime C_0, polynomial bounds, value-1 transfer and Ent lower bound; CITED (fig:compress is executed)")

# --- the descriptions of Compress without certificates ----------------------------------------------
function _edges_idx(typing::Typed)
    index = Dict(l => i for (i, l) in enumerate(typing.labels))
    Tuple{Int,Int}[(index[e[1]], index[e[2]]) for e in typing.edges]
end
_fits(bytes, lambda) = fixed_slot_fits(bytes, lambda)

"""
    compress_terms(V, lambda, policy; tracer_index=2) :: VerifierDescription

The descriptions Compress(V, lambda) builds, as terms only (no certificate
replays): the Compressor primitive of the halting fixed point and the
independent construction of DESIGN 12.6 step 4 and 12.3's ComputeSampler(lambda).
"""
function compress_terms(V::VerifierDescription, lambda::Integer, policy::ConstructionPolicy; tracer_index::Integer=2)
    policy isa ToyPolicy || throw(ArgumentError("production Compress needs the universal constants (mu, gamma, tau, the Pauli and PCP tuples), which are NOT_EVALUABLE symbols: supply a ToyPolicy (DESIGN 12.4)"))
    ell = COMPRESS_LEVELS
    t = policy.intro_tuple
    S1_term = (:Detype, (:Downsize, (:Intro, Int(lambda), ell, t.q, t.m, t.d)))
    S_eff = _fits(canonical_bytes(V.sampler), lambda) ? V.sampler.term : TRIVIAL_SAMPLER_TERM
    D_eff = _fits(canonical_bytes(V.decider), lambda) ? V.decider.term : TRIVIAL_DECIDER_TERM
    intro_labels = intro_type_labels(ell)
    D1_typed = (:TypedDecider, intro_labels, (:IntroFixed, Int(lambda), ell, t.q, t.m, t.d, policy.child_fuel, S_eff, D_eff))
    D1_term = (:Detype, copy(intro_labels), _edges_idx(intro_typing(ell)), D1_typed)
    V1 = VerifierDescription(_from_term(S1_term), _decider_from_term(D1_term))
    sigma = description_size(V1.decider)
    a = policy.pcp_tuple
    pcp_term = (:PCP, a.q, a.m, a.d, a.s, a.m_prime, policy.gamma, sigma)
    extra = V1.sampler.level - 3
    extra >= 0 || throw(ArgumentError("the PCP side is padded to the oracularized level; ell_1 < 3 is not a TB7 case"))
    padded = extra == 0 ? (:Downsize, pcp_term) : (:Pad, extra, (:Downsize, pcp_term))
    S2_typed = (:Product, (:Oracularize, S1_term), padded)
    typing54 = machine_typing(compile_sampler(S2_typed))
    labels54 = copy(typing54.labels)
    D2_typed = (:TypedDecider, labels54, (:AnswerReduce, Int(lambda), policy.mu, policy.gamma, sigma, a.q, a.m, a.d, a.s, a.m_prime, S1_term, D1_term))
    S2_term = (:Detype, S2_typed)
    D2_term = (:Detype, copy(labels54), _edges_idx(typing54), D2_typed)
    S_anch = (:Detype, (:Anchor, S2_term))
    D_anch = (:Detype, copy(ANCHOR_TYPING.labels), _edges_idx(ANCHOR_TYPING), (:TypedAnchor, D2_term))
    c = policy.c_prime
    S3_term = policy.repetitions > 0 ? repeat_toy_term(policy.repetitions, lambda, policy.tau, c, S_anch) :
              (:Repeat, Int(lambda), policy.tau, numerator(c), denominator(c), S_anch)
    D3_term = policy.repetitions > 0 ? (:RepeatToy, policy.repetitions, Int(lambda), policy.tau, numerator(c), denominator(c), D_anch) :
              (:Repeat, Int(lambda), policy.tau, numerator(c), denominator(c), D_anch)
    VerifierDescription(_from_term(S3_term), _decider_from_term(D3_term))
end

"The trivial verifier V* = (0, 0) of lem:compress-independent-samplers: ComputeSampler(lambda) = the sampler of Compress(V*, lambda)."
trivial_verifier_description() = VerifierDescription(_from_term(TRIVIAL_SAMPLER_TERM), _decider_from_term(TRIVIAL_DECIDER_TERM))
"ComputeSampler(lambda) under the policy: the compressed sampler of the trivial verifier (independent of every input)."
compute_sampler(lambda::Integer, policy::ConstructionPolicy; tracer_index::Integer=2) =
    compress_terms(trivial_verifier_description(), lambda, policy; tracer_index).sampler

"The parameter symbols DESIGN 12.3 requires of S^compr: {lambda, universal_constant_ids} and nothing of V."
const EXPECTED_COMPRESS_DEPENDENCIES = Set([:lambda, :ell, :introparams, :pcpparams, :gamma, :sigma_1, :tau, :c_prime, :repetitions])

# --- the TB7 predicate report (DESIGN 12.5, thirteen rows) ----------------------------------------------
function tb7_predicate_report(V::VerifierDescription, lambda::Int, n::Int, policy::ToyPolicy, v1::StageVerifier, v2::StageVerifier, v3::StageVerifier,
                              ar_predicates::Vector{PolicyPredicate})
    N = 2 ^ n
    R = big(N) ^ lambda
    V1, V2, V3 = v1.payload, v2.payload, v3.payload
    t = policy.intro_tuple
    s_N = Dimension(V.sampler, N)
    lines = pauli_policy_report(t; R, s_N=s_N isa QueryError ? -1 : s_N, lambda, description_bytes=description_length(V), F_child=policy.child_fuel, ell=COMPRESS_LEVELS)
    line(name) = only(l for l in lines if l.name == name)
    st(l) = l.status == P_PASS ? :PASS : l.status == P_FAIL ? :FAIL : l.status == P_NOT_EVALUABLE ? :NOT_EVALUABLE : :VACUOUS
    Q = pauli_Q(t)
    input_ok = V.sampler.field_size == 2 && V.sampler.typing isa Untyped && V.sampler.level == COMPRESS_LEVELS &&
               description_length(V) <= lambda && n >= 2
    p1 = PolicyPredicate("input field/level/lambda bounded; n>=2", input_ok ? :PASS : :FAIL;
                         detail="field $(V.sampler.field_size), level $(V.sampler.level) (= 9 of fig:compress), |V| = max(|S|, |D|) = max($(description_size(V.sampler)), $(description_size(V.decider))) = $(description_length(V)) <= lambda = $(lambda), n = $(n) >= 2; TIME_S/TIME_D are metered per query (constant on this fixture) and below n^lambda = $(n)^$(lambda)")
    p2 = PolicyPredicate("intro field admissible, m_I divides q_I, d_I=1", all(l -> l.status == P_PASS, (line(:admissible_field), line(:m_divides_q), line(:d_equals_1))) ? :PASS : :FAIL;
                         detail="$(line(:admissible_field).detail); $(line(:m_divides_q).detail); $(line(:d_equals_1).detail)")
    emb = line(:embedding_Q_ge_s)
    p3 = PolicyPredicate("intro embedding Q_I>=s_0(N): $(Q)>=$(s_N)", st(emb); owner=st(emb) == :PASS ? nothing : "Q_I<s_0", detail=emb.detail)
    p4 = PolicyPredicate("intro canonical tuple equality; source M_I>=R", (line(:canonical_introparams).status == P_PASS && line(:capacity_M_ge_R).status == P_PASS) ? :PASS : :FAIL;
                         detail="$(line(:canonical_introparams).detail); $(line(:capacity_M_ge_R).detail)")
    non_pauli = [l for l in intro_type_labels(COMPRESS_LEVELS) if !is_pauli_label(l)]
    p5 = PolicyPredicate("non-Pauli introspection answer schemas: Introspect, Sample, Read, every Hide stage (both roles)", st(emb) == :PASS ? :PASS : :VACUOUS;
                         owner=st(emb) == :PASS ? nothing : "Q_I<s_0",
                         detail="$(length(non_pauli)) non-Pauli types at ell = 9; Q_I = $(Q) < s_0(N) = $(s_N) and 3Q_I = $(3Q) < $(s_N): the F_2^Q wire format cannot embed the nine-bit input space, so every non-Pauli schema is rejected at the embedding guard; executed non-Pauli schemas = 0 (only the Pauli-typed predicates execute at TB7)")
    k_source = k_rep(lambda, policy.tau, policy.c_prime, n)
    p12 = PolicyPredicate("repeat k_toy=(lambda*n)^((1+c')tau)", policy.repetitions == k_source ? :PASS : :FAIL;
                          detail="k_toy = $(policy.repetitions) vs (lambda n)^((1+c')tau) = ($(lambda)*$(n))^((1+$(policy.c_prime))*$(policy.tau)) = $(k_source)")
    B = B_rep(lambda, policy.tau, n)
    question_component = Dimension(V2.sampler, n) + 8
    a = policy.pcp_tuple
    largest_answer = answer_bit_length(PCPType(:DLine, 6), PCPParams(a.q, a.k, a.m, a.d, a.s, a.m_prime, policy.gamma))
    p13 = PolicyPredicate("repeat question and answer component guard", (question_component <= B && largest_answer <= B) ? :PASS : :FAIL;
                          detail="B(n) = (lambda n)^tau = $(B); anchored question component s_2 + 8 = $(question_component) bits <= B; largest honest line answer (m'+6)(m'd+1) log q = $(largest_answer) bits <= B (not rejected by the guard)")
    p6, p7, p8, p11 = ar_predicates
    p9 = PolicyPredicate("P_pcp_encodes_D1: PCP instance arithmetizes the actual fixed-width D1 trace at printed (T,sigma_1)", :FAIL; owner=AR_GAME_OWNER,
                         detail="see the AnswerReduce stage's P_pcp_encodes_D1 evidence node: the instance arithmetizes the fixture's trivial decider at T = 1, not D1 at T = (2^(lambda n))^mu")
    p10 = PolicyPredicate("enu:ar-game against the actual D1", :NOT_EXECUTED; owner=AR_GAME_OWNER,
                          detail="fig:decider-pcp step 5 records NOT_EXECUTED and rejects whenever it is reached (gt-10:L2060-L2063)")
    PolicyPredicate[p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13]
end

# --- tree utilities -----------------------------------------------------------------------------
function _nodes(node::CertNode, found=CertNode[])
    push!(found, node)
    foreach(child -> _nodes(child, found), node.children)
    found
end
"A copy of the tree without every node carrying `rule`."
function _without(node::CertNode, rule::Symbol)
    children = Tuple(_without(child, rule) for child in node.children if child.rule != rule)
    CertNode(node.grade, node.rule; facts=node.facts, children, replay=node.replay)
end
"The per-sampler chain/replay table of DESIGN 12.5: every SamplerValidity row in the tree."
function chain_coverage(root::CertNode)
    rows = NamedTuple[]
    function walk(node, parent)
        if node.rule == :SamplerValidity && haskey(node.facts, :chain_set_id)
            reports = haskey(node.facts, :reports) ? node.facts.reports : []
            id = parent === nothing ? :root : parent.rule
            hash = parent !== nothing && haskey(parent.facts, :display) ? (m = match(r"fnv1a64 = ([0-9a-f]{16})", parent.facts.display); m === nothing ? "" : m[1]) : ""
            selected = isempty(reports) ? 0 : maximum(r.report.completed_replays for r in reports)
            push!(rows, (; sampler_id=id, hash, chain_set_id=node.facts.chain_set_id, selected, views=length(reports),
                           distinct=sum((r.report.distinct_chains for r in reports); init=0),
                           replayed=sum((r.report.completed_replays for r in reports); init=0),
                           ok=haskey(node.facts, :ok) ? node.facts.ok : false))
        end
        foreach(child -> walk(child, node), node.children)
    end
    walk(root, nothing)
    rows
end
"The table as printed lines: sampler_id / hash / chain_set_id / selected / distinct / replayed."
function chain_coverage_text(rows)
    isempty(rows) && return "VACUOUS(owner=chain-coverage): no sampler validity row"
    join(("$(lpad(string(r.sampler_id), 18)) $(r.hash) $(rpad(r.chain_set_id, 44)) selected=$(r.selected) views=$(r.views) distinct=$(r.distinct) replayed=$(r.replayed)$(r.ok ? "" : " NOT OK")" for r in rows), "\n")
end

"The CITED labels of a tree (theorem-like only when `theorem_like`)."
function cited_labels(root::CertNode; theorem_like::Bool=true)
    labels = Set{String}()
    for node in _nodes(root)
        node.grade == CITED || continue
        label = haskey(node.facts, :label) ? String(node.facts.label) : String(node.rule)
        (!theorem_like || _theorem_like(label)) && push!(labels, label)
    end
    labels
end

"A lossless, one-node-per-line rendering of a TB7 certificate, including grades and cited source spans."
function certificate_tree_text(root::CertNode)
    lines = String[]
    function visit(node::CertNode, prefix::String, is_last::Bool, is_root::Bool=false)
        stem = is_root ? "" : is_last ? "└─ " : "├─ "
        citation = node.grade == CITED && haskey(node.facts, :source) && haskey(node.facts, :lines) ?
                   "  [$(node.facts.source):$(first(node.facts.lines))-$(last(node.facts.lines))]" : ""
        push!(lines, prefix * stem * string(node.grade) * " " * string(node.rule) * citation)
        child_prefix = prefix * (is_root ? "" : is_last ? "   " : "│  ")
        for (i, child) in enumerate(node.children)
            visit(child, child_prefix, i == length(node.children))
        end
    end
    visit(root, "", true, true)
    join(lines, "\n")
end

# --- compress ------------------------------------------------------------------------------------------
"""
    compress(V, lambda; policy=TB7_TOY_POLICY, tracer_index=2, seeds=4) :: Checked{VerifierDescription}

DESIGN 9.6's `compress`: TB4's `Compress` with the three executable stages,
returning the compressed VerifierDescription with the TB7 evidence tree.
"""
function compress(V::VerifierDescription, lambda::Integer; policy::ConstructionPolicy=TB7_TOY_POLICY, tracer_index::Integer=2, seeds::Integer=4)
    policy isa ToyPolicy || throw(ArgumentError("production Compress is NOT_EVALUABLE without the universal constants: supply a ToyPolicy (DESIGN 12.4)"))
    n = Int(tracer_index)
    lambda = Int(lambda)
    walls = Dict{Symbol,Float64}()
    stages = tb7_stages(policy; tracer_index=n, seeds, walls)
    started = time()
    C4 = Compress(V, lambda; stages, mu=policy.mu, gamma=policy.gamma, tau=policy.tau, stage_params=(; n))
    walls[:compress] = time() - started
    v3 = C4.term.input
    v2 = v3.input
    v1 = v2.input
    (v1.origin == :Introspect && v2.origin == :AnswerReduce && v3.origin == :Repeat) || error("the stage chain is not fig:compress's")
    out = v3.payload::VerifierDescription
    V1, V2 = v1.payload::VerifierDescription, v2.payload::VerifierDescription
    chain = Any[v1, v2, v3]
    # 12.1 the constructor order.
    order_ast = _order_ast_of(chain)
    order = CertNode(CHECKED, :ConstructorOrder;
        facts=(display="fig:compress order (gt-12-compression.tex:L75-L98): $(order_ast) == $(COMPRESS_ORDER_AST)", order_ast, expected=COMPRESS_ORDER_AST),
        # The attached term is the output description; the stage chain is the skeleton's (bound by OutputBinding).
        replay=x -> CheckResult(x === out && _order_ast_of(_chain(C4.term)[1:3]) == COMPRESS_ORDER_AST, :constructor_order;
                                location=:ConstructorOrder, expected=COMPRESS_ORDER_AST, actual=_order_ast_of(_chain(C4.term)[1:3])))
    constants = universal_constants_ast()
    universal = CertNode(CHECKED, :UniversalConstants;
        facts=(display="eq:mu-gamma, eq:re-eps-1, eq:re-eps-2, eq:c_rep and k(n) carried as ASTs in the symbols a1, b1, a2, b2, C_intro, C_ar, c3, c3' (gt-12:L229-L232, L263-L271, L289-L308, L347-L359): mu = $(constants.mu); gamma = $(constants.gamma); epsilon1 = $(constants.epsilon1); epsilon2 = $(constants.epsilon2); tau = $(constants.tau); k(n) = $(constants.k); the ToyPolicy substitutes mu = $(policy.mu), gamma = $(policy.gamma), tau = $(policy.tau), c' = $(policy.c_prime) as literals in the DESCRIPTIONS only, never in these ASTs",
               ast=constants),
        replay=x -> CheckResult(universal_constants_ast() == EXPECTED_UNIVERSAL_CONSTANTS, :universal_constants; location=:UniversalConstants,
                                expected=EXPECTED_UNIVERSAL_CONSTANTS, actual=universal_constants_ast()))
    # 12.1 / 9.2 the IntroGap AST with its two graded branches.
    gap = intro_gap_ast(lambda, n)
    floor_node = CertNode(CHECKED, :IntroGapFloor;
        facts=(display="the scalar entanglement-floor branch $(gap.floor_branch) with lambda = $(lambda), n = $(n) substituted symbolically: $(gap.substituted) (the integer 2^(2^$(lambda * n)) is never materialized)", branch=gap.floor_branch, substituted=gap.substituted),
        replay=x -> begin
            g = intro_gap_ast(lambda, n)
            ok = g.full.head == :call && g.full.args[1] == :max && length(g.full.args) == 3 && g.full.args[3] == g.floor_branch &&
                 g.substituted == :((1 - delta_intro(epsilon, $(n))) * 2 ^ (2 ^ $(lambda * n)))
            CheckResult(ok, :intro_gap_floor; location=:IntroGapFloor, expected=g.floor_branch, actual=g.full)
        end)
    ent_node = CertNode(CITED, Symbol("thm:introspection");
        facts=(display="gt-08-introspection.tex:L809-L815 (thm:introspection): the Ent(V_{2^n}, 1 - delta) branch of the max and the semantic max implication are CITED, never evaluated",
               source="gt-08-introspection.tex", lines=809:815, label="thm:introspection"))
    gap_node = CertNode(CHECKED, :IntroGap;
        facts=(display="IntroGap(epsilon, n, delta_intro, $(gap.full)): a max node with exactly two children, the CHECKED scalar floor branch and the CITED Ent branch (DESIGN 9.2)", ast=gap.full),
        children=(floor_node, ent_node),
        replay=x -> CheckResult(intro_gap_ast(lambda, n).full == :(max(Ent(V_{2 ^ n}, 1 - delta_intro(epsilon, n)), (1 - delta_intro(epsilon, n)) * 2 ^ (2 ^ (lambda * n)))), :intro_gap; location=:IntroGap))
    # 12.2 the bookkeeping table.
    rows = bookkeeping_rows(V, V1, V2, out, lambda, n, policy)
    row_certs = Tuple(CertNode(CHECKED, :LawCert;
        facts=(display="TB7 bookkeeping $(r.stage): field $(r.field), level $(r.level), dimension $(r.dimension) = $(r.law) = $(r.law_value)",
               stage=r.stage, expected=(r.field, r.level, r.law_value)),
        replay=x -> begin
            fresh = bookkeeping_rows(V, V1, V2, x, lambda, n, policy)[i]
            CheckResult(x === out && (fresh.field, fresh.level, fresh.dimension) == (r.field, r.level, r.law_value),
                        :bookkeeping_law; location=Symbol("TB7_row_$(i)"), expected=(r.field, r.level, r.law_value),
                        actual=(fresh.field, fresh.level, fresh.dimension))
        end) for (i, r) in enumerate(rows))
    bookkeeping = CertNode(CHECKED, :Bookkeeping;
        facts=(display="DESIGN 12.2 table at n = $(n):\n" * bookkeeping_text(rows), rows),
        children=row_certs,
        replay=x -> begin
            x === out || return CheckResult(false, :bookkeeping; location=:Bookkeeping, actual=:borrowed)
            fresh = bookkeeping_rows(V, V1, V2, x, lambda, n, policy)
            ok = length(fresh) == length(rows) && all(f.field == r.field && f.level == r.level && f.dimension == r.dimension && f.law_value == r.law_value && f.dimension == f.law_value for (f, r) in zip(fresh, rows))
            CheckResult(ok, :bookkeeping; location=:Bookkeeping, expected=[(r.stage, r.field, r.level, r.dimension) for r in rows], actual=[(r.stage, r.field, r.level, r.dimension, r.law_value) for r in fresh])
        end)
    # 12.3 fixed-width sigma_1 and code-dependency independence.
    D1 = V1.decider
    sigma = description_size(D1)
    fixed_length = fixed_width_length(lambda, COMPRESS_LEVELS, policy)
    sigma_node = CertNode(CHECKED, :FixedWidthSigma;
        facts=(display="sigma_1 = |D1| = $(sigma) bytes = the fixed-width length $(fixed_length) of (lambda, ell, tuple, F_child) = ($(lambda), 9, $(policy.intro_tuple), $(policy.child_fuel)): two lambda-byte slots (2 * $(lambda) = $(2lambda)) + $(fixed_length - 2lambda) bytes of labels and parameters; SOURCE_REPAIR(intro-decider-fixed-width), DESIGN 12.3", sigma_1=sigma, fixed_length),
        replay=x -> begin
            x === out || return CheckResult(false, :fixed_width_sigma; location=:FixedWidthSigma, actual=:borrowed)
            d = V1.decider
            body = d.term[4][3]
            CheckResult(description_size(d) == fixed_length && d.term[1] == :Detype && d.term[4][1] == :TypedDecider && body[1] == :IntroFixed,
                        :fixed_width_sigma; location=:FixedWidthSigma, expected=fixed_length, actual=description_size(d))
        end)
    fixed_width = CertNode(SOURCE_REPAIR, :IntroDeciderFixedWidth;
        facts=(display="gt-08-introspection.tex:L757-L776 stores V' in the decider (trivial code when |V| > lambda) and proves only a polynomial upper bound on |D^(1)|, while thm:ar (gt-10:L2094-L2096) makes S^ar depend on |D^(1)| and lem:compress-independent-samplers (gt-12:L128-L147) needs equal lengths: the executable stores S and D in two fixed lambda-byte slots so sigma_1 is an exact function of (lambda, ell): SOURCE_REPAIR(intro-decider-fixed-width)",
               source="gt-08-introspection.tex", lines=757:776))
    deps = parameter_dependencies(canonical_bytes(out.sampler))
    fresh_sampler = compute_sampler(lambda, policy; tracer_index=n)
    independence = CertNode(CHECKED, :CodeDependencyIndependence;
        facts=(display="dependencies(S^compr) by syntax walk = {$(join(sort(string.(collect(deps))), ", "))} = {lambda, universal_constant_ids} (DESIGN 12.3); S^compr bytes ($(description_size(out.sampler)) B, fnv1a64 $(quote_hash(out.sampler))) equal ComputeSampler(lambda) = the sampler of Compress(V*, lambda) on the trivial V* (lem:compress-independent-samplers), so no byte of V reaches the sampler", dependencies=deps, hash=quote_hash(out.sampler)),
        replay=x -> CheckResult(parameter_dependencies(canonical_bytes(x.sampler)) == EXPECTED_COMPRESS_DEPENDENCIES &&
                                canonical_bytes(x.sampler) == canonical_bytes(compute_sampler(lambda, policy; tracer_index=n)),
                                :code_dependency_independence; location=:CodeDependencyIndependence, expected=EXPECTED_COMPRESS_DEPENDENCIES,
                                actual=parameter_dependencies(canonical_bytes(x.sampler))))
    # 12.4 the predicate report.
    ar_node = only(n_ for n_ in _nodes(C4.certificate) if n_.rule == :toy_override && haskey(n_.facts, :predicates))
    ar_predicates = ar_node.facts.predicates
    predicates = tb7_predicate_report(V, lambda, n, policy, v1, v2, v3, ar_predicates)
    recompute = x -> tb7_predicate_report(V, lambda, n, policy, v1, v2, v3, ar_predicates)
    report = toy_override_node(policy, predicates; extra=(policy_grade_validation_node(predicates, recompute), toy_contract_audit_node(predicates)))
    # 12.5 chain coverage.
    inner = _without(C4.certificate, Symbol("lem:commute"))
    coverage_rows = chain_coverage(inner)
    coverage = CertNode(isempty(coverage_rows) ? ASSUMED : CHECKED, :ChainCoverage;
        facts=(display=(isempty(coverage_rows) ? "VACUOUS(owner=chain-coverage)" : "per-sampler chain/replay counts on the declared chain sets ($(length(coverage_rows)) sampler rows, every intermediate sampler included):\n" * chain_coverage_text(coverage_rows)),
               rows=coverage_rows, status=isempty(coverage_rows) ? "VACUOUS" : "PASS", owner=isempty(coverage_rows) ? "chain-coverage" : nothing),
        replay=isempty(coverage_rows) ? nothing : (x -> CheckResult(all(r.ok && r.replayed >= r.distinct && r.replayed > 0 for r in coverage_rows), :chain_coverage; location=:ChainCoverage, actual=coverage_rows)))
    commute_note = CertNode(CONSTRUCTED, :ResidueFilter;
        facts=(display="lem:commute (gt-08:L923-L953) is removed from the TB7 tree: it is a source anchor of the honest-strategy simulation, which TB7 does not run (no non-Pauli transcript executes at Q_I < s_0), and DESIGN 13.2 excludes it from the residue inventory",))
    residue_extra = CertNode(CONSTRUCTED, :ResidueLeaves;
        facts=(display="DESIGN 13.2 residue items not cited by a stage constructor: 3 (Pauli rigidity family), 9 (thm:bvy), 10 (thm:compression, cited by the skeleton), 11 (lem:dhalt-values, lem:lambda and thm:halting, also cited by the fixed-point run)",),
        children=(CITED_PAULI_COMPLETENESS, CITED_PAULI_BINARY, CITED_DELTA_BOUND, CITED_INTROPARAMS_COMPLEXITY, CITED_QLD_COMPLEXITY, CITED_BVY,
                  CITED_DHALT_VALUES, CITED_LEM_LAMBDA, CITED_THM_HALTING))
    binding = CertNode(CHECKED, :OutputBinding;
        facts=(display="the attached term is the Repeat stage's payload (sampler and decider by identity)",),
        replay=x -> CheckResult(x === out || (x.sampler === out.sampler && x.decider === out.decider), :output_binding; location=:OutputBinding))
    root_children = (order, universal, gap_node, bookkeeping, sigma_node, fixed_width, independence, report, coverage, commute_note, residue_extra,
                     binding, _relocate(inner, x -> C4.term))
    labels = cited_labels(CertNode(CONSTRUCTED, :probe; children=root_children))
    inventory = CertNode(CHECKED, :ResidueInventory;
        facts=(display="CITED theorem-like labels in the tree ($(length(labels))) == DESIGN 13.2 inventory ($(length(TB7_RESIDUE_INVENTORY))): missing = $(sort(collect(setdiff(TB7_RESIDUE_INVENTORY, labels)))), phantom = $(sort(collect(setdiff(labels, TB7_RESIDUE_INVENTORY))))", labels=labels),
        replay=x -> CheckResult(labels == TB7_RESIDUE_INVENTORY,
                                :residue_inventory; location=:ResidueInventory, expected=TB7_RESIDUE_INVENTORY, actual=labels))
    census = Dict(g => 0 for g in instances(Grade))
    root = CertNode(CONSTRUCTED, :CompressOnDescriptions;
        facts=(display="Compress(V, lambda = $(lambda)) = Repeat o AnswerReduce o Introspect on descriptions under $(policy): level chain $(join(level_chain(C4.term), " -> ")); dimensions $(Dimension(V.sampler, n)) -> $(Dimension(V1.sampler, n)) -> $(Dimension(V2.sampler, n)) -> $(Dimension(v3.payload.sampler.parts[1], n)) -> $(Dimension(out.sampler, n)) at n = $(n); |S^compr| = $(description_size(out.sampler)) B (fnv1a64 $(quote_hash(out.sampler))), |D^compr| = $(description_size(out.decider)) B (fnv1a64 $(quote_hash(out.decider))); construction wall $(round(walls[:compress]; digits=3)) s",
               order_ast, chain=[s.origin for s in chain], predicates, walls, skeleton=C4.term),
        children=(root_children..., inventory))
    Checked(out, root)
end

# --- DESIGN 12.2 bookkeeping ---------------------------------------------------------------------------
"The fixed-width length of the (detyped) introspection decider as a function of (lambda, ell, tuple, F_child) alone."
function fixed_width_length(lambda::Integer, ell::Integer, policy::ToyPolicy)
    t = policy.intro_tuple
    labels = intro_type_labels(ell)
    typed = (:TypedDecider, labels, (:IntroFixed, Int(lambda), Int(ell), t.q, t.m, t.d, policy.child_fuel, TRIVIAL_SAMPLER_TERM, TRIVIAL_DECIDER_TERM))
    length(decider_term_bytes((:Detype, copy(labels), _edges_idx(intro_typing(ell)), typed)))
end
function bookkeeping_rows(V, V1, V2, V3, lambda::Int, n::Int, policy::ToyPolicy)
    t, a = policy.intro_tuple, policy.pcp_tuple
    s0 = Dimension(V.sampler, n)
    s1_law = (3t.m + 3) * round(Int, log2(t.q)) + 4 * (32 + 2 * COMPRESS_LEVELS)
    typed_ar = V2.sampler.parts[1]
    anchored = V3.sampler.parts[1]
    s2_typed_law = Dimension(V1.sampler, n) + (2a.m_prime + 6) * a.k
    s2_law = s2_typed_law + 4 * 54
    k = policy.repetitions
    [(; stage="input V", field=V.sampler.field_size, level=V.sampler.level, dimension=s0, law="s_0(n)", law_value=s0, dependency="S_0, D_0"),
     (; stage="V1 = Intro(V, lambda, 9)", field=V1.sampler.field_size, level=V1.sampler.level, dimension=Dimension(V1.sampler, n), law="(3m_I+3) log q_I + 4(32 + 2 ell)", law_value=s1_law, dependency="sampler: lambda; decider: V, lambda"),
     (; stage="typed AR", field=typed_ar.field_size, level=typed_ar.level, dimension=Dimension(typed_ar, n), law="s_1 + (2m'_A+6) log q_A", law_value=s2_typed_law, dependency="S_1, lambda, mu, gamma, sigma_1"),
     (; stage="V2 = detype(typed AR)", field=V2.sampler.field_size, level=V2.sampler.level, dimension=Dimension(V2.sampler, n), law="s_1 + (2m'_A+6) log q_A + 4|Type^ar|", law_value=s2_law, dependency="same sampler dependencies"),
     (; stage="anchored V2", field=anchored.field_size, level=anchored.level, dimension=Dimension(anchored, n), law="s_2 + 8", law_value=s2_law + 8, dependency="sampler: S_2; decider: D_2"),
     (; stage="V3 = repeat", field=V3.sampler.field_size, level=V3.sampler.level, dimension=Dimension(V3.sampler, n), law="k (s_2 + 8), k = $(k) (toy; k(n) = (lambda n)^((1+c')tau) printed FAIL)", law_value=k * (s2_law + 8), dependency="S_2, lambda, tau")]
end
function bookkeeping_text(rows)
    lines = ["| stage | field | level | dimension | exact dimension law | description dependency |", "|---|---:|---:|---:|---|---|"]
    for r in rows
        push!(lines, "| $(r.stage) | $(r.field) | $(r.level) | $(r.dimension) | $(r.law) = $(r.law_value) | $(r.dependency) |")
    end
    join(lines, "\n")
end

# --- the TB7 input fixture (DESIGN 12.5) -----------------------------------------------------------------
"The nine-level, nine-bit coordinate-identity CL map: stage j owns the nonzero factor {e_j} with the 1 x 1 identity."
function coordinate_identity_map(s::Integer=9)
    F = GF2
    s = Int(s)
    child = CLZero(F, s, Int[])
    for j in s:-1:1
        # Inner stages act on the enclosing rest register (factor (+) rest = the
        # parent's rest); only the top stage spans the ambient basis.
        child = _clstep(F, s, [j], collect(j+1:s), reshape([one(F)], 1, 1), child, BranchConst(child); require_ambient=(j == 1))
    end
    child
end
"The TB7 input verifier: V = (identity_9, copy decider), s_0 = 9, level 9, |V| <= lambda, deterministic value-one answers (a = x, b = y)."
function tb7_input_verifier(; s::Integer=9, tracer_index::Integer=4)
    L = coordinate_identity_map(s)
    S = describe_cl(L, L, 2; tracer_index)
    S isa NotDescribable && error("the coordinate identity is describable: $(S)")
    VerifierDescription(S.term, copy_decider().term)
end
"A byte-distinct second input at the same lambda: the same sampler with the diagnostic decider (a decider of a different byte length)."
tb7_input_verifier_prime(; s::Integer=9) = VerifierDescription(tb7_input_verifier(; s).sampler, diagnostic_decider([1, 3]).term)
"A third input straddling |V| <= lambda: its 17000-coordinate diagnostic decider exceeds lambda while the sampler remains the same nine-level identity."
function tb7_input_verifier_large(; copies::Integer=17000, s::Integer=9)
    S = tb7_input_verifier(; s).sampler
    VerifierDescription(S, diagnostic_decider(collect(1:Int(copies))).term)
end

"Sample `count` final question pairs of the compressed sampler on seeded uniform seeds (DESIGN 12.5: 16 final questions)."
function final_questions(S::SamplerDescription, n::Integer, count::Integer; rng_seed::Integer=0x7B7)
    s = _raise(Dimension(S, n))
    rng = MersenneTwister(rng_seed)
    [(z = GF2[GF2(rand(rng, 0:1)) for _ in 1:s]; (; z, questions=sample_questions(S, n, z))) for _ in 1:count]
end
