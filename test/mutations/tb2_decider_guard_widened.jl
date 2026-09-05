# verdicts/tb2-r4.md NF1: the decider's step 4(b) guard is widened to copy 6
# while the enumerator is untouched, so honest play on 12 enumerator-silent
# ordered pairs is rejected with :ld_question_format; owned by the lockstep
# testset over all 2916 ordered pairs.
const TB2_DECIDER_GUARD_WIDENED_MUTANT = Mutant(
    "TB2 NF1-decider-guard-widened step4b_copy_in_i_or_6",
    "src/verifiers/answer_reduce.jl",
    "               other_type.pcp.copy == i &&",
    "               other_type.pcp.copy in (i, 6) &&",
    "tb2_lockstep",
    "MUTATION_EXPECTED_RULE guard_lockstep mismatches=12")
