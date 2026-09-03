const TB0_LOCAL_JULIA_DEPOT = "/tmp/mipstar-lambda-julia-depot"
mkpath(TB0_LOCAL_JULIA_DEPOT)
TB0_LOCAL_JULIA_DEPOT in DEPOT_PATH || pushfirst!(DEPOT_PATH, TB0_LOCAL_JULIA_DEPOT)

using Test
using Random
using MIPStarLambda
Base.Experimental.@optlevel 0

const TB0_TARGET = get(ENV, "TB0_TARGET", "all")
runs(name) = TB0_TARGET == "all" || TB0_TARGET == name

bits(n, width) = [isodd(n >> (i - 1)) for i in 1:width]
field_bit(::Type{F}, b::Bool) where {F} = b ? one(F) : zero(F)

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
        for (F, point_count) in ((GF8, 8), (GF2048, 512))
            layout1 = VarLayout((:x1,), (VarBlock(:X, 1:1),))
            a1 = F[0, 1]
            g1 = g_a(a1, layout1, (1,)).term
            xs1 = F == GF8 ? [[x] for x in field_elements(F)] : begin
                rng = MersenneTwister(0x1d_1)
                [[F(rand(rng, 0:field_size(F)-1))] for _ in 1:point_count]
            end
            for x in xs1
                @test evaluate(g1, x) == sum(a1 .* ind(x); init=zero(F))
            end
            @test [evaluate(g1, F[b]) for b in 0:1] == a1
            @test dec(g1, (1,), F[0, 1]) == a1

            layout2 = VarLayout((:x1, :x2), (VarBlock(:X, 1:2),))
            a2 = F[0, 1, 1, 0]
            g2 = g_a(a2, layout2, (1, 2)).term
            xs2 = F == GF8 ? [[x, y] for x in field_elements(F) for y in field_elements(F)] : begin
                rng = MersenneTwister(0x1d_2)
                [[F(rand(rng, 0:field_size(F)-1)), F(rand(rng, 0:field_size(F)-1))]
                 for _ in 1:point_count]
            end
            for x in xs2
                @test evaluate(g2, x) == sum(a2 .* ind(x); init=zero(F))
            end
            @test [evaluate(g2, F[b1, b2]) for b1 in 0:1 for b2 in 0:1] == a2
            @test dec(g2, (1, 2), F[0, 1]) == a2
            @test structural_degrees(g2) == (1, 1)
            @test actual_degrees(g2) == (1, 1)
        end
        println("TB0 encoding: m=1 [0,1], m=2 [0,1,1,0]; GF(8) points=8+64; ",
                "GF(2^11) seeded points=1024")
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

function tb0_witness(n)
    bs = bits(n, 10)
    return ntuple(i -> Bool[bs[2i - 1], bs[2i]], 5)
end

if runs("circuit")
    @testset "4. circuit, Tseitin, output literal, arithmetization" begin
        circuit = tb0_circuit()
        present = 0
        absent = 0
        circuit_ok = true
        present_clauses = Vector{Vector{Bool}}()
        for n in 0:2^10-1
            input = bits(n, 10)
            expected = input[1] && input[6] && input[5]
            circuit_ok &= evaluate_circuit(circuit, input) == expected
            if expected
                present += 1
                push!(present_clauses, input)
            else
                absent += 1
            end
        end
        @test circuit_ok
        @test (present, absent) == (128, 896)

        # `phi_C` is the present-clause relation; exhaust all 2^10 witnesses
        # against the independently exhausted relation table above.
        satisfying = count(0:2^10-1) do n
            witness = tb0_witness(n)
            all(clause -> any(witness[i][Int(clause[i]) + 1] == clause[5 + i]
                              for i in 1:5), present_clauses)
        end
        @test satisfying == 512
        chosen = (Bool[0, 1], Bool[0, 0], Bool[0, 0], Bool[0, 0], Bool[0, 0])
        @test phi_C(circuit, chosen)

        tf = tseitin(circuit).term
        formula_ok = true
        arith_ok = true
        for input_index in 0:2^10-1
            input = bits(input_index, 10)
            trace = gate_trace(circuit, input)
            circuit_value = trace[circuit.output.id]
            for wire_index in 0:2^6-1
                wires = bits(wire_index, 6)
                assignment = vcat(input, wires)
                expected = wires == trace && circuit_value
                formula_ok &= evaluate_formula(tf, assignment) == expected
                arith_ok &= evaluate_arith_formula(tf,
                    GF8[field_bit(GF8, b) for b in assignment]) == field_bit(GF8, expected)
            end
        end
        @test formula_ok
        @test arith_ok
        println("TB0 Boolean scopes: clauses present/absent=128/896; witnesses=512; ",
                "(x,o,w) assignments=65536")
    end
end

function build_polynomial_fixture(::Type{F}; d) where {F}
    circuit = tb0_circuit()
    tf = tseitin(circuit).term
    farith_checked = arith_q(tf, F; budget=MonomialBudget(160_000))
    farith_checked isa ExpansionRefused && return farith_checked
    farith = farith_checked.term
    layout = tf.layout
    assignments = (F[0, 1], F[0, 0], F[0, 0], F[0, 0], F[0, 0])
    gs = ntuple(i -> g_a(assignments[i], layout, (i,)).term, 5)
    c0_checked = build_c0(farith, gs; budget=MonomialBudget(160_000))
    c0_checked isa ExpansionRefused && return c0_checked
    c0 = c0_checked.term
    decomposition_checked = zero_basis_decompose(c0, ntuple(identity, 16))
    proof_checked = build_pcp(gs, c0, decomposition_checked; d=d)
    return (; circuit, tf, farith, gs, c0,
            decomposition=decomposition_checked.term,
            proof=proof_checked.term,
            certificate=proof_checked.certificate)
end

function lifted_polynomial_fixture(source, ::Type{F}, d) where {F}
    proof = lift_pcp(source.proof, F; d=d)
    (; circuit=source.circuit, tf=source.tf, farith=source.farith,
       gs=source.gs, c0=source.c0, decomposition=source.decomposition,
       proof, certificate=source.certificate)
end

const POLY_CACHE = Dict{Tuple{DataType,Int},Any}()
const BUILD_STATS = Dict{Tuple{DataType,Int},NamedTuple}()
function polynomial_fixture(::Type{F}, d) where {F}
    key = (F, d)
    return get!(POLY_CACHE, key) do
        measured = @timed build_polynomial_fixture(F; d=d)
        BUILD_STATS[key] = (seconds=measured.time, bytes=measured.bytes)
        measured.value
    end
end

function base_point(::Type{F}) where {F}
    rho = primitive_element(F)
    z = fill(zero(F), 16)
    z[6:10] .= one(F)
    z[11] = rho
    z[16] = rho
    return z
end

function check_pcp_point(fixture, z)
    view = ev_z(fixture.proof, z)
    pcpverifier(fixture.tf, view)
end

if runs("pcp_separator")
    @testset "5b. mutation-B formula separator" begin
        source = polynomial_fixture(GF8, 6)
        fixture = lifted_polynomial_fixture(source, GF2048, 11)
        @test !(fixture isa ExpansionRefused)
        z = base_point(GF2048)
        z[7] = primitive_element(GF2048) # O2=rho, while C ignores O2.
        @test !iszero(evaluate_arith_formula(fixture.tf, z))
        result = check_pcp_point(fixture, z)
        @test result.formula_ok
        @test result.zero_ok
        @test passed(result)
    end
end

if runs("pcp")
    @testset "5. PCP proof, policies, slices, and samples" begin
        small_policy = parameter_policy(PCPParams(8, 3, 1, 6, 6, 16), 6)
        sampled_policy = parameter_policy(PCPParams(2048, 11, 1, 11, 6, 16), 6)
        @test policy_vector(small_policy) ==
              (PASS, NOT_EVALUABLE, FAIL, FAIL, FAIL, FAIL)
        @test policy_vector(sampled_policy) ==
              (PASS, NOT_EVALUABLE, PASS, PASS, PASS, PASS)
        @test small_policy.P_exponent_range == PASS
        @test sampled_policy.P_formula_structural == PASS
        @test sampled_policy.P_zero == PASS
        @test minimal_checkable_odd_k(6, 16) == 11

        fixture8 = polynomial_fixture(GF8, 6)
        @test !(fixture8 isa ExpansionRefused)
        @test build_c0(fixture8.farith, fixture8.gs;
                       budget=MonomialBudget(148_175)) isa ExpansionRefused
        @test expected_support(fixture8.c0) == 148_176
        @test monomial_count(fixture8.c0) <= 148_176
        @test isempty(fixture8.decomposition.remainder.terms)

        rho8 = primitive_element(GF8)
        b8 = base_point(GF8)
        direct8 = evaluate_arith_formula(fixture8.tf, b8)
        @test direct8 == rho8^4 * (one(GF8) + rho8)
        @test !iszero(direct8)
        slice_checks = 0
        slice_formula_ok = true
        slice_zero_ok = true
        for j in 1:16, t in field_elements(GF8)
            z = copy(b8)
            z[j] = t
            result = check_pcp_point(fixture8, z)
            slice_formula_ok &= result.formula_ok
            slice_zero_ok &= result.zero_ok
            slice_checks += 1
        end
        @test slice_checks == 128
        @test slice_formula_ok
        @test slice_zero_ok

        lifted = @timed lifted_polynomial_fixture(fixture8, GF2048, 11)
        fixture11 = lifted.value
        BUILD_STATS[(GF2048, 11)] = (seconds=lifted.time, bytes=lifted.bytes)
        @test !(fixture11 isa ExpansionRefused)
        @test fixture11.decomposition === fixture8.decomposition
        rng = MersenneTwister(0x20_48_10_000)
        sample_checks = 0
        sample_formula_ok = true
        sample_zero_ok = true
        for _ in 1:10_000
            z = [GF2048(rand(rng, 0:2047)) for _ in 1:16]
            result = check_pcp_point(fixture11, z)
            sample_formula_ok &= result.formula_ok
            sample_zero_ok &= result.zero_ok
            sample_checks += 1
        end
        b11 = base_point(GF2048)
        rho11 = primitive_element(GF2048)
        for j in 1:16
            z = copy(b11)
            z[j] = j == 7 ? rho11 : rho11 + one(GF2048)
            result = check_pcp_point(fixture11, z)
            sample_formula_ok &= result.formula_ok
            sample_zero_ok &= result.zero_ok
        end
        @test sample_checks == 10_000
        @test sample_formula_ok
        @test sample_zero_ok

        for fixture in (fixture8, fixture11)
            @test all(i -> dependency_coordinates(fixture.gs[i]) ⊆ Set((i,)), 1:5)
            @test dependency_blocks(fixture.gs[1]) == Set((:X1,))
            @test all(isempty(dependency_coordinates(fixture.gs[i])) for i in 2:5)
            @test all(degree_accounts_valid,
                      Iterators.flatten(((fixture.farith, fixture.c0),
                                         fixture.decomposition.quotients)))
            @test all(p -> maximum(actual_degrees(p); init=-1) <=
                           (fixture === fixture8 ? 6 : 11),
                      fixture.decomposition.quotients)
        end

        @test passed(verify_certificate(Checked(fixture8.proof, fixture8.certificate)))
        stats8 = BUILD_STATS[(GF8, 6)]
        stats11 = BUILD_STATS[(GF2048, 11)]
        println("TB0 policy (P_shape,P_growth,P_formula_paper,P_tail,P_divisibility,P_degree): ",
                "small=", policy_vector(small_policy),
                "; sampled=", policy_vector(sampled_policy))
        println("TB0 c0 normalized monomials=", monomial_count(fixture8.c0),
                "; expected candidates=", expected_support(fixture8.c0),
                "; GF8 build seconds=", round(stats8.seconds; digits=3),
                "; GF2048 build seconds=", round(stats11.seconds; digits=3),
                "; allocated bytes=", stats8.bytes + stats11.bytes)
        println("TB0 dependency table: g=", map(dependency_coordinates, fixture8.gs),
                "; F_arith=", dependency_coordinates(fixture8.farith),
                "; c0=", dependency_coordinates(fixture8.c0))
        println("TB0 quotient table: monomials=",
                map(monomial_count, fixture8.decomposition.quotients),
                "; max degrees=",
                map(p -> maximum(actual_degrees(p); init=-1),
                    fixture8.decomposition.quotients))
        println("TB0 PCP equations: formula=true; zero=true; GF8 coordinate lines=16x8; ",
                "GF(2^11) seed=0x204810000 samples=10000 + separators=16")
        traceprint(stdout, fixture8.certificate)
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
        circuit = c8_two_gate_circuit()
        tf = tseitin(circuit).term
        farith = arith_q(tf, GF8; budget=MonomialBudget(160_000)).term
        expected = (2, 2, 2, 4, 3)
        @test occurrences(tf.formula, 5) == expected
        @test tseitin_occurrence_account(circuit) == expected
        @test structural_degrees(farith) == expected
        @test actual_degrees(farith) == expected
        @test actual_degrees(farith)[4] == 4
        @test all(actual_degrees(farith) .<= occurrences(tf.formula, 5))
        println("C8 degrees (x1,x2,x3,w1,w2) = ", actual_degrees(farith),
                "; deg_w1=", actual_degrees(farith)[4])
    end
end
