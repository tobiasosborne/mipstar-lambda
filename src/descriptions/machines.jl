# DESIGN 9.3-9.5: the universal sampler interpreter. A description term is
# compiled once to a tree of SamplerMachines; every composite answers the
# four queries by forwarding to its children's four queries only (it never
# reads child CL IR), and every leaf answers from the in-memory CL value
# decoded from its bytes. Illegal calls throw ArgumentError inside the
# machine; the public boundary `query` maps them to QueryError (G5).

abstract type SamplerMachine end

"Per-query meter: same-mode calls issued by the ROOT machine to its direct children, dimension calls, and in-memory leaf calls."
mutable struct Meter
    child_calls::Int
    dimension_calls::Int
    leaf_calls::Int
    depth::Int
end
Meter() = Meter(0, 0, 0, 0)

# A composite calls a child through `_forward`, so the root's direct child
# calls are counted exactly once each (DESIGN 9.2 metered interpreter).
function _forward(ctx::Meter, mode::Symbol, f::Function)
    ctx.depth == 1 && (mode == :dimension ? (ctx.dimension_calls += 1) : (ctx.child_calls += 1))
    ctx.depth += 1
    result = f()
    ctx.depth -= 1
    result
end

# ---------------------------------------------------------------------------
# Leaf: a CL pair or a typed family decoded from bytes (DESIGN 9.3).

struct LeafMachine{F} <: SamplerMachine
    q::Int
    dim::Int
    level::Int
    typing::Union{Untyped,Typed}
    maps::Dict{Tuple{Symbol,Any},AbstractCL{F}}
end

# A leaf CL term is admitted only when it is whole-space on its ambient:
# `factor (+) rest = {1..n}` at the top stage (re-imposed on decode,
# verdicts/tb2-r4.md NOTE 4) and a top-level zero map in one of its two
# whole-space spellings (verdicts/tb1-r5.md N30; DESIGN 9.4).
function _leaf_cl(::Type{F}, term, n::Int) where {F}
    L = _term_to_cl(F, term)
    seed_dim(L) == n || throw(ArgumentError("leaf CL term dimension $(seed_dim(L)) differs from the pair's $(n)"))
    if L isa CLZero
        _whole_space_zero(L) || throw(ArgumentError("a top-level zero map must be whole-space: its full register or the empty register (DESIGN 9.4)"))
    else
        _register(L) == 1:n || throw(ArgumentError("leaf CL term's top stage does not span the ambient basis"))
    end
    L
end

function _compile_leaf(term)
    q = term[2]
    F = _field_type(q)
    maps = Dict{Tuple{Symbol,Any},AbstractCL{F}}()
    if term[1] == :Pair
        n = term[3][2]
        maps[(:alice, nothing)] = _leaf_cl(F, term[3], n)
        maps[(:bob, nothing)] = _leaf_cl(F, term[4], n)
        typing = Untyped()
    else
        labels, edges, entries = term[3], term[4], term[5]
        length(entries) == length(labels) || throw(ArgumentError("typed family needs one map pair per type"))
        typing = Typed(labels, [(labels[i], labels[j]) for (i, j) in edges])
        n = entries[1][1][2]
        for (label, (left, right)) in zip(labels, entries)
            maps[(:alice, label)] = _leaf_cl(F, left, n)
            maps[(:bob, label)] = _leaf_cl(F, right, n)
        end
    end
    levels = unique(level(L) for L in values(maps))
    length(levels) == 1 || throw(ArgumentError("every map of a leaf description must have the constructed common level"))
    LeafMachine{F}(q, n, levels[1], typing, maps)
end

_field(m::LeafMachine{F}) where {F} = F
machine_field_size(m::LeafMachine) = m.q
machine_level(m::LeafMachine) = m.level
machine_typing(m::LeafMachine) = m.typing
_dimension(m::LeafMachine, n::Int, ctx::Meter) = m.dim
function _leaf_map(m::LeafMachine, w::Symbol, t)
    L = get(m.maps, (w, t), nothing)
    L === nothing && throw(ArgumentError("type out of range for this description"))
    L
end
function _marginal(m::LeafMachine{F}, n::Int, w::Symbol, j::Int, z::Vector{F}, t, ctx::Meter) where {F}
    ctx.leaf_calls += 1
    collect(Marginal(_leaf_map(m, w, t), j, z))
end
function _linear(m::LeafMachine{F}, n::Int, w::Symbol, j::Int, u::Vector{F}, y::Vector{F}, t, ctx::Meter) where {F}
    ctx.leaf_calls += 1
    collect(Linear(_leaf_map(m, w, t), j, u, y))
end
function _factor(m::LeafMachine{F}, n::Int, w::Symbol, j::Int, u::Vector{F}, t, ctx::Meter) where {F}
    ctx.leaf_calls += 1
    Factor(_leaf_map(m, w, t), j, u)
end

# ---------------------------------------------------------------------------
# Padding of a child inside a maximum-level composite (DESIGN 9.4): a
# genuine r >= 1-level child keeps its first r factors and appends empty
# factors; a level-0 whole-space zero map is promoted by rk:higher-level
# (gt-04-cl.tex:122-130): stage 1 = the all-ones indicator of its block and
# the zero map, stages 2..ell empty. SOURCE_REPAIR(zero-map-factor-partition).

_zeros(::Type{F}, s::Int) where {F} = fill(zero(F), s)

function _padded_marginal(child::SamplerMachine, n::Int, w::Symbol, j::Int, z::Vector{F}, t, ctx::Meter) where {F}
    r = machine_level(child)
    r == 0 && return _zeros(F, length(z))
    _forward(ctx, :marginal, () -> _marginal(child, n, w, min(j, r), z, t, ctx))
end
function _padded_linear(child::SamplerMachine, n::Int, w::Symbol, j::Int, u::Vector{F}, y::Vector{F}, t, ctx::Meter) where {F}
    r = machine_level(child)
    if r == 0
        j == 1 && !all(iszero, u) && throw(ArgumentError("prefix has support outside V_{<1} = {0}"))
        return _zeros(F, length(y))
    end
    j > r && return _zeros(F, length(y))
    _forward(ctx, :linear, () -> _linear(child, n, w, j, u, y, t, ctx))
end
function _padded_factor(child::SamplerMachine, n::Int, w::Symbol, j::Int, u::Vector{F}, t, ctx::Meter) where {F}
    r = machine_level(child)
    if r == 0
        all(iszero, u) || throw(ArgumentError("Factor prefix is not a reachable marginal L_{<j}(V) = {0} of the zero map"))
        return j == 1 ? ones(Int, length(u)) : zeros(Int, length(u))
    end
    j > r && (_require_image(child, n, w, u, t, ctx); return zeros(Int, length(u)))
    _forward(ctx, :factor, () -> _factor(child, n, w, j, u, t, ctx))
end

# u in L_{<= r}(V) for an r-level child, decided through its queries alone:
# walk the factor chain from the zero prefix, checking each stage's block of
# u against the column space of that stage's map (its columns are Linear on
# the factor basis vectors).
function _require_image(child::SamplerMachine, n::Int, w::Symbol, u::Vector{F}, t, ctx::Meter) where {F}
    r = machine_level(child)
    s = length(u)
    covered = falses(s)
    prefix = _zeros(F, s)
    for j in 1:r
        indicator = _forward(ctx, :factor, () -> _factor(child, n, w, j, prefix, t, ctx))
        support = findall(==(1), indicator)
        columns = Matrix{F}(undef, length(support), length(support))
        for (c, coordinate) in enumerate(support)
            e = _zeros(F, s)
            e[coordinate] = one(F)
            image = _forward(ctx, :linear, () -> _linear(child, n, w, j, prefix, e, t, ctx))
            columns[:, c] = image[support]
        end
        _in_column_space(columns, u[support]) ||
            throw(ArgumentError("Factor prefix is not a reachable marginal L_{<j}(V)"))
        prefix[support] = u[support]
        covered[support] .= true
    end
    all(covered[c] || iszero(u[c]) for c in 1:s) || throw(ArgumentError("prefix has support outside V_{<j}"))
    nothing
end

# ---------------------------------------------------------------------------
# DL9-direct-sum (lem:cl-func-prod, gt-04-cl.tex:315-327): blocks, maximum level.

struct DirectSumMachine <: SamplerMachine
    children::Vector{SamplerMachine}
    q::Int
    level::Int
end
function DirectSumMachine(children::Vector{SamplerMachine})
    isempty(children) && throw(ArgumentError("direct_sum needs at least one description"))
    qs = unique(machine_field_size(c) for c in children)
    length(qs) == 1 || throw(ArgumentError("direct_sum rejects mismatched fields $(qs) (DESIGN 9.4: downsize first)"))
    all(c -> machine_typing(c) isa Untyped, children) ||
        throw(ArgumentError("direct_sum takes untyped descriptions; `product` combines typed ones"))
    DirectSumMachine(children, qs[1], maximum(machine_level, children))
end
_field(m::DirectSumMachine) = _field(m.children[1])
machine_field_size(m::DirectSumMachine) = m.q
machine_level(m::DirectSumMachine) = m.level
machine_typing(m::DirectSumMachine) = Untyped()
_block_dims(m::DirectSumMachine, n::Int, ctx::Meter) =
    Int[_forward(ctx, :dimension, () -> _dimension(c, n, ctx)) for c in m.children]
_dimension(m::DirectSumMachine, n::Int, ctx::Meter) = sum(_block_dims(m, n, ctx))

function _split_blocks(v::Vector{F}, dims::Vector{Int}) where {F}
    length(v) == sum(dims) || throw(ArgumentError("vector does not split into the registered blocks"))
    offset = 0
    blocks = Vector{F}[]
    for d in dims
        push!(blocks, v[offset+1:offset+d])
        offset += d
    end
    blocks
end

function _marginal(m::DirectSumMachine, n::Int, w::Symbol, j::Int, z::Vector{F}, t, ctx::Meter) where {F}
    blocks = _split_blocks(z, _block_dims(m, n, ctx))
    reduce(vcat, (_padded_marginal(c, n, w, j, b, t, ctx) for (c, b) in zip(m.children, blocks)))
end
function _linear(m::DirectSumMachine, n::Int, w::Symbol, j::Int, u::Vector{F}, y::Vector{F}, t, ctx::Meter) where {F}
    dims = _block_dims(m, n, ctx)
    us, ys = _split_blocks(u, dims), _split_blocks(y, dims)
    reduce(vcat, (_padded_linear(c, n, w, j, ui, yi, t, ctx) for (c, ui, yi) in zip(m.children, us, ys)))
end
function _factor(m::DirectSumMachine, n::Int, w::Symbol, j::Int, u::Vector{F}, t, ctx::Meter) where {F}
    blocks = _split_blocks(u, _block_dims(m, n, ctx))
    reduce(vcat, (_padded_factor(c, n, w, j, b, t, ctx) for (c, b) in zip(m.children, blocks)))
end

# ---------------------------------------------------------------------------
# DL9-product: Cartesian type set, tensor type graph (gt-10:1949-1955),
# per-type direct sum of the two selected maps.

struct ProductMachine <: SamplerMachine
    left::SamplerMachine
    right::SamplerMachine
    typing::Typed
    index::Dict{String,Tuple{String,String}}
    level::Int
end
_product_label(l::String, r::String) = l * "," * r
function ProductMachine(left::SamplerMachine, right::SamplerMachine)
    lt, rt = machine_typing(left), machine_typing(right)
    (lt isa Typed && rt isa Typed) || throw(ArgumentError("product takes two typed descriptions"))
    machine_field_size(left) == machine_field_size(right) ||
        throw(ArgumentError("product rejects mismatched fields (DESIGN 9.4: downsize first)"))
    labels = String[_product_label(l, r) for l in lt.labels for r in rt.labels]
    edges = Tuple{String,String}[(_product_label(l, r), _product_label(l2, r2))
                                 for (l, l2) in lt.edges for (r, r2) in rt.edges]
    index = Dict{String,Tuple{String,String}}(_product_label(l, r) => (l, r) for l in lt.labels for r in rt.labels)
    ProductMachine(left, right, Typed(labels, edges), index, max(machine_level(left), machine_level(right)))
end
_field(m::ProductMachine) = _field(m.left)
machine_field_size(m::ProductMachine) = machine_field_size(m.left)
machine_level(m::ProductMachine) = m.level
machine_typing(m::ProductMachine) = m.typing
function _product_types(m::ProductMachine, t)
    pair = get(m.index, t, nothing)
    pair === nothing && throw(ArgumentError("type out of range for this description"))
    pair
end
_product_dims(m::ProductMachine, n::Int, ctx::Meter) =
    Int[_forward(ctx, :dimension, () -> _dimension(m.left, n, ctx)), _forward(ctx, :dimension, () -> _dimension(m.right, n, ctx))]
_dimension(m::ProductMachine, n::Int, ctx::Meter) = sum(_product_dims(m, n, ctx))
function _marginal(m::ProductMachine, n::Int, w::Symbol, j::Int, z::Vector{F}, t, ctx::Meter) where {F}
    l, r = _product_types(m, t)
    zl, zr = _split_blocks(z, _product_dims(m, n, ctx))
    vcat(_padded_marginal(m.left, n, w, j, zl, l, ctx), _padded_marginal(m.right, n, w, j, zr, r, ctx))
end
function _linear(m::ProductMachine, n::Int, w::Symbol, j::Int, u::Vector{F}, y::Vector{F}, t, ctx::Meter) where {F}
    l, r = _product_types(m, t)
    dims = _product_dims(m, n, ctx)
    ul, ur = _split_blocks(u, dims)
    yl, yr = _split_blocks(y, dims)
    vcat(_padded_linear(m.left, n, w, j, ul, yl, l, ctx), _padded_linear(m.right, n, w, j, ur, yr, r, ctx))
end
function _factor(m::ProductMachine, n::Int, w::Symbol, j::Int, u::Vector{F}, t, ctx::Meter) where {F}
    l, r = _product_types(m, t)
    ul, ur = _split_blocks(u, _product_dims(m, n, ctx))
    vcat(_padded_factor(m.left, n, w, j, ul, l, ctx), _padded_factor(m.right, n, w, j, ur, r, ctx))
end

# ---------------------------------------------------------------------------
# DL9-repeat (gt-11-parallel-repetition.tex:200-215): the k(n)-fold direct
# sum of ONE child, executed as a loop; k is never unrolled in the term.

struct RepeatMachine <: SamplerMachine
    lambda::Int
    tau::Int
    c_prime::Rational{Int}
    child::SamplerMachine
end
_field(m::RepeatMachine) = _field(m.child)
machine_field_size(m::RepeatMachine) = machine_field_size(m.child)
machine_level(m::RepeatMachine) = machine_level(m.child)
machine_typing(m::RepeatMachine) = machine_typing(m.child)
_k(m::RepeatMachine, n::Int) = k_rep(m.lambda, m.tau, m.c_prime, n)
_s_prime(m::RepeatMachine, n::Int, ctx::Meter) = _forward(ctx, :dimension, () -> _dimension(m.child, n, ctx))
_dimension(m::RepeatMachine, n::Int, ctx::Meter) = _k(m, n) * _s_prime(m, n, ctx)
function _repeat_blocks(m::RepeatMachine, n::Int, v::Vector{F}, ctx::Meter) where {F}
    s = _s_prime(m, n, ctx)
    k = _k(m, n)
    length(v) == k * s || throw(ArgumentError("vector does not parse as a k(n)-tuple of F_2^s' blocks"))
    [v[(i-1)*s+1:i*s] for i in 1:k]
end
function _marginal(m::RepeatMachine, n::Int, w::Symbol, j::Int, z::Vector{F}, t, ctx::Meter) where {F}
    reduce(vcat, (_forward(ctx, :marginal, () -> _marginal(m.child, n, w, j, zi, t, ctx)) for zi in _repeat_blocks(m, n, z, ctx)))
end
function _linear(m::RepeatMachine, n::Int, w::Symbol, j::Int, u::Vector{F}, y::Vector{F}, t, ctx::Meter) where {F}
    us = _repeat_blocks(m, n, u, ctx)
    ys = _repeat_blocks(m, n, y, ctx)
    reduce(vcat, (_forward(ctx, :linear, () -> _linear(m.child, n, w, j, ui, yi, t, ctx)) for (ui, yi) in zip(us, ys)))
end
function _factor(m::RepeatMachine, n::Int, w::Symbol, j::Int, u::Vector{F}, t, ctx::Meter) where {F}
    reduce(vcat, (_forward(ctx, :factor, () -> _factor(m.child, n, w, j, ui, t, ctx)) for ui in _repeat_blocks(m, n, u, ctx)))
end

# ---------------------------------------------------------------------------
# The typed anchor family (gt-11-parallel-repetition.tex:89-97): Game
# delegates to the child, Anchor is the zero map on the same ambient space,
# promoted by rk:higher-level (SOURCE_REPAIR(zero-map-factor-partition) at
# gt-11:96, which prints an all-zero factor).

const ANCHOR_TYPING = Typed(["Game", "Anchor"],
                            [("Game", "Game"), ("Game", "Anchor"), ("Anchor", "Game"), ("Anchor", "Anchor")])

struct AnchorMachine <: SamplerMachine
    child::SamplerMachine
    function AnchorMachine(child::SamplerMachine)
        machine_typing(child) isa Untyped || throw(ArgumentError("anchoring takes an untyped normal-form sampler"))
        machine_field_size(child) == 2 || throw(ArgumentError("anchoring takes a sampler over F_2 (normal form)"))
        machine_level(child) >= 1 || throw(ArgumentError("anchoring takes a sampler of level >= 1"))
        new(child)
    end
end
_field(m::AnchorMachine) = _field(m.child)
machine_field_size(m::AnchorMachine) = 2
machine_level(m::AnchorMachine) = machine_level(m.child)
machine_typing(m::AnchorMachine) = ANCHOR_TYPING
_dimension(m::AnchorMachine, n::Int, ctx::Meter) = _forward(ctx, :dimension, () -> _dimension(m.child, n, ctx))
function _anchor_type(t)
    t == "Game" && return :game
    t == "Anchor" && return :anchor
    throw(ArgumentError("type out of range for this description"))
end
function _marginal(m::AnchorMachine, n::Int, w::Symbol, j::Int, z::Vector{F}, t, ctx::Meter) where {F}
    _anchor_type(t) == :game && return _forward(ctx, :marginal, () -> _marginal(m.child, n, w, j, z, nothing, ctx))
    _zeros(F, length(z))
end
function _linear(m::AnchorMachine, n::Int, w::Symbol, j::Int, u::Vector{F}, y::Vector{F}, t, ctx::Meter) where {F}
    _anchor_type(t) == :game && return _forward(ctx, :linear, () -> _linear(m.child, n, w, j, u, y, nothing, ctx))
    j == 1 && !all(iszero, u) && throw(ArgumentError("prefix has support outside V_{<1} = {0}"))
    _zeros(F, length(y))
end
function _factor(m::AnchorMachine, n::Int, w::Symbol, j::Int, u::Vector{F}, t, ctx::Meter) where {F}
    _anchor_type(t) == :game && return _forward(ctx, :factor, () -> _factor(m.child, n, w, j, u, nothing, ctx))
    all(iszero, u) || throw(ArgumentError("Factor prefix is not a reachable marginal L_{<j}(V) = {0} of the Anchor zero map"))
    # rk:higher-level: V_1 = V under the zero map, V_{>1} = {0}.
    j == 1 ? ones(Int, length(u)) : zeros(Int, length(u))
end

# ---------------------------------------------------------------------------
# DL9-detype (gt-06-types.tex:225-339 fig:graph-distribution; L359-L404
# def:detyped-CL): V_G = V_vA (+) V_eA (+) V_vB (+) V_eB, each F_2^Type;
# player w's stage 1 is the identity on its own two graph registers, stage 2
# keeps the single opposite-edge bit selected by its encoded type, and
# stages >= 3 forward stage j-2 to the typed child for the revealed type or
# to the promoted zero map when the selected edge register is zero.

struct DetypeMachine <: SamplerMachine
    child::SamplerMachine
    typing::Typed
    neighbors::Vector{Vector{Bool}}
    function DetypeMachine(child::SamplerMachine)
        typing = machine_typing(child)
        typing isa Typed || throw(ArgumentError("detype takes a typed description"))
        machine_field_size(child) == 2 || throw(ArgumentError("detype takes a typed sampler over F_2"))
        T = TypeCount(typing)
        edges = Set(typing.edges)
        neighbors = [Bool[(typing.labels[t], typing.labels[v]) in edges || (typing.labels[v], typing.labels[t]) in edges
                          for v in 1:T] for t in 1:T]
        new(child, typing, neighbors)
    end
end
_field(m::DetypeMachine) = _field(m.child)
machine_field_size(m::DetypeMachine) = 2
machine_level(m::DetypeMachine) = machine_level(m.child) + 2
machine_typing(m::DetypeMachine) = Untyped()
_type_count(m::DetypeMachine) = TypeCount(m.typing)
_body_dim(m::DetypeMachine, n::Int, ctx::Meter) = _forward(ctx, :dimension, () -> _dimension(m.child, n, ctx))
_dimension(m::DetypeMachine, n::Int, ctx::Meter) = 4 * _type_count(m) + _body_dim(m, n, ctx)

# Player w's own (vertex, edge) registers and the opposite player's.
function _graph_registers(m::DetypeMachine, w::Symbol)
    T = _type_count(m)
    vA, eA, vB, eB = 1:T, T+1:2T, 2T+1:3T, 3T+1:4T
    w == :alice ? (; own_v=vA, own_e=eA, other_v=vB, other_e=eB) : (; own_v=vB, own_e=eB, other_v=vA, other_e=eA)
end
_body(m::DetypeMachine, v::Vector) = v[4*_type_count(m)+1:end]

# The type t with (x_own_v, x_own_e) = enc_G(t) = (e_t, neigh_G(t)), or nothing.
function _encoded_type(m::DetypeMachine, x::Vector{F}, regs) where {F}
    ones_at = findall(!iszero, x[regs.own_v])
    length(ones_at) == 1 || return nothing
    t = ones_at[1]
    all(iszero(x[regs.own_e[v]]) == !m.neighbors[t][v] for v in 1:_type_count(m)) || return nothing
    t
end
# The revealed type at stages >= 3 (def:detyped-CL): the opposite-edge
# register selected by the own vertex encoding is nonzero. On unreachable
# prefixes the own vertex must still be a unit vector e_t; otherwise zero.
function _revealed_type(m::DetypeMachine, z::Vector{F}, regs) where {F}
    ones_at = findall(!iszero, z[regs.own_v])
    length(ones_at) == 1 || return nothing
    t = ones_at[1]
    iszero(z[regs.other_e[t]]) ? nothing : t
end

function _graph_marginal(m::DetypeMachine, j::Int, z::Vector{F}, regs) where {F}
    out = _zeros(F, length(z))
    out[regs.own_v] = z[regs.own_v]
    out[regs.own_e] = z[regs.own_e]
    j >= 2 || return out
    t = _encoded_type(m, z, regs)
    t === nothing || (out[regs.other_e[t]] = z[regs.other_e[t]])
    out
end

function _marginal(m::DetypeMachine, n::Int, w::Symbol, j::Int, z::Vector{F}, t, ctx::Meter) where {F}
    regs = _graph_registers(m, w)
    out = _graph_marginal(m, j, z, regs)
    j <= 2 && return out
    revealed = _revealed_type(m, out, regs)
    revealed === nothing && return out
    body = _forward(ctx, :marginal, () -> _marginal(m.child, n, w, j - 2, _body(m, z), m.typing.labels[revealed], ctx))
    out[4*_type_count(m)+1:end] = body
    out
end

# u in L_{<j}(V_G (+) V) for the graph part: stage 1 reaches every own
# value; stage 2 reaches 0 or the selected edge bit only.
function _require_graph_prefix(m::DetypeMachine, j::Int, u::Vector{F}, regs) where {F}
    G = 4 * _type_count(m)
    if j == 1
        all(iszero, u) || throw(ArgumentError("prefix has support outside V_{<1} = {0}"))
    elseif j == 2
        all(iszero(u[c]) for c in vcat(regs.other_v, regs.other_e)) && all(iszero, u[G+1:end]) ||
            throw(ArgumentError("prefix has support outside V_{<2} (the own graph registers)"))
    else
        t = _encoded_type(m, u, regs)
        all(iszero, u[regs.other_v]) || throw(ArgumentError("Factor prefix is not a reachable marginal L_{<j}(V): opposite vertex register"))
        allowed = t === nothing ? Int[] : [regs.other_e[t]]
        all(c in allowed || iszero(u[c]) for c in regs.other_e) ||
            throw(ArgumentError("Factor prefix is not a reachable marginal L_{<j}(V): opposite edge register"))
    end
    nothing
end

function _factor(m::DetypeMachine, n::Int, w::Symbol, j::Int, u::Vector{F}, t, ctx::Meter) where {F}
    regs = _graph_registers(m, w)
    _require_graph_prefix(m, j, u, regs)
    G = 4 * _type_count(m)
    indicator = zeros(Int, length(u))
    if j == 1
        indicator[regs.own_v] .= 1
        indicator[regs.own_e] .= 1
    elseif j == 2
        indicator[regs.other_v] .= 1
        indicator[regs.other_e] .= 1
    else
        revealed = _revealed_type(m, u, regs)
        body = _body(m, u)
        if revealed === nothing
            # The zero conditional child, promoted (DESIGN 9.5 / 9.4).
            all(iszero, body) || throw(ArgumentError("Factor prefix is not a reachable marginal L_{<j}(V) = {0} of the zero conditional child"))
            j == 3 && (indicator[G+1:end] .= 1)
        else
            label = m.typing.labels[revealed]
            indicator[G+1:end] = _forward(ctx, :factor, () -> _factor(m.child, n, w, j - 2, body, label, ctx))
        end
    end
    indicator
end

function _linear(m::DetypeMachine, n::Int, w::Symbol, j::Int, u::Vector{F}, y::Vector{F}, t, ctx::Meter) where {F}
    regs = _graph_registers(m, w)
    G = 4 * _type_count(m)
    out = _zeros(F, length(y))
    if j == 1
        all(iszero, u) || throw(ArgumentError("prefix has support outside V_{<1} = {0}"))
        out[regs.own_v] = y[regs.own_v]
        out[regs.own_e] = y[regs.own_e]
    elseif j == 2
        all(iszero(u[c]) for c in vcat(regs.other_v, regs.other_e)) && all(iszero, u[G+1:end]) ||
            throw(ArgumentError("prefix has support outside V_{<2}"))
        enc = _encoded_type(m, u, regs)
        enc === nothing || (out[regs.other_e[enc]] = y[regs.other_e[enc]])
    else
        revealed = _revealed_type(m, u, regs)
        revealed === nothing && return out
        label = m.typing.labels[revealed]
        out[G+1:end] = _forward(ctx, :linear, () -> _linear(m.child, n, w, j - 2, _body(m, u), _body(m, y), label, ctx))
    end
    out
end

# ---------------------------------------------------------------------------
# DL9-downsize (def:downsize_sampler / lem:downsize_sampler,
# gt-04-cl.tex:628-680): the conjugates downsize o L o downsize^-1 through
# the fixed polynomial basis; ASSUME q = 2^kappa with kappa odd.

struct DownsizeMachine <: SamplerMachine
    child::SamplerMachine
    kappa::Int
    function DownsizeMachine(child::SamplerMachine)
        q = machine_field_size(child)
        kappa = round(Int, log2(q))
        (q >= 4 && 1 << kappa == q) || throw(ArgumentError("downsize takes a sampler over F_{2^kappa}, kappa >= 2"))
        isodd(kappa) || throw(ArgumentError("downsize assumes an odd extension degree (lem:downsize-cl-dist)"))
        new(child, kappa)
    end
end
_field(m::DownsizeMachine) = GF2
machine_field_size(m::DownsizeMachine) = 2
machine_level(m::DownsizeMachine) = machine_level(m.child)
machine_typing(m::DownsizeMachine) = machine_typing(m.child)
_dimension(m::DownsizeMachine, n::Int, ctx::Meter) = m.kappa * _forward(ctx, :dimension, () -> _dimension(m.child, n, ctx))

"The F_2-vector of an F_{2^kappa}-vector in the fixed polynomial basis, kappa big-endian bits per coordinate."
function field_bit_vector(v::AbstractVector{F}) where {F<:GF2k}
    kappa = round(Int, log2(field_size(F)))
    GF2[GF2((Int(x.bits) >> (kappa - b)) & 1) for x in v for b in 1:kappa]
end
function _field_from_bits(::Type{F}, bits::Vector{GF2}, kappa::Int) where {F}
    length(bits) % kappa == 0 || throw(ArgumentError("bit vector does not parse into field elements"))
    F[F(foldl((acc, b) -> (acc << 1) | Int(b.bits), bits[(i-1)*kappa+1:i*kappa]; init=0))
      for i in 1:length(bits) ÷ kappa]
end
function _marginal(m::DownsizeMachine, n::Int, w::Symbol, j::Int, z::Vector{GF2}, t, ctx::Meter)
    F = _field(m.child)
    field_bit_vector(_forward(ctx, :marginal, () -> _marginal(m.child, n, w, j, _field_from_bits(F, z, m.kappa), t, ctx)))
end
function _linear(m::DownsizeMachine, n::Int, w::Symbol, j::Int, u::Vector{GF2}, y::Vector{GF2}, t, ctx::Meter)
    F = _field(m.child)
    field_bit_vector(_forward(ctx, :linear, () -> _linear(m.child, n, w, j, _field_from_bits(F, u, m.kappa),
                                                       _field_from_bits(F, y, m.kappa), t, ctx)))
end
function _factor(m::DownsizeMachine, n::Int, w::Symbol, j::Int, u::Vector{GF2}, t, ctx::Meter)
    F = _field(m.child)
    indicator = _forward(ctx, :factor, () -> _factor(m.child, n, w, j, _field_from_bits(F, u, m.kappa), t, ctx))
    repeat(indicator; inner=m.kappa)
end

# ---------------------------------------------------------------------------
# Query-purity device (DESIGN 9.6): an opaque machine exposing only the four
# operations and logging every call it receives.

struct RecordingMachine <: SamplerMachine
    inner::SamplerMachine
    log::Vector{Any}
end
RecordingMachine(inner::SamplerMachine) = RecordingMachine(inner, Any[])
_field(m::RecordingMachine) = _field(m.inner)
machine_field_size(m::RecordingMachine) = machine_field_size(m.inner)
machine_level(m::RecordingMachine) = machine_level(m.inner)
machine_typing(m::RecordingMachine) = machine_typing(m.inner)
_dimension(m::RecordingMachine, n::Int, ctx::Meter) = (push!(m.log, (:dimension, n)); _dimension(m.inner, n, ctx))
_marginal(m::RecordingMachine, n::Int, w::Symbol, j::Int, z, t, ctx::Meter) =
    (push!(m.log, (:marginal, n, w, j, t)); _marginal(m.inner, n, w, j, z, t, ctx))
_linear(m::RecordingMachine, n::Int, w::Symbol, j::Int, u, y, t, ctx::Meter) =
    (push!(m.log, (:linear, n, w, j, t)); _linear(m.inner, n, w, j, u, y, t, ctx))
_factor(m::RecordingMachine, n::Int, w::Symbol, j::Int, u, t, ctx::Meter) =
    (push!(m.log, (:factor, n, w, j, t)); _factor(m.inner, n, w, j, u, t, ctx))

# ---------------------------------------------------------------------------
# Compilation of a term to its machine, and the public boundary.

function compile_sampler(term)
    tag = term[1]
    tag in (:Pair, :TypedFamily) && return _compile_leaf(term)
    tag == :DirectSum && return DirectSumMachine(SamplerMachine[compile_sampler(c) for c in term[2]])
    tag == :Repeat && return RepeatMachine(term[2], term[3], term[4] // term[5], compile_sampler(term[6]))
    tag == :Anchor && return AnchorMachine(compile_sampler(term[2]))
    tag == :Detype && return DetypeMachine(compile_sampler(term[2]))
    tag == :Product && return ProductMachine(compile_sampler(term[2]), compile_sampler(term[3]))
    tag == :Downsize && return DownsizeMachine(compile_sampler(term[2]))
    throw(ArgumentError("unknown sampler term $(tag)"))
end

function machine(S::SamplerDescription)
    S.machine[] === nothing && (S.machine[] = compile_sampler(S.term))
    S.machine[]::SamplerMachine
end

_as_field_vector(::Type{F}, v, s::Int, what::String) where {F} =
    (length(v) == s || throw(ArgumentError("$(what) has wrong dimension: $(length(v)) for s(n) = $(s)"));
     F[convert(F, x) for x in v])

# The validated public wrapper (DESIGN 9.1): player, stage, type and vector
# lengths are checked before the quoted machine runs; the raw typed machine
# would return 0 on an out-of-range type (gt-06-types.tex:133-136).
function _validated_answer(m::SamplerMachine, q::SamplerQuery, ctx::Meter)
    q.n >= 1 || throw(ArgumentError("index n must be positive"))
    ctx.depth = 1
    q isa DimensionQuery && return _dimension(m, q.n, ctx)
    q.w in PLAYERS || throw(ArgumentError("player must be alice or bob"))
    1 <= q.j <= machine_level(m) || throw(ArgumentError("stage index out of range"))
    typing = machine_typing(m)
    if typing isa Untyped
        q.type === nothing || throw(ArgumentError("this description is untyped"))
    else
        (q.type isa AbstractString && String(q.type) in typing.labels) ||
            throw(ArgumentError("type out of range for this description"))
    end
    t = q.type === nothing ? nothing : String(q.type)
    F = _field(m)
    s = _dimension(m, q.n, Meter())
    q isa MarginalQuery && return _marginal(m, q.n, q.w, q.j, _as_field_vector(F, q.z, s, "seed"), t, ctx)
    q isa FactorQuery && return _factor(m, q.n, q.w, q.j, _as_field_vector(F, q.u, s, "prefix"), t, ctx)
    _linear(m, q.n, q.w, q.j, _as_field_vector(F, q.u, s, "prefix"), _as_field_vector(F, q.y, s, "Linear input"), t, ctx)
end

"query(S, q): the answer, or QueryError for a malformed call (never throws for an ArgumentError)."
function query(S::SamplerDescription, q::SamplerQuery)
    try
        _validated_answer(machine(S), q, Meter())
    catch error
        error isa ArgumentError && return QueryError(error.msg)
        rethrow()
    end
end
"metered_query(S, q) -> (answer, meter): the answer and the root's child-call counts."
function metered_query(S::SamplerDescription, q::SamplerQuery)
    ctx = Meter()
    answer = try
        _validated_answer(machine(S), q, ctx)
    catch error
        error isa ArgumentError ? QueryError(error.msg) : rethrow()
    end
    (answer, ctx)
end

Dimension(S::SamplerDescription, n::Integer) = query(S, DimensionQuery(Int(n)))
Marginal(S::SamplerDescription, n::Integer, w::Symbol, j::Integer, z, type=nothing) =
    query(S, MarginalQuery(Int(n), w, Int(j), z, type))
Linear(S::SamplerDescription, n::Integer, w::Symbol, j::Integer, u, y, type=nothing) =
    query(S, LinearQuery(Int(n), w, Int(j), u, y, type))
Factor(S::SamplerDescription, n::Integer, w::Symbol, j::Integer, u, type=nothing) =
    query(S, FactorQuery(Int(n), w, Int(j), u, type))

"""
    sample_questions(S, n, z[, edge]) -> (x, y)

def:sampler-sample / def:typed-sampler-sample (gt-04-cl.tex:614-626,
gt-06-types.tex:143-151): the last marginal of both players on one seed;
for a typed description the oriented edge supplies the two types.
"""
function sample_questions(S::SamplerDescription, n::Integer, z, edge=nothing)
    if S.typing isa Untyped
        edge === nothing || throw(ArgumentError("an untyped description takes no edge"))
        return (_raise(Marginal(S, n, :alice, S.level, z)), _raise(Marginal(S, n, :bob, S.level, z)))
    end
    edge in S.typing.edges || throw(ArgumentError("oriented type pair is not an edge of the type graph"))
    (_raise(Marginal(S, n, :alice, S.level, z, edge[1])), _raise(Marginal(S, n, :bob, S.level, z, edge[2])))
end
_raise(answer) = answer isa QueryError ? throw(ArgumentError(answer.reason)) : answer

# ---------------------------------------------------------------------------
# The CL function of a description on index n for player w (and type t),
# reachable only through the four queries: an AbstractCL view so that
# TB1's `cl_kth_replay` runs unchanged on descriptions (DESIGN 9.2).

struct DescribedCL{F} <: AbstractCL{F}
    description::SamplerDescription
    n::Int
    w::Symbol
    type::Any
    seed_dim::Int
    level::Int
end
function described_cl(S::SamplerDescription, n::Integer, w::Symbol, type=nothing)
    F = _field(machine(S))
    s = _raise(Dimension(S, n))
    DescribedCL{F}(S, Int(n), w, type === nothing ? nothing : String(type), s, S.level)
end
level(v::DescribedCL) = v.level
Marginal(v::DescribedCL, j::Integer, z) = _raise(Marginal(v.description, v.n, v.w, j, z, v.type))
Linear(v::DescribedCL, j::Integer, u, y) = _raise(Linear(v.description, v.n, v.w, j, u, y, v.type))
Factor(v::DescribedCL, j::Integer, u) = _raise(Factor(v.description, v.n, v.w, j, u, v.type))
apply(v::DescribedCL{F}, z) where {F} = v.level == 0 ? Tuple(_zeros(F, v.seed_dim)) : Tuple(Marginal(v, v.level, z))
