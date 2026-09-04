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
        return CheckResult(valid, valid ? :ld_point_format : :ld_point_format;
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

const D_ld = ld_decider


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
