_cl_field(::AbstractCL{F}) where {F} = F

# rk:higher-level (gt-04-cl.tex:122-130) promotes a zero map by V_1 = V and
# L_1 = 0, where V is the space the value acts on: its register R (for a
# continuation, the enclosing stage's rest register; the empty register is
# the zero-dimensional terminal every chain ends in). DESIGN 9.4 fixes the
# padding order: a genuine r>=1-level child keeps its first r factors and
# APPENDS empty stages; a zero map on R is promoted with stage 1 = R under
# the zero map, followed by empty stages. The source machines would print an
# all-zero factor indicator there, so the promotion is a SOURCE_REPAIR.
const ZERO_MAP_FACTOR_PARTITION = CertNode(SOURCE_REPAIR, :zero_map_factor_partition;
    facts=(display="pad_level(CLZero on register R, ell): stage 1 reports the all-ones indicator of R with the zero linear map; stages 2..ell report empty factors (rk:higher-level, gt-04-cl.tex:122-130; DESIGN 9.4)",))

function _pad_tail(L::CLZero{F}, extra::Int) where {F}
    extra == 0 && return L
    n = seed_dim(L)
    # SOURCE_REPAIR(zero-map-factor-partition): see ZERO_MAP_FACTOR_PARTITION.
    # One rule for every register, the empty one included (def:cl-func
    # permits the empty register subspace; verdicts/tb1-r3.md N16).
    tail = _pad_tail(CLZero(F, n, Int[]), extra - 1)
    width = length(L.indices)
    _clstep(F, n, L.indices, Int[], zeros(F, width, width), tail,
            BranchConst(tail); require_ambient=false)
end

# A top-level value is padded on its ambient space F^n. A top-level zero map
# declared on the empty register is the zero map on F^n (the empty register
# only marks chain terminals), so its promotion takes V_1 = {1..n}
# (DESIGN 9.4; verdicts/tb1-r3.md N16). A top-level zero map declared on a
# proper nonempty sub-register is malformed: every DESIGN 9.4 originator of
# a zero map is whole-space, and promoting such a value on its register
# yields a level-ell value violating enu:cl-space-sum, so the promotion is
# refused (verdicts/tb1-r4.md N25). Continuations never pass through here:
# `_pad_tail` promotes them on their rest register.
_pad_top(L::AbstractCL, extra::Int) = _pad_tail(L, extra)
function _pad_top(L::CLZero{F}, extra::Int) where {F}
    extra == 0 && return L
    isempty(L.indices) && return _pad_tail(CLZero(F, seed_dim(L)), extra)
    _register(L) == 1:seed_dim(L) ||
        throw(ArgumentError("a top-level zero map declared on a proper sub-register cannot be promoted (DESIGN 9.4, verdicts/tb1-r4.md N25)"))
    _pad_tail(L, extra)
end

function _pad_tail(L::CLStep{F}, extra::Int) where {F}
    extra == 0 && return L
    shape = _pad_tail(L.child_shape, extra)
    _clstep(F, L.seed_dim, L.factor, L.rest, L.matrix, shape,
            BranchPadded(L, extra); require_ambient=false)
end

function pad_level(L::AbstractCL{F}, target::Integer) where {F}
    target_level = Int(target)
    target_level >= level(L) || throw(ArgumentError("cannot pad to a lower CL level"))
    result = _pad_top(L, target_level - level(L))
    level(result) == target_level ||
        throw(ArgumentError("CL nesting did not reach the requested level"))
    result
end

function _replay_pad_level(term)
    padded = term.padded
    child = term.child
    ok = level(padded) == term.target && seed_dim(padded) == seed_dim(child)
    for seed in term.seeds
        ok &= apply(padded, seed) == apply(child, seed)
        for k in 1:level(child)
            ok &= marginal_k(padded, seed, k).value == marginal_k(child, seed, k).value
        end
    end
    replay = cl_kth_replay(padded, term.seeds; chain_set_id=term.chain_set_id)
    ok &= replay.space_sum_ok && replay.map_sum_ok
    CheckResult(ok, :pad_level;
                expected=(level=term.target, marginals=:child, space_sum_ok=true,
                          map_sum_ok=true),
                actual=(level=level(padded), replay.space_sum_ok, replay.map_sum_ok,
                        replay.completed_replays))
end

"""
    pad_level_evidence(L, target, seeds; chain_set_id)

`pad_level(L, target)` as a CHECKED node whose replay re-runs the DESIGN 9.4
contract on `seeds` (the child's marginals survive, `enu:cl-space-sum` and
`enu:cl-map-sum` hold on the padded value). When the padding promoted a
zero map, `ZERO_MAP_FACTOR_PARTITION` is carried as a child
(verdicts/tb2-r3.md N7).
"""
function pad_level_evidence(L::AbstractCL{F}, target::Integer, seeds;
                            chain_set_id::AbstractString) where {F}
    padded = pad_level(L, target)
    promoted = L isa CLZero && level(padded) > 0
    root = CertNode(CHECKED, :pad_level;
        facts=(child_level=level(L), target=Int(target), promoted,
               register=register_indices(L), seeds=length(seeds)),
        children=promoted ? (ZERO_MAP_FACTOR_PARTITION,) : (),
        replay=_replay_pad_level)
    Checked((; child=L, padded, target=Int(target), seeds=collect(seeds),
               chain_set_id=String(chain_set_id)), root)
end

struct TypedSampler{F}
    # The oriented type edge is sampled before one shared uniform seed is
    # pushed through its maps (gt-06-types.tex:57-93,95-151).
    # Vectors, not tuples: the product graph has 2916 oriented edges and a
    # 2916-tuple forces enormous per-length specializations.
    types::Vector{Any}
    type_graph::Vector{Tuple{Any,Any}}
    left::Dict{Any,AbstractCL{F}}
    right::Dict{Any,AbstractCL{F}}
    common_level::Int
    seed_dimension::Int
    metadata::NamedTuple
end

function TypedSampler(types, type_graph, left::AbstractDict, right::AbstractDict;
                      metadata=(;))
    type_tuple = collect(Any, types)
    isempty(type_tuple) && throw(ArgumentError("typed sampler needs at least one type"))
    length(unique(type_tuple)) == length(type_tuple) ||
        throw(ArgumentError("typed sampler types must be unique"))
    Set(keys(left)) == Set(type_tuple) == Set(keys(right)) ||
        throw(ArgumentError("left and right maps must cover the type set exactly"))
    first_map = left[first(type_tuple)]
    first_map isa AbstractCL || throw(ArgumentError("typed maps must be CL functions"))
    F = _cl_field(first_map)
    dimension = seed_dim(first_map)
    all_maps = (collect(values(left))..., collect(values(right))...)
    all(map -> map isa AbstractCL{F}, all_maps) ||
        throw(ArgumentError("typed maps must use one field"))
    all(map -> seed_dim(map) == dimension, all_maps) ||
        throw(ArgumentError("typed maps must share one seed dimension"))

    all(edge -> length(edge) == 2, type_graph) ||
        throw(ArgumentError("type graph edges must be oriented pairs"))
    edges = Tuple{Any,Any}[(edge[1], edge[2]) for edge in type_graph]
    all(edge -> edge[1] in type_tuple && edge[2] in type_tuple, edges) ||
        throw(ArgumentError("type graph has an unknown endpoint"))
    isempty(edges) && throw(ArgumentError("type graph needs an oriented edge"))
    common = maximum(level, all_maps)
    padded_left = Dict{Any,AbstractCL{F}}(
        type => pad_level(left[type], common) for type in type_tuple)
    padded_right = Dict{Any,AbstractCL{F}}(
        type => pad_level(right[type], common) for type in type_tuple)
    TypedSampler{F}(type_tuple, edges, padded_left, padded_right, common,
                    dimension, metadata)
end

level(sampler::TypedSampler) = sampler.common_level
seed_dim(sampler::TypedSampler) = sampler.seed_dimension

function sample(sampler::TypedSampler, edge_index::Integer, seed)
    1 <= edge_index <= length(sampler.type_graph) ||
        throw(ArgumentError("edge index out of range"))
    length(seed) == sampler.seed_dimension ||
        throw(ArgumentError("seed has wrong dimension"))
    edge = sampler.type_graph[Int(edge_index)]
    (; edge,
       left_question=apply(sampler.left[edge[1]], seed),
       right_question=apply(sampler.right[edge[2]], seed),
       seed=Tuple(seed))
end

function edge_index(sampler::TypedSampler, edge)
    oriented = (edge[1], edge[2])
    index = findfirst(==(oriented), sampler.type_graph)
    index === nothing &&
        throw(ArgumentError("oriented type pair is not an edge of the type graph"))
    index
end

sample(sampler::TypedSampler, edge::Tuple, seed) =
    sample(sampler, edge_index(sampler, edge), seed)

function sample(rng::AbstractRNG, sampler::TypedSampler{F}) where {F}
    edge_index = rand(rng, eachindex(sampler.type_graph))
    values = field_elements(F)
    seed = ntuple(_ -> rand(rng, values), sampler.seed_dimension)
    sample(sampler, edge_index, seed)
end
