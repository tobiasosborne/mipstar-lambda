@enum PredicateStatus PASS FAIL NOT_EVALUABLE

struct PCPParams
    q::Int
    k::Int
    m::Int
    d::Int
    s::Int
    m_prime::Int
end

struct ParameterPolicy
    P_shape::PredicateStatus
    P_growth::PredicateStatus
    P_formula_paper::PredicateStatus
    P_tail::PredicateStatus
    P_divisibility::PredicateStatus
    P_degree::PredicateStatus
    P_formula_structural::PredicateStatus
    P_zero::PredicateStatus
    P_exponent_range::PredicateStatus
end

policy_vector(policy::ParameterPolicy) =
    (policy.P_shape, policy.P_growth, policy.P_formula_paper,
     policy.P_tail, policy.P_divisibility, policy.P_degree)

_status(value::Bool) = value ? PASS : FAIL

# gt-10-answer-reduction.tex:1396-1422 (def:pcpparams).
function parameter_policy(params::PCPParams, degree_formula::Int)
    shape = params.m_prime == 5params.m + 5 + params.s &&
            ispow2(params.m_prime)
    formula_paper = 2 * (2 + 5params.k) * params.m_prime < params.q
    tail_lhs = params.k * params.m_prime // params.q
    # With unknown 0<b'<1: s^(-b') lies strictly between 1/s and 1.
    tail = tail_lhs < 1 // params.s ? PASS :
           tail_lhs >= 1 ? FAIL : NOT_EVALUABLE
    divisibility = params.q % params.m_prime == 0
    degree = params.d == params.k
    formula_structural = 2 * (degree_formula + 5params.d) * params.m_prime < params.q
    zero_test = 2 * (2 + params.d) * params.m_prime < params.q
    exponent_range = params.d <= params.q - 1
    ParameterPolicy(_status(shape), NOT_EVALUABLE, _status(formula_paper), tail,
                    _status(divisibility), _status(degree),
                    _status(formula_structural), _status(zero_test),
                    _status(exponent_range))
end

function minimal_checkable_odd_k(degree_formula::Int, m_prime::Int)
    for k in 1:2:63
        q = big(1) << k
        structural = 2big(degree_formula + 5k) * m_prime < q
        paper = 2big(2 + 5k) * m_prime < q
        zero_test = 2big(2 + k) * m_prime < q
        structural && paper && zero_test && return k
    end
    nothing
end

function build_c0(farith::Poly{F,N}, gs::NTuple{5,Poly{F,N}};
                  budget=MonomialBudget(typemax(Int))) where {F,N}
    result = farith
    for i in 1:5
        sign_coordinate = 5 + i
        factor = gs[i] - polyvar(F, farith.layout, sign_coordinate)
        multiplied = mul_poly(result, factor; budget=budget)
        multiplied isa ExpansionRefused && return multiplied
        result = multiplied
    end
    certificate = CertNode(CHECKED, :BuildC0;
        facts=(display="inddeg = $(maximum(actual_degrees(result))); monomials = $(monomial_count(result))",),
        replay=p -> CheckResult(degree_accounts_valid(p), :c0_degree_accounts;
                                expected=p.structural.bound, actual=p.actual.degrees))
    Checked(result, certificate)
end

struct EvalDAGNode{F}
    coordinate::Int
    coefficient::F
    branches::Vector{Tuple{UInt8,Int}}
end

struct SharedEvalPlan{F,N}
    nodes::Vector{EvalDAGNode{F}}
    roots::NTuple{N,Int}
    max_exponents::NTuple{N,Int}
end

function _shared_eval_plan(polynomials::NTuple{N,Poly{F,N}}) where {F,N}
    nodes = EvalDAGNode{F}[]
    signatures = Dict{Any,Int}()

    function intern_leaf(coefficient::F)
        signature = (:leaf, coefficient)
        get!(signatures, signature) do
            push!(nodes, EvalDAGNode(0, coefficient, Tuple{UInt8,Int}[]))
            length(nodes)
        end
    end

    function intern_node(coordinate::Int, branches::Vector{Tuple{UInt8,Int}})
        sort!(branches)
        signature = (coordinate, Tuple(branches))
        get!(signatures, signature) do
            push!(nodes, EvalDAGNode(coordinate, zero(F), copy(branches)))
            length(nodes)
        end
    end

    function compile_polynomial(poly::Poly{F,N})
        isempty(poly.terms) && return 0
        current = Dict{NTuple{N,UInt8},Int}(
            key => intern_leaf(coefficient) for (key, coefficient) in poly.terms)
        for coordinate in N:-1:1
            groups = Dict{NTuple{N,UInt8},Vector{Tuple{UInt8,Int}}}()
            for (key, child) in current
                prefix = ntuple(i -> i < coordinate ? key[i] : UInt8(0), N)
                push!(get!(groups, prefix, Tuple{UInt8,Int}[]),
                      (key[coordinate], child))
            end
            next = Dict{NTuple{N,UInt8},Int}()
            for (prefix, branches) in groups
                next[prefix] = intern_node(coordinate, branches)
            end
            current = next
        end
        only(values(current))
    end

    roots = ntuple(i -> compile_polynomial(polynomials[i]), N)
    maxima = ntuple(coordinate -> begin
        maximum((Int(exponent) for node in nodes if node.coordinate == coordinate
                              for (exponent, _) in node.branches); init=0)
    end, N)
    SharedEvalPlan{F,N}(nodes, roots, maxima)
end

function _evaluate_shared(plan::SharedEvalPlan{F,N}, point::AbstractVector{F}) where {F,N}
    powers = ntuple(coordinate -> begin
        values = Vector{F}(undef, plan.max_exponents[coordinate] + 1)
        values[1] = one(F)
        for exponent in 1:plan.max_exponents[coordinate]
            values[exponent + 1] = values[exponent] * point[coordinate]
        end
        values
    end, N)
    values = Vector{F}(undef, length(plan.nodes))
    for (id, node) in enumerate(plan.nodes)
        if node.coordinate == 0
            values[id] = node.coefficient
            continue
        end
        total = zero(F)
        coordinate_powers = powers[node.coordinate]
        for (exponent, child) in node.branches
            total += coordinate_powers[Int(exponent) + 1] * values[child]
        end
        values[id] = total
    end
    ntuple(i -> plan.roots[i] == 0 ? zero(F) : values[plan.roots[i]], N)
end

struct PCPProof{F,N}
    gs::NTuple{5,Poly{F,N}}
    c0::Poly{F,N}
    cs::NTuple{N,Poly{F,N}}
    decomposition::ZeroDecomposition{F,N}
    d::Int
    eval_plan::SharedEvalPlan{F,N}
end

"The canonical coefficient embedding of a `{0,1}`-coefficient proof."
struct PrimeFieldPCPProof{F,S,N}
    source::PCPProof{S,N}
    d::Int
end

function lift_pcp(proof::PCPProof{S,N}, ::Type{F}; d::Int) where {S,N,F<:GF2k}
    polynomials = (proof.gs..., proof.c0, proof.cs...)
    all(poly -> all(coefficient.bits <= 1 for coefficient in values(poly.terms)),
        polynomials) || throw(ArgumentError("PCP proof is not defined over the prime subfield"))
    PrimeFieldPCPProof{F,S,N}(proof, d)
end

struct PCPView{F,N}
    z::Vector{F}
    alpha::NTuple{5,F}
    beta0::F
    beta::NTuple{N,F}
end

function build_pcp(gs::NTuple{5,Poly{F,N}}, c0::Poly{F,N},
                   decomposition_checked::Checked; d::Int) where {F,N}
    decomposition = decomposition_checked.term
    cs = decomposition.quotients
    length(cs) == N || throw(ArgumentError("zero-basis tuple has wrong arity"))
    typed_cs = ntuple(i -> cs[i]::Poly{F,N}, N)
    eval_plan = _shared_eval_plan(typed_cs)
    proof = PCPProof(gs, c0, typed_cs, decomposition, d, eval_plan)

    build_node = CertNode(CHECKED, :BuildC0;
        facts=(display="inddeg = $(maximum(actual_degrees(c0))); monomials = $(monomial_count(c0))",),
        replay=p -> CheckResult(degree_accounts_valid(p.c0), :c0_degree_accounts;
                                expected=p.c0.structural.bound,
                                actual=p.c0.actual.degrees))
    zero_node = CertNode(CHECKED, :ZeroBasis;
        facts=(display="remainder = $(isempty(decomposition.remainder.terms) ? 0 : monomial_count(decomposition.remainder)); coefficient identity = true",),
        replay=p -> verify_zero_decomposition(p.c0, p.decomposition))
    verifier_node = CertNode(CHECKED, :PCPVerifier;
        facts=(display="formula + zero tests = accept on certified views",),
        replay=p -> CheckResult(length(p.gs) == 5 && length(p.cs) == N,
                                :pcp_shape; expected=(5, N),
                                actual=(length(p.gs), length(p.cs))))
    root = CertNode(CHECKED, :PCPProof;
        facts=(display="polynomials = $(N + 6); d = $(d); shared eval nodes = $(length(eval_plan.nodes))",),
        children=(build_node, zero_node, verifier_node),
        replay=p -> begin
            degree_ok = all(degree_accounts_valid, (p.gs..., p.c0, p.cs...)) &&
                        all(q -> maximum(actual_degrees(q); init=-1) <= p.d, p.cs)
            CheckResult(degree_ok, :pcp_degree;
                        expected="all support degrees <= $(p.d)",
                        actual=maximum((maximum(actual_degrees(q); init=-1)
                                        for q in p.cs); init=-1))
        end)
    Checked(proof, root)
end

function ev_z(proof::PCPProof{F,N}, point::AbstractVector{F}) where {F,N}
    length(point) == N || throw(ArgumentError("PCP point has wrong dimension"))
    alpha = ntuple(i -> evaluate(proof.gs[i], point), 5)
    beta0 = evaluate(proof.c0, point)
    beta = _evaluate_shared(proof.eval_plan, point)
    PCPView(Vector(point), alpha, beta0, beta)
end


function _evaluate_shared_as(plan::SharedEvalPlan{S,N},
                             point::AbstractVector{F}) where {S,N,F<:GF2k}
    maximum_exponent = maximum(plan.max_exponents)
    powers = Matrix{UInt16}(undef, N, maximum_exponent + 1)
    for coordinate in 1:N
        powers[coordinate, 1] = UInt16(1)
        for exponent in 1:plan.max_exponents[coordinate]
            powers[coordinate, exponent + 1] =
                _mul_raw(F, powers[coordinate, exponent], point[coordinate].bits)
        end
    end
    values = Vector{UInt16}(undef, length(plan.nodes))
    for (id, node) in enumerate(plan.nodes)
        if node.coordinate == 0
            node.coefficient.bits <= 1 ||
                throw(ArgumentError("DAG coefficient is outside the prime subfield"))
            values[id] = node.coefficient.bits
            continue
        end
        total = UInt16(0)
        for (exponent, child) in node.branches
            product = _mul_raw(F, powers[node.coordinate, Int(exponent) + 1],
                               values[child])
            total = xor(total, product)
        end
        values[id] = total
    end
    ntuple(i -> plan.roots[i] == 0 ? zero(F) : F(Int(values[plan.roots[i]])), N)
end

function ev_z(proof::PrimeFieldPCPProof{F,S,N},
              point::AbstractVector{F}) where {F,S,N}
    source = proof.source
    length(point) == N || throw(ArgumentError("PCP point has wrong dimension"))
    alpha = ntuple(i -> _evaluate_as(source.gs[i], point), 5)
    beta0 = _evaluate_as(source.c0, point)
    beta = _evaluate_shared_as(source.eval_plan, point)
    PCPView(Vector(point), alpha, beta0, beta)
end

pcp_eval(proof::PCPProof, point) = ev_z(proof, point)
pcp_eval(proof::PrimeFieldPCPProof, point) = ev_z(proof, point)

# gt-10-answer-reduction.tex:1548-1585 (fig:pcpverifier, steps 4-5).
function pcpverifier(tf::TseitinFormula{N}, view::PCPView{F,N}) where {F,N}
    formula_value = evaluate_arith_formula(tf, view.z)
    formula_rhs = formula_value
    for i in 1:5
        formula_rhs *= view.alpha[i] - view.z[5 + i]
    end
    formula_ok = view.beta0 == formula_rhs

    zero_rhs = zero(F)
    for i in 1:N
        zero_rhs += view.beta[i] * view.z[i] * (one(F) - view.z[i])
    end
    zero_ok = view.beta0 == zero_rhs
    CheckResult(formula_ok && zero_ok, :pcpverifier;
                expected=(view.beta0, view.beta0),
                actual=(formula_rhs, zero_rhs),
                formula_ok=formula_ok, zero_ok=zero_ok)
end
