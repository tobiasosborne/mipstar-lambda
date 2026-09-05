using Test
using MIPStarLambda
Base.Experimental.@optlevel 0

const TB1_TARGET = get(ENV, "TB1_TARGET", "all")
tb1_runs(name) = TB1_TARGET == "all" || TB1_TARGET == name

const TB1_F = GF8
const TB1_M = 2
const TB1_D = 1
const TB1_ELEMS = Tuple(field_elements(TB1_F))

tb1_int(x::GF2k) = Int(x.bits)
tb1_tuple(xs) = Tuple(xs)

function tb1_seeds()
    ((a, b, s, c, d) for a in TB1_ELEMS for b in TB1_ELEMS
                       for s in TB1_ELEMS for c in TB1_ELEMS for d in TB1_ELEMS)
end

function tb1_ref_lnf(v::Tuple, u::Tuple)
    pivot = findfirst(!iszero, v)
    pivot === nothing && return u # DESIGN SOURCE_REPAIR for def:line's v=0.
    scale = u[pivot] / v[pivot]
    ntuple(j -> u[j] - scale * v[j], length(u))
end

function tb1_transcribed_histograms()
    axis = Dict{Any,Int}()
    diagonal = Dict{Any,Int}()
    bucket_width = field_size(TB1_F) ÷ TB1_M
    for seed in tb1_seeds()
        u = (seed[1], seed[2])
        s = seed[3]
        v = (seed[4], seed[5])
        # Separate transcription of eq:cl-ptf/alnf/dlnf, including eq:chi-func.
        # This joint (line,point) histogram is deliberately not chi-independent.
        i = 1 + div(tb1_int(s), bucket_width)
        e_i = ntuple(j -> TB1_F(j == i), TB1_M)
        v_prime = ntuple(j -> j < i ? zero(TB1_F) : v[j], TB1_M)
        point_raw = (u..., zero(TB1_F), zero(TB1_F), zero(TB1_F))
        axis_raw = (tb1_ref_lnf(e_i, u)..., s, zero(TB1_F), zero(TB1_F))
        diagonal_raw = (tb1_ref_lnf(v_prime, u)..., s, v_prime...)
        axis[(axis_raw, point_raw)] = get(axis, (axis_raw, point_raw), 0) + 1
        diagonal[(diagonal_raw, point_raw)] =
            get(diagonal, (diagonal_raw, point_raw), 0) + 1
    end
    (; axis, diagonal)
end

function tb1_chifree_marginals()
    axis = Dict{Any,Int}()
    diagonal = Dict{Any,Int}()
    bucket_labels = 1:(field_size(TB1_F) ÷ TB1_M)
    for i in 1:TB1_M, _ in bucket_labels, u1 in TB1_ELEMS,
        u2 in TB1_ELEMS, v1 in TB1_ELEMS, v2 in TB1_ELEMS
        u = (u1, u2)
        v = (v1, v2)
        e_i = ntuple(j -> TB1_F(j == i), TB1_M)
        v_prime = ntuple(j -> j < i ? zero(TB1_F) : v[j], TB1_M)
        axis_key = (AffineLine(tb1_ref_lnf(e_i, u), e_i), u)
        diagonal_key = (AffineLine(tb1_ref_lnf(v_prime, u), v_prime), u)
        axis[axis_key] = get(axis, axis_key, 0) + 1
        diagonal[diagonal_key] = get(diagonal, diagonal_key, 0) + 1
    end
    (; axis, diagonal)
end

if tb1_runs("levels")
    @testset "TB1 datatype levels" begin
        point = L_Point(TB1_F, TB1_M)
        axis = L_ALine(TB1_F, TB1_M)
        diagonal = L_DLine(TB1_F, TB1_M)
        # gt-07-ldt.tex eq:cl-ptf, eq:cl-alnf, eq:cl-dlnf.
        @test (level(point), level(axis), level(diagonal)) == (1, 2, 3)
        @test seed_dim(point) == seed_dim(axis) == seed_dim(diagonal) == 5
        @test register_indices(point) == register_indices(axis) ==
              register_indices(diagonal) == (1, 2, 3, 4, 5)
        @test level(pad_level(point, 5)) == 5
        identity2 = [one(TB1_F) zero(TB1_F);
                     zero(TB1_F) one(TB1_F)]
        @test_throws ArgumentError CLStep(
            TB1_F, 5, (1, 2), (3,), identity2,
            CLZero(TB1_F, 5, (3,)))

        calls = Ref(0)
        lazy_child = CLZero(TB1_F, 2, (2,))
        lazy = CLStep(TB1_F, 2, (1,), (2,), reshape([one(TB1_F)], 1, 1),
                      lazy_child) do _
            calls[] += 1
            lazy_child
        end
        @test calls[] == 0
        apply(lazy, (TB1_F(3), TB1_F(4)))
        apply(lazy, (TB1_F(3), TB1_F(5)))
        @test calls[] == 1 # the reached image value is memoised

        # verdicts/tb1-r2.md N2: the lazy continuation validation is the only
        # enforcement of DD-7's "level cannot be forged"; each guard is
        # reached through `apply`, never at construction.
        one1 = reshape([one(TB1_F)], 1, 1)
        # A genuine level-1 map on register {2} (promoted zero map): only the
        # continuation-level guard can reject it.
        wrong_level = CLStep(TB1_F, 2, (1,), (2,), one1, CLZero(TB1_F, 2, (2,))) do _
            pad_level(CLZero(TB1_F, 2, (2,)), 1)
        end
        @test level(pad_level(CLZero(TB1_F, 2, (2,)), 1)) == 1
        @test_throws ArgumentError apply(wrong_level, (TB1_F(1), TB1_F(2)))
        wrong_register = CLStep(TB1_F, 2, (1,), (2,), one1, CLZero(TB1_F, 2, (2,))) do _
            CLZero(TB1_F, 2, (1,))
        end
        @test_throws ArgumentError apply(wrong_register, (TB1_F(1), TB1_F(2)))
        wrong_dimension = CLStep(TB1_F, 2, (1,), (2,), one1, CLZero(TB1_F, 2, (2,))) do _
            CLZero(TB1_F, 3, (2,))
        end
        @test_throws ArgumentError apply(wrong_dimension, (TB1_F(1), TB1_F(2)))
        wrong_field = CLStep(TB1_F, 2, (1,), (2,), one1, CLZero(TB1_F, 2, (2,))) do _
            CLZero(GF2048, 2, (2,))
        end
        @test_throws ArgumentError apply(wrong_field, (TB1_F(1), TB1_F(2)))
        @test_throws ArgumentError CLStep(TB1_F, 5, (1, 2), (3,), identity2,
                                          CLZero(TB1_F, 5, (3,))) do _
            CLZero(TB1_F, 5, (3,))
        end

        @test level(concatenate(point, L_Point(TB1_F, TB1_M))) == 2
        @test level(direct_sum(point, axis)) == 2
        typed = TypedSampler((:point, :axis), ((:point, :axis),),
            Dict(:point => point, :axis => axis),
            Dict(:point => point, :axis => axis))
        @test typed.common_level == 2

        # verdicts/tb1-r2.md N5 / tb2-r2.md N3 (DESIGN 9.4): padding APPENDS
        # empty stages, so every marginal of the child survives; a zero map
        # on a register is promoted with that whole register as stage 1
        # (rk:higher-level, SOURCE_REPAIR zero-map-factor-partition).
        seed = (TB1_F(3), TB1_F(5), TB1_F(4), TB1_F(6), TB1_F(7))
        padded_axis = pad_level(axis, 3)
        @test marginal_k(padded_axis, seed, 1).value == marginal_k(axis, seed, 1).value
        @test marginal_k(padded_axis, seed, 2).value == apply(axis, seed)
        @test marginal_k(padded_axis, seed, 3).factor_spaces ==
              [[3, 4, 5], [1, 2], Int[]]
        @test marginal_k(pad_level(point, 5), seed, 5).factor_spaces ==
              [collect(1:5), Int[], Int[], Int[], Int[]]
        padded_zero = pad_level(CLZero(TB1_F, 5), 3)
        @test level(padded_zero) == 3
        @test apply(padded_zero, seed) == ntuple(_ -> zero(TB1_F), 5)
        @test marginal_k(padded_zero, seed, 3).factor_spaces ==
              [collect(1:5), Int[], Int[]]
        @test Factor(padded_zero, 1, ntuple(_ -> zero(TB1_F), 5)) == ones(Int, 5)
        @test ZERO_MAP_FACTOR_PARTITION.grade == SOURCE_REPAIR
        @test ZERO_MAP_FACTOR_PARTITION.rule == :zero_map_factor_partition
    end
end

if tb1_runs("space_sum")
    @testset "TB1 lem:cl-kth enu:cl-space-sum / enu:cl-map-sum replay" begin
        # verdicts/tb1-r2.md N3: the replay TB2 runs, now on all three maps,
        # through DESIGN 9.1's four queries only (DESIGN 9.2).
        samplers = (L_Point(TB1_F, TB1_M), L_ALine(TB1_F, TB1_M),
                    L_DLine(TB1_F, TB1_M))
        seed = (TB1_F(3), TB1_F(5), TB1_F(4), TB1_F(6), TB1_F(7))
        for sampler in samplers
            factors = marginal_k(sampler, seed, level(sampler)).factor_spaces
            @test Set(Iterators.flatten(factors)) == Set(1:5)
            @test sum(length, factors) == 5
        end
        @test marginal_k(samplers[1], seed, 1).factor_spaces == [collect(1:5)]
        reports = [cl_kth_replay(sampler, tb1_seeds(); chain_set_id="tb1-exhaustive-8^5")
                   for sampler in samplers]
        for (sampler, report) in zip(samplers, reports)
            @test report.space_sum_ok
            @test report.map_sum_ok
            @test report.completed_replays == 8^5
            @test report.map_sum_checks == level(sampler) * 8^5
        end
        @test [report.distinct_chains for report in reports] == [1, 8, 288]
        # Negative witness: the r2 sub-ambient L_Point (factor {1,2}, level-0
        # tail on {3,4,5}) violates enu:cl-space-sum and the replay says so.
        identity2 = [one(TB1_F) zero(TB1_F); zero(TB1_F) one(TB1_F)]
        sub_ambient = CLStep(TB1_F, 5, (1, 2), (3, 4, 5), identity2,
                             CLZero(TB1_F, 5, (3, 4, 5)))
        negative = cl_kth_replay(sub_ambient, (seed,); chain_set_id="tb1-negative")
        @test !negative.space_sum_ok
        @test negative.map_sum_ok
        println("TB1 lem:cl-kth replay: chain_set_id=", reports[1].chain_set_id,
                " distinct_chains=", [r.distinct_chains for r in reports],
                " completed_replays=", [r.completed_replays for r in reports],
                " map_sum_checks=", [r.map_sum_checks for r in reports],
                " negative_witness_space_sum_ok=", negative.space_sum_ok)
    end
end

if tb1_runs("queries")
    @testset "TB1 def:sampler queries Dimension/Marginal/Linear/Factor" begin
        point = L_Point(TB1_F, TB1_M)
        axis = L_ALine(TB1_F, TB1_M)
        diagonal = L_DLine(TB1_F, TB1_M)
        z = (TB1_F(3), TB1_F(5), TB1_F(4), TB1_F(6), TB1_F(7))
        zero5 = ntuple(_ -> zero(TB1_F), 5)
        @test Dimension(point) == Dimension(axis) == Dimension(diagonal) == 5
        for L in (point, axis, diagonal), j in 0:level(L)
            @test Marginal(L, j, z) == marginal_k(L, z, j).value
        end
        @test Marginal(diagonal, 3, z) == apply(diagonal, z)
        # Factor returns a length-Dimension 0/1 indicator (DESIGN 9.1).
        @test Factor(axis, 1, zero5) == [0, 0, 1, 1, 1]
        @test Factor(point, 1, zero5) == [1, 1, 1, 1, 1]
        reachable = (zero(TB1_F), zero(TB1_F), TB1_F(4), zero(TB1_F), zero(TB1_F))
        @test Factor(axis, 2, reachable) == [1, 1, 0, 0, 0]
        @test Factor(diagonal, 2, reachable) == [0, 0, 0, 1, 1]
        @test Factor(diagonal, 3, Marginal(diagonal, 2, z)) == [1, 1, 0, 0, 0]
        # Factor's domain is L_{<j}(V): a direction component is never emitted
        # by L_ALine's stage 1, so this prefix is unreachable and rejected.
        unreachable = (zero(TB1_F), zero(TB1_F), TB1_F(4), one(TB1_F), zero(TB1_F))
        @test_throws ArgumentError Factor(axis, 2, unreachable)
        @test_throws ArgumentError Factor(axis, 1, reachable)
        # Linear's domain is the broader V_{<j}: the same unreachable prefix
        # is answered (never narrowed, gt-04-cl.tex:588-594), by the stage-2
        # map L_lnf(e_chi(4)) = L_lnf(e_2) on the V_pt projection of y.
        y = (TB1_F(3), TB1_F(5), TB1_F(1), TB1_F(2), TB1_F(3))
        e2 = (zero(TB1_F), one(TB1_F))
        expected = L_lnf(e2, (TB1_F(3), TB1_F(5)))
        @test Linear(axis, 2, unreachable, y) == (expected..., zero5[3:5]...)
        @test Linear(axis, 2, reachable, y) == (expected..., zero5[3:5]...)
        @test Linear(axis, 1, zero5, y) == (zero(TB1_F), zero(TB1_F), TB1_F(1),
                                           zero(TB1_F), zero(TB1_F))
        # Support outside V_{<j} is malformed for both prefix queries.
        @test_throws ArgumentError Linear(axis, 2, (one(TB1_F), zero5[2:5]...), y)
        @test_throws ArgumentError Linear(axis, 4, zero5, y)
        println("TB1 queries: Factor(L_ALine,1,0)=", Factor(axis, 1, zero5),
                " Factor(L_ALine,2,(0,0,4,0,0))=", Factor(axis, 2, reachable),
                " Linear at unreachable (0,0,4,1,0) answered=", true)
    end
end

if tb1_runs("describe")
    @testset "TB1 DESIGN 9.3 describability (QuotedBranch)" begin
        point = L_Point(TB1_F, TB1_M)
        axis = L_ALine(TB1_F, TB1_M)
        diagonal = L_DLine(TB1_F, TB1_M)
        sizes = Int[]
        for (name, L) in (("L_Point", point), ("L_ALine", axis), ("L_DLine", diagonal))
            description = describe_cl(L)
            @test description isa CLDescription
            @test description_size(description) == length(canonical_bytes(description))
            @test canonical_bytes(describe_cl(L)) == canonical_bytes(description)
            @test (description.field_size, description.seed_dim, description.level) ==
                  (8, 5, level(L))
            push!(sizes, description_size(description))
        end
        @test sizes == [75, 132, 156]
        @test describe_cl(point).term[1] == :Step
        @test describe_cl(axis).term[6][1] == :ByAxis
        @test describe_cl(diagonal).term[6][4][1][6][1] == :Lnf
        @test describe_cl(pad_level(axis, 3)) isa CLDescription
        @test describe_cl(pad_level(axis, 3)).term[6][1] == :Padded
        @test describe_cl(pad_level(CLZero(TB1_F, 5), 2)) isa CLDescription
        # An opaque host closure stays usable in memory and is NotDescribable.
        closure = CLStep(TB1_F, 2, (1,), (2,), reshape([one(TB1_F)], 1, 1),
                         CLZero(TB1_F, 2, (2,))) do _
            CLZero(TB1_F, 2, (2,))
        end
        @test apply(closure, (TB1_F(3), TB1_F(4))) == (TB1_F(3), zero(TB1_F))
        @test describe_cl(closure) isa NotDescribable
        # The combinators still wrap host closures (TB5 residue, DESIGN 9.4).
        @test describe_cl(direct_sum(point, axis)) isa NotDescribable
        println("TB1 describe: description_size L_Point/L_ALine/L_DLine=", sizes,
                " closure=NotDescribable direct_sum=NotDescribable")
    end
end

if tb1_runs("memo")
    @testset "TB1 bounded continuation memo" begin
        padded = pad_level(L_Point(TB1_F, TB1_M), 2)
        y = (TB1_F(3), TB1_F(5), TB1_F(4), TB1_F(6), TB1_F(7))
        distinct = 0
        for prefix in tb1_seeds()
            Linear(padded, 2, prefix, y)
            distinct += 1
            distinct >= 10_000 && break
        end
        report = memo_report(padded)
        @test distinct == 10_000 > CL_MEMO_LIMIT
        @test report.max_entries <= CL_MEMO_LIMIT
        @test report.entries <= CL_MEMO_LIMIT * report.nodes
        println("TB1 memo: distinct Linear prefixes=", distinct, " limit=",
                CL_MEMO_LIMIT, " max_entries=", report.max_entries,
                " entries=", report.entries, " nodes=", report.nodes)
    end
end

if tb1_runs("chi") || tb1_runs("chi_boundary")
    @testset "TB1 eq:chi-func buckets and joint histogram (M-χ owner)" begin
        @test [chi(s, TB1_M) for s in TB1_ELEMS] == [1, 1, 1, 1, 2, 2, 2, 2]
        if TB1_TARGET != "chi_boundary"
            point = L_Point(TB1_F, TB1_M)
            axis = L_ALine(TB1_F, TB1_M)
            transcribed = tb1_transcribed_histograms()
            actual = histogram(distribution(axis, point),
                               enumerate_seeds(TB1_F, seed_dim(point)))
            @test actual == transcribed.axis
        end
    end
end

if tb1_runs("pi_separator")
    @testset "TB1 pi-prefix sampler separator" begin
        sampler = L_DLine(TB1_F, TB1_M)
        raw = apply(sampler, (TB1_F(3), TB1_F(5), TB1_F(4),
                              TB1_F(6), TB1_F(7)))
        @test raw[4:5] == (zero(TB1_F), TB1_F(7))
    end
end

if tb1_runs("lnf_separator")
    @testset "TB1 canonical-complement sampler separator" begin
        u = (TB1_F(3), TB1_F(5))
        v = (TB1_F(6), TB1_F(7))
        raw = apply(L_DLine(TB1_F, TB1_M), (u..., TB1_F(0), v...))
        @test raw[1:2] == tb1_ref_lnf(v, u)
    end
end

if tb1_runs("chifree")
    @testset "TB1 genuinely chi-free lem:alnf/lem:dlnf marginals" begin
        marginal = tb1_chifree_marginals()
        @test length(marginal.axis) == 128
        @test Set(values(marginal.axis)) == Set((256,))
        @test length(marginal.diagonal) == 4096
        @test Set(values(marginal.diagonal)) == Set((4, 36))
        # Any bucket permutation with four labels per axis has these marginals;
        # M-χ is therefore owned by eq:chi-func and the joint histogram above.
        println("TB1 chi-free marginals: axis support=128 mass={256}; ",
                "diagonal support=4096 mass={4,36}; M-χ undetectable here")
    end
end

if tb1_runs("histogram_axis") || tb1_runs("histogram_diagonal")
    point = L_Point(TB1_F, TB1_M)
    axis = L_ALine(TB1_F, TB1_M)
    diagonal = L_DLine(TB1_F, TB1_M)
    reference = tb1_transcribed_histograms()

    if tb1_runs("histogram_axis")
        @testset "TB1 exact axis histogram (M-χ owner)" begin
            actual_axis = histogram(distribution(axis, point),
                                    enumerate_seeds(TB1_F, seed_dim(point)))
            @test actual_axis == reference.axis
            @test sum(values(actual_axis)) == 8^5
            @test length(actual_axis) == 512
            println("TB1 axis histogram: seeds=32768 support=", length(actual_axis),
                    " total=", sum(values(actual_axis)))
        end
    end

    if tb1_runs("histogram_diagonal")
        @testset "TB1 exact diagonal histogram (M-π, M-lnf owner)" begin
            actual_diagonal = histogram(distribution(diagonal, point),
                enumerate_seeds(TB1_F, seed_dim(point)))
            @test actual_diagonal == reference.diagonal
            @test sum(values(actual_diagonal)) == 8^5
            @test length(actual_diagonal) == 18_432
            zero_direction = filter(reference.diagonal) do entry
                raw = first(entry)[1]
                iszero(raw[4]) && iszero(raw[5])
            end
            @test !isempty(zero_direction)
            evidence = diagonal_histogram_evidence(
                actual_diagonal, reference.diagonal, TB1_M)
            repair = only(child for child in evidence.certificate.children
                          if child.rule == :ld_lnf_zero_direction)
            @test evidence.certificate.grade == CHECKED
            @test repair.grade == SOURCE_REPAIR
            @test repair.facts == (support=512, mass=2304, of=32768)
            @test passed(verify_certificate(evidence))
            println("TB1 diagonal histogram: seeds=32768 support=",
                    length(actual_diagonal), " total=", sum(values(actual_diagonal)),
                    " zero_direction_support=", length(zero_direction))
        end
    end
end

if tb1_runs("marginals")
    @testset "TB1 exhaustive marginal replay" begin
        samplers = (L_Point(TB1_F, TB1_M), L_ALine(TB1_F, TB1_M),
                    L_DLine(TB1_F, TB1_M))
        replayed = 0
        values_ok = true
        lengths_ok = true
        for seed in tb1_seeds(), sampler in samplers
            marginal = marginal_k(sampler, seed, level(sampler))
            applied = apply(sampler, seed)
            values_ok &= marginal.value == applied
            values_ok &= marginal.value == sum_stage_outputs(marginal)
            lengths_ok &= length(marginal.outputs) == level(sampler)
            replayed += 1
        end
        @test values_ok
        @test lengths_ok
        @test replayed == 3 * 8^5
        println("TB1 marginal replay: seeds=32768 samplers=3 replays=", replayed)
    end
end

function tb1_polynomial()
    layout = VarLayout((:x1, :x2), (VarBlock(:X, 1:2),))
    x1 = polyvar(TB1_F, layout, 1)
    x2 = polyvar(TB1_F, layout, 2)
    onep = constant_poly(TB1_F, layout, 1)
    onep + x1 + x1 * x2
end

function tb1_lines(point, axis, diagonal)
    axis_lines = Set{Any}()
    diagonal_lines = Set{Any}()
    zero_f = zero(TB1_F)
    for s in (TB1_F(0), TB1_F(4)), a in TB1_ELEMS, b in TB1_ELEMS
        seed = (a, b, s, zero_f, zero_f)
        push!(axis_lines, axis_line(apply(axis, seed), TB1_M))
    end
    # At i=1 the diagonal sampler ranges over every direction, so these 8^4
    # seeds cover every distinct canonical (base,direction) restriction; i=2
    # contributes only directions already present in that set.
    for a in TB1_ELEMS, b in TB1_ELEMS, c in TB1_ELEMS, d in TB1_ELEMS
        seed = (a, b, zero_f, c, d)
        push!(diagonal_lines, diagonal_line(apply(diagonal, seed), TB1_M))
    end
    (; axis_lines, diagonal_lines)
end

if tb1_runs("restrictions")
    @testset "TB1 all honest line restrictions" begin
        point = L_Point(TB1_F, TB1_M)
        axis = L_ALine(TB1_F, TB1_M)
        diagonal = L_DLine(TB1_F, TB1_M)
        g = tb1_polynomial()
        lines = tb1_lines(point, axis, diagonal)
        @test length(lines.axis_lines) == 16
        @test !isempty(lines.diagonal_lines)
        axis_degree_ok = true
        diagonal_degree_ok = true
        evaluations_ok = true
        for line in lines.axis_lines
            f = restrict(g, line)
            axis_degree_ok &= univariate_degree(f) <= TB1_D
            for t in TB1_ELEMS
                evaluations_ok &= evaluate(f, [t]) ==
                                  evaluate(g, collect(line_point(line, t)))
            end
        end
        for line in lines.diagonal_lines
            f = restrict(g, line)
            diagonal_degree_ok &= univariate_degree(f) <= TB1_M * TB1_D
            for t in TB1_ELEMS
                evaluations_ok &= evaluate(f, [t]) ==
                                  evaluate(g, collect(line_point(line, t)))
            end
        end
        @test axis_degree_ok
        @test diagonal_degree_ok
        @test evaluations_ok
        println("TB1 restrictions: axis_lines=", length(lines.axis_lines),
                " diagonal_representatives=", length(lines.diagonal_lines),
                " degree_bounds=1/2")
    end
end

function tb1_honest_answer(g, kind::Symbol, raw, m::Int)
    if kind == :Point
        u = point_value(raw, m)
        return (evaluate(g, collect(u)),)
    elseif kind == :ALine
        return (restrict(g, axis_line(raw, m)),)
    elseif kind == :DLine
        return (restrict(g, diagonal_line(raw, m)),)
    end
    error("unknown TB1 type")
end

function tb1_decider_sweep()
    params = LDParams(TB1_F, TB1_M, TB1_D, 1)
    samplers = Dict(:Point => L_Point(TB1_F, TB1_M),
                    :ALine => L_ALine(TB1_F, TB1_M),
                    :DLine => L_DLine(TB1_F, TB1_M))
    kinds = (:Point, :ALine, :DLine)
    g = tb1_polynomial()
    cache = Dict{Tuple{Symbol,Any},Any}()
    supports = Dict((left, right) => Set{Any}()
                    for left in kinds for right in kinds)
    for seed in tb1_seeds()
        questions = (Point=apply(samplers[:Point], seed),
                     ALine=apply(samplers[:ALine], seed),
                     DLine=apply(samplers[:DLine], seed))
        for left_kind in kinds, right_kind in kinds
            push!(supports[(left_kind, right_kind)],
                  (getproperty(questions, left_kind),
                   getproperty(questions, right_kind)))
        end
    end
    checked = 0
    non_noop = 0
    equal_type = 0
    line_vs_point = 0
    off_line_hits = 0
    accepted = true
    for left_kind in kinds, right_kind in kinds
        for (left_q, right_q) in supports[(left_kind, right_kind)]
            left_a = get!(cache, (left_kind, left_q)) do
                tb1_honest_answer(g, left_kind, left_q, TB1_M)
            end
            right_a = get!(cache, (right_kind, right_q)) do
                tb1_honest_answer(g, right_kind, right_q, TB1_M)
            end
            result = ld_decider(params, left_kind, left_q, right_kind,
                                right_q, left_a, right_a)
            accepted &= passed(result)
            non_noop += result.rule != :ld_noop
            equal_type += result.rule == :ld_consistency
            if result.rule in (:ld_axis_point, :ld_diagonal_point)
                line_vs_point += 1
                off_line_hits += result.location == :question
            end
            checked += 1
        end
    end
    raw = apply(samplers[:Point], (TB1_F(3), TB1_F(5), TB1_F(0),
                                   TB1_F(0), TB1_F(0)))
    mismatch = ld_decider(params, :Point, raw, :Point, raw,
                          (TB1_F(1),), (TB1_F(0),))
    (; accepted, checked, non_noop, equal_type, line_vs_point, off_line_hits,
       support_count=sum(length, values(supports)),
       nonempty=all(support -> !isempty(support), values(supports)), mismatch)
end

if tb1_runs("decider")
    @testset "TB1 D^ld honest deterministic sweep and consistency" begin
        report = tb1_decider_sweep()
        @test report.accepted
        @test report.checked == report.support_count
        @test report.non_noop == 40_768
        # verdicts/tb1-r2.md N11: the equal-type decisions are tautologies
        # (identical questions), the rest are line-versus-point.
        @test (report.equal_type, report.line_vs_point) == (2_880, 37_888)
        @test report.equal_type + report.line_vs_point == report.non_noop
        @test report.nonempty
        @test !passed(report.mismatch)
        @test report.mismatch.rule == :ld_consistency
        # verdicts/tb1-r2.md N4: the off-line rejection is a SOURCE_REPAIR of
        # fig:ld-decider items 2/3 (gt-07-ldt.tex:377-384), never reached by
        # honest play.
        @test report.off_line_hits == 0
        repair = ld_off_line_repair(honest_support_hits=report.off_line_hits,
                                    of=report.checked)
        @test repair.grade == SOURCE_REPAIR
        @test repair.rule == :ld_off_line_rejects
        @test repair.facts.honest_support_hits == 0 && repair.facts.of == 71_360
        println("TB1 D^ld: type_pairs=9 seeds=32768 support_decisions=",
                report.checked, " non_noop=", report.non_noop,
                " (equal-type tautologies=", report.equal_type,
                " line_vs_point=", report.line_vs_point,
                ") off_line_hits=", report.off_line_hits,
                " equal-type mismatch_rule=", report.mismatch.rule)
    end
end

if tb1_runs("decider_rejections")
    @testset "TB1 D^ld rejections" begin
        params = LDParams(GF8, 2, 1, 1)
        lay = VarLayout((:x1, :x2), (VarBlock(:X, 1:2),))
        g = constant_poly(GF8, lay, 1) + polyvar(GF8, lay, 1) +
            polyvar(GF8, lay, 1) * polyvar(GF8, lay, 2)
        lay1 = VarLayout((:t,), (VarBlock(:LineParameter, 1:1),))
        raw_axis = (GF8(0), GF8(5), GF8(0), GF8(0), GF8(0))
        raw_point = (GF8(3), GF8(5), GF8(0), GF8(0), GF8(0))
        cheat = restrict(g, axis_line(raw_axis, 2)) +
            constant_poly(GF8, lay1, GF8(1))
        pa = (evaluate(g, GF8[3, 5]),)
        @test univariate_degree(cheat) == 1
        axis_lr = ld_decider(params, :ALine, raw_axis, :Point, raw_point,
                             (cheat,), pa)
        axis_rl = ld_decider(params, :Point, raw_point, :ALine, raw_axis,
                             pa, (cheat,))
        @test axis_lr.rule == :ld_axis_point && !passed(axis_lr)
        @test axis_rl.rule == :ld_axis_point && !passed(axis_rl)

        raw_d = (GF8(3), GF8(0), GF8(0), GF8(2), GF8(7))
        dl = diagonal_line(raw_d, 2)
        p = line_point(dl, GF8(4))
        raw_dp = (p..., GF8(0), GF8(0), GF8(0))
        cd = restrict(g, dl) + constant_poly(GF8, lay1, GF8(1))
        pd = (evaluate(g, collect(p)),)
        diagonal_lr = ld_decider(params, :DLine, raw_d, :Point, raw_dp,
                                 (cd,), pd)
        diagonal_rl = ld_decider(params, :Point, raw_dp, :DLine, raw_d,
                                 pd, (cd,))
        @test diagonal_lr.rule == :ld_diagonal_point && !passed(diagonal_lr)
        @test diagonal_rl.rule == :ld_diagonal_point && !passed(diagonal_rl)

        # Unprojected DLine directions are legal question data; item 3 applies
        # pi_{chi(s)-1} in the verifier, not only in the honest sampler.
        raw_unprojected = (GF8(3), GF8(0), GF8(4), GF8(5), GF8(7))
        projected_line = AffineLine((raw_unprojected[1], raw_unprojected[2]),
                                    (zero(GF8), raw_unprojected[5]))
        projected_point = line_point(projected_line, GF8(6))
        projected_raw_point = (projected_point..., GF8(0), GF8(0), GF8(0))
        @test passed(ld_decider(params, :DLine, raw_unprojected, :Point,
            projected_raw_point, (restrict(g, projected_line),),
            (evaluate(g, collect(projected_point)),)))

        # verdicts/tb1-r2.md N1: fig:ld-decider's diagonal answer bound md
        # (gt-07-ldt.tex:359-360). x1^2*x2 restricted to a line with both
        # direction entries nonzero has degree 3 > md = 2.
        over_md = restrict(polyvar(GF8, lay, 1)^2 * polyvar(GF8, lay, 2), dl)
        @test univariate_degree(over_md) == 3
        diagonal_degree = ld_decider(params, :DLine, raw_d, :Point, raw_dp,
                                     (over_md,), pd)
        @test diagonal_degree.rule == :ld_diagonal_degree
        @test diagonal_degree.location == (:left, 1)
        @test !passed(diagonal_degree)
        println("MUTATION_EXPECTED_RULE ld_diagonal_degree actual=",
                diagonal_degree.rule, " passed=", passed(diagonal_degree))

        off_line_point = (GF8(3), GF8(6), GF8(0), GF8(0), GF8(0))
        honest_axis = restrict(g, axis_line(raw_axis, 2))
        matching_at_pivot = (evaluate(honest_axis, GF8[3]),)
        off_line = ld_decider(params, :ALine, raw_axis, :Point,
                              off_line_point, (honest_axis,), matching_at_pivot)
        @test off_line.rule == :ld_axis_point && !passed(off_line)

        malformed = ld_decider(params, :Point, (GF8(1), GF8(2)),
            :Point, (GF8(1), GF8(2)), (GF8(0),), (GF8(0),))
        @test malformed.rule == :ld_question_format && !passed(malformed)

        # kappa = 2: the `for all j in 1..kappa` loops of fig:ld-decider and the
        # answer arity are exercised beyond the single-polynomial case.
        params2 = LDParams(GF8, 2, 1, 2)
        h = polyvar(GF8, lay, 2)
        honest2 = (honest_axis, restrict(h, axis_line(raw_axis, 2)))
        point2 = (evaluate(g, GF8[3, 5]), evaluate(h, GF8[3, 5]))
        accepted2 = ld_decider(params2, :ALine, raw_axis, :Point, raw_point,
                               honest2, point2)
        @test accepted2.rule == :ld_axis_point && passed(accepted2)
        cheat2 = ld_decider(params2, :ALine, raw_axis, :Point, raw_point,
                            (honest_axis, cheat), point2)
        @test cheat2.rule == :ld_axis_point && !passed(cheat2) &&
              cheat2.location == 2
        short2 = ld_decider(params2, :ALine, raw_axis, :Point, raw_point,
                            honest2, pa)
        @test short2.rule == :ld_answer_arity && !passed(short2)
        println("TB1 rejection owners: axis/diagonal cheating both orders; ",
                "projected DLine; off-line guard; arity guard; kappa=2 ",
                "accept/second-entry cheat/short answer")
    end
end

if tb1_runs("degree")
    @testset "TB1 axis degree rejection (M-deg owner)" begin
        layout = VarLayout((:x1, :x2), (VarBlock(:X, 1:2),))
        x1 = polyvar(TB1_F, layout, 1)
        bad = x1^2
        params = LDParams(TB1_F, TB1_M, TB1_D, 1)
        named_point = (TB1_F(3), TB1_F(5))
        raw_point = (named_point..., zero(TB1_F), zero(TB1_F), zero(TB1_F))
        raw_axis = (zero(TB1_F), named_point[2], zero(TB1_F),
                    zero(TB1_F), zero(TB1_F))
        line_answer = (restrict(bad, axis_line(raw_axis, TB1_M)),)
        point_answer = (evaluate(bad, collect(named_point)),)
        result = ld_decider(params, :ALine, raw_axis, :Point, raw_point,
                            line_answer, point_answer)
        @test !passed(result)
        @test result.rule == :ld_axis_degree
        @test result.location == (:left, 1)
        fake_linear = (zero_poly(TB1_F,
            VarLayout((:t,), (VarBlock(:LineParameter, 1:1),))),)
        point_separator = ld_decider(params, :ALine, raw_axis, :Point,
                                     raw_point, fake_linear, point_answer)
        @test !passed(point_separator)
        @test point_separator.rule == :ld_axis_point
        println("TB1 degree separator: point=", named_point,
                " claimed_d=1 actual_degree=", univariate_degree(line_answer[1]),
                " format_rule=", result.rule,
                " point_rule=", point_separator.rule)
    end
end

if tb1_runs("trace")
    @testset "TB1 sampled question-pair trace" begin
        params = LDParams(TB1_F, TB1_M, TB1_D, 1)
        point = L_Point(TB1_F, TB1_M)
        axis = L_ALine(TB1_F, TB1_M)
        diagonal = L_DLine(TB1_F, TB1_M)
        g = tb1_polynomial()
        seed = (TB1_F(3), TB1_F(5), TB1_F(4), TB1_F(6), TB1_F(7))
        q_point = apply(point, seed)
        q_axis = apply(axis, seed)
        q_diagonal = apply(diagonal, seed)
        pairs = ((:Point, q_point, :Point, q_point),
                 (:ALine, q_axis, :Point, q_point),
                 (:DLine, q_diagonal, :Point, q_point))
        println("TB1 TRACE seed=", seed)
        for (lt, lq, rt, rq) in pairs
            la = tb1_honest_answer(g, lt, lq, TB1_M)
            ra = tb1_honest_answer(g, rt, rq, TB1_M)
            result = ld_decider(params, lt, lq, rt, rq, la, ra)
            @test passed(result)
            println("  ", lt, " × ", rt, " q=", (lq, rq),
                    " answer_degrees=", map(univariate_degree,
                        filter(x -> x isa Poly, (la..., ra...))),
                    " => ", result.rule, " PASS")
        end
    end
end
