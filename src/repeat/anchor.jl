# DESIGN 10.1: anchoring = the typed {Game, Anchor} verifier
# (gt-11-parallel-repetition.tex:89-103) followed by the executable detyper
# of DESIGN 9.5 (gt-06-types.tex:359-427). The typed anchor sampler is
# `typed_anchor_sampler` (src/descriptions/transformations.jl); this file
# adds the deciders, `detype(s, d)`, the public `anchor(v)` and the lifted
# honest strategy. prop:anchoring's completeness and Ent map stay CITED.

const CITED_ANCHORING = _cited("prop:anchoring", "gt-11-parallel-repetition.tex", 112:136,
    "V^anch is a normal form verifier: PCC completeness transfers, Ent(V^anch_n, 1 - eps) >= Ent(V_n, 1 - 4 * 16^2 * eps), TIME poly, levels ell + 2 and dimension s(n) + 8, S^anch depends only on S")

"""
    typed_anchor_decider(D) :: Checked{DeciderDescription}

gt-11-parallel-repetition.tex:98-101: a Game/Game pair is decided by D; if
either type is Anchor, every Anchor-typed player must answer the canonical
bit 0 (a Game-typed player may answer anything); malformed answers reject.
"""
function typed_anchor_decider(D::Union{DeciderDescription,Checked})
    child = _ddesc(D)
    child.typing isa Untyped || throw(ArgumentError("the typed anchor decider wraps an untyped decider"))
    term = (:TypedAnchor, child.term)
    desc = _decider_from_term(term; parts=(child,))
    replay = x -> begin
        ok = decide(x, 1, "Anchor", Bool[], "Game", Bool[], [false], [true]) &&
             decide(x, 1, "Game", Bool[], "Anchor", Bool[], [true], [false]) &&
             !decide(x, 1, "Anchor", Bool[], "Game", Bool[], [true], [false]) &&
             !decide(x, 1, "Anchor", Bool[], "Anchor", Bool[], [false], Bool[]) &&
             !decide(x, 1, "Anchor", Bool[], "Anchor", Bool[], [false, false], [false]) &&
             !decide(x, 1, "Referee", Bool[], "Game", Bool[], [false], [false])
        CheckResult(ok, :typed_anchor_decider; location=:TypedAnchorDecider)
    end
    _decider_certificate(:TypedAnchorDecider, desc,
        "Game/Game -> D(n, x, y, a, b); any Anchor-typed player must answer exactly [0]; Game answers ignored on such a pair; out-of-range types reject",
        replay, (), (D,))
end

"""
    detype_decider(D, typing) :: Checked{DeciderDescription}

gt-06-types.tex:409-427: parse x = (x', x''), y = (y', y'') with V_G the
first 4|Type| bits; accept when parsing fails or the views are not
(e_l, neigh(l), 0, e_l) / (0, e_r, e_r, neigh(r)) for an oriented edge
(l, r); otherwise return D(n, l, x'', r, y'', a, b). Accept-on-invalid is literal.
"""
function detype_decider(D::Union{DeciderDescription,Checked}, typing::Typed)
    child = _ddesc(D)
    child.typing isa Typed || throw(ArgumentError("detype_decider wraps a typed decider"))
    child.typing.labels == typing.labels || throw(ArgumentError("decider and sampler type sets differ"))
    index = Dict(l => i for (i, l) in enumerate(typing.labels))
    edges = Tuple{Int,Int}[(index[e[1]], index[e[2]]) for e in typing.edges]
    term = (:Detype, copy(typing.labels), edges, child.term)
    desc = _decider_from_term(term; parts=(child,))
    T = TypeCount(typing)
    replay = x -> begin
        l, r = first(edges)
        neigh(t) = Bool[(t, v) in edges || (v, t) in edges for v in 1:T]
        unit(t) = Bool[v == t for v in 1:T]
        xG = vcat(unit(l), neigh(l), falses(T), unit(l))
        yG = vcat(falses(T), unit(r), unit(r), neigh(r))
        traced = decide_traced(x, 1, xG, yG, [false], [false])
        ok = decide(x, 1, Bool[], Bool[], [true], Bool[]) &&              # cannot parse: accept
             decide(x, 1, falses(4T), falses(4T), [true], Bool[]) &&       # not an edge view: accept
             (traced[1] == decide(x.parts[1], 1, typing.labels[l], Bool[], typing.labels[r], Bool[], [false], [false]))
        CheckResult(ok, :detype_decider; location=:DetypeDecider)
    end
    _decider_certificate(:DetypeDecider, desc,
        "parse V_G = first 4 x $(T) bits of x and y; accept on parse failure or a non-edge view; on the oriented edge (l, r) call D(n, l, x'', r, y'', a, b) once",
        replay, (), (D,))
end

"""
    detype(s, d; tracer_index=1, seeds=32) :: Checked{VerifierDescription}

DESIGN 9.6's sole public detyping arity: `detype_sampler(s)` and
`detype_decider(d, s.typing)` on a typed pair.
"""
function detype(s::Union{SamplerDescription,Checked}, d::Union{DeciderDescription,Checked};
                tracer_index::Integer=1, seeds::Integer=32)
    S = _desc(s)
    S.typing isa Typed || throw(ArgumentError("detype takes a typed sampler description"))
    sampler = detype_sampler(s; tracer_index, seeds)
    decider = detype_decider(d, S.typing)
    V = VerifierDescription(sampler.term, decider.term)
    root = CertNode(CONSTRUCTED, :Detype;
        facts=(display="detype(S, D) over $(TypeCount(S.typing)) types: level $(S.level) + 2 = $(V.sampler.level); dimension s(n) + 4|Type| = $(Dimension(V.sampler, tracer_index)) at n = $(tracer_index); questions add $(4 * TypeCount(S.typing)) graph bits; answers unchanged",),
        children=(CITED_DETYPING, _relocate(sampler.certificate, x -> x.sampler), _relocate(decider.certificate, x -> x.decider)))
    Checked(V, root)
end

"""
    anchor(v; tracer_index=1, seeds=32) :: Checked{VerifierDescription}

DESIGN 9.4's `anchor(v)`: typed anchor sampler and decider, then detype;
field 2, level ell + 2, dimension s(n) + 8 (gt-11-parallel-repetition.tex:80-136).
"""
function anchor(V::VerifierDescription; tracer_index::Integer=1, seeds::Integer=32)
    typed_sampler = typed_anchor_sampler(V.sampler; tracer_index, seeds)
    typed_decider = typed_anchor_decider(V.decider)
    detyped = detype(typed_sampler, typed_decider; tracer_index, seeds)
    A = detyped.term
    root = CertNode(CONSTRUCTED, :Anchor;
        facts=(display="V^anch = detype(tS^anch, tD^anch): field 2; level ell + 2 = $(V.sampler.level) + 2 = $(A.sampler.level); dimension s(n) + 8 = $(Dimension(A.sampler, tracer_index)) at n = $(tracer_index); S^anch depends on {$(join(sort(string.(collect(A.sampler.dependency_set))), ", "))} (gt-11:134-135)",),
        children=(CITED_ANCHORING, detyped.certificate))
    Checked(A, root)
end

# ---------------------------------------------------------------------------
# The finite honest strategy of DESIGN 10.1: parse the detyped graph view;
# an Anchor question answers 0, a Game question goes through the child's
# honest strategy on the body, an invalid view answers 0 (the decider
# accepts such pairs regardless).

function _graph_view_type(labels::Vector{String}, edges::Vector{Tuple{Int,Int}}, player::Symbol, question::Vector{Bool})
    T = length(labels)
    length(question) >= 4T || return nothing
    neigh(t) = Bool[(t, v) in edges || (v, t) in edges for v in 1:T]
    unit(t) = Bool[v == t for v in 1:T]
    G = question[1:4T]
    for t in 1:T
        expected = player == :alice ? vcat(unit(t), neigh(t), falses(T), unit(t)) :
                                      vcat(falses(T), unit(t), unit(t), neigh(t))
        G == expected && return t
    end
    nothing
end

"""
    anchored_honest_answer(A, player, question, child_honest) -> Vector{Bool}

The lifted honest strategy on the anchored verifier A: `child_honest(player, body)`
answers a Game question's body, an Anchor question answers [0], an invalid
view answers [0].
"""
function anchored_honest_answer(A::VerifierDescription, player::Symbol, question::Vector{Bool}, child_honest::Function)
    term = A.decider.term
    term[1] == :Detype || throw(ArgumentError("not a detyped verifier"))
    labels, edges = term[2], term[3]
    t = _graph_view_type(labels, edges, player, question)
    t === nothing && return Bool[false]
    labels[t] == "Anchor" && return Bool[false]
    child_honest(player, question[4*length(labels)+1:end])
end
