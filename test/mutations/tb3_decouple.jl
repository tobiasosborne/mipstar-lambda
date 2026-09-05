# briefs/23-tb3.md M-decouple: decouple5 sends the first 3SAT literal to
# block 1 (the answer block a) instead of block 3; the five-block shape
# assertions fail.
const TB3_DECOUPLE_MUTANT = Mutant(
    "TB3 M-decouple slot1_reuses_block1",
    "src/frontend/decouple5.jl",
    "_slot_block(k::Int) = 2 + k",
    "_slot_block(k::Int) = k == 1 ? 1 : 2 + k",
    "tb3_decouple",
    "MUTATION_EXPECTED_RULE decoupled_shape literal_blocks=[1]")
