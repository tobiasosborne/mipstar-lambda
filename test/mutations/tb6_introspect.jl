# briefs/43-tb6-introspect.md: the twelve owned TB6 mutations of DESIGN 11.6
# (M6-pauli-edge, M6-pauli-gamma, M6-sampler-nonzero, M6-N, M6-factor-prefix,
# M6-perp, M6-game, M6-boundary, M6-noncommuting, M-factor-partition,
# M-detype-view-orientation, M-intro-fuel) plus the TB6a audit's three
# (missing edge = M6-pauli-edge, wrong count, missing guard) and the
# check-after-return variant of M-intro-fuel. Each runs its tb6a_/tb6b_
# target in an isolated copy under the baseline-first runner.

const TB6_PAULI_EDGE_MUTANT = Mutant(
    "TB6 M6-pauli-edge remove_PointW_PauliW",
    "src/introspect/pauli_types.jl",
    "        push!(edges, (\"Point_\$(W)\", \"Pauli_\$(W)\"))\n",
    "",
    "tb6a_graphs")

const TB6A_COUNT_MUTANT = Mutant(
    "TB6 M6a-count loops_skip_first_label",
    "src/introspect/pauli_types.jl",
    "    for l in labels\n        push!(pairs, (l, l))\n    end",
    "    for l in labels[2:end]\n        push!(pairs, (l, l))\n    end",
    "tb6a_graphs")

const TB6A_GUARD_MUTANT = Mutant(
    "TB6 M6a-guard item7_point_variable_missing",
    "src/introspect/pauli_decider.jl",
    "    if kw == :Point && kv == :Variable\n        (xw === nothing || xv === nothing) && return false",
    "    if false && kw == :Point && kv == :Variable\n        (xw === nothing || xv === nothing) && return false",
    "tb6a_schemas")

const TB6_PAULI_GAMMA_MUTANT = Mutant(
    "TB6 M6-pauli-gamma trace_bit_flipped",
    "src/introspect/pauli_decider.jl",
    "    field_trace(sum(a .* b; init=zero(eltype(a))))\nend",
    "    !field_trace(sum(a .* b; init=zero(eltype(a))))\nend",
    "tb6b_pauli")

const TB6_SAMPLER_NONZERO_MUTANT = Mutant(
    "TB6 M6-sampler-nonzero introspect_has_a_content_map",
    "src/introspect/pauli_sampler.jl",
    "        haskey(maps, label) || (maps[label] = CLZero(F, n))",
    "        haskey(maps, label) || (maps[label] = startswith(label, \"Introspect\") ? maps[\"Pair\"] : CLZero(F, n))",
    "tb6b_sampler")

const TB6_N_MUTANT = Mutant(
    "TB6 M6-N child_called_at_n_not_2n",
    "src/introspect/intro_decider.jl",
    "    N = 2 ^ n\n    R = big(N) ^ lambda",
    "    N = n\n    R = big(2 ^ n) ^ lambda",
    "tb6b_schedule")

const TB6_FACTOR_PREFIX_MUTANT = Mutant(
    "TB6 M6-factor-prefix hide_k1_uses_earlier_players_prefix",
    "src/introspect/intro_decider.jl",
    "        sched_v = _schedule(c, role, yv, k + 1, s)",
    "        sched_v = _schedule(c, role, yw, k + 1, s)",
    "tb6b_M")

const TB6_PERP_MUTANT = Mutant(
    "TB6 M6-perp stage_matrix_transposed",
    "src/introspect/intro_decider.jl",
    "        M[:, i] = column[register]\n    end\n    M\nend",
    "        M[i, :] = column[register]\n    end\n    M\nend",
    "tb6b_M")

const TB6_GAME_MUTANT = Mutant(
    "TB6 M6-game introspected_questions_swapped",
    "src/introspect/intro_decider.jl",
    "        verdict = _child_decide(c, _V(aw_p.y, s), _V(av_p.y, s), aw_p.a, av_p.a)",
    "        verdict = _child_decide(c, _V(av_p.y, s), _V(aw_p.y, s), av_p.a, aw_p.a)",
    "tb6b_M")

const TB6_BOUNDARY_MUTANT = Mutant(
    "TB6 M6-boundary literal_3Q_guard",
    "src/introspect/intro_decider.jl",
    "    intro_guard_operative(a, b, Q) && return false",
    "    intro_guard_literal(a, b, Q) && return false",
    "tb6b_E")

const TB6_NONCOMMUTING_MUTANT = Mutant(
    "TB6 M6-noncommuting anticommuting_family_allowed",
    "src/introspect/stabilizer.jl",
    "        anticommute(family[i], family[j]) &&\n            throw(ArgumentError(",
    "        false &&\n            throw(ArgumentError(",
    "tb6b_stabilizer")

# A zero-matrix stage (the promoted zero map's stage 1) reports the literal
# all-zero factor of gt-07:L1106-L1108 / gt-08:L333-L345.
const TB6_FACTOR_PARTITION_MUTANT = Mutant(
    "TB6 M-factor-partition zero_stage_reports_zero_factor",
    "src/introspect/meter.jl",
    "    indicator = zeros(Int, seed_dim(L))\n    for c in node.factor\n        indicator[c] = 1\n    end\n    indicator\nend",
    "    indicator = zeros(Int, seed_dim(L))\n    for c in (all(iszero, node.matrix) ? Int[] : node.factor)\n        indicator[c] = 1\n    end\n    indicator\nend",
    "tb6b_pauli")

const TB6_DETYPE_VIEW_ORIENTATION_MUTANT = Mutant(
    "TB6 M-detype-view-orientation views_swapped",
    "src/descriptions/deciders.jl",
    "            xG == vcat(unit(l), neigh(l), falses(T), unit(l)) || continue\n            yG == vcat(falses(T), unit(r), unit(r), neigh(r)) || continue",
    "            xG == vcat(falses(T), unit(l), unit(l), neigh(l)) || continue\n            yG == vcat(unit(r), neigh(r), falses(T), unit(r)) || continue",
    "tb6b_M")

const TB6_INTRO_FUEL_MUTANT = Mutant(
    "TB6 M-intro-fuel production_budget_R_squared",
    "src/introspect/intro_decider.jl",
    "_budget(c::_IntroContext) = c.fuel == 0 ? c.R : c.fuel",
    "_budget(c::_IntroContext) = c.fuel == 0 ? c.R ^ 2 : c.fuel",
    "tb6b_fuel")

# The check-after-return variant: the (budget + 1)-th step executes before the meter refuses.
const TB6_INTRO_FUEL_AFTER_MUTANT = Mutant(
    "TB6 M-intro-fuel-after budget_checked_after_the_step",
    "src/descriptions/machines.jl",
    "    total = ctx.steps + k\n    ctx.budget > 0 && total > ctx.budget && throw(FuelExhausted(total, ctx.budget))\n    ctx.steps = total",
    "    total = ctx.steps + k\n    ctx.steps = total\n    ctx.budget > 0 && total > ctx.budget && throw(FuelExhausted(total, ctx.budget))",
    "tb6b_fuel")

const TB6_MUTANTS = (TB6_PAULI_EDGE_MUTANT, TB6A_COUNT_MUTANT, TB6A_GUARD_MUTANT, TB6_PAULI_GAMMA_MUTANT,
                     TB6_SAMPLER_NONZERO_MUTANT, TB6_N_MUTANT, TB6_FACTOR_PREFIX_MUTANT, TB6_PERP_MUTANT,
                     TB6_GAME_MUTANT, TB6_BOUNDARY_MUTANT, TB6_NONCOMMUTING_MUTANT, TB6_FACTOR_PARTITION_MUTANT,
                     TB6_DETYPE_VIEW_ORIENTATION_MUTANT, TB6_INTRO_FUEL_MUTANT, TB6_INTRO_FUEL_AFTER_MUTANT)
