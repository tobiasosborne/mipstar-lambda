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
    expected_evidence::Union{Nothing,String}
    runtime_patch::Union{Nothing,String}
end

Mutant(label, source, before, after, target) =
    Mutant(label, source, before, after, target, nothing, nothing)
Mutant(label, source, before, after, target, expected_evidence) =
    Mutant(label, source, before, after, target, expected_evidence, nothing)

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
    Mutant("G g_a_reverse_bit_order", "src/polynomials/sparse.jl",
           "variable = polyvar(F, layout, coordinates[local_coordinate])\n            bit = (index >> (M - local_coordinate)) & 1",
           "variable = polyvar(F, layout, coordinates[local_coordinate])\n            bit = (index >> (local_coordinate - 1)) & 1", "encoding"),
    Mutant("H ind_reverse_bit_order", "src/polynomials/sparse.jl",
           "bit = (index >> (m - coordinate)) & 1",
           "bit = (index >> (coordinate - 1)) & 1", "encoding"),
    Mutant("I restore_GF2k_accumulator_bug", "src/polynomials/zero_basis.jl",
           "coefficient.bits == 1 && stored.bits <= 1",
           "coefficient.bits == 1",
           "zero_basis"),
    Mutant("J ev_z_ignores_c0_terms", "src/verifiers/pcp.jl",
           "beta0 = _evaluate_terms(c0, powers)",
           "beta0 = zero(F)", "c0_terms"),
    Mutant("K witness_iff_reverses_factor", "test/tb0_core.jl",
           "all(witness[i][Int(input[i]) + 1] != input[5 + i] for i in 1:5)",
           "all(witness[i][Int(input[i]) + 1] == input[5 + i] for i in 1:5)",
           "witness_iff"),
    Mutant("L PCPVerifier_replays_degree_only", "src/verifiers/pcp.jl",
           "replay=_replay_pcp_verifier)",
           "replay=_replay_pcp_c0)", "certificate"),
    Mutant("M drop_nonprime_multiply_guard", "src/polynomials/sparse.jl",
           "prime_support || return _multiply_terms_generic(a, b)",
           "true || return _multiply_terms_generic(a, b)", "nonprime"),
)

include("tb1_chi.jl")
include("tb1_pi.jl")
include("tb1_lnf.jl")
include("tb1_deg.jl")
include("tb1_level.jl")
include("tb1_agreement.jl")
include("tb1_symmetry.jl")
include("tb1_verifier_pi.jl")
include("tb1_online.jl")
include("tb1_question_arity.jl")
include("tb1_concat.jl")
include("tb2_formula.jl")
include("tb2_g3.jl")
include("tb2_line.jl")
include("tb2_guard.jl")
include("tb2_i345.jl")

const TB1_MUTANTS = (TB1_CHI_MUTANT, TB1_PI_MUTANT, TB1_LNF_MUTANT,
                     TB1_DEG_MUTANT, TB1_LEVEL_MUTANT,
                     TB1_AGREEMENT_MUTANT, TB1_SYMMETRY_MUTANT,
                     TB1_VERIFIER_PI_MUTANT, TB1_ONLINE_MUTANT,
                     TB1_QUESTION_ARITY_MUTANT, TB1_CONCAT_MUTANT)
const TB2_MUTANTS = (TB2_FORMULA_MUTANT, TB2_G3_MUTANT, TB2_LINE_MUTANT,
                     TB2_GUARD_MUTANT, TB2_I345_MUTANT)

function _trim_module(source::String, rung::Symbol)
    removals = rung == :tb0 ? (
        "include(\"samplers/cl.jl\")\n", "include(\"samplers/typed.jl\")\n",
        "include(\"samplers/ldt.jl\")\n", "include(\"samplers/pcp_sampler.jl\")\n",
        "include(\"samplers/oracularize.jl\")\n", "include(\"verifiers/ldt.jl\")\n",
        "include(\"verifiers/answer_reduce.jl\")\n") : rung == :tb1 ? (
        "include(\"verifiers/pcp.jl\")\n", "include(\"samplers/pcp_sampler.jl\")\n",
        "include(\"samplers/oracularize.jl\")\n",
        "include(\"verifiers/answer_reduce.jl\")\n", "include(\"tb0.jl\")\n") : ()
    for line in (removals..., "include(\"precompile.jl\")\n")
        source = replace(source, line => "")
    end
    source
end

function copied_mutant(mutant::Mutant, index::Int, temporary::String)
    is_tb1 = startswith(mutant.target, "tb1_")
    is_tb2 = startswith(mutant.target, "tb2_")
    rung = is_tb2 ? :tb2 : is_tb1 ? :tb1 : :tb0
    test_name = is_tb2 ? "tb2_answer_reduce.jl" :
                is_tb1 ? "tb1_ld_sampler.jl" : "tb0_core.jl"
    sandbox = joinpath(temporary, "mutant-$(index)")
    mkpath(sandbox)
    cp(joinpath(ROOT, "src"), joinpath(sandbox, "src"); force=true)
    mkpath(joinpath(sandbox, "test"))
    cp(joinpath(ROOT, "test", test_name), joinpath(sandbox, "test", test_name);
       force=true)

    path = joinpath(sandbox, mutant.source)
    original = read(path, String)
    occurrences = count(mutant.before, original)
    occurrences == 1 || error("mutation $(mutant.label) matched $occurrences source sites")
    write(path, replace(original, mutant.before => mutant.after; count=1))

    module_name = Symbol("MIPStarLambdaMutant", index)
    module_path = joinpath(sandbox, "src", "MIPStarLambda.jl")
    module_source = _trim_module(read(module_path, String), rung)
    module_source = replace(module_source,
                            "module MIPStarLambda\n" => "module $(module_name)\n";
                            count=1)
    write(module_path, module_source)
    test_source = replace(read(joinpath(sandbox, "test", test_name), String),
                          "using MIPStarLambda" => "using Main.$(module_name)";
                          count=1)
    target_name = is_tb2 ? replace(mutant.target, "tb2_" => "") :
                  is_tb1 ? replace(mutant.target, "tb1_" => "") : mutant.target
    target_variable = is_tb2 ? "TB2_TARGET" : is_tb1 ? "TB1_TARGET" : "TB0_TARGET"
    previous = get(ENV, target_variable, nothing)
    ENV[target_variable] = target_name
    phase = :load
    caught = nothing
    output = ""
    log_path = joinpath(sandbox, "output.log")
    started = time()
    open(log_path, "w+") do log
        try
            redirect_stdio(stdout=log, stderr=log) do
                Base.include(Main, module_path)
                phase = :test
                test_module = Module(Symbol("MutantTest", index), true, true)
                Base.include_string(test_module, test_source,
                                    joinpath(sandbox, "test", test_name))
            end
        catch error
            caught = (error, catch_backtrace())
        end
        flush(log)
        seekstart(log)
        output = read(log, String)
    end
    previous === nothing ? delete!(ENV, target_variable) :
                           (ENV[target_variable] = previous)

    evidence_ok = mutant.expected_evidence === nothing ||
                  occursin(mutant.expected_evidence, output)
    killed = phase == :test && caught !== nothing && evidence_ok
    assertion_failure = occursin("Test Failed", output) ||
                        occursin("Some tests did not pass", output)
    disposition = killed ? (assertion_failure ? "KILLED" :
                                                "KILLED-BY-CRASH") :
                           phase == :load ? "LOAD-ERROR" : "SURVIVED"
    println("MUTANT ", mutant.label, " target=", mutant.target, " => ",
            disposition, " (", round(time() - started; digits=2), " s)")
    if !killed
        print(output)
        caught === nothing || Base.display_error(stderr, caught...)
    end
    killed
end

function patched_process_mutant(mutant::Mutant, index::Int,
                                temporary::String, depot::String)
    test_name = "tb2_answer_reduce.jl"
    script = joinpath(temporary, "runtime-mutant-$(index).jl")
    patch_literal = repr(mutant.runtime_patch)
    source = "using MIPStarLambda\n" *
             "Core.eval(MIPStarLambda, Meta.parse($patch_literal))\n" *
             "println(\"MUTANT_TEST_STARTED\")\n" *
             "include(" * repr(joinpath(ROOT, "test", test_name)) * ")\n"
    write(script, source)
    target_name = replace(mutant.target, "tb2_" => "")
    command = addenv(`$(Base.julia_cmd()) --startup-file=no --project=$(ROOT) $script`,
        "TB2_TARGET" => target_name,
        "JULIA_DEPOT_PATH" => string(depot, ":", join(DEPOT_PATH, ':')),
        "JULIA_PKG_PRECOMPILE_AUTO" => "0",
        "MIPSTAR_SKIP_EXPLICIT_PRECOMPILE" => "1")
    log_path = joinpath(temporary, "runtime-mutant-$(index).log")
    started = time()
    process = open(log_path, "w") do log
        run(pipeline(ignorestatus(command), stdout=log, stderr=log))
    end
    output = read(log_path, String)
    test_started = occursin("MUTANT_TEST_STARTED", output)
    evidence_ok = mutant.expected_evidence === nothing ||
                  occursin(mutant.expected_evidence, output)
    killed = process.exitcode != 0 && test_started && evidence_ok
    assertion_failure = occursin("Test Failed", output) ||
                        occursin("Some tests did not pass", output)
    disposition = killed ? (assertion_failure ? "KILLED" :
                                                "KILLED-BY-CRASH") :
                  test_started ? "SURVIVED" : "LOAD-ERROR"
    println("MUTANT ", mutant.label, " target=", mutant.target, " => ",
            disposition, " (", round(time() - started; digits=2), " s)")
    killed || print(output)
    killed
end

started = time()
results = Pair{String,Bool}[]
mktempdir() do temporary
    mutation_depot = joinpath(temporary, "depot")
    mkpath(mutation_depot)
    index = 0
    for (name, mutants) in (("TB0", MUTANTS), ("TB1", TB1_MUTANTS),
                            ("TB2", TB2_MUTANTS))
        for mutant in mutants
            selected(mutant) || continue
            index += 1
            result = mutant.runtime_patch === nothing ?
                copied_mutant(mutant, index, temporary) :
                patched_process_mutant(mutant, index, temporary, mutation_depot)
            push!(results, "$name $(mutant.label)" => result)
        end
    end
end
@testset "isolated targeted mutations" begin
    @test all(last, results)
end
println("MUTATION REGISTRY: killed=", count(last, results), "/", length(results),
        " wall=", round(time() - started; digits=2), " s")
