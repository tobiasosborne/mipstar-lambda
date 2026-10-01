# briefs/77-tb5-repair-r1.md, gate condition (iv) of verdicts/tb5-r1.md
# section 4: the TB0 calibration-ratio gate in test/runtests.jl needs a red
# witness that INFLATES the TB0 body. verdicts/tb7-r1.md T7-7 (brief 93 C):
# the body is inflated by MEASURED elapsed time -- it waits inside the timed
# region until `time() - started` exceeds (TB0_RATIO + 1) x the recorded
# kernel SUITE_CALIBRATION -- so the ratio exceeds K deterministically under
# any load (the 2026-09-27 witness added K + 1 kernel CALLS, which run faster
# than the load-inflated calibration once concurrent workers finish: the
# TB5/TB7 twins SURVIVED at ratios 3.91 < 4 and 151.36 < 198). The absolute
# 60 s gate may fail as well under this mutant.
# It runs the suite driver itself (rung :suite in run.jl).
const TB0_GATE_BODY_INFLATED_MUTANT = Mutant(
    "TB0 M-gate-body-inflated tb0_body_beyond_K_plus_1_kernels_measured",
    "test/runtests.jl",
    "    include(\"tb0_core.jl\")\n    elapsed = time() - started",
    "    include(\"tb0_core.jl\")\n    while time() - started <= (TB0_RATIO + 1) * SUITE_CALIBRATION\n        sleep(0.05)\n    end\n    elapsed = time() - started",
    "tb0_gate", "TB0 ratio gate: ratio<100.0 => false")
const SUITE_MUTANTS = (TB0_GATE_BODY_INFLATED_MUTANT,)
