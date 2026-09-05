# verdicts/tb1-r4.md N24 (NM12): stage matrices serialized column-major;
# owned by the nonsymmetric [1 1; 0 1] byte window 35:38.
const TB1_DESCRIBE_TRANSPOSE_MUTANT = Mutant(
    "TB1 N24-describe-transpose field_ints_column_major",
    "src/samplers/cl.jl",
    "    Int[Int(matrix[r, c].bits) for r in 1:size(matrix, 1) for c in 1:size(matrix, 2)]",
    "    Int[Int(matrix[r, c].bits) for c in 1:size(matrix, 2) for r in 1:size(matrix, 1)]",
    "tb1_describe",
    "MUTATION_EXPECTED_RULE describe_transpose row_major=false")
