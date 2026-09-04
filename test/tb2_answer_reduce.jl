using Test
using Random
using MIPStarLambda
Base.Experimental.@optlevel 0

const TB2_TARGET = get(ENV, "TB2_TARGET", "all")
tb2_runs(name) = TB2_TARGET == "all" || TB2_TARGET == name

const TB2_PARAMS = PCPParams(2048, 11, 1, 11, 6, 16, 1)
const TB2_DEGENERATE_TABLES = ((0, 1), (0, 0), (0, 0), (0, 0), (0, 0))
const TB2_NONDEGENERATE_TABLES = ((0, 1), (0, 1), (0, 1), (0, 1), (0, 1))
const TB2_FIXTURES = Dict{Symbol,Any}()
const TB2_REDUCTIONS = Dict{Symbol,Any}()

function tb2_source_fixture(witness::Symbol)
    get!(TB2_FIXTURES, witness) do
        if isdefined(Main, :polynomial_fixture)
            Main.polynomial_fixture(GF8, 6; witness)
        elseif witness == :nondegenerate
            built = tb0_build_nondegenerate_fixture(
                6, TB2_NONDEGENERATE_TABLES, MonomialBudget(2_500_000))
            built isa ExpansionRefused ? built : built.fixture
        else
            tb0_build_fixture(GF8, 6, TB2_DEGENERATE_TABLES,
                              MonomialBudget(160_000))
        end
    end
end

function tb2_proof(witness::Symbol)
    fixture = tb2_source_fixture(witness)
    fixture isa ExpansionRefused && error("TB2 fixture expansion refused")
    change_field(fixture.proof, GF2048, 11)
end

tb2_tf() = tb2_source_fixture(:degenerate).tf

function tb2_checked_reduction()
    get!(TB2_REDUCTIONS, :tb0) do
        original = trivial_original_verifier(GF2048, TB2_PARAMS, tb2_tf();
            n=2, T=1, Q_len=1, sigma=1, label=:tb0_trivial)
        answer_reduce_pcp(original, 1, 1, 1)
    end
end

tb2_atype(role, kind, copy) = AnswerReduceType(role, PCPType(kind, copy))

function tb2_seed(sampler, index::Int)
    ntuple(j -> GF2048(mod(37index + 13j + 1, 2048)), seed_dim(sampler))
end

function tb2_has_node(node, grade, rule)
    (node.grade == grade && node.rule == rule) ||
        any(child -> tb2_has_node(child, grade, rule), node.children)
end

function tb2_zero_answer(kind::PCPType)
    count = kind.copy == 6 ? TB2_PARAMS.m_prime + 6 : 1
    if kind.kind == :Point
        ntuple(_ -> zero(GF2048), count)
    else
        layout = VarLayout((:t,), (VarBlock(:LineParameter, 1:1),))
        p = zero_poly(GF2048, layout)
        ntuple(_ -> p, count)
    end
end

if tb2_runs("sampler")
    @testset "TB2 typed PCP sampler and product" begin
        @test tb2_sampler_invariant_report() ==
            (pcp_types=18, pcp_edges=324, pcp_complete=true,
             pcp_level=3, padded=true, intrinsic_ok=true,
             individual_dimensions=true, copy6=(16, 6, 16),
             source_repair=true, certificate=true, marginals=true,
             ora_types=3, ora_edges=9, ora_level=1, product_types=54,
             product_edges=2916, product_level=3)
        println("TB2 sampler: PCP types=18 edges=324 dims V6=(16,6,16) ",
                "SOURCE_REPAIR=true; product types=54 edges=2916 level=3")

        checked = tb2_checked_reduction()
        pcp = checked.term.pcp_sampler
        rng = MersenneTwister(0xC4B)
        seeds = [ntuple(_ -> rand(rng, field_elements(GF2048)), seed_dim(pcp))
                 for _ in 1:20]
        replay_ok = true
        for map in values(pcp.left), seed in seeds
            marginal = marginal_k(map, seed, level(map))
            factors = marginal.factor_spaces
            replay_ok &= length(factors) == level(map)
            replay_ok &= Set(Iterators.flatten(factors)) == Set(1:seed_dim(map))
            replay_ok &= sum(length, factors) == seed_dim(map)
            for stage in eachindex(factors)
                factor = factors[stage]
                local_input = ntuple(i -> seed[factor[i]], length(factor))
                expected_local = ntuple(row -> sum(
                    marginal.linear_maps[stage][row, column] * local_input[column]
                    for column in eachindex(local_input); init=zero(GF2048)),
                    length(factor))
                expected = fill(zero(GF2048), seed_dim(map))
                for (index, value) in zip(factor, expected_local)
                    expected[index] = value
                end
                replay_ok &= Tuple(expected) == marginal.outputs[stage]
            end
            replay_ok &= marginal.value == apply(map, seed)
        end
        @test replay_ok

        dline6 = pcp.left[PCPType(:DLine, 6)]
        foreach(seed -> apply(dline6, seed), seeds)
        elapsed = @elapsed for _ in 1:50, seed in seeds
            apply(dline6, seed)
        end
        apply_microseconds = elapsed * 1.0e6 / (50 * length(seeds))
        @test apply_microseconds < 1_000
        println("TB2 lazy CLStep replay: maps=18 seeds/map=20; DLine_6 apply=",
                round(apply_microseconds; digits=2), " us; peak RSS MiB=",
                round(Sys.maxrss() / 2^20; digits=1))

        @test passed(verify_certificate(checked))
        @test tb2_has_node(checked.certificate, ASSUMED, :AnswerReduceHypotheses)
        @test tb2_has_node(checked.certificate, SOURCE_REPAIR,
                           :PCPVerifierFixedFormula)
        @test tb2_has_node(checked.certificate, SOURCE_REPAIR,
                           :PCPGameOtherwiseFallthrough)
        @test tb2_has_node(checked.certificate, CITED,
                           :AnswerReduceQuantumContract)
        detyped = detype(checked)
        @test detyped.term.level == 5
        @test detyped.term.soundness_factor == big(16)^54
        @test detyped.certificate.grade == CITED
    end
end

if tb2_runs("parsers")
    @testset "TB2 table:tpcp parser round trips" begin
        @test tb2_parser_roundtrip_report() == (questions=18, answers=18)
        println("TB2 table:tpcp parsers: 18/18 question and answer formats round-trip")
    end
end

function tb2_answer_pair(reduced, proof, left_type, right_type, seed_index)
    seed = tb2_seed(reduced.sampler, seed_index)
    tb2_answer_pair_seed(reduced, proof, left_type, right_type, seed)
end

function tb2_answer_pair_seed(reduced, proof, left_type, right_type, seed)
    left_q, right_q = sample_answer_reduce_questions(
        reduced, left_type, right_type, seed)
    strategy = honest_pcp_strategy(proof, TB2_PARAMS)
    left_a = honest_pcp_answer(strategy, left_type.pcp, left_q.pcp)
    right_a = honest_pcp_answer(strategy, right_type.pcp, right_q.pcp)
    decision = typed_answer_reduced_decider(
        reduced.decider, left_type, left_q, right_type, right_q, left_a, right_a)
    (; decision, left_q, right_q, left_a, right_a)
end

function tb2_case_types(player::Symbol, left_current, right_other)
    player == :alice ? (left_current, right_other) : (right_other, left_current)
end

function tb2_trace_keys(decision)
    Set((entry.step, entry.branch, entry.player, entry.index, entry.line_kind)
        for entry in decision.trace)
end

if tb2_runs("branches")
    @testset "TB2 deterministic honest branch coverage" begin
        reduced = tb2_checked_reduction().term
        deg = tb2_proof(:degenerate)
        nd = tb2_proof(:nondegenerate)
        covered = Set{Tuple{Int,Symbol,Symbol,Int,Symbol}}()
        traces = Dict{Int,Any}()
        case_index = 10

        global_type = tb2_atype(:alice, :Point, 1)
        run = tb2_answer_pair(reduced, deg, global_type, global_type, case_index)
        @test passed(run.decision)
        union!(covered, tb2_trace_keys(run.decision))
        traces[1] = run
        case_index += 1

        for player in (:alice, :bob), role in (:alice, :bob)
            copy = role == :alice ? 1 : 2
            types = tb2_case_types(player,
                tb2_atype(:oracle, :Point, 6), tb2_atype(role, :Point, copy))
            run = tb2_answer_pair(reduced, deg, types..., case_index)
            @test passed(run.decision)
            union!(covered, tb2_trace_keys(run.decision))
            get!(traces, 2, run)
            case_index += 1
        end

        for player in (:alice, :bob), role in (:alice, :bob),
            line_kind in (:ALine, :DLine)
            copy = role == :alice ? 1 : 2
            types = tb2_case_types(player,
                tb2_atype(role, :Point, copy), tb2_atype(role, line_kind, copy))
            run = tb2_answer_pair(reduced, deg, types..., case_index)
            @test passed(run.decision)
            union!(covered, tb2_trace_keys(run.decision))
            get!(traces, 3, run)
            case_index += 1
        end

        for player in (:alice, :bob), i in 3:5
            types = tb2_case_types(player,
                tb2_atype(:oracle, :Point, i), tb2_atype(:oracle, :Point, 6))
            run = tb2_answer_pair(reduced, nd, types..., case_index)
            @test passed(run.decision)
            union!(covered, tb2_trace_keys(run.decision))
            get!(traces, 4, run)
            case_index += 1
        end
        for player in (:alice, :bob), i in 3:5, line_kind in (:ALine, :DLine)
            types = tb2_case_types(player,
                tb2_atype(:oracle, :Point, i), tb2_atype(:oracle, line_kind, i))
            run = tb2_answer_pair(reduced, nd, types..., case_index)
            @test passed(run.decision)
            union!(covered, tb2_trace_keys(run.decision))
            get!(traces, 4, run)
            case_index += 1
        end
        for player in (:alice, :bob), line_kind in (:ALine, :DLine)
            types = tb2_case_types(player,
                tb2_atype(:oracle, :Point, 6), tb2_atype(:oracle, line_kind, 6))
            run = tb2_answer_pair(reduced, deg, types..., case_index)
            @test passed(run.decision)
            union!(covered, tb2_trace_keys(run.decision))
            traces[4] = run
            case_index += 1
        end

        for player in (:alice, :bob)
            types = tb2_case_types(player,
                tb2_atype(:oracle, :Point, 6), tb2_atype(:bob, :Point, 2))
            run = tb2_answer_pair(reduced, deg, types..., case_index)
            @test passed(run.decision)
            union!(covered, tb2_trace_keys(run.decision))
            get!(traces, 5, run)
            case_index += 1
        end

        @test (1, :global_consistency, :both, 0, :none) in covered
        @test all((2, :input_consistency, player, role == :alice ? 1 : 2, :none)
                  in covered for player in (:alice, :bob), role in (:alice, :bob))
        @test all((3, line_kind == :ALine ? :input_axis : :input_diagonal,
                   player, role == :alice ? 1 : 2, line_kind) in covered
                  for player in (:alice, :bob), role in (:alice, :bob),
                      line_kind in (:ALine, :DLine))
        @test all((4, :proof_consistency, player, i, :none) in covered
                  for player in (:alice, :bob), i in 3:5)
        @test all((4, line_kind == :ALine ? :proof_individual_axis :
                                             :proof_individual_diagonal,
                   player, i, line_kind) in covered
                  for player in (:alice, :bob), i in 3:5,
                      line_kind in (:ALine, :DLine))
        @test all((4, line_kind == :ALine ? :proof_simultaneous_axis :
                                             :proof_simultaneous_diagonal,
                   player, 6, line_kind) in covered
                  for player in (:alice, :bob), line_kind in (:ALine, :DLine))
        @test all((5, :game, player, 6, :none) in covered
                  for player in (:alice, :bob))
        @test any(entry -> entry.ldparams == (2048, 1, 11, 1),
                  Iterators.flatten(run.decision.trace for run in values(traces)))
        @test any(entry -> entry.ldparams == (2048, 16, 11, 22),
                  Iterators.flatten(run.decision.trace for run in values(traces)))

        for step in 1:5
            run = traces[step]
            entries = filter(entry -> entry.step == step, run.decision.trace)
            println("TB2 TRACE step", step, " types=",
                    (run.decision.left_type, run.decision.right_type),
                    " questions=", (run.left_q, run.right_q),
                    " => ", [(entry.branch, entry.result.rule,
                               entry.ldparams) for entry in entries], " PASS")
        end
        println("TB2 deterministic branches: covered=", length(covered),
                " seeds=", case_index - 10,
                " every guard orientation and both ldparams PASS")
    end
end

if tb2_runs("seeded")
    @testset "TB2 256 conditioned seeded honest questions" begin
        reduced = tb2_checked_reduction().term
        deg = tb2_proof(:degenerate)
        nd = tb2_proof(:nondegenerate)
        triggering = [(left, right) for left in reduced.sampler.types
                                     for right in reduced.sampler.types
                                     if !isempty(answer_reduce_guard_branches(
                                         reduced.decider, left, right))]
        rng = MersenneTwister(0x18_20_48)
        accepted = true
        triggered = true
        seeds = Set{Any}()
        for index in 1:256
            left, right = rand(rng, triggering)
            proof = answer_reduce_requires_nondegenerate(
                reduced.decider, left, right) ? nd : deg
            seed = ntuple(_ -> rand(rng, field_elements(GF2048)),
                          seed_dim(reduced.sampler))
            push!(seeds, seed)
            run = tb2_answer_pair_seed(reduced, proof, left, right, seed)
            accepted &= passed(run.decision)
            triggered &= !isempty(run.decision.trace)
        end
        @test accepted
        @test triggered
        @test length(seeds) == 256
        println("TB2 seeded conditioned suite: RNG=0x182048 full-field seeds=256 accepted=256")
    end
end

if tb2_runs("no_check")
    @testset "TB2 unconditioned no-check fraction" begin
        reduced = tb2_checked_reduction().term
        total = length(reduced.sampler.types)^2
        no_check = count(isempty(answer_reduce_guard_branches(
            reduced.decider, left, right)) for left in reduced.sampler.types
                                            for right in reduced.sampler.types)
        @test (no_check, total) == (2736, 2916)
        @test no_check // total == 76 // 81
        println("TB2 no-check ordered type pairs: ", no_check, "/", total,
                " = 76/81 = ", round(100no_check / total; digits=3), "%")
    end
end

if tb2_runs("game") || tb2_runs("formula")
    @testset "TB2 step-5 original-game plumbing and formula mutation owner" begin
        reduced = tb2_checked_reduction().term
        proof = tb2_proof(:degenerate)
        left = tb2_atype(:oracle, :Point, 6)
        right = tb2_atype(:alice, :Point, 1)
        run = tb2_answer_pair(reduced, proof, left, right, 77)
        println("MUTATION_EXPECTED_RULE pcpverifier actual=",
                run.decision.result.rule, " passed=", passed(run.decision))
        @test passed(run.decision)
        game = only(entry for entry in run.decision.trace
                    if entry.step == 5 && entry.player == :alice)
        @test game.game_call !== nothing
        @test game.game_call.x_alice == apply(reduced.original_sampler.left,
                                               run.left_q.original)
        @test game.game_call.x_bob == apply(reduced.original_sampler.right,
                                             run.left_q.original)
        @test game.game_call.x_alice != game.game_call.x_bob
        @test game.result.rule == :pcpverifier
        specification = pcp_decider_specification(game.game_call)
        @test specification.x_alice == game.game_call.x_alice
        @test specification.x_bob == game.game_call.x_bob
        view = PCPView(collect(run.left_q.pcp.point),
            ntuple(i -> run.left_a[i], 5), run.left_a[6],
            ntuple(i -> run.left_a[6 + i], TB2_PARAMS.m_prime))
        swapped = PCPGameCall(game.game_call.D, game.game_call.n,
            game.game_call.T_bound, game.game_call.Q_len,
            game.game_call.sigma, game.game_call.gamma,
            game.game_call.x_bob, game.game_call.x_alice,
            game.game_call.formula)
        fixed_result = pcpverifier(game.game_call, view)
        swapped_result = pcpverifier(swapped, view)
        @test (fixed_result.ok, fixed_result.formula_ok, fixed_result.zero_ok) ==
              (swapped_result.ok, swapped_result.formula_ok, swapped_result.zero_ok)
        println("TB2 game call: oracle seed=", run.left_q.original,
                " -> original decider x=", game.game_call.x_alice,
                " y=", game.game_call.x_bob,
                "; pcpverifier rule=", game.result.rule, " PASS")
    end
end

if tb2_runs("proof_consistency")
    @testset "TB2 g3 individual/bundle consistency mutation owner" begin
        reduced = tb2_checked_reduction().term
        proof = tb2_proof(:nondegenerate)
        types = (tb2_atype(:oracle, :Point, 3),
                 tb2_atype(:oracle, :Point, 6))
        run = tb2_answer_pair(reduced, proof, types..., 91)
        println("MUTATION_EXPECTED_RULE proof_consistency actual=",
                run.decision.result.rule, " passed=", passed(run.decision))
        @test passed(run.decision)
        @test any(entry -> entry.branch == :proof_consistency && entry.index == 3,
                  run.decision.trace)
    end
end


if tb2_runs("line")
    @testset "TB2 line-polynomial truncation mutation owner" begin
        reduced = tb2_checked_reduction().term
        proof = tb2_proof(:nondegenerate)
        types = (tb2_atype(:oracle, :Point, 3),
                 tb2_atype(:oracle, :ALine, 3))
        run = tb2_answer_pair(reduced, proof, types..., 103)
        println("MUTATION_EXPECTED_RULE ld_axis_point actual=",
                run.decision.result.rule, " passed=", passed(run.decision))
        @test passed(run.decision)
        @test any(entry -> entry.result.rule == :ld_axis_point,
                  run.decision.trace)
    end
end

if tb2_runs("guard")
    @testset "TB2 Point_i/ALine_i guard degree-format mutation owner" begin
        reduced = tb2_checked_reduction().term
        proof = tb2_proof(:nondegenerate)
        types = (tb2_atype(:oracle, :Point, 3),
                 tb2_atype(:oracle, :ALine, 3))
        run = tb2_answer_pair(reduced, proof, types..., 119)
        layout = VarLayout((:t,), (VarBlock(:LineParameter, 1:1),))
        overdegree = polyvar(GF2048, layout, 1)^12
        bad_line = (overdegree,)
        rejected = typed_answer_reduced_decider(
            reduced.decider, types[1], run.left_q, types[2], run.right_q,
            run.left_a, bad_line)
        println("MUTATION_EXPECTED_RULE ld_axis_degree actual=",
                rejected.result.rule, " passed=", passed(rejected))
        @test !passed(rejected)
        @test rejected.result.rule == :ld_axis_degree
    end
end


if tb2_runs("dline_projection")
    @testset "TB2 honest DLine answers project an unprojected direction" begin
        proof = tb2_proof(:degenerate)
        strategy = honest_pcp_strategy(proof, TB2_PARAMS)
        kind = PCPType(:DLine, 6)
        base = ntuple(_ -> zero(GF2048), TB2_PARAMS.m_prime)
        direction = ntuple(_ -> one(GF2048), TB2_PARAMS.m_prime)
        coordinate = GF2048(700) # chi=6, so the first five entries are removed
        question = PCPDLineQuestion(base, coordinate, direction)
        line_answer = honest_pcp_answer(strategy, kind, question)
        projected = AffineLine(base,
            pi_prefix(direction, chi(coordinate, TB2_PARAMS.m_prime) - 1))
        point = line_point(projected, GF2048(3))
        point_question = PCPPointQuestion(point)
        point_answer = honest_pcp_answer(strategy, PCPType(:Point, 6),
                                         point_question)
        result = ld_decider(LDParams(GF2048, 16, 11, 22),
            :DLine, pcp_ld_question(question), :Point,
            pcp_ld_question(point_question), line_answer, point_answer)
        @test passed(result)
        @test result.rule == :ld_diagonal_point
    end
end

if tb2_runs("i345")
    @testset "TB2 structural guard set i in {3,4,5} (M-i345 owner)" begin
        reduced = tb2_checked_reduction().term
        @test proof_individual_guard_copies(reduced.decider) == (3, 4, 5)
        println("TB2 structural guard table: individual copies=(3,4,5) exactly")
    end
end
