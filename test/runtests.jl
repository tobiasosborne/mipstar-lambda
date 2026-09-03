const LOCAL_JULIA_DEPOT = "/tmp/mipstar-lambda-julia-depot"
mkpath(LOCAL_JULIA_DEPOT)
LOCAL_JULIA_DEPOT in DEPOT_PATH || pushfirst!(DEPOT_PATH, LOCAL_JULIA_DEPOT)

using Test

started = time()
@testset "MIPStarLambda" begin
    include("tb0_core.jl")
end
elapsed = time() - started
println("TB0 total wall seconds = ", round(elapsed; digits=3))
@test elapsed < 60
