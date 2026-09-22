# The suite's clock calibration (verdicts/tb1-r5.md N33; verdicts/tb5-r1.md
# section 4, approved with conditions; verdicts/tb6-r1.md O2 = brief 80 D2).
#
# `suite_calibration_kernel` is a deterministic in-process kernel (1,200,000
# passes over the 512 ordered GF(8) triples accumulating a*b + c*e_i over
# runtime data, ~0.48 s quiet on the reference box at 4.8 GHz). It is timed
# ONCE, before any timed body, so it is excluded from every gated region.
# Every wall gate of the suite is a RATIO gate `elapsed / SUITE_CALIBRATION <
# K` (load-invariant where an absolute wall is not: the runner's own 4-way
# load slowed the kernel 2.7x and the TB6a body 2.0x in verdicts/tb6-r1.md
# O2) plus an absolute ceiling the runner's load cannot reach. Rule for K
# (brief 80 D2): K = max(4, ceil(3 * quiet_ratio)); ceiling = 4 * K * 0.48 s
# (>= 12x the quiet measurement). Red witnesses: test/mutations/tb5_gate.jl
# (TB0) and the M6a-/M6b-gate-body-inflated mutants of
# test/mutations/tb6_introspect.jl (the body inflated, never the kernel).
#
# Included idempotently from runtests.jl and from every rung file that gates
# on the kernel, so a rung file included standalone by the mutation runner
# (TB5_TARGET / TB6A_TARGET / TB6B_TARGET) has the kernel too.
if !isdefined(Main, :SUITE_CALIBRATION)
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
    println("suite calibration kernel seconds = ", round(SUITE_CALIBRATION; digits=4), " (excluded from every timed body)")

    # The calibrated gates: (K, absolute ceiling in seconds, the quiet in-suite
    # measurement the K was set from, in seconds, and its quiet ratio). The
    # quiet numbers are the brief-80 measurements on the reference box
    # (performance governor, load < 1); they are documentation, the gate is K.
    const CALIBRATED_GATES = (
        tb5_construction = (K=4,  ceiling=8.0,  quiet_seconds=0.0,   quiet_ratio=0.0),
        tb5_transcripts  = (K=4,  ceiling=8.0,  quiet_seconds=0.0,   quiet_ratio=0.0),
        tb5_total        = (K=8,  ceiling=16.0, quiet_seconds=0.0,   quiet_ratio=0.0),
        tb6a_audit       = (K=18, ceiling=35.0, quiet_seconds=2.765, quiet_ratio=5.76),
        tb6b_E           = (K=4,  ceiling=8.0,  quiet_seconds=0.0,   quiet_ratio=0.0),
        tb6b_M           = (K=4,  ceiling=8.0,  quiet_seconds=0.0,   quiet_ratio=0.0),
        tb6b_combined    = (K=8,  ceiling=16.0, quiet_seconds=0.0,   quiet_ratio=0.0),
    )

    """
        calibrated_gate(name, elapsed) -> (; ratio, budget, K, ceiling, ratio_ok, wall_ok)

    Evaluate the named calibrated gate on a measured wall time: prints, TB4-style,
    the ratio, the gate K, and `K * kernel` -- the budget enforced at this run's
    own rate -- and the absolute ceiling. Assert `ratio_ok` and `wall_ok`.
    """
    function calibrated_gate(name::Symbol, elapsed::Real)
        g = getfield(CALIBRATED_GATES, name)
        ratio = elapsed / SUITE_CALIBRATION
        budget = g.K * SUITE_CALIBRATION
        println("calibrated gate ", name, ": elapsed = ", round(elapsed; digits=3), " s; kernel = ", round(SUITE_CALIBRATION; digits=4),
                " s; ratio = ", round(ratio; digits=2), " (gate K = ", g.K, " => budget ", round(budget; digits=2),
                " s at this run's rate; quiet ", g.quiet_seconds, " s, quiet ratio ", g.quiet_ratio, "); absolute ceiling ", g.ceiling, " s")
        (; ratio, budget, g.K, g.ceiling, ratio_ok=ratio < g.K, wall_ok=elapsed < g.ceiling)
    end
end
