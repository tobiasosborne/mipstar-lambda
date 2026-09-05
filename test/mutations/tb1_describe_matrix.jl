# verdicts/tb1-r3.md N12 (NM7): the canonical description ignores every stage
# matrix; the decode round trip, the separator pair and the byte window own it.
const TB1_DESCRIBE_MATRIX_MUTANT = Mutant(
    "TB1 M9-describe-matrix description_ignores_stage_matrices",
    "src/samplers/cl.jl",
    "    Int[Int(matrix[r, c].bits) for r in 1:size(matrix, 1) for c in 1:size(matrix, 2)]",
    "    Int[0 for r in 1:size(matrix, 1) for c in 1:size(matrix, 2)]",
    "tb1_describe",
    "MUTATION_EXPECTED_RULE describe_roundtrip ok=false")
