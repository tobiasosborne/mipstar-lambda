# briefs/23-tb3.md M-acc: the trace's verdict flips to rejecting while the
# formula (built from the rows) is unchanged; cook_levin's replay refuses
# with :trace_formula_equivalence before any PCP object exists.
const TB3_ACC_MUTANT = Mutant(
    "TB3 M-acc accepting_trace_reports_reject",
    "src/frontend/bounded_trace.jl",
    "accepts = run.result isa Value && run.result.value === true",
    "accepts = run.result isa Value && run.result.value === false",
    "tb3_cook_levin",
    "MUTATION_EXPECTED_RULE trace_formula_equivalence passed=false rule=trace_formula_equivalence")
