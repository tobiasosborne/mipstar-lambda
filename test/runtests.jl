using Test

started = time()
@testset verbose=true "MIPStarLambda" begin
    include("tb0_core.jl")
    include("tb1_ld_sampler.jl")
    include("tb2_answer_reduce.jl")
end
elapsed = time() - started
measured = round(elapsed; digits=3)
println("TB0 total wall seconds = ", measured,
        " (warning=45.0, hard_limit=60.0)")
elapsed >= 45 && @warn "TB0 suite exceeded its 45 s warning" measured_seconds=measured
@testset "TB0 60 s hard limit (measured $(measured) s)" begin
    @test elapsed < 60
end
