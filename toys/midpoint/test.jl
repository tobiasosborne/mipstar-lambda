using Test: @test, @testset

include(joinpath(@__DIR__, "midpoint.jl"))

const Q = Rational{BigInt}
const QZERO = BigInt(0) // BigInt(1)
const QONE = BigInt(1) // BigInt(1)
const QHALF = BigInt(1) // BigInt(2)

cheating_bound(n) = QONE - BigInt(1) // (BigInt(2)^n)

@testset "term IR and exact evaluators" begin
    k = FiniteContinuation((0, 1), z -> Test(() -> z == 1), 1, 0,
                           (:small_example,), "z")
    term = Ask(k)
    @test value(term, _ -> 0) == QZERO
    @test value(term, _ -> 1) == QONE
    @test optval(term) == QONE
    @test optval(term) isa Q

    coin = Coin(Test(() -> true), Test(() -> false))
    @test value(coin, _ -> 0) == QHALF
    @test optval(coin) == QHALF

    f = t -> mod(t + 1, 5)
    trace = pretty(midpoint_protocol(f, 0:4, 0, iterate_function(f, 0, 4), 2))
    @test occursin("Ask", trace)
    @test occursin("Coin", trace)
    @test occursin("Test", trace)
    println("n=2 term trace:")
    println(trace)
end

@testset "exhaustive exact midpoint values" begin
    for N in (5, 8)
        domain = 0:(N - 1)
        functions = (
            t -> mod(t + 1, N),
            t -> mod(3t + 1, N),
        )
        for f in functions, x in domain, n in 0:5
            true_y = iterate_function(f, x, BigInt(2)^n)
            true_term = midpoint_protocol(f, domain, x, true_y, n)

            @test completeness(f, x, n) == QONE
            @test value(true_term, honest_prover) == QONE
            @test optval(true_term) == QONE

            expected = cheating_bound(n)
            for y in domain
                y == true_y && continue
                false_term = midpoint_protocol(f, domain, x, y, n)
                @test optval(false_term) == expected
            end
        end
    end
end


# For AND repetition, independence does need an argument.  Condition on every
# preceding transcript.  The next verifier coin is fresh, and the conditional
# acceptance chance of that copy is at most the single-copy optimum p.  Thus
# the joint chance is at most p^r.  Playing a single-copy optimal strategy in
# every copy attains p^r, so adaptive or correlated prover choices cannot help.
@testset "naive independent amplification" begin
    f = t -> mod(t + 1, 5)
    domain = 0:4
    rs = Int[]

    for n in 1:8
        x = 0
        true_y = iterate_function(f, x, BigInt(2)^n)
        false_y = mod(true_y + 1, 5)
        term = midpoint_protocol(f, domain, x, false_y, n)
        p = cheating_bound(n)

        @test optval(term) == p
        for r in 0:6
            @test amplified_optval(term, r) == p^r
        end

        r = repetitions_to_half(p)
        push!(rs, r)
        @test p^r <= QHALF
        @test r == 0 || p^(r - 1) > QHALF
    end

    println("r(n) for cheating value <= 1/2")
    println("n  r(n)  r(n+1)/r(n)")
    for n in 1:8
        ratio = n < 8 ? string(round(rs[n + 1] / rs[n]; digits=6)) : "-"
        println(n, "  ", rs[n], "  ", ratio)
    end

    for n in 4:7
        @test isapprox(rs[n + 1] / rs[n], 2.0; atol=0.06, rtol=0.0)
    end
end
