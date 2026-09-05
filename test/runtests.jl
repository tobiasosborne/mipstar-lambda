load_started = time()
using Test
using MIPStarLambda
load_elapsed = time() - load_started
# Warm load only. The COLD image build, which executes src/precompile.jl's
# TB0 workload, is timed by `tools/cold_precompile.sh` (scratch depot).
println("MIPStarLambda load/precompile seconds = ", round(load_elapsed; digits=3),
        " (ungated; cold image build: tools/cold_precompile.sh)")

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
    include("tb3_frontend.jl")
    tb4_started = time()
    include("tb4_compress_ir.jl")
    println("TB4 include wall seconds = ", round(time() - tb4_started; digits=3), " (the 5 s body budget is the calibrated ratio gate inside tb4_compress_ir.jl)")
    tb5_started = time()
    include("tb5_repeat.jl")
    println("TB5 test-body wall seconds = ", round(time() - tb5_started; digits=3), " (Repeat(V_copy) targets: construction < 2, transcripts < 5)")
end
