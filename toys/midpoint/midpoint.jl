"""A verifier term which accepts exactly when its nullary predicate is true."""
struct Test{P}
    pred::P
end

"""A prover-message term. The continuation maps the supplied value to a term."""
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
    FiniteContinuation(domain, next)

The complete data carried by an `Ask`: its finite choice set and continuation.
In particular, this contains neither an honest witness nor evaluator state.
"""
mutable struct FiniteContinuation{D,F}
    domain::D
    next::F
end

(k::FiniteContinuation)(z) = k.next(z)

"""A deterministic prover strategy, kept separate from the protocol term."""
struct Strategy{F}
    choose::F
end

(strategy::Strategy)(k::FiniteContinuation) = strategy.choose(k)

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

"""The orbit list `(x, f(x), ..., f^(2^n)(x))`, with repetitions retained."""
function orbit_prefix(f, x, n::Integer)
    n < 0 && throw(ArgumentError("n must be nonnegative"))
    result = Any[x]
    point = x
    for _ in BigInt(1):(BigInt(1) << n)
        point = f(point)
        push!(result, point)
    end
    return result
end

"""Whether the sharp orbit-prefix hypothesis holds for this finite domain."""
function orbit_prefix_in_domain(f, domain, x, n::Integer)
    choices = collect(domain)
    return all(point -> any(candidate -> candidate == point, choices),
               orbit_prefix(f, x, n))
end


# A concrete call-by-value (Z-style) fixed point. `FixedPoint(body)(state)`
# unfolds to `body(FixedPoint(body), state)`. The memo only hash-conses the
# finite term DAG; it is construction state, not data stored in any term node.
struct FixedPoint{F,M}
    body::F
    memo::M
end

function (fixed::FixedPoint)(state)
    key = (state.x, state.y, state.n)
    return get!(fixed.memo, key) do
        fixed.body(fixed, state)
    end
end

z_fixed_point(body) = FixedPoint(body, Dict{Any,Any}())

struct MidpointState{F,D,X,Y}
    f::F
    domain::D
    x::X
    y::Y
    n::Int
end

struct MidpointYTerm end

# This argument list literally exposes `(self, f, domain, x, y, n)`, mirroring
# the handoff's fixed-point body rather than capturing `f` and `domain` in it.
function (::MidpointYTerm)(self, state::MidpointState)
    (; f, domain, x, y, n) = state
    if n == 0
        return Test(DirectPredicate(f, x, y))
    end

    ask_domain = domain
    next = z -> Coin(
        self(MidpointState(f, domain, x, z, n - 1)),
        self(MidpointState(f, domain, z, y, n - 1)),
    )
    return Ask(FiniteContinuation(ask_domain, next))
end

function _validated_choices(f, domain, x, y, n::Integer)
    n < 0 && throw(ArgumentError("n must be nonnegative"))
    choices = collect(domain)
    isempty(choices) && throw(ArgumentError("domain must be nonempty"))
    any(candidate -> candidate == x, choices) ||
        throw(ArgumentError("x must belong to the domain"))
    any(candidate -> candidate == y, choices) ||
        throw(ArgumentError("y must belong to the domain"))
    orbit_prefix_in_domain(f, choices, x, n) ||
        throw(ArgumentError("orbit prefix through f^(2^n)(x) must lie in the domain"))
    return choices
end

"""
    midpoint_protocol(f, domain, x, y, n)

Construct the explicit level-`n` midpoint verifier term for `y = f^(2^n)(x)`.
The finite `domain` is precisely the set offered at every `Ask`. Construction
requires `x,y` and the orbit prefix `{f^k(x): 0 <= k <= 2^n}` to lie in it.
"""
function midpoint_protocol(f, domain, x, y, n::Integer)
    choices = _validated_choices(f, domain, x, y, n)
    unfold = z_fixed_point(MidpointYTerm())
    return unfold(MidpointState(f, choices, x, y, Int(n)))
end


_probability(value::Bool) = ExactProbability(value)

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


_optval(term::Test, cache) = _probability(Bool(term.pred()))

function _optval(term::Coin, cache)
    left = _optval(term.t1, cache)
    right = _optval(term.t2, cache)
    return (left + right) / BigInt(2)
end

function _maximize_ask(term::Ask, cache)
    isempty(term.k.domain) && throw(ArgumentError("Ask has an empty domain"))
    return maximum(choice -> _optval(term.k(choice), cache), term.k.domain)
end

function _optval(term::Ask, cache)
    key = term.k
    haskey(cache, key) && return cache[key]
    result = _maximize_ask(term, cache)
    cache[key] = result
    return result
end

"""
    optval(term)

Compute the exact optimal prover value. Every `Ask` is maximized over its
finite domain and every `Coin` is averaged in `Rational{BigInt}` arithmetic.
The memo is evaluator-owned and keyed by continuation identity.
"""
function optval(term)::ExactProbability
    return _optval(term, IdDict{Any,ExactProbability}())
end


function _honest_strategy_walk!(moves, seen, term::Test, f, x, y, n)
    n == 0 || error("Test encountered above level zero")
    return nothing
end

function _honest_strategy_walk!(moves, seen, term::Ask, f, x, y, n)
    n > 0 || error("Ask encountered at level zero")
    haskey(seen, term.k) && return nothing
    seen[term.k] = true
    half_steps = BigInt(1) << (n - 1)
    choice = iterate_function(f, x, half_steps)
    moves[term.k] = choice
    child = term.k(choice)
    child isa Coin || error("midpoint Ask continuation did not produce Coin")
    _honest_strategy_walk!(moves, seen, child.t1, f, x, choice, n - 1)
    _honest_strategy_walk!(moves, seen, child.t2, f, choice, y, n - 1)
    return nothing
end

"""Build the honest midpoint strategy separately from an existing term."""
function honest_strategy(term, f, x, y, n::Integer)
    moves = IdDict{Any,Any}()
    seen = IdDict{Any,Bool}()
    _honest_strategy_walk!(moves, seen, term, f, x, y, Int(n))
    return Strategy(k -> get(moves, k) do
        throw(ArgumentError("strategy has no move for this Ask node"))
    end)
end

"""Return the honest value for the true level-`n` claim."""
function completeness(f, x, n::Integer)::ExactProbability
    true_y = iterate_function(f, x, BigInt(1) << n)
    domain = unique(orbit_prefix(f, x, n))
    term = midpoint_protocol(f, domain, x, true_y, n)
    return value(term, honest_strategy(term, f, x, true_y, n))
end


"""
    sequential_and_optval(f, domain, x, y, n, r)

Exact adaptive cross-copy DP for sequential AND repetition. Copy `i+1` begins
only after copy `i` accepts; at every reached `Ask`, maximization occurs after
the complete earlier-copy transcript. Verifier coins in the new copy are fresh.
"""
function sequential_and_optval(f, domain, x, y, n::Integer, r::Integer)::ExactProbability
    r < 0 && throw(ArgumentError("r must be nonnegative"))
    r == 0 && return EXACT_ONE
    choices = _validated_choices(f, domain, x, y, n)
    level = Int(n)
    copies = Int(r)
    memo = Dict{Any,ExactProbability}()

    function game_value(current_x, current_y, current_n::Int, copies_after::Int)
        key = (current_x, current_y, current_n, copies_after)
        haskey(memo, key) && return memo[key]
        result = if current_n == 0
            if current_y == f(current_x)
                copies_after == 0 ? EXACT_ONE : game_value(x, y, level, copies_after - 1)
            else
                EXACT_ZERO
            end
        else
            maximum(choices) do z
                (game_value(current_x, z, current_n - 1, copies_after) +
                 game_value(z, current_y, current_n - 1, copies_after)) / BigInt(2)
            end
        end
        memo[key] = result
        return result
    end

    return game_value(x, y, level, copies - 1)
end

"""Least `r` such that `p^r <= 1/2`, computed with exact rationals."""
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


_predicate_text(pred) = "predicate"
_predicate_text(pred::DirectPredicate) = "$(repr(pred.y)) == f($(repr(pred.x)))"

function _pretty(io::IO, term::Test, prover, depth::Int)
    println(io, repeat("  ", depth), "Test(", _predicate_text(term.pred), ")")
end

function _pretty(io::IO, term::Ask, prover, depth::Int)
    pad = repeat("  ", depth)
    choice = _checked_choice(term.k, prover)
    println(io, pad, "Ask(z in ", repr(term.k.domain), ")")
    println(io, pad, "  strategy chooses ", repr(choice))
    _pretty(io, term.k(choice), prover, depth + 1)
end

function _pretty(io::IO, term::Coin, prover, depth::Int)
    pad = repeat("  ", depth)
    println(io, pad, "Coin(1/2, 1/2)")
    println(io, pad, "  branch 1:")
    _pretty(io, term.t1, prover, depth + 2)
    println(io, pad, "  branch 2:")
    _pretty(io, term.t2, prover, depth + 2)
end

"""Print the expansion selected by a separate prover strategy."""
pretty(io::IO, term, prover) = _pretty(io, term, prover, 0)
pretty(term, prover) = sprint(io -> pretty(io, term, prover))


function _transcript_profiles(term::Test, cache)
    return Set([(0, 0, 1)])
end

function _transcript_profiles(term::Coin, cache)
    profiles = union(_transcript_profiles(term.t1, cache),
                     _transcript_profiles(term.t2, cache))
    return Set((asks, coins + 1, tests) for (asks, coins, tests) in profiles)
end

function _transcript_profiles(term::Ask, cache)
    haskey(cache, term.k) && return cache[term.k]
    profiles = Set{Tuple{Int,Int,Int}}()
    for choice in term.k.domain
        for (asks, coins, tests) in _transcript_profiles(term.k(choice), cache)
            push!(profiles, (asks + 1, coins, tests))
        end
    end
    cache[term.k] = profiles
    return profiles
end

"""All `(Ask, Coin, Test)` counts among root-to-leaf transcripts."""
transcript_profiles(term) =
    _transcript_profiles(term, IdDict{Any,Set{Tuple{Int,Int,Int}}}())

"""Number of `Ask` rounds when every transcript has the same shape."""
function rounds(term)::Int
    counts = Set(first(profile) for profile in transcript_profiles(term))
    length(counts) == 1 || throw(ArgumentError("term has nonuniform round counts"))
    return only(counts)
end

"""Number of direct `Test` queries when every transcript has the same shape."""
function queries(term)::Int
    counts = Set(last(profile) for profile in transcript_profiles(term))
    length(counts) == 1 || throw(ArgumentError("term has nonuniform query counts"))
    return only(counts)
end
