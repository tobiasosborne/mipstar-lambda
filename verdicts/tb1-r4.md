# CRITIC verdict r4 — rung TB1 (`src/samplers/{cl,typed,ldt}.jl`, `src/verifiers/ldt.jl`, `test/tb1_ld_sampler.jl`, `test/mutations/tb1_*.jl`) at commit `1919aff`

Round 4 (adjudicate, closing round). **Prior.** `verdicts/tb1-r3.md` (FAIL(N12,N13); C4a RE-AFFIRM with an
authorized row, C4b one authorized sentence) is the work order, together with `briefs/54-tb1-tb2-repair-r3.md`.
Everything r1/r2/r3 accepted is settled and is not re-litigated; the four objections below are all on code that
did not exist at `dcaaf34`.

**Isolation.** `git archive 1919aff | tar -x -C <scratch>/tree` into
`/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-…/scratchpad/critic-tb1-r4/tree`, `Pkg.instantiate()`
+ `Pkg.precompile()` there (cold precompile **106.6 s** of a 1m55.7 s instantiate+precompile), and every test,
mutation and experiment run there. The live working tree was never read or run for `src/`/`test/`; `docs/`,
`briefs/`, `ground-truth/` were read from the **archived** copy and every `file:line` below is that copy;
`claims/CLAIMS.md` was read live (orchestrator-owned). My only repo output is this file. No state-changing git
command was run.

**Independence.** §1's numbers come from a reference written from the ground truth and the format contract alone
(`indep/ref.jl`, 191 lines): my own carry-less `GF(8)` (modulus `x^3+x+1`, associativity/distributivity/inverses
re-verified on all `8^3` triples), my own `chi` from `eq:chi-func`, my own `L^lnf` from `def:cl-canonical`'s RREF
pivot rule, my own **parser** of the canonical bytes, my own **re-emitter**, and my own **evaluator** of the parsed
term (Const / ByAxis / Lnf / Padded semantics re-derived, not imported). No code from `src/` is on that path; the
package is touched only to obtain the byte strings and the `apply` values being compared. Scratch:
`indep/{ref.jl,probe.jl,probe4.jl,newmut.jl,probes1.jl,probes2.jl,probes3.jl,probes4.jl}`.

**Lane check (law 1).** `git show --stat 1919aff` touches only `briefs/54…last.md`, `src/MIPStarLambda.jl`,
`src/samplers/{cl,typed}.jl`, `src/verifiers/ldt.jl`, `test/mutations/*`, `test/tb1_ld_sampler.jl`,
`test/tb2_answer_reduce.jl` — no `claims/`, no `docs/`. The DESIGN lockstep landed separately and *earlier*, at
`3bf4259`. No status was raised by the proposer; every claim edit is a MERGE PROPOSAL. Law 1 respected.

---

## 0. Adjudication of the brief-54 response table (TB1 rows)

| row | claimed | adjudicated | basis |
|---|---|---|---|
| **N12 MAJOR** (bytes not tied to the map) | FIXED | **ACCEPTED** | §1.1–§1.3. The judgment call "the encoder needed no change" is **correct**: my r3 NM7/NE1 were edits of an encoder that already wrote every matrix entry and every `ByAxis` table, and r3 N12 was an objection about the *tests*, not the format. My independent re-emitter reproduces all five byte strings **exactly**, and my independent evaluator reproduces `apply` on all `8^5` seeds from the bytes alone for all five described maps. `tb1_describe_matrix.jl` is NM7 verbatim and I observed it KILLED (29.0 s). Residues N24, N26 (new, narrower). |
| **N13 MAJOR** (`enu:cl-map-sum` has no red witness) | FIXED | **ACCEPTED** | `test/mutations/tb1_prefix_walk.jl` is my NM10 verbatim; I re-ran it myself on a copy and the **sole** failing assertion is `test/tb1_ld_sampler.jl:209 Expression: report.map_sum_ok`. `map_sum_ok` therefore owns a real semantic mutation, which is exactly the FIX DEMAND. The NM8 re-probe (disarm the comparison) still SURVIVES — my r3 demand explicitly said it would and required only the scope sentence; see §4 and the authorized C4a wording. |
| **N14 / G3** (`Marginal(L,0,z)`) | FIXED | **ACCEPTED** | `cl.jl:306` rejects `j` outside `1..ell`; `cl.jl:406` builds `prefix_1` as the explicit zero vector; `tb1:245-247` asserts `j=0` and `j=ell+1` for all three maps. I also verified the stronger fact the repair needs: `Factor(L,1,u)` admits **only** `u=0` (`_walk_prefix:353-356`), measured `ArgumentError` for the all-ones prefix on all three maps, so the zero prefix is pinned, not merely conventional. DESIGN §9.3 carries the sentence. |
| **N4 PARTIAL / N15(a)** (off-line repair unattached) | FIXED | **ACCEPTED** | `ld_sweep_evidence` (`verifiers/ldt.jl:262-278`) is a CHECKED `:ld_honest_sweep` node with `:ld_off_line_rejects` as its SOURCE_REPAIR child. I measured the replay wall at **1.51 s** — a genuine recount, not a re-read — and four independent tampers of the stored report (`off_line_hits=1`, `checked+1`, `equal_type=0`, `accepted=false`) are all rejected. |
| **N15(b)** (no claim row for `D^ld`) | proposal | **PARTIAL** | The C4c proposal exists and is well-formed, but it is **HELD**: its headline fact has no red witness (N23) and its `kappa` sentence is wrong. §5. |
| **N16** (empty-register pad) | FIXED | **PARTIAL** | The top-level empty-register rule and the in-chain terminal rule are both **correct** — I adjudicate the proposer's design decision in §1.4 and withdraw the "ambient in both cases" branch of my own r3 fix demand. But the repair special-cases only the *empty* register: `pad_level(CLZero(F,5,(2,)),2)` still yields `space_sum_ok = false`, and the suite now pins that value at `tb1:187-188` while `pad_level_evidence` on the same value returns a **failing** certificate. → **N25**. |
| **N17** (`Factor` reachability unowned) | FIXED | **ACCEPTED** | `tb1_factor_reachability.jl` registered, observed KILLED (19.3 s). |
| **N18** (TB2 sizes unpinned; `ByAxis` charging) | FIXED | **ACCEPTED** | TB1 `sizes == [75,132,156]` asserted at `tb1:295`; the five TB2 integers asserted in TB2's lane; DESIGN §9.3 now records the one-child-per-axis charging with the `ALine_6` 10228 vs `ALine_1` 2893 measurement. |
| **N19** (DESIGN lockstep) | orchestrator | **ACCEPTED** | Both landed at `3bf4259`, i.e. *before* the code commit: `DESIGN.md:1191` reads `(gt-04-cl.tex:L122-L130)` intact, and `:372` carries `(single factor space = all of V)`. |
| **N20** (walls) | NOTE | **ACCEPTED as NOTE, upgraded** | §3 and N27: my loaded run measured the TB0 body at **53.194 s**, 6.8 s under the hard gate. |
| **N21** (field guard doubly enforced) | FIXED | **ACCEPTED** | `tb1:122-128` pins the thrown message (`occursin("same field", …)`), so the guard, not the typed memo, is shown to be the rejecter. |
| **N22** (memo flushes, not evicts) | unchanged | **ACCEPTED as carried NOTE** | Correct-but-pessimal; LRU is `DL9` shape. Re-measured unchanged: `max_entries=1808`, `nodes=1809`, limit 4096. |
| cosmetic label collision | FIXED | **ACCEPTED** | `N3-space-sum`, `N5-pad-order`; `MUTATION_FILTER=N3` no longer selects two mutants. |

---

## 1. Independent recomputation (the six brief obligations)

### 1.1 `decode_cl` round trip on all 3 maps × `8^5` seeds — reproduced from the bytes by an independent evaluator

I did not check the package's round trip; I ran my own. `indep/ref.jl` parses the canonical bytes with its own
reader, re-emits them with its own writer, and evaluates the parsed term with its own `GF(8)`, its own `chi`, its
own `L^lnf` and its own `Const`/`ByAxis`/`Lnf`/`Padded` semantics:

```
INDEP field laws over all 512 triples: true
INDEP L_Point        bytes=75  header=(8,5,1) my_term_level=1 reemit==bytes? true apply-agrees-on-8^5? true
INDEP L_ALine        bytes=132 header=(8,5,2) my_term_level=2 reemit==bytes? true apply-agrees-on-8^5? true
INDEP L_DLine        bytes=156 header=(8,5,3) my_term_level=3 reemit==bytes? true apply-agrees-on-8^5? true
INDEP pad(L_ALine,3) bytes=137 header=(8,5,3) my_term_level=3 reemit==bytes? true apply-agrees-on-8^5? true
INDEP pad(CLZero5,2) bytes=93  header=(8,5,2) my_term_level=2 reemit==bytes? true apply-agrees-on-8^5? true
```

`163,840` seed comparisons, zero disagreements; the levels I compute from the term structure alone (`1+`the branch's
own level, `BranchLnf` contributing its point stage, `Padded` contributing `extra`) agree with the header. **The
bytes determine these maps**, and they determine them for a reader that has never seen `src/`. This is the fact
r3 N12 said was missing, and it is now real — not merely asserted.

### 1.2 The separator pair, built and serialized on the reference side

```
INDEP separator: my_L_Point_bytes==pkg? true  my_alt_bytes==pkg? true  sizes=(75,75)  distinct? true
INDEP apply(L_Point,z)=(3,5,0,0,0)  apply(alt,z)=(0,0,4,6,7)  differ? true
```

I built the `V_coord (+) V_dir` projector's term myself and emitted it myself; both 75-byte strings match the
package's byte for byte, they differ, and the maps differ on the suite's own trace seed. `tb1:325-335` is sound.

### 1.3 The stage-1 matrix byte window `41:65`

Hand-derived from the format: header `1+4+4+4 = 13`; `Step` tag `1` (→14); `seed_dim` `4` (→18); factor
`4+2·5 = 14` (→32); rest `4+0` (→36); entry count `4` (→40); so the 25 one-byte `GF(8)` entries occupy **41:65**,
then `Const` `1` + `Zero` `1+4+4` = 75. Measured:

```
INDEP separator differing byte positions = [41, 47, 53, 59, 65]      (the five diagonal entries)
INDEP L_Point[41:65] = 1 0 0 0 0 | 0 1 0 0 0 | 0 0 0 0 0 | 0 0 0 0 0 | 0 0 0 0 0
INDEP alt[41:65]     = 0 0 0 0 0 | 0 0 0 0 0 | 0 0 1 0 0 | 0 0 0 1 0 | 0 0 0 0 1
```

Exactly the window the test asserts, and the two maps differ **only** inside it. `tb1:336-342` is sound.

### 1.4 `pad_level`, the zero-map promotion, and the in-chain terminal rule — the design decision adjudicated

```
PKG pad(CLZero(F,5,Int[]),3)  factors=[[1,2,3,4,5],[],[]]  space_sum_ok=true  map_sum_ok=true
PKG pad(CLZero(F,5),3)        factors=[[1,2,3,4,5],[],[]]
PKG pad(L_ALine,3)            factors=[[3,4,5],[1,2],[]]   space_sum_ok=true   (all 8^5 seeds)
PKG pad(CLZero(F,5,(2,)),2)   factors=[[2],[]]             space_sum_ok=FALSE
PKG pad_level_evidence(CLZero(F,5),3)       children=[:zero_map_factor_partition] verify=true
PKG pad_level_evidence(L_ALine,3)           children=[]                           verify=true
PKG pad_level_evidence(CLZero(F,5,Int[]),3) children=[:zero_map_factor_partition] verify=true
PKG pad_level_evidence(CLZero(F,5,(2,)),2)  children=[:zero_map_factor_partition] verify=FALSE
```

**Adjudication of the DESIGN §9.4 rule the proposer wrote.** The in-chain terminal rule is **right and my r3 fix
demand's "ambient in both cases" branch was wrong**; I withdraw it. `rk:higher-level` promotes a zero map on *the
space it acts on*. A chain terminal reached after stages that already partition the ambient acts on the
zero-dimensional space `{0}`, whose all-ones indicator is the empty vector; promoting it on `1:n` would double-count
and destroy `enu:cl-space-sum` — measured directly: `pad(L_ALine,3)` keeps `[[3,4,5],[1,2],[]]` and passes on all
`8^5` seeds, whereas the ambient reading would give `[[3,4,5],[1,2],[1..5]]`. A **top-level** value, by contrast,
acts on all of `F^n`, so `CLZero(F,n,Int[])` at top level is the zero map on `F^n` and `V_1 = {1..n}` is correct.
The two rules are the same rule applied to two different spaces, and DESIGN §9.4/§1.5 now say so. **ACCEPTED as a
correct design decision.** What is *not* covered is the third case — a top-level zero map on a proper nonempty
sub-register — where `_pad_top` falls through to the continuation rule and produces an invalid sampler while its
own `pad_level_evidence` certificate fails. → **N25**.

### 1.5 The `map_sum_ok` red-capability probe (r3 NM8 re-run)

```
NEWMUTANT REG tb1_prefix_walk (registered)      TB1_TARGET=space_sum => KILLED (32.5 s)
      sole failing assertion: tb1_ld_sampler.jl:209  "Expression: report.map_sum_ok"
NEWMUTANT NM8-reprobe map_sum_never_compared    TB1_TARGET=all       => SURVIVED (65.0 s)
```

**Answer to the brief's question: no, NM8 is still not caught, and that is the authorized outcome.** The two facts
are different: `map_sum_ok` now *owns* a real semantic mutation (the prefix walk), which is what "red-capable"
means and what my r3 FIX DEMAND required; but deleting the comparison remains free because `enu:cl-map-sum` is
CONSTRUCTED by the datatype's disjoint registers and no value inside the invariants falsifies it — r3 said this in
so many words and asked only for the scope sentence. The C4a wording I authorize in §5 says both halves, because
"owned by `tb1_prefix_walk.jl`" alone reads as the stronger claim.

### 1.6 The `:ld_honest_sweep` CHECKED node, and the sweep's numbers recomputed

Support counts recomputed from my own evaluator (no `src/` on the path), per ordered type pair:

```
INDEP  Point -> Point 64, ALine 512, DLine 18432        (19,008)
INDEP  ALine -> Point 512, ALine 64, DLine 15296        (15,872)
INDEP  DLine -> Point 18432, ALine 15296, DLine 2752    (36,480)
INDEP  total distinct support decisions = 71,360   all nine nonempty
PKG    facts=(q=8,m=2,d=1,md=2,kappa=1,support_decisions=71360,non_noop=40768,
              equal_type=2880,line_vs_point=37888)
PKG    child=(SOURCE_REPAIR,:ld_off_line_rejects, honest_support_hits=0, of=71360)
PKG    verify_certificate=true (replay wall 1.51 s)
PKG    tampered off_line_hits=1 => false ; checked+1 => false ; equal_type=0 => false ; accepted=false => false
```

71,360 is mine, independently. The tamper the brief names is rejected, and so are three more I tried. `2,880` and
`37,888` are the r2 numbers, re-printed and now asserted at `tb1:582` and `tb1:603`. **No disagreement with the
report on any number in this rung.**

---

## 2. New objections

### N23 — **MAJOR** — the off-line counter can be disarmed for free: `off_line_hits = 0` and the `:ld_off_line_rejects` fact have no red witness

**Location.** `src/verifiers/ldt.jl:237` (`off_line_hits += result.location == :question`), read by
`ld_sweep_evidence:263` (`ld_off_line_repair(honest_support_hits=report.off_line_hits, …)`) and asserted at
`test/tb1_ld_sampler.jl:590` and `:600`. Against r2 N4's discharge (the SOURCE_REPAIR is justified *because* honest
play never reaches the branch), the proposed C4c row ("the off-line branch is reached 0 times"), and rk-light law 4.

**My independent computation.** Applied on a copy exactly as `run.jl` applies one (`mktempdir`, mutated file
`Base.include`d into the loaded module; the archived tree never modified):

```
NEWMUTANT NM11 off_line_counter_disarmed   ("off_line_hits += result.location == :question"
                                            -> "off_line_hits += false")
   TB1_TARGET=all  => SURVIVED (exit=0, 59.08 s)
CONTROL  equal_type_counter_disarmed       ("equal_type += result.rule == :ld_consistency" -> "+= false")
   TB1_TARGET=all  => KILLED (tb1:582, :583, :603, :605)
```

The control is the point: a **sibling counter in the same loop of the same function** is killed four times over by
the asserted `(2880, 37888)` split, so the harness is red-capable there — `off_line_hits` is the one counter with
nothing behind it. With NM11 applied, `@test report.off_line_hits == 0` (`:590`), the SOURCE_REPAIR fact
`honest_support_hits == 0` (`:600`), the `:ld_honest_sweep` replay and the tampered-report test all stay green
while the sweep has stopped counting. The off-line *branch* is exercised once, at `tb1:680-684`, but that test
asserts only `rule == :ld_axis_point && !passed(off_line)` — never `off_line.location == :question` — so nothing in
the corpus ties the `:question` marker to the branch either.

**FIX DEMAND.** (a) At `tb1:684` add `@test off_line.location == :question`, pinning the marker on the fixture that
already reaches the branch. (b) Register `test/mutations/tb1_off_line.jl`
(`Mutant("TB1 N4-off-line line_point_test_never_agrees", "src/verifiers/ldt.jl",
"(line_point(line, t) == point, t)", "(false, t)", "tb1_decider", "MUTATION_EXPECTED_RULE …")` — the dual of the
existing `tb1_online.jl`, whose target is `decider_rejections`) and show it KILLED by `report.off_line_hits == 0`:
under it every honest line-versus-point decision is judged off-line, so the counter must go positive. Equivalently,
run one extra `ld_honest_sweep` in the test on a deliberately off-line point fixture and assert `off_line_hits > 0`.

**SURVIVING WEAKER STATEMENT.** The off-line divergence is documented at the line where it happens with the source
range and the literal alternative; the sweep is a CHECKED node whose replay genuinely recounts (1.51 s) and rejects
four distinct report tampers; and on the unmutated tree `off_line_hits` is 0 of 71,360, a number I reproduce. What
is unwitnessed is that a nonzero count could ever be reported.

### N24 — **MINOR** — the description's matrix index order is unpinned: every stage matrix serialized at this rung is diagonal

**Location.** `src/samplers/cl.jl:459` (`_field_ints`), `:669-673` (`_term_to_cl`'s row-major reader), against
`test/tb1_ld_sampler.jl:307-345` and DESIGN §9.2's `description_size(X) = length(canonical_bytes(X.code))` /
intensional-hash purpose.

**My independent computation.**

```
NEWMUTANT NM12 field_ints_column_major   TB1_TARGET=all       => SURVIVED (60.1 s)
NEWMUTANT NM12 field_ints_column_major   TB2_TARGET=describe  => SURVIVED (18.4 s)
INDEP serialized matrices: L_Point 1, L_ALine 3, L_DLine 3, pad(L_ALine,3) 3, pad(CLZero5,2) 2
      all symmetric? true    all diagonal? true      (all five maps)
```

I graded this **MINOR, not MAJOR, deliberately** (law 5): I checked and the mutation is provably a *no-op on this
rung's objects* — `_projector_matrix`, `first_matrix`, `L_lnf(e_i)`, `pi_{i-1}` and the identities are all diagonal,
so transposing the encoder changes no described map and C4a's new positive sentence stays true. What it shows is a
coverage hole, not a false claim. It is nevertheless load-bearing forward: DESIGN §11.2/C14 explicitly *require* "a
nonsymmetric stage map" at `TB6b-M`, at which point a transposed serializer silently describes the wrong linear map.

**FIX DEMAND.** Assert one off-diagonal entry's position: build a one-stage map with a non-symmetric `2x2` matrix
(e.g. `[1 1; 0 1]` on `{1,2}`), assert its bytes at the two off-diagonal offsets and that its bytes differ from its
transpose's, and register `test/mutations/tb1_describe_transpose.jl` (`_field_ints` with `r`/`c` loops swapped,
target `tb1_describe`) KILLED.

**SURVIVING WEAKER STATEMENT.** The encoder does write every matrix entry, and the described bytes determine the
map for all 21 maps of TB1 and TB2 — verified by my own parser+evaluator at TB1. Only the row-versus-column
convention is untested, and it is untestable on a fixture whose every matrix is diagonal.

### N25 — **MINOR** — `pad_level` of a top-level zero map on a proper sub-register yields a value failing `enu:cl-space-sum`, and the suite pins it while its own certificate fails

**Location.** `src/samplers/typed.jl:31-33` (`_pad_top` special-cases only `isempty(L.indices)`),
`test/tb1_ld_sampler.jl:187-188`. Against `docs/DESIGN.md:1183-1186` (§9.4: stage 1 of a promoted zero map "reports
the all-ones indicator for its entire ambient space") and §9.2 (the two `lem:cl-kth` obligations are "part of
sampler validity under `def:sampler`, not optional").

**My independent computation.** `pad_level(CLZero(F,5,(2,)),2)` → factors `[[2],[]]`, `space_sum_ok = FALSE`, while
`pad_level_evidence(CLZero(F,5,(2,)),2)` builds the `:zero_map_factor_partition` child and then **fails**
(`verify=false`). So the round's two artefacts disagree: `tb1:187-188` records the factor spaces as the intended
answer, and the certificate the same round introduced says the value is not a valid sampler. `pad_level` is called
on top-level maps by `TypedSampler` (`typed.jl:132-134`); DESIGN §9.4 names `typed_anchor_sampler`, the Pauli
sampler, `tilde S^intro` and `detype_sampler`'s zero opposite-edge child as the constructors that originate zero
maps, so the case is reachable at TB5/TB6, not hypothetical. (This narrows my r3 N16, whose surviving statement —
"for every zero map on a nonempty register `pad_level` … passes the replay" — was itself too generous: I had tested
only the full register.)

**FIX DEMAND.** Decide the top-level rule for a proper sub-register: either `_pad_top` promotes **any** top-level
zero map on the ambient `{1..n}` (drop the `isempty` test, keep `_pad_tail`'s register rule for continuations), or
`pad_level` throws for a top-level zero map whose `register_indices` is neither `()` nor `Tuple(1:n)`. Then replace
`tb1:187-188` by an assertion of the chosen behaviour **plus** `passed(verify_certificate(pad_level_evidence(…)))`
(or `@test_throws ArgumentError`), and say which in DESIGN §9.4.

**SURVIVING WEAKER STATEMENT.** For the empty and the full top-level register, and for every in-chain terminal,
`pad_level` implements DESIGN §9.4 and the padded value passes both `lem:cl-kth` replays — verified on all `8^5`
seeds for `pad(L_ALine,3)` and on the certificate for `pad(CLZero(F,5,·),3)`.

### N26 — **MINOR** — a `CLZero`'s register is written into the bytes but never asserted, so `decode_cl` is not shown to be a left inverse on zero components

**Location.** `src/samplers/cl.jl:462` (`_describe_term(L::CLZero)`), `test/tb1_ld_sampler.jl:307-318`.

**My independent computation.**

```
NEWMUTANT NM13 zero_term_drops_register   TB1_TARGET=all      => SURVIVED (54.2 s)
NEWMUTANT NM13 zero_term_drops_register   TB2_TARGET=describe => SURVIVED (14.7 s)
PKG (unmutated) describe/decode: (1,2,3,4,5) 32 bytes, () 22 bytes, (2,) 24 bytes — register preserved in all three
```

Every terminal of every TB1 and TB2 map is on the *empty* register (the factors partition the ambient), so erasing
the register byte is invisible to both rungs' round trips. Unmutated, the register *is* in the bytes and *is*
recovered — the gap is purely that nothing says so, and it stops being invisible the moment a zero component sits
on a proper sub-register, which is exactly the shape §9.4's four named originators produce.

**FIX DEMAND.** One line in `describe`: `@test register_indices(decode_cl(canonical_bytes(describe_cl(CLZero(TB1_F,5,(2,)))))) == (2,)`
and `canonical_bytes(describe_cl(CLZero(TB1_F,5))) != canonical_bytes(describe_cl(CLZero(TB1_F,5,Int[])))`;
register `test/mutations/tb1_describe_zero_register.jl` (the NM13 edit, target `tb1_describe`) KILLED.

**SURVIVING WEAKER STATEMENT.** `decode_cl` *is* a left inverse of `describe_cl` on all 21 maps and on the three
bare `CLZero` registers I tried, including the register; no test exercises it.

### N27 — **NOTE** — the TB0 test body came within 6.8 s of the hard gate on a shared box

My two runs of the identical archived tree: **53.194 s** (RUN1, box carrying the concurrent TB2 critic) and
**41.521 s** (RUN2, quieter), against the proposer's 39.056 s quiet / 44.113 s loaded. The 45 s warning fired once.
The gate is `60 s` and the rung passed both times, but the spread on this box is now 12 s and the suite grew
499 → 638 tests this round. Worth one line in the TB3 brief: the gate is a *test-body* budget that the TB1/TB2
lanes keep charging.

### N28 — **NOTE** — the `:ld_honest_sweep` report is invariant under the honest polynomial

`Checked(merge(ev.term, (g = g + 1,)), ev.certificate)` still verifies. That is correct — every count in the report
is a function of the question supports and the guard dispatch, and `accepted` holds for any `g` within the `d`/`md`
bounds — but it means the node certifies the decider's *dispatch* on one degree profile, not the low-degree content.
C4c's "one polynomial, one field row" scope already says this; keep it there.

---

## 3. Test and mutation runs observed (archived copy, Julia 1.12.5)

`julia --project=. test/runtests.jl` — **exit 0, 638/638**, twice:

| run | load at start | `MIPStarLambda load/precompile` | TB0 test-body wall | suite wall | maxrss | exit |
|---|---|---|---|---|---|---|
| RUN1 (loaded) | `2,69 3,01 3,40` → 8+ | 0.339 s | **53.194 s** (warning 45, gate 60) | 2m54.6 | 1187 MiB | 0 |
| RUN2 (quieter) | `4,68 8,13 6,97` → `2,72` | 0.34 s | **41.521 s** | 2m24.5 | 1182 MiB | 0 |

```
Test Summary:                                                    | Pass  Total     Time
MIPStarLambda                                                    |  638    638  2m22.8s
  TB0 60 s test-body hard limit (measured 41.521 s)              |    1      1
  TB1 datatype levels                                            |   37     37    (26 -> 37)
  TB1 lem:cl-kth enu:cl-space-sum / enu:cl-map-sum replay        |   22     22
  TB1 def:sampler queries Dimension/Marginal/Linear/Factor       |   27     27    (23 -> 27)
  TB1 DESIGN 9.3 describability (QuotedBranch)                   |   33     33    (22 -> 33)
  TB1 D^ld honest deterministic sweep and consistency            |   17     17    (12 -> 17)
  … 12 further TB1 testsets unchanged …
MUTATION_EXPECTED_RULE describe_roundtrip ok=true separator_bytes_differ=true
TB1 describe: description_size L_Point/L_ALine/L_DLine=[75, 132, 156] … decode round trip on 3x8^5 seeds
    + 2 padded maps; separator L_Point vs V_coord(+)V_dir projector (75 bytes both)
TB1 lem:cl-kth replay: distinct_chains=[1, 8, 288] completed_replays=[32768, 32768, 32768]
    map_sum_checks=[32768, 65536, 98304] negative_witness_space_sum_ok=false
TB1 D^ld: support_decisions=71360 non_noop=40768 (equal-type 2880, line_vs_point 37888) off_line_hits=0
```

`julia --project=. test/mutations/run.jl` — **exit 0**, box load 7.5–9.2 (the TB2 critic ran its own registry
concurrently):

```
package image ready after 0.52 s
MUTATION REGISTRY: killed=69/69 baselines ok=37/37 wall=860.25 s     (proposer, quieter box: 555.67 s)
real 14m21.1
```

All **30** TB1 mutants KILLED with passing baselines, including this round's four arrivals/re-anchorings:

```
MUTANT TB1 M9-describe-matrix description_ignores_stage_matrices  target=tb1_describe => KILLED (28.97 s)
MUTANT TB1 M9-prefix-walk walk_ignores_the_prefix                 target=tb1_space_sum => KILLED (29.97 s)
MUTANT TB1 M9-factor-unreachable-accepted                         target=tb1_queries  => KILLED (19.25 s)
MUTANT TB1 N5-pad-order pad_level_prepends_empty_stages           target=tb1_levels   => KILLED (23.14 s)
```

No FATAL: suite green twice, runner green, every registered mutant killed with a passing baseline, no status raised
by the proposer, and the label collision is gone.

## 4. My new mutations

Applied on copies only (`mktempdir`; the mutated file written to the sandbox and `Base.include`d into the loaded
module; the archived tree never modified). Runner: `indep/newmut.jl`.

| id | file:site | semantic change | target | outcome |
|---|---|---|---|---|
| **NM11** | `verifiers/ldt.jl:237` | the honest sweep stops counting off-line decisions | TB1 all | **SURVIVED** → N23 (MAJOR) |
| **NM12** | `cl.jl:459` | stage matrices serialized column-major (transposed) | TB1 all | **SURVIVED** → N24 |
| NM12 | same | same | TB2 `describe` | **SURVIVED** → N24 |
| **NM13** | `cl.jl:462` | a `CLZero` term drops its register | TB1 all | **SURVIVED** → N26 |
| NM13 | same | same | TB2 `describe` | **SURVIVED** → N26 |
| NM8-reprobe | `cl.jl:422` | `map_sum_ok &= … == running` → `&= true` | TB1 all | SURVIVED (expected; §1.5) |
| CONTROL | `verifiers/ldt.jl:236` | the sibling `equal_type` counter disarmed | TB1 all | KILLED (`tb1:582,583,603,605`) |
| CONTROL | `typed.jl:32-33` | `_pad_top`'s new empty-register rule removed | TB1 all | KILLED (`tb1:180,182,183`) |
| replication | `cl.jl:345` | the registered `tb1_prefix_walk` edit | TB1 `space_sum` | KILLED — sole failure `tb1:209 report.map_sum_ok` |

The two controls are what make N23 and the ACCEPTs above sharp: counters in that exact loop and the pad rule in that
exact function *are* killable, so the three survivors are gaps in coverage, not artefacts of the harness.

## 5. Per-claim decision

| claim | decision | note |
|---|---|---|
| **C4a** | **RE-AFFIRM at TESTED**, replacing the row with the authorized text below | every number in the row independently reproduced, and this round's new positive content — that the canonical bytes determine the map — I verified with my own parser, evaluator and re-emitter on all `8^5` seeds rather than through the package's `decode_cl`. Status may not rise further; the row records N24, N25 and N26 as scope. |
| **C4c** | **HOLD** (not created at TESTED this round) | the missing step is N23: the row's headline negative fact (`off_line_hits = 0` of 71,360, which is what discharges the `:ld_off_line_rejects` SOURCE_REPAIR) has no red witness — the counter can be replaced by a constant and the whole suite, the CHECKED replay and the tamper test stay green. One assertion (`off_line.location == :question` at `tb1:684`) plus one registered mutant (`tb1_off_line.jl`, §N23) closes it; the exact row text I will authorize is below, so the next round is mechanical. The proposer's proposed text also mis-states `kappa`: the sweep runs at `kappa=1` and the `kappa=2` content is three separate `decider_rejections` fixtures. |
| **C4b** | defer to `verdicts/tb2-r4.md` | brief 58's lane. TB1-relevant residue only: C4b's "padded to the common level 3 by appending empty stages … so every marginal of the child survives" is true of the tree and is now carried by a CHECKED `pad_level_evidence` node (`typed.jl:79-90`), whose failing case is N25. |
| **C9** | defer to `verdicts/tb2-r4.md` | TB2's lane; N15(b)'s alternative (extend C9 instead of opening C4c) is superseded by the C4c proposal. |
| **C7** | HOLD at CONJECTURE | `depends-on = C4a,C4b` remains correct; no TB1 evidence bears on it. |
| C1–C3, C5, C6, C8, C12–C19 | unchanged | outside this rung's lane. |

**C4a — AUTHORIZED VERBATIM ROW** (copy exactly; only surrounding table scaffolding may be adapted). It is the
current row with the body unchanged and the **Scope** sentence replaced:

> | C4a | (Sampler is CL — TB1 instance) For `(q,m,d)=(8,2,1)` and ambient `V=V_pt (+) V_coord (+) V_dir` of `seed_dim` 5, `L_Point`, `L_ALine` and `L_DLine` are CL functions of constructed nesting depth 1, 2 and 3 respectively — upper bounds in the sense of `rk:higher-level`, not minimality claims — built only from `CLStep` stages whose factor and rest registers are disjoint coordinate-index sets partitioning that stage's own register, with lazily evaluated continuations validated (field, seed dimension, rest register, child level) on every key reached by the exhaustive enumeration; each map's `level` factor registers are pairwise disjoint and their union is all of `{1,...,5}` on every one of the `8^5` seeds (`lem:cl-kth` `enu:cl-space-sum`), namely all of `V` for `L_Point`, `{3,4,5},{1,2}` for `L_ALine` and `{3},{4,5},{1,2}` for `L_DLine`, matching the concatenation sentences of `gt-07-ldt.tex:203-237`, with 1, 8 and 288 distinct branch chains; `apply` equals the sum of the first `level` stage outputs on all `3 x 8^5 = 98,304` marginal replays (`lem:cl-kth` `enu:cl-map-sum`), and the same telescoping replayed through `def:sampler`'s `Marginal`/`Factor`/`Linear` queries reports agreement on all `32,768 + 65,536 + 98,304 = 196,608` k-checks, with `Factor` accepting exactly the reachable prefixes `u` in `L_{<j}(V)` and `Linear` the broader `u` in `V_{<j}` (measured 8 and 512 at `j=2` for `L_ALine`, `gt-04-cl.tex:588-594`); all three maps are describable from `QuotedBranch` continuations with `description_size` 75, 132 and 156 bytes, reproduced by independent reserialization, while an opaque host branch and every `direct_sum`/`concatenate` output are `NotDescribable`; and over all `8^5 = 32,768` seeds the induced distributions `mu_{L_ALine,L_Point}` and `mu_{L_DLine,L_Point}` have exact histograms of support 512 and 18,432 (mass 32,768 each; 512 zero-direction support points carrying 2,304 seeds) agreeing entry-for-entry with a separately transcribed evaluation of `eq:cl-ptf`/`eq:cl-alnf`/`eq:cl-dlnf` **including `eq:chi-func`** — the comparison is NOT `chi`-independent (`verdicts/tb1-r1.md` O1) — and on the 512 zero-direction points the equality additionally rests on the DESIGN `SOURCE_REPAIR` `L^lnf_0 = id`, which `def:cl-canonical` does not define (O3), emitted as a `SOURCE_REPAIR` `CertNode` under the CHECKED histogram node. The separately asserted `chi`-free content of `lem:alnf`/`lem:dlnf` is the marginal support 128 (all masses 256) and 4,096 (masses 4 and 36). The canonical bytes determine these maps: `decode_cl` round-trips `L_Point`, `L_ALine`, `L_DLine` and two padded maps on all `8^5` seeds, `L_Point` and the `V_coord (+) V_dir` projector are 75 bytes each with distinct bytes, and the stage-1 matrix occupies bytes `41:65` — all four reproduced in `verdicts/tb1-r4.md` §1.1-§1.3 by an independent parser, evaluator and re-emitter written from the byte-format contract and `gt-07-ldt.tex` alone. **Scope:** `enu:cl-map-sum` is CONSTRUCTED by the datatype's disjoint registers, so the four-query replay tests the query compiler rather than the value; its map-sum comparison is the sole owner of `tb1_prefix_walk.jl` (`verdicts/tb1-r3.md` N13), while disarming the comparison itself remains free, no value inside the datatype's invariants falsifying the map sum (`verdicts/tb1-r4.md` §1.5). The bytes are not yet checked to carry the matrix index order — every stage matrix serialized at this rung is diagonal, so a transposed encoder changes no described map and no test notices (ibid. N24) — nor a `CLZero`'s register (ibid. N26). `Marginal` rejects `j=0` and `j=ell+1` like `Factor`/`Linear`, and `Factor(L,1,u)` admits only `u=0` (ibid. N14 discharged). `pad_level` of a top-level zero map declared on a proper sub-register produces a level-`ell` value whose factor registers do not cover the ambient, and whose own `pad_level_evidence` certificate fails (ibid. N25). No claim is made here about `D^ld` (that is C4c), about `concatenate`/`direct_sum`/`product`/`TypedSampler`, or about any other `(q,m)`. | TESTED | D2 | — | `test/tb1_ld_sampler.jl` (`levels`, `space_sum`, `queries`, `describe`, `memo`, `chi`, `chifree`, `pi_separator`, `lnf_separator`, `histogram_axis`, `histogram_diagonal`, `marginals`); red: `test/mutations/tb1_{chi,pi,lnf,level,repair,ambient,ambient_doblock,child_validation,dsum,concat,space_sum,pad_order,chifree,describe_closure,describe_matrix,factor_indicator,factor_reachability,linear_narrowed,prefix_walk,replay_skips_k,replay_skips_union,memo_unbounded}.jl` | `verdicts/tb1-r1.md`, `verdicts/tb1-r2.md`, `verdicts/tb1-r3.md`, `verdicts/tb1-r4.md` |

**C4c — HELD.** Missing step: N23's assertion + registered mutant. When they land and a verdict observes the mutant
KILLED, this is the row text I authorize — the proposer's proposal with `kappa` corrected, the sweep's certificate
named, and the two scope sentences added:

> | C4c | (TB1 `D^ld`, `(q,m,d)=(8,2,1)` at `kappa=1`) `ld_decider` implements `fig:ld-decider` with answer bounds `d=1` (axis) and `md=2` (diagonal, tight: `verdicts/tb1-r3.md` §1.4), symmetrized over the pair order. Over all `8^5` seeds the honest prover for `g = 1 + x1 + x1 x2` is accepted on all 71,360 distinct support decisions of the nine ordered type pairs (per pair: 64/512/18,432; 512/64/15,296; 18,432/15,296/2,752 — recomputed independently in `verdicts/tb1-r4.md` §1.6); 40,768 are non-noop, split 2,880 equal-type tautologies / 37,888 line-versus-point; the off-line branch is reached 0 times. The sweep is a CHECKED `:ld_honest_sweep` node (`ld_sweep_evidence`) whose replay re-runs it from `(params, g, samplers, seeds)` and rejects a tampered report, carrying `SOURCE_REPAIR :ld_off_line_rejects` (`gt-07-ldt.tex:377-384` accepts vacuously when no `t` exists; the executable rejects, strictly stricter). Separately, at `kappa=2` the `for all j in 1..kappa` loops and the answer arity are exercised by three fixtures (accept, second-entry cheat at `location==2`, short answer `:ld_answer_arity`). **Scope:** one polynomial, one field row, no soundness claim; the sweep's counts are functions of the question supports and the guard dispatch and do not depend on the honest polynomial's identity (`verdicts/tb1-r4.md` N28); equal-type decisions are identical-question tautologies (`verdicts/tb1-r2.md` N11). | TESTED | D2, C4a | — | `test/tb1_ld_sampler.jl` (`decider`, `decider_rejections`, `degree`, `restrictions`, `trace`); red: `test/mutations/tb1_{deg,agreement,symmetry,verifier_pi,online,off_line,question_arity,kappa,dline_degree}.jl` | `verdicts/tb1-r1.md`..`verdicts/tb1-r4.md` |

**Lockstep follow-ups for the orchestrator** (not TB1's lane): DESIGN §9.4 should say which of the two branches of
N25 was chosen once it is decided; §9.3's byte-format paragraph should state the matrix index order (row-major)
explicitly, since C14 requires a nonsymmetric stage map at TB6b-M.

## 6. Forward look — NOTEs for brief 39 (TB5 `SamplerDescription` / description-level `direct_sum`)

- **NOTE 1 (byte format).** `SamplerDescription.code` must keep the exact format `decode_cl` now inverts (magic `0xC1`; `q`, `seed_dim`, `level` as 4-byte big-endian; tags `Zero 0x00`, `Step 0x01`, `Const 0x10`, `ByAxis 0x11`, `Lnf 0x12`, `Padded 0x13`; field entries `ceil(log2 q / 8)` big-endian bytes, matrix **row-major**) — and must pin row-major with an off-diagonal witness before TB6b-M's nonsymmetric stage map exists (N24).
- **NOTE 2 (zero components).** `direct_sum` embeds zero maps on *proper sub-registers* — §9.4's four named originators — which is exactly where `describe_cl`'s unasserted `CLZero` register (N26) and `_pad_top`'s undefined sub-register rule (N25) both become live; decide the promotion rule and assert the register byte *before* the combinator is written.
- **NOTE 3 (hashing).** Injectivity is now real but scoped: bytes determine the map on the `QuotedBranch` algebra, verified independently. §10.3's "identical canonical `S^rep` hashes, never `hash(D)`" needs the pair adapter `describe_cl(LA,LB,q)` to be a pure function of the two child byte strings and `q`, so that `direct_sum`'s bytes are computable from children's bytes without re-walking the CL IR.
- **NOTE 4 (dependency sets).** §9.2 wants dependency sets "computed by a syntax walk over quoted child identifiers and replayed against the bytes"; the term AST already exposes child terms, so the walk is cheap — but `BranchByAxis` is charged one full child term per axis (`ALine_6` 10228 vs `ALine_1` 2893), so §9.2's "a compact loop is not charged as `k` copies" is *not* yet honoured and `k(n)`-fold `repeat_sampler` will blow the size law linearly.
- **NOTE 5 (validity children).** Every §9.4 constructor must return a sampler-validity child replaying both `lem:cl-kth` obligations; `pad_level_evidence` (`typed.jl:79-90`) is the ready-made shape — CHECKED root, recount replay, `ZERO_MAP_FACTOR_PARTITION` child exactly when the promotion ran — and it already *fails* on the malformed sub-register case, so wire it in rather than re-inventing it.
- **NOTE 6 (query surface).** `Marginal`/`Factor`/`Linear` now share the `1<=j<=ell` domain and `Factor(L,1,·)` admits only the zero prefix, so the §9.2 replay is portable to a `SamplerDescription` unchanged; keep `cl_kth_replay`'s caller-supplied zero prefix when the adapter maps `ArgumentError` to `QueryError`.

---

**What this round got right, for the record.** Both r3 MAJORs are genuinely discharged, and the harder one is
discharged in the strongest available form: not a byte-length assertion but a deserializer, and I confirmed it by
writing a second, independent one — my own parser, my own `GF(8)`, my own `chi` and `L^lnf`, my own evaluator —
which reproduces all five byte strings exactly and `apply` on all `163,840` seed comparisons. The separator pair,
the `41:65` window and the 71,360 support decisions are mine too. `tb1_prefix_walk` is killed by exactly the
assertion it was demanded to arm. The `:ld_honest_sweep` node is a real recount (1.51 s) that rejects four distinct
report tampers, and `pad_level_evidence` is a real certificate that even fails on the one malformed input I found.
And the in-chain-terminal design decision the proposer flagged is right where my own r3 fix demand was wrong — I
withdraw that branch of it. 69/69 mutants killed, 37/37 baselines, 638/638 twice. The one MAJOR below is a counter
nobody can make go up, in a function whose sibling counter I killed on the first try; it is one assertion and one
registered mutant from closed, and it is the only thing standing between C4c and TESTED.

VERDICT: FAIL(N23)
