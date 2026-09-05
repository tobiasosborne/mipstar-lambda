# Verdict tb2-r4 — adversarial critic on rung TB2 after repair r3 (commit `1919aff`, brief 54) — closing round

Evaluated on an archived copy (`git archive 1919aff | tar -x`) in
`/tmp/claude-1000/.../scratchpad/critic-tb2-r4/tree/`, instantiated there; cold
precompile of `MIPStarLambda` **188.8 s** (`real 3m10.9`, ungated — the concurrent
`critic-tb1-r4` lane held the precompile pidfile for part of it). The live working tree
was never read for `src/`/`test/` and never written; `claims/CLAIMS.md` and
`docs/DESIGN.md` were read live (orchestrator-owned). At the time of my read `docs/DESIGN.md`
was byte-identical to the archived copy (`diff` empty); it has since acquired one unrelated
edit in §5 (TB0 cold-precompile figures) from the concurrent `tb0`/`tb1-r4` merge, and every
§1.5/§9.3/§9.4 line quoted below is unchanged in both. No git command that changes state
was run. My scripts, mutated sources and logs live under the scratch directory only.

**Concurrency caveat (binding for every wall below).** A `critic-tb1-r4` lane ran its own
instantiate, suite and mutation runner on this box throughout; `pgrep -fc 'julia --project'`
was never 0 and the one-minute load average ranged from **1.5 to 12.0**. Both suite walls
are reported (§4); the gated wall — TB0's 60 s test body — passed in both, at 40.81 s
loaded and 41.04 s on the quieter re-run.

Files under review: `src/samplers/cl.jl` (839 L, was 701), `src/samplers/typed.jl` (170 L,
was 126), `src/samplers/pcp_sampler.jl` (329 L), `src/samplers/oracularize.jl` (157 L),
`src/verifiers/answer_reduce.jl` (687 L), `test/tb2_answer_reduce.jl` (735 L, was 619),
`test/mutations/tb2_*.jl` (14 files, was 12), `test/mutations/run.jl` (331 L),
`docs/DESIGN.md` §1.5/§9.3/§9.4, `claims/CLAIMS.md` C4b/C9.

---

## 1. Adjudication of every r3 row for this rung

| r3 item | claimed in `briefs/54-…last.md` | **adjudication** | my evidence |
|---|---|---|---|
| **N6** MAJOR — `describe_cl`'s canonical bytes are never checked against the map | FIXED (a)–(e) | **ACCEPTED** | All three fix demands are met and each is now load-bearing. (a) The five exact sizes are asserted, not printed (`test/tb2_answer_reduce.jl:251-255`). (b) The 18 byte strings are asserted pairwise distinct (`:257`), and each copy-6 `BranchByAxis` table asserted to hold 16 pairwise-distinct child *terms* (`:265-266`). (c) The behavioural tie is a real `decode_cl` (`src/samplers/cl.jl:562-687`) with `apply(decode_cl(b), z) == apply(L, z)` and equal depth-3 `factor_spaces` on the declared 36-seed chain set for all 18 maps (`:296-311`, evidence line `describe_roundtrip ok=true`). My §2.1 recomputation does the same *without* `decode_cl` — my own parser of the byte format plus my own evaluator of the parsed term — with **0 disagreements in 648 comparisons**. **NE1** is registered verbatim as `test/mutations/tb2_describe_byaxis_collapse.jl` and I observed it **KILLED** twice: in the registry (`exit=1, 30.84 s`) and on my own isolated copy (`exit=1, 3 failed assertions at test:265, :266, :311, evidence describe_roundtrip ok=false, 43.1 s`). The r3 MAJOR is discharged. |
| **the flagged judgment call: "the encoder needed no change"** | judgment call | **ACCEPTED — the proposer is right and brief 54 was wrong** | Brief 54's restatement of N6 demanded "(a) Fix the serializer so stage matrices and every `QuotedBranch` table are encoded". That premise is false: r3's N6 never said they were unencoded (NE1 was an *edit of* the encoder), and I verified it independently — my reserializer, written from the format spec, reproduces all 18 sizes exactly, and my parser recovers every stage matrix and every `ByAxis` child from the bytes and reproduces `apply` exactly (§2.1-2.2). Declining the format change and keeping 3009/2893/10228/2754/10479 was the correct call. |
| **N7** MINOR — `ZERO_MAP_FACTOR_PARTITION` is a free-standing constant | FIXED (honest route) | **ACCEPTED** (with **N23** NOTE) | `pad_level_evidence` (`src/samplers/typed.jl:50-90`) is a CHECKED `:pad_level` node whose replay re-runs the §9.4 contract and which carries `ZERO_MAP_FACTOR_PARTITION` **as a child exactly when the promotion ran** (`test/tb1_ld_sampler.jl:161-174`: present for `CLZero(F,5)` and for the empty-register zero map, absent for `L_ALine`). The TB2 half of the honest route is asserted at `test/tb2_answer_reduce.jl:216-224` and `:267` and I recomputed all four facts myself (§2.3): certificate has 10 nodes, none `:zero_map_factor_partition`; 0 described `:Step` terms with an empty factor register across all 18 maps; all 18 PCP maps level 3, all 3 oracularized maps level 1, all 54 direct sums level 3 *before* `TypedSampler` pads. Residue → N23. |
| **the flagged judgment call: the in-chain empty-register terminal rule** | judgment call | **ACCEPTED for this rung** (with **N24** NOTE) | `_pad_top` reads a *top-level* `CLZero(F,n,Int[])` as the zero map on `F^n` and promotes it on `{1..n}`; `_pad_tail` (the in-chain path, and `BranchPadded`) keeps the empty register empty because `_clstep` requires the child to occupy exactly the enclosing rest register, which is `Int[]` at a terminal. The two readings are each correct for their context, DESIGN §1.5/§9.4 now say so verbatim, and **TB2 is untouched by either** — it never pads a zero map at all (row above). The compositionality hazard is N24. |
| **N8** MINOR — two lockstep defects from the brief-46 DESIGN edits | FIXED | **ACCEPTED** | (a) `docs/DESIGN.md:1191` now closes the citation properly — `… zero maps (`gt-04-cl.tex:L122-L130`). `pad_level` promotes a zero map with `V_1` = …` — the spliced `gt-04-cl.` / dangling `tex:L122-L130` is gone. (b) §9.3 (`:1167`) now reads "the pair adapter `describe_cl(LA,LB,q)` and the `SamplerDescription` record are TB5 work (`verdicts/tb2-r3.md` G2)", i.e. named as TB5 work exactly as the fix demand offered. Both edits are in the archived tree AND in the live file (verified line by line at `:1191` and `:1167`), so the DESIGN lockstep holds at this commit. |
| **N9** NOTE — the outcome-checking replay runs at one degenerate seed | FIXED test-side; certificate replay still at the zero seed (declared out of lane) | **ACCEPTED** (residue honestly declared) | `test/tb2_answer_reduce.jl:565-609` runs the seven cases with honest TB0-proof answers at three seeds — the all-zero seed, `tb2_seed 5` and an RNG(0x9E) full-field seed (`:579` asserts exactly one of the three is all-zero) — and asserts four facts per pair: honest accept, corrupted reject, the expected rule, and that the case's step is reached. I re-ran all **21 (case, seed) pairs myself** outside the suite: all four facts hold, 21/21 (§2.5). The residue is real and correctly stated: `_answer_reduce_replay_steps` (`src/verifiers/answer_reduce.jl:645`) still opens with `seed = ntuple(_ -> zero(F), seed_dim(verifier.sampler))`, so `verify_certificate` alone still witnesses only the degenerate seed; `src/verifiers/answer_reduce.jl` was genuinely outside brief 54's lane. Recorded in the authorized C9 row. |
| **N10** MINOR — C9's step-5/step-1 split was arithmetically wrong and asserted nowhere | FIXED | **ACCEPTED** | `test/tb2_answer_reduce.jl:552-558` (testset `:540-562`) computes and asserts the six-number split over all 2916 ordered pairs, printing `MUTATION_EXPECTED_RULE guard_split actual=(2736, 180, 107, 92, 54, 53)`, and `test/mutations/tb2_guard_split.jl` widens the step-2 guard so the split moves 92 → 84 while `no_check` stays 2736: **KILLED** in the registry (`exit=1, 45.56 s`). I reproduced the numbers **three independent ways** (§2.4) — a fresh Julia transcription of the guards, the code's own enumerator, and a fresh Python transcription — all giving `(2736, 180, 107, 92, 54, 53)`, plus the mutant's expected `(2736, 180, 107, 84, 54, 53)` from my Python transcription, and the 15 = 1 + 4 + 6 + 4 decomposition r3 predicted. |
| r3 §1b **PARTIAL** — `QuotedBranch` rebuild + exact `description_size` | — | **now ACCEPTED** | The only reason it was PARTIAL was N6; see the first row. |
| **lockstep** (r3's authorized C4b/C9 rows applied) | orchestrator | **ACCEPTED** | `claims/CLAIMS.md` C9 is byte-identical to r3's authorized text; C4b differs in exactly one place — `\|` → `\\|` inside a markdown table cell, a format adaptation, not a semantic edit. |

**Score: 9 ACCEPTED · 0 PARTIAL · 0 REJECTED · 0 escapes.** Every r3 objection (1 MAJOR,
3 MINOR, 1 NOTE) and both flagged judgment calls are discharged, and the r3 survivor NE1
is now a permanent registered mutant that I observed KILLED.

---

## 2. Independent recomputations (all on the archived copy; scripts under scratch)

Scripts `recompute.jl`, `probe.jl`, `probe2.jl`, `mutate.jl`; logs `recompute.log`,
`probe.log`, `mutate.log`.

### 2.1 The bytes determine the map — checked without the package's decoder

I wrote my own parser of the canonical byte format from the spec
(`0xC1 | u32 q | u32 seed_dim | u32 level | term`; tags `Zero=0x00, Step=0x01, Const=0x10,
ByAxis=0x11, Lnf=0x12, Padded=0x13`; index lists as `u32 count` + `u16` entries; field
entries at `⌈11/8⌉ = 2` big-endian bytes) and my own evaluator of the parsed term (using
only `chi`, `L_lnf` and field arithmetic — never `decode_cl`, never `describe_cl.term`):

```
chain seeds = 36; distinct chi buckets = 16
header (q, seed_dim, level) agrees on 18/18 : true
my reserialized size == length(bytes) 18/18 : true
MY-PARSE+EVAL apply == apply(L) on 18 maps x 36 chain seeds : true  (648 comparisons)
MY factor_spaces(k=3) == marginal_k(L,.,3).factor_spaces : true
```

So the round trip the suite asserts is not a self-consistency artefact: an outside reader
of the byte string alone recovers a map that agrees with `apply` and with the depth-3
factor partition everywhere on the declared chain set. This is the substance of C4b's new
sentence and it is now genuinely evidenced.

### 2.2 Sizes, injectivity, the copy-6 tables

```
sizes: Point=3009  ALine_1..5=2893  ALine_6=10228  DLine_1..5=2754  DLine_6=10479
family equality (Point x6, ALine_1..5, DLine_1..5): true / true / true
pairwise-distinct byte strings: 18/18
ALine_6: branch=Padded(ByAxis) m=16 position=11  distinct children = 16
DLine_6: branch=ByAxis        m=16 position=6   distinct children = 16
```

All 18 sizes come out of *my* reserializer, so the five integers now asserted by the suite
are corroborated, not merely repeated. The 16-distinct-children property is checked on my
own parse of the bytes, so it is a property of the description, not of the in-memory table.

### 2.3 No promoted zero map anywhere in TB2

```
described :Step terms with an EMPTY factor register, all 18 maps: 0
certificate nodes = 10; carries :zero_map_factor_partition = false
all 18 pcp maps level 3: true; all 3 ora maps level 1: true;
all 54 direct sums level 3 BEFORE padding: true
```

I walked the certificate myself rather than using the suite's `tb2_has_node`.

### 2.4 The six-number guard split, three transcriptions

```
MY Julia transcription over 2916 ordered pairs : (2736, 180, 107, 92, 54, 53)
CODE answer_reduce_guard_branches               : (2736, 180, 107, 92, 54, 53)   agree
MY Python transcription, clean                  : (2736, 180, 107, 92, 54, 53)
MY Python transcription, step-2 widened (= tb2_guard_split's mutation)
                                                : (2736, 180, 107, 84, 54, 53)  = registered evidence
step-5 pairs that also fire another guard: global_consistency=>1, input_consistency=>4,
                                          proof_consistency=>6, proof_simultaneous=>4   (15 = 1+4+6+4)
```

### 2.5 The seven-case replay at three seeds

Run by me, not by the suite: seven `_answer_reduce_replay_cases()` × three seeds
(all-zero, `tb2_seed 5`, RNG 0x9E full field), honest answers from the TB0 proof, witness
chosen by `answer_reduce_requires_nondegenerate`:

```
seeds: exactly 1 of 3 is all-zero
21 (case, seed) pairs, honest accepted AND corrupted rejected with the expected rule
AND the case's step reached : true   rows=21
answer_reduce.jl certificate replay seed line: seed = ntuple(_ -> zero(F), seed_dim(verifier.sampler))
```

The last line is the residue: the *certificate-carried* replay is still single-seed.

### 2.6 Behavioural witnesses for the two new mutations (§5)

```
clean tree, three ordered type pairs the ENUMERATOR calls check-free:
  ((oracle,Point_3),(oracle,ALine_6))  branches=()  honest decider = (accept, rule=answer_reduce_accept, |trace|=0)
  ((oracle,Point_4),(oracle,DLine_6))  branches=()  honest decider = (accept, answer_reduce_accept, 0)
  ((oracle,ALine_6),(oracle,Point_5))  branches=()  honest decider = (accept, answer_reduce_accept, 0)
under NF1 (decider step 4(b) widened, enumerator untouched):
  all three                             branches=()  honest decider = (REJECT, rule=ld_question_format, |trace|=1)

clean tree, equal-type pairs with 22-entry answers, corrupting one entry of the right answer:
  (alice,Point_6) (bob,Point_6) (oracle,ALine_6) (oracle,DLine_6): guards=(:global_consistency,)
      entries 1, 7, 22 -> all REJECTED with rule=global_consistency
  (oracle,Point_6): guards=(:global_consistency, :game); same
under NF2 (step 1 compares the first entry only):
  (alice,Point_6) (bob,Point_6) (oracle,ALine_6) (oracle,DLine_6):
      entry 1 -> rejected (global_consistency); entries 7 and 22 -> ACCEPTED
  (oracle,Point_6): entries 7, 22 still rejected, but by rule=pcpverifier (step 5), not step 1
```

---

## 3. New objections

### NF1 · MAJOR · the decider's guards and the guard enumerator are two transcriptions, and nothing pins them together on the 2736 check-free pairs

**Location** `src/verifiers/answer_reduce.jl:392-535` (`typed_answer_reduced_decider`)
versus `:540-578` (`answer_reduce_guard_branches`); `test/tb2_answer_reduce.jl:509-538`
(`seeded`, which draws only from the `triggering` list built at `:514-518`), `:381-507`
(`branches`, hand-listed pairs and `in covered` superset assertions), `:540-562`
(`no_check`).

**My computation.** The six numbers `(2736, 180, 107, 92, 54, 53)` are computed from
`answer_reduce_guard_branches` alone. No test calls `typed_answer_reduced_decider` on any
of the 2736 pairs the enumerator calls check-free: `seeded` samples from `triggering`,
which is built from the same enumerator; `branches` and `replay_seeds` use hand-listed
pairs. So a drift that widens the *decider* there is invisible. Mutation **NF1**:

```julia
# answer_reduce.jl:484, step 4(b)
-               other_type.pcp.copy == i &&
+               other_type.pcp.copy in (i, 6) &&
```

```
MUTANT nf1_decider_step4b_widened_to_copy6 target=all exit=0 started=true
       assertion_failures=false seconds=259.8  => SURVIVED
```

The whole TB2 file — all 13 testsets, every one of the assertions the suite counts for
this rung — passes. It is not a no-op: §2.6 shows the mutated decider **rejects honest
play** with `:ld_question_format` on 12 ordered pairs the enumerator declares check-free,
where the clean decider accepts with an empty trace. C9's "the exact type-pair guards" and
"exactly 2736/2916 … trigger no check" are therefore statements about the enumerator only.
(r3 §6 item 1 predicted the drift but recorded it as elegance and asserted that only a
*narrowing* escapes; a widening escapes too, and that is the direction that breaks
completeness.)

**FIX DEMAND** Add a lockstep testset that runs `typed_answer_reduced_decider` over **all
2916 ordered type pairs** at one seed with the cheap `_answer_reduce_replay_answer`
answers, and asserts, for every pair, `Set(e.branch for e in decision.trace)` equals the
branch set `answer_reduce_guard_branches` reports (so an empty trace exactly on the 2736);
print it as `MUTATION_EXPECTED_RULE guard_lockstep mismatches=0`. Register **NF1** as
`test/mutations/tb2_decider_guard_widened.jl` (target `tb2_no_check` or the new testset)
with that evidence line and show it KILLED. The elegant alternative r3 already named —
one `guard_branches(left,right)` the decider iterates over — makes the testset unnecessary
by construction and should be preferred.

**SURVIVING WEAKER STATEMENT** On the 180 triggering pairs the decider and the enumerator
do agree, evidenced by 37 directed orientations, 256 conditioned seeded pairs and 21
(case, seed) replay pairs, all with honest accept; and `2736/2916 = 76/81` with the split
`(180, 107, 92, 54, 53)` is a correct statement about `answer_reduce_guard_branches`,
independently reproduced three ways by this critic. What is unevidenced is that the
decider itself is silent on those 2736 pairs.

### NF2 · MAJOR · step 1's answer comparison is exercised only at arity 1

**Location** `src/verifiers/answer_reduce.jl:415-423` (step 1) and
`src/verifiers/ldt.jl:98-101` (`_answers_equal`);
`src/verifiers/answer_reduce.jl:611-617` (the only replay case for step 1, at
`(alice,Point_1)` — a **one-entry** answer type); `test/tb2_answer_reduce.jl:391-396`
(the only `branches` case for step 1, also `(alice,Point_1)`).

**My computation.** Every test that makes step 1 *reject* uses a type whose answer has one
entry, so nothing distinguishes "the answers are equal" from "their first entries are
equal". Mutation **NF2**:

```julia
# answer_reduce.jl:417
-        equal = _answers_equal(left_parsed, right_parsed)
+        equal = _answers_equal(left_parsed[1:1], right_parsed[1:1])
```

```
MUTANT nf2_global_consistency_compares_first_entry_only target=all exit=0 started=true
       assertion_failures=false seconds=150.0  => SURVIVED
```

Again not a no-op: §2.6 shows that on the four equal-type pairs whose answers have
`m'+6 = 22` entries and whose **only** guard is step 1 — `(alice,Point_6)`,
`(bob,Point_6)`, `(oracle,ALine_6)`, `(oracle,DLine_6)` — the mutated decider **accepts**
a corruption of entry 7 or entry 22 that the clean decider rejects with
`:global_consistency`. On `(oracle,Point_6)` it is still caught, but by `pcpverifier` at
step 5, a different check with a different rule; that coincidence is what hides the defect
from the replay case. So `fig:decider-pcp` item 1 — the check that ties the two players'
full answers together — has no red witness above arity 1.

**FIX DEMAND** Extend `replay_seeds` (or add a `global_consistency` testset) so that, for
each of the four equal-type copy-6 pairs above and for at least entries `1`, `6`, `7` and
`m'+6` of the 22-entry bundle, the corrupted pair is rejected **with rule
`:global_consistency`**, and print
`MUTATION_EXPECTED_RULE global_consistency arity=22 rejected=…`. Register **NF2** as
`test/mutations/tb2_global_consistency_first_entry.jl` and show it KILLED. Adding a
second case to `_answer_reduce_replay_cases()` at `(oracle,ALine_6)` with
`corrupt=(:right, 7)` would carry the same fact inside the certificate.

**SURVIVING WEAKER STATEMENT** Step 1 is implemented correctly at this commit — I verified
directly that the clean decider rejects a corruption of entries 1, 7 and 22 on all five
equal copy-6 type pairs with rule `:global_consistency` — and it is red-capable at arity 1.
What is missing is any test that can fail when the comparison is narrowed, i.e. law 4 for
`fig:decider-pcp` item 1 above arity 1.

### N23 · NOTE · `pad_level_evidence` exists but nothing in production builds it

`src/samplers/typed.jl:42-48` — `TypedSampler`'s padding path calls `pad_level`, not
`pad_level_evidence`, and `grep` finds the latter only in `test/tb1_ld_sampler.jl`. So the
promotion node is carried only where a test explicitly constructs the evidence. Harmless
for TB2 (which never promotes, §2.3) and for TB1 (which does construct it), but it must be
wired into the sampler certificate before TB5 pads for real.

### N24 · NOTE · `pad_level` is not compositional on the empty-register `CLZero`

`src/samplers/typed.jl:14-33` — the same value `CLZero(F,n,Int[])` promotes to
`V_1 = {1..n}` through `_pad_top` and stays empty through `_pad_tail`/`BranchPadded`. The
reading is context-dependent but the datatype carries no context marker, so
`pad_level(chain)` and `pad_level(terminal_of(chain))` disagree on the factor partition.
TB2 is unaffected; brief 39's description-level `direct_sum`, which pads children, must
pass the context explicitly or mark the terminal.

### N25 · NOTE · what the round trip still does not pin

The bytes are tied to `apply` and to `factor_spaces`. They are *not* directly tied to the
`rest` register (only indirectly, via `_clstep`'s `_register(child_shape) == sort(rest)`
check inside `decode_cl`) nor to `BranchByAxis.position` for the `m=1` maps, where `chi`
has a single bucket. Both are cosmetic here; both become real when TB5 rebuilds
descriptions rather than reading them.

### N26 · NOTE · `decode_cl` does not re-impose the ambient partition

`src/samplers/cl.jl:637-687` builds every stage with `require_ambient=false`, so a byte
string whose `factor ∪ rest ≠ {1..n}` decodes to a value the public `CLStep` constructor
would reject. `decode_cl` is the natural place for TB5's well-formedness gate; today it
validates only the header `(seed_dim, level)` and the child registers.

---

## 4. Test and mutation evidence I observed

```
SUITE (archived tree 1919aff, warm depot)
  RUN 1  LOADED (load average 4.34 -> 3.49; 4 other `julia --project` processes at start,
                 the critic-tb1-r4 lane's suite and runner resident)
    MIPStarLambda load/precompile seconds = 0.331 (ungated)
    TB0 test-body wall seconds = 40.81 (warning=45.0, hard_limit=60.0)   <-- GATE PASSED
    Test Summary: MIPStarLambda | Pass 638  Total 638  Time 2m24.7s
    /usr/bin/time -v: Elapsed 2:26.43 · Maximum RSS 1,263,080 KiB · Exit status 0
  RUN 2  QUIETER (load average 2.56 -> 1.48)
    MIPStarLambda load/precompile seconds = 0.35 (ungated)
    TB0 test-body wall seconds = 41.04 (warning=45.0, hard_limit=60.0)   <-- GATE PASSED
    Test Summary: MIPStarLambda | Pass 638  Total 638  Time 2m14.5s
    /usr/bin/time -v: Elapsed 2:16.04 · Maximum RSS 1,203,668 KiB · Exit status 0
    Every printed TB0/TB1/TB2 line is byte-identical to run 1 except the two timing
    figures (`DLine_6 apply` 2.23 -> 2.12 us warm, 6.73 -> 5.72 us fresh).

  TB2 lines observed (both runs):
    TB2 sampler: PCP types=18 edges=324 dims V6=(16,6,16) SOURCE_REPAIR=true;
                 product types=54 edges=2916 level=3
    MUTATION_EXPECTED_RULE product_projection agrees=true compared=1080
    MUTATION_EXPECTED_RULE certificate rule=certificate_replay passed=true
    MUTATION_EXPECTED_RULE describable actual=18/18
    MUTATION_EXPECTED_RULE describe_roundtrip ok=true
    MUTATION_EXPECTED_RULE guard_split actual=(2736, 180, 107, 92, 54, 53)
    MUTATION_EXPECTED_RULE branches first_failure=none failures=0
    TB2 describe: Point_*=3009 ALine_1..5=2893 ALine_6=10228 DLine_1..5=2754 DLine_6=10479
    TB2 lem:cl-kth replay: chain_set_id=tb2-chi16-directed+rng20(0x9C)
                 distinct_chains 36 everywhere except Point_3=34, ALine_5=35;
                 completed_replays=36/map
    TB2 memo: distinct Linear prefixes=10000 limit=4096 max_entries=1844 entries=1916 nodes=53
    TB2 deterministic branches: covered=37 seeds=37
    TB2 seeded conditioned suite: RNG=0x182048 full-field seeds=256 accepted=256
    TB2 replay at 3 seeds (zero, tb2_seed 5, rng 0x9E): cases=7 outcomes=21 honest=21
                 corrupted_rejected=21
  TB2 testset sizes: sampler 26, describe 126, parsers 1, branches 46, seeded 3,
    no_check 3, replay_seeds 86, game 9, g3 2, line 2, guard 2, dline_projection 2, i345 1.

MUTATION RUNNER (`julia --project=. test/mutations/run.jl`, load 3.74 -> 6.95)
  package image ready after 0.68 s
  BASELINE (unmutated-first): 37/37 OK, every target exits 0
  TB0 25/25 KILLED · TB1 30/30 KILLED · TB2 14/14 KILLED
  new this round, both KILLED:
    TB2 M9-describe-byaxis-collapse byaxis_table_serialized_as_first_entry
        target=tb2_describe (exit=1, 30.84 s)
    TB2 M-guard-split input_consistency_guard_widened_to_lines
        target=tb2_no_check (exit=1, 45.56 s)
  MUTATION REGISTRY: killed=69/69 baselines ok=37/37 wall=855.81 s
  /usr/bin/time -v: Elapsed 14:16.91 · Maximum RSS 742,600 KiB · Exit status 0
  (The proposer's quiet figure is 555.67 s / 9:16; my 855.81 s is the same registry with
  the critic-tb1-r4 lane's runner resident. The runner carries no time gate and exits 0.)
```

## 5. New mutations written by this critic (applied on isolated copies; the tree was never modified)

| id | mutation | expectation | outcome |
|---|---|---|---|
| **NE1** (r3 survivor, re-run) | `cl.jl:473-474` `_describe_branch(::BranchByAxis)` serializes the first table entry `m` times — verbatim the text now in `test/mutations/tb2_describe_byaxis_collapse.jl` | must now break | **KILLED** (exit 1, 3 failed assertions at `test:265`, `:266`, `:311`, evidence `describe_roundtrip ok=false`, 43.1 s on my copy; 30.84 s in the registry) |
| **NF1** (new) | `answer_reduce.jl:484` step 4(b) `other_type.pcp.copy == i` → `in (i, 6)`: the *decider* checks 12 ordered pairs the *enumerator* calls check-free; `answer_reduce_guard_branches` untouched | probe: is the decider tied to the enumerator? | **SURVIVED** (exit 0, 0 failed assertions, whole TB2 file, 259.8 s) → **NF1**; §2.6 shows honest play rejected with `:ld_question_format` on those pairs |
| **NF2** (new) | `answer_reduce.jl:417` `_answers_equal(left_parsed, right_parsed)` → `_answers_equal(left_parsed[1:1], right_parsed[1:1])`: `fig:decider-pcp` item 1 compares 1 of 22 entries | probe: is step 1 red-capable above arity 1? | **SURVIVED** (exit 0, 0 failed assertions, whole TB2 file, 150.0 s) → **NF2**; §2.6 shows entries 7 and 22 accepted on four equal-type copy-6 pairs |

Both survivors are in one family — a check is exercised only on the pairs and entries a
hand-written list names — and one testset (the guard lockstep of NF1's fix demand plus the
arity-22 step-1 rejections of NF2's) closes both.

## 6. Forward look for brief 39 (TB5) — NOTEs on `SamplerDescription` / description-level `direct_sum`

1. **Byte format.** The header is `0xC1 | u32 q | u32 seed_dim | u32 level`, indices are
   `u16`, field entries `⌈log2 q / 8⌉` big-endian bytes, integers `u32`. So a description
   caps at `seed_dim ≤ 65535`, and `decode_cl` only knows `q ∈ {8, 2048}`
   (`_DESCRIPTION_FIELDS`): `direct_sum` at the description level must reject mixed `q`
   explicitly (today `_shift_cl` would happily build the value and `decode_cl` would then
   refuse it) and must register any new field before a description can round-trip.
2. **`description_size` is not additive.** `direct_sum` shifts every stage's registers, so
   each stage's `factor`/`rest` index lists grow by the other summand's coordinates and the
   stage matrices are re-embedded. `description_size(direct_sum(A,B))` is therefore **not**
   a function of `description_size(A)` and `description_size(B)`. DESIGN §9.2's exact-size
   law and C12's "exact-description-size" clause need either a size formula that takes the
   register widths as inputs, or a format where registers are stored as ranges.
3. **Hashing/injectivity.** `canonical_bytes` is deterministic and injective in evidence on
   21 maps; keep that property by construction — a description-level `direct_sum` must emit
   the same bytes as `describe_cl(direct_sum(A,B))` would, or the two paths must be
   asserted equal, otherwise the `LawCert` grading compares incomparable integers.
4. **Well-formedness.** `decode_cl` builds with `require_ambient=false` (N26) and never
   re-checks the factor/rest partition; the description-level combinators must re-impose
   `factor ⊎ rest = {1..n}` per stage, since that invariant is what `enu:cl-space-sum`
   replays.
5. **Dependency sets.** They must be read off the term as the union over every
   `BranchByAxis` table entry and every `BranchLnf` tail, not off the branch a particular
   seed reaches; and the `:Padded` wrapper must contribute the appended empty stages.
6. **Padding context.** N24: pass the padding context (top-level ambient vs in-chain
   terminal) explicitly into any description-level padding, and carry
   `ZERO_MAP_FACTOR_PARTITION` from `pad_level_evidence` (N23) rather than from a test.

---

## 7. Per-claim decisions

Both statuses are already TESTED and both are **re-affirmed** — every fact the rows assert
is true at `1919aff` and independently recomputed here — with the row texts replaced,
because the current rows say things about the tree that the brief-54 repair made false
(that the sizes are printed rather than asserted, that no test ties `canonical_bytes` to
the map, that only 2736/2916 is asserted). The proposer could not apply them (law 1) and
correctly filed merge proposals; I have taken those proposals as input and written the
wording below, which is what the orchestrator must apply. The two new MAJORs are recorded
as scope in C9, not as a downgrade: the code is correct, the corpus cannot yet fail.

### C4b — **RE-AFFIRMED TESTED**, row text replaced. The following is **AUTHORIZED VERBATIM**:


> | C4b | (Sampler is CL — PCP family) At `(q,k,m,d,s,m')=(2048,11,1,11,6,16)` the 18 PCP maps `{Point_i, ALine_i, DLine_i}_{i=1..6}` form one typed CL family on `V^pcp` (`seed_dim` 38), of constructed nesting depth 1, 2 and 3 respectively — upper bounds in the sense of `rk:higher-level`, not minimality claims — built only from lazy `CLStep` stages over named `QuotedBranch` continuations (`BranchConst`/`BranchByAxis`/`BranchLnf`, `src/samplers/pcp_sampler.jl:65-116`) whose factor and rest registers are disjoint coordinate-index sets whose union is all of `{1,...,38}`, with every reached continuation validated against the constructed child level and rest register, so a level-1 wrapper around a level-3 continuation is rejected at construction (`verdicts/tb2-r2.md` §2.1). All 18 are padded to the common level 3 by appending empty stages (`BranchPadded`), so every marginal of the child survives. The typed product with the three-role oracularized sampler has 54 types, level `max(ell,3)=max(1,3)=3`, and a type graph computed as the tensor product `E^ar = E^ora x E^pcp` (`gt-10-answer-reduction.tex:1949-1955`), which has `54^2=2916` oriented edges and equals the complete graph here only because both factor graphs are complete (`verdicts/tb2-r3.md` §2.2). The decider's questions are the projections of `sample(product, edge, seed)`: the suite asserts their equality with the explicit seed split on 20 seeds x 54 types x both sides (1,080 comparisons) and kills the summand-swap mutant `tb2_nd2` (`verdicts/tb2-r2.md` N1, repaired in brief 46 and independently recomputed in `verdicts/tb2-r3.md` §2.1). On 18 maps x 20 random full-field seeds, every stage output equals `A_i * seed\\|_{V_i}` scattered back, the factor spaces are pairwise disjoint and exhaust the ambient basis, the stage count equals the level, and the stage sum equals `apply`; `apply(L_DLine_6)` costs 2.0-3.5 us warm-memo and 5.4-7.0 us on fresh seeds, machine-load dependent. On the declared chain set `tb2-chi16-directed+rng20(0x9C)` (36 seeds per map, all 16 `chi` buckets) the `def:sampler` queries `Dimension`/`Marginal`/`Factor`/`Linear` replay `enu:cl-space-sum` and `enu:cl-map-sum` for all 18 maps (36 completed replays and 108 k-checks each; distinct chains 36 except `Point_3=34` and `ALine_5=35`), and `Linear` answers unreachable prefixes `u in V_{<j}` with a `_child` memo bounded by `CL_MEMO_LIMIT=4096`. **Scope:** `eq:V-pcp` gives `dim V_{6,coord}=6` while `table:tpcp` supplies one scalar; `chi` reads `V_{aux,coord}` and the other five coordinate components are zeroed (`SOURCE_REPAIR :PCPCopy6CoordinateScalar`; the convention is load-bearing — reading the copy-1 scalar instead makes step 4c reject, `verdicts/tb2-r3.md` NE2). The `rk:higher-level` zero-map promotion is never reached by this rung's maps: the suite and this critic's independent recomputation both find that no described stage has an empty factor register, that all 54 direct sums are already level 3 before `TypedSampler` pads, and that no node of the TB2 certificate is `:zero_map_factor_partition`; `pad_level_evidence` carries that node as a child whenever the promotion does run, exercised at TB1 only, and `TypedSampler`'s own padding path does not build such evidence (`verdicts/tb2-r3.md` N7, `verdicts/tb2-r4.md` N23). All 18 maps are describable with `description_size` 3009 (`Point_i`), 2893 (`ALine_1..5`), 10228 (`ALine_6`), 2754 (`DLine_1..5`), 10479 (`DLine_6`), asserted exactly by the suite together with the pairwise distinctness of the 18 canonical byte strings and 16 pairwise-distinct child terms in each copy-6 `BranchByAxis` table; `decode_cl` inverts `canonical_bytes`, and the suite asserts `canonical_bytes(describe_cl(decode_cl(b))) == b`, `apply(decode_cl(b), z) == apply(L, z)` and equal `marginal_k(·, z, 3).factor_spaces` for all 18 maps on the declared 36-seed chain set. This critic re-derived the same facts without the package's decoder — an independently written parser of the byte format plus an independent evaluator of the parsed term reproduce `apply` and the depth-3 factor spaces on 18 maps x 36 chain seeds (648 comparisons, 0 disagreements) and reproduce all 18 sizes from the format spec — and the `BranchByAxis`-collapse mutant `tb2_describe_byaxis_collapse` is KILLED (`verdicts/tb2-r3.md` N6, `verdicts/tb2-r4.md` §2.1-2.3). The 54 product maps are `NotDescribable` because `direct_sum` wraps host closures; their four queries and the `lem:cl-kth` replay do work (critic recomputation on 3 of 54 maps, 5 seeds each), but `DL9-direct-sum` at the description level is not implemented. No claim is made about any other `(q,m)`, nor about unselected reachable chains. | TESTED | D2, C4a | — | `test/tb2_answer_reduce.jl` (`sampler`, `describe`); red: `test/mutations/tb2_{mc1,nd2,tensor,opaque,describe_byaxis_collapse}.jl`, `test/mutations/tb1_{level,dsum,concat,ambient,pad_order}.jl` | `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md` |

### C9 — **RE-AFFIRMED TESTED**, row text replaced. The following is **AUTHORIZED VERBATIM**:

> | C9 | (Typed answer-reduced decider — TB0 fixture) For the row `(q,k,m,d,s,m')=(2048,11,1,11,6,16)`, the trivial two-coordinate original sampler and its three-role oracularization, the typed answer-reduced decider implements the five guarded checks of `fig:decider-pcp` with the exact type-pair guards, the `i in {3,4,5}` restriction and both `ldparams=(q,m,d,1)` and `ldparams'=(q,m',d,m'+6)`; the honest strategy built from the TB0 PCP proof (witness (ii) for checks 4(a)/4(b)) is accepted on all 37 directed guard orientations at 37 distinct seeds and on 256 conditioned seeded question pairs at 256 distinct full-field seeds whose `chi(s_aux,m')` covers all 16 values, and every honest line answer checked equals the true restriction of the corresponding PCP polynomial at all `q=2048` line points (critic recomputation, `verdicts/tb2-r1.md` and `verdicts/tb2-r2.md` §2.3; the suite itself checks one such line through `D^ld`). Exactly `2736/2916 = 76/81 = 93.827%` of ordered product-type pairs trigger no check; of the remaining 180, 107 trigger step 5 (92 of them step 5 alone) and 54 trigger step 1 (53 of them step 1 alone) — the r1/r2 wording "107 only step 5 and 54 only step 1" was arithmetically wrong and is corrected here (`verdicts/tb2-r3.md` N10); all six numbers `(2736, 180, 107, 92, 54, 53)` are asserted by the suite and owned by the mutant `tb2_guard_split`, and this critic reproduced them by two further independent transcriptions of the guards (one in Julia, one in Python), together with the decomposition 1 + 4 + 6 + 4 of the fifteen step-5 pairs that also fire another guard. They are, however, properties of the guard enumerator `answer_reduce_guard_branches`, which is a second transcription of the decider's own guards: no test calls `typed_answer_reduced_decider` on any of the 2736 pairs the enumerator calls check-free, so a drift that widens the decider alone there is undetected (`verdicts/tb2-r4.md` NF1). The questions judged are the projections of the 54-type product sampler's own `sample` output, asserted equal to the explicit seed split on 20 seeds x 54 types x both sides (`verdicts/tb2-r2.md` N1 repaired in brief 46; independently recomputed in `verdicts/tb2-r3.md` §2.1). The `:TypedAnswerReduce` certificate replays shape, branch reachability and, for each of seven guard cases, one honest accept and one corrupted reject carrying the expected rule (ibid. N2 repaired). **Scope:** step 5 executes only items 3-5 of `fig:pcpverifier`; items 1-2 (`PaddedSuccinctDecider` -> Tseitin -> arithmetization) are not implemented, the formula is a construction-time constant, and the computed `x_alice=L^alice(x_Q)`, `x_bob=L^bob(x_Q)` reach `pcp_decider_specification` but do not enter the decision — asserted, including the equal verdict under a swapped call (`SOURCE_REPAIR :PCPVerifierFixedFormula`; `verdicts/tb2-r1.md` O3). Step 5's "otherwise, accept" is read as fallthrough, so the decider is strictly stricter than the literal source (`SOURCE_REPAIR :PCPGameOtherwiseFallthrough`; ibid. O8); the executable runs player-outer where the source is step-outer, with identical verdicts because every rejection is terminal (`verdicts/tb2-r2.md` N4). The seven-case replay carried inside the certificate still runs at the all-zero seed only; the suite re-runs the same seven cases with honest TB0-proof answers at three seeds (all-zero, `tb2_seed 5`, RNG 0x9E) and asserts honest accept, corrupted reject, the expected rule and the reached step for all 21 (case, seed) pairs, recomputed independently by this critic (`verdicts/tb2-r3.md` N9, `verdicts/tb2-r4.md` §2.5). Step 1's answer comparison is exercised only through one-entry answer types: replacing `_answers_equal(left_parsed, right_parsed)` by a comparison of the first entry alone leaves the whole suite green, although it then accepts a corruption of entries 2..22 of a 22-entry bundle on the four equal-type pairs whose only guard is step 1 (`verdicts/tb2-r4.md` NF2). The `i in {3,4,5}` restriction has no honest-play consequence and is evidenced only structurally (O14). `m=1` makes checks 3 and 4(b) act on the whole of `F_q^1`, and honest answer degrees are 1 against the declared bound `d=11` (O12). Detyping, its `+2` levels and its `16^54` loss, and every quantum conclusion remain CITED. | TESTED | D1,D2,C3,C4a,C4b | — | `test/tb2_answer_reduce.jl`; red: `test/mutations/tb2_{formula,g3,line,guard,guard_split,i345,mc1,mc2,mc3,nd2,nd4,tensor,opaque}.jl` | `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md`, `verdicts/tb2-r4.md` |

### C4a, C7, C12 — no change from this rung

C4a is `verdicts/tb1-r4.md`'s business (brief 54's C4a scope edits and the proposed new
`C4c` row for TB1's `D^ld` are for that critic; I express no opinion and did not adjudicate
`tb1_*` mutants beyond observing that all 30 are KILLED in the registry I ran). C7 stays
CONJECTURE. C12 stays CONJECTURE, but two of the five things it names are now better
supported and one is worse: `describe_cl`/`decode_cl` give an injective, round-tripping,
independently re-derived serializer (C12's "exact-description-size" law now has a real
encoder under it), while §6.2 shows that law is **not** additive under `direct_sum`, which
brief 39 must resolve before C12 can move.

---

## 8. Work order for the next round

1. **NF1 (MAJOR).** One lockstep testset over all 2916 ordered pairs tying
   `typed_answer_reduced_decider`'s trace to `answer_reduce_guard_branches`; register the
   widening mutant. Preferably fix by construction (single `guard_branches` the decider
   iterates), which is r3 §6 item 1 and deletes ~60 duplicated lines.
2. **NF2 (MAJOR).** Arity-22 step-1 rejections with rule `:global_consistency` on the four
   equal-type copy-6 pairs; register the first-entry mutant; optionally add an
   `(oracle,ALine_6)` case with `corrupt=(:right, 7)` to `_answer_reduce_replay_cases()`
   so the certificate carries it too.
3. **N23 (NOTE).** Wire `pad_level_evidence` into `TypedSampler`'s padding path.
4. **N24, N26 (NOTE).** Padding context and the ambient-partition gate — brief 39.
5. **N9 residue (NOTE).** When `src/verifiers/answer_reduce.jl` is next in someone's lane,
   move the three seeds into `_answer_reduce_replay_steps` so `verify_certificate` alone
   witnesses them.
6. **§9 gaps G1–G3, G5** remain TB5 work; §6 above is the NOTE list for brief 39.

Objection trajectory for this rung: **14 → 5 → 5 → 6** (r1: 1 FATAL + 4 MAJOR + 6 MINOR +
3 NOTE; r2: 1 MAJOR + 2 MINOR + 2 NOTE; r3: 1 MAJOR + 3 MINOR + 1 NOTE; r4: 2 MAJOR +
0 MINOR + 4 NOTE). Severity is falling in the sense that matters — every r3 objection is
discharged with no escapes, no r3 fix was cosmetic, all 69 registered mutants are KILLED
with 37/37 clean baselines, and every number this rung prints was reproduced independently
here (three times over for the guard split, and once from the raw bytes for the whole
serializer). The count did not fall because this round's two probes are the first to attack
the *decider* rather than the sampler, and both found the same structural weakness: a check
is only red-capable on the pairs and answer entries a hand-written list happens to name.
Neither is a regression and neither refutes anything in C4b or C9; both are law-4 gaps in
the corpus, and one testset closes both.

VERDICT: FAIL(NF1,NF2)
