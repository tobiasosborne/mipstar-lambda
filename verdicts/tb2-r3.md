# Verdict tb2-r3 — adversarial critic on rung TB2 after repair r2 (commit `dcaaf34`, brief 46)

Evaluated on an archived copy (`git archive dcaaf34 | tar -x`) in
`/tmp/claude-1000/.../scratchpad/critic-tb2-r3/tree/`, instantiated there (cold
precompile **101.2 s**, ungated). The live working tree was never read for `src/`/`test/`
and never written; no git command that changes state was run.

**Concurrency caveat (binding for every wall below).** Two other agents were running
Julia on this box throughout: a `critic-tb1-r3` lane (its own instantiate + suite) and a
`tb0-r4` lane running `test/runtests.jl` in the live tree. `pgrep -fa julia` was never
empty and the one-minute load average ranged from **2.7 to 13.7**. Both suite walls are
reported; the machine did eventually go quiet (0 other Julia processes, load 0.40) and the
gated wall — TB0's 60 s test body — was re-measured there at **40.606 s with the whole suite
499/499 green, exit 0** (§4).

Files under review: `src/samplers/cl.jl` (701 L, was 343), `src/samplers/typed.jl` (126 L, was 85),
`src/samplers/pcp_sampler.jl` (329 L), `src/samplers/oracularize.jl` (157 L),
`src/verifiers/answer_reduce.jl` (687 L), `test/tb2_answer_reduce.jl` (619 L),
`test/mutations/tb2_*.jl` (12 files), `test/mutations/run.jl` (306 L),
`docs/DESIGN.md` §1.5/§1.6/§9, `claims/CLAIMS.md` C4b/C9.

---

## 1. Adjudication of every r2 row and every §9-prep item claimed for this rung

### 1a. `verdicts/tb2-r2.md` work order

| r2 item | claimed in `briefs/46-…last.md` | **adjudication** | my evidence |
|---|---|---|---|
| **N1** MAJOR — product maps off the decider path; ND2 survives | FIXED | **ACCEPTED** | `sample_answer_reduce_questions` (`answer_reduce.jl:141-149`) now calls `sample(verifier.sampler, (left,right), Tuple(seed))` and projects (`_answer_reduce_project`, `:129-139`); `sample` applies the padded product maps (`typed.jl:98-108`). I re-ran the r2 survivor **ND2** (summand swap) on an isolated copy: **KILLED** (exit 1, `agrees` fails at `test:165`, printing the registered evidence `MUTATION_EXPECTED_RULE product_projection agrees=false`, 59 s). Independent recomputation §2.1: over **1080** (type, seed) pairs × both sides, `apply(product.left[k],z) == (apply(ora,z[1:2])…, apply(pcp,z[3:40])…)` and my own projection of `sample(...)` equals `sample_answer_reduce_questions` — 0 disagreements. The old seed split survives only as the test reference `tb2_hand_split` (`test:68-81`). |
| **N2** MINOR — CHECKED replay verifies reachability, not checks | FIXED | **ACCEPTED** (with N9 NOTE) | `_answer_reduce_replay_steps` (`answer_reduce.jl:611-673`) runs **7** guard cases, each with an honest accept and a one-entry corruption, and `_answer_reduce_replay` (`:45-68`) requires `honest_passed && !corrupted_passed && corrupted_rule == expected_rule` for all seven plus `steps == Set(1:5)`. I ran the replay myself: all seven `(case, true, false, rule)` with rules `global_consistency, input_consistency, ld_axis_point, ld_diagonal_point, proof_consistency, ld_axis_point, pcpverifier` — identical to the printed report. The r2 survivor **ND4** is now the registered mutant `tb2_nd4.jl` on target `tb2_sampler` with evidence `certificate rule=typed_answer_reduce_shape passed=false`; **KILLED** in my registry run (§4). Residual weakness: the all-zero seed (N9). |
| **N3** MINOR — `pad_level` prepends | FIXED | **ACCEPTED** (with N7) | `_pad_tail` (`typed.jl:12-37`) appends: a `CLStep` keeps its factor/rest/matrix and wraps the branch in `BranchPadded`, and a `CLZero` on a **nonempty** register is promoted to stage 1 = that register under the zero map followed by empty stages. Verified on the TB2 family: my §2.4 replay reports `space_sum_ok = map_sum_ok = true` for all 18 padded maps and `Factor` indicators partition `{1,…,38}` exactly. DESIGN §1.5 and §9.4 now state the APPEND convention. **But** TB2 never reaches the promotion branch (every reachable `CLZero` here has an empty register), and the `ZERO_MAP_FACTOR_PARTITION` node is never attached to a certificate — see **N7**; the authorized C4b text below is worded accordingly. |
| **N4** NOTE — player-outer loop order | proposal | **ACCEPTED** | DESIGN §1.6's step-5 row now carries the sentence verbatim with the `verdicts/tb2-r2.md N4` pointer. |
| **N5** NOTE — type graph written complete | FIXED | **ACCEPTED** | `oracularize.jl:81-83` computes `graph = [((l,r),(l2,r2)) for (l,l2) in E^ora for (r,r2) in E^pcp]`. §2.2: I built the tensor set myself from the two factor graphs — `9 × 324 = 2916`, equal to the code's graph **and** to the complete `54²` graph, with the DESIGN §9.4 red-test edge `((oracle,Point_1),(alice,DLine_6))` present. `tb2_tensor.jl` (Cartesian graph product, 1080 edges) is registered and KILLED. |
| **O5** PARTIAL — `briefs/18-tb2.last.md` still asserts "no semantic deviation" | RESIDUE (orchestrator lane) | **ACCEPTED — now FIXED** | The false sentence is gone; the report now reads "Deviations from DESIGN (corrected per `verdicts/tb2-r1.md` O5 — the original sentence 'no semantic deviation' was false)" followed by the six-item list. r1 O5's fix demand is met in the body of the report of record. |
| **O10** PARTIAL — certificate honesty | FIXED | **ACCEPTED** | Superseded by N2 above; `verify_certificate(checked)` is asserted at `test:181` and the replay outcomes are asserted at `test:186-192`. |
| **O11** PARTIAL — only 4 of 8 TB2 mutants carried `expected_evidence` | FIXED | **ACCEPTED** | All **12** TB2 mutants now carry `expected_evidence` (`tb2_{formula,g3,line,guard,i345,mc1,mc2,mc3,nd2,nd4,tensor,opaque}.jl`); I read each file and confirmed the string, and confirmed the clean suite prints the complementary line for each (`i345 actual=(3, 4, 5)`, `branches first_failure=none`, `product_edges actual=2916`, `describable actual=18/18`, `product_projection agrees=true`, `certificate rule=certificate_replay passed=true`). |

*On brief 51's "six unresolved items":* `briefs/46-tb1-tb2-repair-r2-describable.last.md`
contains no section under that name — it has a response table, a §9-prep table, the size
line, a runner summary, CROSS-LANE EDITS, MERGE PROPOSALS and DESIGN proposals. I read the
residues it does leave open as: (1) the 54 product maps are `NotDescribable` (`direct_sum`
wraps host closures) — adjudicated in §2.5; (2) `briefs/18-tb2.last.md` (O5) is out of lane —
now fixed, row above; (3) `pad_level`'s zero-map promotion node is never carried by a
certificate — **N7**; (4) TB2 N4 is a DESIGN sentence only, no code change — accepted;
(5) C4a's `enu:cl-space-sum` strike is left "for the r3 verdict to authorize" — that is
`verdicts/tb1-r3.md`'s row, not mine; (6) the C4b/C9 merge proposals themselves are unapplied
because law 1 forbids the proposer to apply them — authorized verbatim in §8 below.

**Score: 8 ACCEPTED · 0 PARTIAL · 0 REJECTED · 0 escapes.** Every r2 MAJOR/MINOR/NOTE is
discharged, and the two r2 mutant survivors (ND2, ND4) are now permanent registered mutants
that I observed KILLED.

### 1b. The §9-prep items, as they touch this rung's maps

| §9-prep item | claimed | **adjudication** | my evidence |
|---|---|---|---|
| `QuotedBranch` rebuild of the 18 PCP maps + exact `description_size` | 18/18 describable; 3009/2893/10228/2754/10479 | **PARTIAL** | The rebuild is real: `_pcp_cl_map` (`pcp_sampler.jl:65-116`) uses only `BranchConst`, `BranchByAxis` and `BranchLnf`, and `pad_level` adds `BranchPadded`. I reproduced **all 18 sizes exactly with my own reserializer** written from the encoder spec, and by hand for one map of each family (§2.5). But the suite only *prints* the sizes and asserts family-equality, determinism and `level == 3`; nothing ties `canonical_bytes` to the map. My mutation **NE1** proves the gap — see **N6**. |
| prefix-addressed `Factor`/`Linear`, `Dimension`, `Marginal` | present, §9.1 domains | **ACCEPTED for this rung** | `Factor` enforces `u ∈ L_{<j}(V)` by per-stage column-space membership plus zero support outside the walked factors (`cl.jl:337-370`); `Linear` uses the broader `u ∈ V_{<j}` (`:373-378`), and TB2's memo testset genuinely exercises **unreachable** prefixes: `DLine_6`'s stage-1 matrix selects only `auxiliary_coordinate`, so the 10⁴ prefixes supported on all six copy-6 coordinate registers (`test:267-281`) are outside the column space and `Linear` still answers them. Matches `def:sampler` (`gt-04-cl.tex:588-594`), re-transcribed. |
| chain-directed `enu:cl-space-sum`/`enu:cl-map-sum` replay | `tb2-chi16-directed+rng20(0x9C)`, 36 seeds/map, per-map distinct chains | **ACCEPTED** | §2.4: I rebuilt the chain set from the same RNG and recomputed the distinct-chain counts with **my own** stage-key walk. Exact agreement with `cl_kth_replay` and with the printed report on every one of the 18 maps, including the two non-36 entries `Point_3 = 34` and `ALine_5 = 35`; `completed_replays = 36`, `map_sum_checks = 108`, `space_sum_ok = map_sum_ok = true` for all 18; the 36 seeds hit all 16 `χ` buckets. |
| bounded `_child` memo | `CL_MEMO_LIMIT = 4096`; max 1844 entries over 53 nodes | **ACCEPTED** | Reproduced in my suite run: `TB2 memo: distinct Linear prefixes=10000 limit=4096 max_entries=1844 entries=1916 nodes=53`. The bound is genuinely exercised (10⁴ ≫ 4096, and the clear-on-full leaves 10000 − 2·4096 ≈ 1808–1844). |

---

## 2. Independent recomputations (all on the archived copy; scripts under scratch)

Script: `scratchpad/critic-tb2-r3/recompute.jl`, log `recompute.log`.

### 2.1 `sample_answer_reduce_questions` is a projection of `sample(...)`

```
seed_dim ora=2 pcp=38 product=40
direct_sum(ora,pcp) == blockwise apply on 1080 (type,seed) pairs x 2 sides: true
sample_answer_reduce_questions == my projection of sample():            true
```

I did not use the suite's helper: I recomputed `(apply(ora.left[role], z[1:2])…,
apply(pcp.left[kind], z[3:40])…)` and `pcp_question_from_ambient` myself for all **54**
types × 20 random full-field seeds × both sides. The suite's own `agrees/compared=1080`
line is therefore corroborated, not merely repeated. `gt-10-answer-reduction.tex:1956-1962`
("the corresponding CL function is simply the direct sum … the product distribution
`μ_ora × μ_pcp`") now has a red neighbour: **ND2 KILLED**, plus my new **NE2** (§5) which
kills a copy-6 register misread that the r2 tree would have needed the same seed split to catch.

### 2.2 `E^ar = E^ora × E^pcp` and the DESIGN red-test edge

```
|E^ora|=9  |E^pcp|=324  |my tensor|=2916  |code graph|=2916
equal_to_code=true   equal_to_complete=true
red-test edge ((oracle,Point_1),(alice,DLine_6)) present: true
```

Re-transcribed `gt-10-answer-reduction.tex:1949-1955` before reading the code: the source
writes the *unordered* relation `{(l,r),(l',r')} : {l,l'} ∈ E^ora and {r,r'} ∈ E^pcp`; the
code emits the oriented version. On this fixture both factor graphs are complete with
loops, so the oriented tensor is a bijection onto `54²` and no edge is duplicated
(`length == 2916`, not merely `Set(...) == complete`). The coincidence with the complete
graph is stated in the code comment (`oracularize.jl:77-80`) and in the test comment.

### 2.3 The seven-case replay

```
replay passed = true
(:global_consistency,    honest=true, corrupted=false, rule=:global_consistency)
(:input_consistency,     true, false, :input_consistency)
(:input_axis,            true, false, :ld_axis_point)
(:input_diagonal,        true, false, :ld_diagonal_point)
(:proof_consistency,     true, false, :proof_consistency)
(:proof_simultaneous_axis,true, false, :ld_axis_point)
(:game,                  true, false, :pcpverifier)
```

All five `fig:decider-pcp` steps are covered (steps 1, 2, 3-axis, 3-diagonal, 4a, 4c, 5),
each with an honest accept **and** a rejection carrying the expected rule. **ND4** re-run:
registered as `tb2_nd4.jl` and KILLED in my registry run (§4); the r2 escape is closed.

### 2.4 The chain set `tb2-chi16-directed+rng20(0x9C)`

My own walk (`mykeys`: the sequence of stage keys consumed, recomputed from the stage
matrices without calling `marginal_k`) versus `cl_kth_replay`:

```
kind      code_distinct  mine_directed  mine_full  completed  kchecks  space_sum  map_sum
Point_1..6   36,36,34,36,36,36   identical   identical    36        108      true      true
ALine_1..6   36,36,36,36,35,36   identical   identical    36        108      true      true
DLine_1..6   36 x 6              identical   identical    36        108      true      true
distinct chi buckets over the 36 chain seeds = 16
```

Every number agrees with `briefs/46-…last.md`, including the two collisions it reports
(`Point_3 = 34`, `ALine_5 = 35`). No disagreement with the printed report anywhere.

### 2.5 `description_size` by my own reserialization; the 54 product maps

I implemented the canonical encoding independently from `cl.jl`'s spec
(`1 + 4·3` header, then per term `1 + 4 + (4+2|factor|) + (4+2|rest|) + 4 + 2·|matrix| +
branch`, branches `Const = 1+child`, `ByAxis = 13 + Σ children`, `Lnf = 1+4+(4+2|point|)+tail`,
`Padded = 1+4+inner-branch`, field width `⌈11/8⌉ = 2`) and also derived three of them on paper:

```
Point_i : 13 + [1+4+(4+76)+(4+0)+4+2*1444 + (1+4+(1+(1+4+4)))] = 3009   (code 3009)
ALine_1 : 13 + [... 2*1369 ... Padded(1, ByAxis(1,1,[31]))=49 ]   = 2893   (code 2893)
DLine_1 : 13 + [... 2*1296 ... ByAxis(1,1,[43])=56 ]              = 2754   (code 2754)
ALine_6 : 13 + [... 2*484 ... Padded(1, ByAxis(16,·,16x571))=9154] = 10228  (code 10228)
DLine_6 : 13 + [... 2*36  ... ByAxis(16,·,16x643)=10301 ]          = 10479  (code 10479)
all 18 sizes reproduced independently: true
pairwise-distinct bytes among the 18 PCP descriptions: 18/18
product maps NotDescribable: 54/54
   reason = "continuation is an opaque host closure",
   branch = MIPStarLambda.var"#_combine_embedded##8#…"{GF2048,…}
```

**Is the 54-map `NotDescribable` honestly stated, and is it acceptable for
`DL9-direct-sum`?** *Honestly stated:* yes at the API level and in DESIGN — §9.3 now says
"`direct_sum`/`concatenate` still wrap host closures, so their outputs are `NotDescribable`
until `DL9-direct-sum` answers them at the description level", and TB1's suite prints
`direct_sum=NotDescribable`. *Not stated where it matters:* neither the TB2 `describe`
testset nor the C4b row says a word about the 54 product maps; brief 46's §9-prep table
speaks only of "all 21 CL maps". The authorized C4b text below repairs that.
*Acceptable for `DL9-direct-sum`:* **yes in principle, no as it stands.** §9.4 defines
`DL9-direct-sum` at the description level — the wrapper embeds child descriptions and calls
only their four queries — so it never has to serialize `_combine_embedded`'s closure. But no
such combinator exists: `describe_cl` has exactly one method, on `AbstractCL`, and there is
no `CLDescription` algebra. See the §9 readiness verdict (§7, gap G1).

### 2.6 The four queries and the `lem:cl-kth` replay on the 54 product maps

Not claimed by anyone; I checked it because TB5 needs it:

```
(oracle,DLine_6)  level=3 dim=40  space_sum_ok=true map_sum_ok=true  (5 seeds, 15 k-checks)
(alice,ALine_6)   level=3 dim=40  space_sum_ok=true map_sum_ok=true
(bob,Point_1)     level=3 dim=40  space_sum_ok=true map_sum_ok=true
```

So `Dimension`/`Marginal`/`Factor`/`Linear` and `cl_kth_replay` all work unchanged on the
product maps even though `describe_cl` does not. This is the single most important positive
finding for §9 readiness.

### 2.7 χ coverage and the no-check fraction, recomputed

```
256 seeded conditioned questions: distinct seeds = 256
  distinct chi(s_aux, 16) over the seeds                      = 16 of 16
  distinct chi(question coordinate) on copy-6 line questions  = 13 of 16
no-check ordered type pairs = 2736/2916 = 76//81 = 93.827 %
```

C9's "covering all 16 values of `χ(s_aux,m')`" is a statement about the seeds and is true;
the *questions* of copy-6 line type realise 13 of 16 buckets at this RNG, because the type
pair is drawn before the seed. No change to the row is required; recorded for the record.

---

## 3. New objections

### N6 · MAJOR · `describe_cl`'s canonical bytes are never checked against the map they describe

**Location** `src/samplers/cl.jl:461-472` (`_describe_term`/`_describe_branch`),
`:529-548` (`describe_cl`); `test/tb2_answer_reduce.jl:206-229` (the `describe` testset).

**My computation.** The testset asserts exactly four things: 18/18 values are
`CLDescription`, `description.level == 3`, `canonical_bytes` is deterministic across two
calls of the *same* function, and sizes are equal within `{Point_1..6}`, `{ALine_1..5}`,
`{DLine_1..5}`. It never asserts the five exact sizes (they are `println`-ed), never asserts
that the 18 byte strings differ, and there is no decoder, so no assertion relates a
description to `apply`, `Marginal`, `Factor` or `Linear`. Mutation **NE1** exploits this:

```julia
# cl.jl:467-468
-_describe_branch(branch::BranchByAxis) =
-    (:ByAxis, branch.m, branch.position, Any[_describe_term(child) for child in branch.table])
+_describe_branch(branch::BranchByAxis) =
+    (:ByAxis, branch.m, branch.position, Any[_describe_term(first(branch.table)) for child in branch.table])
```

i.e. the serialized description of `ALine_6`/`DLine_6` now claims that all 16 `χ`-selected
continuations are the axis-1 one — the description asserts a `χ`-independent sampler.

```
MUTANT ne1 target=describe exit=0 started=1 test_failed_lines=0 seconds=20  => SURVIVED
sizes under the mutation: Point_1=3009 ALine_1=2893 ALine_6=10228 DLine_6=10479 (unchanged)
canonical_bytes sha256 (first 16 hex), clean -> mutated:
  ALine_6  95857913fd069f12 -> 099f8c7ddcd80e3f     (changed)
  DLine_6  b89e63be46872d15 -> 9ca676d38095da40     (changed)
  ALine_1  068484abd897b1eb -> 068484abd897b1eb     (m=1: unaffected)
  Point_1  04853b4cd752910e -> 04853b4cd752910e     (no ByAxis: unaffected)
```

The description of the two largest maps changes and the entire `tb2_describe` testset —
117 assertions — stays green. This is a law-4 violation for the exact numbers brief 46
reports in its headline table: `description_size` is what DESIGN §9.2 charges every
transformation with (`description_size(X) = length(canonical_bytes(X.code))`, "the checker
reserializes the term and recomputes that integer"), and TB5's `LawCert` grading is built on
it. `tb2_opaque.jl` covers only *presence* of a description, never its *content*.

**FIX DEMAND** In `test/tb2_answer_reduce.jl`'s `describe` testset: (a) assert the five exact
sizes `Point=3009, ALine_{1..5}=2893, ALine_6=10228, DLine_{1..5}=2754, DLine_6=10479`
instead of printing them; (b) assert the 18 `canonical_bytes` are pairwise distinct; (c) add
one behavioural tie — either a `decode`/reconstruct round trip asserting
`apply(decode(bytes), z) == apply(L, z)` on the declared chain set, or at minimum, per copy-6
map, that the described `ByAxis` table holds `m'` pairwise-distinct child terms. Register
**NE1** as a permanent mutant (`tb2_describe_byaxis_collapse.jl`, target `tb2_describe`,
expected evidence a named failing assertion) and show it KILLED.

**SURVIVING WEAKER STATEMENT** All 18 PCP maps are describable; their sizes are
3009/2893/10228/2754/10479, independently reproduced by this critic's own reserializer and
by hand for one map of each family; and at this commit the 18 canonical byte strings are in
fact pairwise distinct. That injectivity and that faithfulness are evidenced by
`verdicts/tb2-r3.md`, not by the suite.

### N7 · MINOR · `ZERO_MAP_FACTOR_PARTITION` is a free-standing constant, not a certificate child, and TB2 never reaches the promotion

**Location** `src/samplers/typed.jl:9-10` (definition), `:25` (comment reference);
asserted only at `test/tb1_ld_sampler.jl:151-152`.

**My computation.** `grep -rn ZERO_MAP_FACTOR_PARTITION src/ test/` returns the definition,
the export line, one comment and the two TB1 grade/rule assertions — it never appears as a
`children=` entry, so no `Checked` object carries it and `verify_certificate` on the TB2
verifier never prints it, although DESIGN §9.4 says the rule "is tagged
`SOURCE_REPAIR(zero-map-factor-partition)`". Independently: the promotion branch
(`_pad_tail(L::CLZero, extra)` with `!isempty(L.indices)`) is **never reached in TB2** — every
`CLZero` in this rung's maps has an empty register (`pcp_sampler.jl:77` `tail = CLZero(F,n,Int[])`;
`oracularize.jl:4,11` `CLZero(F,dimension,())`), and all 54 product maps are already level 3,
so `TypedSampler`'s `pad_level(L, 3)` is the identity on them. So this rung is padded entirely
by the `BranchPadded` append path, never by `rk:higher-level` promotion.

**FIX DEMAND** Attach `ZERO_MAP_FACTOR_PARTITION` as a child of the sampler certificate of
any `Checked` whose construction actually promoted a nonempty-register zero map (TB1's
`pad(CLZero(F,5),3)` and, later, `typed_anchor_sampler`/`detype_sampler`), or state in
DESIGN §9.4 that it is a documentation constant asserted directly rather than a carried node.

**SURVIVING WEAKER STATEMENT** The append order and the promotion are implemented and pinned
by `tb1_pad_order.jl`; only their carriage in a certificate is missing, and TB2's padded maps
do not exercise the promotion at all.

### N8 · MINOR · two lockstep defects introduced by the brief-46 DESIGN edits

**Location** `docs/DESIGN.md:1184` and `docs/DESIGN.md` §9.3.

**My computation.** (a) `sed -n 1184p docs/DESIGN.md` ends with

```
... stages `2..ell` report empty factors and zero maps (`gt-04-cl. (`pad_level` implements
this for any register zero map and exposes the node `ZERO_MAP_FACTOR_PARTITION`.)tex:L122-L130`).
```

The brief-46 parenthetical was spliced **inside** the citation, so §9.4 now cites a
nonexistent `gt-04-cl.` and leaves a dangling `tex:L122-L130`. This is the only place §9.4
cites `rk:higher-level`. (b) §9.3 states, in the present tense, "the pair adapter
`describe_cl(LA,LB,q)` wraps it"; `grep -rn "describe_cl" src/` shows exactly one method,
`describe_cl(L::AbstractCL{F})` at `cl.jl:530`. `SamplerDescription` and `QueryError` have
zero occurrences in `src/` outside a comment (`cl.jl:301`).

**FIX DEMAND** Close the citation (`(gt-04-cl.tex:L122-L130)`) and move the parenthetical
after it; and either implement `describe_cl(LA,LB,q)` or reword §9.3's sentence to name it
as TB5 work, as the neighbouring sentence already does for `DL9-direct-sum`.

**SURVIVING WEAKER STATEMENT** The single-value adapter, the four queries and the §9.2 replay
are implemented and exercised on this rung; only the pair/description-record layer and one
citation are wrong on the page.

### N9 · NOTE · the outcome-checking replay runs at one degenerate seed

`_answer_reduce_replay_steps` (`answer_reduce.jl:645`) evaluates all seven cases at
`seed = 0^40` with all-zero honest answers and a `+1` corruption. At that seed every
question is the zero vector, `χ(0,16) = 1`, and copy 6's view `z=(y,o,w)` is zero, so each
guard is exercised at a single degenerate point; only the rule *names* are discriminated
across cases. The fix is real (ND4 is killed by it), so this is a NOTE: add one nonzero
seed per case and assert the same four facts.

### N10 · MINOR · C9's "107 trigger only step 5 and 54 only step 1" is arithmetically wrong, and the split is asserted nowhere

**Location** `claims/CLAIMS.md` C9 (inherited from `verdicts/tb2-r1.md`);
`src/verifiers/answer_reduce.jl:540-578`; `test/tb2_answer_reduce.jl:480-493`
(the `no_check` testset asserts only `(2736, 2916)` and `76//81`).

**My computation.** I re-implemented `answer_reduce_guard_branches` from the code in a
separate language (Python) and enumerated all `54² = 2916` ordered product-type pairs. The
no-check count reproduces exactly (**2736 = 76/81 = 93.827 %**, agreeing with the suite,
with r2 §2.4 and with my §2.7 run of the real function), but the split does not:

```
my Python transcription of the guard rules, and the real
answer_reduce_guard_branches enumerated over all 2916 pairs, agree exactly:
  total=2916  no_check=2736  triggering=180
  step5_any=107   step5_only=92
  step1_any=54    step1_only=53
```

The 15 difference at step 5 is exactly the pairs where `(oracle,Point_6)` also fires
something else: 4 `input_consistency`, 6 `proof_consistency`, 4 `proof_simultaneous`, and
the diagonal `((oracle,Point_6),(oracle,Point_6))`, which is also the single pair that keeps
step 1 from being alone. So "107 **only** step 5" and "54 **only** step 1" are both false as
written; the true sentences are "107 trigger step 5, 92 of them alone" and "54 trigger step
1, 53 of them alone". Nothing in the suite asserts either number, so the error survived two
verdicts.

**FIX DEMAND** Extend the `no_check` testset to assert the four-number split
`(2736, 180, 107, 92, 54, 53)` over all 2916 pairs and print it, and register a mutant that
changes one guard's *breadth* (e.g. `_role_copy(counterpart.role) in (1,2)` → `in (0,1,2)`)
which the no-check count alone would not move enough to catch.

**SURVIVING WEAKER STATEMENT** `2736/2916 = 76/81` is correct, independently reproduced
three ways; only the finer split inside the 180 triggering pairs was misstated, and the
corrected numbers are in the authorized C9 row below.

---

## 4. Test and mutation evidence I observed

```
SUITE (archived tree dcaaf34, warm depot)
  RUN 1  load average 3.12 -> 2.17, two other agents' Julia jobs resident
    MIPStarLambda load/precompile seconds = 0.415 (ungated)
    TB0 test-body wall seconds = 72.128 (warning=45.0, hard_limit=60.0)   <-- GATE FAILED
    TB0 60 s test-body hard limit (measured 72.128 s) | Fail 1
    Test Summary: MIPStarLambda | Pass 498  Fail 1  Total 499  Time 2m29.8s
    /usr/bin/time -v: Elapsed 2:32.64 · Maximum RSS 1,234,388 KiB · Exit status 1
    The ONLY failing assertion in the whole suite is the TB0 timing gate; every TB0, TB1
    and TB2 content assertion passed (TB2: 22+117+1+46+3+2+9+2+2+2+2+1 = 209 assertions).
  RUN 2  QUIET (load 0.40 at start, `pgrep -fa 'julia --project'` = 0 other processes)
    MIPStarLambda load/precompile seconds = 0.329 (ungated)
    TB0 test-body wall seconds = 40.606 (warning=45.0, hard_limit=60.0)   <-- GATE PASSED
    Test Summary: MIPStarLambda | Pass 499  Total 499  Time 2m01.1s
    /usr/bin/time -v: Elapsed 2:02.63 · Maximum RSS 1,187,508 KiB · Exit status 0
    TB2 lazy CLStep replay: DLine_6 apply=2.02 us (warm memo); 5.80 us (1000 fresh seeds);
                            peak RSS MiB=728.6
    Every other printed TB2 line is byte-identical to run 1 (sizes, chain counts, memo).

  TB2 lines observed (run 1):
    TB2 sampler: PCP types=18 edges=324 dims V6=(16,6,16) SOURCE_REPAIR=true;
                 product types=54 edges=2916 level=3
    TB2 lazy CLStep replay: maps=18 seeds/map=20; DLine_6 apply=3.53 us (warm memo);
                 5.35 us (1000 fresh seeds); peak RSS MiB=753.9
    MUTATION_EXPECTED_RULE product_projection agrees=true compared=1080
    MUTATION_EXPECTED_RULE describable actual=18/18
    TB2 describe: description_size Point_*=3009 ALine_1..5=2893 ALine_6=10228
                  DLine_1..5=2754 DLine_6=10479
    TB2 lem:cl-kth replay: chain_set_id=tb2-chi16-directed+rng20(0x9C) completed_replays=36/map
    TB2 memo: distinct Linear prefixes=10000 limit=4096 max_entries=1844 entries=1916 nodes=53
    TB2 deterministic branches: covered=37 seeds=37; seeded 256/256; no-check 2736/2916

MUTATION RUNNER (`julia --project=. test/mutations/run.jl`, load 2.73 -> 11.73)
  package image ready after 0.52 s
  BASELINE (unmutated-first, brief 42's guard kept): 36/36 OK, every target exits 0
  TB0 22/22 KILLED : A B C D E F C8 G H I J K L M X1 X1b X2 X3 X4 N O Q
  TB1 27/27 KILLED : M-χ M-π M-lnf M-deg M-level N1 N2 N3 N4 N5 M-concat M-repair
                     M-ambient M-dsum M-kappa NM1 NM2 NM3 N3-space-sum N5-pad-order
                     M-chifree M9-describe-closure M9-factor-not-indicator
                     M9-linear-narrowed-domain M9-replay-skips-k M9-replay-skips-union
                     M9-memo-unbounded
  TB2 12/12 KILLED : c0_plus_one_formula 88.94 s · g3_plus_one 119.80 s ·
                     truncate_line 112.20 s · M-guard 120.96 s · M-i345 89.41 s ·
                     MC1 142.96 s · MC2 151.65 s · MC3 154.39 s ·
                     ND2 product_direct_sum_order_swapped 91.79 s ·
                     ND4 answer_reduce_ld_checks_always_accept 121.55 s ·
                     N5 product_graph_cartesian_not_tensor 83.50 s ·
                     M9-pcp-opaque-branch 36.48 s
  MUTATION REGISTRY: killed=61/61 baselines ok=36/36 wall=853.46 s
  /usr/bin/time -v: Elapsed 14:14.27 · Maximum RSS 730,276 KiB · Exit status 0
  The proposer's quiet figure is 471.1 s / 7m52; my 853 s is the same runner with two
  other agents' Julia jobs resident. The runner carries no time gate and exits 0 in both.
```

**On the gate.** Run 1's 72.128 s is a *loaded* measurement taken while a second agent's cold
precompile and a third agent's full suite were running (load 3.1 at start, peaking above 13
during my later work). **Run 2, on a genuinely quiet box (zero other Julia processes, load
0.40), measures 40.606 s and the whole suite is 499/499 green, exit 0.** That is inside the
60 s hard limit with 19 s of headroom and agrees with the proposer's quiet 39.622 s, the
orchestrator's 37.7 s at this commit, and r2's loaded 40.675 s. Corroborating this,
`git diff --stat 6f4083a dcaaf34 -- test/tb0_core.jl test/runtests.jl src/ir src/polynomials
src/fields src/verifiers/pcp.jl` is **empty**: no TB0 file changed between the base the
proposer measured and `dcaaf34`, so the gate cannot have regressed here. Recorded as a NOTE
with both walls per brief 41's timing caveat — **not** an objection. (The TB0 gate itself is
`verdicts/tb0-r4`'s business; a `tb0-r4` lane was running concurrently.)

## 5. New mutations written by this critic (applied on isolated copies; the tree was never modified)

| id | mutation | expectation | outcome |
|---|---|---|---|
| **ND2** (r2 survivor, re-run) | `oracularize.jl:72-75` `direct_sum(ora,pcp)` → `direct_sum(pcp,ora)` for both sides | must now break | **KILLED** (exit 1, `agrees` at `test:165`, evidence `product_projection agrees=false`, 59 s) |
| **NE1** (new) | `cl.jl:467-468` `_describe_branch(::BranchByAxis)` serializes the first table entry `m` times — the description claims a `χ`-independent continuation | probe: is the description tied to the map? | **SURVIVED** (exit 0, 0 failed assertions, 20 s) → **N6**; bytes of `ALine_6`/`DLine_6` provably change (sha256 above) while sizes and all 117 assertions are unchanged |
| **NE2** (new) | `pcp_sampler.jl:227-228` copy-6 questions read their coordinate from `registers[(6,:coord)][1]` (copy 1's scalar, which the CL map zeroes) instead of `auxiliary_coordinate` — the DD-20 `SOURCE_REPAIR` convention | must break the copy-6 line tests | **KILLED** (exit 1, 2 failed assertions, 138 s; `MUTATION_EXPECTED_RULE branches first_failure=ld_axis_point`, at `test:388`, the `(oracle,Point_6)×(oracle,ALine_6/DLine_6)` step-4c orientations) |

NE2 is the useful negative result for the proposer: the DD-20 copy-6 scalar convention is
**not** free — prover and decider agree on `χ` only because both read `V_{aux,coord}`, and
the suite catches a misread. NE1 is the survivor and the substance of N6.

## 6. Elegance — three places the code is still heavier than the mathematics

1. **The five guards are still written twice, verbatim.** `typed_answer_reduced_decider`
   (`answer_reduce.jl:392-535`) and `answer_reduce_guard_branches` (`:540-578`) encode the
   same predicates independently; only a drift that makes the decider *narrower* is caught
   (the no-check count would move). *Simplification:* one `guard_branches(left,right)`
   returning `(step, branch, player, index, line_kind)` that the decider iterates over.
   Carried over unfixed from r1/r2; not re-litigated as an objection.
2. **`_pcp_cl_map`'s first factor is still the whole complement.** For copies 1–5 the
   coordinate stage allocates a 37×37 (`ALine`) or 36×36 (`DLine`) dense matrix whose only
   nonzero entry is a single 1 (`pcp_sampler.jl:88,103`), and those matrices are 2 738 and
   2 592 of the 2 893 / 2 754 description bytes. *Simplification:* keep the factor list but
   store selector stages as an index set with a `_matvec`/encoder specialisation; both the
   `apply` cost (3.5–5.4 µs) and 95 % of the description size are these dense selectors.
3. **`describe_cl` serializes but nothing consumes.** There is a canonical encoder
   (`cl.jl:474-548`) and no decoder, so the only property the bytes can have is a length.
   *Simplification:* write the 30-line `decode_cl` that inverts `_encode_term!`; it makes
   N6's fix a one-line round-trip assertion and is the natural seed of `DL9-direct-sum`.

---

## 7. §9 readiness verdict

**Can TB5's `describe_cl` adapter and the four-query API be used AS IS by
`typed_anchor_sampler` / `repeat_sampler` (DESIGN §10)? — The four-query API: YES.
`describe_cl`: NO.**

1. **G1 (blocking).** `src/samplers/cl.jl:585-595` and `:630-637` — `direct_sum` and
   `concatenate` build continuations as anonymous closures, wrapped by `_as_branch` into
   `OpaqueBranch`, so every composite is `NotDescribable` (critic: **54/54** product maps).
   `typed_anchor_sampler` (§10.1) and `repeat_sampler` (§10.2) are concatenation/direct-sum
   constructors, so their outputs would be `NotDescribable` too. `DL9-direct-sum` must be a
   `CLDescription`-level combinator; none exists.
2. **G2.** `src/samplers/cl.jl:530` — the only method is `describe_cl(L::AbstractCL)`. No
   `describe_cl(LA,LB,q)`, no `SamplerDescription` record (`field_size`, `level`, `typing`,
   `query_time`, `description_size`, `dependency_set`), no `QueryError`. §9.1's typed arities
   `Marginal(n,w,j,z,type)` / `Factor(n,w,j,u,type)` do not exist: `cl.jl:303-378` are
   `(L,j,…)` on one map.
3. **G3.** `src/samplers/cl.jl:305-307` — `Marginal(L,0,z)` is legal in code and is used by
   `cl_kth_replay` (`:401`), but §9.1 admits only `1 ≤ j ≤ ell`; the adapter must keep the
   zero marginal internal or return `QueryError`.
4. **G4 (= N6).** `src/samplers/cl.jl:461-472` and `test/tb2_answer_reduce.jl:206-229` — no
   assertion ties `canonical_bytes` to the map, so §9.2's `description_size` law and every
   TB5 `LawCert` built on it inherit an untested serializer.
5. **G5.** `src/samplers/cl.jl:348,355,375` throw `ArgumentError`; the promised
   `ArgumentError → QueryError` mapping of §9.3 is unimplemented, and no TB2 test asserts
   `Factor` rejecting an unreachable PCP prefix (only `tb1_queries` does).
6. **Positive.** `Dimension`/`Marginal`/`Factor`/`Linear` and `cl_kth_replay` work unchanged
   on the 54 product maps (§2.6: level 3, dimension 40, `space_sum_ok = map_sum_ok = true`),
   `Linear` genuinely answers unreachable prefixes at `q=2048`, the memo is bounded, and
   levels/registers stay CONSTRUCTED through `direct_sum`. The query side of §9 is ready.

---

## 8. Per-claim decisions

Statuses are already TESTED; both are **re-affirmed**, with the row texts replaced because
the current rows are factually false about `dcaaf34` (they still say `pad_level` prepends,
that the type graph is written complete, and that the questions come from an explicit seed
split). The proposer could not repair them (law 1) and correctly filed merge proposals.

### C4b — **RE-AFFIRMED TESTED**, row text replaced. The following is **AUTHORIZED VERBATIM**:

> | C4b | (Sampler is CL — PCP family) At `(q,k,m,d,s,m')=(2048,11,1,11,6,16)` the 18 PCP maps `{Point_i, ALine_i, DLine_i}_{i=1..6}` form one typed CL family on `V^pcp` (`seed_dim` 38), of constructed nesting depth 1, 2 and 3 respectively — upper bounds in the sense of `rk:higher-level`, not minimality claims — built only from lazy `CLStep` stages over named `QuotedBranch` continuations (`BranchConst`/`BranchByAxis`/`BranchLnf`, `src/samplers/pcp_sampler.jl:65-116`) whose factor and rest registers are disjoint coordinate-index sets whose union is all of `{1,...,38}`, with every reached continuation validated against the constructed child level and rest register, so a level-1 wrapper around a level-3 continuation is rejected at construction (`verdicts/tb2-r2.md` §2.1). All 18 are padded to the common level 3 by appending empty stages (`BranchPadded`), so every marginal of the child survives. The typed product with the three-role oracularized sampler has 54 types, level `max(ell,3)=max(1,3)=3`, and a type graph computed as the tensor product `E^ar = E^ora x E^pcp` (`gt-10-answer-reduction.tex:1949-1955`), which has `54^2=2916` oriented edges and equals the complete graph here only because both factor graphs are complete (`verdicts/tb2-r3.md` §2.2). The decider's questions are the projections of `sample(product, edge, seed)`: the suite asserts their equality with the explicit seed split on 20 seeds x 54 types x both sides (1,080 comparisons) and kills the summand-swap mutant `tb2_nd2` (`verdicts/tb2-r2.md` N1, repaired in brief 46 and independently recomputed in `verdicts/tb2-r3.md` §2.1). On 18 maps x 20 random full-field seeds, every stage output equals `A_i * seed\|_{V_i}` scattered back, the factor spaces are pairwise disjoint and exhaust the ambient basis, the stage count equals the level, and the stage sum equals `apply`; `apply(L_DLine_6)` costs 2.0-3.5 us warm-memo and 5.4-7.0 us on fresh seeds, machine-load dependent. On the declared chain set `tb2-chi16-directed+rng20(0x9C)` (36 seeds per map, all 16 `chi` buckets) the `def:sampler` queries `Dimension`/`Marginal`/`Factor`/`Linear` replay `enu:cl-space-sum` and `enu:cl-map-sum` for all 18 maps (36 completed replays and 108 k-checks each; distinct chains 36 except `Point_3=34` and `ALine_5=35`), and `Linear` answers unreachable prefixes `u in V_{<j}` with a `_child` memo bounded by `CL_MEMO_LIMIT=4096`. **Scope:** `eq:V-pcp` gives `dim V_{6,coord}=6` while `table:tpcp` supplies one scalar; `chi` reads `V_{aux,coord}` and the other five coordinate components are zeroed (`SOURCE_REPAIR :PCPCopy6CoordinateScalar`; the convention is load-bearing — reading the copy-1 scalar instead makes step 4c reject, `verdicts/tb2-r3.md` NE2). The `rk:higher-level` zero-map promotion is implemented by `pad_level` but is never reached by this rung's maps, and its `SOURCE_REPAIR :zero_map_factor_partition` node is not carried by any TB2 certificate (ibid. N7). All 18 maps are describable with `description_size` 3009 (`Point_i`), 2893 (`ALine_1..5`), 10228 (`ALine_6`), 2754 (`DLine_1..5`), 10479 (`DLine_6`), reproduced by independent reserialization in `verdicts/tb2-r3.md` §2.5; the suite prints rather than asserts those integers and no test ties `canonical_bytes` to the map, so a description that misstates the `BranchByAxis` table survives the suite (ibid. N6). The 54 product maps are `NotDescribable` because `direct_sum` wraps host closures; their four queries and the `lem:cl-kth` replay do work (critic recomputation on 3 of 54 maps, 5 seeds each), but `DL9-direct-sum` at the description level is not implemented. No claim is made about any other `(q,m)`, nor about unselected reachable chains. | TESTED | D2, C4a | — | `test/tb2_answer_reduce.jl` (`sampler`, `describe`); red: `test/mutations/tb2_{mc1,nd2,tensor,opaque}.jl`, `test/mutations/tb1_{level,dsum,concat,ambient,pad_order}.jl` | `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md` |

### C9 — **RE-AFFIRMED TESTED**, row text replaced. The following is **AUTHORIZED VERBATIM**:

> | C9 | (Typed answer-reduced decider — TB0 fixture) For the row `(q,k,m,d,s,m')=(2048,11,1,11,6,16)`, the trivial two-coordinate original sampler and its three-role oracularization, the typed answer-reduced decider implements the five guarded checks of `fig:decider-pcp` with the exact type-pair guards, the `i in {3,4,5}` restriction and both `ldparams=(q,m,d,1)` and `ldparams'=(q,m',d,m'+6)`; the honest strategy built from the TB0 PCP proof (witness (ii) for checks 4(a)/4(b)) is accepted on all 37 directed guard orientations at 37 distinct seeds and on 256 conditioned seeded question pairs at 256 distinct full-field seeds whose `chi(s_aux,m')` covers all 16 values, and every honest line answer checked equals the true restriction of the corresponding PCP polynomial at all `q=2048` line points (critic recomputation, `verdicts/tb2-r1.md` and `verdicts/tb2-r2.md` §2.3; the suite itself checks one such line through `D^ld`). Exactly `2736/2916 = 76/81 = 93.827%` of ordered product-type pairs trigger no check; of the remaining 180, 107 trigger step 5 (92 of them step 5 alone) and 54 trigger step 1 (53 of them step 1 alone) — the r1/r2 wording "107 only step 5 and 54 only step 1" was arithmetically wrong and is corrected here (`verdicts/tb2-r3.md` N10); only the 2736/2916 figure is asserted by the suite. The questions judged are the projections of the 54-type product sampler's own `sample` output, asserted equal to the explicit seed split on 20 seeds x 54 types x both sides (`verdicts/tb2-r2.md` N1 repaired in brief 46; independently recomputed in `verdicts/tb2-r3.md` §2.1). The `:TypedAnswerReduce` certificate replays shape, branch reachability and, for each of seven guard cases, one honest accept and one corrupted reject carrying the expected rule (ibid. N2 repaired). **Scope:** step 5 executes only items 3-5 of `fig:pcpverifier`; items 1-2 (`PaddedSuccinctDecider` -> Tseitin -> arithmetization) are not implemented, the formula is a construction-time constant, and the computed `x_alice=L^alice(x_Q)`, `x_bob=L^bob(x_Q)` reach `pcp_decider_specification` but do not enter the decision — asserted, including the equal verdict under a swapped call (`SOURCE_REPAIR :PCPVerifierFixedFormula`; `verdicts/tb2-r1.md` O3). Step 5's "otherwise, accept" is read as fallthrough, so the decider is strictly stricter than the literal source (`SOURCE_REPAIR :PCPGameOtherwiseFallthrough`; ibid. O8); the executable runs player-outer where the source is step-outer, with identical verdicts because every rejection is terminal (`verdicts/tb2-r2.md` N4). The seven-case certificate replay runs at the all-zero seed only (`verdicts/tb2-r3.md` N9). The `i in {3,4,5}` restriction has no honest-play consequence and is evidenced only structurally (O14). `m=1` makes checks 3 and 4(b) act on the whole of `F_q^1`, and honest answer degrees are 1 against the declared bound `d=11` (O12). Detyping, its `+2` levels and its `16^54` loss, and every quantum conclusion remain CITED. | TESTED | D1,D2,C3,C4a,C4b | — | `test/tb2_answer_reduce.jl`; red: `test/mutations/tb2_{formula,g3,line,guard,i345,mc1,mc2,mc3,nd2,nd4,tensor,opaque}.jl` | `verdicts/tb2-r2.md`, `verdicts/tb2-r3.md` |

### C4a, C7, C12 — no change from this rung

C4a is `verdicts/tb1-r3.md`'s business (brief 46's proposal to strike its `enu:cl-space-sum`
scope clause is for that critic). C7 stays CONJECTURE. C12 stays CONJECTURE; N6 and gap G1
are directly relevant to it, since `DL9-direct-sum` and the exact-description-size law are
two of the five things it names.

---

## 9. Work order for the next repair round

1. **N6 (MAJOR, blocking).** Assert the five exact `description_size` integers, assert the 18
   descriptions are pairwise distinct, add a behavioural tie (`decode_cl` round trip is the
   elegant one), and register NE1 as a permanent KILLED mutant.
2. **N10 (MINOR).** Assert the guard split `(2736, 180, 107, 92, 54, 53)`; the corrected
   sentence is already in the authorized C9 row.
3. **N7 (MINOR).** Carry `ZERO_MAP_FACTOR_PARTITION` in a certificate, or downgrade it in
   DESIGN §9.4 to a documentation constant.
4. **N8 (MINOR).** Repair `docs/DESIGN.md:1184`'s spliced citation; reword or implement
   §9.3's `describe_cl(LA,LB,q)`.
5. **N9 (NOTE).** One nonzero seed per replay case.
6. **§9 gaps G1–G3, G5** are TB5 work, not TB2 repairs, but G1 should be scheduled before
   `typed_anchor_sampler`, since every TB5 sampler it produces is `NotDescribable` today.

Objection trajectory for this rung: **14 → 5 → 5** (r1: 1 FATAL + 4 MAJOR + 6 MINOR + 3 NOTE;
r2: 1 MAJOR + 2 MINOR + 2 NOTE; r3: 1 MAJOR + 3 MINOR + 1 NOTE). The count is flat because
N10 is an inherited arithmetic error this round's deeper enumeration surfaced, not a
regression: no r2 objection was rejected or escaped, both r2 mutant survivors are now
registered and KILLED, and every number printed by `briefs/46-…last.md` for this rung was
reproduced independently with zero disagreements.

VERDICT: FAIL(N6)
