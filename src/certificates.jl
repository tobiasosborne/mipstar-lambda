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

"""
    BoundReplay(inner, facts, children)

A CHECKED node's replay bound, at construction, to the node's recorded
`facts` and its exact `children` (verdicts/tb7-r1.md T7-2, brief 93 E).
`_verify_node` refuses a node whose facts or children are not the ones its
replay was constructed with (a forged printed fact, a dropped CITED child)
before running the replay, so a replay can no longer certify a node it was
not built for. Calling it runs the inner replay on the attached term.
"""
struct BoundReplay
    inner::Any
    facts::NamedTuple
    children::Tuple
end
(b::BoundReplay)(term) = b.inner(term)
"""
    unbound(replay)

The unbound inner replay, for a CONSTRUCTOR that deliberately rebuilds a
node with other children (e.g. appending a SOURCE_REPAIR leaf); the keyword
constructor then binds it to the rebuilt node. Copying a node with the same
`replay` keeps the old binding and is refused.
"""
unbound(replay) = replay isa BoundReplay ? replay.inner : replay

# The keyword constructor binds every CHECKED replay to the node it builds; an
# already-bound replay is carried unchanged (so a copy with other facts or
# children keeps the ORIGINAL binding and is refused).
function CertNode(grade::Grade, rule::Symbol; facts=(;), children=(), replay=nothing)
    children = Tuple(children)
    if grade == CHECKED && replay !== nothing && !(replay isa BoundReplay)
        replay = BoundReplay(replay, facts, children)
    end
    CertNode(grade, rule, facts, children, replay)
end

struct Checked{T,C}
    term::T
    certificate::C
end

"The binding of a CHECKED node: its replay is a BoundReplay built for exactly these facts and children."
function _replay_binding(node::CertNode)
    r = node.replay
    r isa BoundReplay ||
        return CheckResult(false, :replay_binding; location=node.rule, expected=:bound_replay, actual=typeof(r))
    r.facts === node.facts ||
        return CheckResult(false, :replay_binding; location=node.rule, expected=:recorded_facts, actual=:facts_differ)
    (length(r.children) == length(node.children) && all(a === b for (a, b) in zip(r.children, node.children))) ||
        return CheckResult(false, :replay_binding; location=node.rule, expected=[c.rule for c in r.children],
                           actual=[c.rule for c in node.children])
    CheckResult(true, :replay_binding; location=node.rule)
end

# One CHECKED node's own obligation: a replay exists, it is bound to exactly
# this node's facts and children, and it passes on the attached term.
function _verify_own(node::CertNode, term)
    node.replay === nothing &&
        return CheckResult(false, :certificate_replay;
                           location=node.rule, expected=:replay, actual=nothing)
    binding = _replay_binding(node)
    passed(binding) || return binding
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
    result
end

function _verify_node(node::CertNode, term)
    if node.grade == CHECKED
        result = _verify_own(node, term)
        passed(result) || return result
    end
    for child in node.children
        result = _verify_node(child, term)
        passed(result) || return result
    end
    CheckResult(true, :certificate_replay; location=node.rule)
end

verify_certificate(checked::Checked) = _verify_node(checked.certificate, checked.term)

"""
    verify_local(node, term) -> CheckResult

One CHECKED node on its own: its fact/child binding and its replay on the
attached term, without descending into its children (the per-node census of
verdicts/tb7-r1.md T7-2). A non-CHECKED node passes vacuously.
"""
verify_local(node::CertNode, term) =
    node.grade == CHECKED ? _verify_own(node, term) : CheckResult(true, :certificate_replay; location=node.rule)
