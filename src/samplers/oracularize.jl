const ORACULAR_ROLES = (:oracle, :alice, :bob)

function _identity_cl(::Type{F}, dimension::Int) where {F}
    tail = CLZero(F, dimension, ())
    CLStep(F, dimension, Tuple(1:dimension), (), _identity_matrix(F, dimension), tail)
end

"A two-coordinate, one-level sampler with visibly distinct x and y projections."
function _build_trivial_original_sampler(::Type{F}) where {F<:GF2k}
    dimension = 2
    tail = CLZero(F, dimension, ())
    left_matrix = zeros(F, dimension, dimension)
    right_matrix = zeros(F, dimension, dimension)
    left_matrix[1, 1] = one(F)
    right_matrix[2, 2] = one(F)
    left = CLStep(F, dimension, (1, 2), (), left_matrix, tail)
    right = CLStep(F, dimension, (1, 2), (), right_matrix, tail)
    distribution(left, right)
end

"The three-role sampler of gt-09:42-86; its theorem contract remains CITED."
function _build_oracularized_sampler(original::CLDistribution{F}) where {F}
    seed_dim(original.left) == seed_dim(original.right) ||
        throw(ArgumentError("original sampler maps must share an ambient space"))
    identity = _identity_cl(F, seed_dim(original.left))
    maps = Dict{Any,AbstractCL{F}}(
        :oracle => identity,
        :alice => original.left,
        :bob => original.right,
    )
    graph = [(left, right) for left in ORACULAR_ROLES for right in ORACULAR_ROLES]
    sampler = TypedSampler(ORACULAR_ROLES, graph, maps, maps)
    cited = CertNode(CITED, :Oracularization;
        facts=(display="roles={oracle,alice,bob}; oracle=Id; isolated maps=L^alice/L^bob; gt-09:36-86",))
    Checked(sampler, cited)
end

struct AnswerReduceType
    role::Symbol
    pcp::PCPType
    function AnswerReduceType(role::Symbol, pcp::PCPType)
        role in ORACULAR_ROLES || throw(ArgumentError("unknown oracularized role"))
        new(role, pcp)
    end
end

Base.show(io::IO, kind::AnswerReduceType) =
    print(io, "(", kind.role, ",", kind.pcp, ")")

function _product_replay(subject)
    sampler = hasproperty(subject, :sampler) ? subject.sampler : subject
    CheckResult(length(sampler.types) == 54 &&
                length(sampler.type_graph) == 54^2 && level(sampler) == 3,
                :answer_reduce_sampler_shape;
                expected=(types=54, edges=2916, level=3),
                actual=(types=length(sampler.types),
                        edges=length(sampler.type_graph), level=level(sampler)))
end

"Product Type^ora x Type^pcp and direct sum of their CL maps."
function _build_typed_sampler_product(oracularized::Checked, pcp::Checked)
    ora_sampler = oracularized.term
    pcp_sampler_term = pcp.term
    F = _cl_field(first(values(ora_sampler.left)))
    _cl_field(first(values(pcp_sampler_term.left))) == F ||
        throw(ArgumentError("sampler product fields differ"))
    types = [AnswerReduceType(role, kind)
             for role in ora_sampler.types for kind in pcp_sampler_term.types]
    left = Dict{Any,AbstractCL{F}}()
    right = Dict{Any,AbstractCL{F}}()
    for kind in types
        left[kind] = direct_sum(ora_sampler.left[kind.role],
                                pcp_sampler_term.left[kind.pcp])
        right[kind] = direct_sum(ora_sampler.right[kind.role],
                                 pcp_sampler_term.right[kind.pcp])
    end
    # E^ar is the tensor product of the two factor graphs
    # (gt-10-answer-reduction.tex:1949-1955; DESIGN 9.4 DL9-product), not the
    # complete graph; the two coincide on this fixture only because both
    # factor graphs are complete (verdicts/tb2-r2.md N5).
    graph = [(AnswerReduceType(l, r), AnswerReduceType(l2, r2))
             for (l, l2) in ora_sampler.type_graph
             for (r, r2) in pcp_sampler_term.type_graph]
    sampler = TypedSampler(types, graph, left, right)
    root = CertNode(CHECKED, :AnswerReduceSamplerProduct;
        facts=(display="3x18=54 types; tensor graph E^ora x E^pcp (54^2 edges here); level=max(ell,3)",),
        children=(oracularized.certificate, pcp.certificate),
        replay=_product_replay)
    Checked(sampler, root)
end

function trivial_original_sampler(::Type{F}) where {F<:GF2k}
    _build_trivial_original_sampler(F)
end

function oracularize_sampler(original::CLDistribution)
    _build_oracularized_sampler(original)
end

function typed_sampler_product(oracularized::Checked, pcp::Checked)
    _build_typed_sampler_product(oracularized, pcp)
end

function _certificate_has_node(node::CertNode, grade::Grade, rule::Symbol)
    (node.grade == grade && node.rule == rule) ||
        any(child -> _certificate_has_node(child, grade, rule), node.children)
end

"Lazily built structural report used by the TB2 sampler test."
function _compute_tb2_sampler_invariant_report()
    params = PCPParams(2048, 11, 1, 11, 6, 16, 1)
    original = trivial_original_sampler(GF2048)
    oracularized = oracularize_sampler(original)
    pcp = pcp_sampler(GF2048, params)
    combined = typed_sampler_product(oracularized, pcp)
    dimensions = pcp_register_dimensions(pcp.term)
    intrinsic = intrinsic_pcp_levels(pcp.term)
    pcp_seed = ntuple(i -> GF2048(7i + 3), seed_dim(pcp.term))
    product_seed = ntuple(i -> GF2048(7i + 3), seed_dim(combined.term))
    (; pcp_types=length(pcp.term.types),
       pcp_edges=length(pcp.term.type_graph),
       pcp_complete=Set(pcp.term.type_graph) ==
           Set((left, right) for left in pcp.term.types for right in pcp.term.types),
       pcp_level=level(pcp.term),
       padded=all(map -> level(map) == 3, values(pcp.term.left)),
       intrinsic_ok=all(intrinsic[PCPType(kind, i)] == expected
           for i in 1:6 for (kind, expected) in
               ((:Point, 1), (:ALine, 2), (:DLine, 3))),
       individual_dimensions=all(dimensions[(i, :pt)] == 1 &&
           dimensions[(i, :coord)] == 1 && dimensions[(i, :dir)] == 1
           for i in 1:5),
       copy6=(dimensions[(6, :pt)], dimensions[(6, :coord)],
              dimensions[(6, :dir)]),
       source_repair=_certificate_has_node(
           pcp.certificate, SOURCE_REPAIR, :PCPCopy6CoordinateScalar),
       certificate=passed(verify_certificate(pcp)),
       marginals=all(marginal_k(map, pcp_seed, level(map)).value ==
                     apply(map, pcp_seed) for map in values(pcp.term.left)) &&
           all(marginal_k(map, product_seed, level(map)).value ==
               apply(map, product_seed) for map in values(combined.term.left)),
       ora_types=length(oracularized.term.types),
       ora_edges=length(oracularized.term.type_graph),
       ora_level=level(oracularized.term),
       product_types=length(combined.term.types),
       product_edges=length(combined.term.type_graph),
       product_level=level(combined.term))
end

tb2_sampler_invariant_report() = _compute_tb2_sampler_invariant_report()

precompile(tb2_sampler_invariant_report, ())
precompile(pcp_register_dimensions, (TypedSampler{GF2048},))
precompile(intrinsic_pcp_levels, (TypedSampler{GF2048},))
precompile(_pcp_replay_sampler, (TypedSampler{GF2048},))
precompile(_verify_node, (CertNode, TypedSampler{GF2048}))
precompile(verify_certificate,
           (Checked{TypedSampler{GF2048},CertNode},))
