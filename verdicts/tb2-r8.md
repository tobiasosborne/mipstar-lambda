# Verdict tb2-r8 — adversarial critic on rung TB2 after repair r7 (commit `8af9073`, brief 73) — closing round

Evaluated on an archived copy (`git archive 8af9073 | tar -x`) in
`/tmp/claude-1000/.../scratchpad/critic-tb2-r8/tree/`, instantiated there; cold
precompile of `MIPStarLambda` **71.79 s** at one-minute load **1.45**. The live working
tree was never read for `src/` or `test/`; `claims/CLAIMS.md` was read live
(orchestrator-owned) and is byte-identical to the archived copy in **both** rows that
concern this rung — C9 (7,352 characters) and C4b (5,077 characters) — checked
programmatically, so nothing below depends on a stale copy. No git command that changes
state was run; every mutation was applied to a copy under the scratch directory. This
verdict file is the only file written.

**Power/load record (binding for every wall below).** A *second critic* (TB4 r2) was
running its own suite and registry on this box throughout my measurements, so every wall
here is a loaded-box wall and is reported with `uptime`'s one-minute load at its start
and end. The TB0 60 s gate was still comfortable (**17.436 s** against warning 45.0 /
hard limit 60.0) at load 3.7.

Files under review (delta `8a1b6e2..8af9073`, TB2 lane): `test/tb2_answer_reduce.jl`
(+158/-56: `tb2_expected_keys()` hoisted out of the `branches` sweep, the new
`tb2_guard_key_cases()` table, `replay_seeds` rewritten), `test/mutations/run.jl`
(additive), four new `test/mutations/tb2_{step2_copy1_only,step3_crossed_copies,
step4a_copy3_only,step4b_copy3_only}.jl`, and evidence-line updates in five existing
TB2 mutants. **`src/verifiers/answer_reduce.jl`'s decider, `src/verifiers/ldt.jl`,
`src/samplers/cl.jl` and `src/samplers/pcp_sampler.jl` are untouched by this round**
except for two CITED-node *display strings* (brief 72: `:Detype` gains
`gt-06-types.tex:L445-L475`, `:Oracularization` gains `gt-09-oracularization.tex:L34-L86`);
no TB2 assertion mentions either string (`grep` for `detyping|Oracularization|orac-def|gt-06|gt-09`
in `test/tb2_answer_reduce.jl` is empty), so every r5/r6/r7 recomputation of the decider
itself still stands verbatim.

---

## 1. Adjudication of every r7 row

| r7 item | claimed in `briefs/73-…last.md` | **adjudication** | my evidence |
|---|---|---|---|
| **NG10** MAJOR — the trace key's `index` (copy) coordinate has no corrupted-reject witness at 19 of 37 keys | `replay_seeds` is the critic's 19-shape table × 3 seeds × 2 orientations = 114 outcomes; rejecting keys asserted **equal** to the 37-key set via the shared `tb2_expected_keys()`; testset 222 → 694 | **ACCEPTED, and it overshoots the demand** | the block is exactly the demanded one and adds three things I did not ask for: `@test !passed(rejection.result)` (the last trace entry *is* a rejection), `@test rejection.step == case.step` as an assertion rather than a critic's side-check, and the `tb2_expected_keys()` *hoist*, which makes the honest sweep and the corrupted-reject block compare against one object instead of two copies of a list. I recomputed all 114 outside the suite from the package API, with my own case table, my own three seeds, my own transcription of `fig:decider-pcp` into an expected-key set and into a rejecting-player predicate: **114/114 honest accept and reach the case's step, 114/114 corrupted reject with the expected rule, 114/114 rejecting step == `case.step`, 114/114 the rejecting entry is the last trace entry and IS the verdict, 114/114 observed player == my prediction, 114/114 full key == my per-case key, and my own 37-key enumeration is SET-EQUAL to the rejecting-key set (0 missing, 0 extra)** (§2.1). My control **MI1** (§5) confirms the per-copy coverage is genuine at the finest grain, and **MI3** confirms the key equality bites on the label. |
| **the four NG10 mutants registered** | `tb2_{step4a_copy3_only,step4b_copy3_only,step2_copy1_only,step3_crossed_copies}.jl`, target `tb2_replay_seeds`, forward `corrupted_rejected` = 51 / 45 / 54 / 51 of 57 | **ACCEPTED** | each `before`/`after` pair is my r7 §5 MH1 / MH2 / MH3 / MH5 **verbatim**; each `before` matches **exactly one** site in `src/verifiers/answer_reduce.jl` (I counted); each is **KILLED** in my own registry run, exit 1, with assertion failures (not `KILLED-BY-CRASH`) and its registered evidence line present: 68.98 / 70.45 / 53.78 / 69.52 s. I re-derived all four counts by hand from the 19-case table before running anything — step 2 loses 1 case × 3 seeds (57→54), step 3 loses 2 (→51), step 4(a) loses `i=4,5` = 2 (→51), step 4(b) loses axis and diagonal at `i=4,5` = 4 (→45) — and they agree. |
| **seven re-registered evidence lines** | the three `*_ld_only_alice` and the two `*_diagonal_never_rejects` mutants keep their anchors, evidence updated to 45 / 39 / 51 and 48 / 54 | **ACCEPTED** | anchors unchanged (`git diff` shows only the comment and the evidence string moved); my hand-derivation from the 19-case table reproduces every one: step 3 disarmed at `:bob` loses the 4 step-3 cases in the swapped half (57−12 = **45**), step 4(b) at `:bob` loses 6 (→**39**), step 4(c) at `:bob` loses 2 (→**51**), step 4(b) on `DLine` loses `proof_individual_diagonal_i{3,4,5}` (→**48**), step 4(c) on `DLine` loses 1 (→**54**). All five **KILLED** in my registry run. |
| **NG11** MINOR — the published site advertises a gap the code no longer has, and under-states the replay count | not in brief 73's lane (test files only); the r7 work order routed it to the orchestrator "after the C9 row lands" | **NOT DONE — re-issued as NG11′** | at `8af9073` the page reads "Still open (tb2-r7 NG10): the trace key's copy index has no corrupted-reject witness at 19 of the 37 guard keys; the 114-outcome block that closes it is written and queued" — **false at this commit**, the block landed here; and it still carries "The nine replay cases", "27 honest outcomes accepted, 27 corrupted outcomes rejected", the C9 ratchet row "nine replay cases at three seeds, 27 (case, seed) pairs" with verdict cell "tb2-r2 … tb2-r5", and "1364 / 1364" assertions / "119" mutants against the actual 2393 and 157. Same failure mode as r7 NG11 item 1, one round later. §3. |
| **NG12** NOTE — `pcp.jl`'s `_bind_upstream` replay was weakened; does not reach TB2 | recorded; brief 72 O8 makes the reproduction a CONSTRUCTED `:UpstreamReproduction` child and corrects the immutability premise; C10's owner | **ACCEPTED (closed for this rung)** | the edit is there and says what the report says (the "immutable data" reasoning is replaced by "a `TseitinFormula.program` vector is mutable in place … caught by `:PCPVerifier`'s replay, not here"). I re-verified the reach independently: the `:TypedAnswerReduce` certificate still has **10 nodes and never reaches `:UpstreamEvidence`**, and `verify_certificate` is `true` (§2.3). Routed to `verdicts/tb4-r2.md` / C10–C11, not to C9. |
| **C9's certificate counts frozen** | `_answer_reduce_replay_cases` untouched; "nine guard cases inside the certificate" still true | **ACCEPTED** | the function still returns exactly nine cases, unchanged byte for byte, and the suite still prints nine certificate replay outcomes with the r6 rules. The new block lives in the suite, so no certificate churn. |
| **MERGE PROPOSAL** | C9 = the live row with the 788-character `Scope (copy index)` sentence deleted and nothing else changed ("string surgery, not by eye") | **ACCEPTED, and I re-checked it programmatically** | live `claims/CLAIMS.md` C9 is string-equal to the row `verdicts/tb2-r7.md` §6 authorised (7,352 chars, both); the sentence `**Scope (copy index):** … covering all 37 keys. ` is 788 characters; live-minus-sentence is **byte-identical** to the proposal (6,564 = 7,352 − 788). No other edit hides in it. |
| **`src/` untouched** | "the only `answer_reduce.jl` edit in this session is brief 72 O11's citation facts on the CITED `:Detype` node" | **ACCEPTED, with the second edit named** | true for `answer_reduce.jl`; `src/samplers/oracularize.jl`'s `:Oracularization` CITED facts changed in the same session and the report does not mention it. Both are display/provenance-only, both are inert for TB2 (no assertion references them; the certificate node count is unchanged at 10). Recorded, not an objection. |
| **suite / registry figures** | 2393/2393 exit 0, TB2 1002 assertions; `killed=157/157 baselines ok=64/64`, exit 0 | **ACCEPTED, reproduced** | my numbers: **2393/2393** in 1m46.6 s (elapsed 1:47.54), exit 0, and **`MUTATION REGISTRY: killed=157/157 baselines ok=64/64 wall=1043.12 s`**, exit 0, no `SURVIVED` / `LOAD-ERROR` / `UNATTRIBUTABLE` / `BROKEN` / `KILLED-BY-CRASH`. TB2 testset sizes sum to exactly 1002, `replay_seeds` = 694 (§4). |
| **NG8, NG9** NOTE | carried unchanged | **ACCEPTED** | NG8's owner (`tb1_degenerate_all_t`) is still registered and KILLED (4.7 s class); NG9's offered precision on C4b's "because" clause remains offered, and C4b's structural facts are byte-identical to r4/r5/r6/r7 (§2.3). |

**Score: 8 ACCEPTED (one of them overshooting) · 1 ACCEPTED-with-a-naming-correction ·
1 NOT DONE (documentation lane, re-issued) · 0 escapes.** The r7 MAJOR is discharged
with a registered, independently reproduced kill at every one of the four survivors, and
the fix is *self-maintaining* in a way the previous five rounds' fixes were not: the
assertion is a set **equality** against the same object the honest sweep uses, so a guard
key added to or removed from the decider fails it rather than silently escaping.

---

## 2. Independent recomputations (archived copy; scripts under scratch)

`fullprobe8.jl`, `c4b.jl`, `mutate8.jl`. **None of them includes
`test/tb2_answer_reduce.jl`**, so nothing in this section is the suite grading itself.
The fixtures, the reduction, the three seeds, the nineteen shapes, the expected-key set
and the rejecting-player predicate are all rebuilt or re-transcribed by me.

### 2.1 The 114 outcomes and the 37-key equality, recomputed against my own enumerator

My seeds are *not* the suite's (`myseed(s,i) = ntuple(j -> GF2048(mod(37i+13j+1, 2048)))`
for the middle one, `MersenneTwister(0x9E)` for the third, zero for the first), and my
`my_expected_keys()` is transcribed from `fig:decider-pcp`
(`gt-10-answer-reduction.tex:2012-2063`) without reading `tb2_expected_keys()`.

```
R8 cases=19 outcomes=114 honest_accept_and_reaches_step=114 corrupted_rejected=114
       expected_rule=114 rejecting_step==case.step=114
R8 rejecting_player==MY transcription=114
       rejection_is_last_trace_entry_and_the_verdict=114
       full_key==MY per-case key=114
R8 MY expected key count=37  rejecting keys=37  SET EQUAL=true  missing=0  extra=0
R8 forward corrupted_rejected=57/57   swapped=57/57
R8 per-case forward rejects: every one of the 19 shapes = 3/3
```

Three facts worth pinning. (a) The equality is *tight*, not decorative: 19 shapes × 2
orientations produce 38 rejecting entries, of which the two step-1 entries collapse to the
single key `(1, :global_consistency, :both, 0, :none)`; 37 remain, so the equality forces
all nineteen shapes to land on **distinct** keys and forces each of the two orientations
to be the `:alice` / `:bob` coordinate. There is no slack in it. (b) The suite asserts
`case.step ∈ steps(honest.trace)` for the honest run; I checked the stronger statement
that the honest run *accepts* **and** reaches that step, on all 114. (c) r7 §2.2 measured
18 of 37 keys carrying a corrupted-reject witness; the number is now **37 of 37**, by my
own count, which is the whole content of the fix.

### 2.2 The nine registered mutant counts, re-derived before running them

For each of the nine TB2 mutants that target `tb2_replay_seeds` I derived the expected
forward/swapped `corrupted_rejected` from the 19-case table by hand, then confirmed it in
the registry run. All nine agree:

```
step2_copy1_only          57-3  = 54  (input_consistency_c2)
step3_crossed_copies      57-6  = 51  (input_axis_c2, input_diagonal_c1)
step4a_copy3_only         57-6  = 51  (proof_consistency_i4, _i5)
step4b_copy3_only         57-12 = 45  (proof_individual_{axis,diagonal}_i4, _i5)
individual_diagonal_never_rejects  57-9  = 48   simultaneous_diagonal_never_rejects 57-3 = 54
input_ld_only_alice (swap)         57-12 = 45   individual_ld_only_alice (swap)     57-18 = 39
simultaneous_ld_only_alice (swap)  57-6  = 51
```

### 2.3 C4b's structural facts, and the reach of the `pcp.jl` change

```
I: TB2 certificate nodes = 10; :UpstreamEvidence reached = false
I: verify_certificate = true
I: product types = 54  level = 3  edges = 2916
I: 54 product maps x 2 sides: NotDescribable=108 describable=0
I: reasons = Set(["continuation is an opaque host closure"])
I: PCP description sizes = Point_*=3009  ALine_1..5=2893  ALine_6=10228
                           DLine_1..5=2754 DLine_6=10479
```

Byte-identical to r4/r5/r6/r7, and brief 72's `:UpstreamReproduction` restructuring of
`_bind_upstream` remains unreachable from this certificate. C4b is untouched.

---

## 3. New objections

### NG11′ · MINOR · the published page still announces a gap the code no longer has, and its counts are two rounds stale

**Location** `docs/tutorial/compress-explained.html` (source of truth) and the generated
`docs/index.html`.

**My computation.** Five strings, all read out of the archived copy:

1. "Still open (tb2-r7 NG10): the trace key's copy index has no corrupted-reject witness
   at 19 of the 37 guard keys; the 114-outcome block that closes it is written and
   queued." — **false at this commit**: the block landed here, its four mutants are
   registered and KILLED, and my own enumerator puts a corrupted-reject witness at 37 of
   37 keys. This is the *same* failure mode r7 NG11 item 1 recorded one round earlier (the
   page then announced NG3 as open after NG3 was fixed), and it is the one kind of
   staleness that is not merely conservative: a reader is told the artefact is weaker
   than it is.
2. "The nine replay cases" (panel heading) — the block is nineteen guard-key shapes.
3. "…: 27 honest outcomes accepted, 27 corrupted outcomes rejected" and "Brief 69 then ran
   all nine cases in both orientations (54 outcomes, …)" — the suite now runs **114**.
4. The C9 ratchet row: "nine replay cases at three seeds, 27 (case, seed) pairs", verdict
   cell "tb2-r2 … tb2-r5" where `claims/CLAIMS.md` already carries `verdicts/tb2-r7.md`.
5. "1364 / 1364" suite assertions and "119" mutants against the measured **2393** and
   **157**.

Nothing here is a code defect and nothing overstates the evidence except item 1, which
under-states it. `docs/DESIGN.md` and `docs/definitions.md` are clean — I grepped both for
`54 (case`, `27 (case`, `nine replay`, `nine cases`, `19 cases`, `114 outcome` and found
nothing; DESIGN §5.5's "9/9 guard cases" is TB3's `decider cases accepted=9/9`, which the
suite still prints, not the replay block. `README.md` and `HANDOFF.md` carry no counts.

**FIX DEMAND** Orchestrator lane, after the C9 row of §6 lands: in
`docs/tutorial/compress-explained.html` delete the "Still open (tb2-r7 NG10)" sentence
(replace it with NG13's scope if the proposer chooses to leave NG13 open), change "nine
replay cases"/"27 outcomes"/"54 outcomes" to the nineteen-shape, 114-outcome, 37-key
wording, update the ratchet row's counts and its verdict list to `tb2-r2 … tb2-r8`, and
update 1364/119 to 2393/157; then re-run `tools/build_site.py`.
**SURVIVING WEAKER STATEMENT** No published number overstates the evidence; one published
sentence understates it.

### NG13 · MINOR · step 4(c)'s simultaneous test has a corrupted-reject witness at 1 of its 22 polynomial slots — and the coverage that saves it is another rung's

**Location** `src/verifiers/ldt.jl:_line_point_test` (`for j in 1:params.kappa, s in
admissible`), reached from `src/verifiers/answer_reduce.jl:508-513` (step 4(c),
`kappa = m'+6 = 22`); `test/tb2_answer_reduce.jl` cases `:proof_simultaneous_axis` and
`:proof_simultaneous_diagonal`, both `corrupt=(:right, 7)`.

**My computation.** Steps 3 and 4(b) run the low-degree decider at `kappa = 1`, so their
corrupted entry is forced. Step 4(c) runs it at `kappa = 22`, and the whole TB2 corpus —
the certificate's nine cases, the 114-outcome block, the 2916-pair locksteps, the arity-22
step-1 sweep — corrupts exactly **slot 7** of the 22. My probe **MI2** (§5) narrows the
agreement loop to that slot whenever `kappa >= 7`, leaving every `kappa < 7` use (steps 3
and 4(b), and every TB1 use) untouched:

```julia
-    for j in 1:params.kappa, s in admissible
+    for j in (params.kappa >= 7 ? (7:7) : 1:params.kappa), s in admissible
```

```
PROBE mi2_simultaneous_only_slot7  TB2_TARGET=all  exit=0  assertion_failures=false => SURVIVED (118.99 s)
      TB2 replay ... corrupted_rejected=57 (both orientations); rejecting trace keys: 37/37
      MUTATION_EXPECTED_RULE branches first_failure=none failures=0
```

All 1002 TB2 assertions stay green: the mutated decider still rejects every corruption
the corpus makes at step 4(c), because the corpus only ever makes one.

**Why this is MINOR and not the sixth MAJOR of this family.** Three reasons, and I want
them on the record because the temptation to grade it MAJOR is exactly the "re-litigate
forever" failure rk-light warns about. (i) The mutated line is **not in this round's
diff** and is not in TB2's file — `ldt.jl` is C4c/TB1 territory, and the adjudication rule
for later rounds is to attack what changed. (ii) The generic mechanism *is* red-capable
and *is* registered: `tb1_kappa` (`for j in 1:1`) targets `tb1_decider_rejections` and is
KILLED in my registry run (exit 1, 5.66 s), and `tb1_ld_sampler.jl:820-835` runs the ld
decider at `kappa = 2` with a **second-entry** cheat asserted to reject at `location == 2`
— so "the loop reaches every `j`, not just the first" has an owner. TB2 independently pins
`kappa = 22` at step 4(c): `tb2_mc3` narrows it to 1 and is KILLED with
`:ld_answer_arity`. The composition covers the fact; what is missing is a TB2-local
witness. (iii) My mutation is not a plausible implementation error — it needs a
`kappa >= 7` special case, introduced for no reason other than to fit the single witnessed
slot. The r7 NG10 survivors were exception lists over a coordinate *no* registered mutant
touched anywhere; this one is a gerrymander around a coordinate that is already owned.

**FIX DEMAND (cheap, optional at this severity)** In `tb2_guard_key_cases()`, vary the
corrupted slot of the two `:proof_simultaneous_*` shapes across the three seeds — or add
two shapes corrupting slots 1 and 22 — so that TB2 itself witnesses the ends of the
`m'+6` range, exactly as `verdicts/tb2-r4.md` NF2 did for step 1's 22 entries. The
19-shape/37-key equality is unaffected (the key is the same for every slot), so C9's
counts do not change and the row does not come back for authorization.
**SURVIVING WEAKER STATEMENT** Step 4(c) compares all 22 polynomials correctly at this
commit and the comparison loop is red-capable in the registry (`tb1_kappa`, `tb2_mc3`);
what TB2's own corpus does not witness is a corruption at any slot but the seventh.

### NOTE N31 · two of the four NG10 evidence lines are not distinguishable from each other

`tb2_step3_crossed_copies` and `tb2_step4a_copy3_only` both register the evidence line
`… cases=19 outcomes=57 honest=57 corrupted_rejected=51`, and their swapped halves also
coincide. This is not a defect — the runner uses the evidence line to discriminate a
mutated run from the **clean** run (57), which it does, and the two mutants are
distinguished by their source anchors, both of which I checked match exactly one site.
Recorded only so that a later reader does not treat the evidence string as a mutant
fingerprint.

### NOTES carried unchanged

**NG8** (TB2 does not itself witness the all-`t` comparison; TB1's `tb1_degenerate_all_t`
owns it — still registered, still KILLED) and **NG9** (C4b's "because" clause is
conditional after brief 65's `direct_sum` normalisation; the offered precision is not
demanded) stand exactly as `verdicts/tb2-r6.md` and `verdicts/tb2-r7.md` recorded them.
**NG12** is closed for this rung and routed to `verdicts/tb4-r2.md` / C10–C11.

### NOTE for brief 39 / TB5 — carried, unchanged

**N23** `TypedSampler`'s padding path still calls `pad_level`, not `pad_level_evidence`.
**N24** `pad_level` is still not compositional on the empty-register `CLZero`. **N25** the
CL round trip still pins neither a `CLStep`'s `rest` register nor `BranchByAxis.position`
at `m=1`. **r4 N9 residue / r5 N30** move the three seeds into
`_answer_reduce_replay_steps` so `verify_certificate` alone witnesses them. None of these
blocks C4b or C9.

---

## 4. Test and mutation evidence I observed

```
SUITE (archived tree 8af9073, warm depot)
  load average 3.71 -> 2.33   (a second critic's suite was running concurrently)
    MIPStarLambda load/precompile seconds = 0.411 (ungated); cold instantiate 71.79 s at load 1.45
    TB0 test-body wall seconds = 17.436 (warning=45.0, hard_limit=60.0)   <-- GATE PASSED
    Test Summary: MIPStarLambda | Pass 2393  Total 2393  Time 1m46.6s
    /usr/bin/time -v: Elapsed 1:47.54 · Maximum RSS 1,624,780 KiB · Exit status 0

  TB2 lines observed:
    TB2 sampler: PCP types=18 edges=324 dims V6=(16,6,16) SOURCE_REPAIR=true;
                 product types=54 edges=2916 level=3
    MUTATION_EXPECTED_RULE product_projection agrees=true compared=1080
    TB2 certificate replay outcomes: 9 tuples, rules as in r6/r7 (unchanged)
    MUTATION_EXPECTED_RULE describable actual=18/18
    MUTATION_EXPECTED_RULE branches first_failure=none failures=0
    TB2 deterministic branches: covered=37 seeds=37
    MUTATION_EXPECTED_RULE guard_split actual=(2736, 180, 107, 92, 54, 53)
    MUTATION_EXPECTED_RULE guard_lockstep mismatches=0 accepted=2916 silent=2736
    MUTATION_EXPECTED_RULE guard_lockstep_honest seed=tb2_seed5 mismatches=0 accepted=2916
    MUTATION_EXPECTED_RULE global_consistency arity=22 rejected_with_rule=20/20
    TB2 replay at 3 seeds (zero, tb2_seed 5, rng 0x9E): cases=19 outcomes=57 honest=57
                           corrupted_rejected=57 expected_rule=57                     <-- new
    TB2 replay SWAP orientation (right,left) at the same 3 seeds: cases=19 outcomes=57
                           honest=57 corrupted_rejected=57 expected_rule=57           <-- new
    TB2 replay rejecting trace keys: 37/37 expected keys (114 outcomes;
                           rejecting_step==case.step=114)                             <-- new (NG10)
    TB2 describe: Point_*=3009 ALine_1..5=2893 ALine_6=10228 DLine_1..5=2754 DLine_6=10479
    TB3 pcp: decider cases accepted=9/9   (DESIGN 5.5's "9/9 guard cases", still current)
  TB2 testset sizes (1002 assertions, was 530): sampler 26, describe 126, parsers 1,
    branches 48, seeded 3, no_check 3, lockstep 83, replay_seeds 694 (was 222),
    game 9, proof_consistency 2, line 2, guard 2, dline_projection 2, i345 1.

MUTATION RUNNER (`julia --project=. test/mutations/run.jl`, load 5.89 -> 13.07 with a
  second critic's suite and registry running concurrently throughout)
  BASELINE (unmutated-first): 64/64 OK, every target exits 0
  TB0 28/28 · TB1 38/38 · TB2 25/25 · TB3 19/19 · TB4 26/26 · TB5 21/21 — all KILLED
  new this round, all KILLED with their registered evidence lines and real assertion
  failures (no KILLED-BY-CRASH anywhere in the run):
    TB2 NG10-step2   step2_copy1_only      target=tb2_replay_seeds (exit=1, 53.78 s)
    TB2 NG10-step3   step3_crossed_copies  target=tb2_replay_seeds (exit=1, 69.52 s)
    TB2 NG10-step4a  step4a_copy3_only     target=tb2_replay_seeds (exit=1, 68.98 s)
    TB2 NG10-step4b  step4b_copy3_only     target=tb2_replay_seeds (exit=1, 70.45 s)
  re-registered at the new counts, all KILLED:
    tb2_{input,individual,simultaneous}_ld_only_alice  (58.77 / 61.12 / 54.53 s)
    tb2_{individual,simultaneous}_diagonal_never_rejects (53.73 / 40.23 s)
  MUTATION REGISTRY: killed=157/157 baselines ok=64/64 wall=1043.12 s
  /usr/bin/time -v: Elapsed 17:23.75 · Maximum RSS 6,384,612 KiB · Exit status 0
  No SURVIVED, no LOAD-ERROR, no UNATTRIBUTABLE, no BROKEN baseline.
  (The proposer measured 709.43 s; mine is 1043.12 s on a box carrying a second critic.
  Same registry, no time gate.)

MY OWN SCRIPTS
  fullprobe8.jl  32.15 s  (load 13.33 -> 13.62)
  c4b.jl         10.62 s  (load 13.53 -> 13.60)
  mutate8.jl     2:01.59  (load 13.55 -> 15.73), four probes in parallel
```

## 5. Mutations written by this critic (isolated copies; the tree was never modified)

Each ran as the registry runs one — `Base.include(MIPStarLambda, <mutated copy>)` then
`test/tb2_answer_reduce.jl` at the stated `TB2_TARGET` — four at a time alongside an
unmutated control in the same shape.

| id | mutation | expectation | outcome |
|---|---|---|---|
| mi0 (control) | none, `TB2_TARGET=all` | must pass | **OK** (exit 0, 120.29 s at load ≈ 14) |
| **MI1** | `:495` step 4(b): `rejected === nothing \|\| return rejected` → `… \|\| i == 5 \|\| …` — the individual low-degree test never rejects at proof copy **5 alone** (the registered mutant disarms 4 *and* 5) | is the new block's per-copy coverage genuine at the finest grain, or only "not copy 3"? | **KILLED** (exit 1, assertion failures, 69.99 s) by `TB2_TARGET=replay_seeds` **alone**: `corrupted_rejected=51/57` in each orientation and `rejecting trace keys: 33/37` — the four keys `(4, proof_individual_{axis,diagonal}, {alice,bob}, 5, {ALine,DLine})` disappear and the equality fails. The fix is not coarse. |
| **MI2** | `ldt.jl` `_line_point_test`: `for j in 1:params.kappa` → `for j in (params.kappa >= 7 ? (7:7) : 1:params.kappa)` — the simultaneous test compares only the one polynomial slot the corpus corrupts, leaving every `kappa < 7` use untouched | is step 4(c)'s slot coordinate red-capable *inside TB2*? | **SURVIVED** (exit 0, no assertion failures, 118.99 s, `TB2_TARGET=all`) → **NG13**, graded MINOR: the coordinate is owned across rungs (`tb1_kappa` KILLED; `tb1_ld_sampler.jl` cheats at `location == 2` with `kappa = 2`; `tb2_mc3` pins `kappa = 22`), the file is outside this round's diff, and the mutation needs a `kappa >= 7` special case to exist |
| **MI3** (control on the key equality) | `:463` step 3: `_ar_entry(3, branch, player, input_role_copy, …)` → `_ar_entry(3, branch, player, 1, …)` — the trace mislabels the input copy | does the 37-key equality bite on the *label*, not only on the rejection? | **KILLED** (exit 1, assertion failures, 69.65 s) by `TB2_TARGET=replay_seeds` **alone**: every corruption is still rejected (`corrupted_rejected=57` in both orientations, `expected_rule=57`) and the block still fails, at `rejecting trace keys: 33/37`. Mislabelled evidence is now caught by the replay block itself, not only by the honest sweep. |

Two of four new semantic mutations were written to attack the r7 fix directly (MI1, MI3);
both are KILLED **by the new testset in isolation**, which is the strongest form of the
claim that brief 73's block is the owner of what it says it owns. The one survivor (MI2)
lies outside this round's diff and outside TB2's file.

---

## 6. Per-claim decisions

Both statuses stay TESTED and both are **re-affirmed**. Every fact either row asserts is
true at `8af9073` and has been independently recomputed here. NG10's `Scope (copy index)`
sentence is **deleted**, not weakened — the condition r7 §6 note (c) attached to it is
met: the 19-case block landed in the suite, the four mutations are registered and KILLED,
and the coverage is now a checked set equality rather than a critic's enumeration. NG13 is
recorded as a MINOR scope note and, on my judgement, does **not** earn a sentence in C9:
the fact it concerns (the simultaneous test compares all `m'+6` polynomials) is
red-capable in the registry through `tb1_kappa` and `tb2_mc3`, and C9 makes no per-slot
claim. No claim moves up or down this round.

### C4b — **RE-AFFIRMED TESTED**, statement UNCHANGED. The following edit is **AUTHORIZED**:

> In the C4b row of `claims/CLAIMS.md`, leave the statement, status, depends-on and test
> columns exactly as they stand, and replace the final column
> `` `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md`; `verdicts/tb2-r5.md` (re-affirmed); `verdicts/tb2-r6.md` (re-affirmed); `verdicts/tb2-r7.md` (re-affirmed) ``
> by
> `` `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md`; `verdicts/tb2-r5.md` (re-affirmed); `verdicts/tb2-r6.md` (re-affirmed); `verdicts/tb2-r7.md` (re-affirmed); `verdicts/tb2-r8.md` (re-affirmed) ``.

Rationale: nothing in C4b's territory changed this round — `cl.jl`, `pcp_sampler.jl` and
`answer_reduce.jl`'s sampler and decider all show an empty diff (the only
`answer_reduce.jl` edit is a CITED display string), all 108 product maps (54 types × 2
sides) are still `NotDescribable` with the single reason "continuation is an opaque host
closure", and all 18 PCP description sizes are byte-identical to r4/r5/r6/r7 (§2.3).
NG9's precision remains offered, not demanded.

### C9 — **RE-AFFIRMED TESTED**, row text replaced. The following is **AUTHORIZED VERBATIM**:

> | C9 | (Typed answer-reduced decider — TB0 fixture) For the row `(q,k,m,d,s,m')=(2048,11,1,11,6,16)`, the trivial two-coordinate original sampler and its three-role oracularization, the typed answer-reduced decider implements the five guarded checks of `fig:decider-pcp` with the exact type-pair guards, the `i in {3,4,5}` restriction and both `ldparams=(q,m,d,1)` and `ldparams'=(q,m',d,m'+6)`; the honest strategy built from the TB0 PCP proof (witness (ii) for checks 4(a)/4(b)) is accepted on all 37 directed guard orientations at 37 distinct seeds, whose 37 `(step, branch, player, index, line_kind)` trace keys are asserted to be exactly the keys the sweep reaches and not merely a subset (`verdicts/tb2-r5.md` N28), and on 256 conditioned seeded question pairs at 256 distinct full-field seeds whose `chi(s_aux,m')` covers all 16 values, and every honest line answer checked equals the true restriction of the corresponding PCP polynomial at all `q=2048` line points (critic recomputation, `verdicts/tb2-r1.md` and `verdicts/tb2-r2.md` §2.3; the suite itself checks one such line through `D^ld`). Exactly `2736/2916 = 76/81 = 93.827%` of ordered product-type pairs trigger no check; of the remaining 180, 107 trigger step 5 (92 of them step 5 alone) and 54 trigger step 1 (53 of them step 1 alone) — the r1/r2 wording "107 only step 5 and 54 only step 1" was arithmetically wrong and is corrected here (`verdicts/tb2-r3.md` N10); all six numbers `(2736, 180, 107, 92, 54, 53)` are asserted by the suite and owned by the mutant `tb2_guard_split`, and this critic reproduced them by two further independent transcriptions of the guards (one in Julia, one in Python), together with the decomposition 1 + 4 + 6 + 4 of the fifteen step-5 pairs that also fire another guard. The decider itself, not only the enumerator `answer_reduce_guard_branches`, is now run on all 2916 ordered pairs — at the all-zero seed with the certificate replay's all-zero answers, and again at the nonzero full-field seed `tb2_seed 5` with honest TB0-proof answers (witness (ii) on the 18 of 2916 pairs that require it) — and its trace fires exactly the enumerated `(check, line_kind)` key set pair for pair, the branch label's `_axis`/`_diagonal` suffix being asserted to match the trace entry's line kind, with an empty trace on exactly the 2736 and an accept on all 2916 in both sweeps; the step-4(b) widening mutant `tb2_decider_guard_widened` is KILLED at 12 mismatches, and this critic reproduced the lockstep against a third, independently written transcription of `fig:decider-pcp` (0 mismatches clean, 12 mutated) and extended it to honest degenerate-proof answers at two seeds, where it also holds (`verdicts/tb2-r5.md` §2.2). The questions judged are the projections of the 54-type product sampler's own `sample` output, asserted equal to the explicit seed split on 20 seeds x 54 types x both sides (`verdicts/tb2-r2.md` N1 repaired in brief 46; independently recomputed in `verdicts/tb2-r3.md` §2.1). The `:TypedAnswerReduce` certificate replays shape, branch reachability and, for each of nine guard cases, one honest accept and one corrupted reject carrying the expected rule (ibid. N2 repaired). **Scope:** step 5 executes only items 3-5 of `fig:pcpverifier`; items 1-2 (`PaddedSuccinctDecider` -> Tseitin -> arithmetization) are not implemented, the formula is a construction-time constant, and the computed `x_alice=L^alice(x_Q)`, `x_bob=L^bob(x_Q)` reach `pcp_decider_specification` but do not enter the decision — asserted, including the equal verdict under a swapped call (`SOURCE_REPAIR :PCPVerifierFixedFormula`; `verdicts/tb2-r1.md` O3). Step 5's "otherwise, accept" is read as fallthrough, so the decider is strictly stricter than the literal source (`SOURCE_REPAIR :PCPGameOtherwiseFallthrough`; ibid. O8); the executable runs player-outer where the source is step-outer, with identical verdicts because every rejection is terminal (`verdicts/tb2-r2.md` N4). The nine-case replay carried inside the certificate still runs at the all-zero seed only; the suite runs a wider block — one case per `(step, branch, index, line_kind)` guard key of `fig:decider-pcp`, **nineteen** shapes (`tb2_guard_key_cases`), covering both line kinds of steps 3, 4(b) and 4(c), both input copies `in {1,2}` at steps 2 and 3, and all three proof copies `i in {3,4,5}` at steps 4(a) and 4(b) — with honest TB0-proof answers at three seeds (all-zero, `tb2_seed 5`, RNG 0x9E) and in **both orientations** — the registered one and the swap `(case.right, case.left)` with the corrupted side flipped — asserting honest accept, corrupted reject, the expected rule, the reached step, that the rejecting entry is the last entry of the trace and its step is the case's own, and the rejecting trace entry's player (`:alice` forward, `:bob` swapped, `:both` at step 1) for all **114** (case, seed, orientation) outcomes, and asserting further that the set of rejecting `(step, branch, player, index, line_kind)` keys is **equal** to the 37-key set the honest sweep pins — one corrupted-reject witness at every one of the 37 keys, both sets produced by the single shared helper `tb2_expected_keys()`, so a guard key added to or removed from the decider fails the equality rather than escaping. All of it was recomputed independently by this critic from the package API — his own case table, his own three seeds, his own transcription of the guards into an expected-key set and a rejecting-player predicate — obtaining 114/114 honest accepts that reach the case's step, 114/114 corrupted rejects with the expected rule at the expected step, 114/114 rejecting players and last-entry rejections, and a rejecting-key set equal to his own 37 (`verdicts/tb2-r3.md` N9, `verdicts/tb2-r4.md` §2.5, `verdicts/tb2-r6.md` §2.3, `verdicts/tb2-r7.md` §2.1, `verdicts/tb2-r8.md` §2.1). Disarming a step's rejection in the `:bob` orientation alone is KILLED at step 3, step 4(b) and step 4(c) (`tb2_{input,individual,simultaneous}_ld_only_alice`), and disarming it at a single copy — step 2 on Bob's copy, step 3 at axis@copy2 together with diagonal@copy1, steps 4(a) and 4(b) at proof copies 4 and 5 — is KILLED by the same block at forward `corrupted_rejected` = 54 / 51 / 51 / 45 of 57 (`tb2_{step2_copy1_only,step3_crossed_copies,step4a_copy3_only,step4b_copy3_only}`; `verdicts/tb2-r7.md` NG10, closed here). Step 1 compares the full bundle: on all five equal-type copy-6 pairs the suite asserts that corrupting entry 1, 6, 7 or `m'+6 = 22` of the 22-entry right answer is rejected with rule `:global_consistency` at step 1 (20/20), the first-entry-narrowing mutant `tb2_global_consistency_first_entry` is KILLED at 5/20, and this critic swept every one of the 22 entries on all five pairs (110/110 rejected with that rule; 5/110 under the mutant) (`verdicts/tb2-r5.md` §2.3). Both facts are carried by the suite, not by the `:TypedAnswerReduce` certificate, whose replay list is the nine cases at the all-zero seed. The `i in {3,4,5}` restriction has no honest-play consequence and is evidenced only structurally (O14). `m=1` makes checks 3 and 4(b) act on the whole of `F_q^1`, and honest answer degrees are 1 against the declared bound `d=11` (O12). Detyping, its `+2` levels and its `16^54` loss, and every quantum conclusion remain CITED. | TESTED | D1,D2,C3,C4a,C4b | — | `test/tb2_answer_reduce.jl`; red: `test/mutations/tb2_{formula,g3,line,guard,guard_split,i345,mc1,mc2,mc3,nd2,nd4,tensor,opaque,decider_guard_widened,global_consistency_first_entry,individual_diagonal_never_rejects,simultaneous_diagonal_never_rejects,input_ld_only_alice,individual_ld_only_alice,simultaneous_ld_only_alice,step2_copy1_only,step3_crossed_copies,step4a_copy3_only,step4b_copy3_only}.jl` | `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md`, `verdicts/tb2-r5.md`, `verdicts/tb2-r6.md`, `verdicts/tb2-r7.md`, `verdicts/tb2-r8.md` |

Four notes on the authorised text, for the orchestrator. (a) It is brief 73's MERGE
PROPOSAL — the r7 row minus the `Scope (copy index)` sentence, which I verified by string
surgery is exactly what the proposal is — plus three changes I make as critic, all of them
the amendment the proposer explicitly offered and brief 75 authorises me to make: the
under-counting "same nine cases … 54 (case, seed, orientation) outcomes" clause is
replaced by the nineteen-shape, 114-outcome, 37-key statement the proposer earned; the
four new mutants are added to the red list; and `verdicts/tb2-r8.md` is added to the
verdict cell. Nothing else in the row moves. (b) The certificate count stays **nine** and
remains frozen: `_answer_reduce_replay_cases` is unchanged, and if a later round closes
anything inside `_answer_reduce_replay_steps` rather than in the suite, "nine guard cases"
and "the nine cases at the all-zero seed" change and the row must come back for
authorization. (c) The row now carries **no** open `Scope (copy index)`-style sentence; do
not add one for NG13 (see §6 opening). (d) The assertion count 530 left the row with the
deleted sentence and is not reintroduced; the current figure (1002) lives in this verdict
and in the site copy NG11′ demands.

### C4c, C4a, C7, C10, C11, C12, C13 — not this rung's claim

C4a and C4c belong to `verdicts/tb1-r6.md`; NG13's cross-rung half is a **NOTE to C4c's
owner** — TB1 already owns the `for j in 1:kappa` loop (`tb1_kappa` KILLED,
`tb1_ld_sampler.jl:820-835` at `kappa = 2` with a second-entry cheat), and nothing there
needs to change; it is recorded so no later summary reads TB2's step 4(c) as the owner.
C10 and C11 belong to `verdicts/tb4-r2.md`; NG12 is closed for TB2 and routed there. C12
and C13 belong to `verdicts/tb5-r1.md`. C7 stays CONJECTURE; nothing this round touches
r4 §6.2's finding that `description_size` is not additive under `direct_sum`.

---

## 7. Work order for the next round — documentation only

1. **NG11′ (MINOR).** Orchestrator lane: `docs/tutorial/compress-explained.html` (drop the
   false "Still open (tb2-r7 NG10)" sentence; nine → nineteen cases; 27/54 → 114 outcomes
   with the 37-key equality; ratchet row counts and verdict list to `tb2-r8`; 1364 → 2393
   and 119 → 157), then re-run `tools/build_site.py`. Do it after the C9 row of §6 lands.
2. **NG13 (MINOR).** Optional and cheap: vary the corrupted slot of the two
   `:proof_simultaneous_*` shapes so TB2 witnesses more than slot 7 of 22. No claim text
   changes either way.
3. **N31, NG8, NG9, NG12 (NOTE).** Recorded only.
4. **N23, N24, N25, r4 N9 residue (NOTE).** Unchanged, brief 39 / TB5.

**Why this rung is now closed.** A guard branch's red-capability is indexed by the trace
key `(step, branch, player, index, line_kind)`. r3 closed the guard *set*; r4 closed the
step-1 answer *arity*; r5 closed the *line kind*; r6 closed the *player*; r7 found the
last free coordinate, the *copy* `index`, unowned at 19 of 37 keys. This round closes it
— and closes it in the only way that terminates the family, by construction rather than by
argument: the suite now asserts that the set of rejecting keys **equals** the set the
honest sweep pins, both produced by one shared helper. There is no coordinate of the key
left to displace an objection into, and, unlike every previous round's fix, the coverage
is self-maintaining: a guard key added to or removed from the decider fails the equality
instead of escaping it. I attacked the fix twice at its two weakest-looking points — a
single-copy disarm (MI1) and a mislabelled index (MI3) — and both died against the new
testset *in isolation*. My one survivor is a `kappa >= 7` gerrymander in another rung's
file, outside this round's diff, against a mechanism two registered mutants already own; I
have graded it MINOR and I have no further probe of this shape to run.

Objection trajectory for this rung: **14 → 5 → 5 → 6 → 6 → 6 → 3 → 2**, and for the first
time in the sequence **no MAJOR and no FATAL**. Every r7 objection is discharged except
the documentation refresh, which was deliberately deferred out of brief 73's lane; the
registry grew from 119 to 157 mutants with 64/64 clean baselines and no survivor; the
suite grew from 1364 to 2393 assertions and TB2's own from 530 to 1002.

VERDICT: PASS
