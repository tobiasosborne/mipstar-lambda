function tb0_base_point(::Type{F}) where {F<:GF2k}
    rho = primitive_element(F)
    point = fill(zero(F), 16)
    point[6:10] .= one(F)
    point[11] = rho
    point[16] = rho
    point
end

function _tb0_certified_points(::Type{F}) where {F<:GF2k}
    separator = tb0_base_point(F)
    separator[7] = primitive_element(F)
    (separator,)
end

"Build one fully materialized TB0 proof over the requested field."
function tb0_build_fixture(::Type{F}, d::Int,
                           tables::NTuple{5,NTuple{2,Int}},
                           budget::MonomialBudget) where {F<:GF2k}
    circuit = tb0_circuit()
    tf_checked = tseitin(circuit)
    tf = tf_checked.term
    farith_checked = arith_q(tf, F, budget)
    farith_checked isa ExpansionRefused && return farith_checked
    gs_checked = ntuple(i -> g_a(F[tables[i]...], tf.layout, (i,)), 5)
    gs = map(checked -> checked.term, gs_checked)
    c0_checked = build_c0(farith_checked.term, gs, budget)
    c0_checked isa ExpansionRefused && return c0_checked
    decomposition = zero_basis_decompose(c0_checked.term, ntuple(identity, 16))
    evidence = (tf_checked, farith_checked, gs_checked..., c0_checked, decomposition)
    proof = build_pcp(tf, gs, c0_checked.term, decomposition, d,
                      _tb0_certified_points(F), evidence)
    (; circuit, tf, farith=farith_checked.term, gs, c0=c0_checked.term,
       decomposition=decomposition.term, proof=proof.term,
       certificate=proof.certificate)
end

"Build witness (ii) directly over GF(8); the critic owns the separate Z count."
function tb0_build_nondegenerate_fixture(d::Int,
                                         tables::NTuple{5,NTuple{2,Int}},
                                         budget::MonomialBudget)
    started = time_ns()
    fixture = tb0_build_fixture(GF8, d, tables, budget)
    fixture isa ExpansionRefused && return fixture
    build_seconds = (time_ns() - started) / 1.0e9
    reference_report = (; support=788_032, source=:critic,
                         seconds=build_seconds, peak_rss=Sys.maxrss())
    (; fixture, integer_report=reference_report)
end
