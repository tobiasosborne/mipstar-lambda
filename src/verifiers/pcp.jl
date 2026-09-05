@enum PredicateStatus PASS FAIL NOT_EVALUABLE

struct PCPParams
    q::Int
    k::Int
    m::Int
    d::Int
    s::Int
    m_prime::Int
    gamma::Int
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
    tail = tail_lhs <= 1 // big(params.s)^params.gamma ? PASS :
           tail_lhs >= 1 ? FAIL : NOT_EVALUABLE
    divisibility = params.q % params.m_prime == 0
    degree = params.d == params.k
    formula_structural = 2 * (degree_formula + 5params.d) * params.m_prime < params.q
    zero_test = 2 * (2 + params.d) * params.m_prime < params.q
    exponent_range = params.d <= params.q - 1
    # With a'>1 and 0<b'<1, the growth RHS is strictly greater than
    # (gamma+3)log2(s).  A value below that lower bound fails for the full
    # admissible range; without an upper bound on a'/b', none can pass it.
    growth = params.k <= (params.gamma + 3) * log2(params.s) ?
             FAIL : NOT_EVALUABLE
    ParameterPolicy(_status(shape), growth, _status(formula_paper), tail,
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
        divisibility = q % m_prime == 0
        structural && paper && zero_test && divisibility && return k
    end
    nothing
end

function build_c0(farith::Poly{F,N}, gs::NTuple{5,Poly{F,N}},
                  budget::MonomialBudget) where {F,N}
    result = farith
    sign_coordinates = block_coordinates(farith.layout, :O)
    length(sign_coordinates) == 5 ||
        throw(ArgumentError("the PCP sign block must have five coordinates"))
    for (i, sign_coordinate) in enumerate(sign_coordinates)
        factor = gs[i] - polyvar(F, farith.layout, sign_coordinate)
        multiplied = mul_poly(result, factor, budget)
        multiplied isa ExpansionRefused && return multiplied
        result = multiplied
    end
    certificate = CertNode(CHECKED, :BuildC0;
        facts=(display="inddeg = $(maximum(actual_degrees(result))); monomials = $(monomial_count(result))",),
        replay=p -> CheckResult(degree_accounts_valid(p), :c0_degree_accounts;
                                expected=p.structural.bound, actual=p.actual.degrees))
    Checked(result, certificate)
end


build_c0(farith::Poly, gs::NTuple{5,Poly};
         budget=MonomialBudget(typemax(Int))) = build_c0(farith, gs, budget)

struct PCPView{F,N}
    z::Vector{F}
    alpha::NTuple{5,F}
    beta0::F
    beta::NTuple{N,F}
end

struct PCPProof{F,N}
    gs::NTuple{5,Poly{F,N}}
    c0::Poly{F,N}
    cs::NTuple{N,Poly{F,N}}
    decomposition::ZeroDecomposition{F,N}
    d::Int
    tf::TseitinFormula{N}
    certified_views::Tuple
end

function _replay_pcp_c0(proof::PCPProof)
    CheckResult(degree_accounts_valid(proof.c0), :c0_degree_accounts;
                expected=proof.c0.structural.bound,
                actual=proof.c0.actual.degrees)
end

_replay_pcp_zero(proof::PCPProof) =
    verify_zero_decomposition(proof.c0, proof.decomposition)

function _replay_pcp_degree(proof::PCPProof)
    polynomials = (proof.gs..., proof.c0, proof.cs...)
    degree_ok = all(degree_accounts_valid, polynomials) &&
                all(p -> maximum(actual_degrees(p); init=-1) <= proof.d,
                    polynomials)
    CheckResult(degree_ok, :pcp_degree;
                expected="all support degrees <= $(proof.d)",
                actual=maximum((maximum(actual_degrees(p); init=-1)
                                for p in polynomials); init=-1))
end

function _pcp_view(gs::NTuple{5,Poly{F,N}}, c0::Poly{F,N},
                   cs::NTuple{N,Poly{F,N}},
                   point::AbstractVector{F}) where {F,N}
    polynomials = (gs..., c0, cs...)
    powers = _shared_power_table(polynomials, point)
    alpha = ntuple(i -> _evaluate_terms(gs[i], powers), 5)
    beta0 = _evaluate_terms(c0, powers)
    beta = ntuple(i -> _evaluate_terms(cs[i], powers), N)
    PCPView(Vector(point), alpha, beta0, beta)
end

function _bind_certificate(node::CertNode, term)
    children = map(child -> _bind_certificate(child, term), node.children)
    replay = node.grade == CHECKED ? (_ -> node.replay(term)) : node.replay
    CertNode(node.grade, node.rule; facts=node.facts, children, replay)
end

_bind_certificate(checked::Checked) =
    _bind_certificate(checked.certificate, checked.term)

function _replay_pcp_verifier(proof::PCPProof)
    isempty(proof.certified_views) &&
        return CheckResult(false, :pcpverifier_replay;
                           expected=:stored_view, actual=:none)
    for view in proof.certified_views
        result = pcpverifier(proof.tf, view)
        passed(result) || return result
    end
    CheckResult(true, :pcpverifier_replay;
                expected=:both_equations, actual=:accepted)
end

# Certified views go through `ev_z`, so every stored view has passed the
# block-locality guard; a bare `_pcp_view` never reaches a certificate.
function _certified_views(proof::PCPProof, certified_points::Tuple)
    map(point -> ev_z(proof, point), certified_points)
end

# Upstream nodes for a proof whose constructors left no evidence of their own
# (a field change, or `build_pcp` called without `evidence`). Both displays are
# computed from the attached term; nothing here is a literal.
function _pcp_upstream_nodes(c0::Poly, decomposition::ZeroDecomposition)
    (CertNode(CHECKED, :BuildC0;
         facts=(display="inddeg = $(maximum(actual_degrees(c0))); monomials = $(monomial_count(c0))",),
         replay=_replay_pcp_c0),
     CertNode(CHECKED, :ZeroBasis;
         facts=(display=zero_basis_display(c0, decomposition),),
         replay=_replay_pcp_zero))
end

function _certify_pcp(proof::PCPProof{F,N}, upstream::Tuple, display::String) where {F,N}
    verifier_node = CertNode(CHECKED, :PCPVerifier;
        facts=(display="formula + zero tests = accept on $(length(proof.certified_views)) stored certified views",),
        replay=_replay_pcp_verifier)
    root = CertNode(CHECKED, :PCPProof;
        facts=(display=display,),
        children=(upstream..., verifier_node),
        replay=_replay_pcp_degree)
    Checked(proof, root)
end

function build_pcp(tf::TseitinFormula{N}, gs::NTuple{5,Poly{F,N}},
                   c0::Poly{F,N}, decomposition_checked::Checked, d::Int,
                   certified_points::Tuple, evidence::Tuple) where {F,N}
    decomposition = decomposition_checked.term
    cs = decomposition.quotients
    length(cs) == N || throw(ArgumentError("zero-basis tuple has wrong arity"))
    typed_cs = ntuple(i -> cs[i]::Poly{F,N}, N)
    bare = PCPProof(gs, c0, typed_cs, decomposition, d, tf, ())
    proof = PCPProof(gs, c0, typed_cs, decomposition, d, tf,
                     _certified_views(bare, certified_points))
    upstream = isempty(evidence) ? _pcp_upstream_nodes(c0, decomposition) :
               map(_bind_certificate, evidence)
    _certify_pcp(proof, upstream,
                 "polynomials = $(N + 6); d = $(d); sparse terms are authoritative")
end

function ev_z(proof::PCPProof{F,N}, point::AbstractVector{F}) where {F,N}
    length(point) == N || throw(ArgumentError("PCP point has wrong dimension"))
    for i in 1:5
        coordinates = Set(block_coordinates(proof.gs[i].layout, Symbol("X", i)))
        dependency_coordinates(proof.gs[i]) <= coordinates ||
            throw(ArgumentError("g_$i depends outside its declared input block"))
    end
    _pcp_view(proof.gs, proof.c0, proof.cs, point)
end

"""
    change_field(proof, F, d, certified_points=())

Change a `{0,1}`-coefficient PCP proof to another binary extension field and
re-certify it: the root replay re-derives the `def:pcp-proof` degree condition
for the relabelled `d` on every `g_i`, `c_0`, `c_j`, the `:BuildC0` and
`:ZeroBasis` replays run on the changed polynomials, and the `:PCPVerifier`
node holds views evaluated (through `ev_z`) at `certified_points`, which are
points of the TARGET field: a source-field point such as `b_rho` has no image
under a change between fields of coprime degree, so views are re-evaluated,
never transported.
"""
function change_field(proof::PCPProof{S,N}, ::Type{F}, d::Int,
                      certified_points::Tuple) where {S<:GF2k,F<:GF2k,N}
    polynomials = (proof.gs..., proof.c0, proof.cs...)
    all(poly -> all(coefficient.bits <= 1 for coefficient in values(poly.terms)),
        polynomials) || throw(ArgumentError("PCP proof is not defined over the prime subfield"))
    gs = ntuple(i -> change_field(proof.gs[i], F), 5)
    c0 = change_field(proof.c0, F)
    decomposition = change_field(proof.decomposition, F)
    cs = ntuple(i -> decomposition.quotients[i]::Poly{F,N}, N)
    bare = PCPProof(gs, c0, cs, decomposition, d, proof.tf, ())
    changed = PCPProof(gs, c0, cs, decomposition, d, proof.tf,
                       _certified_views(bare, certified_points))
    _certify_pcp(changed, _pcp_upstream_nodes(c0, decomposition),
                 "field change $(S) -> $(F); polynomials = $(N + 6); d = $(d); re-certified from the changed terms")
end

change_field(proof::PCPProof{S,N}, ::Type{F}, d::Int) where {S<:GF2k,F<:GF2k,N} =
    change_field(proof, F, d, ())

# gt-10-answer-reduction.tex:1548-1585 (fig:pcpverifier, steps 4-5).
function pcpverifier(tf::TseitinFormula{N}, view::PCPView{F,N}) where {F,N}
    formula_value = evaluate_arith_formula(tf, view.z)
    formula_rhs = formula_value
    sign_coordinates = block_coordinates(tf.layout, :O)
    length(sign_coordinates) == 5 ||
        return CheckResult(false, :pcpverifier;
                           expected=:five_sign_coordinates,
                           actual=Tuple(sign_coordinates))
    for (i, sign_coordinate) in enumerate(sign_coordinates)
        formula_rhs *= view.alpha[i] - view.z[sign_coordinate]
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
