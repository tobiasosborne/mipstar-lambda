# TB4 Compress-skeleton workload executed ONCE at image-build time (the
# pattern of src/precompile.jl and frontend/precompile_frontend.jl;
# verdicts/tb4-r2.md NEW-3): every specialization reached here -- the
# fixture-backed stage table, the three contracts and their audits, the
# certificate replays, the trace printer, the Quote/Specialize path of the
# quoted fixed point and the CEK evaluation of D_{M,lambda} -- is cached in
# the image so the TB4 test body pays compute, not JIT, and DESIGN 5.6's
# 6 s in-suite budget is measured with this workload in place. Nothing
# here assigns a global; every printed TB4 fact is identical with this
# workload removed (the test file asserts each of them).
let
    input = (2, Bool[], Bool[], Bool[true], Bool[false])
    verifier = halting_verifier(TWO_STATE_HALTING, 1024)
    stages = tb4_stages(frontend_fixture())
    compressed = Compress(verifier, 1024; stages)
    verify_certificate(compressed)
    sprint(traceprint, compressed.certificate)
    level_chain(compressed.term)
    Compress(halting_verifier(TWO_STATE_LOOPING, 1024), 1024; stages)
    verify_certificate(Introspect(halting_verifier(TWO_STATE_HALTING, 7), 7, 9))
    halting_verifier(TWO_STATE_HALTING, 1024; compress=COMPRESS_IDENTITY)
    eval_quoted(halting_decider(TWO_STATE_HALTING, nat(1024)).term, input, 5_000)
    fix_unfolding(TWO_STATE_HALTING, nat(1024))
end
