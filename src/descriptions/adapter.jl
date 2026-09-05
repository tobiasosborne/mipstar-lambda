# DESIGN 9.3: the adapters from lazy in-memory CL values to leaf
# descriptions. `describe_cl(LA, LB, q)` compiles an untyped pair, and
# `describe_typed_cl(sampler)` a TypedSampler, to a term whose bytes are a
# pure function of the children's canonical CL bytes and q (verdicts/tb2-r4.md
# forward NOTE 3). An opaque host branch is NotDescribable; the adapter never
# serializes a closure.
#
# Canonical order (verdicts/tb1-r5.md N31, "sorting is DL9 work"): set-valued
# registers (`rest`, a zero map's register) are serialized in increasing
# order, so the two spellings of one register give one byte string; the
# POSITIONAL registers (`factor`, whose order indexes the stage matrix, and
# BranchLnf's `point`) must already be increasing, otherwise the value is
# NotDescribable at this boundary. Every map TB1/TB2 build satisfies this.

struct _NotCanonical <: Exception
    reason::String
end

_increasing(v::Vector{Int}) = issorted(v; lt=<) && allunique(v)

function _canonical_cl_term(term)
    tag = term[1]
    if tag == :Zero
        return (:Zero, term[2], sort(term[3]))
    end
    tag == :Step || throw(_NotCanonical("unknown CL term"))
    _increasing(term[3]) || throw(_NotCanonical("a positional factor register must be declared in increasing order"))
    (:Step, term[2], term[3], sort(term[4]), term[5], _canonical_branch(term[6]))
end
function _canonical_branch(branch)
    tag = branch[1]
    tag == :Const && return (:Const, _canonical_cl_term(branch[2]))
    tag == :ByAxis && return (:ByAxis, branch[2], branch[3], Any[_canonical_cl_term(c) for c in branch[4]])
    if tag == :Lnf
        _increasing(branch[3]) || throw(_NotCanonical("BranchLnf's positional point register must be increasing"))
        return (:Lnf, branch[2], branch[3], _canonical_cl_term(branch[4]))
    end
    tag == :Padded && return (:Padded, branch[2], _canonical_branch(branch[3]))
    throw(_NotCanonical("unknown CL branch"))
end

# A CL value to its canonical term, or the NotDescribable reason.
function _cl_leaf_term(L::AbstractCL{F}, q::Int, what::String) where {F}
    field_size(F) == q || throw(ArgumentError("$(what) is over F_$(field_size(F)), not F_$(q)"))
    description = describe_cl(L)
    description isa NotDescribable && return description
    try
        term = _canonical_cl_term(description.term)
        _leaf_cl(F, term, seed_dim(L))   # whole-space at the top level (DESIGN 9.4)
        return term
    catch error
        error isa _NotCanonical && return NotDescribable(error.reason, what)
        error isa ArgumentError && return NotDescribable(error.msg, what)
        rethrow()
    end
end

# The adapter certificate (DESIGN 9.3): on the declared chain set, every
# legal j and seed against marginal_k, every reached Factor prefix against
# the stored factor spaces, and Linear on every factor basis vector against
# the stage matrix; then the DESIGN 9.2 replay of the output.
function _adapter_replay(S::SamplerDescription, n::Int, seeds, chain_set_id::String)
    reference = S.evidence.maps
    check(x) = begin
        ok = true
        compared = 0
        for ((w, t), L) in reference, seed in seeds
            z = _prefix_vector(_field(machine(x)), seed)
            ell = level(L)
            prefixes = Vector{typeof(z)}()
            for j in 1:ell
                m = marginal_k(L, z, j)
                ok &= _raise(Marginal(x, n, w, j, z, t)) == collect(m.value)
                prefix = j == 1 ? zero(z) : collect(marginal_k(L, z, j - 1).value)
                ok &= _raise(Factor(x, n, w, j, prefix, t)) == Factor(L, j, prefix)
                m_full = marginal_k(L, z, ell)
                for c in m_full.factor_spaces[j]
                    e = zero(z)
                    e[c] = one(eltype(z))
                    ok &= _raise(Linear(x, n, w, j, prefix, e, t)) == collect(Linear(L, j, prefix, e))
                end
                compared += 1
            end
        end
        CheckResult(ok, :adapter_replay; location=:AdapterReplay, expected=:agreement, actual=(; ok, compared))
    end
    result = check(S)
    CertNode(CHECKED, :AdapterReplay;
        facts=(display="on chain set $(chain_set_id): every legal j and seed agrees with marginal_k, every reached Factor prefix with the stored factor spaces, Linear on every factor basis vector with the stage matrix ($(result.actual.compared) (view, seed, stage) triples)",),
        replay=_bound_replay(S, :AdapterReplay, check))
end

function _leaf(term, maps::Dict, q::Int, tracer_index::Int, seeds::Int, display::String)
    S = _from_term(term; parts=(), evidence=(; maps))
    n = tracer_index
    chain_seeds, chain_set_id = tracer_chain_set(S, n; seeds)
    expected = (; field=q, level=S.level, dimension=S.field_size == q ? _raise(Dimension(S, n)) : 0, query_time=:(TIME_S(n)))
    root = CertNode(CONSTRUCTED, :DescribeCL;
        facts=(display="$(display); field $(q); level $(S.level); dimension $(Dimension(S, n)); |S| = $(S.description_size) bytes; fnv1a64 = $(quote_hash(S))",),
        children=(_law_cert(:DescribeCL, S, expected, n), _adapter_replay(S, n, chain_seeds, chain_set_id),
                  _size_node(S), _dependency_node(S), _validity_node(S, n, chain_seeds, chain_set_id),
                  CITED_DEF_SAMPLER, CITED_CL_KTH))
    Checked(S, root)
end

"""
    describe_cl(LA, LB, q; tracer_index=1, seeds=32) :: Checked{SamplerDescription} | NotDescribable

The untyped pair adapter of DESIGN 9.3: the description whose CL functions
on every index are (LA, LB) over F_q (an index-independent leaf).
"""
function describe_cl(LA::AbstractCL{F}, LB::AbstractCL{F}, q::Integer; tracer_index::Integer=1, seeds::Integer=32) where {F}
    seed_dim(LA) == seed_dim(LB) || throw(ArgumentError("a sampler's two CL functions share one ambient space"))
    termA = _cl_leaf_term(LA, Int(q), "L^alice")
    termA isa NotDescribable && return termA
    termB = _cl_leaf_term(LB, Int(q), "L^bob")
    termB isa NotDescribable && return termB
    level(LA) == level(LB) || throw(ArgumentError("a sampler's two CL functions have one constructed level; pad first"))
    maps = Dict{Tuple{Symbol,Any},AbstractCL{F}}((:alice, nothing) => LA, (:bob, nothing) => LB)
    _leaf((:Pair, Int(q), termA, termB), maps, Int(q), Int(tracer_index), Int(seeds),
          "untyped pair adapter describe_cl(L^alice, L^bob, q) from QuotedBranch CL values")
end

"""
    describe_typed_cl(sampler::TypedSampler; tracer_index=1, seeds=32)

The typed leaf adapter: labels `string(type)`, the stored oriented edges,
and the padded per-type pair of CL maps.
"""
function describe_typed_cl(sampler::TypedSampler{F}; tracer_index::Integer=1, seeds::Integer=32) where {F}
    q = field_size(F)
    labels = String[string(t) for t in sampler.types]
    allunique(labels) || throw(ArgumentError("type labels string(type) must be unique"))
    index = Dict(t => i for (i, t) in enumerate(sampler.types))
    edges = Tuple{Int,Int}[(index[e[1]], index[e[2]]) for e in sampler.type_graph]
    entries = Tuple{Any,Any}[]
    maps = Dict{Tuple{Symbol,Any},AbstractCL{F}}()
    for (t, label) in zip(sampler.types, labels)
        left = _cl_leaf_term(sampler.left[t], q, "L^alice_$(label)")
        left isa NotDescribable && return left
        right = _cl_leaf_term(sampler.right[t], q, "L^bob_$(label)")
        right isa NotDescribable && return right
        push!(entries, (left, right))
        maps[(:alice, label)] = sampler.left[t]
        maps[(:bob, label)] = sampler.right[t]
    end
    _leaf((:TypedFamily, q, labels, edges, entries), maps, q, Int(tracer_index), Int(seeds),
          "typed family adapter describe_typed_cl over $(length(labels)) types and $(length(edges)) oriented edges")
end
