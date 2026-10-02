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
"The first nested tuple of a description term whose head is `tag` (depth-first), or nothing."
function tb7_find(term, tag::Symbol)
    term isa Tuple || return nothing
    !isempty(term) && term[1] === tag && return term
    for x in term
        found = tb7_find(x, tag)
        found === nothing || return found
    end
    nothing
end
"Verify one CHECKED node on its own (its fact/child binding and its replay), without recursing into the children."
tb7_local(n, term) = M7.verify_local(n, term)
function tb7_atoms(x)
    x isa Expr && return reduce(vcat, (tb7_atoms(a) for a in x.args); init=Any[])
    x isa NamedTuple && return reduce(vcat, (tb7_atoms(a) for a in values(x)); init=Any[])
    Any[x]
end

@testset "TB7 full rung" begin

if tb7_runs("tb7_review")
    include("tb7_review_regressions.jl")
end

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
        # verdicts/tb7-r1.md T7-4 (brief 93 K): seeds, views and selected queries are labelled separately
        # (`selected` used to be the maximum completed replays per view).
        @test all(r.ok && r.seeds > 0 && r.selected_queries == r.replayed && r.replayed >= r.distinct for r in rows)
        @test all(!isempty(r.chain_set_id) for r in rows)
        # ... and every primitive/intermediate sampler replays the child chains ACTUALLY reached by the
        # sixteen final-question seeds (the same seeds as `final_questions`), not only its own rng/exhaustive set.
        coverage = only(tb7_nodes(C.certificate, :ChainCoverage))
        final = coverage.facts.final_rows
        @test length(final) == length(rows) == 12
        @test Set(r.hash for r in final) == Set(r.hash for r in rows)
        @test all(r.ok && r.replayed == r.distinct && r.queries >= r.distinct for r in final)
        @test only(r for r in final if r.hash == M7.quote_hash(C.term.sampler)).final_seeds == 16
        # The 16 uniform seeds reach the repetition, the anchored detype, the anchor and the AR detype; below the
        # AR detype a uniform 54-bit vertex register is (almost) never a valid type encoding, so the promoted zero
        # map answers and no chain of the product or its children is reached (rows printed with zero counts).
        reached = [r for r in final if r.distinct > 0]
        @test length(reached) == 4 && all(r.final_seeds >= 1 && r.replayed >= 1 for r in reached)
        @test passed(tb7_local(coverage, C.term))
        # Missing final-chain coverage is red: drop one sampler's reached-chain row.
        @test !M7.final_chain_coverage_ok(rows, final[2:end], M7.final_chain_coverage(C.term.sampler, 2, 16))
        println("TB7 FINAL-SEED CHAIN COVERAGE\n", M7.final_chain_coverage_text(final))
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
        # verdicts/tb7-r1.md T7-3 (brief 93 D): the fifth step executes the ACTUAL D -- an independent evaluation of
        # the returned D on the returned transcript uses exactly the recorded fuel and returns the recorded value
        # (a constant-true decider substituted for D used 3716 units against D's own 181978 and survived step 5).
        t = run.transcript
        actual = eval_quoted(run.D, (2, t.x, t.y, t.a, t.b), 600_000; hard_cap=600_000)
        @test run.outcome.used == actual.used
        @test actual.result isa Value && run.outcome.result.value == actual.result.value
        @test run.evaluated_hash == M7.quote_hash(run.D)
    end
end

if tb7_runs("tb7_compressor_provenance")
    @testset "TB7 (h2) the Compressor primitive retains the supplied decider byte for byte (verdicts/tb7-r1.md T7-3)" begin
        S = tb7_V().sampler
        dp = Lambda(5, Prim(false, Concrete(1), ()))
        pair = M7._quoted_pair(Code(lower_sampler(S), :Sampler), Code(dp, :Decider))
        code, _ = M7._run_compress_descriptions(pair, 32768, M7.policy_bytes(TB7_TOY_POLICY), 1_000_000)
        term = M7.decode_decider_term(M7.lowered_bytes(code.program))
        body = tb7_find(term, :IntroFixed)
        @test body !== nothing
        if body !== nothing
            expected = lift_decider(quote_program(dp; sort=:Decider).term).term.term
            @test expected[1] == :Program
            @test body[9] == expected                                            # the supplied decider, not trivial code
            @test M7.decider_term_bytes(body[9]) == M7.decider_term_bytes(expected)
            @test Vector{UInt8}(body[9][2]) == canonical_bytes(quote_program(dp; sort=:Decider).term)
            @test body[8] == S.term                                              # and the supplied sampler
        end
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
if tb7_runs("tb7_policy_red")
    @testset "TB7 (f2) report statuses derived from owned evidence; eligibility needs every premise discharged (verdicts/tb7-r1.md T7-1)" begin
        C = tb7_C()
        v1 = C.certificate.facts.skeleton.input.input.input
        for status in (:NOT_EVALUABLE, :VACUOUS, :NOT_EXECUTED, :FAIL)
            audit = M7.toy_contract_audit_node([PolicyPredicate("missing production premise", status; owner="critic")])
            @test !passed(audit.replay(C.term))
        end
        @test passed(M7.toy_contract_audit_node([PolicyPredicate("every premise discharged", :PASS)]).replay(C.term))
        fx = M7.frontend_fixture()
        D1 = v1.payload.decider
        sigma1 = description_size(D1)
        ar(V, a, sigma, gamma, policy) = M7.answer_reduce_predicates(V, a, sigma, 32768, 1, gamma, 2, policy, fx)
        # Row 11 is computed: an unpadded trivial D1, sigma = -1, or a sigma that is not |D1| is never PASS.
        trivial = M7.trivial_verifier_description()
        @test last(ar(trivial, TB7_TOY_POLICY.pcp_tuple, -1, 1, TB7_TOY_POLICY)).status == :FAIL
        @test last(ar(trivial, TB7_TOY_POLICY.pcp_tuple, description_size(trivial.decider), 1, TB7_TOY_POLICY)).status == :FAIL
        @test last(ar(v1.payload, TB7_TOY_POLICY.pcp_tuple, sigma1 + 1, 1, TB7_TOY_POLICY)).status == :FAIL
        honest = ar(v1.payload, TB7_TOY_POLICY.pcp_tuple, sigma1, 1, TB7_TOY_POLICY)
        @test last(honest).status == :PASS
        # Row 7: gamma = 2 definitely FAILS the transcribed growth lower bound 11 <= (2 + 3) log2(6) = 12.92...
        a2 = PCPParams(2048, 11, 1, 11, 6, 16, 2)
        p2 = ToyPolicy(; intro_tuple=TB7_TOY_POLICY.intro_tuple, pcp_tuple=a2, gamma=2, repetitions=2)
        @test ar(v1.payload, a2, sigma1, 2, p2)[2].status == :FAIL
        @test honest[2].status == :NOT_EVALUABLE                 # gamma = 1: 11 > 4 log2(6) = 10.34, unknown a', b'
        # Row 8 is computed from its 2^m >= 2T witness: with m >= 65537 the witness no longer refutes it.
        wide = PCPParams(2048, 11, 65537, 11, 6, 16, 1)
        @test honest[3].status == :FAIL
        @test ar(v1.payload, wide, sigma1, 1, TB7_TOY_POLICY)[3].status == :NOT_EVALUABLE
        # Rows 9 and 10 are bound to their evidence: the P_pcp_encodes_D1 node's computed comparison and an executed
        # game-reaching probe of the actual AnswerReduce decider.
        p = tb7_predicates()
        ev = only(tb7_nodes(C.certificate, :P_pcp_encodes_D1)).facts
        @test ev.status == (ev.instance_is_D1 && ev.width_ok ? "PASS" : "FAIL")
        @test !ev.instance_is_D1 && !ev.width_ok
        @test String(p[9].status) == ev.status
        @test p[10].status == :NOT_EXECUTED && occursin("probe", p[10].detail)
        probe = M7.ar_game_probe(C.certificate.facts.skeleton.input.input.payload, 2)
        @test probe.reached && !probe.executed && !probe.bit
    end
end

if tb7_runs("tb7_replay_binding")
    @testset "TB7 (i2) every CHECKED replay is bound to its node's facts and children (verdicts/tb7-r1.md T7-2)" begin
        C = tb7_C()
        ns = M7._nodes(C.certificate)
        checked = [n for n in ns if n.grade == CHECKED]
        census = [count(n -> n.grade == g, ns) for g in instances(Grade)]
        @test length(ns) == 317 && census == [34, 133, 70, 62, 18]
        println("TB7 CENSUS ", length(ns), " = ", join(("$(c) $(g)" for (g, c) in zip(instances(Grade), census)), " + "))
        failing = [n.rule for n in checked if !passed(tb7_local(n, C.term))]
        @test failing == [:ToyContractAudit]                 # the one designed refusal: toy predicates fail
        forged_passing = 0
        for n in checked
            forged = CertNode(n.grade, n.rule; facts=merge(n.facts, (; display="FORGED checked assertion")), children=n.children, replay=n.replay)
            forged_passing += passed(tb7_local(forged, C.term))
        end
        @test forged_passing == 0
        sigma = only(tb7_nodes(C.certificate, :FixedWidthSigma))
        forged = CertNode(CHECKED, sigma.rule; facts=merge(sigma.facts, (; sigma_1=-1)), children=sigma.children, replay=sigma.replay)
        @test !passed(M7._verify_node(forged, C.term))
        gap = only(tb7_nodes(C.certificate, :IntroGap))
        drop = CertNode(CHECKED, gap.rule; facts=gap.facts, children=(first(gap.children),), replay=gap.replay)
        @test !passed(M7._verify_node(drop, C.term))
        dep = only(tb7_nodes(C.certificate, :CodeDependencyIndependence))
        @test dep.facts.hash == M7.quote_hash(C.term.sampler)
        @test occursin(dep.facts.hash, dep.facts.display)
    end
end

if tb7_runs("tb7_pair_padding")
    @testset "TB7 (d2) |V| > lambda replaces the PAIR by two trivial machines in both paths (gt-08:L757-L763; verdicts/tb7-r1.md T7-5)" begin
        large = tb7_input_verifier_large()
        @test description_size(large.sampler) <= 32768 < description_size(large.decider)   # sampler 546 fits, decider 34006 does not
        I = introspect(large, 32768, 9; tuple=TB7_TOY_POLICY.intro_tuple, fixed_width=true, tracer_index=2, seeds=0).term
        effective = I.decider.term[4][3]
        @test effective[1] == :IntroFixed
        @test effective[8] == TRIVIAL_SAMPLER_TERM
        @test effective[9] == TRIVIAL_DECIDER_TERM
        body = tb7_find(compress_terms(large, 32768, TB7_TOY_POLICY).decider.term, :IntroFixed)
        @test body[8] == TRIVIAL_SAMPLER_TERM && body[9] == TRIVIAL_DECIDER_TERM
        small = tb7_find(compress_terms(tb7_V(), 32768, TB7_TOY_POLICY).decider.term, :IntroFixed)
        @test small[8] == tb7_V().sampler.term && small[9] == tb7_V().decider.term       # control: |V| <= lambda keeps V
    end
end

if tb7_runs("tb7_intro_dispatch")
    @testset "TB7 (f3) Q_I = 2 < s = 9: zero introspection predicates dispatch at TB7, Pauli pairs included (verdicts/tb7-r1.md T7-6)" begin
        C = tb7_C()
        v1 = C.certificate.facts.skeleton.input.input.input
        body = v1.payload.decider.term[4][3]
        pp = M7.PauliParams(2, 1, 1)
        edges = M7.intro_typing(9).edges
        pauli_edges = [e for e in edges if all(M7.is_pauli_label, e)]
        @test length(edges) == 164 && length(pauli_edges) == 86
        answer(l) = M7.is_pauli_label(l) ? Vector{Bool}(falses(M7.answer_schema(pp, l).bits)) : Vector{Bool}(falses(3))
        dispatched = 0
        pauli_fired = 0
        for (l, r) in edges
            bit, _, fired = intro_decide_traced(body, 2, l, falses(6), r, falses(6), answer(l), answer(r))
            dispatched += !isempty(fired)
            pauli_fired += :pauli in fired
            @test !bit
        end
        @test dispatched == 0 && pauli_fired == 0
        p = tb7_predicates()
        @test !occursin("only the Pauli-typed predicates execute", p[5].detail)
        @test occursin("introspection predicate dispatches at TB7 = 0 of 164 oriented pairs (0 of 86 Pauli pairs)", p[5].detail)
    end
end

if tb7_runs("tb7_ar_agreement")
    @testset "TB7 (g2) AnswerReduceStepsAgreement grades game-reaching cases by their NOT_EXECUTED trace (verdicts/tb7-r1.md T7-8)" begin
        C = tb7_C()
        n = only(tb7_nodes(C.certificate, :AnswerReduceStepsAgreement))
        @test passed(n.replay(C.term))
        @test passed(tb7_local(n, C.term))
        o = n.facts.outcomes
        @test length(o) == 9
        complete = [x for x in o if !x.game]
        reaching = [x for x in o if x.game]
        @test [x.case for x in complete] == [:global_consistency, :input_axis, :input_diagonal, :proof_individual_diagonal]
        @test all(x.honest_here == x.honest_tb2 == true && x.corrupt_here == x.corrupt_tb2 == false && x.rule == x.expected_rule for x in complete)
        @test length(reaching) == 5
        @test all(!x.honest_here && x.not_executed && x.prefix_ok for x in reaching)
        @test all(x.own_rule_executed && x.rule == x.expected_rule for x in reaching if x.case != :game)
        @test occursin("4 complete accept/reject agreements", n.facts.display)
        @test occursin("4 game-reaching guard cases agree on their executed prefix", n.facts.display)
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
