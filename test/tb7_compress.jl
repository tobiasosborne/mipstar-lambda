using Test
using MIPStarLambda
Base.Experimental.@optlevel 0

# TB7 (briefs/44-tb7-compress.md + addendum; DESIGN 12, 13.1-13.2): the
# executable Compress = Repeat o AnswerReduce o Introspect on descriptions
# with the full structural bookkeeping, the ToyPolicy predicate report, the
# concrete TB7 execution and the halting fixed point D_{M,L} = Y Psi_{M,L}.
const TB7_TARGET = get(ENV, "TB7_TARGET", "all")
tb7_runs(name) = TB7_TARGET == "all" || TB7_TARGET == name

if tb7_runs("tb7_order")
    @testset "TB7 (a) constructor order AST equals fig:compress" begin
        policy = TB7_TOY_POLICY
        V = tb7_input_verifier()
        C = compress(V, 32768; policy, tracer_index=2, seeds=4)
        @test constructor_order(C) == COMPRESS_ORDER_AST
    end
end
