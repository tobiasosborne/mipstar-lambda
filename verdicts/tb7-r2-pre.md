# Brief 97a — static adversarial pre-review of 78b2dce

Completed static review of frozen src/test/DESIGN checkpoint 78b2dce. Only this verdict and authorized scratch were written. No claim row or status is authorized. Five Julia processes were used; no full suite, registry driver, benchmark, rebuild, state-changing git or bd ran.

The required priors, brief 93/report and complete scoped diff have been read. The report's registry result is a placeholder; its proposed all-killed C14 clause is not established by that report.

1. **P97-1 · MAJOR · `test/mutations/run.jl:388–421,508–531` — spurious mutation credit remains.** The scratch runner probe completed with exit 1: its regression was 2 pass / 1 fail / 0 errors. A child executing exactly one passing assertion reads `Main.MUTANT_DRIVER_CHANNEL`, writes a matching `fail=1` record, prints that single record and exits 19. The runner reports KILLED (0/1/0) although no owned assertion failed and the driver epilogue never ran. The normal runner self-test is 10/10; deleting the duplicate-record guard makes it 8 pass / 2 fail. Thus that self-test is red-capable but misses this case. **FIX DEMAND:** make driver completion and its real assertion outcome authoritative, refuse this early-exit case, and permanently register the exact probe below. **Surviving statement:** stale files are removed, foreign nonces are refused, and printed tally text alone is no longer the tally source.

2. **P97-2 · MAJOR · `src/certificates.jl:41–95`; `src/ir/programs.jl:582–585`; `src/compress/compress7.jl:477–492`; `src/policy/policy.jl:170–178` — identity binding does not authenticate mutable facts or relocated nodes.** The scratch certificate regression is 12 pass / 6 fail / 0 errors, exit 1. Changing the actual `IntroGap` AST from max to min, changing its child's scalar AST, emptying the agreement outcomes, and emptying a FAIL audit's stored failure list are all undetected; the last change makes the failed audit PASS. A copy with forged facts is refused directly but accepted after `_relocate(forged, identity)`; an absent Ent child is accepted after `unbound` reconstruction. **FIX DEMAND:** replay the node's actual immutable/frozen facts and required child rules, preserve validation through relocation/rebuilding, and retain these reds. **Surviving statement:** direct copies with replaced immutable facts/dropped children are refused, and redefining `intro_gap_ast` to return false does make the old node fail.

3. **P97-3 · MAJOR · `test/tb6b_introspect.jl:1098–1117,1143–1174` — whole-tail coordinates are covered only one nonzero bit at a time.** The new even-parity `_in_V` survives BOTH permanent targets: `tb6b_negative` 369/369 and `tb6b_tail_edges` 5105/5105. On a real `Introspect_bob` self-loop with both answers' vector equal to e7+e8, it parses and accepts typed and valid-detyped, firing consistency. The clean implementation rejects at membership; the new four-assertion regression is 0 pass / 4 fail / 0 errors against parity. A second NEW off-by-one variant starting at s+2 is killed at 320/49/0 and 4404/701/0. **FIX DEMAND:** register parity and retain a multi-bit outside-vector witness through parser, typed and valid-detyped paths. **Surviving statement:** the source implementation is correct on this new witness, and all single-coordinate tail coverage repairs work.

4. **P97-4 · MAJOR · `src/compress/answer_reduce.jl:360–374`; `src/compress.jl:501–523` — PCP content PASS is inferred from replaceable headers.** The final scratch probe retained `fx.padded` and `fx.pcp` from the unrelated trivial fixture (actual m=1, T=1), replaced only the `FrontEndFixture.quoted` header by the actual lowered D1 and `params.m` by 65537, and received `P_pcp_encodes_D1=PASS` (`instance_is_D1=true`, `width_ok=true`). The content-authentication assertion is 0 pass / 1 fail / 0 errors, exit 1. `fixture_sat` is assigned but unused, and neither the encoded formula's provenance nor its time/input parameters are compared. **FIX DEMAND:** authenticate the actual formula/proof's construction chain and bound parameters, or allow these necessary conditions only to refute, leaving a positive result NOT_EVALUABLE. **Surviving statement:** the default TB7 mismatch genuinely implies FAIL; it is not a sound positive content checker.

5. **P97-5 · MAJOR · `src/introspect/intro_decider.jl:542–577`; `src/compress/compress7.jl:246–267` — pair fallback leaves its checker and report using the original sampler.** Static counterexample: on the named straddling input, the repaired body embeds the trivial sampler (dimension 1), while the replay computes `s_N=Dimension(V.sampler,4)=9`. Hence `Q=2`, `embedding=false`, but the equal zero-vector `Sample_bob` self-loop at line 562 accepts under the effective sampler; line 576 requires `bit4==false`, so the honest CHECKED IntroDecider node fails. The report similarly derives row 3/5 from original s=9 but dispatches its census on effective s=1, then unconditionally says no predicate executes. This is a newly exposed inconsistency, not an objection to replacing the pair. **FIX DEMAND:** derive executable-check expectations and dispatch/schema reporting from the effective pair, while retaining original-input hypotheses separately; add the straddling-node replay regression below. **Surviving statement:** the helper's source branch and equality boundary are correct, and default small-input 0/164 remains correct. This additional red is supplied but NOT RUN (five-process budget exhausted).


6. **P97-6 · MINOR · test/mutations/tb6_introspect.jl:167–184; test/tb5_repeat.jl:800–804; test/tb6a_audit.jl:162,249–252; test/tb6b_introspect.jl:754,934–945; docs/DESIGN.md:1994 — the universal gate guarantee overlooks rounding.** For raw elapsed e and fixed positive calibration c, waiting for e>(K+1)c proves e/c>K under changing load. TB0/TB4/TB7 gate that raw quantity; the old fast-kernel-versus-slow-calibration failure is removed. TB5/TB6a/TB6b round elapsed to milliseconds before gating. Synthetic arithmetic, NOT measured timing: c=0.00001, e=(K+1)c+0.000001 makes the while guard false for K=4,18,21 but rounds e to 0, so the ratio gate passes. The loop need not sleep when the body already crossed its tiny threshold. This is a boundary defect in the unqualified guarantee, not a claimed survivor on this machine. K changes in the diff: 0. **FIX DEMAND:** gate raw elapsed and round only display values, or explicitly bound the guarantee to c>0.0005 seconds; retain synthetic boundary tests. **Surviving statement:** the wait removes the prior load-dependent survivors for ordinary calibrations; this review supplies zero gate-timing evidence.

7. **P97-7 · MINOR · docs/DESIGN.md:2056 — the copied nested-cost derivation omits binary radix.** As Julia syntax, (1+ndigits(2)+142+142+3+3)+272+81*272+1+(2+6+6+3+3) is 22617, not 22618: ndigits(2) defaults to decimal and is 1. The test correctly uses ndigits(2; base=2) (test/tb6b_introspect.jl:1243–1254). With binary digits, depth 1 is 293+272+22032+1+20=22618, depth 2 is 114+5+8+2=129, total 22747. **FIX DEMAND:** specify base=2 in §13.3. **Surviving statement:** the numeric totals, timeout pins and 43+2=45 registered TB6 inventory are correct.

## Discharge table

DISCHARGED-STATICALLY disposes of the old objection under this limited review; it is not TESTED, promotion, or a claim that the closing registry ran.

| Prior / repair | Disposition | Evidence opened here; what brief 97 must still decide |
|---|---|---|
| T7-1 / F | PARTIAL | src/policy/policy.jl:153–178 propagates every valid FAIL/VACUOUS/NOT_EVALUABLE/NOT_EXECUTED; all four grouping controls passed. answer_reduce.jl:302–329 computes growth, width obstruction and fixed-width equality. Audit evidence can be cleared (P97-2), content metadata gives false PASS (P97-4), fallback reporting is inconsistent (P97-5). Run repaired policy targets, their three new mutants and M7-pcp-content. |
| T7-2 / E | PARTIAL | certificates.jl:60–105 rejects the old copied-fact and missing-child attacks. Actual AST/child/outcome edits and relocation/rebinding still pass (P97-2). compress7.jl:514–548 recomputes sigma/hash. Full run must check all CHECKED nodes after repair, their census and the designed ToyContractAudit refusal. |
| T7-3 / D | DISCHARGED-STATICALLY | test/tb7_compress.jl:203–233; test/mutations/tb7_compress.jl:51–58. Bare-term probe: actual D uses 181978 fuel, constant true 3716, both return true. Thus the new used-fuel equality is red-capable. Primitive provenance: clean match=1, discarded-code match=0 (Trivial). Full registry must kill both exact registered survivors through the repaired runner. |
| T7-4 / K | DISCHARGED-STATICALLY, reached-chain scope | machines.jl:740–784; compress7.jl:354–405,561–576; test/tb7_compress.jl:163–188. Reproduced 12 rows, 4 reached: (seeds,calls) AR detype (5,6), anchor (7,9), anchored detype (16,64), repetition (16,32). Eight zero rows are legitimate: no final chain reached them. They add zero semantic evidence below AR detype; separate declared sets remain that evidence. Run M7-final-chain-untapped and local ChainCoverage replay. |
| T7-5 / H | PARTIAL | Source pair choice is fixed in both paths (intro_decider.jl:542–546,595–597; compress7.jl:198–206). Equality at max size=546 retains both; 545 replaces both. But straddling-input replay expects original dimension 9, not effective 1 (P97-5). Run the unexecuted red below, both permanent path checks and M7-pair-fallback-split. |
| T7-6 / I | DISCHARGED-STATICALLY for primary input | intro_decider.jl:466–486,610–633; compress7.jl:264–267; DESIGN:1926–1929,2001–2006; report:18. Reproduced 0/164, Pauli 0/86. No positive Pauli-execution claim remains in reviewed code/DESIGN except the explicitly refuted quotation at DESIGN:2057; CLAIMS retains its HOLD. P97-5 separates the fallback input. Full run must kill M7-embedding-guard-dropped. |
| T7-7 / C | PARTIAL | Six measured waits replace kernel-call inflation; K changes=0. TB0/TB4/TB7 algebra suffices for finite positive calibration; rounded TB5/TB6a/TB6b retain P97-6. No gates measured. Full mains run must kill all six with their owned assertion/evidence strings. |
| T7-8 / G | DISCHARGED-STATICALLY for pristine grading | answer_reduce.jl:406–446; test/tb7_compress.jl:392–410. Local replay passed: 4 complete, 4 prefixes, 9 total cases (last NOT_EXECUTED). Matches gt-10-answer-reduction.tex:2013–2063: game-reaching honest prefixes are not full agreements. DESIGN:1929 replaces 4/9; no stale “4 of 9”/“4/9” found there. Mutable outcomes remain P97-2. Full run must kill M7-agreement-game-blind. |
| T7-9 / J | PARTIAL | DESIGN:2054–2062 now mirrors C12/C13 TESTED, C14 scoped HOLD and C15 CONJECTURE/HOLD. TB6 inventory 45; nested 22747=[22618,129], 22736→[22618,118], 22745→[22618,127]. P97-7 corrects radix. Reported suite 18209/1/18210 was not rerun; registry line remains a placeholder. Brief 97 must supply closing results and whole rows before stale CLAIMS/HANDOFF can be replaced. |
| T6-1 / B | PARTIAL | test/tb6b_introspect.jl:1098–1117,1126–1178 covers six tail coordinates, seven slots, typed/detyped; 960 field cases +76 short schemas. New off-by-one is killed in both targets; parity survives both (P97-3). Full run must kill both registered skip-interior variants and newly registered parity after adding the two-bit witness. |
| T6-2 / A | PARTIAL | run.jl:364–431,508–537; runner_selftest.jl:29–50. Stale file removed, per-job nonce/path, foreign nonce and pure stdout forgery refused. Self-test 10/10; removed duplicate guard 8/2/0. Early-exit child writing exposed channel still gets spurious credit (P97-1). Run repaired process probe and complete registry. |

## Source checks and scoping rulings

The size rule is independently re-derived: gt-05-games-normalform.tex:624–633 defines |V|=max(|S|,|D|). gt-08-introspection.tex:757–768 asks whether that maximum is **at most** lambda; failure replaces **both** machines, equality retains V. intro_effective_pair implements exactly that <= rule. P97-5 concerns downstream expectations, not the source branch.

Membership is coordinatewise: gt-08-introspection.tex:410–413,524–534 embeds V as span(e1,…,e_s) and rejects outside vectors. e7+e8 is outside span(e1,…,e6), despite even tail parity. The new mutant is a genuine weakening, not an equivalent representation.

The source demands PCP content for (D,n,T,Q,gamma,x_alice,x_bob), not matching headers (gt-10-answer-reduction.tex:1226–1246,1396–1415,2058–2063). Its tensor rule at :1948–1965 does not authorize swapping the formula. The default m=1 fixture cannot cover T=2^65536; m>=65537 is necessary, not sufficient.

Order and limits follow gt-12-compression.tex:75–98,128–147,263–359,426–449. The anchor transcript accepts before child-game content is needed (gt-11-parallel-repetition.tex:98–103); source repetition is k=(lambda*n)^((1+c')tau), requiring all components (:200–220). The finite 181978-unit run and two-input hash prove no generation/value/soundness theorem.

**K caveat accepted at its stated scope.** Every DAG sampler still has a row; eight zero rows do not mean missing logging. They establish no semantic coverage of unreached chains. Do not fabricate eight nonempty sets or silently replace the specified sixteen uniform seeds. An explicit VACUOUS label on zero rows would better distinguish successful collection from semantic coverage; the zero counts are already visible.

**Runner edge cases.** run_isolated deletes tally.result before launch (line 394); the parent draws a nonce per invocation, passes nonce/path by an individual addenv, and uses distinct mutant/baseline sandboxes (lines 392–411,426,458). No global shared nonce under MUTATION_JOBS=4 was found; collisions are probabilistic but distinct paths prevent ordinary cross-job reuse. Wrong nonce was experimentally refused. Printing tally-like text alone does not populate the result channel. A child that exits after the *normal* zero-failure tally has been written still has fail=0 and earns no kill. A child that writes the exposed channel itself and exits before epilogue can earn spurious credit, as P97-1 demonstrates. More than one stdout tally is refused when it would otherwise earn credit. The permanent fifth probe is red-capable for the original stdout attack, but not this new one.

## Proposed rows: advice only

**C14, report:17.** Accept the finite before-dispatch/self-loop validation, every individual outside coordinate and slot typed/detyped, the 960-case corpus, 22747=[22618,129] and timeout pins, D1(d) test-only, named UNCHARGED work, failed source-fuel equality, toy-only acceptance, live hiding only on M, and CITED limitations. “Every coordinate is witnessed” is single-coordinate corruption coverage, not proof for all outside vectors. Cut “all assertion-killed” until P97-1/P97-3 are repaired and the registry demonstrates it. 45 currently means registered, and changes if new mutants are added. A nonce-bound file alone is not an accounting guarantee. The leading ellipsis makes this an amendment sketch, not the required complete replacement row: preserve unchanged graph, histogram, cost, source-repair and simulator-independence scopes in the eventual whole row.

**C15, report:18.** Accept ToyPolicy-only order/levels/dimensions, sigma=67648, finite two-input sampler hash, source pair-fallback branch, reached-chain scope 4/12, finite actual-D evaluation, default content FAIL/game NOT_EXECUTED, primary-input 0/164 (0/86 Pauli), and all production/theorem/UNCHARGED exclusions, subject to closing checks. Cut the general assurance “statuses all come from owned evidence” (P97-2/P97-4/P97-5); instead give the explicit primary-input vector:
[PASS,PASS,FAIL,FAIL,VACUOUS,PASS,NOT_EVALUABLE,FAIL,FAIL,NOT_EXECUTED,PASS,FAIL,PASS].
Cut “none is”: **five** rows are PASS and **eight** are not discharged. Say “the full report is not all-PASS, so theorem contracts are not invoked.” Scope zero dispatch to the fitting primary input, not oversized fallback. Repair the latter's local checker before claiming the complete checking interface.

**Authorization: none.** No replacement row, promotion, or new all-killed statement is authorized.

## Probes run

All four top-level Julia commands used the exact prefix nice -n 10 timeout 240 env JULIA_NUM_THREADS=2. Runner probe launched one additional child with that prefix: **5 Julia processes total**. Top-level probes ran sequentially; the runner parent waited while its one child ran. Existing depot reused: 0 instantiate, 0 rebuild, 0 full-suite, 0 registry-driver, 0 benchmarks. Runner script loads definitions before the execution driver. TB6 imports helpers with a NaN sentinel solely to skip calibration initialization and selects no gates. Incidental wall output was ignored.

Commands ran from /home/tobias/Projects/mipstar-lambda; S below means the exact authorized scratch directory in the ledger. Each Julia command was:
nice -n 10 timeout 240 env JULIA_NUM_THREADS=2 julia --startup-file=no --project=. S/SCRIPT > S/LOG 2>&1

| Script | Exit | Result (pass/fail/error where applicable) |
|---|---:|---|
| runner_probe.jl | 1 | self-test 10/0/0; removed duplicate check 8/2/0; early-exit child 19, actual 1/0/0, claimed 0/1/0, credited=1; new regression 2/1/0. Inventory 248 real /102 baseline targets /45 TB6-owned /3 probes. |
| certificate_probe.jl | 1 | 12/6/0. Agreement 4+4+1; equality boundary 546 retained, 545 replaced; dispatch 0/164 and 0/86; final rows 12, reached 4. |
| tail_probe.jl | 1 | clean 369/0/0 and 5105/0/0; off-by-one 320/49/0 and 4404/701/0; parity 369/0/0 and 5105/0/0. Controls 5/0/0; two-bit red 0/4/0. |
| semantic_probe.jl | 1 | controls 4/0/0 plus one standalone mutation-site assertion passed; fuel 181978/3716, both true; provenance clean=1/mutant=0; content red 0/1/0, actual m/T=1/1, claimed m=65537, required log2 T=65536, status PASS. |
| Python arithmetic, exact command in ledger | 0 | K=4,18,21: loop_done=1, ratio_ok=1 on synthetic rounded inputs; decimal depth1=22617, binary=22618, depth2=129, total=22747. |
| git diff --quiet 78b2dce -- src test docs/DESIGN.md | 0 | 0 differences in frozen files. |

No registry kill is credited here. For the new off-by-one, “killed” means actual assertion failures in directly executed targets with clean controls. P97-5 is a static deduction; its supplied regression was not run.

## For brief 97

Run after repair on mains under brief 97's authorization to lift the present battery bans and limits. Preserve raw output and exit codes. Do not duplicate whole TB6b/TB7 runs before the required suite.

1. Run permanent versions of these new regressions first: exposed-channel early exit (zero credit), mutable AST/child/outcome tampering and relocation (refusal), failed-audit-list clearing (refusal), unrelated PCP formula with matching metadata (not PASS), effective-pair replay on straddling input (honest pass), and parity's e7+e8 loop (clean rejects, mutant assertion-fails). The latter must retain parser, typed, valid-detyped and membership-trace checks. P97-6 needs a cheap synthetic raw-time boundary test, not a benchmark.
2. Required **future mains commands, NOT executed in 97a**:

   ~~~bash
   julia --project=. test/runtests.jl
   MUTATION_JOBS=4 MUTATION_VERBOSE=1 julia --project=. test/mutations/run.jl
   ~~~
   Use the mains session's longer limits, not today's 240-second cap or five-process restriction. Current-checkpoint expectations: suite exit 0, **18209 pass /0 fail /0 error /1 broken /18210 total** (worker-reported, not reproduced here); registry exit 0, **killed=248/248, baselines ok=102/102, probes refused=3/3**. Repairs adding tests/mutants/probes must update these from actual output, not preserve stale totals.
3. The complete registry includes every one of the 45 currently TB6-owned and 248 real mutants. Specifically inspect attribution for:

   - M6-in-V-skip-interior (tb6b_negative, expected rejected=35/42) and M6-in-V-skip-interior-edges (tb6b_tail_edges, rejected=800/960). If expanded tests change these strings, record the change.
   - M7-fixedpoint-constant-execution, M7-compressor-discards-self-code, M7-stale-output-hash, M7-replay-unbound, M7-audit-eligible-unevaluable, M7-row11-literal, M7-row7-literal, M7-pcp-content, M7-agreement-game-blind, M7-pair-fallback-split, M7-embedding-guard-dropped, M7-final-chain-untapped.
   - All six body-inflation mutants: TB0 M-gate-body-inflated, TB4 M-gate-body-inflated, TB5 M5-gate-body-inflated, TB6 M6a-gate-body-inflated and M6b-gate-body-inflated, TB7 M7-gate-body-inflated. K remains 100,38,4,18,21,198 respectively. Require the owned ratio assertion/evidence, not another error/ceiling failure. The runner already serializes TB0's full-suite job.
   - Existing non-credit probes CRIT-R3-crash-outside, CRIT-R3-crash-inside, CRIT-T6-2-forged-tally, plus new P97-1 early exit. Error-only failures must remain uncredited.
4. Retain full-suite pins: E costs 5/13/10/13/10, M 5/53/60/50/22; 14378 leaves, histogram 3058/600/10720; Hide rejects 10/116 and 22/128; 13×13 conjunct ownership matrix; 22747=[22618,129] and timeout tuples. TB7 currently expects **317=34/133/70/62/18**, 132 passing CHECKED replays, one designed ToyContractAudit refusal and zero passing forged copies; explain repair-induced changes. Retain 4 complete/4 prefix/1 NOT_EXECUTED, sigma 67648, primary-input 0/164 and 0/86, final-seed reach 4/12. Do not infer these from an aggregate green line alone.
5. Only the converged repaired regressions, full suite and registry can support brief 97's row adjudication. Assemble complete C14 rather than ellipsis, correct C15's “none is,” and retain all exclusions. This pre-review authorizes nothing.

## Verbatim scratch reproducers

These are the complete scripts, including every new mutation and red assertion. Save under one scratch directory and run from the repository root. fallback_red_NOT_RUN.jl was not executed. The semantic probe reproduces the term/transcript path without the full certificate-producing halting_fixed_point wrapper; the wrapper's registered mutant remains for brief 97.


### runner_probe.jl

~~~julia
using Test, MIPStarLambda
const REPO = pwd()
const SCRATCH = @__DIR__
const RUNNER = joinpath(REPO, "test/mutations/run.jl")
function runner_prefix()
    text = first(split(read(RUNNER, String), "\nstarted = time()\n"))
    for file in readdir(dirname(RUNNER))
        endswith(file, ".jl") || continue
        text = replace(text, "include($(repr(file)))" => "include($(repr(joinpath(dirname(RUNNER), file))))")
    end
    # Only the child launcher changes: enforce this session's process limits.
    replace(text, raw"`$(Base.julia_cmd()) --startup-file=no" =>
                  raw"`nice -n 10 timeout 240 env JULIA_NUM_THREADS=2 $(Base.julia_cmd()) --startup-file=no")
end
module Runner end
Base.include_string(Runner, runner_prefix(), RUNNER)
let queues = (Runner.MUTANTS, Runner.TB1_MUTANTS, Runner.TB2_MUTANTS, Runner.TB3_MUTANTS,
              Runner.TB4_MUTANTS, Runner.TB5_MUTANTS, Runner.TB6_QUEUE, Runner.TB7_MUTANTS, Runner.SUITE_MUTANTS)
    ms = vcat(collect.(queues)...)
    println("COUNTS real=", length(ms), " baselines=", length(unique(Runner.baseline_key.(vcat(ms, collect(Runner.RUNNER_PROBES))))),
            " TB6_owned=", count(m -> startswith(m.label, "TB6 "), ms), " probes=", length(Runner.RUNNER_PROBES))
end
const PAYLOAD = raw"""
@test true
nonce, path = Main.MUTANT_DRIVER_CHANNEL
line = "MUTANT_TALLY nonce=$(nonce) pass=0 fail=1 error=0 broken=0"
write(path, line)
println(line)
exit(19)
"""
const PAYLOAD_PATH = joinpath(SCRATCH, "forged_child.jl")
write(PAYLOAD_PATH, PAYLOAD)
r = Runner.run_isolated(joinpath(SCRATCH, "runner-child"), PAYLOAD_PATH, "", "CRITIC_TARGET", "forge")
m = Runner.Mutant("CRIT97 stolen-channel", "test/tb6b_introspect.jl", "unused", "unused", "tb6b_nested")
d = Runner.disposition(m, r, (; ok=true, exitcode=0))
println("FORGED_CHILD exit=", r.exitcode, " actual_assertions=1/0/0 claimed=", Runner.test_tally(r), " disposition=", d,
        " stdout_records=", Runner.stdout_tally_records(r.output))
println("FORGED_STDOUT\n", r.output)
println("EXIT_ZERO=", Runner.disposition(m, merge(r, (; exitcode=0)), (; ok=true, exitcode=0)))
println("STALE_NONCE=", Runner.test_tally(merge(r, (; nonce="0000000000000000"))))
module Unguarded end
const GUARD = "    records = stdout_tally_records(result.output)\n    records == 1 || return (; killed=false,\n                              label=\"FORGED-TALLY (not credited; \$records MUTANT_TALLY records on stdout, the driver writes exactly one; \$counts)\")\n"
try
    text = runner_prefix()
    @test count(GUARD, text) == 1
    Base.include_string(Unguarded, replace(text, GUARD => ""; count=1), RUNNER)
    println("SELFTEST_WITHOUT_GUARD=unexpected_pass")
catch e
    println("SELFTEST_WITHOUT_GUARD=", typeof(e))
end
@testset "97a runner must refuse stolen-channel forgery" begin
    @test r.exitcode == 19
    @test !occursin("Test Failed at", r.output)
    @test !d.killed
end
~~~

### certificate_probe.jl

~~~julia
using Test, MIPStarLambda
const A = MIPStarLambda
C = compress(tb7_input_verifier(), 32768; policy=TB7_TOY_POLICY, tracer_index=2, seeds=4)
nodes = A._nodes(C.certificate)
one_node(rule) = only(n for n in nodes if n.rule == rule)
checks = Pair{String,Bool}[]
record(name, ok) = (push!(checks, name => ok); println(name, "=", Int(ok)))
gap = one_node(:IntroGap)
record("gap_control", passed(verify_local(gap, C.term)))
saved = gap.facts.ast.args[1]
gap.facts.ast.args[1] = :min
record("mutated_ast_refused", !passed(verify_local(gap, C.term)))
gap.facts.ast.args[1] = saved
floor = first(gap.children)
saved_floor = floor.facts.branch.args[1]
floor.facts.branch.args[1] = :+
record("mutated_child_fact_refused", !passed(A._verify_node(gap, C.term)))
floor.facts.branch.args[1] = saved_floor
forged = CertNode(CHECKED, gap.rule; facts=merge(gap.facts, (; ast=:(false))), children=gap.children, replay=gap.replay)
record("copied_facts_refused", !passed(verify_local(forged, C.term)))
record("relocated_forgery_refused", !passed(verify_local(A._relocate(forged, identity), C.term)))
drop = CertNode(CHECKED, gap.rule; facts=gap.facts, children=(floor,), replay=gap.replay)
record("copied_child_drop_refused", !passed(verify_local(drop, C.term)))
rebuilt = CertNode(CHECKED, gap.rule; facts=gap.facts, children=(floor,), replay=A.unbound(gap.replay))
record("unbound_child_drop_refused", !passed(verify_local(rebuilt, C.term)))
agreement = one_node(:AnswerReduceStepsAgreement)
record("agreement_control", passed(verify_local(agreement, C.term)))
println("AGREEMENT complete=", agreement.facts.complete, " prefix=", agreement.facts.prefix,
        " cases=", length(agreement.facts.outcomes))
old_outcomes = copy(agreement.facts.outcomes)
empty!(agreement.facts.outcomes)
record("empty_agreement_evidence_refused", !passed(verify_local(agreement, C.term)))
append!(agreement.facts.outcomes, old_outcomes)
audit = A.toy_contract_audit_node([PolicyPredicate("required", :FAIL)])
record("audit_control", !passed(verify_local(audit, nothing)))
empty!(audit.facts.failed)
record("empty_failure_list_refused", !passed(verify_local(audit, nothing)))
for status in (:FAIL, :VACUOUS, :NOT_EVALUABLE, :NOT_EXECUTED)
    record("group_$(status)_refused", A.group_status((:PASS, status)) != :PASS)
end
V = tb7_input_verifier()
lambda = description_length(V)
pair = A.intro_effective_pair(V, lambda)
record("equality_keeps_pair", pair.fits && pair.S_term == V.sampler.term && pair.D_term == V.decider.term)
pair = A.intro_effective_pair(V, lambda-1)
record("strict_excess_replaces_pair", !pair.fits && pair.S_term == TRIVIAL_SAMPLER_TERM && pair.D_term == TRIVIAL_DECIDER_TERM)
println("BOUNDARY lambda=", lambda)
body = C.certificate.facts.skeleton.input.input.input.payload.decider.term[4][3]
println("DISPATCH ", A.intro_dispatch_census(body, 2))
rows = one_node(:ChainCoverage).facts.final_rows
println("CHAIN rows=", length(rows), " reached=", count(r -> r.distinct > 0, rows),
        " reached_counts=", [(r.final_seeds, r.queries) for r in rows if r.distinct > 0])
println("POLICY ", [p.status for p in only(n for n in nodes if n.rule == :toy_override && haskey(n.facts,:predicates) && length(n.facts.predicates)==13).facts.predicates])
# Change the function the existing node invokes, without rebuilding the node.
@eval A intro_gap_ast(lambda::Integer, n::Integer) = (;
    full=:(false), floor_branch=:(false), substituted=:(false), ent_branch=:(false))
record("changed_replay_function_refused", !passed(verify_local(gap, C.term)))
println("CHECKS total=", length(checks), " pass=", count(last, checks), " fail=", count(x -> !last(x), checks))
@testset "97a certificate and policy regressions" begin
    for (name, ok) in checks
        @test ok
    end
end
~~~

### tail_probe.jl

~~~julia
using Test, MIPStarLambda
const A = MIPStarLambda
# Suppress only the idempotent calibration initializer; no timing gate is selected.
const SUITE_CALIBRATION = NaN
ENV["TB6B_TARGET"] = "critic_helpers"
const FILE = joinpath(pwd(), "test/tb6b_introspect.jl")
include(FILE)
const SOURCE = read(FILE, String)
function block(target, nexttarget)
    start = findfirst("if tb6b_runs(\"$(target)\")", SOURCE).start
    stop = findnext("if tb6b_runs(\"$(nexttarget)\")", SOURCE, start+1).start
    SOURCE[start:prevind(SOURCE, stop)]
end
const NEGATIVE = block("tb6b_negative", "tb6b_tail_edges")
const EDGES = block("tb6b_tail_edges", "tb6b_nested")
tb6b_runs(name) = name in ("tb6b_negative", "tb6b_tail_edges")
function runblock(name, code)
    result = open(joinpath(@__DIR__, name * ".log"), "w") do io
        redirect_stdout(io) do
            try
                Base.include_string(Main, code, FILE)
                nothing
            catch err
                while err isa LoadError
                    err = err.error
                end
                err isa Test.TestSetException || rethrow()
                err
            end
        end
    end
    println("TARGET ", name, " ", result === nothing ? "PASS" : "pass=$(result.pass) fail=$(result.fail) error=$(result.error)")
    result
end
base_negative = runblock("base_negative", NEGATIVE)
base_edges = runblock("base_edges", EDGES)
# NEW variant 1: accepts a nonzero s+1 coordinate (ordinary off-by-one).
@eval A _in_V(v::AbstractVector{Bool}, s::Int) = all(!v[i] for i in s+2:length(v))
off_negative = runblock("off_negative", NEGATIVE)
off_edges = runblock("off_edges", EDGES)
# NEW variant 2: a single parity check substitutes for coordinatewise zero tests.
@eval A _in_V(v::AbstractVector{Bool}, s::Int) = iseven(count(identity, v[s+1:end]))
parity_negative = runblock("parity_negative", NEGATIVE)
parity_edges = runblock("parity_edges", EDGES)
inst = tb6b_instance(tb6b_M())
label = "Introspect_bob"
x, y = sample_questions(inst.hat, 2, fill(GF2(0), Dimension(inst.hat,2)), (label,label))
bad = Vector{Bool}(falses(inst.Q+1))
bad[inst.s+1] = bad[inst.s+2] = true
t = (; edge=(label,label), tA=label, tB=label, xA=tb6b_bits(x), xB=tb6b_bits(y), aA=bad, aB=copy(bad))
function witness(inst,t,bad)
    bit, trace, fired = A.typed_decision(inst,t)
    (; parsed=A.parse_intro_answer(t.tA,bad,inst.Q,inst.s)!==nothing,
       typed=bit, detyped=A.detyped_decision(inst,t), fired, modes=[r.mode for r in trace])
end
red = witness(inst,t,bad)
@eval A _in_V(v::AbstractVector{Bool}, s::Int) = all(!v[i] for i in s+1:length(v))
green = Base.invokelatest(witness,inst,t,bad)
println("PARITY_DOUBLE_TAIL ",red)
println("CLEAN_DOUBLE_TAIL ",green)
@testset "97a tail controls" begin
    @test base_negative === nothing && base_edges === nothing
    @test off_negative !== nothing && off_negative.fail > 0 && off_negative.error == 0
    @test off_edges !== nothing && off_edges.fail > 0 && off_edges.error == 0
    @test parity_negative === nothing && parity_edges === nothing
    @test !green.parsed && !green.typed && !green.detyped && green.fired == [:membership]
end
@testset "97a even nonzero tail must reject" begin
    @test !red.parsed
    @test !red.typed
    @test !red.detyped
    @test red.fired == [:membership]
end
~~~

### semantic_probe.jl

~~~julia
using Test, MIPStarLambda
Base.Experimental.@optlevel 0
const A = MIPStarLambda
const P = TB7_TOY_POLICY
const L = 32768
# Same term and transcript as fixed_point.jl:57-84, without the full certificate construction.
S = compute_sampler(L,P; tracer_index=2)
Vh = A.halting_verifier(A.TWO_STATE_LOOPING,L; sampler=lower_sampler(S),compress=A.compressor_program(P))
D = Vh.term.decider
V = VerifierDescription(S,lift_decider(D).term)
C = compress_terms(V,L,P; tracer_index=2)
t = A.anchor_transcript(C.decider,2)
args = (2,t.x,t.y,t.a,t.b)
actual = eval_quoted(D,args,600_000;hard_cap=600_000)
constant = eval_quoted(quote_program(Lambda(5,Prim(true,Concrete(1),()));sort=:Decider).term,args,600_000;hard_cap=600_000)
println("FIXED_POINT actual_used=",actual.used," constant_used=",constant.used,
        " actual_value=",actual.result.value," constant_value=",constant.result.value)
# Primitive-boundary provenance: exact before/after of the registered survivor.
S0 = tb7_input_verifier().sampler
dp = Lambda(5,Prim(false,Concrete(1),()))
pair = A._quoted_pair(Code(lower_sampler(S0),:Sampler),Code(dp,:Decider))
function findtag(t,tag)
    t isa Tuple || return nothing
    !isempty(t) && t[1]===tag && return t
    for c in t
        found=findtag(c,tag)
        found===nothing || return found
    end
    nothing
end
function embedded(pair)
    code,_=A._run_compress_descriptions(pair,L,A.policy_bytes(P),1_000_000)
    body=findtag(A.decode_decider_term(A.lowered_bytes(code.program)),:IntroFixed)
    body[9]
end
expected = lift_decider(quote_program(dp;sort=:Decider).term).term.term
clean = embedded(pair)
source=read(joinpath(pwd(),"src/compress/lowering.jl"),String)
start=findfirst("function _run_compress_descriptions",source).start
stop=findnext("\nend\n",source,start).stop
fn=source[start:stop]
before="VerifierDescription(decode_sampler(S_bytes), lift_decider(Quoted{:Decider}(_quoted_bytes(D_program, :Decider))).term)"
after="VerifierDescription(decode_sampler(S_bytes), trivial_decider().term)"
@test count(before,fn)==1
Base.include_string(A,replace(fn,before=>after;count=1),"critic-compressor-mutant.jl")
bad=Base.invokelatest(embedded,pair)
println("PROVENANCE clean_match=",Int(clean==expected)," mutant_match=",Int(bad==expected),
        " mutant_tag=",bad[1])
Base.include_string(A,fn,"critic-compressor-restored.jl")
# The content-status checker compares fixture headers, not the encoded formula.
D1=A._decider_from_term(A._compressed_ar_body(C)[12])
fx=A.frontend_fixture()
wide=PCPParams(2048,11,65537,11,6,16,1)
spoof=A.FrontEndFixture(quote_program(lower_decider(D1);sort=:Decider),fx.input,fx.T,
                       fx.padded,fx.pcp,wide,description_size(D1))
ev=A.pcp_encodes_D1_evidence(D1,spoof,L,1,description_size(D1),2)
println("CONTENT original_m=",fx.padded.term.m," claimed_m=",wide.m,
        " actual_fixture_T=",spoof.T," log2_required_T=",2L," status=",ev.facts.status,
        " instance_same=",ev.facts.instance_is_D1," width_ok=",ev.facts.width_ok)
@testset "97a semantic controls" begin
    @test actual.result isa Value && actual.result.value===true
    @test constant.result isa Value && constant.result.value===true
    @test clean==expected && bad!=expected
    @test actual.used!=constant.used
end
@testset "97a status must authenticate encoded content" begin
    @test ev.facts.status!="PASS"
end
~~~

### fallback_red_NOT_RUN.jl

~~~julia
using Test, MIPStarLambda
const A = MIPStarLambda
V = tb7_input_verifier_large()
I = A.typed_intro_decider(V, 32768, 9;
                         tuple=TB7_TOY_POLICY.intro_tuple, fixed_width=true)
node = only(n for n in A._nodes(I.certificate) if n.rule == :IntroDecider)
@testset "97a effective-pair replay (STATIC prediction; not run in 97a)" begin
    @test Dimension(V.sampler, 4) == 9
    @test I.term.term[3][8] == TRIVIAL_SAMPLER_TERM
    a = Bool[false, false, true]
    @test decide(I.term, 2, "Sample_bob", Bool[], "Sample_bob", Bool[], a, a)
    @test passed(verify_local(node, I.term))
end
~~~

## Complete command ledger

Every shell invocation in this resumed 97a run is listed below with its final numeric exit code. Read-only commands that printed a missing-path diagnostic earned no test evidence; some shell pipelines still returned 0. Commands 29 and 45 returned 2 on missing-path searches. Earlier interrupted-session activity is not claimed as a run here. Polling resumed the four recorded sessions; it launched no commands. One draft tool script had a JavaScript parse error (1), before any nested command executed.

**Command 1; exit=0.**

~~~bash
cat /home/tobias/.claude/skills/rk-light/SKILL.md; cat CLAUDE.md; rg -n -A 5 -B 5 'C1[1-5]' claims/CLAIMS.md
~~~

**Command 2; exit=0.**

~~~bash
sed -n '21,25p' claims/CLAIMS.md
~~~

**Command 3; exit=0.**

~~~bash
wc -l verdicts/tb7-r1.md verdicts/tb6-r4.md briefs/93-tb7-repair-r1-tb6-repair-r4.md briefs/93-tb7-repair-r1-tb6-repair-r4.last.md; cat verdicts/tb7-r1.md
~~~

**Command 4; exit=0.**

~~~bash
cat verdicts/tb6-r4.md
~~~

**Command 5; exit=0.**

~~~bash
nl -ba verdicts/tb7-r1.md | sed -n '1,205p'
~~~

**Command 6; exit=0.**

~~~bash
nl -ba verdicts/tb7-r1.md | sed -n '206,430p'
~~~

**Command 7; exit=0.**

~~~bash
nl -ba verdicts/tb7-r1.md | sed -n '431,584p'; nl -ba verdicts/tb6-r4.md | sed -n '1,130p'
~~~

**Command 8; exit=0.**

~~~bash
nl -ba verdicts/tb6-r4.md | sed -n '131,330p'; nl -ba briefs/93-tb7-repair-r1-tb6-repair-r4.md; nl -ba briefs/93-tb7-repair-r1-tb6-repair-r4.last.md
~~~

**Command 9; exit=0.**

~~~bash
git diff --stat 2fa15e4 78b2dce -- src test docs/DESIGN.md
~~~

**Command 10; exit=0.**

~~~bash
git diff 2fa15e4 78b2dce -- src test docs/DESIGN.md > /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/change.diff
~~~

**Command 11; exit=0.**

~~~bash
cat verdicts/tb7-r2-pre.md; rg --files /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a
~~~

**Command 12; exit=0.**

~~~bash
sed -n '1,420p' /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/change.diff
~~~

**Command 13; exit=0.**

~~~bash
sed -n '115,235p' /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/change.diff; sed -n '421,660p' /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/change.diff
~~~

**Command 14; exit=0.**

~~~bash
sed -n '661,920p' /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/change.diff
~~~

**Command 15; exit=0.**

~~~bash
sed -n '921,1195p' /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/change.diff
~~~

**Command 16; exit=0.**

~~~bash
sed -n '1196,1450p' /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/change.diff
~~~

**Command 17; exit=0.**

~~~bash
sed -n '1451,1760p' /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/change.diff
~~~

**Command 18; exit=0.**

~~~bash
sed -n '1761,1830p' /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/change.diff; sed -n '80,115p' /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/change.diff
~~~

**Command 19; exit=0.**

~~~bash
nl -ba ground-truth/gt-08-introspection.tex | sed -n '401,534p;757,776p'
~~~

**Command 20; exit=0.**

~~~bash
nl -ba ground-truth/gt-12-compression.tex | sed -n '26,147p;263,359p'
~~~

**Command 21; exit=0.**

~~~bash
nl -ba ground-truth/gt-10-answer-reduction.tex | sed -n '1948,2068p'; nl -ba ground-truth/gt-11-parallel-repetition.tex | sed -n '80,136p;194,258p'
~~~

**Command 22; exit=0.**

~~~bash
cat /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/runner_probe.jl; nl -ba test/mutations/run.jl | sed -n '290,340p;437,510p;535,630p'
~~~

**Command 23; exit=0.**

~~~bash
nl -ba src/certificates.jl; nl -ba src/policy/policy.jl | sed -n '90,190p'; rg -n 'function _relocate|_bound_replay|facts=.*(ast|expected)|4 of 9|4/9|Pauli.*execute|Pauli predicates' src docs/DESIGN.md
~~~

**Command 24; exit=1.**

~~~bash
nice -n 10 timeout 240 env JULIA_NUM_THREADS=2 julia --startup-file=no --project=. /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/runner_probe.jl > /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/runner_probe.log 2>&1
~~~

**Command 25; exit=0.**

~~~bash
nl -ba test/tb6b_introspect.jl | sed -n '1,90p;1040,1188p;1230,1315p'; nl -ba test/calibration.jl | sed -n '1,150p'
~~~

**Command 26; exit=0.**

~~~bash
nl -ba src/compress/compress7.jl | sed -n '1,150p;454,512p'; nl -ba src/ir/programs.jl | sed -n '570,595p'; nl -ba src/introspect/intro_decider.jl | sed -n '225,277p;457,495p'; nl -ba src/descriptions/types.jl | sed -n '1,40p'
~~~

**Command 27; exit=0.**

~~~bash
cat /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/runner_probe.log
~~~

**Command 28; exit=0.**

~~~bash
rg -n 'calibrated_gate|ratio|transcript_seconds|tb6b_M|BODY_STARTED|TB4_RATIO|round' test/tb5_repeat.jl test/tb6a_audit.jl test/tb6b_introspect.jl test/tb4_compress_ir.jl test/tb7_compress.jl test/runtests.jl; rg -n 'description_length\(.*Verifier|fixed_slot_fits|function decider_term_bytes' src; nl -ba src/compress/answer_reduce.jl | sed -n '328,391p'; nl -ba src/descriptions/transformations.jl | sed -n '130,150p'
~~~

**Command 29; exit=2.**

~~~bash
nl -ba docs/DESIGN.md | sed -n '2037,2065p'; rg -n '\\abs\{\\verifier\}|description length.*verifier|\\max.*sampler.*decider' ground-truth/gt-06-nonlocal-games.tex ground-truth/gt-03-prelim.tex
~~~

**Command 30; exit=0.**

~~~bash
rg -n 'description length|\\max|\\abs\{\\verifier\}' ground-truth/gt-06-types.tex | head -35; nl -ba src/descriptions/deciders.jl | sed -n '68,105p'; nl -ba src/descriptions/sorts.jl | sed -n '139,161p'; nl -ba test/mutations/run.jl | sed -n '37,65p;362,437p'
~~~

**Command 31; exit=1.**

~~~bash
nice -n 10 timeout 240 env JULIA_NUM_THREADS=2 julia --startup-file=no --project=. /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/certificate_probe.jl > /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/certificate_probe.log 2>&1
~~~

**Command 32; exit=0.**

~~~bash
rg -n '_intro_ordered|parse_intro_answer' src/introspect/intro_decider.jl; rg --files ground-truth | head -16; rg -n 'description length|\\max.*\\abs|\\abs.*\\max' ground-truth/gt-05-normal-form.tex ground-truth/gt-02-overview.tex; nl -ba test/tb6b_introspect.jl | sed -n '980,1049p'; nl -ba test/tb7_compress.jl | sed -n '1,21p;250,279p'
~~~

**Command 33; exit=0.**

~~~bash
cat /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/certificate_probe.log
~~~

**Command 34; exit=0.**

~~~bash
rg -n 'description length|\\max' ground-truth/gt-05-games-normalform.tex | head -30; nl -ba src/introspect/intro_decider.jl | sed -n '593,637p'; nl -ba src/compress/fixed_point.jl | sed -n '51,108p'; nl -ba src/compress/lowering.jl | sed -n '125,156p'; nl -ba src/frontend/fixture.jl | sed -n '1,80p'
~~~

**Command 35; exit=0.**

~~~bash
sed -n '60,84p' /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/change.diff; rg -n 'struct FrontEndFixture|FrontEndFixture\(' src; rg -n '4 of 9|4/9|of 9|all.*status|status.*owned' docs/DESIGN.md
~~~

**Command 36; exit=0.**

~~~bash
ps -eo pid,ppid,etime,stat,comm,args | rg '(certificate_probe|julia|timeout 240)'
~~~

**Command 37; exit=0.**

~~~bash
nl -ba ground-truth/gt-05-games-normalform.tex | sed -n '612,636p'; nl -ba src/compress.jl | sed -n '493,528p'; nl -ba test/tb6b_introspect.jl | sed -n '1188,1238p'
~~~

**Command 38; exit=0.**

~~~bash
tail -n 12 /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/certificate_probe.log
~~~

**Command 39; exit=0.**

~~~bash
sed -n '1,30p' /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/certificate_probe.log
~~~

**Command 40; exit=1.**

~~~bash
nice -n 10 timeout 240 env JULIA_NUM_THREADS=2 julia --startup-file=no --project=. /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/tail_probe.jl > /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/tail_probe.log 2>&1
~~~

**Command 41; exit=0.**

~~~bash
nl -ba src/compress/lowering.jl | sed -n '1,45p'; nl -ba src/compress/fixed_point.jl | sed -n '1,51p'; nl -ba test/mutations/tb7_compress.jl | sed -n '1,124p'
~~~

**Command 42; exit=0.**

~~~bash
nl -ba src/descriptions/machines.jl | sed -n '470,530p'; nl -ba src/compress/answer_reduce.jl | sed -n '177,247p'; nl -ba docs/DESIGN.md | sed -n '1997,2011p'
~~~

**Command 43; exit=0.**

~~~bash
tail -n 12 /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/tail_probe.log
~~~

**Command 44; exit=0.**

~~~bash
nl -ba ground-truth/gt-12-compression.tex | sed -n '426,455p'; nl -ba ground-truth/gt-10-answer-reduction.tex | sed -n '1226,1253p;1396,1422p'; nl -ba src/frontend/decouple5.jl | sed -n '1,30p'
~~~

**Command 45; exit=2.**

~~~bash
nl -ba src/policy/parameters.jl | sed -n '1,30p'; rg -n 'P_growth|gamma \+ 3|gamma.*log2' src/policy.jl src/policy src
~~~

**Command 46; exit=0.**

~~~bash
python3 - <<'PY'
from fractions import Fraction
for k in (4,18,21):
    c=Fraction(1,100000)
    elapsed=(k+1)*c+Fraction(1,1000000)
    rounded=round(float(elapsed),3)
    print('ROUNDING k=%d c=%s elapsed=%s loop_done=%d rounded=%s ratio_ok=%d' % (k,c,elapsed,elapsed>(k+1)*c,rounded,rounded/float(c)<k))
d1=(1+len(str(2))+142+142+3+3)+272+81*272+1+(2+6+6+3+3)
d1b=(1+len(bin(2)[2:])+142+142+3+3)+272+81*272+1+(2+6+6+3+3)
print('DESIGN_DEPTH1_LITERAL=%d BINARY=%d DEPTH2=%d TOTAL=%d' %(d1,d1b,114+5+8+2,d1b+129))
PY
~~~

**Command 47; exit=0.**

~~~bash
cat /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/tail_probe.log
~~~

**Command 48; exit=1.**

~~~bash
nice -n 10 timeout 240 env JULIA_NUM_THREADS=2 julia --startup-file=no --project=. /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/semantic_probe.jl > /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/semantic_probe.log 2>&1
~~~

**Command 49; exit=0.**

~~~bash
rg -n -A 1 'Test Summary' /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/{base_negative,base_edges,parity_negative,parity_edges}.log; nl -ba src/descriptions/deciders.jl | sed -n '245,279p'; nl -ba src/descriptions/machines.jl | sed -n '740,789p'
~~~

**Command 50; exit=0.**

~~~bash
nl -ba src/introspect/intro_decider.jl | sed -n '533,581p'; nl -ba src/compress/compress7.jl | sed -n '239,270p'; nl -ba test/tb7_compress.jl | sed -n '66,124p'; nl -ba src/introspect/introspect.jl | sed -n '12,115p'
~~~

**Command 51; exit=0.**

~~~bash
cat /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/semantic_probe.log
~~~

**Command 52; exit=0.**

~~~bash
git diff --quiet 78b2dce -- src test docs/DESIGN.md
~~~

**Command 53; exit=0.**

~~~bash
python3 /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/finish_verdict.py
~~~

**Command 54; exit=0.**

~~~bash
nl -ba verdicts/tb7-r2-pre.md | sed -n '1,170p'; wc -l verdicts/tb7-r2-pre.md
~~~

**Command 55; exit=0.**

~~~bash
python3 /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/append_ledger.py
~~~

The runner probe also launched exactly one child, through its verbatim run_isolated call and prefixed Base.julia_cmd template above: child exit=19, assertions pass/fail/error=1/0/0. This is included in the five-process total. Its environment used a per-run nonce and a result path under runner-child/; no registry driver was launched.

File-edit operations (apply_patch, success=1 unless indicated):

- apply_patch verdict interim: success
- apply_patch certificate_probe.jl: success
- apply_patch tail_probe.jl: success
- apply_patch verdict P97-1: success
- apply_patch semantic_probe.jl: success
- apply_patch semantic probe m field: success
- apply_patch verdict P97-2 P97-3: success
- apply_patch verdict P97-4 P97-5: success
- apply_patch fallback_red_NOT_RUN.jl: success
- functions.exec draft assembly syntax failure before tool execution: 1
- apply_patch verdict_tail.txt finish_verdict.py: success
- apply_patch append_ledger.py command_ledger.json: success

The final assembly and validation below wrote only this verdict and its scratch manifest/script; assembly success=1. No frozen src/test/DESIGN file was edited. Final deliverable is this file; scratch contains the five reproduced scripts, their outputs, the scoped diff and assembly/ledger files. No commit, push, bd update, claims edit, full suite, full registry, measured gate, or benchmark was performed. P97-5 remains a static counterexample with an unexecuted regression; all expensive closing work remains assigned above to brief 97.

**Command 56; exit=0.** Final wording correction: sequential top-level probes; the runner parent and child coexist while the parent waits. apply_patch of this correction script succeeded (1).

~~~bash
python3 /tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b97a/finalize_correction.py
~~~

Final command totals: 56 shell invocations; exit 0 = 50, exit 1 = 4, exit 2 = 2. One additional Julia child launched by the runner probe exited 19. Julia processes = 5. Reproducer blocks = 5; prior-discharge rows = 11; objections = 7 (5 MAJOR, 2 MINOR); validation errors = 0.

PRE-VERDICT: DEFECTS(P97-1,P97-2,P97-3,P97-4,P97-5,P97-6,P97-7)
