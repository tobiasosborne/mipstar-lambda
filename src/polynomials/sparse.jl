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
    plan::Any
end

function _support_report(terms::Dict{NTuple{N,UInt8},F}) where {F,N}
    if isempty(terms)
        degrees = ntuple(_ -> -1, N)
        return SupportReport(degrees, (), -1)
    end
    degrees = ntuple(i -> maximum(Int(key[i]) for key in keys(terms)), N)
    dependencies = Tuple(i for i in 1:N if degrees[i] > 0)
    total = maximum(sum(Int, key) for key in keys(terms))
    SupportReport(degrees, dependencies, total)
end

function _poly(layout::VarLayout{N}, terms::Dict{NTuple{N,UInt8},F},
               structural::DegreeDerivation{N}, expected::Int, plan) where {F,N}
    normalized = Dict{NTuple{N,UInt8},F}()
    for (key, coefficient) in terms
        iszero(coefficient) || (normalized[key] = coefficient)
    end
    Poly{F,N}(layout, normalized, structural, _support_report(normalized),
              expected, plan)
end

_zero_key(::Val{N}) where {N} = ntuple(_ -> UInt8(0), N)

function constant_poly(::Type{F}, layout::VarLayout{N}, value) where {F,N}
    coefficient = convert(F, value)
    terms = Dict{NTuple{N,UInt8},F}()
    iszero(coefficient) || (terms[_zero_key(Val(N))] = coefficient)
    derivation = DegreeDerivation(:Constant, ntuple(_ -> 0, N), (), ())
    _poly(layout, terms, derivation, iszero(coefficient) ? 0 : 1,
          ConstantPlan(coefficient))
end

zero_poly(::Type{F}, layout::VarLayout) where {F} = constant_poly(F, layout, 0)

function polyvar(::Type{F}, layout::VarLayout{N}, coordinate::Int) where {F,N}
    1 <= coordinate <= N || throw(ArgumentError("variable coordinate out of range"))
    key = ntuple(i -> UInt8(i == coordinate), N)
    terms = Dict{NTuple{N,UInt8},F}(key => one(F))
    bound = ntuple(i -> i == coordinate ? 1 : 0, N)
    derivation = DegreeDerivation(:Variable, bound, (coordinate,), ())
    _poly(layout, terms, derivation, 1, VariablePlan(coordinate))
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
    _poly(a.layout, terms, derivation, expected, AddPlan(a.plan, b.plan))
end

Base.:-(a::Poly{F,N}) where {F,N} = begin
    terms = Dict(key => -coefficient for (key, coefficient) in a.terms)
    _poly(a.layout, terms, a.structural, a.expected,
          MulPlan(ConstantPlan(-one(F)), a.plan))
end
Base.:-(a::Poly, b::Poly) = a + (-b)

function _candidate_product(a::Int, b::Int)
    (a == 0 || b == 0) && return 0
    a > div(typemax(Int), b) ? typemax(Int) : a * b
end

function mul_poly(a::Poly{F,N}, b::Poly{F,N};
                  budget=MonomialBudget(typemax(Int))) where {F,N}
    _same_carrier(a, b)
    estimate = _candidate_product(a.expected, b.expected)
    estimate > budget.limit && return ExpansionRefused(estimate, budget)
    terms = Dict{NTuple{N,UInt8},F}()
    for (left_key, left_coefficient) in a.terms
        for (right_key, right_coefficient) in b.terms
            key = ntuple(i -> begin
                exponent = Int(left_key[i]) + Int(right_key[i])
                exponent <= typemax(UInt8) || throw(ArgumentError("exponent exceeds UInt8"))
                UInt8(exponent)
            end, N)
            value = get(terms, key, zero(F)) + left_coefficient * right_coefficient
            iszero(value) ? delete!(terms, key) : (terms[key] = value)
        end
    end
    bound = ntuple(i -> a.structural.bound[i] + b.structural.bound[i], N)
    dependencies = Tuple(sort!(unique!(collect((a.structural.dependencies...,
                                                 b.structural.dependencies...)))))
    derivation = DegreeDerivation(:Product, bound, dependencies,
                                  (a.structural, b.structural))
    _poly(a.layout, terms, derivation, estimate, MulPlan(a.plan, b.plan))
end

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

function evaluate(poly::Poly{F,N}, point::AbstractVector{F}) where {F,N}
    length(point) == N || throw(ArgumentError("point has wrong dimension"))
    _evalplan(poly.plan, point)
end

monomial_count(poly::Poly) = length(poly.terms)
expected_support(poly::Poly) = poly.expected
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
    _poly(poly.layout, poly.terms, derivation, expected, plan)
end

function _from_terms(::Type{F}, layout::VarLayout{N},
                     terms::Dict{NTuple{N,UInt8},F},
                     derivation::DegreeDerivation{N}; expected=length(terms)) where {F,N}
    copied = copy(terms)
    _poly(layout, copied, derivation, expected, SparsePlan(copied))
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
             coordinates::NTuple{M,Int}) where {F<:GF2k,N,M}
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

function zero(layout::VarLayout, coordinate::Int, ::Type{F}) where {F<:GF2k}
    variable = polyvar(F, layout, coordinate)
    variable * (constant_poly(F, layout, 1) - variable)
end
