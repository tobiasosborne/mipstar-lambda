# TB7 (briefs/39 and briefs/43 API request 1): the lowering of descriptions
# into the DESIGN 1.1 program IR, so a description runs under `Eval` fuel
# with the interpreter-step unit of DESIGN 11.4 as the fuel unit.
#
#   lower_sampler(S)  = Lambda(7, sampler_machine(bytes, mode, n, w, j, u, y, t))   sort Sampler
#   lower_decider(D)  = Lambda(5, decider_machine(bytes, n, x, y, a, b))            sort Decider
#   lift_decider(q)   = the DeciderDescription (:Program, bytes) of a Quoted{Decider}
#
# The three description primitives run the universal description
# interpreter on the quoted bytes with the REMAINING Eval fuel as the step
# budget (programs.jl DESCRIPTION_PRIMITIVES): every metered step is one
# fuel unit, the (budget+1)-th step is never executed, and a timeout is the
# evaluator's OutOfFuel. `compress_descriptions(pair, lambda, policy)` is
# the Compressor of the halting fixed point: it runs the description-level
# Compress on the quoted (sampler, decider) pair under the policy carried in
# its byte literal and returns the compressed decider's code.

const _SAMPLER_MODES = (:Dimension, :Marginal, :Linear, :Factor)
_bits_gf2(bits::Vector{Bool}) = GF2[GF2(Int(b)) for b in bits]

# sampler_machine(bytes, mode, n, w, j, u, y, t): mode 0..3 selects the
# query; w = false is alice, true is bob; u is the seed (Marginal) or prefix;
# y the Linear input; t the type label's UTF-8 bytes (empty = untyped).
# Answers: Dimension -> Int; the others -> Vector{Bool} (F_2 vectors and
# factor indicators). Only F_2 (normal form) descriptions are lowered.
function _run_sampler_machine(bytes, mode, n, w, j, u, y, t, budget::Int)
    (bytes isa Vector{UInt8} && mode isa Int && n isa Int && w isa Bool && j isa Int &&
     u isa Vector{Bool} && y isa Vector{Bool} && t isa Vector{UInt8}) || return nothing
    0 <= mode <= 3 || return nothing
    S = try
        decode_sampler(bytes)
    catch error
        error isa ArgumentError && return nothing
        rethrow()
    end
    S.field_size == 2 || return nothing
    label = isempty(t) ? nothing : String(copy(t))
    player = w ? :bob : :alice
    q = mode == 0 ? DimensionQuery(n) :
        mode == 1 ? MarginalQuery(n, player, j, _bits_gf2(u), label) :
        mode == 2 ? LinearQuery(n, player, j, _bits_gf2(u), _bits_gf2(y), label) :
                    FactorQuery(n, player, j, _bits_gf2(u), label)
    ctx = Meter(budget)
    answer = try
        _validated_answer(machine(S), q, ctx)
    catch error
        error isa FuelExhausted && return :timeout
        error isa ArgumentError && return nothing
        rethrow()
    end
    value = answer isa Int ? answer :
            eltype(answer) == Int ? Bool[v == 1 for v in answer] : Bool[x == one(GF2) for x in answer]
    (value, ctx.steps)
end

# decider_machine(bytes, n, x, y, a, b): the metered evaluation of the
# untyped decider description (the same `_metered_decide` the introspection
# decider uses for its child calls).
function _run_decider_machine(bytes, n, x, y, a, b, budget::Int)
    (bytes isa Vector{UInt8} && n isa Int && x isa Vector{Bool} && y isa Vector{Bool} &&
     a isa Vector{Bool} && b isa Vector{Bool}) || return nothing
    term = try
        decode_decider_term(bytes)
    catch error
        error isa ArgumentError && return nothing
        rethrow()
    end
    _decider_typing(term) isa Untyped || return nothing
    n >= 1 || return (false, 1)
    ctx = Meter(budget)
    bit = try
        _metered_decide(term, n, x, y, a, b, ctx)
    catch error
        error isa FuelExhausted && return :timeout
        error isa ArgumentError && return nothing
        rethrow()
    end
    (bit, ctx.steps)
end

DESCRIPTION_PRIMITIVES[:sampler_machine] = (8, _run_sampler_machine)
DESCRIPTION_PRIMITIVES[:decider_machine] = (6, _run_decider_machine)

"The DESIGN 1.1 program of sort Sampler running the description S under Eval fuel (one metered step = one unit)."
function lower_sampler(S::SamplerDescription)
    S.field_size == 2 || throw(ArgumentError("only an F_2 (normal form) sampler is lowered into the program IR"))
    args = (Prim(canonical_bytes(S), Concrete(1), ()), ntuple(i -> BoundVar(0, i - 1), 7)...)   # bytes + the 7 query arguments = the registered arity 8
    Lambda(7, Prim(:sampler_machine, Opaque("TIME_S(n): the metered steps of the description interpreter on this query (DESIGN 11.4 unit)", (:n,)), args))
end
"The DESIGN 1.1 program of sort Decider running the (untyped) description D under Eval fuel."
function lower_decider(D::DeciderDescription)
    D.typing isa Untyped || throw(ArgumentError("only an untyped decider is lowered into the program IR"))
    args = (Prim(canonical_bytes(D), Concrete(1), ()), ntuple(i -> BoundVar(0, i - 1), 5)...)
    Lambda(5, Prim(:decider_machine, Opaque("TIME_D(n): the metered steps of the description interpreter on this input (DESIGN 11.4 unit)", (:n,)), args))
end
"The description bytes a lowered program carries, or nothing."
function lowered_bytes(p::Program)
    p isa Lambda || return nothing
    body = p.body
    (body isa Prim && body.name in (:sampler_machine, :decider_machine) && !isempty(body.args)) || return nothing
    literal = body.args[1]
    (literal isa Prim && literal.name isa Vector{UInt8}) ? literal.name : nothing
end

"""
    lift_decider(q::Quoted{:Decider}) :: Checked{DeciderDescription}

The DeciderDescription (:Program, bytes) of a quoted DESIGN 1.1 decider: the
universal description interpreter runs it on the CEK evaluator (metered as a
child under the remaining budget), so a program is a decider description and
a description is a program (the two universal interpreters embed each other).
"""
function lift_decider(q::Quoted{:Decider})
    D = _decider_from_term((:Program, copy(canonical_bytes(q))); parts=())
    replay = x -> begin
        # The program halts on the sorted input and its verdict is the CEK value.
        trivial = eval_quoted(Quoted{:Decider}(Vector{UInt8}(x.term[2])), (1, Bool[], Bool[], Bool[], Bool[]), PROGRAM_DECIDER_FUEL)
        CheckResult(x.term[1] == :Program && !(trivial.result isa SortError), :program_decider; location=:ProgramDecider,
                    actual=trivial.result)
    end
    _decider_certificate(:ProgramDecider, D,
        "a quoted DESIGN 1.1 decider ($(description_size(q)) bytes, fnv1a64 $(quote_hash(q))) run by the CEK evaluator; as a metered child the remaining budget is its fuel and its OutOfFuel is the child's timeout",
        replay, (), ())
end

# --- the Compressor primitive (fig:halt_f step 4 on descriptions) --------------------------
# compress_descriptions(pair, lambda, policy): `pair` is the Code of
# quoted_pair(Quote(S), Quote(D)) with S a lowered sampler and D any quoted
# decider; the policy literal is decoded (empty = production); the
# description-level construction `compress_terms` runs and the compressed
# decider's lowered code is returned. The charge is 1 + |D^compr|
# (writing the output); the Turing-machine time of ComputeIntroVerifier /
# ComputeAnsVerifier / ComputeParrepVerifier stays the CITED poly bound.
function _run_compress_descriptions(pair, lambda, policy_literal, budget::Int)
    (pair isa Code && lambda isa Int && policy_literal isa Vector{UInt8} && lambda >= 1) || return nothing
    _admits_sort(pair.program, :Pair) || return nothing
    S_program = pair.program.args[1].code
    D_program = pair.program.args[2].code
    S_bytes = lowered_bytes(S_program)
    S_bytes === nothing && return nothing
    policy = try
        decode_policy(policy_literal)
    catch error
        error isa ArgumentError && return nothing
        rethrow()
    end
    V = try
        VerifierDescription(decode_sampler(S_bytes), lift_decider(Quoted{:Decider}(_quoted_bytes(D_program, :Decider))).term)
    catch error
        error isa ArgumentError && return nothing
        rethrow()
    end
    compressed = compress_terms(V, lambda, policy; tracer_index=2)
    result = Code(lower_decider(compressed.decider), :Decider)
    (result, 1 + description_size(compressed.decider))
end
DESCRIPTION_PRIMITIVES[:compress_descriptions] = (3, _run_compress_descriptions)

"The Compressor program of sort Compressor: (pair, lambda) -> compress_descriptions(pair, lambda, policy)."
function compressor_program(policy::ConstructionPolicy)
    Lambda(2, Prim(:compress_descriptions,
                   Opaque("ComputeIntroVerifier, ComputeAnsVerifier and ComputeParrepVerifier run in polynomial time (CITED, thm:compression); charged 1 + |D^compr|", (:lambda,)),
                   (BoundVar(0, 0), BoundVar(0, 1), Prim(policy_bytes(policy), Concrete(1), ()))))
end
