abstract type BWire end

struct Input <: BWire
    block::Symbol
    offset::Int
    index::Int
end

struct Gate <: BWire
    id::Int
end

abstract type BGate end
struct NotGate <: BGate
    input::BWire
end
struct AndGate <: BGate
    left::BWire
    right::BWire
end
struct OrGate <: BGate
    left::BWire
    right::BWire
end

struct Circuit{N}
    input_layout::VarLayout{N}
    gates::Tuple
    output::Gate
    gate_count::Int
    fanout_counts::Tuple
    function Circuit(layout::VarLayout{N}, gates::Tuple, output::Gate) where {N}
        for (id, gate) in enumerate(gates)
            for wire in _gate_inputs(gate)
                if wire isa Input
                    1 <= wire.index <= N || throw(ArgumentError("input wire out of range"))
                else
                    1 <= wire.id < id || throw(ArgumentError("gate reference is not topological"))
                end
            end
        end
        1 <= output.id <= length(gates) || throw(ArgumentError("output wire out of range"))
        counts = _compute_fanout(N, gates)
        new{N}(layout, gates, output, length(gates), counts)
    end
end

_gate_inputs(gate::NotGate) = (gate.input,)
_gate_inputs(gate::AndGate) = (gate.left, gate.right)
_gate_inputs(gate::OrGate) = (gate.left, gate.right)

function _compute_fanout(input_count::Int, gates::Tuple)
    counts = zeros(Int, input_count + length(gates))
    for gate in gates, wire in _gate_inputs(gate)
        coordinate = wire isa Input ? wire.index : input_count + wire.id
        counts[coordinate] += 1
    end
    Tuple(counts)
end

fanout(circuit::Circuit) = circuit.fanout_counts

function _wire_value(wire::Input, inputs, values)
    inputs[wire.index]
end
function _wire_value(wire::Gate, inputs, values)
    values[wire.id]
end

function gate_trace(circuit::Circuit, inputs::AbstractVector{Bool})
    length(inputs) == length(circuit.input_layout.names) ||
        throw(ArgumentError("circuit input has wrong length"))
    values = Bool[]
    for gate in circuit.gates
        if gate isa NotGate
            push!(values, !_wire_value(gate.input, inputs, values))
        elseif gate isa AndGate
            push!(values, _wire_value(gate.left, inputs, values) &&
                          _wire_value(gate.right, inputs, values))
        else
            push!(values, _wire_value(gate.left, inputs, values) ||
                          _wire_value(gate.right, inputs, values))
        end
    end
    values
end

evaluate_circuit(circuit::Circuit, inputs::AbstractVector{Bool}) =
    gate_trace(circuit, inputs)[circuit.output.id]

function tb0_circuit()
    names = (:X1, :X2, :X3, :X4, :X5, :O1, :O2, :O3, :O4, :O5)
    blocks = (VarBlock(:X1, 1:1), VarBlock(:X2, 2:2), VarBlock(:X3, 3:3),
              VarBlock(:X4, 4:4), VarBlock(:X5, 5:5), VarBlock(:O, 6:10))
    layout = VarLayout(names, blocks)
    x1 = Input(:X1, 1, 1)
    x5 = Input(:X5, 1, 5)
    o1 = Input(:O, 1, 6)
    # DESIGN.md section 5: six-gate TB0 fixture.
    gates = (NotGate(x1), NotGate(Gate(1)), NotGate(Gate(1)),
             AndGate(Gate(2), Gate(3)), AndGate(Gate(4), o1),
             AndGate(Gate(5), x5))
    Circuit(layout, gates, Gate(6))
end

function c8_two_gate_circuit()
    layout = VarLayout((:x1, :x2, :x3), (VarBlock(:X, 1:3),))
    gates = (AndGate(Input(:X, 1, 1), Input(:X, 2, 2)),
             AndGate(Gate(1), Input(:X, 3, 3)))
    Circuit(layout, gates, Gate(2))
end

function phi_C(circuit::Circuit, witness::NTuple{5,<:AbstractVector{Bool}})
    all(length(block) == 2 for block in witness) ||
        throw(ArgumentError("TB0 witness blocks must have length two"))
    for encoded_clause in 0:2^10-1
        input = [isodd(encoded_clause >> (i - 1)) for i in 1:10]
        evaluate_circuit(circuit, input) || continue
        satisfied = any(witness[i][Int(input[i]) + 1] == input[5 + i] for i in 1:5)
        satisfied || return false
    end
    true
end

abstract type Formula end
struct Lit <: Formula
    variable::Int
    sign::Bool
end
Lit(variable::Int) = Lit(variable, true)
struct FNot <: Formula
    child::Formula
end
struct FAnd <: Formula
    left::Formula
    right::Formula
end
struct FOr <: Formula
    left::Formula
    right::Formula
end

struct TseitinFormula{N}
    formula::Formula
    input_blocks::Tuple
    layout::VarLayout{N}
    gadgets::Tuple
    output_variable::Int
    occurrence_vector::NTuple{N,Int}
end

_formula_wire(wire::Input, input_count::Int) = Lit(wire.index)
_formula_wire(wire::Gate, input_count::Int) = Lit(input_count + wire.id)

function _gate_formula(gate::NotGate, input_count::Int)
    FNot(_formula_wire(gate.input, input_count))
end
function _gate_formula(gate::AndGate, input_count::Int)
    FAnd(_formula_wire(gate.left, input_count),
         _formula_wire(gate.right, input_count))
end
function _gate_formula(gate::OrGate, input_count::Int)
    FOr(_formula_wire(gate.left, input_count),
        _formula_wire(gate.right, input_count))
end

function _equality_gadget(gate::BGate, target::Int, input_count::Int)
    computed = _gate_formula(gate, input_count)
    wire = Lit(input_count + target)
    # nw19-tseitin-arith.tex, Tseitin steps (i),(ii).
    FOr(FAnd(computed, wire), FAnd(FNot(computed), FNot(wire)))
end

function _conjoin(parts::Vector{Formula})
    isempty(parts) && throw(ArgumentError("empty formula conjunction"))
    result = last(parts)
    for i in length(parts)-1:-1:1
        result = FAnd(parts[i], result)
    end
    result
end

function occurrences(formula::Formula, variable_count::Int)
    counts = zeros(Int, variable_count)
    function visit(node::Formula)
        if node isa Lit
            counts[node.variable] += 1
        elseif node isa FNot
            visit(node.child)
        else
            visit(node.left)
            visit(node.right)
        end
    end
    visit(formula)
    Tuple(counts)
end

function tseitin_occurrence_account(circuit::Circuit)
    input_count = length(circuit.input_layout.names)
    output = zeros(Int, input_count + circuit.gate_count)
    circuit_fanout = fanout(circuit)
    for i in 1:input_count
        output[i] = 2 * circuit_fanout[i]
    end
    for i in 1:circuit.gate_count
        output[input_count + i] = 2 + 2 * circuit_fanout[input_count + i]
    end
    output[input_count + circuit.output.id] += 1
    Tuple(output)
end

function tseitin(circuit::Circuit; include_output=true)
    input_count = length(circuit.input_layout.names)
    parts = Formula[_equality_gadget(gate, id, input_count)
                    for (id, gate) in enumerate(circuit.gates)]
    # Finding F2: NW19 omits the accepting-output constraint.
    include_output && push!(parts, Lit(input_count + circuit.output.id))
    formula = _conjoin(parts)
    names = (circuit.input_layout.names...,
             ntuple(i -> Symbol("W", i), circuit.gate_count)...)
    blocks = (circuit.input_layout.blocks...,
              VarBlock(:W, input_count + 1:input_count + circuit.gate_count))
    layout = VarLayout(names, blocks)
    count = occurrences(formula, length(names))
    term = TseitinFormula(formula, circuit.input_layout.blocks, layout,
                          Tuple(parts), input_count + circuit.output.id, count)
    certificate = CertNode(CHECKED, :Tseitin;
        facts=(display="variables = $(length(names)); output literal = $(include_output)",),
        replay=tf -> CheckResult(tf.occurrence_vector ==
                                 occurrences(tf.formula, length(tf.layout.names)),
                                 :formula_occurrences;
                                 expected=tf.occurrence_vector,
                                 actual=occurrences(tf.formula, length(tf.layout.names))))
    Checked(term, certificate)
end

function evaluate_formula(formula::Formula, assignment::AbstractVector{Bool})
    formula isa Lit && return formula.sign ? assignment[formula.variable] :
                                           !assignment[formula.variable]
    formula isa FNot && return !evaluate_formula(formula.child, assignment)
    formula isa FAnd && return evaluate_formula(formula.left, assignment) &&
                                  evaluate_formula(formula.right, assignment)
    evaluate_formula(formula.left, assignment) || evaluate_formula(formula.right, assignment)
end

# gt-10-answer-reduction.tex:160-190 and nw19 arithmetization steps (i),(ii).
function evaluate_arith_formula(formula::Formula, assignment::AbstractVector{F}) where {F}
    if formula isa Lit
        value = assignment[formula.variable]
        return formula.sign ? value : one(F) - value
    elseif formula isa FNot
        return one(F) - evaluate_arith_formula(formula.child, assignment)
    elseif formula isa FAnd
        return evaluate_arith_formula(formula.left, assignment) *
               evaluate_arith_formula(formula.right, assignment)
    end
    left = evaluate_arith_formula(formula.left, assignment)
    right = evaluate_arith_formula(formula.right, assignment)
    left + right - left * right
end

struct FormulaEvalPlan <: AbstractEvalPlan
    formula::Formula
end
_evalplan(plan::FormulaEvalPlan, point) = evaluate_arith_formula(plan.formula, point)

function _formula_poly(formula::Formula, ::Type{F}, layout::VarLayout) where {F<:GF2k}
    if formula isa Lit
        variable = polyvar(F, layout, formula.variable)
        return formula.sign ? variable : constant_poly(F, layout, 1) - variable
    elseif formula isa FNot
        return constant_poly(F, layout, 1) - _formula_poly(formula.child, F, layout)
    elseif formula isa FAnd
        return _formula_poly(formula.left, F, layout) *
               _formula_poly(formula.right, F, layout)
    end
    left = _formula_poly(formula.left, F, layout)
    right = _formula_poly(formula.right, F, layout)
    left + right - left * right
end

function arith_q(tf::TseitinFormula{N}, ::Type{F};
                 budget=MonomialBudget(typemax(Int))) where {F<:GF2k,N}
    result = constant_poly(F, tf.layout, 1)
    for formula_part in tf.gadgets
        part = _formula_poly(formula_part, F, tf.layout)
        # Each normalized equality gadget has 6 (NOT) or 7 (AND) terms.
        part = _with_metadata(part, part.structural, monomial_count(part))
        multiplied = mul_poly(result, part; budget=budget)
        multiplied isa ExpansionRefused && return multiplied
        result = multiplied
    end
    dependencies = Tuple(i for i in 1:N if tf.occurrence_vector[i] > 0)
    derivation = DegreeDerivation(:ArithFormula, tf.occurrence_vector,
                                  dependencies, ())
    result = _with_metadata(result, derivation, result.expected,
                            FormulaEvalPlan(tf.formula))
    certificate = CertNode(CHECKED, :ArithTseitin;
        facts=(display="degrees = occurrences; inddeg = $(maximum(tf.occurrence_vector))",),
        replay=p -> CheckResult(degree_accounts_valid(p), :occurrence_degree_bound;
                                expected=p.structural.bound, actual=p.actual.degrees))
    Checked(result, certificate)
end
