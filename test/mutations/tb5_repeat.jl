# briefs/39-tb5-descriptions-repeat.md: the seven M5-* mutants of DESIGN
# 10.3 with their named killers, the Anchor-scoped M-factor-partition
# (verdicts/design-v2-r3.md NOTE-A), M9-size-unrolled and
# M9-adapter-enumerates (brief 39 addendum 2), plus one mutant per new
# check family of the description layer (laws, dependency walk, tensor
# graph, downsize expansion, boundary QueryError, detype parser, framing,
# zero-map promotion, repeat level, anchor typing, validity views).
# Each runs the named tb5_* target in an isolated copy.

# M5-anchor-zero: Game mapped to the zero map; T5-game-seed1's generated
# question changes while the golden answer stays 1, and the query-reference
# replay differs.
const TB5_ANCHOR_ZERO_MUTANT = Mutant(
    "TB5 M5-anchor-zero game_mapped_to_zero",
    "src/descriptions/machines.jl",
    "    _anchor_type(t) == :game && return _forward(ctx, :marginal, () -> _marginal(m.child, n, w, j, z, nothing, ctx))\n    _zeros(F, length(z))",
    "    _anchor_type(t)\n    _zeros(F, length(z))",
    "tb5_transcripts")

# M5-anchor-answer: an Anchor-typed answer 1 is accepted; T5-anchor-one kills it.
const TB5_ANCHOR_ANSWER_MUTANT = Mutant(
    "TB5 M5-anchor-answer accept_anchor_answer_one",
    "src/descriptions/deciders.jl",
    "        tA == \"Anchor\" && a != [false] && return false\n        tB == \"Anchor\" && b != [false] && return false",
    "        tA == \"Anchor\" && length(a) != 1 && return false\n        tB == \"Anchor\" && length(b) != 1 && return false",
    "tb5_transcripts")

# M5-detype-level: detyping reports ell + 1; the law replay and the level
# assertions fail.
const TB5_DETYPE_LEVEL_MUTANT = Mutant(
    "TB5 M5-detype-level ell_plus_one",
    "src/descriptions/machines.jl",
    "machine_level(m::DetypeMachine) = machine_level(m.child) + 2",
    "machine_level(m::DetypeMachine) = machine_level(m.child) + 1",
    "tb5_anchor")

# M5-shared-seed: block 1's seed reused in every repetition; the blockwise
# sample replay fails.
const TB5_SHARED_SEED_MUTANT = Mutant(
    "TB5 M5-shared-seed block_one_reused",
    "src/descriptions/machines.jl",
    "    reduce(vcat, (_forward(ctx, :marginal, () -> _marginal(m.child, n, w, j, zi, t, ctx)) for zi in _repeat_blocks(m, n, z, ctx)))",
    "    reduce(vcat, (_forward(ctx, :marginal, () -> _marginal(m.child, n, w, j, first(_repeat_blocks(m, n, z, ctx)), t, ctx)) for zi in _repeat_blocks(m, n, z, ctx)))",
    "tb5_repeat")

# M5-or: the repeated decisions are combined by OR; T5-one-corrupt kills it.
const TB5_OR_MUTANT = Mutant(
    "TB5 M5-or repeated_decisions_by_or",
    "src/descriptions/deciders.jl",
    "    verdict = true\n    for i in 1:k\n        accepted = _decide(child, n, xs[i], ys[i], as[i], bs[i], trace)\n        push!(trace, ChildCall(i, accepted))\n        verdict &= accepted",
    "    verdict = false\n    for i in 1:k\n        accepted = _decide(child, n, xs[i], ys[i], as[i], bs[i], trace)\n        push!(trace, ChildCall(i, accepted))\n        verdict |= accepted",
    "tb5_transcripts")

# M5-no-guard: an oversized component is read and passed on; T5-boundary's
# empty pre-call log kills it.
const TB5_NO_GUARD_MUTANT = Mutant(
    "TB5 M5-no-guard oversized_component_read",
    "src/descriptions/deciders.jl",
    "        len <= B || return nothing",
    "        true || return nothing",
    "tb5_transcripts")

# M5-decider-hash: the repeated sampler's bytes depend on the decider's
# content; the two-decider hash test fails.
const TB5_DECIDER_HASH_MUTANT = Mutant(
    "TB5 M5-decider-hash sampler_depends_on_decider",
    "src/repeat/repeat.jl",
    "    sampler = repeat_sampler(A.sampler, lambda, tau; c_prime=c, tracer_index=n, seeds)",
    "    sampler = repeat_sampler(A.sampler, lambda, tau + (V.decider.term[1] == :Copy ? 0 : 1); c_prime=c, tracer_index=n, seeds)",
    "tb5_independence")

# M-factor-partition (Anchor-scoped, NOTE-A): the literal all-zero Anchor
# factor of gt-11:96 at every stage; the Anchor-scoped enu:cl-space-sum
# replay and Factor assertion kill it.
const TB5_FACTOR_PARTITION_MUTANT = Mutant(
    "TB5 M-factor-partition anchor_literal_zero_factor",
    "src/descriptions/machines.jl",
    "    j == 1 ? ones(Int, length(u)) : zeros(Int, length(u))\nend\n\n# ---------------------------------------------------------------------------\n# DL9-detype",
    "    zeros(Int, length(u))\nend\n\n# ---------------------------------------------------------------------------\n# DL9-detype",
    "tb5_anchor")

# M9-size-unrolled: description_size charged k times; (f)'s k-independence
# and the DescriptionSize replay fail.
const TB5_SIZE_UNROLLED_MUTANT = Mutant(
    "TB5 M9-size-unrolled description_size_times_k",
    "src/descriptions/transformations.jl",
    "                       length(bytes), dependency_walk(bytes), laws.k, children, evidence, Ref{Any}(m))",
    "                       (term[1] == :Repeat ? length(bytes) * k_rep(term[2], term[3], term[4] // term[5], 9) : length(bytes)), dependency_walk(bytes), laws.k, children, evidence, Ref{Any}(m))",
    "tb5_repeat")

# M9-adapter-enumerates: a leaf Marginal materialises every continuation of
# a BranchByAxis stage; the memo observability assertion kills it.
const TB5_ADAPTER_ENUMERATES_MUTANT = Mutant(
    "TB5 M9-adapter-enumerates marginal_walks_all_branches",
    "src/descriptions/machines.jl",
    "    ctx.leaf_calls += 1\n    collect(Marginal(_leaf_map(m, w, t), j, z))",
    "    ctx.leaf_calls += 1\n    L = _leaf_map(m, w, t)\n    L isa CLStep && L.branch isa BranchByAxis && foreach(k -> _child(L, F[k]), field_elements(F))\n    collect(Marginal(L, j, z))",
    "tb5_queries")

# M-law-drift: the emitted direct-sum dimension law is a product; the
# LawCert and the AST assertion fail.
const TB5_LAW_DRIFT_MUTANT = Mutant(
    "TB5 M-law direct_sum_dimension_product",
    "src/descriptions/transformations.jl",
    "    tag == :DirectSum && return (; field=:q_1, level=_max_law(ells), dimension=_sum_law(ss),",
    "    tag == :DirectSum && return (; field=:q_1, level=_max_law(ells), dimension=(r == 1 ? ss[1] : Expr(:call, :*, ss...)),",
    "tb5_laws")

# M-dependency: the syntax walk forgets c'; the exact dependency set fails.
const TB5_DEPENDENCY_MUTANT = Mutant(
    "TB5 M-dependency walk_drops_c_prime",
    "src/descriptions/sorts.jl",
    "    term[1] == :Repeat && push!(found, :lambda, :tau, :c_prime)\n    foreach(child -> _dependency_walk!(found, child), _term_children(term))",
    "    term[1] == :Repeat && push!(found, :lambda, :tau)\n    foreach(child -> _dependency_walk!(found, child), _term_children(term))",
    "tb5_independence")

# M-tensor: the product type graph is the Cartesian graph; the red edge
# ((oracle,Point_1),(alice,DLine_6)) is missing.
const TB5_TENSOR_MUTANT = Mutant(
    "TB5 M-tensor cartesian_product_graph",
    "src/descriptions/machines.jl",
    "    edges = Tuple{String,String}[(_product_label(l, r), _product_label(l2, r2))\n                                 for (l, l2) in lt.edges for (r, r2) in rt.edges]",
    "    edges = unique(vcat(Tuple{String,String}[(_product_label(l, r), _product_label(l2, r)) for (l, l2) in lt.edges for r in rt.labels],\n                        Tuple{String,String}[(_product_label(l, r), _product_label(l, r2)) for l in lt.labels for (r, r2) in rt.edges]))",
    "tb5_laws")

# M-downsize: the child indicator bits are replicated outer-wise, not
# coordinatewise; the expanded Factor assertion fails.
const TB5_DOWNSIZE_MUTANT = Mutant(
    "TB5 M-downsize factor_bits_outer",
    "src/descriptions/machines.jl",
    "    repeat(indicator; inner=m.kappa)",
    "    repeat(indicator; outer=m.kappa)",
    "tb5_laws")

# M-boundary: illegal calls throw instead of returning QueryError.
const TB5_BOUNDARY_MUTANT = Mutant(
    "TB5 M-boundary query_throws",
    "src/descriptions/machines.jl",
    "        _validated_answer(machine(S), q, Meter())\n    catch error\n        error isa ArgumentError && return QueryError(error.msg)",
    "        _validated_answer(machine(S), q, Meter())\n    catch error\n        error isa ArgumentError && rethrow()",
    "tb5_queries")

# M-detype-parser: the detyped decider rejects when it cannot parse; the
# literal accept-on-invalid assertion fails.
const TB5_DETYPE_PARSER_MUTANT = Mutant(
    "TB5 M-detype-parser reject_on_parse_failure",
    "src/descriptions/deciders.jl",
    "        (length(x) >= 4T && length(y) >= 4T) || return true",
    "        (length(x) >= 4T && length(y) >= 4T) || return false",
    "tb5_anchor")

# M-frame: trailing bits after the k-th component are ignored.
const TB5_FRAME_TRAILING_MUTANT = Mutant(
    "TB5 M-frame trailing_bits_ignored",
    "src/descriptions/deciders.jl",
    "    position == length(bits) || return nothing\n    components",
    "    components",
    "tb5_transcripts")

# M-zero-promotion: a promoted zero summand reports the all-ones factor at
# every stage; the direct sum's enu:cl-space-sum replay fails.
const TB5_ZERO_PROMOTION_MUTANT = Mutant(
    "TB5 M-zero-promotion all_ones_every_stage",
    "src/descriptions/machines.jl",
    "        return j == 1 ? ones(Int, length(u)) : zeros(Int, length(u))\n    end\n    j > r && (_require_image",
    "        return ones(Int, length(u))\n    end\n    j > r && (_require_image",
    "tb5_laws")

# M-repeat-level: the repeated sampler adds two levels on top of anchoring
# (DESIGN 9.4: the two +2 rows must not compose).
const TB5_REPEAT_LEVEL_MUTANT = Mutant(
    "TB5 M-repeat-level repeat_adds_two_levels",
    "src/descriptions/machines.jl",
    "machine_level(m::RepeatMachine) = machine_level(m.child)",
    "machine_level(m::RepeatMachine) = machine_level(m.child) + 2",
    "tb5_repeat")

# M-anchor-graph: the anchor type graph loses its self-loops.
const TB5_ANCHOR_GRAPH_MUTANT = Mutant(
    "TB5 M-anchor-graph no_self_loops",
    "src/descriptions/machines.jl",
    "                            [(\"Game\", \"Game\"), (\"Game\", \"Anchor\"), (\"Anchor\", \"Game\"), (\"Anchor\", \"Anchor\")])",
    "                            [(\"Game\", \"Anchor\"), (\"Anchor\", \"Game\")])",
    "tb5_anchor")

# M-validity-views: the output-sampler replay row runs on alice only.
const TB5_VALIDITY_VIEWS_MUTANT = Mutant(
    "TB5 M-validity alice_only_replay",
    "src/descriptions/transformations.jl",
    "    views = S.typing isa Untyped ? [(w, nothing) for w in PLAYERS] :\n                                   [(w, t) for w in PLAYERS for t in S.typing.labels]",
    "    views = S.typing isa Untyped ? [(:alice, nothing)] :\n                                   [(:alice, t) for t in S.typing.labels]",
    "tb5_replay")

const TB5_MUTANTS = (TB5_ANCHOR_ZERO_MUTANT, TB5_ANCHOR_ANSWER_MUTANT, TB5_DETYPE_LEVEL_MUTANT,
                     TB5_SHARED_SEED_MUTANT, TB5_OR_MUTANT, TB5_NO_GUARD_MUTANT,
                     TB5_DECIDER_HASH_MUTANT, TB5_FACTOR_PARTITION_MUTANT,
                     TB5_SIZE_UNROLLED_MUTANT, TB5_ADAPTER_ENUMERATES_MUTANT,
                     TB5_LAW_DRIFT_MUTANT, TB5_DEPENDENCY_MUTANT, TB5_TENSOR_MUTANT,
                     TB5_DOWNSIZE_MUTANT, TB5_BOUNDARY_MUTANT, TB5_DETYPE_PARSER_MUTANT,
                     TB5_FRAME_TRAILING_MUTANT, TB5_ZERO_PROMOTION_MUTANT,
                     TB5_REPEAT_LEVEL_MUTANT, TB5_ANCHOR_GRAPH_MUTANT, TB5_VALIDITY_VIEWS_MUTANT)
