# DESIGN 9.2: QuotedLaw{Nat} is a closed term in a small law language, not a
# BoundExpr: an Int, a symbol (`n`, `q_i`, `ell_i`, `lambda`, `tau`,
# `c_prime`, `TypeCount`) or a call among `+ - * ^ max div log2`, a child law
# `s_i(n)`, `C_i(n)`, `TIME_i(n)`, `Q_i(n)`, `A_i(n)`, or the repetition laws
# `k(n)`, `B(n)`. `O(...)` marks an asymptotic bound whose constant the
# source does not expose: it is CITED and never evaluated (DD-24).

"Evaluate a law exactly (Int/Rational/BigInt) in `env`; an unbound symbol or an O(...) is an ArgumentError."
function evaluate_law(law, env::AbstractDict{Symbol,Any})
    law isa Integer && return law
    law isa Rational && return law
    if law isa Symbol
        haskey(env, law) || throw(ArgumentError("unbound law symbol $(law)"))
        return env[law]
    end
    (law isa Expr && law.head == :call) || throw(ArgumentError("law is not a call: $(law)"))
    f = law.args[1]
    f == :O && throw(ArgumentError("O(...) is an opaque asymptotic bound (CITED, not evaluable)"))
    if f in (:+, :*, :-, :max, :div, :^, :log2)
        values = [evaluate_law(a, env) for a in law.args[2:end]]
        f == :+ && return sum(values)
        f == :* && return prod(values)
        f == :- && return length(values) == 1 ? -values[1] : values[1] - sum(values[2:end])
        f == :max && return maximum(values)
        f == :div && return div(values...)
        if f == :log2
            v = values[1]
            (v isa Integer && v > 0 && ispow2(v)) || throw(ArgumentError("log2 of a non-power of two"))
            return Int(log2(v))
        end
        base, exponent = values
        exponent >= 0 || throw(ArgumentError("negative exponent"))
        return _exact_power(base, exponent)
    end
    haskey(env, f) || throw(ArgumentError("unbound law function $(f)"))
    env[f]([evaluate_law(a, env) for a in law.args[2:end]]...)
end

# base^exponent for a rational exponent p/q, decided on the VALUE (DESIGN
# 10.2: "valid only when this expression denotes a positive integer";
# verdicts/tb5-r1.md O3): the exact integer q-th root of base^p when it
# exists (9^(3/2) = 27 is admitted), otherwise an ArgumentError naming the
# actual quantity; never a rounded exponent.
function _exact_power(base, exponent)
    exponent isa Rational || return big(base)^exponent
    isinteger(exponent) && return big(base)^Int(exponent)
    p, q = numerator(exponent), denominator(exponent)
    (base isa Integer && base >= 1) || throw(ArgumentError("a rational power needs a positive integer base, got $(base)^$(exponent)"))
    power = big(base)^p
    root = _integer_root(power, q)
    root === nothing && throw(ArgumentError("k(n) = $(base)^($(p)/$(q)) is not a positive integer: $(power) has no exact integer $(q)-th root"))
    root
end
function _integer_root(value::BigInt, q::Integer)
    # Newton iteration from above, exact in BigInt, then the two candidates.
    value <= 1 && return value
    r = BigInt(isqrt(value)) + 1
    q == 2 || (r = BigInt(2)^(cld(ndigits(value; base=2), q)))
    while true
        next = ((q - 1) * r + value ÷ r^(q - 1)) ÷ q
        next >= r && break
        r = next
    end
    for candidate in (r - 1, r, r + 1)
        candidate >= 1 && candidate^q == value && return candidate
    end
    nothing
end

_law_int(value) = value isa BigInt ? (value <= typemax(Int) ? Int(value) : throw(ArgumentError("law value exceeds Int"))) : Int(value)

"k(n) = (lambda n)^((1 + c')tau), the exact source term (gt-11-parallel-repetition.tex:200, gt-12-compression.tex:355)."
const K_REP_LAW = :((lambda * n) ^ ((1 + c_prime) * tau))
"B(n) = (lambda n)^tau, the per-component length guard (gt-11-parallel-repetition.tex:216-220)."
const B_REP_LAW = :((lambda * n) ^ tau)

function k_rep(lambda::Integer, tau::Integer, c_prime::Rational, n::Integer)
    (lambda >= 1 && tau >= 1 && n >= 1) || throw(ArgumentError("k(n) needs positive lambda, tau, n"))
    c_prime > 0 || throw(ArgumentError("c' is a positive universal constant"))
    _law_int(evaluate_law(K_REP_LAW, Dict{Symbol,Any}(:lambda => Int(lambda), :tau => Int(tau),
                                                       :c_prime => c_prime, :n => Int(n))))
end
k_rep(lambda::Integer, tau::Integer, c_prime::Integer, n::Integer) = k_rep(lambda, tau, c_prime // 1, n)
function B_rep(lambda::Integer, tau::Integer, n::Integer)
    (lambda >= 1 && tau >= 1 && n >= 1) || throw(ArgumentError("B(n) needs positive lambda, tau, n"))
    _law_int(evaluate_law(B_REP_LAW, Dict{Symbol,Any}(:lambda => Int(lambda), :tau => Int(tau), :n => Int(n))))
end

# ---------------------------------------------------------------------------
# The hand-transcribed expected laws of DESIGN 9.4's table (one row per
# DL9 constructor). `expected_laws(rule, r)` is the transcription; the
# constructors emit their laws independently from the children they
# combine, and the LawCert compares the two ASTs (a transcription check,
# not a proof of the paper theorem).

_sum_law(names) = length(names) == 1 ? names[1] : Expr(:call, :+, names...)
_max_law(names) = length(names) == 1 ? names[1] : Expr(:call, :max, names...)

function expected_laws(rule::Symbol, r::Int=1)
    ells = [Symbol("ell_$i") for i in 1:r]
    ss = [:($(Symbol("s_$i"))(n)) for i in 1:r]
    Cs = [:($(Symbol("C_$i"))(n)) for i in 1:r]
    rule == Symbol("DL9-direct-sum") && return (; field=:q_1, level=_max_law(ells), dimension=_sum_law(ss),
                                                  query_time=:($(r) + $(_sum_law(Cs))))
    rule == Symbol("DL9-product") && return (; field=:q_1, level=:(max(ell_1, ell_2)), dimension=:(s_1(n) + s_2(n)),
                                               query_time=:(C_1(n) + C_2(n)))
    rule == Symbol("DL9-downsize") && return (; field=2, level=:ell_1, dimension=:(s_1(n) * log2(q_1)),
                                                query_time=:(C_1(n) * log2(q_1)))
    rule == Symbol("DL9-detype") && return (; field=2, level=:(ell_1 + 2), dimension=:(s_1(n) + 4 * TypeCount),
                                              query_time=:(poly(TypeCount, C_1(n))))
    rule == Symbol("DL9-anchor") && return (; field=2, level=:ell_1, dimension=:(s_1(n)),
                                              query_time=:(poly(C_1(n))))
    rule == Symbol("DL9-repeat") && return (; field=2, level=:ell_1, dimension=:(k(n) * s_1(n)),
                                              query_time=:(k(n) * C_1(n)))
    rule == :DescribeCL && return (; field=:q, level=:ell, dimension=:s, query_time=:(TIME_S(n)))
    throw(ArgumentError("no expected laws for $(rule)"))
end

"The law environment of a description at index n: parameters and every child's header laws."
function law_environment(S::SamplerDescription, n::Integer; lambda=nothing, tau=nothing, c_prime=nothing)
    env = Dict{Symbol,Any}(:n => Int(n))
    lambda === nothing || (env[:lambda] = Int(lambda))
    tau === nothing || (env[:tau] = Int(tau))
    c_prime === nothing || (env[:c_prime] = c_prime)
    if S.term[1] == :Repeat
        env[:lambda], env[:tau] = S.term[2], S.term[3]
        env[:c_prime] = S.term[4] // S.term[5]
        env[:k] = m -> k_rep(S.term[2], S.term[3], S.term[4] // S.term[5], m)
        env[:B] = m -> B_rep(S.term[2], S.term[3], m)
    end
    S.typing isa Typed && (env[:TypeCount] = TypeCount(S.typing))
    for (i, part) in enumerate(S.parts)
        part isa SamplerDescription || continue
        env[Symbol("q_$i")] = part.field_size
        env[Symbol("ell_$i")] = part.level
        env[Symbol("s_$i")] = m -> _law_int(_dimension_value(part, m))
        part.typing isa Typed && i == 1 && (env[:TypeCount] = TypeCount(part.typing))
    end
    env
end

"Evaluate a description's own dimension law at n through its children's laws."
_dimension_value(S::SamplerDescription, n::Integer) =
    evaluate_law(S.dimension_law, law_environment(S, n))

# The LawCert node: expected vs actual ASTs and the evaluations at the tracer index.
function _law_cert(rule::Symbol, S::SamplerDescription, expected::NamedTuple, n::Int)
    actual = (; field=S.field_law, level=S.level_law, dimension=S.dimension_law, query_time=S.query_time)
    env = law_environment(S, n)
    evaluations = try
        (; n, field=_law_int(evaluate_law(S.field_law, env)),
           level=_law_int(evaluate_law(S.level_law, env)),
           dimension=_law_int(evaluate_law(S.dimension_law, env)))
    catch error
        error isa ArgumentError ? (; n, field=S.field_size, level=S.level, dimension="NOT_EVALUABLE: " * error.msg) : rethrow()
    end
    display = "expected == actual: field = $(expected.field), level = $(expected.level), dimension = $(expected.dimension), query time = $(expected.query_time); at n = $(n): field $(evaluations.field), level $(evaluations.level), dimension $(evaluations.dimension) (AST equality is a transcription check, DESIGN 9.2)"
    replay = x -> begin
        e = law_environment(x, n)
        ok = (x.field_law, x.level_law, x.dimension_law, x.query_time) ==
             (expected.field, expected.level, expected.dimension, expected.query_time) &&
             _law_int(evaluate_law(x.field_law, e)) == x.field_size &&
             _law_int(evaluate_law(x.level_law, e)) == x.level &&
             _law_int(evaluate_law(x.dimension_law, e)) == Dimension(x, n)
        CheckResult(ok, :law_cert; location=rule, expected=expected,
                    actual=(; field=x.field_law, level=x.level_law, dimension=x.dimension_law, query_time=x.query_time))
    end
    CertNode(CHECKED, :LawCert; facts=(; display, expected, actual, evaluations),
             replay=_bound_replay(S, :LawCert, replay))
end
