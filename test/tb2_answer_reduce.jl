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
    change_field(fixture.proof, GF2048, 11).term
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

# Count described :Step terms whose factor register is empty (a promoted zero
# map would show one; BranchPadded's appended stages are implicit).
function tb2_empty_factor_steps(term)
    term isa Tuple || return 0
    tag = term[1]
    tag == :Zero && return 0
    tag == :Step && return (isempty(term[3]) ? 1 : 0) + tb2_empty_factor_steps(term[6])
    tag == :Const && return tb2_empty_factor_steps(term[2])
    tag == :ByAxis && return sum(tb2_empty_factor_steps, term[4]; init=0)
    tag == :Lnf && return tb2_empty_factor_steps(term[4])
    tag == :Padded && return tb2_empty_factor_steps(term[3])
    error("unknown description term")
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

function tb2_hand_split(verifier, side::Symbol, kind, seed)
    # The r1/r2 explicit seed split, kept only as the reference the product
    # projection must agree with (verdicts/tb2-r2.md N1).
    original_dimension = seed_dim(verifier.original_sampler.left)
    original_seed = ntuple(i -> seed[i], original_dimension)
    pcp_seed = ntuple(i -> seed[original_dimension + i],
                      seed_dim(verifier.pcp_sampler))
    ora_maps = side == :left ? verifier.oracularized_sampler.left :
                               verifier.oracularized_sampler.right
    pcp_maps = side == :left ? verifier.pcp_sampler.left : verifier.pcp_sampler.right
    AnswerReduceQuestion(apply(ora_maps[kind.role], original_seed),
        pcp_question_from_ambient(verifier.pcp_sampler, kind.pcp,
                                  apply(pcp_maps[kind.pcp], pcp_seed)))
end

if tb2_runs("sampler")
    @testset "TB2 typed PCP sampler and product" begin
        report = tb2_sampler_invariant_report()
        println("MUTATION_EXPECTED_RULE product_edges actual=", report.product_edges)
        @test report ==
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
        # verdicts/tb1-r2.md N7: the figure above is a warm-memo figure; time
        # fresh seeds too (each reaches an unseen direction-stage key).
        fresh = [ntuple(_ -> rand(rng, field_elements(GF2048)), seed_dim(pcp))
                 for _ in 1:1000]
        fresh_elapsed = @elapsed for seed in fresh
            apply(dline6, seed)
        end
        fresh_microseconds = fresh_elapsed * 1.0e6 / length(fresh)
        @test fresh_microseconds < 1_000
        println("TB2 lazy CLStep replay: maps=18 seeds/map=20; DLine_6 apply=",
                round(apply_microseconds; digits=2), " us (warm memo, 20 seeds x 50); ",
                round(fresh_microseconds; digits=2), " us (1000 fresh seeds); peak RSS MiB=",
                round(Sys.maxrss() / 2^20; digits=1))

        # verdicts/tb2-r2.md N1: the questions judged ARE the product
        # sampler's questions; the hand split is now only a reference.
        verifier = checked.term
        product_rng = MersenneTwister(0x54)
        product_seeds = [ntuple(_ -> rand(product_rng, field_elements(GF2048)),
                                seed_dim(verifier.sampler)) for _ in 1:20]
        agrees = true
        compared = 0
        for kind in verifier.sampler.types, seed in product_seeds
            left_q, right_q = sample_answer_reduce_questions(verifier, kind, kind, seed)
            agrees &= left_q == tb2_hand_split(verifier, :left, kind, seed)
            agrees &= right_q == tb2_hand_split(verifier, :right, kind, seed)
            drawn = sample(verifier.sampler, (kind, kind), seed)
            agrees &= drawn.left_question == apply(verifier.sampler.left[kind], seed)
            compared += 1
        end
        println("MUTATION_EXPECTED_RULE product_projection agrees=", agrees,
                " compared=", compared)
        @test agrees
        @test compared == 54 * 20
        # verdicts/tb2-r2.md N5: E^ar = E^ora x E^pcp (tensor rule), which
        # equals the complete 54^2 graph here because both factors are complete.
        complete = Set((a, b) for a in verifier.sampler.types
                              for b in verifier.sampler.types)
        @test Set(verifier.sampler.type_graph) == complete
        @test length(verifier.sampler.type_graph) == 2916
        @test (tb2_atype(:oracle, :Point, 1), tb2_atype(:alice, :DLine, 6)) in
              Set(verifier.sampler.type_graph)
        @test_throws ArgumentError edge_index(verifier.oracularized_sampler,
                                              (:oracle, :nobody))

        certificate = verify_certificate(checked)
        println("MUTATION_EXPECTED_RULE certificate rule=", certificate.rule,
                " passed=", passed(certificate))
        @test passed(certificate)
        # verdicts/tb2-r2.md N2: the CHECKED replay now asserts an honest
        # accept and a corrupted reject with the expected rule per guard.
        replay = MIPStarLambda._answer_reduce_replay(verifier)
        @test passed(replay)
        @test length(replay.actual.outcomes) == 9
        @test [o[4] for o in replay.actual.outcomes] ==
              [:global_consistency, :input_consistency, :ld_axis_point,
               :ld_diagonal_point, :proof_consistency, :ld_diagonal_point,
               :ld_axis_point, :ld_diagonal_point, :pcpverifier]
        @test all(o[2] && !o[3] for o in replay.actual.outcomes)
        println("TB2 certificate replay outcomes: ", replay.actual.outcomes)
        @test tb2_has_node(checked.certificate, ASSUMED, :AnswerReduceHypotheses)
        @test tb2_has_node(checked.certificate, SOURCE_REPAIR,
                           :PCPVerifierFixedFormula)
        @test tb2_has_node(checked.certificate, SOURCE_REPAIR,
                           :PCPGameOtherwiseFallthrough)
        @test tb2_has_node(checked.certificate, CITED,
                           :AnswerReduceQuantumContract)
        # verdicts/tb2-r3.md N7: TB2 never promotes a zero map. Every zero map
        # in its source maps is a chain terminal on the empty register, the
        # 18 PCP maps are padded by BranchPadded, the three oracularized maps
        # are level-1 CLSteps, and all 54 products are level 3 before
        # TypedSampler pads; so no certificate carries the promotion node.
        @test all(level(map) == 3 for map in values(verifier.pcp_sampler.left))
        @test all(level(map) == 1 for map in values(verifier.oracularized_sampler.left))
        @test all(level(direct_sum(verifier.oracularized_sampler.left[kind.role],
                                   verifier.pcp_sampler.left[kind.pcp])) == 3
                  for kind in verifier.sampler.types)
        @test !tb2_has_node(checked.certificate, SOURCE_REPAIR,
                            :zero_map_factor_partition)
        detyped = detype(checked)
        @test detyped.term.level == 5
        @test detyped.term.soundness_factor == big(16)^54
        @test detyped.certificate.grade == CITED
    end
end

if tb2_runs("describe")
    @testset "TB2 DESIGN 9 describability, chain-set replay, memo bound" begin
        pcp = pcp_sampler(GF2048, TB2_PARAMS).term
        kinds = [PCPType(kind, i) for kind in (:Point, :ALine, :DLine) for i in 1:6]
        sizes = Dict{PCPType,Int}()
        describable = 0
        for kind in kinds
            description = describe_cl(pcp.left[kind])
            description isa CLDescription || continue
            describable += 1
            sizes[kind] = description_size(description)
            @test description.level == 3
            @test canonical_bytes(describe_cl(pcp.left[kind])) ==
                  canonical_bytes(description)
        end
        println("MUTATION_EXPECTED_RULE describable actual=", describable, "/18")
        @test describable == 18
        # verdicts/tb2-r3.md N6 (a): the five exact sizes, reproduced by the
        # critic's independent reserialization (verdicts/tb2-r3.md 2.5).
        @test all(sizes[PCPType(:Point, i)] == 3009 for i in 1:6)
        @test all(sizes[PCPType(:ALine, i)] == 2893 for i in 1:5)
        @test sizes[PCPType(:ALine, 6)] == 10228
        @test all(sizes[PCPType(:DLine, i)] == 2754 for i in 1:5)
        @test sizes[PCPType(:DLine, 6)] == 10479
        # (b) the 18 canonical byte strings are pairwise distinct.
        @test length(Set(canonical_bytes(describe_cl(pcp.left[kind])) for kind in kinds)) == 18
        # The copy-6 BranchByAxis tables hold m'=16 pairwise-distinct child
        # terms, and no described stage has an empty factor register: all
        # padding is the implicit :Padded branch, none is a promoted zero map.
        aline6_branch = describe_cl(pcp.left[PCPType(:ALine, 6)]).term[6]
        dline6_branch = describe_cl(pcp.left[PCPType(:DLine, 6)]).term[6]
        @test aline6_branch[1] == :Padded && aline6_branch[3][1] == :ByAxis
        @test dline6_branch[1] == :ByAxis
        @test length(Set(aline6_branch[3][4])) == 16
        @test length(Set(dline6_branch[4])) == 16
        @test all(tb2_empty_factor_steps(describe_cl(pcp.left[kind]).term) == 0
                  for kind in kinds)
        println("TB2 describe: description_size ",
                join(("$(kind)=$(sizes[kind])" for kind in kinds), " "))

        # Declared branch-directed chain set (DESIGN 9.2): one seed per
        # chi(s_aux, 16) bucket plus 20 RNG seeds.
        layout = pcp.metadata.pcp_layout
        rng = MersenneTwister(0x9C)
        chain_seeds = Any[]
        for axis in 1:16
            seed = collect(ntuple(_ -> rand(rng, field_elements(GF2048)), seed_dim(pcp)))
            seed[layout.auxiliary_coordinate] = GF2048((axis - 1) * 128 + 7)
            push!(chain_seeds, Tuple(seed))
        end
        for _ in 1:20
            push!(chain_seeds, ntuple(_ -> rand(rng, field_elements(GF2048)),
                                      seed_dim(pcp)))
        end
        chain_set_id = "tb2-chi16-directed+rng20(0x9C)"
        replays = Dict{PCPType,Any}()
        for kind in kinds
            replays[kind] = cl_kth_replay(pcp.left[kind], chain_seeds; chain_set_id)
            @test replays[kind].space_sum_ok
            @test replays[kind].map_sum_ok
            @test replays[kind].completed_replays == 36
            @test replays[kind].map_sum_checks == 3 * 36
        end
        # verdicts/tb2-r3.md N6 (c): decode round trip on the declared chain
        # set for all 18 maps — the bytes determine the map.
        roundtrip_ok = true
        for kind in kinds
            L = pcp.left[kind]
            bytes = canonical_bytes(describe_cl(L))
            decoded = decode_cl(bytes)
            roundtrip_ok &= canonical_bytes(describe_cl(decoded)) == bytes
            roundtrip_ok &= (level(decoded), seed_dim(decoded)) == (3, seed_dim(L))
            for seed in chain_seeds
                roundtrip_ok &= apply(decoded, seed) == apply(L, seed)
                roundtrip_ok &= marginal_k(decoded, seed, 3).factor_spaces ==
                                marginal_k(L, seed, 3).factor_spaces
            end
        end
        println("MUTATION_EXPECTED_RULE describe_roundtrip ok=", roundtrip_ok)
        @test roundtrip_ok
        # A chain is the sequence of stage VALUES consumed by the walk, so
        # ALine_6 has one chain per distinct s_aux and DLine_6 one per
        # distinct (s_aux, pi(v)) pair; the directed half covers all 16 buckets.
        distinct_aux = length(Set(seed[layout.auxiliary_coordinate] for seed in chain_seeds))
        @test length(Set(chi(seed[layout.auxiliary_coordinate], 16)
                         for seed in chain_seeds)) == 16
        @test replays[PCPType(:ALine, 6)].distinct_chains == distinct_aux
        @test replays[PCPType(:DLine, 6)].distinct_chains == 36
        println("TB2 lem:cl-kth replay: chain_set_id=", chain_set_id,
                " distinct_chains ",
                join(("$(kind)=$(replays[kind].distinct_chains)" for kind in kinds), " "),
                " completed_replays=36/map")

        # Bounded memo across 10^4 distinct Linear prefixes at q=2048.
        dline6 = pcp.left[PCPType(:DLine, 6)]
        coordinate_register = layout.registers[(6, :coord)]
        y = ntuple(i -> GF2048(3i + 1), seed_dim(pcp))
        prefixes = Set{Any}()
        while length(prefixes) < 10_000
            u = fill(zero(GF2048), seed_dim(pcp))
            for c in coordinate_register
                u[c] = rand(rng, field_elements(GF2048))
            end
            push!(prefixes, Tuple(u))
        end
        for u in prefixes
            Linear(dline6, 2, u, y)
        end
        memo = memo_report(dline6)
        @test memo.max_entries <= CL_MEMO_LIMIT
        @test memo.entries <= CL_MEMO_LIMIT * memo.nodes
        println("TB2 memo: distinct Linear prefixes=", length(prefixes),
                " limit=", CL_MEMO_LIMIT, " max_entries=", memo.max_entries,
                " entries=", memo.entries, " nodes=", memo.nodes)
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
        failures = Symbol[]
        case_index = 10

        global_type = tb2_atype(:alice, :Point, 1)
        run = tb2_answer_pair(reduced, deg, global_type, global_type, case_index)
        @test passed(run.decision)
        passed(run.decision) || push!(failures, run.decision.result.rule)
        union!(covered, tb2_trace_keys(run.decision))
        traces[1] = run
        case_index += 1

        for player in (:alice, :bob), role in (:alice, :bob)
            copy = role == :alice ? 1 : 2
            types = tb2_case_types(player,
                tb2_atype(:oracle, :Point, 6), tb2_atype(role, :Point, copy))
            run = tb2_answer_pair(reduced, deg, types..., case_index)
            @test passed(run.decision)
            passed(run.decision) || push!(failures, run.decision.result.rule)
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
            passed(run.decision) || push!(failures, run.decision.result.rule)
            union!(covered, tb2_trace_keys(run.decision))
            get!(traces, 3, run)
            case_index += 1
        end

        for player in (:alice, :bob), i in 3:5
            types = tb2_case_types(player,
                tb2_atype(:oracle, :Point, i), tb2_atype(:oracle, :Point, 6))
            run = tb2_answer_pair(reduced, nd, types..., case_index)
            @test passed(run.decision)
            passed(run.decision) || push!(failures, run.decision.result.rule)
            union!(covered, tb2_trace_keys(run.decision))
            get!(traces, 4, run)
            case_index += 1
        end
        for player in (:alice, :bob), i in 3:5, line_kind in (:ALine, :DLine)
            types = tb2_case_types(player,
                tb2_atype(:oracle, :Point, i), tb2_atype(:oracle, line_kind, i))
            run = tb2_answer_pair(reduced, nd, types..., case_index)
            @test passed(run.decision)
            passed(run.decision) || push!(failures, run.decision.result.rule)
            union!(covered, tb2_trace_keys(run.decision))
            get!(traces, 4, run)
            case_index += 1
        end
        for player in (:alice, :bob), line_kind in (:ALine, :DLine)
            types = tb2_case_types(player,
                tb2_atype(:oracle, :Point, 6), tb2_atype(:oracle, line_kind, 6))
            run = tb2_answer_pair(reduced, deg, types..., case_index)
            @test passed(run.decision)
            passed(run.decision) || push!(failures, run.decision.result.rule)
            union!(covered, tb2_trace_keys(run.decision))
            traces[4] = run
            case_index += 1
        end

        for player in (:alice, :bob)
            types = tb2_case_types(player,
                tb2_atype(:oracle, :Point, 6), tb2_atype(:bob, :Point, 2))
            run = tb2_answer_pair(reduced, deg, types..., case_index)
            @test passed(run.decision)
            passed(run.decision) || push!(failures, run.decision.result.rule)
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
        # verdicts/tb2-r5.md N28: the 37 keys above are ALL the keys, not a
        # subset — an extra or mislabelled (branch, line_kind) entry fails.
        expected_keys = Set{Tuple{Int,Symbol,Symbol,Int,Symbol}}()
        push!(expected_keys, (1, :global_consistency, :both, 0, :none))
        for player in (:alice, :bob)
            for role in (:alice, :bob)
                copy = role == :alice ? 1 : 2
                push!(expected_keys, (2, :input_consistency, player, copy, :none))
                push!(expected_keys, (3, :input_axis, player, copy, :ALine))
                push!(expected_keys, (3, :input_diagonal, player, copy, :DLine))
            end
            for i in 3:5
                push!(expected_keys, (4, :proof_consistency, player, i, :none))
                push!(expected_keys, (4, :proof_individual_axis, player, i, :ALine))
                push!(expected_keys, (4, :proof_individual_diagonal, player, i, :DLine))
            end
            push!(expected_keys, (4, :proof_simultaneous_axis, player, 6, :ALine))
            push!(expected_keys, (4, :proof_simultaneous_diagonal, player, 6, :DLine))
            push!(expected_keys, (5, :game, player, 6, :none))
        end
        @test length(expected_keys) == 37
        @test covered == expected_keys
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
        println("MUTATION_EXPECTED_RULE branches first_failure=",
                isempty(failures) ? :none : first(failures),
                " failures=", length(failures))
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
        branches = [answer_reduce_guard_branches(reduced.decider, left, right)
                    for left in reduced.sampler.types for right in reduced.sampler.types]
        no_check = count(isempty, branches)
        @test (no_check, total) == (2736, 2916)
        @test no_check // total == 76 // 81
        # verdicts/tb2-r3.md N10: of the 180 triggering pairs, 107 trigger
        # step 5 (92 of them alone) and 54 trigger step 1 (53 alone); the
        # 15 = 4 + 6 + 4 + 1 step-5 pairs that also fire another guard and the
        # diagonal ((oracle,Point_6),(oracle,Point_6)) account for the gaps.
        split = (no_check, count(!isempty, branches),
                 count(b -> :game in b, branches), count(==((:game,)), branches),
                 count(b -> :global_consistency in b, branches),
                 count(==((:global_consistency,)), branches))
        println("MUTATION_EXPECTED_RULE guard_split actual=", split)
        @test split == (2736, 180, 107, 92, 54, 53)
        println("TB2 no-check ordered type pairs: ", no_check, "/", total,
                " = 76/81 = ", round(100no_check / total; digits=3), "%",
                " triggering=180 step5 any/only=107/92 step1 any/only=54/53")
    end
end

# The decider names its low-degree branches by line kind; the enumerator
# names the check (verdicts/tb2-r4.md NF1). The lockstep compares
# (check, line_kind) keys: the decider's key is its branch name plus the
# trace entry's line kind (which must agree with the branch's suffix), the
# enumerator's is its check name plus the kind of the pair's line-typed side
# (verdicts/tb2-r5.md N28).
const TB2_GUARD_NAMES = Dict(
    :global_consistency => :global_consistency,
    :input_consistency => :input_consistency,
    :input_axis => :input_low_degree, :input_diagonal => :input_low_degree,
    :proof_consistency => :proof_consistency,
    :proof_individual_axis => :proof_individual_low_degree,
    :proof_individual_diagonal => :proof_individual_low_degree,
    :proof_simultaneous_axis => :proof_simultaneous_low_degree,
    :proof_simultaneous_diagonal => :proof_simultaneous_low_degree,
    :game => :game)
const TB2_LOW_DEGREE_CHECKS = (:input_low_degree, :proof_individual_low_degree,
                               :proof_simultaneous_low_degree)

function tb2_decider_guard_key(entry)
    name = TB2_GUARD_NAMES[entry.branch]
    suffix = endswith(String(entry.branch), "_axis") ? :ALine :
             endswith(String(entry.branch), "_diagonal") ? :DLine : :none
    suffix == entry.line_kind || error("branch $(entry.branch) carries line kind $(entry.line_kind)")
    (name, entry.line_kind)
end

function tb2_enumerator_guard_keys(decider, left, right)
    line_kinds = [t.pcp.kind for t in (left, right) if t.pcp.kind in (:ALine, :DLine)]
    Set((name, name in TB2_LOW_DEGREE_CHECKS ? only(line_kinds) : :none)
        for name in answer_reduce_guard_branches(decider, left, right))
end

if tb2_runs("lockstep")
    @testset "TB2 decider/enumerator lockstep on all 2916 pairs; step 1 at arity 22 (verdicts/tb2-r4.md NF1, NF2)" begin
        reduced = tb2_checked_reduction().term
        F = GF2048
        # NF1: `typed_answer_reduced_decider` itself, on every ordered type
        # pair at the all-zero seed with the certificate replay's all-zero
        # answers (honest for every check there), must fire exactly the
        # branches `answer_reduce_guard_branches` enumerates: an empty trace
        # on the 2736 check-free pairs, the enumerated set elsewhere.
        zero_seed = ntuple(_ -> zero(F), seed_dim(reduced.sampler))
        mismatches = 0
        accepted = 0
        silent = 0
        first_mismatch = nothing
        for left in reduced.sampler.types, right in reduced.sampler.types
            left_q, right_q = sample_answer_reduce_questions(reduced, left, right, zero_seed)
            left_a = MIPStarLambda._answer_reduce_replay_answer(F, left.pcp, reduced.decider.params)
            right_a = MIPStarLambda._answer_reduce_replay_answer(F, right.pcp, reduced.decider.params)
            decision = typed_answer_reduced_decider(reduced.decider, left, left_q,
                                                    right, right_q, left_a, right_a)
            expected = tb2_enumerator_guard_keys(reduced.decider, left, right)
            actual = Set(tb2_decider_guard_key(entry) for entry in decision.trace)
            if actual != expected
                mismatches += 1
                first_mismatch === nothing &&
                    (first_mismatch = (left, right, actual, expected, decision.result.rule))
            end
            accepted += passed(decision)
            silent += isempty(decision.trace)
        end
        println("MUTATION_EXPECTED_RULE guard_lockstep mismatches=", mismatches,
                " accepted=", accepted, " silent=", silent, " first=", first_mismatch)
        @test mismatches == 0
        @test accepted == 2916
        @test silent == 2736
        # verdicts/tb2-r5.md N27: the all-zero answers are honest only at the
        # all-zero seed. The same 2916-pair lockstep at the nonzero full-field
        # seed tb2_seed 5 with honest answers from the TB0 proof (witness
        # (ii) where a pair fires step 4(a)/4(b), the degenerate proof
        # elsewhere), cached per (witness, type) since a type's question at
        # a fixed seed is fixed.
        honest_strategies = Dict(:degenerate => honest_pcp_strategy(tb2_proof(:degenerate), TB2_PARAMS),
                                 :nondegenerate => honest_pcp_strategy(tb2_proof(:nondegenerate), TB2_PARAMS))
        honest_seed = tb2_seed(reduced.sampler, 5)
        @test !all(iszero, honest_seed)
        honest_cache = Dict{Tuple{Symbol,Any},Any}()
        honest_mismatches = 0
        honest_accepted = 0
        honest_silent = 0
        honest_first = nothing
        for left in reduced.sampler.types, right in reduced.sampler.types
            witness = answer_reduce_requires_nondegenerate(reduced.decider, left, right) ?
                      :nondegenerate : :degenerate
            strategy = honest_strategies[witness]
            left_q, right_q = sample_answer_reduce_questions(reduced, left, right, honest_seed)
            left_a = get!(() -> honest_pcp_answer(strategy, left.pcp, left_q.pcp),
                          honest_cache, (witness, left))
            right_a = get!(() -> honest_pcp_answer(strategy, right.pcp, right_q.pcp),
                           honest_cache, (witness, right))
            decision = typed_answer_reduced_decider(reduced.decider, left, left_q,
                                                    right, right_q, left_a, right_a)
            expected = tb2_enumerator_guard_keys(reduced.decider, left, right)
            actual = Set(tb2_decider_guard_key(entry) for entry in decision.trace)
            if actual != expected
                honest_mismatches += 1
                honest_first === nothing &&
                    (honest_first = (left, right, actual, expected, decision.result.rule))
            end
            honest_accepted += passed(decision)
            honest_silent += isempty(decision.trace)
        end
        println("MUTATION_EXPECTED_RULE guard_lockstep_honest seed=tb2_seed5 mismatches=",
                honest_mismatches, " accepted=", honest_accepted, " silent=", honest_silent,
                " first=", honest_first)
        @test honest_mismatches == 0
        @test honest_accepted == 2916
        @test honest_silent == 2736
        # NF2: fig:decider-pcp item 1 compares the FULL answer. On the five
        # equal-type copy-6 pairs (22-entry bundles; step 1 is the only
        # guard except on (oracle,Point_6)), corrupting entry 1, 6, 7 or
        # m'+6 = 22 of the right answer must be rejected by step 1 itself.
        strategy = honest_pcp_strategy(tb2_proof(:degenerate), TB2_PARAMS)
        seed = tb2_seed(reduced.sampler, 5)
        rejected_with_rule = 0
        trials = 0
        for kind in (tb2_atype(:alice, :Point, 6), tb2_atype(:bob, :Point, 6),
                     tb2_atype(:oracle, :ALine, 6), tb2_atype(:oracle, :DLine, 6),
                     tb2_atype(:oracle, :Point, 6))
            left_q, right_q = sample_answer_reduce_questions(reduced, kind, kind, seed)
            left_a = honest_pcp_answer(strategy, kind.pcp, left_q.pcp)
            right_a = honest_pcp_answer(strategy, kind.pcp, right_q.pcp)
            @test length(right_a) == TB2_PARAMS.m_prime + 6 == 22
            honest = typed_answer_reduced_decider(reduced.decider, kind, left_q,
                                                  kind, right_q, left_a, right_a)
            @test passed(honest)
            @test 1 in Set(entry.step for entry in honest.trace)
            for entry in (1, 6, 7, TB2_PARAMS.m_prime + 6)
                corrupted = typed_answer_reduced_decider(reduced.decider, kind, left_q,
                    kind, right_q, left_a, MIPStarLambda._corrupt_replay_answer(right_a, entry))
                trials += 1
                rejected_with_rule += !passed(corrupted) &&
                                      corrupted.result.rule == :global_consistency
                @test !passed(corrupted)
                @test corrupted.result.rule == :global_consistency
                @test corrupted.trace[end].step == 1
            end
        end
        println("MUTATION_EXPECTED_RULE global_consistency arity=22 rejected_with_rule=",
                rejected_with_rule, "/", trials)
        @test (rejected_with_rule, trials) == (20, 20)
        println("TB2 lockstep: decider trace == enumerator (check, line_kind) on 2916/2916",
                " ordered pairs (2736 silent, 180 guarded) at the zero seed with all-zero",
                " answers AND at tb2_seed 5 with honest TB0-proof answers; step 1 rejects",
                " entries 1/6/7/22 on 5 equal-type copy-6 pairs at tb2_seed 5")
    end
end

if tb2_runs("replay_seeds")
    @testset "TB2 nine-case replay at three seeds (verdicts/tb2-r3.md N9, tb2-r5.md NG1/NG2)" begin
        # The certificate replay (`_answer_reduce_replay_steps`) runs the
        # nine fig:decider-pcp cases at the all-zero seed with all-zero
        # answers. Here the same nine cases, honest answers from the TB0
        # proof, run at the zero seed and two nonzero full-field seeds, and
        # the same four facts are asserted for every (case, seed).
        reduced = tb2_checked_reduction().term
        strategies = Dict(:degenerate => honest_pcp_strategy(tb2_proof(:degenerate), TB2_PARAMS),
                          :nondegenerate => honest_pcp_strategy(tb2_proof(:nondegenerate), TB2_PARAMS))
        rng = MersenneTwister(0x9E)
        seeds = (ntuple(_ -> zero(GF2048), seed_dim(reduced.sampler)),
                 tb2_seed(reduced.sampler, 5),
                 ntuple(_ -> rand(rng, field_elements(GF2048)), seed_dim(reduced.sampler)))
        @test count(seed -> all(iszero, seed), seeds) == 1
        outcomes = Tuple{Symbol,Int,Bool,Bool,Symbol,Bool}[]
        for case in MIPStarLambda._answer_reduce_replay_cases(), (index, seed) in enumerate(seeds)
            witness = answer_reduce_requires_nondegenerate(reduced.decider, case.left, case.right) ?
                      :nondegenerate : :degenerate
            strategy = strategies[witness]
            left_q, right_q = sample_answer_reduce_questions(reduced, case.left, case.right, seed)
            left_a = honest_pcp_answer(strategy, case.left.pcp, left_q.pcp)
            right_a = honest_pcp_answer(strategy, case.right.pcp, right_q.pcp)
            honest = typed_answer_reduced_decider(reduced.decider, case.left, left_q,
                                                  case.right, right_q, left_a, right_a)
            side, entry = case.corrupt
            corrupted = typed_answer_reduced_decider(reduced.decider, case.left, left_q,
                case.right, right_q,
                side == :left ? MIPStarLambda._corrupt_replay_answer(left_a, entry) : left_a,
                side == :right ? MIPStarLambda._corrupt_replay_answer(right_a, entry) : right_a)
            push!(outcomes, (case.case, index, passed(honest), passed(corrupted),
                             corrupted.result.rule,
                             case.step in Set(e.step for e in honest.trace)))
            @test passed(honest)
            @test !passed(corrupted)
            @test corrupted.result.rule == case.expected_rule
            @test case.step in Set(e.step for e in honest.trace)
        end
        @test length(outcomes) == 27
        @test count(o -> o[1] in (:proof_individual_diagonal, :proof_simultaneous_diagonal),
                    outcomes) == 6
        println("TB2 replay at 3 seeds (zero, tb2_seed 5, rng 0x9E): cases=9 outcomes=",
                length(outcomes), " honest=", count(o -> o[3], outcomes),
                " corrupted_rejected=", count(o -> !o[4], outcomes))
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
        println("MUTATION_EXPECTED_RULE i345 actual=",
                proof_individual_guard_copies(reduced.decider))
        @test proof_individual_guard_copies(reduced.decider) == (3, 4, 5)
        println("TB2 structural guard table: individual copies=(3,4,5) exactly")
    end
end
