"Element of GF(2^K), represented in the polynomial basis modulo M."
struct GF2k{K,M} <: Number
    bits::UInt16
    GF2k{K,M}(bits::UInt16, ::Val{:raw}) where {K,M} = new{K,M}(bits)
end

# x^3+x+1 and x^11+x^2+1. Both are irreducible and primitive.
const GF8 = GF2k{3,0x00b}
const GF2048 = GF2k{11,0x805}

function GF2k{K,M}(x::Integer) where {K,M}
    mask = (UInt32(1) << K) - UInt32(1)
    GF2k{K,M}(UInt16(UInt32(x) & mask), Val(:raw))
end

Base.convert(::Type{F}, x::Integer) where {F<:GF2k} = F(x)
Base.convert(::Type{F}, x::F) where {F<:GF2k} = x
Base.promote_rule(::Type{F}, ::Type{<:Integer}) where {F<:GF2k} = F
Base.zero(::Type{F}) where {F<:GF2k} = F(0)
Base.one(::Type{F}) where {F<:GF2k} = F(1)
Base.zero(x::F) where {F<:GF2k} = zero(F)
Base.one(x::F) where {F<:GF2k} = one(F)
Base.iszero(x::GF2k) = iszero(x.bits)
Base.:(==)(a::F, b::F) where {F<:GF2k} = a.bits == b.bits
Base.hash(a::GF2k, h::UInt) = hash(a.bits, h)
Base.:+(a::F, b::F) where {F<:GF2k} = F(Int(xor(a.bits, b.bits)))
Base.:-(a::F, b::F) where {F<:GF2k} = a + b
Base.:-(a::F) where {F<:GF2k} = a

function _mulbits(a::UInt16, b::UInt16, k::Int, modulus::UInt32)
    x = UInt32(a)
    y = UInt32(b)
    result = UInt32(0)
    top = UInt32(1) << k
    while y != 0
        isodd(y) && (result = xor(result, x))
        y >>= 1
        x <<= 1
        # Polynomial reduction in GF(2)[X]/(M).
        (x & top) != 0 && (x = xor(x, modulus))
    end
    UInt16(result & (top - UInt32(1)))
end

function _log_tables(k::Int, modulus::UInt32)
    q = 1 << k
    logarithm = zeros(UInt16, q)
    exponential = Vector{UInt16}(undef, 2(q - 1))
    value = UInt16(1)
    for exponent in 0:q-2
        logarithm[Int(value) + 1] = UInt16(exponent)
        exponential[exponent + 1] = value
        exponential[exponent + q] = value
        value = _mulbits(value, UInt16(2), k, modulus)
    end
    logarithm, exponential
end

const _GF8_LOG, _GF8_EXP = _log_tables(3, UInt32(0x00b))
const _GF2048_LOG, _GF2048_EXP = _log_tables(11, UInt32(0x805))

@inline function _mul_raw(::Type{GF2k{3,0x00b}}, a::UInt16, b::UInt16)
    (a == 0 || b == 0) && return UInt16(0)
    index = Int(_GF8_LOG[Int(a) + 1]) + Int(_GF8_LOG[Int(b) + 1]) + 1
    _GF8_EXP[index]
end

@inline function _mul_raw(::Type{GF2k{11,0x805}}, a::UInt16, b::UInt16)
    (a == 0 || b == 0) && return UInt16(0)
    index = Int(_GF2048_LOG[Int(a) + 1]) + Int(_GF2048_LOG[Int(b) + 1]) + 1
    _GF2048_EXP[index]
end

@inline _mul_raw(::Type{GF2k{K,M}}, a::UInt16, b::UInt16) where {K,M} =
    _mulbits(a, b, K, UInt32(M))

function Base.:*(a::GF2k{K,M}, b::GF2k{K,M}) where {K,M}
    (iszero(a) || iszero(b)) && return zero(GF2k{K,M})
    raw = if K == 3 && M == 0x00b
        index = Int(_GF8_LOG[Int(a.bits) + 1]) + Int(_GF8_LOG[Int(b.bits) + 1]) + 1
        _GF8_EXP[index]
    elseif K == 11 && M == 0x805
        index = Int(_GF2048_LOG[Int(a.bits) + 1]) + Int(_GF2048_LOG[Int(b.bits) + 1]) + 1
        _GF2048_EXP[index]
    else
        _mulbits(a.bits, b.bits, K, UInt32(M))
    end
    GF2k{K,M}(raw, Val(:raw))
end

function Base.:^(a::F, exponent::Integer) where {F<:GF2k}
    exponent < 0 && return inv(a)^(-exponent)
    result = one(F)
    base = a
    power = exponent
    while power > 0
        isodd(power) && (result *= base)
        power >>= 1
        power > 0 && (base *= base)
    end
    result
end

field_size(::Type{GF2k{K,M}}) where {K,M} = 1 << K
modulus_polynomial(::Type{GF2k{K,M}}) where {K,M} = M
field_elements(::Type{F}) where {F<:GF2k} = [F(i) for i in 0:field_size(F)-1]

function Base.inv(a::F) where {F<:GF2k}
    iszero(a) && throw(DivideError())
    a^(field_size(F) - 2)
end

Base.:/(a::F, b::F) where {F<:GF2k} = a * inv(b)

function Base.show(io::IO, a::GF2k{K,M}) where {K,M}
    print(io, "GF(2^", K, ")(", Int(a.bits), ")")
end

function field_bytes(a::GF2k{K,M}) where {K,M}
    width = cld(K, 8)
    [UInt8((a.bits >> (8 * (width - i))) & 0x00ff) for i in 1:width]
end

function field_from_bytes(::Type{F}, bytes::AbstractVector{UInt8}) where {F<:GF2k}
    expected = cld(round(Int, log2(field_size(F))), 8)
    length(bytes) == expected || throw(ArgumentError("wrong field encoding width"))
    value = foldl((a, b) -> (a << 8) | UInt32(b), bytes; init=UInt32(0))
    value < field_size(F) || throw(ArgumentError("non-canonical field encoding"))
    F(value)
end

function _poly_degree(p::UInt32)
    p == 0 && return -1
    31 - leading_zeros(p)
end

function _poly_mod(a::UInt32, b::UInt32)
    db = _poly_degree(b)
    r = a
    while r != 0 && _poly_degree(r) >= db
        r = xor(r, b << (_poly_degree(r) - db))
    end
    r
end

"Independent trial-division irreducibility check for the declared modulus."
function is_irreducible_modulus(::Type{GF2k{K,M}}) where {K,M}
    f = UInt32(M)
    _poly_degree(f) == K || return false
    for degree in 1:fld(K, 2)
        leading = UInt32(1) << degree
        for low in UInt32(0):leading-UInt32(1)
            divisor = leading | low
            _poly_mod(f, divisor) == 0 && return false
        end
    end
    true
end

primitive_element(::Type{F}) where {F<:GF2k} = F(2)

function multiplicative_order(a::F) where {F<:GF2k}
    iszero(a) && return 0
    value = one(F)
    for order in 1:field_size(F)-1
        value *= a
        value == one(F) && return order
    end
    0
end
