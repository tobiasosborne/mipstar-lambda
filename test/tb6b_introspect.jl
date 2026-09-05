using Test
using MIPStarLambda
using Random
Base.Experimental.@optlevel 0

# TB6b (DESIGN 11, briefs/43-tb6-introspect.md): the executable Pauli test,
# the introspection sampler and decider, the step-metered child calls, the
# exact stabilizer honest-strategy simulation, fixtures TB6b-E and TB6b-M.
# Ground truth: gt-07-ldt.tex L964-L1120 (types, maps), L1126-L1227
# (fig:decider_pauli), L1232-L1330 (lem:pauli-completeness), L659-L760
# (thm:ms-from-ac), L1492-L1569 (def:introparams); gt-08-introspection.tex
# L217-L315 (fig:type-graph-intro), L317-L392 (sampler), L394-L500
# (fig:intro-decider), L524-L530 (wire format), L550-L579, L641-L684 (query
# schedule), L588-L591 (3Q), L923-L953 (lem:commute), L1002-L1172 (honest strategy).

const TB6B_TARGET = get(ENV, "TB6B_TARGET", "all")
tb6b_runs(name) = TB6B_TARGET == "all" || TB6B_TARGET == name
const M6 = MIPStarLambda
const TB6B_ROOT = isdir(joinpath(@__DIR__, "..", "ground-truth")) ? normpath(joinpath(@__DIR__, "..")) :
                  normpath(joinpath(dirname(pathof(MIPStarLambda)), ".."))
const TB6B_CACHE = Dict{Symbol,Any}()
const TB6B_LOG = Dict{Symbol,Any}()
const TB6B_F_CHILD = 65_536
tb6b_started = time()
const TB6B_RSS_START = Sys.maxrss()

tb6b_bits(v) = Bool[x == one(GF2) for x in v]
tb6b_gf2(b) = GF2[GF2(Int(x)) for x in b]
function tb6b_nodes(node::CertNode, found=CertNode[])
    push!(found, node)
    foreach(child -> tb6b_nodes(child, found), node.children)
    found
end
tb6b_find(node, rule::Symbol) = [n for n in tb6b_nodes(node) if n.rule == rule]
tb6b_grades(node) = Dict(g => count(n -> n.grade == g, tb6b_nodes(node)) for g in instances(Grade))
tb6b_first_lines(path) = readlines(joinpath(TB6B_ROOT, "ground-truth", path))
tb6b_e(i, s) = (v = falses(s); v[i] = true; v)

# --- the two fixtures (DESIGN 11.6) -----------------------------------------------
# TB6b-E: n = 2, N = 4, lambda = 1, ell = 1, the copy game V_copy (identity sampler of dimension 1,
# deterministic one-bit answers), (q, m, d) = (2, 1, 1).
tb6b_copy_map() = CLStep(GF2, 1, [1], Int[], reshape([one(GF2)], 1, 1), CLZero(GF2, 1, Int[]))
function tb6b_E_verifier()
    get!(TB6B_CACHE, :V_E) do
        VerifierDescription(describe_cl(tb6b_copy_map(), tb6b_copy_map(), 2; tracer_index=4).term, copy_decider().term)
    end
end
tb6b_E_honest(role, y) = Vector{Bool}(y)
# TB6b-M: n = 2, N = 4, lambda = 2, ell = 3, the binary child sampler of DESIGN 11.6 on F_2^6 and the
# asymmetric diagnostic decider; deterministic zero answers.
function tb6b_binary_map(::Val{player})  where {player}
    F = GF2
    id(k) = F[F(i == j) for i in 1:k, j in 1:k]
    tail = CLZero(F, 6, Int[])
    stage(factor, rest, matrix, child) = M6._clstep(F, 6, factor, rest, matrix, child, BranchConst(child); require_ambient=false)
    nonsym = F[one(F) one(F); zero(F) zero(F)]                  # [[1,1],[0,0]] in the ordered factor basis
    on0 = stage([2, 3], [4, 5, 6], nonsym, stage([4, 5, 6], Int[], id(3), tail))   # prefix 0: <e2,e3> then <e4,e5,e6>
    on1 = stage([4, 5], [2, 3, 6], nonsym, stage([2, 3, 6], Int[], id(1 + 2), tail))  # prefix e1: <e4,e5> then <e2,e3,e6>
    first = player == :alice ? id(1) : F[zero(F);;]
    CLStep(F, 6, [1], [2, 3, 4, 5, 6], first, on0, BranchByAxis(2, 1, AbstractCL{F}[on0, on1]))
end
function tb6b_M_verifier()
    get!(TB6B_CACHE, :V_M) do
        S = describe_cl(tb6b_binary_map(Val(:alice)), tb6b_binary_map(Val(:bob)), 2; tracer_index=4)
        VerifierDescription(S.term, M6.diagnostic_decider([1, 3]).term)
    end
end
tb6b_M_honest(role, y) = Bool[false]
const TB6B_Z_STAR = Bool[1, 0, 1, 0, 1, 1]      # z* = e1 + e3 + e5 + e6

struct TB6bFixture
    name::Symbol
    V::VerifierDescription
    lambda::Int
    ell::Int
    tuple::M6.PauliTuple
    honest::Function
end
tb6b_E() = TB6bFixture(:TB6b_E, tb6b_E_verifier(), 1, 1, M6.PauliTuple(2, 1, 1), tb6b_E_honest)
tb6b_M() = TB6bFixture(:TB6b_M, tb6b_M_verifier(), 2, 3, M6.PauliTuple(8, 2, 1), tb6b_M_honest)

# The introspected verifier (toy fuel F_child) and its honest instance.
function tb6b_intro(f::TB6bFixture; F_child::Int=TB6B_F_CHILD)
    get!(TB6B_CACHE, Symbol(f.name, :_intro_, F_child)) do
        stats = @timed M6.introspect(f.V, f.lambda, f.ell; tuple=f.tuple, F_child, tracer_index=2, seeds=16)
        TB6B_LOG[Symbol(f.name, :_construction_seconds)] = round(stats.time; digits=3)
        stats.value
    end
end
function tb6b_instance(f::TB6bFixture; F_child::Int=TB6B_F_CHILD)
    get!(TB6B_CACHE, Symbol(f.name, :_instance_, F_child)) do
        checked = tb6b_intro(f; F_child)
        I = checked.term
        hat = M6.intro_sampler(f.lambda, f.ell; tuple=f.tuple, tracer_index=2, seeds=0).hat.term
        typed = M6.typed_intro_decider(f.V, f.lambda, f.ell; tuple=f.tuple, F_child).term
        N = 4
        s = Dimension(f.V.sampler, N)
        M6.IntroInstance(hat, I.sampler, typed, I.decider, f.V.sampler, f.V.decider, 2, N, f.lambda, f.ell,
                         M6.PauliParams(f.tuple), M6.pauli_Q(f.tuple), s, f.honest)
    end
end
tb6b_edges(f::TB6bFixture) = M6.intro_typing(f.ell).edges
tb6b_hide_incident(f::TB6bFixture) = [e for e in tb6b_edges(f) if startswith(e[1], "Hide") || startswith(e[2], "Hide")]

# All child-call records of a fixture (for the ten cost slots).
const TB6B_RECORDS = Dict{Symbol,Vector{Any}}()
function tb6b_record!(f::TB6bFixture, trace)
    append!(get!(TB6B_RECORDS, f.name, Any[]), trace)
end

if tb6b_runs("tb6b_params")
    @testset "TB6b (a) pauli_params: the def:introparams AST, admissibility, the capacity chain, the two policy reports" begin
        ast = M6.introparams_ast()
        @test ast.q == :(2 ^ (c * ceil(log2(log2(R))) + 1)) && ast.d == 1
        @test ast.c == :(smallest_even_integer_at_least((b + a) / b))
        @test ast.m == :(largest_power_of_two_at_most(c * ceil(log2(R)) + 1))
        @test M6.introparams_numeric(16, 2) == M6.PauliTuple(32, 8, 1)       # c = 2: k = 2*2+1 = 5 -> q = 32, m = largest 2^j <= 9
        @test M6.introparams_numeric(4, 2) == M6.PauliTuple(8, 4, 1)         # R = 4: loglog = 1, k = 3; bound 2*2+1 = 5 -> m = 4
        @test_throws ArgumentError M6.introparams_numeric(16, 1)             # odd c is forbidden
        @test M6.admissible_field_size(8)[1] && !M6.admissible_field_size(4)[1] && M6.admissible_field_size(2)[1]
        expected = Dict(
            :TB6b_E => Dict(:R_at_least_4 => "PASS", :admissible_field => "PASS", :m_divides_q => "PASS", :d_equals_1 => "PASS",
                            :capacity_s_le_R => "PASS", :capacity_M_ge_R => "FAIL", :capacity_M_le_Q => "PASS", :consequent_Q_ge_R => "FAIL",
                            :embedding_Q_ge_s => "PASS", :canonical_introparams => "FAIL", :description_le_lambda => "FAIL",
                            :toy_child_fuel => "FAIL", :low_degree_margin => "VACUOUS", :hiding_same_guard_set => "VACUOUS"),
            :TB6b_M => Dict(:R_at_least_4 => "PASS", :admissible_field => "PASS", :m_divides_q => "PASS", :d_equals_1 => "PASS",
                            :capacity_s_le_R => "PASS", :capacity_M_ge_R => "FAIL", :capacity_M_le_Q => "PASS", :consequent_Q_ge_R => "FAIL",
                            :embedding_Q_ge_s => "PASS", :canonical_introparams => "FAIL", :description_le_lambda => "FAIL",
                            :toy_child_fuel => "FAIL", :low_degree_margin => "PASS", :hiding_same_guard_set => "PASS"))
        for f in (tb6b_E(), tb6b_M())
            R = 4 ^ f.lambda
            s = Dimension(f.V.sampler, 4)
            lines = M6.pauli_policy_report(f.tuple; R, s_N=s, lambda=f.lambda, description_bytes=description_length(f.V), F_child=TB6B_F_CHILD, ell=f.ell)
            println("TB6b policy report $(f.name) (R = $(R), s(N) = $(s), |V| = $(description_length(f.V)) bytes: |S| = $(description_size(f.V.sampler)), |D| = $(description_size(f.V.decider)); F_child = $(TB6B_F_CHILD)):")
            println(M6.policy_report_text(lines))
            statuses = Dict(l.name => M6._status_name(l.status) for l in lines)
            for (name, status) in expected[f.name]
                @test statuses[name] == status
            end
            @test all(occursin("NOT_EVALUABLE", M6._status_name(l.status)) && l.owner == "tb6-child-meter" for l in lines if startswith(String(l.name), "TIME_child"))
            @test any(l -> l.name == :toy_child_fuel && l.owner == "tb6-child-meter", lines)
            canonical = only(l for l in lines if l.name == :canonical_introparams)
            f.name == :TB6b_M && @test occursin("c = 1, forbidden", canonical.detail) && occursin("gives m=4", canonical.detail) && occursin("c=2 -> m=8", canonical.detail)
            f.name == :TB6b_E && @test occursin("c = 0, forbidden", canonical.detail)
            margin = only(l for l in lines if l.name == :low_degree_margin)
            println("TB6b $(f.name) ", margin)
        end
        println("MUTATION_EXPECTED_RULE tb6b_params E_M_ge_R=FAIL M_M_ge_R=FAIL margin_E=VACUOUS margin_M=1//4")
    end
end

if tb6b_runs("tb6b_pauli")
    @testset "TB6b (b) pauli_sampler(q, m, d) and pauli_decider on all eight guards in both orders" begin
        for (q, m, d) in ((2, 1, 1), (8, 2, 1))
            ps = M6.pauli_sampler(q, m, d; tracer_index=2, seeds=16)
            S = ps.term
            @test S.typing isa Typed && length(S.typing.labels) == 26 && length(S.typing.edges) == 86
            @test S.level == 3 && Dimension(S, 2) == 3m + 3 && S.field_size == q
            @test passed(verify_certificate(ps))
            @test !isempty(tb6b_find(ps.certificate, :zero_map_factor_partition)) && !isempty(tb6b_find(ps.certificate, :zero_map_factor_report))
            @test all(n.grade == CHECKED for n in tb6b_find(ps.certificate, :SamplerValidity))
            @test !isempty(tb6b_find(ps.certificate, :GraphTranscription))
            F = M6._field_type(q)
            n = 3m + 3
            zvec = fill(zero(F), n)
            # (Pauli, W): the whole ambient factor at stage 1, empty at 2, 3 (SOURCE_REPAIR(zero-map-factor-partition)).
            for W in ("X", "Z"), w in (:alice, :bob)
                @test Factor(S, 2, w, 1, zvec, "Pauli_$(W)") == ones(Int, n)
                @test Factor(S, 2, w, 2, zvec, "Pauli_$(W)") == zeros(Int, n)
                @test Factor(S, 2, w, 3, zvec, "Pauli_$(W)") == zeros(Int, n)
                @test all(iszero, Marginal(S, 2, w, 3, F[F(i % 2) for i in 1:n], "Pauli_$(W)"))
            end
            # The embedded low-degree maps agree with TB1's maps on (u_W, s, v) and vanish elsewhere.
            rng = MersenneTwister(0x6A)
            elements = field_elements(F)
            r = M6.pauli_registers(m)
            for _ in 1:12
                z = F[rand(rng, elements) for _ in 1:n]
                for W in ("X", "Z"), (kind, L, lvl) in (("Point", L_Point(F, m), 1), ("ALine", L_ALine(F, m), 2), ("DLine", L_DLine(F, m), 3))
                    positions = M6.pauli_positions(m, W)
                    small = z[positions]
                    out = Marginal(S, 2, :alice, 3, z, "$(kind)_$(W)")
                    @test out[positions] == collect(apply(L, small))
                    @test all(iszero(out[c]) for c in setdiff(1:n, positions))
                end
                proj = Marginal(S, 2, :bob, 3, z, "Constraint_3")
                @test proj[r.u_x] == z[r.u_x] && proj[r.u_z] == z[r.u_z] && proj[r.r_x] == z[r.r_x] && proj[r.r_z] == z[r.r_z]
                @test iszero(proj[r.s]) && all(iszero, proj[r.v])
            end
            # The Pauli decider: every guard in both orders with hand-built accept/reject transcripts.
            pd = M6.pauli_decider(q, m, d)
            D = pd.term
            @test D.typing isa Typed && D.typing.labels == M6.pauli_type_labels()
            @test passed(verify_certificate(pd))
            @test canonical_bytes(decode_decider(canonical_bytes(D))) == canonical_bytes(D)
            p = M6.PauliParams(q, m, d)
            k = round(Int, log2(q))
            bits(v) = tb6b_bits(field_bit_vector(v))
            kb(x) = M6.kappa_bits(x, p.basis)
            # A question vector with chosen registers.
            function question(; u_x=fill(zero(F), m), u_z=fill(zero(F), m), s=zero(F), v=fill(zero(F), m), r_x=zero(F), r_z=zero(F))
                raw = fill(zero(F), n)
                raw[r.u_x] = u_x; raw[r.u_z] = u_z; raw[r.s] = s; raw[r.v] = v; raw[r.r_x] = r_x; raw[r.r_z] = r_z
                bits(raw)
            end
            one_ = one(F)
            # Item 1: equal types.
            @test decide(D, 2, "Pair", question(), "Pair", question(), [true, false], [true, false])
            @test !decide(D, 2, "Pair", question(), "Pair", question(), [true, false], [false, false])
            # Item 2(a)/(b): Point_W with ALine_W / DLine_W through ld_decider: g_h = h_1 (1-y_1)... at u = 0 and the line
            # through 0: honest table h with h[1] = 1 (all other 0): g_h(y) = prod(1 - y_i); on the axis line 0 + t e_i the
            # polynomial is 1 - t (degree 1 <= d).
            h = fill(zero(F), 2^m); h[1] = one_
            layout = VarLayout(Tuple(Symbol("x", i) for i in 1:m), (VarBlock(:Point, 1:m),))
            g = g_a(h, layout, Tuple(1:m)).term
            uq = question(u_x=fill(zero(F), m))
            point_answer = kb(evaluate(g, fill(zero(F), m)))
            for (kind, linef, bound) in (("ALine", axis_line, d), ("DLine", diagonal_line, m * d))
                lq = question(u_x=fill(zero(F), m), s=zero(F), v=fill(one_, m))
                line = linef(M6._ld_question(M6.parse_pauli_question(p, lq), "X"), m)
                coefficients = M6.poly_coefficients(restrict(g, line), bound)
                line_answer = M6.kappa_bits(coefficients, p.basis)
                @test decide(D, 2, "Point_X", uq, "$(kind)_X", lq, point_answer, line_answer)
                @test decide(D, 2, "$(kind)_X", lq, "Point_X", uq, line_answer, point_answer)
                wrong = copy(line_answer); wrong[1] = !wrong[1]
                @test !decide(D, 2, "Point_X", uq, "$(kind)_X", lq, point_answer, wrong)
                @test !decide(D, 2, "Point_X", uq, "$(kind)_X", lq, point_answer, line_answer[1:end-1])   # malformed rejects
            end
            # Item 3: Point_X with Pauli_X: g_h(u) = a.
            pauli_answer = M6.kappa_bits(h, p.basis)
            @test decide(D, 2, "Point_X", uq, "Pauli_X", question(), point_answer, pauli_answer)
            @test decide(D, 2, "Pauli_X", question(), "Point_X", uq, pauli_answer, point_answer)
            @test !decide(D, 2, "Point_X", uq, "Pauli_X", question(), kb(evaluate(g, fill(zero(F), m)) + one_), pauli_answer)
            # gamma: u_x = u_z = 0, r_x = r_z = 1 gives tr(1) = 1 (k odd); r_x = 0 gives 0.
            g1 = question(r_x=one_, r_z=one_)
            g0 = question(r_x=zero(F), r_z=one_)
            @test M6.pauli_gamma(M6.parse_pauli_question(p, g1)) && !M6.pauli_gamma(M6.parse_pauli_question(p, g0))
            # Item 4: Pair_W with Pair.
            @test decide(D, 2, "Pair_Z", g0, "Pair", g0, [true], [false, true]) && decide(D, 2, "Pair", g0, "Pair_Z", g0, [false, true], [true])
            @test !decide(D, 2, "Pair_Z", g0, "Pair", g0, [false], [false, true])
            @test decide(D, 2, "Pair_Z", g1, "Pair", g1, [false], [false, true])     # gamma = 1: accept
            # Item 5: Point_Z with Pair_Z at gamma = 0 (r_z = 1): tr(a r_z) must equal the bit.
            a_one = kb(one_)
            @test decide(D, 2, "Point_Z", question(), "Pair_Z", g0, a_one, [true]) && decide(D, 2, "Pair_Z", g0, "Point_Z", question(), [true], a_one)
            @test !decide(D, 2, "Point_Z", question(), "Pair_Z", g0, a_one, [false])
            # Item 6: Constraint_i with Variable_j at gamma = 1 (row parity 0 for i <= 5, 1 for i = 6; alpha_j = the bit).
            @test decide(D, 2, "Constraint_1", g1, "Variable_2", g1, [true, true, false], [true])
            @test decide(D, 2, "Variable_2", g1, "Constraint_1", g1, [true], [true, true, false])
            @test !decide(D, 2, "Constraint_1", g1, "Variable_2", g1, [true, false, false], [false])   # parity 1 on a row
            @test !decide(D, 2, "Constraint_1", g1, "Variable_2", g1, [true, true, false], [false])    # alpha_2 mismatch
            @test decide(D, 2, "Constraint_6", g1, "Variable_9", g1, [false, false, true], [true])
            @test !decide(D, 2, "Constraint_6", g1, "Variable_9", g1, [false, false, false], [false])
            @test decide(D, 2, "Constraint_6", g0, "Variable_9", g0, [false, false, false], [false])   # gamma = 0: accept
            @test !decide(D, 2, "Constraint_1", g1, "Variable_9", g1, [false, false, false], [false])  # not incident: alpha_9 undefined
            # Item 7: Point_X with Variable_1 (X) and Point_Z with Variable_5 (Z) at gamma = 1.
            @test decide(D, 2, "Point_X", question(), "Variable_1", g1, a_one, [true]) && decide(D, 2, "Variable_1", g1, "Point_X", question(), [true], a_one)
            @test !decide(D, 2, "Point_X", question(), "Variable_1", g1, a_one, [false])
            @test decide(D, 2, "Point_Z", question(), "Variable_5", g1, a_one, [true])
            @test decide(D, 2, "Point_X", question(), "Variable_1", g0, a_one, [false])               # gamma = 0: accept
            @test !decide(D, 2, "Point_X", question(), "Variable_2", g1, a_one, [true])              # (2, X) is not special
            # No guard: accept; out-of-range type: reject.
            @test decide(D, 2, "ALine_X", question(), "Variable_4", g1, Bool[], Bool[])
            @test !decide(D, 2, "Referee", question(), "Variable_4", g1, Bool[], Bool[])
        end
        println("MUTATION_EXPECTED_RULE tb6b_pauli guards=8 orders=2 zero_factor=whole_ambient_stage1")
    end
end

if tb6b_runs("tb6b_sampler")
    @testset "TB6b (c) tilde_S_intro -> downsize -> detype: field 2, level 5, dimensions 142 / 179; intensional independence" begin
        for (f, hat_dim, detyped_dim) in ((tb6b_E(), 6, 142), (tb6b_M(), 27, 179))
            chain = M6.intro_sampler(f.lambda, f.ell; tuple=f.tuple, tracer_index=2, seeds=16)
            tilde, hat, detyped = chain.tilde.term, chain.hat.term, chain.detyped.term
            @test tilde.typing isa Typed && length(tilde.typing.labels) == 32 + 2f.ell && length(tilde.typing.edges) == 6f.ell + 110
            @test tilde.level == 3 && Dimension(tilde, 2) == 3f.tuple.m + 3 && tilde.field_size == f.tuple.q
            @test hat.field_size == 2 && hat.level == 3 && Dimension(hat, 2) == hat_dim && hat.typing isa Typed
            @test detyped.field_size == 2 && detyped.level == 5 && Dimension(detyped, 2) == detyped_dim && detyped.typing isa Untyped
            @test detyped.dimension_law == :(s_1(n) + 4 * TypeCount) && detyped.level_law == :(ell_1 + 2)
            for c in (chain.tilde, chain.hat, chain.detyped)
                @test passed(verify_certificate(c))
                @test !isempty(tb6b_find(c.certificate, :SamplerValidity)) && all(n.grade == CHECKED for n in tb6b_find(c.certificate, :SamplerValidity))
            end
            @test length(tb6b_find(chain.detyped.certificate, :SamplerValidity)) >= 3   # every intermediate sampler replays
            # The new types are zero maps with the promoted stage-1 factor (SOURCE_REPAIR(zero-map-factor-partition)).
            F = M6._field_type(f.tuple.q)
            n = 3f.tuple.m + 3
            for label in ("Introspect_alice", "Hide_1_bob", "Read_alice", "Sample_bob")
                @test Factor(tilde, 2, :alice, 1, fill(zero(F), n), label) == ones(Int, n)
                @test Factor(tilde, 2, :bob, 2, fill(zero(F), n), label) == zeros(Int, n)
                @test all(iszero, Marginal(tilde, 2, :alice, 3, F[F(1) for _ in 1:n], label))
            end
            @test !isempty(tb6b_find(chain.tilde.certificate, :zero_map_factor_report))
            # Bytes round trip and the compact term.
            @test canonical_bytes(decode_sampler(canonical_bytes(detyped))) == canonical_bytes(detyped)
            @test tilde.term == (:Intro, f.lambda, f.ell, f.tuple.q, f.tuple.m, f.tuple.d)
            @test dependency_set(tilde) == Set{Any}([:S])
            # graph_sampler(G^intro) agrees with the detyped sampler's stages 1-2 on the graph registers.
            gs = M6.graph_sampler(hat.typing; tracer_index=2, seeds=8)
            G = gs.term
            T = length(hat.typing.labels)
            @test G.level == 2 && Dimension(G, 2) == 4T && passed(verify_certificate(gs))
            rng = MersenneTwister(0x6B)
            for _ in 1:6
                zg = GF2[GF2(rand(rng, 0:1)) for _ in 1:4T]
                z = vcat(zg, fill(zero(GF2), hat_dim))
                for w in (:alice, :bob), j in 1:2
                    @test Marginal(detyped, 2, w, j, z)[1:4T] == Marginal(G, 2, w, j, zg)
                    @test Factor(detyped, 2, w, 1, fill(zero(GF2), 4T + hat_dim))[1:4T] == Factor(G, 2, w, 1, fill(zero(GF2), 4T))
                end
            end
            TB6B_LOG[Symbol(f.name, :_sampler_dims)] = (Dimension(tilde, 2), hat_dim, detyped_dim)
        end
        # Intensional independence: two byte-distinct input verifiers give byte-identical S^intro.
        f = tb6b_E()
        V2 = VerifierDescription(f.V.sampler, trivial_decider().term)
        @test canonical_bytes(V2.decider) != canonical_bytes(f.V.decider)
        I1 = M6.introspect(f.V, 1, 1; tuple=f.tuple, F_child=TB6B_F_CHILD, tracer_index=2, seeds=4)
        I2 = M6.introspect(V2, 1, 1; tuple=f.tuple, F_child=TB6B_F_CHILD, tracer_index=2, seeds=4)
        I3 = M6.introspect(tb6b_M().V, 1, 1; tuple=f.tuple, F_child=TB6B_F_CHILD, tracer_index=2, seeds=4)   # a byte-distinct SAMPLER too
        @test canonical_bytes(I1.term.sampler) == canonical_bytes(I2.term.sampler) == canonical_bytes(I3.term.sampler)
        @test quote_hash(I1.term.sampler) == quote_hash(I3.term.sampler)
        @test canonical_bytes(I1.term.decider) != canonical_bytes(I2.term.decider)
        @test !(quote_hash(f.V.sampler) in dependency_set(I1.term.sampler)) && !(quote_hash(f.V.decider) in dependency_set(I1.term.sampler))
        @test only(tb6b_find(I1.certificate, :SamplerIndependence)).grade == CHECKED
        println("MUTATION_EXPECTED_RULE tb6b_sampler dims=", TB6B_LOG[:TB6b_E_sampler_dims], " ", TB6B_LOG[:TB6b_M_sampler_dims], " hash=", quote_hash(I1.term.sampler))
    end
end

# Honest transcripts of a fixture: every branch for one (edge, seed), or seeded draws.
function tb6b_enumerate(inst, edge, z)
    M6.enumerate_branches(choose -> M6.honest_transcript(inst, edge, z, choose))
end

if tb6b_runs("tb6b_schedule")
    @testset "TB6b (d) the decider reads V only through the four queries: the recorded query log equals the DESIGN 11.4 schedule; M6-N" begin
        f = tb6b_M()
        inst = tb6b_instance(f)
        S = f.V.sampler
        N = 4
        # Hide_1_alice / Hide_2_alice at z* (alice's stage-1 bit 1 selects the prefix-dependent branch <e4,e5>): one leaf.
        rng = MersenneTwister(0x6C)
        z = tb6b_gf2(vcat(falses(Dimension(inst.hat, 2))))
        leaves = tb6b_enumerate(inst, ("Hide_1_alice", "Hide_2_alice"), z)
        @test sum(l.probability for l in leaves) == 1
        # Pick a leaf whose Hide_2 player measured y_1 = e_1 (prefix e_1 -> V_2 = <e4,e5>).
        Q = inst.Q
        leaf = first(l for l in leaves if l.result.aB[1])
        t = leaf.result
        rec = RecordingMachine(machine(S))
        bit, trace, fired = M6.with_child_sampler(rec) do
            M6.typed_decision(inst, t)
        end
        @test bit && fired == [:hiding_same]
        # The log: Dimension(N) first; then the schedule of the Hide_1 player (V_1), the Hide_2 player (V_1, u_2, V_2),
        # then Linear on each of the two basis vectors of V_2 = <e4, e5>; every vector query is preceded by the
        # child's own sizing Dimension probe (charged on the same meter).
        modes = [entry[1] for entry in rec.log]
        @test rec.log[1] == (:dimension, N)
        @test all(entry[2] == N for entry in rec.log)                                   # M6-N: every call is at N = 2^n
        vector_calls = [entry for entry in rec.log if entry[1] != :dimension]
        @test [(e[1], e[3], e[4]) for e in vector_calls] ==
              [(:factor, :alice, 1), (:factor, :alice, 1), (:marginal, :alice, 1), (:factor, :alice, 2), (:linear, :alice, 2), (:linear, :alice, 2)]
        @test count(==(:dimension), modes) == 1 + length(vector_calls)
        @test all(entry[5] === nothing for entry in rec.log if entry[1] != :dimension)  # untyped child, no type argument
        # The recorded IntroChildCall trace agrees mode for mode and carries every mandatory field.
        @test [r.mode for r in trace] == [:Dimension, :Factor, :Factor, :Marginal, :Factor, :Linear, :Linear]
        @test all(r.source_R == 16 && r.supplied_fuel == TB6B_F_CHILD && r.outcome == :return && r.steps > 0 && r.quote_hash == quote_hash(S) for r in trace)
        @test trace[5].prefix == Bool[1, 0, 0, 0, 0, 0] && trace[5].result == [0, 0, 0, 1, 1, 0]      # V_2(e_1) = <e4, e5>
        @test trace[6].input == 1 && trace[7].input == 2                                            # Linear on h_1, h_2
        println("TB6b (d) query log: ", join(("$(e[1])$(e[1] == :dimension ? "" : "(" * string(e[3]) * "," * string(e[4]) * ")")" for e in rec.log), " "))
        println("MUTATION_EXPECTED_RULE tb6b_schedule calls=", length(vector_calls), " at_N=", all(entry[2] == N for entry in rec.log), " fired=", fired)
        tb6b_record!(f, trace)
    end
end

if tb6b_runs("tb6b_fuel")
    @testset "TB6b (e) the child fuel meter: exactly R steps in production, F_child = 65,536 in toy mode; M-intro-fuel boundary; the ten cost slots" begin
        # Meter semantics: step budget may be reached, never exceeded.
        for budget in (4, 16, TB6B_F_CHILD)
            ctx = Meter(budget)
            M6._charge!(ctx, budget - 1)
            M6._charge!(ctx, 1)
            @test ctx.steps == budget
            @test_throws M6.FuelExhausted M6._charge!(ctx, 1)
            @test ctx.steps == budget                     # step budget + 1 never executed
        end
        # A child call that costs exactly c steps returns under budget c and times out under c - 1 (M-intro-fuel).
        f = tb6b_M()
        S = f.V.sampler
        z = tb6b_gf2(TB6B_Z_STAR)
        answer, meter = metered_query(S, MarginalQuery(4, :alice, 3, z, nothing))
        c = meter.steps
        @test c > 0 && answer == tb6b_gf2(Bool[1, 0, 1, 1, 0, 1])        # y_A* = e1 + e3 + e4 + e6
        exact = Meter(c)
        @test M6._validated_answer(machine(S), MarginalQuery(4, :alice, 3, z, nothing), exact) == answer && exact.steps == c
        short = Meter(c - 1)
        @test_throws M6.FuelExhausted M6._validated_answer(machine(S), MarginalQuery(4, :alice, 3, z, nothing), short)
        @test short.steps <= c - 1
        # Production (F_child = 0): the budget is R = N^lambda = 16; the honest Introspect/Sample transcript's Marginal call
        # costs more than 16 steps, so it times out at exactly 16 and the decider rejects (acceptance under the source gate is withdrawn).
        inst_prod = tb6b_instance(f; F_child=0)
        rng = MersenneTwister(0x6D)
        t = M6.honest_transcript(inst_prod, ("Introspect_alice", "Sample_alice"), tb6b_gf2(falses(27)), M6.seeded_chooser(rng))
        bit_prod, trace_prod, _ = M6.typed_decision(inst_prod, t)
        @test !bit_prod
        timeouts = [r for r in trace_prod if r.outcome == :timeout]
        @test !isempty(timeouts) && all(r.steps == 16 && r.supplied_fuel == 16 && r.source_R == 16 for r in timeouts)
        @test trace_prod[1].mode == :Dimension && trace_prod[1].outcome == :return && trace_prod[1].steps <= 16
        # Toy mode (F_child = 65,536): the same transcript is accepted; every record fits F_child; toy_child_fuel FAIL printed.
        inst = tb6b_instance(f)
        bit_toy, trace_toy, fired = M6.typed_decision(inst, t)
        @test bit_toy && fired == [:sampling_intro]
        @test all(r.outcome == :return && r.steps <= TB6B_F_CHILD && r.supplied_fuel == TB6B_F_CHILD && r.source_R == 16 for r in trace_toy)
        tb6b_record!(f, trace_toy)
        # The record fields of DESIGN 11.4.
        for r in trace_toy
            @test r.quote_hash == quote_hash(S) && r.mode in (:Dimension, :Marginal, :Factor, :Linear, :Decider)
            @test r.outcome in (:return, :timeout, :query_error) && r.steps >= 0 && !isempty(r.by_depth)
        end
        lines = M6.pauli_policy_report(f.tuple; R=16, s_N=6, lambda=2, description_bytes=description_length(f.V), F_child=TB6B_F_CHILD, ell=3)
        fuel_line = only(l for l in lines if l.name == :toy_child_fuel)
        println("TB6b (e) ", fuel_line)
        @test M6._status_name(fuel_line.status) == "FAIL" && fuel_line.owner == "tb6-child-meter"
        println("MUTATION_EXPECTED_RULE tb6b_fuel production_reject=", !bit_prod, " timeouts_at_R=", length(timeouts), " toy_accept=", bit_toy)
    end
end

# Every CHECKED replay of a certificate except the theorem-contract HypothesisAudit (which refuses on a FAIL hypothesis).
function tb6b_construction_verified(checked::Checked)
    ok = true
    for node in tb6b_nodes(checked.certificate)
        node.grade == CHECKED || continue
        node.rule == :HypothesisAudit && continue
        node.replay === nothing && (ok = false; continue)
        result = node.replay(checked.term)
        passed(result) || (println("  replay failed at ", node.rule, ": ", result); ok = false)
    end
    ok
end

function tb6b_literal_rejects(inst, edge, t)
    M6.intro_guard_literal(t.aA, t.aB, inst.Q)
end

if tb6b_runs("tb6b_E")
    @testset "TB6b (f) TB6b-E: every oriented pair, every stabilizer outcome with exact dyadic probability; literal 10 of 116; detyped tree; 256 draws" begin
        started = time()
        f = tb6b_E()
        inst = tb6b_instance(f)
        @test inst.Q == 2 && inst.s == 1 && Dimension(inst.detyped, 2) == 142
        edges = tb6b_edges(f)
        @test length(edges) == 116
        seeds = collect(enumerate_seeds(GF2, Dimension(inst.hat, 2)))     # F_2^6: 64 seeds
        @test length(seeds) == 64
        literal_rejected = Set{Tuple{String,String}}()
        operative_accept = Dict{Tuple{String,String},Rational{Int}}()
        literal_accept = Dict{Tuple{String,String},Rational{Int}}()
        leaves_total = 0
        max_bits = 0
        mass_ok = true
        recorded_edges = Set{Tuple{String,String}}()
        for edge in edges
            pauli_edge = M6.is_pauli_label(edge[1]) || M6.is_pauli_label(edge[2])
            edge_seeds = pauli_edge ? seeds : seeds[1:1]          # non-Pauli questions are identically zero: the seed is immaterial
            acc = 0 // 1
            acc_lit = 0 // 1
            for z in edge_seeds
                leaves = tb6b_enumerate(inst, edge, collect(z))
                mass_ok &= sum(l.probability for l in leaves) == 1
                for l in leaves
                    t = l.result
                    bit, trace, _ = M6.typed_decision(inst, t)
                    leaves_total += 1
                    max_bits = max(max_bits, length(t.aA), length(t.aB))
                    acc += bit ? l.probability : 0
                    lit = tb6b_literal_rejects(inst, edge, t)
                    lit && push!(literal_rejected, edge)
                    acc_lit += (bit && !lit) ? l.probability : 0
                    if !(edge in recorded_edges)          # one honest trace per oriented pair feeds the cost slots
                        push!(recorded_edges, edge)
                        tb6b_record!(f, trace)
                    end
                end
            end
            operative_accept[edge] = acc // length(edge_seeds)
            literal_accept[edge] = acc_lit // length(edge_seeds)
        end
        @test mass_ok
        @test all(==(1), values(operative_accept))
        P_operative = sum(values(operative_accept)) / 116
        P_literal = sum(values(literal_accept)) / 116
        println("TB6b-E P_intro_operative = ", P_operative, "; P_intro_literal = ", P_literal, " = (116 - ", length(literal_rejected), ")/116; leaves = ", leaves_total,
                "; max honest answer bits = ", max_bits, " = 3Q = ", 3inst.Q)
        @test P_operative == 1 && P_literal == (116 - 10) // 116
        @test length(literal_rejected) == 10 && Set(tb6b_hide_incident(f)) == literal_rejected
        @test max_bits == 3inst.Q == 6
        # The detyped decision tree: every valid graph encoding (one seed per edge, every branch) plus the invalid branch.
        detyped_ok = true
        for edge in edges
            for l in tb6b_enumerate(inst, edge, collect(seeds[7]))
                detyped_ok &= M6.detyped_decision(inst, l.result)
            end
        end
        @test detyped_ok
        T = length(inst.hat.typing.labels)
        @test decide(inst.decider, 2, falses(4T + 6), falses(4T + 6), Bool[], Bool[])       # not an edge view: accept (gt-06:409-427)
        @test decide(inst.decider, 2, Bool[1], Bool[0], Bool[], Bool[])                       # cannot parse: accept
        # The detyped sampler's own questions on a seed encoding the edge equal the detyped questions of the typed transcript.
        labels = inst.hat.typing.labels
        edge_ids = Set((findfirst(==(e[1]), labels), findfirst(==(e[2]), labels)) for e in inst.hat.typing.edges)
        neigh(t) = Bool[(t, v) in edge_ids || (v, t) in edge_ids for v in 1:T]
        unit(t) = Bool[v == t for v in 1:T]
        consistent = true
        for edge in edges[1:20]
            l, r = findfirst(==(edge[1]), labels), findfirst(==(edge[2]), labels)
            body = collect(seeds[9])
            z = vcat(tb6b_gf2(vcat(unit(l), neigh(l), unit(r), neigh(r))), body)
            x, y = sample_questions(inst.detyped, 2, z)
            xa, xb = sample_questions(inst.hat, 2, body, edge)
            consistent &= tb6b_bits(x) == M6.detyped_question(inst, :alice, edge, tb6b_bits(xa)) && tb6b_bits(y) == M6.detyped_question(inst, :bob, edge, tb6b_bits(xb))
        end
        @test consistent
        # 256 seeded draws: uniform edge, uniform seed, seeded measurement outcomes.
        rng = MersenneTwister(0x6E)
        accepted = 0
        for _ in 1:256
            edge = rand(rng, edges)
            z = GF2[GF2(rand(rng, 0:1)) for _ in 1:Dimension(inst.hat, 2)]
            t = M6.honest_transcript(inst, edge, z, M6.seeded_chooser(rng))
            M6.typed_decision(inst, t)[1] && M6.detyped_decision(inst, t) && (accepted += 1)
        end
        @test accepted == 256
        TB6B_LOG[:E_transcript_seconds] = round(time() - started; digits=3)
        println("MUTATION_EXPECTED_RULE tb6b_E literal_rejected=", length(literal_rejected), "/116 operative=", P_operative, " draws=", accepted, "/256 leaves=", leaves_total)
        println("TB6b-E transcript seconds = ", TB6B_LOG[:E_transcript_seconds], " (target < 15)")
    end
end

if tb6b_runs("tb6b_M")
    @testset "TB6b (g) TB6b-M: prefix-dependent factors, L^alice != L^bob, live Hide edges, 8 directed + 512 seeded transcripts, literal 22 of 128, T6-view-swap" begin
        started = time()
        f = tb6b_M()
        inst = tb6b_instance(f)
        S = f.V.sampler
        N = 4
        @test inst.Q == 12 && inst.s == 6 && Dimension(inst.detyped, 2) == 179 && inst.hat.level == 3
        z = tb6b_gf2(TB6B_Z_STAR)
        yA = tb6b_bits(Marginal(S, N, :alice, 3, z))
        yB = tb6b_bits(Marginal(S, N, :bob, 3, z))
        @test yA == Bool[1, 0, 1, 1, 0, 1] && yB == Bool[0, 1, 0, 0, 1, 1]           # y_A* = e1+e3+e4+e6, y_B* = e2+e5+e6
        @test tb6b_bits(Marginal(S, N, :alice, 1, z)) == Bool[1, 0, 0, 0, 0, 0] && all(!, tb6b_bits(Marginal(S, N, :bob, 1, z)))
        @test Factor(S, N, :alice, 2, tb6b_gf2(tb6b_e(1, 6))) == [0, 0, 0, 1, 1, 0] && Factor(S, N, :alice, 2, tb6b_gf2(falses(6))) == [0, 1, 1, 0, 0, 0]
        @test Factor(S, N, :alice, 3, tb6b_gf2(Bool[1, 0, 0, 1, 0, 0])) == [0, 1, 1, 0, 0, 1] && Factor(S, N, :bob, 3, tb6b_gf2(Bool[0, 1, 0, 0, 0, 0])) == [0, 0, 0, 1, 1, 1]
        @test Factor(S, N, :bob, 2, tb6b_gf2(tb6b_e(1, 6))) isa QueryError            # Bob's only stage-2 prefix is 0
        @test decide(f.V.decider, N, yA, yB, [false], [false]) && !decide(f.V.decider, N, yB, yA, [false], [false])
        # The dual map of stage 2 at prefix e_1: M = [[1,1],[0,0]], kernel <e4+e5>, L^perp x = (0, x4 + x5).
        Mmat = GF2[one(GF2) one(GF2); zero(GF2) zero(GF2)]
        Lp, Fb, Sb = M6.perp_map(Mmat)
        @test Fb == [GF2[1, 1]] && Sb == [GF2[1, 1]]
        @test Lp * GF2[1, 0] == GF2[0, 1] && Lp * GF2[1, 1] == GF2[0, 0] && Lp * GF2[0, 1] == GF2[0, 1]
        # The literal reading (canonical complement of the kernel basis, gt-08:L669-L678) gives S = {e5} and a map whose
        # X-family anticommutes with the Z-family of L (SOURCE_REPAIR(intro-perp-orthogonal)).
        Lp_lit, _, Sb_lit = M6.perp_map_literal(Mmat)
        @test Sb_lit == [GF2[0, 1]] && Lp_lit * GF2[1, 0] == GF2[1, 0] && Lp_lit != Lp   # the literal map is (x4, x5) -> (x4, 0)
        @test !all(all(iszero, Mmat * v) for v in M6.dual_basis(M6.kernel_basis(Lp_lit), 2))   # lem:commute fails for the literal map
        @test all(all(iszero, Mmat * v) for v in M6.dual_basis(M6.kernel_basis(Lp), 2))        # and holds for the executable
        # Eight branch-directed transcripts (every branch enumerated, every leaf accepted), the live Hide edges included.
        directed = [("Introspect_alice", "Sample_alice"), ("Pauli_Z", "Sample_bob"), ("Introspect_bob", "Read_bob"),
                    ("Hide_3_alice", "Read_alice"), ("Hide_1_alice", "Hide_2_alice"), ("Hide_2_alice", "Hide_3_alice"),
                    ("Pauli_X", "Hide_1_bob"), ("Introspect_alice", "Introspect_bob")]
        zero_hat = tb6b_gf2(falses(27))
        seen_prefix_branch = false
        literal_suffix_rejections = 0
        literal_perp_rejections = 0
        hide_chain_leaves = 0
        for edge in directed
            leaves = tb6b_enumerate(inst, edge, zero_hat)
            @test sum(l.probability for l in leaves) == 1
            fired_all = Set{Symbol}()
            for l in leaves
                bit, trace, fired = M6.typed_decision(inst, l.result)
                @test bit
                union!(fired_all, fired)
                tb6b_record!(f, trace)
                t = l.result
                if edge[1] == "Hide_1_alice"
                    # The Hide_2 player's y_1 selects the prefix-dependent branch in half of the leaves.
                    t.aB[1] && (seen_prefix_branch = true)
                    # The literal register choice of enu:hiding-same on this honest leaf.
                    k = 1
                    lit = M6.hide_suffix_literal(S, N, :alice, k, t.aA[1:6], t.aA[25:30], t.aB[1:6], t.aB[25:30])
                    lit || (literal_suffix_rejections += 1)
                    # The literal dual map on the Hide_2 player's register V_2(y_wbar) against the honest y_perp_2.
                    u = tb6b_bits(Marginal(S, N, :alice, 1, tb6b_gf2(t.aB[1:6])))
                    V2 = findall(==(1), Factor(S, N, :alice, 2, tb6b_gf2(u)))
                    M2 = M6._honest_stage(inst, :alice, 2, u)[2]
                    lit_perp = tb6b_bits(M6.perp_map_literal(M2)[1] * tb6b_gf2(t.aA[24 .+ V2])) == t.aB[12 .+ V2]
                    lit_perp || (literal_perp_rejections += 1)
                    hide_chain_leaves += 1
                end
            end
            println("TB6b-M directed ", edge, ": leaves = ", length(leaves), " all accepted; fired = ", sort(collect(fired_all)))
            @test length(fired_all) == 1
        end
        @test seen_prefix_branch
        println("TB6b-M enu:hiding-same literal register choice (x_w on V_{>2}(y_w), y_{w,1} = 0 -> <e2,e3>): rejects ", literal_suffix_rejections, " of ",
                hide_chain_leaves, " honest Hide_1/Hide_2 leaves; the operative V_{>2}(y_wbar) register accepts all (SOURCE_REPAIR(intro-hide-suffix-register))")
        @test literal_suffix_rejections > 0
        println("TB6b-M literal dual map (canonical complement of the kernel basis, gt-08:L669-L678): rejects ", literal_perp_rejections, " of ",
                hide_chain_leaves, " honest Hide_1/Hide_2 leaves; the orthogonal-complement map accepts all (SOURCE_REPAIR(intro-perp-orthogonal))")
        @test literal_perp_rejections > 0
        # 512 seeded regressions (typed and detyped).
        edges = tb6b_edges(f)
        @test length(edges) == 128
        rng = MersenneTwister(0x6F)
        accepted = 0
        for _ in 1:512
            edge = rand(rng, edges)
            zz = GF2[GF2(rand(rng, 0:1)) for _ in 1:27]
            t = M6.honest_transcript(inst, edge, zz, M6.seeded_chooser(rng))
            bit, trace, _ = M6.typed_decision(inst, t)
            bit && M6.detyped_decision(inst, t) && (accepted += 1)
            accepted <= 64 && tb6b_record!(f, trace)
        end
        @test accepted == 512
        # The literal >= 3Q guard on one honest transcript per oriented pair: exactly the 22 Hide-incident pairs (36 = 3Q bits).
        literal_rejected = Set{Tuple{String,String}}()
        for edge in edges
            t = M6.honest_transcript(inst, edge, zero_hat, M6.seeded_chooser(rng))
            tb6b_literal_rejects(inst, edge, t) && push!(literal_rejected, edge)
            @test max(length(t.aA), length(t.aB)) <= 36
        end
        @test length(literal_rejected) == 22 && literal_rejected == Set(tb6b_hide_incident(f))
        println("TB6b-M P_intro_literal = ", (128 - length(literal_rejected)) // 128, " (22 of 128 rejected at 36 = 3Q bits); P_intro_operative = 1")
        # T6-view-swap (M-detype-view-orientation owner): valid (Introspect_alice, Introspect_bob) encoding, answers reversed.
        Q = inst.Q
        swapped_aA = vcat(M6.embed_Q(yB, Q), [false])
        swapped_aB = vcat(M6.embed_Q(yA, Q), [false])
        edge = ("Introspect_alice", "Introspect_bob")
        xa, xb = sample_questions(inst.hat, 2, zero_hat, edge)
        typed_swapped = M6.intro_decide_traced(inst.typed_decider.term[3], 2, edge[1], tb6b_bits(xa), edge[2], tb6b_bits(xb), swapped_aA, swapped_aB)
        @test !typed_swapped[1] && typed_swapped[3] == [:game]
        honest_order = M6.intro_decide_traced(inst.typed_decider.term[3], 2, edge[1], tb6b_bits(xa), edge[2], tb6b_bits(xb), swapped_aB, swapped_aA)
        @test honest_order[1]
        xd = M6.detyped_question(inst, :alice, edge, tb6b_bits(xa))
        yd = M6.detyped_question(inst, :bob, edge, tb6b_bits(xb))
        @test !decide(inst.decider, 2, xd, yd, swapped_aA, swapped_aB)                  # rejection preserved after detyping
        @test decide(inst.decider, 2, xd, yd, swapped_aB, swapped_aA)
        println("MUTATION_EXPECTED_RULE T6-view-swap typed_reject=", !typed_swapped[1], " detyped_reject=", !decide(inst.decider, 2, xd, yd, swapped_aA, swapped_aB))
        TB6B_LOG[:M_transcript_seconds] = round(time() - started; digits=3)
        println("MUTATION_EXPECTED_RULE tb6b_M literal_rejected=", length(literal_rejected), "/128 draws=", accepted, "/512 prefix_branch=", seen_prefix_branch)
        println("TB6b-M transcript seconds = ", TB6B_LOG[:M_transcript_seconds], " (8 directed + 512 seeded + 128 literal; target < 20)")
    end
end

if tb6b_runs("tb6b_stabilizer")
    @testset "TB6b (h) the stabilizer simulator: symplectic precheck, lem:commute for the Read family, no dense state vector" begin
        n = 6
        tab = M6.epr_tableau(3)
        X1 = M6.pauli_string(n; xs=[1]); Z1 = M6.pauli_string(n; zs=[1]); X4 = M6.pauli_string(n; xs=[4]); Z4 = M6.pauli_string(n; zs=[4])
        @test M6.anticommute(X1, Z1) && !M6.anticommute(X1, X4) && !M6.anticommute(X1, Z4)
        never = () -> error("a noncommuting family must be refused before any sampling")
        @test_throws ArgumentError M6.measure_family!(tab, [X1, Z1], never)       # M6-noncommuting
        @test_throws ArgumentError M6.pauli_string(n; xs=[1]) * M6.pauli_string(n; zs=[1])   # XZ is anti-Hermitian
        # EPR correlations: X_1 X_4 and Z_1 Z_4 are determined (+1); a fresh X_1 is random and then X_4 is determined equal.
        @test !M6.measure!(tab, M6.pauli_string(n; xs=[1, 4]), never) && !M6.measure!(tab, M6.pauli_string(n; zs=[1, 4]), never)
        rng = MersenneTwister(1)
        b = M6.measure!(tab, X1, M6.seeded_chooser(rng))
        @test M6.measure!(tab, X4, never) == b
        # Y-type correlation: the cell-9 observable of thm:ms-from-ac is symmetric, so both halves agree.
        f = tb6b_M()
        inst = tb6b_instance(f)
        p = inst.params
        q = M6.parse_pauli_question(p, tb6b_bits(field_bit_vector(begin
            raw = fill(zero(GF8), 9); r = M6.pauli_registers(2); raw[r.r_x] = one(GF8); raw[r.r_z] = one(GF8); raw end)))
        @test M6.pauli_gamma(q)
        for w in (:alice, :bob)
            O_A = M6._pauli_of(inst, w, :X, ind(collect(q.u_x)) .* q.r_x)
            O_B = M6._pauli_of(inst, w, :Z, ind(collect(q.u_z)) .* q.r_z)
            @test M6.anticommute(O_A, O_B) == M6.pauli_gamma(q)
        end
        tabM = M6.epr_tableau(inst.Q + 1)
        e_a = M6._extra_qubit(inst, :alice); e_b = M6._extra_qubit(inst, :bob)
        nq = 2 * (inst.Q + 1)
        cell9(w) = (M6._pauli_of(inst, w, :X, ind(collect(q.u_x)) .* q.r_x) * M6.pauli_string(nq; zs=[w == :alice ? e_a : e_b])) *
                   (M6._pauli_of(inst, w, :Z, ind(collect(q.u_z)) .* q.r_z) * M6.pauli_string(nq; xs=[w == :alice ? e_a : e_b]))
        ba = M6.measure!(tabM, cell9(:alice), M6.seeded_chooser(rng))
        bb = M6.measure!(tabM, cell9(:bob), never)
        @test ba == bb
        # lem:commute for the Read family at every stage of the M child: ker(L_j^perp)^perp = ker(L_j).
        S = f.V.sampler
        for role in (:alice, :bob), y in (Bool[1, 0, 1, 1, 0, 1], falses(6))
            prefix = falses(6)
            for j in 1:3
                register, Mj = M6._honest_stage(inst, role, j, prefix)
                Lp, Fb, Sb = M6.perp_map(Mj)
                r = length(register)
                kerL = M6.kernel_basis(Mj)
                kerLp = M6.kernel_basis(Lp)
                # (ker Lp)^perp is spanned by the dual basis of ker Lp; it must lie in ker L.
                dual = M6.dual_basis(kerLp, r)
                inker = all(all(iszero, Mj * v) for v in dual)
                @test inker
                yj = tb6b_bits(Marginal(S, 4, role, j, tb6b_gf2(y)))
                prefix = yj
            end
        end
        # No dense state vector: a full M transcript allocates little and the tableau is 2n x (2n+1) bits.
        @test Base.summarysize(tabM) < 4096
        rng2 = MersenneTwister(2)
        M6.honest_transcript(inst, ("Hide_2_alice", "Hide_3_alice"), tb6b_gf2(falses(27)), M6.seeded_chooser(rng2))
        bytes = @allocated M6.honest_transcript(inst, ("Hide_2_alice", "Hide_3_alice"), tb6b_gf2(falses(27)), M6.seeded_chooser(rng2))
        println("TB6b (h) one Hide_2/Hide_3 transcript allocates ", round(bytes / 2^20; digits=3), " MiB (a dense 2^26-amplitude vector would be 1024 MiB)")
        @test bytes < 64 * 2^20
        println("MUTATION_EXPECTED_RULE tb6b_stabilizer precheck=refused commute=true y_correlated=", ba == bb)
    end
end

if tb6b_runs("tb6b_tree")
    @testset "TB6b (i) the certificate tree of Introspect(TB6b-M), the CompressStage, the cost slots, walls" begin
        f = tb6b_M()
        checked = tb6b_intro(f)
        I = checked.term
        @test I isa VerifierDescription && I.sampler.level == 5 && Dimension(I.sampler, 2) == 179 && I.sampler.field_size == 2
        @test I.decider.typing isa Untyped && I.sampler.typing isa Untyped
        # The thm:introspection ASSUME clause |V| <= lambda FAILS for the multi-byte toy quote (DESIGN 11.6), so the
        # CHECKED HypothesisAudit refuses the certificate at that hypothesis (DESIGN 9.6 / compress.jl): the tree is
        # verified with that one audit excluded, and the refusal itself is asserted.
        refusal = verify_certificate(checked)
        @test !passed(refusal) && refusal.rule == :hypothesis_violated && refusal.location == :lambda_bounded_description
        @test tb6b_construction_verified(checked)
        grades = tb6b_grades(checked.certificate)
        println("TB6b certificate tree of Introspect(TB6b-M): nodes = ", length(tb6b_nodes(checked.certificate)),
                " CONSTRUCTED=", grades[CONSTRUCTED], " CHECKED=", grades[CHECKED], " CITED=", grades[CITED],
                " ASSUMED=", grades[ASSUMED], " SOURCE_REPAIR=", grades[SOURCE_REPAIR])
        traceprint(checked.certificate)
        @test all(n.grade != CHECKED || n.replay !== nothing for n in tb6b_nodes(checked.certificate))
        labels = Set(n.rule for n in tb6b_nodes(checked.certificate) if n.grade == CITED)
        for label in (Symbol("thm:pauli"), Symbol("thm:introspection"), Symbol("lem:intro-sampler-complexity"), Symbol("lem:intro-decider-complexity"),
                      Symbol("lem:commute"), Symbol("fig:intro-decider"), Symbol("fig:decider_pauli"), Symbol("fig:type-graph-pauli"),
                      Symbol("lem:detyping-verifiers"), Symbol("def:cl-canonical"), Symbol("def:Lperp"), Symbol("lem:cl-kth"))
            @test label in labels
        end
        for leaf in (n for n in tb6b_nodes(checked.certificate) if n.grade == CITED)
            lines = tb6b_first_lines(leaf.facts.source)
            @test any(occursin("\\label{$(String(leaf.rule))}", lines[i]) for i in leaf.facts.lines)
            @test leaf.replay === nothing
        end
        repairs = Set(n.rule for n in tb6b_nodes(checked.certificate) if n.grade == SOURCE_REPAIR)
        @test issubset(Set([:intro_3Q_guard, :intro_hide_suffix_register, :intro_perp_orthogonal, :zero_map_factor_report, :zero_map_factor_partition]), repairs)
        policy = only(tb6b_find(checked.certificate, :toy_override))
        @test policy.grade == ASSUMED && any(c.rule == :toy_child_fuel && c.facts.status == "FAIL" && c.facts.owner == "tb6-child-meter" for c in policy.children)
        @test any(c.rule == :capacity_M_ge_R && c.facts.status == "FAIL" for c in policy.children)
        @test any(c.rule == :hiding_same_guard_set && c.facts.status == "PASS" for c in policy.children)
        E_policy = only(tb6b_find(tb6b_intro(tb6b_E()).certificate, :toy_override))
        @test any(c.rule == :hiding_same_guard_set && c.facts.status == "VACUOUS" for c in E_policy.children)
        @test any(c.rule == :low_degree_margin && c.facts.status == "VACUOUS" for c in E_policy.children)
        hyp = tb6b_find(checked.certificate, :lambda_bounded_description)
        @test length(hyp) == 1 && hyp[1].facts.status == FAIL          # |V| > lambda for the multi-byte toy quote
        @test only(tb6b_find(checked.certificate, :ell_level)).facts.status == PASS
        # The CompressStage.
        stage = M6.ExecutableIntrospect(; tuple=f.tuple, F_child=TB6B_F_CHILD, tracer_index=2, seeds=4)
        out = Introspect(stage, f.V, f.lambda, f.ell)
        @test out.term isa StageVerifier && out.term.origin == :Introspect && out.term.levels == 5
        @test out.term.payload isa VerifierDescription && Dimension(out.term.payload.sampler, 2) == 179
        @test out.term.sampler_dependencies == (:lambda, :ell)
        @test !isempty(tb6b_find(out.certificate, Symbol("thm:introspection")))
        stage_refusal = verify_certificate(out)
        @test !passed(stage_refusal) && stage_refusal.rule == :hypothesis_violated && stage_refusal.location == :lambda_bounded_description
        @test tb6b_construction_verified(out)
        stub = Introspect(IntrospectStub(), f.V, f.lambda, f.ell)
        @test stub.term isa StubVerifier && stub.term.levels == 5
        # The ten cost slots (finite maxima of the exact metered costs over the recorded honest child calls).
        for fixture in (tb6b_E(), tb6b_M())
            records = get(TB6B_RECORDS, fixture.name, Any[])
            table = M6.cost_table(records)
            R = 4 ^ fixture.lambda
            println("TB6b cost slots ", fixture.name, " (R = ", R, ", F_child = ", TB6B_F_CHILD, ", records = ", length(records), "):")
            for mode in (:Dimension, :Marginal, :Factor, :Linear, :Decider)
                cost = get(table, mode, nothing)
                println("  ", rpad(String(mode), 9), " exact honest cost (steps) = ", cost === nothing ? "NOT_EVALUABLE(owner=tb6-child-meter)" : string(cost),
                        "; TIME_child(N)<=R: ", cost === nothing ? "NE" : (cost <= R ? "PASS" : "FAIL"), "; fits F_child: ", cost === nothing ? "NE" : (cost <= TB6B_F_CHILD ? "PASS" : "FAIL"))
            end
            TB6B_LOG[Symbol(fixture.name, :_costs)] = table
            if TB6B_TARGET == "all"
                @test all(haskey(table, mode) for mode in (:Dimension, :Marginal, :Factor, :Linear, :Decider))
                @test all(v <= TB6B_F_CHILD for v in values(table))
            end
        end
        # The step-meter charge table (DESIGN 11.4 unit) on the M child at z*: one call per mode with by-depth attribution.
        S = f.V.sampler
        z = tb6b_gf2(TB6B_Z_STAR)
        for (mode, q) in (("Dimension", DimensionQuery(4)), ("Marginal(3)", MarginalQuery(4, :alice, 3, z, nothing)),
                          ("Factor(2, e1)", FactorQuery(4, :alice, 2, tb6b_gf2(tb6b_e(1, 6)), nothing)),
                          ("Linear(2, e1, e4)", LinearQuery(4, :alice, 2, tb6b_gf2(tb6b_e(1, 6)), tb6b_gf2(tb6b_e(4, 6)), nothing)))
            _, meter = metered_query(S, q)
            println("TB6b charge table M child ", rpad(mode, 18), " steps = ", meter.steps, " by_depth = ", meter.by_depth)
        end
        walls = (; E_construction=get(TB6B_LOG, :TB6b_E_construction_seconds, nothing), E_transcripts=get(TB6B_LOG, :E_transcript_seconds, nothing),
                   M_construction=get(TB6B_LOG, :TB6b_M_construction_seconds, nothing), M_transcripts=get(TB6B_LOG, :M_transcript_seconds, nothing))
        println("TB6b walls: ", walls, "; process peak RSS MiB = ", round(Sys.maxrss() / 2^20; digits=1))
        if TB6B_TARGET == "all"
            # DESIGN 11.6 / 13.1 targets as hard gates (warm, in this process): E construction < 3, E transcripts < 15,
            # M construction + transcripts < 25, combined < 43, peak < 512 MiB.
            @test walls.E_construction < 3 && walls.E_transcripts < 15
            @test walls.M_construction + walls.M_transcripts < 25
            @test walls.E_construction + walls.E_transcripts + walls.M_construction + walls.M_transcripts < 43
            rss_delta = (Sys.maxrss() - TB6B_RSS_START) / 2^20
            println("TB6b process peak RSS delta over the TB6b body MiB = ", round(rss_delta; digits=1), " (in-suite 0.0 when TB0's earlier peak dominates; standalone includes compilation)")
            @test rss_delta < 512
            println("MUTATION_EXPECTED_RULE tb6b_walls E<3+15 => ", walls.E_construction < 3 && walls.E_transcripts < 15, " M<25 => ", walls.M_construction + walls.M_transcripts < 25)
        end
        census = (length(tb6b_nodes(checked.certificate)), grades[CONSTRUCTED], grades[CHECKED], grades[CITED], grades[ASSUMED], grades[SOURCE_REPAIR])
        println("MUTATION_EXPECTED_RULE tb6b_tree census=", census)
        @test census == (82, 7, 25, 18, 23, 9)
    end
end

println("TB6b test-body wall seconds = ", round(time() - tb6b_started; digits=3), " (E: construction < 3 + transcripts < 15; M warm < 25; combined < 43)")
