using Test: @test, @testset, @test_throws

include(joinpath(@__DIR__, "midpoint.jl"))

cheating_bound(n) = EXACT_ONE - BigInt(1) // (BigInt(2)^n)

# ln 2 = 0.693147180559945309417232121458176568… (independent 30-digit sandwich)
const LN2_LO_REF = BigInt(693147180559945309417232121458) // BigInt(10)^30 # < ln 2
const LN2_HI_REF = BigInt(693147180559945309417232121459) // BigInt(10)^30 # > ln 2

# Positive atanh series: ln(2) = 2 sum_{k>=0} (1/3)^(2k+1)/(2k+1).
# The returned enclosure is rational and rigorous; no floating tolerance enters.
function ln2_interval(terms::Int=16)
    x = BigInt(1) // BigInt(3)
    lower = sum(2 * x^(2k + 1) / BigInt(2k + 1) for k in 0:(terms - 1))
    tail_upper = 2 * x^(2terms + 1) /
                 (BigInt(2terms + 1) * (EXACT_ONE - x^2))
    return lower, lower + tail_upper
end

@testset "term IR, red optimum block, and exact evaluators" begin
    # RED R1: optval must maximize, rather than replaying any fixed move.
    suboptimal = FiniteContinuation((0, 1), z -> Test(() -> z == 1))
    bad = Ask(suboptimal)
    @test value(bad, Strategy(_ -> 0)) == EXACT_ZERO
    @test optval(bad) == EXACT_ONE
    @test optval(bad) isa ExactProbability

    coin = Coin(Test(() -> true), Test(() -> false))
    @test value(coin, Strategy(_ -> 0)) == EXACT_HALF
    @test optval(coin) == EXACT_HALF

    f = t -> mod(t + 1, 5)

    # RED R2: the whole caller-supplied domain is offered by Ask.
    term = midpoint_protocol(f, 0:4, 0, 3, 1)
    @test collect(term.k.domain) == collect(0:4)

    # RED R3: prover freedom is load-bearing on a direct protocol-data example.
    full = Ask(FiniteContinuation((0, 1), z -> Test(() -> z == 1)))
    restricted = Ask(FiniteContinuation((0,), z -> Test(() -> z == 1)))
    @test optval(restricted) < optval(full)

    # RED R4: value rejects an out-of-domain prover message.
    guarded = midpoint_protocol(f, 0:4, 0, 3, 1)
    @test_throws ArgumentError value(guarded, Strategy(_ -> 99))

    # RED R5: the full honest n=2 expansion includes both Coin branches.
    true_y = iterate_function(f, 0, 4)
    trace_term = midpoint_protocol(f, 0:4, 0, true_y, 2)
    honest = honest_strategy(trace_term, f, 0, true_y, 2)
    trace = pretty(trace_term, honest)
    @test count(_ -> true, eachmatch(r"Ask\(", trace)) == 3
    @test count(_ -> true, eachmatch(r"Coin\(", trace)) == 3
    @test count(_ -> true, eachmatch(r"Test\(", trace)) == 4

    # Evaluator memoization must not alias distinct continuation/domain nodes.
    left = Ask(FiniteContinuation((0,), z -> Test(() -> z == 1)))
    right = Ask(FiniteContinuation((0, 1), z -> Test(() -> z == 1)))
    @test optval(Coin(left, right)) == EXACT_HALF

    println("n=2 term trace:")
    println(trace)
end

@testset "sharp orbit-prefix hypothesis" begin
    f = t -> mod(t + 1, 5)
    critic_domain = [0, 1, 2]

    # Critic's n=2 counterexample is rejected because the theorem hypothesis,
    # rather than a claimed value, fails: 3 and 4 are absent from the prefix.
    @test !orbit_prefix_in_domain(f, critic_domain, 0, 2)
    @test_throws ArgumentError midpoint_protocol(f, critic_domain, 0, 0, 2)
    for y in critic_domain
        unchecked_term = midpoint_protocol(
            f, critic_domain, 0, y, 2; unchecked=true,
        )
        @test optval(unchecked_term) <= cheating_bound(2)
    end

    # The sharp hypothesis is weaker than closure under f.
    @test orbit_prefix_in_domain(f, critic_domain, 0, 1)
    @test f(2) ∉ critic_domain
    for y in critic_domain
        term = midpoint_protocol(f, critic_domain, 0, y, 1)
        expected = y == 2 ? EXACT_ONE : cheating_bound(1)
        @test optval(term) == expected
    end
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
            honest = honest_strategy(true_term, f, x, true_y, n)

            @test completeness(f, x, n) == EXACT_ONE
            @test value(true_term, honest) == EXACT_ONE
            @test optval(true_term) == EXACT_ONE

            expected = cheating_bound(n)
            for y in domain
                y == true_y && continue
                false_term = midpoint_protocol(f, domain, x, y, n)
                @test optval(false_term) == expected
            end
        end
    end
end

@testset "adaptive sequential AND repetition" begin
    f = t -> mod(t + 1, 5)
    domain = 0:4
    x = 0

    println("adaptive sequential AND values")
    for n in 1:4
        true_y = iterate_function(f, x, BigInt(2)^n)
        false_y = mod(true_y + 1, 5)
        p = cheating_bound(n)
        values = ExactProbability[]
        for r in 0:4
            adaptive = sequential_and_optval(f, domain, x, false_y, n, r)
            push!(values, adaptive)
            @test adaptive == p^r
        end
        println("n=", n, " r=1..4: ", join(string.(values[2:end]), ", "))
    end
end

@testset "exact repetition threshold and logarithmic bounds" begin
    ln2_lo, ln2_hi = ln2_interval()
    @test ln2_lo <= ln2_hi
    @test ln2_lo <= LN2_LO_REF
    @test LN2_HI_REF <= ln2_hi
    rs = Int[]

    for n in 1:12
        p = cheating_bound(n)
        r = repetitions_to_half(p)
        push!(rs, r)

        # Exact characterization of ceil(ln(2)/-ln(p)), without evaluating logs.
        @test p^r <= EXACT_HALF
        @test p^(r - 1) > EXACT_HALF

        # Rigorous rational enclosures imply the requested real inequalities.
        @test (BigInt(2)^n - 1) * ln2_hi <= r
        @test r <= BigInt(2)^n * ln2_lo + 1
    end

    println("r(n) for sequential cheating value <= 1/2")
    println("n  r(n)")
    for n in 1:12
        println(n, "  ", rs[n])
    end
end

@testset "transcript cost model" begin
    f = t -> mod(t + 1, 5)
    domain = 0:4
    for n in 0:5
        y = iterate_function(f, 0, BigInt(2)^n)
        term = midpoint_protocol(f, domain, 0, y, n)
        @test transcript_profiles(term) == Set([(n, n, 1)])
        @test rounds(term) == n
        @test queries(term) == 1
    end
end

@testset "Z/17Z bottom-up table" begin
    N = 17
    domain = 0:(N - 1)
    f = t -> mod(t + 1, N)
    previous = [y == f(x) ? EXACT_ONE : EXACT_ZERO for x in domain, y in domain]
    checked = 0

    for n in 0:8
        expected_false = cheating_bound(n)
        for x in domain, y in domain
            true_y = iterate_function(f, x, BigInt(2)^n)
            @test previous[x + 1, y + 1] ==
                  (y == true_y ? EXACT_ONE : expected_false)
            checked += 1
        end
        n == 8 && break
        previous = [
            maximum((previous[x + 1, z + 1] + previous[z + 1, y + 1]) /
                    BigInt(2) for z in domain)
            for x in domain, y in domain
        ]
    end
    println("Z/17Z bottom-up exact assertions: ", checked)
end
