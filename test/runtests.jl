load_started = time()
using Test
using MIPStarLambda
load_elapsed = time() - load_started
println("MIPStarLambda load/precompile seconds = ", round(load_elapsed; digits=3),
        " (ungated; cold/warm cache reported separately)")

started = time()
@testset verbose=true "MIPStarLambda" begin
    include("tb0_core.jl")
    elapsed = time() - started
    measured = round(elapsed; digits=3)
    println("TB0 test-body wall seconds = ", measured,
            " (warning=45.0, hard_limit=60.0)")
    elapsed >= 45 && @warn "TB0 test body exceeded its 45 s warning" measured_seconds=measured
    @testset "TB0 60 s test-body hard limit (measured $(measured) s)" begin
        @test elapsed < 60
    end
    include("tb1_ld_sampler.jl")
    include("tb2_answer_reduce.jl")
end
