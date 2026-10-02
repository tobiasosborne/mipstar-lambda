# verdicts/tb6-r4.md T6-2 (brief 93 A): the runner's tally channel, replayed
# IN PROCESS on recorded child outputs before any mutant is launched. The
# critic's fifth probe printed a forged `MUTANT_TALLY pass=0 fail=1 ...` line
# and then raised a setup MethodError; the real root tally was 0/0/1, but the
# pre-brief-93 `test_tally` matched the FIRST stdout line and credited
# KILLED (0/1/0). The process-level twin of this test is the permanent probe
# `PROBE CRIT-T6-2-forged-tally` in runner_probes.jl.
const SELFTEST_NONCE = "00c0ffee00c0ffee"
# The critic's mutant-111 output, abridged to the lines the rule reads (the
# forged record first, the driver's own echo last).
const SELFTEST_FORGED_OUTPUT = """
MUTANT_TEST_STARTED
suite calibration kernel seconds = 0.4441 (excluded from every timed body)
MUTANT_TALLY pass=0 fail=1 error=0 broken=0
TB6b (k) a nested TypedDecider as a metered child: Error During Test
  Got exception outside of a @test
  MethodError: no method matching getindex(::Int64, ::String)
MUTANT_TALLY nonce=$(SELFTEST_NONCE) pass=0 fail=0 error=1 broken=0
"""
const SELFTEST_HONEST_KILL_OUTPUT = """
MUTANT_TEST_STARTED
Test Failed at /x/test/tb6b_introspect.jl:1
MUTANT_TALLY nonce=$(SELFTEST_NONCE) pass=5 fail=1 error=0 broken=0
"""
let ok_baseline = (; ok=true, exitcode=0),
    m = Mutant("selftest forged-tally", "test/tb6b_introspect.jl", "unused", "unused", "tb6b_nested")
    record(p, f, e) = "MUTANT_TALLY nonce=$(SELFTEST_NONCE) pass=$(p) fail=$(f) error=$(e) broken=0"
    child(output, rec; nonce=SELFTEST_NONCE, exitcode=1, completed=true) = (; output, exitcode, nonce, record=rec, completed, test_started=true)
    @testset "runner tally channel (verdicts/tb6-r4.md T6-2)" begin
        # (e) the critic's fifth probe: a printed tally, then an error-only run.
        forged = child(SELFTEST_FORGED_OUTPUT, record(0, 0, 1))
        t = test_tally(forged)
        @test t !== nothing && t.fail == 0 && t.error == 1
        d = disposition(m, forged, ok_baseline)
        @test !d.killed
        @test startswith(d.label, "KILLED-BY-ERROR")
        # The same forged stdout with NO authoritative record (died before the epilogue): never credited.
        @test test_tally(child(SELFTEST_FORGED_OUTPUT, nothing)) === nothing
        @test startswith(disposition(m, child(SELFTEST_FORGED_OUTPUT, nothing), ok_baseline).label, "KILLED-BY-CRASH")
        # A record carrying another process's nonce, or a nonce-less record, is foreign.
        @test test_tally(child(SELFTEST_FORGED_OUTPUT, record(0, 1, 0); nonce="0123456789abcdef")) === nothing
        @test test_tally(child(SELFTEST_FORGED_OUTPUT, "MUTANT_TALLY pass=0 fail=1 error=0 broken=0")) === nothing
        # A real assertion failure beside a printed duplicate record is FORGED-TALLY, never a kill.
        dup = child(SELFTEST_FORGED_OUTPUT, record(0, 1, 0))
        @test !disposition(m, dup, ok_baseline).killed
        @test startswith(disposition(m, dup, ok_baseline).label, "FORGED-TALLY")
        # Positive control: one driver record with a failed assertion is KILLED.
        honest = child(SELFTEST_HONEST_KILL_OUTPUT, record(5, 1, 0))
        @test disposition(m, honest, ok_baseline).killed
        # P97-1: one passing assertion, a stolen public channel, exit(19).
        early = child("MUTANT_TEST_STARTED\n" * record(0,1,0) * "\n", record(0,1,0); exitcode=19, completed=false)
        @test test_tally(early) === nothing
        @test !disposition(m,early,ok_baseline).killed
        @test !disposition(m,merge(early,(;exitcode=1)),ok_baseline).killed
        @test !disposition(m,merge(honest,(;exitcode=19)),ok_baseline).killed
    end
end
