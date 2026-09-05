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
    "    _anchor_type(t) == :game && return _forward(ctx, :marginal, () -> _marginal(m.child, n, w, j, z, nothing, ctx))\n    _zeros(F, length(z), ctx)",
    "    _anchor_type(t)\n    _zeros(F, length(z), ctx)",
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
    "    _concat((_forward(ctx, :marginal, () -> _marginal(m.child, n, w, j, zi, t, ctx)) for zi in _repeat_blocks(m, n, z, ctx)), ctx)",
    "    _concat((_forward(ctx, :marginal, () -> _marginal(m.child, n, w, j, first(_repeat_blocks(m, n, z, ctx)), t, ctx)) for zi in _repeat_blocks(m, n, z, ctx)), ctx)",
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
    "    ctx.leaf_calls += 1\n    _metered_marginal(_leaf_map(m, w, t), j, z, ctx)",
    "    ctx.leaf_calls += 1\n    L = _leaf_map(m, w, t)\n    L isa CLStep && L.branch isa BranchByAxis && foreach(k -> _child(L, F[k]), field_elements(F))\n    _metered_marginal(L, j, z, ctx)",
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


# ---------------------------------------------------------------------------
# briefs/77-tb5-repair-r1.md (verdicts/tb5-r1.md O1-O8): one owned mutant per
# new assertion, each KILLED under the baseline-first runner.

# O1 M5-and-drops-last (the critic's CRIT-1): the k-th component's verdict
# is discarded; T5-last-corrupt (all-Game transcript, component 81 flipped)
# kills it.
const TB5_AND_DROPS_LAST_MUTANT = Mutant(
    "TB5 M5-and-drops-last kth_verdict_discarded",
    "src/descriptions/deciders.jl",
    "        verdict &= accepted\n    end\n    verdict",
    "        i < k && (verdict &= accepted)\n    end\n    verdict",
    "tb5_transcripts", "T5-last-corrupt reject=false")

# O2 M5-repeat-factor-block1 (the critic's CRIT-2): block 1's child Factor is
# computed once and replicated; the prefix-dependent-factor fixture's
# blockwise answer and the exactly-pinned metered Factor count kill it.
const TB5_REPEAT_FACTOR_BLOCK1_MUTANT = Mutant(
    "TB5 M5-repeat-factor-block1 block_one_factor_replicated",
    "src/descriptions/machines.jl",
    "    _concat((_forward(ctx, :factor, () -> _factor(m.child, n, w, j, ui, t, ctx)) for ui in _repeat_blocks(m, n, u, ctx)), ctx)",
    "    first_block = _forward(ctx, :factor, () -> _factor(m.child, n, w, j, first(_repeat_blocks(m, n, u, ctx)), t, ctx))\n    _concat((first_block for _ in _repeat_blocks(m, n, u, ctx)), ctx)",
    "tb5_repeat", "block_factors=[0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0]")

# O3 M5-exponent-integrality: integrality decided on the exponent again;
# k(9) = 9^(3/2) = 27 at c' = 1/2 is refused and the red test fails.
const TB5_EXPONENT_INTEGRALITY_MUTANT = Mutant(
    "TB5 M5-exponent-integrality refuse_nonintegral_exponent",
    "src/descriptions/laws.jl",
    "        return _exact_power(base, exponent)",
    "        exponent isa Rational && (isinteger(exponent) ? (exponent = Int(exponent)) : throw(ArgumentError(\"the exponent (1 + c')tau is not integral\")))\n        return big(base)^exponent",
    "tb5_repeat")

# O4 M5-drop-guard-exponent: the gt-11:L219/L220 finding is not disclosed;
# the node assertion (f) and the exact census (j) fail.
const TB5_DROP_GUARD_EXPONENT_MUTANT = Mutant(
    "TB5 M5-drop-guard-exponent finding_not_disclosed",
    "src/repeat/repeat.jl",
    "REPETITION_COUNT_FINDING, REPEAT_GUARD_EXPONENT, REPEAT_TUPLE_FRAMING,",
    "REPETITION_COUNT_FINDING, REPEAT_TUPLE_FRAMING,",
    "tb5_repeat")

# O6 M5-drop-framing-disclosure: a SOURCE_REPAIR disclosure silently dropped;
# only the exact census tuple sees it.
const TB5_DROP_FRAMING_DISCLOSURE_MUTANT = Mutant(
    "TB5 M5-drop-framing-disclosure census_loses_source_repair",
    "src/repeat/repeat.jl",
    "REPETITION_COUNT_FINDING, REPEAT_GUARD_EXPONENT, REPEAT_TUPLE_FRAMING,",
    "REPETITION_COUNT_FINDING, REPEAT_GUARD_EXPONENT,",
    "tb5_tree", "census=(55, 9, 27, 10, 4, 5)")

# O5 M5-wall-construction: the construction's chain set is inflated 128x;
# the hard DESIGN 10.3 construction gate (< 2 s) fails.
const TB5_WALL_CONSTRUCTION_MUTANT = Mutant(
    "TB5 M5-wall-construction chain_set_inflated",
    "test/tb5_repeat.jl",
    "c_prime=TB5_C_PRIME, tracer_index=TB5_N, seeds=32)",
    "c_prime=TB5_C_PRIME, tracer_index=TB5_N, seeds=4096)",
    "tb5_repeat", "construction<2 => false")

# O5 M5-wall-transcripts: every honest transcript samples its questions 1000
# times; the hard transcript gate (< 5 s) fails while every verdict holds.
const TB5_WALL_TRANSCRIPTS_MUTANT = Mutant(
    "TB5 M5-wall-transcripts question_sampling_inflated",
    "test/tb5_repeat.jl",
    "    x, y = sample_questions(V.sampler, TB5_N, z)\n    xs = [",
    "    foreach(_ -> sample_questions(V.sampler, TB5_N, z), 1:999)\n    x, y = sample_questions(V.sampler, TB5_N, z)\n    xs = [",
    "tb5_transcripts", "transcripts<5 => false")

# O7 M5-law-framing-dropped: the emitted question law loses the 32 framing
# bits; the law assertion and the DESIGN 10.2 lockstep fail.
const TB5_LAW_FRAMING_DROPPED_MUTANT = Mutant(
    "TB5 M5-law-framing-dropped question_law_without_framing",
    "src/descriptions/deciders.jl",
    "question=:(k(n) * (B(n) + \$(FRAME_BITS))),",
    "question=:(k(n) * B(n)),",
    "tb5_repeat")

# O8 M5-view-vertex-only: a graph view is accepted on the two vertex
# registers alone, ignoring both edge registers (a view whose own edge
# register is not neigh(t) is no encoding, gt-06:412-414); the edge-view
# census of the 128 draws (185 of 10368) fails while every verdict holds.
const TB5_VIEW_VERTEX_ONLY_MUTANT = Mutant(
    "TB5 M5-view-vertex-only edge_view_ignores_edge_registers",
    "src/repeat/anchor.jl",
    "        G == expected && return t",
    "        (G[1:T] == expected[1:T] && G[2T+1:3T] == expected[2T+1:3T]) && return t",
    "tb5_transcripts", "honest_accepts=128/128 edge_views=")

const TB5_MUTANTS = (TB5_ANCHOR_ZERO_MUTANT, TB5_ANCHOR_ANSWER_MUTANT, TB5_DETYPE_LEVEL_MUTANT,
                     TB5_SHARED_SEED_MUTANT, TB5_OR_MUTANT, TB5_NO_GUARD_MUTANT,
                     TB5_DECIDER_HASH_MUTANT, TB5_FACTOR_PARTITION_MUTANT,
                     TB5_SIZE_UNROLLED_MUTANT, TB5_ADAPTER_ENUMERATES_MUTANT,
                     TB5_LAW_DRIFT_MUTANT, TB5_DEPENDENCY_MUTANT, TB5_TENSOR_MUTANT,
                     TB5_DOWNSIZE_MUTANT, TB5_BOUNDARY_MUTANT, TB5_DETYPE_PARSER_MUTANT,
                     TB5_FRAME_TRAILING_MUTANT, TB5_ZERO_PROMOTION_MUTANT,
                     TB5_REPEAT_LEVEL_MUTANT, TB5_ANCHOR_GRAPH_MUTANT, TB5_VALIDITY_VIEWS_MUTANT,
                     TB5_AND_DROPS_LAST_MUTANT, TB5_REPEAT_FACTOR_BLOCK1_MUTANT,
                     TB5_EXPONENT_INTEGRALITY_MUTANT, TB5_DROP_GUARD_EXPONENT_MUTANT,
                     TB5_DROP_FRAMING_DISCLOSURE_MUTANT, TB5_WALL_CONSTRUCTION_MUTANT,
                     TB5_WALL_TRANSCRIPTS_MUTANT, TB5_LAW_FRAMING_DROPPED_MUTANT,
                     TB5_VIEW_VERTEX_ONLY_MUTANT)
