# verdicts/tb6-r3.md R3 (brief 84 Step 1): two permanent NEGATIVE tests of
# the runner's kill rule. Each injects `getindex(1, "critic_bad_index")` (a
# MethodError, never an assertion) into the TB6b test file -- once in its
# top-level setup (CRIT-R3-crash-outside) and once inside TB6b (k)'s
# @testset before its first assertion (CRIT-R3-crash-inside). Both make the
# target run fail with ZERO failed assertions, so neither may be credited as
# a kill: the registry asserts each is scored KILLED-BY-ERROR or
# KILLED-BY-CRASH (not credited), and fails if a probe is credited or does
# not fail at all. Under the pre-brief-84 rule the inside probe was credited
# (verdicts/tb6-r3.md R3: 0 pass / 0 fail / 1 error, registry exit 0).
const RUNNER_PROBES = (
    Mutant("PROBE CRIT-R3-crash-outside tb6b_top_level_setup_method_error",
           "test/tb6b_introspect.jl",
           "const TB6B_F_CHILD = 65_536\n",
           "const TB6B_F_CHILD = 65_536\ngetindex(1, \"critic_bad_index\")\n",
           "tb6b_nested"),
    Mutant("PROBE CRIT-R3-crash-inside tb6b_k_setup_method_error",
           "test/tb6b_introspect.jl",
           "        D_nested = I.decider.term",
           "        getindex(1, \"critic_bad_index\")\n        D_nested = I.decider.term",
           "tb6b_nested"),
)
