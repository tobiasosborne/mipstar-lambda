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
    "    for c in node.factor\n        indicator[c] = 1\n    end\n    indicator\nend",
    "    for c in (all(iszero, node.matrix) ? Int[] : node.factor)\n        indicator[c] = 1\n    end\n    indicator\nend",
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
    "_budget(c::_IntroContext) = c.fuel == 0 ? (c.R <= typemax(Int) ? Int(c.R) : 0) : c.fuel",
    "_budget(c::_IntroContext) = c.fuel == 0 ? (c.R <= typemax(Int) ? Int(c.R) ^ 2 : 0) : c.fuel",
    "tb6b_fuel")

# The check-after-return variant: the (budget + 1)-th step executes before the meter refuses.
const TB6_INTRO_FUEL_AFTER_MUTANT = Mutant(
    "TB6 M-intro-fuel-after budget_checked_after_the_step",
    "src/descriptions/machines.jl",
    "    total = ctx.steps + k\n    ctx.budget > 0 && total > ctx.budget && throw(FuelExhausted(total, ctx.budget))\n    ctx.steps = total",
    "    total = ctx.steps + k\n    ctx.steps = total\n    ctx.budget > 0 && total > ctx.budget && throw(FuelExhausted(total, ctx.budget))",
    "tb6b_fuel")

# --- brief 80 (verdicts/tb6-r1.md O1-O4, O8, O9, section 7): the TB6 repair r1 mutants ------------------------
# D1: one conjunct-drop mutant per comparison of items 2(a)-3(d) of `_intro_ordered` (thirteen; the critic's
# CRIT-1 spans two sites and is registered per site, CRIT-4 verbatim); each is caught only by its named negative
# transcript in TB6b (j).
const TB6_CONJUNCT_MUTANTS = (
    Mutant("TB6 M6-sampling-pauli-z drop_a_w_V_eq_z_wbar (C01)", "src/introspect/intro_decider.jl",
           "        return _V(aw, s) == _V(ans.y, s)\n",
           "        return true\n", "tb6b_negative"),
    Mutant("TB6 M6-sampling-image drop_y_w_eq_L_z_wbar (C02)", "src/introspect/intro_decider.jl",
           "        return _V(aw_p.y, s) == _bools(image) && aw_p.a == av_p.a\n",
           "        return aw_p.a == av_p.a\n", "tb6b_negative"),
    Mutant("TB6 CRIT-1 sampling_intro drop_a_w_eq_a_wbar (C03)", "src/introspect/intro_decider.jl",
           "        return _V(aw_p.y, s) == _bools(image) && aw_p.a == av_p.a\n",
           "        return _V(aw_p.y, s) == _bools(image)\n", "tb6b_negative"),
    Mutant("TB6 M6-hiding-intro-y drop_y_w_eq_y_wbar (C04)", "src/introspect/intro_decider.jl",
           "        return aw_p.y == av_p.y && aw_p.a == av_p.a\n",
           "        return aw_p.a == av_p.a\n", "tb6b_negative"),
    Mutant("TB6 CRIT-1 hiding_intro drop_a_w_eq_a_wbar (C05)", "src/introspect/intro_decider.jl",
           "        return aw_p.y == av_p.y && aw_p.a == av_p.a\n",
           "        return aw_p.y == av_p.y\n", "tb6b_negative"),
    Mutant("TB6 M6-read-below drop_y_below_ell_equal (C06)", "src/introspect/intro_decider.jl",
           "        return below_w == below_v && aw_p.y_perp == av_p.y_perp\n",
           "        return aw_p.y_perp == av_p.y_perp\n", "tb6b_negative"),
    Mutant("TB6 CRIT-4 M6-read-perp hiding_read drop_y_perp_w_eq_y_perp_wbar (C07)", "src/introspect/intro_decider.jl",
           "        return below_w == below_v && aw_p.y_perp == av_p.y_perp\n",
           "        return below_w == below_v\n", "tb6b_negative"),
    Mutant("TB6 M6-same-below drop_shared_prefix (C08)", "src/introspect/intro_decider.jl",
           "        below_w == below_v || return false\n        # Registers V_{<= k}(y_w), V_{<= k+1}(y_wbar)",
           "        # Registers V_{<= k}(y_w), V_{<= k+1}(y_wbar)", "tb6b_negative"),
    Mutant("TB6 M6-same-dual-prefix drop_y_perp_on_V_le_k (C09)", "src/introspect/intro_decider.jl",
           "        _project(_V(aw_p.y_perp, s), le_k_w) == _project(_V(av_p.y_perp, s), le_k_v) || return false\n",
           "", "tb6b_negative"),
    Mutant("TB6 M6-same-suffix drop_x_on_V_gt_k1 (C10)", "src/introspect/intro_decider.jl",
           "        _project(_V(aw_p.x, s), gt_k1_v) == _project(_V(av_p.x, s), gt_k1_v) || return false\n",
           "", "tb6b_negative"),
    Mutant("TB6 M6-same-dual-image drop_L_perp_x_k1 (C11)", "src/introspect/intro_decider.jl",
           "        return _apply_perp(M, _restrict(_V(aw_p.x, s), V_k1)) == _restrict(_V(av_p.y_perp, s), V_k1)\n",
           "        return true\n", "tb6b_negative"),
    Mutant("TB6 M6-pauli-hide-dual drop_L_1_perp_image (C12)", "src/introspect/intro_decider.jl",
           "        _apply_perp(M, _restrict(_V(aw, s), V_1)) == _restrict(_V(av_p.y_perp, s), V_1) || return false\n",
           "", "tb6b_negative"),
    Mutant("TB6 M6-pauli-hide-suffix drop_a_hat_w_V_gt_1 (C13)", "src/introspect/intro_decider.jl",
           "        return _project(_V(aw, s), gt_1) == _project(_V(av_p.x, s), gt_1)\n",
           "        return true\n", "tb6b_negative"),
)

# D2: the calibrated gates' red witnesses inflate a BODY (K + 1 extra kernel passes inside the timed region), never
# the kernel; the ratio gate must fail while the absolute ceiling (>= 4 K kernels) still holds.
const TB6A_GATE_BODY_INFLATED_MUTANT = Mutant(
    "TB6 M6a-gate-body-inflated tb6a_audit_body_plus_19_kernels",
    "test/tb6a_audit.jl",
    "tb6a_audit_elapsed = round(time() - tb6a_started; digits=3)   # the audit proper: testsets (1) and (2)",
    "for _ in 1:(CALIBRATED_GATES.tb6a_audit.K + 1)\n    suite_calibration_kernel()\nend\ntb6a_audit_elapsed = round(time() - tb6a_started; digits=3)   # the audit proper: testsets (1) and (2)",
    "tb6a_gate", "tb6a_gate ratio<18 => false")
const TB6B_GATE_BODY_INFLATED_MUTANT = Mutant(
    "TB6 M6b-gate-body-inflated tb6b_M_transcripts_plus_K_kernels",
    "test/tb6b_introspect.jl",
    "        TB6B_LOG[:M_transcript_seconds] = round(time() - started; digits=3)",
    "        for _ in 1:(CALIBRATED_GATES.tb6b_M.K + 1)\n            suite_calibration_kernel()\n        end\n        TB6B_LOG[:M_transcript_seconds] = round(time() - started; digits=3)",
    "tb6b_gate")
const TB5_GATE_BODY_INFLATED_MUTANT = Mutant(
    "TB5 M5-gate-body-inflated tb5_transcripts_plus_K_kernels",
    "test/tb5_repeat.jl",
    "        TB5_LOG[:transcript_seconds] = round(time() - started; digits=3)",
    "        for _ in 1:(CALIBRATED_GATES.tb5_transcripts.K + 1)\n            suite_calibration_kernel()\n        end\n        TB5_LOG[:transcript_seconds] = round(time() - started; digits=3)",
    "tb5_gate")

# D3: a determined stabilizer outcome sampled freely -- the enumerator's total mass stays one, the distribution
# changes; caught by the dense reference and the leaf pins, never by a mass check.
const TB6_FORCED_OUTCOME_FREE_MUTANT = Mutant(
    "TB6 M6-forced-outcome-free determined_outcome_drawn_from_choose",
    "src/introspect/stabilizer.jl",
    "    (scratch.x[h, :] == p.x && scratch.z[h, :] == p.z) || error(\"determined outcome does not reproduce the measured string\")\n    scratch.r[h] ⊻ p.r\nend",
    "    (scratch.x[h, :] == p.x && scratch.z[h, :] == p.z) || error(\"determined outcome does not reproduce the measured string\")\n    choose()::Bool\nend",
    "tb6b_E")

# D4: the pinned measurements (verdicts/tb6-r1.md O4).
const TB6_CHARGE_BRANCH_MUTANT = Mutant(
    "TB6 M6-charge-branch drop_branch_selection_charge",
    "src/introspect/meter.jl",
    "    _charge!(ctx, 1)\n    (full, local_output, _child(L, local_output))",
    "    (full, local_output, _child(L, local_output))",
    "tb6b_tree")
const TB6_LITERAL_SUFFIX_REGISTER_MUTANT = Mutant(
    "TB6 M6-literal-suffix-register hide_suffix_literal_uses_y_wbar_twice",
    "src/introspect/intro_decider.jl",
    "    _project(x_w, reg(y_w)) == _project(x_v, reg(y_v))\nend",
    "    _project(x_w, reg(y_v)) == _project(x_v, reg(y_v))\nend",
    "tb6b_M")
const TB6A_REQUIRE_IMAGE_CHARGE_MUTANT = Mutant(
    "TB6 M6a-require-image-charge drop_prefix_copy_charge",
    "src/descriptions/machines.jl",
    "        _charge!(ctx, 2 * length(support))\n        prefix[support] = u[support]",
    "        prefix[support] = u[support]",
    "tb6a_require_image")

# D8/D9: the sizing probe and the attempted count.
const TB6_PROBE_FROM_INPUT_MUTANT = Mutant(
    "TB6 M6-probe-from-input sizing_from_the_query_vector_not_a_Dimension_probe",
    "src/descriptions/machines.jl",
    "    s = _dimension(m, q.n, ctx)\n    ctx.depth = 1\n    answer = if q isa MarginalQuery",
    "    s = length(q isa MarginalQuery ? q.z : q.u)\n    ctx.depth = 1\n    answer = if q isa MarginalQuery",
    "tb6b_probe")
const TB6_FUEL_ATTEMPTED_CLAMPED_MUTANT = Mutant(
    "TB6 M6-fuel-attempted-clamped exception_reports_budget_plus_one",
    "src/descriptions/machines.jl",
    "    ctx.budget > 0 && total > ctx.budget && throw(FuelExhausted(total, ctx.budget))\n    ctx.steps = total",
    "    ctx.budget > 0 && total > ctx.budget && throw(FuelExhausted(ctx.budget + 1, ctx.budget))\n    ctx.steps = total",
    "tb6b_probe")

# D12: nested typed deciders metered at depth + 1 on one budget.
const TB6_NESTED_DEPTH_MUTANT = Mutant(
    "TB6 M6-nested-depth nested_steps_charged_at_the_parent_depth",
    "src/introspect/intro_decider.jl",
    "    c.parent.depth = max(saved, 1) + 1          # one machine depth below the enclosing decider's own steps",
    "    c.parent.depth = saved",
    "tb6b_nested")

# D11: one fuel currency -- a description primitive charges its metered steps, not a flat unit.
const TB7_CURRENCY_FLAT_CHARGE_MUTANT = Mutant(
    "TB7 M7-currency-flat-charge description_primitive_charges_one_unit",
    "src/ir/programs.jl",
    "            result, steps = outcome\n            _charge!(m, steps) || return false",
    "            result, steps = outcome\n            _charge!(m, 1) || return false",
    "tb6b_currency")

# D14: REPEAT_CONTRACT's index and the normal-form display (verdicts/tb5-r1.md O11).
const TB7_REPEAT_INDEX_MUTANT = Mutant(
    "TB7 M7-repeat-index completeness_bound_at_n_2",
    "src/compress.jl",
    "_repeat_index(p) = get(p, :n, 2)",
    "_repeat_index(p) = 2",
    "tb5_cited")
const TB7_NORMAL_FORM_DISPLAY_MUTANT = Mutant(
    "TB7 M7-normal-form-display totality_claimed",
    "src/compress.jl",
    "-- the structural check of gt-05:625-635 (field size 2, untyped); totality, value and PCC content are not decided here",
    "-- decider a total five-input predicate, the structural check of gt-05:625-635 (field size 2, untyped)",
    "tb5_cited")

const TB6_REPAIR_R1_MUTANTS = (TB6_CONJUNCT_MUTANTS..., TB6A_GATE_BODY_INFLATED_MUTANT, TB6B_GATE_BODY_INFLATED_MUTANT,
                               TB5_GATE_BODY_INFLATED_MUTANT, TB6_FORCED_OUTCOME_FREE_MUTANT, TB6_CHARGE_BRANCH_MUTANT,
                               TB6_LITERAL_SUFFIX_REGISTER_MUTANT, TB6A_REQUIRE_IMAGE_CHARGE_MUTANT, TB6_PROBE_FROM_INPUT_MUTANT,
                               TB6_FUEL_ATTEMPTED_CLAMPED_MUTANT, TB6_NESTED_DEPTH_MUTANT, TB7_CURRENCY_FLAT_CHARGE_MUTANT,
                               TB7_REPEAT_INDEX_MUTANT, TB7_NORMAL_FORM_DISPLAY_MUTANT)

const TB6_MUTANTS = (TB6_PAULI_EDGE_MUTANT, TB6A_COUNT_MUTANT, TB6A_GUARD_MUTANT, TB6_PAULI_GAMMA_MUTANT,
                     TB6_SAMPLER_NONZERO_MUTANT, TB6_N_MUTANT, TB6_FACTOR_PREFIX_MUTANT, TB6_PERP_MUTANT,
                     TB6_GAME_MUTANT, TB6_BOUNDARY_MUTANT, TB6_NONCOMMUTING_MUTANT, TB6_FACTOR_PARTITION_MUTANT,
                     TB6_DETYPE_VIEW_ORIENTATION_MUTANT, TB6_INTRO_FUEL_MUTANT, TB6_INTRO_FUEL_AFTER_MUTANT,
                     TB6_REPAIR_R1_MUTANTS...)
