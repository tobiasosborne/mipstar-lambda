_cl_field(::AbstractCL{F}) where {F} = F

function pad_level(L::AbstractCL{F}, target::Integer) where {F}
    target_level = Int(target)
    target_level >= level(L) || throw(ArgumentError("cannot pad to a lower CL level"))
    result = L
    for _ in 1:(target_level - level(L))
        # def:cl-func permits the empty register subspace; this zero-output
        # stage makes the lower-level function an inhabitant of the next level.
        result = CLStep(F, seed_dim(result), (), register_indices(result),
                        zeros(F, 0, 0), result)
    end
    level(result) == target_level ||
        throw(ArgumentError("CL nesting did not reach the requested level"))
    result
end

struct TypedSampler{F}
    # The oriented type edge is sampled before one shared uniform seed is
    # pushed through its maps (gt-06-types.tex:57-93,95-151).
    types::Tuple
    type_graph::Tuple
    left::Dict{Any,AbstractCL{F}}
    right::Dict{Any,AbstractCL{F}}
    common_level::Int
    seed_dimension::Int
    metadata::NamedTuple
end

function TypedSampler(types, type_graph, left::AbstractDict, right::AbstractDict;
                      metadata=(;))
    type_tuple = Tuple(types)
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

    edges = Tuple(Tuple(edge) for edge in type_graph)
    all(edge -> length(edge) == 2 && edge[1] in type_tuple && edge[2] in type_tuple,
        edges) || throw(ArgumentError("type graph has an unknown endpoint"))
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

function sample(rng::AbstractRNG, sampler::TypedSampler{F}) where {F}
    edge_index = rand(rng, eachindex(sampler.type_graph))
    values = field_elements(F)
    seed = ntuple(_ -> rand(rng, values), sampler.seed_dimension)
    sample(sampler, edge_index, seed)
end
