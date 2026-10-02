# Standalone process-level regression from verdicts/tb7-r2-pre.md runner_probe.
# Includes definitions only; never executes the mutation registry.
using Test
const RUNNER_FILE = joinpath(@__DIR__, "run.jl")
module RunnerProcess end
prefix = first(split(read(RUNNER_FILE,String), "\nstarted = time()\n"))
for file in readdir(@__DIR__)
    endswith(file,".jl") || continue
    global prefix = replace(prefix,"include($(repr(file)))" => "include($(repr(joinpath(@__DIR__,file))))")
end
prefix = replace(prefix,raw"`$(Base.julia_cmd()) --startup-file=no" =>
                        raw"`nice -n 10 timeout 300 env JULIA_NUM_THREADS=2 $(Base.julia_cmd()) --startup-file=no")
Base.include_string(RunnerProcess,prefix,RUNNER_FILE)
const STOLEN_CHANNEL_PAYLOAD = raw"""
@test true
nonce, path = Main.MUTANT_DRIVER_CHANNEL
line = "MUTANT_TALLY nonce=$(nonce) pass=0 fail=1 error=0 broken=0"
write(path,line)
println(line)
exit(19)
"""
mktempdir(get(ENV,"B102_SCRATCH",tempdir())) do scratch
    child = joinpath(scratch,"forged_child.jl")
    write(child,STOLEN_CHANNEL_PAYLOAD)
    r = RunnerProcess.run_isolated(joinpath(scratch,"child"),child,"","CRITIC_TARGET","forge")
    m = RunnerProcess.Mutant("CRIT97 stolen-channel","test/mutations/runner_channel.jl","unused","unused","runner_channel")
    d = RunnerProcess.disposition(m,r,(;ok=true,exitcode=0))
    println("P97-1 child exit=",r.exitcode," actual=1/0/0 claimed=",RunnerProcess.test_tally(r)," killed=",Int(d.killed))
    @testset "P97-1 refuse stolen-channel early exit" begin
        @test r.exitcode == 19
        @test !occursin("Test Failed at",r.output)
        @test !d.killed
    end
end
