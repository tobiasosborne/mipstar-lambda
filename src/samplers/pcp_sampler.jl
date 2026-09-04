const _PCP_KINDS = (:Point, :ALine, :DLine)

"One of the eighteen labels in Type^pcp (gt-10:1887-1894)."
struct PCPType
    kind::Symbol
    copy::Int
    function PCPType(kind::Symbol, copy::Integer)
        kind in _PCP_KINDS || throw(ArgumentError("unknown PCP question kind"))
        1 <= copy <= 6 || throw(ArgumentError("PCP copy must be in 1:6"))
        new(kind, Int(copy))
    end
end

Base.show(io::IO, kind::PCPType) = print(io, kind.kind, "_", kind.copy)

"Register coordinates realizing eq:V-pcp, including its derived copy-6 sums."
struct PCPRegisterLayout
    m::Int
    m_prime::Int
    s::Int
    ambient_dimension::Int
    registers::Dict{Tuple{Int,Symbol},Tuple{Vararg{Int}}}
    auxiliary_coordinate::Int
end

function _pcp_register_layout(params::PCPParams)
    params.m_prime == 5params.m + 5 + params.s ||
        throw(ArgumentError("m' must equal 5m+5+s"))
    registers = Dict{Tuple{Int,Symbol},Tuple{Vararg{Int}}}()
    cursor = 0
    for i in 1:5
        registers[(i, :pt)] = Tuple(cursor+1:cursor+params.m)
        cursor += params.m
        registers[(i, :coord)] = (cursor + 1,)
        cursor += 1
        registers[(i, :dir)] = Tuple(cursor+1:cursor+params.m)
        cursor += params.m
    end
    auxiliary_width = 5 + params.s
    auxiliary_point = Tuple(cursor+1:cursor+auxiliary_width)
    cursor += auxiliary_width
    auxiliary_coordinate = cursor + 1
    cursor += 1
    auxiliary_direction = Tuple(cursor+1:cursor+auxiliary_width)
    cursor += auxiliary_width
    registers[(6, :pt)] = Tuple(vcat(
        [collect(registers[(i, :pt)]) for i in 1:5]...,
        collect(auxiliary_point)))
    registers[(6, :coord)] = Tuple(vcat(
        [collect(registers[(i, :coord)]) for i in 1:5]...,
        [auxiliary_coordinate]))
    registers[(6, :dir)] = Tuple(vcat(
        [collect(registers[(i, :dir)]) for i in 1:5]...,
        collect(auxiliary_direction)))
    PCPRegisterLayout(params.m, params.m_prime, params.s, cursor, registers,
                      auxiliary_coordinate)
end

# The generic CLStep constructor materializes every image value.  At TB2's
# q=2048,m'=16 this would enumerate GF(q)^16 merely to represent the direction
# stage.  This adapter retains an inductive depth witness while evaluating the
# three cited L_Point/L_ALine/L_DLine formulas lazily on the supplied seed.
abstract type AbstractPCPStage end
struct PCPStageZero <: AbstractPCPStage end
struct PCPStage{C<:AbstractPCPStage} <: AbstractPCPStage
    child::C
end
_pcp_stage_depth(::PCPStageZero) = 0
_pcp_stage_depth(stage::PCPStage) = 1 + _pcp_stage_depth(stage.child)
_pcp_stages(depth::Int) = depth == 0 ? PCPStageZero() : PCPStage(_pcp_stages(depth - 1))

struct PCPCLMap{F,S<:AbstractPCPStage} <: AbstractCL{F}
    type::PCPType
    layout::PCPRegisterLayout
    stages::S
end

level(map::PCPCLMap) = _pcp_stage_depth(map.stages)
seed_dim(map::PCPCLMap) = map.layout.ambient_dimension
register_indices(map::PCPCLMap) = Tuple(1:seed_dim(map))

function _pcp_scatter!(output, indices, values)
    for (index, value) in zip(indices, values)
        output[index] = value
    end
    output
end

function apply(map::PCPCLMap{F}, seed) where {F}
    length(seed) == seed_dim(map) || throw(ArgumentError("seed has wrong dimension"))
    kind = map.type
    layout = map.layout
    dimension = kind.copy == 6 ? layout.m_prime : layout.m
    point_indices = layout.registers[(kind.copy, :pt)]
    direction_indices = layout.registers[(kind.copy, :dir)]
    coordinate_index = kind.copy == 6 ? layout.auxiliary_coordinate :
                                        only(layout.registers[(kind.copy, :coord)])
    point = ntuple(i -> convert(F, seed[point_indices[i]]), dimension)
    output = fill(zero(F), layout.ambient_dimension)
    if kind.kind == :Point
        return Tuple(_pcp_scatter!(output, point_indices, point))
    end

    coordinate = convert(F, seed[coordinate_index])
    axis = chi(coordinate, dimension)
    if kind.kind == :ALine
        axis_direction = ntuple(i -> F(i == axis), dimension)
        base = L_lnf(axis_direction, point)
        _pcp_scatter!(output, point_indices, base)
        output[coordinate_index] = coordinate
        return Tuple(output)
    end

    direction = ntuple(i -> convert(F, seed[direction_indices[i]]), dimension)
    projected_direction = pi_prefix(direction, axis - 1)
    base = L_lnf(projected_direction, point)
    _pcp_scatter!(output, point_indices, base)
    output[coordinate_index] = coordinate
    _pcp_scatter!(output, direction_indices, projected_direction)
    Tuple(output)
end

"Empty-stage padding around a lazy PCP map, with depth still carried inductively."
struct PCPPaddedMap{F,M<:PCPCLMap{F},S<:AbstractPCPStage} <: AbstractCL{F}
    map::M
    padding::S
end

level(map::PCPPaddedMap) = _pcp_stage_depth(map.padding) + level(map.map)
seed_dim(map::PCPPaddedMap) = seed_dim(map.map)
register_indices(map::PCPPaddedMap) = register_indices(map.map)
apply(map::PCPPaddedMap, seed) = apply(map.map, seed)

function pad_level(map::PCPCLMap{F}, target::Integer) where {F}
    target_level = Int(target)
    target_level >= level(map) || throw(ArgumentError("cannot pad to a lower CL level"))
    PCPPaddedMap(map, _pcp_stages(target_level - level(map)))
end

function pad_level(map::PCPPaddedMap, target::Integer)
    target_level = Int(target)
    target_level >= level(map) || throw(ArgumentError("cannot pad to a lower CL level"))
    target_level == level(map) && return map
    PCPPaddedMap(map.map,
                 _pcp_stages(_pcp_stage_depth(map.padding) +
                             target_level - level(map)))
end

function _pcp_stage_data(map::PCPCLMap{F}, seed) where {F}
    final = apply(map, seed)
    dimension = map.type.copy == 6 ? map.layout.m_prime : map.layout.m
    point_indices = map.layout.registers[(map.type.copy, :pt)]
    direction_indices = map.layout.registers[(map.type.copy, :dir)]
    coordinate_index = map.type.copy == 6 ? map.layout.auxiliary_coordinate :
        only(map.layout.registers[(map.type.copy, :coord)])
    ambient = map.layout.ambient_dimension
    if map.type.kind == :Point
        matrix = zeros(F, ambient, ambient)
        for index in point_indices
            matrix[index, index] = one(F)
        end
        return (Tuple[final], Tuple[Tuple(1:ambient)], Matrix{F}[matrix])
    end

    coordinate_output = fill(zero(F), ambient)
    coordinate_output[coordinate_index] = final[coordinate_index]
    point_output = fill(zero(F), ambient)
    _pcp_scatter!(point_output, point_indices,
                  ntuple(i -> final[point_indices[i]], dimension))
    point_set = Set(point_indices)
    if map.type.kind == :ALine
        first_factor = Tuple(i for i in 1:ambient if !(i in point_set))
        first_matrix = zeros(F, length(first_factor), length(first_factor))
        first_matrix[findfirst(==(coordinate_index), first_factor),
                     findfirst(==(coordinate_index), first_factor)] = one(F)
        axis = chi(final[coordinate_index], dimension)
        axis_direction = ntuple(i -> F(i == axis), dimension)
        return (Tuple[Tuple(coordinate_output), Tuple(point_output)],
                Tuple[first_factor, point_indices],
                Matrix{F}[first_matrix, L_lnf(axis_direction)])
    end

    direction_output = fill(zero(F), ambient)
    direction = ntuple(i -> final[direction_indices[i]], dimension)
    _pcp_scatter!(direction_output, direction_indices, direction)
    direction_set = Set(direction_indices)
    first_factor = Tuple(i for i in 1:ambient
                         if !(i in point_set) && !(i in direction_set))
    first_matrix = zeros(F, length(first_factor), length(first_factor))
    coordinate_position = findfirst(==(coordinate_index), first_factor)
    first_matrix[coordinate_position, coordinate_position] = one(F)
    axis = chi(final[coordinate_index], dimension)
    direction_matrix = zeros(F, dimension, dimension)
    for i in axis:dimension
        direction_matrix[i, i] = one(F)
    end
    (Tuple[Tuple(coordinate_output), Tuple(direction_output), Tuple(point_output)],
     Tuple[first_factor, direction_indices, point_indices],
     Matrix{F}[first_matrix, direction_matrix, L_lnf(direction)])
end

function marginal_k(map::PCPPaddedMap{F}, seed, k::Integer) where {F}
    length(seed) == seed_dim(map) || throw(ArgumentError("seed has wrong dimension"))
    count = Int(k)
    0 <= count <= level(map) || throw(ArgumentError("marginal index out of range"))
    outputs = Tuple[]
    factors = Tuple[]
    maps = Matrix{F}[]
    padding = _pcp_stage_depth(map.padding)
    for _ in 1:min(count, padding)
        push!(outputs, ntuple(_ -> zero(F), seed_dim(map)))
        push!(factors, ())
        push!(maps, zeros(F, 0, 0))
    end
    if count > padding
        intrinsic_outputs, intrinsic_factors, intrinsic_maps =
            _pcp_stage_data(map.map, seed)
        take = count - padding
        append!(outputs, intrinsic_outputs[1:take])
        append!(factors, intrinsic_factors[1:take])
        append!(maps, intrinsic_maps[1:take])
    end
    marginal = CLMarginal{F}(seed_dim(map), outputs, factors, maps,
                             ntuple(_ -> zero(F), seed_dim(map)))
    CLMarginal{F}(marginal.seed_dim, outputs, factors, maps,
                  sum_stage_outputs(marginal))
end

function _pcp_base_map(map::PCPCLMap)
    map
end

_pcp_base_map(map::PCPPaddedMap) = map.map

function _pcp_base_map(map::CLStep)
    haskey(map.branches, nothing) ||
        throw(ArgumentError("expected a fixed padding branch"))
    _pcp_base_map(map.branches[nothing])
end

function _pcp_replay_sampler(sampler::TypedSampler)
    types_ok = length(sampler.types) == 18 &&
               Set(sampler.types) == Set(PCPType(kind, i)
                                         for kind in _PCP_KINDS for i in 1:6)
    graph_ok = length(sampler.type_graph) == 18^2 &&
               Set(sampler.type_graph) == Set((a, b) for a in sampler.types
                                                     for b in sampler.types)
    base = _pcp_base_map(first(values(sampler.left)))
    dimensions = Dict(key => length(value)
                      for (key, value) in base.layout.registers)
    dimensions_ok = all(dimensions[(i, :pt)] == base.layout.m &&
                        dimensions[(i, :coord)] == 1 &&
                        dimensions[(i, :dir)] == base.layout.m for i in 1:5) &&
                    dimensions[(6, :pt)] == base.layout.m_prime &&
                    dimensions[(6, :coord)] == 6 &&
                    dimensions[(6, :dir)] == base.layout.m_prime
    CheckResult(types_ok && graph_ok && level(sampler) == 3 && dimensions_ok,
                :pcp_sampler_shape;
                expected=(types=18, edges=324, level=3,
                          copy6=(base.layout.m_prime, 6, base.layout.m_prime)),
                actual=(types=length(sampler.types),
                        edges=length(sampler.type_graph), level=level(sampler),
                        copy6=(dimensions[(6, :pt)], dimensions[(6, :coord)],
                               dimensions[(6, :dir)])))
end

"Build the 18-type, complete-graph PCP sampler of sec:ld-compiler."
function _build_pcp_sampler(::Type{F}, params::PCPParams) where {F<:GF2k}
    field_size(F) == params.q || throw(ArgumentError("field size does not match PCP parameters"))
    layout = _pcp_register_layout(params)
    types = Tuple(PCPType(kind, i) for kind in _PCP_KINDS for i in 1:6)
    maps = Dict{Any,AbstractCL{F}}()
    for kind in types
        depth = kind.kind == :Point ? 1 : kind.kind == :ALine ? 2 : 3
        maps[kind] = PCPCLMap{F,typeof(_pcp_stages(depth))}(
            kind, layout, _pcp_stages(depth))
    end
    graph = Tuple((left, right) for left in types for right in types)
    sampler = TypedSampler(types, graph, maps, maps)
    source_repair = CertNode(SOURCE_REPAIR, :PCPCopy6CoordinateScalar;
        facts=(display="dim V_{6,coord}=6; table:tpcp exposes one scalar; chi reads V_aux,coord and the other five coordinates are zeroed/ignored",))
    constructed = CertNode(CONSTRUCTED, :PCPCLDatatype;
        facts=(display="intrinsic levels Point/ALine/DLine=1/2/3; padded common level=3",))
    root = CertNode(CHECKED, :TypedPCPSampler;
        facts=(display="18 types; complete 18^2 graph; V6 dimensions ($(params.m_prime),6,$(params.m_prime))",),
        children=(constructed, source_repair), replay=_pcp_replay_sampler)
    Checked(sampler, root)
end

_pcp_parameter_tuple(params::PCPParams) =
    (params.q, params.k, params.m, params.d, params.s, params.m_prime)

# Like TB1's immutable trees, the sole TB2 row is safe to serialize in the
# package cache and avoids rebuilding/padding 36 maps in every test section.
const _TB2_PCP_PARAMETER_TUPLE = (2048, 11, 1, 11, 6, 16)
const _TB2_PCP_SAMPLER = _build_pcp_sampler(
    GF2048, PCPParams(_TB2_PCP_PARAMETER_TUPLE...))

function pcp_sampler(::Type{F}, params::PCPParams) where {F<:GF2k}
    F == GF2048 && _pcp_parameter_tuple(params) == _TB2_PCP_PARAMETER_TUPLE &&
        return _TB2_PCP_SAMPLER
    _build_pcp_sampler(F, params)
end

function pcp_register_dimensions(sampler::TypedSampler)
    base = _pcp_base_map(first(values(sampler.left)))
    Dict(key => length(value) for (key, value) in base.layout.registers)
end

function intrinsic_pcp_levels(sampler::TypedSampler)
    Dict(kind => _pcp_stage_depth(_pcp_base_map(sampler.left[kind]).stages)
         for kind in sampler.types)
end

abstract type AbstractPCPQuestion end
struct PCPPointQuestion{F,N} <: AbstractPCPQuestion
    point::NTuple{N,F}
end
struct PCPALineQuestion{F,N} <: AbstractPCPQuestion
    base::NTuple{N,F}
    coordinate::F
end
struct PCPDLineQuestion{F,N} <: AbstractPCPQuestion
    base::NTuple{N,F}
    coordinate::F
    direction::NTuple{N,F}
end

encode_pcp_question(question::PCPPointQuestion) = question.point
encode_pcp_question(question::PCPALineQuestion) = (question.base..., question.coordinate)
encode_pcp_question(question::PCPDLineQuestion) =
    (question.base..., question.coordinate, question.direction...)

function parse_pcp_question(kind::PCPType, raw, params::PCPParams)
    dimension = kind.copy == 6 ? params.m_prime : params.m
    values = Tuple(raw)
    expected = kind.kind == :Point ? dimension :
               kind.kind == :ALine ? dimension + 1 : 2dimension + 1
    length(values) == expected || throw(ArgumentError("PCP question has wrong arity"))
    F = typeof(first(values))
    all(value -> value isa F, values) || throw(ArgumentError("PCP question mixes fields"))
    field_size(F) == params.q || throw(ArgumentError("PCP question has wrong field"))
    point = ntuple(i -> values[i], dimension)
    kind.kind == :Point && return PCPPointQuestion(point)
    coordinate = values[dimension + 1]
    kind.kind == :ALine && return PCPALineQuestion(point, coordinate)
    direction = ntuple(i -> values[dimension + 1 + i], dimension)
    PCPDLineQuestion(point, coordinate, direction)
end

function sample_pcp_question(sampler::TypedSampler, kind::PCPType, seed)
    ambient = apply(sampler.left[kind], seed)
    base = _pcp_base_map(sampler.left[kind])
    layout = base.layout
    point_indices = layout.registers[(kind.copy, :pt)]
    dimension = length(point_indices)
    point = ntuple(i -> ambient[point_indices[i]], dimension)
    kind.kind == :Point && return PCPPointQuestion(point)
    coordinate_index = kind.copy == 6 ? layout.auxiliary_coordinate :
                                        only(layout.registers[(kind.copy, :coord)])
    coordinate = ambient[coordinate_index]
    kind.kind == :ALine && return PCPALineQuestion(point, coordinate)
    direction_indices = layout.registers[(kind.copy, :dir)]
    direction = ntuple(i -> ambient[direction_indices[i]], dimension)
    PCPDLineQuestion(point, coordinate, direction)
end

function _pcp_answer_count(kind::PCPType, params::PCPParams)
    kind.copy == 6 ? params.m_prime + 6 : 1
end

_pcp_line_answer_entry(::Any, ::Int) = false
_pcp_line_answer_entry(::Poly{F,1}, q::Int) where {F<:GF2k} = field_size(F) == q

function parse_pcp_answer(kind::PCPType, raw, params::PCPParams)
    entries = Tuple(raw)
    length(entries) == _pcp_answer_count(kind, params) ||
        throw(ArgumentError("PCP answer has wrong arity"))
    if kind.kind == :Point
        all(value -> value isa GF2k && field_size(typeof(value)) == params.q,
            entries) || throw(ArgumentError("point answer has wrong field"))
    else
        all(poly -> _pcp_line_answer_entry(poly, params.q), entries) ||
            throw(ArgumentError("line answer has wrong polynomial field"))
    end
    entries
end

# Encoding is deliberately a shape-preserving transcription of table:tpcp.
function encode_pcp_answer(kind::PCPType, answer, params::PCPParams)
    parse_pcp_answer(kind, answer, params)
end

function pcp_ld_question(question::PCPPointQuestion{F,N}) where {F,N}
    (question.point..., zero(F), ntuple(_ -> zero(F), N)...)
end
function pcp_ld_question(question::PCPALineQuestion{F,N}) where {F,N}
    (question.base..., question.coordinate, ntuple(_ -> zero(F), N)...)
end
pcp_ld_question(question::PCPDLineQuestion) =
    (question.base..., question.coordinate, question.direction...)

function _tb2_zero_parser_answer(kind::PCPType)
    count = kind.copy == 6 ? 22 : 1
    if kind.kind == :Point
        return ntuple(_ -> zero(GF2048), count)
    end
    layout = VarLayout((:t,), (VarBlock(:LineParameter, 1:1),))
    polynomial = zero_poly(GF2048, layout)
    ntuple(_ -> polynomial, count)
end

"One precompilable traversal asserting all table:tpcp parser shapes."
function _compute_tb2_parser_roundtrip_report()
    sampler = _TB2_PCP_SAMPLER.term
    params = PCPParams(_TB2_PCP_PARAMETER_TUPLE...)
    seed = ntuple(j -> GF2048(13j + 1), seed_dim(sampler))
    questions = 0
    answers = 0
    for kind in sampler.types
        question = sample_pcp_question(sampler, kind, seed)
        parse_pcp_question(kind, encode_pcp_question(question), params) == question &&
            (questions += 1)
        answer = _tb2_zero_parser_answer(kind)
        parse_pcp_answer(kind, encode_pcp_answer(kind, answer, params), params) ==
            answer && (answers += 1)
    end
    (; questions, answers)
end

const _TB2_PARSER_ROUNDTRIP_REPORT = _compute_tb2_parser_roundtrip_report()
tb2_parser_roundtrip_report() = _TB2_PARSER_ROUNDTRIP_REPORT

precompile(tb2_parser_roundtrip_report, ())
const _TB2_PCP_SEED_TYPE = NTuple{38,GF2048}
precompile(apply, (CLStep{GF2048}, _TB2_PCP_SEED_TYPE))
for map in values(_TB2_PCP_SAMPLER.term.left)
    precompile(apply, (typeof(_pcp_base_map(map)), _TB2_PCP_SEED_TYPE))
end
precompile(sample_pcp_question,
           (TypedSampler{GF2048}, PCPType, _TB2_PCP_SEED_TYPE))
for width in (1, 2, 3, 16, 17, 33)
    raw_type = NTuple{width,GF2048}
    precompile(parse_pcp_question, (PCPType, raw_type, PCPParams))
end
for question_type in (PCPPointQuestion{GF2048,1},
                      PCPALineQuestion{GF2048,1},
                      PCPDLineQuestion{GF2048,1},
                      PCPPointQuestion{GF2048,16},
                      PCPALineQuestion{GF2048,16},
                      PCPDLineQuestion{GF2048,16})
    precompile(encode_pcp_question, (question_type,))
end
precompile(parse_pcp_answer, (PCPType, NTuple{1,GF2048}, PCPParams))
precompile(parse_pcp_answer, (PCPType, NTuple{22,GF2048}, PCPParams))
precompile(parse_pcp_answer,
           (PCPType, NTuple{1,Poly{GF2048,1}}, PCPParams))
precompile(parse_pcp_answer,
           (PCPType, NTuple{22,Poly{GF2048,1}}, PCPParams))
