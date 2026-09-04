abstract type AbstractCL{F} end

"The unique zero-level CL function on the listed coordinate-index register."
struct CLZero{F} <: AbstractCL{F}
    seed_dim::Int
    indices::Tuple{Vararg{Int}}
end

"One inductive CL stage followed by a branch-selected lower-level CL function."
struct CLStep{F} <: AbstractCL{F}
    seed_dim::Int
    factor::Tuple{Vararg{Int}}
    rest::Tuple{Vararg{Int}}
    matrix::Matrix{F}
    branches::Dict{Any,AbstractCL{F}}
end

function _coordinate_indices(seed_dimension::Int, indices, name)
    result = Tuple(Int(i) for i in indices)
    length(unique(result)) == length(result) ||
        throw(ArgumentError("$name contains duplicate coordinates"))
    all(i -> 1 <= i <= seed_dimension, result) ||
        throw(ArgumentError("$name coordinate out of range"))
    result
end

function CLZero(::Type{F}, seed_dimension::Integer,
                indices=Tuple(1:Int(seed_dimension))) where {F}
    n = Int(seed_dimension)
    n >= 0 || throw(ArgumentError("seed dimension must be nonnegative"))
    CLZero{F}(n, _coordinate_indices(n, indices, "zero register"))
end

seed_dim(L::AbstractCL) = L.seed_dim
register_indices(L::CLZero) = Tuple(sort!(collect(L.indices)))
register_indices(L::CLStep) =
    Tuple(sort!(collect((L.factor..., L.rest...))))

level(::CLZero) = 0
level(L::CLStep) = 1 + level(first(values(L.branches)))

function _field_tuples(::Type{F}, n::Int) where {F}
    n >= 0 || throw(ArgumentError("tuple dimension must be nonnegative"))
    values = Tuple(field_elements(F))
    n == 0 && return ((),)
    Iterators.product(ntuple(_ -> values, n)...)
end

function _matvec(matrix::AbstractMatrix{F}, input) where {F}
    ntuple(size(matrix, 1)) do row
        total = zero(F)
        for column in axes(matrix, 2)
            total += matrix[row, column] * input[column]
        end
        total
    end
end

function CLStep(::Type{F}, seed_dimension::Integer, factor, rest,
                matrix::AbstractMatrix, branch::Function) where {F}
    n = Int(seed_dimension)
    factor_indices = _coordinate_indices(n, factor, "factor register")
    rest_indices = _coordinate_indices(n, rest, "rest register")
    isempty(intersect(Set(factor_indices), Set(rest_indices))) ||
        throw(ArgumentError("factor and rest registers overlap"))
    A = Matrix{F}(matrix)
    size(A) == (length(factor_indices), length(factor_indices)) ||
        throw(ArgumentError("stage matrix must act within its factor register"))

    # def:cl-func (gt-04-cl.tex:35-57): materialize every attainable image
    # value so the continuation is an inductive child, not a forged level tag.
    image_values = Set{Any}()
    for input in _field_tuples(F, length(factor_indices))
        push!(image_values, _matvec(A, input))
    end
    branches = Dict{Any,AbstractCL{F}}()
    child_level = nothing
    expected_register = Tuple(sort!(collect(rest_indices)))
    for value in image_values
        child = branch(value)
        child isa AbstractCL{F} ||
            throw(ArgumentError("every CL branch must have the same field"))
        seed_dim(child) == n ||
            throw(ArgumentError("CL branch seed dimension changed"))
        register_indices(child) == expected_register ||
            throw(ArgumentError("CL branch must occupy exactly the rest register"))
        if child_level === nothing
            child_level = level(child)
        elseif level(child) != child_level
            throw(ArgumentError("all CL branches must have one fixed lower level"))
        end
        branches[value] = child
    end
    CLStep{F}(n, factor_indices, rest_indices, A, branches)
end

CLStep(branch::Function, ::Type{F}, seed_dimension::Integer, factor, rest,
       matrix::AbstractMatrix) where {F} =
    CLStep(F, seed_dimension, factor, rest, matrix, branch)

function CLStep(::Type{F}, seed_dimension::Integer, factor, rest,
                matrix::AbstractMatrix, child::AbstractCL{F}) where {F}
    n = Int(seed_dimension)
    factor_indices = _coordinate_indices(n, factor, "factor register")
    rest_indices = _coordinate_indices(n, rest, "rest register")
    isempty(intersect(Set(factor_indices), Set(rest_indices))) ||
        throw(ArgumentError("factor and rest registers overlap"))
    A = Matrix{F}(matrix)
    size(A) == (length(factor_indices), length(factor_indices)) ||
        throw(ArgumentError("stage matrix must act within its factor register"))
    seed_dim(child) == n || throw(ArgumentError("CL branch seed dimension changed"))
    register_indices(child) == Tuple(sort!(collect(rest_indices))) ||
        throw(ArgumentError("CL branch must occupy exactly the rest register"))
    branches = Dict{Any,AbstractCL{F}}(nothing => child)
    CLStep{F}(n, factor_indices, rest_indices, A, branches)
end

_child(L::CLStep, key) = haskey(L.branches, key) ? L.branches[key] : L.branches[nothing]

function _stage_output(L::CLStep{F}, seed) where {F}
    input = ntuple(j -> convert(F, seed[L.factor[j]]), length(L.factor))
    local_output = _matvec(L.matrix, input)
    full = fill(zero(F), L.seed_dim)
    for (coordinate, value) in zip(L.factor, local_output)
        full[coordinate] = value
    end
    Tuple(full), local_output
end

function _check_seed(L::AbstractCL, seed)
    length(seed) == seed_dim(L) || throw(ArgumentError("seed has wrong dimension"))
    nothing
end

function apply(L::CLZero{F}, seed) where {F}
    _check_seed(L, seed)
    ntuple(_ -> zero(F), L.seed_dim)
end

function apply(L::CLStep{F}, seed) where {F}
    _check_seed(L, seed)
    stage, key = _stage_output(L, seed)
    tail = apply(_child(L, key), seed)
    ntuple(i -> stage[i] + tail[i], L.seed_dim)
end

struct CLMarginal{F}
    seed_dim::Int
    outputs::Vector{Tuple}
    factor_spaces::Vector{Tuple}
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
    factors = Tuple[]
    maps = Matrix{F}[]
    current = L
    for _ in 1:count
        current isa CLStep{F} || error("malformed CL level")
        stage, key = _stage_output(current, seed)
        push!(outputs, stage)
        push!(factors, current.factor)
        push!(maps, current.matrix)
        current = _child(current, key)
    end
    marginal = CLMarginal{F}(seed_dim(L), outputs, factors, maps,
                             ntuple(_ -> zero(F), seed_dim(L)))
    CLMarginal{F}(marginal.seed_dim, outputs, factors, maps,
                  sum_stage_outputs(marginal))
end

function _shift_cl(L::CLZero{F}, offset::Int, total::Int) where {F}
    CLZero(F, total, Tuple(i + offset for i in L.indices))
end

function _shift_cl(L::CLStep{F}, offset::Int, total::Int) where {F}
    factor = Tuple(i + offset for i in L.factor)
    rest = Tuple(i + offset for i in L.rest)
    if haskey(L.branches, nothing)
        return CLStep(F, total, factor, rest, L.matrix,
                      _shift_cl(L.branches[nothing], offset, total))
    end
    CLStep(F, total, factor, rest, L.matrix,
           value -> _shift_cl(_child(L, value), offset, total))
end

function _combine_embedded(nodes::Tuple{Vararg{AbstractCL{F}}}, total::Int) where {F}
    active = findall(node -> node isa CLStep{F}, nodes)
    if isempty(active)
        indices = Tuple(Iterators.flatten(register_indices(node) for node in nodes))
        return CLZero(F, total, indices)
    end

    factor_parts = Tuple((nodes[i]::CLStep{F}).factor for i in active)
    factor = Tuple(Iterators.flatten(factor_parts))
    rest_parts = map(nodes) do node
        node isa CLStep{F} ? node.rest : register_indices(node)
    end
    rest = Tuple(Iterators.flatten(rest_parts))
    matrix = zeros(F, length(factor), length(factor))
    cursor = 0
    for i in active
        node = nodes[i]::CLStep{F}
        width = length(node.factor)
        matrix[cursor+1:cursor+width, cursor+1:cursor+width] .= node.matrix
        cursor += width
    end

    CLStep(F, total, factor, rest, matrix) do value
        children = AbstractCL{F}[nodes...]
        cursor = 0
        for i in active
            node = nodes[i]::CLStep{F}
            width = length(node.factor)
            key = Tuple(value[cursor+1:cursor+width])
            children[i] = _child(node, key)
            cursor += width
        end
        _combine_embedded(Tuple(children), total)
    end
end

function direct_sum(functions::AbstractCL{F}...) where {F}
    # lem:cl-func-prod (gt-04-cl.tex:315-327): levels combine by maximum.
    isempty(functions) && throw(ArgumentError("direct_sum needs at least one CL function"))
    total = sum(seed_dim, functions)
    offset = 0
    embedded = map(functions) do L
        shifted = _shift_cl(L, offset, total)
        offset += seed_dim(L)
        shifted
    end
    _combine_embedded(Tuple(embedded), total)
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
    _combine_embedded((left_zero, shifted_right), total)
end

function _graft_concatenation(L::CLStep{F}, prefix::Vector{F},
                              continuation::Function, right_dim::Int,
                              total::Int) where {F}
    right_register = Tuple(seed_dim(L)+1:total)
    rest = (L.rest..., right_register...)
    CLStep(F, total, L.factor, rest, L.matrix) do value
        next_prefix = copy(prefix)
        for (coordinate, entry) in zip(L.factor, value)
            next_prefix[coordinate] += entry
        end
        _graft_concatenation(_child(L, value), next_prefix, continuation,
                             right_dim, total)
    end
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

function histogram(dist::CLDistribution{F}, elements=Tuple(field_elements(F))) where {F}
    values = Tuple(elements)
    counts = Dict{Any,Int}()
    seeds = seed_dim(dist.left) == 0 ? ((),) :
            Iterators.product(ntuple(_ -> values, seed_dim(dist.left))...)
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
precompile(apply, (CLStep{GF8}, NTuple{5,GF8}))
precompile(marginal_k, (CLStep{GF8}, NTuple{5,GF8}, Int))
precompile(sum_stage_outputs, (CLMarginal{GF8},))
precompile(histogram, (CLDistribution{GF8}, NTuple{8,GF8}))
