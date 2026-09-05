# Keep the heavy TB0 inference outside the body clock. This file runs ONCE,
# while the package image is built (never at `using` time), so every method
# specialization it reaches -- including the certificate `replay` closures,
# which `precompile(f, types)` cannot reach through `CertNode.replay::Any` --
# is cached in the image and the gated TB0 test body pays compute, not JIT.
# Nothing here assigns to a global: the image caches specializations, never
# values (DESIGN.md section 5 records the measured cold/warm figures, and
# `tools/cold_precompile.sh` times the cold build).
let
    # Encoding paths for m = 1, 2, 3 in both fields (test/tb0_core.jl testset 2).
    for F in (GF8, GF2048), (names, coordinates, table) in
            (((:x1,), (1,), [0, 1]), ((:x1, :x2), (1, 2), [0, 0, 1, 0]),
             ((:x1, :x2, :x3), (1, 2, 3), [0, 0, 0, 0, 1, 0, 0, 0]))
        layout = VarLayout(names, (VarBlock(:X, 1:length(names)),))
        extension = g_a(F[table...], layout, coordinates).term
        point = fill(primitive_element(F), length(names))
        evaluate(extension, point)
        sum(F[table...] .* ind(point); init=zero(F))
        dec(extension, coordinates, F[0, 1])
    end

    # Witness (i) end to end, both fields, all replays, the refusal path.
    tables = ((0, 1), (0, 0), (0, 0), (0, 0), (0, 0))
    fixture = tb0_build_fixture(GF8, 6, tables, MonomialBudget(37_240))
    build_c0(fixture.farith, fixture.gs, MonomialBudget(37_239))
    verify_certificate(Checked(fixture.proof, fixture.certificate))
    verify_zero_decomposition(fixture.c0, fixture.decomposition)
    traceprint(devnull, fixture.certificate)
    point8 = tb0_base_point(GF8)
    pcpverifier(fixture.tf, ev_z(fixture.proof, point8))
    evaluate(fixture.c0, point8)
    evaluate_arith_formula(fixture.tf, point8)
    occurrences(fixture.tf.formula, 16)
    tseitin_occurrence_account(fixture.circuit)
    changed = change_field(fixture.proof, GF2048, 11,
                           tb0_certified_points(GF2048))
    verify_certificate(changed)
    verify_certificate(change_field(fixture.proof, GF2048, 11))
    point11 = tb0_base_point(GF2048)
    pcpverifier(fixture.tf, ev_z(changed.term, point11))
    evaluate(change_field(fixture.c0, GF2048), point11)
    evaluate_arith_formula(fixture.tf, point11)
    dependency_coordinates(fixture.gs[1])
    dependency_blocks(fixture.gs[1])
    # The block-locality refusal of `ev_z` and the borrowed-certificate
    # refusal of the identity-bound evidence nodes.
    out_of_block = fixture.gs[1] * polyvar(GF8, fixture.tf.layout, 12)
    bad_locality = PCPProof(Base.setindex(fixture.gs, out_of_block, 1),
                            fixture.c0, fixture.proof.cs, fixture.decomposition,
                            fixture.proof.d, fixture.tf, ())
    try
        ev_z(bad_locality, point8)
    catch err
        err isa ArgumentError || rethrow()
    end
    other = tb0_build_fixture(GF8, 6, tables, MonomialBudget(37_240))
    verify_certificate(Checked(other.proof, fixture.certificate))

    # The m = 2 layout regression (18 variables).
    m2 = build_pcp_fixture(layout_m2_circuit(), GF8, 6, LAYOUT_M2_TABLES,
                           MonomialBudget(10_000), (layout_m2_point(GF8),))
    view = ev_z(m2.proof, layout_m2_point(GF8))
    pcpverifier(m2.tf, view)
    evaluate_arith_formula(m2.tf, layout_m2_point(GF8))
    verify_certificate(Checked(m2.proof, m2.certificate))

    # C8's two-gate circuit (5 variables).
    c8 = c8_two_gate_circuit()
    arith_q(tseitin(c8).term, GF8, MonomialBudget(160_000))
    tseitin_occurrence_account(c8)
end
precompile(tb0_build_nondegenerate_fixture,
           (Int, NTuple{5,NTuple{2,Int}}, MonomialBudget))
