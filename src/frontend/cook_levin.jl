# DESIGN.md sections 1.2 and 2: cook_levin(t::BoundedTrace) :: Checked{Succinct3SAT,
# CookLevinCert}. The honest small Cook-Levin of brief 23: the tableau rows
# are the trace's configuration fields, each field coded over the alphabet
# it takes across ALL answer inputs (a, b), the transition clauses are the
# per-field successor function on that finite alphabet (support found by
# projection, so clauses are local), initialisation is row 0, and the
# acceptance clause reads the final row's explicit accept bit. Short
# clauses are clause FAMILIES with don't-care slots (equivalent to the short
# clause by the complementary-pair argument), which is what keeps the
# succinct circuit small. Faithfulness on a fixture is CHECKED exhaustively;
# the general succinct construction (prop:standard-succinct-sat, analytic
# thm:l-succinct-sat) stays a CITED leaf: this alphabet is enumerated from
# the inputs, not decoded from an O(log T + log sigma)-bit window.

struct Clause3
    slots::NTuple{3,Union{Nothing,Tuple{Int,Bool}}}
end

struct Tableau
    rows::Int
    coded_fields::Vector{Vector{Symbol}}
    raw_clauses::Int
    aux::Int
    eliminated::Int
    answer_widths::Tuple{Int,Int}
end

struct Succinct3SAT
    variable_count::Int
    index_width::Int
    clauses::Vector{Clause3}
    answer_variables::NamedTuple{(:a, :b),Tuple{Vector{Int},Vector{Int}}}
    accept_variable::Int
    circuit::Circuit
    trace::BoundedTrace
    tableau::Tableau
end

"Refusal of a relation-circuit compilation over the gate budget (DESIGN 7 risk 9)."
struct CompilationRefused
    gates::Int
    budget::Int
end

# ---------------------------------------------------------------------------
# A tiny exact DPLL over signed-integer clauses.

function _assign(clauses::Vector{Vector{Int}}, literal::Int)
    Vector{Int}[filter(l -> l != -literal, clause) for clause in clauses if !(literal in clause)]
end

function dpll(clauses::Vector{Vector{Int}})
    while true
        isempty(clauses) && return true
        any(isempty, clauses) && return false
        unit = findfirst(clause -> length(clause) == 1, clauses)
        unit === nothing && break
        clauses = _assign(clauses, clauses[unit][1])
    end
    literal = clauses[1][1]
    dpll(_assign(clauses, literal)) || dpll(_assign(clauses, -literal))
end

# ---------------------------------------------------------------------------
# Answer inputs and their traces.

_bit_vectors(width::Int) = [Bool[isodd(code >> (k - 1)) for k in 1:width] for code in 0:(1 << width) - 1]

function _answer_inputs(input::Tuple)
    wa, wb = length(input[4]), length(input[5])
    [(input[1], input[2], input[3], a, b) for a in _bit_vectors(wa) for b in _bit_vectors(wb)]
end

_code_width(alphabet_size::Int) = alphabet_size <= 1 ? 0 : ceil(Int, log2(alphabet_size))

# Field alphabets per row, over every answer input. The final row's outcome
# is always the explicit one-bit accept flag (accept = 1).
struct _RowCoding
    names::Vector{Symbol}
    alphabets::Dict{Symbol,Vector{Any}}
    widths::Dict{Symbol,Int}
end

function _row_coding(rows_by_input::Vector{Vector{TraceRow}}, i::Int, final::Bool)
    names = Symbol[]
    seen = Set{Symbol}()
    for rows in rows_by_input, (name, _) in rows[i].fields
        name in seen || (push!(names, name); push!(seen, name))
    end
    alphabets = Dict{Symbol,Vector{Any}}()
    widths = Dict{Symbol,Int}()
    for name in names
        values = Any[]
        for rows in rows_by_input
            position = findfirst(pair -> first(pair) == name, rows[i].fields)
            push!(values, position === nothing ? :absent : last(rows[i].fields[position]))
        end
        if final && name == :outcome
            alphabets[name] = Any[:reject, :accept]
            widths[name] = 1
        else
            alphabet = unique(values)
            sort!(alphabet; by=repr)
            alphabets[name] = alphabet
            widths[name] = _code_width(length(alphabet))
        end
    end
    _RowCoding(names, alphabets, widths)
end

function _field_value(row::TraceRow, name::Symbol)
    position = findfirst(pair -> first(pair) == name, row.fields)
    position === nothing ? :absent : last(row.fields[position])
end

function _code(coding::_RowCoding, name::Symbol, value)
    alphabet = coding.alphabets[name]
    if name == :outcome && alphabet == Any[:reject, :accept]
        return value == :accept ? 1 : 0
    end
    position = findfirst(x -> x == value, alphabet)
    position === nothing && throw(ArgumentError("value outside the field alphabet"))
    position - 1
end

# ---------------------------------------------------------------------------
# Tableau -> clauses.

function _chain_split!(clauses::Vector{Vector{Int}}, clause::Vector{Int}, next_variable::Base.RefValue{Int})
    if length(clause) <= 3
        push!(clauses, clause)
        return 0
    end
    aux = 0
    rest = clause
    previous = 0
    while length(rest) + (previous == 0 ? 0 : 1) > 3
        next_variable[] += 1
        z = next_variable[]
        aux += 1
        head = previous == 0 ? rest[1:2] : [previous, rest[1]]
        push!(clauses, vcat(head, z))
        rest = previous == 0 ? rest[3:end] : rest[2:end]
        previous = -z
    end
    push!(clauses, vcat(previous == 0 ? Int[] : [previous], rest))
    aux
end

struct _TableauResult
    clauses::Vector{Vector{Int}}
    answer::NamedTuple{(:a, :b),Tuple{Vector{Int},Vector{Int}}}
    accept::Int
    tableau::Tableau
    all_inputs::Vector{Tuple}
end

function _tableau_formula(q::Quoted, input::Tuple, T::Int)
    body = _decider_body(q)
    inputs = _answer_inputs(input)
    rows_by_input = [_trace_rows(body, u, T).rows for u in inputs]
    row_count = T + 1
    codings = [_row_coding(rows_by_input, i, i == row_count) for i in 1:row_count]
    wa, wb = length(input[4]), length(input[5])

    # Variables: answer bits, then each row's coded field bits.
    counter = Ref(0)
    fresh!() = (counter[] += 1)
    a_vars = [fresh!() for _ in 1:wa]
    b_vars = [fresh!() for _ in 1:wb]
    field_vars = Dict{Tuple{Int,Symbol},Vector{Int}}()
    for i in 1:row_count, name in codings[i].names
        width = codings[i].widths[name]
        width > 0 && (field_vars[(i, name)] = [fresh!() for _ in 1:width])
    end
    accept = field_vars[(row_count, :outcome)][1]

    # Candidate support of a row-i field: the coded fields of row i-1 and
    # the answer bits. Each candidate has a value per input and its code
    # bits/literal variables.
    candidate_value(kind, r) = kind[1] == :a ? Int(inputs[r][4][kind[2]]) :
                               kind[1] == :b ? Int(inputs[r][5][kind[2]]) :
                               _code(codings[kind[2]], kind[3], _field_value(rows_by_input[r][kind[2]], kind[3]))
    candidate_vars(kind) = kind[1] == :a ? [a_vars[kind[2]]] :
                           kind[1] == :b ? [b_vars[kind[2]]] : field_vars[(kind[2], kind[3])]

    raw = Vector{Int}[]
    for i in 2:row_count, name in codings[i].names
        width = codings[i].widths[name]
        width > 0 || continue
        outputs = [_code(codings[i], name, _field_value(rows_by_input[r][i], name)) for r in eachindex(inputs)]
        candidates = Any[(:field, i - 1, f) for f in codings[i - 1].names if codings[i - 1].widths[f] > 0]
        append!(candidates, [(:a, j) for j in 1:wa])
        append!(candidates, [(:b, j) for j in 1:wb])
        function consistent(support)
            table = Dict{Tuple,Int}()
            for r in eachindex(inputs)
                key = Tuple(candidate_value(kind, r) for kind in support)
                if haskey(table, key)
                    table[key] == outputs[r] || return false
                else
                    table[key] = outputs[r]
                end
            end
            true
        end
        consistent(candidates) ||
            throw(ArgumentError("row $i field $name is not a function of the previous row and the answers"))
        support = copy(candidates)
        for kind in candidates
            trial = filter(k -> k != kind, support)
            consistent(trial) && (support = trial)
        end
        seen = Set{Tuple}()
        for r in eachindex(inputs)
            key = Tuple(candidate_value(kind, r) for kind in support)
            key in seen && continue
            push!(seen, key)
            base = Int[]
            for (kind, value) in zip(support, key)
                for (bit, variable) in enumerate(candidate_vars(kind))
                    push!(base, isodd(value >> (bit - 1)) ? -variable : variable)
                end
            end
            for (bit, variable) in enumerate(field_vars[(i, name)])
                push!(raw, vcat(base, isodd(outputs[r] >> (bit - 1)) ? variable : -variable))
            end
        end
    end
    push!(raw, [accept])
    raw_count = length(raw)

    clauses = Vector{Int}[]
    aux = 0
    for clause in raw
        aux += _chain_split!(clauses, clause, counter)
    end

    # Unit propagation of forced INTERNAL variables; the answer bits and
    # the accept bit are interface variables and are retained.
    retained = Set(vcat(a_vars, b_vars, accept))
    eliminated = 0
    contradiction = false
    while true
        unit = findfirst(c -> length(c) == 1 && !(abs(c[1]) in retained), clauses)
        unit === nothing && break
        clauses = _assign(clauses, clauses[unit][1])
        eliminated += 1
        any(isempty, clauses) && (contradiction = true; break)
    end
    if contradiction
        clauses = Vector{Int}[[accept], [-accept]]
    end
    clauses = unique(sort!(unique!(c)) for c in clauses)
    sort!(clauses)

    tableau = Tableau(row_count, [[f for f in c.names if c.widths[f] > 0] for c in codings],
                      raw_count, aux, eliminated, (wa, wb))
    _TableauResult(clauses, (a=a_vars, b=b_vars), accept, tableau, inputs)
end

# Renumber the retained variables 1..M_r (index 0 is padding): the answer
# bits that occur, then the accept bit, then the rest in old order.
function _renumber(result::_TableauResult)
    occurring = Set{Int}()
    for clause in result.clauses, literal in clause
        push!(occurring, abs(literal))
    end
    order = Int[]
    for v in vcat(result.answer.a, result.answer.b)
        v in occurring && push!(order, v)
    end
    push!(order, result.accept)
    for v in sort!(collect(occurring))
        v in order || push!(order, v)
    end
    mapping = Dict(v => i for (i, v) in enumerate(order))
    clauses = [[sign(l) * mapping[abs(l)] for l in clause] for clause in result.clauses]
    answer = (a=[get(mapping, v, 0) for v in result.answer.a],
              b=[get(mapping, v, 0) for v in result.answer.b])
    (; clauses, answer, accept=mapping[result.accept], retained=length(order))
end

_template3(clause::Vector{Int}) =
    Clause3(ntuple(k -> k <= length(clause) ? (abs(clause[k]), clause[k] > 0) : nothing, 3))

# ---------------------------------------------------------------------------
# Relation circuits (def:succinct-formulas / def:decoupled-5sat): a circuit
# on index blocks plus sign bits that is 1 exactly on the present clauses.
# Templates are OR-ed; each template is an AND of index-bit and sign
# literal checks, with the NOT of each input shared.

function _relation_layout(widths::Tuple, sign_count::Int, prefix::Symbol)
    names = Symbol[]
    blocks = VarBlock[]
    position = 0
    for (k, width) in enumerate(widths)
        push!(blocks, VarBlock(Symbol(prefix, k), position + 1:position + width))
        for t in 1:width
            push!(names, Symbol(prefix, k, :_, t))
        end
        position += width
    end
    push!(blocks, VarBlock(:O, position + 1:position + sign_count))
    for t in 1:sign_count
        push!(names, Symbol(:O, t))
    end
    VarLayout(Tuple(names), Tuple(blocks))
end

function compile_relation(templates, widths::Tuple, sign_count::Int;
                          prefix::Symbol=:X, gate_budget::Int=4096)
    layout = _relation_layout(widths, sign_count, prefix)
    offsets = cumsum((0, widths...))
    sign_base = offsets[end]
    input_wire(index) = begin
        block = findfirst(b -> index in b.coordinates, layout.blocks)
        b = layout.blocks[block]
        Input(b.name, index - first(b.coordinates) + 1, index)
    end
    gates = BGate[]
    negated = Dict{Int,Gate}()
    negate(index) = get!(negated, index) do
        push!(gates, NotGate(input_wire(index)))
        Gate(length(gates))
    end
    outputs = BWire[]
    for template in templates
        wires = BWire[]
        for (k, slot) in enumerate(template.slots)
            slot === nothing && continue
            index, sign = slot
            for t in 1:widths[k]
                coordinate = offsets[k] + t
                push!(wires, isodd(index >> (t - 1)) ? input_wire(coordinate) : negate(coordinate))
            end
            push!(wires, sign ? input_wire(sign_base + k) : negate(sign_base + k))
        end
        isempty(wires) && continue
        current = wires[1]
        for wire in wires[2:end]
            push!(gates, AndGate(current, wire))
            current = Gate(length(gates))
        end
        push!(outputs, current)
    end
    if isempty(outputs)
        push!(gates, AndGate(input_wire(sign_base + 1), negate(sign_base + 1)))
        output = Gate(length(gates))
    else
        current = outputs[1]
        for wire in outputs[2:end]
            push!(gates, OrGate(current, wire))
            current = Gate(length(gates))
        end
        if current isa Input
            push!(gates, AndGate(current, current))
            current = Gate(length(gates))
        end
        output = current
    end
    length(gates) > gate_budget && return CompilationRefused(length(gates), gate_budget)
    Circuit(layout, Tuple(gates), output)
end

"Layout-ordered Boolean input of a relation circuit: index bits (LSB first) per block, then signs."
function relation_input(widths::Tuple, sign_count::Int, indices::Tuple, signs::Tuple)
    input = Bool[]
    for (k, width) in enumerate(widths)
        for t in 1:width
            push!(input, isodd(indices[k] >> (t - 1)))
        end
    end
    for k in 1:sign_count
        push!(input, signs[k])
    end
    input
end

"Every (indices, signs) tuple of a relation on the given block widths."
function relation_tuples(widths::Tuple, sign_count::Int)
    tuples = Tuple{Tuple,Tuple}[]
    total = sum(widths) + sign_count
    for code in 0:(1 << total) - 1
        bits = [isodd(code >> (k - 1)) for k in 1:total]
        position = 0
        indices = ntuple(length(widths)) do block
            value = 0
            for k in 1:widths[block]
                value |= Int(bits[position + k]) << (k - 1)
            end
            position += widths[block]
            value
        end
        signs = ntuple(k -> bits[position + k], sign_count)
        push!(tuples, (indices, signs))
    end
    tuples
end

function _template_matches(slots, indices::Tuple, signs::Tuple)
    for (k, slot) in enumerate(slots)
        slot === nothing && continue
        (indices[k] == slot[1] && signs[k] == slot[2]) || return false
    end
    true
end

# Circuit against the template relation: exhaustive when the input has at
# most 16 bits; otherwise every template-present tuple plus 4096 seeded
# random tuples (the seed is printed in the display).
const _RELATION_SAMPLE = 4096
const _RELATION_SEED = 0x7b3

function _check_relation(circuit::Circuit, present::Function, widths::Tuple, sign_count::Int)
    total = sum(widths) + sign_count
    if total <= 16
        for (indices, signs) in relation_tuples(widths, sign_count)
            evaluate_circuit(circuit, relation_input(widths, sign_count, indices, signs)) ==
                present(indices, signs) || return (false, :exhaustive, 1 << total)
        end
        return (true, :exhaustive, 1 << total)
    end
    rng = MersenneTwister(_RELATION_SEED)
    checked = 0
    for _ in 1:_RELATION_SAMPLE
        indices = ntuple(k -> rand(rng, 0:(1 << widths[k]) - 1), length(widths))
        signs = ntuple(_ -> rand(rng, Bool), sign_count)
        evaluate_circuit(circuit, relation_input(widths, sign_count, indices, signs)) ==
            present(indices, signs) || return (false, :sampled, checked)
        checked += 1
    end
    (true, :sampled, checked)
end

# ---------------------------------------------------------------------------
# Succinct3SAT surface.

_widths3(f::Succinct3SAT) = (f.index_width, f.index_width, f.index_width)

"def:succinct-formulas: C(i1,i2,i3,o1,o2,o3) = 1 iff the signed clause is present."
clause_present(f::Succinct3SAT, indices::Tuple, signs::Tuple) =
    any(template -> _template_matches(template.slots, indices, signs), f.clauses)
relation_input(f::Succinct3SAT, indices::Tuple, signs::Tuple) =
    relation_input(_widths3(f), 3, indices, signs)

"Every present clause (family semantics), as (indices, signs)."
present_clauses(f::Succinct3SAT) =
    [(indices, signs) for (indices, signs) in relation_tuples(_widths3(f), 3)
     if clause_present(f, indices, signs)]

"The assignment w (0-based variable order) satisfies every present clause."
function satisfies(f::Succinct3SAT, w::AbstractVector{Bool})
    length(w) == f.variable_count || throw(ArgumentError("assignment has wrong length"))
    for (indices, signs) in present_clauses(f)
        any(w[indices[k] + 1] == signs[k] for k in 1:3) || return false
    end
    true
end

function _formula_clauses(f::Succinct3SAT)
    Vector{Int}[Int[slot[2] ? slot[1] : -slot[1] for slot in template.slots if slot !== nothing]
                for template in f.clauses]
end

function _answer_units(answer, input::Tuple)
    units = Vector{Int}[]
    for (j, v) in enumerate(answer.a)
        v > 0 && push!(units, [input[4][j] ? v : -v])
    end
    for (j, v) in enumerate(answer.b)
        v > 0 && push!(units, [input[5][j] ? v : -v])
    end
    units
end

"Exact satisfiability (DPLL); with `input`, the answer variables are fixed to its a, b bits."
satisfiable(f::Succinct3SAT) = dpll(_formula_clauses(f))
satisfiable(f::Succinct3SAT, input::Tuple) =
    dpll(vcat(_formula_clauses(f), _answer_units(f.answer_variables, input)))

function _build_3sat(trace::BoundedTrace; gate_budget::Int=4096)
    result = _tableau_formula(trace.program, trace.input, trace.T)
    numbered = _renumber(result)
    variable_count = nextpow(2, numbered.retained + 1)
    m = round(Int, log2(variable_count))
    templates = [_template3(clause) for clause in numbered.clauses]
    circuit = compile_relation(templates, (m, m, m), 3; prefix=:I, gate_budget)
    circuit isa CompilationRefused && return circuit
    Succinct3SAT(variable_count, m, templates, numbered.answer, numbered.accept,
                 circuit, trace, result.tableau)
end

function _replay_cook_levin(f::Succinct3SAT)
    rebuilt = try
        _build_3sat(f.trace)
    catch error
        error isa ArgumentError || rethrow()
        return CheckResult(false, :formula_reconstruction; expected=:formula,
                           actual=sprint(showerror, error))
    end
    rebuilt isa CompilationRefused &&
        return CheckResult(false, :formula_reconstruction; expected=:formula, actual=rebuilt)
    same = rebuilt.clauses == f.clauses && rebuilt.variable_count == f.variable_count &&
           rebuilt.index_width == f.index_width &&
           rebuilt.answer_variables == f.answer_variables &&
           rebuilt.accept_variable == f.accept_variable
    same || return CheckResult(false, :formula_reconstruction;
                               expected=(rebuilt.variable_count, length(rebuilt.clauses)),
                               actual=(f.variable_count, length(f.clauses)))
    ok, mode, count = _check_relation(f.circuit, (i, s) -> clause_present(f, i, s), _widths3(f), 3)
    ok || return CheckResult(false, :relation_circuit; expected=mode, actual=count)
    # Trace/formula equivalence: first the trace's own input, then every
    # answer input (the trace is replayed from the bytes for each).
    own = satisfiable(f, f.trace.input)
    own == f.trace.accepts ||
        return CheckResult(false, :trace_formula_equivalence; location=:trace_input,
                           expected=(accepts=f.trace.accepts,), actual=(satisfiable=own,))
    for input in _answer_inputs(f.trace.input)
        accepts = _trace_term(f.trace.program, input, f.trace.T).accepts
        satisfiable(f, input) == accepts ||
            return CheckResult(false, :trace_formula_equivalence; location=(input[4], input[5]),
                               expected=accepts, actual=!accepts)
    end
    CheckResult(true, :cook_levin_replay; expected=mode, actual=count)
end

"cook_levin(t::BoundedTrace) :: Checked{Succinct3SAT, CookLevinCert} (DESIGN 2)."
function cook_levin(trace::Checked{BoundedTrace}; gate_budget::Int=4096)
    f = _build_3sat(trace.term; gate_budget)
    f isa CompilationRefused && return f
    # The CITED leaf names every departure from the general construction
    # (verdicts/tb3-r1.md N4): this is a fixture-only surrogate.
    general = CertNode(CITED, :CookLevinGeneral;
        facts=(display="prop:standard-succinct-sat (gt-10:237-273) / analytic thm:l-succinct-sat, fixture-only surrogate: (1) transition constraints are a per-field function fit, one implication per support key OBSERVED across the $(length(_answer_inputs(trace.term.input))) enumerated answer inputs (greedily minimised; off-table keys unconstrained), not a window function omega; (2) no initialisation clauses: row 0 is fixed only because its field alphabets are singletons; (3) no fuel counter, head marker, endmarker, track structure or radius-one window (lem:transition-window has no executable counterpart); field alphabets enumerated from the inputs, not decoded from an O(log T + log sigma)-bit window",))
    _, mode, count = _check_relation(f.circuit, (i, s) -> clause_present(f, i, s), _widths3(f), 3)
    node = CertNode(CHECKED, :CookLevin;
        facts=(display="m = $(f.index_width); M = $(f.variable_count); clauses = $(length(f.clauses)); rows = $(f.tableau.rows); raw = $(f.tableau.raw_clauses); aux = $(f.tableau.aux); eliminated = $(f.tableau.eliminated); circuit gates = $(f.circuit.gate_count); relation check = $(mode) ($(count)); fnv1a64 = $(quote_hash(trace.term.program))",),
        children=(_relocate(trace.certificate, x -> x isa Succinct3SAT ? x.trace : nothing), general),
        replay=_bound_replay(f, :CookLevin, _replay_cook_levin))
    Checked(f, node)
end
