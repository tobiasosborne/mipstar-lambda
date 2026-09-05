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
function L_lnf(v::AbstractVector{F}) where {F}
    N = length(v)
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

L_lnf(v::NTuple{N,F}) where {N,F} = L_lnf(collect(v))

function L_lnf(v::NTuple{N,F}, u::NTuple{N,F}) where {N,F}
    output = _matvec(L_lnf(collect(v)), collect(u))
    ntuple(i -> output[i], Val(N))
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

function _projector_matrix(::Type{F}, n::Int, selected) where {F}
    matrix = zeros(F, n, n)
    for i in selected
        matrix[i, i] = one(F)
    end
    matrix
end

function _build_L_Point(::Type{F}, m::Integer) where {F<:GF2k}
    # eq:cl-ptf (gt-07-ldt.tex:203-207): the 1-level CL function that
    # projects onto V_pt. Its single factor space is the whole ambient V
    # (lem:cl-kth enu:cl-space-sum, gt-04-cl.tex:151-160; verdicts/tb1-r2.md N3).
    dimension = Int(m)
    dimension > 0 || throw(ArgumentError("m must be positive"))
    n = 2dimension + 1
    ambient = collect(1:n)
    CLStep(F, n, ambient, Int[], _projector_matrix(F, n, 1:dimension),
           CLZero(F, n, Int[]))
end

function _build_L_ALine(::Type{F}, m::Integer) where {F<:GF2k}
    # eq:cl-alnf/eq:chi-func and lem:alnf (gt-07-ldt.tex:208-228,243-257).
    dimension = Int(m)
    q = field_size(F)
    q % dimension == 0 || throw(ArgumentError("m must divide q"))
    n = 2dimension + 1
    point = collect(1:dimension)
    coordinate_direction = collect(dimension+1:n)
    first_matrix = zeros(F, dimension + 1, dimension + 1)
    first_matrix[1, 1] = one(F)
    tail = CLZero(F, n, Int[])
    point_shape = _clstep(F, n, point, Int[], _identity_matrix(F, dimension),
                          tail, BranchConst(tail); require_ambient=false)
    # Stage 2 at axis i applies L_lnf(e_i) on V_pt; the coordinate s sits at
    # position 1 of the stage-1 value (coordinate_direction[1] == m+1).
    table = AbstractCL{F}[
        _clstep(F, n, point, Int[], L_lnf(F[F(j == axis) for j in 1:dimension]),
                tail, BranchConst(tail); require_ambient=false)
        for axis in 1:dimension]
    CLStep(F, n, coordinate_direction, point, first_matrix, point_shape,
           BranchByAxis(dimension, 1, table))
end

function _build_L_DLine(::Type{F}, m::Integer) where {F<:GF2k}
    # eq:cl-dlnf and lem:dlnf (gt-07-ldt.tex:230-237,261-272).
    dimension = Int(m)
    q = field_size(F)
    q % dimension == 0 || throw(ArgumentError("m must divide q"))
    n = 2dimension + 1
    point = collect(1:dimension)
    coordinate = [dimension + 1]
    direction = collect(dimension+2:n)
    tail = CLZero(F, n, Int[])
    point_shape = _clstep(F, n, point, Int[], _identity_matrix(F, dimension),
                          tail, BranchConst(tail); require_ambient=false)
    direction_shape = _clstep(F, n, direction, point,
                              _identity_matrix(F, dimension), point_shape,
                              BranchConst(point_shape); require_ambient=false)
    # Stage 2 at axis i projects the direction by pi_{i-1}; stage 3 applies
    # L_lnf(v') on V_pt for the projected direction v' (BranchLnf).
    table = AbstractCL{F}[]
    for axis in 1:dimension
        projection = zeros(F, dimension, dimension)
        for j in axis:dimension
            projection[j, j] = one(F)
        end
        push!(table, _clstep(F, n, direction, point, projection, point_shape,
                             BranchLnf(n, point, tail); require_ambient=false))
    end
    CLStep(F, n, coordinate, vcat(direction, point), reshape([one(F)], 1, 1),
           direction_shape, BranchByAxis(dimension, 1, table))
end

L_Point(::Type{F}, m::Integer) where {F<:GF2k} = _build_L_Point(F, m)
L_ALine(::Type{F}, m::Integer) where {F<:GF2k} = _build_L_ALine(F, m)
L_DLine(::Type{F}, m::Integer) where {F<:GF2k} = _build_L_DLine(F, m)

function _replay_diagonal_histogram(comparison)
    actual = comparison.actual
    reference = comparison.reference
    CheckResult(actual == reference, :ld_diagonal_histogram;
                expected=(support=length(reference), mass=sum(values(reference))),
                actual=(support=length(actual), mass=sum(values(actual))))
end

"Replayable TB1 histogram evidence with the zero-direction source repair attached."
function diagonal_histogram_evidence(actual::AbstractDict,
                                     reference::AbstractDict, m::Integer)
    dimension = Int(m)
    zero_entries = filter(collect(actual)) do entry
        raw = first(entry)[1]
        all(iszero, raw[dimension+2:2dimension+1])
    end
    repair = CertNode(SOURCE_REPAIR, :ld_lnf_zero_direction;
        facts=(support=length(zero_entries),
               mass=sum(last, zero_entries), of=sum(values(actual))))
    root = CertNode(CHECKED, :ld_diagonal_histogram;
        facts=(support=length(actual), mass=sum(values(actual))),
        children=(repair,), replay=_replay_diagonal_histogram)
    Checked((actual=actual, reference=reference), root)
end

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
precompile(L_lnf, (Vector{GF8},))
precompile(L_lnf, (Vector{GF2048},))
precompile(axis_line, (NTuple{5,GF8}, Int))
precompile(diagonal_line, (NTuple{5,GF8}, Int))
precompile(line_point, (AffineLine{GF8,2}, GF8))
