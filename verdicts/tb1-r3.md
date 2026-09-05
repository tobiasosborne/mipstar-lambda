# CRITIC verdict r3 — rung TB1 (`src/samplers/{cl,typed,ldt}.jl`, `src/verifiers/ldt.jl`, `test/tb1_ld_sampler.jl`, `test/mutations/tb1_*.jl`) at commit `dcaaf34`

Round 3 (adjudicate). **Prior.** `verdicts/tb1-r2.md` (FAIL(N1,N2,N3); C4a PROMOTE→TESTED with a
scope clause, C4b HOLD) is the work order, together with the §9 describability preparation that
`briefs/46-tb1-tb2-repair-r2-describable.md` made binding. Everything r2 accepted is settled and is
not re-litigated. The two MAJORs below are on code that did not exist at `a4dc22a`.

**Isolation.** `git archive dcaaf34 | tar -x -C <scratch>/tree` into
`/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-…/scratchpad/critic-tb1-r3/tree`,
`Pkg.instantiate()` there (cold precompile **206 s** on a box already precompiling the identical
tree for the TB2 critic), and every test, mutation and experiment run there. The live working tree
was never read or run for `src/`/`test/`; `docs/`, `claims/`, `briefs/` and `ground-truth/` were read
from the **archived** copy, and every `file:line` below is that copy. My only repo output is this
file. No git state-changing command was run.

**Independence.** §1's numbers come from a reference written from the ground truth alone
(`indep/ref.jl`): my own carry-less `GF(8)` (modulus `x^3+x+1`, associativity/distributivity/inverses
re-verified on all `8^3` triples), my own `chi` from `eq:chi-func`, my own `L^lnf` from
`def:cl-canonical`'s RREF pivot rule, my own `pi_{i-1}`, and the three maps built as explicit stage
lists straight from `gt-07-ldt.tex:203-237` — including the source's own decomposition sentences
("`L_Point` … projects onto `V_pt`"; `L_ALine` = concatenation of `V_coord (+) V_dir -> V_coord`
with `{L^lnf_{e_i}}` on `V_pt`; `L_DLine` = id on `V_coord`, `pi_{i-1}` on `V_dir`, `L^lnf_{v'}` on
`V_pt`). `enu:cl-space-sum`, `enu:cl-map-sum`, the chain counts and the description byte counts were
computed on that reference before the package was consulted. No code from `src/` is on that path.
Scratch: `indep/{ref.jl,probe.jl,guards.jl,newmut.jl,newmut2.jl,collide.jl}`.

**Lane check (law 1).** `git show --stat dcaaf34` touches `briefs/23,24`, `claims/CLAIMS.md`,
`docs/DESIGN.md` only (the orchestrator's lockstep); the rung's code landed at `9a55215`, whose
report confines itself to MERGE PROPOSALS for C4a/C4b/C9 and to DESIGN wording proposals. No status
was raised by the proposer. Law 1 respected.

---

## 0. Adjudication of the brief-46 response table

### 0.1 The r2 objections

| row | claimed | adjudicated | basis |
|---|---|---|---|
| N1 diagonal `md` bound | FIXED | **ACCEPTED** | `test/tb1_ld_sampler.jl:611-622`: `restrict(x_1^2 x_2, diagonal_line((3,0,0,2,7),2))` has degree 3 > `md = 2` and is rejected `:ld_diagonal_degree` at `(:left,1)`. I recomputed the line — base `(3,0)`, direction `(2,7)` (both entries nonzero, so `pi_0 = id`) — and the degree 3 myself, and confirmed the complementary fact the demand implies: the honest answer has degree exactly `md = 2` and is accepted (`:ld_diagonal_point`). `tb1_dline_degree.jl` is NM1 verbatim, carries `expected_evidence`, and I observed it KILLED. |
| N2 `_child` validation | FIXED | **ACCEPTED** | Four `@test_throws ArgumentError apply(...)` at `:104-120`, all reached through `apply`, plus the do-block span check at `:121-124`; `tb1_child_validation.jl` (NM2) and `tb1_ambient_doblock.jl` (NM3) both KILLED. Isolation verified guard by guard on a copy (§1.2). Residue: N21. |
| N3 `L_Point` ⊬ `enu:cl-space-sum` | FIXED | **ACCEPTED** | `src/samplers/ldt.jl:64-74` is the ambient-factor form I verified green in r2; `space_sum` (`:156-192`) runs the four-query replay exhaustively on all three maps, and the r2 sub-ambient `L_Point` is kept as a negative witness whose `space_sum_ok` is `false`. Every number reproduces against my reference (§1.1). `tb1_space_sum.jl` KILLED. C4a's scope clause is struck in §5. |
| N4 off-line totalization | FIXED | **PARTIAL** | The `SOURCE_REPAIR` comment at `src/verifiers/ldt.jl:119-124` names `gt-07-ldt.tex:377-384` and the literal vacuous-accept alternative — the demand's stated alternative, discharged. The sweep counts the branch (`off_line_hits = 0` of 71,360, reproduced) and asserts the node. But `ld_off_line_repair` is *constructed inside the test* and attached to no certificate, and the demand's third clause ("say in one clause of the C4a/C9 scope which reading is implemented") is undone. → N15. |
| N5 = TB2 N3 `pad_level` | FIXED | **ACCEPTED** | `_pad_tail` APPENDS (`typed.jl:32-37`, `BranchPadded`); measured: `pad(L_ALine,3)` factors `[[3,4,5],[1,2],[]]`, `marginal_k(pad,z,1) == marginal_k(L_ALine,z,1)` and `marginal_k(pad,z,2) == apply(L_ALine,z)` on all 64 seeds I swept, `pad(CLZero(F,5),3)` factors `[[1..5],[],[]]` with `Factor(·,1,0) = ones(5)` and a passing `cl_kth_replay`. `tb1_pad_order.jl` KILLED. Residue: N16 (the empty-register case). |
| N6 `chifree` unowned | FIXED | **ACCEPTED** | `tb1_chifree.jl` is my NM5 verbatim, a test-file mutant, KILLED. |
| N7 warm-memo timing | FIXED | **ACCEPTED** | Both figures printed: my run shows `DLine_6 apply=4.4 us (warm memo, 20 seeds x 50); 13.23 us (1000 fresh seeds)` — larger than the proposer's 2.09/6.95 because my box carried load 13, but both are microseconds and both are labelled. |
| N8 walls | NOTE | **ACCEPTED as NOTE** | §3. |
| N9 lockstep | proposals | **ACCEPTED, one gap** | C4a's where-tested cell is proposed correctly (all 10 testsets and all 19 mutant files exist). C4b's O5 sentence is gone. Gap: DESIGN §1.5's `L_Point` line still carries no record of the N3 repair, and §9.4's citation is now corrupted. → N19. |
| N10 elegance | FIXED | **ACCEPTED** | `grep` finds no `D_ld` anywhere in `src/`/`test/`; the identical-branch ternary is gone (`verifiers/ldt.jl:66`); the memo is bounded (`CL_MEMO_LIMIT = 4096`). Residue: N22. |
| N11 tautology split | FIXED | **ACCEPTED** | `:544` asserts `(equal_type, line_vs_point) == (2_880, 37_888)` and their sum equals `non_noop = 40_768`; all three numbers are mine from r2. |

### 0.2 The §9-preparation items

| item | adjudicated | basis |
|---|---|---|
| `QuotedBranch` + `describe_cl` | **PARTIAL** | All 3 TB1 and all 18 PCP maps are describable with deterministic bytes, opaque closures give `NotDescribable`, and the three sizes 75/132/156 match my own reserialization exactly (§1.5). But the bytes are asserted only by *length* and *determinism*: nothing separates two distinct maps, and the encoder may ignore the stage matrices entirely and stay green. → **N12 (MAJOR)**. |
| prefix walks `Dimension/Marginal/Factor/Linear` | **ACCEPTED** | The §9.1 asymmetry is real and I measured it: of the 512 prefixes supported on `V_1 = {3,4,5}`, `Factor(L_ALine,2,·)` accepts exactly **8** — the size of `L_{<2}(V)`, the image `{(s,0,0)}` — and `Linear(L_ALine,2,·,y)` accepts all **512**, the size of `V_{<2}`; support outside `V_{<j}` is rejected by both. Residue: N14, N17. |
| `cl_kth_replay` (§9.2) | **PARTIAL** | `space_sum_ok`, the chain counts `[1,8,288]`, the replay counts and the negative witness all reproduce (§1.1). But the `enu:cl-map-sum` comparison itself can be deleted and the whole corpus stays green. → **N13 (MAJOR)**. |
| bounded memo | **ACCEPTED** | `max_entries = 1808 <= 4096` over 10^4 distinct `Linear` prefixes; `tb1_memo_unbounded.jl` KILLED. Residue: N22. |

---

## 1. Independent recomputation (the six brief obligations)

### 1.1 `_build_L_Point`'s ambient-factor form and the exhaustive `enu:cl-space-sum` replay

My reference and the package, side by side over all `8^5 = 32,768` seeds:

```
INDEP field laws over all 512 triples: true
INDEP L_Point  level=1 space_sum_ok=true map_sum_ok=true k_checks=32768 distinct_chains=1
INDEP L_ALine  level=2 space_sum_ok=true map_sum_ok=true k_checks=65536 distinct_chains=8
INDEP L_DLine  level=3 space_sum_ok=true map_sum_ok=true k_checks=98304 distinct_chains=288
INDEP factors  L_Point=[[1,2,3,4,5]]  L_ALine=[[3,4,5],[1,2]]  L_DLine=[[3],[4,5],[1,2]]

PKG   L_Point  factors=[[1,2,3,4,5]]  union==1:5? true  sum(len)==5? true  space_sum_ok=true map_sum_ok=true chains=1   kchecks=32768
PKG   L_ALine  factors=[[3,4,5],[1,2]] union==1:5? true sum(len)==5? true  space_sum_ok=true map_sum_ok=true chains=8   kchecks=65536
PKG   L_DLine  factors=[[3],[4,5],[1,2]] union==1:5? true sum(len)==5? true space_sum_ok=true map_sum_ok=true chains=288 kchecks=98304
```

Hand derivation of the chain counts, agreeing with both: `L_Point` has no conditioning stage, so one
chain; `L_ALine`'s chain is stage 1's output `(s,0,0)`, so 8; `L_DLine`'s chain is `(s, pi_{chi(s)-1}(v))`,
so `4·64` (the four `s` with `i=1`, every `v'`) `+ 4·8` (the four with `i=2`, `v'_1 = 0`) `= 288`.
The suite's printed `distinct_chains=[1, 8, 288]`, `completed_replays=[32768,32768,32768]` and
`map_sum_checks=[32768,65536,98304]` are exactly these. **No disagreement.** The ambient-factor form
is also what the source's own wording forces: `eq:cl-ptf` calls `L_Point` "the 1-level CL function
that **projects onto** `V_pt`", and `lem:cl-kth` `enu:cl-space-sum` at `ell = 1` reads `V = V_1`.

### 1.2 Isolation of the four `_child` guards (brief 46 unresolved item 5)

Each guard was deleted **alone** on a copy (`indep/guards.jl`, `mktempdir` + `Base.include`; the
archived tree untouched) and the four `levels` witnesses re-run through `apply`:

```
baseline           : wrong level/register/seed_dim/field  => all four throw ArgumentError
drop G1 (field)    : wrong field   => throws MethodError   (others unchanged, ArgumentError)
drop G2 (seed_dim) : wrong seed_dim=> NO ERROR             (others unchanged)
drop G3 (register) : wrong register=> NO ERROR             (others unchanged)
drop G4 (level)    : wrong level   => NO ERROR             (others unchanged)
```

G2, G3 and G4 are isolated perfectly: deleting one makes exactly its own witness pass and changes
nothing else, so each has a genuine red witness. G1 is **red-capable but not isolated**: with the
field guard deleted the wrong-field child is still rejected, by Julia's typed memo
(`Dict{Vector{F},AbstractCL{F}}` at `cl.jl:65`), as a `MethodError`. `@test_throws ArgumentError`
still fails, so the mutation is killed — but the witness does not show the guard is the *only*
enforcement. → N21 (NOTE).

### 1.3 `pad_level` APPENDS, and the `CLZero` promotion

```
PKG pad(L_ALine,3) factors=[[3,4,5],[1,2],Int64[]]
PKG marginal_k(pad,z,1)==marginal_k(L_ALine,z,1)? true   (value=(0,0,4,0,0))
PKG marginal_k(pad,z,2)==apply(L_ALine,z)?        true
PKG pad-vs-child agreement over 64 seeds (marginals 1,2 and apply): true
PKG pad(CLZero(F,5),3) level=3 factors=[[1,2,3,4,5],[],[]]  Factor(.,1,0)=[1,1,1,1,1]  apply=0
PKG cl_kth_replay(pad(CLZero(F,5),3)) space_sum_ok=true map_sum_ok=true
PKG pad(CLZero(F,5,Int[]),3) factors=[[],[],[]]  space_sum_ok=FALSE
```

The first five lines are exactly DESIGN §9.4's rule and exactly r2 N5's demand. The last line is new
and is N16.

### 1.4 The diagonal `md` bound and NM1

```
PKG diagonal line = base (3,0), direction (2,7); deg(x1^2*x2 | line) = 3 > md = 2
    => rule=ld_diagonal_degree location=(:left,1) passed=false
PKG honest DLine answer degree = 2 = md  => rule=ld_diagonal_point passed=true
```

The rejection is the *degree* rule, not the point test, and the bound is tight at `md`. `NM1`
(`params.m*params.d -> typemax(Int)`), which SURVIVED in r2, is registered and KILLED.

### 1.5 `description_size` from my own reserialization

I derived the byte counts on my reference structures from the encoder contract alone (1 magic byte;
`q`, `seed_dim`, `level` as 4-byte integers; `Zero = tag + 4 + (4+2·len)`;
`Step = tag + 4 + (4+2f) + (4+2r) + 4 + width·entries + branch`; `Const = tag + child`;
`ByAxis = tag + 4 + 4 + 4 + Σ children`; `Lnf = tag + 4 + (4+2p) + tail`; width `= 1` byte for GF(8)):

```
L_Point = 13 + [1+4+14+4+4+25] + [1+9]                                = 75
L_ALine = 13 + [1+4+10+8+4+9]  + [1+4+4+4 + 2·(1+4+8+4+4+4 + 1+9)]    = 132
L_DLine = 13 + [1+4+6+12+4+1]  + [1+4+4+4 + 2·(1+4+8+8+4+4 + 1+4+8+9)] = 156
INDEP description_size L_Point/L_ALine/L_DLine = [75, 132, 156]
PKG   description_size = 75 / 132 / 156 (bytes_len identical; header 0xC1,q=8,n=5,level)
```

**Exact agreement.** `pad(L_ALine,3)` and `pad(L_ALine,4)` both serialize to 137 bytes and their
bytes differ (the `extra` field), so padding is faithfully recorded.

### 1.6 `Factor`'s `u in L_{<j}(V)` versus `Linear`'s broader `u in V_{<j}`

```
PKG L_ALine j=2, u = (0,0,4,0,0) reachable  : Factor=[1,1,0,0,0]        Linear=(3,0,0,0,0)
PKG L_ALine j=2, u = (0,0,4,1,0) unreachable: Factor=throws ArgumentError Linear=(3,0,0,0,0)
PKG over the 512 prefixes supported on V_1={3,4,5}: Factor accepts 8, Linear accepts 512
PKG Linear(L_ALine,2,(1,0,4,0,0),y) => throws ArgumentError            (support outside V_{<2})
```

`|L_{<2}(V)| = 8` (stage 1 emits `(s,0,0)`) and `|V_{<2}| = 8^3 = 512`; the implementation hits both
cardinalities exactly. This is `def:sampler`'s asymmetry (`gt-04-cl.tex:588-594`) implemented, not
approximated, and `Linear` is not narrowed. The `Linear` answer at the unreachable prefix is
`L^lnf_{e_{chi(4)}} = L^lnf_{e_2}` applied to `y|V_pt`, which I recomputed by hand from
`def:cl-canonical`.

---

## 2. New objections

### N12 — **MAJOR** — `canonical_bytes` / `description_size` do not depend on the stage matrices, and nothing in the corpus separates two distinct CL maps by their bytes

**Location.** `src/samplers/cl.jl:458-459` (`_field_ints`), `:490-527` (`_encode_term!`),
`:530-548` (`describe_cl`); `test/tb1_ld_sampler.jl:237-271` (`describe`) and
`test/tb2_answer_reduce.jl:205-230` (`describe`). Against `docs/DESIGN.md:1131-1136` (§9.2:
"`description_size(X) = length(canonical_bytes(X.code))` … The checker **reserializes the term**
and recomputes that integer … Dependency sets are computed by a syntax walk over quoted child
identifiers and **replayed against the bytes**"), `docs/DESIGN.md:1372-1375` (§10.3 sampler
independence: two verifiers "must have **identical canonical `S^rep` hashes**", the output
dependency set "never `hash(D)`"), and rk-light law 4.

**My independent computation.** A new mutation, applied on a copy exactly as `run.jl` applies one
(`mktempdir`, mutated file `Base.include`d into the loaded module; the archived tree never modified):

```
NEWMUTANT NM7 description_ignores_stage_matrices   (_field_ints -> Int[0 for …])
   TB1_TARGET=all       => SURVIVED (exit=0, 47.72 s)
   TB2_TARGET=describe  => SURVIVED (exit=0, 29.31 s)
NEWMUTANT NM9 (control) _stage_output drops the matrix  TB1_TARGET=all => KILLED (exit=1)
```

Every assertion on the bytes is either a **length** (`sizes == [75,132,156]`;
`description_size == length(canonical_bytes)`; at TB2 only "all `Point_i` sizes are equal") or a
**determinism** check (`canonical_bytes(describe_cl(L)) == canonical_bytes(description)`), plus four
`term[...]` tag probes. None of them is sensitive to what the bytes *say*. I made the consequence
concrete: with `_field_ints` returning zeros, the real `L_Point` (projector onto `V_pt`) and the
projector onto `V_coord (+) V_dir` — two maps whose `apply` differs on the very seed the suite
traces — serialize to **identical canonical bytes**:

```
UNMUTATED : apply(L_pt,z)=(3,5,0,0,0)  apply(L_coorddir,z)=(0,0,4,6,7)  bytes EQUAL? false
MUTATED   : apply(L_pt,z)=(3,5,0,0,0)  apply(L_coorddir,z)=(0,0,4,6,7)  bytes EQUAL? true   (both 75 bytes)
```

A description that collides on distinct maps destroys exactly the property §9.2/§10.3 buy with
`canonical_bytes`: intensional hashing, dependency-set replay, and `M5-decider-hash`. This is the
description-layer analogue of r2 N1 — the artefact is built, printed, and never falsified.

**FIX DEMAND.** In the `describe` testset assert **injectivity on a named separator pair**:
build `alt = CLStep(F, 5, collect(1:5), Int[], <projector onto 3:5>, CLZero(F,5,Int[]))`, assert
`apply(alt,z) != apply(L_Point,z)`, `description_size(describe_cl(alt)) == 75` and
`canonical_bytes(describe_cl(alt)) != canonical_bytes(describe_cl(L_Point))`; additionally assert one
exact byte window carrying a matrix entry (e.g. that flipping `_projector_matrix`'s selection changes
the bytes at a stated offset). Register `test/mutations/tb1_describe_matrix.jl`
(`"    Int[Int(matrix[r, c].bits) for r in 1:size(matrix, 1) for c in 1:size(matrix, 2)]"` →
`"    Int[0 for r in 1:size(matrix, 1) for c in 1:size(matrix, 2)]"`, target `tb1_describe`) and show
it KILLED.

**SURVIVING WEAKER STATEMENT.** All 3 TB1 and all 18 PCP maps are describable through `QuotedBranch`
constructors; opaque closures and every `direct_sum`/`concatenate` output are `NotDescribable`; the
serialization is deterministic; and the three TB1 byte lengths 75, 132, 156 are exactly the lengths an
independent reserialization of the documented format produces. Nothing in the rung shows that the
bytes determine the map.

### N13 — **MAJOR** — the `enu:cl-map-sum` half of the mandatory §9.2 replay has no red witness

**Location.** `src/samplers/cl.jl:416` (`map_sum_ok &= collect(Marginal(L, k, z)) == running`);
`test/tb1_ld_sampler.jl:173` and `test/tb2_answer_reduce.jl:248` (`@test replays[kind].map_sum_ok`).
Against `docs/DESIGN.md:1118-1129` (§9.2: the two `lem:cl-kth` obligations are replayed on **every**
sampler-producing `LawCert`, "part of sampler validity under `def:sampler`, not optional
distribution tests") and rk-light law 4.

**My independent computation.**

```
NEWMUTANT NM8 replay_map_sum_never_compared  ("map_sum_ok &= collect(Marginal(L,k,z)) == running"
                                              -> "map_sum_ok &= true")
   TB1_TARGET=all       => SURVIVED (exit=0, 45.76 s)
   TB2_TARGET=describe  => SURVIVED (exit=0, 26.71 s)
```

The two registered replay mutants do not reach it: `tb1_replay_skips_union.jl` owns
`space_sum_ok`, and `tb1_replay_skips_k.jl` (`for k in 1:ell` → `for k in ell:ell`) is killed by the
**count** assertion `map_sum_checks == level·8^5`, not by the comparison. So the entire
`enu:cl-map-sum` obligation — the only check on the 18 PCP maps' four-query telescoping at
`q = 2^11`, since TB2's other replay goes through `marginal_k`, not through the queries — is
`@test true`.

That the comparison is *not* vacuous in the code I showed with a third mutant, which breaks the
prefix walk so that `Linear`/`Factor` answer at the wrong node:

```
NEWMUTANT NM10 prefix_walk_descends_on_zero_key   TB1_TARGET=space_sum => KILLED, and the ONLY
      failing assertion is tb1_ld_sampler.jl:173  "Expression: report.map_sum_ok"
NEWMUTANT NM8+NM10 (comparison also disarmed)     TB1_TARGET=space_sum => SURVIVED
```

so `map_sum_ok` genuinely owns a real semantic mutation — it simply has no registered owner, and
deleting it is free.

**FIX DEMAND.** Register `test/mutations/tb1_prefix_walk.jl`
(`Mutant("TB1 M9-prefix-walk walk_ignores_the_prefix", "src/samplers/cl.jl",
"        key = F[u[c] for c in step.factor]", "        key = F[zero(F) for c in step.factor]",
"tb1_space_sum")`) and show it KILLED; that makes `map_sum_ok` red-capable. (Registering
`tb1_replay_skips_mapsum.jl` — the NM8 edit — in addition would need a value on which the map sum
genuinely fails; within the datatype's invariants none exists, which is itself worth one sentence in
the C4a scope: `enu:cl-map-sum` is CONSTRUCTED, and the replay checks the *query compiler*, not the
value.)

**SURVIVING WEAKER STATEMENT.** `enu:cl-map-sum` holds: on all `32,768 + 65,536 + 98,304 = 196,608`
`k`-checks of the three TB1 maps my own reference reproduces `map_sum_ok = true` independently, and
the fact is separately witnessed through `marginal_k` by the `marginals` testset (98,304 replays) and
by `test/tb2_answer_reduce.jl:104-120`. What is unwitnessed is that the *replay through the four
queries* checks anything.

### N14 — **MINOR** — the §9.2 replay issues `Marginal(L,0,z)`, which §9.1 makes a `QueryError`

**Location.** `src/samplers/cl.jl:401` (`prefixes = [collect(Marginal(L, i - 1, z)) for i in 1:ell]`)
and `:305-307` (`Marginal` forwards `j` to `marginal_k`, which accepts `0 <= k <= level`), against
`_walk_prefix:339` (`1 <= j <= level(L)` for `Factor`/`Linear`). Against `docs/DESIGN.md:1120-1125`
("`prefix_i := Marginal(i-1,x)` — prefix_1 is the zero marginal … The zero marginal in this notation
is **mathematical shorthand, not a stage-0 machine query**") and `docs/DESIGN.md:1075-1078`
("Certificates quantify only over legal calls: `w in {alice,bob}`, `1<=j<=ell` … A malformed mode,
player, stage, vector, or prefix returns `QueryError`").

**My independent computation.** `Marginal(L_ALine, 0, z)` returns the zero tuple, while
`Factor(L_ALine, 0, z)` and `Linear(L_ALine, 0, z, y)` throw `ArgumentError` ("stage index out of
range"). So one of the four query variants silently accepts an out-of-range stage that the other two
reject and that §9.1 says a real sampler machine must refuse. The replay is written against that
extra behaviour, so `cl_kth_replay` as written cannot be pointed at a `SamplerDescription` whose
`Marginal` enforces `1 <= j <= ell`: it will raise on `i = 1` of every map.

**FIX DEMAND.** Either make `Marginal` reject `j = 0` (matching `Factor`/`Linear`) and compute
`prefixes[1]` as the explicit zero vector inside `cl_kth_replay`, or state in DESIGN §9.3 that this
adapter's `Marginal` deliberately extends the machine interface with `j = 0` and that the TB5 adapter
must translate it. Assert the chosen behaviour in `queries` (`@test_throws ArgumentError` or
`@test Marginal(L,0,z) == zeros`).

**SURVIVING WEAKER STATEMENT.** For `1 <= j <= ell` all four queries obey the `def:sampler` contract,
including the `Factor`/`Linear` domain asymmetry; only stage `0` is treated inconsistently across the
four, and only `Marginal` accepts it.

### N15 — **MINOR** — r2 N4 is discharged in the comment but not in the certificate or the claim, and TB1's whole `D^ld` evidence supports no claim row

**Location.** `src/verifiers/ldt.jl:119-124` (comment), `:180-186` (`ld_off_line_repair`),
`src/samplers/typed.jl:9-10` (`ZERO_MAP_FACTOR_PARTITION`); `test/tb1_ld_sampler.jl:551-557`,
`:145-152`. Against r2 N4's FIX DEMAND ("… and say in one clause of the C4a/C9 scope which reading is
implemented") and rk-light law 3.

**My independent computation.** `grep` over `src/` finds `ld_off_line_repair` and
`ZERO_MAP_FACTOR_PARTITION` *defined and exported* and called from nowhere but the test file; neither
is a child of any `Checked` certificate, unlike `:ld_lnf_zero_direction`, which r2 O3 accepted
precisely because it hangs under a CHECKED node with a live `replay` (`samplers/ldt.jl:149-155`). And
`claims/CLAIMS.md` has **no row** covering TB1's `D^ld` at all: C4a says "No claim is made here about
`D^ld`" and C9 is the TB2 answer-reduced decider. So the rung's 35 decider assertions, its 71,360
honest support decisions, the new `md` bound, the off-line `SOURCE_REPAIR` and the 2,880/37,888 split
are entirely off the ratchet.

**FIX DEMAND.** (a) Attach both nodes to a certificate the suite verifies (a `CheckResult`-carrying
`Checked` for the sweep, as `diagonal_histogram_evidence` already does), or state in DESIGN §5.3 that
TB1 keeps no decider certificate and these are free-standing constants. (b) Orchestrator lane: open a
`C4c` row for TB1's `D^ld` (or extend C9's scope) carrying the off-line reading
(`SOURCE_REPAIR :ld_off_line_rejects`), the `d`/`md` answer bounds, `kappa = 2`, and the
2,880 tautological / 37,888 line-versus-point split.

**SURVIVING WEAKER STATEMENT.** The divergence is documented at the exact line where it happens, with
the source line range and the literal alternative, and the sweep proves it is never reached by honest
play at `(8,2,1)` (0 of 71,360). Its grade is asserted; it is not attached to any evidence tree and
not on the claims ratchet.

### N16 — **MINOR** — `pad_level` of an empty-register zero map produces a level-`ell` value that fails `enu:cl-space-sum`, and §1.5 and §9.4 now disagree about which register is promoted

**Location.** `src/samplers/typed.jl:12-30` (`_pad_tail(L::CLZero, extra)`: the promotion branch is
guarded by `isempty(L.indices)`, and the empty case appends `extra` empty stages instead).
Against `docs/DESIGN.md:1183-1185` (§9.4: "stage 1 reports the all-ones indicator for its **entire
ambient space**") versus `docs/DESIGN.md:372` (§1.5, landed this round: "a zero map on **a register**
is promoted with **that register** as stage 1").

**My independent computation.**

```
PKG pad(CLZero(F,5),    3)  factors=[[1,2,3,4,5],[],[]]  space_sum_ok=true
PKG pad(CLZero(F,5,Int[]),3) factors=[[],[],[]]          space_sum_ok=FALSE
```

`CLZero(F,n,Int[])` is exactly the terminal every TB1 and PCP map ends in, and it is reachable from
the public API (`pad_level`). Nothing at TB1/TB2 pads a terminal, so no current map is affected; but
`typed_anchor_sampler`, the Pauli sampler and `tilde S^intro` (DESIGN §9.4's named originators) all
go through this function, and `detype_sampler`'s "zero opposite-edge view" child is a sub-register
zero map for which §1.5 and §9.4 prescribe different stage-1 factors.

**FIX DEMAND.** Decide the rule (I read `rk:higher-level` with `V_1 = V` as ambient-wide, so §9.4 is
right and §1.5's landed sentence is the loose one), make `_pad_tail(CLZero)` promote to the value's
**ambient** register in both cases (or reject the empty-register pad with an `ArgumentError`), assert
`cl_kth_replay(pad_level(CLZero(F,5,Int[]),3), …).space_sum_ok`, and reconcile §1.5 with §9.4.

**SURVIVING WEAKER STATEMENT.** For every zero map on a nonempty register, `pad_level` implements
DESIGN §9.4's promotion and the padded value passes the `enu:cl-space-sum` replay; for the
empty-register zero map it produces a value with no factor partition at all.

### N17 — **NOTE** — `Factor`'s reachability rejection is red-capable but unregistered

`tb1_factor_indicator.jl` owns the indicator *shape* and `tb1_linear_narrowed.jl` owns `Linear`'s
*breadth*; no registered mutant owns `Factor`'s `_in_column_space` rejection itself, although
`@test_throws ArgumentError Factor(axis, 2, unreachable)` (`:216`) would catch
`reachable=true -> false`. Register the one-line dual of `tb1_linear_narrowed.jl`.

### N18 — **NOTE** — the TB2 description sizes are printed but not asserted, and `BranchByAxis` charges one child term per axis

`test/tb2_answer_reduce.jl:223-225` asserts only that the sizes are equal **within** each family;
the printed 3009 / 2893 / 10228 / 2754 / 10479 are unpinned, so a size regression at `q = 2^11`
is invisible. Separately, `_describe_branch(BranchByAxis)` emits one full child term per axis, so
`description_size` grows linearly in `m`: measured `ALine_1 = 2893` at `m = 1` against
`ALine_6 = 10228` at `m' = 16`, and `DLine_1 = 2754` against `DLine_6 = 10479`. DESIGN §9.2's rule
that "a compact loop in a repetition description is not charged as `k` copies of its code" is the
discipline a `chi`-indexed literal table gives up; pin the numbers and say in §9.3 whether the table
form is intended at production `m`.

### N19 — **NOTE** — two DESIGN lockstep defects at `dcaaf34`

(a) §9.4's citation is corrupted by the brief-46 insertion: `docs/DESIGN.md:1184` reads
`` (`gt-04-cl. (`pad_level` implements this … `ZERO_MAP_FACTOR_PARTITION`.)tex:L122-L130`) `` — the
parenthetical was spliced **inside** `gt-04-cl.tex:L122-L130`, so the reference no longer resolves.
(b) brief 46 proposed adding `(single factor space = all of V)` to §1.5's `L_Point` line; it did not
land (`grep` finds no such string), so the N3 repair — the one thing this round changed in the
sampler's mathematics — has no record in DESIGN. Both are orchestrator-lane one-line edits.

### N20 — **NOTE** — walls, and a cold-precompile figure four times the reported one

My two runs of the identical archived tree: TB0 test body **41.251 s** (load 1.70) and **41.420 s**
(load 4.74), against the proposer's 39.622 s quiet and 40.94 s loaded; whole suite 2m35.9 / 2m30.9,
maxrss 1102 / 1084 MiB, exit 0, 499/499 both times. The wall is stable but only 3.6 s under the 45 s
warning, and it grew ~5 s this round (r2 measured 36.302 s quiet on the same box). Cold precompile of the package here was **206 s**, not
the reported 103 s — the depot entry is keyed by content, so the TB2 critic's identical archived tree
was precompiling the same cache entry concurrently (Julia printed `Being precompiled by another
process`). The registry ran **736.51 s** here against the proposer's quiet 471.1 s, with identical
dispositions.

### N21 — **NOTE** — the wrong-field `_child` guard is doubly enforced, so its witness does not isolate it

§1.2: deleting the field guard alone leaves the wrong-field continuation rejected by the typed memo
`Dict{Vector{F},AbstractCL{F}}` as a `MethodError`. `@test_throws ArgumentError` still fails, so the
guard is red-capable; but unlike G2/G3/G4 its witness does not show the guard is load-bearing. If the
memo is ever loosened to `Dict{Any,Any}` this witness goes silent. One extra assertion —
`@test_throws ArgumentError MIPStarLambda._child(wrong_field, [one(TB1_F)])` before any memo
insertion, or a `@test` that the thrown message names the field — would pin it.

### N22 — **NOTE** — the bounded memo is shared between `apply` and the prefix walks, and clears rather than evicts

`_child` (`cl.jl:190`) does `length(L.children) >= CL_MEMO_LIMIT && empty!(L.children)` — a full
flush, not an eviction — and the same memo serves `apply`, `marginal_k`, `Factor` and `Linear`. A
description-level `Linear` sweep over `V_{<j}` therefore evicts the sampling path's continuations
(measured: 10^4 distinct `Linear` prefixes at TB1 leave `max_entries = 1808`, `nodes = 1809`; at
`q = 2^11` on `DLine_6`, 1,844 / 1,916 over 53 nodes). Correct but pessimal; an LRU or a memo-free
descent for the query path is the §9.1 shape.

---

## 3. Test and mutation runs observed (archived copy, Julia 1.12.5)

`julia --project=. test/runtests.jl` — **exit 0, 499/499**, twice:

| run | load at start | `MIPStarLambda load/precompile` | TB0 test-body wall | suite wall | maxrss | exit |
|---|---|---|---|---|---|---|
| RUN1 (loaded) | `1,70 2,61 2,95` | 0.37 s | **41.251 s** (warning 45, gate 60) | 2m35.9 | 1102 MiB | 0 |
| RUN2 (quieter) | `4,74 7,76 7,67` | 0.371 s | **41.420 s** | 2m30.9 | 1084 MiB | 0 |

```
Test Summary:                                                | Pass  Total     Time
MIPStarLambda                                                |  499    499  2m34.3s
  TB0 60 s test-body hard limit (measured 41.251 s)          |    1      1     0.0s
  TB1 datatype levels                                        |   26     26     3.2s
  TB1 lem:cl-kth enu:cl-space-sum / enu:cl-map-sum replay     |   22     22     4.0s
  TB1 def:sampler queries Dimension/Marginal/Linear/Factor    |   23     23     0.1s
  TB1 DESIGN 9.3 describability (QuotedBranch)                |   22     22     0.9s
  TB1 bounded continuation memo                               |    3      3     0.4s
  TB1 eq:chi-func buckets and joint histogram (M-chi owner)   |    2      2     0.8s
  TB1 pi-prefix / canonical-complement sampler separators     |    2      2     0.0s
  TB1 genuinely chi-free lem:alnf/lem:dlnf marginals          |    4      4     0.4s
  TB1 exact axis histogram (M-chi owner)                      |    3      3     0.1s
  TB1 exact diagonal histogram (M-pi, M-lnf owner)            |    8      8     0.7s
  TB1 exhaustive marginal replay                              |    3      3     0.8s
  TB1 all honest line restrictions                            |    5      5     0.5s
  TB1 D^ld honest deterministic sweep and consistency         |   12     12     2.0s
  TB1 D^ld rejections                                         |   15     15     1.1s
  TB1 axis degree rejection (M-deg owner)                     |    5      5     0.2s
  TB1 sampled question-pair trace                             |    3      3     0.6s
TB1 lem:cl-kth replay: chain_set_id=tb1-exhaustive-8^5 distinct_chains=[1, 8, 288]
    completed_replays=[32768, 32768, 32768] map_sum_checks=[32768, 65536, 98304]
    negative_witness_space_sum_ok=false
TB1 queries: Factor(L_ALine,1,0)=[0,0,1,1,1] Factor(L_ALine,2,(0,0,4,0,0))=[1,1,0,0,0]
    Linear at unreachable (0,0,4,1,0) answered=true
TB1 describe: description_size L_Point/L_ALine/L_DLine=[75, 132, 156]
    closure=NotDescribable direct_sum=NotDescribable
TB1 memo: distinct Linear prefixes=10000 limit=4096 max_entries=1808 entries=1808 nodes=1809
TB1 D^ld: type_pairs=9 seeds=32768 support_decisions=71360 non_noop=40768
    (equal-type tautologies=2880 line_vs_point=37888) off_line_hits=0
MUTATION_EXPECTED_RULE ld_diagonal_degree actual=ld_diagonal_degree passed=false
```

`julia --project=. test/mutations/run.jl` — **exit 0**, load 9.81 -> 5.62 (the TB2 critic was running
its own registry on the same box):

```
package image ready after 0.97 s
MUTATION REGISTRY: killed=61/61 baselines ok=36/36 wall=736.51 s     (proposer, quiet box: 471.1 s)
```

All 27 TB1 mutants KILLED, including the five that this round adds or re-anchors:

```
MUTANT TB1 NM1 diagonal_answer_accepts_any_degree       target=tb1_decider_rejections => KILLED (11.84 s)
MUTANT TB1 NM2 child_skips_continuation_level_check     target=tb1_levels             => KILLED (15.98 s)
MUTANT TB1 NM3 doblock_constructor_skips_span_check     target=tb1_levels             => KILLED (17.90 s)
MUTANT TB1 N3  L_Point_sub_ambient_factor               target=tb1_space_sum          => KILLED (19.28 s)
MUTANT TB1 N5  pad_level_prepends_empty_stages          target=tb1_levels             => KILLED (13.30 s)
MUTANT TB1 M-chifree pi_prefix_off_by_one               target=tb1_chifree            => KILLED ( 9.64 s)
MUTANT TB1 M9-describe-closure                          target=tb1_describe           => KILLED (15.97 s)
MUTANT TB1 M9-factor-not-indicator                      target=tb1_queries            => KILLED (10.23 s)
MUTANT TB1 M9-linear-narrowed-domain                    target=tb1_queries            => KILLED (10.41 s)
MUTANT TB1 M9-replay-skips-k                            target=tb1_space_sum          => KILLED (20.16 s)
MUTANT TB1 M9-replay-skips-union                        target=tb1_space_sum          => KILLED (16.52 s)
MUTANT TB1 M9-memo-unbounded                            target=tb1_memo               => KILLED (13.28 s)
```

No FATAL: suite green, runner green, every registered mutant killed with a passing baseline, no bare
`@assert` in `src/` or `test/`, no status raised by the proposer. One cosmetic hazard: the registry
now carries **two** TB1 mutants labelled `N3` (r1's `verifier_diagonal_line_skips_pi` and r2's
`L_Point_sub_ambient_factor`) and two labelled `N5`, so `MUTATION_FILTER=N3` selects both; rename the
brief-46 arrivals to `N3-space-sum` / `N5-pad-order` as the proposer's own report already calls them.

---

## 4. My new mutations

Applied on copies only (`mktempdir`, the mutated file written to the sandbox and `Base.include`d into
the loaded module; the archived tree never modified). Runners: `indep/{newmut.jl,newmut2.jl,collide.jl}`.

| id | file:site | semantic change | target | outcome |
|---|---|---|---|---|
| NM7 | `cl.jl:458-459` | `_field_ints` returns zeros — the canonical description ignores every stage matrix | TB1 all | **SURVIVED** → N12 |
| NM7 | same | same | TB2 `describe` | **SURVIVED** → N12 |
| NM8 | `cl.jl:416` | `map_sum_ok &= collect(Marginal(L,k,z)) == running` → `&= true` (the `enu:cl-map-sum` comparison) | TB1 all | **SURVIVED** → N13 |
| NM8 | same | same | TB2 `describe` | **SURVIVED** → N13 |
| NM9 (control) | `cl.jl:218` | `_stage_output` drops the matrix (`local_output = copy(input)`) | TB1 all | KILLED (`levels:147`) |
| NM10 (auxiliary) | `cl.jl:345` | the prefix walk descends on the zero key, so `Factor`/`Linear` answer at the wrong node | TB1 `space_sum` | KILLED — sole failure `report.map_sum_ok` (`:173`) |
| NM8+NM10 | both | the same walk break with the comparison disarmed | TB1 `space_sum` | **SURVIVED** (this is what makes N13 MAJOR) |

Two independent survivors ⇒ N12, N13. The control confirms the harness is red-capable in the same
files, and NM10 shows the deleted comparison is not decoration.

## 5. Per-claim decision

| claim | decision | note |
|---|---|---|
| **C4a** | **RE-AFFIRM at TESTED**, replacing the row with the authorized text below | every number in the row independently reproduced; the N3 scope clause is struck (the repair is real and I re-derived it from the source's own wording), the positive `enu:cl-space-sum` sentence is authorized, and two new scope clauses record N12/N13. Status may not rise further while N12/N13 stand. |
| **C4b** | **RE-AFFIRM at TESTED (TB2 lane)** | the only TB1-owned sentence in its Scope — `` `pad_level` prepends its zero-factor stages … `` — is now **false of the tree** and I authorize the proposer's replacement verbatim (below). Everything else in C4b belongs to `verdicts/tb2-r3.md` (brief 51). |
| **C9** | **defer to `verdicts/tb2-r3.md`** | TB2's lane; but see N15(b): C9's scope should also carry `SOURCE_REPAIR :ld_off_line_rejects`, since C9's steps 3/4 run this `ld_decider`. |
| **C7** | HOLD at CONJECTURE | `depends-on = C4a,C4b` remains correct; no TB1 evidence bears on it. |
| C1, C2, C3, C5, C6, C8, C12–C19 | unchanged | outside this rung's lane; no TB1 evidence bears on them. |

**C4a — AUTHORIZED VERBATIM ROW** (copy exactly; only surrounding table scaffolding may be adapted):

> | C4a | (Sampler is CL — TB1 instance) For `(q,m,d)=(8,2,1)` and ambient `V=V_pt (+) V_coord (+) V_dir` of `seed_dim` 5, `L_Point`, `L_ALine` and `L_DLine` are CL functions of constructed nesting depth 1, 2 and 3 respectively — upper bounds in the sense of `rk:higher-level`, not minimality claims — built only from `CLStep` stages whose factor and rest registers are disjoint coordinate-index sets partitioning that stage's own register, with lazily evaluated continuations validated (field, seed dimension, rest register, child level) on every key reached by the exhaustive enumeration; each map's `level` factor registers are pairwise disjoint and their union is all of `{1,...,5}` on every one of the `8^5` seeds (`lem:cl-kth` `enu:cl-space-sum`), namely all of `V` for `L_Point`, `{3,4,5},{1,2}` for `L_ALine` and `{3},{4,5},{1,2}` for `L_DLine`, matching the concatenation sentences of `gt-07-ldt.tex:203-237`, with 1, 8 and 288 distinct branch chains; `apply` equals the sum of the first `level` stage outputs on all `3 x 8^5 = 98,304` marginal replays (`lem:cl-kth` `enu:cl-map-sum`), and the same telescoping replayed through `def:sampler`'s `Marginal`/`Factor`/`Linear` queries reports agreement on all `32,768 + 65,536 + 98,304 = 196,608` k-checks, with `Factor` accepting exactly the reachable prefixes `u` in `L_{<j}(V)` and `Linear` the broader `u` in `V_{<j}` (measured 8 and 512 at `j=2` for `L_ALine`, `gt-04-cl.tex:588-594`); all three maps are describable from `QuotedBranch` continuations with `description_size` 75, 132 and 156 bytes, reproduced by independent reserialization, while an opaque host branch and every `direct_sum`/`concatenate` output are `NotDescribable`; and over all `8^5 = 32,768` seeds the induced distributions `mu_{L_ALine,L_Point}` and `mu_{L_DLine,L_Point}` have exact histograms of support 512 and 18,432 (mass 32,768 each; 512 zero-direction support points carrying 2,304 seeds) agreeing entry-for-entry with a separately transcribed evaluation of `eq:cl-ptf`/`eq:cl-alnf`/`eq:cl-dlnf` **including `eq:chi-func`** — the comparison is NOT `chi`-independent (`verdicts/tb1-r1.md` O1) — and on the 512 zero-direction points the equality additionally rests on the DESIGN `SOURCE_REPAIR` `L^lnf_0 = id`, which `def:cl-canonical` does not define (O3), emitted as a `SOURCE_REPAIR` `CertNode` under the CHECKED histogram node. The separately asserted `chi`-free content of `lem:alnf`/`lem:dlnf` is the marginal support 128 (all masses 256) and 4,096 (masses 4 and 36). **Scope:** `enu:cl-map-sum` is CONSTRUCTED by the datatype's disjoint registers, so the four-query replay tests the query compiler rather than the value, and its map-sum comparison currently has no red witness (`verdicts/tb1-r3.md` N13); the canonical description bytes are asserted only by length and determinism — no test separates two distinct CL maps by their bytes (ibid. N12); `Marginal` accepts the stage index `j=0` that `Factor`/`Linear` and `def:sampler` reject (ibid. N14). No claim is made here about `D^ld`, about `concatenate`/`direct_sum`/`product`/`TypedSampler`, or about any other `(q,m)`. | TESTED | D2 | — | `test/tb1_ld_sampler.jl` (`levels`, `space_sum`, `queries`, `describe`, `memo`, `chi`, `chifree`, `pi_separator`, `lnf_separator`, `histogram_axis`, `histogram_diagonal`, `marginals`); red: `test/mutations/tb1_{chi,pi,lnf,level,repair,ambient,ambient_doblock,child_validation,dsum,concat,space_sum,pad_order,chifree,describe_closure,factor_indicator,linear_narrowed,replay_skips_k,replay_skips_union,memo_unbounded}.jl` | `verdicts/tb1-r1.md`, `verdicts/tb1-r2.md`, `verdicts/tb1-r3.md` |

**C4b — AUTHORIZED single-sentence replacement** (TB1-owned; the rest of C4b is brief 51's): replace

> `pad_level` prepends its zero-factor stages, so a padded map's marginals `L_{<=j}` for `j<3` are zero rather than the `V_1=V` promotion of `rk:higher-level`/DESIGN §9.4 (`verdicts/tb2-r2.md` N3).

by

> `pad_level` appends its empty stages, so a padded map's marginals `L_{<=j}` for `j<3` equal the child's, and a zero map on a nonempty register is promoted by `rk:higher-level` with that register as stage 1 (`SOURCE_REPAIR :zero_map_factor_partition`; `verdicts/tb2-r2.md` N3 repaired in brief 46, `verdicts/tb1-r3.md` §1.3); a zero map on the *empty* register is not promoted and its padding has no factor partition (`verdicts/tb1-r3.md` N16).

**Lockstep follow-ups for the orchestrator** (not TB1's lane): repair DESIGN §9.4's spliced
`gt-04-cl.tex:L122-L130` citation and reconcile §9.4 ("entire ambient space") with §1.5 ("that
register") — N19, N16; add the `(single factor space = all of V)` annotation brief 46 proposed for
§1.5's `L_Point` line — N19(b); open a claim row for TB1's `D^ld`, or extend C9's scope with
`SOURCE_REPAIR :ld_off_line_rejects` — N15(b).

## 6. §9 readiness verdict

**The four-query API: YES, as is.** `Dimension`/`Marginal`/`Factor`/`Linear` have the §9.1 signatures and shapes (`Factor` a length-`Dimension` 0/1 vector) and implement `def:sampler`'s domain asymmetry exactly (measured 8 reachable vs 512 legal prefixes at `L_ALine`, `j=2`); illegal calls raise `ArgumentError`, which §9.3 already maps to `QueryError`. **`describe_cl`: NO.** Remaining gaps, each with the file:line that must change:

- NOTE 1 — `repeat_sampler` (§10.2) *is* a `k(n)`-fold `direct_sum` and `typed_anchor_sampler` (§10.1) is a `TypedSampler`; every `direct_sum`/`concatenate` output is `NotDescribable` today (asserted at `test/tb1_ld_sampler.jl:267`). Must change: `src/samplers/cl.jl:552-561` (`_shift_cl`), `:563-596` (`_combine_embedded`), `:611-650` (`_graft_concatenation`) — rebuild on `QuotedBranch` (`DL9-direct-sum`, `DL9-product`).
- NOTE 2 — there is no `SamplerDescription`: `CLDescription` carries `field_size/seed_dim/level/term/bytes` and no `typing`, `query_time`, `dependency_set`, and there is no pair adapter `describe_cl(LA,LB,q)`. Must change: `src/samplers/cl.jl:434-440`. §10.3's sampler-independence test ("dependency set exactly `{hash(S),lambda,tau,c_prime}`, never `hash(D)`") has nothing to run against.
- NOTE 3 — the §9.2 replay cannot be pointed at a description: it issues `Marginal(·,0,·)`, which §9.1 makes a `QueryError`. Must change: `src/samplers/cl.jl:401` (N14).
- NOTE 4 — the zero-map promotion TB5 depends on is half-implemented: `pad_level` of an empty-register `CLZero` has no factor partition. Must change: `src/samplers/typed.jl:12-30` (N16).
- NOTE 5 — the description layer is not yet usable as a hash: nothing shows the bytes determine the map. Must change: `src/samplers/cl.jl:458-459` + a red test in `describe` (N12).
- Ready as is: `TypedSampler` pads with `BranchPadded`, so typed children stay describable, and all 21 non-combinator maps serialize deterministically.

---

**What this round got right, for the record:** all three r2 MAJORs are genuinely discharged, and two
of them I re-derived from the ground truth rather than from the report. The `L_Point` repair is not a
cosmetic re-registering: with the ambient factor, the three maps' factor families
(`[[1..5]]`, `[[3,4,5],[1,2]]`, `[[3],[4,5],[1,2]]`), their chain counts `[1, 8, 288]` and their
`196,608` k-checks agree entry for entry with a reference I wrote from `gt-07-ldt.tex:203-237` and
`gt-04-cl.tex:151-180` alone, and they are exactly the decompositions the source's own concatenation
sentences prescribe. The lazy-continuation guards are now four `@test_throws` reached through
`apply`, and I confirmed by deleting each guard alone on a copy that three of the four are perfectly
isolated. `pad_level` appends, the promoted zero map carries the whole-register indicator, the
diagonal `md` bound rejects at `(:left,1)` and is tight, and `Factor`/`Linear` implement
`def:sampler`'s domain asymmetry to the element (8 versus 512). 61/61 mutants killed with 36/36
baselines. The two MAJORs below are both on the §9 layer that brief 46 added this round, both are one
registered mutant plus one assertion away from closed, and neither touches a number that is wrong —
what is missing is the red test that would notice if it became wrong.

VERDICT: FAIL(N12,N13)
