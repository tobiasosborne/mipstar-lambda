abstract type AbstractCL{F} end

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
    # apply/marginal_k; encountered children are memoised after validation
    # (`_child` checks field, seed dimension, rest register and child level).
    # Registers are `Vector{Int}` and stage values `Vector{F}` on purpose:
    # one `CLStep{F}` type and one specialization per operation, instead of
    # one per closure type and per register width (TB2 has widths 1..40),
    # which cost ~60 s of runtime compilation per test process.
    child_shape::AbstractCL{F}
    branch::Function
    children::Dict{Vector{F},AbstractCL{F}}
end

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
    branch isa Function ||
        throw(ArgumentError("CL continuation must be a function of the stage value"))
    CLStep{F}(n, factor_indices, rest_indices, A, child_shape, branch,
              Dict{Vector{F},AbstractCL{F}}())
end

function CLStep(branch::Function, ::Type{F}, seed_dimension::Integer,
                factor, rest, matrix::AbstractMatrix,
                child_shape::AbstractCL{F}) where {F}
    _clstep(F, seed_dimension, factor, rest, matrix, child_shape, branch;
            require_ambient=true)
end

function CLStep(::Type{F}, seed_dimension::Integer, factor, rest,
                matrix::AbstractMatrix, child::AbstractCL{F}) where {F}
    _clstep(F, seed_dimension, factor, rest, matrix, child, _ -> child;
            require_ambient=true)
end

function _child(L::CLStep{F}, key::Vector{F}) where {F}
    get!(L.children, key) do
        child = L.branch(key)
        child isa AbstractCL{F} ||
            throw(ArgumentError("every CL continuation must have the same field"))
        seed_dim(child) == L.seed_dim ||
            throw(ArgumentError("CL continuation seed dimension changed"))
        _register(child) == sort(L.rest) ||
            throw(ArgumentError("CL continuation must occupy exactly the rest register"))
        level(child) == level(L.child_shape) ||
            throw(ArgumentError("all CL continuations must have the constructed child level"))
        child
    end
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
