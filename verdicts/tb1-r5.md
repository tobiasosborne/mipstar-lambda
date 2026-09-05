# CRITIC verdict r5 — rung TB1 (`src/samplers/{cl,typed,ldt}.jl`, `src/verifiers/ldt.jl`, `test/tb1_ld_sampler.jl`, `test/mutations/tb1_*.jl`) at commit `3f2d1f1`

Round 5 (adjudicate; intended as the closing round). **Prior.** `verdicts/tb1-r4.md` (FAIL(N23); N24–N26 MINOR,
N27–N28 NOTE; C4a RE-AFFIRM with an authorized row; C4c HELD with a pre-written row) is the work order, together
with `briefs/59-tb1-tb2-repair-r4.md` and its response table `briefs/59-tb1-tb2-repair-r4.last.md`. Everything
r1–r4 accepted is settled and is not re-litigated. Every r4 row is adjudicated in §0; the objections in §2 are all
new, and all of them are on code paths no earlier round probed.

**Isolation.** `git archive 3f2d1f1 | tar -x -C <scratch>/tree` into
`/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-…/scratchpad/critic-tb1-r5/tree`, `Pkg.instantiate()`
+ `Pkg.precompile()` there, and every test, mutation and experiment run there. The live working tree was never
read or run for `src/`/`test/`; `docs/`, `briefs/`, `ground-truth/` were read from the **archived** copy and every
`file:line` below is that copy, except where §2 N32 explicitly reports on the *live* `docs/DESIGN.md` (a lockstep
audit the orchestrator asked for, and outside the worker's lane). `claims/CLAIMS.md` was read live
(orchestrator-owned). My only repo output is this file. No state-changing git command was run.

**Machine note (the timing caveat in brief 61).** This session straddled a reboot. Before it the box ran at
802–1151 MHz (`scaling_governor=powersave`, `energy_performance_preference` not yet raised) under desktop load
3–9; after it at 4801 MHz (`intel_pstate` active, `energy_performance_preference=performance`) with load < 1 at
start. Both sets of walls are reported in §3, each with the `uptime` load at which it was taken. The pre-reboot
figures were taken on the same archived tree and reproduce the post-reboot conclusions exactly; only the walls
differ. See N33: on my measurements the TB0 gate is **not** structurally marginal at 907 assertions, and r4's own
N27 mis-stated why.

**Independence.** §1's numbers come from code written from the byte-format contract, `gt-04-cl.tex` and
`gt-07-ldt.tex` alone (`indep/{probe1,probe2,probe3,newmut}.jl`): my own big-endian emitter for the canonical
bytes (header, tags, index and field-entry widths hand-derived), my own solve for the line parameter `t`, my own
on-line predicate, and my own recount of the nine ordered type pairs. No `src/` code is on those paths; the
package is touched only to obtain the byte strings, the sampler outputs and the `apply`/decider values being
compared.

**Lane check (law 1).** `git show --stat 3f2d1f1` touches `briefs/59-…last.md`, `src/samplers/{cl,typed}.jl`,
`test/mutations/run.jl`, five new `test/mutations/tb1_*.jl`, two new `test/mutations/tb2_*.jl`,
`test/tb1_ld_sampler.jl`, `test/tb2_answer_reduce.jl` — **no `claims/`, no `docs/`**. No status was raised by the
proposer; every claim edit is a MERGE PROPOSAL in `briefs/59-…last.md`. Law 1 respected. The DESIGN lockstep the
proposer proposed has **not** landed anywhere (N32).

---

## 0. Adjudication of the brief-59 response table (TB1 rows)

| row | claimed | adjudicated | basis |
|---|---|---|---|
| **N23 MAJOR** (`off_line_hits` has no red witness) | FIXED | **ACCEPTED** | Both halves of my r4 FIX DEMAND landed and both are real. (a) `test/tb1_ld_sampler.jl:748-750` asserts `off_line.location == :question` **and** `off_line.expected == :point_on_line` on the fixture that reaches the branch; I re-derived that fixture from `fig:ld-decider` myself (§1.4) — `chi(0,2)=1`, line `base=(0,5)`, `direction=e_1`, `t=3`, `line_point(line,3)=(3,5) != (3,6)`, and the two answers **agree** at `t`, so the on-line test is the only thing that can reject it. (b) `test/mutations/tb1_off_line.jl` is my NM11 dual verbatim (`(line_point(line,t)==point,t)` → `(false,t)`, target `tb1_decider`), and I observed it **KILLED (7.34 s)** in the registry, with the registered evidence line `MUTATION_EXPECTED_RULE off_line reached=true` — i.e. the kill is credited only when the counter actually goes positive, not merely when the suite reddens. The *fact* `off_line_hits = 0` is now red-capable. Residue, exactly as r4 predicted for the analogous NM8 case: the *counter expression* can still be replaced by the constant `false` and everything stays green (NM11 re-probed, **SURVIVED**, §4), because the honest value is 0; that is carried as a scope clause in the C4c row below, not as an objection. |
| **N24 MINOR** (matrix index order unpinned) | FIXED | **ACCEPTED** | `tb1:358-379` builds the nonsymmetric `[1 1; 0 1]` on `{1,2}` and pins bytes `35:38 == [1,1,0,1]` against the transpose's `[1,0,1,1]`. I re-derived the window by hand from the format — header `1+4+4+4=13`; `Step` tag (→14); `seed_dim` 4 (→18); factor `4+2·2=8` (→26); rest `4+0` (→30); entry count 4 (→34); four one-byte `GF(8)` entries at **35:38**; `Const` 1 + `Zero` 9 = 48 total — and my own emitter reproduces **both** 48-byte strings exactly (§1.1). The only differing byte positions are `[36,37]`, both inside the window, so "the bytes differ only there" is true as asserted (`tb1:376`). `tb1_describe_transpose.jl` is my NM12 verbatim, observed **KILLED (10.23 s)**. The repair also armed the *decoder* side, which I did not demand: my new NM14 (transpose `_term_to_cl`'s matrix reconstruction) is **KILLED**, and the sole failing assertions are `tb1:377` and `:378`. |
| **N25 MINOR** (`_pad_top` on a proper sub-register) | DECIDED: throw | **ACCEPTED as a correct design decision**, with a residue (N30) | The decision is inside the set my r4 FIX DEMAND authorized ("either promote on the ambient … or throw"). Adjudicated against `rk:higher-level` and DESIGN §9.4 in §1.2: at top level `rk:higher-level` sets `V_1 = V`, the space the value acts on, which for a top-level sampler is all of `F^n`; a declaration of a proper nonempty sub-register is therefore inconsistent with the value's own domain, and DESIGN §9.4 lists the originators of zero maps as *exactly* four **whole-space** constructors. Refusing is strictly better than the r4 behaviour, which silently produced a level-`ell` value failing `enu:cl-space-sum` while its own certificate said so. Verified: `pad_level(CLZero(F,5,(2,)),2)` throws `ArgumentError`; `extra==0` is the identity (`register_indices(pad_level(CLZero(F,5,(2,)),0)) == (2,)`); the empty and full top-level rules and the in-chain `_pad_tail` rule are unchanged (`pad(CLZero(F,5),2)` and `pad(CLZero(F,5,Int[]),2)` both give factors `[[1,2,3,4,5],[]]`). `tb1_pad_subregister.jl` observed **KILLED (12.27 s)**; the `tb1:105` level-1-on-`{2}` fixture was correctly rebuilt through the in-chain `_pad_tail`, which exercises the same continuation guard. **Residue:** the throw is not closed under `direct_sum` — see N30. |
| **N26 MINOR** (`CLZero` register never asserted) | FIXED | **ACCEPTED** | `tb1:382-392`. Independently reproduced (§1.1): my own emitter gives 24 / 32 / 22 bytes for the `(2,)`, full and empty registers, byte-for-byte equal to the package's, all three distinct, and `decode_cl` returns `(2,)`, `(1,2,3,4,5)`, `()`. `tb1_describe_zero_register.jl` is my NM13 verbatim, observed **KILLED (15.19 s)**. |
| **TB2 N26** (`decode_cl` re-imposes `factor ⊎ rest = {1..n}`) — landed in TB1's lane | FIXED | **ACCEPTED** | `src/samplers/cl.jl:683-687`, asserted at `tb1:394-405`. Reproduced: a top stage spanning only `{1,2}` of `F^5`, buildable only through the internal `_clstep(…; require_ambient=false)`, describes fine and is refused by `decode_cl` with `ArgumentError`; `tb1_decode_ambient.jl` observed **KILLED (13.54 s)**. Note the deliberate exemption `L isa CLZero` — needed so that all three `CLZero` register spellings still round-trip — which is why the guard does not make a decoded value automatically `pad_level`-able; that asymmetry is folded into the C4a scope. |
| **N27 NOTE** (TB0 wall) | NOTE | **ACCEPTED as NOTE, but my own r4 framing was WRONG** | See N33. `test/runtests.jl:10-20` starts the clock before `include("tb0_core.jl")` and stops it immediately after, *before* TB1/TB2/TB3 are included. The gate therefore charges **only `tb0_core.jl` — 146 of the suite's 907 assertions**; the TB1/TB2/TB3 lanes do not charge it at all, contrary to r4 N27's "a test-body budget that the TB1/TB2 lanes keep charging". The proposer's response ("the TB3 brief should carry the budget line") inherits that error. |
| **N28 NOTE** (sweep invariant under the honest polynomial) | kept as C4c scope | **ACCEPTED** | Unchanged; the C4c row below still carries it. |
| MERGE PROPOSALS (C4a strike/replace, C4c verbatim, DESIGN §9.3/§9.4) | orchestrator | **PARTIAL** | The C4a text is adjudicated and re-authorized in §5 (with two clauses added for N30/N31). The C4c proposal is **not** applied — see §5 and N29. The DESIGN lockstep has landed nowhere: **N32**. |

---

## 1. Independent recomputation (the five brief obligations)

### 1.1 The canonical bytes: row-major window, `CLZero` registers, ambient re-imposition

My own emitter (`indep/probe1.jl`; header `0xC1`, `q`/`seed_dim`/`level` as 4-byte big-endian, tags
`Zero 0x00 / Step 0x01 / Const 0x10`, index counts 4 bytes + `UInt16` entries, `GF(8)` entries one byte each),
written from the format contract without reading `describe_cl`:

```
P1 len=48 mine==pkg? true  transpose mine==pkg? true
P1 hand-derived window 35:38 ; pkg[35:38]=[1, 1, 0, 1] pkg_t[35:38]=[1, 0, 1, 1] differing positions=[36, 37]
P1 apply(shear,(3,5))=(6,5)  apply(shear^T,(3,5))=(3,6)  row-major reading y=(x1+x2,x2)? true
P2 sub(2,) len=24 mine==pkg? true decode register=(2,)
P2 full    len=32 mine==pkg? true decode register=(1, 2, 3, 4, 5)
P2 empty   len=22 mine==pkg? true decode register=()
P2 three byte strings distinct? true
P3 nonspanning register=(1, 2) decode refused? true
P3 top-level CLZero on {2} of F^5: decode ACCEPTS? true
P7 CLZero(F,5,[2,1]) vs [1,2]: same register_indices? true  same apply? true  bytes equal? false
```

The window, the two byte strings, the three `CLZero` lengths and the refusal are all mine. `P7` is new and is
N31.

### 1.2 `_pad_top`'s throw, and `direct_sum`

```
P4 pad_level(CLZero(F,5,(2,)),2) throws? true   pad_level(.,0) register=(2,)
P4 direct_sum full+full  : register=(1, 2, 3, 4, 5) level=0  pad_level(.,1) => ok factors=[[1,2,3,4,5]]
P4 direct_sum full+empty : register=(1, 2, 3)     level=0  pad_level(.,1) => THROW ArgumentError
P4 direct_sum empty+empty: register=()            level=0  pad_level(.,1) => ok factors=[[1,2,3,4,5]]
```

The middle line is N30: `direct_sum(CLZero(F,3), CLZero(F,2,Int[]))` — the direct sum of two *whole-space* zero
maps, one spelled with its full register and one with the empty register that DESIGN §9.4 says means "the zero map
on `F^n`" at top level — is a top-level `CLZero` on the proper sub-register `(1,2,3)`, and `pad_level` now refuses
it. Root cause: `_shift_cl(CLZero(F,2,Int[]), 3, 5) = CLZero(F,5,Int[])` (empty `.+ offset` is empty), after which
`_combine_embedded` (`cl.jl:706-711`) concatenates `_register` of each summand.

### 1.3 The sweep, recounted with my own on-line predicate

```
P6 INDEP per-pair support = Point->(64,512,18432)  ALine->(512,64,15296)  DLine->(18432,15296,2752)
P6 INDEP total=71360 non_noop=40768 equal_type=2880 line_vs_point=37888 OFF_LINE=0
P6 INDEP degenerate line-vs-point decisions=1024 of which point==base: 1024
```

Every number C4c asserts is mine, computed with my own solve for `t` and my own on-line test rather than
`_line_parameter`. The last line is new and is N29: **1,024 of the 37,888 line-versus-point decisions are against a
zero-direction (degenerate) line**, and in every one of them the point equals the line's base.

### 1.4 The off-line fixture, re-derived

```
P5 chi(0,2)=1 base=(0,5) dir=(1,0)   my t=3   on line? false
P5 rule=ld_axis_point passed=false location=question expected=point_on_line  answers agree at t? true
```

The fixture is sound and sharp: the answers *agree* at the pivot parameter, so nothing but the on-line test can
reject it, and the two newly asserted fields are exactly the marker `ld_honest_sweep` counts.

### 1.5 `enu:cl-space-sum` on the padded values, and the certificates

`pad(CLZero(F,5),2)` and `pad(CLZero(F,5,Int[]),2)` both report factors `[[1,2,3,4,5],[]]`; the `@test_throws`
pair at `tb1:193-195` covers `pad_level` **and** `pad_level_evidence`, so the r4 complaint that the suite pinned a
value its own certificate rejected is fully discharged — the failing certificate no longer exists because the
value no longer exists.

---

## 2. New objections

### N29 — **MAJOR** — on a zero-direction diagonal line the decider checks the answer at `t=0` only; that totalization is undeclared, is strictly WEAKER than `fig:ld-decider` item 3, and its rejecting side has no red witness

**Location.** `src/verifiers/ldt.jl:103-110` (`_line_parameter`, the `pivot === nothing` branch) feeding
`:112-136` (`_line_point_test`). Against `gt-07-ldt.tex:379-384` (item 3), `docs/DESIGN.md:1013-1015` (DD-4
"Canonical zero direction … Exact histograms must reveal whether this convention matches all downstream uses"),
the `:ld_off_line_rejects` SOURCE_REPAIR on the very same branch, and rk-light law 4.

**My independent computation.** Item 3 reads "accept iff `f_j(t) = (a_w̄)_j` for all `j` where `t ∈ F_q` is such
that `x_w̄ = u_0 + t v'`". When `v' = 0` the constraint is `x = u_0`: if `x ≠ u_0` **no** `t` exists (the executable
rejects — that is the declared, strictly-stricter `:ld_off_line_rejects` repair), but if `x = u_0` then **every**
`t ∈ F_q` satisfies it, and the definite description "the `t` such that …" is ambiguous. The executable totalizes
it by taking `t = 0` (`_line_parameter` returns `(true, zero(F))`), i.e. it checks one of the eight admissible
parameters. That is a divergence in the **lenient** direction and it carries no `SOURCE_REPAIR` node, no DESIGN
sentence and no claim scope clause, while its sibling on the same two lines does. DD-4's own instruction — check
whether the `v=0` convention "matches all downstream uses" — points at exactly this downstream use, and it does
not match.

It is reachable, and reached, in the flagship sweep: **1,024 of the 37,888 honest line-versus-point decisions**
(§1.3) are against a degenerate line. A concrete accepted cheat, at the sweep's own seed `(0,0,0,0,0)`:

```
N29 seed=(0,0,0,0,0)  line base=(0,0) dir=(0,0) DEGENERATE=true  point==base? true
N29 honest deg=0  honest decision=(:ld_diagonal_point, true)
N29 cheat f(0)=1 f(1)=0 deg=1 (md=2)  =>  decider rule=ld_diagonal_point ACCEPTED=true
N29 point!=base on a degenerate line: rule=ld_diagonal_point passed=false location=question
```

The honest restriction is the constant `1`, so completeness is untouched; but `f(t) = 1 + t` has degree 1 ≤ `md=2`,
agrees with the point answer at `t=0` and at no other `t`, and `ld_decider` **accepts** it. Under the strict
reading of item 3 it is rejected at seven of the eight admissible parameters.

And the branch is untested in both directions. My **NM15** (`_line_parameter`'s degenerate branch → `(true,
zero(F))`, i.e. every point counts as lying on a degenerate line) **SURVIVED** the whole TB1 suite (§4): the
rejecting side of that branch — the last line of the block above — is asserted nowhere, and cannot be reached by
the honest sweep because all 1,024 degenerate decisions have `point == base`.

**Why MAJOR and not MINOR.** I downgraded r4's N24 to MINOR precisely because that mutation was provably a no-op
on the rung's objects and falsified no claim text. This one is not the same: it is not merely a coverage hole but
an **undeclared divergence from the ground truth**, inside the exact function whose headline C4c sentence is
"`ld_decider` implements `fig:ld-decider`", and in a campaign whose stated method is that every deviation from
`gt-*.tex` is recorded as a `SOURCE_REPAIR`. Promoting C4c verbatim while it says "`gt-07-ldt.tex:377-384` accepts
vacuously when no `t` exists; the executable rejects, **strictly stricter**" would be an overclaim, because on the
same branch the executable is strictly *weaker* and the row does not say so.

**FIX DEMAND.** Choose one and say which in DESIGN §9.x next to DD-4:
(a) **Declare it.** Add a `SOURCE_REPAIR` node (e.g. `:ld_degenerate_line_t0`) hanging where
`:ld_off_line_rejects` hangs, with facts `(source="gt-07-ldt.tex:379-384", literal="every t in F_q satisfies x =
u_0 + t·0", executable="the answer is compared at t=0 only", honest_support_hits=1024, of=37888)`; **or**
(b) **Strengthen it.** When `v' = 0` and `x = u_0`, require `f_j` to be constant equal to `(a_w̄)_j` (equivalently
compare at all `t ∈ F_q`), which is the literal item 3 and costs `q·κ` evaluations on 1,024 of 71,360 decisions.
In **either** case: assert both sides of the degenerate branch in `decider_rejections` — a fixture with `point ==
base` and a nonconstant `f` agreeing at `t=0` (accepted under (a), rejected under (b)), and a fixture with `point
!= base` asserting `rule == :ld_diagonal_point && !passed && location == :question` — and register
`test/mutations/tb1_degenerate_line.jl` (`src/verifiers/ldt.jl`, `"        return point == line.base ? (true,
zero(F)) : (false, zero(F))"` → `"        return (true, zero(F))"`, target `tb1_decider_rejections`, expected
evidence a printed `MUTATION_EXPECTED_RULE` line) shown **KILLED**.

**SURVIVING WEAKER STATEMENT.** For every honest question pair at `(8,2,1)` the decider's verdict is correct and
the counts are exactly as C4c states — I reproduced all of them independently, including `off_line_hits = 0` — and
on the 36,864 non-degenerate line-versus-point decisions `_line_parameter` solves for the unique `t` and item 3 is
implemented literally. What is unwitnessed and undeclared is the 1,024-decision degenerate case: that a point off a
degenerate line is rejected, and that a line answer agreeing only at `t=0` is accepted.

### N30 — **MINOR** — the N25 throw is not closed under `direct_sum`: the two spellings of a whole-space zero map stop being interchangeable

**Location.** `src/samplers/typed.jl:36-42` (`_pad_top`) together with `src/samplers/cl.jl:697-699` (`_shift_cl` on
`CLZero`) and `:706-711` (`_combine_embedded`'s all-zero case). Against `docs/DESIGN.md:1188-1191` (§9.4:
`direct_sum` "only transport[s] such components and must preserve their promoted factor reports") and r4's
forward NOTE 2.

**My independent computation.** §1.2. `CLZero(F,3)` and `CLZero(F,3,Int[])` are both "the zero map on `F^3`" by
§9.4's own sentence, but `_shift_cl` maps the empty register to the empty register, so `_combine_embedded`
concatenates `[1,2,3] ⊎ [] = [1,2,3]` and the direct sum lands on a proper sub-register of `F^5`. `pad_level` then
throws where the same map spelled `full+full` or `empty+empty` pads fine. This is **not a regression** — at
`1919aff` the same input silently produced factors `[[1,2,3]]`, failing `enu:cl-space-sum`, which is worse — but it
means the empty-register convention is overloaded (top-level "whole space" vs in-chain "zero-dimensional
terminal") and `_shift_cl` conflates the two readings.

**FIX DEMAND** (for brief 39 / TB5, not for another TB1 round): before `direct_sum` acquires a description-level
constructor, either normalise in `_combine_embedded` (when the all-zero case is reached at top level, emit
`CLZero(F,total)` if the concatenated register is nonempty, `CLZero(F,total,Int[])` otherwise) or widen `_pad_top`
to promote any top-level zero map on the ambient `{1..n}` (r4 N25's other authorized branch). Pin whichever with an
assertion that `pad_level(direct_sum(CLZero(F,3), CLZero(F,2,Int[])), 1)` has factor spaces `[[1,2,3,4,5]]`.

**SURVIVING WEAKER STATEMENT.** For every value TB1 and TB2 actually build, `pad_level` is total and correct, and
the throw strictly improves on the r4 behaviour on the input r4 found. C4a already says no claim is made about
`direct_sum`; the row now records the interaction explicitly.

### N31 — **MINOR** — `canonical_bytes` is not canonical: a permuted register declaration gives a different byte string for the same map

**Location.** `src/samplers/cl.jl:87-91` (`CLZero`'s constructor keeps the declared order; only `_register` sorts)
and `:462` (`_describe_term(L::CLZero)` copies `L.indices` unsorted). Against DESIGN §9.2's intensional
`description_size`/hash purpose and §10.3's "identical canonical `S^rep` hashes, never `hash(D)`" (r4 forward
NOTE 3).

**My independent computation.** `CLZero(F,5,[2,1])` and `CLZero(F,5,[1,2])` have the same `register_indices`
`(1,2)`, agree on `apply` at every seed I tried, and have **different** canonical bytes (§1.1 `P7`). The same
mechanism applies to a `CLStep`'s `factor`/`rest` order. So `canonical_bytes` is injective in the direction C4a
claims (bytes determine the map) but is not a *canonical form*: equal maps can have unequal bytes, and byte
equality is therefore not yet a decision procedure for description equality.

**FIX DEMAND** (brief 39 / TB5): either sort the index vectors in `_describe_term` (and state in DESIGN §9.3 that
registers are serialized in increasing order), or state explicitly that `canonical_bytes` is canonical only up to
the declared register order and that `S^rep` hashing must normalise first. Pin with
`canonical_bytes(describe_cl(CLZero(F,5,[2,1]))) == canonical_bytes(describe_cl(CLZero(F,5,[1,2])))` (option 1) and
a registered mutant that unsorts.

**SURVIVING WEAKER STATEMENT.** Every claim TB1 makes today is unaffected: all 21 TB1/TB2 maps declare their
registers in increasing order, and the bytes-determine-the-map direction is verified independently.

### N32 — **NOTE** — the DESIGN lockstep for N24/N25/TB2-N26 has landed nowhere, and §9.4 now contradicts the code

**Location.** `docs/DESIGN.md:1186-1187` (archived) — and I checked the **live** file too: `grep` for "proper
sub-register", "row-major" and "does not span the ambient" over the live `docs/DESIGN.md` returns nothing. §9.4
still reads "`pad_level` promotes a zero map with `V_1` = the space the value acts on: **its register `R`** … and
the whole ambient `{1..n}` for a top-level value declared on the empty register", which is precisely the behaviour
`_pad_top` now refuses. Law 2 (single-source definitions, lockstep) is violated between `src/samplers/typed.jl` and
DESIGN §9.4.

This is the **orchestrator's** lane, not the proposer's — brief 59 excluded `docs/`, and the proposer correctly
filed MERGE PROPOSALS. I re-issue them as authorized text: §9.4 append "a top-level zero map declared on a proper
nonempty sub-register is refused by `pad_level` (`ArgumentError`) — every originator below is whole-space, so it is
a declaration error, not a promotion case (`verdicts/tb1-r4.md` N25) — while `direct_sum` of the two spellings of a
whole-space zero map can still build one (`verdicts/tb1-r5.md` N30)"; §9.3's byte-format paragraph append "stage
matrix entries are serialized row-major, `(1,1),(1,2),…,(w,w)`, pinned by an off-diagonal witness; `decode_cl`
re-imposes `factor ⊎ rest = {1..n}` on the top stage, a top-level `CLZero` excepted; register index vectors are
serialized in their declared order, so canonical bytes are canonical only up to that order (`verdicts/tb1-r5.md`
N31)".

### N33 — **NOTE** — the TB0 gate charges only `tb0_core.jl` (146 of 907 assertions); the observed spread is the CPU clock, not suite growth

**Location.** `test/runtests.jl:10-20`. `started = time()` is taken before `include("tb0_core.jl")` and `elapsed`
immediately after it; TB1/TB2/TB3 are included afterwards and never charge the gate. Summing the reported per-set
times for the 18 TB0 testsets in my run 2 gives ≈ 17.0 s against a measured 18.567 s, confirming it.

My six measurements of the identical archived tree, each with the `uptime` load average at the time (§3):
**74.6 / 85.2 s** (orchestrator, powersave), **92.7 / 49.9 / 40.6 s** (proposer), **23.7 / 17.5 s** (mine,
pre-reboot, powersave, load 7.9 → 3.2), **18.0 / 18.6 s** (mine, post-reboot, `energy_performance_preference =
performance`, load 1.6 → 2.8). The box ran at 802–1151 MHz before the reboot and 4801 MHz after: a 4–6× clock
ratio that accounts for the entire 5× spread. **The gate is not structurally marginal at 907 assertions** — the
assertion count is not what it measures, and it has 3.2× headroom on a performance-profile box.

**RECOMMENDATION (not implemented; the orchestrator's call).** In descending order of value:
(1) make the gate machine-independent — time a fixed calibration kernel in the same process (e.g. the existing
`GF(8)` exhaustive-triple loop) and gate on the **ratio** `tb0_body / calibration`, with the current 60 s budget
re-expressed as that ratio measured once on a known-good box; (2) failing that, keep the wall gate but read the
budget from an env var (`TB0_BUDGET_SECONDS`, default 60) so a loaded or throttled box can be told, and keep the
45 s warning as the real regression signal; (3) in any case correct the surrounding comments and the TB3 brief:
the budget does **not** track TB1/TB2/TB3 growth, so "the suite is now 907 assertions" is not an argument about
this gate.

---

## 3. Test and mutation runs observed (archived copy at `3f2d1f1`, Julia 1.12.5)

All eight runs below are mine, on the archived tree. `uptime` load average is quoted at the start → end of each
run, as brief 61 requires. The reboot separates runs 1–2 (802–1151 MHz, `powersave`) from runs 3–4 (4801 MHz,
`energy_performance_preference=performance`).

| run | what | load (start → end) | TB0 test-body wall | suite/registry wall | result |
|---|---|---|---|---|---|
| 1 | `test/runtests.jl` (pre-reboot) | `7.85 5.58 4.95` → `4.46 5.20 4.88` | **23.693 s** (gate 60, warning 45 not fired) | 1m37.9 | **exit 0, 907/907** |
| 2 | `test/runtests.jl` (pre-reboot) | `3.17 4.82 4.77` → `3.80 4.54 4.66` | **17.486 s** | 1m11.2 | **exit 0, 907/907** |
| 3 | `test/runtests.jl` (post-reboot) | `1.60 0.72 0.34` → `2.00 1.01 0.47` | **17.963 s** | 1m06.0 | **exit 0, 907/907** |
| 4 | `test/runtests.jl` (post-reboot) | `2.00 1.05 0.49` → `2.83 1.45 0.67` | **18.567 s** | 1m11.9 | **exit 0, 907/907** |
| 5 | `test/mutations/run.jl` (pre-reboot) | `6.92 4.89 4.77` → runner's own 4 jobs, 8–9 | — | 5m07.7 | **exit 0**, `killed=84/84 baselines ok=43/43 wall=307.34 s` |
| 6 | `test/mutations/run.jl` (post-reboot) | `2.83 1.45 0.67` → `9.63 7.04 3.50` | — | 6m43.2 | **exit 0**, `killed=84/84 baselines ok=43/43 wall=402.86 s` |
| 7 | `indep/{probe1,probe2,probe3}.jl` | `7.50 3.15 1.33` → `7.81 3.36 1.41` | — | ≈ 20 s total | §1 |
| 8 | `indep/newmut.jl` (3 mutants) | `7.75 7.03 3.71` → `8.99 7.50 4.11` | — | 1m07 | §4 |

Zero `SURVIVED`, `UNATTRIBUTABLE` or `LOAD-ERROR` lines in either registry run. The registry is 84 mutants over 43
baselines: 28 TB0, **35 TB1**, 16 TB2, 5 TB3. This round's five TB1 arrivals, all observed KILLED with passing
baselines (run 6 timings):

```
MUTANT TB1 N4-off-line line_point_test_never_agrees              target=tb1_decider   => KILLED ( 7.34 s)
MUTANT TB1 N24-describe-transpose field_ints_column_major        target=tb1_describe  => KILLED (10.23 s)
MUTANT TB1 N26-describe-zero-register zero_term_drops_register   target=tb1_describe  => KILLED (15.19 s)
MUTANT TB1 N25-pad-subregister top_level_subregister_zero_promoted target=tb1_levels  => KILLED (12.27 s)
MUTANT TB1 N26-decode-ambient decode_skips_ambient_partition     target=tb1_describe  => KILLED (13.54 s)
```

Suite evidence lines, all present and all `true` on the unmutated tree:

```
MUTATION_EXPECTED_RULE pad_subregister refused=true
MUTATION_EXPECTED_RULE describe_transpose row_major=true
MUTATION_EXPECTED_RULE describe_zero_register ok=true
MUTATION_EXPECTED_RULE decode_ambient refused=true
MUTATION_EXPECTED_RULE off_line reached=false hits=0
TB1 D^ld: support_decisions=71360 non_noop=40768 (equal-type 2880 line_vs_point 37888) off_line_hits=0
TB1 describe: description_size L_Point/L_ALine/L_DLine=[75, 132, 156] … decode round trip on 3x8^5 seeds
```

TB1's own testsets grew `levels` 37 → 40, `describe` 33 → 49 and are otherwise unchanged; the suite is
638 → 907 across all four rungs (TB3 landed in the same range).

No FATAL: suite green four times, registry green twice, every registered mutant killed with a passing baseline, no
status raised by the proposer.

## 4. My new mutations

Applied on copies only (`mktempdir`; the mutated file written to the sandbox and `Base.include`d into the loaded
module; the archived tree never modified). Runner: `indep/newmut.jl`, `TB1_TARGET=all`.

| id | file:site | semantic change | outcome |
|---|---|---|---|
| **NM14** (new) | `cl.jl:635` (`_term_to_cl`) | the **decoder** reconstructs the stage matrix column-major | **KILLED** — sole failures `tb1:377`, `tb1:378` (`apply(decode_cl(shear_bytes), ·)`). The N24 repair pins both ends of the round trip, not just the encoder. |
| **NM15** (new) | `ldt.jl:105` (`_line_parameter`) | every point counts as lying on a **degenerate** (zero-direction) line | **SURVIVED** (exit 0) → **N29** |
| NM11 (r4 re-probe) | `ldt.jl:237` | the honest sweep stops counting off-line decisions | SURVIVED (expected; §0 N23 row) — the *fact* is now red-capable through `tb1_off_line.jl`, the *counter expression* is not, because its honest value is 0. |

One of the two new mutations is killed by exactly the assertion this round added; the other is the objection.

## 5. Per-claim decision

| claim | decision | note |
|---|---|---|
| **C4a** | **RE-AFFIRM at TESTED**, replacing the row with the authorized text below | Every fact in the brief-59 merge proposal independently reproduced (§1.1–§1.2): my own emitter reproduces the shear map's 48 bytes and its transpose's, the hand-derived window `35:38`, and all three `CLZero` register byte strings; `decode_cl`'s ambient refusal and `pad_level`'s throw both verified; the four mutants observed KILLED. Two scope clauses are **added** to the proposer's text, for N30 and N31 — both are restrictions, never strengthenings. Status may not rise further. |
| **C4c** | **HOLD** (not created at TESTED this round) | The r4 missing step (N23) **is** discharged: the marker is asserted, `tb1_off_line.jl` is registered and observed KILLED, and I recomputed every number in the row independently (§1.3). The new missing step is **N29**: the row's fidelity sentence — "`ld_decider` implements `fig:ld-decider`" together with "the executable rejects, strictly stricter" — is not sustainable while, on the same branch, the executable is strictly *weaker* than item 3 on 1,024 of the 37,888 line-versus-point decisions, undeclared and unwitnessed. One `SOURCE_REPAIR` node (or one strengthening), two fixtures and one registered mutant close it; the exact row text I will authorize is below, in both variants, so the next round is mechanical. |
| **C4b** | defer to `verdicts/tb2-r5.md` | brief 62's lane. TB1-relevant residue only: C4b's padding sentence is carried by `pad_level_evidence`, whose r4 failing case no longer exists (§1.5). |
| **C9** | defer to `verdicts/tb2-r5.md` | TB2's lane. |
| **C7** | HOLD at CONJECTURE | `depends-on = C4a,C4b` remains correct; no TB1 evidence bears on it. |
| C1–C3, C5, C6, C8, C12–C19 | unchanged | outside this rung's lane. |

**C4a — AUTHORIZED VERBATIM ROW** (copy exactly; only surrounding table scaffolding may be adapted). It is the
current row with the body unchanged and the two scope sentences named in brief 59's merge proposal replaced, the
red list extended by the four mutants, and this verdict appended to the verdict column:

> | C4a | (Sampler is CL — TB1 instance) For `(q,m,d)=(8,2,1)` and ambient `V=V_pt (+) V_coord (+) V_dir` of `seed_dim` 5, `L_Point`, `L_ALine` and `L_DLine` are CL functions of constructed nesting depth 1, 2 and 3 respectively — upper bounds in the sense of `rk:higher-level`, not minimality claims — built only from `CLStep` stages whose factor and rest registers are disjoint coordinate-index sets partitioning that stage's own register, with lazily evaluated continuations validated (field, seed dimension, rest register, child level) on every key reached by the exhaustive enumeration; each map's `level` factor registers are pairwise disjoint and their union is all of `{1,...,5}` on every one of the `8^5` seeds (`lem:cl-kth` `enu:cl-space-sum`), namely all of `V` for `L_Point`, `{3,4,5},{1,2}` for `L_ALine` and `{3},{4,5},{1,2}` for `L_DLine`, matching the concatenation sentences of `gt-07-ldt.tex:203-237`, with 1, 8 and 288 distinct branch chains; `apply` equals the sum of the first `level` stage outputs on all `3 x 8^5 = 98,304` marginal replays (`lem:cl-kth` `enu:cl-map-sum`), and the same telescoping replayed through `def:sampler`'s `Marginal`/`Factor`/`Linear` queries reports agreement on all `32,768 + 65,536 + 98,304 = 196,608` k-checks, with `Factor` accepting exactly the reachable prefixes `u` in `L_{<j}(V)` and `Linear` the broader `u` in `V_{<j}` (measured 8 and 512 at `j=2` for `L_ALine`, `gt-04-cl.tex:588-594`); all three maps are describable from `QuotedBranch` continuations with `description_size` 75, 132 and 156 bytes, reproduced by independent reserialization, while an opaque host branch and every `direct_sum`/`concatenate` output are `NotDescribable`; and over all `8^5 = 32,768` seeds the induced distributions `mu_{L_ALine,L_Point}` and `mu_{L_DLine,L_Point}` have exact histograms of support 512 and 18,432 (mass 32,768 each; 512 zero-direction support points carrying 2,304 seeds) agreeing entry-for-entry with a separately transcribed evaluation of `eq:cl-ptf`/`eq:cl-alnf`/`eq:cl-dlnf` **including `eq:chi-func`** — the comparison is NOT `chi`-independent (`verdicts/tb1-r1.md` O1) — and on the 512 zero-direction points the equality additionally rests on the DESIGN `SOURCE_REPAIR` `L^lnf_0 = id`, which `def:cl-canonical` does not define (O3), emitted as a `SOURCE_REPAIR` `CertNode` under the CHECKED histogram node. The separately asserted `chi`-free content of `lem:alnf`/`lem:dlnf` is the marginal support 128 (all masses 256) and 4,096 (masses 4 and 36). The canonical bytes determine these maps: `decode_cl` round-trips `L_Point`, `L_ALine`, `L_DLine` and two padded maps on all `8^5` seeds, `L_Point` and the `V_coord (+) V_dir` projector are 75 bytes each with distinct bytes, and the stage-1 matrix occupies bytes `41:65` — all four reproduced in `verdicts/tb1-r4.md` §1.1-§1.3 by an independent parser, evaluator and re-emitter written from the byte-format contract and `gt-07-ldt.tex` alone. **Scope:** `enu:cl-map-sum` is CONSTRUCTED by the datatype's disjoint registers, so the four-query replay tests the query compiler rather than the value; its map-sum comparison is the sole owner of `tb1_prefix_walk.jl` (`verdicts/tb1-r3.md` N13), while disarming the comparison itself remains free, no value inside the datatype's invariants falsifying the map sum (`verdicts/tb1-r4.md` §1.5). The bytes carry the matrix index order (row-major; pinned by the nonsymmetric `[1 1; 0 1]` window `35:38`, `tb1_describe_transpose.jl`) and a `CLZero`'s register (`tb1_describe_zero_register.jl`); `decode_cl` re-imposes the top stage's ambient partition `factor (+) rest = {1..n}` (`tb1_decode_ambient.jl`), a top-level `CLZero` being exempt so that all three register spellings still decode. `canonical_bytes` is canonical in the bytes-to-map direction only: `CLZero(F,5,[2,1])` and `CLZero(F,5,[1,2])` are the same map with the same `register_indices` and different bytes, so byte equality is not yet a decision procedure for map equality (`verdicts/tb1-r5.md` N31). `Marginal` rejects `j=0` and `j=ell+1` like `Factor`/`Linear`, and `Factor(L,1,u)` admits only `u=0` (ibid. N14 discharged). `pad_level` refuses (`ArgumentError`) a top-level zero map declared on a proper nonempty sub-register (ibid. N25, throw branch; `tb1_pad_subregister.jl`); `direct_sum` of a whole-space zero map declared on its full register with one declared on the empty register builds exactly such a value, so the two spellings of a whole-space zero map are not interchangeable under `pad_level` after `direct_sum` (`verdicts/tb1-r5.md` N30). No claim is made here about `D^ld` (that is C4c), about `concatenate`/`direct_sum`/`product`/`TypedSampler`, or about any other `(q,m)`. | TESTED | D2 | — | `test/tb1_ld_sampler.jl` (`levels`, `space_sum`, `queries`, `describe`, `memo`, `chi`, `chifree`, `pi_separator`, `lnf_separator`, `histogram_axis`, `histogram_diagonal`, `marginals`); red: `test/mutations/tb1_{chi,pi,lnf,level,repair,ambient,ambient_doblock,child_validation,dsum,concat,space_sum,pad_order,chifree,describe_closure,describe_matrix,factor_indicator,factor_reachability,linear_narrowed,prefix_walk,replay_skips_k,replay_skips_union,memo_unbounded,describe_transpose,describe_zero_register,pad_subregister,decode_ambient}.jl` | `verdicts/tb1-r1.md`, `verdicts/tb1-r2.md`, `verdicts/tb1-r3.md`, `verdicts/tb1-r4.md`, `verdicts/tb1-r5.md` |

**C4c — HELD.** Missing step: **N29** (one declared `SOURCE_REPAIR` *or* one strengthening, two fixtures, one
registered mutant). When it lands and a verdict observes `tb1_degenerate_line.jl` KILLED, this is the row text I
authorize — `verdicts/tb1-r4.md` §5's pre-written row with the independent r5 recount added, the NM11 residue
recorded, and **exactly one** of the two bracketed degenerate-line sentences kept, matching the branch the
proposer chose:

> | C4c | (TB1 `D^ld`, `(q,m,d)=(8,2,1)` at `kappa=1`) `ld_decider` implements `fig:ld-decider` with answer bounds `d=1` (axis) and `md=2` (diagonal, tight: `verdicts/tb1-r3.md` §1.4), symmetrized over the pair order. Over all `8^5` seeds the honest prover for `g = 1 + x1 + x1 x2` is accepted on all 71,360 distinct support decisions of the nine ordered type pairs (per pair: 64/512/18,432; 512/64/15,296; 18,432/15,296/2,752 — recomputed independently in `verdicts/tb1-r4.md` §1.6 and again, with an independent on-line predicate, in `verdicts/tb1-r5.md` §1.3); 40,768 are non-noop, split 2,880 equal-type tautologies / 37,888 line-versus-point; the off-line branch is reached 0 times. The sweep is a CHECKED `:ld_honest_sweep` node (`ld_sweep_evidence`) whose replay re-runs it from `(params, g, samplers, seeds)` and rejects a tampered report, carrying `SOURCE_REPAIR :ld_off_line_rejects` (`gt-07-ldt.tex:377-384` accepts vacuously when no `t` exists; the executable rejects, strictly stricter). **[variant (a), if the totalization was declared:** On a zero-direction diagonal line — 1,024 of the 37,888 line-versus-point decisions, every one of them with the point equal to the line's base — every `t in F_q` satisfies item 3's constraint and the executable compares the answers at `t=0` only, which is strictly weaker than the literal item and is recorded as `SOURCE_REPAIR :ld_degenerate_line_t0` (`verdicts/tb1-r5.md` N29).**]** **[variant (b), if the check was strengthened:** On a zero-direction diagonal line — 1,024 of the 37,888 line-versus-point decisions, every one of them with the point equal to the line's base — every `t in F_q` satisfies item 3's constraint, and the executable requires agreement at all of them, which is the literal item (`verdicts/tb1-r5.md` N29).**]** Separately, at `kappa=2` the `for all j in 1..kappa` loops and the answer arity are exercised by three fixtures (accept, second-entry cheat at `location==2`, short answer `:ld_answer_arity`). **Scope:** one polynomial, one field row, no soundness claim; the sweep's counts are functions of the question supports and the guard dispatch and do not depend on the honest polynomial's identity (`verdicts/tb1-r4.md` N28); equal-type decisions are identical-question tautologies (`verdicts/tb1-r2.md` N11); `off_line_hits = 0` is red-capable as a fact (`tb1_off_line.jl` drives it positive) but the counter expression itself may still be replaced by the constant `false` without any test noticing, its honest value being 0 (`verdicts/tb1-r5.md` §4, NM11). | TESTED | D2, C4a | — | `test/tb1_ld_sampler.jl` (`decider`, `decider_rejections`, `degree`, `restrictions`, `trace`); red: `test/mutations/tb1_{deg,agreement,symmetry,verifier_pi,online,off_line,degenerate_line,question_arity,kappa,dline_degree}.jl` | `verdicts/tb1-r1.md`..`verdicts/tb1-r5.md` |

**Lockstep follow-ups for the orchestrator** (not TB1's lane): the two DESIGN paragraphs authorized in N32, plus
the N29 sentence next to DD-4 once the branch is chosen.

## 6. Forward look — additions to r4's NOTEs for brief 39 (TB5 `SamplerDescription`)

- **NOTE 1 (byte format), amended.** Row-major is now pinned with an off-diagonal witness at both ends of the
  round trip (encoder by the `35:38` window, decoder by NM14). Add to the format contract that index vectors are
  serialized in their *declared* order — and normalise them, or `S^rep` hashing is not well defined (N31).
- **NOTE 2 (zero components), amended.** The promotion rule is now decided (throw), but `direct_sum` can build the
  refused shape out of two legitimate whole-space zero maps (N30). Fix the empty-register overload in `_shift_cl`
  or widen `_pad_top` *before* the description-level `direct_sum` is written.
- **NOTE 7 (new — degenerate lines downstream).** DD-4 asks whether the `v=0` convention "matches all downstream
  uses". At TB1 it does not (N29). `fig:decider-pcp` steps 3, 4(b) and 4(c) all call `D^ld`, at
  `(q,m,d,1)` and `(q,m',d,m'+6)`; whatever N29 decides must be applied there too, and TB2's answer-reduced
  decider inherits it. Check it when `kappa = m'+6 = 6` rather than 1, where a degenerate line costs `q·kappa`
  comparisons under variant (b).
- r4's NOTEs 3–6 stand unchanged.

---

**What this round got right, for the record.** All five r4 work-order items landed, and the MAJOR one landed in
the strong form: the marker is asserted on a fixture I re-derived from `fig:ld-decider` myself, and the registered
mutant's kill is gated on the counter actually going positive rather than on the suite merely reddening. The
row-major repair went further than I demanded — it pins the decoder too (my NM14 is killed by exactly the two
assertions the proposer added). The N25 judgment call is the right one and is better than either behaviour I
described in r4, because it converts a silently invalid sampler into a refusal. 907/907 four times, 84/84 mutants
over 43/43 baselines twice, and every number in C4a and C4c reproduced independently. The one MAJOR is not a
repair that failed: it is a branch of `ld_decider` that no round has looked at, reached 1,024 times by the sweep
this rung's flagship claim is built on, where the executable is quietly more permissive than the paper.

VERDICT: FAIL(N29)
