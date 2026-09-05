struct LDParams{F}
    m::Int
    d::Int
    kappa::Int
end

function LDParams(::Type{F}, m::Integer, d::Integer, kappa::Integer=1) where {F<:GF2k}
    dimension = Int(m)
    degree_bound = Int(d)
    simultaneous = Int(kappa)
    dimension > 0 || throw(ArgumentError("m must be positive"))
    degree_bound >= 0 || throw(ArgumentError("d must be nonnegative"))
    simultaneous > 0 || throw(ArgumentError("kappa must be positive"))
    field_size(F) % dimension == 0 || throw(ArgumentError("m must divide q"))
    LDParams{F}(dimension, degree_bound, simultaneous)
end

"Restrict a sparse multivariate polynomial to t -> base + t*direction."
function restrict(poly::Poly{F,N}, line::AffineLine{F,N}) where {F,N}
    layout = VarLayout((:t,), (VarBlock(:LineParameter, 1:1),))
    t = polyvar(F, layout, 1)
    result = zero_poly(F, layout)
    for (powers, coefficient) in poly.terms
        term = constant_poly(F, layout, coefficient)
        for coordinate in 1:N
            exponent = Int(powers[coordinate])
            exponent == 0 && continue
            affine = constant_poly(F, layout, line.base[coordinate]) +
                     constant_poly(F, layout, line.direction[coordinate]) * t
            term = term * affine^exponent
        end
        result = result + term
    end
    result
end

univariate_degree(poly::Poly{F,1}) where {F} = actual_degrees(poly)[1]

function _known_type(kind)
    kind in (:Point, :ALine, :DLine)
end

function _question_format(params::LDParams{F}, kind::Symbol, raw) where {F}
    _known_type(kind) || return false
    try
        length(raw) == 2 * params.m + 1 && all(value -> value isa F, raw)
    catch
        false
    end
end

function _answer_entries(answer, expected::Int)
    (answer isa Tuple || answer isa AbstractVector) || return nothing
    length(answer) == expected || return nothing
    Tuple(answer)
end

function _answer_format(params::LDParams{F}, kind::Symbol, answer, side::Symbol) where {F}
    entries = _answer_entries(answer, params.kappa)
    entries === nothing &&
        return CheckResult(false, :ld_answer_arity; location=side,
                           expected=params.kappa,
                           actual=try length(answer) catch; nothing end)
    if kind == :Point
        valid = all(value -> value isa F, entries)
        return CheckResult(valid, :ld_point_format;
                           location=side, expected=F, actual=map(typeof, entries))
    end
    bound = if kind == :ALine
        params.d
    elseif kind == :DLine
        params.m * params.d
    else
        return CheckResult(false, :ld_unknown_type; location=side,
                           expected=(:Point, :ALine, :DLine), actual=kind)
    end
    rule = kind == :ALine ? :ld_axis_degree : :ld_diagonal_degree
    for (j, polynomial) in enumerate(entries)
        polynomial isa Poly{F,1} ||
            return CheckResult(false, rule; location=(side, j),
                               expected="univariate polynomial over the declared field",
                               actual=typeof(polynomial))
        degree = univariate_degree(polynomial)
        degree <= bound ||
            return CheckResult(false, rule; location=(side, j),
                               expected=bound, actual=degree)
    end
    CheckResult(true, rule; location=side, expected=bound, actual=:valid)
end

function _entry_equal(left, right)
    if left isa Poly && right isa Poly
        return polynomial_equal(left, right)
    end
    left == right
end

function _answers_equal(left, right)
    length(left) == length(right) &&
        all(_entry_equal(a, b) for (a, b) in zip(left, right))
end

function _line_parameter(line::AffineLine{F,N}, point::NTuple{N,F}) where {F,N}
    pivot = findfirst(!iszero, line.direction)
    if pivot === nothing
        return point == line.base ? (true, zero(F)) : (false, zero(F))
    end
    t = (point[pivot] - line.base[pivot]) / line.direction[pivot]
    (line_point(line, t) == point, t)
end

function _line_point_test(params::LDParams{F}, kind::Symbol, line_raw, point_raw,
                          line_answer, point_answer) where {F}
    line = kind == :ALine ? axis_line(line_raw, params.m) :
                            diagonal_line(line_raw, params.m)
    point = point_value(point_raw, params.m)
    on_line, t = _line_parameter(line, point)
    rule = kind == :ALine ? :ld_axis_point : :ld_diagonal_point
    # SOURCE_REPAIR :ld_off_line_rejects (gt-07-ldt.tex:377-384): items 2/3
    # quantify over "t such that x = u_0 + t e_i" (resp. "+ t v'"); when the
    # point is off the line no such t exists and the literal reading accepts
    # vacuously ("in all cases where no action is indicated, accept"). The
    # executable rejects instead: strictly stricter, never reached by honest
    # play at (8,2,1) (see `ld_off_line_repair`).
    on_line || return CheckResult(false, rule; location=:question,
                                  expected=:point_on_line, actual=point)
    for j in 1:params.kappa
        line_value = evaluate(line_answer[j], [t])
        point_value_j = point_answer[j]
        line_value == point_value_j ||
            return CheckResult(false, rule; location=j,
                               expected=point_value_j, actual=line_value)
    end
    CheckResult(true, rule; location=Tuple(point), expected=:agreement,
                actual=:agreement)
end

"Figure fig:ld-decider, returning structured pass/fail evidence."
function ld_decider(params::LDParams{F}, left_type::Symbol, left_question,
                    right_type::Symbol, right_question,
                    left_answer, right_answer) where {F}
    for (side, kind, question) in ((:left, left_type, left_question),
                                   (:right, right_type, right_question))
        _question_format(params, kind, question) ||
            return CheckResult(false, :ld_question_format; location=side,
                               expected=(kind, 2 * params.m + 1),
                               actual=try (kind, length(question)) catch; (kind, nothing) end)
    end
    left_format = _answer_format(params, left_type, left_answer, :left)
    passed(left_format) || return left_format
    right_format = _answer_format(params, right_type, right_answer, :right)
    passed(right_format) || return right_format

    # fig:ld-decider item 1 (gt-07-ldt.tex:371-374).
    if left_type == right_type
        equal = _answers_equal(left_answer, right_answer)
        return CheckResult(equal, :ld_consistency; location=left_type,
                           expected=left_answer, actual=right_answer)
    end

    # fig:ld-decider items 2 and 3 (gt-07-ldt.tex:375-384), symmetrized.
    if left_type in (:ALine, :DLine) && right_type == :Point
        return _line_point_test(params, left_type, left_question, right_question,
                                left_answer, right_answer)
    elseif right_type in (:ALine, :DLine) && left_type == :Point
        return _line_point_test(params, right_type, right_question, left_question,
                                right_answer, left_answer)
    end
    CheckResult(true, :ld_noop; location=(left_type, right_type))
end

"""
    ld_off_line_repair(; honest_support_hits, of)

The SOURCE_REPAIR node recording that `ld_decider` rejects a line-versus-point
pair whose point is off the line (fig:ld-decider items 2/3,
gt-07-ldt.tex:377-384, read literally, accept vacuously). The facts carry how
many honest support decisions reached that branch in a sweep of `of`.
"""
function ld_off_line_repair(; honest_support_hits::Integer, of::Integer)
    CertNode(SOURCE_REPAIR, :ld_off_line_rejects;
        facts=(honest_support_hits=Int(honest_support_hits), of=Int(of),
               source="gt-07-ldt.tex:377-384",
               literal="accept when no t satisfies x = u_0 + t v (vacuous)",
               executable="reject with :ld_axis_point/:ld_diagonal_point at location :question"))
end

"The honest low-degree prover for `g`: value at a point, restriction to a line."
function ld_honest_answer(g::Poly, kind::Symbol, raw, m::Integer)
    dimension = Int(m)
    kind == :Point && return (evaluate(g, collect(point_value(raw, dimension))),)
    kind == :ALine && return (restrict(g, axis_line(raw, dimension)),)
    kind == :DLine && return (restrict(g, diagonal_line(raw, dimension)),)
    throw(ArgumentError("unknown low-degree question type"))
end

const _LD_KINDS = (:Point, :ALine, :DLine)

"""
    ld_honest_sweep(params, g, samplers, seeds)

Run `ld_decider` on every distinct (left, right) question pair the three
samplers produce over `seeds` for all nine ordered type pairs, answered
honestly for `g`. Counts the non-noop decisions, the equal-type tautologies,
the line-versus-point checks and how often the off-line branch
(`ld_off_line_repair`) was reached.
"""
function ld_honest_sweep(params::LDParams{F}, g::Poly, samplers, seeds) where {F}
    supports = Dict((left, right) => Set{Any}()
                    for left in _LD_KINDS for right in _LD_KINDS)
    for seed in seeds
        questions = (apply(samplers[:Point], seed), apply(samplers[:ALine], seed),
                     apply(samplers[:DLine], seed))
        for (l, left) in enumerate(_LD_KINDS), (r, right) in enumerate(_LD_KINDS)
            push!(supports[(left, right)], (questions[l], questions[r]))
        end
    end
    cache = Dict{Tuple{Symbol,Any},Any}()
    checked = 0
    non_noop = 0
    equal_type = 0
    line_vs_point = 0
    off_line_hits = 0
    accepted = true
    for left in _LD_KINDS, right in _LD_KINDS
        for (left_q, right_q) in supports[(left, right)]
            left_a = get!(() -> ld_honest_answer(g, left, left_q, params.m),
                          cache, (left, left_q))
            right_a = get!(() -> ld_honest_answer(g, right, right_q, params.m),
                           cache, (right, right_q))
            result = ld_decider(params, left, left_q, right, right_q, left_a, right_a)
            accepted &= passed(result)
            non_noop += result.rule != :ld_noop
            equal_type += result.rule == :ld_consistency
            if result.rule in (:ld_axis_point, :ld_diagonal_point)
                line_vs_point += 1
                off_line_hits += result.location == :question
            end
            checked += 1
        end
    end
    (; accepted, checked, non_noop, equal_type, line_vs_point, off_line_hits,
       support_count=sum(length, values(supports)),
       nonempty=all(support -> !isempty(support), values(supports)))
end

function _replay_ld_sweep(term)
    recount = ld_honest_sweep(term.params, term.g, term.samplers, term.seeds)
    ok = recount == term.report && recount.accepted && recount.nonempty &&
         recount.off_line_hits == 0 && recount.checked == recount.support_count &&
         recount.equal_type + recount.line_vs_point == recount.non_noop
    CheckResult(ok, :ld_honest_sweep; expected=term.report, actual=recount)
end

"""
    ld_sweep_evidence(params, g, samplers, seeds)

TB1's `D^ld` evidence as a CHECKED node (verdicts/tb1-r3.md N15): the replay
re-runs `ld_honest_sweep` from its inputs and requires the recount to equal
the recorded report, every honest decision accepted and the off-line branch
never reached; the `:ld_off_line_rejects` SOURCE_REPAIR hangs under it. The
facts carry the answer bounds `d`, `md` and `kappa`.
"""
function ld_sweep_evidence(params::LDParams{F}, g::Poly, samplers, seeds) where {F}
    report = ld_honest_sweep(params, g, samplers, seeds)
    repair = ld_off_line_repair(honest_support_hits=report.off_line_hits,
                                of=report.checked)
    root = CertNode(CHECKED, :ld_honest_sweep;
        facts=(q=field_size(F), m=params.m, d=params.d, md=params.m * params.d,
               kappa=params.kappa, support_decisions=report.checked,
               non_noop=report.non_noop, equal_type=report.equal_type,
               line_vs_point=report.line_vs_point),
        children=(repair,), replay=_replay_ld_sweep)
    Checked((; params, g, samplers, seeds, report), root)
end


const _TB1_POLY2 = Poly{GF8,2}
const _TB1_POLY1 = Poly{GF8,1}
const _TB1_RAW_QUESTION = NTuple{5,GF8}
precompile(restrict, (_TB1_POLY2, AffineLine{GF8,2}))
precompile(ld_decider,
           (LDParams{GF8}, Symbol, _TB1_RAW_QUESTION,
            Symbol, _TB1_RAW_QUESTION, Tuple{_TB1_POLY1}, Tuple{GF8}))
precompile(ld_decider,
           (LDParams{GF8}, Symbol, _TB1_RAW_QUESTION,
            Symbol, _TB1_RAW_QUESTION, Tuple{GF8}, Tuple{_TB1_POLY1}))
precompile(ld_decider,
           (LDParams{GF8}, Symbol, _TB1_RAW_QUESTION,
            Symbol, _TB1_RAW_QUESTION, Tuple{GF8}, Tuple{GF8}))
