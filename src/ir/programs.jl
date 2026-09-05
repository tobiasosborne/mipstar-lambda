# DESIGN.md section 1.1: the program and description sort. An explicitly
# represented, phase-separated calculus: de Bruijn variables, typed holes,
# lambda, application, Fix, If, bounded primitives, Quote, fuel-bounded Eval
# and Specialize. Only two representations are IR values (DD-1): Quoted{A}
# (canonical bytes of a closed term) and CircuitIR. A runtime Closure is a
# value, never a description. The canonical serialization is the SAME
# encoding family as src/samplers/cl.jl's describe_cl (header byte, tagged
# nodes, UInt32 big-endian integer fields via _encode_int!/_decode_int!,
# count-prefixed children); 0xC1 is a CL description, 0xC2 a program.
#
# This is the IMPLEMENTED instantiation of the analytic document's L
# (part2a section 8), not its constants (verdicts/tb3-r1.md N3, option b):
# integers are fixed-width 4-byte fields and |d| is a BYTE count, where
# def:l-serialization uses a nu prefix code and counts bits; the CEK charge
# table folds context navigation (pushing/popping a frame, returning a
# value) into the following charged contraction, where part2a 8.3 charges
# each administrative transition one unit. The Fix unfolding charge c_Y = 3
# is the analytic one.

abstract type Program end

abstract type BoundExpr end
"Concrete primitive cost/size bound (definitions.md F: BoundExpr)."
struct Concrete <: BoundExpr
    value::Int
end
"Opaque theorem bound: printed, never assigned an invented exponent."
struct Opaque <: BoundExpr
    description::String
    parameters::Tuple{Vararg{Symbol}}
end

abstract type Fuel end
struct FuelLiteral <: Fuel
    value::Int
end
# FuelBound(n, lambda) evaluates to n^lambda (def:lambda, gt-12:435-440),
# both operands of sort Nat (DESIGN 1.1; definitions.md F). When n^lambda
# exceeds the host integer the inner budget is taken as not below the
# remaining ambient fuel: the run then ends in OutOfFuel if it needs more,
# never in SortError.
struct FuelBound <: Fuel
    n::Program
    lambda::Program
end

# A primitive name is finite serializable data: a registered operator
# (Symbol) or a literal: Bool (`Prim(true, Concrete(1), ())` of DESIGN 1.1),
# natural (Int) or bit string (Vector{Bool}).
const PrimName = Union{Symbol,Bool,Int,Vector{Bool}}

struct BoundVar <: Program
    depth::Int
    slot::Int
end
struct Hole <: Program
    name::Symbol
    sort::Symbol
end
struct Lambda <: Program
    arity::Int
    body::Program
end
struct Apply <: Program
    head::Program
    args::Tuple{Vararg{Program}}
end
struct If <: Program
    condition::Program
    then_branch::Program
    else_branch::Program
end
struct Prim <: Program
    name::PrimName
    bound::BoundExpr
    args::Tuple{Vararg{Program}}
end
struct Eval <: Program
    code::Program
    args::Tuple{Vararg{Program}}
    fuel::Fuel
end
struct Specialize <: Program
    code::Program
    env::Tuple{Vararg{Pair{Symbol,Program}}}
end

# Quote is a checked constructor: only Closed(P) (every BoundVar scoped, no
# Hole) may become syntax-as-value. `sort` is the A of Quoted{A}, checked
# against the term's shape by `_admits_sort` (declared sorts below).
struct Quote <: Program
    code::Program
    sort::Symbol
    function Quote(code::Program, sort::Symbol=:Decider)
        is_closed(code) || throw(ArgumentError("Quote requires a closed term"))
        _check_sort(code, sort)
        new(code, sort)
    end
end

# Fix(P) requires the distinguished hole self_code : Quoted{A} exactly once,
# no other hole and no free variable; it ties self_code to Quote(Fix(P), A)
# and is closed syntax of sort A (DESIGN 1.1). The hole's declared sort A
# must admit the body's shape, so a Decider fixed point has a five-argument
# Lambda body; `Program` is the unchecked top sort.
struct Fix <: Program
    body::Program
    sort::Symbol
    function Fix(body::Program)
        holes(body) == Dict(:self_code => 1) ||
            throw(ArgumentError("Fix requires exactly one self_code hole"))
        is_scoped(body, Int[]) ||
            throw(ArgumentError("Fix body must have no free variable"))
        sort = only(hole for hole in _hole_nodes(body) if hole.name == SELF_CODE).sort
        _check_sort(body, sort)
        new(body, sort)
    end
end

const SELF_CODE = :self_code

"YCode(P) = Fix(P): the description-level fixed point of analytic part2a 10.2 (C18), closing the single self_code hole at the constant runtime charge c_Y = 3 rather than materialising Specialize(P, {self_code -> d_P})."
YCode(body::Program) = Fix(body)

# ---------------------------------------------------------------------------
# Declared sorts (DESIGN 1.1, definitions.md F). A sort names the shape a
# closed term must have; `Program` admits every term. Sorts are checked when
# a term becomes a description (Quote, quote_program, specialize, Fix) and
# when a code value is evaluated (only function sorts may be applied).

# :Level (verdicts/tb3-r2.md N17) is the compression-level datum of
# definitions.md F, a Nat literal by shape; Compress's second argument is
# lambda : P{Nat} (DESIGN 1.1), so a Level literal never reaches FuelBound.
const DECLARED_SORTS = (:Program, :Decider, :Compressor, :Sampler, :MachineDesc,
                        :Pair, :Nat, :Bit, :Bits, :Level)
const FUNCTION_SORTS = (:Program, :Decider, :Compressor, :Sampler)

# A MachineDesc literal is the bit string of a one-tape machine over {0,1}
# with S >= 1 states: entry (state s, symbol b) at bit offset 4(2s+b) is
# (write, move right?, next_hi, next_lo); next >= S halts. Start state 0,
# blank tape, head at 0.
_is_machine_desc(bits::Vector{Bool}) = length(bits) >= 8 && length(bits) % 8 == 0

_literal(p::Program, ::Type{T}) where {T} = p isa Prim && p.name isa T && isempty(p.args)

function _admits_sort(p::Program, sort::Symbol)
    sort == :Program && return true
    sort == :Decider && return (p isa Lambda && p.arity == DECIDER_ARITY) ||
                              (p isa Fix && _admits_sort(p.body, sort))
    sort == :Compressor && return (p isa Lambda && p.arity == 2) ||
                                 (p isa Fix && _admits_sort(p.body, sort))
    sort == :Sampler && return (p isa Lambda && p.arity >= 1) ||
                              (p isa Fix && _admits_sort(p.body, sort))
    sort == :MachineDesc && return _literal(p, Vector{Bool}) && _is_machine_desc(p.name)
    sort == :Pair && return p isa Prim && p.name == :quoted_pair && length(p.args) == 2 &&
                            all(arg -> arg isa Quote, p.args)
    sort == :Nat && return _literal(p, Int)
    sort == :Level && return _literal(p, Int) && p.name >= 1
    sort == :Bit && return _literal(p, Bool)
    sort == :Bits && return _literal(p, Vector{Bool})
    false
end

function _check_sort(p::Program, sort::Symbol)
    sort in DECLARED_SORTS || throw(ArgumentError("undeclared sort $(sort)"))
    _admits_sort(p, sort) || throw(ArgumentError("term does not have sort $(sort)"))
    p
end

const DECIDER_ARITY = 5
# R9 (verdicts/design-r4.md): Lambda binders carry no sorts in the IR; a
# Decider's five arguments (n, x, y, a, b) of def:decider (gt-05:613-622)
# are checked as VALUES at the evaluator entry by `decider_input_sorted`.
const DECIDER_ARGUMENT_SORTS = (:Nat, :Bits, :Bits, :Bits, :Bits)
_value_has_sort(v, sort::Symbol) =
    sort == :Nat ? (v isa Int && v >= 0) :
    sort == :Bits ? v isa Vector{Bool} :
    sort == :Bit ? v isa Bool : false
"The runtime tuple u matches DECIDER_ARGUMENT_SORTS (n : Nat, x y a b : Bits)."
decider_input_sorted(u::Tuple) = length(u) == DECIDER_ARITY &&
    all(_value_has_sort(u[i], DECIDER_ARGUMENT_SORTS[i]) for i in 1:DECIDER_ARITY)

# ---------------------------------------------------------------------------
# Scope and holes.

_children(p::BoundVar) = ()
_children(p::Hole) = ()
_children(p::Lambda) = (p.body,)
_children(p::Apply) = (p.head, p.args...)
_children(p::Fix) = (p.body,)
_children(p::If) = (p.condition, p.then_branch, p.else_branch)
_children(p::Prim) = p.args
_children(p::Quote) = (p.code,)
_children(p::Eval) = (p.code, p.args..., _fuel_terms(p.fuel)...)
_children(p::Specialize) = (p.code, map(last, p.env)...)
_fuel_terms(::FuelLiteral) = ()
_fuel_terms(f::FuelBound) = (f.n, f.lambda)

"Every BoundVar addresses an existing (depth, slot) under `binders` (arities, innermost first)."
function is_scoped(p::Program, binders::Vector{Int})
    if p isa BoundVar
        return 0 <= p.depth < length(binders) && 0 <= p.slot < binders[p.depth + 1]
    elseif p isa Lambda
        return is_scoped(p.body, vcat(p.arity, binders))
    elseif p isa Quote
        return true # checked closed by its constructor, in its own scope
    end
    all(child -> is_scoped(child, binders), _children(p))
end

"Hole occurrence counts, with Fix binding its own self_code."
function holes(p::Program)
    counts = Dict{Symbol,Int}()
    _holes!(counts, p)
    counts
end
function _holes!(counts::Dict{Symbol,Int}, p::Program)
    if p isa Hole
        counts[p.name] = get(counts, p.name, 0) + 1
    elseif p isa Fix
        inner = holes(p.body)
        delete!(inner, SELF_CODE)
        for (name, count) in inner
            counts[name] = get(counts, name, 0) + count
        end
    elseif p isa Quote
        return counts
    else
        for child in _children(p)
            _holes!(counts, child)
        end
    end
    counts
end

is_closed(p::Program) = is_scoped(p, Int[]) && isempty(holes(p))

"Capture-free substitution of holes; inserted terms are closed, so no index shifts."
function substitute(p::Program, env::Dict{Symbol,Program})
    if p isa Hole
        return haskey(env, p.name) ? env[p.name] : p
    elseif p isa BoundVar
        return p
    elseif p isa Lambda
        return Lambda(p.arity, substitute(p.body, env))
    elseif p isa Apply
        return Apply(substitute(p.head, env), map(a -> substitute(a, env), p.args))
    elseif p isa Fix
        # self_code is bound by Fix, never a specialization hole: the
        # environment passes through to the body without it (DESIGN 1.1).
        inner = copy(env)
        delete!(inner, SELF_CODE)
        return Fix(substitute(p.body, inner))
    elseif p isa If
        return If(substitute(p.condition, env), substitute(p.then_branch, env),
                  substitute(p.else_branch, env))
    elseif p isa Prim
        return Prim(p.name, p.bound, map(a -> substitute(a, env), p.args))
    elseif p isa Quote
        return p
    elseif p isa Eval
        fuel = p.fuel isa FuelLiteral ? p.fuel :
               FuelBound(substitute(p.fuel.n, env), substitute(p.fuel.lambda, env))
        return Eval(substitute(p.code, env), map(a -> substitute(a, env), p.args), fuel)
    end
    Specialize(substitute(p.code, env),
               Tuple(name => substitute(term, env) for (name, term) in p.env))
end

# ---------------------------------------------------------------------------
# Canonical serialization (the cl.jl family).

const _PROGRAM_TAGS = Dict(
    :BoundVar => 0x20, :Hole => 0x21, :Lambda => 0x22, :Apply => 0x23,
    :Fix => 0x24, :If => 0x25, :Prim => 0x26, :Quote => 0x27, :Eval => 0x28,
    :Specialize => 0x29, :Concrete => 0x30, :Opaque => 0x31,
    :FuelLiteral => 0x32, :FuelBound => 0x33,
    :NameSymbol => 0x40, :NameNat => 0x41, :NameBits => 0x42, :NameBool => 0x43)
const _PROGRAM_TAG_NAMES = Dict(byte => tag for (tag, byte) in _PROGRAM_TAGS)
const PROGRAM_HEADER = 0xC2

function _encode_symbol!(buffer::IOBuffer, name::Symbol)
    bytes = codeunits(String(name))
    _encode_int!(buffer, length(bytes))
    write(buffer, bytes)
end

function _encode_bits!(buffer::IOBuffer, bits::Vector{Bool})
    _encode_int!(buffer, length(bits))
    for bit in bits
        write(buffer, UInt8(bit))
    end
end

function _encode_children!(buffer::IOBuffer, children)
    _encode_int!(buffer, length(children))
    for child in children
        _encode_program!(buffer, child)
    end
end

function _encode_bound!(buffer::IOBuffer, bound::BoundExpr)
    if bound isa Concrete
        write(buffer, _PROGRAM_TAGS[:Concrete])
        _encode_int!(buffer, bound.value)
    else
        write(buffer, _PROGRAM_TAGS[:Opaque])
        bytes = codeunits(bound.description)
        _encode_int!(buffer, length(bytes))
        write(buffer, bytes)
        _encode_int!(buffer, length(bound.parameters))
        for parameter in bound.parameters
            _encode_symbol!(buffer, parameter)
        end
    end
end

function _encode_fuel!(buffer::IOBuffer, fuel::Fuel)
    if fuel isa FuelLiteral
        write(buffer, _PROGRAM_TAGS[:FuelLiteral])
        _encode_int!(buffer, fuel.value)
    else
        write(buffer, _PROGRAM_TAGS[:FuelBound])
        _encode_program!(buffer, fuel.n)
        _encode_program!(buffer, fuel.lambda)
    end
end

function _encode_name!(buffer::IOBuffer, name::PrimName)
    if name isa Symbol
        write(buffer, _PROGRAM_TAGS[:NameSymbol])
        _encode_symbol!(buffer, name)
    elseif name isa Bool
        write(buffer, _PROGRAM_TAGS[:NameBool])
        write(buffer, UInt8(name))
    elseif name isa Int
        write(buffer, _PROGRAM_TAGS[:NameNat])
        _encode_int!(buffer, name)
    else
        write(buffer, _PROGRAM_TAGS[:NameBits])
        _encode_bits!(buffer, name)
    end
end

function _encode_program!(buffer::IOBuffer, p::Program)
    if p isa BoundVar
        write(buffer, _PROGRAM_TAGS[:BoundVar])
        _encode_int!(buffer, p.depth)
        _encode_int!(buffer, p.slot)
        _encode_children!(buffer, ())
    elseif p isa Hole
        write(buffer, _PROGRAM_TAGS[:Hole])
        _encode_symbol!(buffer, p.name)
        _encode_symbol!(buffer, p.sort)
        _encode_children!(buffer, ())
    elseif p isa Lambda
        write(buffer, _PROGRAM_TAGS[:Lambda])
        _encode_int!(buffer, p.arity)
        _encode_children!(buffer, (p.body,))
    elseif p isa Apply
        write(buffer, _PROGRAM_TAGS[:Apply])
        _encode_children!(buffer, (p.head, p.args...))
    elseif p isa Fix
        write(buffer, _PROGRAM_TAGS[:Fix])
        _encode_children!(buffer, (p.body,))
    elseif p isa If
        write(buffer, _PROGRAM_TAGS[:If])
        _encode_children!(buffer, (p.condition, p.then_branch, p.else_branch))
    elseif p isa Prim
        write(buffer, _PROGRAM_TAGS[:Prim])
        _encode_name!(buffer, p.name)
        _encode_bound!(buffer, p.bound)
        _encode_children!(buffer, p.args)
    elseif p isa Quote
        write(buffer, _PROGRAM_TAGS[:Quote])
        _encode_symbol!(buffer, p.sort)
        _encode_children!(buffer, (p.code,))
    elseif p isa Eval
        write(buffer, _PROGRAM_TAGS[:Eval])
        _encode_fuel!(buffer, p.fuel)
        _encode_children!(buffer, (p.code, p.args...))
    else
        write(buffer, _PROGRAM_TAGS[:Specialize])
        _encode_int!(buffer, length(p.env))
        for (name, term) in p.env
            _encode_symbol!(buffer, name)
            _encode_program!(buffer, term)
        end
        _encode_children!(buffer, (p.code,))
    end
    buffer
end

"Canonical bytes of one term (open terms included); no header."
function term_bytes(p::Program)
    buffer = IOBuffer()
    _encode_program!(buffer, p)
    take!(buffer)
end
term_size(p::Program) = length(term_bytes(p))
program_equal(a::Program, b::Program) = term_bytes(a) == term_bytes(b)

function _decode_symbol!(buffer::IOBuffer)
    count = _decode_int!(buffer)
    bytesavailable(buffer) >= count || throw(ArgumentError("truncated description"))
    Symbol(String(read(buffer, count)))
end

function _decode_bits!(buffer::IOBuffer)
    count = _decode_int!(buffer)
    bytesavailable(buffer) >= count || throw(ArgumentError("truncated description"))
    Bool[read(buffer, UInt8) != 0 for _ in 1:count]
end

function _decode_tag!(buffer::IOBuffer)
    bytesavailable(buffer) >= 1 || throw(ArgumentError("truncated description"))
    tag = get(_PROGRAM_TAG_NAMES, read(buffer, UInt8), nothing)
    tag === nothing && throw(ArgumentError("unknown program tag"))
    tag
end

function _decode_children!(buffer::IOBuffer)
    count = _decode_int!(buffer)
    Program[_decode_program!(buffer) for _ in 1:count]
end

function _expect_children(children, count)
    length(children) == count || throw(ArgumentError("wrong child count"))
    children
end

function _decode_bound!(buffer::IOBuffer)
    tag = _decode_tag!(buffer)
    tag == :Concrete && return Concrete(_decode_int!(buffer))
    tag == :Opaque || throw(ArgumentError("expected a bound"))
    count = _decode_int!(buffer)
    bytesavailable(buffer) >= count || throw(ArgumentError("truncated description"))
    description = String(read(buffer, count))
    parameters = Tuple(_decode_symbol!(buffer) for _ in 1:_decode_int!(buffer))
    Opaque(description, parameters)
end

function _decode_fuel!(buffer::IOBuffer)
    tag = _decode_tag!(buffer)
    tag == :FuelLiteral && return FuelLiteral(_decode_int!(buffer))
    tag == :FuelBound || throw(ArgumentError("expected a fuel expression"))
    n = _decode_program!(buffer)
    FuelBound(n, _decode_program!(buffer))
end

function _decode_name!(buffer::IOBuffer)
    tag = _decode_tag!(buffer)
    tag == :NameSymbol && return _decode_symbol!(buffer)
    if tag == :NameBool
        bytesavailable(buffer) >= 1 || throw(ArgumentError("truncated description"))
        return read(buffer, UInt8) != 0
    end
    tag == :NameNat && return _decode_int!(buffer)
    tag == :NameBits || throw(ArgumentError("expected a primitive name"))
    _decode_bits!(buffer)
end

function _decode_program!(buffer::IOBuffer)
    tag = _decode_tag!(buffer)
    if tag == :BoundVar
        depth = _decode_int!(buffer)
        slot = _decode_int!(buffer)
        _expect_children(_decode_children!(buffer), 0)
        return BoundVar(depth, slot)
    elseif tag == :Hole
        name = _decode_symbol!(buffer)
        sort = _decode_symbol!(buffer)
        _expect_children(_decode_children!(buffer), 0)
        return Hole(name, sort)
    elseif tag == :Lambda
        arity = _decode_int!(buffer)
        return Lambda(arity, only(_expect_children(_decode_children!(buffer), 1)))
    elseif tag == :Apply
        children = _decode_children!(buffer)
        isempty(children) && throw(ArgumentError("Apply without a head"))
        return Apply(children[1], Tuple(children[2:end]))
    elseif tag == :Fix
        return Fix(only(_expect_children(_decode_children!(buffer), 1)))
    elseif tag == :If
        children = _expect_children(_decode_children!(buffer), 3)
        return If(children[1], children[2], children[3])
    elseif tag == :Prim
        name = _decode_name!(buffer)
        bound = _decode_bound!(buffer)
        return Prim(name, bound, Tuple(_decode_children!(buffer)))
    elseif tag == :Quote
        sort = _decode_symbol!(buffer)
        return Quote(only(_expect_children(_decode_children!(buffer), 1)), sort)
    elseif tag == :Eval
        fuel = _decode_fuel!(buffer)
        children = _decode_children!(buffer)
        isempty(children) && throw(ArgumentError("Eval without code"))
        return Eval(children[1], Tuple(children[2:end]), fuel)
    end
    count = _decode_int!(buffer)
    env = Tuple((_decode_symbol!(buffer) => _decode_program!(buffer)) for _ in 1:count)
    Specialize(only(_expect_children(_decode_children!(buffer), 1)), env)
end

"Inverse of `term_bytes`."
function decode_term(bytes::AbstractVector{UInt8})
    buffer = IOBuffer(Vector{UInt8}(bytes))
    term = _decode_program!(buffer)
    bytesavailable(buffer) == 0 || throw(ArgumentError("trailing description bytes"))
    term
end

# ---------------------------------------------------------------------------
# Quoted{A}: canonical bytes of a closed program of sort A.

struct Quoted{A}
    bytes::Vector{UInt8}
end

canonical_bytes(q::Quoted) = q.bytes
description_size(q::Quoted) = length(q.bytes)
sort_of(::Quoted{A}) where {A} = A

function _quoted_bytes(p::Program, sort::Symbol)
    buffer = IOBuffer()
    write(buffer, PROGRAM_HEADER)
    _encode_symbol!(buffer, sort)
    _encode_program!(buffer, p)
    take!(buffer)
end

"Decode canonical program bytes (header, sort, term) to the program."
function decode_program(bytes::AbstractVector{UInt8})
    buffer = IOBuffer(Vector{UInt8}(bytes))
    (bytesavailable(buffer) >= 1 && read(buffer, UInt8) == PROGRAM_HEADER) ||
        throw(ArgumentError("not a canonical program description"))
    _decode_symbol!(buffer)
    term = _decode_program!(buffer)
    bytesavailable(buffer) == 0 || throw(ArgumentError("trailing description bytes"))
    term
end
decode_program(q::Quoted) = decode_program(q.bytes)
program(q::Quoted) = decode_program(q.bytes)

"FNV-1a 64-bit digest of the canonical bytes, as 16 hex digits."
function quote_hash(bytes::AbstractVector{UInt8})
    digest = 0xcbf29ce484222325
    for byte in bytes
        digest = (digest ⊻ UInt64(byte)) * 0x00000100000001b3
    end
    string(digest; base=16, pad=16)
end
quote_hash(q::Quoted) = quote_hash(q.bytes)

# Front-end certificates are bound by identity to the object they were
# built for, the discipline of `_bind_certificate` in src/verifiers/pcp.jl
# (verdicts/tb3-r1.md N2): a CHECKED node replays only when the attached
# term IS its subject; a downstream constructor relocates its child's
# subtree so the subject is reached through the constructor chain
# (PaddedSuccinctDecoupled5SAT.source -> SuccinctDecoupled5SAT.source ->
# Succinct3SAT.trace -> BoundedTrace.program). Anything else, a tampered
# copy of the same type included, is refused with :certificate_binding.
function _bound_replay(subject, rule::Symbol, replay::Function)
    x -> x === subject ? replay(subject) :
         CheckResult(false, :certificate_binding; location=rule,
                     expected=:attached_component,
                     actual=(x === nothing ? :unreachable : :borrowed))
end

function _relocate(node::CertNode, locate::Function)
    children = map(child -> _relocate(child, locate), node.children)
    replay = node.grade == CHECKED ? (x -> node.replay(locate(x))) : node.replay
    CertNode(node.grade, node.rule; facts=node.facts, children, replay)
end

function _replay_quote(q::Quoted)
    decoded = try
        decode_program(q.bytes)
    catch error
        error isa ArgumentError || rethrow()
        return CheckResult(false, :quote_roundtrip; expected=:decodable,
                           actual=sprint(showerror, error))
    end
    ok = is_closed(decoded) && _admits_sort(decoded, sort_of(q)) &&
         _quoted_bytes(decoded, sort_of(q)) == q.bytes &&
         description_size(q) == length(q.bytes)
    CheckResult(ok, :quote_roundtrip;
                expected=(closed=true, sort=sort_of(q), size=length(q.bytes)),
                actual=(closed=is_closed(decoded), sort=_admits_sort(decoded, sort_of(q)),
                        size=description_size(q)))
end

function _quote_certificate(q::Quoted{A}) where {A}
    CertNode(CHECKED, :Quote;
        facts=(display="|D| = $(description_size(q)) bytes; fnv1a64 = $(quote_hash(q)); sort = $(A)",),
        replay=_bound_replay(q, :Quote, _replay_quote))
end

"quote_program(p; sort) :: Checked{Quoted{sort}, ScopeAndSizeCert} (DESIGN 2)."
function quote_program(p::Program; sort::Symbol=:Decider)
    is_closed(p) || throw(ArgumentError("quote_program requires a closed term"))
    _check_sort(p, sort)
    q = Quoted{sort}(_quoted_bytes(p, sort))
    Checked(q, _quote_certificate(q))
end

"specialize(p, env) :: Checked{Quoted, SubstCert}: total, sort-agnostic hole substitution."
function specialize(p::Program, env::Tuple; sort::Symbol=:Decider)
    all(binding -> binding isa Pair{Symbol,<:Program}, env) ||
        throw(ArgumentError("a static environment maps hole names to programs"))
    env = Tuple(Pair{Symbol,Program}(name, term) for (name, term) in env)
    counts = holes(p)
    all(count == 1 for count in values(counts)) ||
        throw(ArgumentError("affine-hole discipline: a hole name occurs at most once"))
    names = Set(map(first, env))
    length(names) == length(env) || throw(ArgumentError("duplicate binding"))
    names == Set(keys(counts)) ||
        throw(ArgumentError("environment must cover exactly the remaining holes"))
    for (name, term) in env
        is_closed(term) || throw(ArgumentError("replacement for $name is not closed"))
    end
    result = substitute(p, Dict{Symbol,Program}(env...))
    is_closed(result) || throw(ArgumentError("specialization did not close the term"))
    _check_sort(result, sort)
    q = Quoted{sort}(_quoted_bytes(result, sort))
    # The exact size identity of part2a Lemma specialization: the encoding
    # has no ancestor length fields, so each replaced hole trades its own
    # node bytes for the inserted term's bytes.
    expected = term_size(p) -
               sum(term_size(hole) for hole in _hole_nodes(p); init=0) +
               sum(term_size(term) for (_, term) in env; init=0)
    # verdicts/tb4-r1.md O14: the replay is bound to this Quoted (a borrowed
    # Quoted is :certificate_binding) and recomputes the substitution, so a
    # closed term of the same byte length does not pass on size alone.
    bindings = Dict{Symbol,Program}(env...)
    node = CertNode(CHECKED, :Specialize;
        facts=(display="|P| = $(term_size(p)); holes = $(length(env)); |result| = $(term_size(result)); |D| = $(description_size(q)) bytes",),
        replay=_bound_replay(q, :Specialize, quoted -> begin
            decoded = decode_program(quoted.bytes)
            actual = term_size(decoded)
            CheckResult(actual == expected && is_closed(decoded) &&
                        program_equal(decoded, substitute(p, bindings)),
                        :specialize_size_law; location=:Specialize, expected=expected, actual=actual)
        end))
    Checked(q, node)
end

function _hole_nodes(p::Program)
    found = Hole[]
    _hole_nodes!(found, p)
    found
end
function _hole_nodes!(found::Vector{Hole}, p::Program)
    if p isa Hole
        push!(found, p)
    elseif p isa Fix
        for hole in _hole_nodes(p.body)
            hole.name == SELF_CODE || push!(found, hole)
        end
    elseif !(p isa Quote)
        for child in _children(p)
            _hole_nodes!(found, child)
        end
    end
    found
end

# ---------------------------------------------------------------------------
# Runtime values and results. Closure is a value (DD-1): never a description.

struct Closure
    arity::Int
    body::Program
    env::Vector{Vector{Any}}
end
"Syntax pointer produced by Quote: the closed program and its sort."
struct Code
    program::Program
    sort::Symbol
end
struct Value
    value::Any
end
struct OutOfFuel
    used::Int
end
"The TypeError outcome of DESIGN 1.1 (named SortError: Core.TypeError is taken)."
struct SortError
    reason::Symbol
end
"Host guard only (never part of the semantics): the hard step cap fired."
struct Aborted
    reason::Symbol
end

quote_program(::Closure; kwargs...) =
    throw(ArgumentError("a runtime closure is a value, not a description (DD-1)"))

# Ground values are encoded in the same family; |enc(u)| is their byte size.
function _encode_value!(buffer::IOBuffer, value)
    if value isa Bool
        write(buffer, 0x50)
        write(buffer, UInt8(value))
    elseif value isa Int
        write(buffer, 0x51)
        _encode_int!(buffer, value)
    elseif value isa Vector{Bool}
        write(buffer, 0x52)
        _encode_bits!(buffer, value)
    elseif value isa Code
        write(buffer, 0x53)
        bytes = _quoted_bytes(value.program, value.sort)
        _encode_int!(buffer, length(bytes))
        write(buffer, bytes)
    else
        throw(ArgumentError("value is not encodable: $(typeof(value))"))
    end
    buffer
end

function encoded_size(values::Tuple)
    buffer = IOBuffer()
    for value in values
        _encode_value!(buffer, value)
    end
    buffer.size
end

_code_size(code::Code) = length(_quoted_bytes(code.program, code.sort))

"h(d,u) = 3 + |d| + |enc(u)| (C16; analytic part2a Theorem quote-eval)."
eval_overhead(q::Quoted, values::Tuple) = 3 + description_size(q) + encoded_size(values)

# ---------------------------------------------------------------------------
# Primitive registry: name => (arity, charge, implementation). The charge
# kappa_p is an Int or a function of the argument values (part2a 8.3:
# `Prim(p, B, v_1..v_r)` costs exactly kappa_p(v_1..v_r) >= 1). The
# implementation returns `nothing` on a contract failure (SortError).

function _same_ground(a, b)
    (a isa Bool && b isa Bool) || (a isa Int && b isa Int) ||
        (a isa Vector{Bool} && b isa Vector{Bool})
end

# The machine model of a MachineDesc literal (see `_is_machine_desc`):
# simulate at most `budget` steps from state 0 on the blank tape; returns
# (halted, steps taken).
function _simulate_machine(bits::Vector{Bool}, budget::Int)
    state_count = length(bits) ÷ 8
    tape = Dict{Int,Bool}()
    head = 0
    state = 0
    for step in 1:budget
        symbol = get(tape, head, false)
        offset = 4 * (2 * state + Int(symbol))
        write, right = bits[offset + 1], bits[offset + 2]
        next = 2 * Int(bits[offset + 3]) + Int(bits[offset + 4])
        tape[head] = write
        head += right ? 1 : -1
        next >= state_count && return (true, step)
        state = next
    end
    (false, budget)
end

_halts_within(machine, n) =
    (machine isa Vector{Bool} && _is_machine_desc(machine) && n isa Int && n >= 0) ?
        _simulate_machine(machine, n)[1] : nothing
# The declared bound Opaque("n steps", (n,)) of DESIGN 1.1: one unit per
# simulated step plus one.
_halts_within_charge(machine, n) =
    (machine isa Vector{Bool} && _is_machine_desc(machine) && n isa Int && n >= 0) ?
        1 + _simulate_machine(machine, n)[2] : 1

# quoted_pair joins two code values without capture: the pair's own code is
# the term `quoted_pair(Quote(a), Quote(b))` of sort Pair, which evaluates
# to itself. fst_code/snd_code project it.
_quoted_pair(a, b) =
    (a isa Code && b isa Code) ?
        Code(Prim(:quoted_pair, Concrete(1), (Quote(a.program, a.sort), Quote(b.program, b.sort))), :Pair) :
        nothing
_pair_component(pair, index::Int) =
    (pair isa Code && _admits_sort(pair.program, :Pair)) ?
        (quoted = pair.program.args[index]; Code(quoted.code, quoted.sort)) : nothing

const PRIMITIVES = Dict{Symbol,Tuple{Int,Any,Function}}(
    :not => (1, 1, v -> v isa Bool ? !v : nothing),
    :and => (2, 1, (a, b) -> (a isa Bool && b isa Bool) ? (a && b) : nothing),
    :or => (2, 1, (a, b) -> (a isa Bool && b isa Bool) ? (a || b) : nothing),
    :eq => (2, 1, (a, b) -> _same_ground(a, b) ? (a == b) : nothing),
    :lt => (2, 1, (a, b) -> (a isa Int && b isa Int) ? (a < b) : nothing),
    :add => (2, 1, (a, b) -> (a isa Int && b isa Int) ? (a + b) : nothing),
    :sub => (2, 1, (a, b) -> (a isa Int && b isa Int) ? max(a - b, 0) : nothing),
    :length => (1, 1, v -> v isa Vector{Bool} ? length(v) : nothing),
    :bit => (2, 1, (v, i) -> (v isa Vector{Bool} && i isa Int && 0 <= i < length(v)) ? v[i + 1] : nothing),
    :halts_within => (2, _halts_within_charge, _halts_within),
    :quoted_pair => (2, 1, _quoted_pair),
    :fst_code => (1, 1, pair -> _pair_component(pair, 1)),
    :snd_code => (1, 1, pair -> _pair_component(pair, 2)),
)

_charge_of(charge::Int, values) = charge
_charge_of(charge, values) = charge(values...)::Int

function _primitive(name::PrimName)
    name isa Bool && return (0, 1, () -> name)
    name isa Int && return (0, 1, () -> name)
    name isa Vector{Bool} && return (0, 1, () -> copy(name))
    get(PRIMITIVES, name, nothing)
end

# ---------------------------------------------------------------------------
# The deterministic call-by-value CEK machine (analytic part2a 8.3): charged
# contractions are BoundVar lookup, closure creation, beta, If selection,
# Prim (its charge), Quote, Fix unfolding (c_Y = 3), Eval front end h(d,u),
# and Specialize; evaluation-context navigation (pushing/popping frames,
# returning a value) is folded into the same transition, which is where
# this instantiation is cheaper than part2a 8.3 (verdicts/tb3-r1.md N3).
# One `step!` is one charged transition, so a bounded trace has one row per
# fuel unit spent. `Aborted(:hard_cap)` is a host guard outside the
# semantics: it fires only when the count of host steps (charged or not)
# exceeds `hard_cap`, and the entry points require `hard_cap >= fuel`.

struct Ret
    value::Any
end

mutable struct SeqFrame
    kind::Symbol
    pending::Vector{Program}
    env::Vector{Vector{Any}}
    values::Vector{Any}
    tail::Vector{Any}
    node::Any
end

struct IfFrame
    then_branch::Program
    else_branch::Program
    env::Vector{Vector{Any}}
end

"An Eval delimiter: the inner budget is exhausted once the ambient usage reaches `limit`."
struct Delimiter
    limit::Int
end

mutable struct Machine
    control::Any
    env::Vector{Vector{Any}}
    kont::Vector{Any}
    limits::Vector{Int}
    fuel::Int
    initial_fuel::Int
    used::Int
    halted::Any
    steps::Int
    hard_cap::Int
end

const DEFAULT_HARD_CAP = 1_000_000

"Direct evaluation state eval(t, u; f): t with an application continuation on the values u."
function machine_for_apply(p::Program, args::Tuple, fuel::Int; hard_cap::Int=DEFAULT_HARD_CAP)
    m = Machine(p, Vector{Any}[], Any[], Int[], fuel, fuel, 0, nothing, 0, hard_cap)
    isempty(args) ||
        push!(m.kont, SeqFrame(:apply, Program[p], Vector{Any}[], Any[], collect(Any, args), nothing))
    m
end

"Body-level state: the decider body with its argument frame installed (bounded_trace's rows)."
function machine_for_body(p::Lambda, args::Tuple, fuel::Int; hard_cap::Int=DEFAULT_HARD_CAP)
    length(args) == p.arity || throw(ArgumentError("argument count does not match the binder arity"))
    Machine(p.body, Vector{Any}[collect(Any, args)], Any[], Int[], fuel, fuel, 0, nothing, 0, hard_cap)
end

# Charge k units against the ambient budget and every enclosing Eval
# delimiter; exhausting any of them halts with OutOfFuel (DD-2).
function _charge!(m::Machine, k::Int)
    if !isempty(m.limits) && m.used + k > m.limits[end]
        consumed = m.limits[end] - m.used
        m.used += consumed
        m.fuel -= consumed
        m.halted = OutOfFuel(m.used)
        return false
    end
    if m.fuel < k
        m.used = m.initial_fuel
        m.fuel = 0
        m.halted = OutOfFuel(m.used)
        return false
    end
    m.fuel -= k
    m.used += k
    true
end

function _type_error!(m::Machine, reason::Symbol)
    _charge!(m, 1) || return false
    m.halted = SortError(reason)
    false
end

function _fix_unfold(fix::Fix)
    substitute(fix.body, Dict{Symbol,Program}(SELF_CODE => Quote(fix, fix.sort)))
end

# FuelBound(n, lambda) = n^lambda; `nothing` only for ill-sorted operands.
# An overflowing power stands for a budget beyond any ambient fuel
# (typemax), which the Eval contraction clamps to the remaining ambient
# fuel: exhausting it is OutOfFuel, never SortError.
function _fuel_value(fuel::Fuel, values)
    fuel isa FuelLiteral && return fuel.value
    n, lambda = values
    (n isa Int && lambda isa Int && n >= 0 && lambda >= 0) || return nothing
    (n <= 1 || lambda == 0) && return n^lambda
    lambda * log2(n) > 62 && return typemax(Int)
    n^lambda
end

function _contract_sequence!(m::Machine, frame::SeqFrame)
    values = frame.values
    if frame.kind == :apply
        head = values[1]
        args = values[2:end]
        head isa Closure || return _type_error!(m, :apply_non_closure)
        head.arity == length(args) || return _type_error!(m, :apply_arity)
        _charge!(m, 1) || return false
        m.env = vcat([args], head.env)
        m.control = head.body
        return true
    elseif frame.kind == :prim
        node = frame.node::Prim
        registered = _primitive(node.name)
        registered === nothing && return _type_error!(m, :unknown_primitive)
        arity, declared_charge, implementation = registered
        length(values) == arity || return _type_error!(m, :primitive_arity)
        result = implementation(values...)
        result === nothing && return _type_error!(m, :primitive_contract)
        charge = _charge_of(declared_charge, values)
        node.bound isa Concrete && node.bound.value < charge &&
            return _type_error!(m, :primitive_bound)
        _charge!(m, charge) || return false
        m.control = Ret(result)
        return true
    elseif frame.kind == :eval
        node = frame.node::Eval
        code = values[1]
        code isa Code || return _type_error!(m, :eval_non_code)
        code.sort in FUNCTION_SORTS || return _type_error!(m, :eval_sort)
        count = length(node.args)
        args = values[2:1 + count]
        all(v -> v isa Bool || v isa Int || v isa Vector{Bool} || v isa Code, args) ||
            return _type_error!(m, :eval_argument)
        inner = _fuel_value(node.fuel, values[2 + count:end])
        inner === nothing && return _type_error!(m, :eval_fuel)
        overhead = 3 + _code_size(code) + encoded_size(Tuple(args))
        _charge!(m, overhead) || return false
        inner = min(inner, m.fuel)
        # The delimiter's limit is the ambient usage at which the inner
        # budget is exhausted; the stack keeps the running minimum so a
        # charge checks every enclosing delimiter in O(1).
        limit = m.used + inner
        push!(m.limits, isempty(m.limits) ? limit : min(limit, m.limits[end]))
        push!(m.kont, Delimiter(limit))
        isempty(args) ||
            push!(m.kont, SeqFrame(:apply, Program[code.program], Vector{Any}[], Any[], args, nothing))
        m.env = Vector{Any}[]
        m.control = code.program
        return true
    end
    node = frame.node::Specialize
    code = values[1]
    code isa Code || return _type_error!(m, :specialize_non_code)
    all(v -> v isa Code, values[2:end]) || return _type_error!(m, :specialize_environment)
    env = Tuple(name => (values[1 + i]::Code).program for (i, (name, _)) in enumerate(node.env))
    specialized = try
        specialize(code.program, env; sort=code.sort)
    catch error
        error isa ArgumentError || rethrow()
        return _type_error!(m, occursin("sort", error.msg) ? :specialize_sort : :specialize_coverage)
    end
    charge = 1 + term_size(code.program) + sum(term_size(term) for (_, term) in env; init=0)
    _charge!(m, charge) || return false
    m.control = Ret(Code(decode_program(specialized.term), code.sort))
    true
end

"One charged transition; returns false when the machine has halted."
function step!(m::Machine)
    m.halted === nothing || return false
    while true
        m.steps += 1
        if m.steps > m.hard_cap
            m.halted = Aborted(:hard_cap)
            return false
        end
        c = m.control
        if c isa Ret
            if isempty(m.kont)
                m.halted = Value(c.value)
                return false
            end
            frame = m.kont[end]
            if frame isa Delimiter
                pop!(m.kont)
                pop!(m.limits)
                continue
            elseif frame isa IfFrame
                pop!(m.kont)
                condition = c.value
                condition isa Bool || return _type_error!(m, :if_condition)
                _charge!(m, 1) || return false
                m.env = frame.env
                m.control = condition ? frame.then_branch : frame.else_branch
                return true
            end
            push!(frame.values, c.value)
            if length(frame.values) < length(frame.pending)
                m.env = frame.env
                m.control = frame.pending[length(frame.values) + 1]
                continue
            end
            pop!(m.kont)
            append!(frame.values, frame.tail)
            return _contract_sequence!(m, frame)
        elseif c isa BoundVar
            (c.depth < length(m.env) && c.slot < length(m.env[c.depth + 1])) ||
                return _type_error!(m, :unbound_variable)
            _charge!(m, 1) || return false
            m.control = Ret(m.env[c.depth + 1][c.slot + 1])
            return true
        elseif c isa Lambda
            _charge!(m, 1) || return false
            m.control = Ret(Closure(c.arity, c.body, m.env))
            return true
        elseif c isa Hole
            return _type_error!(m, :residual_hole)
        elseif c isa Quote
            _charge!(m, 1) || return false
            m.control = Ret(Code(c.code, c.sort))
            return true
        elseif c isa Fix
            # c_Y = 3 (part2a 8.3, C18): the unfolding with its binding.
            _charge!(m, 3) || return false
            m.control = _fix_unfold(c)
            return true
        elseif c isa If
            push!(m.kont, IfFrame(c.then_branch, c.else_branch, m.env))
            m.control = c.condition
            continue
        elseif c isa Apply
            push!(m.kont, SeqFrame(:apply, Program[c.head, c.args...], m.env, Any[], Any[], c))
            m.control = c.head
            continue
        elseif c isa Prim
            if isempty(c.args)
                return _contract_sequence!(m, SeqFrame(:prim, Program[], m.env, Any[], Any[], c))
            end
            push!(m.kont, SeqFrame(:prim, Program[c.args...], m.env, Any[], Any[], c))
            m.control = c.args[1]
            continue
        elseif c isa Eval
            pending = Program[c.code, c.args..., _fuel_terms(c.fuel)...]
            push!(m.kont, SeqFrame(:eval, pending, m.env, Any[], Any[], c))
            m.control = pending[1]
            continue
        elseif c isa Specialize
            pending = Program[c.code, map(last, c.env)...]
            push!(m.kont, SeqFrame(:specialize, pending, m.env, Any[], Any[], c))
            m.control = pending[1]
            continue
        end
        m.halted = SortError(:unknown_control)
        return false
    end
end

function run!(m::Machine)
    while step!(m)
    end
    (; result=m.halted, used=m.used)
end

"eval(t, u; f): Value, OutOfFuel or SortError with the fuel used; never a host exception."
function eval_program(p::Program, args::Tuple, fuel::Int; hard_cap::Int=DEFAULT_HARD_CAP)
    fuel >= 0 || throw(ArgumentError("fuel must be a natural number"))
    hard_cap >= fuel || throw(ArgumentError("the host step cap must be at least the fuel"))
    run!(machine_for_apply(p, args, fuel; hard_cap))
end

"Eval_L(d, u; f) on canonical bytes: charges h(d,u), then runs eval(t, u; f - h)."
function eval_quoted(q::Quoted, args::Tuple, fuel::Int; hard_cap::Int=DEFAULT_HARD_CAP)
    fuel >= 0 || throw(ArgumentError("fuel must be a natural number"))
    hard_cap >= fuel || throw(ArgumentError("the host step cap must be at least the fuel"))
    overhead = eval_overhead(q, args)
    fuel < overhead && return (; result=OutOfFuel(fuel), used=fuel)
    inner = run!(machine_for_apply(decode_program(q), args, fuel - overhead; hard_cap))
    (; result=inner.result, used=inner.used + overhead)
end

# ---------------------------------------------------------------------------
# Verifier[QuestionLength, AnswerLength, Runtime, Gap, Levels] (DESIGN 1.6,
# definitions.md F): the minimal carrier reachable from Quoted -- the
# payload (sampler, decider) as descriptions of the declared sorts, the four
# symbolic measures, and the CL level count. Gap is a directed implication
# between value thresholds (completeness, soundness). TB4 fills the
# transformations; this record only fixes the sorts.

struct Verifier
    sampler::Quoted{:Sampler}
    decider::Quoted{:Decider}
    question_length::BoundExpr
    answer_length::BoundExpr
    runtime::BoundExpr
    gap::Tuple{BoundExpr,BoundExpr}
    levels::Int
    function Verifier(sampler::Quoted, decider::Quoted, question_length::BoundExpr,
                      answer_length::BoundExpr, runtime::BoundExpr,
                      gap::Tuple{BoundExpr,BoundExpr}, levels::Int)
        sort_of(sampler) == :Sampler ||
            throw(ArgumentError("a Verifier's sampler must be Quoted{Sampler}, got Quoted{$(sort_of(sampler))}"))
        sort_of(decider) == :Decider ||
            throw(ArgumentError("a Verifier's decider must be Quoted{Decider}, got Quoted{$(sort_of(decider))}"))
        levels >= 1 || throw(ArgumentError("a Verifier has at least one CL level"))
        new(sampler, decider, question_length, answer_length, runtime, gap, levels)
    end
end

description_size(v::Verifier) = description_size(v.sampler) + description_size(v.decider)
"|V| = max{|S|, |D|}, the description length of a normal form verifier (gt-05:626-635; def:lambda gt-05:641-653)."
description_length(v::Verifier) = max(description_size(v.sampler), description_size(v.decider))

# ---------------------------------------------------------------------------
# Printing.

function program_label(p::Program)
    p isa BoundVar && return "BoundVar($(p.depth),$(p.slot))"
    p isa Hole && return "Hole($(p.name):$(p.sort))"
    p isa Lambda && return "Lambda($(p.arity), ...)"
    p isa Apply && return "Apply(...)"
    p isa Fix && return "Fix(...)"
    p isa If && return "If(...)"
    p isa Prim && return "Prim($(p.name isa Vector{Bool} ? join(Int.(p.name)) : p.name))"
    p isa Quote && return "Quote(...)"
    p isa Eval && return "Eval(...)"
    "Specialize(...)"
end

function value_label(v)
    v isa Bool && return string(v)
    v isa Int && return string(v)
    v isa Vector{Bool} && return "[" * join(Int.(v)) * "]"
    v isa Code && return "Code(" * quote_hash(_quoted_bytes(v.program, v.sort)) * ")"
    v isa Closure && return "Closure($(v.arity))"
    string(v)
end

Base.show(io::IO, v::Value) = print(io, "Value(", value_label(v.value), ")")
Base.show(io::IO, ::MIME"text/plain", q::Quoted{A}) where {A} =
    print(io, "Quoted{", A, "}(", description_size(q), " bytes, ", quote_hash(q), ")")
