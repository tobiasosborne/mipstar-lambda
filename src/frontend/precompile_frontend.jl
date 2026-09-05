# TB3 front-end workload executed ONCE at image-build time (the pattern of
# src/precompile.jl): every specialization reached here -- the CEK machine,
# the codec, the tableau, the relation compiler, DPLL, the certificate
# replay closures, and the N = 512 polynomial layout of the equality
# snapshot -- is cached in the image so the test body pays compute, not
# JIT. Nothing here assigns a global; every printed TB3 fact is identical
# with this workload removed.
let
    input = (1, Bool[], Bool[], Bool[true], Bool[false])
    trivial = Lambda(5, Prim(true, Concrete(1), ()))
    equality = Lambda(5, Prim(:eq, Concrete(1), (BoundVar(0, 3), BoundVar(0, 4))))

    # Codec and evaluator paths (test (a), (b)).
    quoted = quote_program(trivial; sort=:Decider)
    decode_program(canonical_bytes(quoted.term))
    verify_certificate(quoted)
    for term in (Fix(Eval(Hole(:self_code, :Program), (), FuelLiteral(7))),
                 Prim(:halts_within, Opaque("n steps", (:n,)), (Prim(1, Concrete(1), ()),)),
                 Specialize(Quote(trivial), (:flag => Prim(true, Concrete(1), ()),)),
                 If(Prim(true, Concrete(1), ()), Prim(Bool[true], Concrete(1), ()), Prim(false, Concrete(1), ())))
        decode_term(term_bytes(term))
    end
    verify_certificate(specialize(Lambda(5, If(Hole(:flag, :Bit), Prim(true, Concrete(1), ()),
                                                  Prim(false, Concrete(1), ()))),
                                  (:flag => Prim(:not, Concrete(1), (Prim(false, Concrete(1), ()),)),)))
    eval_program(trivial, input, 3)
    eval_program(trivial, input, 2)
    eval_program(equality, input, 5)
    eval_program(Fix(Eval(Hole(:self_code, :Program), (), FuelLiteral(4_000_000_000))), (), 50)
    eval_program(Apply(Prim(true, Concrete(1), ()), ()), (), 5)
    eval_quoted(quoted.term, input, 100)
    literal_args = (Prim(1, Concrete(1), ()), Prim(Bool[], Concrete(1), ()),
                    Prim(Bool[], Concrete(1), ()), Prim(Bool[true], Concrete(1), ()),
                    Prim(Bool[false], Concrete(1), ()))
    eval_program(Eval(Quote(trivial), literal_args,
                      FuelBound(Prim(2, Concrete(1), ()), Prim(2, Concrete(1), ()))), (), 100)

    # The trivial pipeline through TB0's PCP builder and TB2's decider
    # (tests (c)-(f)), witness (i) only.
    trace = bounded_trace(quoted, input, 1)
    sat3 = cook_levin(trace)
    sat5 = decouple5(sat3)
    padded = pad5(sat5)
    for checked in (trace, sat3, sat5, padded)
        verify_certificate(checked)
    end
    present_clauses(sat3.term)
    satisfies(sat3.term, Bool[false, true])
    satisfies5(sat5.term, input, ([true], [false], [false, true], [false, false], [false, false]))
    frontend_witness_tables(padded.term; nondegenerate=false)
    frontend_c0_estimate(padded.term)
    tables = ((0, 0), (0, 0), (0, 1), (0, 0), (0, 0))
    fx = frontend_pcp(padded, GF8, 6, tables, MonomialBudget(160_000), tb0_certified_points(GF8))
    verify_certificate(Checked(fx.proof, fx.certificate))
    sprint(traceprint, fx.certificate)
    build_pcp_fixture(padded.term.circuit, GF8, 6, tables, MonomialBudget(160_000),
                      tb0_certified_points(GF8))
    proof11 = change_field(fx.proof, GF2048, 11).term
    params = PCPParams(2048, 11, 1, 11, 6, 16, 1)
    original = trivial_original_verifier(GF2048, params, fx.tf; n=2, T=1, Q_len=1, sigma=33,
                                         label=:precompile_frontend)
    reduced = answer_reduce_pcp(original, 1, 1, 1).term
    strategy = honest_pcp_strategy(proof11, params)
    seed = ntuple(j -> GF2048(mod(37 + 13j, 2048)), seed_dim(reduced.sampler))
    for case in _answer_reduce_replay_cases()
        left_q, right_q = sample_answer_reduce_questions(reduced, case.left, case.right, seed)
        left_a = honest_pcp_answer(strategy, case.left.pcp, left_q.pcp)
        right_a = honest_pcp_answer(strategy, case.right.pcp, right_q.pcp)
        typed_answer_reduced_decider(reduced.decider, case.left, left_q, case.right, right_q,
                                     left_a, right_a)
    end

    # The equality snapshot (test (g)): T = 3, the padded m' = 512 circuit,
    # Tseitin and the refused arithmetization on that layout.
    etrace = bounded_trace(quote_program(equality; sort=:Decider), input, 3)
    esat3 = cook_levin(etrace)
    esat5 = decouple5(esat3)
    epadded = pad5(esat5)
    for checked in (etrace, esat3, esat5, epadded)
        verify_certificate(checked)
    end
    satisfiable5(esat5.term, input)
    satisfiable(esat3.term, input)
    tf = tseitin(epadded.term.circuit).term
    arith_q(tf, GF8, MonomialBudget(160_000))
end
