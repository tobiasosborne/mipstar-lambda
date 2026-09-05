_cl_field(::AbstractCL{F}) where {F} = F

# rk:higher-level (gt-04-cl.tex:122-130) promotes a zero map by V_1 = V and
# L_1 = 0. DESIGN 9.4 fixes the padding order: a genuine r>=1-level child
# keeps its first r factors and APPENDS empty stages; a zero map on a
# nonempty register is promoted with stage 1 = that whole register under the
# zero map, followed by empty stages. The source machines would print an
# all-zero factor indicator there, so the promotion is a SOURCE_REPAIR.
const ZERO_MAP_FACTOR_PARTITION = CertNode(SOURCE_REPAIR, :zero_map_factor_partition;
    facts=(display="pad_level(CLZero on register R, ell): stage 1 reports the all-ones indicator of R with the zero linear map; stages 2..ell report empty factors (rk:higher-level, gt-04-cl.tex:122-130; DESIGN 9.4)",))

function _pad_tail(L::CLZero{F}, extra::Int) where {F}
    extra == 0 && return L
    n = seed_dim(L)
    empty_tail = CLZero(F, n, Int[])
    if isempty(L.indices)
        result = L
        for _ in 1:extra
            # def:cl-func permits the empty register subspace.
            result = _clstep(F, n, Int[], Int[], zeros(F, 0, 0), result,
                             BranchConst(result); require_ambient=false)
        end
        return result
    end
    # SOURCE_REPAIR(zero-map-factor-partition): see ZERO_MAP_FACTOR_PARTITION.
    tail = _pad_tail(empty_tail, extra - 1)
    width = length(L.indices)
    _clstep(F, n, L.indices, Int[], zeros(F, width, width), tail,
            BranchConst(tail); require_ambient=false)
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
    result = _pad_tail(L, target_level - level(L))
    level(result) == target_level ||
        throw(ArgumentError("CL nesting did not reach the requested level"))
    result
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
