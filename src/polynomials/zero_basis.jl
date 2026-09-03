struct RewriteStep{F,N}
    variable::UInt8
    source::NTuple{N,UInt8}
    coefficient::F
    remainder_exponent::UInt8
    quotient_exponent::UInt8
    quotient_coefficient::F
end

struct ZeroDecomposition{F,N}
    layout::VarLayout{N}
    quotients::Tuple
    remainder::Poly{F,N}
    steps::Tuple
end

function _accumulate!(terms::Dict{K,F}, key::K, coefficient::F) where {K,F}
    value = get(terms, key, zero(F)) + coefficient
    iszero(value) ? delete!(terms, key) : (terms[key] = value)
    terms
end

function zero_basis_decompose(input::Poly{F,N}, order) where {F,N}
    Tuple(sort(collect(order))) == Tuple(1:N) ||
        throw(ArgumentError("division order must contain each coordinate once"))
    remainder_terms = copy(input.terms)
    remainder_bound = collect(input.structural.bound)
    quotients = Poly{F,N}[]
    steps = RewriteStep{F,N}[]

    # gt-10-answer-reduction.tex:1281-1373 (prop:zero-basis proof).
    for variable in order
        quotient_terms = Dict{NTuple{N,UInt8},F}()
        next_remainder = Dict{NTuple{N,UInt8},F}()
        for key in sort!(collect(keys(remainder_terms)))
            coefficient = remainder_terms[key]
            exponent = Int(key[variable])
            if exponent < 2
                _accumulate!(next_remainder, key, coefficient)
                continue
            end
            remainder_key = ntuple(i -> i == variable ? UInt8(1) : key[i], N)
            _accumulate!(next_remainder, remainder_key, coefficient)
            for e in exponent:-1:2
                quotient_exponent = e - 2
                quotient_key = ntuple(i -> i == variable ? UInt8(quotient_exponent) : key[i], N)
                quotient_coefficient = -coefficient
                _accumulate!(quotient_terms, quotient_key, quotient_coefficient)
                source = ntuple(i -> i == variable ? UInt8(e) : key[i], N)
                push!(steps, RewriteStep(UInt8(variable), source, coefficient,
                                         UInt8(e - 1), UInt8(quotient_exponent),
                                         quotient_coefficient))
            end
        end

        quotient_bound = copy(remainder_bound)
        quotient_bound[variable] = max(remainder_bound[variable] - 2, 0)
        quotient_dependencies = Tuple(i for i in 1:N if quotient_bound[i] > 0)
        quotient_derivation = DegreeDerivation(:RewriteQuotient,
            Tuple(quotient_bound), quotient_dependencies, (input.structural,))
        push!(quotients, _from_terms(F, input.layout, quotient_terms,
                                     quotient_derivation))
        remainder_terms = next_remainder
        remainder_bound[variable] = min(remainder_bound[variable], 1)
    end

    remainder_dependencies = Tuple(i for i in 1:N if remainder_bound[i] > 0)
    remainder_derivation = DegreeDerivation(:RewriteRemainder,
        Tuple(remainder_bound), remainder_dependencies, (input.structural,))
    remainder = _from_terms(F, input.layout, remainder_terms,
                            remainder_derivation)
    decomposition = ZeroDecomposition(input.layout, Tuple(quotients),
                                      remainder, Tuple(steps))
    certificate = CertNode(CHECKED, :ZeroBasis;
        facts=(display="remainder = $(isempty(remainder.terms) ? 0 : monomial_count(remainder)); coefficient identity = true",),
        replay=term -> verify_zero_decomposition(input, term))
    Checked(decomposition, certificate)
end

function verify_rewrite_step(step::RewriteStep{F,N}) where {F,N}
    variable = Int(step.variable)
    exponent = Int(step.source[variable])
    shape_ok = exponent >= 2 &&
               Int(step.remainder_exponent) == exponent - 1 &&
               Int(step.quotient_exponent) == exponent - 2 &&
               step.quotient_coefficient == -step.coefficient
    shape_ok || return CheckResult(false, :rewrite_identity;
                                   location=variable,
                                   expected=(exponent - 1, exponent - 2, -step.coefficient),
                                   actual=(Int(step.remainder_exponent),
                                           Int(step.quotient_exponent),
                                           step.quotient_coefficient))

    lhs = Dict{NTuple{N,UInt8},F}(step.source => step.coefficient)
    rhs = Dict{NTuple{N,UInt8},F}()
    lower = ntuple(i -> i == variable ? step.remainder_exponent : step.source[i], N)
    _accumulate!(rhs, lower, step.coefficient)
    zero_first = ntuple(i -> i == variable ? UInt8(step.quotient_exponent + 1) :
                                             step.source[i], N)
    zero_second = ntuple(i -> i == variable ? UInt8(step.quotient_exponent + 2) :
                                              step.source[i], N)
    _accumulate!(rhs, zero_first, step.quotient_coefficient)
    _accumulate!(rhs, zero_second, -step.quotient_coefficient)
    CheckResult(lhs == rhs, :rewrite_identity;
                location=variable, expected=lhs, actual=rhs)
end

function verify_zero_decomposition(input::Poly{F,N},
                                   decomposition::ZeroDecomposition{F,N}) where {F,N}
    input.layout == decomposition.layout ||
        return CheckResult(false, :coefficient_identity;
                           expected=input.layout, actual=decomposition.layout)
    all(step -> passed(verify_rewrite_step(step)), decomposition.steps) ||
        return CheckResult(false, :coefficient_identity;
                           expected=:valid_rewrites, actual=:invalid_rewrite)

    rhs = copy(decomposition.remainder.terms)
    for (variable, quotient) in enumerate(decomposition.quotients)
        for (key, coefficient) in quotient.terms
            first_key = ntuple(i -> i == variable ? UInt8(Int(key[i]) + 1) : key[i], N)
            second_key = ntuple(i -> i == variable ? UInt8(Int(key[i]) + 2) : key[i], N)
            _accumulate!(rhs, first_key, coefficient)
            _accumulate!(rhs, second_key, -coefficient)
        end
    end
    identity = rhs == input.terms
    zero_remainder = isempty(decomposition.remainder.terms)
    CheckResult(identity && zero_remainder, :coefficient_identity;
                expected=(input.terms, :zero_remainder),
                actual=(rhs, zero_remainder ? :zero_remainder :
                                           decomposition.remainder.terms))
end
