using Test
using Random
using MIPStarLambda
Base.Experimental.@optlevel 0

const TB0_TARGET = get(ENV, "TB0_TARGET", "all")
runs(name) = TB0_TARGET == "all" || TB0_TARGET == name

function exercise_field_axioms(::Type{F}, triples) where {F}
    all_ok = true
    for (a, b, c) in triples
        all_ok &= (a + b) + c == a + (b + c)
        all_ok &= (a * b) * c == a * (b * c)
        all_ok &= a + b == b + a
        all_ok &= a * b == b * a
        all_ok &= a * (b + c) == a * b + a * c
        all_ok &= (a + b) * c == a * c + b * c
        all_ok &= a + zero(F) == a
        all_ok &= a * one(F) == a
        all_ok &= a + (-a) == zero(F)
        iszero(a) || (all_ok &= a * inv(a) == one(F))
        all_ok &= field_from_bytes(F, field_bytes(a)) == a
    end
    @test all_ok
end

if runs("field")
    @testset "1. GF(2^k) field laws" begin
        @test modulus_polynomial(GF8) == 0x00b
        @test modulus_polynomial(GF2048) == 0x805
        @test is_irreducible_modulus(GF8)
        @test is_irreducible_modulus(GF2048)
        @test multiplicative_order(primitive_element(GF8)) == 7
        @test multiplicative_order(primitive_element(GF2048)) == 2047

        elems8 = field_elements(GF8)
        exercise_field_axioms(GF8,
            ((a, b, c) for a in elems8 for b in elems8 for c in elems8))

        rng = MersenneTwister(0x09_20_48)
        samples = ((GF2048(rand(rng, 0:2047)),
                    GF2048(rand(rng, 0:2047)),
                    GF2048(rand(rng, 0:2047))) for _ in 1:10_000)
        exercise_field_axioms(GF2048, samples)
        println("TB0 fields: GF(8) modulus=0x00b exhaustive triples=512; ",
                "GF(2^11) modulus=0x805 seed=0x092048 triples=10000")
    end
end

if runs("encoding")
    @testset "2. multilinear low-degree encoding" begin
        report = tb0_encoding_report()
        @test report.gf8 ==
              (m1_ok=true, m2_ok=true, m1_points=16, m2_points=64)
        @test report.gf2048 ==
              (m1_ok=true, m2_ok=true, m1_points=1024, m2_points=512)
        println("TB0 encoding: m=1 [0,1]/[1,0], m=2 [0,1,1,0]; GF(8) points=16+64; ",
                "GF(2^11) seeded points=1024+512")
    end
end

function simple_zero_basis_fixture()
    layout = VarLayout((:x, :y), (VarBlock(:Z, 1:2),))
    x = polyvar(GF8, layout, 1)
    y = polyvar(GF8, layout, 2)
    # gt-10-answer-reduction.tex:1281-1373 (prop:zero-basis).
    f = x^3 - x^2 + x * y^2 - x * y
    checked = zero_basis_decompose(f, (1, 2))
    return f, checked.term, checked.certificate
end

if runs("zero_basis")
    @testset "3. zero-basis rewrite certificate" begin
        f, decomposition, certificate = simple_zero_basis_fixture()
        @test !isempty(decomposition.steps)
        @test all(step -> passed(verify_rewrite_step(step)), decomposition.steps)
        result = verify_zero_decomposition(f, decomposition)
        @test passed(result)
        @test result.rule == :coefficient_identity
        @test isempty(decomposition.remainder.terms)
        rhs = decomposition.remainder
        for i in eachindex(decomposition.quotients)
            rhs = rhs + decomposition.quotients[i] * zero(decomposition.layout, i, GF8)
        end
        @test polynomial_equal(f, rhs)
        for p in Iterators.flatten(((f,), decomposition.quotients, (decomposition.remainder,)))
            @test degree_accounts_valid(p)
        end
        @test passed(verify_certificate(Checked(decomposition, certificate)))
        println("TB0 zero basis: rewrites=", length(decomposition.steps),
                "; remainder=0; coefficient identity=true")
    end
end

if runs("circuit")
    @testset "4. circuit, Tseitin, output literal, arithmetization" begin
        report = tb0_truth_report()
        @test report.circuit_ok
        @test (report.present, report.absent) == (128, 896)
        @test report.satisfying == 512
        @test report.chosen_satisfies
        @test report.formula_ok
        @test report.arith_ok
        println("TB0 Boolean scopes: clauses present/absent=128/896; witnesses=512; ",
                "(x,o,w) assignments=", report.assignments)
    end
end

const DEGENERATE_TABLES = ((0, 1), (0, 0), (0, 0), (0, 0), (0, 0))
const NONDEGENERATE_TABLES = ((0, 1), (0, 1), (0, 1), (0, 1), (0, 1))
const NONDEGENERATE_INTEGER_STATS = Ref{Any}(nothing)

const POLY_CACHE = Dict{Tuple{DataType,Int,Symbol},Any}()
const BUILD_STATS = Dict{Tuple{DataType,Int,Symbol},NamedTuple}()
function polynomial_fixture(::Type{F}, d; witness=:degenerate) where {F}
    key = (F, d, witness)
    haskey(POLY_CACHE, key) && return POLY_CACHE[key]
    measured = if witness == :nondegenerate && F == GF8
        @timed Base.invokelatest(tb0_build_nondegenerate_fixture, d,
                                 NONDEGENERATE_TABLES,
                                 MonomialBudget(2_500_000))
    else
        tables, budget = witness == :degenerate ?
            (DEGENERATE_TABLES, MonomialBudget(160_000)) :
            (NONDEGENERATE_TABLES, MonomialBudget(2_500_000))
        @timed Base.invokelatest(tb0_build_fixture, F, d, tables, budget)
    end
    value = measured.value
    if witness == :nondegenerate && F == GF8 && !(value isa ExpansionRefused)
        NONDEGENERATE_INTEGER_STATS[] = value.integer_report
        value = value.fixture
    end
    BUILD_STATS[key] = (seconds=measured.time, bytes=measured.bytes,
                        peak_rss=Sys.maxrss())
    POLY_CACHE[key] = value
    value
end

function base_point(::Type{F}) where {F}
    tb0_base_point(F)
end

check_pcp_point(tf, proof, z) = pcpverifier(tf, ev_z(proof, z))

function mutation_b_separator(tf, proof, ::Type{F}) where {F}
    rho = primitive_element(F)
    z = base_point(F)
    z[7] = rho
    view = ev_z(proof, z)
    honest = rho^5 * (one(F) + rho)
    mutated = rho^4 * (one(F) + rho)
    result = pcpverifier(tf, view)
    (; view, honest, mutated, result)
end

if TB0_TARGET == "pcp_separator"
    @testset "5b. mutation-B formula separator" begin
        source = polynomial_fixture(GF8, 6; witness=:nondegenerate)
        proof11 = lift_pcp(source.proof, GF2048, 11)
        separator8 = mutation_b_separator(source.tf, source.proof, GF8)
        separator11 = mutation_b_separator(source.tf, proof11, GF2048)
        @test separator8.view.beta0 == separator8.honest == GF8(2)
        @test separator8.mutated == GF8(1)
        @test separator11.view.beta0 == separator11.honest == GF2048(96)
        @test separator11.mutated == GF2048(48)
        @test passed(separator8.result)
        @test passed(separator11.result)
    end
end

if runs("pcp")
    @testset "5a. PCP policies and degenerate proof" begin
        fixture8 = polynomial_fixture(GF8, 6)
        @test !(fixture8 isa ExpansionRefused)
        report = Base.invokelatest(tb0_degenerate_core_report,
                                   fixture8.tf, fixture8.farith, fixture8.gs,
                                   fixture8.c0, fixture8.decomposition)
        @test report ==
            (small=(PASS, FAIL, FAIL, FAIL, FAIL, FAIL),
             sampled=(PASS, NOT_EVALUABLE, PASS, PASS, PASS, PASS),
             small_exponent=PASS, structural=(FAIL, PASS), sampled_zero=PASS,
             minimal_k=11, refused=true, expected=148_176, peak_ok=true,
             support_ok=true, remainder_zero=true, quotient_split=true,
             quotient_degree=6, base_value_ok=true)
    end

    @testset "5b. degenerate GF(8) coordinate lines" begin
        fixture8 = polynomial_fixture(GF8, 6)
        b8 = base_point(GF8)
        lines = pcp_coordinate_line_report(fixture8.tf, fixture8.proof, b8)
        cube = pcp_boolean_cube_report(fixture8.tf, fixture8.proof)
        @test lines == (formula_ok=true, zero_ok=true, count=128)
        @test cube == (formula_ok=true, zero_ok=true, count=65_536)
    end

    @testset "5d. degenerate reports and certificate" begin
        fixture8 = polynomial_fixture(GF8, 6)
        small_policy = parameter_policy(PCPParams(8, 3, 1, 6, 6, 16), 6)
        sampled_policy = parameter_policy(PCPParams(2048, 11, 1, 11, 6, 16), 6)
        stats8 = BUILD_STATS[(GF8, 6, :degenerate)]
        report = Base.invokelatest(tb0_print_degenerate_report,
                                   fixture8.farith, fixture8.gs, fixture8.c0,
                                   fixture8.decomposition, fixture8.proof,
                                   fixture8.certificate, small_policy,
                                   sampled_policy, stats8.seconds,
                                   stats8.peak_rss)
        @test report.local_dependencies
        @test report.g1_block == Set((:X1,))
        @test report.constant_tail
        @test report.degree_accounts
        @test report.quotient_degree_ok
        @test report.certificate_ok
    end
end

const TB0_ND_C0_DEGREES =
    (3, 1, 1, 1, 3, 3, 1, 1, 1, 1, 6, 4, 4, 4, 4, 3)

if runs("nondegenerate")
    @testset "6a. non-degenerate support and certificate" begin
        fixture8 = polynomial_fixture(GF8, 6; witness=:nondegenerate)
        integer_stats = NONDEGENERATE_INTEGER_STATS[]
        @test (integer_stats.support, integer_stats.expected,
               integer_stats.multiplication_peak) ==
              (788_032, 2_370_816, 788_032)
        @test integer_stats.multiplication_peak < 2_500_000
        @test !(fixture8 isa ExpansionRefused)
        @test (monomial_count(fixture8.c0), expected_support(fixture8.c0),
               multiplication_peak(fixture8.c0)) ==
              (534_912, 2_370_816, 788_032)
        @test 788_032 < 2_500_000
        @test structural_degrees(fixture8.c0) ==
              actual_degrees(fixture8.c0) == TB0_ND_C0_DEGREES
        report = tb0_pcp_certificate_report(fixture8.farith, fixture8.gs,
                                            fixture8.c0, fixture8.decomposition,
                                            fixture8.proof, fixture8.certificate)
        @test report.degree_accounts
        @test isempty(fixture8.decomposition.remainder.terms)
        @test report.certificate_ok
        @test report.quotient_degree_ok
    end

    @testset "6b. non-degenerate exact dependencies" begin
        fixture8 = polynomial_fixture(GF8, 6; witness=:nondegenerate)
        for i in 1:5
            gi = fixture8.gs[i]
            @test evaluate(gi, zeros(GF8, 16)) !=
                  evaluate(gi, [j == i ? one(GF8) : zero(GF8) for j in 1:16])
            @test dependency_coordinates(gi) == Set((i,))
            @test dependency_blocks(gi) == Set((Symbol("X", i),))
        end
    end

    @testset "6c. non-degenerate completeness coverage" begin
        fixture_deg = polynomial_fixture(GF8, 6)
        fixture8 = polynomial_fixture(GF8, 6; witness=:nondegenerate)
        b8 = base_point(GF8)
        lines = pcp_coordinate_line_report(fixture8.tf, fixture8.proof, b8)
        @test lines == (formula_ok=true, zero_ok=true, count=128)
        proof_deg11 = lift_pcp(fixture_deg.proof, GF2048, 11)
        proof_nd11 = lift_pcp(fixture8.proof, GF2048, 11)
        sampled = pcp_seeded_pair_report(fixture8.tf, proof_deg11, proof_nd11,
                                         10_000, UInt64(0x20_48_10_000))
        @test sampled == (degenerate_ok=true, nondegenerate_ok=true,
                          separator_ok=true, count=10_000)
    end

    @testset "6d. non-degenerate separator and report" begin
        fixture8 = polynomial_fixture(GF8, 6; witness=:nondegenerate)
        proof11 = lift_pcp(fixture8.proof, GF2048, 11)
        separator8 = mutation_b_separator(fixture8.tf, fixture8.proof, GF8)
        separator11 = mutation_b_separator(fixture8.tf, proof11, GF2048)
        @test separator8.view.beta0 == separator8.honest == GF8(2)
        @test separator8.mutated == GF8(1)
        @test separator8.result.actual[1] == separator8.honest
        @test passed(separator8.result)
        @test separator11.view.beta0 == separator11.honest == GF2048(96)
        @test separator11.mutated == GF2048(48)
        @test separator11.result.actual[1] == separator11.honest
        @test passed(separator11.result)

        integer_stats = NONDEGENERATE_INTEGER_STATS[]
        field_stats = BUILD_STATS[(GF8, 6, :nondegenerate)]
        println("TB0 witness (ii) support: local Z=", integer_stats.support,
                " vs critic 788032 CONFIRMED; local char2=",
                monomial_count(fixture8.c0), " vs critic 534912 CONFIRMED")
        println("TB0 witness (ii) measurements: Z seconds=",
                round(integer_stats.seconds; digits=3), ", Z multiplication peak=",
                integer_stats.multiplication_peak, "; char2 proof seconds=",
                round(field_stats.seconds; digits=3), ", construction peak=",
                multiplication_peak(fixture8.c0), "; peak RSS MiB=",
                round(max(integer_stats.peak_rss, field_stats.peak_rss) / 2.0^20;
                      digits=1))
        println("TB0 witness (ii) dependencies=",
                map(dependency_coordinates, fixture8.gs),
                "; every g_i non-constant; C3 locality owner=witness(ii)")
        println("TB0 mutation-B separator: honest/mutated GF8=2/1; ",
                "GF(2^11)=96/48; verifier RHS=honest")
    end
end

if runs("layout_m2")
    @testset "7. layout-driven sign block for m=2" begin
        report = tb0_layout_m2_report()
        @test report.sign_coordinates == 11:15
        @test report.c0_nonzero
        @test passed(report.verifier)
    end
end

if runs("lift_agreement")
    @testset "8. lifted/direct GF(2^11) proof agreement" begin
        source = polynomial_fixture(GF8, 6)
        report = tb0_lift_direct_report(source.proof, DEGENERATE_TABLES,
                                        MonomialBudget(160_000), 200,
                                        UInt64(0x11_20_0))
        @test !(report isa ExpansionRefused)
        @test report.agreement == (agreed=true, count=200)
        println("TB0 lift/direct agreement: GF(2^11) direct build seconds=",
                round(report.direct_seconds; digits=3),
                "; seeded points=200; support=", report.support,
                "; peak RSS MiB=", round(report.peak_rss / 2.0^20; digits=1))
    end
end

const TB0_F_DEGREES = (2, 0, 0, 0, 2, 2, 0, 0, 0, 0, 6, 4, 4, 4, 4, 3)
const TB0_C0_DEGREES = (3, 0, 0, 0, 2, 3, 1, 1, 1, 1, 6, 4, 4, 4, 4, 3)

if runs("occurrence")
    @testset "6a. TB0 occurrence, fan-out, degree, dependency reports" begin
        fixture = polynomial_fixture(GF8, 6)
        @test occurrences(fixture.tf.formula, 16) == TB0_F_DEGREES
        @test tseitin_occurrence_account(fixture.circuit) == TB0_F_DEGREES
        @test structural_degrees(fixture.farith) == TB0_F_DEGREES
        @test actual_degrees(fixture.farith) == TB0_F_DEGREES
        @test structural_degrees(fixture.c0) == TB0_C0_DEGREES
        @test actual_degrees(fixture.c0) == TB0_C0_DEGREES
        @test structural_degrees(fixture.farith) == actual_degrees(fixture.farith)
        @test structural_degrees(fixture.c0) == actual_degrees(fixture.c0)
        @test degree_accounts_valid(fixture.farith)
        @test degree_accounts_valid(fixture.c0)
        println("TB0 F_arith degrees = ", actual_degrees(fixture.farith))
        println("TB0 c0 degrees = ", actual_degrees(fixture.c0))
    end
end

if runs("c8")
    @testset "6b. C8 two-gate fan-out regression" begin
        expected = (2, 2, 2, 4, 3)
        report = tb0_c8_report()
        @test report.occurrence == expected
        @test report.accounted == expected
        @test report.structural == expected
        @test report.actual == expected
        @test report.actual[4] == 4
        @test report.bounded
        println("C8 degrees (x1,x2,x3,w1,w2) = ", report.actual,
                "; deg_w1=", report.actual[4])
    end
end
