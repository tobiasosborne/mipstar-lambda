# TB6 (DESIGN 11.4; briefs/43-tb6-introspect.md addendum, Blocker 1): the
# METERED walk of a leaf CL term. It is the universal interpreter's
# evaluation of a description leaf, stage by stage, with every primitive
# step charged on the Meter: a register read or write, one multiply-
# accumulate over one field element, one branch selection, one control
# transfer. The unmetered cl.jl functions (`Marginal`, `Linear`, `Factor`)
# are the reference; agreement is the CHECKED `MeteredWalkAgreement` row of
# TB6 and every TB5 leaf assertion runs through this walk.

# One stage of the walk on `seed`: reads of z[factor], |factor|^2
# multiply-accumulates, |factor| writes, one branch selection.
function _metered_stage(L::CLStep{F}, seed::Vector{F}, ctx::Meter) where {F}
    f = L.factor
    k = length(f)
    _charge!(ctx, k)
    input = F[seed[c] for c in f]
    _charge!(ctx, k * k)
    local_output = _matvec(L.matrix, input)
    _charge!(ctx, k)
    full = fill(zero(F), L.seed_dim)
    for (coordinate, value) in zip(f, local_output)
        full[coordinate] = value
    end
    _charge!(ctx, 1)
    (full, local_output, _child(L, local_output))
end

"The metered L_{<= j}(z) (lem:cl-kth item 3): the sum of the first j stage outputs."
function _metered_marginal(L::AbstractCL{F}, j::Integer, z::Vector{F}, ctx::Meter) where {F}
    1 <= Int(j) <= level(L) || throw(ArgumentError("stage index out of range"))
    length(z) == seed_dim(L) || throw(ArgumentError("seed has wrong dimension"))
    total = fill(zero(F), seed_dim(L))
    current = L
    for _ in 1:Int(j)
        current isa CLStep{F} || error("malformed CL level")
        full, _, child = _metered_stage(current, z, ctx)
        _charge!(ctx, length(current.factor))
        for c in current.factor
            total[c] += full[c]
        end
        current = child
    end
    total
end

# The prefix walk of cl.jl (`_walk_prefix`): each stage's key is read off
# u, checked against the stage's column space when `reachable`, and the
# branch is selected; then u's support is scanned.
function _metered_walk(L::AbstractCL{F}, j::Int, u::Vector{F}, ctx::Meter; reachable::Bool) where {F}
    1 <= j <= level(L) || throw(ArgumentError("stage index out of range"))
    length(u) == seed_dim(L) || throw(ArgumentError("prefix has wrong dimension"))
    walked = falses(seed_dim(L))
    current = L
    for _ in 1:j-1
        step = current::CLStep{F}
        _charge!(ctx, length(step.factor))
        key = F[u[c] for c in step.factor]
        if reachable
            _metered_in_column_space(step.matrix, key, ctx) ||
                throw(ArgumentError("Factor prefix is not a reachable marginal L_{<j}(V)"))
        end
        walked[step.factor] .= true
        _charge!(ctx, 1)
        current = _child(step, key)
    end
    _charge!(ctx, seed_dim(L))
    for c in 1:seed_dim(L)
        walked[c] || iszero(u[c]) || throw(ArgumentError("prefix has support outside V_{<j}"))
    end
    current::CLStep{F}
end

"The metered factor indicator V_{j,u} (def:sampler factor call)."
function _metered_factor(L::AbstractCL{F}, j::Integer, u::Vector{F}, ctx::Meter) where {F}
    node = _metered_walk(L, Int(j), u, ctx; reachable=true)
    _charge!(ctx, seed_dim(L))
    indicator = zeros(Int, seed_dim(L))
    for c in node.factor
        indicator[c] = 1
    end
    indicator
end

"The metered L_{j,u}(y) on the V_j projection of y (def:sampler linear call)."
function _metered_linear(L::AbstractCL{F}, j::Integer, u::Vector{F}, y::Vector{F}, ctx::Meter) where {F}
    node = _metered_walk(L, Int(j), u, ctx; reachable=false)
    length(y) == seed_dim(L) || throw(ArgumentError("Linear input has wrong dimension"))
    f = node.factor
    k = length(f)
    _charge!(ctx, k + k * k + k)
    input = F[y[c] for c in f]
    local_output = _matvec(node.matrix, input)
    full = fill(zero(F), seed_dim(L))
    for (coordinate, value) in zip(f, local_output)
        full[coordinate] = value
    end
    full
end

# cl.jl's `_in_column_space` with every row operation charged: the
# canonical Gaussian elimination of [A | b] over the field.
function _metered_in_column_space(A::Matrix{F}, b::Vector{F}, ctx::Meter) where {F}
    rows, columns = size(A)
    M = hcat(A, b)
    _charge!(ctx, rows * (columns + 1))
    pivot_row = 1
    for column in 1:columns
        pivot_row > rows && break
        _charge!(ctx, rows - pivot_row + 1)
        found = findfirst(r -> !iszero(M[r, column]), pivot_row:rows)
        found === nothing && continue
        p = found + pivot_row - 1
        if p != pivot_row
            _charge!(ctx, 2 * (columns + 1))
            M[p, :], M[pivot_row, :] = M[pivot_row, :], M[p, :]
        end
        scale = inv(M[pivot_row, column])
        _charge!(ctx, columns + 1)
        for c in 1:columns+1
            M[pivot_row, c] *= scale
        end
        for r in 1:rows
            (r == pivot_row || iszero(M[r, column])) && continue
            f = M[r, column]
            _charge!(ctx, columns + 1)
            for c in 1:columns+1
                M[r, c] -= f * M[pivot_row, c]
            end
        end
        pivot_row += 1
    end
    _charge!(ctx, rows * (columns + 1))
    all(r -> !(all(iszero, M[r, 1:columns]) && !iszero(M[r, columns+1])), 1:rows)
end
