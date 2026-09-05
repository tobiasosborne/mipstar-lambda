load_started = time()
using Test
using MIPStarLambda
load_elapsed = time() - load_started
# Warm load only. The COLD image build, which executes src/precompile.jl's
# TB0 workload, is timed by `tools/cold_precompile.sh` (scratch depot).
println("MIPStarLambda load/precompile seconds = ", round(load_elapsed; digits=3),
        " (ungated; cold image build: tools/cold_precompile.sh)")

# TB0 gate (verdicts/tb1-r5.md N33; verdicts/tb5-r1.md section 4, approved
# with conditions): the absolute `elapsed < 60` stays hard, and the body is
# ALSO gated as a clock-calibrated ratio. `suite_calibration_kernel` is a
# deterministic in-process kernel (1,200,000 passes over the 512 ordered GF(8)
# triples accumulating a*b + c*e_i over runtime data, ~0.5 s on this box at
# 4.8 GHz), timed once
# BEFORE `started` so it is excluded from the timed body; the gate is
# elapsed / calibration < TB0_RATIO, set once from quiet performance-governor
# runs (brief 77). TB0_BUDGET_SECONDS only LOWERS the wall bound. Red
# witness: test/mutations/tb5_gate.jl (the body run three times).
function suite_calibration_kernel()
    elements = collect(field_elements(GF8))   # runtime data, so the loop is not folded away
    acc = zero(GF8)
    for i in 1:1_200_000, a in elements, b in elements, c in elements
        acc += a * b + c * elements[(i % 8) + 1]
    end
    acc
end
const SUITE_KERNEL_VALUE = suite_calibration_kernel()   # warm-up; the value is deterministic
const SUITE_CALIBRATION = @elapsed suite_calibration_kernel()
const TB0_RATIO = 50.0
const TB0_WALL_BUDGET = min(60.0, haskey(ENV, "TB0_BUDGET_SECONDS") ? parse(Float64, ENV["TB0_BUDGET_SECONDS"]) : 60.0)
println("suite calibration kernel seconds = ", round(SUITE_CALIBRATION; digits=4), " (excluded from the TB0 body)")

started = time()
@testset verbose=true "MIPStarLambda" begin
    include("tb0_core.jl")
    elapsed = time() - started
    measured = round(elapsed; digits=3)
    ratio = elapsed / SUITE_CALIBRATION
    println("TB0 test-body wall seconds = ", measured,
            " (warning=45.0, hard_limit=", TB0_WALL_BUDGET, "); calibration kernel = ",
            round(SUITE_CALIBRATION; digits=4), " s; ratio = ", round(ratio; digits=1), " (gate ", TB0_RATIO, ")")
    elapsed >= 45 && @warn "TB0 test body exceeded its 45 s warning" measured_seconds=measured
    println("TB0 ratio gate: ratio<", TB0_RATIO, " => ", ratio < TB0_RATIO, "; wall<", TB0_WALL_BUDGET, " => ", elapsed < TB0_WALL_BUDGET)
    @testset "TB0 test-body gates: wall < $(TB0_WALL_BUDGET) s (measured $(measured) s); body / calibration kernel < $(TB0_RATIO) (measured $(round(ratio; digits=1)))" begin
        @test suite_calibration_kernel() == SUITE_KERNEL_VALUE   # the kernel is deterministic
        @test elapsed < TB0_WALL_BUDGET
        @test ratio < TB0_RATIO
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
    tb6_started = time()
    include("tb6a_audit.jl")
    include("tb6b_introspect.jl")
    println("TB6 test-body wall seconds = ", round(time() - tb6_started; digits=3), " (TB6a target < 1; TB6b-E < 3 + 15, TB6b-M < 25, combined < 43)")
end
