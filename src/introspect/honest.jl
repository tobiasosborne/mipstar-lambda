# TB6 (DESIGN 11.5): the honest introspection strategy S^intro_n on the
# exact stabilizer tableau (gt-08-introspection.tex:L1070-L1172, fig:intro-honest
# L1002-L1050) for a deterministic-child fixture (DD-27): every measurement
# is a commuting Pauli family on the player's half of |EPR_2>^{(x)(Q+1)};
# the auxiliary register is classical because the child's value-1 strategy
# is deterministic. The input verifier's CL functions are reached ONLY
# through the four sampler queries (unmetered here: the players are not
# budgeted). Pauli-typed questions follow lem:pauli-completeness
# (gt-07-ldt.tex:L1232-L1330) with the Magic-Square operator solution of
# thm:ms-from-ac (L659-L760).

struct IntroInstance
    hat::SamplerDescription          # hat S^intro (typed, F_2)
    detyped::SamplerDescription      # S^intro (untyped, level 5)
    typed_decider::DeciderDescription
    decider::DeciderDescription      # the detyped D^intro
    S::SamplerDescription            # the input verifier's sampler
    D::DeciderDescription
    n::Int
    N::Int
    lambda::Int
    ell::Int
    params::PauliParams
    Q::Int
    s::Int
    child_honest::Function           # (role::Symbol, y::Vector{Bool}) -> a::Vector{Bool}
end
_qubits(inst::IntroInstance, w::Symbol, coordinates) = (w == :alice ? 0 : inst.Q + 1) .+ collect(coordinates)
_extra_qubit(inst::IntroInstance, w::Symbol) = (w == :alice ? 0 : inst.Q + 1) + inst.Q + 1

# The register V_j(prefix) and the matrix of L_{j,prefix} in its basis, through the four queries.
function _honest_stage(inst::IntroInstance, role::Symbol, j::Int, prefix::AbstractVector{Bool})
    indicator = _raise(Factor(inst.S, inst.N, role, j, _gf2(prefix)))
    register = findall(==(1), indicator)
    r = length(register)
    M = Matrix{GF2}(undef, r, r)
    for (i, h) in enumerate(register)
        e = falses(inst.s)
        e[h] = true
        column = _raise(Linear(inst.S, inst.N, role, j, _gf2(prefix), _gf2(e)))
        M[:, i] = column[register]
    end
    (register, M)
end
# The X-string tau^X(v) / Z-string tau^Z(v) of v in F_q^M on the player's Q qubits (lem:pauli-binary).
function _pauli_of(inst::IntroInstance, w::Symbol, W::Symbol, v::AbstractVector)
    bits = kappa_bits(v, inst.params.basis)
    support = _qubits(inst, w, findall(bits))
    n = 2 * (inst.Q + 1)
    W == :X ? pauli_string(n; xs=support) : pauli_string(n; zs=support)
end

"The honest answer of player w to the typed question (t, x_bits) on the shared tableau."
function honest_answer!(inst::IntroInstance, tab::StabilizerTableau, w::Symbol, t::String, x::AbstractVector{Bool}, choose::Function)
    p = inst.params
    Q, s = inst.Q, inst.s
    kind, arg = parse_type_label(t)
    n_qubits = 2 * (Q + 1)
    if is_pauli_label(t)
        q = parse_pauli_question(p, x)
        q === nothing && throw(ArgumentError("a Pauli-typed question must be a downsized V^pauli vector"))
        if kind == :Pauli
            return plain_measure!(tab, Symbol(arg), _qubits(inst, w, 1:Q), choose)
        elseif kind in (:Point, :ALine, :DLine)
            W = arg
            bits = plain_measure!(tab, Symbol(W), _qubits(inst, w, 1:Q), choose)
            h = kappa_fields(bits, p.basis)                              # the tau^W outcome in F_q^M
            F = _pfield(p)
            kind == :Point && return kappa_bits(ld_encoding_value(h, W == "X" ? q.u_x : q.u_z), p.basis)
            layout = VarLayout(Tuple(Symbol("x", i) for i in 1:p.tuple.m), (VarBlock(:Point, 1:p.tuple.m),))
            g = g_a(h, layout, Tuple(1:p.tuple.m)).term
            line = kind == :ALine ? axis_line(_ld_question(q, W), p.tuple.m) : diagonal_line(_ld_question(q, W), p.tuple.m)
            bound = kind == :ALine ? p.tuple.d : p.tuple.m * p.tuple.d
            coefficients = poly_coefficients(restrict(g, line), bound)
            coefficients === nothing && error("the honest line answer exceeds the degree bound")
            return kappa_bits(coefficients, p.basis)
        end
        # Magic-Square / Pair types: the observables O_A = tau^X(ind(u_x) r_x), O_B = tau^Z(ind(u_z) r_z).
        O_A = _pauli_of(inst, w, :X, ind(collect(q.u_x)) .* q.r_x)
        O_B = _pauli_of(inst, w, :Z, ind(collect(q.u_z)) .* q.r_z)
        gamma = anticommute(O_A, O_B)
        gamma == pauli_gamma(q) || error("gamma disagrees with the symplectic product")
        e = _extra_qubit(inst, w)
        Xe = pauli_string(n_qubits; xs=[e])
        Ze = pauli_string(n_qubits; zs=[e])
        if kind == :Pair && arg === nothing
            return gamma ? Bool[false, false] : measure_family!(tab, [O_A, O_B], choose)
        elseif kind == :Pair
            gamma && return Bool[false]
            return Bool[measure!(tab, arg == "X" ? O_A : O_B, choose)]
        end
        gamma || return kind == :Constraint ? Bool[false, false, false] : Bool[false]
        cells = Dict(1 => O_A, 2 => Xe, 3 => O_A * Xe, 4 => Ze, 5 => O_B, 6 => O_B * Ze, 7 => O_A * Ze, 8 => O_B * Xe)
        cells[9] = cells[7] * cells[8]
        kind == :Variable && return Bool[measure!(tab, cells[arg], choose)]
        return measure_family!(tab, [cells[v] for v in magic_square_variables(arg)], choose)
    end
    role = kind == :Hide ? Symbol(arg[2]) : Symbol(arg)
    if kind == :Sample
        z = plain_measure!(tab, :Z, _qubits(inst, w, 1:s), choose)
        y = _bools(_raise(Marginal(inst.S, inst.N, role, inst.ell, _gf2(z))))
        return vcat(embed_Q(z, Q), inst.child_honest(role, y))
    end
    # Sequential Z-measurements of the stages (Introspect, Read, Hide).
    stages = kind == :Hide ? arg[1] - 1 : inst.ell
    y = falses(s)
    registers = Vector{Int}[]
    matrices = Matrix{GF2}[]
    for j in 1:stages
        register, M = _honest_stage(inst, role, j, y)
        yj = coarse_measure!(tab, :Z, _qubits(inst, w, register), M, choose)
        y[register] = yj
        push!(registers, register)
        push!(matrices, M)
    end
    kind == :Introspect && return vcat(embed_Q(y, Q), inst.child_honest(role, y))
    # The dual X-measurements sigma^X_{[(L_j)^perp (.) = y_perp_j]} for j = 1..ell (Read) or 1..k (Hide_k).
    perp_stages = kind == :Read ? inst.ell : arg[1]
    for j in length(registers)+1:perp_stages
        register, M = _honest_stage(inst, role, j, y)
        push!(registers, register)
        push!(matrices, M)
    end
    y_perp = falses(s)
    for j in 1:perp_stages
        Lp, _, _ = perp_map(matrices[j])
        y_perp[registers[j]] = coarse_measure!(tab, :X, _qubits(inst, w, registers[j]), Lp, choose)
    end
    kind == :Read && return vcat(embed_Q(y, Q), embed_Q(y_perp, Q), inst.child_honest(role, y))
    # Hide_k: X on the register V_{>k}(y).
    rest = setdiff(1:s, reduce(vcat, registers[1:perp_stages]; init=Int[]))
    x_out = falses(s)
    x_out[rest] = plain_measure!(tab, :X, _qubits(inst, w, rest), choose)
    vcat(embed_Q(y, Q), embed_Q(y_perp, Q), embed_Q(x_out, Q))
end

"""
    honest_transcript(inst, edge, z, choose) -> (; edge, xA, xB, aA, aB)

One honest transcript: the typed questions of hat S^intro on seed z for the
oriented edge, and both players' answers from a fresh |EPR_2>^{(x)(Q+1)}.
"""
function honest_transcript(inst::IntroInstance, edge::Tuple{String,String}, z, choose::Function)
    xA, xB = sample_questions(inst.hat, inst.n, z, edge)
    tab = epr_tableau(inst.Q + 1)
    xa, xb = _bools(xA), _bools(xB)
    aA = honest_answer!(inst, tab, :alice, edge[1], xa, choose)
    aB = honest_answer!(inst, tab, :bob, edge[2], xb, choose)
    (; edge, xA=xa, xB=xb, aA, aB)
end

"The decision of the TYPED decider on a transcript, with the child-call trace and the fired tests."
typed_decision(inst::IntroInstance, t) =
    intro_decide_traced(inst.typed_decider.term[3], inst.n, t.edge[1], t.xA, t.edge[2], t.xB, t.aA, t.aB)

"The detyped question of player w for the oriented edge (l, r): the graph view followed by the body."
function detyped_question(inst::IntroInstance, w::Symbol, edge::Tuple{String,String}, body::AbstractVector{Bool})
    labels = inst.hat.typing.labels
    T = length(labels)
    edges = Set((findfirst(==(e[1]), labels), findfirst(==(e[2]), labels)) for e in inst.hat.typing.edges)
    neigh(t) = Bool[(t, v) in edges || (v, t) in edges for v in 1:T]
    unit(t) = Bool[v == t for v in 1:T]
    l, r = findfirst(==(edge[1]), labels), findfirst(==(edge[2]), labels)
    view = w == :alice ? vcat(unit(l), neigh(l), falses(T), unit(l)) : vcat(falses(T), unit(r), unit(r), neigh(r))
    vcat(view, body)
end
"The detyped decider's decision on a transcript through the valid graph encoding of its edge."
detyped_decision(inst::IntroInstance, t) =
    decide(inst.decider, inst.n, detyped_question(inst, :alice, t.edge, t.xA), detyped_question(inst, :bob, t.edge, t.xB), t.aA, t.aB)

"Per-mode maximum of the exact metered costs over a set of child-call records (the finite honest cost)."
function cost_table(records)
    table = Dict{Symbol,Int}()
    for r in records
        r.outcome == :return || continue
        table[r.mode] = max(get(table, r.mode, 0), r.steps)
    end
    table
end
