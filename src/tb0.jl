function tb0_base_point(::Type{F}) where {F<:GF2k}
    rho = primitive_element(F)
    point = fill(zero(F), 16)
    point[6:10] .= one(F)
    point[11] = rho
    point[16] = rho
    point
end

"The TB0 certified points: the mutation-B separator `b_rho[O2 <- rho]`."
function tb0_certified_points(::Type{F}) where {F<:GF2k}
    separator = tb0_base_point(F)
    separator[7] = primitive_element(F)
    (separator,)
end

"""
    build_pcp_fixture(circuit, F, d, tables, budget, certified_points)

Build one fully materialized PCP proof for `circuit` over `F`: Tseitin,
arithmetization, the five witness tables extended over the layout's `X_i`
blocks (each table has `2^m` entries for an `m`-coordinate block), `c_0`, its
zero-basis decomposition over every coordinate, and the certificate tree. Every
block lookup is layout-driven, so the same pipeline serves the `m=1` TB0
circuit and the `m=2` layout regression.
"""
function build_pcp_fixture(circuit::Circuit, ::Type{F}, d::Int,
                           tables::NTuple{5,<:Tuple}, budget::MonomialBudget,
                           certified_points::Tuple) where {F<:GF2k}
    tf_checked = tseitin(circuit)
    tf = tf_checked.term
    variable_count = length(tf.layout.names)
    farith_checked = arith_q(tf, F, budget)
    farith_checked isa ExpansionRefused && return farith_checked
    gs_checked = ntuple(5) do i
        coordinates = Tuple(block_coordinates(tf.layout, Symbol("X", i)))
        length(tables[i]) == 1 << length(coordinates) ||
            throw(ArgumentError("witness table $i must have 2^$(length(coordinates)) entries"))
        g_a(F[tables[i]...], tf.layout, coordinates)
    end
    gs = map(checked -> checked.term, gs_checked)
    c0_checked = build_c0(farith_checked.term, gs, budget)
    c0_checked isa ExpansionRefused && return c0_checked
    decomposition = zero_basis_decompose(c0_checked.term, 1:variable_count)
    evidence = (tf_checked, farith_checked, gs_checked..., c0_checked, decomposition)
    proof = build_pcp(tf, gs, c0_checked.term, decomposition, d,
                      certified_points, evidence)
    (; circuit, tf, farith=farith_checked.term, gs, c0=c0_checked.term,
       decomposition=decomposition.term, proof=proof.term,
       certificate=proof.certificate)
end

"""
    layout_m2_circuit()

The `m=2` layout regression: five two-coordinate input blocks `X1..X5`, the
sign block `O` at coordinates 11:15 (where the `m=1` TB0 constant `6:10`
reads `X3b..X5b`), and three gates `w1 = x1a AND o1`, `w2 = NOT o2`,
`w3 = w1 AND w2` (output). Every present clause has `o1 = 1`, so the all-ones
table on block 1 (`LAYOUT_M2_TABLES`) satisfies the clause relation and its
`c_0` vanishes on the Boolean cube.
"""
function layout_m2_circuit()
    names = (:X1a, :X1b, :X2a, :X2b, :X3a, :X3b, :X4a, :X4b,
             :X5a, :X5b, :O1, :O2, :O3, :O4, :O5)
    blocks = (VarBlock(:X1, 1:2), VarBlock(:X2, 3:4),
              VarBlock(:X3, 5:6), VarBlock(:X4, 7:8),
              VarBlock(:X5, 9:10), VarBlock(:O, 11:15))
    layout = VarLayout(names, blocks)
    gates = (AndGate(Input(:X1, 1, 1), Input(:O, 1, 11)),
             NotGate(Input(:O, 2, 12)), AndGate(Gate(1), Gate(2)))
    Circuit(layout, gates, Gate(3))
end

const LAYOUT_M2_TABLES = ((1, 1, 1, 1), (0, 0, 0, 0), (0, 0, 0, 0),
                          (0, 0, 0, 0), (0, 0, 0, 0))

"A point off the cube for `layout_m2_circuit`: every `g_i - o_i` and `F_arith` nonzero."
function layout_m2_point(::Type{F}) where {F<:GF2k}
    rho = primitive_element(F)
    point = zeros(F, 18)
    point[1] = rho
    point[11:15] .= F[0, 1, 1, 1, 1]
    point[16:18] .= F[rho, rho, 1]
    point
end

"Build one fully materialized TB0 proof over the requested field."
tb0_build_fixture(::Type{F}, d::Int, tables::NTuple{5,NTuple{2,Int}},
                  budget::MonomialBudget) where {F<:GF2k} =
    build_pcp_fixture(tb0_circuit(), F, d, tables, budget, tb0_certified_points(F))

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
