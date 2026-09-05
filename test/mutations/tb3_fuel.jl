# briefs/23-tb3.md M-fuel: the evaluator ignores the ambient fuel; the
# starved trivial run returns a value instead of OutOfFuel. Since brief 63
# the inner Eval budget is clamped to the remaining ambient fuel (DESIGN
# 1.1, FuelBound overflow rule), so the non-terminating Fix is stopped by
# its own delimiter (OutOfFuel) rather than by the host hard cap; the
# evidence is the starved run's Value.
const TB3_FUEL_MUTANT = Mutant(
    "TB3 M-fuel eval_ignores_fuel",
    "src/ir/programs.jl",
    "    if m.fuel < k\n        m.used = m.initial_fuel",
    "    if false && m.fuel < k\n        m.used = m.initial_fuel",
    "tb3_eval",
    "MUTATION_EXPECTED_RULE fuel_bound looped=OutOfFuel starved=Value")
