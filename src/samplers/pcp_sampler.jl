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

function _pcp_stage_matrix(::Type{F}, factor, selected=()) where {F}
    matrix = zeros(F, length(factor), length(factor))
    for coordinate in selected
        position = findfirst(==(coordinate), factor)
        position === nothing || (matrix[position, position] = one(F))
    end
    matrix
end

function _pcp_cl_map(::Type{F}, kind::PCPType,
                     layout::PCPRegisterLayout) where {F<:GF2k}
    n = layout.ambient_dimension
    point = layout.registers[(kind.copy, :pt)]
    direction = layout.registers[(kind.copy, :dir)]
    coordinate = kind.copy == 6 ? layout.auxiliary_coordinate :
                                  only(layout.registers[(kind.copy, :coord)])
    complement(excluded) = Tuple(i for i in 1:n if !(i in Set(excluded)))
    tail = CLZero(F, n, ())
    if kind.kind == :Point
        ambient = Tuple(1:n)
        return CLStep(F, n, ambient, (),
                      _pcp_stage_matrix(F, ambient, point), tail)
    end

    point_shape = _clstep(F, n, point, (), _identity_matrix(F, length(point)),
                          tail, _ -> tail; require_ambient=false)
    if kind.kind == :ALine
        first_factor = complement(point)
        first_matrix = _pcp_stage_matrix(F, first_factor, (coordinate,))
        return CLStep(F, n, first_factor, point, first_matrix, point_shape) do output
            s = output[findfirst(==(coordinate), first_factor)]
            axis_direction = ntuple(i -> F(i == chi(s, length(point))),
                                     length(point))
            _clstep(F, n, point, (), L_lnf(axis_direction), tail, _ -> tail;
                    require_ambient=false)
        end
    end

    direction_shape = _clstep(
        F, n, direction, point, _identity_matrix(F, length(direction)),
        point_shape, _ -> point_shape; require_ambient=false)
    first_factor = complement((point..., direction...))
    first_matrix = _pcp_stage_matrix(F, first_factor, (coordinate,))
    CLStep(F, n, first_factor, (direction..., point...), first_matrix,
           direction_shape) do output
        s = output[findfirst(==(coordinate), first_factor)]
        axis = chi(s, length(point))
        projection = zeros(F, length(direction), length(direction))
        for i in axis:length(direction)
            projection[i, i] = one(F)
        end
        _clstep(F, n, direction, point, projection, point_shape,
                projected -> begin
            v_prime = Tuple(projected)
            _clstep(F, n, point, (), L_lnf(v_prime), tail, _ -> tail;
                    require_ambient=false)
        end; require_ambient=false)
    end
end

function _pcp_replay_sampler(subject)
    sampler = hasproperty(subject, :pcp_sampler) ? subject.pcp_sampler : subject
    types_ok = length(sampler.types) == 18 &&
               Set(sampler.types) == Set(PCPType(kind, i)
                                         for kind in _PCP_KINDS for i in 1:6)
    graph_ok = length(sampler.type_graph) == 18^2 &&
               Set(sampler.type_graph) == Set((a, b) for a in sampler.types
                                                     for b in sampler.types)
    layout = sampler.metadata.pcp_layout
    dimensions = Dict(key => length(value)
                      for (key, value) in layout.registers)
    dimensions_ok = all(dimensions[(i, :pt)] == layout.m &&
                        dimensions[(i, :coord)] == 1 &&
                        dimensions[(i, :dir)] == layout.m for i in 1:5) &&
                    dimensions[(6, :pt)] == layout.m_prime &&
                    dimensions[(6, :coord)] == 6 &&
                    dimensions[(6, :dir)] == layout.m_prime
    CheckResult(types_ok && graph_ok && level(sampler) == 3 && dimensions_ok,
                :pcp_sampler_shape;
                expected=(types=18, edges=324, level=3,
                          copy6=(layout.m_prime, 6, layout.m_prime)),
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
    intrinsic = Dict{PCPType,Int}()
    for kind in types
        maps[kind] = _pcp_cl_map(F, kind, layout)
        intrinsic[kind] = level(maps[kind])
    end
    graph = Tuple((left, right) for left in types for right in types)
    sampler = TypedSampler(types, graph, maps, maps;
                           metadata=(pcp_layout=layout,
                                     intrinsic_levels=intrinsic))
    source_repair = CertNode(SOURCE_REPAIR, :PCPCopy6CoordinateScalar;
        facts=(display="dim V_{6,coord}=6; table:tpcp exposes one scalar; chi reads V_aux,coord and the other five coordinates are zeroed/ignored",))
    constructed = CertNode(CONSTRUCTED, :PCPCLDatatype;
        facts=(display="intrinsic levels Point/ALine/DLine=1/2/3; padded common level=3",))
    root = CertNode(CHECKED, :TypedPCPSampler;
        facts=(display="18 types; complete 18^2 graph; V6 dimensions ($(params.m_prime),6,$(params.m_prime))",),
        children=(constructed, source_repair), replay=_pcp_replay_sampler)
    Checked(sampler, root)
end

function pcp_sampler(::Type{F}, params::PCPParams) where {F<:GF2k}
    _build_pcp_sampler(F, params)
end

function pcp_register_dimensions(sampler::TypedSampler)
    layout = sampler.metadata.pcp_layout
    Dict(key => length(value) for (key, value) in layout.registers)
end

function intrinsic_pcp_levels(sampler::TypedSampler)
    sampler.metadata.intrinsic_levels
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
    layout = sampler.metadata.pcp_layout
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

"A lazy traversal asserting all table:tpcp parser shapes."
function _compute_tb2_parser_roundtrip_report()
    params = PCPParams(2048, 11, 1, 11, 6, 16, 1)
    sampler = pcp_sampler(GF2048, params).term
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

tb2_parser_roundtrip_report() = _compute_tb2_parser_roundtrip_report()

precompile(tb2_parser_roundtrip_report, ())
const _TB2_PCP_SEED_TYPE = NTuple{38,GF2048}
precompile(apply, (CLStep{GF2048}, _TB2_PCP_SEED_TYPE))
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
