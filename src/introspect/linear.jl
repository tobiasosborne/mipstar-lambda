# TB6 linear algebra over F_q for the introspection decider and the
# stabilizer simulator: canonical reduced row echelon form, kernel basis,
# canonical complement (def:canonical-complement, gt-03-prelim.tex:307-318),
# the canonical linear map with kernel basis F (def:cl-canonical,
# gt-03:375-384; def:Lperp, gt-03:386-392), the dual space ker(L)^perp, the
# self-dual normal basis kappa of lem:pauli-binary (gt-03:1173-1198), and the
# coordinate embedding of a CL term into a larger ambient space.

"Reduced row echelon form of `A` by the canonical algorithm; returns (R, pivot columns)."
function rref(A::AbstractMatrix{F}) where {F}
    M = Matrix{F}(A)
    rows, columns = size(M)
    pivots = Int[]
    r = 1
    for c in 1:columns
        r > rows && break
        p = findfirst(i -> !iszero(M[i, c]), r:rows)
        p === nothing && continue
        p += r - 1
        if p != r
            M[p, :], M[r, :] = M[r, :], M[p, :]
        end
        s = inv(M[r, c])
        M[r, :] .*= s
        for i in 1:rows
            (i == r || iszero(M[i, c])) && continue
            f = M[i, c]
            M[i, :] .-= f .* M[r, :]
        end
        push!(pivots, c)
        r += 1
    end
    (M, pivots)
end

"Canonical basis of ker(A) (A is r x c): one vector per free column, from the RREF."
function kernel_basis(A::AbstractMatrix{F}) where {F}
    R, pivots = rref(A)
    columns = size(A, 2)
    free = setdiff(1:columns, pivots)
    basis = Vector{F}[]
    for f in free
        v = fill(zero(F), columns)
        v[f] = one(F)
        for (i, p) in enumerate(pivots)
            v[p] = -R[i, f]
        end
        push!(basis, v)
    end
    basis
end

"def:canonical-complement: the standard basis vectors e_j with j not a pivot column of RREF(rows = F)."
function canonical_complement(vectors::Vector{Vector{F}}, n::Int) where {F}
    isempty(vectors) && return [begin v = fill(zero(F), n); v[j] = one(F); v end for j in 1:n]
    A = Matrix{F}(undef, length(vectors), n)
    for (i, v) in enumerate(vectors)
        A[i, :] = v
    end
    _, pivots = rref(A)
    [begin v = fill(zero(F), n); v[j] = one(F); v end for j in 1:n if !(j in pivots)]
end

"""
    canonical_linear_map(kernel_vectors, n) -> Matrix

def:cl-canonical: the projector onto T = span(F^perp) parallel to
S = span(F), for a linearly independent set F. Its matrix P satisfies
P x = t where x = s + t, s in S, t in T.
"""
function canonical_linear_map(kernel_vectors::Vector{Vector{F}}, n::Int) where {F}
    complement = canonical_complement(kernel_vectors, n)
    basis = vcat(kernel_vectors, complement)
    length(basis) == n || throw(ArgumentError("kernel basis and canonical complement do not span"))
    B = Matrix{F}(undef, n, n)
    for (j, v) in enumerate(basis)
        B[:, j] = v
    end
    # Coordinates of x in the basis (S | T): solve B c = x; P x = sum of the T part.
    inverse = _invert(B)
    k = length(kernel_vectors)
    P = fill(zero(F), n, n)
    for j in 1:n
        e = fill(zero(F), n)
        e[j] = one(F)
        c = inverse * e
        t = fill(zero(F), n)
        for i in k+1:n
            t .+= c[i] .* basis[i]
        end
        P[:, j] = t
    end
    P
end

function _invert(B::Matrix{F}) where {F}
    n = size(B, 1)
    M = hcat(B, Matrix{F}(one(F) * LinearAlgebraIdentity(n)))
    R, pivots = rref(M)
    pivots[1:n] == collect(1:n) || throw(ArgumentError("matrix is singular"))
    R[:, n+1:2n]
end
# A tiny identity constructor without a LinearAlgebra dependency.
struct LinearAlgebraIdentity
    n::Int
end
Base.:*(x::F, I::LinearAlgebraIdentity) where {F} = F[i == j ? x : zero(F) for i in 1:I.n, j in 1:I.n]

"Dual space basis: ker(L)^perp = {v : v . k = 0 for all k in ker(L)}, canonical kernel basis of the kernel rows."
function dual_basis(kernel_vectors::Vector{Vector{F}}, n::Int) where {F}
    isempty(kernel_vectors) && return [begin v = fill(zero(F), n); v[j] = one(F); v end for j in 1:n]
    A = Matrix{F}(undef, length(kernel_vectors), n)
    for (i, v) in enumerate(kernel_vectors)
        A[i, :] = v
    end
    kernel_basis(A)
end

"""
    perp_map(M::Matrix) -> (L_perp, kernel_basis_F, dual_basis_S)

def:Lperp (gt-03:L386-L392) with lem:L_perp_perp: from the matrix M of
L_{k+1,u} in the factor basis, a canonical basis F of ker(M) by Gaussian
elimination, the canonical basis S of the ORTHOGONAL complement ker(L)^perp
= {v : v . f = 0 for all f in F} (the kernel of the matrix with rows F), and
L^perp = the canonical linear map with kernel basis S (def:cl-canonical), so
that ker(L^perp) = ker(L)^perp and lem:commute holds for the honest Z_L /
X_{L^perp} families. SOURCE_REPAIR(intro-perp-orthogonal): the decider text
(gt-08:L669-L678) takes S = the CANONICAL COMPLEMENT of F instead, which
spans ker(L)^perp only when ker(L) is a register subspace (gt-03:L333-L340);
`perp_map_literal` is that reading.
"""
function perp_map(M::Matrix{F}) where {F}
    n = size(M, 2)
    F_basis = kernel_basis(M)
    S = dual_basis(F_basis, n)
    (canonical_linear_map(S, n), F_basis, S)
end
"The literal reading of gt-08:L669-L678: S = the canonical complement of the kernel basis."
function perp_map_literal(M::Matrix{F}) where {F}
    n = size(M, 2)
    F_basis = kernel_basis(M)
    S = canonical_complement(F_basis, n)
    (canonical_linear_map(S, n), F_basis, S)
end

# ---------------------------------------------------------------------------
# The bijection kappa: F_q -> F_2^k of lem:pauli-binary through a SELF-DUAL
# NORMAL basis {alpha^(2^i)} (lem:efficient_basis, gt-03:707-737): the
# qudit Pauli tau^W_a is the tensor product of the qubit Paulis
# sigma^W_{a_j} with a = sum_j a_j e_j, and tr(ab) = sum_j a_j b_j.

"Absolute trace F_{2^k} -> F_2 as a Bool."
function field_trace(x::F) where {F<:GF2k}
    k = round(Int, log2(field_size(F)))
    t = zero(F)
    y = x
    for _ in 1:k
        t += y
        y = y * y
    end
    iszero(t) ? false : (t == one(F) ? true : throw(ArgumentError("trace is not in F_2")))
end

"A self-dual normal basis of F_{2^k} over F_2 (k odd), found by exhaustive search; F_2 gives [1]."
function self_dual_normal_basis(::Type{F}) where {F<:GF2k}
    k = round(Int, log2(field_size(F)))
    for alpha in field_elements(F)
        iszero(alpha) && continue
        basis = F[alpha ^ (2 ^ i) for i in 0:k-1]
        ok = all(field_trace(basis[i] * basis[j]) == (i == j) for i in 1:k, j in 1:k)
        ok && return basis
    end
    throw(ArgumentError("no self-dual normal basis (k must be odd)"))
end

"kappa(a) in the self-dual normal basis: a = sum_j a_j e_j, a_j = tr(a e_j)."
kappa_bits(a::F, basis::Vector{F}) where {F} = Bool[field_trace(a * e) for e in basis]
"kappa^{-1}: bits -> field element."
kappa_field(bits::AbstractVector{Bool}, basis::Vector{F}) where {F} =
    (length(bits) == length(basis) || throw(ArgumentError("kappa needs log q bits")); sum((b ? e : zero(F)) for (b, e) in zip(bits, basis); init=zero(F)))
"A vector of F_q elements to its Q = n log q bits (blockwise kappa)."
kappa_bits(v::AbstractVector{F}, basis::Vector{F}) where {F} = reduce(vcat, (kappa_bits(x, basis) for x in v); init=Bool[])
function kappa_fields(bits::AbstractVector{Bool}, basis::Vector{F}) where {F}
    k = length(basis)
    length(bits) % k == 0 || throw(ArgumentError("bit vector does not parse into log q blocks"))
    F[kappa_field(bits[(i-1)*k+1:i*k], basis) for i in 1:length(bits) ÷ k]
end

# ---------------------------------------------------------------------------
# Coordinate embedding of a CL term into a larger ambient space
# (gt-07-ldt.tex:1085-1101, footnote: "the range ... of L_Point is embedded in
# V^pauli in the natural way"): coordinate i of the small space becomes
# `positions[i]`; the remaining `extra` coordinates of the big space join the
# TOP stage's factor register under the zero map (the first factor space of
# the embedded map absorbs V_{Wbar} (+) V_r, on which the map is zero;
# rk:higher-level's convention for zero blocks), so every stage below is
# untouched and the level is preserved.

function embed_cl(L::AbstractCL{F}, positions::Vector{Int}, n::Int) where {F}
    length(positions) == seed_dim(L) || throw(ArgumentError("embedding needs one position per coordinate"))
    allunique(positions) && all(p -> 1 <= p <= n, positions) || throw(ArgumentError("embedding positions must be distinct coordinates of F^n"))
    extra = setdiff(1:n, positions)
    L isa CLZero && return CLZero(F, n, vcat(positions[L.indices], extra))
    step = L::CLStep{F}
    factor = vcat(positions[step.factor], extra)
    k0 = length(step.factor)
    matrix = fill(zero(F), length(factor), length(factor))
    matrix[1:k0, 1:k0] = step.matrix
    child = _embed_below(step.child_shape, positions, n)
    _clstep(F, n, factor, positions[step.rest], matrix, child, _embed_branch(step.branch, positions, n); require_ambient=true)
end
function _embed_below(L::AbstractCL{F}, positions::Vector{Int}, n::Int) where {F}
    L isa CLZero && return CLZero(F, n, positions[L.indices])
    step = L::CLStep{F}
    _clstep(F, n, positions[step.factor], positions[step.rest], step.matrix, _embed_below(step.child_shape, positions, n),
            _embed_branch(step.branch, positions, n); require_ambient=false)
end
_embed_branch(b::BranchConst, positions, n) = BranchConst(_embed_below(b.child, positions, n))
_embed_branch(b::BranchByAxis{F}, positions, n) where {F} =
    BranchByAxis(b.m, b.position, AbstractCL{F}[_embed_below(c, positions, n) for c in b.table])
_embed_branch(b::BranchLnf{F}, positions, n) where {F} = BranchLnf(n, positions[b.point], _embed_below(b.tail, positions, n))
_embed_branch(b::BranchPadded, positions, n) = throw(ArgumentError("embed a map before padding it"))
_embed_branch(b::OpaqueBranch, positions, n) = throw(ArgumentError("an opaque branch cannot be embedded"))
