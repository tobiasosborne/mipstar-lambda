"Canonical line representation from def:line-representative."
struct AffineLine{F,N}
    base::NTuple{N,F}
    direction::NTuple{N,F}
end

function _identity_matrix(::Type{F}, n::Int) where {F}
    matrix = zeros(F, n, n)
    for i in 1:n
        matrix[i, i] = one(F)
    end
    matrix
end

"The canonical projection with kernel span(v), or identity for v=0."
function L_lnf(v::NTuple{N,F}) where {N,F}
    matrix = _identity_matrix(F, N)
    pivot = findfirst(!iszero, v)
    # SOURCE_REPAIR: def:line allows v=0 (gt-07-ldt.tex:106-116), while
    # def:cl-canonical requires an independent kernel basis. DESIGN DD-7
    # totalizes the singleton-line case by the identity.
    pivot === nothing && return matrix

    # def:canonical-complement/def:cl-canonical (gt-03-prelim.tex:306-320,
    # 375-384): RREF of the one-row basis v pivots at its first nonzero
    # coordinate; project onto the span of all other standard basis vectors.
    inverse_pivot = inv(v[pivot])
    for row in 1:N
        matrix[row, pivot] -= v[row] * inverse_pivot
    end
    matrix
end

function L_lnf(v::NTuple{N,F}, u::NTuple{N,F}) where {N,F}
    _matvec(L_lnf(v), u)
end

function chi(s::F, m::Integer) where {F<:GF2k}
    dimension = Int(m)
    q = field_size(F)
    dimension > 0 || throw(ArgumentError("m must be positive"))
    q % dimension == 0 || throw(ArgumentError("m must divide q"))
    1 + div(Int(s.bits), q ÷ dimension)
end

function pi_prefix(v::NTuple{N,F}, count::Integer) where {N,F}
    prefix = Int(count)
    0 <= prefix <= N || throw(ArgumentError("prefix length out of range"))
    ntuple(i -> i <= prefix ? zero(F) : v[i], N)
end

function _build_L_Point(::Type{F}, m::Integer) where {F<:GF2k}
    # eq:cl-ptf (gt-07-ldt.tex:203-207).
    dimension = Int(m)
    dimension > 0 || throw(ArgumentError("m must be positive"))
    n = 2dimension + 1
    point = Tuple(1:dimension)
    rest = Tuple(dimension+1:n)
    tail = CLZero(F, n, rest)
    CLStep(F, n, point, rest, _identity_matrix(F, dimension), tail)
end

function _build_L_ALine(::Type{F}, m::Integer) where {F<:GF2k}
    # eq:cl-alnf/eq:chi-func and lem:alnf (gt-07-ldt.tex:208-228,243-257).
    dimension = Int(m)
    q = field_size(F)
    q % dimension == 0 || throw(ArgumentError("m must divide q"))
    n = 2dimension + 1
    point = Tuple(1:dimension)
    coordinate_direction = Tuple(dimension+1:n)
    first_matrix = zeros(F, dimension + 1, dimension + 1)
    first_matrix[1, 1] = one(F)
    axis_cache = Dict{Int,AbstractCL{F}}()
    CLStep(F, n, coordinate_direction, point, first_matrix) do output
        s = output[1]
        axis = chi(s, dimension)
        get!(axis_cache, axis) do
            e_i = ntuple(j -> F(j == axis), dimension)
            tail = CLZero(F, n, ())
            CLStep(F, n, point, (), L_lnf(e_i), tail)
        end
    end
end

function _build_L_DLine(::Type{F}, m::Integer) where {F<:GF2k}
    # eq:cl-dlnf and lem:dlnf (gt-07-ldt.tex:230-237,261-272).
    dimension = Int(m)
    q = field_size(F)
    q % dimension == 0 || throw(ArgumentError("m must divide q"))
    n = 2dimension + 1
    point = Tuple(1:dimension)
    coordinate = (dimension + 1,)
    direction = Tuple(dimension+2:n)
    direction_cache = Dict{Int,AbstractCL{F}}()
    CLStep(F, n, coordinate, (direction..., point...),
           reshape([one(F)], 1, 1)) do coordinate_output
        s = coordinate_output[1]
        axis = chi(s, dimension)
        get!(direction_cache, axis) do
            projection = zeros(F, dimension, dimension)
            for j in axis:dimension
                projection[j, j] = one(F)
            end
            CLStep(F, n, direction, point, projection) do direction_output
                v_prime = Tuple(direction_output)
                tail = CLZero(F, n, ())
                CLStep(F, n, point, (), L_lnf(v_prime), tail)
            end
        end
    end
end

# The exhaustive TB1 fixture requests these immutable sampler trees repeatedly.
# Constructing them once also avoids charging branch-table construction to each
# test section; all other parameter pairs still use the same builders.
const _TB1_POINT_SAMPLER = _build_L_Point(GF8, 2)
const _TB1_AXIS_SAMPLER = _build_L_ALine(GF8, 2)
const _TB1_DIAGONAL_SAMPLER = _build_L_DLine(GF8, 2)

L_Point(::Type{GF8}, m::Integer) =
    Int(m) == 2 ? _TB1_POINT_SAMPLER : _build_L_Point(GF8, m)
L_ALine(::Type{GF8}, m::Integer) =
    Int(m) == 2 ? _TB1_AXIS_SAMPLER : _build_L_ALine(GF8, m)
L_DLine(::Type{GF8}, m::Integer) =
    Int(m) == 2 ? _TB1_DIAGONAL_SAMPLER : _build_L_DLine(GF8, m)
L_Point(::Type{F}, m::Integer) where {F<:GF2k} = _build_L_Point(F, m)
L_ALine(::Type{F}, m::Integer) where {F<:GF2k} = _build_L_ALine(F, m)
L_DLine(::Type{F}, m::Integer) where {F<:GF2k} = _build_L_DLine(F, m)

function _raw_question(raw, m::Int)
    length(raw) == 2m + 1 || throw(ArgumentError("low-degree question has wrong dimension"))
    Tuple(raw)
end

function point_value(raw, m::Integer)
    dimension = Int(m)
    question = _raw_question(raw, dimension)
    ntuple(i -> question[i], dimension)
end

function axis_line(raw, m::Integer)
    dimension = Int(m)
    question = _raw_question(raw, dimension)
    F = typeof(question[1])
    s = question[dimension + 1]
    axis = chi(s, dimension)
    direction = ntuple(j -> F(j == axis), dimension)
    AffineLine(ntuple(j -> question[j], dimension), direction)
end

function diagonal_line(raw, m::Integer)
    dimension = Int(m)
    question = _raw_question(raw, dimension)
    s = question[dimension + 1]
    axis = chi(s, dimension)
    direction = ntuple(j -> question[dimension + 1 + j], dimension)
    AffineLine(ntuple(j -> question[j], dimension),
               pi_prefix(direction, axis - 1))
end

function line_point(line::AffineLine{F,N}, t::F) where {F,N}
    ntuple(i -> line.base[i] + t * line.direction[i], N)
end


precompile(L_Point, (Type{GF8}, Int))
precompile(L_ALine, (Type{GF8}, Int))
precompile(L_DLine, (Type{GF8}, Int))
precompile(L_lnf, (NTuple{2,GF8},))
precompile(axis_line, (NTuple{5,GF8}, Int))
precompile(diagonal_line, (NTuple{5,GF8}, Int))
precompile(line_point, (AffineLine{GF8,2}, GF8))
