# DESIGN.md sections 1.2 and 2: decouple5(x::Succinct3SAT) :: Checked{
# SuccinctDecoupled5SAT, DecoupleCert} and the padded specialisation
# (DD-17). The paper's decoupled clause (gt-10:920-979) reads one addressed
# literal from each of a, b, w_1, w_2, w_3. Following gt-10:1036-1130 and
# the analytic part2b 11.3: each 3SAT clause's first, second and third
# literal go to blocks 3, 4, 5; copy gadgets tie the answer blocks 1, 2 to
# their copies in block 3; equality gadgets u_3 = u_4 = u_5 are emitted for
# every variable that occurs in more than one slot (a variable living in one
# slot needs no copy: satisfiability is unchanged). Answer blocks are read as
# raw bits (ASSUMED leaf): the paper's enc_Gamma format and (10)^(L/2-T)
# blank padding clauses are not emitted on these fixtures.

struct Clause5
    slots::NTuple{5,Union{Nothing,Tuple{Int,Bool}}}
end

struct SuccinctDecoupled5SAT
    index_widths::NTuple{5,Int}
    sign_count::Int
    clauses::Vector{Clause5}
    formula_clauses::Int
    copy_gadgets::Int
    equality_gadgets::Int
    u_index::Vector{Int}
    circuit::Circuit
    source::Succinct3SAT
end

struct PaddedSuccinctDecoupled5SAT
    m::Int
    s::Int
    live_gates::Int
    m_prime::Int
    circuit::Circuit
    clauses::Vector{Clause5}
    source::SuccinctDecoupled5SAT
end

_widths5(d::SuccinctDecoupled5SAT) = d.index_widths
_widths5(p::PaddedSuccinctDecoupled5SAT) = ntuple(_ -> p.m, 5)
_slot_block(k::Int) = 2 + k

"def:decoupled-5sat: C(i1..i5, o1..o5) = 1 iff the decoupled clause is present."
clause_present5(d::Union{SuccinctDecoupled5SAT,PaddedSuccinctDecoupled5SAT}, indices::Tuple, signs::Tuple) =
    any(template -> _template_matches(template.slots, indices, signs), d.clauses)
relation_input(d::Union{SuccinctDecoupled5SAT,PaddedSuccinctDecoupled5SAT}, indices::Tuple, signs::Tuple) =
    relation_input(_widths5(d), 5, indices, signs)

"Blocks in which the 3SAT-derived (non-gadget) literals land."
function literal_blocks(d::SuccinctDecoupled5SAT)
    blocks = Set{Int}()
    for template in d.clauses[1:d.formula_clauses], (k, slot) in enumerate(template.slots)
        slot === nothing || push!(blocks, k)
    end
    blocks
end

function _decouple_templates(f::Succinct3SAT)
    answer = f.answer_variables
    retained = maximum(vcat([abs(slot[1]) for t in f.clauses for slot in t.slots if slot !== nothing], 0))
    # u-block numbering: 0 = padding, used answer copies (a then b), then
    # the remaining variables in order (w = (a_1, b_1, c) of gt-10:1100).
    u_index = zeros(Int, max(retained, 1))
    next = 0
    used_a = [(j, v) for (j, v) in enumerate(answer.a) if v > 0]
    used_b = [(j, v) for (j, v) in enumerate(answer.b) if v > 0]
    for (_, v) in vcat(used_a, used_b)
        u_index[v] = (next += 1)
    end
    for v in 1:retained
        u_index[v] == 0 && (u_index[v] = (next += 1))
    end
    n_u = _code_width(next + 1)
    wa, wb = length(answer.a), length(answer.b)
    widths = (_code_width(wa), _code_width(wb), n_u, n_u, n_u)

    templates = Clause5[]
    slots_of = Dict{Int,Set{Int}}()
    for template in f.clauses
        slots = Any[nothing, nothing, nothing, nothing, nothing]
        for (k, slot) in enumerate(template.slots)
            slot === nothing && continue
            v, sign = slot
            slots[_slot_block(k)] = (u_index[v], sign)
            push!(get!(slots_of, v, Set{Int}()), k)
        end
        push!(templates, Clause5(Tuple(slots)))
    end
    formula_count = length(templates)
    for (j, v) in used_a, o in (false, true)
        push!(templates, Clause5(((j - 1, o), nothing, (u_index[v], !o), nothing, nothing)))
        push!(get!(slots_of, v, Set{Int}()), 1)
    end
    for (j, v) in used_b, o in (false, true)
        push!(templates, Clause5((nothing, (j - 1, o), (u_index[v], !o), nothing, nothing)))
        push!(get!(slots_of, v, Set{Int}()), 1)
    end
    copies = length(templates) - formula_count
    for v in sort!(collect(keys(slots_of)))
        length(slots_of[v]) >= 2 || continue
        u = u_index[v]
        for o in (false, true)
            push!(templates, Clause5((nothing, nothing, (u, o), (u, !o), nothing)))
            push!(templates, Clause5((nothing, nothing, nothing, (u, o), (u, !o))))
        end
    end
    equalities = length(templates) - formula_count - copies
    (; templates, widths, u_index, formula_count, copies, equalities)
end

function _build_decoupled(f::Succinct3SAT; gate_budget::Int=4096)
    built = _decouple_templates(f)
    circuit = compile_relation(built.templates, built.widths, 5; prefix=:X, gate_budget)
    circuit isa CompilationRefused && return circuit
    SuccinctDecoupled5SAT(built.widths, 5, built.templates, built.formula_count,
                          built.copies, built.equalities, built.u_index, circuit, f)
end

# Block-variable ids of a decoupled relation: block k index i => offset + i + 1.
function _block_offsets(widths::Tuple)
    offsets = zeros(Int, length(widths) + 1)
    for k in eachindex(widths)
        offsets[k + 1] = offsets[k] + (1 << widths[k])
    end
    offsets
end

function _decoupled_clauses(clauses::Vector{Clause5}, widths::Tuple)
    offsets = _block_offsets(widths)
    Vector{Int}[Int[(slot[2] ? 1 : -1) * (offsets[k] + slot[1] + 1)
                    for (k, slot) in enumerate(template.slots) if slot !== nothing]
                for template in clauses]
end

function _answer_block_units(widths::Tuple, input::Tuple)
    offsets = _block_offsets(widths)
    units = Vector{Int}[]
    for (block, bits) in ((1, input[4]), (2, input[5]))
        for (j, bit) in enumerate(bits)
            j <= (1 << widths[block]) || throw(ArgumentError("answer longer than its block"))
            v = offsets[block] + j
            push!(units, [bit ? v : -v])
        end
    end
    units
end

"Exists (w_1, w_2, w_3) [and free answer padding] with (a, b, w) satisfying phi_5 (DPLL)."
satisfiable5(d::Union{SuccinctDecoupled5SAT,PaddedSuccinctDecoupled5SAT}, input::Tuple) =
    dpll(vcat(_decoupled_clauses(d.clauses, _widths5(d)), _answer_block_units(_widths5(d), input)))

"(a, b, w_1, w_2, w_3) satisfies every present decoupled clause; blocks 1, 2 must carry the input's a, b."
function satisfies5(d::Union{SuccinctDecoupled5SAT,PaddedSuccinctDecoupled5SAT}, input::Tuple,
                    w::NTuple{5,<:AbstractVector{Bool}})
    widths = _widths5(d)
    all(length(w[k]) == 1 << widths[k] for k in 1:5) ||
        throw(ArgumentError("witness blocks must have length 2^n_k"))
    (w[1][1:length(input[4])] == input[4] && w[2][1:length(input[5])] == input[5]) || return false
    for (indices, signs) in relation_tuples(widths, 5)
        clause_present5(d, indices, signs) || continue
        any(w[k][indices[k] + 1] == signs[k] for k in 1:5) || return false
    end
    true
end

function _replay_decouple5(d::SuccinctDecoupled5SAT)
    rebuilt = _decouple_templates(d.source)
    (rebuilt.templates == d.clauses && rebuilt.widths == d.index_widths &&
     rebuilt.formula_count == d.formula_clauses && rebuilt.copies == d.copy_gadgets &&
     rebuilt.equalities == d.equality_gadgets) ||
        return CheckResult(false, :decouple_reconstruction;
                           expected=length(rebuilt.templates), actual=length(d.clauses))
    # Shape: five index blocks of the declared widths and five sign bits
    # as structural fields of the circuit; 3SAT literals only in blocks
    # 3..5; blocks 1, 2 only in copy gadgets.
    layout = d.circuit.input_layout
    shape_ok = length(layout.blocks) == 6 && d.sign_count == 5 &&
               all(length(layout.blocks[k].coordinates) == d.index_widths[k] for k in 1:5) &&
               layout.blocks[6].name == :O && length(layout.blocks[6].coordinates) == 5 &&
               literal_blocks(d) <= Set(3:5)
    for template in d.clauses[d.formula_clauses + 1:d.formula_clauses + d.copy_gadgets]
        fixed = [k for (k, slot) in enumerate(template.slots) if slot !== nothing]
        shape_ok &= length(fixed) == 2 && fixed[2] == 3 && fixed[1] in (1, 2)
    end
    shape_ok || return CheckResult(false, :decoupled_shape; expected=:five_blocks_five_signs,
                                   actual=(blocks=length(layout.blocks), literal_blocks=literal_blocks(d)))
    ok, mode, count = _check_relation(d.circuit, (i, s) -> clause_present5(d, i, s), d.index_widths, 5)
    ok || return CheckResult(false, :relation_circuit; expected=mode, actual=count)
    trace = d.source.trace
    for input in _answer_inputs(trace.input)
        accepts = _trace_term(trace.program, input, trace.T).accepts
        satisfiable5(d, input) == accepts ||
            return CheckResult(false, :decoupled_guarantee; location=(input[4], input[5]),
                               expected=accepts, actual=!accepts)
    end
    CheckResult(true, :decouple5_replay; expected=mode, actual=count)
end

"decouple5(x::Succinct3SAT) :: Checked{SuccinctDecoupled5SAT, DecoupleCert} (DESIGN 2)."
function decouple5(sat3::Checked{Succinct3SAT}; gate_budget::Int=4096)
    d = _build_decoupled(sat3.term; gate_budget)
    d isa CompilationRefused && return d
    raw = CertNode(ASSUMED, :RawAnswerBlocks;
        facts=(display="answer blocks read as raw bits of widths $(length(sat3.term.answer_variables.a)), $(length(sat3.term.answer_variables.b)); enc_Gamma format and (10)^(L/2-T) padding clauses of gt-10:1036-1130 not emitted; (4) C19's 2F reserved bits per answer block not reserved",))
    # verdicts/tb3-r1.md N8: prop:explicit-succinct-deciders (gt-10:1046-1060)
    # emits the equality pair for EVERY index; this fixture emits it only
    # for variables occurring in >= 2 slots (satisfiability-preserving: a
    # single-slot variable needs no copy).
    multi = sum(length(slots) >= 2 for slots in values(_slots_of(d)); init=0)
    omitted = CertNode(ASSUMED, :PerIndexEqualityGadgets;
        facts=(display="equality gadgets u_3 = u_4 = u_5 emitted for the $(multi) multi-slot variables only; the per-index pairs (i_3 = i_4, o_3 != o_4) and (i_4 = i_5, o_4 != o_5) of gt-10:1046-1060 are omitted for the $((1 << d.index_widths[3]) - multi) remaining indices of the u-blocks (satisfiability unchanged: a single-slot variable is read once)",))
    _, mode, count = _check_relation(d.circuit, (i, s) -> clause_present5(d, i, s), d.index_widths, 5)
    node = CertNode(CHECKED, :Decouple5;
        facts=(display="widths = $(d.index_widths); clauses = $(length(d.clauses)) (formula $(d.formula_clauses), copy $(d.copy_gadgets), equality $(d.equality_gadgets)); circuit gates = $(d.circuit.gate_count); relation check = $(mode) ($(count)); fnv1a64 = $(quote_hash(sat3.term.trace.program))",),
        children=(_relocate(sat3.certificate, x -> x isa SuccinctDecoupled5SAT ? x.source : nothing), raw, omitted),
        replay=_bound_replay(d, :Decouple5, _replay_decouple5))
    Checked(d, node)
end

# Slots (1 = a-copy, 2 = b-copy, k = 3SAT literal k) in which each retained
# 3SAT variable occurs, as used for the equality-gadget decision.
function _slots_of(d::SuccinctDecoupled5SAT)
    slots_of = Dict{Int,Set{Int}}()
    for template in d.source.clauses, (k, slot) in enumerate(template.slots)
        slot === nothing || push!(get!(slots_of, slot[1], Set{Int}()), k)
    end
    answer = d.source.answer_variables
    for v in vcat(answer.a, answer.b)
        v > 0 && push!(get!(slots_of, v, Set{Int}()), 1)
    end
    slots_of
end

# ---------------------------------------------------------------------------
# Padding (prop:explicit-padded-succinct-deciders, gt-10:1226-1246): equal
# m-bit blocks with 2^m >= 2T (obligation 1), and a gate count s with
# 5m + 5 + s a power of two. The padding gates are DEAD: a NOT chain
# dangling off the output, the output itself unchanged, so they add Tseitin
# variables but nothing to C.

_padded_width(d::SuccinctDecoupled5SAT) =
    max(maximum(d.index_widths), _code_width(2 * d.source.trace.T))

function _build_padded(d::SuccinctDecoupled5SAT; gate_budget::Int=4096)
    m = _padded_width(d)
    widths = ntuple(_ -> m, 5)
    live = compile_relation(d.clauses, widths, 5; prefix=:X, gate_budget)
    live isa CompilationRefused && return live
    total = 5m + 5 + live.gate_count
    m_prime = nextpow(2, total)
    s = m_prime - 5m - 5
    gates = BGate[live.gates...]
    previous = live.output
    for _ in 1:(s - live.gate_count)
        push!(gates, NotGate(previous))
        previous = Gate(length(gates))
    end
    circuit = Circuit(live.input_layout, Tuple(gates), live.output)
    PaddedSuccinctDecoupled5SAT(m, s, live.gate_count, m_prime, circuit, d.clauses, d)
end

function _replay_pad5(p::PaddedSuccinctDecoupled5SAT)
    rebuilt = _build_padded(p.source)
    rebuilt isa CompilationRefused &&
        return CheckResult(false, :pad_reconstruction; expected=:circuit, actual=rebuilt)
    (rebuilt.m == p.m && rebuilt.s == p.s && rebuilt.live_gates == p.live_gates &&
     rebuilt.m_prime == p.m_prime && rebuilt.clauses == p.clauses) ||
        return CheckResult(false, :pad_reconstruction; expected=(rebuilt.m, rebuilt.s),
                           actual=(p.m, p.s))
    layout = p.circuit.input_layout
    T = p.source.source.trace.T
    shape_ok = ispow2(p.m_prime) && p.m_prime == 5p.m + 5 + p.s &&
               p.circuit.gate_count == p.s && p.m == _padded_width(p.source) &&
               (1 << p.m) >= 2T &&
               all(length(layout.blocks[k].coordinates) == p.m for k in 1:5) &&
               length(layout.names) == 5p.m + 5
    shape_ok || return CheckResult(false, :padded_shape;
                                   expected=(m=p.m, s=p.s, m_prime=5p.m + 5 + p.s, two_T=2T),
                                   actual=(gates=p.circuit.gate_count, m_prime=p.m_prime, two_to_m=1 << p.m))
    ok, mode, count = _check_relation(p.circuit, (i, s) -> clause_present5(p.source, i, s), _widths5(p), 5)
    ok || return CheckResult(false, :relation_circuit; expected=mode, actual=count)
    CheckResult(true, :pad5_replay; expected=mode, actual=count)
end

"pad5(d) :: Checked{PaddedSuccinctDecoupled5SAT, PadCert}: DD-17's explicitly padded specialisation."
function pad5(sat5::Checked{SuccinctDecoupled5SAT}; gate_budget::Int=4096)
    p = _build_padded(sat5.term; gate_budget)
    p isa CompilationRefused && return p
    _, mode, count = _check_relation(p.circuit, (i, s) -> clause_present5(p.source, i, s), _widths5(p), 5)
    T = sat5.term.source.trace.T
    node = CertNode(CHECKED, :Pad5;
        facts=(display="m = $(p.m) (2^m = $(1 << p.m) >= 2T = $(2T)); s = $(p.s) (live $(p.live_gates), padding $(p.s - p.live_gates) dead NOT gates off the unchanged output); m' = 5m + 5 + s = $(p.m_prime); relation check = $(mode) ($(count)); fnv1a64 = $(quote_hash(p.source.source.trace.program))",),
        children=(_relocate(sat5.certificate, x -> x isa PaddedSuccinctDecoupled5SAT ? x.source : nothing),),
        replay=_bound_replay(p, :Pad5, _replay_pad5))
    Checked(p, node)
end

# The upstream-evidence hook of build_pcp (src/verifiers/pcp.jl): the
# padded object's circuit is what the proof's Tseitin formula was built from.
upstream_circuit(p::PaddedSuccinctDecoupled5SAT) = p.circuit

# ---------------------------------------------------------------------------
# Witness tables and the PCP graft.

function _tables_satisfy(p::PaddedSuccinctDecoupled5SAT, tables::NTuple{5,<:Tuple})
    for (indices, signs) in relation_tuples(_widths5(p), 5)
        clause_present5(p.source, indices, signs) || continue
        any(tables[k][indices[k] + 1] == Int(signs[k]) for k in 1:5) || return false
    end
    true
end

"Witness tables for the padded relation: all-nonconstant (index parity) or its greedy zeroing."
function frontend_witness_tables(p::PaddedSuccinctDecoupled5SAT; nondegenerate::Bool)
    size = 1 << p.m
    parity = ntuple(_ -> ntuple(i -> (i - 1) & 1, size), 5)
    _tables_satisfy(p, parity) ||
        throw(ArgumentError("the index-parity witness does not satisfy the generated relation"))
    nondegenerate && return parity
    tables = parity
    for k in 1:5
        trial = Base.setindex(tables, ntuple(_ -> 0, size), k)
        _tables_satisfy(p, trial) && (tables = trial)
    end
    tables
end

"Candidate counts of F_arith (6 per NOT, 7 per AND/OR gadget) and of c_0 (five binomial factors)."
function frontend_c0_estimate(p::PaddedSuccinctDecoupled5SAT)
    farith = prod(BigInt(gate isa NotGate ? 6 : 7) for gate in p.circuit.gates)
    (; farith, c0=farith * BigInt(2)^5)
end

"""
    frontend_pcp(padded, F, d, tables, budget, certified_points)

TB0's PCP pipeline (tseitin, arith_q, g_a, build_c0, zero_basis_decompose,
build_pcp) on the GENERATED circuit, with the front-end certificate passed
through `build_pcp`'s upstream-evidence slot (bound to the proof's Tseitin
formula, verdicts/tb3-r1.md N2) so the quote hash and |D| propagate into the
PCP certificate. A borrowed front-end certificate is refused there with
`ArgumentError` naming `:certificate_binding` at its front-end node, before
any PCP certificate exists. Returns the same fields as `build_pcp_fixture`.
"""
function frontend_pcp(padded::Checked{PaddedSuccinctDecoupled5SAT}, ::Type{F}, d::Int,
                      tables::NTuple{5,<:Tuple}, budget::MonomialBudget,
                      certified_points::Tuple) where {F<:GF2k}
    circuit = padded.term.circuit
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
    proof = build_pcp(tf, gs, c0_checked.term, decomposition, d, certified_points, evidence;
                      upstream=(padded,))
    (; circuit, tf, farith=farith_checked.term, gs, c0=c0_checked.term,
       decomposition=decomposition.term, proof=proof.term, certificate=proof.certificate)
end
