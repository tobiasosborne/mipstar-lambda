using Test: @test, @testset

const SOURCE_DIR = normpath(joinpath(@__DIR__, ".."))
const IMPLEMENTATION = joinpath(SOURCE_DIR, "midpoint.jl")
const TEST_SUITE = joinpath(SOURCE_DIR, "test.jl")

struct Mutation
    name::String
    description::String
    target::Symbol
    replacements::Vector{Pair{String,String}}
end

Mutation(name, description, replacements) =
    Mutation(name, description, :implementation, replacements)

const MUTATIONS = (
    Mutation(
        "M1",
        "Coin checks both subclaims",
        ["return (left + right) / BigInt(2)" => "return left * right"],
    ),
    Mutation(
        "M2",
        "prover cannot choose z (each Ask is fixed to its left endpoint)",
        ["ask_domain = domain" => "ask_domain = (x,)"],
    ),
    Mutation(
        "M3",
        "honest midpoint uses 2^n instead of 2^(n-1)",
        ["half_steps = BigInt(1) << (n - 1)" =>
         "half_steps = BigInt(1) << n"],
    ),
    Mutation(
        "M4",
        "N-P: Ask domain collapsed to the honest midpoint",
        ["ask_domain = domain" =>
         "ask_domain = (iterate_function(f, x, BigInt(1) << (n - 1)),)"],
    ),
    Mutation(
        "M5",
        "N-Q: Ask evaluator replays one fixed move instead of maximizing",
        ["return maximum(choice -> _optval(term.k(choice), cache), term.k.domain)" =>
         "return _optval(term.k(first(term.k.domain)), cache)"],
    ),
    Mutation(
        "M6",
        "N-T: optval evaluates a fixed strategy instead of optimizing",
        ["return _optval(term, IdDict{Any,ExactProbability}())" =>
         "return value(term, Strategy(k -> first(k.domain)))"],
    ),
    Mutation(
        "M7",
        "N-U: Ask domain is only the orbit of x, ignoring caller domain",
        ["return choices\nend\n\n\"\"\"\n    midpoint_protocol" =>
         "return unique(orbit_prefix(f, x, n))\nend\n\n\"\"\"\n    midpoint_protocol"],
    ),
    Mutation(
        "M8",
        "N-F: value accepts an out-of-domain prover message",
        ["throw(ArgumentError(\"prover choice is outside the finite domain\"))" =>
         "nothing"],
    ),
    Mutation(
        "M9",
        "N-G: pretty-printer drops Coin branch 2",
        ["_pretty(io, term.t2, prover, depth + 2)" => "nothing"],
    ),
    Mutation(
        "M10",
        "N-J: separate honest strategy chooses the claim endpoint",
        ["choice = iterate_function(f, x, half_steps)" => "choice = y"],
    ),
    Mutation(
        "M11",
        "O9: evaluator memo aliases distinct Ask/domain nodes",
        ["key = term.k" => "key = typeof(term)"],
    ),
    Mutation(
        "M12",
        "O2: sequential game stops after one accepted copy",
        ["copies_after == 0 ? EXACT_ONE : game_value(x, y, level, copies_after - 1)" =>
         "EXACT_ONE"],
    ),
    Mutation(
        "M13",
        "O16: ln2 enclosure inverted (lo/hi swapped)",
        :test,
        ["return lower, lower + tail_upper" =>
         "return lower + tail_upper, lower"],
    ),
)

function apply_mutation(source::String, mutation::Mutation)
    result = source
    for (old, new) in mutation.replacements
        occurrences = length(findall(old, result))
        occurrences > 0 || error("$(mutation.name): mutation target not found: $old")
        result = replace(result, old => new)
    end
    return result
end

function mutant_exit_code(mutation::Mutation)
    implementation_source = read(IMPLEMENTATION, String)
    test_source = read(TEST_SUITE, String)
    if mutation.target == :implementation
        implementation_source = apply_mutation(implementation_source, mutation)
    elseif mutation.target == :test
        test_source = apply_mutation(test_source, mutation)
    else
        error("$(mutation.name): unknown mutation target $(mutation.target)")
    end

    # Every mutation is applied only to this temporary COPY.
    return mktempdir(prefix="midpoint-mutation-") do temporary_dir
        implementation_copy = joinpath(temporary_dir, "midpoint.jl")
        test_copy = joinpath(temporary_dir, "test.jl")
        write(implementation_copy, implementation_source)
        write(test_copy, test_source)

        output = IOBuffer()
        command = `$(Base.julia_cmd()) --startup-file=no $test_copy`
        process = run(pipeline(ignorestatus(command), stdout=output, stderr=output))
        if process.exitcode == 0
            println("Unexpected passing output for $(mutation.name):")
            println(String(take!(output)))
        end
        return process.exitcode
    end
end

@testset "midpoint mutation suite" begin
    for mutation in MUTATIONS
        exit_code = mutant_exit_code(mutation)
        @test exit_code != 0
        println(mutation.name, " killed (exit ", exit_code, "): ", mutation.description)
    end
end
