using Test

# Every mutant runs in its OWN Julia process against the real precompiled
# package: the process loads `MIPStarLambda` from the package image, then
# re-evaluates only the mutated source file inside the module (so only that
# file's methods and their dependents recompile), and finally includes the
# rung's test file with its target selected. A mutant of a test file runs the
# mutated copy of that file instead. The working tree is never modified.
#
# Unmutated first: before any kill is credited, the mutant's target testset is
# run UNMUTATED in the same isolated way (once per distinct target) and must
# exit 0. A mutant whose target is broken on clean code is reported
# UNATTRIBUTABLE, never KILLED, and fails the registry — "no mutation is
# credited merely because an unrelated test fails" (DESIGN.md section 5.1).
#
# Scoring: KILLED needs a passing baseline, a nonzero exit AFTER the
# "MUTANT_TEST_STARTED" marker (so a load/mutation failure is LOAD-ERROR,
# never a kill), plus the mutant's expected evidence line when one is
# registered (the named rejection rule). A nonzero exit without a failed
# `@test` is KILLED-BY-CRASH.

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
    # verdicts/tb0-r2.md section 4: the critic's surviving mutations, now
    # permanent (X1/X1b -> N3, X2 -> N5, X3 -> N5, X4 -> N4).
    Mutant("X1 pcpverifier_hardcodes_sign_block", "src/verifiers/pcp.jl",
           "sign_coordinates = block_coordinates(tf.layout, :O)",
           "sign_coordinates = 6:10", "layout_m2"),
    Mutant("X1b build_c0_hardcodes_sign_block", "src/verifiers/pcp.jl",
           "sign_coordinates = block_coordinates(farith.layout, :O)",
           "sign_coordinates = 6:10", "layout_m2"),
    Mutant("X2 change_field_mislabels_d", "src/verifiers/pcp.jl",
           "decomposition, d, proof.tf,\n                       _certified_views",
           "decomposition, 1, proof.tf,\n                       _certified_views", "field_change"),
    Mutant("X3 empty_view_replay_accepts", "src/verifiers/pcp.jl",
           "isempty(proof.certified_views) &&\n        return CheckResult(false, :pcpverifier_replay;",
           "isempty(proof.certified_views) &&\n        return CheckResult(true, :pcpverifier_replay;", "certificate"),
    Mutant("X4 tseitin_replay_wrong_vector", "src/ir/circuits.jl",
           "counts[node.variable] += 1",
           "counts[node.variable] = 1", "certificate"),
    # verdicts/tb0-r2.md N1: witness (iii) owners.
    Mutant("N checker_accepts_nonzero_remainder", "src/polynomials/zero_basis.jl",
           "CheckResult(identity && zero_remainder, :coefficient_identity;",
           "CheckResult(identity, :coefficient_identity;", "witness_iii"),
    Mutant("O phi_C_ignores_unsatisfied_clause", "src/ir/circuits.jl",
           "satisfied || return false",
           "satisfied || continue", "witness_iii"),
    # verdicts/tb0-r2.md N4: owner of witness (i)'s restored quotient split.
    Mutant("Q skip_degree_two_rewrite", "src/polynomials/zero_basis.jl",
           "if exponent < 2\n                _accumulate!(next_remainder, key, coefficient)",
           "if exponent < 3\n                _accumulate!(next_remainder, key, coefficient)", "pcp"),
    # verdicts/tb0-r3.md N8 (NM4): the certified separator moves O2 -> O3,
    # where deleting g_2 - o_2 no longer changes beta_0 and mutant B would
    # be silently disarmed; owned by testset 5a's fixture-computed value.
    Mutant("S separator_moved_O2_to_O3", "src/tb0.jl",
           "separator[7] = primitive_element(F)",
           "separator[8] = primitive_element(F)", "pcp_separator"),
    # verdicts/tb0-r3.md N9 (NM3): ev_z's block-locality guard removed.
    Mutant("NM3 ev_z_drops_block_locality_guard", "src/verifiers/pcp.jl",
           "dependency_coordinates(proof.gs[i]) <= coordinates ||",
           "true ||", "certificate"),
    # verdicts/tb0-r3.md N10: constructor evidence detached from the proof
    # again, so a borrowed certificate replays the other proof's sub-terms.
    Mutant("P bind_certificate_detached", "src/verifiers/pcp.jl",
           "proof -> locate(proof) === anchor ? node.replay(term) :",
           "proof -> true ? node.replay(term) :", "witness_iii"),
    # verdicts/tb0-r4.md N13 (R4M3): the root def:pcp-proof replay drops the
    # quotients c_1..c_m'; owned by testset 5c's over-degree c_16.
    Mutant("R4M3 pcp_degree_replay_drops_quotients", "src/verifiers/pcp.jl",
           "function _replay_pcp_degree(proof::PCPProof)\n    polynomials = (proof.gs..., proof.c0, proof.cs...)",
           "function _replay_pcp_degree(proof::PCPProof)\n    polynomials = (proof.gs..., proof.c0)",
           "certificate"),
    # N14 (R4M5): all five :MultilinearExtension anchors collapse to g_1;
    # owned by testset 5c's g_3-swap chimera.
    Mutant("R4M5 multilinear_anchors_collapse_to_g1", "src/verifiers/pcp.jl",
           "(proof -> proof.gs[i]), gs[i]",
           "(proof -> proof.gs[1]), gs[1]", "certificate"),
    # N15 (R4M2): the constructor's stored views bypass ev_z; owned by
    # testset 5c's build_pcp refusal on the locality-violating g_1.
    Mutant("R4M2 certified_views_bypass_ev_z", "src/verifiers/pcp.jl",
           "map(point -> ev_z(proof, point), certified_points)",
           "map(point -> _pcp_view(proof.gs, proof.c0, proof.cs, point), certified_points)",
           "certificate"),
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
# verdicts/tb1-r2.md N1-N6 and the DESIGN 9 preparation (brief 46).
include("tb1_dline_degree.jl")
include("tb1_child_validation.jl")
include("tb1_ambient_doblock.jl")
include("tb1_space_sum.jl")
include("tb1_pad_order.jl")
include("tb1_chifree.jl")
include("tb1_describe_closure.jl")
include("tb1_factor_indicator.jl")
include("tb1_linear_narrowed.jl")
include("tb1_replay_skips_k.jl")
include("tb1_replay_skips_union.jl")
include("tb1_memo_unbounded.jl")
# verdicts/tb1-r3.md N12, N13, N17 (brief 54).
include("tb1_describe_matrix.jl")
include("tb1_prefix_walk.jl")
include("tb1_factor_reachability.jl")
include("tb2_formula.jl")
include("tb2_g3.jl")
include("tb2_line.jl")
include("tb2_guard.jl")
include("tb2_i345.jl")
include("tb2_mc1.jl")
include("tb2_mc2.jl")
include("tb2_mc3.jl")
# verdicts/tb2-r2.md N1, N2, N5 and the DESIGN 9 preparation (brief 46).
include("tb2_nd2.jl")
include("tb2_nd4.jl")
include("tb2_tensor.jl")
include("tb2_opaque.jl")
# verdicts/tb2-r3.md N6, N10 (brief 54).
include("tb2_describe_byaxis_collapse.jl")
include("tb2_guard_split.jl")
# briefs/23-tb3.md: the five TB3 front-end mutants.
include("tb3_acc.jl")
include("tb3_size.jl")
include("tb3_fuel.jl")
include("tb3_decouple.jl")
include("tb3_closure.jl")

const TB1_MUTANTS = (TB1_CHI_MUTANT, TB1_PI_MUTANT, TB1_LNF_MUTANT,
                     TB1_DEG_MUTANT, TB1_LEVEL_MUTANT,
                     TB1_AGREEMENT_MUTANT, TB1_SYMMETRY_MUTANT,
                     TB1_VERIFIER_PI_MUTANT, TB1_ONLINE_MUTANT,
                     TB1_QUESTION_ARITY_MUTANT, TB1_CONCAT_MUTANT,
                     TB1_REPAIR_MUTANT, TB1_AMBIENT_MUTANT, TB1_DSUM_MUTANT,
                     TB1_KAPPA_MUTANT,
                     TB1_DLINE_DEGREE_MUTANT, TB1_CHILD_VALIDATION_MUTANT,
                     TB1_AMBIENT_DOBLOCK_MUTANT, TB1_SPACE_SUM_MUTANT,
                     TB1_PAD_ORDER_MUTANT, TB1_CHIFREE_MUTANT,
                     TB1_DESCRIBE_CLOSURE_MUTANT, TB1_FACTOR_INDICATOR_MUTANT,
                     TB1_LINEAR_NARROWED_MUTANT, TB1_REPLAY_SKIPS_K_MUTANT,
                     TB1_REPLAY_SKIPS_UNION_MUTANT, TB1_MEMO_UNBOUNDED_MUTANT,
                     TB1_DESCRIBE_MATRIX_MUTANT, TB1_PREFIX_WALK_MUTANT,
                     TB1_FACTOR_REACHABILITY_MUTANT)
const TB2_MUTANTS = (TB2_FORMULA_MUTANT, TB2_G3_MUTANT, TB2_LINE_MUTANT,
                     TB2_GUARD_MUTANT, TB2_I345_MUTANT,
                     TB2_MC1_MUTANT, TB2_MC2_MUTANT, TB2_MC3_MUTANT,
                     TB2_ND2_MUTANT, TB2_ND4_MUTANT, TB2_TENSOR_MUTANT,
                     TB2_OPAQUE_MUTANT, TB2_DESCRIBE_BYAXIS_COLLAPSE_MUTANT,
                     TB2_GUARD_SPLIT_MUTANT)
const TB3_MUTANTS = (TB3_ACC_MUTANT, TB3_SIZE_MUTANT, TB3_FUEL_MUTANT,
                     TB3_DECOUPLE_MUTANT, TB3_CLOSURE_MUTANT)

function _rung(mutant::Mutant)
    startswith(mutant.target, "tb3_") && return (:tb3, "tb3_frontend.jl",
        "TB3_TARGET", mutant.target)
    startswith(mutant.target, "tb2_") && return (:tb2, "tb2_answer_reduce.jl",
        "TB2_TARGET", replace(mutant.target, "tb2_" => ""))
    startswith(mutant.target, "tb1_") && return (:tb1, "tb1_ld_sampler.jl",
        "TB1_TARGET", replace(mutant.target, "tb1_" => ""))
    (:tb0, "tb0_core.jl", "TB0_TARGET", mutant.target)
end

# The unmutated baseline is keyed by (test file, target variable, target
# name): every mutant sharing a target shares one baseline run.
baseline_key(mutant::Mutant) = _rung(mutant)[2:4]

# One isolated Julia process: load the package image, apply `patch` (a
# `Base.include` of the mutated source file, or nothing), print the marker,
# include the test file with the target selected.
function run_isolated(sandbox::String, test_path::String, patch::String,
                      target_variable::String, target_name::String)
    mkpath(sandbox)
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
    (; exitcode=process.exitcode, output,
       seconds=round(time() - started; digits=2),
       test_started=occursin("MUTANT_TEST_STARTED", output))
end

function unmutated_baseline(key, index::Int, temporary::String)
    test_name, target_variable, target_name = key
    result = run_isolated(joinpath(temporary, "baseline-$(index)"),
                          joinpath(ROOT, "test", test_name), "",
                          target_variable, target_name)
    ok = result.exitcode == 0 && result.test_started
    println("BASELINE ", test_name, " ", target_variable, "=", target_name,
            " => ", ok ? "OK" : "BROKEN", " (exit=", result.exitcode, ", ",
            result.seconds, " s)")
    ok || print(result.output)
    (; ok, result.exitcode, result.seconds)
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
    result = run_isolated(sandbox, test_path, patch, target_variable, target_name)
    println("MUTANT-RUN ", mutant.label, " target=", mutant.target,
            " (exit=", result.exitcode, ", ", result.seconds, " s)")
    result
end

# Disposition needs the baseline: a kill is credited only when the same
# target exits 0 unmutated.
function disposition(mutant::Mutant, result, baseline)
    evidence_ok = mutant.expected_evidence === nothing ||
                  occursin(mutant.expected_evidence, result.output)
    failed_after_start = result.exitcode != 0 && result.test_started
    assertion_failure = occursin("Test Failed", result.output) ||
                        occursin("Some tests did not pass", result.output)
    if !baseline.ok
        return (; killed=false,
                  label="UNATTRIBUTABLE (target exits $(baseline.exitcode) unmutated)")
    end
    killed = failed_after_start && evidence_ok
    label = killed ? (assertion_failure ? "KILLED" : "KILLED-BY-CRASH") :
            result.test_started ? "SURVIVED" : "LOAD-ERROR"
    (; killed, label)
end

started = time()
# Warm the package image once so no mutant process pays for precompilation.
run(`$(Base.julia_cmd()) --startup-file=no --project=$(ROOT) -e "using MIPStarLambda"`)
println("package image ready after ", round(time() - started; digits=2), " s")
queue = Tuple{String,Mutant}[]
for (name, mutants) in (("TB0", MUTANTS), ("TB1", TB1_MUTANTS),
                        ("TB2", TB2_MUTANTS), ("TB3", TB3_MUTANTS)), mutant in mutants
    selected(mutant) && push!(queue, (name, mutant))
end
baseline_keys = unique(baseline_key(mutant) for (_, mutant) in queue)
jobs = vcat([(:baseline, key) for key in baseline_keys],
            [(:mutant, entry) for entry in queue])
outcomes = mktempdir() do temporary
    asyncmap(enumerate(jobs); ntasks=MUTATION_JOBS) do (index, job)
        kind, payload = job
        kind == :baseline ? unmutated_baseline(payload, index, temporary) :
                            isolated_mutant(last(payload), index, temporary)
    end
end
baselines = Dict(key => outcomes[i] for (i, key) in enumerate(baseline_keys))
results = map(enumerate(queue)) do (i, entry)
    name, mutant = entry
    result = outcomes[length(baseline_keys) + i]
    verdict = disposition(mutant, result, baselines[baseline_key(mutant)])
    println("MUTANT ", mutant.label, " target=", mutant.target, " => ",
            verdict.label, " (exit=", result.exitcode, ", ", result.seconds, " s)")
    verdict.killed || print(result.output)
    "$name $(mutant.label)" => verdict.killed
end
@testset "isolated targeted mutations" begin
    @test all(baseline.ok for baseline in values(baselines))
    @test all(last, results)
end
println("MUTATION REGISTRY: killed=", count(last, results), "/", length(results),
        " baselines ok=", count(b -> b.ok, values(baselines)), "/", length(baselines),
        " wall=", round(time() - started; digits=2), " s")
