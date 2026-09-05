# TB6 (DESIGN 11.4): the typed introspection decider tilde D^intro of
# fig:intro-decider (gt-08-introspection.tex:L394-L500) as the TypedDecider
# instance (:TypedDecider, TypeIntro, (:Intro, lambda, ell, q, m, d, fuel, S, D)).
# It reads the input verifier V = (S, D) ONLY through the four sampler
# queries and one decider call, each run by the universal interpreter under
# the step meter with exactly R = N^lambda steps in production (fuel = 0)
# or the explicit toy F_child (fuel > 0; DESIGN 12.4 ToyPolicy): a call may
# return at step R, step R + 1 never executes (Meter budget semantics).
# Every child call leaves an IntroChildCall record (fixture label added by
# the caller, quote hash, mode, role, stage/prefix/input, exact metered
# cost, source R, supplied fuel, timeout/return).

"One child call of the introspection decider (DESIGN 11.4's mandatory record)."
struct IntroChildCall
    quote_hash::String
    mode::Symbol                  # :Dimension, :Marginal, :Factor, :Linear, :Decider
    role::Union{Symbol,Nothing}
    stage::Union{Int,Nothing}
    prefix::Any
    input::Any
    steps::Int                    # exact metered cost consumed (the budget on a timeout)
    by_depth::Vector{Int}
    source_R::Int
    supplied_fuel::Int
    outcome::Symbol               # :return, :timeout, :query_error
    result::Any
end
Base.show(io::IO, c::IntroChildCall) =
    print(io, "IntroChildCall(", c.mode, c.role === nothing ? "" : ", $(c.role)", c.stage === nothing ? "" : ", stage $(c.stage)",
          ", steps=", c.steps, "/", c.supplied_fuel, " (R=", c.source_R, "), ", c.outcome, ")")

# The child sampler machine used by the interpreter: normally compiled from
# the embedded bytes (cached by bytes); a test may substitute a recording
# wrapper through `with_child_sampler`.
const _INTRO_MACHINE_CACHE = Dict{Vector{UInt8},SamplerMachine}()
const _INTRO_CHILD_OVERRIDE = Ref{Any}(nothing)
function _intro_child_machine(S_term)
    _INTRO_CHILD_OVERRIDE[] === nothing || return _INTRO_CHILD_OVERRIDE[]::SamplerMachine
    bytes = sampler_term_bytes(S_term)
    get!(_INTRO_MACHINE_CACHE, bytes) do
        compile_sampler(S_term)
    end
end
"Run f with the introspection decider's child sampler replaced by `machine` (the query-purity device of DESIGN 9.6)."
function with_child_sampler(f::Function, machine::SamplerMachine)
    previous = _INTRO_CHILD_OVERRIDE[]
    _INTRO_CHILD_OVERRIDE[] = machine
    try
        f()
    finally
        _INTRO_CHILD_OVERRIDE[] = previous
    end
end

struct _IntroContext
    N::Int
    R::Int
    fuel::Int
    child::SamplerMachine
    child_hash::String
    D_term::Any
    trace::Vector
end
_budget(c::_IntroContext) = c.fuel == 0 ? c.R : c.fuel

# One metered child sampler query; nothing on timeout or QueryError (the
# decider then rejects, gt-08:L417-L419 "aborts and rejects").
function _child_query(c::_IntroContext, mode::Symbol, q::SamplerQuery; role=nothing, stage=nothing, prefix=nothing, input=nothing)
    ctx = Meter(_budget(c))
    outcome, result = try
        (:return, _validated_answer(c.child, q, ctx))
    catch error
        error isa FuelExhausted ? (:timeout, nothing) :
        error isa ArgumentError ? (:query_error, error.msg) : rethrow()
    end
    push!(c.trace, IntroChildCall(c.child_hash, mode, role, stage, prefix, input,
                                  outcome == :timeout ? _budget(c) : ctx.steps, copy(ctx.by_depth), c.R, _budget(c), outcome, result))
    outcome == :return ? result : nothing
end

_gf2(bits::AbstractVector{Bool}) = GF2[GF2(Int(b)) for b in bits]
_bools(v::AbstractVector{GF2}) = Bool[x == one(GF2) for x in v]

# --- the metered child decider call (enu:intro-game) ------------------------------
# The universal interpreter's evaluation of an UNTYPED child decider term
# with every primitive step charged (input decoding per bit, comparisons
# per bit, control transfers). Nested typed introspection deciders are TB7
# work (API REQUEST): they are refused here.
function _metered_decide(term, n::Int, x::AbstractVector{Bool}, y::AbstractVector{Bool}, a::AbstractVector{Bool}, b::AbstractVector{Bool}, ctx::Meter)
    tag = term[1]
    _charge!(ctx, 1 + ndigits(n; base=2) + length(x) + length(y) + length(a) + length(b))
    if tag == :Copy
        _charge!(ctx, length(x) + length(y))
        return a == x && b == y
    elseif tag == :Trivial
        return true
    elseif tag == :ZeroAnswers
        _charge!(ctx, 2 + length(term[2]))
        return _decide_zero_answers(term, x, y, a, b)
    elseif tag == :Detype
        labels, edges, child = term[2], term[3], term[4]
        T = length(labels)
        (length(x) >= 4T && length(y) >= 4T) || return true
        _charge!(ctx, 8T)
        edge_set = Set(edges)
        neigh(t) = Bool[(t, v) in edge_set || (v, t) in edge_set for v in 1:T]
        unit(t) = Bool[v == t for v in 1:T]
        xG, yG = x[1:4T], y[1:4T]
        for (l, r) in edges
            _charge!(ctx, 8T)
            xG == vcat(unit(l), neigh(l), falses(T), unit(l)) || continue
            yG == vcat(falses(T), unit(r), unit(r), neigh(r)) || continue
            _charge!(ctx, 1)
            return _metered_decide_typed(child, n, labels[l], x[4T+1:end], labels[r], y[4T+1:end], a, b, ctx)
        end
        return true
    elseif tag == :Repeat
        lambda, tau, c_num, c_den, child = term[2], term[3], term[4], term[5], term[6]
        B = B_rep(lambda, tau, n)
        k = k_rep(lambda, tau, c_num // c_den, n)
        _charge!(ctx, 2)
        parts = Vector{Vector{Bool}}[]
        for v in (x, y, a, b)
            _charge!(ctx, length(v))
            parsed = parse_framed(v, k, B)
            parsed === nothing && return false
            push!(parts, parsed)
        end
        verdict = true
        for i in 1:k
            _charge!(ctx, 1)
            verdict &= _metered_decide(child, n, parts[1][i], parts[2][i], parts[3][i], parts[4][i], ctx)
        end
        return verdict
    end
    throw(ArgumentError("unknown or unsupported untyped decider term $(tag) for a metered child call"))
end
function _metered_decide_typed(term, n::Int, tA, x::AbstractVector{Bool}, tB, y::AbstractVector{Bool}, a::AbstractVector{Bool}, b::AbstractVector{Bool}, ctx::Meter)
    tag = term[1]
    if tag == :TypedAnchor
        _charge!(ctx, 2 + length(a) + length(b))
        (tA in ANCHOR_TYPING.labels && tB in ANCHOR_TYPING.labels) || return false
        if tA == "Anchor" || tB == "Anchor"
            tA == "Anchor" && a != [false] && return false
            tB == "Anchor" && b != [false] && return false
            return true
        end
        return _metered_decide(term[2], n, x, y, a, b, ctx)
    end
    throw(ArgumentError("a nested typed introspection decider as a child is TB7 work (API REQUEST): not metered here"))
end

function _child_decide(c::_IntroContext, yA::AbstractVector{Bool}, yB::AbstractVector{Bool}, aA::AbstractVector{Bool}, aB::AbstractVector{Bool})
    ctx = Meter(_budget(c))
    outcome, result = try
        (:return, _metered_decide(c.D_term, c.N, yA, yB, aA, aB, ctx))
    catch error
        error isa FuelExhausted ? (:timeout, nothing) :
        error isa ArgumentError ? (:query_error, error.msg) : rethrow()
    end
    push!(c.trace, IntroChildCall(quote_hash(decider_term_bytes(c.D_term)), :Decider, nothing, nothing, nothing, (yA, yB, aA, aB),
                                  outcome == :timeout ? _budget(c) : ctx.steps, copy(ctx.by_depth), c.R, _budget(c), outcome, result))
    outcome == :return ? result : nothing
end

# --- the wire format (gt-08:L524-L530; DESIGN 11.4 IntroAnswerEncoding) ------------
# Every vector field is a full Q-bit vector whose last Q - s coordinates are
# zero; y, y_perp, z, x must be presented as vectors in V (else reject).
struct IntroAnswer
    kind::Symbol
    y::Union{Nothing,Vector{Bool}}        # Introspect / Read / Hide: y; Sample: z
    y_perp::Union{Nothing,Vector{Bool}}
    x::Union{Nothing,Vector{Bool}}
    a::Union{Nothing,Vector{Bool}}
end
_in_V(v::AbstractVector{Bool}, s::Int) = all(!v[i] for i in s+1:length(v))
function parse_intro_answer(label::AbstractString, bits::AbstractVector{Bool}, Q::Int, s::Int)
    bits = Vector{Bool}(bits)
    kind, _ = parse_type_label(label)
    if kind in (:Introspect, :Sample)
        length(bits) >= Q || return nothing
        y = bits[1:Q]
        _in_V(y, s) || return nothing
        return IntroAnswer(kind, y, nothing, nothing, bits[Q+1:end])
    elseif kind == :Read
        length(bits) >= 2Q || return nothing
        y, yp = bits[1:Q], bits[Q+1:2Q]
        (_in_V(y, s) && _in_V(yp, s)) || return nothing
        return IntroAnswer(kind, y, yp, nothing, bits[2Q+1:end])
    elseif kind == :Hide
        length(bits) == 3Q || return nothing
        y, yp, x = bits[1:Q], bits[Q+1:2Q], bits[2Q+1:3Q]
        (_in_V(y, s) && _in_V(yp, s) && _in_V(x, s)) || return nothing
        return IntroAnswer(kind, y, yp, x, nothing)
    end
    nothing
end
"The V-part (first s coordinates) of a Q-bit vector."
_V(v::AbstractVector{Bool}, s::Int) = v[1:s]
"Embed an s-bit vector in F_2^Q."
embed_Q(v::AbstractVector{Bool}, Q::Int) = vcat(Vector{Bool}(v), falses(Q - length(v)))

# --- the factor schedule (gt-08:L550-L579) ------------------------------------
# V_1 = Factor(N, role, 1, 0); for j >= 2: u_j = Marginal(N, role, j-1, y),
# V_j(y) = Factor(N, role, j, u_j). Returns nothing on any failed child call.
function _schedule(c::_IntroContext, role::Symbol, y::AbstractVector{Bool}, upto::Int, s::Int)
    registers = Vector{Int}[]
    prefixes = Vector{Bool}[]
    zero = falses(s)
    indicator = _child_query(c, :Factor, FactorQuery(c.N, role, 1, _gf2(zero), nothing); role, stage=1, prefix=zero)
    indicator === nothing && return nothing
    push!(registers, findall(==(1), indicator))
    push!(prefixes, zero)
    for j in 2:upto
        u = _child_query(c, :Marginal, MarginalQuery(c.N, role, j - 1, _gf2(y), nothing); role, stage=j - 1, input=y)
        u === nothing && return nothing
        ub = _bools(u)
        indicator = _child_query(c, :Factor, FactorQuery(c.N, role, j, u, nothing); role, stage=j, prefix=ub)
        indicator === nothing && return nothing
        push!(registers, findall(==(1), indicator))
        push!(prefixes, ub)
    end
    (; registers, prefixes)
end
# y_{<k} = L_{<k}(y) = Marginal(N, role, k-1, y) for k >= 2, the zero vector for k = 1.
function _marginal_below(c::_IntroContext, role::Symbol, y::AbstractVector{Bool}, k::Int, s::Int)
    k <= 1 && return falses(s)
    u = _child_query(c, :Marginal, MarginalQuery(c.N, role, k - 1, _gf2(y), nothing); role, stage=k - 1, input=y)
    u === nothing ? nothing : _bools(u)
end
# The matrix of L_{j,u} in the basis H of the register V_j(y): one Linear
# call per basis vector h_i (gt-08:L659-L668), columns restricted to the register.
function _stage_matrix(c::_IntroContext, role::Symbol, j::Int, prefix::AbstractVector{Bool}, register::Vector{Int}, s::Int)
    r = length(register)
    M = Matrix{GF2}(undef, r, r)
    for (i, h) in enumerate(register)
        e = falses(s)
        e[h] = true
        column = _child_query(c, :Linear, LinearQuery(c.N, role, j, _gf2(prefix), _gf2(e), nothing); role, stage=j, prefix, input=i)
        column === nothing && return nothing
        M[:, i] = column[register]
    end
    M
end
_restrict(v::AbstractVector{Bool}, register::Vector{Int}) = v[register]
function _project(v::AbstractVector{Bool}, register::Vector{Int})
    out = falses(length(v))
    out[register] = v[register]
    out
end
# (L_{j,u})^perp applied to the V_j projection of x, returned on the register coordinates.
function _apply_perp(M::Matrix{GF2}, x_register::AbstractVector{Bool})
    Lp, _, _ = perp_map(M)
    _bools(Lp * _gf2(x_register))
end

# --- the predicate ---------------------------------------------------------------------
const _INTRO_TESTS = (:pauli, :sampling_pauli, :sampling_intro, :hiding_intro, :hiding_read, :hiding_same, :hiding_pauli, :game, :consistency)

"""
    intro_guard_literal(aA, aB, Q) / intro_guard_operative(aA, aB, Q)

PAPER_LITERAL: max(|a_A|, |a_B|) >= 3Q rejects (gt-08:L424-L425);
OPERATIVE: > 3Q rejects (SOURCE_REPAIR(intro-3Q-guard): the honest Hide
tuple is exactly 3Q bits, gt-08:L588-L591). Both return `true` when the
guard REJECTS.
"""
intro_guard_literal(aA::AbstractVector{Bool}, aB::AbstractVector{Bool}, Q::Int) = max(length(aA), length(aB)) >= 3Q
intro_guard_operative(aA::AbstractVector{Bool}, aB::AbstractVector{Bool}, Q::Int) = max(length(aA), length(aB)) > 3Q

# One ordered test pass (w, wbar); returns nothing when no test of items
# 2-4 applies to the ordered pair, else the verdict. `fired` collects the
# names of the applicable tests.
function _intro_ordered(c::_IntroContext, p::PauliParams, s::Int, Q::Int, ell::Int,
                        tw::String, xw::Vector{Bool}, aw::Vector{Bool}, tv::String, xv::Vector{Bool}, av::Vector{Bool}, fired::Vector{Symbol})
    kw, argw = parse_type_label(tw)
    kv, argv = parse_type_label(tv)
    # 2(a) (Pauli, Z) with (Sample, role): a_w^V = z_wbar.
    if kw == :Pauli && argw == "Z" && kv == :Sample
        push!(fired, :sampling_pauli)
        length(aw) == Q || return false
        ans = parse_intro_answer(tv, av, Q, s)
        ans === nothing && return false
        return _V(aw, s) == _V(ans.y, s)
    end
    # 2(b) (Introspect, role) with (Sample, role): y_w = L^role(z_wbar) and a_w = a_wbar.
    if kw == :Introspect && kv == :Sample && argw == argv
        push!(fired, :sampling_intro)
        role = Symbol(argw)
        aw_p = parse_intro_answer(tw, aw, Q, s)
        av_p = parse_intro_answer(tv, av, Q, s)
        (aw_p === nothing || av_p === nothing) && return false
        image = _child_query(c, :Marginal, MarginalQuery(c.N, role, ell, _gf2(_V(av_p.y, s)), nothing); role, stage=ell, input=_V(av_p.y, s))
        image === nothing && return false
        return _V(aw_p.y, s) == _bools(image) && aw_p.a == av_p.a
    end
    # 3(a) (Introspect, role) with (Read, role): y and a equal.
    if kw == :Introspect && kv == :Read && argw == argv
        push!(fired, :hiding_intro)
        aw_p = parse_intro_answer(tw, aw, Q, s)
        av_p = parse_intro_answer(tv, av, Q, s)
        (aw_p === nothing || av_p === nothing) && return false
        return aw_p.y == av_p.y && aw_p.a == av_p.a
    end
    # 3(b) (Hide_ell, role) with (Read, role): y_{<ell} equal and y_perp equal.
    if kw == :Hide && argw[1] == ell && kv == :Read && argw[2] == argv
        push!(fired, :hiding_read)
        role = Symbol(argv)
        aw_p = parse_intro_answer(tw, aw, Q, s)
        av_p = parse_intro_answer(tv, av, Q, s)
        (aw_p === nothing || av_p === nothing) && return false
        below_w = _marginal_below(c, role, _V(aw_p.y, s), ell, s)
        below_v = _marginal_below(c, role, _V(av_p.y, s), ell, s)
        (below_w === nothing || below_v === nothing) && return false
        return below_w == below_v && aw_p.y_perp == av_p.y_perp
    end
    # 3(c) (Hide_k, role) with (Hide_{k+1}, role), k in {1..ell-1}.
    if kw == :Hide && kv == :Hide && argw[2] == argv[2] && argv[1] == argw[1] + 1 && 1 <= argw[1] <= ell - 1
        push!(fired, :hiding_same)
        k = argw[1]
        role = Symbol(argv[2])
        aw_p = parse_intro_answer(tw, aw, Q, s)
        av_p = parse_intro_answer(tv, av, Q, s)
        (aw_p === nothing || av_p === nothing) && return false
        yw, yv = _V(aw_p.y, s), _V(av_p.y, s)
        below_w = _marginal_below(c, role, yw, k, s)
        below_v = _marginal_below(c, role, yv, k, s)
        (below_w === nothing || below_v === nothing) && return false
        below_w == below_v || return false
        # Registers V_{<= k}(y_w), V_{<= k+1}(y_wbar) from the factor schedule of each player's own y.
        sched_w = _schedule(c, role, yw, k, s)
        sched_v = _schedule(c, role, yv, k + 1, s)
        (sched_w === nothing || sched_v === nothing) && return false
        le_k_w = reduce(vcat, sched_w.registers[1:k]; init=Int[])
        le_k_v = reduce(vcat, sched_v.registers[1:k]; init=Int[])
        _project(_V(aw_p.y_perp, s), le_k_w) == _project(_V(av_p.y_perp, s), le_k_v) || return false
        V_k1 = sched_v.registers[k + 1]
        # SOURCE_REPAIR(intro-hide-suffix-register): both suffixes are taken on
        # V_{> k+1}(y_wbar) (the literal text projects x_w onto V_{> k+1}(y_w),
        # whose stage-(k+1) factor is selected by the prefix with y_{w,k} = 0).
        gt_k1_v = setdiff(1:s, vcat(le_k_v, V_k1))
        _project(_V(aw_p.x, s), gt_k1_v) == _project(_V(av_p.x, s), gt_k1_v) || return false
        # y_perp_{wbar,k+1} = (L_{k+1,u})^perp (x_{w,k+1}) with u = y_{wbar,<=k} (the Hide_{k+1} player's prefix).
        u = sched_v.prefixes[k + 1]
        M = _stage_matrix(c, role, k + 1, u, V_k1, s)
        M === nothing && return false
        return _apply_perp(M, _restrict(_V(aw_p.x, s), V_k1)) == _restrict(_V(av_p.y_perp, s), V_k1)
    end
    # 3(d) (Pauli, X) with (Hide_1, role).
    if kw == :Pauli && argw == "X" && kv == :Hide && argv[1] == 1
        push!(fired, :hiding_pauli)
        role = Symbol(argv[2])
        length(aw) == Q || return false
        av_p = parse_intro_answer(tv, av, Q, s)
        av_p === nothing && return false
        sched = _schedule(c, role, _V(av_p.y, s), 1, s)
        sched === nothing && return false
        V_1 = sched.registers[1]
        M = _stage_matrix(c, role, 1, falses(s), V_1, s)
        M === nothing && return false
        _apply_perp(M, _restrict(_V(aw, s), V_1)) == _restrict(_V(av_p.y_perp, s), V_1) || return false
        gt_1 = setdiff(1:s, V_1)
        return _project(_V(aw, s), gt_1) == _project(_V(av_p.x, s), gt_1)
    end
    # 4 (Introspect, alice) with (Introspect, bob): the original decider on (N, y_w, y_wbar, a_w, a_wbar).
    if kw == :Introspect && kv == :Introspect && argw == "alice" && argv == "bob"
        push!(fired, :game)
        aw_p = parse_intro_answer(tw, aw, Q, s)
        av_p = parse_intro_answer(tv, av, Q, s)
        (aw_p === nothing || av_p === nothing) && return false
        verdict = _child_decide(c, _V(aw_p.y, s), _V(av_p.y, s), aw_p.a, av_p.a)
        return verdict === nothing ? false : verdict
    end
    nothing
end

"""
    intro_decide_traced(body, n, tA, x, tB, y, a, b) -> (bit, trace, fired)

The predicate of fig:intro-decider under the term's fuel policy; `fired`
lists the applied tests (empty: accepted by "no test applies").
"""
function intro_decide_traced(body, n::Int, tA::String, x::AbstractVector{Bool}, tB::String, y::AbstractVector{Bool}, a::AbstractVector{Bool}, b::AbstractVector{Bool})
    trace = Any[]
    fired = Symbol[]
    bit = _decide_intro(body, n, tA, Vector{Bool}(x), tB, Vector{Bool}(y), Vector{Bool}(a), Vector{Bool}(b), trace; fired)
    (bit, trace, fired)
end

function _decide_intro(body, n::Int, tA::String, x::AbstractVector{Bool}, tB::String, y::AbstractVector{Bool}, a::AbstractVector{Bool}, b::AbstractVector{Bool}, trace::Vector; fired::Vector{Symbol}=Symbol[])
    lambda, ell, q, m, d, fuel, S_term, D_term = body[2], body[3], body[4], body[5], body[6], body[7], body[8], body[9]
    n <= 30 || throw(ArgumentError("N = 2^n does not fit the interpreter's index (n <= 30)"))
    N = 2 ^ n
    R = big(N) ^ lambda
    R <= typemax(Int) || throw(ArgumentError("R = N^lambda exceeds the interpreter's step counter"))
    labels = intro_type_labels(ell)
    (tA in labels && tB in labels) || return false
    p = PauliParams(q, m, d)
    Q = pauli_Q(p.tuple)
    child = _intro_child_machine(S_term)
    c = _IntroContext(N, Int(R), fuel, child, quote_hash(sampler_term_bytes(S_term)), D_term, trace)
    # First: s(N) by Dimension(N) (gt-08:L420-L423), reject if s(N) > R.
    dimension = _child_query(c, :Dimension, DimensionQuery(N))
    dimension === nothing && return false
    s = dimension::Int
    s > R && return false
    Q >= s || return false                       # the F_2^Q embedding needs Q >= s(N) (gt-08:L524-L530)
    # The OPERATIVE answer-length guard (SOURCE_REPAIR(intro-3Q-guard)).
    intro_guard_operative(a, b, Q) && return false
    verdicts = Bool[]
    # 1: both Pauli types -> D^pauli.
    if is_pauli_label(tA) && is_pauli_label(tB)
        push!(fired, :pauli)
        push!(verdicts, pauli_decide(p, tA, x, tB, y, a, b))
    end
    # 2-4 in both orders.
    for (tw, xw, aw, tv, xv, av) in ((tA, x, a, tB, y, b), (tB, y, b, tA, x, a))
        v = _intro_ordered(c, p, s, Q, ell, tw, xw, aw, tv, xv, av, fired)
        v === nothing || push!(verdicts, v)
    end
    # 5: equal types -> equal answers.
    if tA == tB
        push!(fired, :consistency)
        push!(verdicts, a == b)
    end
    all(verdicts)
end

# --- the description ----------------------------------------------------------------------
const CITED_INTRO_DECIDER_FIG = _cited("fig:intro-decider", "gt-08-introspection.tex", 394:500,
    "the answer key, the timeout rule (L417-L419), the s(N) > N^lambda and 3Q length guards (L424-L425) and the nine tests; executed as the classical predicate")
const CITED_INTRO_DECIDER_COMPLEXITY = _cited("lem:intro-decider-complexity", "gt-08-introspection.tex", 694:776,
    "ComputeIntroDecider: |D^intro| = poly(lambda, ell), TIME = poly(2^(lambda n), ell); the universal-TM bounds stay CITED")
const CITED_INTROSPECTION = _cited("thm:introspection", "gt-08-introspection.tex", 784:817,
    "V^intro is a 5-level normal-form verifier; completeness, soundness delta(eps, n) and the Ent map are CITED, never executed")
const CITED_COMMUTE = _cited("lem:commute", "gt-08-introspection.tex", 923:953,
    "Z-measurements of L and X-measurements of R commute when ker(R)^perp is contained in ker(L); the honest Read/Hide families satisfy it with R = L_j^perp")
const CITED_CL_CANONICAL = _cited("def:cl-canonical", "gt-03-prelim.tex", 375:384,
    "the canonical linear map with kernel basis F: the projector onto span(F^perp) parallel to span(F)")
const CITED_L_PERP = _cited("def:Lperp", "gt-03-prelim.tex", 386:392,
    "L^perp = the canonical linear map with kernel basis a basis of ker(L)^perp")

const INTRO_3Q_GUARD = CertNode(SOURCE_REPAIR, :intro_3Q_guard;
    facts=(display="PAPER_LITERAL rejects max(|a_A|, |a_B|) >= 3Q (gt-08-introspection.tex:L424-L425); the honest (Hide_k, role) tuple (y, y_perp, x) in (F_2^Q)^3 is exactly 3Q bits and the source calls 3Q the maximum answer length (L588-L591), so the executable uses the OPERATIVE > 3Q; a Read answer (y, y_perp, a) has literal capacity |a| < Q and operative capacity |a| <= Q: SOURCE_REPAIR(intro-3Q-guard)",
           source="gt-08-introspection.tex", lines=424:425))
const INTRO_PERP_ORTHOGONAL = CertNode(SOURCE_REPAIR, :intro_perp_orthogonal;
    facts=(display="fig:intro-decider's dual map (gt-08-introspection.tex:L669-L678) computes a basis F of ker(M) and then 'the canonical complement S of F, a basis for ker(L)^perp'; the canonical complement (def:canonical-complement, gt-03:L307-L318) spans the orthogonal complement only when ker(L) is a register subspace (gt-03:L333-L340), and for TB6b-M's stage-2 map [[1,1],[0,0]] (kernel <e4+e5>) it gives span{e5}, whose X-family anticommutes with the Z-family of L, so the honest Read and Hide_3 answers would be rejected; the executable takes S = the canonical basis of the ORTHOGONAL complement {v : v . f = 0, f in F}, for which ker(L^perp) = ker(L)^perp (lem:L_perp_perp) and lem:commute holds: SOURCE_REPAIR(intro-perp-orthogonal); the literal reading (`perp_map_literal`) is evaluated separately on the honest transcripts",
           source="gt-08-introspection.tex", lines=669:678))
const INTRO_HIDE_SUFFIX_REGISTER = CertNode(SOURCE_REPAIR, :intro_hide_suffix_register;
    facts=(display="enu:hiding-same (gt-08-introspection.tex:L464-L473, explained at L641-L657) projects x_w to V_{>k+1}(y_w) and x_wbar to V_{>k+1}(y_wbar); the Hide_k player's y carries no k-th component, so when the stage-(k+1) factor REGISTER depends on the k-th prefix component (TB6b-M's stage 2, and every detyped sampler's revealed-type stage) the two registers differ and the honest strategy (x_w = the X outcomes on V_{>k}(y_w), gt-08:L1166-L1169) is rejected; the executable projects both onto V_{>k+1}(y_wbar), the register the Hide_{k+1} player measured, which the source's footnote (L652-L657) singles out for the dual check: SOURCE_REPAIR(intro-hide-suffix-register); the literal register choice is evaluated separately on the honest transcripts",
           source="gt-08-introspection.tex", lines=464:473))

"""
    typed_intro_decider(V::VerifierDescription, lambda, ell; tuple::PauliTuple, F_child=0) :: Checked{DeciderDescription}

tilde D^intro as (:TypedDecider, TypeIntro, (:Intro, lambda, ell, q, m, d, F_child, S, D)):
the embedded input verifier is read only through the four sampler queries
and one decider call, each under the step meter with budget N^lambda
(F_child = 0) or the explicit toy F_child (DESIGN 12.4).
"""
function typed_intro_decider(V::VerifierDescription, lambda::Integer, ell::Integer; tuple::PauliTuple, F_child::Integer=0)
    V.sampler.typing isa Untyped || throw(ArgumentError("the introspected verifier is an untyped normal-form verifier"))
    V.sampler.field_size == 2 || throw(ArgumentError("the introspected sampler is over F_2 (normal form)"))
    term = (:TypedDecider, intro_type_labels(ell), (:Intro, Int(lambda), Int(ell), tuple.q, tuple.m, tuple.d, Int(F_child), V.sampler.term, V.decider.term))
    desc = _decider_from_term(term; parts=(V.decider,))
    Q = pauli_Q(tuple)
    replay = x -> begin
        n = 2
        body = x.term[3]
        # Out-of-range types reject; an answer of 3Q + 1 bits rejects with no child call past Dimension.
        bit1 = decide(x, n, "Referee", Bool[], "Introspect_alice", Bool[], Bool[], Bool[])
        bit2, trace2, _ = intro_decide_traced(body, n, "Hide_1_alice", falses(0), "Hide_1_alice", falses(0), falses(3Q + 1), falses(3Q + 1))
        # Equal types with unequal answers reject; equal answers accept when no other test applies.
        bit3 = decide(x, n, "Sample_bob", Bool[], "Sample_bob", Bool[], vcat(falses(Q), true), vcat(falses(Q), false))
        bit4 = decide(x, n, "Sample_bob", Bool[], "Sample_bob", Bool[], vcat(falses(Q), true), vcat(falses(Q), true))
        ok = !bit1 && !bit2 && length(trace2) <= 1 && all(r -> r.mode == :Dimension, trace2) && !bit3 && bit4
        CheckResult(ok, :intro_decider; location=:IntroDecider, actual=(; bit1, bit2, calls=length(trace2), bit3, bit4))
    end
    _decider_certificate(:IntroDecider, desc,
        "fig:intro-decider on (lambda, ell) = ($(lambda), $(ell)), $(tuple), Q = $(Q): Dimension(N) first (reject if s(N) > R = N^lambda), operative > 3Q guard, then the nine tests in both player orders with child calls under the step meter ($(F_child == 0 ? "budget R = N^lambda (production)" : "toy budget F_child = $(F_child)")), accept when no test applies",
        replay, (CITED_INTRO_DECIDER_FIG, CITED_INTRO_DECIDER_COMPLEXITY, CITED_PAULI_DECIDER, CITED_THM_PAULI, CITED_CL_CANONICAL, CITED_L_PERP, INTRO_3Q_GUARD, INTRO_HIDE_SUFFIX_REGISTER, INTRO_PERP_ORTHOGONAL), (V.decider,))
end

"The literal register choice of enu:hiding-same on one ordered (Hide_k, Hide_{k+1}) transcript: does x_w|V_{>k+1}(y_w) equal x_wbar|V_{>k+1}(y_wbar)? (for the report; not the operative decider)"
function hide_suffix_literal(S::SamplerDescription, N::Int, role::Symbol, k::Int, y_w::AbstractVector{Bool}, x_w::AbstractVector{Bool}, y_v::AbstractVector{Bool}, x_v::AbstractVector{Bool})
    s = length(y_w)
    reg(y) = begin
        registers = Vector{Int}[]
        push!(registers, findall(==(1), _raise(Factor(S, N, role, 1, _gf2(falses(s))))))
        for j in 2:k+1
            u = _raise(Marginal(S, N, role, j - 1, _gf2(y)))
            push!(registers, findall(==(1), _raise(Factor(S, N, role, j, u))))
        end
        setdiff(1:s, reduce(vcat, registers; init=Int[]))
    end
    _project(x_w, reg(y_w)) == _project(x_v, reg(y_v))
end

"""
    intro_query_plan(ell) -> Vector{Pair{Symbol,Vector}}

The source-query plan of the typed introspection decider (DESIGN 11.4;
gt-08-introspection.tex:L420-L423, L550-L579, L641-L684): for each test the
child calls it issues, in order, as (mode, stage) with symbolic counts
(`(:Linear, j, :basis_of_V_j)` = one call per canonical basis vector of the
stage-j factor register). The sizing Dimension probe every vector query
makes inside the child's own input validation is not part of the plan.
"""
function intro_query_plan(ell::Integer)
    ell = Int(ell)
    schedule(upto) = vcat(Any[(:Factor, 1)], Any[x for j in 2:upto for x in ((:Marginal, j - 1), (:Factor, j))])
    plan = Pair{Symbol,Vector{Any}}[]
    push!(plan, :preamble => Any[(:Dimension, :N)])
    push!(plan, :pauli => Any[])
    push!(plan, :sampling_pauli => Any[])
    push!(plan, :sampling_intro => Any[(:Marginal, ell)])
    push!(plan, :hiding_intro => Any[])
    push!(plan, :hiding_read => ell >= 2 ? Any[(:Marginal, ell - 1), (:Marginal, ell - 1)] : Any[])
    for k in 1:ell-1
        push!(plan, Symbol("hiding_same_", k) => vcat(k >= 2 ? Any[(:Marginal, k - 1), (:Marginal, k - 1)] : Any[],
                                                      schedule(k), schedule(k + 1), Any[(:Linear, k + 1, :basis_of_V_k1)]))
    end
    push!(plan, :hiding_pauli => Any[(:Factor, 1), (:Linear, 1, :basis_of_V_1)])
    push!(plan, :game => Any[(:Decider, :N)])
    push!(plan, :consistency => Any[])
    plan
end
