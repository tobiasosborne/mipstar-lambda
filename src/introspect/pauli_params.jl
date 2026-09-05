# TB6 (DESIGN 11.1, 11.6, 12.4): the canonical Pauli parameters
# introparams(R) of def:introparams (gt-07-ldt.tex:L1503-L1514) as a symbolic
# AST in the universal constants a, b of thm:pauli, the explicit toy tuple
# (q, m, d), and the policy report evaluating every production predicate as
# PASS / FAIL / NOT_EVALUABLE / VACUOUS (DD-28, DD-31).

"Definition def:introparams as closed law ASTs in the symbols a, b, R (gt-07:L1503-L1514)."
function introparams_ast()
    (; c=:(smallest_even_integer_at_least((b + a) / b)),
       k=:(c * ceil(log2(log2(R))) + 1),
       q=:(2 ^ (c * ceil(log2(log2(R))) + 1)),
       m=:(largest_power_of_two_at_most(c * ceil(log2(R)) + 1)),
       d=1,
       M=:(2 ^ m), Q=:(2 ^ m * log2(q)))
end

"The explicit tuple (q, m, d) with its derived M = 2^m, Q = M log2 q."
struct PauliTuple
    q::Int
    m::Int
    d::Int
end
Base.show(io::IO, t::PauliTuple) = print(io, "(q, m, d) = (", t.q, ", ", t.m, ", ", t.d, ")")
pauli_M(t::PauliTuple) = 2 ^ t.m
pauli_Q(t::PauliTuple) = pauli_M(t) * round(Int, log2(t.q))
pauli_log_q(t::PauliTuple) = round(Int, log2(t.q))

"introparams(R) evaluated for an explicit even c >= 2 (never for a symbolic c)."
function introparams_numeric(R::Integer, c::Integer)
    (R >= 4 && c >= 2 && iseven(c)) || throw(ArgumentError("def:introparams needs R >= 4 and an even c >= 2"))
    loglog = ceil(Int, log2(ceil(Int, log2(R))))
    k = c * loglog + 1
    bound = c * ceil(Int, log2(R)) + 1
    j = floor(Int, log2(bound))
    PauliTuple(2 ^ k, 2 ^ j, 1)
end

# Every predicate of the policy report is a CertNode with a status
# (PASS / FAIL / NOT_EVALUABLE / VACUOUS) and a printed detail. VACUOUS is
# used only where DESIGN 12.4 demands it (empty guard sets, a low-degree
# margin >= 1/2), never folded into PASS.
@enum PolicyStatus P_PASS P_FAIL P_NOT_EVALUABLE P_VACUOUS
_status_name(s::PolicyStatus) = s == P_PASS ? "PASS" : s == P_FAIL ? "FAIL" : s == P_NOT_EVALUABLE ? "NOT_EVALUABLE" : "VACUOUS"

struct PolicyLine
    name::Symbol
    status::PolicyStatus
    detail::String
    owner::Union{Nothing,String}
end
function Base.show(io::IO, l::PolicyLine)
    print(io, String(l.name), " ", _status_name(l.status))
    l.owner === nothing || print(io, "(owner=", l.owner, ")")
    print(io, " (", l.detail, ")")
end

"Is q = 2^k with k odd (def:admissible-size, gt-03-prelim.tex:L664-L666)?"
function admissible_field_size(q::Integer)
    q >= 2 && ispow2(q) || return (false, "q = $(q) is not a power of two")
    k = round(Int, log2(q))
    (isodd(k), "$(q) = 2^$(k), k $(isodd(k) ? "odd" : "even")")
end

"""
    pauli_policy_report(t::PauliTuple; R, s_N, lambda, description_bytes, child_time, F_child, ell)

The DESIGN 11.6 policy report for an explicit toy tuple: R >= 4, the
admissible field, m | q, d = 1, the capacity chain s(N) <= R <= M <= Q link
by link, the consequent Q >= R, the embedding Q >= s(N), the canonical
introparams(R) equality (FAIL with the even-c obstruction printed), the
description predicate |V| <= lambda, TIME_child(N) <= R per mode (from
measured step counts or NOT_EVALUABLE), the toy fuel equality F_child = R,
the low-degree margin d m / q (VACUOUS when >= 1/2) and the enu:hiding-same
guard set (VACUOUS when ell = 1).
"""
function pauli_policy_report(t::PauliTuple; R::Integer, s_N::Integer, lambda::Integer, description_bytes::Integer,
                             child_time::Union{Nothing,Dict{Symbol,Int}}=nothing, F_child::Integer=0, ell::Integer=1)
    lines = PolicyLine[]
    M, Q = pauli_M(t), pauli_Q(t)
    push!(lines, PolicyLine(:R_at_least_4, R >= 4 ? P_PASS : P_FAIL, "R = $(R) >= 4 (def:introparams)", nothing))
    adm, why = admissible_field_size(t.q)
    push!(lines, PolicyLine(:admissible_field, adm ? P_PASS : P_FAIL, "admissible odd-extension field: $(why)", nothing))
    push!(lines, PolicyLine(:m_divides_q, t.q % t.m == 0 ? P_PASS : P_FAIL, "m | q: $(t.m) | $(t.q)", nothing))
    push!(lines, PolicyLine(:d_equals_1, t.d == 1 ? P_PASS : P_FAIL, "d = $(t.d)", nothing))
    push!(lines, PolicyLine(:capacity_s_le_R, s_N <= R ? P_PASS : P_FAIL, "s(N) <= R: $(s_N) <= $(R)", nothing))
    push!(lines, PolicyLine(:capacity_M_ge_R, M >= R ? P_PASS : P_FAIL, "M >= R (lem:delta-bound): $(M) $(M >= R ? ">=" : "<") $(R)", nothing))
    push!(lines, PolicyLine(:capacity_M_le_Q, M <= Q ? P_PASS : P_FAIL, "M <= Q: $(M) <= $(Q)", nothing))
    push!(lines, PolicyLine(:consequent_Q_ge_R, Q >= R ? P_PASS : P_FAIL, "Q >= R: $(Q) $(Q >= R ? ">=" : "<") $(R)", nothing))
    push!(lines, PolicyLine(:embedding_Q_ge_s, Q >= s_N ? P_PASS : P_FAIL, "Q >= s(N) (the F_2^Q wire embedding, gt-08:L524-L530): $(Q) >= $(s_N)", nothing))
    # Canonical equality: q = 2^k forces k = c ceil(log log R) + 1, so c = (k - 1)/loglog.
    loglog = R >= 4 ? ceil(Int, log2(ceil(Int, log2(R)))) : 0
    k = pauli_log_q(t)
    canonical = if R < 4 || loglog == 0 || (k - 1) % loglog != 0
        (P_FAIL, "no integer c with 2^(c*ceil(log2 log2 R)+1) = $(t.q) (ceil(log2 log2 $(R)) = $(loglog))")
    else
        c = (k - 1) ÷ loglog
        if c < 2 || isodd(c)
            candidates = join(("c=$(cc) -> m=$(introparams_numeric(R, cc).m)" for cc in (2,)), "; ")
            forced = c >= 1 ? "even that forbidden c=$(c) gives m=$(2 ^ floor(Int, log2(c * ceil(Int, log2(R)) + 1)))" : "c=$(c) forbidden"
            (P_FAIL, "matching exponent $(k) = c*$(loglog)+1 requires c = $(c), forbidden (c even, c >= 2); $(forced); least allowed even $(candidates); tuple m = $(t.m)")
        else
            canon = introparams_numeric(R, c)
            (canon == t ? P_PASS : P_FAIL, "introparams($(R)) at c = $(c) is $(canon), tuple $(t)")
        end
    end
    push!(lines, PolicyLine(:canonical_introparams, canonical[1], canonical[2], nothing))
    push!(lines, PolicyLine(:description_le_lambda, description_bytes <= lambda ? P_PASS : P_FAIL,
                            "|V| <= lambda: $(description_bytes) bytes $(description_bytes <= lambda ? "<=" : ">") $(lambda)", nothing))
    for mode in (:Dimension, :Marginal, :Factor, :Linear, :Decider)
        if child_time === nothing || !haskey(child_time, mode)
            push!(lines, PolicyLine(Symbol("TIME_child_", mode, "_le_R"), P_NOT_EVALUABLE, "no metered trace for $(mode)", "tb6-child-meter"))
        else
            cost = child_time[mode]
            push!(lines, PolicyLine(Symbol("TIME_child_", mode, "_le_R"), cost <= R ? P_PASS : P_FAIL,
                                    "finite honest $(mode) cost $(cost) steps $(cost <= R ? "<=" : ">") R = $(R) (a finite maximum, not the source TIME bound)", "tb6-child-meter"))
            F_child > 0 && push!(lines, PolicyLine(Symbol("fit_F_child_", mode), cost <= F_child ? P_PASS : P_FAIL,
                                                   "finite honest $(mode) cost $(cost) $(cost <= F_child ? "<=" : ">") F_child = $(F_child)", "tb6-child-meter"))
        end
    end
    F_child > 0 && push!(lines, PolicyLine(:toy_child_fuel, F_child == R ? P_PASS : P_FAIL,
                                           "F_child = R: $(F_child) $(F_child == R ? "==" : "!=") $(R)", "tb6-child-meter"))
    margin = t.d * t.m // t.q
    push!(lines, PolicyLine(:low_degree_margin, margin < 1 // 2 ? P_PASS : P_VACUOUS,
                            "dm/q = $(t.d)*$(t.m)/$(t.q) = $(margin) $(margin < 1 // 2 ? "< 1/2 (live)" : ">= 1/2 (vacuous margin)")", nothing))
    push!(lines, PolicyLine(:hiding_same_guard_set, ell >= 2 ? P_PASS : P_VACUOUS,
                            "enu:hiding-same quantifies k in {1..ell-1} = $(ell >= 2 ? "{1..$(ell - 1)}" : "{} (empty)")", nothing))
    lines
end

"The report as printed lines."
policy_report_text(lines::Vector{PolicyLine}) = join((string(l) for l in lines), "\n")

"The policy report as ASSUMED CertNodes (one per predicate) under an ASSUMED toy_override parent."
function policy_report_nodes(lines::Vector{PolicyLine}, t::PauliTuple, R::Integer, F_child::Integer)
    children = Tuple(CertNode(ASSUMED, l.name; facts=(display=string(l), status=_status_name(l.status), owner=l.owner)) for l in lines)
    CertNode(ASSUMED, :toy_override;
        facts=(display="ToyPolicy: explicit Pauli tuple $(t) instead of introparams($(R)) (NOT_EVALUABLE: a, b of thm:pauli are symbols), child fuel $(F_child == 0 ? "= source R = $(R)" : "F_child = $(F_child) steps (source R = $(R))"); every production predicate printed below (DD-28, DD-31)",),
        children=children)
end
