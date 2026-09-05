# verdicts/tb1-r4.md N23 (NM11 dual): every line-versus-point decision is
# judged off-line, so `ld_honest_sweep`'s `off_line_hits` must go positive;
# owned by the decider sweep's `off_line_hits == 0` and its CHECKED replay.
const TB1_OFF_LINE_MUTANT = Mutant(
    "TB1 N4-off-line line_point_test_never_agrees",
    "src/verifiers/ldt.jl",
    "(line_point(line, t) == point, t)",
    "(false, t)",
    "tb1_decider",
    "MUTATION_EXPECTED_RULE off_line reached=true")
