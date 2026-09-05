# verdicts/tb2-r3.md N6 (NE1): the description claims a chi-independent
# continuation (every BranchByAxis table entry serialized as the first); the
# decode round trip on the chain set and the table-distinctness assertion own it.
const TB2_DESCRIBE_BYAXIS_COLLAPSE_MUTANT = Mutant(
    "TB2 M9-describe-byaxis-collapse byaxis_table_serialized_as_first_entry",
    "src/samplers/cl.jl",
    "    (:ByAxis, branch.m, branch.position, Any[_describe_term(child) for child in branch.table])",
    "    (:ByAxis, branch.m, branch.position, Any[_describe_term(first(branch.table)) for child in branch.table])",
    "tb2_describe",
    "MUTATION_EXPECTED_RULE describe_roundtrip ok=false")
