using Test
using MIPStarLambda
using Random
Base.Experimental.@optlevel 0

# TB5: the sampler/decider DESCRIPTION layer (DESIGN 9) and executable
# Repeat = anchoring + parallel repetition (DESIGN 10) on the V_copy fixture
# (briefs/39-tb5-descriptions-repeat.md with addenda 1-3). Ground truth:
# gt-04-cl.tex def:sampler L572-L601, lem:cl-kth L151-L180, lem:cl-func-prod
# L315-L327; gt-06-types.tex def:typed-sampler L95-L151, detyping L359-L427,
# lem:detyping-verifiers L444-L475; gt-11-parallel-repetition.tex anchoring
# L89-L136, repetition L200-L220, thm:repetition L229-L258.

const TB5_TARGET = get(ENV, "TB5_TARGET", "all")
tb5_runs(name) = TB5_TARGET == "all" || TB5_TARGET == name
# The repository root: this file's parent, or (for a mutated copy of this
# file run from a sandbox by test/mutations/run.jl) the package's own root.
const TB5_ROOT = isdir(joinpath(@__DIR__, "..", "ground-truth")) ? normpath(joinpath(@__DIR__, "..")) :
                 normpath(joinpath(dirname(pathof(MIPStarLambda)), ".."))
const TB5_CACHE = Dict{Symbol,Any}()
const TB5_N = 9
const TB5_LAMBDA = 1
const TB5_TAU = 1
const TB5_C_PRIME = 1 // 1
const TB5_LOG = Dict{Symbol,Any}()   # measured walls for the report

tb5_first_lines(path) = readlines(joinpath(TB5_ROOT, "ground-truth", path))
function tb5_nodes(node::CertNode, found=CertNode[])
    push!(found, node)
    foreach(child -> tb5_nodes(child, found), node.children)
    found
end
tb5_find(node, rule::Symbol) = [n for n in tb5_nodes(node) if n.rule == rule]
tb5_grades(node) = Dict(g => count(n -> n.grade == g, tb5_nodes(node)) for g in instances(Grade))
tb5_bits(v) = Bool[x.bits == 1 for x in v]
tb5_gf2(bits) = GF2[GF2(Int(b)) for b in bits]
tb5_zero(n) = fill(zero(GF2), n)

# --- the V_copy fixture (DESIGN 10.3): F_2, ell = 1, s(n) = 1, both CL maps
# the identity, decider a = x and b = y. Built here, never in src/.
function tb5_copy_map()
    CLStep(GF2, 1, [1], Int[], reshape([one(GF2)], 1, 1), CLZero(GF2, 1, Int[]))
end
tb5_copy_sampler() = get!(TB5_CACHE, :S_copy) do
    describe_cl(tb5_copy_map(), tb5_copy_map(), 2)
end
tb5_copy_decider() = get!(TB5_CACHE, :D_copy) do
    copy_decider()
end
tb5_copy_verifier() = get!(TB5_CACHE, :V_copy) do
    VerifierDescription(tb5_copy_sampler().term, tb5_copy_decider().term)
end
tb5_copy_honest(player, question::Vector{Bool}) = copy(question)

tb5_anchor() = get!(TB5_CACHE, :anchor) do
    anchor(tb5_copy_verifier(); tracer_index=TB5_N)
end
tb5_repeat() = get!(TB5_CACHE, :repeat) do
    # verdicts/tb5-r1.md O5: the DESIGN 10.3 construction wall is a WARM
    # measurement (a small n = 2 construction first compiles the path), the
    # allocation figure is total bytes allocated (not a peak), and the peak
    # is the process maxrss delta around the construction (0 when TB0's
    # earlier peak already dominates) plus the GC live-heap delta.
    anchored_repeat(tb5_copy_verifier(), TB5_LAMBDA, TB5_TAU; c_prime=TB5_C_PRIME, tracer_index=2, seeds=2)
    GC.gc()
    rss_before = Sys.maxrss()
    live_before = Base.gc_live_bytes()
    stats = @timed anchored_repeat(tb5_copy_verifier(), TB5_LAMBDA, TB5_TAU;
                                   c_prime=TB5_C_PRIME, tracer_index=TB5_N, seeds=32)
    TB5_LOG[:construction_seconds] = round(stats.time; digits=3)
    TB5_LOG[:construction_alloc_MiB] = round(stats.bytes / 2^20; digits=1)
    TB5_LOG[:construction_peak_rss_delta_MiB] = round((Sys.maxrss() - rss_before) / 2^20; digits=1)
    TB5_LOG[:construction_live_delta_MiB] = round((Base.gc_live_bytes() - live_before) / 2^20; digits=1)
    stats.value
end

# verdicts/tb5-r1.md O2: a level-3 F_2 child on F_2^4 whose stage-2 factor
# register is {2} (stage-1 bit 0) or {2,3} (stage-1 bit 1), with stage 3 on
# the complement; both branches partition the ambient, so the child's own
# certificate passes while its per-block Factor answers depend on the prefix.
function tb5_prefix_dependent_child()
    F = GF2
    id(k) = F[F(i == j) for i in 1:k, j in 1:k]
    tail = CLZero(F, 4, Int[])
    step(factor, rest, child) = MIPStarLambda._clstep(F, 4, factor, rest, id(length(factor)), child,
                                                       BranchConst(child); require_ambient=false)
    on0 = step([2], [3, 4], step([3, 4], Int[], tail))
    on1 = step([2, 3], [4], step([4], Int[], tail))
    CLStep(F, 4, [1], [2, 3, 4], id(1), on0, BranchByAxis(2, 1, AbstractCL{F}[on0, on1]))
end
tb5_prefix_dependent_repeat() = get!(TB5_CACHE, :prefix_repeat) do
    child = describe_cl(tb5_prefix_dependent_child(), tb5_prefix_dependent_child(), 2; tracer_index=2)
    (; child, repeat=repeat_sampler(child.term, 1, 1; c_prime=1, tracer_index=2, seeds=16))
end
tb5_e(i, s) = GF2[GF2(Int(j == i)) for j in 1:s]

# The TB1 maps at (q, m, d) = (8, 2, 1) as untyped pair descriptions.
tb1_pairs() = get!(TB5_CACHE, :tb1_pairs) do
    Dict(:Point => describe_cl(L_Point(GF8, 2), L_Point(GF8, 2), 8),
         :ALine => describe_cl(L_ALine(GF8, 2), L_ALine(GF8, 2), 8),
         :DLine => describe_cl(L_DLine(GF8, 2), L_DLine(GF8, 2), 8))
end
tb1_maps() = Dict(:Point => L_Point(GF8, 2), :ALine => L_ALine(GF8, 2), :DLine => L_DLine(GF8, 2))
const TB1_ELEMS8 = Tuple(field_elements(GF8))
tb1_all_seeds() = ((a, b, s, c, d) for a in TB1_ELEMS8 for b in TB1_ELEMS8
                                     for s in TB1_ELEMS8 for c in TB1_ELEMS8 for d in TB1_ELEMS8)

if tb5_runs("tb5_queries")
    @testset "TB5 (a) the four SamplerQuery modes on describe_cl(L_Point/L_ALine/L_DLine) at (8,2,1)" begin
        pairs = tb1_pairs()
        maps = tb1_maps()
        for (name, L) in maps
            checked = pairs[name]
            @test checked isa Checked && checked.term isa SamplerDescription
            S = checked.term
            @test S.field_size == 8 && S.level == level(L) && S.typing isa Untyped
            @test Dimension(S, 1) == 5 && Dimension(S, 9) == 5
            @test passed(verify_certificate(checked))
            @test checked.certificate.rule == :DescribeCL
            @test !isempty(tb5_find(checked.certificate, :AdapterReplay))
            # Every legal j and seed agrees with marginal_k (both players).
            agree = 0
            for z in tb1_all_seeds(), j in 1:level(L), w in (:alice, :bob)
                Marginal(S, 1, w, j, z) == collect(marginal_k(L, z, j).value) && (agree += 1)
            end
            @test agree == 8^5 * level(L) * 2
            # Every reachable prefix: Factor against the stored factor spaces
            # and Linear on every factor basis vector against the stage matrix.
            prefixes = Set{Tuple{Int,Vector{GF8}}}()
            for z in tb1_all_seeds()
                m = marginal_k(L, z, level(L))
                for j in 1:level(L)
                    prefix = j == 1 ? fill(zero(GF8), 5) : collect(marginal_k(L, z, j - 1).value)
                    push!(prefixes, (j, GF8[prefix...]))
                end
            end
            factor_ok = true
            linear_ok = true
            for (j, u) in prefixes
                z = u  # any seed reproducing this prefix; the factor space depends on u only
                indicator = Factor(S, 1, :alice, j, u)
                factor_ok &= indicator == Factor(L, j, u)
                for c in findall(==(1), indicator)
                    e = GF8[GF8(i == c) for i in 1:5]
                    linear_ok &= Linear(S, 1, :alice, j, u, e) == collect(Linear(L, j, u, e))
                end
            end
            @test factor_ok && linear_ok
            println("TB5 (a) $(name): distinct reachable prefixes = ", length(prefixes))
        end
        # Illegal calls return QueryError, never throw (DESIGN 9.1; G3/G5).
        S = pairs[:ALine].term
        z = GF8[3, 5, 4, 6, 7]
        zero5 = fill(zero(GF8), 5)
        @test Marginal(S, 1, :alice, 0, z) isa QueryError            # G3: j = 0 at the boundary
        @test Marginal(S, 1, :alice, 3, z) isa QueryError
        @test Marginal(S, 1, :carol, 1, z) isa QueryError
        @test Marginal(S, 1, :alice, 1, z[1:4]) isa QueryError
        @test Marginal(S, 1, :alice, 1, z, "Game") isa QueryError      # a type on an untyped sampler
        unreachable = GF8[0, 0, 4, 1, 0]
        @test Factor(S, 1, :alice, 2, unreachable) isa QueryError    # G5: ArgumentError -> QueryError
        @test !(Linear(S, 1, :alice, 2, unreachable, z) isa QueryError)
        @test Factor(S, 1, :alice, 1, zero5) == [0, 0, 1, 1, 1]
        # An opaque host branch is NotDescribable.
        closure = CLStep(v -> CLZero(GF8, 5, Int[]), GF8, 5, 1:5, (), zeros(GF8, 5, 5), CLZero(GF8, 5, Int[]))
        @test describe_cl(closure, closure, 8) isa NotDescribable
        @test describe_cl(L_Point(GF8, 2), closure, 8) isa NotDescribable
        # G5 on the TB2 fixture: Factor rejects an unreachable PCP prefix.
        pcp = pcp_sampler(GF2048, PCPParams(2048, 11, 1, 11, 6, 16, 1)).term
        kind = PCPType(:ALine, 1)
        T = describe_cl(pcp.left[kind], pcp.right[kind], 2048).term
        zero38 = fill(zero(GF2048), 38)
        stage1 = Factor(T, 1, :alice, 1, zero38)
        z38 = GF2048[GF2048(7i + 3) for i in 1:38]
        reached = Marginal(T, 1, :alice, 1, z38)
        dead = first(c for c in findall(==(1), stage1) if iszero(reached[c]))
        bad = copy(reached)
        bad[dead] = one(GF2048)
        @test Factor(T, 1, :alice, 2, reached) isa Vector
        @test Factor(T, 1, :alice, 2, bad) isa QueryError
        @test occursin("reachable", Factor(T, 1, :alice, 2, bad).reason)
        # M9-adapter-enumerates owner: a Marginal walks exactly the selected
        # branch of each stage, never the whole BranchByAxis table (DESIGN 9.3):
        # a freshly decoded L_DLine memoises exactly one continuation per
        # stage walked (three, the zero-level terminal included), never the
        # 8 keyed continuations of its BranchByAxis table.
        fresh = decode_sampler(canonical_bytes(pairs[:DLine].term))
        L = machine(fresh).maps[(:alice, nothing)]
        @test memo_report(L).entries == 0
        @test Marginal(fresh, 1, :alice, 3, z) == collect(marginal_k(L_DLine(GF8, 2), z, 3).value)
        @test memo_report(L).entries == 3
        println("MUTATION_EXPECTED_RULE tb5_queries boundary=QueryError memo_entries_after_one_marginal=", memo_report(L).entries)
    end
end

if tb5_runs("tb5_size")
    @testset "TB5 (b) description_size = reserialized byte length; dependency set = syntax walk" begin
        for (name, checked) in tb1_pairs()
            S = checked.term
            bytes = canonical_bytes(S)
            @test description_size(S) == length(bytes)
            decoded = decode_sampler(bytes)
            @test canonical_bytes(decoded) == bytes
            @test description_size(decoded) == description_size(S)
            @test dependency_set(S) == dependency_walk(bytes)
            @test dependency_set(S) == Set{Any}([:S])  # a leaf depends only on itself
            @test !isempty(tb5_find(checked.certificate, :DescriptionSize))
            @test !isempty(tb5_find(checked.certificate, :DependencySet))
        end
        # The pair adapter's bytes are a pure function of the children's
        # bytes and q (verdicts/tb2-r4.md forward NOTE 3).
        P = tb1_pairs()[:Point].term
        expected = vcat(UInt8[0xC3, 0x01], reinterpret(UInt8, [hton(UInt32(8))]),
                        canonical_bytes(describe_cl(L_Point(GF8, 2)))[14:end],
                        canonical_bytes(describe_cl(L_Point(GF8, 2)))[14:end])
        @test canonical_bytes(P) == expected
        # verdicts/tb1-r5.md N31 at the description level: set-valued
        # registers are serialized in increasing order, so the two spellings
        # of one zero register give one byte string; a non-increasing
        # positional register is refused.
        a = describe_cl(CLZero(GF8, 5, [2, 1]), CLZero(GF8, 5, [1, 2]), 8)
        b = describe_cl(CLZero(GF8, 5, [1, 2]), CLZero(GF8, 5, [2, 1]), 8)
        @test a isa NotDescribable  # a top-level zero map on a proper sub-register is not whole-space
        c = describe_cl(CLZero(GF8, 5, [3, 1, 2, 5, 4]), CLZero(GF8, 5, Int[]), 8)
        @test c isa Checked && canonical_bytes(c.term) ==
              canonical_bytes(describe_cl(CLZero(GF8, 5), CLZero(GF8, 5, Int[]), 8).term)
        @test dependency_walk(canonical_bytes(c.term)) == Set{Any}([:S])
        println("MUTATION_EXPECTED_RULE tb5_size sizes=",
                Dict(k => description_size(v.term) for (k, v) in tb1_pairs()))
    end
end

if tb5_runs("tb5_replay")
    @testset "TB5 (c) DESIGN 9.2 replay through the four queries on every exhaustive fixture (NOTE-B)" begin
        reports = Dict{String,Any}()
        # TB1's three maps: exhaustive 8^5 through the description view.
        for (name, checked) in tb1_pairs()
            S = checked.term
            for w in (:alice, :bob)
                view = described_cl(S, 1, w)
                report = cl_kth_replay(view, tb1_all_seeds(); chain_set_id="tb5-tb1-exhaustive-8^5")
                @test report.space_sum_ok && report.map_sum_ok
                @test report.completed_replays == 8^5
                reports["$(name)/$(w)"] = report
            end
        end
        @test [reports["$(k)/alice"].distinct_chains for k in (:Point, :ALine, :DLine)] == [1, 8, 288]
        # V_copy (2 seeds), the typed anchor (2 seeds per type) and S^anch
        # (512 seeds) are exhaustive over F_2.
        S = tb5_copy_sampler().term
        for w in (:alice, :bob)
            r = cl_kth_replay(described_cl(S, TB5_N, w), enumerate_seeds(GF2, 1); chain_set_id="tb5-copy-exhaustive-2")
            @test r.space_sum_ok && r.map_sum_ok && r.completed_replays == 2
            reports["S_copy/$(w)"] = r
        end
        A = tb5_anchor().term
        for view in tb5_find(tb5_anchor().certificate, :SamplerValidity)
            @test view.grade == CHECKED && view.facts.ok
            @test Set(r.w for r in view.facts.reports) == Set([:alice, :bob])
            @test all(r.report.completed_replays == length(enumerate_seeds(GF2, r.report.dimension)) for r in view.facts.reports)
        end
        for w in (:alice, :bob)
            r = cl_kth_replay(described_cl(A.sampler, TB5_N, w), enumerate_seeds(GF2, 9); chain_set_id="tb5-anch-exhaustive-2^9")
            @test r.space_sum_ok && r.map_sum_ok && r.completed_replays == 512
            reports["S_anch/$(w)"] = r
        end
        R = tb5_repeat().term
        rng = MersenneTwister(0x5E)
        rep_seeds = [ntuple(_ -> rand(rng, (zero(GF2), one(GF2))), 729) for _ in 1:32]
        for w in (:alice, :bob)
            r = cl_kth_replay(described_cl(R.sampler, TB5_N, w), rep_seeds; chain_set_id="tb5-rep-rng32(0x5E)")
            @test r.space_sum_ok && r.map_sum_ok && r.completed_replays == 32
            reports["S_rep/$(w)"] = r
        end
        for (key, r) in sort(collect(reports); by=first)
            println("TB5 (c) replay ", key, ": chain_set_id=", r.chain_set_id, " level=", r.level,
                    " dimension=", r.dimension, " distinct_chains=", r.distinct_chains,
                    " completed_replays=", r.completed_replays, " map_sum_checks=", r.map_sum_checks)
        end
        println("MUTATION_EXPECTED_RULE tb5_replay space_sum_ok=true map_sum_ok=true")
    end
end

if tb5_runs("tb5_laws")
    @testset "TB5 (d) DL9-direct-sum / product / downsize / detype laws as LawCert AST equality + output replay" begin
        P = tb1_pairs()[:Point].term
        D = tb1_pairs()[:DLine].term
        # DL9-direct-sum (lem:cl-func-prod, gt-04:315-327): common q, max level, summed dimension.
        ds = direct_sum(P, D; tracer_index=1)
        @test ds.certificate.rule == Symbol("DL9-direct-sum")
        S = ds.term
        @test S.field_size == 8 && S.level == 3 && Dimension(S, 1) == 10
        @test S.level_law == :(max(ell_1, ell_2)) && S.dimension_law == :(s_1(n) + s_2(n))
        @test S.field_law == :(q_1) && S.query_time == :(2 + (C_1(n) + C_2(n)))
        @test passed(verify_certificate(ds))
        law = only(tb5_find(ds.certificate, :LawCert))
        @test law.grade == CHECKED && law.facts.expected == law.facts.actual
        @test !isempty(tb5_find(ds.certificate, :SamplerValidity))
        @test !isempty(tb5_find(ds.certificate, Symbol("lem:cl-func-prod")))
        @test dependency_set(S) == Set{Any}([quote_hash(P), quote_hash(D)])
        # Blockwise agreement with the in-memory direct sum on random seeds,
        # including the padded stages 2, 3 of the level-1 summand.
        reference = direct_sum(L_Point(GF8, 2), L_DLine(GF8, 2))
        rng = MersenneTwister(0x1D)
        ok = true
        for _ in 1:40
            z = GF8[rand(rng, TB1_ELEMS8) for _ in 1:10]
            for j in 1:3
                ok &= Marginal(S, 1, :alice, j, z) == collect(marginal_k(reference, z, j).value)
            end
            m = marginal_k(reference, z, 3)
            for j in 1:3
                u = j == 1 ? fill(zero(GF8), 10) : collect(marginal_k(reference, z, j - 1).value)
                ok &= Factor(S, 1, :alice, j, u) == Factor(reference, j, u)
            end
        end
        @test ok
        @test Factor(S, 1, :alice, 2, GF8[3, 5, 4, 6, 7, 0, 0, 0, 0, 0]) isa QueryError  # unreachable: stage 1 zeroes coordinates 3..5
        @test Factor(S, 1, :alice, 2, GF8[3, 5, 0, 0, 0, 0, 0, 7, 0, 0]) == [0, 0, 0, 0, 0, 0, 0, 0, 1, 1] .* 0 .+ [0, 0, 0, 0, 0, 0, 0, 0, 1, 1]
        @test canonical_bytes(decode_sampler(canonical_bytes(S))) == canonical_bytes(S)
        @test dependency_walk(canonical_bytes(S)) == dependency_set(S)
        # Byte injectivity by construction: the composite's bytes are the
        # tag plus the children's term bytes (verdicts/tb2-r4.md NOTE 3).
        @test canonical_bytes(S) == vcat(UInt8[0xC3, 0x03], reinterpret(UInt8, [hton(UInt32(2))]),
                                        canonical_bytes(P)[2:end], canonical_bytes(D)[2:end])

        # Query purity (DESIGN 9.6): the wrapper reaches its children only
        # through the four operations; an opaque recording child logs them.
        rec1, rec2 = RecordingMachine(machine(P)), RecordingMachine(machine(D))
        opaque = MIPStarLambda.DirectSumMachine(SamplerMachine[rec1, rec2])
        ctx = Meter()
        ctx.depth = 1
        z10 = GF8[3, 5, 4, 6, 7, 1, 2, 3, 4, 5]
        @test MIPStarLambda._marginal(opaque, 1, :alice, 3, z10, nothing, ctx) == Marginal(S, 1, :alice, 3, z10)
        @test all(entry[1] in (:dimension, :marginal, :linear, :factor) for entry in vcat(rec1.log, rec2.log))
        @test count(entry -> entry[1] == :marginal, rec1.log) == 1 && count(entry -> entry[1] == :marginal, rec2.log) == 1
        @test only(entry for entry in rec1.log if entry[1] == :marginal)[4] == 1   # the level-1 child is asked stage min(3, 1)

        # DL9-product on the TB2 typed samplers: 54/54 product maps describable,
        # tensor graph E^ar = E^ora x E^pcp (gt-10:1949-1955).
        started = time()
        original = trivial_original_sampler(GF2048)
        ora = oracularize_sampler(original)
        pcp = pcp_sampler(GF2048, PCPParams(2048, 11, 1, 11, 6, 16, 1))
        T_ora = describe_typed_cl(ora.term)
        T_pcp = describe_typed_cl(pcp.term)
        @test T_ora.term.typing isa Typed && length(T_ora.term.typing.labels) == 3
        @test T_pcp.term.typing isa Typed && length(T_pcp.term.typing.labels) == 18 && T_pcp.term.level == 3
        prod = product(T_ora.term, T_pcp.term; tracer_index=1)
        @test prod.certificate.rule == Symbol("DL9-product")
        Tp = prod.term
        @test Tp.typing isa Typed && length(Tp.typing.labels) == 54 && length(Tp.typing.edges) == 54^2
        @test Tp.level == 3 && Dimension(Tp, 1) == 40 && Tp.field_size == 2048
        @test Tp.level_law == :(max(ell_1, ell_2)) && Tp.dimension_law == :(s_1(n) + s_2(n))
        @test ("oracle,Point_1", "alice,DLine_6") in Tp.typing.edges   # both coordinates change: tensor, not Cartesian
        combined = typed_sampler_product(ora, pcp).term
        product_rng = MersenneTwister(0x54)
        describable = 0
        agree = true
        for kind in combined.types
            label = "$(kind.role),$(kind.pcp)"
            label in Tp.typing.labels || continue
            describable += 1
            for _ in 1:3
                z = GF2048[rand(product_rng, field_elements(GF2048)) for _ in 1:40]
                for j in 1:3, (w, side) in ((:alice, combined.left), (:bob, combined.right))
                    agree &= Marginal(Tp, 1, w, j, z, label) == collect(marginal_k(side[kind], z, j).value)
                end
                m = marginal_k(combined.left[kind], z, 3)
                for j in 1:3
                    u = j == 1 ? fill(zero(GF2048), 40) : collect(marginal_k(combined.left[kind], z, j - 1).value)
                    agree &= Factor(Tp, 1, :alice, j, u, label) == Factor(combined.left[kind], j, u)
                end
            end
        end
        println("MUTATION_EXPECTED_RULE tb5_product describable=", describable, "/54 agree=", agree)
        @test describable == 54 && agree
        @test passed(verify_certificate(prod))
        @test canonical_bytes(decode_sampler(canonical_bytes(Tp))) == canonical_bytes(Tp)
        @test Marginal(Tp, 1, :alice, 1, fill(zero(GF2048), 40), "nobody") isa QueryError
        TB5_LOG[:product_seconds] = round(time() - started; digits=3)

        # DL9-downsize (def:downsize_sampler / lem:downsize_sampler, gt-04:628-680) on L_ALine at q = 8.
        Aq = tb1_pairs()[:ALine].term
        dz = downsize(Aq; tracer_index=1)
        @test dz.certificate.rule == Symbol("DL9-downsize")
        Z = dz.term
        @test Z.field_size == 2 && Z.level == 2 && Dimension(Z, 1) == 15
        @test Z.field_law == 2 && Z.level_law == :(ell_1) && Z.dimension_law == :(s_1(n) * log2(q_1))
        @test passed(verify_certificate(dz))
        # Conjugation: downsize o L o downsize^-1 on random seeds; Factor
        # expands each child indicator bit into log2 q copies.
        for _ in 1:20
            z = GF8[rand(rng, TB1_ELEMS8) for _ in 1:5]
            bits = field_bit_vector(z)
            @test length(bits) == 15
            for j in 1:2
                @test Marginal(Z, 1, :bob, j, bits) == field_bit_vector(collect(marginal_k(L_ALine(GF8, 2), z, j).value))
            end
            @test Factor(Z, 1, :bob, 1, tb5_zero(15)) == repeat([0, 0, 1, 1, 1]; inner=3)
            u = collect(marginal_k(L_ALine(GF8, 2), z, 1).value)
            @test Factor(Z, 1, :bob, 2, field_bit_vector(u)) == repeat(Factor(L_ALine(GF8, 2), 2, u); inner=3)
        end
        @test canonical_bytes(decode_sampler(canonical_bytes(Z))) == canonical_bytes(Z)

        # DL9-detype on the typed anchor of V_copy (gt-06:359-427): +2 levels, +4|Type|.
        A = tb5_anchor().term
        dt = tb5_find(tb5_anchor().certificate, Symbol("DL9-detype"))
        @test length(dt) == 1
        @test A.sampler.level_law == :(ell_1 + 2) && A.sampler.dimension_law == :(s_1(n) + 4 * TypeCount)
        @test A.sampler.field_law == 2
        @test !isempty(tb5_find(tb5_anchor().certificate, Symbol("lem:detyping-verifiers")))
        @test !isempty(tb5_find(tb5_anchor().certificate, Symbol("lem:cl-concat")))
        # Every DL9 output carries the mandatory replay row (DESIGN 9.6),
        # at every intermediate sampler.
        for cert in (ds.certificate, prod.certificate, dz.certificate, tb5_anchor().certificate)
            @test !isempty(tb5_find(cert, :SamplerValidity))
            @test all(n.grade == CHECKED for n in tb5_find(cert, :SamplerValidity))
        end
        @test length(tb5_find(tb5_anchor().certificate, :SamplerValidity)) >= 2   # typed anchor + detyped
        # DL9-direct-sum with a whole-space zero summand promotes it from
        # level 0 (rk:higher-level) and says so.
        Zp = describe_cl(CLZero(GF8, 3), CLZero(GF8, 3, Int[]), 8).term
        dz0 = direct_sum(Zp, P; tracer_index=1)
        @test dz0.term.level == 1 && Dimension(dz0.term, 1) == 8
        @test Factor(dz0.term, 1, :alice, 1, fill(zero(GF8), 8)) == ones(Int, 8)
        @test Factor(dz0.term, 1, :bob, 1, fill(zero(GF8), 8)) == ones(Int, 8)
        @test !isempty(tb5_find(dz0.certificate, :zero_map_factor_partition))
        @test passed(verify_certificate(dz0))
        # In a level-3 sum the promoted summand's stages 2, 3 are EMPTY
        # (rk:higher-level: V_{>1} = {0}); the all-ones report at every stage
        # would double-cover the ambient basis (M-zero-promotion owner).
        dz3 = direct_sum(Zp, D; tracer_index=1)
        @test dz3.term.level == 3
        z8 = GF8[rand(rng, TB1_ELEMS8) for _ in 1:8]
        u2 = vcat(fill(zero(GF8), 3), collect(marginal_k(L_DLine(GF8, 2), z8[4:8], 1).value))
        @test Factor(dz3.term, 1, :alice, 1, fill(zero(GF8), 8)) == vcat(ones(Int, 3), Factor(L_DLine(GF8, 2), 1, fill(zero(GF8), 5)))
        @test Factor(dz3.term, 1, :alice, 2, u2) == vcat(zeros(Int, 3), Factor(L_DLine(GF8, 2), 2, u2[4:8]))
        @test Factor(dz3.term, 1, :bob, 2, u2) == vcat(zeros(Int, 3), Factor(L_DLine(GF8, 2), 2, u2[4:8]))
        @test Factor(dz3.term, 1, :alice, 2, vcat(GF8[1, 0, 0], u2[4:8])) isa QueryError   # L_{<2}(V) = {0} on the zero block
        @test cl_kth_replay(described_cl(dz3.term, 1, :alice), [Tuple(z8)]; chain_set_id="tb5-dsum0-one").space_sum_ok
        @test passed(verify_certificate(dz3))
        # Mismatched fields are rejected (DESIGN 9.4).
        @test_throws ArgumentError direct_sum(P, tb5_copy_sampler().term)
    end
end

if tb5_runs("tb5_anchor")
    @testset "TB5 (e) typed_anchor_sampler / typed_anchor_decider on V_copy; detyped (S^anch, D^anch)" begin
        S = tb5_copy_sampler().term
        ta = typed_anchor_sampler(S; tracer_index=TB5_N)
        T = ta.term
        @test T.typing isa Typed
        @test T.typing.labels == ["Game", "Anchor"]
        @test Set(T.typing.edges) == Set([("Game", "Game"), ("Game", "Anchor"), ("Anchor", "Game"), ("Anchor", "Anchor")])
        @test T.level == 1 && Dimension(T, TB5_N) == 1 && T.field_size == 2
        one1 = [one(GF2)]
        @test Marginal(T, TB5_N, :alice, 1, one1, "Game") == one1
        @test Marginal(T, TB5_N, :alice, 1, one1, "Anchor") == [zero(GF2)]
        @test Linear(T, TB5_N, :bob, 1, [zero(GF2)], one1, "Anchor") == [zero(GF2)]
        # Anchor's Factor: all-ones at stage 1 and empty thereafter
        # (SOURCE_REPAIR(zero-map-factor-partition), gt-11:96 vs rk:higher-level).
        @test Factor(T, TB5_N, :alice, 1, [zero(GF2)], "Anchor") == [1]
        @test Factor(T, TB5_N, :alice, 1, one1, "Anchor") isa QueryError   # prefix not in L_{<1}(V) = {0}
        @test Marginal(T, TB5_N, :alice, 1, one1, "Referee") isa QueryError
        repair = tb5_find(ta.certificate, :zero_map_factor_partition)
        @test length(repair) >= 1 && all(n.grade == SOURCE_REPAIR for n in repair)
        # NOTE-A: an Anchor-scoped enu:cl-space-sum assertion.
        for w in (:alice, :bob)
            r = cl_kth_replay(described_cl(T, TB5_N, w, "Anchor"), enumerate_seeds(GF2, 1); chain_set_id="tb5-anchor-type-exhaustive")
            @test r.space_sum_ok && r.map_sum_ok && r.completed_replays == 2
            g = cl_kth_replay(described_cl(T, TB5_N, w, "Game"), enumerate_seeds(GF2, 1); chain_set_id="tb5-game-type-exhaustive")
            @test g.space_sum_ok && g.map_sum_ok
        end
        @test passed(verify_certificate(ta))
        # pad_level_evidence is the promotion witness (tb2-r5 N23/N24): its
        # node is carried with the padding context marked.
        pad = tb5_find(ta.certificate, :pad_level)
        @test length(pad) == 1 && pad[1].grade == CHECKED && pad[1].facts.promoted
        @test pad[1].facts.padding_context == :top_level_ambient
        # The typed anchor decider.
        td = typed_anchor_decider(tb5_copy_decider().term)
        Dt = td.term
        @test Dt.typing isa Typed && Dt.typing.labels == ["Game", "Anchor"]
        @test decide(Dt, TB5_N, "Game", [true], "Game", [true], [true], [true])
        @test !decide(Dt, TB5_N, "Game", [true], "Game", [true], [false], [true])
        @test decide(Dt, TB5_N, "Anchor", [false], "Game", [true], [false], [true])
        @test decide(Dt, TB5_N, "Anchor", [false], "Game", [true], [false], [false])   # Game answers ignored
        @test !decide(Dt, TB5_N, "Anchor", [false], "Game", [true], [true], [true])    # Anchor must answer 0
        @test !decide(Dt, TB5_N, "Anchor", [false], "Anchor", [false], [false], Bool[]) # malformed rejects
        @test !decide(Dt, TB5_N, "Anchor", [false], "Anchor", [false], [false, false], [false])
        @test decide(Dt, TB5_N, "Anchor", [false], "Anchor", [false], [false], [false])
        @test !decide(Dt, TB5_N, "Referee", [false], "Game", [true], [false], [true])
        # Detyped (S^anch, D^anch): field 2, level 3, dimension 9.
        A = tb5_anchor().term
        @test A isa VerifierDescription
        @test A.sampler.field_size == 2 && A.sampler.level == 3 && Dimension(A.sampler, TB5_N) == 9
        @test A.sampler.typing isa Untyped && A.decider.typing isa Untyped
        @test A.sampler.dependency_set == Set{Any}([quote_hash(S)])
        @test A.decider.dependency_set == Set{Any}([quote_hash(tb5_copy_decider().term)])
        # The good (Game, Game) seed: z_G = (e_Game, neigh, e_Game, neigh), z_body = 1.
        z = tb5_gf2(Bool[1, 0, 1, 1, 1, 0, 1, 1, 1])
        x, y = sample_questions(A.sampler, TB5_N, z)
        @test tb5_bits(x) == Bool[1, 0, 1, 1, 0, 0, 1, 0, 1]
        @test tb5_bits(y) == Bool[0, 0, 1, 0, 1, 0, 1, 1, 1]
        @test decide(A.decider, TB5_N, tb5_bits(x), tb5_bits(y), [true], [true])
        @test !decide(A.decider, TB5_N, tb5_bits(x), tb5_bits(y), [false], [true])
        # Accept-on-invalid is literal (gt-06:409-427): a non-edge view accepts.
        @test decide(A.decider, TB5_N, falses(9), falses(9), [true], Bool[])
        @test decide(A.decider, TB5_N, Bool[1, 0], Bool[1], [true], Bool[])  # cannot parse -> accept
        # Detyped graph honest strategy: Game -> child, Anchor -> 0.
        @test anchored_honest_answer(A, :alice, tb5_bits(x), tb5_copy_honest) == [true]
        za = tb5_gf2(Bool[0, 1, 1, 1, 1, 0, 1, 1, 1])
        xa, ya = sample_questions(A.sampler, TB5_N, za)
        @test tb5_bits(xa)[1:8] == Bool[0, 1, 1, 1, 0, 0, 0, 1]
        @test anchored_honest_answer(A, :alice, tb5_bits(xa), tb5_copy_honest) == [false]
        @test decide(A.decider, TB5_N, tb5_bits(xa), tb5_bits(ya), [false], [true])
        # Level and dimension laws of the public anchor (DESIGN 9.4 table).
        @test A.sampler.level == S.level + 2 && Dimension(A.sampler, TB5_N) == Dimension(S, TB5_N) + 8
        @test canonical_bytes(decode_sampler(canonical_bytes(A.sampler))) == canonical_bytes(A.sampler)
        @test canonical_bytes(decode_decider(canonical_bytes(A.decider))) == canonical_bytes(A.decider)
        println("MUTATION_EXPECTED_RULE tb5_anchor level=", A.sampler.level, " dimension=", Dimension(A.sampler, TB5_N))
    end
end

if tb5_runs("tb5_repeat")
    @testset "TB5 (f) repeat_sampler / repeat_decider at lambda = tau = c' = 1, n = 9: B = 9, k = 81, level 3, dimension 729" begin
        R = tb5_repeat()
        V = R.term
        @test V isa VerifierDescription
        @test k_rep(TB5_LAMBDA, TB5_TAU, TB5_C_PRIME, TB5_N) == 81
        @test B_rep(TB5_LAMBDA, TB5_TAU, TB5_N) == 9
        @test V.sampler.level == 3 && Dimension(V.sampler, TB5_N) == 729 && V.sampler.field_size == 2
        @test Dimension(V.sampler, 2) == 4 * 9
        @test V.sampler.level_law == :(ell_1) && V.sampler.dimension_law == :(k(n) * s_1(n))
        @test V.sampler.k_law == :((lambda * n) ^ ((1 + c_prime) * tau))
        @test V.sampler.query_time == :(k(n) * C_1(n))
        # The compact loop is never unrolled: description_size is independent of k.
        R2 = anchored_repeat(tb5_copy_verifier(), 2, TB5_TAU; c_prime=TB5_C_PRIME, tracer_index=TB5_N)
        @test k_rep(2, TB5_TAU, TB5_C_PRIME, TB5_N) == 324
        @test description_size(R2.term.sampler) == description_size(V.sampler)
        @test description_size(R2.term.decider) == description_size(V.decider)
        @test Dimension(R2.term.sampler, TB5_N) == 324 * 9
        # Integrality of k(n) is an ASSUMED witness; the universal-bound
        # predicate is NOT_EVALUABLE; the gt-12:70 inconsistency is reported.
        integrality = tb5_find(R.certificate, :KRepIntegrality)
        @test length(integrality) == 1 && integrality[1].grade == ASSUMED && integrality[1].facts.status == PASS
        universal = tb5_find(R.certificate, :UniversalConstantBound)
        @test length(universal) == 1 && universal[1].grade == ASSUMED && universal[1].facts.status == NOT_EVALUABLE
        @test occursin("owner=", universal[1].facts.display)
        finding = tb5_find(R.certificate, :RepetitionCountInconsistency)
        @test length(finding) == 1 && finding[1].grade == SOURCE_REPAIR
        @test occursin("gt-12-compression.tex:L70", finding[1].facts.display)
        @test occursin("(lambda*n)^tau", finding[1].facts.display)
        # A non-integer k(n) is refused at the boundary, on the VALUE: 3^(3/2)
        # is irrational, but 9^(3/2) = 27 is admitted (verdicts/tb5-r1.md O3).
        refused = Dimension(anchored_repeat(tb5_copy_verifier(), 1, 1; c_prime=1 // 2, tracer_index=2, seeds=0).term.sampler, 3)
        @test refused isa QueryError && occursin("3^(3/2) is not a positive integer", refused.reason)
        @test k_rep(1, 1, 1 // 2, 9) == 27 && k_rep(1, 1, 2 // 3, 8) == 32
        @test_throws ArgumentError k_rep(2, 1, 1 // 2, 9)   # 18^(3/2) = sqrt(5832) is irrational
        R27 = anchored_repeat(tb5_copy_verifier(), 1, 1; c_prime=1 // 2, tracer_index=TB5_N, seeds=4)
        @test Dimension(R27.term.sampler, TB5_N) == 27 * 9
        @test only(tb5_find(R27.certificate, :KRepIntegrality)).facts.status == PASS
        @test occursin("k(9) = (1*9)^((1 + 1//2)*1) = 27", only(tb5_find(R27.certificate, :KRepIntegrality)).facts.display)
        @test passed(verify_certificate(R27))
        println("MUTATION_EXPECTED_RULE tb5_integrality k(9)@c'=1/2=", k_rep(1, 1, 1 // 2, 9), " dimension=", Dimension(R27.term.sampler, TB5_N))
        # verdicts/tb5-r1.md O4: the gt-11:L219/L220 guard-exponent finding is disclosed.
        guard = tb5_find(R.certificate, :RepeatGuardExponent)
        @test length(guard) == 1 && guard[1].grade == SOURCE_REPAIR
        @test occursin("gt-11-parallel-repetition.tex:L219", guard[1].facts.display) && occursin("c' = 1", guard[1].facts.display)
        @test guard[1].facts.lines == 219:220
        # verdicts/tb5-r1.md O2 (ii): the prefix-dependent-factor child repeated
        # 4-fold at n = 2 (k = 4, dimension 16): each block's Factor is that
        # block's child factor at that block's prefix (gt-11:L281).
        pr = tb5_prefix_dependent_repeat()
        @test pr.child isa Checked && passed(verify_certificate(pr.child))
        @test level(tb5_prefix_dependent_child()) == 3
        @test Factor(pr.child.term, 2, :alice, 2, tb5_zero(4)) == [0, 1, 0, 0]
        @test Factor(pr.child.term, 2, :alice, 2, tb5_e(1, 4)) == [0, 1, 1, 0]
        Sp = pr.repeat.term
        @test Dimension(Sp, 2) == 16 && Sp.level == 3
        @test Factor(Sp, 2, :alice, 2, tb5_e(1, 16)) == Bool[0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0]
        @test Factor(Sp, 2, :bob, 2, tb5_e(5, 16)) == Bool[0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0]
        @test Factor(Sp, 2, :alice, 2, tb5_e(1, 16) + tb5_e(13, 16)) == Bool[0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0]
        @test Factor(Sp, 2, :alice, 3, tb5_e(1, 16) + tb5_e(2, 16) + tb5_e(6, 16)) == Bool[0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1]
        @test Factor(Sp, 2, :alice, 2, tb5_e(6, 16)) isa QueryError      # block 2's coordinate 2 is not in L_{<2}(V) of that block
        @test Factor(Sp, 2, :alice, 2, tb5_e(1, 16) + tb5_e(7, 16)) isa QueryError
        @test passed(verify_certificate(pr.repeat))
        # O2 (i): the metered counts are pinned exactly (Marginal, Factor AND Linear = k).
        for (mode, q) in (("Marginal", MarginalQuery(2, :alice, 3, tb5_zero(16), nothing)),
                          ("Factor", FactorQuery(2, :alice, 1, tb5_zero(16), nothing)),
                          ("Linear", LinearQuery(2, :alice, 1, tb5_zero(16), tb5_zero(16), nothing)))
            @test metered_query(Sp, q)[2].child_calls == 4
        end
        @test metered_query(Sp, FactorQuery(2, :alice, 2, tb5_e(1, 16), nothing))[2].child_calls == 4
        metered_pr = only(tb5_find(pr.repeat.certificate, :MeteredCalls))
        @test metered_pr.facts.measured == (; marginal=4, factor=4, linear=4)
        @test occursin("exactly 4", metered_pr.facts.display)
        println("MUTATION_EXPECTED_RULE tb5_prefix_factor block_factors=", Factor(Sp, 2, :alice, 2, tb5_e(1, 16)), " metered=", metered_pr.facts.measured)
        # verdicts/tb5-r1.md O7 (a): DESIGN 10.2 and the emitted law agree.
        design = read(joinpath(TB5_ROOT, "docs", "DESIGN.md"), String)
        @test occursin("question_length(n), answer_length(n) <= k(n)*(B(n)+32)", design)
        @test !occursin("question_length(n), answer_length(n) <= k(n)*B(n)\n", design)
        @test V.decider.question_length == :(k(n) * (B(n) + 32))
        # Decider metadata (DESIGN 10.2).
        @test V.decider.question_length == :(k(n) * (B(n) + 32))
        @test V.decider.answer_length == :(k(n) * (B(n) + 32))
        @test V.decider.time_bound == :(O(k(n) * max(TIME_1(n), B(n))))
        @test V.decider.B_law == :((lambda * n) ^ tau)
        # Blockwise sample replay (M5-shared-seed owner): every block of the
        # repeated marginal is the anchored marginal of that block's seed.
        rng = MersenneTwister(0x7E)
        A = tb5_anchor().term
        blockwise = true
        for _ in 1:8
            z = GF2[rand(rng, (zero(GF2), one(GF2))) for _ in 1:729]
            for w in (:alice, :bob), j in 1:3
                out = Marginal(V.sampler, TB5_N, w, j, z)
                for i in 1:81
                    block = (i - 1) * 9 + 1:i * 9
                    blockwise &= out[block] == Marginal(A.sampler, TB5_N, w, j, z[block])
                end
            end
        end
        @test blockwise
        println("MUTATION_EXPECTED_RULE tb5_repeat blockwise=", blockwise, " k=81 B=9 size=", description_size(V.sampler))
        @test passed(verify_certificate(R))
        @test canonical_bytes(decode_sampler(canonical_bytes(V.sampler))) == canonical_bytes(V.sampler)
        @test canonical_bytes(decode_decider(canonical_bytes(V.decider))) == canonical_bytes(V.decider)
        # The metered call law: one repeated Marginal issues exactly k child Marginals.
        answer, meter = metered_query(V.sampler, MarginalQuery(TB5_N, :alice, 3, tb5_zero(729), nothing))
        @test meter.child_calls == 81
        metered = tb5_find(R.certificate, :MeteredCalls)
        @test length(metered) >= 3 && all(m.grade == CHECKED for m in metered)   # S^rep, S^anch, the typed anchor
        println("TB5 (f) warm construction seconds = ", TB5_LOG[:construction_seconds],
                " (DESIGN 10.3 gate < 2); total bytes allocated during construction MiB = ", TB5_LOG[:construction_alloc_MiB],
                "; peak RSS delta MiB = ", TB5_LOG[:construction_peak_rss_delta_MiB],
                "; GC live-heap delta MiB = ", TB5_LOG[:construction_live_delta_MiB])
        println("MUTATION_EXPECTED_RULE tb5_walls construction<2 => ", TB5_LOG[:construction_seconds] < 2)
        @test TB5_LOG[:construction_seconds] < 2
        @test TB5_LOG[:construction_peak_rss_delta_MiB] < 256
    end
end

# Honest repeated transcript at seed z: framed questions and answers.
function tb5_honest_transcript(V::VerifierDescription, A::VerifierDescription, z)
    k = k_rep(TB5_LAMBDA, TB5_TAU, TB5_C_PRIME, TB5_N)
    x, y = sample_questions(V.sampler, TB5_N, z)
    xs = [tb5_bits(x[(i - 1) * 9 + 1:i * 9]) for i in 1:k]
    ys = [tb5_bits(y[(i - 1) * 9 + 1:i * 9]) for i in 1:k]
    as = [anchored_honest_answer(A, :alice, xi, tb5_copy_honest) for xi in xs]
    bs = [anchored_honest_answer(A, :bob, yi, tb5_copy_honest) for yi in ys]
    (; xs, ys, as, bs)
end

if tb5_runs("tb5_transcripts")
    @testset "TB5 (g) 128 seeded honest repeated pairs accept; T5-game-seed1, T5-anchor-one, T5-one-corrupt, T5-boundary" begin
        V = tb5_repeat().term
        A = tb5_anchor().term
        D = V.decider
        labels, edges = A.decider.term[2], A.decider.term[3]
        game = findfirst(==("Game"), labels)
        # Warm the transcript path once (compilation), then time the 128
        # draws and the named transcripts (DESIGN 10.3's transcript wall).
        let t0 = tb5_honest_transcript(V, A, tb5_gf2(falses(729)))
            decide_traced(D, TB5_N, frame_components(t0.xs), frame_components(t0.ys), frame_components(t0.as), frame_components(t0.bs))
        end
        started = time()
        rng = MersenneTwister(0x5E)
        accepted = 0
        edge_views = 0     # components whose two graph views encode an oriented edge (verdicts/tb5-r1.md O8)
        game_pairs = 0     # ... and are (Game, Game), reaching the child decider
        seed_views = 0     # the same census read off the SEEDS: z_eA = z_eB = (1,1), z_vA and z_vB unit
        seed_games = 0
        for _ in 1:128
            z = GF2[rand(rng, (zero(GF2), one(GF2))) for _ in 1:729]
            for i in 1:81
                blk = tb5_bits(z[(i - 1) * 9 + 1:i * 9])
                (blk[3:4] == [true, true] && blk[7:8] == [true, true] && sum(blk[1:2]) == 1 && sum(blk[5:6]) == 1) || continue
                seed_views += 1
                blk[1] && blk[5] && (seed_games += 1)   # e_Game = e_1 on both sides
            end
            t = tb5_honest_transcript(V, A, z)
            bit, calls = decide_traced(D, TB5_N, frame_components(t.xs), frame_components(t.ys),
                                       frame_components(t.as), frame_components(t.bs))
            bit && length(calls) == 81 && (accepted += 1)
            for i in 1:81
                tA = MIPStarLambda._graph_view_type(labels, edges, :alice, t.xs[i])
                tB = MIPStarLambda._graph_view_type(labels, edges, :bob, t.ys[i])
                (tA === nothing || tB === nothing || !((tA, tB) in edges)) && continue
                edge_views += 1
                tA == game == tB && (game_pairs += 1)
            end
        end
        println("MUTATION_EXPECTED_RULE tb5_transcripts honest_accepts=", accepted, "/128 edge_views=", edge_views,
                "/10368 game_game=", game_pairs, "/10368 (the rest accept on the literal invalid-view branch, gt-06:409-427)")
        @test accepted == 128
        # These are this test's own seeds (rand from the tuple (0, 1) on
        # MersenneTwister(0x5E)); the critic's 159 / 40 (verdicts/tb5-r1.md O8)
        # is the count on the `rand(rng, Bool, 729)` stream of the same
        # seed, i.e. different draws (expected 10368/64 = 162 either way).
        @test edge_views == 185 && game_pairs == 42
        @test (edge_views, game_pairs) == (seed_views, seed_games)
        # T5-game-seed1: seed 1 = the (Game, Game) view with body 1; the
        # reference Game question is 1 and the golden answer is 1. Mapping
        # Game to zero changes the question but not the golden answer.
        z1 = tb5_gf2(Bool[1, 0, 1, 1, 1, 0, 1, 1, 1])
        x1, y1 = sample_questions(A.sampler, TB5_N, z1)
        @test tb5_bits(x1)[9] == true && tb5_bits(y1)[9] == true
        golden = [true]
        @test decide(A.decider, TB5_N, tb5_bits(x1), tb5_bits(y1), golden, golden)
        # The same seed in every block of the repeated game.
        zrep = repeat(z1, 81)
        t1 = tb5_honest_transcript(V, A, zrep)
        @test all(==(golden), t1.as) && all(==(golden), t1.bs)
        @test decide(D, TB5_N, frame_components(t1.xs), frame_components(t1.ys),
                     frame_components(t1.as), frame_components(t1.bs))
        # The query-reference replay: S^anch's Game marginal equals the
        # in-memory child map on the body coordinate.
        @test Marginal(A.sampler, TB5_N, :alice, 3, z1)[9] == apply(tb5_copy_map(), (one(GF2),))[1]
        println("MUTATION_EXPECTED_RULE T5-game-seed1 accept=true question=", tb5_bits(x1)[9])
        # T5-anchor-one: an Anchor-typed player answers 1.
        za = tb5_gf2(Bool[0, 1, 1, 1, 1, 0, 1, 1, 1])
        xa, ya = sample_questions(A.sampler, TB5_N, za)
        @test decide(A.decider, TB5_N, tb5_bits(xa), tb5_bits(ya), [false], [true])
        @test !decide(A.decider, TB5_N, tb5_bits(xa), tb5_bits(ya), [true], [true])
        ta = tb5_honest_transcript(V, A, repeat(za, 81))
        @test decide(D, TB5_N, frame_components(ta.xs), frame_components(ta.ys),
                     frame_components(ta.as), frame_components(ta.bs))
        corrupt_anchor = copy(ta.as)
        corrupt_anchor[5] = [true]
        @test !decide(D, TB5_N, frame_components(ta.xs), frame_components(ta.ys),
                      frame_components(corrupt_anchor), frame_components(ta.bs))
        println("MUTATION_EXPECTED_RULE T5-anchor-one reject=true")
        # T5-one-corrupt: exactly one of the 81 otherwise honest answer
        # components changes; the repeated AND rejects.
        z = GF2[rand(rng, (zero(GF2), one(GF2))) for _ in 1:729]
        t = tb5_honest_transcript(V, A, z)
        game_blocks = [i for i in 1:81 if t.xs[i][1:8] == Bool[1, 0, 1, 1, 0, 0, 1, 0] && t.ys[i][1:8] == Bool[0, 0, 1, 0, 1, 0, 1, 1]]
        @test !isempty(game_blocks)
        i = first(game_blocks)
        corrupted = copy(t.as)
        corrupted[i] = Bool[!t.as[i][1]]
        bit, calls = decide_traced(D, TB5_N, frame_components(t.xs), frame_components(t.ys),
                                   frame_components(corrupted), frame_components(t.bs))
        @test !bit && length(calls) == 81
        @test count(c -> !c.accepted, calls) == 1 && calls[i].accepted == false
        println("MUTATION_EXPECTED_RULE T5-one-corrupt reject=true child_calls=", length(calls))
        # T5-last-corrupt (verdicts/tb5-r1.md O1): the all-Game transcript
        # (every component a (Game, Game) edge view) with component k = 81
        # flipped must reject with exactly one rejecting child call, the last.
        @test all(MIPStarLambda._graph_view_type(labels, edges, :alice, xi) == game for xi in t1.xs)
        @test all(MIPStarLambda._graph_view_type(labels, edges, :bob, yi) == game for yi in t1.ys)
        last_corrupt = copy(t1.as)
        last_corrupt[81] = Bool[!t1.as[81][1]]
        bit_last, calls_last = decide_traced(D, TB5_N, frame_components(t1.xs), frame_components(t1.ys),
                                             frame_components(last_corrupt), frame_components(t1.bs))
        @test !bit_last && length(calls_last) == 81
        @test count(c -> !c.accepted, calls_last) == 1 && !calls_last[81].accepted
        for i in (1, 40)
            mid_corrupt = copy(t1.as)
            mid_corrupt[i] = Bool[!t1.as[i][1]]
            bit_i, calls_i = decide_traced(D, TB5_N, frame_components(t1.xs), frame_components(t1.ys),
                                           frame_components(mid_corrupt), frame_components(t1.bs))
            @test !bit_i && count(c -> !c.accepted, calls_i) == 1 && !calls_i[i].accepted
        end
        println("MUTATION_EXPECTED_RULE T5-last-corrupt reject=", !bit_last, " rejecting_index=", findfirst(c -> !c.accepted, calls_last))
        # T5-boundary (NOTE-D): the exactly-9-bit component is a QUESTION
        # component and is accepted; a 10-bit component is rejected with the
        # child-call log EMPTY (DD-26).
        @test all(length(xi) == 9 == B_rep(TB5_LAMBDA, TB5_TAU, TB5_N) for xi in t.xs)
        bit9, calls9 = decide_traced(D, TB5_N, frame_components(t.xs), frame_components(t.ys),
                                     frame_components(t.as), frame_components(t.bs))
        @test bit9 && length(calls9) == 81
        long = copy(t.xs)
        long[i] = vcat(t.xs[i], false)
        bit10, calls10 = decide_traced(D, TB5_N, frame_components(long), frame_components(t.ys),
                                       frame_components(t.as), frame_components(t.bs))
        @test !bit10 && isempty(calls10)
        # The guard covers all four tuples (gt-11:219): an oversized answer
        # component and a malformed k-tuple are rejected before any child call.
        long_a = copy(t.as)
        long_a[i] = trues(10)
        @test decide_traced(D, TB5_N, frame_components(t.xs), frame_components(t.ys),
                            frame_components(long_a), frame_components(t.bs)) == (false, [])
        @test decide_traced(D, TB5_N, frame_components(t.xs[1:80]), frame_components(t.ys),
                            frame_components(t.as), frame_components(t.bs)) == (false, [])
        @test decide_traced(D, TB5_N, vcat(frame_components(t.xs), false), frame_components(t.ys),
                            frame_components(t.as), frame_components(t.bs)) == (false, [])
        println("MUTATION_EXPECTED_RULE T5-boundary accept9=", bit9, " reject10=", !bit10, " pre_call_log_empty=", isempty(calls10))
        TB5_LOG[:transcript_seconds] = round(time() - started; digits=3)
        println("TB5 (g) warm transcript seconds = ", TB5_LOG[:transcript_seconds], " (DESIGN 10.3 gate < 5)")
        println("MUTATION_EXPECTED_RULE tb5_walls transcripts<5 => ", TB5_LOG[:transcript_seconds] < 5)
        @test TB5_LOG[:transcript_seconds] < 5
    end
end

if tb5_runs("tb5_independence")
    @testset "TB5 (h) sampler independence: byte-distinct deciders, identical canonical S^rep; dependency set exactly {hash(S), lambda, tau, c_prime}" begin
        S = tb5_copy_sampler().term
        V1 = VerifierDescription(S, copy_decider().term)
        V2 = VerifierDescription(S, trivial_decider().term)
        @test canonical_bytes(V1.decider) != canonical_bytes(V2.decider)
        R1 = anchored_repeat(V1, TB5_LAMBDA, TB5_TAU; c_prime=TB5_C_PRIME, tracer_index=TB5_N, seeds=4)
        R2 = anchored_repeat(V2, TB5_LAMBDA, TB5_TAU; c_prime=TB5_C_PRIME, tracer_index=TB5_N, seeds=4)
        @test canonical_bytes(R1.term.sampler) == canonical_bytes(R2.term.sampler)
        @test quote_hash(R1.term.sampler) == quote_hash(R2.term.sampler)
        @test quote_hash(R1.term.sampler) == quote_hash(tb5_repeat().term.sampler)
        @test canonical_bytes(R1.term.decider) != canonical_bytes(R2.term.decider)
        expected = Set{Any}([quote_hash(S), :lambda, :tau, :c_prime])
        @test dependency_set(R1.term.sampler) == expected
        @test dependency_walk(canonical_bytes(R1.term.sampler)) == expected
        @test !(quote_hash(V1.decider) in dependency_set(R1.term.sampler))
        node = only(tb5_find(R1.certificate, :SamplerIndependence))
        @test node.grade == CHECKED
        println("MUTATION_EXPECTED_RULE tb5_independence hash=", quote_hash(R1.term.sampler),
                " dependency_set=", sort(string.(collect(expected))))
    end
end

if tb5_runs("tb5_cited")
    @testset "TB5 (i) TIME_D(n) <= B(n) printed NOT_EVALUABLE(owner=...) (DD-31); PCC completeness / Ent CITED by grepped labels" begin
        R = tb5_repeat()
        hyp = tb5_find(R.certificate, :completeness_decider_time)
        @test length(hyp) >= 1
        @test any(occursin("NOT_EVALUABLE(owner=", n.facts.display) for n in hyp)
        @test any(n.facts.status == NOT_EVALUABLE for n in hyp)
        cited = [n for n in tb5_nodes(R.certificate) if n.grade == CITED]
        labels = Set(n.rule for n in cited)
        for label in (Symbol("thm:repetition"), Symbol("prop:anchoring"), Symbol("lem:detyping-verifiers"),
                      Symbol("lem:cl-func-prod"), Symbol("lem:cl-concat"), Symbol("lem:cl-kth"))
            @test label in labels
        end
        for leaf in cited
            @test haskey(leaf.facts, :source) && haskey(leaf.facts, :lines)
            lines = tb5_first_lines(leaf.facts.source)
            range = leaf.facts.lines
            @test any(occursin("\\label{$(String(leaf.rule))}", lines[i]) for i in range)
            @test leaf.replay === nothing
        end
        for node in tb5_nodes(R.certificate)
            node.grade == CHECKED && @test node.replay !== nothing
        end
        println("MUTATION_EXPECTED_RULE tb5_cited labels=", sort(string.(collect(labels))))
    end
end

if tb5_runs("tb5_stage")
    @testset "TB5 Repeat as a CompressStage swappable for TB4's stub" begin
        stage = ExecutableRepeat(; c_prime=TB5_C_PRIME, tracer_index=TB5_N, seeds=4)
        out = Repeat(stage, tb5_copy_verifier(), TB5_LAMBDA, TB5_TAU)
        @test out.term isa StageVerifier && out.term.origin == :Repeat
        @test out.term.levels == 3 && out.term.payload isa VerifierDescription
        @test Dimension(out.term.payload.sampler, TB5_N) == 729
        @test out.certificate.rule == :Repeat
        @test !isempty(tb5_find(out.certificate, Symbol("thm:repetition")))
        @test out.term.sampler_dependencies == (:S, :lambda, :tau, :c_prime)
        stub = Repeat(RepeatStub(), tb5_copy_verifier(), TB5_LAMBDA, TB5_TAU)
        @test stub.term isa StubVerifier && stub.term.levels == 3
        @test passed(verify_certificate(out))
    end
end

if tb5_runs("tb5_tree")
    @testset "TB5 (j) the full certificate tree of Repeat(V_copy)" begin
        R = tb5_repeat()
        grades = tb5_grades(R.certificate)
        println("TB5 certificate tree of Repeat(V_copy): nodes = ", length(tb5_nodes(R.certificate)),
                " CONSTRUCTED=", grades[CONSTRUCTED], " CHECKED=", grades[CHECKED], " CITED=", grades[CITED],
                " ASSUMED=", grades[ASSUMED], " SOURCE_REPAIR=", grades[SOURCE_REPAIR])
        traceprint(R.certificate)
        # verdicts/tb5-r1.md O6: the census is pinned exactly (nodes,
        # CONSTRUCTED, CHECKED, CITED, ASSUMED, SOURCE_REPAIR) and every
        # CHECKED node carries a replay.
        census = (length(tb5_nodes(R.certificate)), grades[CONSTRUCTED], grades[CHECKED], grades[CITED], grades[ASSUMED], grades[SOURCE_REPAIR])
        println("MUTATION_EXPECTED_RULE tb5_tree census=", census)
        @test census == (56, 9, 27, 10, 4, 6)
        @test all(n.grade != CHECKED || n.replay !== nothing for n in tb5_nodes(R.certificate))
        @test passed(verify_certificate(R))
        walls = (; construction=get(TB5_LOG, :construction_seconds, nothing),
                   transcripts=get(TB5_LOG, :transcript_seconds, nothing),
                   product=get(TB5_LOG, :product_seconds, nothing))
        println("TB5 walls (warm): ", walls, "; total bytes allocated during construction MiB = ", get(TB5_LOG, :construction_alloc_MiB, nothing),
                "; construction peak RSS delta MiB = ", get(TB5_LOG, :construction_peak_rss_delta_MiB, nothing),
                "; process peak RSS MiB = ", round(Sys.maxrss() / 2^20; digits=1))
        if walls.construction !== nothing && walls.transcripts !== nothing
            println("MUTATION_EXPECTED_RULE tb5_walls total<7 => ", walls.construction + walls.transcripts < 7)
            @test walls.construction + walls.transcripts < 7
        end
    end
end
