abstract type AbstractCL{F} end

# A continuation selector for one CLStep (DESIGN 1.5 / 9.3). The lazily
# evaluated branch is a function of the previous stage's value only. A
# QuotedBranch is a named pure constructor with canonical captured data and is
# serializable by `describe_cl`; an OpaqueBranch wraps an arbitrary host
# closure, remains usable in memory, and is never describable.
abstract type AbstractBranch end
abstract type QuotedBranch <: AbstractBranch end

"Opaque host closure: allowed in memory, `describe_cl` returns NotDescribable."
struct OpaqueBranch <: AbstractBranch
    f::Function
end

"The continuation is the same CL value for every stage value."
struct BranchConst{F} <: QuotedBranch
    child::AbstractCL{F}
end

"Select `table[chi(value[position], m)]` (eq:chi-func, gt-07-ldt.tex:216-223)."
struct BranchByAxis{F} <: QuotedBranch
    m::Int
    position::Int
    table::Vector{AbstractCL{F}}
    function BranchByAxis(m::Integer, position::Integer,
                          table::AbstractVector{<:AbstractCL{F}}) where {F}
        length(table) == Int(m) ||
            throw(ArgumentError("BranchByAxis needs one continuation per axis"))
        1 <= Int(position) || throw(ArgumentError("BranchByAxis position out of range"))
        new{F}(Int(m), Int(position), AbstractCL{F}[table...])
    end
end

"Map a direction value v' to the one-stage point map L_lnf(v') on `point`."
struct BranchLnf{F} <: QuotedBranch
    seed_dim::Int
    point::Vector{Int}
    tail::AbstractCL{F}
end

"The unique zero-level CL function on the listed coordinate-index register."
struct CLZero{F} <: AbstractCL{F}
    seed_dim::Int
    indices::Vector{Int}
end

"One inductive CL stage followed by an on-demand conditional continuation."
struct CLStep{F} <: AbstractCL{F}
    seed_dim::Int
    factor::Vector{Int}
    rest::Vector{Int}
    matrix::Matrix{F}
    # `child_shape` is an actual nested witness, so the level is constructed
    # by datatype depth. `branch` is evaluated only for values reached by
    # apply/marginal_k/walks; encountered children are memoised after
    # validation (`_child` checks field, seed dimension, rest register and
    # child level) in a memo bounded by CL_MEMO_LIMIT entries per node.
    # Registers are `Vector{Int}` and stage values `Vector{F}` on purpose:
    # one `CLStep{F}` type and one specialization per operation, instead of
    # one per closure type and per register width (TB2 has widths 1..40),
    # which cost ~60 s of runtime compilation per test process.
    child_shape::AbstractCL{F}
    branch::AbstractBranch
    children::Dict{Vector{F},AbstractCL{F}}
end

"Append `extra` empty stages below every continuation of `inner` (DESIGN 9.4)."
struct BranchPadded <: QuotedBranch
    inner::CLStep
    extra::Int
end

# The memo of a stage is bounded because DESIGN 9.1's `Linear` prefix domain is
# all of V_{<j}, not the reachable image; once full, the memo is cleared.
const CL_MEMO_LIMIT = 4096

function _coordinate_indices(seed_dimension::Int, indices, name)
    result = Int[Int(i) for i in indices]
    allunique(result) ||
        throw(ArgumentError("$name contains duplicate coordinates"))
    all(i -> 1 <= i <= seed_dimension, result) ||
        throw(ArgumentError("$name coordinate out of range"))
    result
end

function CLZero(::Type{F}, seed_dimension::Integer,
                indices=1:Int(seed_dimension)) where {F}
    n = Int(seed_dimension)
    n >= 0 || throw(ArgumentError("seed dimension must be nonnegative"))
    CLZero{F}(n, _coordinate_indices(n, indices, "zero register"))
end

seed_dim(L::AbstractCL) = L.seed_dim
_register(L::CLZero) = sort(L.indices)
_register(L::CLStep) = sort(vcat(L.factor, L.rest))
register_indices(L::AbstractCL) = Tuple(_register(L))

level(::CLZero) = 0
level(L::CLStep) = 1 + level(L.child_shape)

function _matvec(matrix::AbstractMatrix{F}, input::AbstractVector) where {F}
    rows, columns = size(matrix)
    output = fill(zero(F), rows)
    for row in 1:rows
        total = zero(F)
        for column in 1:columns
            total += matrix[row, column] * input[column]
        end
        output[row] = total
    end
    output
end

_as_branch(branch::AbstractBranch) = branch
_as_branch(branch::Function) = OpaqueBranch(branch)
_as_branch(branch) =
    throw(ArgumentError("CL continuation must be a QuotedBranch or a function of the stage value"))

function _clstep(::Type{F}, seed_dimension::Integer, factor, rest,
                 matrix::AbstractMatrix, child_shape::AbstractCL{F},
                 branch; require_ambient::Bool) where {F}
    n = Int(seed_dimension)
    factor_indices = _coordinate_indices(n, factor, "factor register")
    rest_indices = _coordinate_indices(n, rest, "rest register")
    isempty(intersect(factor_indices, rest_indices)) ||
        throw(ArgumentError("factor and rest registers overlap"))
    if require_ambient
        sort(vcat(factor_indices, rest_indices)) == 1:n ||
            throw(ArgumentError("factor and rest registers must span the ambient basis"))
    end
    A = Matrix{F}(matrix)
    size(A) == (length(factor_indices), length(factor_indices)) ||
        throw(ArgumentError("stage matrix must act within its factor register"))
    seed_dim(child_shape) == n ||
        throw(ArgumentError("CL child shape seed dimension changed"))
    _register(child_shape) == sort(rest_indices) ||
        throw(ArgumentError("CL child shape must occupy exactly the rest register"))
    CLStep{F}(n, factor_indices, rest_indices, A, child_shape, _as_branch(branch),
              Dict{Vector{F},AbstractCL{F}}())
end

function CLStep(branch::Function, ::Type{F}, seed_dimension::Integer,
                factor, rest, matrix::AbstractMatrix,
                child_shape::AbstractCL{F}) where {F}
    _clstep(F, seed_dimension, factor, rest, matrix, child_shape, OpaqueBranch(branch);
            require_ambient=true)
end

function CLStep(::Type{F}, seed_dimension::Integer, factor, rest,
                matrix::AbstractMatrix, child::AbstractCL{F}) where {F}
    _clstep(F, seed_dimension, factor, rest, matrix, child, BranchConst(child);
            require_ambient=true)
end

function CLStep(::Type{F}, seed_dimension::Integer, factor, rest,
                matrix::AbstractMatrix, child_shape::AbstractCL{F},
                branch::QuotedBranch) where {F}
    _clstep(F, seed_dimension, factor, rest, matrix, child_shape, branch;
            require_ambient=true)
end

_select(branch::OpaqueBranch, key) = branch.f(key)
_select(branch::BranchConst, key) = branch.child
function _select(branch::BranchByAxis{F}, key::Vector{F}) where {F}
    branch.position <= length(key) ||
        throw(ArgumentError("BranchByAxis position exceeds the stage value"))
    branch.table[chi(key[branch.position], branch.m)]
end
function _select(branch::BranchLnf{F}, key::Vector{F}) where {F}
    length(key) == length(branch.point) ||
        throw(ArgumentError("BranchLnf direction and point registers differ in width"))
    _clstep(F, branch.seed_dim, branch.point, Int[], L_lnf(key), branch.tail,
            BranchConst(branch.tail); require_ambient=false)
end
_select(branch::BranchPadded, key) = _pad_tail(_child(branch.inner, key), branch.extra)

function _child(L::CLStep{F}, key::Vector{F}) where {F}
    cached = get(L.children, key, nothing)
    cached === nothing || return cached
    child = _select(L.branch, key)
    child isa AbstractCL{F} ||
        throw(ArgumentError("every CL continuation must have the same field"))
    seed_dim(child) == L.seed_dim ||
        throw(ArgumentError("CL continuation seed dimension changed"))
    _register(child) == sort(L.rest) ||
        throw(ArgumentError("CL continuation must occupy exactly the rest register"))
    level(child) == level(L.child_shape) ||
        throw(ArgumentError("all CL continuations must have the constructed child level"))
    length(L.children) >= CL_MEMO_LIMIT && empty!(L.children)
    L.children[key] = child
    child
end

"Count the memoised continuations reachable from `L` (bounded by CL_MEMO_LIMIT per node)."
function memo_report(L::AbstractCL)
    seen = IdDict{Any,Nothing}()
    nodes = 0
    entries = 0
    max_entries = 0
    stack = AbstractCL[L]
    while !isempty(stack)
        node = pop!(stack)
        haskey(seen, node) && continue
        seen[node] = nothing
        node isa CLStep || continue
        nodes += 1
        count = length(node.children)
        entries += count
        max_entries = max(max_entries, count)
        append!(stack, values(node.children))
    end
    (; nodes, entries, max_entries, limit=CL_MEMO_LIMIT)
end

function _stage_output(L::CLStep{F}, seed) where {F}
    input = F[convert(F, seed[j]) for j in L.factor]
    local_output = _matvec(L.matrix, input)
    full = fill(zero(F), L.seed_dim)
    for (coordinate, value) in zip(L.factor, local_output)
        full[coordinate] = value
    end
    full, local_output
end

function _check_seed(L::AbstractCL, seed)
    length(seed) == seed_dim(L) || throw(ArgumentError("seed has wrong dimension"))
    nothing
end

# Outputs are tuples at the public boundary, typed by the seed's length.
_as_tuple(values::Vector, ::NTuple{N,Any}) where {N} = ntuple(i -> values[i], Val(N))
_as_tuple(values::Vector, seed) = Tuple(values)

_apply_vector(L::CLZero{F}, seed) where {F} = fill(zero(F), L.seed_dim)

function _apply_vector(L::CLStep{F}, seed) where {F}
    stage, key = _stage_output(L, seed)
    tail = _apply_vector(_child(L, key), seed)
    for i in eachindex(stage)
        stage[i] += tail[i]
    end
    stage
end

function apply(L::AbstractCL, seed)
    _check_seed(L, seed)
    _as_tuple(_apply_vector(L, seed), seed)
end

struct CLMarginal{F}
    seed_dim::Int
    outputs::Vector{Tuple}
    factor_spaces::Vector{Vector{Int}}
    linear_maps::Vector{Matrix{F}}
    value::Tuple
end

function sum_stage_outputs(marginal::CLMarginal{F}) where {F}
    total = fill(zero(F), marginal.seed_dim)
    for output in marginal.outputs, i in 1:marginal.seed_dim
        total[i] += output[i]
    end
    Tuple(total)
end

function marginal_k(L::AbstractCL{F}, seed, k::Integer) where {F}
    # lem:cl-kth item 3 (gt-04-cl.tex:150-178): the kth marginal is
    # the sum of the first k stage outputs, with their factor maps retained.
    _check_seed(L, seed)
    count = Int(k)
    0 <= count <= level(L) || throw(ArgumentError("marginal index out of range"))
    outputs = Tuple[]
    factors = Vector{Int}[]
    maps = Matrix{F}[]
    total = fill(zero(F), seed_dim(L))
    current = L
    for _ in 1:count
        current isa CLStep{F} || error("malformed CL level")
        stage, key = _stage_output(current, seed)
        push!(outputs, _as_tuple(stage, seed))
        push!(factors, copy(current.factor))
        push!(maps, current.matrix)
        for i in eachindex(total)
            total[i] += stage[i]
        end
        current = _child(current, key)
    end
    CLMarginal{F}(seed_dim(L), outputs, factors, maps, _as_tuple(total, seed))
end

# ---------------------------------------------------------------------------
# def:sampler's four query variants (gt-04-cl.tex:572-601; DESIGN 9.1) on the
# in-memory datatype. `Dimension` is `seed_dim`; `Marginal` walks the first j
# stages of one seed; `Factor` and `Linear` are PREFIX-addressed: they descend
# stage by stage, keying each stage by the prefix restricted to that stage's
# factor register. `Factor(L,j,u)` requires u in L_{<j}(V) (each stage key
# must lie in the image of that stage's matrix); `Linear(L,j,u,y)` accepts the
# broader u in V_{<j} (supported on the walked factor registers, reachable or
# not) and is never narrowed to reachable marginal values. Illegal calls throw
# ArgumentError; a description adapter maps that to QueryError.

Dimension(L::AbstractCL) = seed_dim(L)

function Marginal(L::AbstractCL{F}, j::Integer, z) where {F}
    marginal_k(L, z, j).value
end

function _in_column_space(A::Matrix{F}, b::Vector{F}) where {F}
    rows, columns = size(A)
    M = hcat(A, b)
    pivot_row = 1
    for column in 1:columns
        pivot_row > rows && break
        found = findfirst(r -> !iszero(M[r, column]), pivot_row:rows)
        found === nothing && continue
        p = found + pivot_row - 1
        if p != pivot_row
            M[p, :], M[pivot_row, :] = M[pivot_row, :], M[p, :]
        end
        scale = inv(M[pivot_row, column])
        for c in 1:columns+1
            M[pivot_row, c] *= scale
        end
        for r in 1:rows
            (r == pivot_row || iszero(M[r, column])) && continue
            f = M[r, column]
            for c in 1:columns+1
                M[r, c] -= f * M[pivot_row, c]
            end
        end
        pivot_row += 1
    end
    all(r -> !(all(iszero, M[r, 1:columns]) && !iszero(M[r, columns+1])), 1:rows)
end

function _walk_prefix(L::AbstractCL{F}, j::Int, u::Vector{F};
                      reachable::Bool) where {F}
    1 <= j <= level(L) || throw(ArgumentError("stage index out of range"))
    length(u) == seed_dim(L) || throw(ArgumentError("prefix has wrong dimension"))
    walked = falses(seed_dim(L))
    current = L
    for _ in 1:j-1
        step = current::CLStep{F}
        key = F[u[c] for c in step.factor]
        if reachable
            _in_column_space(step.matrix, key) ||
                throw(ArgumentError("Factor prefix is not a reachable marginal L_{<j}(V)"))
        end
        walked[step.factor] .= true
        current = _child(step, key)
    end
    for c in 1:seed_dim(L)
        walked[c] || iszero(u[c]) ||
            throw(ArgumentError("prefix has support outside V_{<j}"))
    end
    current::CLStep{F}
end

_prefix_vector(::Type{F}, u) where {F} = F[convert(F, x) for x in u]

"Factor(L,j,u): the 0/1 indicator (length Dimension) of the stage-j factor register at prefix u in L_{<j}(V)."
function Factor(L::AbstractCL{F}, j::Integer, u) where {F}
    node = _walk_prefix(L, Int(j), _prefix_vector(F, u); reachable=true)
    indicator = zeros(Int, seed_dim(L))
    for c in node.factor
        indicator[c] = 1
    end
    indicator
end

"Linear(L,j,u,y): the stage-j linear map at prefix u in V_{<j}, applied to the V_j projection of y."
function Linear(L::AbstractCL{F}, j::Integer, u, y) where {F}
    node = _walk_prefix(L, Int(j), _prefix_vector(F, u); reachable=false)
    length(y) == seed_dim(L) || throw(ArgumentError("Linear input has wrong dimension"))
    stage, _ = _stage_output(node, y)
    _as_tuple(stage, y)
end

"""
    cl_kth_replay(L, seeds; chain_set_id)

DESIGN 9.2's replay of lem:cl-kth conditions enu:cl-space-sum and
enu:cl-map-sum (gt-04-cl.tex:151-180) through the four queries only:
prefix_i = Marginal(i-1, x); the Factor indicators at those prefixes must be
disjoint and cover the ambient basis; and for every k, Marginal(k, x) must
equal the sum over i <= k of Linear(i, prefix_i, project(V_i, x)). A chain is
the sequence of stage keys the walk consumed; the report counts distinct
chains, completed replays and the number of k-checks performed.
"""
function cl_kth_replay(L::AbstractCL{F}, seeds; chain_set_id::AbstractString) where {F}
    n = seed_dim(L)
    ell = level(L)
    chains = Set{Vector{Vector{F}}}()
    completed = 0
    map_sum_checks = 0
    space_sum_ok = true
    map_sum_ok = true
    for seed in seeds
        z = _prefix_vector(F, seed)
        prefixes = [collect(Marginal(L, i - 1, z)) for i in 1:ell]
        indicators = [Factor(L, i, prefixes[i]) for i in 1:ell]
        coverage = zeros(Int, n)
        for indicator in indicators
            length(indicator) == n || (space_sum_ok = false)
            coverage .+= indicator
        end
        space_sum_ok &= all(==(1), coverage)
        running = fill(zero(F), n)
        for k in 1:ell
            projected = F[indicators[k][c] == 1 ? z[c] : zero(F) for c in 1:n]
            stage = Linear(L, k, prefixes[k], projected)
            for c in 1:n
                running[c] += stage[c]
            end
            map_sum_ok &= collect(Marginal(L, k, z)) == running
            map_sum_checks += 1
        end
        chain = Vector{F}[F[(prefixes[i+1][c] - prefixes[i][c]) for c in 1:n if indicators[i][c] == 1]
                          for i in 1:ell-1]
        push!(chains, chain)
        completed += 1
    end
    (; chain_set_id=String(chain_set_id), level=ell, dimension=n,
       distinct_chains=length(chains), completed_replays=completed,
       map_sum_checks, space_sum_ok, map_sum_ok)
end

# ---------------------------------------------------------------------------
# DESIGN 9.3: description of a CL value built only from QuotedBranch
# continuations. The canonical term is a nested tuple AST; canonical_bytes is
# its deterministic serialization and description_size its byte length.

struct CLDescription
    field_size::Int
    seed_dim::Int
    level::Int
    term::Any
    bytes::Vector{UInt8}
end

"Result of `describe_cl` on a value whose continuation is an opaque host closure."
struct NotDescribable
    reason::String
    branch::String
end

Base.show(io::IO, result::NotDescribable) =
    print(io, "NotDescribable(", repr(result.reason), ", ", result.branch, ")")

struct _OpaqueBranchError <: Exception
    branch::Any
end

canonical_bytes(description::CLDescription) = description.bytes
description_size(description::CLDescription) = length(description.bytes)

_field_ints(matrix::Matrix{F}) where {F} =
    Int[Int(matrix[r, c].bits) for r in 1:size(matrix, 1) for c in 1:size(matrix, 2)]

_describe_term(L::CLZero) = (:Zero, L.seed_dim, copy(L.indices))
_describe_term(L::CLStep) = (:Step, L.seed_dim, copy(L.factor), copy(L.rest),
                             _field_ints(L.matrix), _describe_branch(L.branch))

_describe_branch(branch::OpaqueBranch) = throw(_OpaqueBranchError(branch))
_describe_branch(branch::BranchConst) = (:Const, _describe_term(branch.child))
_describe_branch(branch::BranchByAxis) =
    (:ByAxis, branch.m, branch.position, Any[_describe_term(child) for child in branch.table])
_describe_branch(branch::BranchLnf) =
    (:Lnf, branch.seed_dim, copy(branch.point), _describe_term(branch.tail))
_describe_branch(branch::BranchPadded) =
    (:Padded, branch.extra, _describe_branch(branch.inner.branch))

const _DESCRIPTION_TAGS = Dict(:Zero => 0x00, :Step => 0x01, :Const => 0x10,
                               :ByAxis => 0x11, :Lnf => 0x12, :Padded => 0x13)

function _encode_int!(buffer::IOBuffer, value::Integer)
    0 <= value <= typemax(UInt32) || throw(ArgumentError("description integer out of range"))
    write(buffer, hton(UInt32(value)))
end

function _encode_indices!(buffer::IOBuffer, indices::Vector{Int})
    _encode_int!(buffer, length(indices))
    for index in indices
        0 <= index <= typemax(UInt16) || throw(ArgumentError("description index out of range"))
        write(buffer, hton(UInt16(index)))
    end
end

function _encode_term!(buffer::IOBuffer, term, field_width::Int)
    tag = term[1]
    write(buffer, _DESCRIPTION_TAGS[tag])
    if tag == :Zero
        _encode_int!(buffer, term[2])
        _encode_indices!(buffer, term[3])
    elseif tag == :Step
        _encode_int!(buffer, term[2])
        _encode_indices!(buffer, term[3])
        _encode_indices!(buffer, term[4])
        _encode_int!(buffer, length(term[5]))
        for entry in term[5]
            for byte in field_width:-1:1
                write(buffer, UInt8((entry >> (8 * (byte - 1))) & 0xff))
            end
        end
        _encode_term!(buffer, term[6], field_width)
    elseif tag == :Const
        _encode_term!(buffer, term[2], field_width)
    elseif tag == :ByAxis
        _encode_int!(buffer, term[2])
        _encode_int!(buffer, term[3])
        _encode_int!(buffer, length(term[4]))
        for child in term[4]
            _encode_term!(buffer, child, field_width)
        end
    elseif tag == :Lnf
        _encode_int!(buffer, term[2])
        _encode_indices!(buffer, term[3])
        _encode_term!(buffer, term[4], field_width)
    elseif tag == :Padded
        _encode_int!(buffer, term[2])
        _encode_term!(buffer, term[3], field_width)
    else
        throw(ArgumentError("unknown description term"))
    end
    buffer
end

"Serialize a CL value built on QuotedBranch continuations; opaque closures give NotDescribable."
function describe_cl(L::AbstractCL{F}) where {F}
    term = try
        _describe_term(L)
    catch error
        error isa _OpaqueBranchError ||
            rethrow()
        return NotDescribable("continuation is an opaque host closure",
                              string(typeof(error.branch.f)))
    end
    q = field_size(F)
    width = cld(round(Int, log2(q)), 8)
    buffer = IOBuffer()
    write(buffer, 0xC1)
    _encode_int!(buffer, q)
    _encode_int!(buffer, seed_dim(L))
    _encode_int!(buffer, level(L))
    _encode_term!(buffer, term, width)
    CLDescription(q, seed_dim(L), level(L), term, take!(buffer))
end

# ---------------------------------------------------------------------------

function _shift_cl(L::CLZero{F}, offset::Int, total::Int) where {F}
    CLZero(F, total, L.indices .+ offset)
end

function _shift_cl(L::CLStep{F}, offset::Int, total::Int) where {F}
    shape = _shift_cl(L.child_shape, offset, total)
    _clstep(F, total, L.factor .+ offset, L.rest .+ offset, L.matrix, shape,
            value -> _shift_cl(_child(L, value), offset, total);
            require_ambient=false)
end

function _combine_embedded(nodes::Vector{AbstractCL{F}}, total::Int) where {F}
    active = findall(node -> node isa CLStep{F}, nodes)
    if isempty(active)
        indices = reduce(vcat, (_register(node) for node in nodes); init=Int[])
        return CLZero(F, total, indices)
    end

    factor = reduce(vcat, ((nodes[i]::CLStep{F}).factor for i in active); init=Int[])
    rest = reduce(vcat, (node isa CLStep{F} ? node.rest : _register(node)
                         for node in nodes); init=Int[])
    matrix = zeros(F, length(factor), length(factor))
    cursor = 0
    for i in active
        node = nodes[i]::CLStep{F}
        width = length(node.factor)
        matrix[cursor+1:cursor+width, cursor+1:cursor+width] .= node.matrix
        cursor += width
    end

    shape_children = AbstractCL{F}[
        node isa CLStep{F} ? node.child_shape : node for node in nodes]
    shape = _combine_embedded(shape_children, total)
    _clstep(F, total, factor, rest, matrix, shape, value -> begin
        children = copy(nodes)
        cursor = 0
        for i in active
            node = nodes[i]::CLStep{F}
            width = length(node.factor)
            children[i] = _child(node, value[cursor+1:cursor+width])
            cursor += width
        end
        _combine_embedded(children, total)
    end; require_ambient=false)
end

function direct_sum(functions::AbstractCL{F}...) where {F}
    # lem:cl-func-prod (gt-04-cl.tex:315-327): levels combine by maximum.
    isempty(functions) && throw(ArgumentError("direct_sum needs at least one CL function"))
    total = sum(seed_dim, functions)
    offset = 0
    embedded = AbstractCL{F}[]
    for L in functions
        push!(embedded, _shift_cl(L, offset, total))
        offset += seed_dim(L)
    end
    _combine_embedded(embedded, total)
end

function _graft_concatenation(L::CLZero{F}, prefix::Vector{F},
                              continuation::Function, right_dim::Int,
                              total::Int) where {F}
    left_zero = _shift_cl(L, 0, total)
    right = continuation(Tuple(prefix))
    right isa AbstractCL{F} ||
        throw(ArgumentError("concatenation branches must have the same field"))
    seed_dim(right) == right_dim ||
        throw(ArgumentError("concatenation branch dimension changed"))
    shifted_right = _shift_cl(right, length(prefix), total)
    _combine_embedded(AbstractCL{F}[left_zero, shifted_right], total)
end

function _graft_concatenation(L::CLStep{F}, prefix::Vector{F},
                              continuation::Function, right_dim::Int,
                              total::Int) where {F}
    rest = vcat(L.rest, collect(seed_dim(L)+1:total))
    shape = _graft_concatenation(L.child_shape, copy(prefix), continuation,
                                 right_dim, total)
    _clstep(F, total, L.factor, rest, L.matrix, shape, value -> begin
        next_prefix = copy(prefix)
        for (coordinate, entry) in zip(L.factor, value)
            next_prefix[coordinate] += entry
        end
        _graft_concatenation(_child(L, value), next_prefix, continuation,
                             right_dim, total)
    end; require_ambient=false)
end

function concatenate(L::AbstractCL{F}, continuation::Function) where {F}
    # lem:cl-concat (gt-04-cl.tex:282-292): conditional concatenation adds levels.
    zero_seed = ntuple(_ -> zero(F), seed_dim(L))
    first_right = continuation(apply(L, zero_seed))
    first_right isa AbstractCL{F} ||
        throw(ArgumentError("concatenation branches must be CL functions"))
    right_dim = seed_dim(first_right)
    total = seed_dim(L) + right_dim
    prefix = fill(zero(F), seed_dim(L))
    _graft_concatenation(L, prefix, continuation, right_dim, total)
end

concatenate(L::AbstractCL, R::AbstractCL) = concatenate(L, _ -> R)

struct CLDistribution{F}
    left::AbstractCL{F}
    right::AbstractCL{F}
end

function distribution(left::AbstractCL{F}, right::AbstractCL{F}) where {F}
    # def:cl-dist (gt-04-cl.tex:132-138): both maps receive one uniform seed.
    seed_dim(left) == seed_dim(right) ||
        throw(ArgumentError("a CL distribution pushes one shared seed dimension"))
    CLDistribution{F}(left, right)
end

function enumerate_seeds(::Type{F}, dimension::Integer;
                         elements=Tuple(field_elements(F))) where {F}
    n = Int(dimension)
    n >= 0 || throw(ArgumentError("seed dimension must be nonnegative"))
    values = Tuple(elements)
    n == 0 ? ((),) : Iterators.product(ntuple(_ -> values, n)...)
end

function histogram(dist::CLDistribution, seeds)
    counts = Dict{Any,Int}()
    for seed in seeds
        key = (apply(dist.left, seed), apply(dist.right, seed))
        counts[key] = get(counts, key, 0) + 1
    end
    counts
end

function product(left::CLDistribution{F}, right::CLDistribution{F}) where {F}
    distribution(direct_sum(left.left, right.left),
                 direct_sum(left.right, right.right))
end

# TB1's exhaustive loop should measure the sampler rather than first-call JIT.
for F in (GF8, GF2048), seed_type in (NTuple{5,GF8}, NTuple{2,GF2048},
                                       NTuple{38,GF2048}, NTuple{40,GF2048})
    F == eltype(seed_type) || continue
    precompile(apply, (CLStep{F}, seed_type))
    precompile(apply, (CLZero{F}, seed_type))
    precompile(_apply_vector, (CLStep{F}, seed_type))
    precompile(_stage_output, (CLStep{F}, seed_type))
    precompile(marginal_k, (CLStep{F}, seed_type, Int))
end
precompile(_child, (CLStep{GF8}, Vector{GF8}))
precompile(_child, (CLStep{GF2048}, Vector{GF2048}))
precompile(sum_stage_outputs, (CLMarginal{GF8},))
precompile(histogram, (CLDistribution{GF8}, NTuple{8,GF8}))
