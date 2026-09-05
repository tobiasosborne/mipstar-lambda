# verdicts/tb2-r4.md NF2: fig:decider-pcp item 1 compares only the first
# answer entry; owned by the arity-22 step-1 rejections on the equal-type
# copy-6 pairs.
const TB2_GLOBAL_CONSISTENCY_FIRST_ENTRY_MUTANT = Mutant(
    "TB2 NF2-global-consistency-first-entry step1_compares_first_entry_only",
    "src/verifiers/answer_reduce.jl",
    "        equal = _answers_equal(left_parsed, right_parsed)",
    "        equal = _answers_equal(left_parsed[1:1], right_parsed[1:1])",
    "tb2_lockstep",
    "MUTATION_EXPECTED_RULE global_consistency arity=22 rejected_with_rule=5/20")
