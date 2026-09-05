# Verdict tb2-r6 — adversarial critic on rung TB2 after repair r5 (commit `7423c53`, brief 65) — intended closing round

Evaluated on an archived copy (`git archive 7423c53 | tar -x`) in
`/tmp/claude-1000/.../scratchpad/critic-tb2-r6/tree/`, instantiated there; cold
precompile of `MIPStarLambda` **87.79 s** (`real 1m43.07` including the registry
update), at one-minute load average **3.38**. The live working tree was never read
for `src/` or `test/`; `claims/CLAIMS.md` and `docs/DESIGN.md` were read live
(orchestrator-owned) and both are **byte-identical** to the archived copies (`diff`
empty), so nothing below depends on a stale copy. No git command that changes state
was run; every mutation was applied to a copy under the scratch directory. This
verdict file is the only file written.

**Power/load caveat (binding for every wall below).** `powerprofilesctl get` reports
**`balanced`**, not the `performance` the dispatching brief expected; I did not change
it. Every wall below is reported with `uptime`'s one-minute load at its start and end.
The TB0 60 s gate was comfortable in both suite runs (**20.78 s** and **35.34 s**
against warning 45.0 / hard limit 60.0), but the 14.6 s spread between two runs of the
same commit on the same box confirms `verdicts/tb1-r5.md` N33: the gate is
CPU-clock/load-bound, not workload-bound.

Files under review (delta `3f2d1f1..7423c53`, TB2 lane):
`src/verifiers/answer_reduce.jl` (+14/-2: the eighth and ninth replay cases),
`src/verifiers/ldt.jl` (+26/-8: N29 variant (b), inherited by TB2),
`src/samplers/cl.jl` (+14: the `direct_sum` zero-map normalisation),
`test/tb2_answer_reduce.jl` (+114/-31), `test/mutations/tb2_*.jl` (18 files, was 16),
`test/mutations/run.jl`, `test/tb3_frontend.jl` (the one cross-lane edit),
`claims/CLAIMS.md` C4b/C9 (unchanged this round), `docs/DESIGN.md`.

---

## 1. Adjudication of every r5 row

| r5 item | claimed in `briefs/65-…last.md` | **adjudication** | my evidence |
|---|---|---|---|
| **NG1** MAJOR — eighth replay case, step 4(b) diagonal corrupted-reject | added at `answer_reduce.jl:637`; mutant `tb2_individual_diagonal_never_rejects.jl` KILLED | **ACCEPTED** | the case is present and is exactly the demanded one — `(:proof_individual_diagonal, step 4, (oracle,Point_3)/(oracle,DLine_3), corrupt (:right,1), :ld_diagonal_point)` (§2.3 row 6). Registry: KILLED, exit 1, 45.22 s, target `tb2_replay_seeds`. I recomputed the case at all three seeds without the suite: honest accept 3/3, corrupted reject 3/3, rule `:ld_diagonal_point` 3/3, and — stronger than the suite asserts — the *rejecting* trace entry is step 4 in all three. |
| **NG2** MAJOR — ninth replay case, step 4(c) diagonal corrupted-reject | added at `answer_reduce.jl:645`; mutant `tb2_simultaneous_diagonal_never_rejects.jl` KILLED | **ACCEPTED** | `(:proof_simultaneous_diagonal, step 4, (oracle,Point_6)/(oracle,DLine_6), corrupt (:right,7), :ld_diagonal_point)`; registry KILLED, exit 1, 30.36 s. Same independent recomputation, 3/3 on every count. Both mutants' registered evidence line `cases=9 outcomes=27 honest=27 corrupted_rejected=24` is the right discriminator: the clean run prints `corrupted_rejected=27` (observed in both suite runs). |
| **NG1/NG2 certificate coverage** | certificate replay = 9 outcomes; suite replay = 27 (case,seed) pairs, 6 diagonal | **ACCEPTED** | `verify_certificate` returns `CheckResult(true, :certificate_replay, :TypedAnswerReduce, …)` and `_answer_reduce_replay` gives **9** outcomes with rules `[:global_consistency, :input_consistency, :ld_axis_point, :ld_diagonal_point, :proof_consistency, :ld_diagonal_point, :ld_axis_point, :ld_diagonal_point, :pcpverifier]`, all `honest && !corrupted` — recomputed outside the suite (§2.4). Suite: `TB2 replay at 3 seeds …: cases=9 outcomes=27 honest=27 corrupted_rejected=27`, and the testset now carries 111 assertions (was 86). |
| **N27** NOTE — the lockstep's "honest" beyond all-zero answers at the zero seed | second 2916-pair lockstep at `tb2_seed 5` with honest TB0-proof answers, witness (ii) where needed | **ACCEPTED, and it overshoots the demand** (the note asked only for the 180 triggering pairs) | suite prints `guard_lockstep_honest seed=tb2_seed5 mismatches=0 accepted=2916 silent=2736 first=nothing`. My own run, against my own transcription of `fig:decider-pcp` and never against the package enumerator, reproduces `mismatches=0 accepted=2916 silent=2736` at that seed and `mismatches=0 accepted=2916 silent=2736` at the zero seed (§2.2). I also confirm the witness split the testset uses: exactly **18 of 2916** ordered pairs fire step 4(a) or 4(b) and so require witness (ii); the other 2898 use the degenerate proof. C9's "which are honest there" qualifier can indeed be dropped — §6 does. |
| **N28** NOTE — `TB2_GUARD_NAMES` collapsed axis/diagonal; `branches` asserted only `⊆` | lockstep keys are `(check, line_kind)` with a branch-suffix/line-kind consistency check; `branches` asserts `covered == expected_keys` (37) | **ACCEPTED** | both changes are present (`tb2:489-508`, `:604-619`, `:641-642`). I enumerated the 37 `(step, branch, player, index, line_kind)` keys independently and got **37**, agreeing set-for-set with the file's `expected_keys`. The fix is red-capable, not decorative: my mutation **MG4** (step 4(b) labels every line kind `:proof_individual_axis`) is **KILLED** (exit 1, 66.75 s), which under r4/r5's code would have been invisible. My own 2916-pair key enumeration also agrees with `answer_reduce_guard_branches` + line kind on **all 2916 pairs** and reaches exactly **10** distinct keys. |
| **N29** NOTE — brief-59 DESIGN §9.3/§9.4 merges unlanded | orchestrator (commits `f8bd881`, `0f67e31`) | **ACCEPTED (closed)** | `docs/DESIGN.md` §9.3 now carries "stage matrix entries are serialized row-major `(1,1),(1,2),…,(w,w)`, pinned by an off-diagonal witness, and `decode_cl` re-imposes `factor ⊎ rest = {1..n}` on the top stage (brief 59)"; §9.4 carries "A top-level zero map declared on a proper nonempty sub-register is refused by `pad_level` (`ArgumentError`) … (brief 59, `verdicts/tb1-r5.md` N25)". The brief-65 DESIGN proposals also landed: DD-4 item 4's N29-variant-(b) sentence (`DESIGN.md:1058-1060`) and §9.4's `direct_sum` normalisation sentence, the latter with a citation-format adaptation ("(brief 65, `verdicts/tb1-r5.md` N30)" for "(`verdicts/tb1-r5.md` N30; `tb1_dsum_zero_spellings.jl`)") — scaffolding only, no semantic drift. |
| **N30** NOTE — certificate versus suite ownership | disposition: nine cases inside the certificate; three-seed replay and both locksteps stay suite-owned; r4 N9 residue → TB5 | **ACCEPTED** | verified: `_answer_reduce_replay_steps` still runs the nine cases at the all-zero seed only (§2.4), and neither lockstep nor the arity-22 sweep is inside `verify_certificate`. That is an adequate disposition under law 4 — both facts have red-capable, registered owners — and C9 says so. r4's N9 residue stays open, re-affirmed as a brief-39 NOTE. |
| **TB1 N29 variant (b) inheritance** | "TB2 inherits (b) … at the all-zero seed every DLine is degenerate, so the certificate's three diagonal cases compare at all 2048 t (×22 for 4(c))" | **ACCEPTED (recomputed exactly)** | all **18** `DLine` types have zero direction at the all-zero seed; the eighth case compares at `kappa=1 × 2048 = 2048` parameters and the ninth at `kappa=22 × 2048 = 45,056`; both lines are non-degenerate at `tb2_seed 5` (§2.5). One caveat, filed as NG8: TB2 does not itself *witness* the all-`t` reading. |
| **N23 / N24 / N25** NOTE — `pad_level_evidence` wiring, `pad_level` on the empty register, the `rest`/`BranchByAxis.position` round trip | out of scope for brief 65, deferred to brief 39 | **ACCEPTED (still open)** | correctly excluded by the dispatching brief; unchanged at this commit; re-affirmed below as a NOTE for brief 39. |
| **Cross-lane edit** `test/tb3_frontend.jl:631-632,650,654` (`7` → `9`) | the only cross-lane edit; all 9 decisions accepted | **PARTIAL** | the code edit is right and TB3 is green (`(f),(h)` testset 36/36). But `docs/DESIGN.md` §5.5 was not moved with it and still reads "so TB2's block-locality evidence survives: **7/7 guard cases**" (`DESIGN.md:975`) — a live law-2 divergence created by this round. Objection **NG4**. |
| **MERGE PROPOSALS — DESIGN** | as listed | **ACCEPTED** (see N29 row); applied by the orchestrator at `0f67e31`, verbatim modulo the citation format |
| **MERGE PROPOSALS — CLAIMS (C4a, C4c, C9)** | "C9's row already says 'nine cases / 27 (case,seed) pairs' (unfrozen by the critic) — match it" | **REJECTED as stated, ACCEPTED as a proposal** | the assertion is false. `claims/CLAIMS.md` C9 is **byte-identical** (5,748 bytes, `diff` empty) to the text `verdicts/tb2-r5.md` §6 authorised, which says "seven guard cases", "all 21 (case, seed) pairs", "still the seven cases", and still carries the NG1/NG2 scope sentence. r5 *unfroze* the count; it did not pre-apply it. No ratchet violation occurred — nothing was edited — but the proposer's and the dispatching brief's shared premise was wrong, and the C9 row is therefore out of lockstep with the code it describes at this commit. Objection **NG6**; §6 supplies the row that fixes it. The C4a/C4c proposals are `verdicts/tb1-r6.md`'s business, not mine. |
| **lockstep of the r5 promotions** | orchestrator (`076a356`, `4810bd8`) | **ACCEPTED** | C9 exactly as authorised (above). C4b's verdict cell reads `…, verdicts/tb2-r4.md; verdicts/tb2-r5.md (re-affirmed)` where r5 authorised `…, verdicts/tb2-r4.md, verdicts/tb2-r5.md`: a punctuation-plus-parenthetical adaptation that adds no claim. Accepted. |

**Score: 11 ACCEPTED · 2 PARTIAL/REJECTED-as-stated · 0 escapes.** Both r5 MAJORs are
discharged with registered, independently reproduced kills; both r5 NOTES that asked
for code (N27, N28) were overshot rather than met minimally; the one unlanded r5 NOTE
(N29) is now landed. The two non-clean rows are documentation lockstep, not code.

---

## 2. Independent recomputations (archived copy; scripts under scratch)

`recompute.jl`, `swapprobe.jl`, `probe54.jl`, `mutate.jl`; logs `recompute.log`,
`swap_*.out`, `mut_*.out`. **None of them includes `test/tb2_answer_reduce.jl`**, so
nothing in this section is the suite grading itself. The fixtures, the reduction and
`tb2_seed` are rebuilt from the package API; every predicate below is mine.

### 2.1 A fourth transcription of `fig:decider-pcp`, as `(check, line_kind)` keys

Items 1, 2, 3, 4(a), 4(b), 4(c), 5 transcribed from
`gt-10-answer-reduction.tex:2012-2063` with `alice↔1`, `bob↔2` (`rk:ab-01`), producing
keys directly rather than branch names:

```
A: my_keys == code_keys on all ordered pairs: true (agree=2916)
A: MY six-number split = (2736, 180, 107, 92, 54, 53)
A: distinct (check,line_kind) keys reachable over pairs = 10
B: my expected key count = 37
```

The six numbers C9 asserts now have five independent transcriptions behind them. The
37-key set is reproduced exactly, so N28's `covered == expected_keys` is not a
self-consistency check of the test file.

### 2.2 Both locksteps, against MY enumerator

```
C1 zero seed, all-zero answers          : mismatches=0 accepted=2916 silent=2736 first=nothing
C2 tb2_seed 5, honest TB0-proof answers : mismatches=0 accepted=2916 silent=2736 first=nothing
C2 seed nonzero = true
C2 pairs requiring witness (ii) [nondegenerate] = 18/2916
```

The decider's trace keys equal my enumerator's keys pair for pair at both seeds, and
the branch label's `_axis`/`_diagonal` suffix agreed with the trace entry's
`line_kind` on every entry I reached (my `decider_keys` raises otherwise). N27 is
closed and the C9 qualifier is genuinely removable.

### 2.3 The nine replay cases, at three seeds, recomputed

```
D: replay cases = 9
D:   global_consistency        step=1 (alice,Point_1)/(alice,Point_1)  corrupt=(:right,1) rule=global_consistency
D:   input_consistency         step=2 (oracle,Point_6)/(alice,Point_1) corrupt=(:right,1) rule=input_consistency
D:   input_axis                step=3 (alice,Point_1)/(alice,ALine_1)  corrupt=(:right,1) rule=ld_axis_point
D:   input_diagonal            step=3 (bob,Point_2)/(bob,DLine_2)      corrupt=(:right,1) rule=ld_diagonal_point
D:   proof_consistency         step=4 (oracle,Point_3)/(oracle,Point_6) corrupt=(:left,1) rule=proof_consistency
D:   proof_individual_diagonal step=4 (oracle,Point_3)/(oracle,DLine_3) corrupt=(:right,1) rule=ld_diagonal_point   <- NG1
D:   proof_simultaneous_axis   step=4 (oracle,Point_6)/(oracle,ALine_6) corrupt=(:right,7) rule=ld_axis_point
D:   proof_simultaneous_diagonal step=4 (oracle,Point_6)/(oracle,DLine_6) corrupt=(:right,7) rule=ld_diagonal_point <- NG2
D: outcomes=27 honest_accepted=27 corrupted_rejected=27 expected_rule=27 rejecting_step==case.step=27
```

The last figure is stronger than the suite's assertion, which pins the *honest* trace's
step, not the rejecting one. Note also what the list does **not** contain: there is no
`proof_individual_axis` case — step 4(b) on an axis line is owned by `tb2_line`
(truncation) and `tb2_guard` (degree format), both registered and KILLED, so the
branch is covered, but by a different mechanism.

### 2.4 What the certificate carries

```
E: verify_certificate = CheckResult(true, :certificate_replay, :TypedAnswerReduce, …)
E: certificate replay passed=true outcomes=9
E: rules = [:global_consistency, :input_consistency, :ld_axis_point, :ld_diagonal_point,
            :proof_consistency, :ld_diagonal_point, :ld_axis_point, :ld_diagonal_point, :pcpverifier]
E: all(honest && !corrupted) = true
```

Nine cases at the all-zero seed, as N30's disposition says; the three-seed sweep and
both locksteps remain suite-owned with registered mutants.

### 2.5 N29 variant (b) as TB2 inherits it

```
F: DLine types=18   all degenerate at the zero seed = true
F: proof_individual_diagonal   degenerate=true  kappa=1   admissible t=2048  comparisons=2048
F: proof_simultaneous_diagonal degenerate=true  kappa=22  admissible t=2048  comparisons=45056
F: proof_individual_diagonal   at tb2_seed 5 degenerate=false
F: proof_simultaneous_diagonal at tb2_seed 5 degenerate=false
G: proof_individual_diagonal   corrupted entry 1 differs already at t=0: true
G: proof_simultaneous_diagonal corrupted entry 7 differs already at t=0: true
```

The inheritance claim in `briefs/65-…last.md` is exact. Row `G` is the caveat behind
NG8.

### 2.6 C4b's structural facts re-checked at this commit

`direct_sum` changed this round, so I re-ran C4b's two load-bearing structural facts:

```
I: 54 product maps x 2 sides: NotDescribable=108 describable=0
I: reasons = Set(["continuation is an opaque host closure"])
I: PCP sizes = Point_*=3009 ALine_1..5=2893 ALine_6=10228 DLine_1..5=2754 DLine_6=10479
```

Byte-identical to r4/r5. The new normalisation is unreachable for this rung (no set of
summands here is all whole-space zero maps), so C4b is untouched. See NG9 for a
one-clause precision I do **not** demand.

---

## 3. New objections

### NG3 · MAJOR · no corrupted-reject witness anywhere in the corpus fires in the `:bob` orientation

**Location** `src/verifiers/answer_reduce.jl:463` (step 3), `:495` (step 4(b)),
`:511` (step 4(c)) — the `rejected === nothing || return rejected` lines inside the
`for player in (:alice, :bob)` loop; `src/verifiers/answer_reduce.jl:615-660`
(`_answer_reduce_replay_cases`); `test/tb2_answer_reduce.jl:738-782` (`replay_seeds`),
`:857-873` (`guard`), `:842-855` (`line`).

**My computation.** For an ordered pair `(left, right)`, `player = :alice` means
`current_type = left`. Every guarded check except item 1 fires only when `current_type`
is the `Point`-side type, so a check fires at `:alice` exactly when the `Point` type is
the **left** type. I asked which orientation each existing corrupted-reject witness
uses:

```
H: global_consistency          rejecting entry player=both
H: input_consistency           player=alice     H: input_axis                 player=alice
H: input_diagonal              player=alice     H: proof_consistency          player=alice
H: proof_individual_diagonal   player=alice     H: proof_simultaneous_axis    player=alice
H: proof_simultaneous_diagonal player=alice     H: game                       player=alice
```

All nine. `tb2_guard` and `tb2_line` likewise use `(oracle,Point_3)/(oracle,ALine_3)`.
The `branches` sweep does visit both orientations (`tb2_case_types(player, …)` swaps
them) — but for **honest accepts only**, and the two locksteps compare branch *sets*,
which a disarmed rejection does not change. So no test in the corpus can fail when a
step's rejection is disarmed in the reversed orientation. Three one-line mutations,
one per low-degree step:

```julia
# answer_reduce.jl:463 / :495 / :511
-            rejected === nothing || return rejected
+            rejected === nothing || player == :bob || return rejected
```

```
MUTANT mg1_step4b_only_alice  TB2_TARGET=all  exit=0  assertion_failures=false  131.92 s  => SURVIVED
MUTANT mg2_step4c_only_alice  TB2_TARGET=all  exit=0  assertion_failures=false  113.85 s  => SURVIVED
MUTANT mg3_step3_only_alice   TB2_TARGET=all  exit=0  assertion_failures=false  125.02 s  => SURVIVED
MUTANT baseline (control)     TB2_TARGET=all  exit=0  419 assertions            120.30 s  => OK
```

They are not no-ops. Running the nine replay cases with the two types **swapped**
(and the corrupted side swapped with them) at the same three seeds:

```
clean : SWAP outcomes=27 honest=27 corrupted_rejected=27 expected_rule=27
mg1   : SWAP outcomes=27 honest=27 corrupted_rejected=24 expected_rule=24
        failures: proof_individual_diagonal accepted (:answer_reduce_accept) at all 3 seeds
mg2   : SWAP outcomes=27 honest=27 corrupted_rejected=21 expected_rule=21
        failures: proof_simultaneous_axis and proof_simultaneous_diagonal accepted, 3 seeds each
mg3   : SWAP outcomes=27 honest=27 corrupted_rejected=21 expected_rule=21
        failures: input_axis and input_diagonal accepted, 3 seeds each
```

So the mutated deciders accept, in the reversed orientation, exactly the corruptions
the clean decider rejects — six of them at every one of three seeds — while the whole
TB2 file stays green. This is the same family as r3/r4/r5's (a check is red-capable
only where a hand-written list says so), displaced from the guard *set*, the answer
*arity* and the *line kind* to the *orientation*; it is the last coordinate of the
`(step, branch, player, index, line_kind)` key, and the only one never corrupted.

**FIX DEMAND** Add the swapped orientation to `replay_seeds`: for each of the nine
cases and each of the three seeds, run the pair `(case.right, case.left)` with the
corrupted side flipped, and assert honest accept, corrupted reject, the expected rule
and the reached step — 27 more outcomes, 54 in all. The block above is exactly that
test and I have shown it green on clean code and red under each of the three mutants.
Register the three mutations as
`test/mutations/tb2_{input,individual,simultaneous}_ld_only_alice.jl` (target
`tb2_replay_seeds`) and show them KILLED. Putting the swap in the *suite* rather than
in `_answer_reduce_replay_cases()` is preferred: it costs no certificate-count churn
and leaves the nine-case wording of C9 (§6) intact. If the proposer prefers the
certificate, `_answer_reduce_replay_steps` must run each case in both orientations and
C9's counts change again.

**SURVIVING WEAKER STATEMENT** All five guarded checks are implemented correctly in
both orientations at this commit — I verified 27/27 honest accepts and 27/27 corrupted
rejects with the expected rule on the swapped pairs at three seeds — and the branch
*set* the decider fires is pinned in both orientations, pair for pair, by the two
2916-pair locksteps. What is missing is a test that fails when a step's *rejection* is
removed in the `:bob` orientation.

### NG4 · MINOR · `docs/DESIGN.md` §5.5 still says "7/7 guard cases"

**Location** `docs/DESIGN.md:975` versus `test/tb3_frontend.jl:640-654`.
The cross-lane edit of brief 65 moved TB3's pin from `length(decisions) == 7` to `== 9`
and its print from `/7` to `/9`, but §5.5's sentence "the five `g_i` stay non-constant
with `dependency_coordinates(g_i) = {i}`, so TB2's block-locality evidence survives:
**7/7 guard cases**" was not moved with it. Law 2: the code and its single-source
description diverge, and the divergence was introduced by this round.
**FIX DEMAND** Orchestrator lane: replace "7/7 guard cases" by "9/9 guard cases" in
`docs/DESIGN.md:975`.
**SURVIVING WEAKER STATEMENT** The fact is stale, not false in a way that flatters:
TB3 now accepts 9/9, more than the sentence claims.

### NG5 · MINOR · the published site and tutorial still describe the seven-case replay

**Location** `docs/index.html` and `docs/tutorial/compress-explained.html`
(byte-identical content), three places each: the panel "**The seven replay cases** ·
TB2 · three seeds · honest 21 / corrupted-rejected 21"; "Each of the seven certificate
cases is replayed at three seeds"; the TB3 row `["TB2 decider","7 / 7 guard cases
accepted in 1.013 s","check"]`; and the claims-ratchet table row for C9, "…; seven
replay cases at three seeds."
These are published summary documents — precisely the "summary moment" rk-light's
orchestrator duties single out — and they now disagree with the suite (nine cases, 27
outcomes, 9/9 TB3 decisions).
**FIX DEMAND** Orchestrator lane: regenerate or hand-patch the four strings in
`docs/index.html` and re-run `tools/build_site.py` (and the tutorial artifact) after
the C9 row of §6 lands, so the ratchet row on the page matches `claims/CLAIMS.md`.
**SURVIVING WEAKER STATEMENT** Again stale rather than inflated; no published number
overstates the evidence.

### NG6 · NOTE · brief 65's report asserts a CLAIMS state that does not exist

`briefs/65-tb1-tb2-repair-r5.last.md` (and `briefs/65-…md` line 10) say "C9's row
already says 'nine cases / 27 (case,seed) pairs' (unfrozen by the critic) — match it".
It does not. `claims/CLAIMS.md:17` is byte-identical (5,748 bytes) to the text
`verdicts/tb2-r5.md` §6 authorised: "seven guard cases", "all 21 (case, seed) pairs",
"still the seven cases", plus the NG1/NG2 scope sentence. r5 unfroze the count so that
a future repair *could* change it; it did not pre-apply it. Nothing was edited, so no
law-1 violation occurred, and the report's own MERGE PROPOSALS section states the
correct edit. The residue is that C9 has been out of lockstep with the code since
`7423c53` landed. §6 closes it.

### NG7 · NOTE · the N29 variant-(b) line is red-capable but unregistered (TB1 lane)

`src/verifiers/ldt.jl:132`, `admissible = all(iszero, line.direction) ?
field_elements(F) : (t,)`, is the whole of the N29 fix that TB2 inherits. The registered
mutant `test/mutations/tb1_degenerate_line.jl` does **not** target it — it mutates
`_line_parameter`'s degenerate branch (`point == line.base ? … : …` → `(true, …)`) and
is killed by the off-base half of the fixture. I reverted the `admissible` line itself
on a copy:

```
MG5 revert_all_t  TB1_TARGET=decider_rejections  exit=1  (2 failed at tb1_ld_sampler.jl:806-807)
                  MUTATION_EXPECTED_RULE degenerate_line off_base=ld_diagonal_point@question t0_cheat_passed=true
```

So the `degenerate_t0_cheat` transcript is a genuine red witness — but the registry
does not contain a mutant that flips `t0_cheat_passed`. Under the project's law 4 this
line has a test but no registered mutation. **TB1's lane**: routed to `briefs/67`
/ `verdicts/tb1-r6.md` and C4c, not to C4b or C9.

### NG8 · NOTE · TB2 does not itself witness the all-`t` comparison

Both new diagonal cases corrupt by adding the constant 1, which disagrees with the
point answer already at `t = 0` (§2.5 row `G`). So the eighth and ninth cases would
still reject under the old `t = 0` reading; the 2,048-fold and 45,056-fold comparisons
they perform at the zero seed are real but unwitnessed on the TB2 side. This is
correct division of labour — the fact belongs to `D^ld` and TB1 owns it (NG7) — and I
therefore do **not** put an all-`t` sentence in C9. Recorded so no later summary
attributes the variant-(b) evidence to TB2.

### NG9 · NOTE · C4b's "because" clause is now conditional (no edit demanded)

C4b says "The 54 product maps are `NotDescribable` because `direct_sum` wraps host
closures". After brief 65's normalisation, `direct_sum` returns a describable `CLZero`
when *every* summand is a whole-space zero map. The stated fact is still exactly true
of the 54 (§2.6: 108/108 `NotDescribable`, reason "continuation is an opaque host
closure"), and none of them is that degenerate case, so I re-affirm the row unchanged
rather than churn it. If the orchestrator wants the precision, the authorised clause
is: "… because `direct_sum` wraps host closures whenever its summands are not all
whole-space zero maps (brief 65's normalisation returns a describable `CLZero` in that
case, which none of the 54 is)".

### NOTE for brief 39 (TB5) — carried, unchanged

**N23** `TypedSampler`'s padding path still calls `pad_level`, not
`pad_level_evidence`. **N24** `pad_level` is still not compositional on the
empty-register `CLZero` (the context-dependence survives brief 59's `_pad_top` throw).
**N25** the CL round trip still pins neither a `CLStep`'s `rest` register nor
`BranchByAxis.position` at `m=1`. **r4 N9 residue / r5 N30** move the three seeds into
`_answer_reduce_replay_steps` so `verify_certificate` alone witnesses them. None of
these blocks C4b or C9; all four are TB5 work.

---

## 4. Test and mutation evidence I observed

```
SUITE (archived tree 7423c53, warm depot; powerprofilesctl get = balanced)
  RUN 1  (load average 2.63 -> 3.20; 3 other `julia --project` processes at start)
    MIPStarLambda load/precompile seconds = 0.466 (ungated)
    TB0 test-body wall seconds = 20.78 (warning=45.0, hard_limit=60.0)   <-- GATE PASSED
    Test Summary: MIPStarLambda | Pass 1038  Total 1038  Time 1m46.4s
    /usr/bin/time -v: Elapsed 1:47.50 · Maximum RSS 1,537,700 KiB · Exit status 0
  RUN 2  (load average 6.96 -> 3.37)
    TB0 test-body wall seconds = 35.34 (warning=45.0, hard_limit=60.0)   <-- GATE PASSED
    Test Summary: MIPStarLambda | Pass 1038  Total 1038  Time 1m45.2s
    /usr/bin/time -v: Elapsed 1:48.08 · Maximum RSS 1,547,292 KiB · Exit status 0
    Every printed TB2 and MUTATION_EXPECTED_RULE line is byte-identical between the
    two runs; the only TB2 difference is the `DLine_6 apply` timing (2.96/10.02 us
    vs 1.13/3.56 us). The 20.78 -> 35.34 s TB0 spread on one commit and one box is
    tb1-r5 N33's CPU-clock sensitivity, not a workload change.

  TB2 lines observed (both runs, identical):
    TB2 sampler: PCP types=18 edges=324 dims V6=(16,6,16) SOURCE_REPAIR=true;
                 product types=54 edges=2916 level=3
    MUTATION_EXPECTED_RULE product_projection agrees=true compared=1080
    MUTATION_EXPECTED_RULE certificate rule=certificate_replay passed=true
    TB2 certificate replay outcomes: 9 tuples, rules
      [global_consistency, input_consistency, ld_axis_point, ld_diagonal_point,
       proof_consistency, ld_diagonal_point, ld_axis_point, ld_diagonal_point, pcpverifier]
    MUTATION_EXPECTED_RULE describable actual=18/18
    MUTATION_EXPECTED_RULE describe_roundtrip ok=true
    MUTATION_EXPECTED_RULE branches first_failure=none failures=0
    TB2 deterministic branches: covered=37 seeds=37
    MUTATION_EXPECTED_RULE guard_split actual=(2736, 180, 107, 92, 54, 53)
    MUTATION_EXPECTED_RULE guard_lockstep mismatches=0 accepted=2916 silent=2736 first=nothing
    MUTATION_EXPECTED_RULE guard_lockstep_honest seed=tb2_seed5 mismatches=0 accepted=2916
                           silent=2736 first=nothing                        <-- new (N27)
    MUTATION_EXPECTED_RULE global_consistency arity=22 rejected_with_rule=20/20
    TB2 replay at 3 seeds (zero, tb2_seed 5, rng 0x9E): cases=9 outcomes=27 honest=27
                           corrupted_rejected=27                            <-- new (NG1/NG2)
    TB2 describe: Point_*=3009 ALine_1..5=2893 ALine_6=10228 DLine_1..5=2754 DLine_6=10479
    TB2 TRACE step4 shows :proof_simultaneous_diagonal with ldparams (2048, 16, 11, 22) PASS
  TB2 testset sizes (419 assertions, was 388): sampler 26, describe 126, parsers 1,
    branches 48 (was 46), seeded 3, no_check 3, lockstep 83 (was 79),
    replay_seeds 111 (was 86), game 9, proof_consistency 2, line 2, guard 2,
    dline_projection 2, i345 1.

MUTATION RUNNER (`julia --project=. test/mutations/run.jl`, load 2.63 -> 4.16)
  BASELINE (unmutated-first): 47/47 OK, every target exits 0
  TB0 28/28 KILLED · TB1 37/37 KILLED · TB2 18/18 KILLED · TB3 18/18 KILLED
  new this round, all KILLED with their registered evidence lines:
    TB1 N29-degenerate-line  every_point_on_degenerate_line   target=tb1_decider_rejections (exit=1,  6.10 s)
    TB1 N30-dsum-zero-spellings direct_sum_keeps_concatenated_register target=tb1_levels    (exit=1, 12.45 s)
    TB2 NG1-individual-diagonal step4b_diagonal_never_rejects target=tb2_replay_seeds       (exit=1, 45.22 s)
    TB2 NG2-simultaneous-diagonal step4c_diagonal_never_rejects target=tb2_replay_seeds     (exit=1, 30.36 s)
  MUTATION REGISTRY: killed=101/101 baselines ok=47/47 wall=435.26 s
  /usr/bin/time -v: Elapsed 7:15.59 · Maximum RSS 752,676 KiB · Exit status 0
  No SURVIVED, no LOAD-ERROR, no UNATTRIBUTABLE, no BROKEN baseline.
  (The proposer measured 490.04 s under its own load; mine is 435.26 s. Same registry,
  no time gate.)
```

## 5. Mutations written by this critic (isolated copies; the tree was never modified)

Each ran as the registry runs one — `Base.include(MIPStarLambda, <mutated copy>)` then
the whole `test/tb2_answer_reduce.jl` with `TB2_TARGET=all` — three at a time at load
≈ 7, alongside an unmutated control in the same shape.

| id | mutation | expectation | outcome |
|---|---|---|---|
| baseline (control) | none | must pass | **OK** (exit 0, 419 assertions, 120.30 s) |
| **MG1** (new) | `answer_reduce.jl:495` step 4(b): `rejected === nothing \|\| return rejected` → `… \|\| player == :bob \|\| return rejected` — the individual low-degree test never rejects when the line type is the LEFT type | probe: is step 4(b) red-capable in the reversed orientation? | **SURVIVED** (exit 0, 0 failed assertions, 131.92 s) → **NG3**; swapped-orientation probe drops to 24/27 corrupted rejects |
| **MG2** (new) | `answer_reduce.jl:511` step 4(c): same edit | ditto for 4(c) | **SURVIVED** (exit 0, 113.85 s) → **NG3**; swap probe 21/27 |
| **MG3** (new) | `answer_reduce.jl:463` step 3: same edit | ditto for the input low-degree test | **SURVIVED** (exit 0, 125.02 s) → **NG3**; swap probe 21/27 |
| **MG4** (new, control on N28) | `answer_reduce.jl:490-491`: `branch = line_kind == :ALine ? :proof_individual_axis : :proof_individual_diagonal` → `branch = :proof_individual_axis` | is the new `(check, line_kind)` key really red-capable? | **KILLED** (exit 1, assertion failures, 66.75 s) — N28's fix works; this was invisible before brief 65 |
| **MG5** (new, TB1 probe) | `ldt.jl:132`: `admissible = all(iszero, line.direction) ? field_elements(F) : (t,)` → `admissible = (t,)` (reverts N29 variant (b)) | who owns the all-`t` reading? | **KILLED by TB1** (`TB1_TARGET=decider_rejections`, exit 1, 2 failed at `tb1_ld_sampler.jl:806-807`, `t0_cheat_passed=true`) → **NG7**: red-capable but no registered mutant |
| **NG1, NG2** (r5 survivors, re-run as registered) | verbatim registry entries | must now break | **KILLED** in the registry, exit 1, 45.22 s / 30.36 s, evidence `cases=9 outcomes=27 honest=27 corrupted_rejected=24` matched |

Three of five new semantic mutations survived, all three from one axis, all three
closed by one 27-outcome test block that I have already run green-on-clean and
red-under-each.

---

## 6. Per-claim decisions

Both statuses stay TESTED and both are **re-affirmed**. Every fact either row asserts
is true at `7423c53` and has been independently recomputed here. NG3 is recorded as
**scope** in C9, not as a downgrade: the checks are implemented correctly in both
orientations (27/27 swapped honest accepts, 27/27 swapped corrupted rejects, verified
here); what is missing is a test that fails when the reversed-orientation rejection is
removed. No claim moves up or down this round.

### C4b — **RE-AFFIRMED TESTED**, statement UNCHANGED. The following edit is **AUTHORIZED**:

> In the C4b row of `claims/CLAIMS.md`, leave the statement, status, depends-on and
> test columns exactly as they stand, and replace the final column
> `` `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md`; `verdicts/tb2-r5.md` (re-affirmed) ``
> by
> `` `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md`; `verdicts/tb2-r5.md`, `verdicts/tb2-r6.md` (re-affirmed) ``.

Rationale: the only r5 change reaching C4b's territory is `direct_sum`'s zero-map
normalisation, which is unreachable for this rung — all 108 product maps (54 types ×
2 sides) are still `NotDescribable` with reason "continuation is an opaque host
closure", and all 18 PCP description sizes are byte-identical to r4/r5 (§2.6). NG9's
precision is offered, not demanded.

### C9 — **RE-AFFIRMED TESTED**, row text replaced. The following is **AUTHORIZED VERBATIM**:

> | C9 | (Typed answer-reduced decider — TB0 fixture) For the row `(q,k,m,d,s,m')=(2048,11,1,11,6,16)`, the trivial two-coordinate original sampler and its three-role oracularization, the typed answer-reduced decider implements the five guarded checks of `fig:decider-pcp` with the exact type-pair guards, the `i in {3,4,5}` restriction and both `ldparams=(q,m,d,1)` and `ldparams'=(q,m',d,m'+6)`; the honest strategy built from the TB0 PCP proof (witness (ii) for checks 4(a)/4(b)) is accepted on all 37 directed guard orientations at 37 distinct seeds, whose 37 `(step, branch, player, index, line_kind)` trace keys are asserted to be exactly the keys the sweep reaches and not merely a subset (`verdicts/tb2-r5.md` N28), and on 256 conditioned seeded question pairs at 256 distinct full-field seeds whose `chi(s_aux,m')` covers all 16 values, and every honest line answer checked equals the true restriction of the corresponding PCP polynomial at all `q=2048` line points (critic recomputation, `verdicts/tb2-r1.md` and `verdicts/tb2-r2.md` §2.3; the suite itself checks one such line through `D^ld`). Exactly `2736/2916 = 76/81 = 93.827%` of ordered product-type pairs trigger no check; of the remaining 180, 107 trigger step 5 (92 of them step 5 alone) and 54 trigger step 1 (53 of them step 1 alone) — the r1/r2 wording "107 only step 5 and 54 only step 1" was arithmetically wrong and is corrected here (`verdicts/tb2-r3.md` N10); all six numbers `(2736, 180, 107, 92, 54, 53)` are asserted by the suite and owned by the mutant `tb2_guard_split`, and this critic reproduced them by two further independent transcriptions of the guards (one in Julia, one in Python), together with the decomposition 1 + 4 + 6 + 4 of the fifteen step-5 pairs that also fire another guard. The decider itself, not only the enumerator `answer_reduce_guard_branches`, is now run on all 2916 ordered pairs — at the all-zero seed with the certificate replay's all-zero answers, and again at the nonzero full-field seed `tb2_seed 5` with honest TB0-proof answers (witness (ii) on the 18 of 2916 pairs that require it) — and its trace fires exactly the enumerated `(check, line_kind)` key set pair for pair, the branch label's `_axis`/`_diagonal` suffix being asserted to match the trace entry's line kind, with an empty trace on exactly the 2736 and an accept on all 2916 in both sweeps; the step-4(b) widening mutant `tb2_decider_guard_widened` is KILLED at 12 mismatches, and this critic reproduced the lockstep against a third, independently written transcription of `fig:decider-pcp` (0 mismatches clean, 12 mutated) and extended it to honest degenerate-proof answers at two seeds, where it also holds (`verdicts/tb2-r5.md` §2.2). The questions judged are the projections of the 54-type product sampler's own `sample` output, asserted equal to the explicit seed split on 20 seeds x 54 types x both sides (`verdicts/tb2-r2.md` N1 repaired in brief 46; independently recomputed in `verdicts/tb2-r3.md` §2.1). The `:TypedAnswerReduce` certificate replays shape, branch reachability and, for each of nine guard cases, one honest accept and one corrupted reject carrying the expected rule (ibid. N2 repaired). **Scope:** step 5 executes only items 3-5 of `fig:pcpverifier`; items 1-2 (`PaddedSuccinctDecider` -> Tseitin -> arithmetization) are not implemented, the formula is a construction-time constant, and the computed `x_alice=L^alice(x_Q)`, `x_bob=L^bob(x_Q)` reach `pcp_decider_specification` but do not enter the decision — asserted, including the equal verdict under a swapped call (`SOURCE_REPAIR :PCPVerifierFixedFormula`; `verdicts/tb2-r1.md` O3). Step 5's "otherwise, accept" is read as fallthrough, so the decider is strictly stricter than the literal source (`SOURCE_REPAIR :PCPGameOtherwiseFallthrough`; ibid. O8); the executable runs player-outer where the source is step-outer, with identical verdicts because every rejection is terminal (`verdicts/tb2-r2.md` N4). The nine-case replay carried inside the certificate still runs at the all-zero seed only; the suite re-runs the same nine cases — one per `fig:decider-pcp` guard branch that can reject, both line kinds of steps 3, 4(b) and 4(c) included — with honest TB0-proof answers at three seeds (all-zero, `tb2_seed 5`, RNG 0x9E) and asserts honest accept, corrupted reject, the expected rule and the reached step for all 27 (case, seed) pairs, recomputed independently by this critic, who also checked that the rejecting trace entry is the case's own step in all 27 (`verdicts/tb2-r3.md` N9, `verdicts/tb2-r4.md` §2.5, `verdicts/tb2-r6.md` §2.3). Step 1 compares the full bundle: on all five equal-type copy-6 pairs the suite asserts that corrupting entry 1, 6, 7 or `m'+6 = 22` of the 22-entry right answer is rejected with rule `:global_consistency` at step 1 (20/20), the first-entry-narrowing mutant `tb2_global_consistency_first_entry` is KILLED at 5/20, and this critic swept every one of the 22 entries on all five pairs (110/110 rejected with that rule; 5/110 under the mutant) (`verdicts/tb2-r5.md` §2.3). Both facts are carried by the suite, not by the `:TypedAnswerReduce` certificate, whose replay list is the nine cases at the all-zero seed. **Scope (orientation):** every corrupted-reject witness in the corpus puts the rejecting guard's `Point`-side type on the LEFT, so each fires at `player = :alice` (step 1 alone fires at `:both`); disarming a step's rejection only when `player == :bob` leaves all 419 TB2 assertions green, although the mutated decider then accepts, in the reversed orientation, corruptions that the clean decider rejects at step 3, step 4(b) and step 4(c) (`verdicts/tb2-r6.md` NG3). The reversed orientation is itself correct at this commit: this critic ran the nine cases with the two types swapped at the same three seeds and obtained 27/27 honest accepts and 27/27 corrupted rejects with the expected rule. The `i in {3,4,5}` restriction has no honest-play consequence and is evidenced only structurally (O14). `m=1` makes checks 3 and 4(b) act on the whole of `F_q^1`, and honest answer degrees are 1 against the declared bound `d=11` (O12). Detyping, its `+2` levels and its `16^54` loss, and every quantum conclusion remain CITED. | TESTED | D1,D2,C3,C4a,C4b | — | `test/tb2_answer_reduce.jl`; red: `test/mutations/tb2_{formula,g3,line,guard,guard_split,i345,mc1,mc2,mc3,nd2,nd4,tensor,opaque,decider_guard_widened,global_consistency_first_entry,individual_diagonal_never_rejects,simultaneous_diagonal_never_rejects}.jl` | `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md`, `verdicts/tb2-r5.md`, `verdicts/tb2-r6.md` |

Four notes on the authorised text, for the proposer. (a) It applies every change
brief 65's MERGE PROPOSALS asked for — "seven" → "nine" in **all four** places (the
proposal said "both places"; there are four), "21 (case, seed) pairs" → "27", the
NG1/NG2 scope sentence deleted, the "honest there" clause replaced by the two-seed
statement, and both new mutants added to the red list. (b) It adds two facts the
proposer earned but did not claim: the 37-key **equality** (N28) and the `(check,
line_kind)` key set with its label/line-kind consistency assertion. (c) The new
**Scope (orientation)** sentence is the NG3 record; like its predecessor it is to be
**deleted**, not weakened, by the repair that lands the swapped-orientation block.
(d) The certificate count is now nine and is **frozen again**: if the proposer chooses
to close NG3 inside `_answer_reduce_replay_steps` rather than in the suite, it must
come back for authorization, because that changes "nine guard cases" and "the nine
cases at the all-zero seed".

### C4a, C4c, C7, C12 — not this rung's business

C4a and C4c belong to `verdicts/tb1-r6.md` (brief 67); I express no opinion on the
brief-65 TB1 rows beyond observing that all 37 TB1 mutants are KILLED with clean
baselines in the registry I ran, that the DESIGN §9.4 sentence C4a's proposal depends
on has landed, and that NG7 above is a TB1 gap those rows should absorb. C7 and C12
stay CONJECTURE; nothing this round touches r4 §6.2's finding that `description_size`
is not additive under `direct_sum`.

---

## 7. Work order for the next round (one code fix, two documentation fixes)

1. **NG3 (MAJOR).** One block in `replay_seeds`: the nine cases with the two types
   swapped and the corrupted side flipped, at the same three seeds — 27 more outcomes,
   asserting honest accept, corrupted reject, expected rule and reached step. Register
   the three mutations of §5 (target `tb2_replay_seeds`) and show them KILLED. My
   `swapprobe.jl` is that test; it is green on `7423c53` and red under each mutant.
   Then delete C9's **Scope (orientation)** sentence.
2. **NG4 (MINOR).** `docs/DESIGN.md:975`: "7/7 guard cases" → "9/9 guard cases".
   Orchestrator lane.
3. **NG5 (MINOR).** Regenerate `docs/index.html` (and the tutorial artifact) after the
   C9 row lands: seven → nine replay cases, 21 → 27 outcomes, 7/7 → 9/9 TB3 decisions,
   and the ratchet row. Orchestrator lane.
4. **NG6 (NOTE).** Apply §6's C4b and C9 edits verbatim; that closes the divergence
   brief 65's report mistakenly believed was already closed.
5. **NG7 (NOTE).** TB1 lane (brief 67): register a mutant for
   `ldt.jl:132`'s `admissible` line, evidence `t0_cheat_passed=true`.
6. **NG8, NG9 (NOTE).** Recorded only; no edit demanded.
7. **N23, N24, N25, r4 N9 residue (NOTE).** Unchanged, brief 39 (TB5).

**Why this family terminates — for real this time.** A guard branch's red-capability is
indexed by the trace key `(step, branch, player, index, line_kind)`. r3 closed the
guard *set* (which branches fire: the enumerator, then the 2916-pair lockstep); r4
closed the answer *arity* (`index`, the 22-entry sweep); r5 closed the *line kind*; NG3
is the *player*, the fourth and last coordinate; `step` is pinned by the replay cases'
`case.step` assertion, which I verified fires on the rejecting entry as well. After
item 1, every coordinate of the key has a corrupted-reject witness, and I have no
further probe of this shape to run. The three probes that stayed green this round
(MG4's mislabel, MG5's all-`t` revert, and the baseline control) are the evidence that
the previous rounds' fixes really bite.

Objection trajectory for this rung: **14 → 5 → 5 → 6 → 6 → 6** (r6: 1 MAJOR + 2 MINOR
+ 3 NOTE, plus four carried TB5 notes). The count is flat; the *code* content is not.
Every r5 objection is discharged with no escapes, both r5 MAJOR fixes overshoot their
demands, the registry grew from 84 to 101 mutants with 47/47 clean baselines and no
survivor, and this round's single MAJOR is one keyword (`player == :bob`) on three
`||` chains, closed by one test block I have already written and run. Two of the three
remaining objections are stale strings in documents, not code. I would have said PASS
had the orientation probes died; they did not, and law 4 does not care that the code is
correct in both orientations — which, as §3 records, it is.

VERDICT: FAIL(NG3)
