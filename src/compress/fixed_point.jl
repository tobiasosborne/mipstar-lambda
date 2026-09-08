# TB7 (DESIGN 12.6; briefs/44 (h)): executing D_{M,lambda} = Y Psi_{M,lambda}
# with the REAL Compress in the term. fig:halt_f (gt-12-compression.tex:
# L426-L455): step 1 runs M for n steps; steps 2-4 hand (S_lambda, D_halt)
# to Compress; step 5 runs the compressed decider. TB4's Psi_{M,lambda} is
# reused with S_lambda = the lowered ComputeSampler(lambda) and the
# Compressor = compress_descriptions under the policy carried in its bytes.
# The run constructs and reserializes D, checks the embedded self_code hash,
# simulates exactly two steps of M_loop (the nonhalting branch), runs
# Compress((S_lambda, D), lambda) at the description level and compares its
# sampler hash with the independent hash, and executes the compressed
# decider on the supplied transcript through the CEK evaluator (no host
# recursion: the Compressor is a primitive whose value is code, and the
# returned decider runs under Eval). lem:dhalt-values, lem:lambda and
# thm:halting stay CITED (L502-L519, L569-L576, L643-L720).

"The legal repeated anchor transcript of DESIGN 12.6: k components, each an (Anchor, Anchor) graph view on zero bodies with the canonical answer 0."
function anchor_transcript(D_compr::DeciderDescription, n::Int)
    term = D_compr.term
    term[1] in (:RepeatToy, :Repeat) || throw(ArgumentError("the compressed decider is a repetition"))
    k = term[1] == :RepeatToy ? term[2] : k_rep(term[2], term[3], term[4] // term[5], n)
    anchored = term[end]                       # (:Detype, ["Game","Anchor"], edges, (:TypedAnchor, D2))
    anchored[1] == :Detype || throw(ArgumentError("the repeated decider wraps a detyped anchored decider"))
    labels, edges = anchored[2], anchored[3]
    T = length(labels)
    t = findfirst(==("Anchor"), labels)
    neigh(v) = Bool[(v, w) in edges || (w, v) in edges for w in 1:T]
    unit(v) = Bool[w == v for w in 1:T]
    body_bits = _anchored_body_bits(anchored[4], n)
    xa = vcat(unit(t), neigh(t), falses(T), unit(t), falses(body_bits))
    yb = vcat(falses(T), unit(t), unit(t), neigh(t), falses(body_bits))
    x = frame_components([copy(xa) for _ in 1:k])
    y = frame_components([copy(yb) for _ in 1:k])
    a = frame_components([Bool[false] for _ in 1:k])
    b = frame_components([Bool[false] for _ in 1:k])
    (; k, x, y, a, b)
end
# The body length of the anchored question: the detyped AR question (its own graph view + the product question).
function _anchored_body_bits(typed_anchor, n::Int)
    D2 = typed_anchor[2]                       # (:Detype, labels54, edges, (:TypedDecider, labels54, AnswerReduce body))
    body = D2[4][3]
    S1_term = body[11]
    s1 = _s1_dimension(S1_term, n)
    q, m_prime = body[6], body[10]
    4 * length(D2[2]) + s1 + round(Int, log2(q)) * (2 * m_prime + 6)
end

"""
    halting_fixed_point(lambda; policy=TB7_TOY_POLICY, machine=TWO_STATE_LOOPING, tracer_index=2, seeds=2, independent_hash)

The five-step run of DESIGN 12.6 plus the fuel-boundary test; returns the
record and its CONSTRUCTED certificate node.
"""
function halting_fixed_point(lambda::Integer; policy::ConstructionPolicy=TB7_TOY_POLICY, machine::Program=TWO_STATE_LOOPING,
                             tracer_index::Integer=2, seeds::Integer=2, independent_hash::Union{Nothing,String}=nothing, fuel::Int=600_000)
    n = Int(tracer_index)
    lambda = Int(lambda)
    S_lambda = compute_sampler(lambda, policy; tracer_index=n)                  # ComputeSampler(lambda), fig:halt_f step 3
    sampler_program = lower_sampler(S_lambda)
    compressor = compressor_program(policy)
    V_halt = halting_verifier(machine, lambda; sampler=sampler_program, compress=compressor)
    D = V_halt.term.decider
    # 1. construct and reserialize.
    decoded = decode_program(D)
    reserialized = quote_program(decoded; sort=:Decider).term
    step1 = canonical_bytes(reserialized) == canonical_bytes(D) && decoded isa Fix
    # 2. the embedded self_code hash equals the outer quote hash.
    unfolded = _fix_unfold(decoded)
    inner_quote = unfolded.body.else_branch.code.args[1].args[2]
    step2 = inner_quote isa Quote && quote_hash(quote_program(inner_quote.code; sort=:Decider).term) == quote_hash(D)
    # 3. exactly two steps of M on the blank tape, nonhalting.
    halted, steps = _simulate_machine(machine.name, n)
    step3 = !halted && steps == n
    # 4. Compress((S_lambda, D), lambda) under the same policy: the sampler hash equals the independent hash.
    V_desc = VerifierDescription(S_lambda, lift_decider(D).term)
    compressed = compress(V_desc, lambda; policy, tracer_index=n, seeds)
    sampler_hash = quote_hash(compressed.term.sampler)
    step4 = sampler_hash == quote_hash(S_lambda) && (independent_hash === nothing || sampler_hash == independent_hash)
    # 5. execute D on the supplied transcript through the evaluator.
    transcript = anchor_transcript(compressed.term.decider, n)
    args = (n, transcript.x, transcript.y, transcript.a, transcript.b)
    outcome = eval_quoted(D, args, fuel; hard_cap=max(fuel, DEFAULT_HARD_CAP))
    step5 = outcome.result isa Value && outcome.result.value === true
    # The same transcript through the description interpreter (the compressed decider directly).
    direct = decide(compressed.term.decider, n, transcript.x, transcript.y, transcript.a, transcript.b)
    # The separately labelled SYNTHETIC evaluator-entry test (DESIGN 12.6): the lowered
    # introspection decider D1 of this run on an empty transcript needs exactly
    # `boundary` fuel units; one unit less is OutOfFuel at that boundary (a metered
    # description child never runs its (budget+1)-th step), never host recursion.
    v1 = compressed.certificate.facts.skeleton.input.input.input
    D1_program = quote_program(lower_decider(v1.payload.decider); sort=:Decider).term
    probe_args = (n, Bool[], Bool[], Bool[true], Bool[false])
    full = eval_quoted(D1_program, probe_args, fuel; hard_cap=max(fuel, DEFAULT_HARD_CAP))
    boundary = full.used
    below = eval_quoted(D1_program, probe_args, boundary - 1; hard_cap=max(fuel, DEFAULT_HARD_CAP))
    fuel_boundary = (; boundary, at=full.result, below=below.result, ok=full.result isa Value && below.result isa OutOfFuel && below.used == boundary - 1)
    steps = (step1, step2, step3, step4, step5)
    node = CertNode(CONSTRUCTED, :HaltingFixedPoint;
        facts=(display="D_{M,lambda} = Fix(Psi_{M,lambda}) with the REAL Compressor (compress_descriptions under $(policy)) and S_lambda = ComputeSampler(lambda) lowered; |D| = $(description_size(D)) bytes, fnv1a64 $(quote_hash(D)); (1) reserialized $(step1); (2) self_code hash == outer hash $(step2); (3) M_loop run $(n) steps, halted = $(halted) $(step3); (4) Compress((S_lambda, D), lambda).sampler hash $(sampler_hash) == S_lambda hash $(quote_hash(S_lambda))$(independent_hash === nothing ? "" : " == independent hash $(independent_hash)") $(step4); (5) the compressed decider on the supplied $(transcript.k)-component anchor transcript through the evaluator: $(outcome.result), $(outcome.used) fuel units, no host recursion $(step5) (directly on the description: $(direct)); synthetic fuel boundary of the lowered D1: $(boundary) units -> $(fuel_boundary.at), $(boundary - 1) -> $(fuel_boundary.below)",
               steps, sampler_hash, fuel_used=outcome.used, fuel_boundary, D_size=description_size(D), D_hash=quote_hash(D)),
        children=(CITED_DHALT_VALUES, CITED_LEM_LAMBDA, CITED_THM_HALTING,
                  _relocate(V_halt.certificate, x -> V_halt.term)))
    (; V_halt, D, S_lambda, compressed, sampler_hash, outcome, transcript, direct, steps, fuel_boundary, node)
end
