"Build one fully materialized TB0 proof over the requested field."
function tb0_build_fixture(::Type{F}, d::Int,
                           tables::NTuple{5,NTuple{2,Int}},
                           budget::MonomialBudget) where {F<:GF2k}
    circuit = tb0_circuit()
    tf = tseitin(circuit).term
    farith = arith_q(tf, F, budget)
    farith isa ExpansionRefused && return farith
    gs = ntuple(i -> g_a(F[tables[i]...], tf.layout, (i,)).term, 5)
    c0 = build_c0(farith.term, gs, budget)
    c0 isa ExpansionRefused && return c0
    decomposition = zero_basis_decompose(c0.term, ntuple(identity, 16))
    proof = build_pcp(gs, c0.term, decomposition, d)
    (; circuit, tf, farith=farith.term, gs, c0=c0.term,
       decomposition=decomposition.term, proof=proof.term,
       certificate=proof.certificate)
end

function _tb0_encoding_report(::Type{F}, point_count::Int) where {F<:GF2k}
    layout1 = VarLayout((:x1,), (VarBlock(:X, 1:1),))
    points1 = F == GF8 ? [[x] for x in field_elements(F)] : begin
        rng = MersenneTwister(0x1d_1)
        [[F(rand(rng, 0:field_size(F)-1))] for _ in 1:point_count]
    end
    m1_ok = true
    for table in (F[0, 1], F[1, 0])
        extension = g_a(table, layout1, (1,)).term
        m1_ok &= all(point -> evaluate(extension, point) ==
                              sum(table .* ind(point); init=zero(F)), points1)
        m1_ok &= [evaluate(extension, F[bit]) for bit in 0:1] == table
        m1_ok &= dec(extension, (1,), F[0, 1]) == table
    end

    layout2 = VarLayout((:x1, :x2), (VarBlock(:X, 1:2),))
    table2 = F[0, 1, 1, 0]
    extension2 = g_a(table2, layout2, (1, 2)).term
    points2 = F == GF8 ?
        [[x, y] for x in field_elements(F) for y in field_elements(F)] : begin
            rng = MersenneTwister(0x1d_2)
            [[F(rand(rng, 0:field_size(F)-1)),
              F(rand(rng, 0:field_size(F)-1))] for _ in 1:point_count]
        end
    m2_ok = all(point -> evaluate(extension2, point) ==
                         sum(table2 .* ind(point); init=zero(F)), points2)
    m2_ok &= [evaluate(extension2, F[b1, b2])
              for b1 in 0:1 for b2 in 0:1] == table2
    m2_ok &= dec(extension2, (1, 2), F[0, 1]) == table2
    m2_ok &= structural_degrees(extension2) == (1, 1)
    m2_ok &= actual_degrees(extension2) == (1, 1)
    (; m1_ok, m2_ok, m1_points=2 * length(points1), m2_points=length(points2))
end

function tb0_encoding_report()
    (; gf8=_tb0_encoding_report(GF8, 8),
       gf2048=_tb0_encoding_report(GF2048, 512))
end

_tb0_bits(value, width) = [isodd(value >> (i - 1)) for i in 1:width]

function tb0_truth_report()
    circuit = tb0_circuit()
    present_clauses = Vector{Vector{Bool}}()
    circuit_ok = true
    for encoded in 0:2^10-1
        input = _tb0_bits(encoded, 10)
        expected = input[1] && input[6] && input[5]
        circuit_ok &= evaluate_circuit(circuit, input) == expected
        expected && push!(present_clauses, input)
    end
    satisfying = count(0:2^10-1) do encoded
        bits = _tb0_bits(encoded, 10)
        witness = ntuple(i -> Bool[bits[2i - 1], bits[2i]], 5)
        all(clause -> any(witness[i][Int(clause[i]) + 1] == clause[5 + i]
                          for i in 1:5), present_clauses)
    end
    chosen = (Bool[0, 1], Bool[0, 0], Bool[0, 0], Bool[0, 0], Bool[0, 0])

    tf = tseitin(circuit).term
    formula_ok = true
    arith_ok = true
    for input_index in 0:2^10-1
        input = _tb0_bits(input_index, 10)
        trace = gate_trace(circuit, input)
        circuit_value = trace[circuit.output.id]
        for wire_index in 0:2^6-1
            wires = _tb0_bits(wire_index, 6)
            assignment = vcat(input, wires)
            expected = wires == trace && circuit_value
            formula_ok &= evaluate_formula(tf, assignment) == expected
            field_assignment = GF8[bit ? one(GF8) : zero(GF8)
                                   for bit in assignment]
            arith_ok &= evaluate_arith_formula(tf, field_assignment) ==
                        (expected ? one(GF8) : zero(GF8))
        end
    end
    (; circuit_ok, present=length(present_clauses),
       absent=2^10 - length(present_clauses), satisfying,
       chosen_satisfies=phi_C(circuit, chosen), formula_ok, arith_ok,
       assignments=2^16)
end

function tb0_pcp_certificate_report(farith::Poly{GF8,16},
                                    gs::NTuple{5,Poly{GF8,16}},
                                    c0::Poly{GF8,16},
                                    decomposition::ZeroDecomposition{GF8,16},
                                    proof::PCPProof{GF8,16},
                                    certificate::CertNode)
    quotient_counts = map(monomial_count, decomposition.quotients)
    quotient_degrees = map(p -> maximum(actual_degrees(p); init=-1),
                           decomposition.quotients)
    (; local_dependencies=all(i -> dependency_coordinates(gs[i]) ⊆ Set((i,)),
                              1:5),
       g1_block=dependency_blocks(gs[1]),
       constant_tail=all(isempty(dependency_coordinates(gs[i])) for i in 2:5),
       degree_accounts=all(degree_accounts_valid,
                           (farith, c0, decomposition.quotients...)),
       quotient_degree_ok=all(degree -> degree <= proof.d, quotient_degrees),
       certificate_ok=passed(verify_certificate(Checked(proof, certificate))),
       quotient_counts, quotient_degrees,
       g_dependencies=map(dependency_coordinates, gs),
       farith_dependencies=dependency_coordinates(farith),
       c0_dependencies=dependency_coordinates(c0))
end

function tb0_lift_direct_report(source::PCPProof{GF8,16},
                                tables::NTuple{5,NTuple{2,Int}},
                                budget::MonomialBudget, count::Int,
                                seed::UInt64)
    lifted = lift_pcp(source, GF2048, 11)
    started = time_ns()
    direct = tb0_build_fixture(GF2048, 11, tables, budget)
    direct_seconds = (time_ns() - started) / 1.0e9
    direct isa ExpansionRefused && return direct
    agreement = pcp_agreement_report(lifted, direct.proof, count, seed)
    (; agreement, direct_seconds, support=monomial_count(direct.c0),
       peak_rss=Sys.maxrss())
end

function tb0_c8_report()
    circuit = c8_two_gate_circuit()
    tf = tseitin(circuit).term
    farith = arith_q(tf, GF8, MonomialBudget(160_000)).term
    occurrence = occurrences(tf.formula, 5)
    accounted = tseitin_occurrence_account(circuit)
    structural = structural_degrees(farith)
    actual = actual_degrees(farith)
    (; occurrence, accounted, structural, actual,
       bounded=all(actual .<= occurrence))
end

function tb0_print_degenerate_report(farith::Poly{GF8,16},
                                     gs::NTuple{5,Poly{GF8,16}},
                                     c0::Poly{GF8,16},
                                     decomposition::ZeroDecomposition{GF8,16},
                                     proof::PCPProof{GF8,16},
                                     certificate::CertNode,
                                     small_policy::ParameterPolicy,
                                     sampled_policy::ParameterPolicy,
                                     build_seconds::Float64,
                                     peak_rss::UInt64)
    report = tb0_pcp_certificate_report(farith, gs, c0, decomposition,
                                        proof, certificate)
    println("TB0 policy (P_shape,P_growth,P_formula_paper,P_tail,P_divisibility,P_degree): ",
            "small=", policy_vector(small_policy),
            "; sampled=", policy_vector(sampled_policy))
    println("TB0 P_formula_structural (separate extra): small=",
            small_policy.P_formula_structural,
            "; sampled=", sampled_policy.P_formula_structural)
    println("TB0 c0 normalized monomials=", monomial_count(c0),
            "; expected candidates=", expected_support(c0),
            "; multiplication peak=", multiplication_peak(c0),
            "; GF8 build seconds=", round(build_seconds; digits=3),
            "; peak RSS MiB=", round(peak_rss / 2.0^20; digits=1))
    println("TB0 dependency table: g=", report.g_dependencies,
            "; F_arith=", report.farith_dependencies,
            "; c0=", report.c0_dependencies)
    println("TB0 quotient table: monomials=", report.quotient_counts,
            "; max degrees=", report.quotient_degrees)
    println("TB0 quotient relation: c0=sum(j=1..16, c_j*zero(z_j)); ",
            "remainder=0; zero quotients=(2,3,4,7,8,9,10); ",
            "nonzero quotients=(1,5,6,11,12,13,14,15,16); max inddeg=6<=d")
    println("TB0 PCP equations: formula=true; zero=true; GF8 coordinate lines=16x8; ",
            "GF8 Boolean cube=65536; GF(2^11) seed=0x204810000 ",
            "samples=10000 + separators=16")
    traceprint(stdout, certificate)
    report
end

function tb0_degenerate_core_report(tf::TseitinFormula{16},
                                    farith::Poly{GF8,16},
                                    gs::NTuple{5,Poly{GF8,16}},
                                    c0::Poly{GF8,16},
                                    decomposition::ZeroDecomposition{GF8,16})
    small = parameter_policy(PCPParams(8, 3, 1, 6, 6, 16), 6)
    sampled = parameter_policy(PCPParams(2048, 11, 1, 11, 6, 16), 6)
    unit = constant_poly(GF8, tf.layout, 1)
    refused = mul_poly(farith, unit,
        MonomialBudget(monomial_count(farith) - 1)) isa ExpansionRefused
    zero_quotients = Set((2, 3, 4, 7, 8, 9, 10))
    quotient_split = all(i -> iszero(monomial_count(decomposition.quotients[i])) ==
                              (i in zero_quotients), 1:16)
    quotient_degree = maximum((maximum(actual_degrees(q); init=-1)
                               for q in decomposition.quotients); init=-1)
    rho = primitive_element(GF8)
    direct = evaluate_arith_formula(tf, tb0_base_point(GF8))
    (; small=policy_vector(small), sampled=policy_vector(sampled),
       small_exponent=small.P_exponent_range,
       structural=(small.P_formula_structural,
                   sampled.P_formula_structural),
       sampled_zero=sampled.P_zero, minimal_k=minimal_checkable_odd_k(6, 16),
       refused, expected=expected_support(c0),
       peak_ok=multiplication_peak(c0) <= 160_000,
       support_ok=monomial_count(c0) <= 148_176,
       remainder_zero=isempty(decomposition.remainder.terms),
       quotient_split, quotient_degree,
       base_value_ok=direct == rho^4 * (one(GF8) + rho) && !iszero(direct))
end

"Build witness (ii) once over Z, then reduce the formal coefficients mod 2."
function tb0_build_nondegenerate_fixture(d::Int,
                                         tables::NTuple{5,NTuple{2,Int}},
                                         budget::MonomialBudget)
    circuit = tb0_circuit()
    tf = tseitin(circuit).term
    farith_z = arith_q(tf, Int, budget)
    farith_z isa ExpansionRefused && return farith_z
    started = time_ns()
    gs_z = ntuple(i -> g_a(Int[tables[i]...], tf.layout, (i,)).term, 5)
    c0_z = build_c0(farith_z.term, gs_z, budget)
    c0_z isa ExpansionRefused && return c0_z
    integer_seconds = (time_ns() - started) / 1.0e9
    integer_report =
        (; support=monomial_count(c0_z.term),
           expected=expected_support(c0_z.term),
           multiplication_peak=multiplication_peak(c0_z.term),
           seconds=integer_seconds, peak_rss=Sys.maxrss())

    farith = change_field(farith_z.term, GF8)
    gs = ntuple(i -> change_field(gs_z[i], GF8), 5)
    c0 = change_field(c0_z.term, GF8)
    decomposition = zero_basis_decompose(c0, ntuple(identity, 16))
    proof = build_pcp(gs, c0, decomposition, d)
    fixture = (; circuit, tf, farith, gs, c0,
                decomposition=decomposition.term, proof=proof.term,
                certificate=proof.certificate)
    (; fixture, integer_report)
end

function tb0_base_point(::Type{F}) where {F<:GF2k}
    rho = primitive_element(F)
    point = fill(zero(F), 16)
    point[6:10] .= one(F)
    point[11] = rho
    point[16] = rho
    point
end

function _pcp_report(tf, proof, points)
    formula_ok = true
    zero_ok = true
    count = 0
    for point in points
        result = pcpverifier(tf, ev_z(proof, point))
        formula_ok &= result.formula_ok
        zero_ok &= result.zero_ok
        count += 1
    end
    (; formula_ok, zero_ok, count)
end

function pcp_coordinate_line_report(tf::TseitinFormula{16},
                                    proof::PCPProof{F,16},
                                    base::Vector{F}) where {F<:GF2k}
    points = (begin
                  point = copy(base)
                  point[j] = value
                  point
              end
              for j in 1:16 for value in field_elements(F))
    _pcp_report(tf, proof, points)
end

function pcp_seeded_report(tf::TseitinFormula{16}, proof,
                           ::Type{F}, count::Int, seed::UInt64) where {F<:GF2k}
    rng = MersenneTwister(seed)
    points = ([F(rand(rng, 0:field_size(F)-1)) for _ in 1:16]
              for _ in 1:count)
    _pcp_report(tf, proof, points)
end

function pcp_seeded_pair_report(
        tf::TseitinFormula{16},
        degenerate::PrimeFieldPCPProof{GF2048,GF8,16},
        nondegenerate::PrimeFieldPCPProof{GF2048,GF8,16},
        count::Int, seed::UInt64)
    rng = MersenneTwister(seed)
    degenerate_ok = true
    nondegenerate_ok = true
    for _ in 1:count
        point = [GF2048(rand(rng, 0:2047)) for _ in 1:16]
        degenerate_ok &= passed(pcpverifier(tf, ev_z(degenerate, point)))
        nondegenerate_ok &= passed(pcpverifier(tf, ev_z(nondegenerate, point)))
    end
    separator_ok = true
    base = tb0_base_point(GF2048)
    rho = primitive_element(GF2048)
    for j in 1:16
        point = copy(base)
        point[j] = j == 7 ? rho : rho + one(GF2048)
        separator_ok &= passed(pcpverifier(tf, ev_z(degenerate, point)))
    end
    (; degenerate_ok, nondegenerate_ok, separator_ok, count)
end

function pcp_boolean_cube_report(tf::TseitinFormula{16},
                                 proof::PCPProof{GF8,16})
    points = (GF8[isodd(index >> (i - 1)) for i in 1:16]
              for index in 0:2^16-1)
    # On the Boolean cube every z_i(1-z_i) is zero, so the verifier's
    # quotient-weighted RHS is identically zero.  Avoid the redundant 16
    # quotient evaluations while still evaluating every g_i and c0 and
    # invoking the unmodified verifier at every point.
    formula_ok = true
    zero_ok = true
    count = 0
    for point in points
        alpha = ntuple(i -> evaluate(proof.gs[i], point), 5)
        beta0 = evaluate(proof.c0, point)
        view = PCPView(point, alpha, beta0, ntuple(_ -> zero(GF8), 16))
        result = pcpverifier(tf, view)
        formula_ok &= result.formula_ok
        zero_ok &= result.zero_ok
        count += 1
    end
    (; formula_ok, zero_ok, count)
end

function pcp_agreement_report(lifted::PrimeFieldPCPProof{F,S,N},
                              direct::PCPProof{F,N}, count::Int,
                              seed::UInt64) where {F,S,N}
    rng = MersenneTwister(seed)
    agreed = true
    for _ in 1:count
        point = [F(rand(rng, 0:field_size(F)-1)) for _ in 1:N]
        lifted_view = ev_z(lifted, point)
        direct_view = ev_z(direct, point)
        agreed &= (lifted_view.alpha, lifted_view.beta0, lifted_view.beta) ==
                  (direct_view.alpha, direct_view.beta0, direct_view.beta)
    end
    (; agreed, count)
end

function tb0_layout_m2_report()
    names = (:X1a, :X1b, :X2a, :X2b, :X3a, :X3b, :X4a, :X4b,
             :X5a, :X5b, :O1, :O2, :O3, :O4, :O5)
    blocks = (VarBlock(:X1, 1:2), VarBlock(:X2, 3:4),
              VarBlock(:X3, 5:6), VarBlock(:X4, 7:8),
              VarBlock(:X5, 9:10), VarBlock(:O, 11:15))
    layout = VarLayout(names, blocks)
    formula = FAnd(Lit(1), FNot(Lit(1)))
    tf = TseitinFormula(formula, blocks[1:5], layout, (formula,), 1,
                        occurrences(formula, 15), _compile_formula(formula))
    farith = zero(layout, 1, GF8)
    gs = ntuple(_ -> zero_poly(GF8, layout), 5)
    c0 = build_c0(farith, gs, MonomialBudget(100)).term
    decomposition = zero_basis_decompose(c0, ntuple(identity, 15))
    proof = build_pcp(gs, c0, decomposition, 1).term
    point = ones(GF8, 15)
    point[1] = primitive_element(GF8)
    point[6] = zero(GF8) # old hard-coded 6:10 sign lookup would reject
    (; sign_coordinates=block_coordinates(layout, :O),
       c0_nonzero=!iszero(evaluate(c0, point)),
       verifier=pcpverifier(tf, ev_z(proof, point)))
end
