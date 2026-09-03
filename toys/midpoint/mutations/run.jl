using Test: @test, @testset

const SOURCE_DIR = normpath(joinpath(@__DIR__, ".."))
const IMPLEMENTATION = joinpath(SOURCE_DIR, "midpoint.jl")
const TEST_SUITE = joinpath(SOURCE_DIR, "test.jl")

struct Mutation
    name::String
    description::String
    replacements::Vector{Pair{String,String}}
end

const MUTATIONS = (
    Mutation(
        "M1",
        "Coin checks both subclaims",
        ["return (left + right) / BigInt(2)" => "return left * right"],
    ),
    Mutation(
        "M2",
        "prover cannot choose z (z is fixed to x)",
        [
            "choice = _checked_choice(term.k, prover)" => "choice = term.k.fixed",
            "choices = term.k.domain" => "choices = (term.k.fixed,)",
        ],
    ),
    Mutation(
        "M3",
        "use 2^n instead of 2^(n-1) for the midpoint",
        ["half_steps = BigInt(1) << (n - 1)" =>
         "half_steps = BigInt(1) << n"],
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
    source = read(IMPLEMENTATION, String)
    mutated = apply_mutation(source, mutation)

    return mktempdir(prefix="midpoint-mutation-") do temporary_dir
        implementation_copy = joinpath(temporary_dir, "midpoint.jl")
        test_copy = joinpath(temporary_dir, "test.jl")
        write(implementation_copy, mutated)
        cp(TEST_SUITE, test_copy; force=true)

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
