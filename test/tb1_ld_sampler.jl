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
        # A genuine level-1 map on register {2} (a zero map promoted in-chain
        # on its rest register, verdicts/tb1-r4.md N25): only the
        # continuation-level guard can reject it.
        wrong_level = CLStep(TB1_F, 2, (1,), (2,), one1, CLZero(TB1_F, 2, (2,))) do _
            MIPStarLambda._pad_tail(CLZero(TB1_F, 2, (2,)), 1)
        end
        @test level(MIPStarLambda._pad_tail(CLZero(TB1_F, 2, (2,)), 1)) == 1
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
        # verdicts/tb1-r3.md N21: the field guard itself rejects (its message
        # names the field), not the typed memo behind it.
        field_error = try
            apply(wrong_field, (TB1_F(1), TB1_F(2)))
        catch error
            error
        end
        @test field_error isa ArgumentError && occursin("same field", field_error.msg)
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
        # verdicts/tb2-r3.md N7: the promotion is carried by a certificate the
        # suite verifies; a padded genuine child carries no repair node.
        zero5 = ntuple(_ -> zero(TB1_F), 5)
        pad_seeds = (seed, zero5, (TB1_F(1), TB1_F(0), TB1_F(7), TB1_F(2), TB1_F(0)))
        zero_evidence = pad_level_evidence(CLZero(TB1_F, 5), 3, pad_seeds;
                                           chain_set_id="tb1-pad-zero")
        @test zero_evidence.certificate.grade == CHECKED
        @test any(child -> child === ZERO_MAP_FACTOR_PARTITION,
                  zero_evidence.certificate.children)
        @test passed(verify_certificate(zero_evidence))
        axis_evidence = pad_level_evidence(axis, 3, pad_seeds;
                                           chain_set_id="tb1-pad-axis")
        @test isempty(axis_evidence.certificate.children)
        @test passed(verify_certificate(axis_evidence))
        # verdicts/tb1-r3.md N16: a top-level zero map on the EMPTY register is
        # the zero map on F^5 and is promoted with V_1 = {1..5} (DESIGN 9.4);
        # inside a chain the empty-register terminal stays empty (the padded
        # L_ALine's third factor).
        empty_padded = pad_level(CLZero(TB1_F, 5, Int[]), 3)
        @test marginal_k(empty_padded, seed, 3).factor_spaces ==
              [collect(1:5), Int[], Int[]]
        @test cl_kth_replay(empty_padded, pad_seeds; chain_set_id="tb1-pad-empty").space_sum_ok
        @test passed(verify_certificate(pad_level_evidence(
            CLZero(TB1_F, 5, Int[]), 3, pad_seeds; chain_set_id="tb1-pad-empty")))
        @test marginal_k(padded_axis, seed, 3).factor_spaces[3] == Int[]
        # verdicts/tb1-r4.md N25: a top-level zero map declared on a proper
        # sub-register is malformed (DESIGN 9.4's originators are all
        # whole-space) and its promotion is refused rather than producing a
        # value that fails enu:cl-space-sum; padding to its own level 0 is
        # the identity, and the same value is still promotable in-chain on
        # its rest register.
        @test_throws ArgumentError pad_level(CLZero(TB1_F, 5, (2,)), 2)
        @test_throws ArgumentError pad_level_evidence(CLZero(TB1_F, 5, (2,)), 2, pad_seeds;
                                                      chain_set_id="tb1-pad-sub")
        @test register_indices(pad_level(CLZero(TB1_F, 5, (2,)), 0)) == (2,)
        @test marginal_k(MIPStarLambda._pad_tail(CLZero(TB1_F, 5, (2,)), 2), seed, 2).factor_spaces ==
              [[2], Int[]]
        println("MUTATION_EXPECTED_RULE pad_subregister refused=",
                try pad_level(CLZero(TB1_F, 5, (2,)), 2); false catch e; e isa ArgumentError end)
        # verdicts/tb1-r5.md N30: the two spellings of a whole-space zero map
        # stay interchangeable under direct_sum: full (+) empty is the zero map
        # on F^5 spelled with its full register, empty (+) empty keeps the
        # empty spelling, and both promote; a proper sub-register summand is
        # transported verbatim and still refused.
        mixed = direct_sum(CLZero(TB1_F, 3), CLZero(TB1_F, 2, Int[]))
        @test register_indices(mixed) == (1, 2, 3, 4, 5)
        @test marginal_k(pad_level(mixed, 1), seed, 1).factor_spaces == [collect(1:5)]
        @test register_indices(direct_sum(CLZero(TB1_F, 3, Int[]), CLZero(TB1_F, 2, Int[]))) == ()
        @test marginal_k(pad_level(direct_sum(CLZero(TB1_F, 3, Int[]), CLZero(TB1_F, 2, Int[])), 1),
                         seed, 1).factor_spaces == [collect(1:5)]
        @test register_indices(direct_sum(CLZero(TB1_F, 3, (2,)), CLZero(TB1_F, 2))) == (2, 4, 5)
        @test_throws ArgumentError pad_level(direct_sum(CLZero(TB1_F, 3, (2,)), CLZero(TB1_F, 2)), 1)
        println("MUTATION_EXPECTED_RULE dsum_zero_spellings promoted=",
                try marginal_k(pad_level(mixed, 1), seed, 1).factor_spaces == [collect(1:5)]
                catch e; e isa ArgumentError ? false : rethrow() end)
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
        for L in (point, axis, diagonal), j in 1:level(L)
            @test Marginal(L, j, z) == marginal_k(L, z, j).value
        end
        @test Marginal(diagonal, 3, z) == apply(diagonal, z)
        # verdicts/tb1-r3.md N14: def:sampler admits 1 <= j <= ell for every
        # query; the zero marginal of DESIGN 9.2 is the caller's zero vector.
        for L in (point, axis, diagonal)
            @test_throws ArgumentError Marginal(L, 0, z)
            @test_throws ArgumentError Marginal(L, level(L) + 1, z)
        end
        @test marginal_k(axis, z, 0).value == zero5
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

        # verdicts/tb1-r3.md N12: the bytes are tied to the map. (b) decode
        # round trip on the exhaustive chain set, (c) injectivity on the named
        # separator pair, (e) the exact byte window of the stage-1 matrix.
        z = (TB1_F(3), TB1_F(5), TB1_F(4), TB1_F(6), TB1_F(7))
        roundtrip_ok = true
        for L in (point, axis, diagonal, pad_level(axis, 3), pad_level(CLZero(TB1_F, 5), 2))
            bytes = canonical_bytes(describe_cl(L))
            decoded = decode_cl(bytes)
            roundtrip_ok &= canonical_bytes(describe_cl(decoded)) == bytes
            roundtrip_ok &= (level(decoded), seed_dim(decoded)) == (level(L), seed_dim(L))
            roundtrip_ok &= marginal_k(decoded, z, level(L)).factor_spaces ==
                            marginal_k(L, z, level(L)).factor_spaces
            for seed in tb1_seeds()
                roundtrip_ok &= apply(decoded, seed) == apply(L, seed)
            end
        end
        projector_coord_dir = zeros(TB1_F, 5, 5)
        for i in 3:5
            projector_coord_dir[i, i] = one(TB1_F)
        end
        alt = CLStep(TB1_F, 5, collect(1:5), Int[], projector_coord_dir,
                     CLZero(TB1_F, 5, Int[]))
        point_bytes = canonical_bytes(describe_cl(point))
        alt_bytes = canonical_bytes(describe_cl(alt))
        separated = point_bytes != alt_bytes
        println("MUTATION_EXPECTED_RULE describe_roundtrip ok=", roundtrip_ok,
                " separator_bytes_differ=", separated)
        @test roundtrip_ok
        @test apply(alt, z) == (zero(TB1_F), zero(TB1_F), TB1_F(4), TB1_F(6), TB1_F(7))
        @test apply(alt, z) != apply(point, z)
        @test description_size(describe_cl(alt)) == 75
        @test separated
        @test length(Set(canonical_bytes(describe_cl(L)) for L in (point, axis, diagonal))) == 3
        # Header 13 bytes, then Step: tag 1, seed_dim 4, factor 4+2*5, rest 4,
        # entry count 4 => the 25 GF(8) entries (1 byte each, row-major) sit at
        # bytes 41:65; L_Point selects (1,1),(2,2), alt selects (3,3),(4,4),(5,5).
        window(selected) = UInt8[(r == c && r in selected) ? 0x01 : 0x00
                                 for r in 1:5 for c in 1:5]
        @test point_bytes[41:65] == window(1:2)
        @test alt_bytes[41:65] == window(3:5)
        @test point_bytes[1:40] == alt_bytes[1:40] && point_bytes[66:75] == alt_bytes[66:75]
        @test_throws ArgumentError decode_cl(point_bytes[1:74])
        @test_throws ArgumentError decode_cl(vcat(point_bytes, 0x00))
        # verdicts/tb1-r4.md N24: every stage matrix above is diagonal, so the
        # matrix index order is pinned on a one-stage map with the
        # nonsymmetric [1 1; 0 1] on {1,2}: header 13, Step tag 1, seed_dim 4,
        # factor 4+2*2, rest 4, count 4 => the four GF(8) entries sit at
        # bytes 35:38 in row-major order (1,1),(1,2),(2,1),(2,2).
        shear = [one(TB1_F) one(TB1_F); zero(TB1_F) one(TB1_F)]
        shear_map = CLStep(TB1_F, 2, [1, 2], Int[], shear, CLZero(TB1_F, 2, Int[]))
        shear_map_t = CLStep(TB1_F, 2, [1, 2], Int[], permutedims(shear),
                             CLZero(TB1_F, 2, Int[]))
        shear_bytes = canonical_bytes(describe_cl(shear_map))
        shear_bytes_t = canonical_bytes(describe_cl(shear_map_t))
        row_major = shear_bytes[35:38] == UInt8[1, 1, 0, 1] &&
                    shear_bytes_t[35:38] == UInt8[1, 0, 1, 1]
        println("MUTATION_EXPECTED_RULE describe_transpose row_major=", row_major)
        @test length(shear_bytes) == 38 + 1 + 9
        @test row_major
        @test shear_bytes != shear_bytes_t
        @test shear_bytes[1:34] == shear_bytes_t[1:34] && shear_bytes[39:end] == shear_bytes_t[39:end]
        @test apply(shear_map, (TB1_F(3), TB1_F(5))) == (TB1_F(3) + TB1_F(5), TB1_F(5))
        @test apply(decode_cl(shear_bytes), (TB1_F(3), TB1_F(5))) == apply(shear_map, (TB1_F(3), TB1_F(5)))
        @test apply(decode_cl(shear_bytes_t), (TB1_F(3), TB1_F(5))) == apply(shear_map_t, (TB1_F(3), TB1_F(5)))
        @test apply(shear_map, (TB1_F(3), TB1_F(5))) != apply(shear_map_t, (TB1_F(3), TB1_F(5)))
        # verdicts/tb1-r4.md N26: a CLZero's register is in the bytes and is
        # recovered, so decode_cl is a left inverse on zero components too.
        sub_zero = CLZero(TB1_F, 5, (2,))
        zero_register_ok =
            register_indices(decode_cl(canonical_bytes(describe_cl(sub_zero)))) == (2,) &&
            canonical_bytes(describe_cl(CLZero(TB1_F, 5))) !=
            canonical_bytes(describe_cl(CLZero(TB1_F, 5, Int[])))
        println("MUTATION_EXPECTED_RULE describe_zero_register ok=", zero_register_ok)
        @test zero_register_ok
        @test register_indices(decode_cl(canonical_bytes(describe_cl(sub_zero)))) == (2,)
        @test register_indices(decode_cl(canonical_bytes(describe_cl(CLZero(TB1_F, 5))))) == (1, 2, 3, 4, 5)
        @test register_indices(decode_cl(canonical_bytes(describe_cl(CLZero(TB1_F, 5, Int[]))))) == ()
        @test length(Set(canonical_bytes(describe_cl(L)) for L in
                         (sub_zero, CLZero(TB1_F, 5), CLZero(TB1_F, 5, Int[])))) == 3
        # verdicts/tb1-r5.md N31: registers are serialized in their DECLARED
        # order, so canonical bytes are canonical in the bytes-to-map
        # direction only (C4a scope): the same map, spelled [2,1] and [1,2].
        @test register_indices(CLZero(TB1_F, 5, [2, 1])) == register_indices(CLZero(TB1_F, 5, [1, 2])) == (1, 2) &&
              canonical_bytes(describe_cl(CLZero(TB1_F, 5, [2, 1]))) != canonical_bytes(describe_cl(CLZero(TB1_F, 5, [1, 2])))
        # verdicts/tb2-r4.md N26: decode_cl re-imposes the top stage's
        # ambient partition factor (+) rest = {1..n}; a description whose top
        # stage spans only {1,2} of F^5 (buildable only through the internal
        # constructor) is refused.
        nonspanning = MIPStarLambda._clstep(TB1_F, 5, [1, 2], Int[], zeros(TB1_F, 2, 2),
            CLZero(TB1_F, 5, Int[]), MIPStarLambda.BranchConst(CLZero(TB1_F, 5, Int[]));
            require_ambient=false)
        @test register_indices(nonspanning) == (1, 2)
        @test describe_cl(nonspanning) isa CLDescription
        @test_throws ArgumentError decode_cl(canonical_bytes(describe_cl(nonspanning)))
        println("MUTATION_EXPECTED_RULE decode_ambient refused=",
                try decode_cl(canonical_bytes(describe_cl(nonspanning))); false catch e; e isa ArgumentError end)
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
                " closure=NotDescribable direct_sum=NotDescribable",
                " decode round trip on 3x8^5 seeds + 2 padded maps; separator L_Point vs V_coord(+)V_dir projector (75 bytes both)")
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

tb1_honest_answer(g, kind::Symbol, raw, m::Int) = ld_honest_answer(g, kind, raw, m)

# The honest sweep is `ld_honest_sweep` (src/verifiers/ldt.jl), attached to a
# CHECKED certificate by `ld_sweep_evidence` (verdicts/tb1-r3.md N15).
function tb1_decider_sweep()
    params = LDParams(TB1_F, TB1_M, TB1_D, 1)
    samplers = Dict(:Point => L_Point(TB1_F, TB1_M),
                    :ALine => L_ALine(TB1_F, TB1_M),
                    :DLine => L_DLine(TB1_F, TB1_M))
    evidence = ld_sweep_evidence(params, tb1_polynomial(), samplers, tb1_seeds())
    raw = apply(samplers[:Point], (TB1_F(3), TB1_F(5), TB1_F(0),
                                   TB1_F(0), TB1_F(0)))
    mismatch = ld_decider(params, :Point, raw, :Point, raw,
                          (TB1_F(1),), (TB1_F(0),))
    (; evidence.term.report..., mismatch, evidence)
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
        # verdicts/tb1-r5.md N29: 1,024 of the 37,888 line-versus-point
        # decisions are against a zero-direction diagonal line (512 support
        # points, both orders); accepted with off_line_hits == 0 means the
        # point equals the base on every one, and item 3 was checked at all
        # eight t there.
        @test report.degenerate_hits == 1_024
        # verdicts/tb1-r3.md N15: the sweep is a CHECKED node whose replay
        # re-runs it; the off-line SOURCE_REPAIR hangs under it, the answer
        # bounds d/md and kappa are its facts.
        evidence = report.evidence
        @test evidence.certificate.grade == CHECKED
        @test evidence.certificate.rule == :ld_honest_sweep
        repair = only(child for child in evidence.certificate.children
                      if child.rule == :ld_off_line_rejects)
        @test repair.grade == SOURCE_REPAIR
        @test repair.facts.honest_support_hits == 0 && repair.facts.of == 71_360
        @test evidence.certificate.facts.d == 1 && evidence.certificate.facts.md == 2 &&
              evidence.certificate.facts.kappa == 1
        @test (evidence.certificate.facts.equal_type,
               evidence.certificate.facts.line_vs_point) == (2_880, 37_888)
        @test evidence.certificate.facts.degenerate_line_vs_point == 1_024
        @test passed(verify_certificate(evidence))
        # The replay is a recount, not a re-reading of the report: a tampered
        # report is rejected.
        tampered = Checked(merge(evidence.term,
                                 (report=merge(report.evidence.term.report,
                                               (off_line_hits=1,)),)),
                           evidence.certificate)
        @test !passed(verify_certificate(tampered))
        # verdicts/tb1-r4.md N23: the counter must be able to go positive.
        println("MUTATION_EXPECTED_RULE off_line reached=", report.off_line_hits > 0,
                " hits=", report.off_line_hits)
        println("TB1 D^ld: type_pairs=9 seeds=32768 support_decisions=",
                report.checked, " non_noop=", report.non_noop,
                " (equal-type tautologies=", report.equal_type,
                " line_vs_point=", report.line_vs_point,
                ") off_line_hits=", report.off_line_hits,
                " degenerate_line_vs_point=", report.degenerate_hits,
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
        # verdicts/tb1-r4.md N23: the off-line branch is the one that marks
        # the question, and `ld_honest_sweep` counts exactly that marker.
        @test off_line.location == :question
        @test off_line.expected == :point_on_line

        # verdicts/tb1-r5.md N29: a zero-direction diagonal line. Seed
        # (0,0,0,0,0) gives base (0,0), direction (0,0); with the point at
        # the base every t in F_8 satisfies item 3's constraint
        # (gt-07-ldt.tex:379-384). The honest restriction is the constant
        # g(0,0) = 1 and is accepted; the degree-1 cheat f(t) = 1 + t agrees
        # with the point answer at t = 0 only and is rejected at the first
        # other parameter (named negative transcript: degenerate_t0_cheat).
        # A point off a degenerate line is the off-line SOURCE_REPAIR
        # (location :question), never a t = 0 comparison.
        raw_degenerate = ntuple(_ -> GF8(0), 5)
        @test all(iszero, diagonal_line(raw_degenerate, 2).direction)
        raw_base_point = ntuple(_ -> GF8(0), 5)
        honest_degenerate = restrict(g, diagonal_line(raw_degenerate, 2))
        base_answer = (evaluate(g, GF8[0, 0]),)
        @test base_answer == (GF8(1),)
        @test passed(ld_decider(params, :DLine, raw_degenerate, :Point,
                                raw_base_point, (honest_degenerate,), base_answer))
        degenerate_t0_cheat = constant_poly(GF8, lay1, GF8(1)) + polyvar(GF8, lay1, 1)
        @test univariate_degree(degenerate_t0_cheat) == 1
        @test evaluate(degenerate_t0_cheat, GF8[0]) == GF8(1)
        t0_lr = ld_decider(params, :DLine, raw_degenerate, :Point, raw_base_point,
                           (degenerate_t0_cheat,), base_answer)
        t0_rl = ld_decider(params, :Point, raw_base_point, :DLine, raw_degenerate,
                           base_answer, (degenerate_t0_cheat,))
        @test t0_lr.rule == :ld_diagonal_point && !passed(t0_lr) && t0_lr.location == 1
        @test t0_rl.rule == :ld_diagonal_point && !passed(t0_rl) && t0_rl.location == 1
        raw_off_base = (GF8(1), GF8(0), GF8(0), GF8(0), GF8(0))
        off_base = ld_decider(params, :DLine, raw_degenerate, :Point, raw_off_base,
                              (honest_degenerate,), (evaluate(g, GF8[1, 0]),))
        @test off_base.rule == :ld_diagonal_point && !passed(off_base)
        @test off_base.location == :question && off_base.expected == :point_on_line
        println("MUTATION_EXPECTED_RULE degenerate_line off_base=", off_base.rule,
                "@", off_base.location, " t0_cheat_passed=", passed(t0_lr))

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
                "projected DLine; off-line guard; degenerate line (t0 cheat, ",
                "off-base point); arity guard; kappa=2 ",
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
