# briefs/77-tb5-repair-r1.md, gate condition (iv) of verdicts/tb5-r1.md
# section 4: the TB0 calibration-ratio gate in test/runtests.jl needs a red
# witness that INFLATES the TB0 body. Since 2026-09-27 the mutant adds
# TB0_RATIO + 1 calibration-kernel passes inside the timed region (machine-
# independent: the ratio then exceeds K on any box); the earlier witness ran
# the body three times, which is below K on the reference box once K = 100.
# The absolute 60 s gate may fail as well under this mutant.
# It runs the suite driver itself (rung :suite in run.jl).
const TB0_GATE_BODY_INFLATED_MUTANT = Mutant(
    "TB0 M-gate-body-inflated tb0_body_plus_K_kernels",
    "test/runtests.jl",
    "    include(\"tb0_core.jl\")\n    elapsed = time() - started",
    "    include(\"tb0_core.jl\")\n    for extra in 1:(Int(TB0_RATIO) + 1)\n        suite_calibration_kernel()\n    end\n    elapsed = time() - started",
    "tb0_gate", "TB0 ratio gate: ratio<100.0 => false")
const SUITE_MUTANTS = (TB0_GATE_BODY_INFLATED_MUTANT,)
