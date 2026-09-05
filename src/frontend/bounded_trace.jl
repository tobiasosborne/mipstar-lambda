# DESIGN.md sections 1.2 and 2: bounded_trace(D, input, T) :: Checked{BoundedTrace,
# TraceCert}. One row per charged CEK transition of the decider BODY under
# its installed argument frame (row 0 = <body, [n,x,y,a,b], [], T>); halting
# early pads to T + 1 rows with the halting self-loop (analytic part2b 11.1).
# eval(D, u; T + 2) is the same run with the closure and beta transitions
# that install the frame; those two units are the front end's, not the
# body's (recorded in the certificate display).

struct TraceRow
    index::Int
    control::String
    fields::Vector{Pair{Symbol,Any}}
    fuel::Int
    outcome::Symbol
end

struct BoundedTrace
    program::Quoted
    input::Tuple
    T::Int
    configurations::Vector{TraceRow}
    result::Any
    accepts::Bool
end

function _check_decider_input(input::Tuple)
    (length(input) == DECIDER_ARITY && input[1] isa Int &&
     all(v -> v isa Vector{Bool}, input[2:5])) ||
        throw(ArgumentError("a decider input is (n::Int, x, y, a, b :: Vector{Bool})"))
    input
end

function _decider_body(q::Quoted)
    p = decode_program(q)
    (p isa Lambda && p.arity == DECIDER_ARITY) ||
        throw(ArgumentError("a decider is a closed five-argument Lambda"))
    p
end

# Prefix-order identities of the body's subterms (program points).
function program_points(p::Program)
    points = IdDict{Any,Int}()
    _collect_points!(points, p)
    points
end
function _collect_points!(points::IdDict{Any,Int}, p::Program)
    haskey(points, p) || (points[p] = length(points) + 1)
    for child in _children(p)
        _collect_points!(points, child)
    end
    points
end

_value_key(v::Bool) = (:bool, v)
_value_key(v::Int) = (:nat, v)
_value_key(v::Vector{Bool}) = (:bits, Tuple(v))
_value_key(v::Code) = (:code, quote_hash(_quoted_bytes(v.program, v.sort)))
_value_key(v::Closure) = (:closure, quote_hash(term_bytes(v.body)), length(v.env))
_value_key(v) = (:other, string(v))

function _term_key(term::Program, points::IdDict{Any,Int})
    haskey(points, term) ? (:point, points[term]) : (:term, quote_hash(term_bytes(term)))
end

_outcome(m::Machine) = m.halted === nothing ? :running :
                       (m.halted isa Value && m.halted.value === true) ? :accept : :reject

# The Cook-Levin fields of one configuration: control, continuation frames
# (kind and evaluated values), environment frames created during the run,
# and the outcome flag. The installed input frame is the answer blocks'
# business and is not a field.
function _row_fields(m::Machine, points::IdDict{Any,Int}, input_frame)
    fields = Pair{Symbol,Any}[]
    c = m.control
    push!(fields, :control => (c isa Ret ? (:value, _value_key(c.value)) : _term_key(c, points)))
    for (i, frame) in enumerate(m.kont)
        if frame isa SeqFrame
            node_key = frame.node === nothing ? (:inner,) : _term_key(frame.node, points)
            push!(fields, Symbol(:k, i) => (:seq, frame.kind, node_key, length(frame.values), length(frame.pending)))
            for (j, value) in enumerate(frame.values)
                push!(fields, Symbol(:k, i, :v, j) => _value_key(value))
            end
        elseif frame isa IfFrame
            push!(fields, Symbol(:k, i) => (:if, _term_key(frame.then_branch, points),
                                               _term_key(frame.else_branch, points)))
        else
            push!(fields, Symbol(:k, i) => (:delimiter, frame.limit - m.used))
        end
    end
    for (d, frame) in enumerate(m.env)
        frame === input_frame && continue
        for (j, value) in enumerate(frame)
            push!(fields, Symbol(:e, d, :v, j) => _value_key(value))
        end
    end
    push!(fields, :outcome => _outcome(m))
    fields
end

_control_label(m::Machine) =
    m.control isa Ret ? "Value(" * value_label(m.control.value) * ")" : program_label(m.control)

# Free (uncharged) settlement: pop exhausted delimiters and recognise a
# value with an empty continuation as the final configuration.
function settle!(m::Machine)
    m.halted === nothing || return m
    while m.control isa Ret && !isempty(m.kont) && m.kont[end] isa Delimiter
        pop!(m.kont)
        pop!(m.limits)
    end
    if m.control isa Ret && isempty(m.kont)
        m.halted = Value(m.control.value)
    end
    m
end

function _trace_rows(body::Lambda, input::Tuple, T::Int)
    m = machine_for_body(body, input, T)
    input_frame = m.env[end]
    points = program_points(body)
    settle!(m)
    rows = TraceRow[TraceRow(0, _control_label(m), _row_fields(m, points, input_frame), m.fuel, _outcome(m))]
    for index in 1:T
        if m.halted === nothing
            step!(m)
            settle!(m)
            push!(rows, TraceRow(index, _control_label(m), _row_fields(m, points, input_frame),
                                 m.fuel, _outcome(m)))
        else
            last = rows[end]
            push!(rows, TraceRow(index, last.control, last.fields, last.fuel, last.outcome))
        end
    end
    if m.halted === nothing
        # The next charged transition has no fuel: the run is out of fuel.
        m.halted = OutOfFuel(T)
    end
    (; rows, result=m.halted)
end

function _trace_term(q::Quoted, input::Tuple, T::Int)
    T >= 0 || throw(ArgumentError("fuel must be a natural number"))
    body = _decider_body(q)
    _check_decider_input(input)
    run = _trace_rows(body, input, T)
    accepts = run.result isa Value && run.result.value === true
    BoundedTrace(q, input, T, run.rows, run.result, accepts)
end

_rows_equal(a::TraceRow, b::TraceRow) =
    a.index == b.index && a.control == b.control && a.fields == b.fields &&
    a.fuel == b.fuel && a.outcome == b.outcome

_result_key(r::Value) = (:value, _value_key(r.value))
_result_key(r::OutOfFuel) = (:out_of_fuel, r.used)
_result_key(r::SortError) = (:type_error, r.reason)
_result_key(r) = (:other, string(r))

function _replay_trace(t::BoundedTrace)
    recomputed = try
        _trace_term(t.program, t.input, t.T)
    catch error
        error isa ArgumentError || rethrow()
        return CheckResult(false, :trace_replay; expected=:decider,
                           actual=sprint(showerror, error))
    end
    rows_ok = length(recomputed.configurations) == length(t.configurations) == t.T + 1 &&
              all(_rows_equal(a, b) for (a, b) in zip(recomputed.configurations, t.configurations))
    result_ok = _result_key(recomputed.result) == _result_key(t.result)
    accepts_ok = t.accepts == recomputed.accepts ==
                 (t.result isa Value && t.result.value === true) ==
                 (t.configurations[end].outcome == :accept)
    CheckResult(rows_ok && result_ok && accepts_ok, :trace_replay;
                expected=(rows=t.T + 1, result=_result_key(recomputed.result), accepts=recomputed.accepts),
                actual=(rows=length(t.configurations), result=_result_key(t.result), accepts=t.accepts))
end

# The quote node is relocated to the trace's program: bound by identity
# through BoundedTrace.program (see _bound_replay in src/ir/programs.jl).
function _trace_certificate(t::BoundedTrace, quote_node::CertNode)
    CertNode(CHECKED, :BoundedTrace;
        facts=(display="T = $(t.T) body transitions (eval fuel T + 2; the implemented charge table of DESIGN 1.1, not part2a 8.3's); rows = $(length(t.configurations)); result = $(t.result); accepts = $(t.accepts); fnv1a64 = $(quote_hash(t.program))",),
        children=(_relocate(quote_node, x -> x isa BoundedTrace ? x.program : nothing),),
        replay=_bound_replay(t, :BoundedTrace, _replay_trace))
end

"bounded_trace(D, input, T) :: Checked{BoundedTrace, TraceCert} (DESIGN 2)."
function bounded_trace(q::Checked{<:Quoted}, input::Tuple, T::Int)
    t = _trace_term(q.term, input, T)
    Checked(t, _trace_certificate(t, q.certificate))
end
bounded_trace(q::Quoted, input::Tuple, T::Int) =
    bounded_trace(Checked(q, _quote_certificate(q)), input, T)
# DD-1: a runtime closure is never accepted where a description is expected.
bounded_trace(::Closure, input::Tuple, T::Int) =
    throw(ArgumentError("bounded_trace consumes a Quoted description, not a runtime Closure"))
bounded_trace(::Program, input::Tuple, T::Int) =
    throw(ArgumentError("bounded_trace consumes a Quoted description; quote the program first"))
