**TB7 r1 — adversarial review of brief 44 + addenda, archive `2fa15e4`.** C15 is **HOLD**. The arithmetic and the actual description chaining reproduce; the advertised evidence does not yet support TESTED.

1. **T7-1 — MAJOR · `src/policy/policy.jl:146–157`; `src/compress/answer_reduce.jl:297–326`; `src/compress/compress7.jl:240–285`.** `ToyContractAudit` calls a report with only NOT_EVALUABLE or VACUOUS premises eligible: both new refusal assertions fail. `answer_reduce_predicates` prints row 11 PASS for an unpadded trivial D1 and `sigma=-1`; its status is a literal. Row 7 also remains NOT_EVALUABLE when `gamma=2`, although the package's independently transcribed growth lower bound definitely fails: `11 <= 5 log₂6 = 12.9248…`. Rows 8, 9 and 10 are literal FAIL/FAIL/NOT_EXECUTED cells, not status computations linked to attached evidence. Their default TB7 outcomes are justified, but the grade-recompute closure merely reruns the same literals.

**FIX DEMAND:** derive each status from the owned evidence, propagate known failure through grouped predicates, validate fixed-width/size equality, and permit theorem eligibility only when every required premise is discharged.

**SURVIVING WEAKER STATEMENT:** the default numerical failure witnesses for embedding, canonical parameters, PCP content and repeat count are correct; this report is not a general red-capable policy checker.

2. **T7-2 — MAJOR · `src/certificates.jl:37–64`; `src/compress/compress7.jl:375–492`.** I walked and individually replayed all 133 CHECKED nodes. Forging their recorded facts changes **none** of the replay outcomes: 131 true→true, 2 false→false. In particular `FixedWidthSigma.sigma_1=-1` still verifies; deleting the CITED Ent child from `IntroGap` still verifies its remaining subtree. Replays consult closed-over old data or fresh global ASTs rather than the supplied node's facts/children. A copied-source mutation setting `CodeDependencyIndependence.facts.hash="0000000000000000"` survives the entire TB7 rung (83/0/0, one broken); the new hash assertion fails against actual `232697784bfd7f0c`.

**FIX DEMAND:** bind replay to the node's recorded facts and required children, recompute the printed hash, and retain the fact-tamper and missing-child reds plus the stale-hash mutant.

**SURVIVING WEAKER STATEMENT:** many replays recompute their captured original objects; the census counts executable callbacks, not authenticated printed assertions or a fully passing tree.

3. **T7-3 — MAJOR · `src/compress/fixed_point.jl:55–101`; `src/compress/lowering.jl:131–155`; `test/tb7_compress.jl:172–181`.** Two new semantic mutants survive the **entire** TB7 file, each 83 pass / 0 fail / 0 errors / 1 broken. One replaces the actual fixed-point evaluation by evaluation of a constant-true decider. The other discards the supplied decider CODE in `compress_descriptions` and constructs from `trivial_decider()`. All five booleans remain true on the anchor witness. New independent regressions expose both: the first reports 3716 used units versus 181978 from evaluating the returned `D` itself (1 pass / 1 fail); the second embeds `(:Trivial,)` instead of the exact `(:Program, bytes)` supplied (0 pass / 1 fail).

**FIX DEMAND:** register these two survivors and assert actual D execution/provenance and byte-for-byte retention of the supplied decider at the compression primitive boundary.

**SURVIVING WEAKER STATEMENT:** the archived unmutated term really is quoted self-reference and does perform this finite anchor run; the five checks cannot distinguish its execution from a substituted constant or a discarded self description.

4. **T7-4 — MAJOR · `src/compress/compress7.jl:288–315,466–478`; `test/tb7_compress.jl:137–170`; brief 44 DEVIATIONS.** The required chain set must include chains reached by the sixteen final seeds at every primitive/intermediate sampler. It does not: the emitted rows are `tb5-rng4(0x5a)` or exhaustive 64, while final questions use a separate `0x7B7` draw. `ChainCoverage` closes over prior rows and checks their counters; it never propagates those final seeds. The final explicit Factor/Linear assertions are stage 1 on one seed, not a replay of the sampled full chains. `selected` is maximum completed replays per view (e.g. 4), not selected-query count.

**FIX DEMAND:** collect and replay the actual reached child chains from all sixteen final seeds, label seed/view/query counts separately, and make missing final-chain coverage red.

**SURVIVING WEAKER STATEMENT:** the independently declared rng4/exhaustive64 chains pass the finite sampler-validity replays; sixteen full final marginals and stage-1 queries are executed.

5. **T7-5 — MAJOR · `src/compress/compress7.jl:210–211`; `src/introspect/intro_decider.jl:541–544`; gt-08:L757–L763.** The source replaces **the pair** by two trivial machines when `|V|>lambda`. These paths choose S and D independently. On the mandated straddling input, sampler size 546 fits but decider size 34006 does not. The resulting D1 embeds the original nine-dimensional sampler and trivial decider, not the source's trivial pair. The new pristine red fails the sampler substitution assertion; the oversized-size control and trivial-decider assertion pass. Padding disclosure does not disclose this extra construction change.

**FIX DEMAND:** use the single verifier-size predicate to choose both effective components in both construction paths, or explicitly disclose and downgrade this additional source deviation.

**SURVIVING WEAKER STATEMENT:** equal fixed-width lengths and compressed-sampler hashes across the straddling inputs hold; those hash checks say nothing about the effective decider's required input substitution.

6. **T7-6 — MAJOR · `src/introspect/intro_decider.jl:470–490`; `compress7.jl:263–266`; DESIGN §12.5; CLAIMS C15.** The `Q>=s` guard runs **before** Pauli dispatch. At TB7, `2<9`, so it rejects every typed introspection call, including Pauli pairs. My sweep of all 86 Pauli-oriented pairs records **0 Pauli firings / 86**, and the new assertion against the report's “only the Pauli-typed predicates execute at TB7” fails. The published C15 clause contains that same false positive. No TB7 Pauli-decider subtest is rescued by the sampler's Pauli construction nodes or CITED figure leaves.

**FIX DEMAND:** report zero introspection predicate dispatches at this fixture and amend all three layers; separately execute/label any claimed local Pauli predicate evidence, or implement an explicitly adjudicated guard scope change.

**SURVIVING WEAKER STATEMENT:** the Pauli sampler construction and finite sampler queries execute; the whole introspection predicate rejects at embedding before any of its tests dispatch.

7. **T7-7 — MAJOR · `test/mutations/tb7_compress.jl:53–58`; `test/mutations/tb6_introspect.jl:178–185`; required registry.** Two registered body-inflation mutants survive with clean baselines. TB5: kernel 0.8237 s, inflated transcripts 3.221 s, ratio 3.91<4, 478/0/0. TB7: kernel 1.0247 s, inflated body 155.095 s, ratio 151.36<198, 83/0/0 (one broken). Calling the kernel K+1 times does not guarantee K+1 units of the earlier, load-inflated calibration when other workers finish. The required registry therefore exits 1, not the reported final all-killed state.

**FIX DEMAND:** retain deterministic gate-boundary negatives and make body inflation exceed the recorded kernel budget by measured cumulative elapsed time; rerun the required four-job registry without changing K to hide these survivors.

**SURVIVING WEAKER STATEMENT:** all unmutated ratio gates pass and their arithmetic is correct; the present registered negative witnesses are not reliably red under the authorized runner schedule.

8. **T7-8 — MAJOR · `src/compress/answer_reduce.jl:371–407`; `test/tb7_compress.jl:163`.** `AnswerReduceStepsAgreement` is a failed CHECKED node on the pristine tree, not just a tamper target. Its displayed count is 4/9. The stored outcomes and fresh replay show that input consistency, proof consistency, simultaneous axis and simultaneous diagonal all reach `ARGameNotExecuted`: honest_here=false, honest_tb2=true. Nevertheless the checker special-cases only `case==:game`, so it demands honest whole-decider acceptance on those four other cases and returns `CheckResult(false,:answer_reduce_agreement,…)`. The suite asserts only that the node exists. The new replay assertion is RED (0 pass / 1 fail / 0 errors).

**FIX DEMAND:** grade every game-reaching case by its actual NOT_EXECUTED trace, check the executed prefix separately, and assert the local replay's honest result; expose remaining failure rather than counting a failed CHECKED node as agreement evidence.

**SURVIVING WEAKER STATEMENT:** global consistency, input axis, input diagonal and proof individual diagonal are four actual accept/reject agreements; the other five complete decisions reject at the disclosed unexecuted game layer.

9. **T7-9 — MINOR · DESIGN §13.3; CLAIMS C14; HANDOFF resume; brief reports.** DESIGN still calls C12/C13 CONJECTURE although CLAIMS says TESTED. C14 retains 37 mutants, the obsolete no-membership-witness/dropped-timeout limitations and accepting 22633 boundary; actual owned count is 43 and nested completion is 22747. The report/handoff's suite prediction is one assertion too high after the authorized RSS assertion removal. These are stale status/number summaries, not newly derived stronger claims.

**FIX DEMAND:** update those summaries from the eventual adjudicated rows and final run, retaining the current HOLD and arithmetic gaps.

**SURVIVING WEAKER STATEMENT:** C15 is still CONJECTURE and the TB7 worker explicitly calls its output WIP; it has not silently promoted itself.

**Independent arithmetic and census.** Ground truth was read freshly: fig:compress/thm:compression/independence at gt-12:L26–147 and constants at L263–359; the intro answer key and padding at gt-08:L401–534,L757–776; the AR tensor product at gt-10:L1948–1965; anchoring/repetition at gt-11:L80–136,L194–258. No package formula helper was used for these arithmetic derivations.

| construction | independent law | substitution |
|---|---|---|
| levels | Intro=5; AR=max(ell+2,5); Anchor adds 2; Repeat direct sum preserves level | 9→5→7→9 |
| Intro | `(3m_I+3)log₂q_I+4(32+2ell)` | `6+200=206` |
| typed AR | `s1+(2m'_A+6)log₂q_A` | `206+38·11=624` |
| detyped AR | `s_typed+4·|Type_ar|` | `624+216=840` |
| Anchor | `s2+4·2` | 848 |
| Repeat | `k(s2+8)` | `2·848=1696` |
| AR type graph | `3·(3·6)` types; both factor graphs complete with loops, tensor support | 54 types, 54²=2916 oriented edges |
| largest answer | `(m'+6)(m'd+1)` symbols × log₂q | `22·177=3894`; `3894·11=42834` bits |
| Repeat source | `(lambda n)^((1+c')tau)`; guard `(lambda n)^tau` | 4294967296 repetitions versus toy 2; B=65536 |

The fixed-width codec can be counted without its serializer. There are 50 intro labels containing 502 UTF-8 bytes. Outer typing: `4+50·4+502+4+164·4=1366`; inner typing (no edges): 710. Thus `sigma1=1(header)+1(Detype)+1366+1(Typed)+710+1(IntroFixed)+6·4+2(4+32768)=67648`. Padding changes the construction and leaves the paper's length-equality inference CITED.

An independent walk of the archived printed tree and my own recursive walk of the fresh object both give **317 = 34 CONSTRUCTED + 133 CHECKED + 70 CITED + 62 ASSUMED + 18 SOURCE_REPAIR**. The 35 distinct **theorem-like** CITED labels equal DESIGN §13.2's extracted inventory. All 70 nodes' actual `facts.label` values exist in their stated ground-truth files. `CookLevinGeneral` is a rule alias whose actual label is `prop:standard-succinct-sat`; do not grep the alias as a TeX label. The full label set additionally contains eight definition/figure/remark/section anchors: `def:Lperp`, `def:cl-canonical`, `def:typed-sampler`, `fig:decider_pauli`, `fig:intro-decider`, `fig:type-graph-pauli`, `rk:higher-level`, `sec:orac-def`. Exact set equality with the theorem inventory is therefore the theorem-like comparison, not all 43 labels. All 62 ASSUMED nodes have explicit nonempty assumption/disclosure text. No general quantum implication has been proved by these walks. `IntroGap`'s mathematical maximum remains CITED; the checked portion is symbolic syntax/substitution only. T7-2 prevents the recorded facts/child grades from authenticating that boundary.

The new independent D1 front-end execution gives `(T_actual,sigma,m,3SAT,decoupled)=(7,67648,3,10,38)`, and the lowered primitive's literal bytes equal the actual D1 quote. This is the shortest invalid-graph input, not a faithful run at T=2^65536. The latter would require `2^m≥2T`, i.e. `m≥65537`; the local fixture has m=1 and arithmetizes a different 33-byte trivial program. Hence the default `P_pcp_encodes_D1=FAIL` and actual game NOT_EXECUTED are justified, with the advertised owner. They cannot be promoted to successful PCP-content evidence.

The nested meter is independently `depth1=293+272+81·272+1+20=22618`, `depth2=(2+16+14+6+6+3+3+2(2+16+14))+5+8+2=114+15=129`. Total 22747 and both part-way timeout points are detailed in [tb6-r4.md](tb6-r4.md). This is a charged reservation plus child work, not a complete arithmetic account.

**Composition honesty and one real question.** The certificate-stage path is `Introspect(v0)→AnswerReduce(actual v1)→Repeat(actual v2)`. The outer `StubVerifier(:Compress)` is a metadata carrier; `compress` returns the real Repeat payload. The separate `compress_terms` implementation duplicates the entire construction and is what the quoted compression primitive executes. Both embed previous-stage sampler/decider terms as data. The independently selected valid seed uses outer Game/Game, AR `alice,Point_1` on both sides, and intro `Pauli_X` on both sides. Exact outputs have lengths 206/624/840/848/1696; all five byte/vector chaining assertions pass. For Alice, intro/product nonzero positions are `{7,51,57,80,92,157}`; AR adds graph `{19,55:108,181}` and shifts those six by 216; Anchor adds `{1,3,4,7}` and shifts AR by 8; Repeat returns the Anchor vector followed by an identical vector shifted by 848. The AR label is index 19 in the actual product order. This traces actual outputs rather than inter-stage fixtures.

Executed-path constants/fixtures and ownership: ToyPolicy owns the intro/PCP tuples, mu/gamma/tau/c'=1 and repetition override 2 (ASSUMED policy, failures visible). The compact PCP primitive builds its family from those tuple bytes; sigma is carried in its code, not a compiler of D1 content. `frontend_fixture()` supplies the trivial-program local polynomial checks and the degree used by row 6; its `PCPFixtureLocalOnly` ASSUMED parent explicitly owns the surrogate. That fixture is not substituted as v1 or fed into the actual game. The game branch itself is a constant rejection with `ARGameNotExecuted`; rows 9/10 own this construction hole. Fixed-width trivial fallbacks are intended source behavior but currently implemented incorrectly (T7-5). The anchor strategy uses fixed zero answers as a legitimate selected transcript, thereby bypassing all AR/intro game work. Generic COPY/Zero/Pad/Anchor primitives are executable constructors, not replacements for the prior-stage code. Source universal constants are ASTs checked against a separate transcription; the actual toy descriptions use literals. ProductionPolicy throws rather than producing a symbolic description.

**The thirteen report rows, individually adjudicated.**

| row | default cell | ruling |
|---|---|---|
| 1 input field/level/lambda bounded/n≥2 | PASS | structural conjuncts computed and falsifiable; the runtime conjunct is prose, not part of `input_ok`; finite identity/copy controls do not establish the general bound |
| 2 intro admissibility/divisibility/d=1 | PASS | computed from the policy checks; can fail |
| 3 Q≥s | FAIL | computed: 2<9; correct owner |
| 4 canonical tuple/M≥R | FAIL | both have explicit numerical refutations; correct on this tuple |
| 5 non-Pauli schemas | VACUOUS | embedding consequence correct; its positive Pauli-execution detail is false (T7-6) |
| 6 AR six shape/degree checks | PASS | computed and falsifiable, **on the disclosed local fixture**, not D1's formula |
| 7 growth/constants/C0 | NOT_EVALUABLE | correct at gamma=1, but constant cell hides known FAIL at gamma=2 (T7-1) |
| 8 canonical PCP tuple | FAIL | m=1<65537 proves default failure; status literal even when its computed lower-bound witness changes |
| 9 actual PCP content | FAIL | independently confirmed default mismatch; report status literal, not bound to the evidence node |
| 10 actual AR game | NOT_EXECUTED | faithful disclosure of unconditional step-5 rejection; literal status |
| 11 fixed-width sigma | PASS | actual 67648 recomputed; status can still say PASS for sigma=-1/unpadded D1 |
| 12 source repetition count | FAIL | computed, 2≠4294967296; can become PASS on equality |
| 13 component guard | PASS | computed, 848≤65536 and 42834≤65536; can fail |

**Fixed point.** `_fix_unfold` substitutes `Quote(fix,fix.sort)` for the self-code hole. This is a term receiving its own CODE, not a Julia closure. The five checks respectively establish serialization of Fix, a self-quote hash, a separate two-step loop-machine simulation, an independently constructed sampler hash, and an accepting evaluation on a two-component Anchor/Anchor witness. The synthetic fuel boundary is the lowered D1 on empty graph questions; detyping accepts before a typed introspection body is reached. One unfold proves neither infinite value behavior nor faithful recursive PCP-game execution, universal lambda boundedness, a fuel account for unreached arithmetic, or the paper's halting theorem. The two semantic survivors in T7-3 show precisely what the five checks fail to protect.

**DEVIATIONS ruling and discharge.**

| obligation/deviation | ruling |
|---|---|
| no symbolic ProductionPolicy construction; u32 grammar | acceptable limitation **only for an explicitly ToyPolicy-only row**; remains an unmet general API deliverable, with 1 broken assertion; no production theorem/generation claim |
| nested vector/dual/Pauli/PCP arithmetic UNCHARGED | acceptable scoped residue; retain `UNCHARGED(owner=tb7-nested-own-steps)` wherever broader fuel is discussed; reservation tests do not close it |
| primitive chains omit final sixteen seeds | defect blocking the requested TESTED evidence, T7-4 |
| explicit PCP downsize/field alignment | acceptable named SOURCE_REPAIR; concrete dimensions and tensor support reproduce |
| two lambda-byte fixed slots | acceptable named padding repair, scope limited to the repaired byte-independence variant; extra partial-pair fallback is T7-5 |
| constructor order/laws/constants/floor AST | finite transcriptions reproduce; recorded-fact authentication still fails T7-2 |
| certificate census/source labels | independently reproduced; census is not evidence that every checked replay succeeds (T7-8) |
| finite description-level self-reference | real term present, but executed-code/provenance checks need T7-3 regressions |
| common mutation registry | NOT DISCHARGED, 233/235; T7-7 and global runner T6-2 |

**Lockstep.** DESIGN/code/report/HANDOFF agree on 9→5→7→9, typed dimension 624, 206→840→848→1696, 54/2916, 67648, 317 and the grade census. CLAIMS C15 omits the typed intermediate 624 but does not contradict it. The false Pauli-dispatch clause is shared by DESIGN/code-report/C15 and needs all three edits. Brief 44 and HANDOFF correctly call production/charging/coverage WIP, but their earlier all-killed/expected suite numbers are not this run's result. C14's old metering/count/limitation clauses and DESIGN §13.3's statuses need the T7-9 corrections after adjudication.

**C15 — HOLD; no TESTED replacement row authorized.** Missing steps are T7-1 through T7-8: evidence-derived report/eligibility, fact- and child-bound replay, both execution/provenance mutants plus stale-hash registration, reached final-chain coverage, correct pair fallback (or named downgrade), honest zero intro-dispatch reporting, reliable gate reds/green four-job registry, and a passing or explicitly downgraded local agreement replay. The replacement, when authorized, must say ToyPolicy only; actual D1 PCP game and all intro predicate dispatch are not executed here; symbolic production construction and paper sampler-independence/generation/value arguments remain outside local evidence; the named arithmetic remains UNCHARGED. C14 remains HOLD for T6-1/T6-2. C11–C13 retain their priors; **authorized replacement rows: none**.

**Elegance.** (1) `compress_terms` manually repeats the certificate-stage pipeline, including the same fallback bug twice. Use one immutable construction plan emitting terms, with certificate execution as an optional observer. (2) Thirteen hand-written AR/intro guard branches and a second TB2 comparison path encode an applicability/equality table. Use a typed predicate IR with shared bit-codec lowering, while retaining an independently transcribed test oracle. (3) Separate child meters plus after-the-fact `_charge_parent!` and fixed reservations make one mathematical budget a bookkeeping protocol. A shared meter with a stack of active limits and one charge at its real depth removes the timeout-drop class and gives arithmetic a place to be charged.

An author extending the paper needs symbolic index-dependent field/dimension/count laws that can remain descriptions under budget refusal, a faithful quoted-decider-to-PCP compiler with content provenance, and portable rule/data certificates whose checks consume their attached facts. The current literal u32 grammar, duplicated constructors, host replay closures and reserved-but-unaccounted arithmetic cannot supply that general interface. Tiny ToyPolicy construction is useful test infrastructure; extension requires these explicit API boundaries and failure/unknown results, not another fixed tuple and more accepting anchor witnesses.

**Required archive runs.** All reads and Julia execution used the archive of `2fa15e4`, extracted by `git archive 2fa15e4 | tar -x -C <scratch>/tree`. Only these two verdicts are repository writes; no state-changing git command ran. Scratch is `/tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/c4866fe0-7f69-4e1a-8e74-13a22fc59bc5/scratchpad/critic-tb7-r1/`. Runtime observed: Julia **1.12.5**, `nproc=12` (the brief specifies 1.12.3/64 cores). One top-level Julia run at a time; the required registry internally used `MUTATION_JOBS=4`. No gate or source was repaired for this review. A scratch-first depot with the home depot as a read fallback was used; offline `Pkg.instantiate()` succeeded. Initial setup encountered a read-only home depot and an interrupted registry update; neither is test evidence.

`julia --project=. test/runtests.jl`: **exit 0**, 12729 pass / 1 broken (the ProductionPolicy construction assertion), wall 234.992 s:

```text
MIPStarLambda load/precompile seconds = 0.507 (ungated; cold image build: tools/cold_precompile.sh)
TB0 test-body wall seconds = 20.385 (warning=45.0, hard_limit=60.0); calibration kernel = 0.5257 s; ratio = 38.8 (gate 100.0)
TB0 ratio gate: ratio<100.0 => true; wall<60.0 => true
TB4 test-body wall seconds = 4.276; calibration kernel = 0.1866 s; ratio = 22.9 (gate 38.0 = floor(6.0 s / 0.154 s reference in-suite kernel); enforced body budget at this kernel rate = 7.09 s; TB4_BUDGET_SECONDS = Inf; gated)
calibrated gate tb5_construction: elapsed = 0.355 s; kernel = 0.5257 s; ratio = 0.68 (gate K = 4 => budget 2.1 s at this run's rate; quiet 0.533 s, quiet ratio 0.68); absolute ceiling 7.68 s
calibrated gate tb5_transcripts: elapsed = 0.645 s; kernel = 0.5257 s; ratio = 1.23 (gate K = 4 => budget 2.1 s at this run's rate; quiet 0.986 s, quiet ratio 1.26); absolute ceiling 7.68 s
calibrated gate tb5_total: elapsed = 1.0 s; kernel = 0.5257 s; ratio = 1.9 (gate K = 6 => budget 3.15 s at this run's rate; quiet 1.519 s, quiet ratio 1.94); absolute ceiling 11.52 s
calibrated gate tb6a_audit: elapsed = 3.287 s; kernel = 0.5257 s; ratio = 6.25 (gate K = 18 => budget 9.46 s at this run's rate; quiet 2.765 s, quiet ratio 5.76); absolute ceiling 35.0 s
calibrated gate tb6b_E: elapsed = 8.528 s; kernel = 0.5257 s; ratio = 16.22 (gate K = 33 => budget 17.35 s at this run's rate; quiet 8.51 s, quiet ratio 10.88); absolute ceiling 63.36 s
calibrated gate tb6b_M: elapsed = 3.643 s; kernel = 0.5257 s; ratio = 6.93 (gate K = 21 => budget 11.04 s at this run's rate; quiet 5.316 s, quiet ratio 6.79); absolute ceiling 40.32 s
calibrated gate tb6b_combined: elapsed = 12.171 s; kernel = 0.5257 s; ratio = 23.15 (gate K = 54 => budget 28.39 s at this run's rate; quiet 13.826 s, quiet ratio 17.67); absolute ceiling 103.68 s
calibrated gate tb7_total: elapsed = 40.367 s; kernel = 0.5257 s; ratio = 76.78 (gate K = 198 => budget 104.1 s at this run's rate; quiet 51.438 s, quiet ratio 65.9); absolute ceiling 380.16 s
TB7 gate ratio<198 => true uptime= 10:10:57 up 1 day,  8:50,  1 user,  load average: 2.22, 2.07, 1.49
```

`MUTATION_JOBS=4 julia --project=. test/mutations/run.jl`: **exit 1**. The summary and **every non-KILLED disposition**, verbatim:

```text
MUTATION REGISTRY: killed=233/235 baselines ok=93/93 probes refused=2/2 wall=2320.13 s
MUTANT TB5 M5-gate-body-inflated tb5_transcripts_plus_K_kernels target=tb5_gate => SURVIVED (pass/fail/error = 478/0/0) (exit=0, 57.54 s)
MUTANT TB7 M7-gate-body-inflated add_K_kernels_to_body target=tb7_gate => SURVIVED (pass/fail/error = 83/0/0) (exit=0, 158.7 s)
MUTANT PROBE CRIT-R3-crash-outside tb6b_top_level_setup_method_error target=tb6b_nested => KILLED-BY-ERROR (not credited; pass/fail/error = 0/0/1) (exit=1, 4.44 s)
MUTANT PROBE CRIT-R3-crash-inside tb6b_k_setup_method_error target=tb6b_nested => KILLED-BY-ERROR (not credited; pass/fail/error = 0/0/1) (exit=1, 32.52 s)
```

All 43 labels owned by TB6 are assertion-killed in this run. The two survivors above belong to TB5 and TB7. The permanent runner probes are correctly refused. The raw logs of all **93 baseline + 237 mutant/probe processes** are retained in `registry-raw/`; `registry.log` also contains every child output (`MUTATION_VERBOSE=1`). A green baseline does not erase a survivor.

**Additional mutation and red outcomes.** The serial critic launcher exits 0 because it reports outcomes rather than demanding all kills. Its clean full-file baselines are TB6b 9811/0/0 and TB7 83/0/0 with one broken. The three NEW TB7 semantic mutations each SURVIVE that whole TB7 baseline target. New regression file is pristine 4/4; under constant execution it is 1/1/0, under discarded input code 0/1/0, under stale hash 0/1/0. The independent audit gives 5/5 actual chaining controls and 2 pass / 8 fail / 0 errors on the pristine report/certificate/fallback reds. The local agreement replay red is 0/1/0. TB6 new mutation/outcome details are in [tb6-r4.md](tb6-r4.md).

**Reproduction convention.** Extract the same commit into `<scratch>/tree`; save the code blocks under `<scratch>` with their indicated filenames, and run from `tree` with `julia --project=. ../<file>.jl`. Use a writable scratch depot (`JULIA_DEPOT_PATH=<scratch>/depot:/home/tobias/.julia`) and `TMPDIR=<scratch>/tmp`. `CRITIC_PATCH` selects the copied source created by the launcher; no original source is changed. All new mutation definitions and red tests are included below, so the scratch directory is not required for rebuilding the attacks. The full launcher appears in `tb7-r1.md`; it runs the TB6 probes as well and preserves their numeric paths, including `mutant-111` used by `runner_red.jl`.

**`critic_mutations.jl` — verbatim:**

```julia
# Exact archived runner definitions, without its execution driver.
const ARCHIVE_RUNNER=joinpath(@__DIR__,"tree/test/mutations/run.jl")
prefix=first(split(read(ARCHIVE_RUNNER,String),"\nstarted = time()\n"))
for f in readdir(dirname(ARCHIVE_RUNNER))
    endswith(f,".jl") || continue
    global prefix=replace(prefix,"include($(repr(f)))"=>"include($(repr(joinpath(dirname(ARCHIVE_RUNNER),f))))")
end
include_string(Main,prefix,ARCHIVE_RUNNER)
println("CRITIC_OWNED_TB6_COUNT=",count(m->startswith(m.label,"TB6 "),TB6_QUEUE))
const VLINE="_in_V(v::AbstractVector{Bool}, s::Int) = all(!v[i] for i in s+1:length(v))"
const CRITIC_MUTANTS=[
    Mutant("CRIT tail-odd", "src/introspect/intro_decider.jl",VLINE,
           "_in_V(v::AbstractVector{Bool}, s::Int) = all(!v[i] for i in s+1:length(v) if isodd(i))", "tb6b_negative"),
    Mutant("CRIT tail-except-Q", "src/introspect/intro_decider.jl",VLINE,
           "_in_V(v::AbstractVector{Bool}, s::Int) = all(!v[i] for i in s+1:length(v)-1)", "tb6b_negative"),
    Mutant("CRIT tail-except-interior", "src/introspect/intro_decider.jl",VLINE,
           "_in_V(v::AbstractVector{Bool}, s::Int) = all(!v[i] for i in s+1:length(v) if i != s+3)", "all_tb6"),
    Mutant("CRIT fixedpoint-constant-execution", "src/compress/fixed_point.jl",
           "    outcome = eval_quoted(D, args, fuel; hard_cap=max(fuel, DEFAULT_HARD_CAP))",
           "    outcome = eval_quoted(quote_program(Lambda(5, Prim(true, Concrete(1), ())); sort=:Decider).term, args, fuel; hard_cap=max(fuel, DEFAULT_HARD_CAP))", "all_tb7"),
    Mutant("CRIT compressor-discards-self-code", "src/compress/lowering.jl",
           "VerifierDescription(decode_sampler(S_bytes), lift_decider(Quoted{:Decider}(_quoted_bytes(D_program, :Decider))).term)",
           "VerifierDescription(decode_sampler(S_bytes), trivial_decider().term)", "all_tb7"),
    Mutant("CRIT stale-output-hash", "src/compress/compress7.jl",
           "dependencies=deps, hash=quote_hash(out.sampler)",
           "dependencies=deps, hash=\"0000000000000000\"", "all_tb7"),
    Mutant("CRIT runner-error-inside","test/tb6b_introspect.jl",
           "        D_nested = I.decider.term", "        getindex(1, \"critic_bad_index\")\n        D_nested = I.decider.term", "tb6b_nested"),
    Mutant("CRIT runner-crash-outside","test/tb6b_introspect.jl",
           "const TB6B_F_CHILD = 65_536\n", "const TB6B_F_CHILD = 65_536\nexit(19)\n", "tb6b_nested"),
    Mutant("CRIT runner-unrelated-error","test/tb6b_introspect.jl",
           "        D_nested = I.decider.term", "        @testset \"unrelated error\" begin\n            getindex(1, \"unrelated\")\n        end\n        D_nested = I.decider.term", "tb6b_nested"),
    Mutant("CRIT runner-print-Test-Failed","test/tb6b_introspect.jl",
           "        D_nested = I.decider.term", "        println(\"Test Failed\")\n        D_nested = I.decider.term", "tb6b_nested"),
    Mutant("CRIT runner-forged-tally","test/tb6b_introspect.jl",
           "        D_nested = I.decider.term", "        println(\"MUTANT_TALLY pass=0 fail=1 error=0 broken=0\")\n        getindex(1, \"critic_bad_index\")\n        D_nested = I.decider.term", "tb6b_nested"),
]
# Make all_tb6/all_tb7 select the WHOLE rung (the native driver uses a family prefix).
@eval function _rung(m::Mutant)
    m.target == "all_tb6" && return (:tb6b,"tb6b_introspect.jl","TB6B_TARGET","all")
    m.target == "all_tb7" && return (:tb7,"tb7_compress.jl","TB7_TARGET","all")
    startswith(m.target,"tb6b_") && return (:tb6b,"tb6b_introspect.jl","TB6B_TARGET",m.target)
    startswith(m.target,"tb7_") && return (:tb7,"tb7_compress.jl","TB7_TARGET",m.target)
    error("unexpected critic target")
end
const CRITIC_TMP=joinpath(@__DIR__,"critic-registry")
mkpath(CRITIC_TMP)
bases=Dict{Any,Any}()
for (i,m) in enumerate(CRITIC_MUTANTS)
    key=baseline_key(m)
    if !haskey(bases,key)
        println("UPTIME before baseline ",key," ",strip(read(`uptime`,String)))
        bases[key]=unmutated_baseline(key,i,CRITIC_TMP)
        println("UPTIME after baseline ",key," ",strip(read(`uptime`,String)))
    end
    println("UPTIME before ",m.label," ",strip(read(`uptime`,String)))
    r=isolated_mutant(m,i+100,CRITIC_TMP)
    d=disposition(m,r,bases[key])
    println("CRITIC ",m.label," => ",d.label," exit=",r.exitcode)
    println("UPTIME after ",m.label," ",strip(read(`uptime`,String)))
end
```

**`tb7_regression.jl` — verbatim:**

```julia
using Test, MIPStarLambda
const A=MIPStarLambda
patch=get(ENV,"CRITIC_PATCH","")
!isempty(patch) && Base.include(A,patch)
mode=get(ENV,"CRIT_RED","all")
@testset "critic TB7 regressions" begin
    if mode in ("all","compressor")
        S=tb7_input_verifier().sampler
        dp=Lambda(5,Prim(false,Concrete(1),()))
        pair=A._quoted_pair(Code(lower_sampler(S),:Sampler),Code(dp,:Decider))
        code,_=A._run_compress_descriptions(pair,32768,A.policy_bytes(TB7_TOY_POLICY),1_000_000)
        term=A.decode_decider_term(A.lowered_bytes(code.program))
        D2=term[end][4][2]
        D1=D2[4][3][12]
        actual_child=D1[4][3][9]
        expected_child=lift_decider(quote_program(dp;sort=:Decider).term).term.term
        @test actual_child==expected_child
    end
    if mode in ("all","fixedpoint")
        run=halting_fixed_point(32768)
        t=run.transcript
        actual=eval_quoted(run.D,(2,t.x,t.y,t.a,t.b),600_000;hard_cap=600_000)
        @test run.outcome.used==actual.used
        @test run.outcome.result.value==actual.result.value
    end
    if mode in ("all","hash")
        C=compress(tb7_input_verifier(),32768;policy=TB7_TOY_POLICY,tracer_index=2,seeds=4)
        n=only(n for n in A._nodes(C.certificate) if n.rule==:CodeDependencyIndependence)
        @test n.facts.hash==A.quote_hash(C.term.sampler)
    end
end
```

**`tb7_audit.jl` — verbatim:**

```julia
using Test, MIPStarLambda
const A=MIPStarLambda
V=tb7_input_verifier()
C=compress(V,32768;policy=TB7_TOY_POLICY,tracer_index=2,seeds=4)
function critic_walk(n,out=CertNode[])
    push!(out,n)
    for child in n.children
        critic_walk(child,out)
    end
    out
end
ns=critic_walk(C.certificate)
println("LIVE_CENSUS ",length(ns)," ",[(g,count(n->n.grade==g,ns)) for g in instances(Grade)])
for n in ns
    n.grade==CITED || continue
    l=get(n.facts,:label,string(n.rule)); source=get(n.facts,:source,"")
    found=!isempty(source) && occursin("\\label{"*l*"}",read(joinpath(@__DIR__,"tree/ground-truth",source),String))
    println("CITED_EXISTS ",l," ",found)
end
println("ASSUMED_NAMED ",all(n->haskey(n.facts,:display)&&!isempty(n.facts.display),filter(n->n.grade==ASSUMED,ns)))
for n in filter(n->n.rule==:P_pcp_encodes_D1,ns)
    println("ACTUAL_D1 ",n.facts)
end
sk=C.certificate.facts.skeleton
v3=sk.input; v2=v3.input; v1=v2.input
println("COMPOSITION_BYTES ",canonical_bytes(v2.payload.sampler.parts[1].parts[1].parts[1])==canonical_bytes(v1.payload.sampler))
println("DECLARED_QUERY_ROWS ",chain_coverage_text(chain_coverage(C.certificate)))
println("CERTIFICATE_RESULT ",verify_certificate(C))
checked=filter(n->n.grade==CHECKED,ns)
# Each archived replay is evaluated independently; otherwise ToyContractAudit
# short-circuits the root before most of this tree is visited.
for (i,n) in enumerate(checked)
    r=n.replay(C.term)
    f=merge(n.facts,(;display="FORGED checked assertion",critic_forged=true))
    haskey(f,:sigma_1) && (f=merge(f,(;sigma_1=-1)))
    haskey(f,:ast) && (f=merge(f,(;ast=:(false))))
    haskey(f,:hash) && (f=merge(f,(;hash="0000000000000000")))
    haskey(f,:expected) && (f=merge(f,(;expected=:forged)))
    haskey(f,:rows) && (f=merge(f,(;rows=NamedTuple[])))
    forged=CertNode(n.grade,n.rule;facts=f,children=n.children,replay=n.replay)
    rr=forged.replay(C.term)
    println("CHECKED_FACT_TAMPER ",i," ",n.rule," original=",passed(r)," forged=",passed(rr))
end
p=A.tb7_predicate_report(V,32768,2,TB7_TOY_POLICY,v1,v2,v3,only(n for n in ns if n.rule==:toy_override&&haskey(n.facts,:predicates)&&length(n.facts.predicates)==4).facts.predicates)
println("POLICY_ROWS\n",predicate_report_table(p))
D1=v1.payload.decider
body=D1.term[4][3]
q=quote_program(lower_decider(D1);sort=:Decider)
args=(2,Bool[],Bool[],Bool[true],Bool[false])
probe=bounded_trace(q,args,256)
T=findfirst(r->r.outcome!=:running,probe.term.configurations)-1
trace=bounded_trace(q,args,T)
sat=cook_levin(trace;gate_budget=1<<20)
dec=decouple5(sat;gate_budget=1<<20)
println("RECOMPUTED_D1_FRONTEND ",(T,description_size(D1),sat.term.index_width,length(sat.term.clauses),length(dec.term.clauses))," lower literal matches=",A.lowered_bytes(lower_decider(D1))==canonical_bytes(D1))
pauli_edges=[e for e in A.intro_typing(9).edges if all(A.is_pauli_label,e)]
pauli_fired=0
for (l,r) in pauli_edges
    z=Bool[false for _ in 1:6]
    pp=A.PauliParams(2,1,1)
    la=Vector{Bool}(falses(A.answer_schema(pp,l).bits)); ra=Vector{Bool}(falses(A.answer_schema(pp,r).bits))
    bit,trace,fired=A.intro_decide_traced(body,2,l,z,r,z,la,ra)
    global pauli_fired+=:pauli in fired
end
println("TB7_INTRO_PAULI_FIRED=",pauli_fired,"/",length(pauli_edges))
# One real final question, not a fixture between transformations: construct
# Game/Game at the outer graph, alice/Point_1 at AR, Pauli_X at intro.
function graph_seed(typing,l,r,body)
    T=length(typing.labels)
    li=findfirst(==(l),typing.labels); ri=findfirst(==(r),typing.labels)
    unit(i)=GF2[GF2(j==i) for j in 1:T]
    neigh(i)=GF2[GF2((typing.labels[i],typing.labels[j]) in typing.edges) for j in 1:T]
    vcat(unit(li),neigh(li),unit(ri),neigh(ri),body)
end
S1=v1.payload.sampler
s1typed=S1.parts[1]
z_intro=graph_seed(s1typed.typing,"Pauli_X","Pauli_X",fill(GF2(0),6))
z_product=vcat(z_intro,fill(GF2(0),418))
prod=v2.payload.sampler.parts[1]
z_ar=graph_seed(prod.typing,"alice,Point_1","alice,Point_1",z_product)
anchored=v3.payload.sampler.parts[1]
z_anch=graph_seed(A.ANCHOR_TYPING,"Game","Game",z_ar)
z_final=vcat(z_anch,z_anch)
qx,qy=sample_questions(C.term.sampler,2,z_final)
qi=sample_questions(S1,2,z_intro)
qt=sample_questions(prod,2,z_product,("alice,Point_1","alice,Point_1"))
q2=sample_questions(v2.payload.sampler,2,z_ar)
qa=sample_questions(anchored,2,z_anch)
println("END_TO_END nonzero positions intro=",findall(!iszero,qi[1])," product=",findall(!iszero,qt[1])," AR=",findall(!iszero,q2[1])," anchor=",findall(!iszero,qa[1])," final=",findall(!iszero,qx))
@testset "actual output chaining" begin
    @test length(qi[1])==206 && length(qt[1])==624 && length(q2[1])==840 && length(qa[1])==848 && length(qx)==1696
    @test qt[1][1:206]==qi[1]
    @test q2[1][217:end]==qt[1]
    @test qa[1][9:end]==q2[1]
    @test qx==vcat(qa[1],qa[1]) && qy==vcat(qa[2],qa[2])
end
# These are new RED assertions against the current recorded certificate and
# report, deliberately made after the independent computations above.
@testset "critic red surface" begin
    for status in (:NOT_EVALUABLE,:VACUOUS)
        audit=A.toy_contract_audit_node([PolicyPredicate("missing production premise",status;owner="critic")])
        @test !passed(audit.replay(C.term))
    end
    fx=A.frontend_fixture()
    wrong=A.answer_reduce_predicates(A.trivial_verifier_description(),TB7_TOY_POLICY.pcp_tuple,-1,32768,1,1,2,TB7_TOY_POLICY,fx)
    @test last(wrong).status!=:PASS
    a2=PCPParams(2048,11,1,11,6,16,2)
    p2=ToyPolicy(;intro_tuple=TB7_TOY_POLICY.intro_tuple,pcp_tuple=a2,gamma=2,repetitions=2)
    known_failure=A.answer_reduce_predicates(v1.payload,a2,description_size(v1.payload.decider),32768,1,2,2,p2,fx)
    @test known_failure[2].status==:FAIL # 11 <= (2+3)log2(6), so P_growth definitely FAILS
    sigma=only(n for n in ns if n.rule==:FixedWidthSigma)
    forged=CertNode(CHECKED,sigma.rule;facts=merge(sigma.facts,(;sigma_1=-1)),children=sigma.children,replay=sigma.replay)
    @test !passed(A._verify_node(forged,C.term))
    gap=only(n for n in ns if n.rule==:IntroGap)
    drop=CertNode(CHECKED,gap.rule;facts=gap.facts,children=(first(gap.children),),replay=gap.replay)
    @test !passed(A._verify_node(drop,C.term))
    @test pauli_fired>0  # report: "only the Pauli-typed predicates execute"
    large=tb7_input_verifier_large()
    I=introspect(large,32768,9;tuple=TB7_TOY_POLICY.intro_tuple,fixed_width=true,tracer_index=2,seeds=0).term
    effective=I.decider.term[4][3]
    @test description_length(large)>32768
    @test effective[8]==TRIVIAL_SAMPLER_TERM
    @test effective[9]==TRIVIAL_DECIDER_TERM
end
```

**`agreement_probe.jl` — verbatim:**

```julia
using Test, MIPStarLambda
const A=MIPStarLambda
C=compress(tb7_input_verifier(),32768;policy=TB7_TOY_POLICY,tracer_index=2,seeds=4)
function walk(n,out=CertNode[])
 push!(out,n)
 for child in n.children; walk(child,out); end
 out
end
for n in walk(C.certificate)
 n.rule==:AnswerReduceStepsAgreement || continue
 println("AGREEMENT_DISPLAY ",n.facts.display)
 println("AGREEMENT_REPLAY ",n.replay(C.term))
 @testset "local agreement replay must match its advertised CHECKED result" begin
     @test passed(n.replay(C.term))
 end
 for r in n.facts.outcomes; println("AGREEMENT_CASE ",r); end
end
```

**`independent.py` — verbatim:**

```python
from pathlib import Path
import re, collections
root=Path(__file__).parent/'tree'
cert=(root/'briefs/44-tb7-compress.certificate.md').read_text().split('```text')[1].split('```')[0]
nodes=re.findall(r'\b(CONSTRUCTED|CHECKED|CITED|ASSUMED|SOURCE_REPAIR) ([^\s]+)',cert)
print('ARCHIVED_PRINT_CENSUS',len(nodes),dict(collections.Counter(g for g,r in nodes)))
labels={r for g,r in nodes if g=='CITED'}
theorems={x for x in labels if x.startswith(('lem:','thm:','prop:','cor:'))}
design=(root/'docs/DESIGN.md').read_text().split('### 13.2')[1].split('### 13.3')[0].split('`lem:commute` is a source anchor')[0]
inv=set(re.findall(r'`((?:lem|thm|prop|cor):[^`]+)`',design))
print('CITED_THEOREM_SET',len(theorems),'DESIGN',len(inv),'missing',inv-theorems,'phantom',theorems-inv)
tex='\n'.join(p.read_text() for p in (root/'ground-truth').glob('gt-*.tex'))
print('ALL_CITED',len(labels),'missing_ground_truth',sorted(x for x in labels if not re.search(r'\\label\{'+re.escape(x)+r'\}',tex)))
print('non_theorem_anchors',sorted(labels-theorems))
p=[f'{k}_{b}' for k in ('Point','ALine','DLine','Pauli','Pair') for b in ('X','Z')]+[f'Constraint_{i}' for i in range(1,7)]+[f'Variable_{j}' for j in range(1,10)]+['Pair']
ls=p+[x for role in ('alice','bob') for x in ([f'{k}_{role}' for k in ('Introspect','Sample','Read')]+[f'Hide_{k}_{role}' for k in range(1,10)])]
labelbytes=sum(len(x.encode()) for x in ls)
typing=lambda E:4+sum(4+len(x.encode()) for x in ls)+4+4*E
sigma=1+1+typing(164)+1+typing(0)+1+6*4+2*(4+32768)
print('SIGMA_INDEPENDENT labels=',len(ls),'labelbytes=',labelbytes,'typing164=',typing(164),'typing0=',typing(0),'sigma=',sigma)
print('LAWS',[(3*1+3)*1+4*(32+18),206+(2*16+6)*11,624+4*(3*18),840+4*2,2*(840+8)])
print('ANS_SYMBOLS',(16+6)*(16*11+1),'ANS_BITS',(16+6)*(16*11+1)*11,'source_k',(32768*2)**2)
```

**Runs and load, verbatim.** `BEFORE`/`AFTER` are `uptime` around each top-level Julia run. The additional child records cover the serial critic baselines and mutants. Early launcher failures (relative include, then Julia global-scope assignment), the first audit's global-scope error, and missing-patch follow-ups are retained as **harness errors, with no kill/red-test credit**; the successful launcher is `critic_mutations3`, and substantive follow-ups have suffix `2`.

```text
 10:01:44 up 1 day,  8:41,  1 user,  load average: 0.90, 0.82, 0.77
 10:04:09 up 1 day,  8:44,  1 user,  load average: 2.03, 1.41, 1.00
interrupted_registry_update=130

 10:04:09 up 1 day,  8:44,  1 user,  load average: 2.03, 1.41, 1.00
 10:06:05 up 1 day,  8:46,  1 user,  load average: 4.31, 2.30, 1.37
exit=0

suite
BEFORE 10:07:02 up 1 day,  8:47,  1 user,  load average: 2.66, 2.16, 1.37
AFTER 10:10:57 up 1 day,  8:50,  1 user,  load average: 2.22, 2.07, 1.49
exit=0 wall=234.992

registry
BEFORE 10:11:56 up 1 day,  8:51,  1 user,  load average: 1.31, 1.83, 1.45
AFTER 10:50:37 up 1 day,  9:30,  1 user,  load average: 1.15, 2.20, 3.14
exit=1 wall=2321.668

critic_mutations
BEFORE 10:50:38 up 1 day,  9:30,  1 user,  load average: 1.15, 2.20, 3.14
AFTER 10:50:40 up 1 day,  9:30,  1 user,  load average: 1.15, 2.20, 3.14
exit=1 wall=1.179

tb6_attack
BEFORE 10:50:40 up 1 day,  9:30,  1 user,  load average: 1.15, 2.20, 3.14
AFTER 10:50:55 up 1 day,  9:30,  1 user,  load average: 1.11, 2.14, 3.10
exit=0 wall=15.448

tb7_audit
BEFORE 10:50:55 up 1 day,  9:30,  1 user,  load average: 1.11, 2.14, 3.10
AFTER 10:51:39 up 1 day,  9:31,  1 user,  load average: 1.17, 2.01, 3.01
exit=1 wall=43.332

red_baseline
BEFORE 10:51:39 up 1 day,  9:31,  1 user,  load average: 1.17, 2.01, 3.01
AFTER 10:52:19 up 1 day,  9:32,  1 user,  load average: 1.09, 1.88, 2.92
exit=0 wall=40.574

red_tail
BEFORE 10:52:19 up 1 day,  9:32,  1 user,  load average: 1.09, 1.88, 2.92
AFTER 10:52:21 up 1 day,  9:32,  1 user,  load average: 1.08, 1.87, 2.91
exit=1 wall=1.539

red_fixedpoint
BEFORE 10:52:21 up 1 day,  9:32,  1 user,  load average: 1.08, 1.87, 2.91
AFTER 10:52:22 up 1 day,  9:32,  1 user,  load average: 1.08, 1.87, 2.91
exit=1 wall=1.571

red_compressor
BEFORE 10:52:22 up 1 day,  9:32,  1 user,  load average: 1.08, 1.87, 2.91
AFTER 10:52:24 up 1 day,  9:32,  1 user,  load average: 1.08, 1.87, 2.91
exit=1 wall=1.721

red_hash
BEFORE 10:52:24 up 1 day,  9:32,  1 user,  load average: 1.08, 1.87, 2.91
AFTER 10:52:26 up 1 day,  9:32,  1 user,  load average: 1.15, 1.87, 2.91
exit=1 wall=2.002

critic_mutations2
BEFORE 10:53:44 up 1 day,  9:33,  1 user,  load average: 0.49, 1.51, 2.70
AFTER 10:53:45 up 1 day,  9:33,  1 user,  load average: 0.49, 1.51, 2.70
exit=1 wall=1.165

critic_mutations3
BEFORE 10:55:47 up 1 day,  9:35,  1 user,  load average: 0.25, 1.09, 2.39
AFTER 11:02:30 up 1 day,  9:42,  1 user,  load average: 1.31, 1.15, 1.95
exit=0 wall=402.523

runner_red
BEFORE 11:04:53 up 1 day,  9:44,  1 user,  load average: 0.26, 0.82, 1.71
AFTER 11:04:55 up 1 day,  9:44,  1 user,  load average: 0.26, 0.82, 1.71
exit=1 wall=1.587

tb7_audit2
BEFORE 11:04:55 up 1 day,  9:44,  1 user,  load average: 0.26, 0.82, 1.71
AFTER 11:05:38 up 1 day,  9:45,  1 user,  load average: 0.65, 0.85, 1.67
exit=1 wall=43.049

red_tail2
BEFORE 11:05:38 up 1 day,  9:45,  1 user,  load average: 0.65, 0.85, 1.67
AFTER 11:05:55 up 1 day,  9:45,  1 user,  load average: 0.75, 0.86, 1.66
exit=1 wall=17.576

red_fixedpoint2
BEFORE 11:05:56 up 1 day,  9:45,  1 user,  load average: 0.75, 0.86, 1.66
AFTER 11:06:29 up 1 day,  9:46,  1 user,  load average: 0.92, 0.89, 1.64
exit=1 wall=33.146

red_compressor2
BEFORE 11:06:29 up 1 day,  9:46,  1 user,  load average: 0.92, 0.89, 1.64
AFTER 11:06:43 up 1 day,  9:46,  1 user,  load average: 0.94, 0.89, 1.63
exit=1 wall=14.156

red_hash2
BEFORE 11:06:43 up 1 day,  9:46,  1 user,  load average: 0.94, 0.89, 1.63
AFTER 11:07:18 up 1 day,  9:47,  1 user,  load average: 1.03, 0.92, 1.61
exit=1 wall=35.022

agreement
BEFORE 11:15:43 up 1 day,  9:55,  1 user,  load average: 0.18, 0.33, 1.00
AFTER 11:16:15 up 1 day,  9:56,  1 user,  load average: 0.50, 0.39, 1.00
exit=0 wall=32.351

agreement_red
BEFORE 11:19:20 up 1 day,  9:59,  1 user,  load average: 0.08, 0.27, 0.84
AFTER 11:19:53 up 1 day,  9:59,  1 user,  load average: 0.49, 0.35, 0.85
exit=1 wall=33.767

UPTIME before baseline ("tb6b_introspect.jl", "TB6B_TARGET", "tb6b_negative") 10:55:48 up 1 day,  9:35,  1 user,  load average: 0.25, 1.09, 2.39
UPTIME after baseline ("tb6b_introspect.jl", "TB6B_TARGET", "tb6b_negative") 10:56:06 up 1 day,  9:36,  1 user,  load average: 0.52, 1.10, 2.37
UPTIME before CRIT tail-odd 10:56:06 up 1 day,  9:36,  1 user,  load average: 0.52, 1.10, 2.37
UPTIME after CRIT tail-odd 10:56:26 up 1 day,  9:36,  1 user,  load average: 0.66, 1.09, 2.34
UPTIME before CRIT tail-except-Q 10:56:26 up 1 day,  9:36,  1 user,  load average: 0.66, 1.09, 2.34
UPTIME after CRIT tail-except-Q 10:56:46 up 1 day,  9:36,  1 user,  load average: 0.76, 1.08, 2.31
UPTIME before baseline ("tb6b_introspect.jl", "TB6B_TARGET", "all") 10:56:46 up 1 day,  9:36,  1 user,  load average: 0.76, 1.08, 2.31
UPTIME after baseline ("tb6b_introspect.jl", "TB6B_TARGET", "all") 10:57:27 up 1 day,  9:37,  1 user,  load average: 0.88, 1.07, 2.25
UPTIME before CRIT tail-except-interior 10:57:27 up 1 day,  9:37,  1 user,  load average: 0.88, 1.07, 2.25
UPTIME after CRIT tail-except-interior 10:58:06 up 1 day,  9:38,  1 user,  load average: 0.94, 1.06, 2.20
UPTIME before baseline ("tb7_compress.jl", "TB7_TARGET", "all") 10:58:06 up 1 day,  9:38,  1 user,  load average: 0.94, 1.06, 2.20
UPTIME after baseline ("tb7_compress.jl", "TB7_TARGET", "all") 10:58:52 up 1 day,  9:38,  1 user,  load average: 1.05, 1.07, 2.14
UPTIME before CRIT fixedpoint-constant-execution 10:58:52 up 1 day,  9:38,  1 user,  load average: 1.05, 1.07, 2.14
UPTIME after CRIT fixedpoint-constant-execution 10:59:37 up 1 day,  9:39,  1 user,  load average: 1.02, 1.06, 2.09
UPTIME before CRIT compressor-discards-self-code 10:59:37 up 1 day,  9:39,  1 user,  load average: 1.02, 1.06, 2.09
UPTIME after CRIT compressor-discards-self-code 11:00:24 up 1 day,  9:40,  1 user,  load average: 1.06, 1.06, 2.04
UPTIME before CRIT stale-output-hash 11:00:24 up 1 day,  9:40,  1 user,  load average: 1.06, 1.06, 2.04
UPTIME after CRIT stale-output-hash 11:01:11 up 1 day,  9:41,  1 user,  load average: 1.15, 1.08, 1.99
UPTIME before baseline ("tb6b_introspect.jl", "TB6B_TARGET", "tb6b_nested") 11:01:11 up 1 day,  9:41,  1 user,  load average: 1.15, 1.08, 1.99
UPTIME after baseline ("tb6b_introspect.jl", "TB6B_TARGET", "tb6b_nested") 11:01:27 up 1 day,  9:41,  1 user,  load average: 1.19, 1.09, 1.98
UPTIME before CRIT runner-error-inside 11:01:27 up 1 day,  9:41,  1 user,  load average: 1.19, 1.09, 1.98
UPTIME after CRIT runner-error-inside 11:01:40 up 1 day,  9:41,  1 user,  load average: 1.16, 1.09, 1.97
UPTIME before CRIT runner-crash-outside 11:01:40 up 1 day,  9:41,  1 user,  load average: 1.16, 1.09, 1.97
UPTIME after CRIT runner-crash-outside 11:01:41 up 1 day,  9:41,  1 user,  load average: 1.15, 1.09, 1.97
UPTIME before CRIT runner-unrelated-error 11:01:41 up 1 day,  9:41,  1 user,  load average: 1.15, 1.09, 1.97
UPTIME after CRIT runner-unrelated-error 11:01:59 up 1 day,  9:41,  1 user,  load average: 1.33, 1.13, 1.97
UPTIME before CRIT runner-print-Test-Failed 11:01:59 up 1 day,  9:41,  1 user,  load average: 1.33, 1.13, 1.97
UPTIME after CRIT runner-print-Test-Failed 11:02:16 up 1 day,  9:42,  1 user,  load average: 1.36, 1.16, 1.96
UPTIME before CRIT runner-forged-tally 11:02:16 up 1 day,  9:42,  1 user,  load average: 1.36, 1.16, 1.96
UPTIME after CRIT runner-forged-tally 11:02:30 up 1 day,  9:42,  1 user,  load average: 1.31, 1.15, 1.95
```

VERDICT: FAIL(T7-1,T7-2,T7-3,T7-4,T7-5,T7-6,T7-7,T7-8)
