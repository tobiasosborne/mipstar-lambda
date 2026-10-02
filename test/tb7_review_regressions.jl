# Permanent P97-2/4/5/6 regressions; one target, no clock measurements.
module TB7ReviewRegressions
using Test, MIPStarLambda
Base.Experimental.@optlevel 0
const A = MIPStarLambda

function certificate_checks(C)
    nodes = A._nodes(C.certificate)
    one_node(rule) = only(n for n in nodes if n.rule == rule)
    @testset "P97-2 certificate facts and reconstruction" begin
        gap = one_node(:IntroGap)
        @test passed(verify_local(gap, C.term))
        saved = gap.facts.ast.args[1]
        try
            gap.facts.ast.args[1] = :min
            @test !passed(verify_local(gap, C.term))
        finally
            gap.facts.ast.args[1] = saved
        end
        floor = first(gap.children)
        saved_floor = floor.facts.branch.args[1]
        try
            floor.facts.branch.args[1] = :+
            @test !passed(A._verify_node(gap, C.term))
        finally
            floor.facts.branch.args[1] = saved_floor
        end
        forged = CertNode(CHECKED, gap.rule; facts=merge(gap.facts, (; ast=:(false))), children=gap.children, replay=gap.replay)
        @test !passed(verify_local(forged, C.term))
        @test !passed(verify_local(A._relocate(forged, identity), C.term))
        drop = CertNode(CHECKED, gap.rule; facts=gap.facts, children=(floor,), replay=gap.replay)
        @test !passed(verify_local(drop, C.term))
        rebuilt = CertNode(CHECKED, gap.rule; facts=gap.facts, children=(floor,), replay=A.unbound(gap.replay))
        @test !passed(verify_local(rebuilt, C.term))
        agreement = one_node(:AnswerReduceStepsAgreement)
        @test passed(verify_local(agreement, C.term))
        old = copy(agreement.facts.outcomes)
        try
            empty!(agreement.facts.outcomes)
            @test !passed(verify_local(agreement, C.term))
        finally
            append!(agreement.facts.outcomes, old)
        end
        audit = A.toy_contract_audit_node([PolicyPredicate("required", :FAIL)])
        @test !passed(verify_local(audit, nothing))
        empty!(audit.facts.failed)
        @test !passed(verify_local(audit, nothing))
        for status in (:FAIL, :VACUOUS, :NOT_EVALUABLE, :NOT_EXECUTED)
            @test A.group_status((:PASS, status)) != :PASS
        end
        V = tb7_input_verifier()
        lambda = description_length(V)
        pair = A.intro_effective_pair(V, lambda)
        @test pair.fits && pair.S_term == V.sampler.term && pair.D_term == V.decider.term
        pair = A.intro_effective_pair(V, lambda-1)
        @test !pair.fits && pair.S_term == TRIVIAL_SAMPLER_TERM && pair.D_term == TRIVIAL_DECIDER_TERM
        # The old node must consult the live formula implementation too; restore
        # the exact method after the attack so later suite targets are unchanged.
        source = read(joinpath(@__DIR__,"../src/compress/compress7.jl"),String)
        start = findfirst("function intro_gap_ast",source).start
        stop = findnext("\nend",source,start).stop
        original = source[start:stop]
        try
            Core.eval(A, :(intro_gap_ast(lambda::Integer,n::Integer) =
                (;full=:(false),floor_branch=:(false),substituted=:(false),ent_branch=:(false))))
            @test !Base.invokelatest(passed,Base.invokelatest(verify_local,gap,C.term))
        finally
            Base.include_string(A,original,"restored-intro-gap.jl")
        end
    end
end

function content_checks(C)
    @testset "P97-4 matching headers cannot certify unrelated PCP content" begin
        D1 = C.certificate.facts.skeleton.input.input.input.payload.decider
        fx = A.frontend_fixture()
        wide = PCPParams(2048,11,65537,11,6,16,1)
        spoof = A.FrontEndFixture(quote_program(lower_decider(D1);sort=:Decider), fx.input, fx.T,
                                 fx.padded, fx.pcp, wide, description_size(D1))
        ev = A.pcp_encodes_D1_evidence(D1,spoof,32768,1,description_size(D1),2)
        @test ev.facts.instance_is_D1 && ev.facts.width_ok
        @test fx.padded.term.m == 1 && spoof.T == 1
        @test ev.facts.status != "PASS"
    end
end

function fallback_checks(C)
    @testset "P97-5 effective-pair replay (97a fallback_red_NOT_RUN)" begin
        V = tb7_input_verifier_large()
        I = A.typed_intro_decider(V,32768,9; tuple=TB7_TOY_POLICY.intro_tuple,fixed_width=true)
        node = only(n for n in A._nodes(I.certificate) if n.rule == :IntroDecider)
        @test Dimension(V.sampler,4) == 9
        @test I.term.term[3][8] == TRIVIAL_SAMPLER_TERM
        a = Bool[false,false,true]
        @test decide(I.term,2,"Sample_bob",Bool[],"Sample_bob",Bool[],a,a)
        @test passed(verify_local(node,I.term))
        # Reuse unchanged sampler/AR/repeat stages: replace only the embedded
        # D1 by the actual fallback term when asking for its report.
        sk = C.certificate.facts.skeleton
        v3, v2, v1 = sk.input, sk.input.input, sk.input.input.input
        fallback = introspect(V,32768,9;tuple=TB7_TOY_POLICY.intro_tuple,fixed_width=true,tracer_index=2,seeds=0).term
        replacement = A.StageVerifier(v1.origin,v1.levels,v1.sampler_time,v1.decider_time,v1.description,
                                     v1.question_length,v1.answer_length,v1.gap,v1.sampler_dependencies,v1.input,fallback)
        arp = only(n for n in A._nodes(C.certificate) if n.rule == :toy_override && haskey(n.facts,:predicates) && length(n.facts.predicates)==4).facts.predicates
        p = A.tb7_predicate_report(V,32768,2,TB7_TOY_POLICY,replacement,v2,v3,arp)
        @test p[1].status == :FAIL
        @test p[3].status == :PASS
        @test p[5].status == :PASS
        @test !occursin("no introspection predicate executes",p[5].detail)
    end
end

# Evaluate the actual capture expressions with synthetic time/stat values.
# This covers the callers that used to round before calibrated_gate saw e.
function captured_elapsed(file, lhs, elapsed)
    line = only(filter(l -> startswith(strip(l), lhs * " = "), readlines(joinpath(@__DIR__,file))))
    rhs = Meta.parse(first(split(split(line," = ";limit=2)[2],"#")))
    f = Core.eval(@__MODULE__, :((time, started, tb6a_started, stats) -> $rhs))
    Base.invokelatest(f, () -> elapsed, 0.0, 0.0, (;time=elapsed))
end
function boundary_checks()
    @testset "P97-6 raw elapsed at sub-millisecond boundaries" begin
        sites = (("tb5_repeat.jl","TB5_LOG[:construction_seconds]",4),
                 ("tb5_repeat.jl","TB5_LOG[:transcript_seconds]",4),
                 ("tb6a_audit.jl","tb6a_audit_elapsed",18),
                 ("tb6b_introspect.jl","TB6B_LOG[Symbol(f.name, :_construction_seconds)]",21),
                 ("tb6b_introspect.jl","TB6B_LOG[:E_transcript_seconds]",33),
                 ("tb6b_introspect.jl","TB6B_LOG[:M_transcript_seconds]",21))
        for (file,lhs,K) in sites
            c = 0.00001
            e = (K+1)*c + 0.000001
            @test e > (K+1)*c && round(e;digits=3) == 0
            got = captured_elapsed(file,lhs,e)
            @test got == e
            @test got/c > K
            @test captured_elapsed(file,lhs,(K-0.1)*c)/c < K
        end
    end
end

function run_checks()
    @testset "TB7 review regressions" begin
        C = compress(tb7_input_verifier(),32768;policy=TB7_TOY_POLICY,tracer_index=2,seeds=4)
        certificate_checks(C)
        content_checks(C)
        fallback_checks(C)
        boundary_checks()
        @testset "CHECKED census and retained fixture evidence" begin
            ns = A._nodes(C.certificate)
            @test length(ns) == 317 && [count(n -> n.grade == g,ns) for g in instances(Grade)] == [34,133,70,62,18]
            checked = filter(n -> n.grade == CHECKED,ns)
            failing = [n.rule for n in checked if !Base.invokelatest(passed,Base.invokelatest(verify_local,n,C.term))]
            println("P97-2 CHECKED failures=",failing)
            @test failing == [:ToyContractAudit]
            forged = [CertNode(n.grade,n.rule;facts=merge(n.facts,(;display="FORGED")),children=n.children,replay=n.replay) for n in checked]
            @test count(n -> passed(verify_local(n,C.term)),forged) == 0
            agreement = only(n for n in ns if n.rule == :AnswerReduceStepsAgreement)
            @test (agreement.facts.complete,agreement.facts.prefix,length(agreement.facts.outcomes)) == (4,4,9)
            rows = only(n for n in ns if n.rule == :ChainCoverage).facts.final_rows
            @test length(rows) == 12 && count(r -> r.distinct > 0,rows) == 4
            sigma = only(n for n in ns if n.rule == :FixedWidthSigma)
            @test sigma.facts.sigma_1 == 67648
            body = C.certificate.facts.skeleton.input.input.input.payload.decider.term[4][3]
            census = A.intro_dispatch_census(body,2)
            @test (census.dispatched,census.pairs,census.pauli_dispatched,census.pauli_pairs) == (0,164,0,86)
        end
    end
end
run_checks()
end
