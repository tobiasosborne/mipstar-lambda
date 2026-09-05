# verdicts/tb3-r2.md N13: the equality snapshot's figures are owned by the
# tb3_equality target. Without the greedy support minimisation every row
# field keeps its full candidate support, so M, the clause count, the
# gadget counts and the padded circuit all grow (the critic's X2).
const TB3_N13_MUTANT = Mutant(
    "TB3 N13 support_minimisation_disabled",
    "src/frontend/cook_levin.jl",
    "            consistent(trial) && (support = trial)",
    "            false && (support = trial)",
    "tb3_equality")
