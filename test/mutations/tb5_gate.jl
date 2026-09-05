# briefs/77-tb5-repair-r1.md, gate condition (iv) of verdicts/tb5-r1.md
# section 4: the TB0 calibration-ratio gate in test/runtests.jl needs a red
# witness that INFLATES the TB0 body. This mutant runs the whole TB0 test
# body three times inside the timed region (the two extra passes in fresh
# modules, so nothing is redefined): on a performance-governor box the
# inflated body (~40 s) still clears the absolute 60 s gate while the ratio
# gate must fail. It runs the suite driver itself (rung :suite in run.jl).
const TB0_GATE_BODY_INFLATED_MUTANT = Mutant(
    "TB0 M-gate-body-inflated tb0_body_run_three_times",
    "test/runtests.jl",
    "    include(\"tb0_core.jl\")\n    elapsed = time() - started",
    "    include(\"tb0_core.jl\")\n    for extra in 1:2\n        Base.include(Module(Symbol(\"TB0Inflated\", extra)), joinpath(@__DIR__, \"tb0_core.jl\"))\n    end\n    elapsed = time() - started",
    "tb0_gate", "TB0 ratio gate: ratio<")
const SUITE_MUTANTS = (TB0_GATE_BODY_INFLATED_MUTANT,)
