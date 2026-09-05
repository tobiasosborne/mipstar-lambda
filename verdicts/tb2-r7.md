# Verdict tb2-r7 — adversarial critic on rung TB2 after repair r6 (commit `8a1b6e2`, brief 69) — intended closing round

Evaluated on an archived copy (`git archive 8a1b6e2 | tar -x`) in
`/tmp/claude-1000/.../scratchpad/critic-tb2-r7/tree/`, instantiated there; cold
precompile of `MIPStarLambda` **69.50 s** (`real 1m24.03` including the registry
update), at one-minute load average **2.66**. The live working tree was never read
for `src/` or `test/`; `claims/CLAIMS.md` and `docs/DESIGN.md` were read live
(orchestrator-owned). `docs/DESIGN.md` is byte-identical to the archived copy; live
`claims/CLAIMS.md` differs from the archive only in the TB4 lane (C11 added, C16/C18
amended by `verdicts/tb4-r1.md`) — **C9 and C4b are byte-identical live and archived**,
so nothing below depends on a stale copy. No git command that changes state was run;
every mutation was applied to a copy under the scratch directory. This verdict file is
the only file written.

**Power/load record (binding for every wall below).** `powerprofilesctl get` reports
**`performance`**. Every wall is reported with `uptime`'s one-minute load at its start
and end. The TB0 60 s gate was comfortable (**15.561 s** against warning 45.0 / hard
limit 60.0) on a quiet box.

Files under review (delta `7423c53..8a1b6e2`, TB2 lane): `test/tb2_answer_reduce.jl`
(+47/-20: the swapped-orientation half of `replay_seeds`), `test/mutations/run.jl`
(additive), new `test/mutations/tb2_{input,individual,simultaneous}_ld_only_alice.jl`,
new `test/mutations/tb1_degenerate_all_t.jl`, `docs/DESIGN.md` §5.5,
`docs/index.html` + `docs/tutorial/compress-explained.html`, `claims/CLAIMS.md`.
**`src/verifiers/answer_reduce.jl`, `src/verifiers/ldt.jl`, `src/samplers/cl.jl` and
`src/samplers/pcp_sampler.jl` are untouched by this round** (`git diff --stat`
empty), so every r5/r6 recomputation of the decider itself still stands verbatim.

---

## 1. Adjudication of every r6 row

| r6 item | claimed in `briefs/69-…last.md` | **adjudication** | my evidence |
|---|---|---|---|
| **NG3** MAJOR — no corrupted-reject witness in the `:bob` orientation | `replay_seeds` runs the nine cases at three seeds in BOTH orientations, 54 outcomes, testset 222 assertions; the three `*_ld_only_alice` mutants KILLED | **ACCEPTED, and it overshoots the demand** | the block is exactly the demanded one and adds one assertion I did not ask for: the *rejecting* trace entry's `player` (`:alice` forward, `:bob` swapped, `:both` at step 1) on every one of the 54 outcomes. I recomputed all 54 outside the suite from the package API, with my own fourth transcription of the `fig:decider-pcp` guards deciding which player must fire: **54/54 honest accept, 54/54 corrupted reject with the expected rule, 54/54 rejecting step == `case.step`, 54/54 the last trace entry IS the rejection, and 54/54 the observed rejecting player equals my transcription's** (§2.1). Registry: all three mutants KILLED, exit 1, 31.95 / 39.89 / 34.43 s, evidence lines matched. My control **MH4** (§5) confirms the new player assertion is red-capable, not decorative. |
| **NG3 mutants registered** | `tb2_{input,individual,simultaneous}_ld_only_alice.jl`, target `tb2_replay_seeds`, evidence = the SWAP line at `corrupted_rejected=21/24/21` | **ACCEPTED** | the three `before` strings are the r6 MG3/MG1/MG2 anchors verbatim; each matches exactly one source site (the runner errors otherwise); each is KILLED with its registered evidence line present. |
| **NG4** MINOR — `docs/DESIGN.md` §5.5 "7/7 guard cases" | orchestrator lane (`1b1b2f7`) | **ACCEPTED (closed)** | `docs/DESIGN.md:994` now reads "so TB2's block-locality evidence survives: 9/9 guard cases"; no `7/7`, `seven guard`, `seven replay` or `21 (case` string survives anywhere in `docs/DESIGN.md`. Live and archived copies are byte-identical. |
| **NG5** MINOR — site/tutorial still describe the seven-case replay | orchestrator lane (`1b1b2f7`): "explainer + site refreshed to the r6 state" | **PARTIAL** | the four strings the r6 work order named *are* fixed: "The nine replay cases · TB2 · three seeds · honest 27 / corrupted-rejected 27", "Each of the nine certificate cases is replayed at three seeds", `["TB2 decider","9 / 9 guard cases accepted…"]`, and the C9 ratchet row "nine replay cases at three seeds, 27 (case, seed) pairs". But the refresh was cut at `1b1b2f7`, *before* the repair landed at `8a1b6e2`, and three strings are stale again against the code they describe. Objection **NG11**. |
| **NG6** NOTE — brief 65's report asserted a CLAIMS state that did not exist | "confirmed — live C9 is byte-identical to the r6-authorised row (checked programmatically)" | **ACCEPTED, and I re-checked it independently** | live `claims/CLAIMS.md` C9 is 6,630 characters and **string-equal** to the row `verdicts/tb2-r6.md` §6 authorised, "Scope (orientation)" sentence included. The MERGE PROPOSAL in `briefs/69-…last.md` is, byte for byte, that row with the 694-character `**Scope (orientation):** … expected rule.` sentence excised and nothing else changed (verified by string surgery, not by eye). |
| **NG7** NOTE — the N29 variant-(b) `admissible` line was red-capable but unregistered | `test/mutations/tb1_degenerate_all_t.jl` = my MG5 verbatim, target `tb1_decider_rejections`, evidence `t0_cheat_passed=true` | **ACCEPTED (closed)** | registered in `test/mutations/run.jl` and in `TB1_MUTANTS`; **KILLED**, exit 1, 4.69 s, in my own registry run. The clean suite prints the same line with `t0_cheat_passed=false`, so the evidence string is a genuine discriminator. |
| **NG8** NOTE — TB2 does not itself witness the all-`t` comparison | accepted as recorded; no all-`t` sentence added to C9; the witness is now TB1's registered mutant | **ACCEPTED** | correct disposition; the all-`t` reading now has a registered owner in the TB1 lane and C9 does not claim it. |
| **NG9** NOTE — C4b's "because" clause | no edit; clause left as authorised | **ACCEPTED** | re-checked at this commit (§2.4): 108/108 `NotDescribable`, single reason "continuation is an opaque host closure", all 18 description sizes byte-identical to r4/r5/r6. The offered precision stays offered, not demanded. |
| **lockstep of the r6 promotions** | orchestrator (`1b1b2f7`) | **ACCEPTED** | C9 exactly as authorised. C4b's verdict cell reads `…, verdicts/tb2-r4.md; verdicts/tb2-r5.md (re-affirmed); verdicts/tb2-r6.md (re-affirmed)` where r6 authorised `…; verdicts/tb2-r5.md, verdicts/tb2-r6.md (re-affirmed)`: a punctuation-plus-parenthetical adaptation that adds no claim. Accepted. |
| **`src/` untouched** | "`src/` untouched" | **ACCEPTED for the TB2 lane, with one out-of-lane note** | `answer_reduce.jl`, `ldt.jl`, `cl.jl`, `pcp_sampler.jl` all show an empty diff. `src/verifiers/pcp.jl` *did* change at `278b1ac` (TB4/TB3 lane: `_bind_upstream`'s replay dropped the `_same_tseitin(tseitin(circuit).term, proof.tf)` conjunct). It does not reach TB2: the `:TypedAnswerReduce` certificate has **10 nodes and no `:UpstreamEvidence`** (§2.4), and `verify_certificate` still returns true. Recorded as **NG12**, routed to `verdicts/tb3-r2.md` / C10, not to C9. |
| **suite / registry figures** | 1364/1364, `killed=119/119 baselines ok=55/55`, exit 0 | **ACCEPTED, reproduced** | my numbers: 1364/1364 in 1m11.7s, and `MUTATION REGISTRY: killed=119/119 baselines ok=55/55 wall=509.35 s`, exit 0 (§4). |

**Score: 10 ACCEPTED · 1 PARTIAL · 0 escapes.** The r6 MAJOR is discharged with a
registered, independently reproduced kill and one assertion more than demanded; both
r6 code NOTES are closed; the single non-clean row is a documentation refresh that ran
one commit too early.

---

## 2. Independent recomputations (archived copy; scripts under scratch)

`recompute.jl`, `keycover.jl`, `copyprobe.jl`, `fullprobe.jl`, `c4b.jl`, `mutate.jl`,
`mh5.jl`. **None of them includes `test/tb2_answer_reduce.jl`**, so nothing in this
section is the suite grading itself. The fixtures, the reduction and the three seeds
are rebuilt from the package API; every predicate below is mine.

### 2.1 The 54 outcomes, recomputed, with the rejecting player from my own transcription

I re-transcribed items 2, 3, 4(a), 4(b), 4(c), 5 of `fig:decider-pcp`
(`gt-10-answer-reduction.tex:2012-2063`) as a predicate `my_fires(current, other)`
and derived, for each case and orientation, which player must carry the rejection —
without reading the test file's `rejecting_player` helper.

```
A: zero seeds among the three = 1
B: replay cases = 9
C: FORWARD outcomes=27 honest=27 corrupted_rejected=27 rule=27 honest_reaches_step=27
           rejecting_step==case.step=27 last_entry_is_the_rejection=27
           player_matches_MY_transcription=27
C: SWAPPED outcomes=27 honest=27 corrupted_rejected=27 rule=27 honest_reaches_step=27
           rejecting_step==case.step=27 last_entry_is_the_rejection=27
           player_matches_MY_transcription=27
D: total outcomes = 54
D: distinct (orientation, rejecting player)
     = [(:forward,:alice), (:forward,:both), (:swapped,:bob), (:swapped,:both)]
E: global_consistency          fwd=[:both]  swp=[:both] step=[1] witness=[:degenerate]
E: input_consistency           fwd=[:alice] swp=[:bob]  step=[2] witness=[:degenerate]
E: input_axis                  fwd=[:alice] swp=[:bob]  step=[3] witness=[:degenerate]
E: input_diagonal              fwd=[:alice] swp=[:bob]  step=[3] witness=[:degenerate]
E: proof_consistency           fwd=[:alice] swp=[:bob]  step=[4] witness=[:nondegenerate]
E: proof_individual_diagonal   fwd=[:alice] swp=[:bob]  step=[4] witness=[:nondegenerate]
E: proof_simultaneous_axis     fwd=[:alice] swp=[:bob]  step=[4] witness=[:degenerate]
E: proof_simultaneous_diagonal fwd=[:alice] swp=[:bob]  step=[4] witness=[:degenerate]
E: game                        fwd=[:alice] swp=[:bob]  step=[5] witness=[:degenerate]
```

Two facts worth pinning. (a) The swap is a *pure relabelling of the questions* —
`sample_answer_reduce_questions` returns `(l,r)` for `(L,R)` and `(r,l)` for `(R,L)` —
so the swapped block cannot be dismissed as a second sample; what it exercises is the
decider's `for player in (:alice,:bob)` loop, and the three registered kills prove that
is a distinct code path. (b) The suite asserts `case.step ∈ steps(honest.trace)`, which
is weaker than what actually holds; I checked the stronger statement, that the
*rejecting* entry's step is `case.step`, on all 54.

### 2.2 Which of the 37 trace keys have a corrupted-reject witness — 18 of 37

C9's own granularity for red-capability is the trace key
`(step, branch, player, index, line_kind)`, and the honest sweep pins all **37** of
them (my own enumeration reproduces 37, set for set). I asked the complementary
question: at how many of those 37 keys does the corpus contain a *corrupted-reject*
witness? Counting the 54 replay outcomes, the step-1 arity-22 sweep, and `tb2_guard`'s
`ld_axis_degree` rejection:

```
MY expected key count = 37
keys with a corrupted-reject witness    = 18/37
keys with NO corrupted-reject witness   = 19
   (2, :input_consistency,        {alice,bob}, 2, :none)
   (3, :input_axis,               {alice,bob}, 2, :ALine)
   (3, :input_diagonal,           {alice,bob}, 1, :DLine)
   (4, :proof_consistency,        {alice,bob}, {4,5}, :none)
   (4, :proof_individual_axis,    {alice,bob}, {4,5}, :ALine) + (:bob, 3, :ALine)
   (4, :proof_individual_diagonal,{alice,bob}, {4,5}, :DLine)
```

Every missing key differs from a witnessed one **only in `index`** — the copy. This is
the ground of **NG10**.

### 2.3 The proposed 19-case block: green on clean, red under every survivor

```
CLEAN                     FULLPROBE outcomes=114 honest=114 corrupted_rejected=114
                                    expected_rule=114 rejecting_step==case.step=114
                          FULLPROBE distinct rejecting trace keys = 37
mh1_step4a_only_copy3     FULLPROBE outcomes=114 honest=114 corrupted_rejected=102 …
mh2_step4b_only_copy3     FULLPROBE outcomes=114 honest=114 corrupted_rejected=90  …
mh3_step2_only_copy1      FULLPROBE outcomes=114 honest=114 corrupted_rejected=108 …
mh5_step3_crossed_copies  FULLPROBE outcomes=114 honest=114 corrupted_rejected=102 …
```

Nineteen cases × three seeds × two orientations. On clean code every outcome is an
honest accept and a corrupted reject with the expected rule at the expected step, and
the rejecting entries cover **all 37 keys**. Under each of the four survivors the block
goes red. This is the FIX DEMAND of NG10, already written and already run.

### 2.4 C4b's structural facts, and the reach of the `pcp.jl` change

```
I: TB2 certificate nodes = 10; :UpstreamEvidence reached = false
I: verify_certificate = true
I: product types = 54  level = 3  edges = 2916
I: 54 product maps x 2 sides: NotDescribable=108 describable=0
I: reasons = Set(["continuation is an opaque host closure"])
I: PCP description sizes = Point_*=3009  ALine_1..5=2893  ALine_6=10228
                           DLine_1..5=2754 DLine_6=10479
```

Byte-identical to r4/r5/r6, and the one `src/` edit that touches a TB2 dependency
(`pcp.jl`'s `_bind_upstream`) is unreachable from this certificate. C4b is untouched.

---

## 3. New objections

### NG10 · MAJOR · the trace key's `index` (copy) coordinate has no corrupted-reject witness at 19 of 37 keys

**Location** `src/verifiers/answer_reduce.jl:440-446` (step 2), `:463` (step 3),
`:472-478` (step 4(a)), `:495` (step 4(b)); `src/verifiers/answer_reduce.jl:615-660`
(`_answer_reduce_replay_cases`); `test/tb2_answer_reduce.jl:738-811` (`replay_seeds`),
`:853-867` (`proof_consistency`), `:884-903` (`guard`).

**My computation.** §2.2. Steps 2 and 3 range over the input copy `∈ {1,2}`; steps
4(a) and 4(b) range over the proof copy `i ∈ {3,4,5}`. The replay corpus contains one
corrupted-reject witness per *branch*, at one copy each: step 2 at copy 1 only, step 3
axis at copy 1 and diagonal at copy 2 only, steps 4(a)/4(b) at `i = 3` only. Nothing in
the corpus fails when a step's rejection is disarmed at the other copies. Four one-line
mutations, each restricting an existing rejection to the witnessed copy:

```julia
# :472  step 4(a): proof_consistency never rejects for copies 4 and 5
-                result = CheckResult(current_answer[1] == other_answer[i],
+                result = CheckResult(current_answer[1] == other_answer[i] || i != 3,
# :495  step 4(b): the individual low-degree test never rejects for copies 4 and 5
-                rejected === nothing || return rejected
+                rejected === nothing || i != 3 || return rejected
# :440  step 2: input_consistency never rejects on Bob's copy
-            result = CheckResult(other_answer[1] == current_answer[input_copy],
+            result = CheckResult(other_answer[1] == current_answer[input_copy] || input_copy == 2,
# :463  step 3: the input low-degree test never rejects on axis@copy2 or diagonal@copy1
-            rejected === nothing || return rejected
+            rejected === nothing || (line_kind == :ALine) == (input_role_copy == 2) || return rejected
```

```
MUTANT mh1_step4a_only_copy3      TB2_TARGET=all  exit=0  assertion_failures=false  => SURVIVED
MUTANT mh2_step4b_only_copy3      TB2_TARGET=all  exit=0  assertion_failures=false  => SURVIVED
MUTANT mh3_step2_only_copy1       TB2_TARGET=all  exit=0  assertion_failures=false  => SURVIVED
MUTANT mh5_step3_crossed_copies   TB2_TARGET=all  exit=0  assertion_failures=false  => SURVIVED
MUTANT mh0_baseline (control)     TB2_TARGET=all  exit=0  all green                 => OK
```

Re-run on a quiet box (load 0.93) they survive again, at 54.6 / 56.0 / 57.3 / 39.6 s
against a 61.8 s control. All four leave `replay_seeds` (both halves), the two
2916-pair locksteps, the 37-key `branches` equality and the arity-22 sweep untouched:
each prints `corrupted_rejected=27` forward, `corrupted_rejected=27` swapped,
`branches first_failure=none failures=0` and `guard_lockstep mismatches=0`.

They are not no-ops. Under each, the clean decider's rejections become accepts:

```
mh1 : proof_consistency at copies 4 and 5 ACCEPTED, both orientations, all 3 seeds (12/12)
mh2 : proof_individual axis@4 and diagonal@5 ACCEPTED, both orientations, 3 seeds (12/12)
mh3 : input_consistency at copy 2 ACCEPTED, both orientations, 3 seeds (6/6)
mh5 : input_axis@copy2 and input_diagonal@copy1 ACCEPTED, both orientations, 3 seeds (12/12)
```

This is the same family as r3/r4/r5/r6 — a check is red-capable only where a
hand-written list says so — displaced from the guard *set*, the answer *arity*, the
*line kind* and the *orientation* to the *copy*. `verdicts/tb2-r6.md` §7 asserted the
`index` coordinate was already closed "by the 22-entry sweep"; that was wrong. The
22-entry sweep varies the corrupted *answer entry* at step 1, whose trace `index` is
the constant **0** (`_ar_entry(1, :global_consistency, :both, 0, :none, result)`); it
never varies the key's `index` at all.

**FIX DEMAND** Replace the nine ad-hoc replay cases in `replay_seeds` by one case per
`(step, branch, index, line_kind)` guard key — nineteen shapes — and keep the existing
three seeds and both orientations: 114 outcomes, asserting honest accept, corrupted
reject, expected rule, reached step and rejecting player as now. The nineteen:

```
 1  global_consistency        1  (alice,Point_1)/(alice,Point_1)  (:right,1)  global_consistency
 2  input_consistency c1      2  (oracle,Point_6)/(alice,Point_1) (:right,1)  input_consistency
 3  input_consistency c2      2  (oracle,Point_6)/(bob,Point_2)   (:right,1)  input_consistency
 4  input_axis c1             3  (alice,Point_1)/(alice,ALine_1)  (:right,1)  ld_axis_point
 5  input_axis c2             3  (bob,Point_2)/(bob,ALine_2)      (:right,1)  ld_axis_point
 6  input_diagonal c1         3  (alice,Point_1)/(alice,DLine_1)  (:right,1)  ld_diagonal_point
 7  input_diagonal c2         3  (bob,Point_2)/(bob,DLine_2)      (:right,1)  ld_diagonal_point
 8- 10 proof_consistency i    4  (oracle,Point_i)/(oracle,Point_6) (:left,1)  proof_consistency   i=3,4,5
11- 13 proof_ind_axis i       4  (oracle,Point_i)/(oracle,ALine_i) (:right,1) ld_axis_point       i=3,4,5
14- 16 proof_ind_diagonal i   4  (oracle,Point_i)/(oracle,DLine_i) (:right,1) ld_diagonal_point   i=3,4,5
17  proof_simultaneous_axis   4  (oracle,Point_6)/(oracle,ALine_6) (:right,7) ld_axis_point
18  proof_simultaneous_diag   4  (oracle,Point_6)/(oracle,DLine_6) (:right,7) ld_diagonal_point
19  game                      5  (oracle,Point_6)/(bob,Point_2)    (:left,6)  pcpverifier
```

and assert that the set of rejecting trace keys is exactly the 37-key set the
`branches` sweep already pins as `covered == expected_keys`. My `fullprobe.jl` is that
test; it is green on `8a1b6e2` (114/114, 37 keys) and red under each of the four
mutants. Register the four mutations as
`test/mutations/tb2_{step2_copy1_only,step3_crossed_copies,step4a_copy3_only,step4b_copy3_only}.jl`
(target `tb2_replay_seeds`) and show them KILLED. Keeping the block in the suite rather
than in `_answer_reduce_replay_steps` again costs no certificate churn and leaves C9's
"nine guard cases inside the certificate" wording intact; if the proposer moves it into
the certificate instead, C9's counts change and must come back for authorization.

**SURVIVING WEAKER STATEMENT** Every check is implemented correctly at every copy at
this commit — I ran the 19-case block on clean code in both orientations at three
seeds and obtained 114/114 honest accepts and 114/114 corrupted rejects with the
expected rule and the expected step, covering all 37 keys. What is missing is a test
that fails when a step's *rejection* is removed at a copy other than the one the ad-hoc
case list happens to use.

### NG11 · MINOR · the published site advertises NG3 as still open, and its replay count now under-states the suite

**Location** `docs/tutorial/compress-explained.html` (source of truth) and the
generated `docs/index.html` — three strings, in the answer-reduction panel and the
ratchet table:

1. "Still open (tb2-r6 NG3): every corrupted-reject witness puts the Point type on the
   left; the `:bob` orientation of three steps has no witness yet." — **false at this
   commit**; NG3 is fixed and its three mutants are registered and KILLED. A published
   page that announces a gap the code no longer has is the mirror image of an inflated
   claim, and it is the one kind of staleness that is not merely conservative: a reader
   is told the artefact is weaker than it is.
2. "…: 27 honest outcomes accepted, 27 corrupted outcomes rejected" and the ratchet
   row "nine replay cases at three seeds, 27 (case, seed) pairs" — the suite now runs
   **54** outcomes in two orientations.
3. The ratchet row's verdict cell reads "tb2-r2 … tb2-r5" where `claims/CLAIMS.md`
   already carries `verdicts/tb2-r6.md`.

The refresh at `1b1b2f7` landed *before* the repair at `8a1b6e2`, which is how this
happened; the fix is to regenerate after the C9 row of §6 lands.
**FIX DEMAND** Orchestrator lane: edit `docs/tutorial/compress-explained.html` (drop
the "Still open (tb2-r6 NG3)" sentence, replace it with the NG10 scope if NG10 is still
open when the page is rebuilt; 27 → 54 outcomes with the two-orientation wording; the
ratchet row's counts and verdict list), then re-run `tools/build_site.py`.
**SURVIVING WEAKER STATEMENT** No published number overstates the evidence.

### NG12 · NOTE · `pcp.jl`'s `_bind_upstream` replay was weakened at `278b1ac`; it does not reach TB2

`src/verifiers/pcp.jl:205-213` now replays `proof.tf === tf` where it previously
replayed `proof.tf === tf && _same_tseitin(tseitin(circuit).term, proof.tf)`, with the
reasoning (from `verdicts/tb3-r2.md` N14) that the reproduction is a build-time check
over immutable data. That is a claim about C10/C11, not C9, and I express no opinion on
it here beyond the fact that establishes it is out of this rung's lane: the
`:TypedAnswerReduce` certificate has **10 nodes and never reaches `:UpstreamEvidence`**
(§2.4). Recorded so that no later summary treats the TB2 certificate as evidence for,
or as damaged by, that change.

### NOTES carried unchanged

**NG8** (TB2 does not itself witness the all-`t` comparison; TB1's
`tb1_degenerate_all_t` now owns it) and **NG9** (C4b's "because" clause is conditional
after brief 65's `direct_sum` normalisation; the offered precision is not demanded)
stand exactly as `verdicts/tb2-r6.md` recorded them.

### NOTE for brief 39 (TB5) — carried, unchanged

**N23** `TypedSampler`'s padding path still calls `pad_level`, not
`pad_level_evidence`. **N24** `pad_level` is still not compositional on the
empty-register `CLZero`. **N25** the CL round trip still pins neither a `CLStep`'s
`rest` register nor `BranchByAxis.position` at `m=1`. **r4 N9 residue / r5 N30** move
the three seeds into `_answer_reduce_replay_steps` so `verify_certificate` alone
witnesses them. None of these blocks C4b or C9; all four are TB5 work.

---

## 4. Test and mutation evidence I observed

```
SUITE (archived tree 8a1b6e2, warm depot; powerprofilesctl get = performance)
  quiet box: `pgrep -fa 'runtests|mutations/run'` empty at start
  load average 1.15 -> 1.04
    MIPStarLambda load/precompile seconds = 0.222 (ungated)
    TB0 test-body wall seconds = 15.561 (warning=45.0, hard_limit=60.0)   <-- GATE PASSED
    Test Summary: MIPStarLambda | Pass 1364  Total 1364  Time 1m11.7s
    /usr/bin/time -v: Elapsed 1:12.39 · Maximum RSS 1,574,388 KiB · Exit status 0

  TB2 lines observed:
    TB2 sampler: PCP types=18 edges=324 dims V6=(16,6,16) SOURCE_REPAIR=true;
                 product types=54 edges=2916 level=3
    MUTATION_EXPECTED_RULE product_projection agrees=true compared=1080
    MUTATION_EXPECTED_RULE certificate rule=certificate_replay passed=true
    TB2 certificate replay outcomes: 9 tuples, rules as in r6 (unchanged)
    MUTATION_EXPECTED_RULE describable actual=18/18
    MUTATION_EXPECTED_RULE branches first_failure=none failures=0
    TB2 deterministic branches: covered=37 seeds=37
    MUTATION_EXPECTED_RULE guard_split actual=(2736, 180, 107, 92, 54, 53)
    MUTATION_EXPECTED_RULE guard_lockstep mismatches=0 accepted=2916 silent=2736
    MUTATION_EXPECTED_RULE guard_lockstep_honest seed=tb2_seed5 mismatches=0 accepted=2916
    MUTATION_EXPECTED_RULE global_consistency arity=22 rejected_with_rule=20/20
    TB2 replay at 3 seeds (zero, tb2_seed 5, rng 0x9E): cases=9 outcomes=27 honest=27
                           corrupted_rejected=27
    TB2 replay SWAP orientation (right,left) at the same 3 seeds: cases=9 outcomes=27
                           honest=27 corrupted_rejected=27 expected_rule=27   <-- new (NG3)
    TB2 describe: Point_*=3009 ALine_1..5=2893 ALine_6=10228 DLine_1..5=2754 DLine_6=10479
    MUTATION_EXPECTED_RULE degenerate_line off_base=ld_diagonal_point@question
                           t0_cheat_passed=false                              <-- NG7's owner
  TB2 testset sizes (530 assertions, was 419): sampler 26, describe 126, parsers 1,
    branches 48, seeded 3, no_check 3, lockstep 83, replay_seeds 222 (was 111),
    game 9, proof_consistency 2, line 2, guard 2, dline_projection 2, i345 1.

MUTATION RUNNER (`julia --project=. test/mutations/run.jl`, load 0.75 -> 2.23; my probe
  mutations ran concurrently between 11:39 and 11:44, 1-min load peaking at 7.30)
  BASELINE (unmutated-first): 55/55 OK, every target exits 0
  TB0 28/28 · TB1 38/38 · TB2 21/21 · TB3 19/19 · TB4 13/13 — all KILLED
  new this round, all KILLED with their registered evidence lines:
    TB1 NG7-degenerate-all-t   admissible_t_only    target=tb1_decider_rejections (exit=1,  4.69 s)
    TB2 NG3-input-ld           step3_only_alice     target=tb2_replay_seeds       (exit=1, 31.95 s)
    TB2 NG3-individual-ld      step4b_only_alice    target=tb2_replay_seeds       (exit=1, 39.89 s)
    TB2 NG3-simultaneous-ld    step4c_only_alice    target=tb2_replay_seeds       (exit=1, 34.43 s)
  MUTATION REGISTRY: killed=119/119 baselines ok=55/55 wall=509.35 s
  /usr/bin/time -v: Elapsed 8:29.61 · Maximum RSS 6,601,172 KiB · Exit status 0
  No SURVIVED, no LOAD-ERROR, no UNATTRIBUTABLE, no BROKEN baseline.
  (The proposer measured 671.25 s under a loaded box; mine is 509.35 s. Same registry,
  no time gate.)
```

## 5. Mutations written by this critic (isolated copies; the tree was never modified)

Each ran as the registry runs one — `Base.include(MIPStarLambda, <mutated copy>)` then
the whole `test/tb2_answer_reduce.jl` with `TB2_TARGET=all` — five at a time alongside
an unmutated control in the same shape, once at load ≈ 4–7 and once at load ≈ 1.

| id | mutation | expectation | outcome |
|---|---|---|---|
| mh0 (control) | none | must pass | **OK** (exit 0, 93.87 s loaded / 61.83 s quiet) |
| **MH1** | `:472` step 4(a): `CheckResult(current_answer[1] == other_answer[i], …)` → `… \|\| i != 3` — `proof_consistency` never rejects at copies 4, 5 | is the copy index red-capable at step 4(a)? | **SURVIVED** (exit 0, 103.78 / 54.55 s) → **NG10**; 19-case probe 102/114 |
| **MH2** | `:495` step 4(b): `rejected === nothing \|\| return rejected` → `… \|\| i != 3 \|\| …` | ditto for the individual low-degree test | **SURVIVED** (exit 0, 113.32 / 56.00 s) → **NG10**; probe 90/114 |
| **MH3** | `:440` step 2: `CheckResult(other_answer[1] == current_answer[input_copy], …)` → `… \|\| input_copy == 2` | ditto for `input_consistency` on Bob's copy | **SURVIVED** (exit 0, 107.36 / 57.25 s) → **NG10**; probe 108/114 |
| **MH5** | `:463` step 3: `rejected === nothing \|\| (line_kind == :ALine) == (input_role_copy == 2) \|\| return rejected` — disarms exactly axis@copy2 and diagonal@copy1 | ditto for the two uncovered step-3 keys | **SURVIVED** (exit 0, 39.59 s) → **NG10**; probe 102/114 |
| **MH4** (control on NG3) | `_ar_entry`: `AnswerReduceTraceEntry(step, branch, player, …)` → `(step, branch, :alice, …)` | is the new rejecting-player assertion red-capable? | **KILLED** (exit 1, assertion failures, 60.69 / 31.06 s) — NG3's fix bites; this was invisible before brief 69 |
| **NG3 mutants** (r6 survivors MG1–MG3, now registered) | verbatim registry entries | must now break | **KILLED** in the registry, exit 1, 31.95 / 39.89 / 34.43 s |
| **MG5** (r6 TB1 probe, now registered as `tb1_degenerate_all_t`) | `ldt.jl:132` `admissible = (t,)` | must now break | **KILLED** in the registry, exit 1, 4.69 s |

Four of six new semantic mutations survived, all four from one axis, all four closed by
one 114-outcome block I have already run green-on-clean and red-under-each.

---

## 6. Per-claim decisions

Both statuses stay TESTED and both are **re-affirmed**. Every fact either row asserts
is true at `8a1b6e2` and has been independently recomputed here. NG10 is recorded as
**scope** in C9, not as a downgrade: the checks are implemented correctly at every copy
(114/114 honest accepts, 114/114 corrupted rejects with the expected rule, verified
here); what is missing is a test that fails when the rejection is removed at an
unwitnessed copy. No claim moves up or down this round.

### C4b — **RE-AFFIRMED TESTED**, statement UNCHANGED. The following edit is **AUTHORIZED**:

> In the C4b row of `claims/CLAIMS.md`, leave the statement, status, depends-on and
> test columns exactly as they stand, and replace the final column
> `` `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md`; `verdicts/tb2-r5.md` (re-affirmed); `verdicts/tb2-r6.md` (re-affirmed) ``
> by
> `` `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md`; `verdicts/tb2-r5.md` (re-affirmed); `verdicts/tb2-r6.md` (re-affirmed); `verdicts/tb2-r7.md` (re-affirmed) ``.

Rationale: nothing in C4b's territory changed this round — `cl.jl`, `pcp_sampler.jl`
and `answer_reduce.jl` all show an empty diff, all 108 product maps (54 types × 2
sides) are still `NotDescribable` with the single reason "continuation is an opaque
host closure", and all 18 PCP description sizes are byte-identical to r4/r5/r6 (§2.4).
NG9's precision remains offered, not demanded.

### C4c — **not this rung's claim; one red-list addition is AUTHORIZED**

C4c belongs to `verdicts/tb1-r6.md` / brief 67. NG7 was routed there by
`verdicts/tb2-r6.md`, and brief 69 landed its mutant in the TB1 lane. On the strength
of my own registry run — `TB1 NG7-degenerate-all-t admissible_t_only`, target
`tb1_decider_rejections`, **KILLED**, exit 1, 4.69 s, with the clean suite printing the
discriminating `t0_cheat_passed=false` — the orchestrator is **AUTHORIZED** to make
this single edit to the C4c row and no other:

> in C4c's red list, replace
> `` red: `test/mutations/tb1_{deg,agreement,symmetry,verifier_pi,online,off_line,degenerate_line,question_arity,kappa,dline_degree}.jl` ``
> by
> `` red: `test/mutations/tb1_{deg,agreement,symmetry,verifier_pi,online,off_line,degenerate_line,degenerate_all_t,question_arity,kappa,dline_degree}.jl` ``.

The C4c *statement* already claims the all-`t` fact is red-capable ("the
`degenerate_line_vs_point` fact is red-capable, `verdicts/tb1-r6.md` §4 NM18"); this
edit only records the registered owner. The statement, status, depends-on and verdict
columns are untouched, and I express no other opinion on C4c.

### C9 — **RE-AFFIRMED TESTED**, row text replaced. The following is **AUTHORIZED VERBATIM**:

> | C9 | (Typed answer-reduced decider — TB0 fixture) For the row `(q,k,m,d,s,m')=(2048,11,1,11,6,16)`, the trivial two-coordinate original sampler and its three-role oracularization, the typed answer-reduced decider implements the five guarded checks of `fig:decider-pcp` with the exact type-pair guards, the `i in {3,4,5}` restriction and both `ldparams=(q,m,d,1)` and `ldparams'=(q,m',d,m'+6)`; the honest strategy built from the TB0 PCP proof (witness (ii) for checks 4(a)/4(b)) is accepted on all 37 directed guard orientations at 37 distinct seeds, whose 37 `(step, branch, player, index, line_kind)` trace keys are asserted to be exactly the keys the sweep reaches and not merely a subset (`verdicts/tb2-r5.md` N28), and on 256 conditioned seeded question pairs at 256 distinct full-field seeds whose `chi(s_aux,m')` covers all 16 values, and every honest line answer checked equals the true restriction of the corresponding PCP polynomial at all `q=2048` line points (critic recomputation, `verdicts/tb2-r1.md` and `verdicts/tb2-r2.md` §2.3; the suite itself checks one such line through `D^ld`). Exactly `2736/2916 = 76/81 = 93.827%` of ordered product-type pairs trigger no check; of the remaining 180, 107 trigger step 5 (92 of them step 5 alone) and 54 trigger step 1 (53 of them step 1 alone) — the r1/r2 wording "107 only step 5 and 54 only step 1" was arithmetically wrong and is corrected here (`verdicts/tb2-r3.md` N10); all six numbers `(2736, 180, 107, 92, 54, 53)` are asserted by the suite and owned by the mutant `tb2_guard_split`, and this critic reproduced them by two further independent transcriptions of the guards (one in Julia, one in Python), together with the decomposition 1 + 4 + 6 + 4 of the fifteen step-5 pairs that also fire another guard. The decider itself, not only the enumerator `answer_reduce_guard_branches`, is now run on all 2916 ordered pairs — at the all-zero seed with the certificate replay's all-zero answers, and again at the nonzero full-field seed `tb2_seed 5` with honest TB0-proof answers (witness (ii) on the 18 of 2916 pairs that require it) — and its trace fires exactly the enumerated `(check, line_kind)` key set pair for pair, the branch label's `_axis`/`_diagonal` suffix being asserted to match the trace entry's line kind, with an empty trace on exactly the 2736 and an accept on all 2916 in both sweeps; the step-4(b) widening mutant `tb2_decider_guard_widened` is KILLED at 12 mismatches, and this critic reproduced the lockstep against a third, independently written transcription of `fig:decider-pcp` (0 mismatches clean, 12 mutated) and extended it to honest degenerate-proof answers at two seeds, where it also holds (`verdicts/tb2-r5.md` §2.2). The questions judged are the projections of the 54-type product sampler's own `sample` output, asserted equal to the explicit seed split on 20 seeds x 54 types x both sides (`verdicts/tb2-r2.md` N1 repaired in brief 46; independently recomputed in `verdicts/tb2-r3.md` §2.1). The `:TypedAnswerReduce` certificate replays shape, branch reachability and, for each of nine guard cases, one honest accept and one corrupted reject carrying the expected rule (ibid. N2 repaired). **Scope:** step 5 executes only items 3-5 of `fig:pcpverifier`; items 1-2 (`PaddedSuccinctDecider` -> Tseitin -> arithmetization) are not implemented, the formula is a construction-time constant, and the computed `x_alice=L^alice(x_Q)`, `x_bob=L^bob(x_Q)` reach `pcp_decider_specification` but do not enter the decision — asserted, including the equal verdict under a swapped call (`SOURCE_REPAIR :PCPVerifierFixedFormula`; `verdicts/tb2-r1.md` O3). Step 5's "otherwise, accept" is read as fallthrough, so the decider is strictly stricter than the literal source (`SOURCE_REPAIR :PCPGameOtherwiseFallthrough`; ibid. O8); the executable runs player-outer where the source is step-outer, with identical verdicts because every rejection is terminal (`verdicts/tb2-r2.md` N4). The nine-case replay carried inside the certificate still runs at the all-zero seed only; the suite re-runs the same nine cases — one per `fig:decider-pcp` guard branch that can reject, both line kinds of steps 3, 4(b) and 4(c) included — with honest TB0-proof answers at three seeds (all-zero, `tb2_seed 5`, RNG 0x9E) and in **both orientations** — the registered one and the swap `(case.right, case.left)` with the corrupted side flipped — asserting honest accept, corrupted reject, the expected rule, the reached step and the rejecting trace entry's player (`:alice` forward, `:bob` swapped, `:both` at step 1) for all 54 (case, seed, orientation) outcomes, recomputed independently by this critic, who also checked that the rejecting trace entry is the case's own step and the last entry of the trace in all 54 and that the observed player agrees with his own transcription of the guards in all 54 (`verdicts/tb2-r3.md` N9, `verdicts/tb2-r4.md` §2.5, `verdicts/tb2-r6.md` §2.3, `verdicts/tb2-r7.md` §2.1); disarming a step's rejection in the `:bob` orientation alone is KILLED at step 3, step 4(b) and step 4(c) (`tb2_{input,individual,simultaneous}_ld_only_alice`). Step 1 compares the full bundle: on all five equal-type copy-6 pairs the suite asserts that corrupting entry 1, 6, 7 or `m'+6 = 22` of the 22-entry right answer is rejected with rule `:global_consistency` at step 1 (20/20), the first-entry-narrowing mutant `tb2_global_consistency_first_entry` is KILLED at 5/20, and this critic swept every one of the 22 entries on all five pairs (110/110 rejected with that rule; 5/110 under the mutant) (`verdicts/tb2-r5.md` §2.3). Both facts are carried by the suite, not by the `:TypedAnswerReduce` certificate, whose replay list is the nine cases at the all-zero seed. **Scope (copy index):** the nine replay cases fix one copy per branch — step 2 at copy 1, step 3 axis at copy 1 and diagonal at copy 2, steps 4(a) and 4(b) at `i = 3` — so only 18 of the 37 trace keys carry a corrupted-reject witness; disarming a step's rejection at the other copies leaves all 530 TB2 assertions green, although the mutated decider then accepts corruptions the clean decider rejects at step 2 copy 2, step 3 axis copy 2 / diagonal copy 1, and steps 4(a)/4(b) at copies 4 and 5 (`verdicts/tb2-r7.md` NG10). Those copies are themselves correct at this commit: this critic ran one case per guard key — nineteen shapes, three seeds, both orientations — and obtained 114/114 honest accepts and 114/114 corrupted rejects with the expected rule and step, covering all 37 keys. The `i in {3,4,5}` restriction has no honest-play consequence and is evidenced only structurally (O14). `m=1` makes checks 3 and 4(b) act on the whole of `F_q^1`, and honest answer degrees are 1 against the declared bound `d=11` (O12). Detyping, its `+2` levels and its `16^54` loss, and every quantum conclusion remain CITED. | TESTED | D1,D2,C3,C4a,C4b | — | `test/tb2_answer_reduce.jl`; red: `test/mutations/tb2_{formula,g3,line,guard,guard_split,i345,mc1,mc2,mc3,nd2,nd4,tensor,opaque,decider_guard_widened,global_consistency_first_entry,individual_diagonal_never_rejects,simultaneous_diagonal_never_rejects,input_ld_only_alice,individual_ld_only_alice,simultaneous_ld_only_alice}.jl` | `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md`, `verdicts/tb2-r5.md`, `verdicts/tb2-r6.md`, `verdicts/tb2-r7.md` |

Four notes on the authorised text, for the proposer. (a) It is brief 69's MERGE
PROPOSAL — the r6 row minus the `Scope (orientation)` sentence, which I verified is
exactly what the proposal is — plus four changes I make as critic: the "27 (case,
seed) pairs" clause is replaced by the two-orientation, 54-outcome statement the
proposer earned (the brief's flagged under-count); the rejecting-player assertion and
the three `*_ld_only_alice` kills are recorded; the three new mutants are added to the
red list; and the new **Scope (copy index)** sentence is the NG10 record. (b) The
certificate count stays **nine** and remains frozen: if NG10 is closed inside
`_answer_reduce_replay_steps` rather than in the suite, "nine guard cases" and "the
nine cases at the all-zero seed" change and the row must come back for authorization.
(c) Like its predecessor, the `Scope (copy index)` sentence is to be **deleted**, not
weakened, by the repair that lands the 19-case block. (d) The assertion count 530 in
that sentence is this commit's; a repair that changes it should update the number in
the same edit.

### C4a, C7, C10, C11, C12 — not this rung's business

C4a belongs to `verdicts/tb1-r6.md`. C10 and C11 belong to `verdicts/tb3-r2.md` and
`verdicts/tb4-r1.md`; NG12 above is routed to C10's owner. C7 and C12 stay CONJECTURE;
nothing this round touches r4 §6.2's finding that `description_size` is not additive
under `direct_sum`.

---

## 7. Work order for the next round (one code fix, one documentation fix)

1. **NG10 (MAJOR).** Replace the nine ad-hoc replay cases by the nineteen guard-key
   cases of §3, keeping three seeds and both orientations — 114 outcomes — and assert
   that the rejecting trace keys are exactly the 37-key set. Register the four
   mutations of §5 (target `tb2_replay_seeds`) and show them KILLED. My
   `fullprobe.jl` is that test; it is green on `8a1b6e2` and red under each of the
   four. Then delete C9's **Scope (copy index)** sentence.
2. **NG11 (MINOR).** Orchestrator lane: edit
   `docs/tutorial/compress-explained.html` (drop the false "Still open (tb2-r6 NG3)"
   sentence; 27 → 54 outcomes in two orientations; the ratchet row's counts and its
   verdict list), then re-run `tools/build_site.py`. Do it after the C9 row lands so
   the page and `claims/CLAIMS.md` agree.
3. **NG12, NG8, NG9 (NOTE).** Recorded only; NG12 is routed to C10's owner.
4. **N23, N24, N25, r4 N9 residue (NOTE).** Unchanged, brief 39 (TB5).

**Why this family should now terminate — and why r6's argument that it already had was
wrong.** A guard branch's red-capability is indexed by the trace key
`(step, branch, player, index, line_kind)`. r3 closed the guard *set*; r4 closed the
step-1 answer *arity*; r5 closed the *line kind*; r6 closed the *player*. r6 §7 then
claimed `index` had been closed "by the 22-entry sweep" and declared the family shut.
It had not: that sweep varies the corrupted answer entry at step 1, whose trace `index`
is the constant 0, and 19 of the 37 keys — every one of them differing from a witnessed
key only in `index` — had no corrupted-reject witness at all. Item 1 closes the last
coordinate by construction rather than by argument: it puts one corrupted-reject
witness at **each** of the 37 keys, in both orientations, at three seeds, and asserts
that the rejecting-key set equals the honest sweep's `expected_keys`. After that there
is no coordinate of the key left to displace an objection into, and the assertion is
self-maintaining — a new guard key added to the decider would fail the equality rather
than silently escape. I have no further probe of this shape to run.

Objection trajectory for this rung: **14 → 5 → 5 → 6 → 6 → 6 → 3** (r7: 1 MAJOR +
1 MINOR + 1 NOTE, plus two carried r6 notes and four carried TB5 notes). Every r6
objection is discharged with no escapes; the r6 MAJOR's fix overshoots its demand; the
registry grew from 101 to 119 mutants with 55/55 clean baselines and no survivor; the
suite grew from 1038 to 1364 assertions. This round's single MAJOR is four one-token
exception lists, closed by one test block I have already written and run — and, unlike
r6's, its closure is verifiable rather than argued, because the 37-key equality makes
the coverage a checked assertion instead of a critic's enumeration. I would have said
PASS had the copy-index probes died; they did not, and law 4 does not care that the
code is correct at every copy — which, as §2.3 records, it is.

VERDICT: FAIL(NG10)
