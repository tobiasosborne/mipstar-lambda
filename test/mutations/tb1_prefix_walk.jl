# verdicts/tb1-r3.md N13 (NM10): the prefix walk ignores the prefix, so
# Factor/Linear answer at the wrong node; only the enu:cl-map-sum comparison
# of cl_kth_replay (map_sum_ok) notices.
const TB1_PREFIX_WALK_MUTANT = Mutant(
    "TB1 M9-prefix-walk walk_ignores_the_prefix",
    "src/samplers/cl.jl",
    "        key = F[u[c] for c in step.factor]",
    "        key = F[zero(F) for c in step.factor]",
    "tb1_space_sum")
