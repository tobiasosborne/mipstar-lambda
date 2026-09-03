@enum Grade CONSTRUCTED CHECKED CITED ASSUMED SOURCE_REPAIR

"Structured result used by library checkers; no checker relies on `@assert`."
struct CheckResult
    ok::Bool
    rule::Symbol
    location::Any
    expected::Any
    actual::Any
    formula_ok::Bool
    zero_ok::Bool
end

function CheckResult(ok::Bool, rule::Symbol;
                     location=nothing, expected=nothing, actual=nothing,
                     formula_ok=ok, zero_ok=ok)
    CheckResult(ok, rule, location, expected, actual, formula_ok, zero_ok)
end

passed(result::CheckResult) = result.ok

"One replayable evidence node from DESIGN.md section 3."
struct CertNode
    grade::Grade
    rule::Symbol
    facts::NamedTuple
    children::Tuple
    replay::Any
end

CertNode(grade::Grade, rule::Symbol; facts=(;), children=(), replay=nothing) =
    CertNode(grade, rule, facts, Tuple(children), replay)

struct Checked{T,C}
    term::T
    certificate::C
end

function _verify_node(node::CertNode, term)
    if node.grade == CHECKED
        node.replay === nothing &&
            return CheckResult(false, :certificate_replay;
                               location=node.rule, expected=:replay, actual=nothing)
        result = try
            node.replay(term)
        catch err
            return CheckResult(false, :certificate_replay;
                               location=node.rule, expected=:pass,
                               actual=sprint(showerror, err))
        end
        result isa CheckResult ||
            return CheckResult(false, :certificate_replay;
                               location=node.rule, expected=CheckResult,
                               actual=typeof(result))
        passed(result) || return result
    end
    for child in node.children
        result = _verify_node(child, term)
        passed(result) || return result
    end
    CheckResult(true, :certificate_replay; location=node.rule)
end

verify_certificate(checked::Checked) = _verify_node(checked.certificate, checked.term)
