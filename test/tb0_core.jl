using Test
using Random
using MIPStarLambda
Base.Experimental.@optlevel 0

const TB0_TARGET = get(ENV, "TB0_TARGET", "all")
runs(name) = TB0_TARGET == "all" || TB0_TARGET == name
bits(value, width) = [isodd(value >> (i - 1)) for i in 1:width]

function exercise_field_axioms(::Type{F}, triples) where {F}
    all_ok = true
    for (a, b, c) in triples
        all_ok &= (a + b) + c == a + (b + c)
        all_ok &= (a * b) * c == a * (b * c)
        all_ok &= a + b == b + a
        all_ok &= a * b == b * a
        all_ok &= a * (b + c) == a * b + a * c
        all_ok &= (a + b) * c == a * c + b * c
        all_ok &= a + zero(F) == a && a * one(F) == a && a + (-a) == zero(F)
        iszero(a) || (all_ok &= a * inv(a) == one(F))
        all_ok &= field_from_bytes(F, field_bytes(a)) == a
    end
    all_ok
end

if runs("field")
    @testset "1. GF(2^k) field laws" begin
        @test modulus_polynomial(GF8) == 0x00b
        @test modulus_polynomial(GF2048) == 0x805
        @test is_irreducible_modulus(GF8) && is_irreducible_modulus(GF2048)
        @test multiplicative_order(primitive_element(GF8)) == 7
        @test multiplicative_order(primitive_element(GF2048)) == 2047
        elems8 = field_elements(GF8)
        @test exercise_field_axioms(GF8,
            ((a, b, c) for a in elems8 for b in elems8 for c in elems8))
        rng = MersenneTwister(0x09_20_48)
        @test exercise_field_axioms(GF2048,
            ((GF2048(rand(rng, 0:2047)), GF2048(rand(rng, 0:2047)),
              GF2048(rand(rng, 0:2047))) for _ in 1:10_000))
        println("TB0 fields: GF(8) modulus=0x00b exhaustive triples=512; ",
                "GF(2^11) modulus=0x805 seed=0x092048 triples=10000")
    end
end

function encoding_checks(::Type{F}) where {F<:GF2k}
    layout1 = VarLayout((:x1,), (VarBlock(:X, 1:1),))
    m1_ok = true
    for table in (F[0, 1], F[1, 0])
        extension = g_a(table, layout1, (1,)).term
        m1_ok &= [evaluate(extension, F[b]) for b in 0:1] == table
        m1_ok &= dec(extension, (1,), F[0, 1]) == table
    end

    layout2 = VarLayout((:x1, :x2), (VarBlock(:X, 1:2),))
    cube2 = [F[b1, b2] for b1 in 0:1 for b2 in 0:1]
    m2_ok = true
    for table in (F[0, 1, 1, 0], F[0, 0, 1, 0])
        extension = g_a(table, layout2, (1, 2)).term
        m2_ok &= [evaluate(extension, p) for p in cube2] == table
        m2_ok &= all(p -> evaluate(extension, p) ==
                          sum(table .* ind(p); init=zero(F)), cube2)
        m2_ok &= dec(extension, (1, 2), F[0, 1]) == table
    end

    layout3 = VarLayout((:x1, :x2, :x3), (VarBlock(:X, 1:3),))
    table3 = F[0, 0, 0, 0, 1, 0, 0, 0]
    extension3 = g_a(table3, layout3, (1, 2, 3)).term
    cube3 = [F[b1, b2, b3] for b1 in 0:1 for b2 in 0:1 for b3 in 0:1]
    m3_ok = [evaluate(extension3, p) for p in cube3] == table3
    m3_ok &= all(p -> evaluate(extension3, p) ==
                      sum(table3 .* ind(p); init=zero(F)), cube3)
    (; m1_ok, m2_ok, m3_ok, m1_points=4, m2_points=8,
       m3_points=length(cube3))
end

if runs("encoding")
    @testset "2. multilinear low-degree encoding and bit order" begin
        report8 = encoding_checks(GF8)
        @test report8 == (m1_ok=true, m2_ok=true, m3_ok=true,
                          m1_points=4, m2_points=8, m3_points=8)
        println("TB0 encoding: asymmetric m=2 [0,0,1,0], m=3 singleton@100; ",
                "big-endian index order checked in g_a and ind")
    end
end

function polynomial_from_coefficients(coefficients::NTuple{4,GF8})
    layout = VarLayout((:x,), (VarBlock(:Z, 1:1),))
    terms = Dict{NTuple{1,UInt8},GF8}()
    for (exponent, coefficient) in enumerate(coefficients)
        iszero(coefficient) || (terms[(UInt8(exponent),)] = coefficient)
    end
    derivation = DegreeDerivation(:QuarticFixture, (4,), (1,), ())
    MIPStarLambda._from_terms(GF8, layout, terms, derivation)
end

if runs("zero_basis") || runs("nonprime")
    @testset "3. zero-basis rewrite over arbitrary GF(8) coefficients" begin
        layout = VarLayout((:x, :y), (VarBlock(:Z, 1:2),))
        x, y = polyvar(GF8, layout, 1), polyvar(GF8, layout, 2)
        f = x^3 - x^2 + x * y^2 - x * y
        checked = zero_basis_decompose(f, (1, 2))
        @test !isempty(checked.term.steps)
        @test all(step -> passed(verify_rewrite_step(step)), checked.term.steps)
        @test passed(verify_zero_decomposition(f, checked.term))
        @test isempty(checked.term.remainder.terms)
        @test passed(verify_certificate(checked))

        # Critic counterexample x^3+2x^2+3x, plus the full 8^3=512 family.
        counterexample = polynomial_from_coefficients((GF8(3), GF8(2), GF8(1), GF8(0)))
        @test isempty(zero_basis_decompose(counterexample, (1,)).term.remainder.terms)
        correct = 0
        family_ok = true
        for c2 in field_elements(GF8), c3 in field_elements(GF8), c4 in field_elements(GF8)
            c1 = c2 + c3 + c4
            quartic = polynomial_from_coefficients((c1, c2, c3, c4))
            decomposition = zero_basis_decompose(quartic, (1,))
            family_ok &= iszero(evaluate(quartic, GF8[0]))
            family_ok &= iszero(evaluate(quartic, GF8[1]))
            family_ok &= passed(verify_zero_decomposition(quartic, decomposition.term))
            isempty(decomposition.term.remainder.terms) && (correct += 1)
        end
        @test family_ok
        @test correct == 512

        # This reaches the GF2k multiplication guard with a non-prime coefficient.
        scaled = constant_poly(GF8, layout, GF8(2)) * x
        @test evaluate(scaled * x, GF8[GF8(3), GF8(0)]) == GF8(2) * GF8(3)^2
        println("TB0 zero basis: arbitrary-coefficient quartics correct=512/512; ",
                "critic counterexample remainder=0")
    end
end

function present_clauses(circuit)
    [bits(encoded, 10) for encoded in 0:2^10-1
     if evaluate_circuit(circuit, bits(encoded, 10))]
end

# Clause-relation count, NOT a remainder computation: this re-derives phi_C
# from the present clauses by De Morgan, so testset 4b only counts the
# satisfying witnesses. The link between phi_C and the zero-basis remainder
# of c_0 is machine-checked through the real pipeline in testset 4c.
function clause_relation_holds(circuit, witness)
    for input in present_clauses(circuit)
        all(witness[i][Int(input[i]) + 1] != input[5 + i] for i in 1:5) &&
            return false
    end
    true
end

witness_blocks(tables) = ntuple(i -> Bool[tables[i]...], 5)

if runs("circuit")
    @testset "4a. exhaustive circuit and Tseitin arithmetization" begin
        circuit = tb0_circuit()
        clauses = present_clauses(circuit)
        @test length(clauses) == 128
        @test count(encoded -> !evaluate_circuit(circuit, bits(encoded, 10)),
                    0:2^10-1) == 896
        tf = tseitin(circuit).term
        formula_ok = true
        arith_ok = true
        for input_index in 0:2^10-1
            input = bits(input_index, 10)
            trace = gate_trace(circuit, input)
            for wire_index in 0:2^6-1
                wires = bits(wire_index, 6)
                assignment = vcat(input, wires)
                expected = wires == trace && trace[circuit.output.id]
                formula_ok &= evaluate_formula(tf, assignment) == expected
                arith_ok &= evaluate_arith_formula(tf, GF8.(assignment)) == GF8(expected)
            end
        end
        @test formula_ok && arith_ok
        println("TB0 Boolean circuit scope: clauses=128/896; assignments=65536")
    end
end

if runs("circuit") || runs("witness_iff")
    @testset "4b. clause-relation count on all 1024 witnesses (surrogate)" begin
        circuit = tb0_circuit()
        satisfying = 0
        clause_holds = 0
        agree = true
        count_seconds = @elapsed for encoded in 0:2^10-1
            witness_bits = bits(encoded, 10)
            witness = ntuple(i -> Bool[witness_bits[2i-1], witness_bits[2i]], 5)
            satisfies = phi_C(circuit, witness)
            holds = clause_relation_holds(circuit, witness)
            agree &= holds == satisfies
            satisfying += satisfies
            clause_holds += holds
        end
        @test agree
        @test satisfying == clause_holds == 512
        println("TB0 witness scope: witnesses=1024; clause-relation count=512/512 ",
                "(surrogate, not a remainder computation); seconds=",
                round(count_seconds; digits=3))
    end
end

const DEGENERATE_TABLES = ((0, 1), (0, 0), (0, 0), (0, 0), (0, 0))
const NONDEGENERATE_TABLES = ((0, 1), (0, 1), (0, 1), (0, 1), (0, 1))
# Witness (iii) fails phi_C: phi_C needs some a_i(x_i) == o_i on every
# present clause, and the all-zero tables agree with no sign of the present
# clauses whose o_i are all 1. So its c_0 must NOT vanish on the Boolean cube
# and its zero-basis remainder must be nonzero.
const UNSATISFYING_TABLES = ((0, 0), (0, 0), (0, 0), (0, 0), (0, 0))
const NONDEGENERATE_INTEGER_STATS = Ref{Any}(nothing)
const POLY_CACHE = Dict{Tuple{DataType,Int,Symbol},Any}()
const BUILD_STATS = Dict{Tuple{DataType,Int,Symbol},NamedTuple}()
const PROOF11_CACHE = Dict{Symbol,NamedTuple}()
const C0_11_CACHE = Ref{Any}(nothing)

function polynomial_fixture(::Type{F}, d; witness=:degenerate) where {F}
    key = (F, d, witness)
    haskey(POLY_CACHE, key) && return POLY_CACHE[key]
    measured = if witness == :nondegenerate && F == GF8
        @timed tb0_build_nondegenerate_fixture(
            d, NONDEGENERATE_TABLES, MonomialBudget(2_500_000))
    else
        tables, budget = witness == :degenerate ?
            # The retained proof is identical under the design budget 160000;
            # using the exact peak here proves the O11 success boundary.
            (DEGENERATE_TABLES, MonomialBudget(37_240)) :
            (NONDEGENERATE_TABLES, MonomialBudget(2_500_000))
        @timed tb0_build_fixture(F, d, tables, budget)
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

function proof11_fixture(witness::Symbol)
    get!(PROOF11_CACHE, witness) do
        fixture = polynomial_fixture(GF8, 6; witness)
        measured = @timed change_field(fixture.proof, GF2048, 11,
                                       tb0_certified_points(GF2048))
        (; checked=measured.value, proof=measured.value.term,
           seconds=measured.time, bytes=measured.bytes)
    end
end

function c0_candidate_counts(farith, gs, c0)
    signs = block_coordinates(farith.layout, :O)
    factors = ntuple(i -> gs[i] - polyvar(GF8, farith.layout, signs[i]), 5)
    first_count = monomial_count(farith) * monomial_count(factors[1])
    counts = [first_count;
              [monomial_count(c0) * monomial_count(factors[i])
               for i in 2:5]]
    counts
end

function line_values(poly::Poly{F,N}, base::Vector{F}, coordinate::Int) where {F,N}
    top = max(actual_degrees(poly)[coordinate], 0)
    coefficients = fill(zero(F), top + 1)
    maxima = ntuple(i -> i == coordinate ? 0 : max(actual_degrees(poly)[i], 0), N)
    powers = MIPStarLambda._power_table(base, maxima)
    for (key, coefficient) in poly.terms
        term = coefficient
        for i in 1:N
            i == coordinate && continue
            exponent = Int(key[i])
            if exponent > 0
                if iszero(base[i])
                    term = zero(F)
                    break
                end
                term *= powers[i][exponent + 1]
            end
        end
        coefficients[Int(key[coordinate]) + 1] += term
    end
    map(field_elements(F)) do value
        total = zero(F)
        power = one(F)
        for coefficient in coefficients
            total += coefficient * power
            power *= value
        end
        total
    end
end

function coordinate_line_report(tf, proof, base)
    F = eltype(base)
    formula_ok = true
    zero_ok = true
    count = 0
    polynomials = (proof.gs..., proof.c0, proof.cs...)
    for coordinate in eachindex(base)
        evaluations = map(p -> line_values(p, base, coordinate), polynomials)
        for (index, value) in enumerate(field_elements(F))
            point = copy(base)
            point[coordinate] = value
            view = PCPView(point, ntuple(i -> evaluations[i][index], 5),
                           evaluations[6][index],
                           ntuple(i -> evaluations[6+i][index], length(base)))
            result = pcpverifier(tf, view)
            formula_ok &= result.formula_ok
            zero_ok &= result.zero_ok
            count += 1
        end
    end
    (; formula_ok, zero_ok, count)
end

function boolean_cube_zero_report(poly::Poly{F,N}) where {F,N}
    values = fill(zero(F), 1 << N)
    for (key, coefficient) in poly.terms
        mask = sum((key[i] > 0 ? 1 << (i-1) : 0) for i in 1:N)
        values[mask + 1] += coefficient
    end
    for bit in 0:N-1, mask in 0:(1 << N)-1
        isodd(mask >> bit) && (values[mask+1] += values[(mask & ~(1 << bit))+1])
    end
    (; zero=all(iszero, values), count=length(values))
end

if runs("circuit") || runs("witness_iii")
    @testset "4c. witness (iii) through the real pipeline: r != 0 iff !phi_C" begin
        circuit = tb0_circuit()
        witness_iii = witness_blocks(UNSATISFYING_TABLES)
        @test !phi_C(circuit, witness_iii)
        # The design budget 160,000 is the one named in DESIGN.md section 5.1.
        seconds = @elapsed fixture_iii = tb0_build_fixture(
            GF8, 6, UNSATISFYING_TABLES, MonomialBudget(160_000))
        @test !(fixture_iii isa ExpansionRefused)
        @test monomial_count(fixture_iii.c0) == 18_620
        remainder = fixture_iii.decomposition.remainder
        @test !isempty(remainder.terms)
        @test monomial_count(remainder) == 2
        @test !passed(verify_zero_decomposition(fixture_iii.c0,
                                                fixture_iii.decomposition))
        failed = verify_certificate(Checked(fixture_iii.proof, fixture_iii.certificate))
        @test !passed(failed) && failed.rule == :coefficient_identity
        zero_basis_node = fixture_iii.certificate.children[end - 1]
        @test zero_basis_node.facts.display ==
              "remainder = 2; coefficient identity = false"
        # The sentence that links phi_C to c_0: on all three retained
        # witnesses, c_0 vanishes on the 2^16 cube exactly when phi_C holds.
        cube_iii = boolean_cube_zero_report(fixture_iii.c0)
        @test cube_iii == (zero=false, count=65_536)
        for (tables, fixture) in ((DEGENERATE_TABLES, polynomial_fixture(GF8, 6)),
                                  (NONDEGENERATE_TABLES,
                                   polynomial_fixture(GF8, 6; witness=:nondegenerate)),
                                  (UNSATISFYING_TABLES, fixture_iii))
            @test boolean_cube_zero_report(fixture.c0).zero ==
                  phi_C(circuit, witness_blocks(tables))
        end
        println("TB0 witness (iii) all-zero: phi_C=false; |c0|=18620; |r|=2; ",
                "coefficient identity=false; cube vanishing==phi_C on (i),(ii),(iii); ",
                "build seconds=", round(seconds; digits=3))
    end
end

# The separator view is evaluated by `ev_z` at b_rho[O2 <- rho], so this
# works on any proof over F, stored views or not.
function mutation_b_separator(tf, proof, ::Type{F}) where {F}
    rho = primitive_element(F)
    view = ev_z(proof, only(tb0_certified_points(F)))
    result = pcpverifier(tf, view)
    (; view, honest=rho^5 * (one(F) + rho),
       mutated=rho^4 * (one(F) + rho), result)
end

if runs("pcp_separator")
    @testset "5a. mutation-B formula separator" begin
        source = polynomial_fixture(GF8, 6; witness=:nondegenerate)
        proof11 = change_field(source.proof, GF2048, 11,
                               tb0_certified_points(GF2048)).term
        separator8 = mutation_b_separator(source.tf, source.proof, GF8)
        separator11 = mutation_b_separator(source.tf, proof11, GF2048)
        @test separator8.view.beta0 == separator8.honest == GF8(2)
        @test separator8.mutated == GF8(1) && passed(separator8.result)
        @test separator11.view.beta0 == separator11.honest == GF2048(96)
        @test separator11.mutated == GF2048(48) && passed(separator11.result)
        @test only(proof11.certified_views).beta0 == separator11.view.beta0
    end
end

if runs("pcp")
    @testset "5a. PCP policy, exact support, and per-product budget" begin
        fixture = polynomial_fixture(GF8, 6)
        @test !(fixture isa ExpansionRefused)
        degree_formula = maximum(occurrences(fixture.tf.formula, 16))
        small = parameter_policy(PCPParams(8, 3, 1, 6, 6, 16, 1), degree_formula)
        sampled = parameter_policy(PCPParams(2048, 11, 1, 11, 6, 16, 1),
                                   degree_formula)
        @test policy_vector(small) == (PASS, FAIL, FAIL, FAIL, FAIL, FAIL)
        @test policy_vector(sampled) ==
              (PASS, NOT_EVALUABLE, PASS, PASS, PASS, PASS)
        @test small.P_formula_structural == FAIL
        @test sampled.P_formula_structural == PASS && sampled.P_zero == PASS
        @test minimal_checkable_odd_k(degree_formula, 16) == 11

        refused = build_c0(fixture.farith, fixture.gs, MonomialBudget(37_239))
        @test refused isa ExpansionRefused && refused.estimate == 37_240
        counts = c0_candidate_counts(fixture.farith, fixture.gs, fixture.c0)
        @test counts == [37_240, 33_432, 33_432, 33_432, 33_432]
        @test sum(counts) > 160_000 >= maximum(counts)
        @test monomial_count(fixture.c0) == 33_432
        @test multiplication_peak(fixture.c0) == 37_240
        @test expected_support(fixture.c0) == 148_176

        # Witness (i)'s own zero-basis certificate: r = 0, the coefficient
        # identity, the seven-zero/nine-nonzero quotient split, max inddeg 6.
        quotients = collect(fixture.decomposition.quotients)
        @test isempty(fixture.decomposition.remainder.terms)
        @test passed(verify_zero_decomposition(fixture.c0, fixture.decomposition))
        @test findall(q -> isempty(q.terms), quotients) == [2, 3, 4, 7, 8, 9, 10]
        @test count(q -> !isempty(q.terms), quotients) == 9
        @test maximum(maximum(actual_degrees(q); init=-1) for q in quotients) == 6
        @test all(q -> maximum(actual_degrees(q); init=-1) <= fixture.proof.d, quotients)
        println("TB0 policy gamma=1: small=", policy_vector(small),
                "; sampled=", policy_vector(sampled),
                "; degree_formula=", degree_formula)
        println("TB0 witness (i): support=33432; product counts=", counts,
                "; cumulative=", sum(counts), " > budget=160000 >= peak=37240")
    end

    @testset "5b. degenerate GF(8) lines and Boolean cube" begin
        fixture = polynomial_fixture(GF8, 6)
        lines = coordinate_line_report(fixture.tf, fixture.proof,
                                       tb0_base_point(GF8))
        cube = boolean_cube_zero_report(fixture.c0)
        @test lines == (formula_ok=true, zero_ok=true, count=128)
        @test cube == (zero=true, count=65_536)
    end
end

if runs("certificate") || runs("c0_terms")
    @testset "5c. sparse terms and replayable derivation tree" begin
        fixture = polynomial_fixture(GF8, 6)
        proof = fixture.proof
        @test passed(fixture.certificate.replay(proof))
        nodes = (fixture.certificate, fixture.certificate.children...)
        expected_rules = (:PCPProof, :Tseitin, :ArithTseitin,
                          :MultilinearExtension, :MultilinearExtension,
                          :MultilinearExtension, :MultilinearExtension,
                          :MultilinearExtension, :BuildC0, :ZeroBasis,
                          :PCPVerifier)
        @test map(node -> node.rule, nodes) == expected_rules
        @test all(node -> node.grade == CHECKED, nodes)

        view = only(proof.certified_views)
        @test view.z == only(tb0_certified_points(GF8))
        @test view.beta0 == evaluate(fixture.c0, view.z) == GF8(2)
        empty_terms = Dict{NTuple{16,UInt8},GF8}()
        empty_c0 = MIPStarLambda._from_terms(
            GF8, fixture.c0.layout, empty_terms, fixture.c0.structural)
        empty_proof = PCPProof(proof.gs, empty_c0, proof.cs, proof.decomposition,
                               proof.d, proof.tf, proof.certified_views)
        empty_view = PCPView(copy(view.z), view.alpha,
                             evaluate(empty_proof.c0, view.z), view.beta)
        @test !passed(pcpverifier(fixture.tf, empty_view))

        bad_view = PCPView(copy(view.z), view.alpha, view.beta0 + one(GF8), view.beta)
        bad_proof = PCPProof(proof.gs, proof.c0, proof.cs, proof.decomposition,
                             proof.d, proof.tf, (bad_view,))
        verifier_node = last(fixture.certificate.children)
        @test passed(verifier_node.replay(proof))
        @test !passed(verifier_node.replay(bad_proof))
        # X3: a proof with NO stored certified view carries no verifier
        # evidence and must not replay as accepted.
        no_view_proof = PCPProof(proof.gs, proof.c0, proof.cs, proof.decomposition,
                                 proof.d, proof.tf, ())
        @test !passed(verifier_node.replay(no_view_proof))

        # All eleven CHECKED replays run on witness (i)'s own terms.
        @test passed(verify_certificate(Checked(proof, fixture.certificate)))
        # The displayed zero-basis fact is computed, never a literal.
        zero_basis_node = fixture.certificate.children[end - 1]
        @test zero_basis_node.rule == :ZeroBasis
        @test zero_basis_node.facts.display ==
              "remainder = 0; coefficient identity = true"

        # X4: the :Tseitin replay compares the stored occurrence vector with
        # the independent fan-out account, so a wrong stored vector is rejected.
        tseitin_checked = tseitin(fixture.circuit)
        @test passed(verify_certificate(tseitin_checked))
        tf = tseitin_checked.term
        capped = ntuple(i -> min(tf.occurrence_vector[i], 1), 16)
        bad_tf = TseitinFormula(tf.formula, tf.input_blocks, tf.layout, tf.gadgets,
                                tf.output_variable, capped, tf.program)
        @test !passed(tseitin_checked.certificate.replay(bad_tf))
        traceprint(stdout, fixture.certificate)
    end
end

const TB0_ND_C0_DEGREES =
    (3, 1, 1, 1, 3, 3, 1, 1, 1, 1, 6, 4, 4, 4, 4, 3)

if runs("nondegenerate")
    @testset "6a. non-degenerate support and certificate" begin
        fixture = polynomial_fixture(GF8, 6; witness=:nondegenerate)
        integer_stats = NONDEGENERATE_INTEGER_STATS[]
        @test (integer_stats.support, integer_stats.source) == (788_032, :critic)
        @test (monomial_count(fixture.c0), expected_support(fixture.c0),
               multiplication_peak(fixture.c0)) ==
              (534_912, 2_370_816, 534_912)
        @test structural_degrees(fixture.c0) ==
              actual_degrees(fixture.c0) == TB0_ND_C0_DEGREES
        @test isempty(fixture.decomposition.remainder.terms)
        @test all(p -> degree_accounts_valid(p) &&
                       maximum(actual_degrees(p); init=-1) <= fixture.proof.d,
                  (fixture.gs..., fixture.c0, fixture.decomposition.quotients...))
        @test passed(verify_zero_decomposition(fixture.c0, fixture.decomposition))
        # All eleven CHECKED replays run on witness (ii)'s own terms.
        @test passed(verify_certificate(Checked(fixture.proof, fixture.certificate)))
    end

    @testset "6b. non-degenerate exact dependencies and non-vacuity" begin
        fixture = polynomial_fixture(GF8, 6; witness=:nondegenerate)
        for i in 1:5
            gi = fixture.gs[i]
            @test evaluate(gi, zeros(GF8, 16)) !=
                  evaluate(gi, [j == i ? one(GF8) : zero(GF8) for j in 1:16])
            @test dependency_coordinates(gi) == Set((i,))
            @test dependency_blocks(gi) == Set((Symbol("X", i),))
        end
        base8 = tb0_base_point(GF8)
        @test !iszero(evaluate(fixture.c0, base8))
        C0_11_CACHE[] = change_field(fixture.c0, GF2048)
        @test !iszero(evaluate(C0_11_CACHE[], tb0_base_point(GF2048)))
    end

    @testset "6c. non-degenerate completeness coverage" begin
        degenerate = polynomial_fixture(GF8, 6)
        fixture = polynomial_fixture(GF8, 6; witness=:nondegenerate)
        proof_deg11 = proof11_fixture(:degenerate).proof
        @test monomial_count(proof_deg11.c0) == 33_432
    end

    @testset "6d. separators and direct field-change measurement" begin
        fixture = polynomial_fixture(GF8, 6; witness=:nondegenerate)
        changed = proof11_fixture(:degenerate)
        proof11 = changed.proof
        separator8 = mutation_b_separator(fixture.tf, fixture.proof, GF8)
        rho11 = primitive_element(GF2048)
        point11 = tb0_base_point(GF2048)
        point11[7] = rho11
        beta0_11 = evaluate(proof11.c0, point11)
        @test separator8.view.beta0 == separator8.honest == GF8(2)
        @test separator8.mutated == GF8(1) && passed(separator8.result)
        @test beta0_11 == GF2048(96)
        @test rho11^4 * (one(GF2048) + rho11) == GF2048(48)
        @test monomial_count(proof11.c0) == 33_432
        stats = BUILD_STATS[(GF8, 6, :nondegenerate)]
        println("TB0 witness (ii): critic-Z/local-char2 support=788032/534912; build seconds=",
                round(stats.seconds; digits=3), "; peak RSS MiB=",
                round(stats.peak_rss / 2.0^20; digits=1))
        println("TB0 direct GF(2^11) change_field proof seconds=",
                round(changed.seconds; digits=3), "; lazy lift deleted; ",
                "c0(b_rho)=48 != 0; separator honest/mutated=96/48")
    end
end

if runs("nondegenerate") || runs("field_change")
    @testset "6e. GF(2^11) field change is re-certified" begin
        fixture = polynomial_fixture(GF8, 6)
        checked = proof11_fixture(:degenerate).checked
        nodes = (checked.certificate, checked.certificate.children...)
        @test map(node -> node.rule, nodes) ==
              (:PCPProof, :BuildC0, :ZeroBasis, :PCPVerifier)
        @test all(node -> node.grade == CHECKED, nodes)
        @test passed(verify_certificate(checked))
        @test checked.term.d == 11
        view11 = only(checked.term.certified_views)
        @test view11.z == only(tb0_certified_points(GF2048))
        @test view11.beta0 == evaluate(checked.term.c0, view11.z) == GF2048(96)
        @test passed(pcpverifier(fixture.tf, view11))
        # The relabelled d is re-derived by the root replay, not copied:
        # d = 5 < inddeg(c_0) = 6 is refused with the degree rule.
        too_small = verify_certificate(change_field(fixture.proof, GF2048, 5))
        @test !passed(too_small) && too_small.rule == :pcp_degree
        # Without certified points the change carries no verifier evidence.
        no_points = verify_certificate(change_field(fixture.proof, GF2048, 11))
        @test !passed(no_points) && no_points.rule == :pcpverifier_replay
        println("TB0 GF(2^11) change_field: re-certified (4 CHECKED nodes replayed); ",
                "stored view beta0=96 at b_rho[O2<-rho]; d=5 refused; no-point change refused")
    end
end

if runs("layout_m2")
    @testset "7. layout-driven sign block for m=2" begin
        # `layout_m2_circuit`: five 2-coordinate X blocks, sign block 11:15,
        # three gates; the TB0 constant 6:10 reads X3b..X5b here. The point
        # is off the cube with every g_i - o_i and F_arith nonzero.
        circuit = layout_m2_circuit()
        point = layout_m2_point(GF8)
        fixture = build_pcp_fixture(circuit, GF8, 6, LAYOUT_M2_TABLES,
                                    MonomialBudget(10_000), (point,))
        @test !(fixture isa ExpansionRefused)
        layout = fixture.tf.layout
        @test block_coordinates(layout, :O) == 11:15
        @test block_coordinates(layout, :X3) == 5:6
        @test all(iszero, point[6:10])
        signs = block_coordinates(layout, :O)
        view = ev_z(fixture.proof, point)
        expected = evaluate_arith_formula(fixture.tf, point) *
                   prod(view.alpha[i] - point[signs[i]] for i in 1:5)
        @test !iszero(expected)
        @test view.beta0 == evaluate(fixture.c0, point) == expected
        @test passed(pcpverifier(fixture.tf, view))
        @test isempty(fixture.decomposition.remainder.terms)
        @test passed(verify_certificate(Checked(fixture.proof, fixture.certificate)))
        # A view whose sign product was taken over the TB0 constant block 6:10
        # is rejected by the layout-driven verifier.
        wrong_beta0 = evaluate_arith_formula(fixture.tf, point) *
                      prod(view.alpha[i] - point[5 + i] for i in 1:5)
        @test iszero(wrong_beta0)
        wrong = PCPView(copy(point), view.alpha, wrong_beta0, view.beta)
        @test !passed(pcpverifier(fixture.tf, wrong))
        println("TB0 layout m=2: 18 variables, sign block 11:15, c0(z)=", expected,
                " != 0; verifier accepts the layout view and rejects the 6:10 view")
    end
end

const TB0_F_DEGREES = (2, 0, 0, 0, 2, 2, 0, 0, 0, 0, 6, 4, 4, 4, 4, 3)
const TB0_C0_DEGREES = (3, 0, 0, 0, 2, 3, 1, 1, 1, 1, 6, 4, 4, 4, 4, 3)

if runs("occurrence")
    @testset "8. TB0 occurrence, fan-out, degree, dependency" begin
        fixture = polynomial_fixture(GF8, 6)
        @test occurrences(fixture.tf.formula, 16) == TB0_F_DEGREES
        @test tseitin_occurrence_account(fixture.circuit) == TB0_F_DEGREES
        @test structural_degrees(fixture.farith) ==
              actual_degrees(fixture.farith) == TB0_F_DEGREES
        @test structural_degrees(fixture.c0) ==
              actual_degrees(fixture.c0) == TB0_C0_DEGREES
        println("TB0 F_arith/c0 degree vectors=", TB0_F_DEGREES, "/",
                TB0_C0_DEGREES)
    end
end

if runs("c8")
    @testset "9. C8 two-gate fan-out regression" begin
        circuit = c8_two_gate_circuit()
        tf = tseitin(circuit).term
        farith = arith_q(tf, GF8, MonomialBudget(160_000)).term
        expected = (2, 2, 2, 4, 3)
        @test occurrences(tf.formula, 5) == expected
        @test tseitin_occurrence_account(circuit) == expected
        @test structural_degrees(farith) == actual_degrees(farith) == expected
        @test actual_degrees(farith)[4] == 4
        println("C8 degrees (x1,x2,x3,w1,w2)=", expected, "; deg_w1=4")
    end
end
