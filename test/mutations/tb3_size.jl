# briefs/23-tb3.md M-size: description_size off by one from the canonical
# byte length; the exact-size and |D| propagation assertions fail.
const TB3_SIZE_MUTANT = Mutant(
    "TB3 M-size description_size_off_by_one",
    "src/ir/programs.jl",
    "description_size(q::Quoted) = length(q.bytes)",
    "description_size(q::Quoted) = length(q.bytes) + 1",
    "tb3_quote")
