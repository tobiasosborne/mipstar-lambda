using Test
using MIPStarLambda
Base.Experimental.@optlevel 0

# TB7 (briefs/44-tb7-compress.md + addendum; DESIGN 12, 13.1-13.2): the
# executable Compress = Repeat o AnswerReduce o Introspect on descriptions
# with the full structural bookkeeping, the ToyPolicy predicate report, the
# concrete TB7 execution and the halting fixed point D_{M,L} = Y Psi_{M,L}.
const TB7_TARGET = get(ENV, "TB7_TARGET", "all")
include(joinpath(@__DIR__, "calibration.jl"))
const TB7_STARTED = time()
tb7_runs(name) = TB7_TARGET in ("all", "tb7_gate") || TB7_TARGET == name
const M7 = MIPStarLambda
const TB7_CACHE = Dict{Symbol,Any}()
tb7_V() = get!(TB7_CACHE, :input) do
    tb7_input_verifier()
end
tb7_C() = get!(TB7_CACHE, :compressed) do
    compress(tb7_V(), 32768; policy=TB7_TOY_POLICY, tracer_index=2, seeds=4)
end
tb7_nodes(node, rule::Symbol) = [x for x in M7._nodes(node) if x.rule == rule]
tb7_predicates() = only(x for x in tb7_nodes(tb7_C().certificate, :toy_override)
                         if haskey(x.facts, :predicates) && length(x.facts.predicates) == 13).facts.predicates
function tb7_atoms(x)
    x isa Expr && return reduce(vcat, (tb7_atoms(a) for a in x.args); init=Any[])
    x isa NamedTuple && return reduce(vcat, (tb7_atoms(a) for a in values(x)); init=Any[])
    Any[x]
end

@testset "TB7 full rung" begin

if tb7_runs("tb7_order")
    @testset "TB7 (a) constructor order AST equals fig:compress" begin
        policy = TB7_TOY_POLICY
        C = tb7_C()
        @test constructor_order(C) == COMPRESS_ORDER_AST
    end
end

if tb7_runs("tb7_constants")
    @testset "TB7 (b) symbolic source constants" begin
        @test universal_constants_ast() == EXPECTED_UNIVERSAL_CONSTANTS
        ast = universal_constants_ast()
        @test :C_intro in tb7_atoms(ast.mu)
        @test :c3_prime in tb7_atoms(ast.k)
    end
end
if tb7_runs("tb7_production")
    @testset "TB7 (b) production policy compact construction" begin
        # WIP: the current u32 description grammar cannot encode the source's
        # universal constants as ASTs. This remains a visible broken assertion.
        @test_broken compress_terms(tb7_V(), 32768, ProductionPolicy()) isa VerifierDescription
    end
end
if tb7_runs("tb7_bookkeeping")
    @testset "TB7 (c) six bookkeeping rows, field alignment and product graph" begin
        C = try
            tb7_C()
        catch err
            err isa ArgumentError && occursin("mismatched fields", sprint(showerror, err)) ? nothing : rethrow()
        end
        @test C isa Checked                         # M7-field-align must fail by this assertion, not a test error.
        if C isa Checked
            rows = only(tb7_nodes(C.certificate, :Bookkeeping)).facts.rows
            @test length(only(tb7_nodes(C.certificate, :Bookkeeping)).children) == 6
            @test [(r.field, r.level, r.dimension) for r in rows] ==
                  [(2, 9, 9), (2, 5, 206), (2, 5, 624), (2, 7, 840), (2, 9, 848), (2, 9, 1696)]
            @test all(r.dimension == r.law_value for r in rows)
            @test M7.level_chain(C.certificate.facts.skeleton) == [9, 5, 7, 9]
            @test hasmethod(answer_reduce_pcp, Tuple{VerifierDescription,Int,Int,Int})
            product_term = C.term.sampler.term[end][2][2][2]   # RepeatToy -> Detype -> Anchor -> Detype -> Product
            @test product_term[1] == :Product
            @test product_term[3][1] == :Pad
            @test product_term[3][3][1] == :Downsize
            typing = M7.machine_typing(M7.compile_sampler(product_term))
            @test length(typing.labels) == 54
            @test length(typing.edges) == 2916
            @test ("oracle,Point_1", "alice,DLine_6") in typing.edges
            println("TB7 BOOKKEEPING\n", bookkeeping_text(rows))
        end
    end

end
if tb7_runs("tb7_independence")
    @testset "TB7 (d) fixed-width sigma and sampler byte independence" begin
        V, W = tb7_V(), tb7_input_verifier_prime()
        A, B = compress_terms(V, 32768, TB7_TOY_POLICY), compress_terms(W, 32768, TB7_TOY_POLICY)
        @test canonical_bytes(V.decider) != canonical_bytes(W.decider)
        @test canonical_bytes(A.sampler) == canonical_bytes(B.sampler)
        @test M7.quote_hash(A.sampler) == M7.quote_hash(B.sampler)
        L = tb7_input_verifier_large()
        @test description_length(V) <= 32768 < description_length(L)
        C = compress_terms(L, 32768, TB7_TOY_POLICY)
        @test canonical_bytes(A.sampler) == canonical_bytes(C.sampler)
        @test canonical_bytes(A.sampler) == canonical_bytes(tb7_C().term.sampler)
        @test M7.parameter_dependencies(canonical_bytes(A.sampler)) == EXPECTED_COMPRESS_DEPENDENCIES
    end

end
if tb7_runs("tb7_intro_gap")
    @testset "TB7 (e) IntroGap has CHECKED floor and CITED Ent branch" begin
        gap = intro_gap_ast(32768, 2)
        @test gap.full.head == :call && gap.full.args[1] == :max
        @test length(gap.full.args) == 3
        @test gap.full.args[2] == gap.ent_branch
        @test gap.full.args[3] == gap.floor_branch
        @test 65536 in tb7_atoms(gap.substituted)
        node = only(tb7_nodes(tb7_C().certificate, :IntroGap))
        @test [c.grade for c in node.children] == [CHECKED, CITED]
    end
end

if tb7_runs("tb7_policy")
    @testset "TB7 (f) thirteen fail-visible predicates" begin
        C = tb7_C()
        p = tb7_predicates()
        @test length(p) == 13
        @test [x.status for x in p] == [:PASS, :PASS, :FAIL, :FAIL, :VACUOUS, :PASS,
                                         :NOT_EVALUABLE, :FAIL, :FAIL, :NOT_EXECUTED,
                                         :PASS, :FAIL, :PASS]
        @test p[3].owner == p[5].owner == "Q_I<s_0"
        @test p[9].owner == p[10].owner == "pcpverifier-D1-trace"
        @test occursin("executed non-Pauli schemas = 0", p[5].detail)
        @test only(tb7_nodes(C.certificate, :P_pcp_encodes_D1)).facts.status == "FAIL"
        pcp_evidence = only(tb7_nodes(C.certificate, :P_pcp_encodes_D1)).facts
        @test pcp_evidence.actual.refused === nothing
        @test pcp_evidence.actual.m > pcp_evidence.fixture_m
        @test pcp_evidence.actual.decoupled_clauses > 0
        @test pcp_evidence.D1_hash != pcp_evidence.fixture_hash
        @test any(x -> x.rule == :toy_override && x.grade == ASSUMED, M7._nodes(C.certificate))
        println("TB7 PREDICATES\n", predicate_report_text(p))
    end
end

if tb7_runs("tb7_execution")
    @testset "TB7 (g) finite questions, chain replays, and local subtests" begin
        C = tb7_C()
        @test Dimension(C.term.sampler, 2) == 1696
        @test all(haskey(C.certificate.facts.walls, stage) for stage in (:Introspect, :AnswerReduce, :Repeat, :compress))
        questions = final_questions(C.term.sampler, 2, 16)
        @test length(questions) == 16
        @test all(length(q.questions[1]) == length(q.questions[2]) == 1696 for q in questions)
        transcript_alloc = @allocated final_questions(C.term.sampler, 2, 16)
        @test transcript_alloc < 512 * 2^20
        println("TB7 16-question allocation MiB=", round(transcript_alloc / 2^20; digits=2))
        z = questions[1].z
        for role in (:alice, :bob)
            @test length(Marginal(C.term.sampler, 2, role, 1, z)) == 1696
            @test length(Factor(C.term.sampler, 2, role, 1, fill(GF2(0), 1696))) == 1696
            @test length(Linear(C.term.sampler, 2, role, 1, fill(GF2(0), 1696), z)) == 1696
        end
        rows = chain_coverage(C.certificate)
        @test !isempty(rows)
        @test all(r.ok && r.selected > 0 && r.replayed >= r.distinct for r in rows)
        @test all(!isempty(r.chain_set_id) for r in rows)
        @test any(n.rule == :AnswerReduceStepsAgreement for n in M7._nodes(C.certificate))
        @test any(n.rule == :PCPFixtureLocalOnly for n in M7._nodes(C.certificate))
        @test only(tb7_nodes(C.certificate, :PCPFixtureLocalOnly)).facts.representation == "structural-evaluator"
        @test answer_bit_length(PCPType(:DLine, 6), TB7_TOY_POLICY.pcp_tuple) == 42834
        println("TB7 WALLS ", C.certificate.facts.walls, " process_peak_MiB=", round(Sys.maxrss() / 2^20; digits=1),
                " uptime=", read(`uptime`, String))
        println("TB7 CHAIN COVERAGE\n", chain_coverage_text(rows))
    end
end

if tb7_runs("tb7_fixed_point")
    @testset "TB7 (h) five finite fixed-point steps and evaluator boundary" begin
        hash = M7.quote_hash(tb7_C().term.sampler)
        run = halting_fixed_point(32768; independent_hash=hash)
        @test all(run.steps)
        @test run.sampler_hash == hash
        @test run.outcome.result isa Value
        @test run.fuel_boundary.ok
        @test run.fuel_boundary.below isa OutOfFuel
    end
end

if tb7_runs("tb7_tree")
    @testset "TB7 (i) complete certificate residue and census" begin
        C = tb7_C()
        @test cited_labels(C.certificate) == TB7_RESIDUE_INVENTORY
        @test length(M7._nodes(C.certificate)) > 200
        @test length(split(certificate_tree_text(C.certificate), '\n')) == length(M7._nodes(C.certificate))
        @test only(tb7_nodes(C.certificate, :ConstructorOrder)).grade == CHECKED
        @test any(x -> x.grade == SOURCE_REPAIR, tb7_nodes(C.certificate, :IntroDeciderFixedWidth))
        get(ENV, "TB7_PRINT_TREE", "0") == "1" && println("TB7 CERTIFICATE TREE\n", certificate_tree_text(C.certificate))
    end
end

if tb7_runs("tb7_api")
    @testset "TB7 API: Sampler arity, attempted fuel, and Pad's terminal walk" begin
        @test !M7._admits_sort(Lambda(1, BoundVar(0, 0)), :Sampler)
        @test M7._admits_sort(Lambda(7, BoundVar(0, 0)), :Sampler)
        e = FuelExhausted(7, 5)
        @test hasproperty(e, :attempted)
        hasproperty(e, :attempted) && @test e.attempted == 7
        @test occursin("attempted", sprint(showerror, e))
        S = tb7_V().sampler
        P = pad(S, 1; tracer_index=2, seeds=1).term
        @test P.level == S.level + 1
        @test Dimension(P, 2) == Dimension(S, 2)
        terminal = Factor(P, 2, :alice, P.level, fill(GF2(0), 9))
        @test terminal isa Vector{Int}
        if terminal isa Vector{Int}
            @test length(terminal) == 9
            @test all(iszero, terminal)                  # j = child level + 1 is the empty stage.
        end
    end
end

if tb7_runs("tb7_nested_meter")
    @testset "TB7 nested typed bodies charge their own work" begin
        labels = M7.pauli_type_labels()
        pauli = (:TypedDecider, labels, (:Pauli, 2, 1, 1))
        @test_throws FuelExhausted M7._metered_decide_typed(pauli, 2, labels[1], Bool[], labels[1], Bool[], Bool[], Bool[], Meter(2))
        ar_body = (:AnswerReduce, 1, 1, 1, 1, 2048, 1, 11, 6, 16, TRIVIAL_SAMPLER_TERM, TRIVIAL_DECIDER_TERM)
        ar_labels = ["alice,Point_1"]
        @test_throws FuelExhausted M7._decide_typed_body(ar_labels, ar_body, 2, ar_labels[1], Bool[], ar_labels[1], Bool[], Bool[], Bool[], Any[]; parent=Meter(1))
        intro_body = (:Intro, 1, 1, 2, 1, 1, 0, TRIVIAL_SAMPLER_TERM, TRIVIAL_DECIDER_TERM)
        @test_throws FuelExhausted M7._decide_intro(intro_body, 2, "Pauli_X", Bool[], "Pauli_X", Bool[], Bool[], Bool[], Any[]; parent=Meter(1))
    end
end
end # TB7 full rung
if TB7_TARGET in ("all", "tb7_gate")
    tb7_elapsed = time() - TB7_STARTED
    tb7_gate = calibrated_gate(:tb7_total, tb7_elapsed)
    @testset "TB7 calibrated total gate" begin
        @test tb7_gate.ratio_ok
        @test tb7_gate.wall_ok
    end
    println("TB7 gate ratio<", tb7_gate.K, " => ", tb7_gate.ratio_ok, " uptime=", read(`uptime`, String))
end
