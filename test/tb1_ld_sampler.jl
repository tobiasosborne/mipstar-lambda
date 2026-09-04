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

function tb1_reference_histograms()
    axis = Dict{Any,Int}()
    diagonal = Dict{Any,Int}()
    bucket_width = field_size(TB1_F) ÷ TB1_M
    for seed in tb1_seeds()
        u = (seed[1], seed[2])
        s = seed[3]
        v = (seed[4], seed[5])
        # χ-free literal samplers for gt-07-ldt.tex lem:alnf/lem:dlnf:
        # draw i uniformly, then retain the independent within-bucket field label.
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

function tb1_actual_histogram(left, right)
    counts = Dict{Any,Int}()
    for seed in tb1_seeds()
        key = (apply(left, seed), apply(right, seed))
        counts[key] = get(counts, key, 0) + 1
    end
    counts
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
    end
end

if tb1_runs("histogram_axis") || tb1_runs("histogram_diagonal")
    point = L_Point(TB1_F, TB1_M)
    axis = L_ALine(TB1_F, TB1_M)
    diagonal = L_DLine(TB1_F, TB1_M)
    reference = tb1_reference_histograms()

    if tb1_runs("histogram_axis")
        @testset "TB1 exact axis histogram (M-χ owner)" begin
            actual_axis = histogram(distribution(axis, point), TB1_ELEMS)
            @test actual_axis == reference.axis
            @test sum(values(actual_axis)) == 8^5
            @test length(actual_axis) == 512
            println("TB1 axis histogram: seeds=32768 support=", length(actual_axis),
                    " total=", sum(values(actual_axis)))
        end
    end

    if tb1_runs("histogram_diagonal")
        @testset "TB1 exact diagonal histogram (M-π, M-lnf owner)" begin
            actual_diagonal = histogram(distribution(diagonal, point), TB1_ELEMS)
            @test actual_diagonal == reference.diagonal
            @test sum(values(actual_diagonal)) == 8^5
            @test length(actual_diagonal) == 18_432
            zero_direction = filter(reference.diagonal) do entry
                raw = first(entry)[1]
                iszero(raw[4]) && iszero(raw[5])
            end
            @test !isempty(zero_direction)
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
            checked += 1
        end
    end
    raw = apply(samplers[:Point], (TB1_F(3), TB1_F(5), TB1_F(0),
                                   TB1_F(0), TB1_F(0)))
    mismatch = ld_decider(params, :Point, raw, :Point, raw,
                          (TB1_F(1),), (TB1_F(0),))
    (; accepted, checked, support_count=sum(length, values(supports)),
       nonempty=all(support -> !isempty(support), values(supports)), mismatch)
end

if tb1_runs("decider")
    @testset "TB1 D^ld honest deterministic sweep and consistency" begin
        report = tb1_decider_sweep()
        @test report.accepted
        @test report.checked == report.support_count
        @test report.nonempty
        @test !passed(report.mismatch)
        @test report.mismatch.rule == :ld_consistency
        println("TB1 D^ld: type_pairs=9 seeds=32768 support_decisions=",
                report.checked, " equal-type mismatch_rule=", report.mismatch.rule)
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
        println("TB1 degree separator: point=", named_point,
                " claimed_d=1 actual_degree=", univariate_degree(line_answer[1]),
                " rule=", result.rule)
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
