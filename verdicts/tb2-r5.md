# Verdict tb2-r5 — adversarial critic on rung TB2 after repair r4 (commit `3f2d1f1`, brief 59) — intended closing round

*Status: COMPLETE — written and finalised before the machine-restart notice of 2026-09-05 (runs timestamped 08:09–08:35 in this session). Every obligation of `briefs/62-tb2-critic-r5.md` was discharged: suite run twice, mutation registry run, all r4 rows adjudicated, the three demanded recomputations done, two new semantic mutations run to a decision, and per-claim decisions issued for C4b and C9. This is not a draft; the final VERDICT line at the bottom stands.*


Evaluated on an archived copy (`git archive 3f2d1f1 | tar -x`) in
`/tmp/claude-1000/.../scratchpad/critic-tb2-r5/tree/`, instantiated there; cold
precompile of `MIPStarLambda` **164.1 s** (`real 2m44.1`, ungated, load average 4.8).
The live working tree was never read for `src/`/`test/` and never written;
`claims/CLAIMS.md` and `docs/DESIGN.md` were read live (orchestrator-owned) and
`docs/DESIGN.md` is byte-identical to the archived copy (`diff` empty). No git command
that changes state was run; every mutation was applied to a copy under the scratch
directory. Live `HEAD` has since moved to `57c8946` ("governor switched to performance"),
which matters for §4.

**Load caveat (binding for every wall below).** Other desktop work was resident throughout:
`pgrep -fc 'julia --project'` was 4 at the start of both suite runs and the one-minute load
average ranged from **2.2 to 8.5**; every wall below is reported with the load at its start
and end. Contrary to the dispatching brief's expectation, the TB0 60 s gate was **not**
marginal on this box: the gated test-body wall came out at **33.93 s** and **35.02 s**
(warning 45.0, hard limit 60.0) — 25 s of headroom in both runs, at load 4.2 and 6.9. The
governor switch recorded in the live `HEAD` is the plausible cause; the orchestrator's
74.6 s / 85.2 s figures for this same commit are not reproducible here, so no timing NOTE
is filed.

Files under review: `src/verifiers/answer_reduce.jl` (687 L, unchanged this round),
`src/samplers/cl.jl` (+5 L, the N26 ambient gate), `src/samplers/typed.jl` (+17/-8 L, the
TB1 N25 `_pad_top` throw), `test/tb2_answer_reduce.jl` (822 L, was 735; the new
`lockstep` testset at `:567-650`), `test/mutations/tb2_*.jl` (16 files, was 14),
`test/mutations/run.jl`, `claims/CLAIMS.md` C4b/C9, `docs/DESIGN.md` §1.5/§9.3/§9.4.

---

## 1. Adjudication of every r4 row for this rung

| r4 item | claimed in `briefs/59-…last.md` | **adjudication** | my evidence |
|---|---|---|---|
| **NF1** MAJOR — decider/enumerator lockstep over all 2916 ordered pairs; widening mutant registered | fixed at `test/tb2_answer_reduce.jl:579-612`; `tb2_decider_guard_widened.jl` KILLED with `mismatches=12` | **ACCEPTED** | testset present and it is the demanded one: it calls `typed_answer_reduced_decider` on every ordered pair and compares `Set(TB2_GUARD_NAMES[e.branch])` with `answer_reduce_guard_branches`, asserting `mismatches==0`, `accepted==2916`, `silent==2736` (79 assertions). Suite prints `guard_lockstep mismatches=0 accepted=2916 silent=2736` in both my runs; registry reports the mutant KILLED (exit 1, 17.5 s). I recomputed both numbers against a **third** transcription of `fig:decider-pcp` written by me: 0 mismatches clean, **12** mutated, first offender `((oracle,Point_3),(oracle,ALine_6))` where the mutated decider rejects honest play with `:ld_question_format` on an enumerator-silent pair (§2.2). |
| **NF2** MAJOR — step 1 red-capable above arity 1; first-entry mutant registered | fixed at `tb2:613-645` (five equal-type copy-6 pairs × entries 1/6/7/22 → `:global_consistency`, `20/20`); `tb2_global_consistency_first_entry.jl` KILLED at `5/20` | **ACCEPTED** | suite prints `global_consistency arity=22 rejected_with_rule=20/20`; registry KILLED (exit 1, 24.3 s). The proposer went one pair beyond the demand by adding `(oracle,Point_6)`. My own sweep is stronger and agrees: **all 22** entries on **all five** pairs are rejected with rule `:global_consistency` and `trace[end].step == 1` (110/110), and **5/110** under the registered mutant, the five survivors of which being exactly the entry-1 corruptions (§2.3). |
| **NF2 judgment call** — eighth replay case at `(oracle,ALine_6)` `corrupt=(:right,7)` **not** taken, "C9's authorized text counts them" | replay-case list left at seven | **ACCEPTED, with the ratchet unblocked below** | correct under law 1: the r4-authorized C9 row says "seven guard cases", so the proposer could not add a case without editing a promoted row. That is a process artefact, not a design decision, and it is now costing coverage (§3 NG1/NG2). §6 authorises the count wording so the next repair may add cases. |
| **N23** NOTE — wire `pad_level_evidence` into `TypedSampler` | deferred to brief 39 (TB5) | **ACCEPTED (still open)** | `src/samplers/typed.jl:141-143` still calls `pad_level`, not `pad_level_evidence`; the latter occurs in `src/` only as its own definition and in `test/tb1_ld_sampler.jl`. Harmless for TB2, which promotes nothing. Re-affirmed as a NOTE for brief 39. |
| **N24** NOTE — `pad_level` not compositional on the empty-register `CLZero` | deferred to brief 39 | **ACCEPTED (still open)** | the brief-59 `_pad_top` change narrows the top-level path (empty → ambient, full register → identity, proper sub-register → `ArgumentError`) but leaves the context-dependence of the empty register intact. Brief 39 must still pass the padding context explicitly. |
| **N25** NOTE — the round trip pins neither the `rest` register nor `BranchByAxis.position` at `m=1` | deferred to brief 39 | **ACCEPTED (still open)** | unchanged in `src/samplers/cl.jl`; TB1's N26 fix pins a `CLZero`'s register, not a `CLStep`'s `rest`. |
| **N26** NOTE — `decode_cl` does not re-impose the ambient partition | done at `src/samplers/cl.jl:683-687`; `tb1_decode_ambient.jl` KILLED | **ACCEPTED** | the gate is `(L isa CLZero \|\| _register(L) == 1:n)`, i.e. exactly the top stage, with inner stages left to `_clstep`; the `CLZero` exemption is required by TB1's own N26 round-trip fixture and is deliberate. Registry KILLED. All 18 TB2 descriptions still round-trip (`describe_roundtrip ok=true`, sizes byte-identical to r4). |
| **TB1 N25 judgment call** — `_pad_top` throws for a top-level zero map on a proper nonempty sub-register | DECIDED: throw | **ACCEPTED for TB2, deferred to `verdicts/tb1-r5.md`** | TB2 promotes no zero map at all (r4 §2.3, re-confirmed: `describe` testset green, no `:zero_map_factor_partition` node), so the branch is unreachable here and C4b is unaffected. The DESIGN §9.4 lockstep edit that this decision requires has **not** landed — see §3 N29. |
| **lockstep** (r4's authorized C4b/C9 rows applied) | orchestrator | **ACCEPTED** | `claims/CLAIMS.md` C9 is byte-identical to r4's authorized text (4535 bytes, exact match). C4b differs in exactly one character — `\\|` → `\\\|` inside a markdown table cell, the same escaping adaptation r4 already recorded. No semantic drift. |

**Score: 9 ACCEPTED · 0 PARTIAL · 0 REJECTED · 0 escapes.** Both r4 MAJORs and all four r4
NOTEs are discharged or correctly deferred, both r4 survivors are now registered mutants
that I observed KILLED, and both fixes overshoot the demand rather than meeting it
minimally.

---

## 2. Independent recomputations (all on the archived copy; scripts under scratch)

Scripts `recompute.jl`, `recompute_mut.jl`, `probe.jl`; logs `recompute.log`, `mut/*.log`.
None of them includes `test/tb2_answer_reduce.jl`, so nothing below is the suite grading
itself.

### 2.1 A third transcription of the guards, written from the source, not from the code

I transcribed the five guarded checks of `fig:decider-pcp`
(`gt-10-answer-reduction.tex:2012-2063`) into my own predicate `my_guards(left,right)` —
items 1, 2, 3, 4(a), 4(b), 4(c), 5 with `alice↔1`, `bob↔2` per `rk:ab-01` — and compared it
with `answer_reduce_guard_branches` on all 2916 ordered pairs:

```
A: pairs=2916  my_enumerator == code_enumerator on all pairs: true
A: MY six-number split = (2736, 180, 107, 92, 54, 53)
```

So the six numbers C9 asserts are now reproduced by four independent transcriptions
(the code's, r4's Julia and Python, and mine).

### 2.2 The lockstep, recomputed against MY enumerator (NF1's fix)

Decider run on all 2916 ordered pairs; trace branch names mapped to figure items by my own
table; compared with `my_guards`, never with the package's enumerator:

```
B  zero seed, zero answers            : mismatches=0  accepted=2916 silent=2736
C2 tb2_seed 5, degenerate-honest answers : mismatches=0  accepted=2916 silent=2736
C3 zero seed,  degenerate-honest answers : mismatches=0  accepted=2916 silent=2736
C1 tb2_seed 5, zero answers           : mismatches=3  accepted=2809 silent=2736
under the registered mutant tb2_decider_guard_widened (step 4(b) `== i` -> `in (i,6)`):
B  zero seed, zero answers            : mismatches=12 accepted=2904 silent=2724
   first = ((oracle,Point_3),(oracle,ALine_6)) decider={proof_individual_low_degree}
           enumerator={} rule=:ld_question_format      <- honest play REJECTED
C2 tb2_seed 5, degenerate-honest answers : mismatches=12
```

Three things follow. (i) The suite's `mismatches=0 accepted=2916 silent=2736` is correct and
is a statement about the **decider**, so NF1 is genuinely closed. (ii) The registered
mutant's evidence line `mismatches=12` is reproduced exactly, and I can name the 12 pairs'
failure mode independently. (iii) The lockstep is stronger than the suite claims: it also
holds with the honest degenerate-proof strategy at a second seed. It is **weaker** than the
suite's wording suggests in one respect — the all-zero answers are honest **only at the
all-zero seed** (`C1`: at `tb2_seed 5` the same answers produce 107 rejections and 3
genuine branch-set mismatches, all from traces truncated by a step-5 rejection). See N27.

### 2.3 Step 1 at arity 22, every entry (NF2's fix)

Honest degenerate-proof answers at `tb2_seed 5`; each of the 22 entries of the right answer
corrupted in turn on each of the five equal-type copy-6 pairs `(alice,Point_6)`,
`(bob,Point_6)`, `(oracle,ALine_6)`, `(oracle,DLine_6)`, `(oracle,Point_6)`:

```
D clean : rejected with rule :global_consistency and trace[end].step == 1 = 110/110, anomalies none
D under tb2_global_consistency_first_entry ([1:1] narrowing) : 5/110
        the five survivors are exactly the entry-1 corruptions; on the four non-oracle-point
        pairs entries 2..22 are ACCEPTED, on (oracle,Point_6) they are rejected by
        :pcpverifier at step 5, never by step 1
```

The suite's `20/20` (entries 1/6/7/22) is the four-entry restriction of my 110/110, and the
mutant's `5/20` the restriction of my 5/110. NF2 is closed, and the "different rule hides
it on `(oracle,Point_6)`" mechanism r4 predicted is confirmed exactly.

### 2.4 What the certificate still carries

```
E: replay cases=7 honest_passed=7 corrupted_rejected=7 (all expected rules)
E: certificate verify=true
E: step-1 cases in certificate = [(:global_consistency, Point_1, (:right, 1))]
E: under tb2_decider_guard_widened : the seven cases and verify_certificate stay GREEN
```

So `verify_certificate` alone still witnesses neither the 2916-pair lockstep nor the
arity-22 step-1 rejection; both live in the suite. That is adequate (law 4 asks for a
red-capable test, which exists and is registered), but C9 must say so — §6 does.

### 2.5 Behavioural witnesses for the two new mutations (§5)

Clean tree versus my two mutants, all at the all-zero seed with all-zero answers (honest
there), corrupting one entry of the right answer:

```
                honest      corrupted            rule                 branches in trace
clean  4b-axis     accept    reject   entry 1   :ld_axis_point       (:proof_individual_axis,)
clean  4b-diag     accept    reject   entry 1   :ld_diagonal_point   (:proof_individual_diagonal,)
clean  4c-axis     accept    reject   entry 7   :ld_axis_point       (:proof_simultaneous_axis,)
clean  4c-diag     accept    reject   entry 7   :ld_diagonal_point   (:proof_simultaneous_diagonal,)
NG1    4b-diag     accept    ACCEPT   entry 1   :answer_reduce_accept(:proof_individual_diagonal,)
NG2    4c-diag     accept    ACCEPT   entry 7   :answer_reduce_accept(:proof_simultaneous_diagonal, :game)
```

Both mutants leave every other row identical to clean, and both leave all 388 TB2
assertions green (§5).

---

## 3. New objections

### NG1 · MAJOR · the *individual* low-degree test (step 4(b)) has no red witness on diagonal lines

**Location** `src/verifiers/answer_reduce.jl:481-495` (step 4(b)'s
`_ar_ld_check` + `_ar_record!` + `rejected === nothing || return rejected`);
`test/tb2_answer_reduce.jl:769-788` (the `guard` testset — the only corrupted-reject test
that reaches step 4(b), and it uses `(oracle,Point_3)/(oracle,ALine_3)`),
`:381-507` (`branches`, honest accept only), `:652-695`
(`replay_seeds` — the seven cases contain **no** 4(b) case at all),
`src/verifiers/answer_reduce.jl:611-641` (`_answer_reduce_replay_cases`).

**My computation.** Enumerate which of the ten `fig:decider-pcp` guard branches have a test
that makes them *reject*: step 1 ✓ (replay case + the new arity-22 block), step 2 ✓ (replay
case + `tb2_mc2`), step 3 axis ✓ and diagonal ✓ (two replay cases), step 4(a) ✓ (replay case
+ `tb2_g3`), step 4(b) **axis only** (`guard` testset's degree rejection and `tb2_line`,
both at `ALine_3`), step 4(c) **axis only** (replay case `proof_simultaneous_axis`), step 5 ✓
(replay case + `tb2_formula`). The two diagonal orientations of step 4 are covered by honest
accepts only. Mutation **NG1**, one line, disarms exactly that branch:

```julia
# answer_reduce.jl:495, step 4(b)
-                rejected === nothing || return rejected
+                rejected === nothing || line_kind == :DLine || return rejected
```

```
MUTANT ng1_step4b_diagonal_never_rejects  TB2_TARGET=all
       exit=0  started=true  assertion_failures=false  seconds=101.83  => SURVIVED
```

It is not a no-op: §2.5 shows the mutated decider **accepts** a corrupted `DLine_3` answer at
`(oracle,Point_3)` that the clean decider rejects with `:ld_diagonal_point`. Note that the
new lockstep testset cannot see it — the branch still fires and still appears in the trace,
so `mismatches` stays 0 — and `TB2_GUARD_NAMES` maps `proof_individual_diagonal` and
`proof_individual_axis` to the same enumerator name, so even a branch-label swap is invisible
there (N28).

**FIX DEMAND** Add an eighth case to `_answer_reduce_replay_cases()`:
`(case=:proof_individual_diagonal, step=4, left=(oracle,Point_3), right=(oracle,DLine_3),
corrupt=(:right,1), expected_rule=:ld_diagonal_point)`. Putting it there rather than in a
testset carries the fact **inside the certificate** and inside the existing three-seed
`replay_seeds` sweep for free, and closes r4's N9 residue for this branch. Register **NG1**
as `test/mutations/tb2_individual_diagonal_never_rejects.jl` (target `tb2_replay_seeds`)
and show it KILLED. §6 authorises the C9 wording change from "seven" to "nine" so law 1
does not block this.

**SURVIVING WEAKER STATEMENT** Step 4(b) is implemented correctly at this commit — I verified
directly that the clean decider rejects a corrupted diagonal line answer with
`:ld_diagonal_point`, and the shared `_line_point_test` diagonal path *is* red-capable at
`ldparams=(q,m,d,1)` through step 3's `input_diagonal` replay case. What is missing is any
test that fails when step 4(b)'s own diagonal rejection is removed.

### NG2 · MAJOR · the *simultaneous* low-degree test (step 4(c)) has no red witness on diagonal lines

**Location** `src/verifiers/answer_reduce.jl:498-511` (step 4(c));
`test/tb2_answer_reduce.jl:790-812` (`dline_projection`, which calls `ld_decider` directly,
not the decider, and asserts `passed` only); `src/verifiers/answer_reduce.jl:633-636` (the
`proof_simultaneous_axis` replay case, the only 4(c) corrupted case).

**My computation.** Mutation **NG2**:

```julia
# answer_reduce.jl:511, step 4(c)
-                rejected === nothing || return rejected
+                rejected === nothing || line_kind == :DLine || return rejected
```

```
MUTANT ng2_step4c_diagonal_never_rejects  TB2_TARGET=all
       exit=0  started=true  assertion_failures=false  seconds=99.17  => SURVIVED
```

§2.5: the mutated decider **accepts** a corruption of entry 7 of the 22-polynomial `DLine_6`
answer at `(oracle,Point_6)` which the clean decider rejects with `:ld_diagonal_point`, and
then proceeds to step 5 and accepts outright. This is the `ldparams'=(q,m',d,m'+6)`
configuration — the only place in the whole corpus where a 22-fold diagonal test runs — and
nothing anywhere makes it reject: `dline_projection` exercises `ld_decider` at
`LDParams(GF2048,16,11,22)` on a diagonal line but asserts only that honest answers pass.

**FIX DEMAND** Add a ninth replay case
`(case=:proof_simultaneous_diagonal, step=4, left=(oracle,Point_6), right=(oracle,DLine_6),
corrupt=(:right,7), expected_rule=:ld_diagonal_point)`, register **NG2** as
`test/mutations/tb2_simultaneous_diagonal_never_rejects.jl` (target `tb2_replay_seeds`) and
show it KILLED. Equivalently, extend `dline_projection` with a corrupted-entry assertion —
but the replay case is preferred because it also lands in the certificate.

**SURVIVING WEAKER STATEMENT** Step 4(c) is implemented correctly at this commit on both
orientations (verified directly), the `ldparams'` tuple `(2048,16,11,22)` is asserted to
occur in a trace, and `tb2_mc3` owns the case where 4(c) uses `ldparams` instead of
`ldparams'`. What is missing is a test that fails when 4(c)'s diagonal rejection is removed.

### N27 · NOTE · the lockstep's "honest accept" is the all-zero answers at the all-zero seed

`test/tb2_answer_reduce.jl:585-596` uses `_answer_reduce_replay_answer` (all zeros) at
`zero_seed`. That is honest **there** and nowhere else: §2.2's `C1` shows that the same
answers at `tb2_seed 5` produce 107 rejections and 3 branch-set mismatches. The proposer's
merge-proposal wording "with honest accept everywhere" would therefore overclaim if read as
"the honest TB0 strategy". The underlying fact is nonetheless true and stronger than the
suite checks — I ran the lockstep with honest degenerate-proof answers at both the zero seed
and `tb2_seed 5` and got `mismatches=0 accepted=2916` in both — so §6's authorised C9 text
states the suite's version and attributes the stronger version to this recomputation. A
one-line strengthening of the testset (use `honest_pcp_answer` at a nonzero seed for the 180
triggering pairs) would let C9 drop the qualifier.

### N28 · NOTE · `TB2_GUARD_NAMES` collapses axis and diagonal, and `branches` only asserts a superset

`test/tb2_answer_reduce.jl:567-576` maps `input_axis`/`input_diagonal` (and both
`proof_individual_*`, both `proof_simultaneous_*`) onto one enumerator name, so the lockstep
is blind to the line-kind half of a branch label. The `branches` testset does pin all 37
`(step, branch, player, index, line_kind)` keys — but with `in covered`, i.e. as a **subset**
assertion, so an extra or mislabelled entry on some other pair is still invisible. This is
sound today (I checked the label on every branch my probes reached) and is cheap to harden:
assert `covered == expected_keys` rather than `⊆`.

### N29 · NOTE · brief 59's DESIGN merge proposals have not landed — a live lockstep divergence

`briefs/59-…last.md` proposes §9.4 "a top-level zero map declared on a proper nonempty
sub-register is refused by `pad_level` (`ArgumentError`)" and §9.3 "stage matrix entries are
serialized row-major …; `decode_cl` re-imposes `factor ⊎ rest = {1..n}` on the top stage".
Neither string occurs in `docs/DESIGN.md`, at `3f2d1f1` or live (`diff` of the two is empty).
So §9.4 still states the old rule — `pad_level` promotes "with `V_1` = … its register `R`" —
which `src/samplers/typed.jl:36-42` now refuses. Law 2 divergence; orchestrator lane, and the
substance belongs to `verdicts/tb1-r5.md` (C4a), not to C4b/C9. Recorded here only so it is
not lost between the two lanes.

### N30 · NOTE · the certificate's replay list is still seven arity-1/entry-7 cases at the all-zero seed

Answering the dispatching brief's question directly: the arity-22 step-1 fact is **adequately
owned** — by a red-capable testset with a registered, KILLED mutant — but it is **not** owned
inside `verify_certificate` (§2.4), and neither is the 2916-pair lockstep. Both NG1 and NG2
would be closed by extending the same seven-case list, which is why §3's fix demands target
it rather than adding a fourth testset. r4's N9 residue (moving the three seeds into
`_answer_reduce_replay_steps`) remains open and now has a second reason to be done.

---

## 4. Test and mutation evidence I observed

```
SUITE (archived tree 3f2d1f1, warm depot)
  RUN 1  (load average 4.21 -> 7.14; 4 other `julia --project` processes at start)
    MIPStarLambda load/precompile seconds = 0.706 (ungated)
    TB0 test-body wall seconds = 33.932 (warning=45.0, hard_limit=60.0)   <-- GATE PASSED
    Test Summary: MIPStarLambda | Pass 907  Total 907  Time 2m20.7s
    /usr/bin/time -v: Elapsed 2:22.43 · Maximum RSS 1,443,148 KiB · Exit status 0
  RUN 2  (load average 6.93 -> 3.44; 4 other `julia --project` processes at start)
    TB0 test-body wall seconds = 35.024 (warning=45.0, hard_limit=60.0)   <-- GATE PASSED
    Test Summary: MIPStarLambda | Pass 907  Total 907  Time 1m24.1s
    /usr/bin/time -v: Elapsed 1:26.51 · Maximum RSS 1,448,284 KiB · Exit status 0
    Every printed TB0/TB1/TB2/TB3 line is byte-identical between the two runs except one
    timing line (`DLine_6 apply` 2.35 -> 0.93 us warm, 7.3 -> 2.91 us fresh).
    The dispatching brief's 74.6 s / 85.2 s figures for this commit did not reproduce:
    25 s of headroom in both runs, at load 4.2 and 6.9. No timing NOTE is filed.

  TB2 lines observed (both runs, identical):
    TB2 sampler: PCP types=18 edges=324 dims V6=(16,6,16) SOURCE_REPAIR=true;
                 product types=54 edges=2916 level=3
    MUTATION_EXPECTED_RULE product_projection agrees=true compared=1080
    MUTATION_EXPECTED_RULE certificate rule=certificate_replay passed=true
    MUTATION_EXPECTED_RULE describable actual=18/18
    MUTATION_EXPECTED_RULE describe_roundtrip ok=true
    MUTATION_EXPECTED_RULE guard_split actual=(2736, 180, 107, 92, 54, 53)
    MUTATION_EXPECTED_RULE guard_lockstep mismatches=0 accepted=2916 silent=2736 first=nothing
    MUTATION_EXPECTED_RULE global_consistency arity=22 rejected_with_rule=20/20
    MUTATION_EXPECTED_RULE branches first_failure=none failures=0
    MUTATION_EXPECTED_RULE ld_axis_degree actual=ld_axis_degree passed=false
    MUTATION_EXPECTED_RULE i345 actual=(3, 4, 5)
    TB2 describe: Point_*=3009 ALine_1..5=2893 ALine_6=10228 DLine_1..5=2754 DLine_6=10479
    TB2 lem:cl-kth replay: chain_set_id=tb2-chi16-directed+rng20(0x9C);
                 distinct_chains 36 everywhere except Point_3=34, ALine_5=35; 36 replays/map
    TB2 memo: distinct Linear prefixes=10000 limit=4096 max_entries=1844 entries=1916 nodes=53
    TB2 deterministic branches: covered=37 seeds=37
    TB2 seeded conditioned suite: RNG=0x182048 full-field seeds=256 accepted=256
    TB2 replay at 3 seeds: cases=7 outcomes=21 honest=21 corrupted_rejected=21
    TB2 TRACE step4 shows :proof_simultaneous_diagonal with ldparams (2048, 16, 11, 22) PASS
  TB2 testset sizes (388 assertions): sampler 26, describe 126, parsers 1, branches 46,
    seeded 3, no_check 3, LOCKSTEP 79 (new), replay_seeds 86, game 9, proof_consistency 2,
    line 2, guard 2, dline_projection 2, i345 1.

MUTATION RUNNER (`julia --project=. test/mutations/run.jl`, load 2.24 -> 7.84)
  package image ready after 0.66 s
  BASELINE (unmutated-first): 43/43 OK, every target exits 0
  TB0 25/25 KILLED · TB1 35/35 KILLED · TB2 16/16 KILLED · TB3 5/5 KILLED
  new this round, both KILLED with their registered evidence lines:
    TB2 NF1-decider-guard-widened step4b_copy_in_i_or_6  target=tb2_lockstep (exit=1, 17.50 s)
    TB2 NF2-global-consistency-first-entry               target=tb2_lockstep (exit=1, 24.34 s)
  MUTATION REGISTRY: killed=84/84 baselines ok=43/43 wall=304.88 s
  /usr/bin/time -v: Elapsed 5:05.25 · Maximum RSS 732,356 KiB · Exit status 0
  No SURVIVED, no LOAD-ERROR, no UNATTRIBUTABLE, no BROKEN baseline.
  (The proposer's figure was 643.02 s under its own load; mine is 304.88 s on the
  performance governor. Same registry, no time gate.)
```

## 5. New mutations written by this critic (applied on isolated copies; the tree was never modified)

Each was run as the registry runs one — `Base.include(MIPStarLambda, <mutated copy>)` then the
whole `test/tb2_answer_reduce.jl` with `TB2_TARGET=all` — alongside an unmutated baseline in
the same shape, all three concurrently at load ≈ 7.5.

| id | mutation | expectation | outcome |
|---|---|---|---|
| baseline (control) | none | must pass | **OK** (exit 0, 388 assertions, 92.30 s) |
| **NG1** (new) | `answer_reduce.jl:495` step 4(b): `rejected === nothing \|\| return rejected` → `rejected === nothing \|\| line_kind == :DLine \|\| return rejected` — the individual low-degree test never rejects on a diagonal line | probe: is step 4(b) red-capable on `DLine`? | **SURVIVED** (exit 0, 0 failed assertions, whole TB2 file, 101.83 s) → **NG1**; §2.5 shows a corrupted `DLine_3` answer accepted where clean rejects with `:ld_diagonal_point` |
| **NG2** (new) | `answer_reduce.jl:511` step 4(c): same edit — the simultaneous `ldparams'` test never rejects on a diagonal line | probe: is step 4(c) red-capable on `DLine`? | **SURVIVED** (exit 0, 0 failed assertions, whole TB2 file, 99.17 s) → **NG2**; §2.5 shows a corrupted entry 7 of the 22-polynomial `DLine_6` answer accepted where clean rejects with `:ld_diagonal_point` |
| **NF1** (r4 survivor, re-run as registered) | verbatim `test/mutations/tb2_decider_guard_widened.jl` | must now break | **KILLED** in the registry (exit 1, 17.50 s) and reproduced independently at `mismatches=12` by my own enumerator (§2.2) |
| **NF2** (r4 survivor, re-run as registered) | verbatim `test/mutations/tb2_global_consistency_first_entry.jl` | must now break | **KILLED** in the registry (exit 1, 24.34 s) and reproduced independently at `5/110` by my own sweep (§2.3) |

Both survivors are the same family as r4's — a check is red-capable only on the pairs a
hand-written list names — displaced one notch: r4's probes found it in the *guard set* and
the *answer arity*, r5's find it in the *line kind*. One two-line addition to
`_answer_reduce_replay_cases()` closes both, and unlike r4's fix it lands inside the
certificate.

---

## 6. Per-claim decisions

Both statuses are already TESTED and both are **re-affirmed**. Every fact either row asserts
is true at `3f2d1f1` and has been independently recomputed here. The two new MAJORs are
recorded as **scope** in C9, not as a downgrade: the diagonal step-4 checks are implemented
correctly and accept honest play; what is missing is a test that can fail when they are
removed. No claim moves up or down this round.

### C4b — **RE-AFFIRMED TESTED**, row text UNCHANGED except one column. The following edit is **AUTHORIZED**:

> In the C4b row of `claims/CLAIMS.md`, leave the statement, status, depends-on and test
> columns exactly as they stand (including the `\\\|` escaping already applied), and replace
> the final column
> `` `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md` ``
> by
> `` `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md`, `verdicts/tb2-r5.md` ``.

Rationale: nothing this round touched the sampler or the serializer except `decode_cl`'s new
ambient gate, which only makes `decode_cl` stricter and leaves all 18 descriptions,
sizes and round trips byte-identical (§4); that gate's red witness is a TB1 mutant and
belongs to C4a. C4b's N23 sentence (`TypedSampler`'s padding path builds no
`pad_level_evidence`) is still true and stays.

### C9 — **RE-AFFIRMED TESTED**, row text replaced. The following is **AUTHORIZED VERBATIM**:

> | C9 | (Typed answer-reduced decider — TB0 fixture) For the row `(q,k,m,d,s,m')=(2048,11,1,11,6,16)`, the trivial two-coordinate original sampler and its three-role oracularization, the typed answer-reduced decider implements the five guarded checks of `fig:decider-pcp` with the exact type-pair guards, the `i in {3,4,5}` restriction and both `ldparams=(q,m,d,1)` and `ldparams'=(q,m',d,m'+6)`; the honest strategy built from the TB0 PCP proof (witness (ii) for checks 4(a)/4(b)) is accepted on all 37 directed guard orientations at 37 distinct seeds and on 256 conditioned seeded question pairs at 256 distinct full-field seeds whose `chi(s_aux,m')` covers all 16 values, and every honest line answer checked equals the true restriction of the corresponding PCP polynomial at all `q=2048` line points (critic recomputation, `verdicts/tb2-r1.md` and `verdicts/tb2-r2.md` §2.3; the suite itself checks one such line through `D^ld`). Exactly `2736/2916 = 76/81 = 93.827%` of ordered product-type pairs trigger no check; of the remaining 180, 107 trigger step 5 (92 of them step 5 alone) and 54 trigger step 1 (53 of them step 1 alone) — the r1/r2 wording "107 only step 5 and 54 only step 1" was arithmetically wrong and is corrected here (`verdicts/tb2-r3.md` N10); all six numbers `(2736, 180, 107, 92, 54, 53)` are asserted by the suite and owned by the mutant `tb2_guard_split`, and this critic reproduced them by two further independent transcriptions of the guards (one in Julia, one in Python), together with the decomposition 1 + 4 + 6 + 4 of the fifteen step-5 pairs that also fire another guard. The decider itself, not only the enumerator `answer_reduce_guard_branches`, is now run on all 2916 ordered pairs — at the all-zero seed with the certificate replay's all-zero answers, which are honest there — and its trace fires exactly the enumerated branch set pair for pair, with an empty trace on exactly the 2736 and an accept on all 2916; the step-4(b) widening mutant `tb2_decider_guard_widened` is KILLED at 12 mismatches, and this critic reproduced the lockstep against a third, independently written transcription of `fig:decider-pcp` (0 mismatches clean, 12 mutated) and extended it to honest degenerate-proof answers at two seeds, where it also holds (`verdicts/tb2-r5.md` §2.2). The questions judged are the projections of the 54-type product sampler's own `sample` output, asserted equal to the explicit seed split on 20 seeds x 54 types x both sides (`verdicts/tb2-r2.md` N1 repaired in brief 46; independently recomputed in `verdicts/tb2-r3.md` §2.1). The `:TypedAnswerReduce` certificate replays shape, branch reachability and, for each of seven guard cases, one honest accept and one corrupted reject carrying the expected rule (ibid. N2 repaired). **Scope:** step 5 executes only items 3-5 of `fig:pcpverifier`; items 1-2 (`PaddedSuccinctDecider` -> Tseitin -> arithmetization) are not implemented, the formula is a construction-time constant, and the computed `x_alice=L^alice(x_Q)`, `x_bob=L^bob(x_Q)` reach `pcp_decider_specification` but do not enter the decision — asserted, including the equal verdict under a swapped call (`SOURCE_REPAIR :PCPVerifierFixedFormula`; `verdicts/tb2-r1.md` O3). Step 5's "otherwise, accept" is read as fallthrough, so the decider is strictly stricter than the literal source (`SOURCE_REPAIR :PCPGameOtherwiseFallthrough`; ibid. O8); the executable runs player-outer where the source is step-outer, with identical verdicts because every rejection is terminal (`verdicts/tb2-r2.md` N4). The seven-case replay carried inside the certificate still runs at the all-zero seed only; the suite re-runs the same seven cases with honest TB0-proof answers at three seeds (all-zero, `tb2_seed 5`, RNG 0x9E) and asserts honest accept, corrupted reject, the expected rule and the reached step for all 21 (case, seed) pairs, recomputed independently by this critic (`verdicts/tb2-r3.md` N9, `verdicts/tb2-r4.md` §2.5). Step 1 compares the full bundle: on all five equal-type copy-6 pairs the suite asserts that corrupting entry 1, 6, 7 or `m'+6 = 22` of the 22-entry right answer is rejected with rule `:global_consistency` at step 1 (20/20), the first-entry-narrowing mutant `tb2_global_consistency_first_entry` is KILLED at 5/20, and this critic swept every one of the 22 entries on all five pairs (110/110 rejected with that rule; 5/110 under the mutant) (`verdicts/tb2-r5.md` §2.3). Both facts are carried by the suite, not by the `:TypedAnswerReduce` certificate, whose replay list is still the seven cases at the all-zero seed. The *diagonal* orientation of the two step-4 low-degree checks has no corrupted-reject witness anywhere in the corpus: disarming the rejection of step 4(b), or of step 4(c), when `line_kind == :DLine` leaves all 388 TB2 assertions green, although the mutated decider then accepts a corrupted `DLine_3` line answer at `(oracle,Point_3)`, resp. a corrupted entry 7 of the 22-polynomial `DLine_6` answer at `(oracle,Point_6)`, that the clean decider rejects with `:ld_diagonal_point` (`verdicts/tb2-r5.md` NG1, NG2). The `i in {3,4,5}` restriction has no honest-play consequence and is evidenced only structurally (O14). `m=1` makes checks 3 and 4(b) act on the whole of `F_q^1`, and honest answer degrees are 1 against the declared bound `d=11` (O12). Detyping, its `+2` levels and its `16^54` loss, and every quantum conclusion remain CITED. | TESTED | D1,D2,C3,C4a,C4b | — | `test/tb2_answer_reduce.jl`; red: `test/mutations/tb2_{formula,g3,line,guard,guard_split,i345,mc1,mc2,mc3,nd2,nd4,tensor,opaque,decider_guard_widened,global_consistency_first_entry}.jl` | `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md`, `verdicts/tb2-r5.md` |

Three notes on the authorised text, for the proposer. (a) The NF1 replacement says
explicitly that the lockstep runs at the all-zero seed with the all-zero replay answers
(N27); the stronger honest-strategy version is attributed to this critic's recomputation,
not to the suite. When the testset is strengthened as N27 suggests, the qualifier may be
dropped. (b) The NG1/NG2 scope sentence is to be **deleted** — not weakened — by the next
repair that lands the two diagonal replay cases. (c) The row still says the certificate
replays "seven guard cases". **That count is hereby unfrozen**: when the two diagonal cases
of §3 land, the proposer is authorised to change "seven" to "nine" in both places it occurs
and to update the accompanying "21 (case, seed) pairs" to "27", with no other edit to the
row. This removes the law-1 obstacle that made brief 59 decline the eighth case.

### C4a, C4c, C7, C12 — not this rung's business

C4a and C4c belong to `verdicts/tb1-r5.md`; I express no opinion on the brief-59 TB1 rows
beyond observing that all 35 TB1 mutants are KILLED with clean baselines in the registry I
ran, and that the DESIGN §9.3/§9.4 merge proposals those rows depend on have not landed
(N29). C7 stays CONJECTURE. C12 stays CONJECTURE; nothing this round changes r4 §6.2's
finding that `description_size` is not additive under `direct_sum`.

---

## 7. Work order for the next round (small, and terminating)

1. **NG1 + NG2 (MAJOR).** Two entries appended to `_answer_reduce_replay_cases()` —
   `(:proof_individual_diagonal, (oracle,Point_3)/(oracle,DLine_3), corrupt=(:right,1),
   :ld_diagonal_point)` and `(:proof_simultaneous_diagonal,
   (oracle,Point_6)/(oracle,DLine_6), corrupt=(:right,7), :ld_diagonal_point)` — plus the two
   registered mutants of §3, plus the C9 count edits §6 authorises. This is the whole fix.
2. **N27 (NOTE).** Optionally run the lockstep's 180 triggering pairs with
   `honest_pcp_answer` at a nonzero seed so C9 need not qualify "honest".
3. **N28 (NOTE).** Turn `branches`' `in covered` superset assertions into an equality.
4. **N29 (NOTE).** Orchestrator: apply brief 59's DESIGN §9.3/§9.4 merge proposals, or say
   why not; `docs/DESIGN.md` §9.4 currently contradicts `src/samplers/typed.jl:36-42`.
5. **N30 / r4 N9 residue (NOTE).** Move the three seeds into `_answer_reduce_replay_steps`
   so `verify_certificate` alone witnesses them; item 1 puts two more cases in its path.
6. **TB2 N23, N24, N25 (NOTE).** Unchanged, brief 39 (TB5).

**Why this family terminates.** `fig:decider-pcp` has exactly ten guard branches at these
parameters: `global_consistency`, `input_consistency`, `input_{axis,diagonal}`,
`proof_consistency`, `proof_individual_{axis,diagonal}`,
`proof_simultaneous_{axis,diagonal}`, `game`. Eight have a corrupted-reject witness today;
item 1 supplies the last two. After it, every branch is red-capable, the guard *set* is
pinned pair-for-pair by the r4 lockstep, and the answer *arity* is pinned by the r4 step-1
sweep — the three axes along which r3, r4 and r5 each found one more hand-written list are
then all closed, and I have no further probe of this shape to run.

Objection trajectory for this rung: **14 → 5 → 5 → 6 → 6** (r1: 1 FATAL + 4 MAJOR + 6 MINOR +
3 NOTE; r2: 1 MAJOR + 2 MINOR + 2 NOTE; r3: 1 MAJOR + 3 MINOR + 1 NOTE; r4: 2 MAJOR + 4 NOTE;
r5: 2 MAJOR + 4 NOTE). The count is flat but the severity is not: every r4 objection is
discharged with no escapes and both r4 fixes overshoot their demands, all 84 registered
mutants are KILLED with 43/43 clean baselines, and this round's two MAJORs are each one line
kind of one check — a strictly smaller target than r4's whole guard set and whole answer
bundle, closed by an eight-line edit that also lands the fact inside the certificate. Three
of the four NOTEs are wording or process, not code. I would have said PASS had the two
diagonal probes died; they did not, and law 4 does not care that the code is correct.

VERDICT: FAIL(NG1,NG2)
