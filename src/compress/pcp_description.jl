# TB7 (DESIGN 12.2, 12.5; briefs/44): TB2's typed PCP sampler of
# sec:ld-compiler as a COMPACT description primitive
#   (:PCP, q, m, d, s, m_prime, gamma, sigma)
# carrying the pcpparams tuple (def:pcpparams, gt-10-answer-reduction.tex:
# L1396-L1422) and sigma = |D| -- the description length thm:ar makes the
# sampler depend on (L2094-L2096) -- rather than the 18 x 2 CL leaf terms
# (a TypedFamily of ~200 KB at m' = 16; DD-29 compact descriptions). The
# machine is the in-memory family of `pcp_sampler(F, params)`: 18 types,
# the complete type graph, level 3, dimension 2m' + 6 over F_q.

const _PCP_MACHINE_CACHE = Dict{NTuple{7,Int},Any}()

pcp_params_of(term) = PCPParams(term[2], round(Int, log2(term[2])), term[3], term[4], term[5], term[6], term[7])

"The TB2 in-memory typed PCP sampler of a (:PCP, ...) term (cached by its parameters)."
function pcp_family(term)
    key = Tuple(term[2:8])
    get!(_PCP_MACHINE_CACHE, key) do
        params = pcp_params_of(term)
        F = _field_type(params.q)
        pcp_sampler(F, params).term
    end
end

function _compile_pcp(term)
    q = term[2]
    (q >= 2 && ispow2(q) && term[3] >= 1 && term[4] >= 1 && term[5] >= 1 && term[6] >= 1 && term[8] >= 0) ||
        throw(ArgumentError("the PCP family needs an explicit tuple (q, m, d, s, m') with q a power of two and sigma >= 0"))
    F = _field_type(q)
    sampler = pcp_family(term)
    labels = String[string(t) for t in sampler.types]
    typing = Typed(labels, [(string(l), string(r)) for (l, r) in sampler.type_graph])
    index = Dict(string(t) => t for t in sampler.types)
    leaf = Dict{Tuple{Symbol,Any},AbstractCL{F}}()
    for label in labels
        leaf[(:alice, label)] = sampler.left[index[label]]
        leaf[(:bob, label)] = sampler.right[index[label]]
    end
    LeafMachine{F}(q, seed_dim(sampler), level(sampler), typing, leaf)
end

const CITED_PCP_DECIDER = _cited("thm:pcp-decider", "gt-10-answer-reduction.tex", 1455:1533,
    "general completeness/soundness of the PCP decider; the concrete predicate, polynomial identities and TB fixture are executed")
const CITED_LD_SOUNDNESS = _cited("lem:ld-soundness", "gt-07-ldt.tex", 413:490,
    "quantum low-degree enforcement (soundness of the classical low-degree test against entangled provers); never executed")
const CITED_LD_COMPLEXITY = _cited("lem:ld-complexity", "gt-07-ldt.tex", 413:490,
    "the general asymptotic implementation bound of the low-degree test; never executed")
const CITED_PADDED_SUCCINCT = _cited("prop:explicit-padded-succinct-deciders", "gt-10-answer-reduction.tex", 1226:1275,
    "m(T, sigma) = O(log T + log sigma) with 2^m >= 2T and the s(n, T, Q, sigma)-gate padded succinct circuit of a decider; the general faithfulness and asymptotics stay CITED")
const CITED_STANDARD_SUCCINCT = _cited("prop:standard-succinct-sat", "gt-10-answer-reduction.tex", 237:276,
    "the standard Cook-Levin succinct 3SAT of a bounded computation; the fixture front end is a finite surrogate")

"""
    pcp_description(params::PCPParams, sigma; tracer_index=1, seeds=32) :: Checked{SamplerDescription}

(:PCP, q, m, d, s, m', gamma, sigma): the compact typed PCP family with the
DESIGN 9.6 rows and the CITED PCP leaves of the residue inventory (items 1, 2, 6).
"""
function pcp_description(params::PCPParams, sigma::Integer; tracer_index::Integer=1, seeds::Integer=32)
    term = (:PCP, params.q, params.m, params.d, params.s, params.m_prime, params.gamma, Int(sigma))
    _composite(:PCPSampler, term, (), (CITED_PCP_DECIDER, CITED_LD_SOUNDNESS, CITED_LD_COMPLEXITY, CITED_PADDED_SUCCINCT,
                                       CITED_STANDARD_SUCCINCT, CITED_TYPED_SAMPLER, CITED_CL_KTH);
               tracer_index=Int(tracer_index), seeds=Int(seeds),
               expected=(; field=params.q, level=3, dimension=2 * params.m_prime + 6, query_time=:(TIME_S(n))),
               expected_calls=0, call_law="a primitive family answers without child calls",
               display="compact PCP family (:PCP) over F_$(params.q): 18 types (Point/ALine/DLine x 6 copies), complete type graph, level 3, dimension 2m'+6 = $(2 * params.m_prime + 6); pcpparams tuple (q, k, m, d, s, m') = ($(params.q), $(params.k), $(params.m), $(params.d), $(params.s), $(params.m_prime)), gamma = $(params.gamma), sigma = |D| = $(sigma) carried in the bytes (thm:ar: S^ar depends on |D|)")
end
