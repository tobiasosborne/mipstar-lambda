# verdicts/tb2-r7.md NG10 (the critic's MH1, verbatim): step 4(a)'s
# proof_consistency rejection is disarmed at proof copies 4 and 5 (only
# i = 3 still rejects); owned by the guard-key block of `replay_seeds`
# (cases :proof_consistency_i4/_i5, three seeds, both orientations).
const TB2_STEP4A_COPY3_ONLY_MUTANT = Mutant(
    "TB2 NG10-step4a step4a_copy3_only",
    "src/verifiers/answer_reduce.jl",
    "                result = CheckResult(current_answer[1] == other_answer[i],\n                    :proof_consistency; location=i,",
    "                result = CheckResult(current_answer[1] == other_answer[i] || i != 3,\n                    :proof_consistency; location=i,",
    "tb2_replay_seeds",
    "TB2 replay at 3 seeds (zero, tb2_seed 5, rng 0x9E): cases=19 outcomes=57 honest=57 corrupted_rejected=51")
