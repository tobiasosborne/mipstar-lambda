using Test

const ROOT = normpath(joinpath(@__DIR__, "..", ".."))
const MUTATION_FILTER = get(ENV, "MUTATION_FILTER", "")
selected(mutant) = isempty(MUTATION_FILTER) || occursin(MUTATION_FILTER, mutant.label)

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
           "for (i, sign_coordinate) in enumerate(sign_coordinates)\n        factor =",
           "for (i, sign_coordinate) in enumerate(sign_coordinates)\n        i == 2 && continue\n        factor =", "pcp_separator"),
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
    Mutant("F degenerate_witness_ii_a3", "test/tb0_core.jl",
           "const NONDEGENERATE_TABLES = ((0, 1), (0, 1), (0, 1), (0, 1), (0, 1))",
           "const NONDEGENERATE_TABLES = ((0, 1), (0, 1), (0, 0), (0, 1), (0, 1))",
           "nondegenerate"),
    Mutant("C8 occurrence_ignores_fanout", "src/ir/circuits.jl",
           "counts[node.variable] += 1",
           "counts[node.variable] = 1", "c8"),
)

include("tb1_chi.jl")
include("tb1_pi.jl")
include("tb1_lnf.jl")
include("tb1_deg.jl")
include("tb1_level.jl")

const TB1_MUTANTS = (TB1_CHI_MUTANT, TB1_PI_MUTANT, TB1_LNF_MUTANT,
                     TB1_DEG_MUTANT, TB1_LEVEL_MUTANT)

function copied_mutant(mutant::Mutant)
    mktempdir() do temporary
        cp(joinpath(ROOT, "Project.toml"), joinpath(temporary, "Project.toml"); force=true)
        cp(joinpath(ROOT, "src"), joinpath(temporary, "src"); force=true)
        mkpath(joinpath(temporary, "test"))
        is_tb1 = startswith(mutant.target, "tb1_")
        test_name = is_tb1 ? "tb1_ld_sampler.jl" : "tb0_core.jl"
        cp(joinpath(ROOT, "test", test_name),
           joinpath(temporary, "test", test_name); force=true)

        path = joinpath(temporary, mutant.source)
        original = read(path, String)
        occurrences = count(mutant.before, original)
        occurrences == 1 || error("mutation $(mutant.label) matched $occurrences source sites")
        write(path, replace(original, mutant.before => mutant.after; count=1))

        target_name = is_tb1 ? replace(mutant.target, "tb1_" => "") : mutant.target
        target_variable = is_tb1 ? "TB1_TARGET" : "TB0_TARGET"
        command = setenv(`$(Base.julia_cmd()) --project=$(temporary) $(joinpath(temporary, "test", test_name))`,
                         target_variable => target_name)
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
        selected(mutant) && @test copied_mutant(mutant)
    end
end


@testset "TB1 targeted mutations" begin
    for mutant in TB1_MUTANTS
        selected(mutant) && @test copied_mutant(mutant)
    end
end
