"""A verifier term which accepts exactly when its nullary predicate is true."""
struct Test{P}
    pred::P
end

"""A prover-message term.  The continuation maps the supplied value to a term."""
struct Ask{K}
    k::K
end

"""A verifier term which selects either child with equal probability."""
struct Coin{L,R}
    t1::L
    t2::R
end


const ExactProbability = Rational{BigInt}
const EXACT_ZERO = BigInt(0) // BigInt(1)
const EXACT_ONE = BigInt(1) // BigInt(1)
const EXACT_HALF = BigInt(1) // BigInt(2)

"""
    FiniteContinuation(domain, next, honest, fixed, cache_key, label)

The data carried by an `Ask`: its finite choice set, continuation, honest move,
claim's left endpoint (used by the mutation suite), memoization key, and a
human-readable label.  `Ask` itself still has exactly the advertised `Ask(k)`
shape.
"""
struct FiniteContinuation{D,F,H,X,K}
    domain::D
    next::F
    honest::H
    fixed::X
    cache_key::K
    label::String
end

(k::FiniteContinuation)(z) = k.next(z)

"""The direct level-zero predicate `y == f(x)`, represented as data."""
struct DirectPredicate{F,X,Y}
    f::F
    x::X
    y::Y
end

(pred::DirectPredicate)() = pred.y == pred.f(pred.x)

"""Apply `f` exactly `steps` times."""
function iterate_function(f, x, steps::Integer)
    steps < 0 && throw(ArgumentError("steps must be nonnegative"))
    result = x
    remaining = BigInt(steps)
    while remaining > 0
        result = f(result)
        remaining -= 1
    end
    return result
end


# A concrete, typed fixed point.  `FixedPoint(body)(state)` unfolds to
# `body(FixedPoint(body), state)`, which is the operational content of the
# handoff's Y-term without Julia macros, Exprs, or self-recursive source code.
struct FixedPoint{F}
    body::F
end


(fixed::FixedPoint)(state) = fixed.body(fixed, state)
y_fixed_point(body) = FixedPoint(body)

struct MidpointClaim{X,Y}
    x::X
    y::Y
    n::Int
end

struct MidpointYTerm{F,D}
    f::F
    domain::D
end

function (body::MidpointYTerm)(self, claim::MidpointClaim)
    (; x, y, n) = claim
    if n == 0
        return Test(DirectPredicate(body.f, x, y))
    end

    half_steps = BigInt(1) << (n - 1)
    honest_midpoint = iterate_function(body.f, x, half_steps)
    next = z -> Coin(
        self(MidpointClaim(x, z, n - 1)),
        self(MidpointClaim(z, y, n - 1)),
    )
    continuation = FiniteContinuation(
        body.domain,
        next,
        honest_midpoint,
        x,
        (:midpoint_claim, x, y, n),
        "z for level-$n claim",
    )
    return Ask(continuation)
end

"""
    midpoint_protocol(f, domain, x, y, n)

Construct the explicit level-`n` midpoint verifier term for `y = f^(2^n)(x)`.
The finite `domain` is precisely the set maximized over at each `Ask`.
"""
function midpoint_protocol(f, domain, x, y, n::Integer)
    n < 0 && throw(ArgumentError("n must be nonnegative"))
    choices = collect(domain)
    isempty(choices) && throw(ArgumentError("domain must be nonempty"))
    unfold = y_fixed_point(MidpointYTerm(f, choices))
    return unfold(MidpointClaim(x, y, Int(n)))
end


_probability(value::Bool) = value ? EXACT_ONE : EXACT_ZERO

function _checked_choice(k::FiniteContinuation, prover)
    choice = prover(k)
    any(candidate -> candidate == choice, k.domain) ||
        throw(ArgumentError("prover choice is outside the finite domain"))
    return choice
end


_value(term::Test, prover) = _probability(Bool(term.pred()))

function _value(term::Ask, prover)
    choice = _checked_choice(term.k, prover)
    return _value(term.k(choice), prover)
end


function _value(term::Coin, prover)
    left = _value(term.t1, prover)
    right = _value(term.t2, prover)
    return (left + right) / BigInt(2)
end


"""Evaluate a term exactly against a deterministic prover strategy."""
value(term, prover)::ExactProbability = _value(term, prover)

"""The honest midpoint move recorded in each continuation."""
honest_prover(k::FiniteContinuation) = k.honest


_optval(term::Test, cache) = _probability(Bool(term.pred()))

function _optval(term::Coin, cache)
    left = _optval(term.t1, cache)
    right = _optval(term.t2, cache)
    return (left + right) / BigInt(2)
end


function _maximize_ask(term::Ask, cache)
    choices = term.k.domain
    isempty(choices) && throw(ArgumentError("Ask has an empty domain"))
    best = EXACT_ZERO
    first_choice = true
    for choice in choices
        candidate = _optval(term.k(choice), cache)
        if first_choice || candidate > best
            best = candidate
            first_choice = false
        end
    end
    return best
end


function _optval(term::Ask, cache)
    key = term.k.cache_key
    if key !== nothing && haskey(cache, key)
        return cache[key]
    end
    result = _maximize_ask(term, cache)
    key !== nothing && (cache[key] = result)
    return result
end


"""
    optval(term)

Compute the exact optimal prover value.  Every `Ask` is maximized over its
finite domain and every `Coin` is averaged in `Rational{BigInt}` arithmetic.
"""
function optval(term)::ExactProbability
    return _optval(term, Dict{Any,ExactProbability}())
end


"""Return the honest value for the true level-`n` claim (perfect completeness)."""
function completeness(f, x, n::Integer)::ExactProbability
    n < 0 && throw(ArgumentError("n must be nonnegative"))
    total_steps = BigInt(1) << n
    true_y = iterate_function(f, x, total_steps)

    # The orbit prefix is a sufficient finite domain for every honest midpoint
    # encountered along this particular true claim.
    orbit = Any[x]
    point = x
    for _ in BigInt(1):total_steps
        point = f(point)
        any(candidate -> candidate == point, orbit) || push!(orbit, point)
    end
    term = midpoint_protocol(f, orbit, x, true_y, n)
    return value(term, honest_prover)
end


"""Exact value of `r` independent copies, accepted only if all accept."""
function amplified_optval(term, r::Integer)::ExactProbability
    r < 0 && throw(ArgumentError("r must be nonnegative"))
    return optval(term)^r
end

"""Least `r` such that `p^r <= 1/2`."""
function repetitions_to_half(p::ExactProbability)::Int
    (p < EXACT_ZERO || p >= EXACT_ONE) &&
        throw(ArgumentError("p must satisfy 0 <= p < 1"))
    product = EXACT_ONE
    repetitions = 0
    while product > EXACT_HALF
        product *= p
        repetitions += 1
    end
    return repetitions
end


function _predicate_text(pred)
    return "predicate"
end

function _predicate_text(pred::DirectPredicate)
    return "$(repr(pred.y)) == f($(repr(pred.x)))"
end


function _pretty(io::IO, term::Test, depth::Int)
    println(io, repeat("  ", depth), "Test(", _predicate_text(term.pred), ")")
end


function _pretty(io::IO, term::Ask, depth::Int)
    pad = repeat("  ", depth)
    println(io, pad, "Ask(", term.k.label, ")")
    println(io, pad, "  honest trace chooses ", repr(term.k.honest))
    _pretty(io, term.k(term.k.honest), depth + 1)
end


function _pretty(io::IO, term::Coin, depth::Int)
    pad = repeat("  ", depth)
    println(io, pad, "Coin(1/2, 1/2)")
    println(io, pad, "  branch 1:")
    _pretty(io, term.t1, depth + 2)
    println(io, pad, "  branch 2:")
    _pretty(io, term.t2, depth + 2)
end


"""Print an honest-choice expansion of an explicit protocol term."""
pretty(io::IO, term) = _pretty(io, term, 0)

"""Return `pretty(io, term)` as a string."""
pretty(term) = sprint(io -> pretty(io, term))
