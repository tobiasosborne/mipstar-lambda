# DESIGN 9.1: the description sorts. A SamplerDescription is canonical quoted
# data (a term of the sampler grammar below, serialized to bytes) plus the
# header laws that parse its answers; its only behavioral operations are the
# four SamplerQuery variants of def:sampler (gt-04-cl.tex:572-601) and their
# typed forms (gt-06-types.tex:95-140). No public left/right/branch-table
# field: composites embed their children by BYTES and answer queries by
# forwarding to the children's queries (DL9 "definable", DESIGN 9.4).
#
# Grammar (nested-tuple AST; every child description is embedded verbatim):
#   (:Pair, q, clA, clB)                     untyped leaf: two CL terms (cl.jl format)
#   (:TypedFamily, q, labels, edges, maps)   typed leaf: per-type (clA_t, clB_t)
#   (:DirectSum, [S_1, ..., S_r])            DL9-direct-sum
#   (:Repeat, lambda, tau, c_num, c_den, S)  DL9-repeat: a compact k(n)-fold loop
#   (:Anchor, S)                             typed {Game, Anchor} family over S
#   (:Detype, T)                             DL9-detype: graph maps + conditional child
#   (:Product, T_1, T_2)                     DL9-product: tensor type graph
#   (:Downsize, S)                           DL9-downsize: F_q -> F_2 conjugation
#   (:Pauli, q, m, d)                        TB6: the typed Pauli family (gt-07:1070-1120), 26 types
#   (:Intro, lambda, ell, q, m, d)           TB6: tilde S^intro (gt-08:317-345), 32 + 2 ell types
#   (:Graph, labels, edges)                  TB6: graph_sampler(G) (gt-06:225-339), level 2, dim 4|Type|
# Bytes: 0xC3 then the term; tags below; integers u32 big-endian; labels as
# u32-length-prefixed UTF-8; CL terms exactly as `describe_cl` writes them.

"The prime field F_2 (GF2k{1, x+1}); registered for description round trips (verdicts/tb2-r4.md forward NOTE 1)."
const GF2 = GF2k{1,0x3}
_DESCRIPTION_FIELDS[field_size(GF2)] = GF2

"Total non-success result of a malformed sampler or decider call (DESIGN 9.1); no sampler-law conclusion."
struct QueryError
    reason::String
end
Base.show(io::IO, e::QueryError) = print(io, "QueryError(", repr(e.reason), ")")

"Typing of a description: Untyped, or Typed(labels, oriented edges over the labels)."
struct Untyped end
struct Typed
    labels::Vector{String}
    edges::Vector{Tuple{String,String}}
    function Typed(labels, edges)
        ls = String[String(l) for l in labels]
        allunique(ls) || throw(ArgumentError("type labels must be unique"))
        es = Tuple{String,String}[(String(e[1]), String(e[2])) for e in edges]
        all(e -> e[1] in ls && e[2] in ls, es) || throw(ArgumentError("type graph has an unknown endpoint"))
        new(ls, es)
    end
end
Base.:(==)(a::Typed, b::Typed) = a.labels == b.labels && a.edges == b.edges
"TypeCount: the cardinality of a typed description's type set (definitions.md H)."
TypeCount(t::Typed) = length(t.labels)
TypeCount(::Untyped) = 0

# The four query variants (DESIGN 9.1 arities; `type` is the optional
# seventh input of a typed sampler, `nothing` for an untyped one).
abstract type SamplerQuery end
struct DimensionQuery <: SamplerQuery
    n::Int
end
struct MarginalQuery <: SamplerQuery
    n::Int
    w::Symbol
    j::Int
    z::Any
    type::Any
end
struct LinearQuery <: SamplerQuery
    n::Int
    w::Symbol
    j::Int
    u::Any
    y::Any
    type::Any
end
struct FactorQuery <: SamplerQuery
    n::Int
    w::Symbol
    j::Int
    u::Any
    type::Any
end
const PLAYERS = (:alice, :bob)

"""
    SamplerDescription

DESIGN 9.1's record: `code` (canonical bytes of the term, sort SamplerMachine),
the header laws `field_law`/`level_law`/`dimension_law` (closed QuotedLaw{Nat}
terms over `n`, the parameters and the children's laws `q_i`, `ell_i`,
`s_i(n)`), their values at the construction index (`field_size`, `level`),
`typing`, the metered `query_time` law, `description_size` = the exact byte
length, and `dependency_set` = the syntax walk over the embedded leaf
descriptions and parameter literals. `parts` holds the constructor's input
descriptions for certificate relocation only; `machine` caches the compiled
universal interpreter (never serialized, never hashed).
"""
struct SamplerDescription
    code::Quoted{:SamplerMachine}
    term::Any
    field_size::Int
    field_law::Any
    level::Int
    level_law::Any
    typing::Union{Untyped,Typed}
    dimension_law::Any
    query_time::Any
    description_size::Int
    dependency_set::Set{Any}
    k_law::Any
    parts::Tuple
    evidence::Any
    machine::Ref{Any}
end

"DESIGN 9.1's DeciderDescription: a total (typed) predicate's canonical code with its TIME/length laws."
struct DeciderDescription
    code::Quoted{:TotalPredicate}
    term::Any
    typing::Union{Untyped,Typed}
    time_bound::Any
    question_length::Any
    answer_length::Any
    description_size::Int
    dependency_set::Set{Any}
    B_law::Any
    k_law::Any
    parts::Tuple
end

"definitions.md H: a field-aligned (sampler, decider) pair; typed samplers pair with typed deciders over the same type set."
struct VerifierDescription
    sampler::SamplerDescription
    decider::DeciderDescription
    function VerifierDescription(sampler::SamplerDescription, decider::DeciderDescription)
        (sampler.typing isa Untyped) == (decider.typing isa Untyped) ||
            throw(ArgumentError("a typed sampler pairs with a typed decider"))
        sampler.typing isa Typed && sampler.typing.labels != decider.typing.labels &&
            throw(ArgumentError("sampler and decider type sets differ"))
        new(sampler, decider)
    end
end

canonical_bytes(S::SamplerDescription) = S.code.bytes
canonical_bytes(D::DeciderDescription) = D.code.bytes
description_size(S::SamplerDescription) = S.description_size
description_size(D::DeciderDescription) = D.description_size
quote_hash(S::SamplerDescription) = quote_hash(canonical_bytes(S))
quote_hash(D::DeciderDescription) = quote_hash(canonical_bytes(D))
dependency_set(S::SamplerDescription) = S.dependency_set
dependency_set(D::DeciderDescription) = D.dependency_set
"description_length of a VerifierDescription is def:normal-form's |V| = max{|S|, |D|}."
description_length(V::VerifierDescription) = max(description_size(V.sampler), description_size(V.decider))
Base.show(io::IO, S::SamplerDescription) =
    print(io, "SamplerDescription(", S.term[1], ", q=", S.field_size, ", level=", S.level,
          ", ", S.typing isa Untyped ? "untyped" : "typed($(TypeCount(S.typing)))",
          ", |S|=", S.description_size, ")")
Base.show(io::IO, D::DeciderDescription) =
    print(io, "DeciderDescription(", D.term[1], ", |D|=", D.description_size, ")")

# ---------------------------------------------------------------------------
# Serialization of sampler terms.

const SAMPLER_HEADER = 0xC3
const _SAMPLER_TAGS = Dict(:Pair => 0x01, :TypedFamily => 0x02, :DirectSum => 0x03,
                           :Repeat => 0x04, :Anchor => 0x05, :Detype => 0x06,
                           :Product => 0x07, :Downsize => 0x08,
                           :Pauli => 0x09, :Intro => 0x0A, :Graph => 0x0B)
const _SAMPLER_TAG_NAMES = Dict(byte => tag for (tag, byte) in _SAMPLER_TAGS)

_field_width(q::Int) = cld(round(Int, log2(q)), 8)
_field_type(q::Int) = (F = get(_DESCRIPTION_FIELDS, q, nothing);
                       F === nothing && throw(ArgumentError("no field of size $q is registered")); F)

function _encode_label!(buffer::IOBuffer, label::String)
    bytes = codeunits(label)
    _encode_int!(buffer, length(bytes))
    write(buffer, bytes)
end
function _decode_label!(buffer::IOBuffer)
    count = _decode_int!(buffer)
    bytesavailable(buffer) >= count || throw(ArgumentError("truncated description"))
    String(read(buffer, count))
end

function _encode_typing!(buffer::IOBuffer, labels::Vector{String}, edges::Vector{Tuple{Int,Int}})
    _encode_int!(buffer, length(labels))
    foreach(label -> _encode_label!(buffer, label), labels)
    _encode_int!(buffer, length(edges))
    for (i, j) in edges
        write(buffer, hton(UInt16(i)))
        write(buffer, hton(UInt16(j)))
    end
end
function _decode_typing!(buffer::IOBuffer)
    labels = String[_decode_label!(buffer) for _ in 1:_decode_int!(buffer)]
    count = _decode_int!(buffer)
    bytesavailable(buffer) >= 4count || throw(ArgumentError("truncated description"))
    edges = Tuple{Int,Int}[(Int(ntoh(read(buffer, UInt16))), Int(ntoh(read(buffer, UInt16)))) for _ in 1:count]
    labels, edges
end

function _encode_sampler_term!(buffer::IOBuffer, term)
    tag = term[1]
    write(buffer, _SAMPLER_TAGS[tag])
    if tag == :Pair
        q = term[2]
        _encode_int!(buffer, q)
        _encode_term!(buffer, term[3], _field_width(q))
        _encode_term!(buffer, term[4], _field_width(q))
    elseif tag == :TypedFamily
        q = term[2]
        _encode_int!(buffer, q)
        _encode_typing!(buffer, term[3], term[4])
        for (left, right) in term[5]
            _encode_term!(buffer, left, _field_width(q))
            _encode_term!(buffer, right, _field_width(q))
        end
    elseif tag == :DirectSum
        _encode_int!(buffer, length(term[2]))
        foreach(child -> _encode_sampler_term!(buffer, child), term[2])
    elseif tag == :Repeat
        foreach(v -> _encode_int!(buffer, v), term[2:5])
        _encode_sampler_term!(buffer, term[6])
    elseif tag in (:Anchor, :Detype, :Downsize)
        _encode_sampler_term!(buffer, term[2])
    elseif tag == :Product
        _encode_sampler_term!(buffer, term[2])
        _encode_sampler_term!(buffer, term[3])
    elseif tag == :Pauli
        foreach(v -> _encode_int!(buffer, v), term[2:4])
    elseif tag == :Intro
        foreach(v -> _encode_int!(buffer, v), term[2:6])
    elseif tag == :Graph
        _encode_typing!(buffer, term[2], term[3])
    else
        throw(ArgumentError("unknown sampler term"))
    end
    buffer
end

function _decode_sampler_term!(buffer::IOBuffer)
    bytesavailable(buffer) >= 1 || throw(ArgumentError("truncated description"))
    tag = get(_SAMPLER_TAG_NAMES, read(buffer, UInt8), nothing)
    tag === nothing && throw(ArgumentError("unknown sampler description tag"))
    if tag == :Pair
        q = _decode_int!(buffer)
        width = _field_width(q)
        return (:Pair, q, _decode_term!(buffer, width), _decode_term!(buffer, width))
    elseif tag == :TypedFamily
        q = _decode_int!(buffer)
        width = _field_width(q)
        labels, edges = _decode_typing!(buffer)
        maps = Tuple{Any,Any}[(_decode_term!(buffer, width), _decode_term!(buffer, width)) for _ in labels]
        return (:TypedFamily, q, labels, edges, maps)
    elseif tag == :DirectSum
        count = _decode_int!(buffer)
        return (:DirectSum, Any[_decode_sampler_term!(buffer) for _ in 1:count])
    elseif tag == :Repeat
        values = [_decode_int!(buffer) for _ in 1:4]
        return (:Repeat, values..., _decode_sampler_term!(buffer))
    elseif tag == :Product
        left = _decode_sampler_term!(buffer)
        return (:Product, left, _decode_sampler_term!(buffer))
    elseif tag == :Pauli
        return (:Pauli, [_decode_int!(buffer) for _ in 1:3]...)
    elseif tag == :Intro
        return (:Intro, [_decode_int!(buffer) for _ in 1:5]...)
    elseif tag == :Graph
        labels, edges = _decode_typing!(buffer)
        return (:Graph, labels, edges)
    else
        return (tag, _decode_sampler_term!(buffer))
    end
end

function sampler_term_bytes(term)
    buffer = IOBuffer()
    write(buffer, SAMPLER_HEADER)
    _encode_sampler_term!(buffer, term)
    take!(buffer)
end

"Decode canonical sampler-description bytes to the term; trailing bytes are refused."
function decode_sampler_term(bytes::AbstractVector{UInt8})
    buffer = IOBuffer(Vector{UInt8}(bytes))
    (bytesavailable(buffer) >= 1 && read(buffer, UInt8) == SAMPLER_HEADER) ||
        throw(ArgumentError("not a canonical sampler description"))
    term = _decode_sampler_term!(buffer)
    bytesavailable(buffer) == 0 || throw(ArgumentError("trailing description bytes"))
    term
end

# The children of a term (embedded descriptions) and its leaf test.
_term_children(term) = term[1] == :DirectSum ? term[2] :
                       term[1] == :Repeat ? Any[term[6]] :
                       term[1] == :Product ? Any[term[2], term[3]] :
                       term[1] in (:Anchor, :Detype, :Downsize) ? Any[term[2]] : Any[]
_is_leaf(term) = term[1] in (:Pair, :TypedFamily, :Pauli, :Intro, :Graph)

"""
    dependency_walk(bytes) :: Set

DESIGN 9.2: the dependency set read off the bytes. A leaf description is its
own content (`:S`); a composite depends on the canonical hash of every leaf
description it embeds and on the parameter SYMBOLS it carries (`:lambda`,
`:tau`, `:c_prime` for a repetition -- the symbols, not their values, so
lambda = 1 and lambda = 2 share one dependency set while their bytes
differ; gt-11-parallel-repetition.tex:L257 names the parameters, and c' is
a universal constant the executable additionally encodes; verdicts/tb5-r1.md
O10), never on a decider.
"""
function dependency_walk(bytes::AbstractVector{UInt8})
    term = decode_sampler_term(bytes)
    _is_leaf(term) && return Set{Any}([:S])
    found = Set{Any}()
    _dependency_walk!(found, term)
    found
end
function _dependency_walk!(found::Set{Any}, term)
    if _is_leaf(term)
        push!(found, quote_hash(sampler_term_bytes(term)))
        return found
    end
    term[1] == :Repeat && push!(found, :lambda, :tau, :c_prime)
    foreach(child -> _dependency_walk!(found, child), _term_children(term))
    found
end
