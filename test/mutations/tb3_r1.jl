# verdicts/tb3-r1.md (brief 63): the critic's four mutants (C-N1, C-N2a,
# C-N2b, C-N3), the N2 binding mutants, and one mutant per new TB4-
# prerequisite check.

# C-N2a: the trace row's control field is constantised; the pinned row
# contents of test (c) fail.
const TB3_CN2A_MUTANT = Mutant(
    "TB3 C-N2a trace_control_constant",
    "src/frontend/bounded_trace.jl",
    "push!(fields, :control => (c isa Ret ? (:value, _value_key(c.value)) : _term_key(c, points)))",
    "push!(fields, :control => (:constant,))",
    "tb3_trace",
    "row1_control=(:constant,)")

# C-N2b: a row carries only the outcome flag.
const TB3_CN2B_MUTANT = Mutant(
    "TB3 C-N2b trace_rows_outcome_only",
    "src/frontend/bounded_trace.jl",
    "    fields = Pair{Symbol,Any}[]\n    c = m.control\n",
    "    fields = Pair{Symbol,Any}[]\n    push!(fields, :outcome => _outcome(m))\n    return fields\n    c = m.control\n",
    "tb3_trace",
    "row2_keys=[:outcome]")

# C-N1: the u_4 = u_5 equality gadget pair is dropped.
const TB3_CN1_MUTANT = Mutant(
    "TB3 C-N1 drop_u4_u5_equality_gadget",
    "src/frontend/decouple5.jl",
    "            push!(templates, Clause5((nothing, nothing, nothing, (u, o), (u, !o))))\n",
    "",
    "tb3_decouple")

# C-N3: pad5 emits one padding gate too few.
const TB3_CN3_MUTANT = Mutant(
    "TB3 C-N3 pad5_one_gate_short",
    "src/frontend/decouple5.jl",
    "for _ in 1:(s - live.gate_count)",
    "for _ in 1:(s - live.gate_count - 1)",
    "tb3_decouple")

# N2: the front-end identity binding is detached; a borrowed padded
# certificate passes and the chimera reaches frontend_pcp.
const TB3_BIND_MUTANT = Mutant(
    "TB3 M-bind frontend_binding_detached",
    "src/ir/programs.jl",
    "x -> x === subject ? replay(subject) :",
    "x -> true ? replay(subject) :",
    "tb3_pcp",
    "MUTATION_EXPECTED_RULE certificate_binding borrowed_passed=true")

# N2: build_pcp's upstream slot stops checking that the upstream circuit
# generated the proof's Tseitin formula.
const TB3_UPSTREAM_MUTANT = Mutant(
    "TB3 M-upstream upstream_skips_tseitin_reproduction",
    "src/verifiers/pcp.jl",
    "    _same_tseitin(tseitin(circuit).term, tf) ||\n        throw(ArgumentError(\"PCP upstream evidence did not generate the proof's Tseitin formula\"))",
    "    true ||\n        throw(ArgumentError(\"PCP upstream evidence did not generate the proof's Tseitin formula\"))",
    "tb3_pcp")

# N6: the gate budget is never enforced.
const TB3_BUDGET_MUTANT = Mutant(
    "TB3 M-budget gate_budget_ignored",
    "src/frontend/cook_levin.jl",
    "length(gates) > gate_budget && return CompilationRefused(length(gates), gate_budget)",
    "false && return CompilationRefused(length(gates), gate_budget)",
    "tb3_decouple")

# N7: the padded width ignores 2^m >= 2T.
const TB3_WIDTH_MUTANT = Mutant(
    "TB3 M-width pad5_ignores_2T",
    "src/frontend/decouple5.jl",
    "max(maximum(d.index_widths), _code_width(2 * d.source.trace.T))",
    "maximum(d.index_widths)",
    "tb3_decouple")

# Gap 1 / N3: the Fix unfolding charges 1 instead of c_Y = 3.
const TB3_CY_MUTANT = Mutant(
    "TB3 M-cY fix_charges_one",
    "src/ir/programs.jl",
    "            _charge!(m, 3) || return false\n            m.control = _fix_unfold(c)",
    "            _charge!(m, 1) || return false\n            m.control = _fix_unfold(c)",
    "tb3_eval")

# Gap 2: halts_within never sees the halting state.
const TB3_HALTS_MUTANT = Mutant(
    "TB3 M-halts halts_within_never_halts",
    "src/ir/programs.jl",
    "        next >= state_count && return (true, step)",
    "        next > state_count && return (true, step)",
    "tb3_tb4prep")

# Gap 3: every sort admits every term.
const TB3_SORT_MUTANT = Mutant(
    "TB3 M-sort sorts_admit_everything",
    "src/ir/programs.jl",
    "    sort == :Program && return true\n    sort == :Decider",
    "    true && return true\n    sort == :Decider",
    "tb3_tb4prep")

# Gap 4: an overflowing FuelBound is a SortError again.
const TB3_FUELBOUND_MUTANT = Mutant(
    "TB3 M-fuelbound overflow_is_sort_error",
    "src/ir/programs.jl",
    "lambda * log2(n) > 62 && return typemax(Int)",
    "lambda * log2(n) > 62 && return nothing",
    "tb3_tb4prep")

# Gap 6: the Verifier carrier accepts any Quoted as its sampler.
const TB3_VERIFIER_MUTANT = Mutant(
    "TB3 M-verifier verifier_sampler_sort_unchecked",
    "src/ir/programs.jl",
    "        sort_of(sampler) == :Sampler ||",
    "        true ||",
    "tb3_tb4prep")

const TB3_R1_MUTANTS = (TB3_CN2A_MUTANT, TB3_CN2B_MUTANT, TB3_CN1_MUTANT, TB3_CN3_MUTANT,
                        TB3_BIND_MUTANT, TB3_UPSTREAM_MUTANT, TB3_BUDGET_MUTANT,
                        TB3_WIDTH_MUTANT, TB3_CY_MUTANT, TB3_HALTS_MUTANT, TB3_SORT_MUTANT,
                        TB3_FUELBOUND_MUTANT, TB3_VERIFIER_MUTANT)
