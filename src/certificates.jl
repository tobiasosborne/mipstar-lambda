@enum Grade CONSTRUCTED CHECKED CITED ASSUMED SOURCE_REPAIR

import SHA

# An immutable value seal of the actual evidence, including mutable Expr
# arguments, arrays, dictionaries and fields of evidence structs. References
# break cycles; functions/types are opaque identities, never alleged proofs.
# Keep this generic walker unspecialized: evidence has many large tuple types.
function _write_fact(io, @nospecialize(x), seen::IdDict{Any,Int})
    print(io, typeof(x), ':')
    if isbitstype(typeof(x)) || x isa Number || x isa AbstractString || x isa Symbol || x isa Char ||
       x === nothing || x isa Type || x isa Module || x isa Function
        s = repr(x)
        print(io, ncodeunits(s), ':', s, ';')
        return
    end
    if ismutabletype(typeof(x))
        if haskey(seen,x)
            print(io,"ref",seen[x],';')
            return
        end
        seen[x] = length(seen)+1
    end
    if x isa AbstractArray
        print(io,size(x), '[')
        for v in x
            _write_fact(io,v,seen)
        end
    elseif x isa AbstractDict || x isa AbstractSet || x isa Tuple
        print(io,length(x),'[')
        for v in x
            _write_fact(io,v,seen)
        end
    else
        print(io,fieldcount(typeof(x)),'[')
        for i in 1:fieldcount(typeof(x))
            isdefined(x,i) ? _write_fact(io,getfield(x,i),seen) : print(io,"undef;")
        end
    end
    print(io,']')
end
function _fact_seal(@nospecialize(x))
    io = IOBuffer()
    _write_fact(io,x,IdDict{Any,Int}())
    Tuple(SHA.sha256(take!(io)))
end

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
struct FactReplay
    check::Any
end

struct BoundReplay
    inner::Any
    facts::NamedTuple
    children::Tuple
    fact_seal::NTuple{32,UInt8}
    child_seals::Tuple
end
BoundReplay(inner, facts, children) = BoundReplay(inner, facts, children, _fact_seal(facts),
    Tuple((c.grade,c.rule,_fact_seal(c.facts)) for c in children))
_invoke_bound(b::BoundReplay, term) = b.inner isa FactReplay ? b.inner.check(b.facts,b.children,term) : b.inner(term)
function (b::BoundReplay)(term)
    node = CertNode(CHECKED,:bound_replay,b.facts,b.children,b)
    binding = _replay_binding(node)
    passed(binding) || return binding
    _invoke_bound(b,term)
end
"""
    unbound(replay)

Compatibility spelling that retains the existing replay and its seals.
It cannot turn a forged node or missing required child into fresh evidence.
"""
# Compatibility spelling: reconstruction never discards an existing seal.
unbound(replay) = replay

# Explicit construction adapters retain the original validation before adding
# a disclosure or changing a display. Unlike unbound, this requires the source
# node, and replays its real binding on every invocation.
_reconstruction_replay(node::CertNode) = node.grade == CHECKED ?
    (term -> _verify_own(node,term)) : node.replay

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
    _fact_seal(node.facts) == r.fact_seal ||
        return CheckResult(false, :replay_binding; location=node.rule, expected=:frozen_facts, actual=:facts_mutated)
    (length(r.children) == length(node.children) && all(a === b for (a, b) in zip(r.children, node.children))) ||
        return CheckResult(false, :replay_binding; location=node.rule, expected=[c.rule for c in r.children],
                           actual=[c.rule for c in node.children])
    Tuple((c.grade,c.rule,_fact_seal(c.facts)) for c in node.children) == r.child_seals ||
        return CheckResult(false, :replay_binding; location=node.rule, expected=:required_child_evidence, actual=:child_mutated)
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
        _invoke_bound(node.replay,term)
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
