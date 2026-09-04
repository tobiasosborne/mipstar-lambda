using Test

# Every mutant runs in its OWN Julia process against the real precompiled
# package: the process loads `MIPStarLambda` from the package image, then
# re-evaluates only the mutated source file inside the module (so only that
# file's methods and their dependents recompile), and finally includes the
# rung's test file with its target selected. A mutant of a test file runs the
# mutated copy of that file instead. The working tree is never modified.
#
# Scoring: KILLED needs a nonzero exit AFTER the "MUTANT_TEST_STARTED" marker
# (so a load/mutation failure is LOAD-ERROR, never a kill), plus the mutant's
# expected evidence line when one is registered (the named rejection rule).
# A nonzero exit without a failed `@test` is KILLED-BY-CRASH.

const ROOT = normpath(joinpath(@__DIR__, "..", ".."))
const MUTATION_FILTER = get(ENV, "MUTATION_FILTER", "")
# Mutant processes are independent, so up to MUTATION_JOBS run concurrently.
const MUTATION_JOBS = max(1, parse(Int, get(ENV, "MUTATION_JOBS", "4")))
selected(mutant) = isempty(MUTATION_FILTER) || occursin(MUTATION_FILTER, mutant.label)

struct Mutant
    label::String
    source::String
    before::String
    after::String
    target::String
    expected_evidence::Union{Nothing,String}
end

Mutant(label, source, before, after, target) =
    Mutant(label, source, before, after, target, nothing)

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
include("tb1_repair.jl")
include("tb1_ambient.jl")
include("tb1_dsum.jl")
include("tb1_kappa.jl")
include("tb2_formula.jl")
include("tb2_g3.jl")
include("tb2_line.jl")
include("tb2_guard.jl")
include("tb2_i345.jl")
include("tb2_mc1.jl")
include("tb2_mc2.jl")
include("tb2_mc3.jl")

const TB1_MUTANTS = (TB1_CHI_MUTANT, TB1_PI_MUTANT, TB1_LNF_MUTANT,
                     TB1_DEG_MUTANT, TB1_LEVEL_MUTANT,
                     TB1_AGREEMENT_MUTANT, TB1_SYMMETRY_MUTANT,
                     TB1_VERIFIER_PI_MUTANT, TB1_ONLINE_MUTANT,
                     TB1_QUESTION_ARITY_MUTANT, TB1_CONCAT_MUTANT,
                     TB1_REPAIR_MUTANT, TB1_AMBIENT_MUTANT, TB1_DSUM_MUTANT,
                     TB1_KAPPA_MUTANT)
const TB2_MUTANTS = (TB2_FORMULA_MUTANT, TB2_G3_MUTANT, TB2_LINE_MUTANT,
                     TB2_GUARD_MUTANT, TB2_I345_MUTANT,
                     TB2_MC1_MUTANT, TB2_MC2_MUTANT, TB2_MC3_MUTANT)

function _rung(mutant::Mutant)
    startswith(mutant.target, "tb2_") && return (:tb2, "tb2_answer_reduce.jl",
        "TB2_TARGET", replace(mutant.target, "tb2_" => ""))
    startswith(mutant.target, "tb1_") && return (:tb1, "tb1_ld_sampler.jl",
        "TB1_TARGET", replace(mutant.target, "tb1_" => ""))
    (:tb0, "tb0_core.jl", "TB0_TARGET", mutant.target)
end

function isolated_mutant(mutant::Mutant, index::Int, temporary::String)
    _, test_name, target_variable, target_name = _rung(mutant)
    sandbox = joinpath(temporary, "mutant-$(index)")
    mkpath(sandbox)

    original = read(joinpath(ROOT, mutant.source), String)
    occurrences = count(mutant.before, original)
    occurrences == 1 || error("mutation $(mutant.label) matched $occurrences source sites")
    mutated_path = joinpath(sandbox, basename(mutant.source))
    write(mutated_path, replace(original, mutant.before => mutant.after; count=1))

    test_path = joinpath(ROOT, "test", test_name)
    patch = if startswith(mutant.source, "src/")
        "Base.include(MIPStarLambda, $(repr(mutated_path)))\n"
    elseif mutant.source == "test/" * test_name
        test_path = mutated_path
        ""
    else
        error("mutation $(mutant.label) targets a file outside its rung: $(mutant.source)")
    end
    script = joinpath(sandbox, "run.jl")
    write(script, "using Test, MIPStarLambda\n" * patch *
                  "println(\"MUTANT_TEST_STARTED\")\n" *
                  "include($(repr(test_path)))\n")

    command = addenv(`$(Base.julia_cmd()) --startup-file=no --project=$(ROOT) $script`,
                     target_variable => target_name,
                     "JULIA_PKG_PRECOMPILE_AUTO" => "0")
    log_path = joinpath(sandbox, "output.log")
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
    disposition = killed ? (assertion_failure ? "KILLED" : "KILLED-BY-CRASH") :
                  test_started ? "SURVIVED" : "LOAD-ERROR"
    println("MUTANT ", mutant.label, " target=", mutant.target, " => ",
            disposition, " (exit=", process.exitcode, ", ",
            round(time() - started; digits=2), " s)")
    killed || print(output)
    killed
end

started = time()
# Warm the package image once so no mutant process pays for precompilation.
run(`$(Base.julia_cmd()) --startup-file=no --project=$(ROOT) -e "using MIPStarLambda"`)
println("package image ready after ", round(time() - started; digits=2), " s")
queue = Tuple{String,Mutant}[]
for (name, mutants) in (("TB0", MUTANTS), ("TB1", TB1_MUTANTS),
                        ("TB2", TB2_MUTANTS)), mutant in mutants
    selected(mutant) && push!(queue, (name, mutant))
end
results = mktempdir() do temporary
    asyncmap(enumerate(queue); ntasks=MUTATION_JOBS) do (index, entry)
        name, mutant = entry
        "$name $(mutant.label)" => isolated_mutant(mutant, index, temporary)
    end
end
@testset "isolated targeted mutations" begin
    @test all(last, results)
end
println("MUTATION REGISTRY: killed=", count(last, results), "/", length(results),
        " wall=", round(time() - started; digits=2), " s")
