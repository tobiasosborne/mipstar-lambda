# TB6 (DESIGN 11.5, DD-27): an exact binary stabilizer-tableau simulator for
# the honest introspection strategy on |EPR_2>^{(x)(Q+1)} (gt-08-introspection.tex
# fig:intro-honest L1002-L1050 and the strategy text L1070-L1172; the Pauli
# strategy of lem:pauli-completeness gt-07-ldt.tex:L1232-L1330 with the
# Magic-Square operator solution of thm:ms-from-ac L659-L760). Every
# measurement is a family of commuting Hermitian Pauli strings; the family is
# refused (never sampled) when two of its strings anticommute. A coarse
# measurement {tau^W_[L(.) = b]} is realized by measuring W(v) for a basis
# {v} of ker(L)^perp and solving for b (lem:why-didnt-i-think-of-this-before,
# gt-08:L861-L921). No dense state vector is ever formed: the state is the
# 2n x (2n+1) bit tableau of Aaronson-Gottesman.

"A Hermitian Pauli string (-1)^r (x) P_j, with (x_j, z_j) = (1,1) meaning Y."
struct PauliString
    x::BitVector
    z::BitVector
    r::Bool
end
Base.length(p::PauliString) = length(p.x)
function pauli_string(n::Int; xs=Int[], zs=Int[], sign::Bool=false)
    x = falses(n); z = falses(n)
    x[xs] .= true
    z[zs] .= true
    PauliString(x, z, sign)
end
"Symplectic product: 1 iff the strings anticommute."
function anticommute(p::PauliString, q::PauliString)
    s = 0
    for j in eachindex(p.x)
        s += (p.x[j] & q.z[j]) + (p.z[j] & q.x[j])
    end
    isodd(s)
end
# Aaronson-Gottesman's g: the exponent of i contributed by multiplying single-qubit Paulis.
@inline function _g(x1::Bool, z1::Bool, x2::Bool, z2::Bool)
    if !x1 && !z1
        return 0
    elseif x1 && z1
        return Int(z2) - Int(x2)
    elseif x1 && !z1
        return Int(z2) * (2 * Int(x2) - 1)
    else
        return Int(x2) * (1 - 2 * Int(z2))
    end
end
"The product p*q as a Hermitian string; throws when the product carries a phase +-i (anti-Hermitian)."
function Base.:*(p::PauliString, q::PauliString)
    phase = 2 * Int(p.r) + 2 * Int(q.r)
    for j in eachindex(p.x)
        phase += _g(p.x[j], p.z[j], q.x[j], q.z[j])
    end
    phase = mod(phase, 4)
    phase in (0, 2) || throw(ArgumentError("the product of two Pauli strings is anti-Hermitian (phase i^$(phase)); anticommuting factors cannot form an observable"))
    PauliString(p.x .⊻ q.x, p.z .⊻ q.z, phase == 2)
end

mutable struct StabilizerTableau
    n::Int
    x::BitMatrix       # 2n rows: destabilizers 1..n, stabilizers n+1..2n
    z::BitMatrix
    r::BitVector
end
function _rowsum!(t::StabilizerTableau, h::Int, i::Int)
    phase = 2 * Int(t.r[h]) + 2 * Int(t.r[i])
    for j in 1:t.n
        phase += _g(t.x[i, j], t.z[i, j], t.x[h, j], t.z[h, j])
    end
    phase = mod(phase, 4)
    # Stabilizer products are Hermitian (phase 0 or 2); a destabilizer row may
    # anticommute with the pivot and pick up a phase +-i, which is never read
    # (Aaronson-Gottesman: destabilizer phases do not enter any outcome).
    (h > t.n && !(phase in (0, 2))) && error("tableau invariant violated")
    t.r[h] = phase >= 2
    for j in 1:t.n
        t.x[h, j] ⊻= t.x[i, j]
        t.z[h, j] ⊻= t.z[i, j]
    end
    nothing
end
_row_anticommutes(t::StabilizerTableau, i::Int, p::PauliString) =
    isodd(sum((t.x[i, j] & p.z[j]) + (t.z[i, j] & p.x[j]) for j in 1:t.n))

"""
    epr_tableau(pairs) -> StabilizerTableau on 2*pairs qubits

|EPR_2>^{(x) pairs} with Alice's qubit i at position i and Bob's at pairs + i:
stabilizers X_i X_{i'}, Z_i Z_{i'}; destabilizers Z_i, X_{i'}.
"""
function epr_tableau(pairs::Int)
    n = 2pairs
    x = falses(2n, n); z = falses(2n, n); r = falses(2n)
    for i in 1:pairs
        a, b = i, pairs + i
        # stabilizer rows n + 2i - 1 (X_a X_b) and n + 2i (Z_a Z_b)
        x[n + 2i - 1, a] = true; x[n + 2i - 1, b] = true
        z[n + 2i, a] = true; z[n + 2i, b] = true
        # destabilizers: Z_a for X_a X_b, X_b for Z_a Z_b
        z[2i - 1, a] = true
        x[2i, b] = true
    end
    StabilizerTableau(n, x, z, r)
end

"""
    measure!(t, p, choose) -> Bool

Measure the Hermitian Pauli string p: the outcome bit b means eigenvalue
(-1)^b. A random outcome is drawn through `choose()` (a fair bit; the
enumeration driver branches on it); a determined outcome is read off the
destabilizer/stabilizer rows.
"""
function measure!(t::StabilizerTableau, p::PauliString, choose::Function)
    length(p) == t.n || throw(ArgumentError("Pauli string on the wrong number of qubits"))
    n = t.n
    anti = [i for i in n+1:2n if _row_anticommutes(t, i, p)]
    if !isempty(anti)
        pidx = anti[1]
        for i in vcat(1:n, n+1:2n)
            i == pidx && continue
            _row_anticommutes(t, i, p) && _rowsum!(t, i, pidx)
        end
        # destabilizer := old stabilizer row; stabilizer := (-1)^b p
        t.x[pidx - n, :] = t.x[pidx, :]
        t.z[pidx - n, :] = t.z[pidx, :]
        t.r[pidx - n] = t.r[pidx]
        b = choose()::Bool
        t.x[pidx, :] = p.x
        t.z[pidx, :] = p.z
        t.r[pidx] = p.r ⊻ b
        return b
    end
    # Determined: accumulate the stabilizer rows selected by anticommuting destabilizers.
    scratch = StabilizerTableau(n, vcat(t.x, falses(1, n)), vcat(t.z, falses(1, n)), vcat(t.r, falses(1)))
    h = 2n + 1
    for i in 1:n
        _row_anticommutes(t, i, p) && _rowsum!(scratch, h, i + n)
    end
    (scratch.x[h, :] == p.x && scratch.z[h, :] == p.z) || error("determined outcome does not reproduce the measured string")
    scratch.r[h] ⊻ p.r
end

"Measure a simultaneous family: the symplectic precheck refuses an anticommuting pair before any sampling."
function measure_family!(t::StabilizerTableau, family::Vector{PauliString}, choose::Function)
    for i in eachindex(family), j in i+1:length(family)
        anticommute(family[i], family[j]) &&
            throw(ArgumentError("noncommuting measurement family: strings $(i) and $(j) anticommute (lem:commute precheck)"))
    end
    Bool[measure!(t, p, choose) for p in family]
end

# ---------------------------------------------------------------------------
# Coarse measurements on a register (a list of qubit positions) from a map
# matrix M (r x r in the register's basis order).

"Solve v_i . z = c_i over F_2 for the given rows (a particular solution, free variables 0)."
function _solve_gf2(rows::Vector{Vector{Bool}}, c::Vector{Bool}, r::Int)
    isempty(rows) && return falses(r)
    A = Matrix{GF2}(undef, length(rows), r + 1)
    for (i, v) in enumerate(rows)
        A[i, 1:r] = GF2[GF2(Int(b)) for b in v]
        A[i, r + 1] = GF2(Int(c[i]))
    end
    R, pivots = rref(A)
    r + 1 in pivots && error("inconsistent measurement outcomes")
    z = falses(r)
    for (i, p) in enumerate(pivots)
        z[p] = R[i, r + 1] == one(GF2)
    end
    z
end
_gf2rows(vectors::Vector{Vector{GF2}}) = [Bool[x == one(GF2) for x in v] for v in vectors]

"""
    coarse_measure!(t, W, register, M, choose) -> Vector{Bool}

The measurement {tau^W_[L(.) = b]} for the linear map with matrix M on the
register: measure W(v) for the canonical basis v of ker(M)^perp and return
b = M z0 for a solution z0 (gt-08:L861-L921).
"""
function coarse_measure!(t::StabilizerTableau, W::Symbol, register::Vector{Int}, M::Matrix{GF2}, choose::Function)
    r = length(register)
    dual = _gf2rows(dual_basis(kernel_basis(M), r))
    family = PauliString[W == :Z ? pauli_string(t.n; zs=register[findall(v)]) : pauli_string(t.n; xs=register[findall(v)]) for v in dual]
    bits = measure_family!(t, family, choose)
    z0 = _solve_gf2(dual, bits, r)
    out = M * GF2[GF2(Int(b)) for b in z0]
    Bool[x == one(GF2) for x in out]
end
"Measure W on every qubit of the register."
plain_measure!(t::StabilizerTableau, W::Symbol, register::Vector{Int}, choose::Function) =
    Bool[measure!(t, W == :Z ? pauli_string(t.n; zs=[q]) : pauli_string(t.n; xs=[q]), choose) for q in register]

# ---------------------------------------------------------------------------
# The enumeration driver: every fair bit is a branch; a leaf's probability is
# 2^-(number of bits drawn) exactly.

"""
    enumerate_branches(f) -> Vector{(; probability::Rational, result)}

Run `f(choose)` on every path of fair bits: `choose()` returns the next bit
of the current tape (0 when the tape is exhausted, extending it), and each
extension spawns the sibling branch with that bit flipped.
"""
function enumerate_branches(f::Function)
    leaves = Any[]
    worklist = Vector{Bool}[Bool[]]
    while !isempty(worklist)
        tape = pop!(worklist)
        record = copy(tape)
        position = 0
        choose = () -> begin
            position += 1
            position <= length(record) && return record[position]
            push!(record, false)
            false
        end
        result = f(choose)
        for p in length(tape)+1:length(record)
            push!(worklist, vcat(record[1:p-1], true))
        end
        push!(leaves, (; probability=(1 // 2) ^ length(record), result))
    end
    leaves
end

"A seeded fair-bit source for the seeded-draw regressions."
seeded_chooser(rng::AbstractRNG) = () -> rand(rng, Bool)
