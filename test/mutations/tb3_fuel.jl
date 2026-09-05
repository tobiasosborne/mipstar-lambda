# briefs/23-tb3.md M-fuel: the evaluator ignores the ambient fuel; the
# non-terminating Fix then runs into the host hard step cap (Aborted) instead
# of OutOfFuel, and the starved trivial run returns a value. Time-boxed by
# the cap, never a hang. The loop's inner Eval budget (4e9) exceeds the cap
# (1e6 steps), so the cap is what stops the mutant.
const TB3_FUEL_MUTANT = Mutant(
    "TB3 M-fuel eval_ignores_fuel",
    "src/ir/programs.jl",
    "    if m.fuel < k\n        m.used = m.initial_fuel",
    "    if false && m.fuel < k\n        m.used = m.initial_fuel",
    "tb3_eval",
    "MUTATION_EXPECTED_RULE fuel_bound looped=Aborted")
