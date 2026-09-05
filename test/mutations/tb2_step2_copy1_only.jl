# verdicts/tb2-r7.md NG10 (the critic's MH3, verbatim): step 2's
# input_consistency rejection is disarmed on Bob's copy (input_copy = 2);
# owned by the guard-key block of `replay_seeds` (case
# :input_consistency_c2, three seeds, both orientations).
const TB2_STEP2_COPY1_ONLY_MUTANT = Mutant(
    "TB2 NG10-step2 step2_copy1_only",
    "src/verifiers/answer_reduce.jl",
    "            result = CheckResult(other_answer[1] == current_answer[input_copy],\n                :input_consistency; location=input_copy,",
    "            result = CheckResult(other_answer[1] == current_answer[input_copy] || input_copy == 2,\n                :input_consistency; location=input_copy,",
    "tb2_replay_seeds",
    "TB2 replay at 3 seeds (zero, tb2_seed 5, rng 0x9E): cases=19 outcomes=57 honest=57 corrupted_rejected=54")
