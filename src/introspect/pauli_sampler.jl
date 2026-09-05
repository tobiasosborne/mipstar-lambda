# TB6 (DESIGN 11.2, 11.3; briefs/43 addendum Gap 4): the three primitive
# sampler tags with the mandatory DESIGN 9.6 output-sampler rows:
#   (:Pauli, q, m, d)               the typed Pauli family of gt-07-ldt.tex:L1070-L1120
#   (:Intro, lambda, ell, q, m, d)  tilde S^intro of gt-08-introspection.tex:L317-L345
#   (:Graph, labels, edges)         graph_sampler(G) of gt-06-types.tex:L250-L339
# and the composite `intro_sampler` = detype_sampler(downsize(tilde S^intro)).

# --- the Pauli CL maps on V^pauli ------------------------------------------------
# V^pauli = V_xpt (+) V_zpt (+) V_coord (+) V_dir (+) V_rxpt (+) V_rzpt, identified
# with tuples (u_x, u_z, s, v, r_x, r_z) in F_q^m x F_q^m x F_q x F_q^m x F_q x F_q
# (gt-07:L1077-L1084); coordinates in that order.
pauli_dimension(m::Integer) = 3 * Int(m) + 3
function pauli_registers(m::Integer)
    m = Int(m)
    (; u_x=1:m, u_z=m+1:2m, s=2m+1, v=2m+2:3m+1, r_x=3m+2, r_z=3m+3)
end
# The positions of (u_W, s, v) in V^pauli: the range of the low-degree maps
# (gt-07:L1085-L1089 and footnote: embedded "in the natural way").
function pauli_positions(m::Integer, W::AbstractString)
    r = pauli_registers(m)
    vcat(collect(W == "X" ? r.u_x : r.u_z), r.s, collect(r.v))
end

"""
    pauli_maps(F, m) -> Dict{String,AbstractCL}

The CL functions L_t of gt-07:L1085-L1112, one per type label: the embedded
L_Point / L_ALine / L_DLine of TB1 on (u_W, s, v) (levels 1, 2, 3; zero on
V_{Wbar} (+) V_r); the 1-level projection onto (u_x, u_z, r_x, r_z) for the
Magic-Square, Pair, (Pair, W) types; the whole-space zero map for (Pauli, W).
Both players use the same maps (gt-08:L326-L328).
"""
function pauli_maps(::Type{F}, m::Integer) where {F<:GF2k}
    n = pauli_dimension(m)
    r = pauli_registers(m)
    maps = Dict{String,AbstractCL{F}}()
    for W in PAULI_BASES
        positions = pauli_positions(m, W)
        maps["Point_$(W)"] = embed_cl(L_Point(F, m), positions, n)
        maps["ALine_$(W)"] = embed_cl(L_ALine(F, m), positions, n)
        maps["DLine_$(W)"] = embed_cl(L_DLine(F, m), positions, n)
        maps["Pauli_$(W)"] = CLZero(F, n)
    end
    factor = vcat(collect(r.u_x), collect(r.u_z), r.r_x, r.r_z)
    rest = vcat(r.s, collect(r.v))
    identity = F[F(i == j) for i in 1:length(factor), j in 1:length(factor)]
    tail = CLZero(F, n, rest)
    projection = _clstep(F, n, factor, rest, identity, tail, BranchConst(tail); require_ambient=true)
    for label in vcat(["Constraint_$(i)" for i in 1:6], ["Variable_$(j)" for j in 1:9], ["Pair", "Pair_X", "Pair_Z"])
        maps[label] = projection
    end
    maps
end

# A LeafMachine over the padded in-memory family (the machine of a primitive tag).
function _family_machine(::Type{F}, typing::Typed, maps::Dict{String,AbstractCL{F}}) where {F}
    sampler = TypedSampler(typing.labels, typing.edges, maps, maps)
    leaf = Dict{Tuple{Symbol,Any},AbstractCL{F}}()
    for label in typing.labels
        leaf[(:alice, label)] = sampler.left[label]
        leaf[(:bob, label)] = sampler.right[label]
    end
    LeafMachine{F}(field_size(F), seed_dim(sampler), level(sampler), typing, leaf)
end

function _compile_pauli(term)
    q, m, d = term[2], term[3], term[4]
    (q >= 2 && m >= 1 && d >= 1) || throw(ArgumentError("the Pauli family needs an explicit tuple (q, m, d) (production introparams are NOT_EVALUABLE: a, b of thm:pauli are symbols)"))
    F = _field_type(q)
    _family_machine(F, pauli_typing(), pauli_maps(F, m))
end

function _intro_maps(::Type{F}, m::Integer, ell::Integer) where {F}
    maps = pauli_maps(F, m)
    n = pauli_dimension(m)
    for label in intro_type_labels(ell)
        haskey(maps, label) || (maps[label] = CLZero(F, n))   # 0-level maps (gt-08:L331-L336), promoted by rk:higher-level
    end
    maps
end
function _compile_intro(term)
    lambda, ell, q, m, d = term[2], term[3], term[4], term[5], term[6]
    (lambda >= 1 && ell >= 1) || throw(ArgumentError("tilde S^intro needs lambda, ell >= 1"))
    (q >= 2 && m >= 1 && d >= 1) || throw(ArgumentError("tilde S^intro needs an explicit tuple (q, m, d) (production introparams(N^lambda) are NOT_EVALUABLE: a, b of thm:pauli are symbols)"))
    F = _field_type(q)
    _family_machine(F, intro_typing(ell), _intro_maps(F, m, ell))
end

# --- graph_sampler(G) as a stand-alone level-2 machine ------------------------
struct GraphMachine <: AbstractGraphMachine
    typing::Typed
    neighbors::Vector{Vector{Bool}}
    q::Int
    dim::Int
    level::Int
    function GraphMachine(typing::Typed)
        T = TypeCount(typing)
        edges = Set(typing.edges)
        neighbors = [Bool[(typing.labels[t], typing.labels[v]) in edges || (typing.labels[v], typing.labels[t]) in edges
                          for v in 1:T] for t in 1:T]
        new(typing, neighbors, 2, 4T, 2)
    end
end
_field(m::GraphMachine) = GF2
machine_field_size(m::GraphMachine) = 2
machine_level(m::GraphMachine) = 2
machine_typing(m::GraphMachine) = Untyped()
_dimension(m::GraphMachine, n::Int, ctx::Meter) = m.dim
function _marginal(m::GraphMachine, n::Int, w::Symbol, j::Int, z::Vector{GF2}, t, ctx::Meter)
    regs = _graph_registers(m, w)
    _charge!(ctx, 4 * _type_count(m))
    _graph_marginal(m, j, z, regs)
end
function _factor(m::GraphMachine, n::Int, w::Symbol, j::Int, u::Vector{GF2}, t, ctx::Meter)
    regs = _graph_registers(m, w)
    _charge!(ctx, 2 * length(u))
    _require_graph_prefix(m, j, u, regs)
    indicator = zeros(Int, length(u))
    own = j == 1 ? (regs.own_v, regs.own_e) : (regs.other_v, regs.other_e)
    indicator[own[1]] .= 1
    indicator[own[2]] .= 1
    indicator
end
function _linear(m::GraphMachine, n::Int, w::Symbol, j::Int, u::Vector{GF2}, y::Vector{GF2}, t, ctx::Meter)
    regs = _graph_registers(m, w)
    _charge!(ctx, length(u))
    out = _zeros(GF2, length(y), ctx)
    if j == 1
        all(iszero, u) || throw(ArgumentError("prefix has support outside V_{<1} = {0}"))
        out[regs.own_v] = y[regs.own_v]
        out[regs.own_e] = y[regs.own_e]
    else
        all(iszero(u[c]) for c in vcat(regs.other_v, regs.other_e)) ||
            throw(ArgumentError("prefix has support outside V_{<2}"))
        enc = _encoded_type(m, u, regs)
        enc === nothing || (out[regs.other_e[enc]] = y[regs.other_e[enc]])
    end
    out
end

# --- certificate rows shared by the primitives ------------------------------------
const CITED_PAULI_MAPS = _cited("fig:type-graph-pauli", "gt-07-ldt.tex", 1012:1068,
    "G^pauli: 26 vertices, the 18 Magic-Square incidences, the six low-degree/Pauli chain edges, PointX--Variable1, PointZ--Variable5, the two Pair chains, and a self-loop at every vertex (caption L1064-L1066); the CL functions per type are L1070-L1120")
const CITED_QLD_COMPLEXITY = _cited("lem:qld-complexity", "gt-07-ldt.tex", 1577:1600,
    "poly(R) decider time, polylog R marginal/factor computations and description of D^pauli at introparams(R); the general TM bounds stay CITED")
const CITED_INTRO_SAMPLER = _cited("lem:intro-sampler-complexity", "gt-08-introspection.tex", 347:392,
    "ComputeIntroSampler outputs tilde S^intro from (lambda, ell) in polylog(lambda, ell); TIME = poly(n, lambda, ell); a 3-level typed sampler; the paper-TM bounds stay CITED")
const CITED_GRAPH_SAMPLER = _cited("def:graph-sampler", "gt-06-types.tex", 250:339,
    "the graph sampler on V_vA (+) V_eA (+) V_vB (+) V_eB with the vertex/neighbour encodings and the selected opposite-edge bit (fig:graph-distribution, prop:simulating-graph)")
const CITED_DOWNSIZE_TYPED = _cited("lem:downsize_typed_sampler", "gt-06-types.tex", 153:178,
    "the downsized typed sampler keeps the level and type graph, has field 2 and dimension s(n) log q(n)")

# The zero-map promotion witness for the (Pauli, W) / new introspection types
# (SOURCE_REPAIR(zero-map-factor-partition) against gt-07:L1106-L1108 and gt-08:L333-L345).
function _zero_promotion_nodes(::Type{F}, n::Int, level::Int, labels::Vector{String}, source::String, chain_set_id::String) where {F}
    witness_seeds = big(field_size(F))^n <= 512 ? collect(enumerate_seeds(F, n)) : Any[]
    pad = pad_level_evidence(CLZero(F, n), level, witness_seeds; chain_set_id)
    pad_node = CertNode(pad.certificate.grade, pad.certificate.rule;
        facts=(; pad.certificate.facts..., padding_context=:top_level_ambient,
                 display="$(join(labels, ", ")) = pad_level(CLZero(F_$(field_size(F)), $(n)), $(level)) in the top-level ambient context: stage 1 reports the all-ones indicator, stages 2..$(level) empty"),
        children=pad.certificate.children, replay=pad.certificate.replay)
    repair = CertNode(SOURCE_REPAIR, :zero_map_factor_report;
        facts=(display="$(source) writes the identically-0 (0-level) map for $(join(labels, ", ")); the executable reports V_1 = V^pauli at stage 1 and empty factors at stages 2..$(level) (rk:higher-level, gt-04-cl.tex:122-130) so enu:cl-space-sum holds: SOURCE_REPAIR(zero-map-factor-partition)",))
    (pad.term, (repair, _relocate(pad_node, x -> x.evidence)))
end

# CHECKED: the oriented pair set stored in the description is both
# orientations of the transcribed undirected edges plus every loop.
function _graph_transcription_node(typing::Typed, undirected::Vector{Tuple{String,String}}, what::String)
    expected = oriented_pairs(typing.labels, undirected)
    counts = (types=length(typing.labels), undirected=length(undirected), oriented=length(expected))
    CertNode(CHECKED, :GraphTranscription;
        facts=(display="$(what): $(counts.types) types, $(counts.undirected) undirected non-loop edges transcribed from the figure, stored as $(counts.oriented) = 2*$(counts.undirected) + $(counts.types) oriented pairs (DESIGN 9.5 convention)", counts),
        replay=x -> CheckResult(x.typing.labels == typing.labels && Set(x.typing.edges) == Set(expected) &&
                                length(x.typing.edges) == 2 * length(undirected) + length(typing.labels),
                                :graph_transcription; location=:GraphTranscription, expected=counts,
                                actual=(types=TypeCount(x.typing), oriented=length(x.typing.edges))))
end

"""
    pauli_sampler(q, m, d; tracer_index=1, seeds=32) :: Checked{SamplerDescription}

The typed Pauli family (:Pauli, q, m, d): field q, level 3, dimension 3m+3,
26 types, 86 oriented pairs; with the DESIGN 9.6 rows, the zero-map
promotion for (Pauli, X), (Pauli, Z), and the graph transcription check.
"""
function pauli_sampler(q::Integer, m::Integer, d::Integer; tracer_index::Integer=1, seeds::Integer=32)
    term = (:Pauli, Int(q), Int(m), Int(d))
    F = _field_type(Int(q))
    n = pauli_dimension(m)
    evidence, zero_nodes = _zero_promotion_nodes(F, n, 3, ["Pauli_X", "Pauli_Z"], "gt-07-ldt.tex:L1106-L1108", "tb6-pauli-pad")
    _composite(:PauliSampler, term, (), (CITED_PAULI_MAPS, CITED_QLD_COMPLEXITY, CITED_TYPED_SAMPLER, CITED_CL_KTH);
               tracer_index=Int(tracer_index), seeds=Int(seeds),
               expected=(; field=Int(q), level=3, dimension=3 * Int(m) + 3, query_time=:(TIME_S(n))),
               promoted=true, expected_calls=0, call_law="a primitive family answers without child calls",
               evidence, extra=(_graph_transcription_node(pauli_typing(), pauli_undirected_edges(), "G^pauli"), zero_nodes...),
               display="typed Pauli family over F_$(q) on V^pauli = (u_x, u_z, s, v, r_x, r_z), dim 3m+3 = $(n), (q, m, d) = ($(q), $(m), $(d)); PointW/ALineW/DLineW embed TB1's maps (levels 1, 2, 3), MS/Pair types project onto (u_x, u_z, r_x, r_z), PauliW = 0")
end

"""
    tilde_S_intro(lambda, ell; tuple::PauliTuple, tracer_index=1, seeds=32) :: Checked{SamplerDescription}

tilde S^intro (:Intro, lambda, ell, q, m, d): the Pauli maps on the Pauli
types and the whole-space zero map on the 6 + 2 ell new types; typed, field
q, level 3, dimension 3m+3, 32 + 2 ell types, 6 ell + 110 oriented pairs.
The description depends only on (lambda, ell) and the tuple, never on the
input verifier (gt-08:L317-L345, L819-L840).
"""
function tilde_S_intro(lambda::Integer, ell::Integer; tuple::PauliTuple, tracer_index::Integer=1, seeds::Integer=32)
    term = (:Intro, Int(lambda), Int(ell), tuple.q, tuple.m, tuple.d)
    F = _field_type(tuple.q)
    n = pauli_dimension(tuple.m)
    new_labels = [l for l in intro_type_labels(ell) if !is_pauli_label(l)]
    evidence, zero_nodes = _zero_promotion_nodes(F, n, 3, vcat(["Pauli_X", "Pauli_Z"], new_labels), "gt-07-ldt.tex:L1106-L1108 and gt-08-introspection.tex:L333-L345", "tb6-intro-pad")
    _composite(:TildeSIntro, term, (), (CITED_INTRO_SAMPLER, CITED_PAULI_MAPS, CITED_TYPED_SAMPLER, CITED_CL_KTH);
               tracer_index=Int(tracer_index), seeds=Int(seeds),
               expected=(; field=tuple.q, level=3, dimension=3 * tuple.m + 3, query_time=:(TIME_S(n))),
               promoted=true, expected_calls=0, call_law="a primitive family answers without child calls",
               evidence, extra=(_graph_transcription_node(intro_typing(ell), intro_undirected_edges(ell), "G^intro at ell = $(ell)"), zero_nodes...),
               display="tilde S^intro over F_$(tuple.q): |TypeIntro| = 32 + 2 ell = $(32 + 2ell), $(6ell + 110) oriented pairs; Pauli maps on TypePauli, the zero map on the $(length(new_labels)) new types; depends on (lambda, ell) = ($(lambda), $(ell)) and $(tuple) only")
end

"""
    graph_sampler(typing::Typed; tracer_index=1, seeds=32) :: Checked{SamplerDescription}

graph_sampler(G) (:Graph, labels, edges): untyped, field 2, level 2,
dimension 4|Type| (def:graph-sampler, gt-06:L250-L339).
"""
function graph_sampler(typing::Typed; tracer_index::Integer=1, seeds::Integer=32)
    index = Dict(l => i for (i, l) in enumerate(typing.labels))
    term = (:Graph, copy(typing.labels), Tuple{Int,Int}[(index[e[1]], index[e[2]]) for e in typing.edges])
    _composite(:GraphSampler, term, (), (CITED_GRAPH_SAMPLER, CITED_CL_KTH);
               tracer_index=Int(tracer_index), seeds=Int(seeds),
               expected=(; field=2, level=2, dimension=4 * TypeCount(typing), query_time=:(TIME_S(n))),
               expected_calls=0, call_law="a primitive family answers without child calls",
               display="graph_sampler(G) on V_vA (+) V_eA (+) V_vB (+) V_eB, 4 x $(TypeCount(typing)) bits, $(length(typing.edges)) oriented pairs (fig:graph-distribution)")
end

"""
    intro_sampler(lambda, ell; tuple, tracer_index=1, seeds=32) -> (; tilde, hat, detyped)

The chain tilde S^intro -> hat S^intro = downsize(...) (typed, field 2,
level 3, dimension (3m+3) log q) -> S^intro = detype_sampler(...) (untyped,
level 5, dimension (3m+3) log q + 4(32+2 ell)) (DESIGN 11.3).
"""
function intro_sampler(lambda::Integer, ell::Integer; tuple::PauliTuple, tracer_index::Integer=1, seeds::Integer=32)
    tilde = tilde_S_intro(lambda, ell; tuple, tracer_index, seeds)
    hat = downsize(tilde; tracer_index, seeds)
    detyped = detype_sampler(hat; tracer_index, seeds)
    (; tilde, hat, detyped)
end
