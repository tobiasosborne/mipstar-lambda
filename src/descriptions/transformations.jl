# DESIGN 9.4 / 9.6: the description-level constructors. Each one builds the
# composite TERM from its children's terms (so its bytes are a pure function
# of the children's bytes and its parameters), compiles it, derives the
# header laws, and returns Checked{SamplerDescription, CertNode} with the
# mandatory rows of DESIGN 9.6's table: LawCert, exact byte length, the
# dependency set replayed against the bytes, the enu:cl-space-sum /
# enu:cl-map-sum replay of the OUTPUT sampler on a declared chain set, the
# metered child-call count, and CITED leaves for the semantic lemma.

# --- laws derived from a term ------------------------------------------------

# The constructor's own emission of DESIGN 9.4's laws, spelled out per
# term (the LawCert compares it with the separately transcribed table
# `expected_laws` in laws.jl).
function _term_laws(term, parts::Tuple)
    tag = term[1]
    if tag in (:Pair, :TypedFamily, :Pauli, :Intro, :Graph)
        m = compile_sampler(term)
        return (; field=m.q, level=m.level, dimension=m.dim, query_time=:(TIME_S(n)), k=nothing)
    end
    r = length(parts)
    ells = [Symbol("ell_$i") for i in 1:r]
    ss = [:($(Symbol("s_$i"))(n)) for i in 1:r]
    Cs = [:($(Symbol("C_$i"))(n)) for i in 1:r]
    tag == :DirectSum && return (; field=:q_1, level=_max_law(ells), dimension=_sum_law(ss),
                                   query_time=:($(r) + $(_sum_law(Cs))), k=nothing)
    tag == :Product && return (; field=:q_1, level=:(max(ell_1, ell_2)), dimension=:(s_1(n) + s_2(n)),
                                 query_time=:(C_1(n) + C_2(n)), k=nothing)
    tag == :Downsize && return (; field=2, level=:ell_1, dimension=:(s_1(n) * log2(q_1)),
                                  query_time=:(C_1(n) * log2(q_1)), k=nothing)
    tag == :Detype && return (; field=2, level=:(ell_1 + 2), dimension=:(s_1(n) + 4 * TypeCount),
                                query_time=:(poly(TypeCount, C_1(n))), k=nothing)
    tag == :Anchor && return (; field=2, level=:ell_1, dimension=:(s_1(n)), query_time=:(poly(C_1(n))), k=nothing)
    tag == :Repeat && return (; field=2, level=:ell_1, dimension=:(k(n) * s_1(n)), query_time=:(k(n) * C_1(n)), k=K_REP_LAW)
    throw(ArgumentError("unknown sampler term $(tag)"))
end

# Build the record from a term; `parts` are the constructor's inputs (for
# certificate relocation) or, on decode, the recursively decoded children.
function _from_term(term; parts=nothing, evidence=nothing)
    children = parts === nothing ? Tuple(_from_term(c) for c in _term_children(term)) : parts
    bytes = sampler_term_bytes(term)
    m = compile_sampler(term)
    laws = _term_laws(term, children)
    SamplerDescription(Quoted{:SamplerMachine}(bytes), term, machine_field_size(m), laws.field,
                       machine_level(m), laws.level, machine_typing(m), laws.dimension, laws.query_time,
                       length(bytes), dependency_walk(bytes), laws.k, children, evidence, Ref{Any}(m))
end

"Decode canonical sampler-description bytes back to a SamplerDescription (re-imposing every leaf's ambient partition)."
decode_sampler(bytes::AbstractVector{UInt8}) = _from_term(decode_sampler_term(bytes))
decode_sampler(S::SamplerDescription) = decode_sampler(canonical_bytes(S))
_desc(x::Checked) = x.term
_desc(x::SamplerDescription) = x
_desc_cert(x::Checked) = x.certificate
_desc_cert(::SamplerDescription) = CertNode(CONSTRUCTED, :SamplerDescription; facts=(display="unattested input description",))

# --- the declared chain set at a tracer index -------------------------------

"""
    tracer_chain_set(S, n; seeds, limit, rng_seed) -> (seeds, chain_set_id)

Exhaustive over F_q^s when q^s <= limit, otherwise `seeds` RNG seeds from
MersenneTwister(rng_seed). The id names the choice (DESIGN 9.2).
"""
function tracer_chain_set(S::SamplerDescription, n::Integer; seeds::Int=32, limit::Int=512, rng_seed::Integer=0x5A)
    F = _field(machine(S))
    s = _raise(Dimension(S, n))
    q = field_size(F)
    if big(q)^s <= limit
        return (collect(enumerate_seeds(F, s)), "tb5-exhaustive-$(q)^$(s)@n=$(n)")
    end
    rng = MersenneTwister(rng_seed)
    elements = field_elements(F)
    ([ntuple(_ -> rand(rng, elements), s) for _ in 1:seeds], "tb5-rng$(seeds)(0x$(string(rng_seed; base=16)))@n=$(n)")
end

"""
    sampler_validity(S, n, seeds; chain_set_id)

DESIGN 9.2's two lem:cl-kth obligations replayed through the four queries
on every (player, type) view of the description at index n.
"""
function sampler_validity(S::SamplerDescription, n::Integer, seeds; chain_set_id::AbstractString)
    views = S.typing isa Untyped ? [(w, nothing) for w in PLAYERS] :
                                   [(w, t) for w in PLAYERS for t in S.typing.labels]
    reports = [(; w, type=t, report=cl_kth_replay(described_cl(S, n, w, t), seeds; chain_set_id))
               for (w, t) in views]
    (; ok=all(r.report.space_sum_ok && r.report.map_sum_ok for r in reports), reports)
end

function _validity_display(validity, chain_set_id)
    per_view = join(("$(r.w)$(r.type === nothing ? "" : "/" * r.type): chains $(r.report.distinct_chains)/replays $(r.report.completed_replays)"
                     for r in validity.reports), "; ")
    "enu:cl-space-sum and enu:cl-map-sum (lem:cl-kth, gt-04-cl.tex:151-180) replayed through Dimension/Marginal/Factor/Linear on chain set $(chain_set_id): $(per_view)"
end

# --- certificate rows ----------------------------------------------------------

function _size_node(S::SamplerDescription)
    replay = x -> begin
        reserialized = sampler_term_bytes(x.term)
        ok = length(reserialized) == x.description_size == length(canonical_bytes(x)) &&
             reserialized == canonical_bytes(x) &&
             canonical_bytes(decode_sampler(canonical_bytes(x))) == canonical_bytes(x)
        CheckResult(ok, :description_size; location=:DescriptionSize, expected=x.description_size, actual=length(reserialized))
    end
    CertNode(CHECKED, :DescriptionSize;
        facts=(display="description_size = length(canonical_bytes(code)) = $(S.description_size) bytes, reserialized and decoded round trip; fnv1a64 = $(quote_hash(S))",),
        replay=_bound_replay(S, :DescriptionSize, replay))
end

function _dependency_node(S::SamplerDescription)
    replay = x -> CheckResult(dependency_walk(canonical_bytes(x)) == x.dependency_set, :dependency_set;
                              location=:DependencySet, expected=x.dependency_set, actual=dependency_walk(canonical_bytes(x)))
    CertNode(CHECKED, :DependencySet;
        facts=(display="syntax walk over the embedded leaf descriptions and parameter literals = {$(join(sort(string.(collect(S.dependency_set))), ", "))}",),
        replay=_bound_replay(S, :DependencySet, replay))
end

function _validity_node(S::SamplerDescription, n::Int, seeds, chain_set_id::String; promoted::Bool=false)
    dimension = Dimension(S, n)
    if dimension isa QueryError
        display = "NOT REPLAYABLE at n = $(n): $(dimension.reason)"
        replay = x -> CheckResult(false, :sampler_validity; location=:SamplerValidity, expected=:replayable, actual=dimension.reason)
        return CertNode(CHECKED, :SamplerValidity; facts=(; display, chain_set_id, ok=false), replay=_bound_replay(S, :SamplerValidity, replay))
    end
    validity = sampler_validity(S, n, seeds; chain_set_id)
    replay = x -> begin
        v = sampler_validity(x, n, seeds; chain_set_id)
        CheckResult(v.ok, :sampler_validity; location=:SamplerValidity, expected=true,
                    actual=[(r.w, r.type, r.report.space_sum_ok, r.report.map_sum_ok) for r in v.reports])
    end
    CertNode(CHECKED, :SamplerValidity;
        facts=(display=_validity_display(validity, chain_set_id), chain_set_id, ok=validity.ok,
               reports=validity.reports),
        children=promoted ? (ZERO_MAP_FACTOR_PARTITION,) : (),
        replay=_bound_replay(S, :SamplerValidity, replay))
end

# Child calls per query at index n: the Marginal at the top stage on every
# chain-set seed (the maximum over seeds is the law's count; a seed that
# reveals no type or no reachable block issues fewer), Factor and Linear at
# stage 1 on the zero prefix, all three pinned exactly; `at_most` laws
# (detype, anchor) are bounds (verdicts/tb5-r1.md O2).
function _metered_node(S::SamplerDescription, n::Int, expected::Int, law::String, seeds; at_most::Bool=false)
    counts(x) = begin
        s = _raise(Dimension(x, n))
        F = _field(machine(x))
        zero = _zeros(F, s)
        t = x.typing isa Untyped ? nothing : x.typing.labels[1]
        marginal = maximum((metered_query(x, MarginalQuery(n, :alice, x.level, collect(z), t))[2].child_calls for z in seeds); init=0)
        (; marginal,
           factor=metered_query(x, FactorQuery(n, :alice, 1, zero, t))[2].child_calls,
           linear=metered_query(x, LinearQuery(n, :alice, 1, zero, zero, t))[2].child_calls)
    end
    safe(x) = try
        counts(x)
    catch error
        error isa ArgumentError ? (; marginal=-1, factor=-1, linear=-1, error=error.msg) : rethrow()
    end
    measured = safe(S)
    replay = x -> begin
        c = safe(x)
        # verdicts/tb5-r1.md O2: Factor and Linear are PINNED exactly (like
        # Marginal) unless the law is an upper bound (`at_most`).
        ok = at_most ? (0 <= c.marginal <= expected && 0 <= c.factor <= expected && 0 <= c.linear <= expected) :
                       (c.marginal == expected && c.factor == expected && c.linear == expected)
        CheckResult(ok, :metered_calls; location=:MeteredCalls, expected, actual=c)
    end
    CertNode(CHECKED, :MeteredCalls;
        facts=(display="child calls per query at n = $(n) over $(length(seeds)) seeds: Marginal max $(measured.marginal), Factor $(measured.factor), Linear $(measured.linear); law $(law) => $(at_most ? "at most" : "exactly") $(expected) same-mode child calls per Marginal", expected, measured),
        replay=_bound_replay(S, :MeteredCalls, replay))
end

function _cited(label::String, source::String, lines::UnitRange{Int}, statement::String)
    CertNode(CITED, Symbol(label);
        facts=(display="$(source):L$(first(lines))-L$(last(lines)) ($(label)): $(statement)",
               source=source, lines=lines, label=label))
end
const CITED_CL_KTH = _cited("lem:cl-kth", "gt-04-cl.tex", 151:180,
    "the marginal decomposition, factor partition and telescoping identity characterizing ell-level CL functions; the general statement is CITED, its two obligations are replayed finitely")
const CITED_DEF_SAMPLER = _cited("def:sampler", "gt-04-cl.tex", 572:601,
    "the six-input sampler machine and its four query modes; promises are restricted to legal calls")
const CITED_CL_FUNC_PROD = _cited("lem:cl-func-prod", "gt-04-cl.tex", 315:327,
    "the direct sum of CL functions on complementary registers is CL of level max_j ell_j")
const CITED_CL_CONCAT = _cited("lem:cl-concat", "gt-04-cl.tex", 282:292,
    "the concatenation of a k-level CL function with an ell-level family is (k + ell)-level")
const CITED_DOWNSIZE = _cited("lem:downsize_sampler", "gt-04-cl.tex", 628:680,
    "the downsized sampler's level, field, dimension s(n) log2 q(n), distribution identity and runtime O(TIME_S(n) log q(n))")
const CITED_DETYPING = _cited("lem:detyping-verifiers", "gt-06-types.tex", 444:475,
    "completeness, soundness with 16^|Type| epsilon, the Ent map and the polynomial time bounds of detyping; the sampler/decider construction, +2 levels and 4|Type| registers are executed")
const CITED_TYPED_SAMPLER = _cited("def:typed-sampler", "gt-06-types.tex", 95:140,
    "the seven-input typed sampler machine; the type is the seventh input, not a fifth operation")
const CITED_TENSOR_GRAPH = _cited("thm:ar", "gt-10-answer-reduction.tex", 2077:2116,
    "the answer-reduced type graph is the tensor product E^ar = {((l,r),(l',r')) : (l,l') in E^ora, (r,r') in E^pcp} (its construction at L1949-L1955; the theorem contract stays CITED)")

# --- the constructors -------------------------------------------------------------

function _composite(rule::Symbol, term, parts::Tuple, cited::Tuple; tracer_index::Int, seeds::Int,
                    expected::NamedTuple, promoted::Bool=false, expected_calls::Int, call_law::String,
                    at_most::Bool=false, evidence=nothing, extra::Tuple=(), display::String="")
    S = _from_term(term; parts=Tuple(_desc(p) for p in parts), evidence)
    n = tracer_index
    chain_seeds, chain_set_id = if seeds == 0 || Dimension(S, n) isa QueryError
        (Any[], "tb5-none")
    else
        tracer_chain_set(S, n; seeds)
    end
    validity = _validity_node(S, n, chain_seeds, chain_set_id; promoted)
    relocated = Tuple(_relocate(_desc_cert(p), x -> x.parts[i]) for (i, p) in enumerate(parts) if p isa Checked)
    root = CertNode(CONSTRUCTED, rule;
        facts=(display="$(display); field $(S.field_size); level $(S.level); dimension at n = $(n): $(Dimension(S, n)); typing $(S.typing isa Untyped ? "untyped" : "typed($(TypeCount(S.typing)) types, $(length(S.typing.edges)) oriented edges)"); |S| = $(S.description_size) bytes; fnv1a64 = $(quote_hash(S))",),
        children=(_law_cert(rule, S, expected, n), _size_node(S), _dependency_node(S), validity,
                  _metered_node(S, n, expected_calls, call_law, chain_seeds; at_most), extra..., cited..., relocated...))
    Checked(S, root)
end

"""
    direct_sum(ss...; tracer_index=1, seeds=32) :: Checked{SamplerDescription}

DL9-direct-sum: field common q, level max_i ell_i, dimension sum_i s_i(n),
query law O(r + sum_i C_i(n)) (lem:cl-func-prod, gt-04-cl.tex:315-327).
A whole-space zero summand is promoted from level 0 by rk:higher-level.
"""
function direct_sum(s1::Union{SamplerDescription,Checked}, rest::Union{SamplerDescription,Checked}...;
                    tracer_index::Integer=1, seeds::Integer=32)
    inputs = (s1, rest...)
    parts = Tuple(_desc(x) for x in inputs)
    term = (:DirectSum, Any[p.term for p in parts])
    promoted = any(p.level == 0 for p in parts) && maximum(p.level for p in parts) >= 1
    r = length(parts)
    _composite(Symbol("DL9-direct-sum"), term, inputs, (CITED_CL_FUNC_PROD, CITED_CL_KTH);
               tracer_index=Int(tracer_index), seeds=Int(seeds), expected=expected_laws(Symbol("DL9-direct-sum"), r),
               promoted, expected_calls=count(p -> p.level >= 1, parts),
               call_law="O(r + sum_i C_i(n)), r = $(r); a promoted zero summand answers without a child call",
               display="direct sum of $(r) untyped descriptions on complementary blocks")
end

"""
    product(T1, T2; tracer_index=1, seeds=32) :: Checked{SamplerDescription}

DL9-product: Cartesian type set, tensor type graph E = E_1 x E_2
(gt-10-answer-reduction.tex:1949-1955), per-type direct sum of the selected maps.
"""
function product(left::Union{SamplerDescription,Checked}, right::Union{SamplerDescription,Checked};
                 tracer_index::Integer=1, seeds::Integer=32)
    parts = (_desc(left), _desc(right))
    term = (:Product, parts[1].term, parts[2].term)
    promoted = any(p.level == 0 for p in parts) && maximum(p.level for p in parts) >= 1
    _composite(Symbol("DL9-product"), term, (left, right), (CITED_CL_FUNC_PROD, CITED_TENSOR_GRAPH, CITED_CL_KTH);
               tracer_index=Int(tracer_index), seeds=Int(seeds), expected=expected_laws(Symbol("DL9-product")),
               promoted, expected_calls=count(p -> p.level >= 1, parts), call_law="O(C_1(n) + C_2(n))",
               display="typed product: Cartesian type set, tensor type graph, blockwise direct sum")
end

"""
    downsize(S; tracer_index=1, seeds=32) :: Checked{SamplerDescription}

DL9-downsize: field 2, level ell, dimension s(n) log2 q(n), Factor bits
expanded log2 q times (def:downsize_sampler, lem:downsize_sampler, gt-04-cl.tex:628-680).
"""
function downsize(S::Union{SamplerDescription,Checked}; tracer_index::Integer=1, seeds::Integer=32)
    part = _desc(S)
    term = (:Downsize, part.term)
    _composite(Symbol("DL9-downsize"), term, (S,), (CITED_DOWNSIZE, CITED_CL_KTH);
               tracer_index=Int(tracer_index), seeds=Int(seeds), expected=expected_laws(Symbol("DL9-downsize")),
               expected_calls=1, call_law="O(C_S(n) log q(n))",
               display="downsize F_$(part.field_size) -> F_2 through the fixed polynomial basis (odd extension degree assumed)")
end

"""
    detype_sampler(T; tracer_index=1, seeds=32) :: Checked{SamplerDescription}

DL9-detype's sampler projection (DESIGN 9.5): graph_sampler(G) concatenated
conditionally with the typed child; level ell + 2, dimension s(n) + 4|Type|.
"""
function detype_sampler(T::Union{SamplerDescription,Checked}; tracer_index::Integer=1, seeds::Integer=32)
    part = _desc(T)
    term = (:Detype, part.term)
    _composite(Symbol("DL9-detype"), term, (T,), (CITED_DETYPING, CITED_CL_CONCAT, CITED_CL_KTH);
               tracer_index=Int(tracer_index), seeds=Int(seeds), expected=expected_laws(Symbol("DL9-detype")),
               expected_calls=1, call_law="poly(TypeCount, C_S(n)); at most one child call per query", at_most=true,
               display="detype: V_G = V_vA (+) V_eA (+) V_vB (+) V_eB (4 x $(TypeCount(part.typing)) bits) then the typed child for the revealed type (gt-06-types.tex:359-404)")
end

"""
    typed_anchor_sampler(S; tracer_index=1, seeds=32) :: Checked{SamplerDescription}

DESIGN 10.1 / gt-11-parallel-repetition.tex:89-97: type set {Game, Anchor},
complete graph with both self-loops; Game delegates to S, Anchor is the
zero map on the same ambient space with the promoted stage-1 factor
(SOURCE_REPAIR(zero-map-factor-partition) against the literal L96).
"""
function typed_anchor_sampler(S::Union{SamplerDescription,Checked}; tracer_index::Integer=1, seeds::Integer=32)
    part = _desc(S)
    term = (:Anchor, part.term)
    n = Int(tracer_index)
    # The promotion witness (verdicts/tb2-r5.md N23/N24): pad_level_evidence
    # on the in-memory whole-space zero map of the child's ambient, in the
    # top-level (ambient) padding context, carrying ZERO_MAP_FACTOR_PARTITION.
    s = _raise(Dimension(part, n))
    witness_seeds = s <= 9 ? collect(enumerate_seeds(GF2, s)) : Any[]
    pad = pad_level_evidence(CLZero(GF2, s), part.level, witness_seeds; chain_set_id="tb5-anchor-pad@n=$(n)")
    pad_node = CertNode(pad.certificate.grade, pad.certificate.rule;
        facts=(; pad.certificate.facts..., padding_context=:top_level_ambient,
                 display="Anchor = pad_level(CLZero(F_2, $(s)), $(part.level)) in the top-level ambient context: stage 1 reports the all-ones indicator, stages 2..$(part.level) empty"),
        children=pad.certificate.children, replay=pad.certificate.replay)
    anchor_zero = CertNode(SOURCE_REPAIR, :AnchorFactorReport;
        facts=(display="gt-11-parallel-repetition.tex:L96 prints the all-zero factor for Anchor at every stage; the executable reports V_1 = V (rk:higher-level, gt-04-cl.tex:122-130) so enu:cl-space-sum holds: SOURCE_REPAIR(zero-map-factor-partition)",))
    _composite(Symbol("DL9-anchor"), term, (S,), (CITED_TYPED_SAMPLER, CITED_CL_KTH);
               tracer_index=n, seeds=Int(seeds), expected=expected_laws(Symbol("DL9-anchor")), promoted=true,
               expected_calls=1, call_law="poly(C_S(n)); at most one child call per query", at_most=true,
               evidence=pad.term, extra=(anchor_zero, _relocate(pad_node, x -> x.evidence)),
               display="typed anchor family {Game, Anchor} with the complete graph and both self-loops; Game = S, Anchor = 0 on F_2^$(s)")
end
