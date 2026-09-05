using MIPStarLambda
using Base64

F = GF8
q = 8
# GF(8) multiplication table (add is XOR)
mul = Matrix{Int}(undef, q, q)
for a in 0:q-1, b in 0:q-1
    mul[a+1, b+1] = Int((F(a) * F(b)).bits)
end
println("GF8_MUL=", join(vec(permutedims(mul)), ","))
println("GF8_MODULUS=", Int(modulus_polynomial(F)))

LP = L_Point(F, 2); LA = L_ALine(F, 2); LD = L_DLine(F, 2)
println("SEED_DIM=", seed_dim(LP), ",", seed_dim(LA), ",", seed_dim(LD))
println("LEVELS=", level(LP), ",", level(LA), ",", level(LD))

# describe bytes
for (nm, L) in (("Point", LP), ("ALine", LA), ("DLine", LD))
    d = describe_cl(L)
    b = canonical_bytes(d)
    println("DESC_", nm, "_LEN=", length(b))
    println("DESC_", nm, "_HEX=", bytes2hex(b))
end

# full question table over all 8^5 seeds
n = 5
total = q^n
buf = IOBuffer()
packq(t) = (Int(t[1].bits) << 12) | (Int(t[2].bits) << 9) | (Int(t[3].bits) << 6) | (Int(t[4].bits) << 3) | Int(t[5].bits)
for code in 0:total-1
    c = code
    z = ntuple(i -> begin v = (c >> (3*(n-i))) & 7; F(v) end, n)
    for L in (LP, LA, LD)
        v = packq(apply(L, z))
        write(buf, UInt8((v >> 8) & 0xff)); write(buf, UInt8(v & 0xff))
    end
end
raw = take!(buf)
println("TABLE_BYTES=", length(raw))
open(joinpath(@__DIR__, "cl_table.b64"), "w") do io
    write(io, base64encode(raw))
end
println("TABLE_WRITTEN")
