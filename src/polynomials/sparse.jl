struct VarBlock
    name::Symbol
    coordinates::UnitRange{Int}
end

struct VarLayout{N}
    names::NTuple{N,Symbol}
    blocks::Tuple
    function VarLayout(names::NTuple{N,Symbol}, blocks::Tuple) where {N}
        seen = falses(N)
        for block in blocks, coordinate in block.coordinates
            1 <= coordinate <= N || throw(ArgumentError("block coordinate out of range"))
            seen[coordinate] && throw(ArgumentError("overlapping variable blocks"))
            seen[coordinate] = true
        end
        all(seen) || throw(ArgumentError("variable blocks must cover the layout"))
        new{N}(names, blocks)
    end
end

function block_coordinates(layout::VarLayout, name::Symbol)
    matches = filter(block -> block.name == name, layout.blocks)
    length(matches) == 1 ||
        throw(ArgumentError("layout must contain exactly one $name block"))
    only(matches).coordinates
end

struct DegreeDerivation{N}
    rule::Symbol
    bound::NTuple{N,Int}
    dependencies::Tuple
    children::Tuple
end

struct SupportReport{N}
    degrees::NTuple{N,Int}
    dependencies::Tuple
    total_degree::Int
end

struct MonomialBudget
    limit::Int
end

struct ExpansionRefused
    estimate::Int
    budget::MonomialBudget
end

abstract type AbstractEvalPlan end
struct ConstantPlan{F} <: AbstractEvalPlan
    value::F
end
struct VariablePlan <: AbstractEvalPlan
    coordinate::Int
end
struct AddPlan <: AbstractEvalPlan
    left::Any
    right::Any
end
struct MulPlan <: AbstractEvalPlan
    left::Any
    right::Any
end
struct SparsePlan{F,N} <: AbstractEvalPlan
    terms::Dict{NTuple{N,UInt8},F}
end

struct Poly{F,N}
    layout::VarLayout{N}
    terms::Dict{NTuple{N,UInt8},F}
    structural::DegreeDerivation{N}
    actual::SupportReport{N}
    expected::Int
    multiplication_peak::Int
    plan::Any
end

function _support_report(terms::Dict{NTuple{N,UInt8},F}) where {F,N}
    if isempty(terms)
        degrees = ntuple(_ -> -1, N)
        return SupportReport(degrees, (), -1)
    end
    degrees = fill(-1, N)
    total_degree = -1
    for key in keys(terms)
        monomial_degree = 0
        for i in 1:N
            exponent = Int(key[i])
            degrees[i] = max(degrees[i], exponent)
            monomial_degree += exponent
        end
        total_degree = max(total_degree, monomial_degree)
    end
    degree_tuple = Tuple(degrees)
    dependencies = Tuple(i for i in 1:N if degree_tuple[i] > 0)
    SupportReport(degree_tuple, dependencies, total_degree)
end

function _poly(layout::VarLayout{N}, terms::Dict{NTuple{N,UInt8},F},
               structural::DegreeDerivation{N}, expected::Int,
               multiplication_peak::Int, plan; normalized=false) where {F,N}
    support = if normalized
        terms
    else
        cleaned = Dict{NTuple{N,UInt8},F}()
        for (key, coefficient) in terms
            iszero(coefficient) || (cleaned[key] = coefficient)
        end
        cleaned
    end
    Poly{F,N}(layout, support, structural, _support_report(support),
              expected, multiplication_peak, plan)
end

_zero_key(::Val{N}) where {N} = ntuple(_ -> UInt8(0), N)

function constant_poly(::Type{F}, layout::VarLayout{N}, value) where {F,N}
    coefficient = convert(F, value)
    terms = Dict{NTuple{N,UInt8},F}()
    iszero(coefficient) || (terms[_zero_key(Val(N))] = coefficient)
    derivation = DegreeDerivation(:Constant, ntuple(_ -> 0, N), (), ())
    _poly(layout, terms, derivation, iszero(coefficient) ? 0 : 1, 0,
          ConstantPlan(coefficient); normalized=true)
end

zero_poly(::Type{F}, layout::VarLayout) where {F} = constant_poly(F, layout, 0)

function polyvar(::Type{F}, layout::VarLayout{N}, coordinate::Int) where {F,N}
    1 <= coordinate <= N || throw(ArgumentError("variable coordinate out of range"))
    key = ntuple(i -> UInt8(i == coordinate), N)
    terms = Dict{NTuple{N,UInt8},F}(key => one(F))
    bound = ntuple(i -> i == coordinate ? 1 : 0, N)
    derivation = DegreeDerivation(:Variable, bound, (coordinate,), ())
    _poly(layout, terms, derivation, 1, 0, VariablePlan(coordinate);
          normalized=true)
end

function _same_carrier(a::Poly{F,N}, b::Poly{F,N}) where {F,N}
    a.layout == b.layout || throw(ArgumentError("polynomial layouts differ"))
    nothing
end

function Base.:+(a::Poly{F,N}, b::Poly{F,N}) where {F,N}
    _same_carrier(a, b)
    terms = copy(a.terms)
    for (key, coefficient) in b.terms
        value = get(terms, key, zero(F)) + coefficient
        iszero(value) ? delete!(terms, key) : (terms[key] = value)
    end
    bound = ntuple(i -> max(a.structural.bound[i], b.structural.bound[i]), N)
    dependencies = Tuple(sort!(unique!(collect((a.structural.dependencies...,
                                                 b.structural.dependencies...)))))
    derivation = DegreeDerivation(:Sum, bound, dependencies,
                                  (a.structural, b.structural))
    expected = min(typemax(Int), a.expected + b.expected)
    peak = max(a.multiplication_peak, b.multiplication_peak)
    _poly(a.layout, terms, derivation, expected, peak, AddPlan(a.plan, b.plan);
          normalized=true)
end

Base.:-(a::Poly{F,N}) where {F,N} = begin
    terms = Dict(key => -coefficient for (key, coefficient) in a.terms)
    _poly(a.layout, terms, a.structural, a.expected, a.multiplication_peak,
          MulPlan(ConstantPlan(-one(F)), a.plan); normalized=true)
end
Base.:-(a::Poly, b::Poly) = a + (-b)

function _candidate_product(a::Int, b::Int)
    (a == 0 || b == 0) && return 0
    a > div(typemax(Int), b) ? typemax(Int) : a * b
end

function _multiply_terms_generic(a::Dict{K,F}, b::Dict{K,F}) where {K,F}
    terms = Dict{K,F}()
    for (left_key, left_coefficient) in a
        for (right_key, right_coefficient) in b
            key = ntuple(i -> UInt8(Int(left_key[i]) + Int(right_key[i])),
                         length(left_key))
            value = get(terms, key, zero(F)) + left_coefficient * right_coefficient
            iszero(value) ? delete!(terms, key) : (terms[key] = value)
        end
    end
    terms
end


_multiply_terms(a::Dict{K,F}, b::Dict{K,F}) where {K,F} =
    _multiply_terms_generic(a, b)

function _multiply_terms(a::Dict{K,F}, b::Dict{K,F}) where {K,F<:GF2k}
    prime_support = all(coefficient -> coefficient.bits == 1, values(a)) &&
                    all(coefficient -> coefficient.bits == 1, values(b))
    prime_support || return _multiply_terms_generic(a, b)
    terms = Dict{K,F}()
    unit = one(F)
    for left_key in keys(a), right_key in keys(b)
        key = ntuple(i -> UInt8(Int(left_key[i]) + Int(right_key[i])),
                     length(left_key))
        haskey(terms, key) ? delete!(terms, key) : (terms[key] = unit)
    end
    terms
end

function mul_poly(a::Poly{F,N}, b::Poly{F,N},
                  budget::MonomialBudget) where {F,N}
    _same_carrier(a, b)
    candidates = _candidate_product(length(a.terms), length(b.terms))
    candidates > budget.limit && return ExpansionRefused(candidates, budget)
    terms = _multiply_terms(a.terms, b.terms)
    bound = ntuple(i -> a.structural.bound[i] + b.structural.bound[i], N)
    dependencies = Tuple(sort!(unique!(collect((a.structural.dependencies...,
                                                 b.structural.dependencies...)))))
    derivation = DegreeDerivation(:Product, bound, dependencies,
                                  (a.structural, b.structural))
    expected = _candidate_product(a.expected, b.expected)
    peak = max(a.multiplication_peak, b.multiplication_peak, candidates)
    _poly(a.layout, terms, derivation, expected, peak, MulPlan(a.plan, b.plan);
          normalized=true)
end


mul_poly(a::Poly, b::Poly;
         budget=MonomialBudget(typemax(Int))) = mul_poly(a, b, budget)

function Base.:*(a::Poly{F,N}, b::Poly{F,N}) where {F,N}
    result = mul_poly(a, b)
    result isa ExpansionRefused && error("unbounded polynomial product was refused")
    result
end

function Base.:^(a::Poly{F,N}, exponent::Integer) where {F,N}
    exponent >= 0 || throw(ArgumentError("negative polynomial exponent"))
    result = constant_poly(F, a.layout, 1)
    base = a
    power = exponent
    while power > 0
        isodd(power) && (result = result * base)
        power >>= 1
        power > 0 && (base = base * base)
    end
    result
end

_evalplan(plan::ConstantPlan, point) = plan.value
_evalplan(plan::VariablePlan, point) = point[plan.coordinate]
_evalplan(plan::AddPlan, point) = _evalplan(plan.left, point) + _evalplan(plan.right, point)
_evalplan(plan::MulPlan, point) = _evalplan(plan.left, point) * _evalplan(plan.right, point)

_evalplan_as(plan::VariablePlan, point, ::Type{F}) where {F} = point[plan.coordinate]
_evalplan_as(plan::ConstantPlan, point, ::Type{F}) where {F} = F(Int(plan.value.bits))
_evalplan_as(plan::AddPlan, point, ::Type{F}) where {F} =
    _evalplan_as(plan.left, point, F) + _evalplan_as(plan.right, point, F)
_evalplan_as(plan::MulPlan, point, ::Type{F}) where {F} =
    _evalplan_as(plan.left, point, F) * _evalplan_as(plan.right, point, F)

function _evalplan(plan::SparsePlan{F,N}, point) where {F,N}
    total = zero(F)
    for (key, coefficient) in plan.terms
        term = coefficient
        for i in 1:N
            key[i] == 0 || (term *= point[i]^Int(key[i]))
        end
        total += term
    end
    total
end


function _evalplan_as(plan::SparsePlan{S,N}, point, ::Type{F}) where {S,N,F}
    total = zero(F)
    for (key, coefficient) in plan.terms
        coefficient.bits <= 1 || throw(ArgumentError("coefficient is outside the prime subfield"))
        term = F(Int(coefficient.bits))
        for i in 1:N
            key[i] == 0 || (term *= point[i]^Int(key[i]))
        end
        total += term
    end
    total
end

function _evaluate_as(poly::Poly{S,N}, point::AbstractVector{F}) where {S,N,F}
    length(point) == N || throw(ArgumentError("point has wrong dimension"))
    _evalplan_as(poly.plan, point, F)
end

function evaluate(poly::Poly{F,N}, point::AbstractVector{F}) where {F,N}
    length(point) == N || throw(ArgumentError("point has wrong dimension"))
    _evalplan(poly.plan, point)
end

monomial_count(poly::Poly) = length(poly.terms)
expected_support(poly::Poly) = poly.expected
multiplication_peak(poly::Poly) = poly.multiplication_peak
structural_degrees(poly::Poly) = poly.structural.bound
actual_degrees(poly::Poly) = poly.actual.degrees
dependency_coordinates(poly::Poly) = Set(poly.actual.dependencies)

function dependency_blocks(poly::Poly)
    coordinates = dependency_coordinates(poly)
    Set(block.name for block in poly.layout.blocks
        if any(in(coordinates), block.coordinates))
end

function degree_accounts_valid(poly::Poly)
    all(actual <= structural
        for (actual, structural) in zip(poly.actual.degrees, poly.structural.bound))
end

function polynomial_equal(a::Poly{F,N}, b::Poly{F,N}) where {F,N}
    a.layout == b.layout && a.terms == b.terms
end

function _with_metadata(poly::Poly{F,N}, derivation::DegreeDerivation{N},
                        expected::Int, plan=poly.plan) where {F,N}
    _poly(poly.layout, poly.terms, derivation, expected,
          poly.multiplication_peak, plan; normalized=true)
end

_change_plan(plan::VariablePlan, ::Type{F}) where {F} = plan
_change_plan(plan::ConstantPlan{S}, ::Type{F}) where {S<:GF2k,F} =
    ConstantPlan(convert(F, Int(plan.value.bits)))
_change_plan(plan::ConstantPlan{S}, ::Type{F}) where {S<:Integer,F} =
    ConstantPlan(convert(F, mod(plan.value, 2)))
_change_plan(plan::AddPlan, ::Type{F}) where {F} =
    AddPlan(_change_plan(plan.left, F), _change_plan(plan.right, F))
_change_plan(plan::MulPlan, ::Type{F}) where {F} =
    MulPlan(_change_plan(plan.left, F), _change_plan(plan.right, F))
function _change_plan(plan::SparsePlan{S,N}, ::Type{F}) where {S,N,F}
    terms = Dict(key => convert(F, Int(coefficient.bits))
                 for (key, coefficient) in plan.terms)
    SparsePlan(terms)
end

function _change_plan(plan::SparsePlan{S,N}, ::Type{F}) where {S<:Integer,N,F}
    terms = Dict(key => convert(F, mod(coefficient, 2))
                 for (key, coefficient) in plan.terms
                 if !iszero(mod(coefficient, 2)))
    SparsePlan(terms)
end


"Change the carrier of a prime-subfield-coefficient polynomial (coefficients 0 or 1)."
function change_field(poly::Poly{S,N}, ::Type{F}) where {S<:GF2k,F<:GF2k,N}
    all(coefficient.bits <= 1 for coefficient in values(poly.terms)) ||
        throw(ArgumentError("field change is defined only for prime-subfield coefficients"))
    terms = Dict(key => convert(F, Int(coefficient.bits))
                 for (key, coefficient) in poly.terms)
    _poly(poly.layout, terms, poly.structural, poly.expected,
          poly.multiplication_peak,
          _change_plan(poly.plan, F); normalized=true)
end

"Reduce an integer-coefficient formal polynomial to characteristic two."
function change_field(poly::Poly{S,N}, ::Type{F}) where {S<:Integer,F<:GF2k,N}
    terms = Dict(key => F(mod(coefficient, 2))
                 for (key, coefficient) in poly.terms
                 if !iszero(mod(coefficient, 2)))
    _poly(poly.layout, terms, poly.structural, poly.expected,
          poly.multiplication_peak, _change_plan(poly.plan, F);
          normalized=true)
end

function _from_terms(::Type{F}, layout::VarLayout{N},
                     terms::Dict{NTuple{N,UInt8},F},
                     derivation::DegreeDerivation{N}; expected=length(terms),
                     multiplication_peak=0) where {F,N}
    _poly(layout, terms, derivation, expected, multiplication_peak,
          SparsePlan(terms); normalized=true)
end

# gt-03-prelim.tex:873-897 (sec:ld-encoding).
function ind(point::AbstractVector{F}) where {F}
    m = length(point)
    values = Vector{F}(undef, 1 << m)
    for index in 0:(1 << m)-1
        value = one(F)
        for coordinate in 1:m
            bit = (index >> (m - coordinate)) & 1
            value *= bit == 1 ? point[coordinate] : one(F) - point[coordinate]
        end
        values[index + 1] = value
    end
    values
end

function g_a(table::AbstractVector{F}, layout::VarLayout{N},
             coordinates::NTuple{M,Int}) where {F,N,M}
    length(table) == 1 << M || throw(ArgumentError("assignment table has wrong length"))
    result = zero_poly(F, layout)
    for index in 0:(1 << M)-1
        basis = constant_poly(F, layout, table[index + 1])
        for local_coordinate in 1:M
            variable = polyvar(F, layout, coordinates[local_coordinate])
            bit = (index >> (M - local_coordinate)) & 1
            factor = bit == 1 ? variable : constant_poly(F, layout, 1) - variable
            basis = basis * factor
        end
        result = result + basis
    end
    constant_table = all(value == first(table) for value in table)
    bound = ntuple(i -> (!constant_table && i in coordinates) ? 1 : 0, N)
    dependencies = constant_table ? () : Tuple(coordinates)
    derivation = DegreeDerivation(:MultilinearExtension, bound, dependencies, ())
    result = _with_metadata(result, derivation, monomial_count(result))
    certificate = CertNode(CHECKED, :MultilinearExtension;
        facts=(display="bound = $(maximum(bound)); coordinates = $(coordinates)",),
        replay=p -> CheckResult(degree_accounts_valid(p), :multilinear_degree;
                                expected=p.structural.bound, actual=p.actual.degrees))
    Checked(result, certificate)
end

function dec(poly::Poly{F,N}, coordinates::NTuple{M,Int}, alphabet) where {F,N,M}
    allowed = Set(alphabet)
    output = Vector{F}(undef, 1 << M)
    base = fill(zero(F), N)
    for index in 0:(1 << M)-1
        point = copy(base)
        for local_coordinate in 1:M
            bit = (index >> (M - local_coordinate)) & 1
            point[coordinates[local_coordinate]] = convert(F, bit)
        end
        value = evaluate(poly, point)
        output[index + 1] = value in allowed ? value : zero(F)
    end
    output
end

function zero(layout::VarLayout, coordinate::Int, ::Type{F}) where {F}
    variable = polyvar(F, layout, coordinate)
    variable * (constant_poly(F, layout, 1) - variable)
end
