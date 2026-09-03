using Test

const ROOT = normpath(joinpath(@__DIR__, "..", ".."))

struct Mutant
    label::String
    source::String
    before::String
    after::String
    target::String
end

const MUTANTS = (
    Mutant("A e-2_to_e-1", "src/polynomials/zero_basis.jl",
           "quotient_exponent = e - 2",
           "quotient_exponent = e - 1", "zero_basis"),
    Mutant("B omit_g2_minus_o2", "src/verifiers/pcp.jl",
           "for i in 1:5\n        sign_coordinate = 5 + i",
           "for i in (1, 3, 4, 5)\n        sign_coordinate = 5 + i", "pcp_separator"),
    Mutant("C omit_output_literal", "src/ir/circuits.jl",
           "include_output && push!(parts, Lit(input_count + circuit.output.id))",
           "false && push!(parts, Lit(input_count + circuit.output.id))", "circuit"),
    Mutant("D corrupt_field_reduction", "src/fields/gf2k.jl",
           "(x & top) != 0 && (x = xor(x, modulus))",
           "(x & top) != 0 && (x = xor(x, modulus << 1))", "field"),
    Mutant("E w1_fanout_2_to_1", "src/ir/circuits.jl",
           "fanout(circuit::Circuit) = circuit.fanout_counts",
           "fanout(circuit::Circuit) = Base.setindex(circuit.fanout_counts, circuit.fanout_counts[length(circuit.input_layout.names) + 1] - 1, length(circuit.input_layout.names) + 1)",
           "occurrence"),
    Mutant("C8 occurrence_ignores_fanout", "src/ir/circuits.jl",
           "counts[node.variable] += 1",
           "counts[node.variable] = 1", "c8"),
)

function copied_mutant(mutant::Mutant)
    mktempdir() do temporary
        cp(joinpath(ROOT, "Project.toml"), joinpath(temporary, "Project.toml"); force=true)
        cp(joinpath(ROOT, "src"), joinpath(temporary, "src"); force=true)
        mkpath(joinpath(temporary, "test"))
        cp(joinpath(ROOT, "test", "tb0_core.jl"),
           joinpath(temporary, "test", "tb0_core.jl"); force=true)

        path = joinpath(temporary, mutant.source)
        original = read(path, String)
        occurrences = count(mutant.before, original)
        occurrences == 1 || error("mutation $(mutant.label) matched $occurrences source sites")
        write(path, replace(original, mutant.before => mutant.after; count=1))

        command = setenv(`$(Base.julia_cmd()) --project=$(temporary) $(joinpath(temporary, "test", "tb0_core.jl"))`,
                         "TB0_TARGET" => mutant.target)
        captured = IOBuffer()
        process = run(pipeline(ignorestatus(command), stdout=captured, stderr=captured))
        output = String(take!(captured))
        killed = process.exitcode != 0
        println("MUTANT ", mutant.label, " target=", mutant.target, " => ",
                killed ? "KILLED" : "SURVIVED", " (exit=", process.exitcode, ")")
        killed || print(output)
        killed
    end
end

@testset "TB0 targeted mutations" begin
    for mutant in MUTANTS
        @test copied_mutant(mutant)
    end
end
