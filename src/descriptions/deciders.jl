# DESIGN 9.1's DeciderDescription: a total bit predicate on (n, x, y, a, b)
# (def:decider, gt-05-games-normalform.tex:612-622) or (n, tA, x, tB, y, a, b)
# (def:typed-decider, gt-06-types.tex:185-195), as canonical quoted data for
# one universal interpreter `decide`. Grammar and bytes (0xC4 then the term):
#   (:Copy)                                    accept iff a == x and b == y (the copy game)
#   (:Trivial)                                 accept always
#   (:TypedAnchor, D)                          gt-11:98-103 over {Game, Anchor}
#   (:Detype, labels, edges, D)                gt-06:409-427 parser + one child call
#   (:Repeat, lambda, tau, c_num, c_den, D)    gt-11:216-220 guard, then exactly k child calls
# Every interpreter path halts; malformed input REJECTS except where the
# source prescribes accept-on-invalid (the detyped parser).

const DECIDER_HEADER = 0xC4
const _DECIDER_TAGS = Dict(:Copy => 0x01, :Trivial => 0x02, :TypedAnchor => 0x03, :Detype => 0x04, :Repeat => 0x05)
const _DECIDER_TAG_NAMES = Dict(byte => tag for (tag, byte) in _DECIDER_TAGS)

function _encode_decider_term!(buffer::IOBuffer, term)
    tag = term[1]
    write(buffer, _DECIDER_TAGS[tag])
    if tag == :TypedAnchor
        _encode_decider_term!(buffer, term[2])
    elseif tag == :Detype
        _encode_typing!(buffer, term[2], term[3])
        _encode_decider_term!(buffer, term[4])
    elseif tag == :Repeat
        foreach(v -> _encode_int!(buffer, v), term[2:5])
        _encode_decider_term!(buffer, term[6])
    end
    buffer
end
function _decode_decider_term!(buffer::IOBuffer)
    bytesavailable(buffer) >= 1 || throw(ArgumentError("truncated description"))
    tag = get(_DECIDER_TAG_NAMES, read(buffer, UInt8), nothing)
    tag === nothing && throw(ArgumentError("unknown decider description tag"))
    tag in (:Copy, :Trivial) && return (tag,)
    tag == :TypedAnchor && return (:TypedAnchor, _decode_decider_term!(buffer))
    if tag == :Detype
        labels, edges = _decode_typing!(buffer)
        return (:Detype, labels, edges, _decode_decider_term!(buffer))
    end
    values = [_decode_int!(buffer) for _ in 1:4]
    (:Repeat, values..., _decode_decider_term!(buffer))
end
function decider_term_bytes(term)
    buffer = IOBuffer()
    write(buffer, DECIDER_HEADER)
    _encode_decider_term!(buffer, term)
    take!(buffer)
end
function decode_decider_term(bytes::AbstractVector{UInt8})
    buffer = IOBuffer(Vector{UInt8}(bytes))
    (bytesavailable(buffer) >= 1 && read(buffer, UInt8) == DECIDER_HEADER) ||
        throw(ArgumentError("not a canonical decider description"))
    term = _decode_decider_term!(buffer)
    bytesavailable(buffer) == 0 || throw(ArgumentError("trailing description bytes"))
    term
end

_decider_child(term) = term[1] == :TypedAnchor ? term[2] : term[1] == :Detype ? term[4] :
                       term[1] == :Repeat ? term[6] : nothing
function _decider_typing(term)
    term[1] == :TypedAnchor && return ANCHOR_TYPING
    Untyped()
end
function _decider_dependencies(term)
    child = _decider_child(term)
    child === nothing && return Set{Any}([:D])
    found = Set{Any}()
    term[1] == :Repeat && push!(found, :lambda, :tau, :c_prime)
    _decider_leaf_hashes!(found, child)
    found
end
function _decider_leaf_hashes!(found::Set{Any}, term)
    child = _decider_child(term)
    if child === nothing
        push!(found, quote_hash(decider_term_bytes(term)))
    else
        term[1] == :Repeat && push!(found, :lambda, :tau, :c_prime)
        _decider_leaf_hashes!(found, child)
    end
    found
end
"The dependency set read off decider bytes: the leaf predicate's hash and every parameter literal (`:D` for a leaf)."
decider_dependency_walk(bytes::AbstractVector{UInt8}) = _decider_dependencies(decode_decider_term(bytes))

function _decider_laws(term)
    tag = term[1]
    tag in (:Copy, :Trivial) && return (; time=1, question=1, answer=1, B=nothing, k=nothing)
    tag == :TypedAnchor && return (; time=:(1 + TIME_1(n)), question=:(Q_1(n)), answer=:(max(A_1(n), 1)), B=nothing, k=nothing)
    tag == :Detype && return (; time=:(1 + TIME_1(n)), question=:(Q_1(n) + 4 * TypeCount), answer=:(A_1(n)), B=nothing, k=nothing)
    # SOURCE_REPAIR(repeat-tuple-framing): the source parses x, y, a, b as
    # k(n)-tuples without a cost model for the tuple encoding; the executable
    # frames every component with a 32-bit length field, so the honest
    # strings carry k(n) * 32 framing bits above k(n) * B(n).
    (; time=:(O(k(n) * max(TIME_1(n), B(n)))), question=:(k(n) * (B(n) + $(FRAME_BITS))),
       answer=:(k(n) * (B(n) + $(FRAME_BITS))), B=B_REP_LAW, k=K_REP_LAW)
end

function _decider_from_term(term; parts=nothing)
    child = _decider_child(term)
    children = parts === nothing ? (child === nothing ? () : (_decider_from_term(child),)) : parts
    bytes = decider_term_bytes(term)
    laws = _decider_laws(term)
    DeciderDescription(Quoted{:TotalPredicate}(bytes), term, _decider_typing(term), laws.time, laws.question,
                       laws.answer, length(bytes), _decider_dependencies(term), laws.B, laws.k, children)
end
decode_decider(bytes::AbstractVector{UInt8}) = _decider_from_term(decode_decider_term(bytes))
_ddesc(x::Checked) = x.term
_ddesc(x::DeciderDescription) = x

function _decider_certificate(rule::Symbol, D::DeciderDescription, display::String, replay_check::Function, cited::Tuple, parts::Tuple)
    size_node = CertNode(CHECKED, :DescriptionSize;
        facts=(display="|D| = $(D.description_size) bytes, reserialized; fnv1a64 = $(quote_hash(D))",),
        replay=_bound_replay(D, :DescriptionSize, x -> CheckResult(length(decider_term_bytes(x.term)) == x.description_size &&
            canonical_bytes(decode_decider(canonical_bytes(x))) == canonical_bytes(x), :description_size; location=:DescriptionSize)))
    dependency = CertNode(CHECKED, :DependencySet;
        facts=(display="syntax walk = {$(join(sort(string.(collect(D.dependency_set))), ", "))}",),
        replay=_bound_replay(D, :DependencySet, x -> CheckResult(decider_dependency_walk(canonical_bytes(x)) == x.dependency_set, :dependency_set; location=:DependencySet)))
    predicate = CertNode(CHECKED, rule;
        facts=(display=display,), replay=_bound_replay(D, rule, replay_check))
    relocated = Tuple(_relocate(p.certificate, x -> x.parts[i]) for (i, p) in enumerate(parts) if p isa Checked)
    root = CertNode(CONSTRUCTED, Symbol(String(rule) * "Description");
        facts=(display="$(display); typing $(D.typing isa Untyped ? "untyped (n, x, y, a, b)" : "typed (n, tA, x, tB, y, a, b)"); TIME = $(D.time_bound); |question| <= $(D.question_length); |answer| <= $(D.answer_length); |D| = $(D.description_size) bytes",),
        children=(predicate, size_node, dependency, cited..., relocated...))
    Checked(D, root)
end

"The copy game's decider a = x and b = y (DESIGN 10.3's V_copy; the fixture's sampler lives in the tests)."
function copy_decider()
    D = _decider_from_term((:Copy,); parts=())
    _decider_certificate(:CopyDecider, D, "accept iff a == x and b == y as bit strings",
        x -> CheckResult(decide(x, 1, [true], [false], [true], [false]) && !decide(x, 1, [true], [false], [false], [false]) &&
                         !decide(x, 1, [true], [false], [true], [true]) && !decide(x, 1, [true], Bool[], [true], [false]),
                         :copy_decider; location=:CopyDecider), (), ())
end
"The always-accepting decider (a byte-distinct decider for the independence test)."
function trivial_decider()
    D = _decider_from_term((:Trivial,); parts=())
    _decider_certificate(:TrivialDecider, D, "accept on every input",
        x -> CheckResult(decide(x, 1, Bool[], Bool[], [true], Bool[]), :trivial_decider; location=:TrivialDecider), (), ())
end

# ---------------------------------------------------------------------------
# Canonical framing of a k-tuple of bit strings (DESIGN 10.2, DD-26): each
# component is a 32-bit big-endian length followed by its bits.

const FRAME_BITS = 32
function frame_components(components::AbstractVector{<:AbstractVector{Bool}})
    out = Bool[]
    for component in components
        len = length(component)
        append!(out, Bool[(len >> (FRAME_BITS - i)) & 1 == 1 for i in 1:FRAME_BITS])
        append!(out, component)
    end
    out
end

# Streaming parse: exactly k components, each length field checked against
# B BEFORE its payload is read, no trailing bits; `nothing` on any failure.
function parse_framed(bits::Vector{Bool}, k::Int, B::Int)
    components = Vector{Bool}[]
    position = 0
    for _ in 1:k
        position + FRAME_BITS <= length(bits) || return nothing
        len = 0
        for i in 1:FRAME_BITS
            len = (len << 1) | Int(bits[position + i])
        end
        position += FRAME_BITS
        len <= B || return nothing
        position + len <= length(bits) || return nothing
        push!(components, bits[position+1:position+len])
        position += len
    end
    position == length(bits) || return nothing
    components
end

# ---------------------------------------------------------------------------
# The interpreter. `trace` collects the child calls a repeated decider makes.

struct ChildCall
    index::Int
    accepted::Bool
end

_bits(v) = v isa AbstractVector{Bool} ? Vector{Bool}(v) : throw(ArgumentError("decider inputs are bit strings"))

function _decide(term, n::Int, x::Vector{Bool}, y::Vector{Bool}, a::Vector{Bool}, b::Vector{Bool}, trace::Vector{ChildCall})
    tag = term[1]
    tag == :Copy && return a == x && b == y
    tag == :Trivial && return true
    tag == :TypedAnchor && throw(ArgumentError("a typed decider takes (n, tA, x, tB, y, a, b)"))
    if tag == :Detype
        labels, edges, child = term[2], term[3], term[4]
        T = length(labels)
        # (x', x''), (y', y'') by the canonical pair scheme: V_G is the first
        # 4|Type| bits; a string too short to parse is accepted (gt-06:412-414).
        (length(x) >= 4T && length(y) >= 4T) || return true
        edge_set = Set(edges)
        neigh(t) = Bool[(t, v) in edge_set || (v, t) in edge_set for v in 1:T]
        unit(t) = Bool[v == t for v in 1:T]
        xG, yG = x[1:4T], y[1:4T]
        for (l, r) in edges
            xG == vcat(unit(l), neigh(l), falses(T), unit(l)) || continue
            yG == vcat(falses(T), unit(r), unit(r), neigh(r)) || continue
            return _decide_typed(child, n, labels[l], x[4T+1:end], labels[r], y[4T+1:end], a, b, trace)
        end
        return true
    end
    tag == :Repeat || throw(ArgumentError("unknown decider term"))
    lambda, tau, c_num, c_den, child = term[2], term[3], term[4], term[5], term[6]
    # B(n) first, without reading the payloads; then the streamed guard on
    # all four tuples (gt-11:216-220, DD-26); only then exactly k child calls.
    B = B_rep(lambda, tau, n)
    k = k_rep(lambda, tau, c_num // c_den, n)
    xs = parse_framed(x, k, B)
    xs === nothing && return false
    ys = parse_framed(y, k, B)
    ys === nothing && return false
    as = parse_framed(a, k, B)
    as === nothing && return false
    bs = parse_framed(b, k, B)
    bs === nothing && return false
    verdict = true
    for i in 1:k
        accepted = _decide(child, n, xs[i], ys[i], as[i], bs[i], trace)
        push!(trace, ChildCall(i, accepted))
        verdict &= accepted
    end
    verdict
end

function _decide_typed(term, n::Int, tA, x::Vector{Bool}, tB, y::Vector{Bool}, a::Vector{Bool}, b::Vector{Bool}, trace::Vector{ChildCall})
    tag = term[1]
    tag == :TypedAnchor || throw(ArgumentError("an untyped decider takes (n, x, y, a, b)"))
    child = term[2]
    (tA in ANCHOR_TYPING.labels && tB in ANCHOR_TYPING.labels) || return false
    if tA == "Anchor" || tB == "Anchor"
        # gt-11:98-101: every Anchor-typed player answers the canonical bit 0;
        # a Game-typed player on such a pair may answer anything; a malformed
        # Anchor answer (not exactly one bit) rejects.
        tA == "Anchor" && a != [false] && return false
        tB == "Anchor" && b != [false] && return false
        return true
    end
    _decide(child, n, x, y, a, b, trace)
end

"decide(D, n, x, y, a, b) / decide(D, n, tA, x, tB, y, a, b): the decider's bit."
decide(D::DeciderDescription, n::Integer, x, y, a, b) = decide_traced(D, n, x, y, a, b)[1]
decide(D::DeciderDescription, n::Integer, tA, x, tB, y, a, b) = decide_traced(D, n, tA, x, tB, y, a, b)[1]
"decide_traced(...) -> (bit, child_calls): the bit and the log of child calls made by a repeated decider (empty on a guard failure)."
function decide_traced(D::DeciderDescription, n::Integer, x, y, a, b)
    n >= 1 || return (false, ChildCall[])
    D.typing isa Untyped || throw(ArgumentError("a typed decider takes (n, tA, x, tB, y, a, b)"))
    trace = ChildCall[]
    (_decide(D.term, Int(n), _bits(x), _bits(y), _bits(a), _bits(b), trace), trace)
end
function decide_traced(D::DeciderDescription, n::Integer, tA, x, tB, y, a, b)
    n >= 1 || return (false, ChildCall[])
    D.typing isa Typed || throw(ArgumentError("an untyped decider takes (n, x, y, a, b)"))
    trace = ChildCall[]
    (_decide_typed(D.term, Int(n), String(tA), _bits(x), String(tB), _bits(y), _bits(a), _bits(b), trace), trace)
end
