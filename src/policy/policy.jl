# TB7 (DESIGN 12.4, DD-28, DD-31): the construction policy. Production keeps
# the exact source laws and refuses over budget (DD-29); a ToyPolicy
# substitutes only parameter values and the repetition count, attaches an
# ASSUMED `toy_override` child, evaluates every production predicate and
# prints each as PASS, FAIL, NOT_EVALUABLE, VACUOUS or NOT_EXECUTED with its
# owner. Toy mode changes no constructor or parser: the same `compress`
# runs under both policies. A policy is serializable data (so the
# Compressor program of the halting fixed point carries it in its bytes).

abstract type ConstructionPolicy end

"""
    ProductionPolicy(; budget_bits=2^20)

The exact source laws with symbolic universal constants (mu, gamma, tau,
c', the Pauli and PCP tuples are NOT_EVALUABLE without a, b, a', b'); a
materialized vector longer than `budget_bits` is refused as BudgetExceeded.
"""
struct ProductionPolicy <: ConstructionPolicy
    budget_bits::Int
end
ProductionPolicy(; budget_bits::Integer=2^20) = ProductionPolicy(Int(budget_bits))

"""
    ToyPolicy(intro_tuple, pcp_tuple, mu, gamma, tau, c_prime, repetitions, child_fuel=0)

DESIGN 12.4's explicit override: the Pauli tuple (q_I, m_I, d_I), the PCP tuple
(q_A, m_A, d_A, s_A, m'_A) as a PCPParams (k = log2 q_A, gamma), the toy
universal constants, the repetition count, and the child fuel (0 = source R).
"""
struct ToyPolicy <: ConstructionPolicy
    intro_tuple::PauliTuple
    pcp_tuple::PCPParams
    mu::Int
    gamma::Int
    tau::Int
    c_prime::Rational{Int}
    repetitions::Int
    child_fuel::Int
end
function ToyPolicy(; intro_tuple::PauliTuple, pcp_tuple::PCPParams, mu::Integer=1, gamma::Integer=1, tau::Integer=1,
                   c_prime::Union{Integer,Rational}=1 // 1, repetitions::Integer=1, child_fuel::Integer=0)
    repetitions >= 1 || throw(ArgumentError("a toy repetition count is a positive integer"))
    ToyPolicy(intro_tuple, pcp_tuple, Int(mu), Int(gamma), Int(tau), Rational{Int}(c_prime), Int(repetitions), Int(child_fuel))
end
Base.show(io::IO, p::ToyPolicy) = print(io, "ToyPolicy(intro ", p.intro_tuple, ", AR (q,m,d,s,m') = (", p.pcp_tuple.q, ", ", p.pcp_tuple.m, ", ",
                                          p.pcp_tuple.d, ", ", p.pcp_tuple.s, ", ", p.pcp_tuple.m_prime, "), mu = ", p.mu, ", gamma = ", p.gamma,
                                          ", tau = ", p.tau, ", c' = ", p.c_prime, ", repetitions = ", p.repetitions, ", child fuel ",
                                          p.child_fuel == 0 ? "R" : string(p.child_fuel), ")")

"DESIGN 12.5's TB7 tuple: intro (2,1,1); AR (2^11, 1, 11, 6, 16); mu = gamma = tau = c' = 1; repetitions 2; child fuel R."
const TB7_TOY_POLICY = ToyPolicy(; intro_tuple=PauliTuple(2, 1, 1), pcp_tuple=PCPParams(2048, 11, 1, 11, 6, 16, 1),
                                 mu=1, gamma=1, tau=1, c_prime=1 // 1, repetitions=2, child_fuel=0)

policy_mu(::ProductionPolicy) = nothing
policy_mu(p::ToyPolicy) = p.mu
policy_gamma(::ProductionPolicy) = nothing
policy_gamma(p::ToyPolicy) = p.gamma
policy_tau(::ProductionPolicy) = nothing
policy_tau(p::ToyPolicy) = p.tau

# --- serialization (the Compressor program's policy literal) -----------------------
# Production is the empty byte string; a toy policy is 0x01 followed by its
# fourteen integers as u32 big-endian words (q_I, m_I, d_I, q_A, k_A, m_A,
# d_A, s_A, m'_A, gamma_A, mu, gamma, tau, c_num, c_den, repetitions,
# child_fuel).
function policy_bytes(p::ConstructionPolicy)
    p isa ProductionPolicy && return UInt8[]
    buffer = IOBuffer()
    write(buffer, 0x01)
    t, a = p.intro_tuple, p.pcp_tuple
    for v in (t.q, t.m, t.d, a.q, a.k, a.m, a.d, a.s, a.m_prime, a.gamma, p.mu, p.gamma, p.tau,
              numerator(p.c_prime), denominator(p.c_prime), p.repetitions, p.child_fuel)
        _encode_int!(buffer, v)
    end
    take!(buffer)
end
function decode_policy(bytes::AbstractVector{UInt8})
    isempty(bytes) && return ProductionPolicy()
    buffer = IOBuffer(Vector{UInt8}(bytes))
    read(buffer, UInt8) == 0x01 || throw(ArgumentError("unknown policy encoding"))
    v = [_decode_int!(buffer) for _ in 1:17]
    bytesavailable(buffer) == 0 || throw(ArgumentError("trailing policy bytes"))
    ToyPolicy(PauliTuple(v[1], v[2], v[3]), PCPParams(v[4], v[5], v[6], v[7], v[8], v[9], v[10]), v[11], v[12], v[13],
              v[14] // v[15], v[16], v[17])
end

# --- predicates ---------------------------------------------------------------------------
"One printed row of the policy report: name | STATUS(owner=...) with its detail."
struct PolicyPredicate
    name::String
    status::Symbol                 # :PASS, :FAIL, :NOT_EVALUABLE, :VACUOUS, :NOT_EXECUTED
    owner::Union{Nothing,String}
    detail::String
end
const POLICY_STATUSES = (:PASS, :FAIL, :NOT_EVALUABLE, :VACUOUS, :NOT_EXECUTED)
function PolicyPredicate(name::AbstractString, status::Symbol; owner=nothing, detail::AbstractString="")
    status in POLICY_STATUSES || throw(ArgumentError("unknown predicate status $(status)"))
    PolicyPredicate(String(name), status, owner === nothing ? nothing : String(owner), String(detail))
end
"The printed result cell: STATUS or STATUS(owner=...)."
result_text(p::PolicyPredicate) = p.owner === nothing ? String(p.status) : "$(p.status)(owner=$(p.owner))"
"The 13-row report of DESIGN 12.5 as printed: `predicate | result` per line."
predicate_report_text(predicates::Vector{PolicyPredicate}) =
    join(("$(p.name) | $(result_text(p))" for p in predicates), "\n")
"The report as a Markdown table with the details."
function predicate_report_table(predicates::Vector{PolicyPredicate})
    lines = ["| predicate | result | detail |", "|---|---|---|"]
    for p in predicates
        push!(lines, "| $(p.name) | $(result_text(p)) | $(p.detail) |")
    end
    join(lines, "\n")
end

"The ASSUMED toy_override parent with one ASSUMED child per predicate (status and owner as facts)."
function toy_override_node(policy::ToyPolicy, predicates::Vector{PolicyPredicate}; extra::Tuple=())
    children = Tuple(CertNode(ASSUMED, Symbol(replace(p.name, r"[^A-Za-z0-9_]+" => "_"));
                              facts=(display="$(p.name) | $(result_text(p)) ($(p.detail))", predicate=p.name,
                                     status=String(p.status), owner=p.owner))
                     for p in predicates)
    CertNode(ASSUMED, :toy_override;
        facts=(display="ToyPolicy: $(policy); every production equality/admissibility/divisibility/capacity predicate evaluated and printed below (DD-28, DD-31); a failed predicate is a FAIL row with its owner, never folded into PASS; VACUOUS where a guard set is empty or an embedding fails",
               predicates=predicates),
        children=(children..., extra...))
end

# The CHECKED grade validation (M7-grade): every predicate node's recorded
# status equals the status recomputed by `recompute(subject)`, and no node
# labelled PASS has a recomputed FAIL/VACUOUS/NOT_EXECUTED.
function policy_grade_validation_node(predicates::Vector{PolicyPredicate}, recompute::Function)
    replay = subject -> begin
        fresh = recompute(subject)
        ok = length(fresh) == length(predicates) &&
             all(f.name == p.name && f.status == p.status && f.owner == p.owner for (f, p) in zip(fresh, predicates))
        forged = [p.name for (f, p) in zip(fresh, predicates) if p.status == :PASS && f.status != :PASS]
        CheckResult(ok && isempty(forged), :policy_grade; location=:PolicyGradeValidation,
                    expected=[(p.name, p.status) for p in predicates], actual=[(f.name, f.status) for f in fresh])
    end
    CertNode(CHECKED, :PolicyGradeValidation;
        facts=(display="every predicate's printed status is recomputed from the constructed objects and must agree; a FAIL/VACUOUS/NOT_EXECUTED predicate printed PASS is a certificate failure (M7-grade)",),
        replay=replay)
end

# The CHECKED toy-eligibility audit: a ToyPolicy result never satisfies a
# theorem contract while a required production predicate fails (DESIGN
# 12.4); the replay REFUSES at the first failed predicate, exactly as the
# HypothesisAudit of a contract refuses a violated hypothesis.
function toy_contract_audit_node(predicates::Vector{PolicyPredicate})
    failed = [p.name for p in predicates if p.status in (:FAIL, :NOT_EXECUTED)]
    CertNode(CHECKED, :ToyContractAudit;
        facts=(display=isempty(failed) ? "every production predicate holds: the theorem contracts may be invoked" :
                       "theorem contracts NOT invoked: $(length(failed)) production predicate(s) fail under the ToyPolicy ($(join(failed, "; "))) -- a toy result establishes construction behaviour only (DESIGN 12.4)",
               failed=failed),
        replay=x -> isempty(failed) ? CheckResult(true, :toy_predicate_failed; location=:ToyContractAudit) :
                    CheckResult(false, :toy_predicate_failed; location=Symbol(replace(failed[1], r"[^A-Za-z0-9_]+" => "_")),
                                expected=:PASS, actual=failed))
end
