# TB6 (DESIGN 11.2): the executable classical predicate D^pauli of
# fig:decider_pauli (gt-07-ldt.tex:L1126-L1227) as the TypedDecider instance
# (:TypedDecider, TypePauli, (:Pauli, q, m, d)). Questions arrive as the
# DOWNSIZED bits of V^pauli vectors (the players undo the bijection
# themselves, rk:downsizing gt-08:L1053-L1068); answers are bit strings
# parsed by the exact table below (IntroAnswerEncoding for Pauli answers:
# every F_q element is kappa-encoded in the self-dual normal basis of
# lem:pauli-binary, so a (Pauli, W) answer IS the vector of qubit W-outcomes,
# cor:pauli-binary gt-07:L1470-L1487). Quantum rigidity (thm:pauli) is not
# part of this predicate.

struct PauliParams{F}
    tuple::PauliTuple
    basis::Vector{F}        # the self-dual normal basis (kappa)
    ld::LDParams{F}         # ldparams = (q, m, d, 1) (gt-07:L1134-L1136)
end
function PauliParams(t::PauliTuple)
    F = _field_type(t.q)
    PauliParams{F}(t, self_dual_normal_basis(F), LDParams(F, t.m, t.d, 1))
end
PauliParams(q::Integer, m::Integer, d::Integer) = PauliParams(PauliTuple(Int(q), Int(m), Int(d)))
_pfield(::PauliParams{F}) where {F} = F

"The exact answer schema of a type label: (fields, bit length) (fig:decider_pauli table; gt-08 fig:intro-decider table)."
function answer_schema(p::PauliParams, label::AbstractString)
    t = p.tuple
    k = pauli_log_q(t)
    Q = pauli_Q(t)
    kind, arg = parse_type_label(label)
    kind == :Point && return (; fields="a in F_q", bits=k)
    kind == :ALine && return (; fields="f: F_q -> F_q of degree <= d = $(t.d), coefficients c_0..c_d", bits=(t.d + 1) * k)
    kind == :DLine && return (; fields="f: F_q -> F_q of degree <= md = $(t.m * t.d), coefficients c_0..c_md", bits=(t.m * t.d + 1) * k)
    kind == :Pair && arg === nothing && return (; fields="(beta_x, beta_z) in F_2^2", bits=2)
    kind == :Pair && return (; fields="beta_$(arg) in F_2", bits=1)
    kind == :Constraint && return (; fields="(alpha_v1, alpha_v2, alpha_v3) in F_2^3 for the variables $(magic_square_variables(arg))", bits=3)
    kind == :Variable && return (; fields="gamma in F_2", bits=1)
    kind == :Pauli && return (; fields="h in F_q^M as Q = M log q = $(Q) qubit $(arg)-outcome bits (kappa blockwise)", bits=Q)
    kind == :Introspect && return (; fields="(y, a): y in F_2^Q (zero outside V), a in {0,1}^*", bits=nothing)
    kind == :Sample && return (; fields="(z, a): z in F_2^Q (zero outside V), a in {0,1}^*", bits=nothing)
    kind == :Read && return (; fields="(y, y_perp, a): y, y_perp in F_2^Q (zero outside V), a in {0,1}^*", bits=nothing)
    kind == :Hide && return (; fields="(y, y_perp, x) in (F_2^Q)^3 (zero outside V), exactly 3Q = $(3Q) bits", bits=3Q)
    throw(ArgumentError("unknown label"))
end

# --- parsing ---------------------------------------------------------------------
"The V^pauli vector (u_x, u_z, s, v, r_x, r_z) of a downsized question, or nothing."
function parse_pauli_question(p::PauliParams{F}, bits::AbstractVector{Bool}) where {F}
    bits = Vector{Bool}(bits)
    k = pauli_log_q(p.tuple)
    n = pauli_dimension(p.tuple.m)
    length(bits) == n * k || return nothing
    v = _field_from_bits(F, GF2[GF2(Int(b)) for b in bits], k)
    r = pauli_registers(p.tuple.m)
    (; u_x=v[r.u_x], u_z=v[r.u_z], s=v[r.s], v=v[r.v], r_x=v[r.r_x], r_z=v[r.r_z], raw=v)
end
"The (u_W, s, v) tuple of TB1's low-degree questions (gt-07:L1085-L1101)."
_ld_question(q, W::AbstractString) = Tuple(vcat(W == "X" ? q.u_x : q.u_z, q.s, q.v))

_univariate_layout() = VarLayout((:t,), (VarBlock(:LineParameter, 1:1),))
function _coefficients_to_poly(::Type{F}, coefficients::Vector{F}) where {F}
    layout = _univariate_layout()
    t = polyvar(F, layout, 1)
    result = zero_poly(F, layout)
    for (i, c) in enumerate(coefficients)
        iszero(c) && continue
        result = result + constant_poly(F, layout, c) * t ^ (i - 1)
    end
    result
end
"The coefficient vector c_0..c_bound of a univariate Poly (degree > bound gives nothing)."
function poly_coefficients(poly::Poly{F,1}, bound::Int) where {F}
    coefficients = fill(zero(F), bound + 1)
    for (powers, c) in poly.terms
        e = Int(powers[1])
        e <= bound || return nothing
        coefficients[e + 1] = c
    end
    coefficients
end

"Parse an answer bit string by its type's schema; nothing when malformed."
function parse_pauli_answer(p::PauliParams{F}, label::AbstractString, bits::AbstractVector{Bool}) where {F}
    bits = Vector{Bool}(bits)
    schema = answer_schema(p, label)
    schema.bits === nothing && return nothing
    length(bits) == schema.bits || return nothing
    kind, arg = parse_type_label(label)
    k = pauli_log_q(p.tuple)
    kind == :Point && return kappa_field(bits, p.basis)
    kind in (:ALine, :DLine) && return _coefficients_to_poly(F, kappa_fields(bits, p.basis))
    kind == :Pauli && return kappa_fields(bits, p.basis)
    bits   # Pair, Pair_W, Constraint, Variable: raw bits
end

# --- the arithmetic of the guards ----------------------------------------------
"g_h(y) = h . ind_m(y) (eq:low-degree-encoding-definition, gt-03:L892-L897)."
ld_encoding_value(h::AbstractVector{F}, y::AbstractVector{F}) where {F} =
    (length(h) == length(ind(collect(y))) || throw(ArgumentError("h must have 2^m entries"));
     sum(h[i] * v for (i, v) in enumerate(ind(collect(y))); init=zero(F)))
"gamma = tr((ind_m(u_x) r_x) . (ind_m(u_z) r_z)) (eq:gamma-value, gt-07:L1178-L1182)."
function pauli_gamma(q)
    a = ind(collect(q.u_x)) .* q.r_x
    b = ind(collect(q.u_z)) .* q.r_z
    field_trace(sum(a .* b; init=zero(eltype(a))))
end

# One ordered guard (w, wbar) of fig:decider_pauli items 2-7: `nothing` when
# no guard applies to (t_w, t_wbar); malformed applicable data rejects.
function _pauli_guard(p::PauliParams{F}, tw::String, xw, aw::AbstractVector{Bool}, tv::String, xv, av::AbstractVector{Bool}) where {F}
    kw, argw = parse_type_label(tw)
    kv, argv = parse_type_label(tv)
    # Item 2: low-degree, (Point, W) with (ALine, W) / (DLine, W).
    if kw == :Point && kv in (:ALine, :DLine) && argw == argv
        (xw === nothing || xv === nothing) && return false
        a = parse_pauli_answer(p, tw, aw)
        f = parse_pauli_answer(p, tv, av)
        (a === nothing || f === nothing) && return false
        return passed(ld_decider(p.ld, :Point, _ld_question(xw, argw), kv, _ld_question(xv, argv), (a,), (f,)))
    end
    # Item 3: (Point, W) with (Pauli, W): g_{a_wbar}(x_w) = a_w.
    if kw == :Point && kv == :Pauli && argw == argv
        xw === nothing && return false
        a = parse_pauli_answer(p, tw, aw)
        h = parse_pauli_answer(p, tv, av)
        (a === nothing || h === nothing) && return false
        return ld_encoding_value(h, argw == "X" ? xw.u_x : xw.u_z) == a
    end
    # Items 4-7 need gamma from the question of the player whose question carries (u_x, u_z, r_x, r_z).
    if kw == :Pair && argw !== nothing && kv == :Pair && argv === nothing
        (xw === nothing || xv === nothing) && return false
        aw_bit = parse_pauli_answer(p, tw, aw)
        beta = parse_pauli_answer(p, tv, av)
        (aw_bit === nothing || beta === nothing) && return false
        gamma = pauli_gamma(xv)
        return gamma || aw_bit[1] == beta[argw == "X" ? 1 : 2]
    end
    if kw == :Point && kv == :Pair && argv !== nothing && argw == argv
        (xw === nothing || xv === nothing) && return false
        a = parse_pauli_answer(p, tw, aw)
        bit = parse_pauli_answer(p, tv, av)
        (a === nothing || bit === nothing) && return false
        gamma = pauli_gamma(xv)
        r = argw == "X" ? xv.r_x : xv.r_z
        return gamma || field_trace(a * r) == bit[1]
    end
    if kw == :Constraint && kv == :Variable
        (xw === nothing || xv === nothing) && return false
        alphas = parse_pauli_answer(p, tw, aw)
        bit = parse_pauli_answer(p, tv, av)
        (alphas === nothing || bit === nothing) && return false
        gamma = pauli_gamma(xw)
        gamma || return true
        variables = magic_square_variables(argw)
        position = findfirst(==(argv), variables)
        position === nothing && return false            # not an incident pair: alpha_j undefined
        return (count(alphas) % 2 == 1) == magic_square_parity(argw) && alphas[position] == bit[1]
    end
    if kw == :Point && kv == :Variable
        (xw === nothing || xv === nothing) && return false
        a = parse_pauli_answer(p, tw, aw)
        bit = parse_pauli_answer(p, tv, av)
        (a === nothing || bit === nothing) && return false
        gamma = pauli_gamma(xv)
        gamma || return true
        (argv == 1 && argw == "X") && return field_trace(a * xv.r_x) == bit[1]
        (argv == 5 && argw == "Z") && return field_trace(a * xv.r_z) == bit[1]
        return false
    end
    nothing
end

"""
    pauli_decide(p, tA, xA, tB, xB, aA, aB) -> Bool

fig:decider_pauli: item 1 on equal types (equal answers as bit strings);
otherwise every applicable guard among items 2-7 in both orders (w, wbar);
accept when none applies.
"""
function pauli_decide(p::PauliParams, tA::String, xA::AbstractVector{Bool}, tB::String, xB::AbstractVector{Bool}, aA::AbstractVector{Bool}, aB::AbstractVector{Bool})
    (tA in pauli_type_labels() && tB in pauli_type_labels()) || return false
    tA == tB && return aA == aB
    qA = parse_pauli_question(p, xA)
    qB = parse_pauli_question(p, xB)
    verdicts = Bool[]
    for (tw, xw, aw, tv, xv, av) in ((tA, qA, aA, tB, qB, aB), (tB, qB, aB, tA, qA, aA))
        g = _pauli_guard(p, tw, xw, aw, tv, xv, av)
        g === nothing || push!(verdicts, g)
    end
    all(verdicts)
end

"The set of ordered (t_w, t_wbar) label pairs a guard item applies to (TB6a's guard census)."
function pauli_guard_table()
    labels = pauli_type_labels()
    table = Dict{Symbol,Vector{Tuple{String,String}}}()
    push_item!(item, pair) = push!(get!(table, item, Tuple{String,String}[]), pair)
    for tw in labels, tv in labels
        kw, argw = parse_type_label(tw)
        kv, argv = parse_type_label(tv)
        tw == tv && (push_item!(:item1_consistency, (tw, tv)); continue)
        kw == :Point && kv in (:ALine, :DLine) && argw == argv && push_item!(:item2_low_degree, (tw, tv))
        kw == :Point && kv == :Pauli && argw == argv && push_item!(:item3_point_pauli, (tw, tv))
        kw == :Pair && argw !== nothing && kv == :Pair && argv === nothing && push_item!(:item4_commutation, (tw, tv))
        kw == :Point && kv == :Pair && argv !== nothing && argw == argv && push_item!(:item5_point_pair, (tw, tv))
        kw == :Constraint && kv == :Variable && push_item!(:item6_magic_square, (tw, tv))
        kw == :Point && kv == :Variable && push_item!(:item7_point_variable, (tw, tv))
    end
    table
end

const CITED_PAULI_DECIDER = _cited("fig:decider_pauli", "gt-07-ldt.tex", 1126:1227,
    "the question/answer table and the eight guards of D^pauli (consistency, low-degree, Point/Pauli, gamma, commutation, Point/Pair, Magic Square, Point/Variable); executed as the classical predicate")
const CITED_THM_PAULI = _cited("thm:pauli", "gt-07-ldt.tex", 1426:1447,
    "rigidity of the Pauli basis test: delta_qld(eps, m, d, q) and the isometries to |EPR_q>^{(x)M} with tau^W_u; not part of the executable predicate")

function _pauli_replay_cases(p::PauliParams{F}) where {F}
    t = p.tuple
    m = t.m
    k = pauli_log_q(t)
    n = pauli_dimension(m)
    zeros_q = falses(n * k)
    basis = p.basis
    # A question with u_x = u_z = 0, r_x = r_z = 1: gamma = tr(ind(0).1 . ind(0).1) = tr(1) = 1 (k odd).
    r = pauli_registers(m)
    raw = fill(zero(F), n)
    raw[r.r_x] = one(F)
    raw[r.r_z] = one(F)
    gamma1 = Bool[x.bits == 1 for x in field_bit_vector(raw)]
    raw0 = fill(zero(F), n)
    gamma0 = Bool[x.bits == 1 for x in field_bit_vector(raw0)]    # r_x = r_z = 0: gamma = 0
    one_bits = kappa_bits(one(F), basis)
    zero_bits = kappa_bits(zero(F), basis)
    cases = Any[]
    # item 1: equal types, equal / unequal answers
    push!(cases, (:item1, ("Variable_1", zeros_q, "Variable_1", zeros_q, [true], [true]), true))
    push!(cases, (:item1, ("Variable_1", zeros_q, "Variable_1", zeros_q, [true], [false]), false))
    # item 3: Point_X at u_x = 0 against Pauli_X with h: g_h(0) = h_1 (the all-zero index).
    h = fill(zero(F), pauli_M(t)); h[1] = one(F)
    push!(cases, (:item3, ("Point_X", gamma0, "Pauli_X", zeros_q, one_bits, kappa_bits(h, basis)), true))
    push!(cases, (:item3, ("Point_X", gamma0, "Pauli_X", zeros_q, zero_bits, kappa_bits(h, basis)), false))
    # item 4: Pair_X with Pair at gamma = 0 (r = 0): beta_x must match; at gamma = 1 anything accepts.
    push!(cases, (:item4, ("Pair_X", gamma0, "Pair", gamma0, [true], [true, false]), true))
    push!(cases, (:item4, ("Pair_X", gamma0, "Pair", gamma0, [true], [false, false]), false))
    push!(cases, (:item4, ("Pair_X", gamma1, "Pair", gamma1, [true], [false, false]), true))
    # item 6: Constraint_6 (parity 1) with Variable_3 at gamma = 1.
    push!(cases, (:item6, ("Constraint_6", gamma1, "Variable_3", gamma1, [true, false, false], [true]), true))
    push!(cases, (:item6, ("Constraint_6", gamma1, "Variable_3", gamma1, [false, false, false], [false]), false))
    push!(cases, (:item6, ("Constraint_6", gamma0, "Variable_3", gamma0, [false, false, false], [false]), true))
    # item 7: Point_X with Variable_1 at gamma = 1: tr(a r_x) = a_wbar with a = 1, r_x = 1: tr(1) = 1.
    push!(cases, (:item7, ("Point_X", gamma1, "Variable_1", gamma1, one_bits, [true]), true))
    push!(cases, (:item7, ("Point_X", gamma1, "Variable_1", gamma1, one_bits, [false]), false))
    # item 5: Point_X with Pair_X at gamma = 0 (r_x = 0 there): tr(a . 0) = 0 must equal the bit.
    push!(cases, (:item5, ("Point_X", gamma0, "Pair_X", gamma0, one_bits, [false]), true))
    push!(cases, (:item5, ("Point_X", gamma0, "Pair_X", gamma0, one_bits, [true]), false))
    cases
end

"""
    pauli_decider(q, m, d) :: Checked{DeciderDescription}

D^pauli as (:TypedDecider, TypePauli, (:Pauli, q, m, d)); the replay runs
the hand-built accept/reject pairs of `_pauli_replay_cases` in both orders.
"""
function pauli_decider(q::Integer, m::Integer, d::Integer)
    term = (:TypedDecider, pauli_type_labels(), (:Pauli, Int(q), Int(m), Int(d)))
    desc = _decider_from_term(term; parts=())
    p = PauliParams(q, m, d)
    replay = x -> begin
        ok = true
        for (_, (tA, xA, tB, xB, aA, aB), expected) in _pauli_replay_cases(p)
            ok &= decide(x, 1, tA, xA, tB, xB, aA, aB) == expected
            ok &= decide(x, 1, tB, xB, tA, xA, aB, aA) == expected
        end
        CheckResult(ok, :pauli_decider; location=:PauliDecider)
    end
    _decider_certificate(:PauliDecider, desc,
        "fig:decider_pauli on (q, m, d) = ($(q), $(m), $(d)): item 1 on equal types, items 2-7 in both player orders, accept when no guard applies, malformed applicable answers reject; Pauli answers kappa-encoded (self-dual normal basis)",
        replay, (CITED_PAULI_DECIDER, CITED_THM_PAULI), ())
end

# The TypedDecider dispatch (deciders.jl `_decide_typed`).
function _decide_typed_body(labels::Vector{String}, body, n::Int, tA, x::AbstractVector{Bool}, tB, y::AbstractVector{Bool}, a::AbstractVector{Bool}, b::AbstractVector{Bool}, trace::Vector)
    (tA in labels && tB in labels) || return false
    body[1] == :Pauli && return pauli_decide(PauliParams(body[2], body[3], body[4]), String(tA), x, String(tB), y, a, b)
    body[1] == :Intro && return _decide_intro(body, n, String(tA), x, String(tB), y, a, b, trace)
    throw(ArgumentError("unknown typed decider body"))
end

# TB6b-M's diagnostic child decider (:ZeroAnswers, coords): accept iff both
# answers are the single bit 0 and Bob's question vanishes on `coords`.
function _decide_zero_answers(term, x::AbstractVector{Bool}, y::AbstractVector{Bool}, a::AbstractVector{Bool}, b::AbstractVector{Bool})
    coords = term[2]
    a == [false] && b == [false] || return false
    all(c <= length(y) && !y[c] for c in coords)
end
"""
    diagnostic_decider(bob_zero_coordinates) :: Checked{DeciderDescription}

The asymmetric diagnostic decider of DESIGN 11.6 (TB6b-M): accepts every
on-support pair of the binary child sampler with zero answers (Bob's
question never has e_1 or e_3 components) and rejects the swapped pair.
"""
function diagnostic_decider(coords::AbstractVector{<:Integer})
    term = (:ZeroAnswers, Int[c for c in coords])
    desc = _decider_from_term(term; parts=())
    replay = x -> CheckResult(decide(x, 1, [true], falses(6), [false], [false]) &&
                              !decide(x, 1, falses(6), [true, false, false, false, false, false], [false], [false]) &&
                              !decide(x, 1, [true], falses(6), [true], [false]) &&
                              !decide(x, 1, [true], falses(6), [false], Bool[]), :diagnostic_decider; location=:DiagnosticDecider)
    _decider_certificate(:DiagnosticDecider, desc, "accept iff a == b == [0] and y vanishes on coordinates $(coords)", replay, (), ())
end
