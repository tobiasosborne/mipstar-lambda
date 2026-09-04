# CRITIC verdict r2 — rung TB1 (`src/samplers/{cl,typed,ldt}.jl`, `src/verifiers/ldt.jl`, `test/tb1_ld_sampler.jl`, `test/mutations/tb1_*.jl`) at commit `a4dc22a`

Round 2 (adjudicate). **Prior.** `verdicts/tb1-r1.md` (FAIL(O1,O2,O3,O5); C4a PROMOTE to TESTED,
C4b HOLD) is the work order. Everything that passed there is treated as settled and is not
re-litigated; the objections below are all new, and every one of them is on code that did not exist
at `41ff317`.

**Isolation.** `git archive a4dc22a | tar -x -C <scratch>/tree` into
`/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-…/scratchpad/critic-tb1-r2/tree`,
`Pkg.instantiate()` there, and every test, mutation, timing and experiment run there. The live
working tree (a TB0 repair worker is editing it) was never read or run for `src/`/`test/`; only
`ground-truth/`, `briefs/`, `claims/` and `docs/` were read at HEAD for lane/lockstep purposes, and
all `file:line` citations below are the archived copy. My only repo output is this file. No git
state-changing command was run.

**Independence.** Every number in §1 was recomputed from a *new* implementation written directly
from `gt-03-prelim.tex` (`def:register-subspace`, `def:canonical-complement`, `def:cl-canonical`),
`gt-04-cl.tex` (`def:cl-func`, `def:cl-dist`, `lem:cl-kth`, `rk:higher-level`, `def:sampler`
L572–L601) and `gt-07-ldt.tex` (`eq:cl-ptf`/`eq:cl-alnf`/`eq:cl-dlnf`, `eq:chi-func`, `lem:alnf`,
`lem:dlnf`, `fig:ld-decider`): my own carry-less `GF(8)` (modulus `x^3+x+1`, distributivity,
associativity and inverses re-verified on all `8^3` triples), my own `chi` solved as a search for the
unique `i` with `0 <= s-(i-1)q/m < q/m`, my own `L^lnf` built from the RREF pivot rule, and my own
`pi_{i-1}`. Scratch: `…/critic-tb1-r2/indep/{ref.jl,refcore.jl,compare.jl,support.jl,struct.jl,
memo2.jl,time6.jl,newmut.jl,newmut2.jl,fixcheck.jl}`. No code from `src/` is on the reference path.

**Lane check (law 1).** `git show --stat a4dc22a` touches `src/**`, `test/**`, `briefs/`, `docs/`
(`DESIGN.md` §1.5/§5.3/§1.6 lockstep, applied by the orchestrator) and `Project.toml`;
`git diff 41ff317 a4dc22a -- claims/CLAIMS.md` shows no status raised by the proposer. Law 1
respected. The proposer's report explicitly confines itself to MERGE PROPOSALS for C4a/C4b/C9.

---

## 0. Adjudication of the response table (`briefs/38-tb1-tb2-repair-r1-resume.last.md`)

TB1 rows only; the two DOWNGRADED rows in that table (TB2 O3, TB2 O8) are outside this rung's lane
and belong to `verdicts/tb2-r2.md` (brief 41). **No TB1 row was downgraded**, so law 5's
"downgrade-or-escape" question does not arise here; every TB1 row claims FIXED except O10.

| row | claimed | adjudicated | basis |
|---|---|---|---|
| O1 | FIXED | **ACCEPTED** | `test/tb1_ld_sampler.jl:36-38` now says "Separate transcription … including eq:chi-func. This joint (line,point) histogram is deliberately not chi-independent"; the `chifree` testset (`:139-151`) asserts the two genuinely `chi`-free facts, which I recomputed independently (axis 128/{256}, diagonal 4,096/{4,36}); M-χ's owner is retargeted to `tb1_chi_boundary`, which runs only the direct `eq:chi-func` bucket assertion (`:109`). `docs/DESIGN.md:889-893` was rewritten in the same commit and now states the negative explicitly. Residue: N6. |
| O2 | FIXED | **ACCEPTED** | `decider_rejections` (`:357-431`, 11 assertions) contains the r1 testset verbatim plus both orders, the unprojected-`DLine` case, the off-line guard, the arity guard and `kappa=2`. N1–N5 are registered (`tb1_{agreement,symmetry,verifier_pi,online,question_arity}.jl`) and I observed all five KILLED in my own registry run. `non_noop == 40_768` asserted at `:347`, and I reproduce 40,768 independently. Residue: N1 (the *diagonal* degree bound is still not red-capable), N11. |
| O3 | FIXED | **ACCEPTED** | `src/samplers/ldt.jl:138-152` emits `CertNode(SOURCE_REPAIR, :ld_lnf_zero_direction; facts=(support=512, mass=2304, of=32768))` as a child of the CHECKED `:ld_diagonal_histogram` node with a live `replay`; `:183-190` asserts both grades, the exact facts tuple and `verify_certificate`. My independent enumeration gives support **512**, mass **2,304**, of **32,768** — exact agreement. `M-repair` KILLED. |
| O4 | FIXED | **ACCEPTED** | The report line now attributes the kill to `:ld_axis_degree`, and `:451-456` adds the complementary separator (`fake_linear`, format-legal, rejected `:ld_axis_point` at the named point (3,5)). The demand said "degree-1"; `zero_poly` is degree 0, which discharges the same obligation (format-legal answer, point test rejects). |
| O5 | FIXED | **ACCEPTED** | `CLStep{F}` now stores `branch::Function` with a memoised, validated `_child` (`cl.jl:103-116`); `grep` finds no `_field_tuples`/image sweep anywhere. Laziness is asserted behaviourally at `:86-96` (`calls[]==0` before `apply`, `==1` after two applies sharing a stage key). I timed `apply(L_DLine_6)` at `q=2^11, m'=16` myself: **2.41 µs/call** warm-memo and **5.87 µs/call** on 1,000 fresh seeds, against r1's projected ~5.4 days for a single eager `L_ALine` stage at that field. Residue: N2, N7. |
| O6 | FIXED | **ACCEPTED (partial)** | Both public constructors pass `require_ambient=true` (`cl.jl:93-94, 99-100`) and `_clstep:73-76` throws; red test at `:82-84`; `M-ambient` KILLED. But only the *non*-do-block constructor's guard is mutation-covered — NM3 shows the do-block form's identical guard survives. Folded into N2. |
| O7 | FIXED | **ACCEPTED** | `level(L::CLStep) = 1 + level(L.child_shape)` (`cl.jl:50`) — the `first(values(L.branches))` read site is gone; `@test level(pad_level(point,5)) == 5` at `:79`; the upper-bound reading is already in the C4a row. New consequence: N5. |
| O8 | FIXED | **ACCEPTED** | `:98-103` asserts `level(concatenate(point,point))==2` (which separates `+` from `max`, since `max(1,1)=1`), `level(direct_sum(point,axis))==2` (which separates `max` from `+`, since `1+2=3`) and `TypedSampler.common_level==2`; `M-concat` and `M-dsum` KILLED. Each equation is asserted at exactly one instance — sufficient to discriminate the two candidate laws, noted not objected. |
| O9 | FIXED | **ACCEPTED** | `test/runtests.jl:1-6` starts the clock after `using MIPStarLambda`; load time is printed ungated (0.288 s warm here). Quiet TB0 body **36.302 s**; exit 0. Residue: N8. |
| O10 | RESIDUE | **ACCEPTED as RESIDUE** | `_question_format` (`verifiers/ldt.jl:46`) still demands the ambient `2m+1` for all three types. This is *correct* for TB1's encoding — all three CL maps output in the full ambient `V` — so `fig:ld-decider`'s per-type widths are a display convention, not a parser contract, here; the arity check is now genuinely red-capable (N5 KILLED); TB2's parsers are per-type. Legitimate residue. |
| O11 | FIXED | **ACCEPTED** | `kappa=2` at `:412-427`: honest accept, second-entry cheat rejected with `location == 2`, short answer rejected `:ld_answer_arity`; `M-kappa` KILLED. |
| O12 | FIXED | **ACCEPTED (with a wall caveat)** | `run.jl:125-177` warms the package image once (0.49 s in my run) and then runs each mutant in its own process that loads the precompiled image and `Base.include`s only the mutated file; 4 concurrent jobs; no re-precompile. 37/37 KILLED, exit 0. But my wall is **404.79 s**, not the reported 230.24 s: the runner's own wall is load-sensitive by construction (4 jobs), so "< 5 min" holds only on a quiet box. NOTE, not a disagreement — every disposition reproduces. |

---

## 1. Independent recomputation (brief obligations 1–5)

**(1) (line, point) joint histograms for `(q,m,d)=(8,2,1)` — CONFIRMED, entry for entry.** My own
enumeration of all `q^{2m+1}=32,768` seeds under `eq:cl-ptf`/`eq:cl-alnf`/`eq:cl-dlnf`, compared
key-by-key against the package's `histogram(distribution(·,·), enumerate_seeds(GF8,5))`:

```
INDEP GF(8) field laws over all 512 triples: true
INDEP axis     support=512    mass=32768  multiplicities=[64]
INDEP diagonal support=18432  mass=32768  multiplicities=[1, 8]
INDEP diagonal zero-direction support=512  mass=2304
INDEP axis  histogram == code : true   (code support=512    mass=32768)
INDEP diag  histogram == code : true   (code support=18432  mass=32768)
```

Hand derivation agreeing with both: the axis pair is a function of `(u,s)` alone → `8^2*8=512` keys
each hit by the `8^2` free `v`; the diagonal pair is a function of `(u,s,v')` → `4*64*64=16,384`
keys at `i=1` (multiplicity 1) plus `4*8*64=2,048` at `i=2` (multiplicity 8) = **18,432**, mass
`16,384+16,384=32,768`; `v'=0` needs `v=0` at `i=1` and `v_2=0` at `i=2`, giving `4*64+4*64=512`
keys carrying `64*(4*1+4*8)=2,304` seeds. **The `SOURCE_REPAIR` node's facts tuple
`(support=512, mass=2304, of=32768)` is exactly right.** I also reproduced the genuinely `chi`-free
`lem:alnf`/`lem:dlnf` marginals the new `chifree` testset asserts — axis support **128**, all masses
**256**; diagonal support **4,096**, masses **{4, 36}** (mass 4 when `v'_1 != 0`, 36 when `v'_1=0`,
from `4*1 + 4*8`) — and the decider sweep's support counts:

```
Point×Point 64   Point×ALine 512    Point×DLine 18432
ALine×Point 512  ALine×ALine 64     ALine×DLine 15296
DLine×Point 18432 DLine×ALine 15296 DLine×DLine 2752
INDEP total = 71360   noop = 30592   non_noop = 40768
              of which equal-type consistency = 2880, line-vs-point = 37888
INDEP every equal-type support pair has identical left/right question: true
```

**No disagreement with any printed number** (512, 18,432, 512, 2,304, 32,768, 98,304, 71,360,
40,768, 16, 568, 128/{256}, 4,096/{4,36}).

**(2) `eq:chi-func` bucket boundaries by hand for three seeds — CONFIRMED.** Solving
`s = (i-1)q/m + r`, `0 <= r < q/m` at `q=8, m=2` (`w = 4`): `s=3 -> i=1` (`0 <= 3-0 < 4`);
`s=4 -> i=2` (`0 <= 4-4 < 4`, and `i=1` fails since `4 !< 4`); `s=7 -> i=2` (`0 <= 7-4=3 < 4`). Full
table `[1,1,1,1,2,2,2,2]`, identical to `src/samplers/ldt.jl:47` and to the literal list asserted at
`test:109`. `chi` also throws when `m` does not divide `q` (`ldt.jl:46`), matching the hypothesis.
Hand restrictions of `g = 1+x_1+x_1x_2` also reproduce: axis line `(0,5)+t(1,0)` gives
`[1,5,2,6,7,3,4,0]`, diagonal `(3,0)+t(2,7)` gives `[2,7,0,5,1,4,3,6]`; seed `(3,5,4,6,7)` gives
`chi(4)=2`, `pi_1((6,7))=(0,7)`, `L_ALine=(3,0,4,0,0)`, `L_DLine=(3,0,4,0,7)`,
`L_Point=(3,5,0,0,0)` — matching the printed `TB1 TRACE` and the `pi_separator`/`lnf_separator`
assertions.

**(3) `apply(L_DLine_6)` at `q=2^11, m'=16` — CONFIRMED microseconds; the printed figure is a
warm-memo figure.** Measured by me on the archived copy, load ≈ 2.2:

```
apply(L_DLine_6) WARM MEMO (the suite's method), best of 5: 2.41 us/call
apply(L_DLine_6) FRESH SEEDS, best of 5 x 1000 distinct:    5.87 us/call
```

The reported 2.13 µs reproduces (2.41 µs), but `test/tb2_answer_reduce.jl:109-114` pre-applies the
*same* 20 seeds into the memo before timing 50 repeats of them, so the printed number is a cache-hit
cost, not the cost of a fresh question. The honest figure is 5.87 µs; the `< 1_000` assertion holds
either way. O5's demand ("microseconds, not days") is met by a factor of ~8·10^10. → N7.

**(4) CONSTRUCTED level by nesting depth — CONFIRMED for all three maps** (walked structurally
through `child_shape`, not via `level`):

```
L_Point nesting=1 level()=1 factors=[[1,2]]        terminal CLZero register=[3,4,5]
L_ALine nesting=2 level()=2 factors=[[3,4,5],[1,2]] terminal CLZero register=[]
L_DLine nesting=3 level()=3 factors=[[3],[4,5],[1,2]] terminal CLZero register=[]
```

Depth equals the reported level in every case, and `register_indices == (1,2,3,4,5)` for all three.
The `L_Point` row is the subject of N3.

**(5) The five r1 survivors are registered and KILLED — CONFIRMED in my own registry run:**

```
MUTANT TB1 N1 line_point_test_always_agrees        target=tb1_decider_rejections => KILLED (exit=1, 14.03 s)
MUTANT TB1 N2 drop_point_on_left_symmetrization    target=tb1_decider_rejections => KILLED (exit=1, 15.96 s)
MUTANT TB1 N3 verifier_diagonal_line_skips_pi      target=tb1_decider_rejections => KILLED (exit=1, 16.10 s)
MUTANT TB1 N4 drop_point_on_line_verification      target=tb1_decider_rejections => KILLED (exit=1, 14.97 s)
MUTANT TB1 N5 question_format_accepts_any_arity    target=tb1_decider_rejections => KILLED (exit=1, 13.21 s)
```

---

## 2. New objections

### N1 — **MAJOR** — `fig:ld-decider`'s *diagonal* answer-format degree bound `md` is not red-capable

**Location.** `src/verifiers/ldt.jl:69-76` (`bound = … elseif kind == :DLine; params.m * params.d`),
`:77` (`rule = … :ld_diagonal_degree`). Against `gt-07-ldt.tex:359-360` (`fig:ld-decider`'s answer
table: `DLine` answers are "`ldc` degree-`md` polynomials") and rk-light law 4.

**My independent computation.** New mutant, applied on a copy (`mktempdir`, mutated file
`Base.include`d into the loaded module, the archived tree never modified), full TB1 file with
`TB1_TARGET=all`:

```
NEWMUTANT NM1 diagonal_answer_accepts_any_degree   ("params.m * params.d" -> "typemax(Int)")  => SURVIVED (exit=0)
NEWMUTANT NM4 control_restrict_drops_constant_term                                            => KILLED   (exit=1, "TB1 all honest line restrictions")
```

The axis bound is owned by `M-deg` (`params.d -> params.m*params.d`, KILLED). The diagonal bound has
no owner at all: the whole suite accepts a decider that imposes *no* degree bound on `DLine`
answers. `:ld_diagonal_degree` is never the rule of any asserted result — `grep` over
`test/tb1_ld_sampler.jl` returns zero hits — while `:ld_axis_degree` has two. This is the residue of
r1 O2 in its answer-format half, on the one side the repair did not cover.

**FIX DEMAND.** Add to `decider_rejections` a diagonal analogue of the `degree` testset: on
`raw_d = (3,0,0,2,7)` submit `restrict(x_1^2*x_2, diagonal_line(raw_d,2))` (individual degree 3 > `md = 2`)
against the honest point answer and assert `rule == :ld_diagonal_degree`, `location == (:left, 1)`,
`!passed`; register `tb1_dline_degree.jl` (`"elseif kind == :DLine\n        params.m * params.d"` →
`"elseif kind == :DLine\n        typemax(Int)"`, target `tb1_decider_rejections`) and show it KILLED.

**SURVIVING WEAKER STATEMENT.** `ld_decider` enforces the `ALine` answer-format bound `d` (red-tested)
and, on all 71,360 honest support decisions, never rejects an honest `DLine` answer of degree `<= md`;
no evidence in the rung shows that the `DLine` bound `md` can reject anything.

### N2 — **MAJOR** — the lazy `CLStep`'s continuation validation — the sole enforcement of DD-7's "level is impossible to forge" after the O5 repair — has no red test

**Location.** `src/samplers/cl.jl:103-116` (`_child`: the field / seed-dimension / rest-register /
child-level checks) and `:90-95` (the do-block `CLStep` constructor's `require_ambient=true`).
Against `docs/DESIGN.md:341-344` ("the branch is evaluated lazily on demand (**memoised and
validated**) … Therefore 'is CL of level ell' is CONSTRUCTED, not discovered by sampling") and
DD-7 ("level is then impossible to forge"), and rk-light law 4.

**My independent computation.** Two more new mutants, same isolation:

```
NEWMUTANT NM2 child_skips_continuation_level_check  ("level(child) == level(L.child_shape) ||" -> "true ||")     => SURVIVED (exit=0)
NEWMUTANT NM3 doblock_constructor_skips_span_check  ("matrix, child_shape, branch;\n require_ambient=true)" ->
                                                     "…require_ambient=false)")                                   => SURVIVED (exit=0)
```

Before the O5 repair the level was a property of a fully materialised branch *table*, so the
datatype could not lie. After it, `level(L) = 1 + level(L.child_shape)` describes a *shape*, and the
only thing tying the function `apply` actually evaluates to that shape is `_child`'s run-time check
on each reached key. That check is never exercised: nothing in the lane ever hands `CLStep` a branch
that returns a wrong-level, wrong-register, wrong-dimension or non-`AbstractCL{F}` continuation.
`M-ambient` covers the *other* constructor's span check only, so NM3 walks through the gap. For the
three TB1 maps the claim is unaffected — the exhaustive 32,768-seed enumeration reaches and validates
every key — but the datatype's advertised forgery-resistance is "runs without errors", not a test.

**FIX DEMAND.** Add to the `levels` testset four `@test_throws ArgumentError` cases, each reached by
an `apply` (the branch is lazy, so construction alone will not fire them): a branch returning
(a) a child of the wrong level, (b) a child on the wrong rest register, (c) a child of the wrong
`seed_dim`, (d) a non-`AbstractCL{F}` value; plus a `@test_throws ArgumentError` on the **do-block**
constructor with non-spanning `factor ∪ rest`. Register `tb1_child_validation.jl`
(`"level(child) == level(L.child_shape) ||"` → `"true ||"`, target `tb1_levels`) and
`tb1_ambient_doblock.jl` (the do-block `require_ambient=true` → `false`, target `tb1_levels`); show
both KILLED.

**SURVIVING WEAKER STATEMENT.** For `L_Point`, `L_ALine` and `L_DLine` at `(8,2,1)` the nesting depth
is 1, 2, 3 and every continuation reached by the exhaustive enumeration is validated at run time, so
the depth genuinely describes `apply` on those three maps; for an arbitrary `CLStep` value the
"level cannot be forged" property of DD-7 is asserted by DESIGN and unwitnessed by any test.

### N3 — **MAJOR** — `L_Point`'s constructed factor-space witness violates `lem:cl-kth` `enu:cl-space-sum`, and TB1 omits precisely the replay that TB2 runs

**Location.** `src/samplers/ldt.jl:56-65` (`_build_L_Point`: `factor = 1:m`, `rest = m+1:2m+1`,
terminal `CLZero(F, n, rest)`). Against `gt-04-cl.tex:151-160` (`lem:cl-kth`
condition `enu:cl-space-sum`: `V = ⊕_{i=1}^{ℓ} V_{i, x^{L_{<i}}}` **for all `x`**),
`gt-07-ldt.tex:203-207` ("`L_Point` … the 1-level CL function that **projects onto** `V_pt`"),
`docs/DESIGN.md:352-353` ("`marginal_k` returns the first `k` stages and their factor spaces/linear
maps, **matching `lem:cl-kth`**") and `docs/DESIGN.md:1122-1129` (§9.2: the mandatory
`enu:cl-space-sum` replay "checks disjoint coordinate indicators and that their union is the full
length-`Dimension(n)` ambient basis").

**My independent computation.** I ran on the three TB1 maps exactly the replay
`test/tb2_answer_reduce.jl:88-92` already runs on the 18 PCP maps:

```
TB1 L_Point: level=1 factors=[[1,2]]           union==1:5 ? false   sum(len)==5 ? false
TB1 L_ALine: level=2 factors=[[3,4,5],[1,2]]   union==1:5 ? true    sum(len)==5 ? true
TB1 L_DLine: level=3 factors=[[3],[4,5],[1,2]] union==1:5 ? true    sum(len)==5 ? true
```

`L_Point`'s single factor space is `span{e_1,e_2}`, not `F_q^5`; coordinates 3,4,5 live only in the
level-0 terminal, which is not a factor space. `L_Point` *is* a 1-level CL function (`lem:cl-kth` is
an existence statement, and `V_1 = V`, `L_1 = pi_{V_pt}` is a valid witness), but the witness the
rung constructs and exposes through `marginal_k` is not one, and TB1's testset deliberately omits
the union/partition assertions TB2 makes 200 lines away — the same "the suite is blind exactly
where it would catch this" pattern r1 O2 established. `src/samplers/pcp_sampler.jl:74-78` already
uses the correct convention for its own `Point_i` (`ambient = collect(1:n)` with the projector as
the stage matrix), so the repo carries two contradictory conventions for one object.

**I verified the repair end to end on a copy**, replacing
`CLStep(F, n, point, rest, _identity_matrix(F, dimension), tail)` by
`CLStep(F, n, Tuple(1:n), (), <n×n projector onto 1:m>, CLZero(F, n, ()))`:

```
FIXED L_Point level=1 factors=[[1,2,3,4,5]] union==1:5 ? true  sum(len)==5 ? true
… whole TB1 file green, EXIT=0, every count unchanged
(512, 18432, 32768, 98304, 71360/40768, 16, 568, 128/{256}, 4096/{4,36})
```

so the fix is pointwise identical on all `8^5` seeds, changes no histogram, and is closer to the
source's own wording ("projects onto `V_pt`").

**FIX DEMAND.** Rebuild `_build_L_Point` in the ambient-factor form above (verified equivalent), and
add to the `levels` testset the TB2 replay for all three maps:
`Set(Iterators.flatten(marginal_k(L,seed,level(L)).factor_spaces)) == Set(1:5)` and
`sum(length, factor_spaces) == 5`; register `tb1_space_sum.jl` reverting `_build_L_Point` to the
sub-ambient factor and show it KILLED. Then strike the **Scope** clause from the C4a row authorized
in §5.

**SURVIVING WEAKER STATEMENT.** `L_Point`, `L_ALine` and `L_DLine` are CL functions of nesting depth
1, 2, 3 whose per-stage `factor`/`rest` registers are disjoint coordinate-index sets whose union is
the ambient basis (`def:cl-func`), and `marginal_k` satisfies `lem:cl-kth` item 3 on all 98,304
replays; for `L_Point` the constructed factor-space family does not satisfy `lem:cl-kth` item 2, so
`marginal_k`'s "matching `lem:cl-kth`" is item-3-only for that map.

### N4 — **MINOR** — the off-line totalization of `fig:ld-decider` items 2/3 is an ungraded, unrecorded `SOURCE_REPAIR`

**Location.** `src/verifiers/ldt.jl:103-110` (`_line_parameter`), `:119-120` (`on_line || return
CheckResult(false, rule; …)`). Against `gt-07-ldt.tex:377-384` and its preamble "In all cases where
no action is indicated, accept", and `docs/definitions.md:179` / DESIGN §3.

**My independent computation.** The source's items 2 and 3 read "accept iff `f_j(t) = (a_w̄)_j` for
all `j`, **where `t` is such that** `x_w̄ = u_0 + t e_i` (resp. `u_0 + t v'`)". When the point is not
on the line no such `t` exists, so the universally quantified condition is vacuously true and the
*literal* reading accepts; the executable rejects with `:ld_axis_point`/`:ld_diagonal_point`
(exercised at `test:401-406`). The executable is strictly stricter, so soundness is unaffected and
completeness is untouched — I confirmed that **0 of the 71,360** honest support decisions reach the
branch, because all nine ordered type pairs are generated from one shared seed. But this is exactly
the divergence TB2 records as `SOURCE_REPAIR(:PCPGameOtherwiseFallthrough)`
(`src/verifiers/answer_reduce.jl:81-82`, tb2-r1 O8 DOWNGRADED); TB1 records nothing, so the same
class of decision is graded in one rung and invisible in the other.

**FIX DEMAND.** Emit `CertNode(SOURCE_REPAIR, :ld_off_line_rejects; facts=(honest_support_hits=0, of=71360))`
on the decider evidence path (or, if TB1 keeps no decider certificate, add the two-line
`SOURCE_REPAIR` comment at `verifiers/ldt.jl:119` naming `gt-07-ldt.tex:377-384` and the literal
alternative), and say in one clause of the C4a/C9 scope which reading is implemented.

**SURVIVING WEAKER STATEMENT.** `D^ld` rejects a line-versus-point pair whose point is off the line;
this is a strictly stricter totalization of `fig:ld-decider` items 2/3, is never reached by honest
play at `(8,2,1)`, and is not attributed to the source.

### N5 — **MINOR** — `pad_level` prepends the empty factor, contradicting DESIGN §9.4, and a padded `CLZero` has no factor spaces at all

**Location.** `src/samplers/typed.jl:3-16`. Against `docs/DESIGN.md:1186-1190` (§9.4: "A genuine
`r>=1`-level child padded to a larger level **keeps its first `r` factors and appends empty
factors**. A whole-space zero map is instead promoted from level 0 by `rk:higher-level`: **stage 1
reports the all-ones indicator for its entire ambient space and the zero linear map**, and stages
`2..ell` report empty factors" — tagged `SOURCE_REPAIR(zero-map-factor-partition)`) and
`gt-04-cl.tex:121-129` (`rk:higher-level`, which promotes with `V_1 = V`).

**My independent computation.**

```
pad_level(L_ALine,2 -> 3)      factors = [Int64[], [3,4,5], [1,2]]     (DESIGN 9.4 requires [[3,4,5],[1,2],[]])
pad_level(CLZero(GF8,5),0 -> 3) factors = [Int64[], Int64[], Int64[]]  union==1:5 ? false
```

For a genuine map the union survives, so nothing is currently wrong; the divergence is in *which*
stage carries which factor, which is observable through `Marginal(1,·)` and therefore matters at the
description boundary (`Marginal(1,z)` is `0` for every padded map here, and would be the original
first stage under §9.4). For a whole-space zero map — which §9.4 says `typed_anchor_sampler`, the
Pauli sampler and `tilde S^intro` will all originate at TB5/TB6 — the code's convention produces a
level-`ell` witness with `⊕_i V_i = {0} != V`, failing `enu:cl-space-sum` outright.

**FIX DEMAND.** Change `pad_level` to append the empty stage at the tail of the chain rather than
prepend it at the head, and special-case `pad_level(CLZero(F,n,1:n), ell)` to emit stage 1 with the
whole ambient register and the zero matrix (tagging `SOURCE_REPAIR(zero-map-factor-partition)` as
§9.4 requires); assert `marginal_k(pad_level(L_ALine,3), seed, 1).value == marginal_k(L_ALine, seed, 1).value`
and the zero-map factor partition; register a mutant swapping the two orders.

**SURVIVING WEAKER STATEMENT.** `pad_level(L, t)` produces a CL value of level exactly `t` that is
pointwise equal to `L` (`rk:higher-level` is satisfied); its stage *ordering* is the reverse of the
one DESIGN §9.4 fixes, and its `CLZero` case has no factor partition.

### N6 — **MINOR** — the `chifree` testset, added to discharge r1 O1, has no registered mutant

**Location.** `test/tb1_ld_sampler.jl:51-67, 139-151`; `test/mutations/run.jl:82-112` (no TB1 mutant
targets `chifree`). The proposer states "the `chifree` testset is a fact check with no src owner by
construction" — true of `src/`, but law 4 does not exempt an assertion from having a red test, and
`run.jl` already supports test-file mutants (`F`, `K` target `test/tb0_core.jl`).

**My independent computation.** Both test-file mutants I tried are killed, so the testset *is*
red-capable — it simply has no registered witness:

```
NEWMUTANT NM5 chifree_reference_shifts_pi_prefix  ("j < i" -> "j <= i" in tb1_chifree_marginals) => KILLED (exit=1)
NEWMUTANT NM6 chifree_reference_draws_i_from_chi  (i drawn from one bucket instead of uniformly)  => KILLED (exit=1)
```

**FIX DEMAND.** Register NM5 as `test/mutations/tb1_chifree.jl`
(`Mutant("TB1 M-chifree pi_prefix_off_by_one", "test/tb1_ld_sampler.jl",
"        v_prime = ntuple(j -> j < i ? zero(TB1_F) : v[j], TB1_M)\n        axis_key",
"        v_prime = ntuple(j -> j <= i ? zero(TB1_F) : v[j], TB1_M)\n        axis_key",
"tb1_chifree")`) and show it KILLED.

**SURVIVING WEAKER STATEMENT.** The four `chifree` assertions (128/{256}, 4,096/{4,36}) are true —
I recomputed them independently — and are red-capable; they are not yet part of the ratcheted red
corpus.

### N7 — **NOTE** — the printed `DLine_6 apply=2.1 us` is a warm-memo figure

`test/tb2_answer_reduce.jl:109-114` applies the same 20 seeds before timing 50 repeats of them, so
the number measures `_child` cache hits. Fresh questions cost **5.87 µs/call** (my measurement,
1,000 distinct seeds, best of 5). Both are microseconds and both satisfy `< 1_000`. **FIX DEMAND:**
print both, or time on fresh seeds; say "warm memo" where the memo is warm.

### N8 — **NOTE** — the TB0 gate crosses its 45 s warning under concurrent load

My two runs of the identical archived tree: **36.302 s** on a quiet box (load 2.06, matching the
proposer's 36.415 s cold / 40.374 s warm) and **47.621 s** with a codex worker running (load 3.81).
Both are far inside the 60 s hard gate and both exit 0, so this is a NOTE with both walls, per the
brief's timing caveat — but the 45 s warning fires under exactly the concurrency this campaign runs
under. Same caveat for the mutation registry: **404.79 s** here vs the reported 230.24 s, with
identical dispositions.

### N9 — **NOTE** — lockstep: two stale rows in `claims/CLAIMS.md`

(a) C4a's `where-tested` column still reads `(levels, histogram_axis, histogram_diagonal, marginals);
red: test/mutations/tb1_{chi,pi,lnf,level}.jl` — the tree now has the `chi` and `chifree` testsets
and 15 TB1 mutants. §5 authorizes the replacement. (b) C4b's **Missing step** paragraph asserts
"`CLStep` materialises its branch table eagerly, so at DESIGN §5.4's `q=2^11` a single `L_ALine`
stage enumerates `2048^3` domain points and `L_DLine_6`'s direction stage would need up to `2048^15`
branch entries (`verdicts/tb1-r1.md` O5)". **That sentence is now false of the tree**: `CLStep` is
lazy and all 18 maps are built and applied at `(q,m,d,s,m')=(2048,1,11,6,16)` in microseconds. I
authorize the deletion of that sentence (it is my own prior verdict's text and its premise is
discharged); the replacement "Missing step" is TB2 evidence and belongs to `verdicts/tb2-r2.md`
(brief 41) — C4b stays CONJECTURE either way and no TB1 evidence bears on it.

### N10 — **NOTE** — elegance residue from r1 §6, and one addition

Fixed since r1: `tb1_actual_histogram` (deleted), the `GF8`-keyed sampler cache (deleted), the
double `CLMarginal` in `marginal_k` (deleted), `_truncate_univariate` (deleted). Still present:
the identical-branch ternary `valid ? :ld_point_format : :ld_point_format`
(`src/verifiers/ldt.jl:66`) and `const D_ld = ld_decider` exported and never used (`:166`,
`MIPStarLambda.jl:51`) — both one-line deletions. New: `_child`'s memo `Dict{Vector{F},AbstractCL{F}}`
never evicts; I measure ≈ **1 cached `CLStep` node and 2.4 memo entries per distinct query** at
`q=2^11, m'=16` (119 nodes / 298 entries after 100 seeds; 4,994 / 11,846 after 5,000). Linear and
harmless at TB1/TB2 scale, unbounded at the §9.1 `Linear(j,u,y)` boundary, whose prefix domain is
all of `V_{<j}`.

### N11 — **NOTE** — `non_noop = 40,768` still contains 2,880 tautological decisions

Independently: of the 40,768 non-`:ld_noop` decisions, **2,880** are equal-type pairs whose left and
right questions are *literally identical* (verified: every equal-type support pair satisfies
`p[1] == p[2]`), so `:ld_consistency` is a tautology across the entire honest sweep; the remaining
**37,888** are line-versus-point. The rejection evidence for `:ld_consistency` is still the single
hand-built mismatch at `test:335-336`. Printing the 2,880/37,888 split alongside `non_noop` would
make the sweep's coverage honest at a glance.

---

## 3. Test and mutation runs observed (archived copy, Julia 1.12.5)

`julia --project=. test/runtests.jl` — **exit 0, 224/224**, twice:

| run | load at start | `MIPStarLambda load/precompile` | TB0 test-body wall | suite wall | exit |
|---|---|---|---|---|---|
| loaded (codex worker running) | `3,81 3,45 3,01` | 0.443 s | **47.621 s** (warning 45, gate 60) | 1m56.58 | 0 |
| quiet | `2,06 6,06 5,44` | 0.288 s | **36.302 s** | 1m33.81 (maxrss 952 MiB) | 0 |

```
Test Summary:                                             | Pass  Total     Time
MIPStarLambda                                             |  224    224  1m32.3s
  TB0 60 s test-body hard limit (measured 36.302 s)       |    1      1     0.0s
  TB1 datatype levels                                     |   10     10     2.7s
  TB1 eq:chi-func buckets and joint histogram (M-χ owner) |    2      2     1.1s
  TB1 pi-prefix sampler separator                         |    1      1     0.2s
  TB1 canonical-complement sampler separator              |    1      1     0.0s
  TB1 genuinely chi-free lem:alnf/lem:dlnf marginals      |    4      4     0.3s
  TB1 exact axis histogram (M-χ owner)                    |    3      3     0.1s
  TB1 exact diagonal histogram (M-π, M-lnf owner)         |    8      8     0.7s
  TB1 exhaustive marginal replay                          |    3      3     0.5s
  TB1 all honest line restrictions                        |    5      5     0.4s
  TB1 D^ld honest deterministic sweep and consistency     |    6      6     1.6s
  TB1 D^ld rejections                                     |   11     11     0.6s
  TB1 axis degree rejection (M-deg owner)                 |    5      5     0.1s
  TB1 sampled question-pair trace                         |    3      3     0.4s
TB0 test-body wall seconds = 36.302 (warning=45.0, hard_limit=60.0)
TB1 chi-free marginals: axis support=128 mass={256}; diagonal support=4096 mass={4,36}; M-χ undetectable here
TB1 axis histogram: seeds=32768 support=512 total=32768
TB1 diagonal histogram: seeds=32768 support=18432 total=32768 zero_direction_support=512
TB1 marginal replay: seeds=32768 samplers=3 replays=98304
TB1 restrictions: axis_lines=16 diagonal_representatives=568 degree_bounds=1/2
TB1 D^ld: type_pairs=9 seeds=32768 support_decisions=71360 non_noop=40768 equal-type mismatch_rule=ld_consistency
TB1 degree separator: point=(3, 5) claimed_d=1 actual_degree=2 format_rule=ld_axis_degree point_rule=ld_axis_point
```

`julia --project=. test/mutations/run.jl` — **exit 0, killed=37/37, wall 404.79 s** (load rose to
11.98 during the run; the proposer's 230.24 s figure is a quiet-box figure and I do not dispute it):

```
package image ready after 0.49 s
MUTANT D corrupt_field_reduction                       target=field          => KILLED (exit=1,   7.18 s)
MUTANT C omit_output_literal                           target=circuit        => KILLED (exit=1,   8.96 s)
MUTANT A e-2_to_e-1                                    target=zero_basis     => KILLED (exit=1,  10.00 s)
MUTANT C8 occurrence_ignores_fanout                    target=c8             => KILLED (exit=1,   8.94 s)
MUTANT E w1_fanout_2_to_1                              target=occurrence     => KILLED (exit=1,  21.04 s)
MUTANT B omit_g2_minus_o2                              target=pcp_separator  => KILLED (exit=1,  31.47 s)
MUTANT G g_a_reverse_bit_order                         target=encoding       => KILLED (exit=1,  12.66 s)
MUTANT F degenerate_witness_ii_a3                      target=nondegenerate  => KILLED (exit=1,  24.67 s)
MUTANT H ind_reverse_bit_order                         target=encoding       => KILLED (exit=1,  12.71 s)
MUTANT K witness_iff_reverses_factor                   target=witness_iff    => KILLED (exit=1,   8.25 s)
MUTANT I restore_GF2k_accumulator_bug                  target=zero_basis     => KILLED (exit=1,  11.83 s)
MUTANT M drop_nonprime_multiply_guard                  target=nonprime       => KILLED (exit=1,  10.56 s)
MUTANT J ev_z_ignores_c0_terms                         target=c0_terms       => KILLED (exit=1,  25.44 s)
MUTANT L PCPVerifier_replays_degree_only               target=certificate    => KILLED (exit=1,  25.07 s)
MUTANT TB1 M-χ shift_bucket_boundary                   target=tb1_chi_boundary      => KILLED (exit=1,  8.66 s)
MUTANT TB1 M-π omit_prefix_projection                  target=tb1_pi_separator      => KILLED (exit=1,  9.15 s)
MUTANT TB1 M-lnf noncanonical_complement               target=tb1_lnf_separator     => KILLED (exit=1,  9.41 s)
MUTANT TB1 M-deg axis_accepts_md                       target=tb1_degree            => KILLED (exit=1,  9.12 s)
MUTANT TB1 M-level omit_inductive_increment            target=tb1_levels            => KILLED (exit=1, 17.11 s)
MUTANT TB1 N1 line_point_test_always_agrees            target=tb1_decider_rejections=> KILLED (exit=1, 14.03 s)
MUTANT TB1 N2 drop_point_on_left_symmetrization        target=tb1_decider_rejections=> KILLED (exit=1, 15.96 s)
MUTANT TB1 N3 verifier_diagonal_line_skips_pi          target=tb1_decider_rejections=> KILLED (exit=1, 16.10 s)
MUTANT TB1 N4 drop_point_on_line_verification          target=tb1_decider_rejections=> KILLED (exit=1, 14.97 s)
MUTANT TB1 N5 question_format_accepts_any_arity        target=tb1_decider_rejections=> KILLED (exit=1, 13.21 s)
MUTANT TB1 M-repair drop_lnf_zero_direction_node       target=tb1_histogram_diagonal=> KILLED (exit=1, 16.96 s)
MUTANT TB1 M-concat drops_left_level                   target=tb1_levels            => KILLED (exit=1, 17.25 s)
MUTANT TB1 M-dsum direct_sum_forgets_stages            target=tb1_levels            => KILLED (exit=1, 16.33 s)
MUTANT TB1 M-ambient constructor_skips_span_check      target=tb1_levels            => KILLED (exit=1, 21.53 s)
MUTANT TB1 M-kappa line_point_checks_first_entry_only  target=tb1_decider_rejections=> KILLED (exit=1, 16.60 s)
MUTANT TB2 c0_plus_one_formula                         target=tb2_formula           => KILLED (exit=1, 127.25 s)
MUTANT TB2 truncate_line_polynomial                    target=tb2_line              => KILLED (exit=1, 137.41 s)
MUTANT TB2 g3_plus_one_individual_only                 target=tb2_proof_consistency => KILLED (exit=1, 146.85 s)
MUTANT TB2 M-guard Point_ALine_to_Point_DLine          target=tb2_guard             => KILLED (exit=1, 141.20 s)
MUTANT TB2 M-i345 extend_to_i12                        target=tb2_i345              => KILLED (exit=1, 105.92 s)
MUTANT TB2 MC1 sampler_dline_skips_pi                  target=tb2_branches          => KILLED (exit=1, 146.38 s)
MUTANT TB2 MC2 input_consistency_compares_other_block  target=tb2_branches          => KILLED (exit=1, 145.44 s)
MUTANT TB2 MC3 simultaneous_test_uses_ldparams_not_ldparams_prime target=tb2_branches => KILLED (exit=1, 144.25 s)
Test Summary:               | Pass  Total  Time
isolated targeted mutations |    1      1  0.3s
MUTATION REGISTRY: killed=37/37 wall=404.79 s
```

No FATAL: the suite runs green, the runner runs green, every registered mutant is killed, no bare
`@assert` appears anywhere in `src/` or `test/`, and no status was raised by the proposer.

## 4. My new mutations

Applied on copies only (`mktempdir`, the mutated file written to the sandbox and `Base.include`d
into the loaded module; the archived tree never modified). Runners:
`…/critic-tb1-r2/indep/{newmut.jl,newmut2.jl}`.

| id | file:site | semantic change | outcome |
|---|---|---|---|
| NM1 | `src/verifiers/ldt.jl:72` | `DLine` answer-format bound `params.m*params.d` → `typemax(Int)` (`fig:ld-decider`'s degree-`md` answer table) | **SURVIVED** → N1 |
| NM2 | `src/samplers/cl.jl:112-113` | `_child` drops `level(child) == level(L.child_shape)` (DD-7's forgery guard) | **SURVIVED** → N2 |
| NM3 | `src/samplers/cl.jl:93-94` | the do-block `CLStep` constructor skips the ambient-span check | **SURVIVED** → N2 |
| NM4 (control) | `src/verifiers/ldt.jl:24` | `restrict` shifts every coefficient by 1 | KILLED by `TB1 all honest line restrictions` |
| NM5 | `test/tb1_ld_sampler.jl:60` | `chifree` reference off-by-one in `pi_{i-1}` (`j < i` → `j <= i`) | KILLED → N6 (registrable, unregistered) |
| NM6 | `test/tb1_ld_sampler.jl:55` | `chifree` reference draws `i` from one bucket instead of uniformly | KILLED → N6 |

Three survivors ⇒ N1, N2. The control confirms the harness is red-capable, and NM5/NM6 confirm the
`chifree` assertions can fail.

## 5. Per-claim decision

| claim | decision | note |
|---|---|---|
| **C4a** | **PROMOTE — keep TESTED, replace the row with the authorized text below** | every number in the row independently reproduced; the statement is scoped for N3 and must be re-scoped (clause struck) by the r3 verdict once N3 is fixed |
| **C4b** | **HOLD at CONJECTURE**; the O5-based "Missing step" sentence is **authorized for deletion** (its premise is discharged: `CLStep` is lazy and all 18 maps are built at `q=2^11`). The replacement missing-step text is TB2 evidence and is deferred to `verdicts/tb2-r2.md` (brief 41). |
| **C7** | HOLD at CONJECTURE; unchanged. `depends-on = C4a,C4b` is already correct. |
| C1, C2, C3, C5, C6, C8, C12–C15, N1 | unchanged — outside this rung's lane; no TB1 evidence bears on them |

**C4a — AUTHORIZED VERBATIM ROW (copy exactly; format adaptations only in surrounding scaffolding):**

> | C4a | (Sampler is CL — TB1 instance) For `(q,m,d)=(8,2,1)` and ambient `V=V_pt (+) V_coord (+) V_dir` of `seed_dim` 5, `L_Point`, `L_ALine` and `L_DLine` are CL functions of constructed nesting depth 1, 2 and 3 respectively — upper bounds in the sense of `rk:higher-level`, not minimality claims — built only from `CLStep` stages whose factor and rest registers are disjoint coordinate-index sets whose union is all of `{1,...,5}`, with lazily evaluated continuations validated (field, seed dimension, rest register, child level) on every key reached by the exhaustive enumeration; `apply` equals the sum of the first `level` stage outputs on all `3 x 8^5 = 98,304` marginal replays (`lem:cl-kth` item 3); and over all `8^5 = 32,768` seeds the induced distributions `mu_{L_ALine,L_Point}` and `mu_{L_DLine,L_Point}` have exact histograms of support 512 and 18,432 (mass 32,768 each; 512 zero-direction support points carrying 2,304 seeds) agreeing entry-for-entry with a separately transcribed evaluation of `eq:cl-ptf`/`eq:cl-alnf`/`eq:cl-dlnf` **including `eq:chi-func`** — the comparison is NOT `chi`-independent (`verdicts/tb1-r1.md` O1) — and on the 512 zero-direction points the equality additionally rests on the DESIGN `SOURCE_REPAIR` `L^lnf_0 = id`, which `def:cl-canonical` does not define (O3), emitted as a `SOURCE_REPAIR` `CertNode` under the CHECKED histogram node. The separately asserted `chi`-free content of `lem:alnf`/`lem:dlnf` is the marginal support 128 (all masses 256) and 4,096 (masses 4 and 36). **Scope:** the constructed factor-space witness satisfies `lem:cl-kth` item 3 but, for `L_Point`, not item 2 (`enu:cl-space-sum`): its single factor register is `{1,2}`, not all of `{1,...,5}` (`verdicts/tb1-r2.md` N3). No claim is made here about `D^ld`, about `concatenate`/`direct_sum`/`product`/`TypedSampler`, or about any other `(q,m)`. | TESTED | D2 | — | `test/tb1_ld_sampler.jl` (`levels`, `chi`, `chifree`, `histogram_axis`, `histogram_diagonal`, `marginals`); red: `test/mutations/tb1_{chi,pi,lnf,level,repair,ambient,dsum,concat}.jl` | `verdicts/tb1-r1.md`, `verdicts/tb1-r2.md` |

**Lockstep follow-ups for the orchestrator** (not TB1's lane): delete the O5 sentence from C4b's
"Missing step" (N9b); DESIGN §5.3's `chi` paragraph is already correct at `a4dc22a` — no further
edit; DESIGN §1.5's invariant row "equality to paper distributions | CHECKED | TB1 exact histograms"
now has its `SOURCE_REPAIR` residue visible in the certificate, which discharges the r1 follow-up.

## 6. Forward look — does TB1's datatype support DESIGN §9's `SamplerDescription` adapter?

1. `Dimension` and `Marginal` are ready (`seed_dim`; `marginal_k(L,z,j).value` walks exactly `j` nodes).
2. `Linear(j,u,y)` and `Factor(j,u)` have **no API**: `_child` is keyed on a stage's own local output,
   not on a prefix `u`; a `walk_prefix(L,j,u)` that splits `u` by each stage's factor register (legal,
   since the registers are coordinate sets) is missing, and §9.1 requires `Linear` to accept the broader
   *unreachable* `u in V_{<j}` while `Factor` takes `u in L_{<j}(V)`. NOTE.
3. §9.3's rule "an opaque host branch returns `NotDescribable`" bites immediately: **every** branch in
   the tree is an anonymous Julia closure (do-blocks, `_ -> child`, `v_prime -> …`), there is no
   `QuotedBranch` constructor, and `description_size = length(canonical_bytes(code))` is uncomputable
   from a `CLStep`. All 3 TB1 and all 18 PCP maps are currently `NotDescribable`. NOTE.
4. §9.2's mandatory `enu:cl-space-sum` replay fails today on `L_Point` (N3) and on
   `pad_level(CLZero(F,n),ell)` (N5); §9.4's padding order is the reverse of `pad_level`'s (N5).
5. `Factor` must return a length-`Dimension(n)` 0/1 indicator; `register_indices`/`marginal_k` expose
   index tuples instead — trivial but absent. NOTE.
6. `_child`'s memo never evicts (≈2.4 entries per distinct query at `q=2^11,m'=16`); §9.1's `Linear`
   domain is all of `V_{<j}`, so a description-level query loop needs a bounded cache or a memo-free
   descent. NOTE.

---

**What this round got right, for the record:** all four r1 MAJORs are genuinely discharged — the
`chi`-free mislabelling is replaced by an honest split (transcribed joint histogram vs. a separate
`chifree` testset whose two facts I recomputed independently); the five surviving decider mutants are
registered and killed and the decider now has eleven rejection assertions in both orders, at `kappa=2`,
and against an unprojected `DLine` question; the zero-direction `SOURCE_REPAIR` is a graded
`CertNode` with the exact facts `(512, 2304, 32768)` that my own enumeration produces; and the eager
branch table is gone, taking `L_DLine_6` at `q=2^11, m'=16` from r1's projected 5.4 days to 5.87 µs
on fresh questions. Every one of the report's printed numbers reproduces exactly against an
implementation written from the ground truth alone. The three MAJORs below are all on code that did
not exist a round ago, and each has a two-line fix — one of which (N3) I have already run green end
to end.

VERDICT: FAIL(N1,N2,N3)
