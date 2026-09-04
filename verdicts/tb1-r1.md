# CRITIC verdict r1 — rung TB1 (`src/samplers/**`, `src/verifiers/ldt.jl`, `test/tb1_ld_sampler.jl`, `test/mutations/tb1_*.jl`) at commit `41ff317`

Round 1 (attack). **Priors.** `verdicts/design-r1..r4.md` (design cycle converged, PASS at r4) and
`verdicts/tb0-r1.md` (FAIL(O1–O7); C3 PROMOTE, C8 PROMOTE(scoped), C1/C2 HOLD) are treated as settled
for `docs/` and for the TB0 lane; nothing there is re-litigated. **No prior verdict exists on TB1**, so
this is a full attack round, not an adjudication.

**Isolation.** Per brief §Isolation I ran
`git -C /home/tobias/Projects/discussions archive 41ff317 | tar -x -C <scratch>/tb1/`
into `/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-.../scratchpad/critic-tb1-r1/tb1/`
and ran **every** test, mutation, timing and experiment there. All `file:line` citations below are that
copy, byte-identical to `41ff317` ("TB1 r0 (codex): …"). The live working tree — where a TB2 codex
worker is concurrently editing — was never read, run or written. My only repo output is this file.

**Lane check (law 1).** `git show --stat 41ff317` touches only `briefs/16-tb1.*`, `src/MIPStarLambda.jl`,
`src/samplers/{cl,typed,ldt}.jl`, `src/verifiers/ldt.jl`, `test/runtests.jl`, `test/tb1_ld_sampler.jl`,
`test/mutations/{run,tb1_*}.jl`. `git diff 3ddb388 41ff317 -- claims/ docs/` is **empty**. The proposer
did **not** raise any status themselves. Law 1 respected.

**Independence.** Every number in §0 was recomputed from a *new* implementation I wrote directly from
`gt-03-prelim.tex` (`def:register-subspace`, `def:canonical-complement`, `def:cl-canonical`),
`gt-04-cl.tex` (`def:cl-func`, `def:cl-dist`, `lem:cl-kth`, `lem:cl-concat`) and `gt-07-ldt.tex`
(`def:line`, `def:line-representative`, `eq:cl-ptf`/`alnf`/`dlnf`, `eq:chi-func`, `lem:alnf`,
`lem:dlnf`, `fig:ld-decider`): my own carry-less `GF(8)` (modulus `x^3+x+1`, distributivity and
associativity re-verified on all `8^3` triples), my own `chi` solved from `eq:chi-func` as a search for
the unique `i` with `0 <= s-(i-1)q/m < q/m`, my own canonical projector built column-by-column from the
RREF pivot rule, and my own `pi_{i-1}`. Scratch:
`.../critic-tb1-r1/indep/{indep.jl,indep_core.jl,compare.jl,chifree.jl,supports.jl,m6.jl,misc.jl,scale.jl,newmut.jl}`.
No code from `src/` was reused in the reference path.

---

## 0. Independent recomputation (brief obligations 1–5)

**(1) Histogram supports — CONFIRMED, exactly.** My independent enumeration of all `q^{2m+1}=32,768`
seeds under `eq:cl-ptf`/`eq:cl-alnf`/`eq:cl-dlnf`:

```
INDEP axis:     support=512    mass=32768   multiplicity set = {64}
INDEP diagonal: support=18432  mass=32768   multiplicity set = {1, 8}
                zero_direction_support=512  (mass 64*(4*1 + 4*8) = 2304 of 32768)
CODE  axis:     support=512    mass=32768   axis  histogram == INDEP : true
CODE  diagonal: support=18432  mass=32768   diag  histogram == INDEP : true
CODE  diagonal zero-direction support = 512
```

Hand derivation agreeing with both: the axis pair is a function of `(u,s)` alone, giving `8^2*8 = 512`
keys each hit by the `8^2` free `v`'s; the diagonal pair is a function of `(u,s,v')`, giving
`4*64*64 = 16,384` keys at `i=1` (multiplicity 1) plus `4*8*64 = 2,048` keys at `i=2` (multiplicity 8),
`16,384+2,048 = 18,432`, mass `16,384+16,384 = 32,768`; `v'=0` needs `v=0` at `i=1` and `v_2=0` at
`i=2`, giving `4*64 + 4*64 = 512` keys. The printed report's `512` / `18,432` / `512` are **correct**.
I also reproduced every other printed number: `98,304 = 3*8^5` marginal replays, `71,360` distinct
`D^ld` support decisions (my independent per-pair counts: Point×Point 64, Point×ALine 512,
Point×DLine 18,432, ALine×Point 512, ALine×ALine 64, ALine×DLine 15,296, DLine×Point 18,432,
DLine×ALine 15,296, DLine×DLine 2,752), `16` axis lines, `568` diagonal representatives, and the whole
trace line for seed `(3,5,4,6,7)` (`chi(4)=2`, `e_2` pivot 2 ⇒ `u_0=(3,0)`; `pi_1((6,7))=(0,7)`,
pivot 2 ⇒ `u_0=(3,0)`; both restrictions degree 1). **No disagreement with the proposer's report on any
key number.**

**(2) `L_lnf` IS the canonical map of `def:cl-canonical` — CONFIRMED on 5 hand-picked `v`.** For
`F={v}` the RREF of the `1×m` matrix pivots at `j0 = min{j : v_j != 0}`, `J={j0}`,
`F^perp = {e_j : j != j0}`, and `L` is the projector onto `span(F^perp)` parallel to `span(v)`, i.e.
`L(x) = x - (x_{j0}/v_{j0}) v`. I checked kernel, image and idempotence exhaustively over `F_8^2`:

```
v=(1,0) pivot=1 ker=span(v) OK  img=span{e_2} OK  L^2=L OK
v=(0,1) pivot=2 ker=span(v) OK  img=span{e_1} OK  L^2=L OK
v=(1,1) pivot=1 ker=span(v) OK  img=span{e_2} OK  L^2=L OK
v=(3,5) pivot=1 ker=span(v) OK  img=span{e_2} OK  L^2=L OK
v=(0,6) pivot=2 ker=span(v) OK  img=span{e_1} OK  L^2=L OK
```

This is the *canonical* complement, not merely *some* complement (a non-canonical choice would put the
image elsewhere; the M-lnf mutant `findfirst -> findlast` moves the pivot and is killed). **PASSES.**
Caveat carried into O3: `v=0` is outside `def:cl-canonical` entirely.

**(3) `chi` bucket boundaries vs `eq:chi-func` — CONFIRMED.** Solving `s = (i-1)q/m + r`,
`0 <= r < q/m` for `q=8, m=2` gives `i=1` on `s in {0,1,2,3}` and `i=2` on `s in {4,5,6,7}`.
`src/samplers/ldt.jl:43` returns exactly `[1,1,1,1,2,2,2,2]`; **zero mismatches**.
`chi` also throws when `m` does not divide `q` (`ldt.jl:42`), matching the `eq:chi-func` hypothesis.

**(4) Hand restrictions of `g = 1 + x_1 + x_1 x_2` — CONFIRMED.**

```
axis line  base=(0,5) dir=(1,0):  hand 1 + (1+5)t = 1 + 4t   deg 1
                                  hand values [1,5,2,6,7,3,4,0] == code values  OK
diag line  base=(3,0) dir=(2,7):                              deg 2
                                  hand values [2,7,0,5,1,4,3,6] == code values  OK
```

Degree bounds `d=1` (axis) and `md=2` (diagonal) hold, as `fig:ld-decider`'s answer-format table
requires.

**(5) `CLStep` admits register subspaces ONLY (design-r1 M6 / DD-19) — CONFIRMED.** I attacked the
constructor directly:

```
factor = [1 1; 0 1] (a general-subspace basis)  -> rejected (MethodError Int64(::GF8))
factor = (1.5, 2)                               -> rejected (InexactError)
factor = (0, 1) / (6, 1)                        -> rejected (ArgumentError: coordinate out of range)
factor = (1, 1)                                 -> rejected (ArgumentError: duplicate coordinates)
```

There is no code path by which a non-coordinate subspace enters a `CLStep`; the general-subspace /
rank-certificate branch DD-19 asked to delete is genuinely absent. **M6 PASSES.** (One residual hole
in the same constructor is O6.)

---

## 1. Objections

### O1 — **MAJOR** — the "χ-free reference" is not χ-free, and provably cannot be

**Location.** `test/tb1_ld_sampler.jl:36-40` — the comment reads "χ-free literal samplers for
gt-07-ldt.tex lem:alnf/lem:dlnf: draw i uniformly", but line 38 is
`i = 1 + div(tb1_int(s), bucket_width)`, which is `src/samplers/ldt.jl:43` transcribed character for
character. Against `docs/DESIGN.md` §5.3 ("The reference histogram is `chi`-free: it draws the axis `i`
uniformly") and `claims/CLAIMS.md` C4 ("by a `chi`-independent exact histogram").

**My independent computation.** I built the genuinely χ-free marginals that `lem:alnf` and `lem:dlnf`
actually assert — the distribution of `(line, u)` with `i` drawn uniformly — and evaluated them under
the real `chi` and under the M-χ mutant `chi'(s) = 1 + floor(((s+1) mod 8)/4)`:

```
chi      : [1,1,1,1,2,2,2,2]        bucket sizes [4,4]
chi_mut  : [1,1,1,2,2,2,2,1]        bucket sizes [4,4]
lem:alnf (line,point) marginal equal under chi vs chi_mut?  true   support=128  all masses 256
lem:dlnf (line,point) marginal equal under chi vs chi_mut?  true   support=4096 masses {4, 36}
```

Both χ's make `i` uniform, so **every** genuinely χ-free consequence of `lem:alnf`/`lem:dlnf` is
invariant under an M-χ bucket permutation. The reference kills M-χ *precisely because* it is not
χ-free. DESIGN §5.3's two demands — "the reference is χ-free" and "mutate χ at a bucket boundary and
require mismatch against that independent reference" — are **mutually inconsistent**; the proposer
silently satisfied the second and mislabelled the result as the first.

**FIX DEMAND.** Delete "chi-independent"/"χ-free" from the C4 row and from DESIGN §5.3, rename the
helper to `tb1_transcribed_reference`, and add a *separate* `histogram_chifree` testset asserting the
two genuinely χ-free facts I computed (axis `(line,point)` marginal: support 128, every mass 256;
diagonal: support 4096, mass 4 when `v'_1 != 0` and 36 when `v'_1 = 0`), which is what `lem:alnf` and
`lem:dlnf` state.

**SURVIVING WEAKER STATEMENT.** For `(q,m,d)=(8,2,1)` the CL-constructed distributions coincide
entry-for-entry with a *separately transcribed* evaluation of `eq:cl-ptf`/`eq:cl-alnf`/`eq:cl-dlnf`
**including `eq:chi-func`**; and (verified by me, not by the suite) their `(line,point)` marginals
satisfy `lem:alnf` and `lem:dlnf` exactly.

---

### O2 — **MAJOR** — five NEW semantic mutations SURVIVE: `fig:ld-decider` items 2 and 3 are not red-capable

**Location.** `src/verifiers/ldt.jl:112-130` (`_line_point_test`, comparison at `:124`), `:156-162`
(the Point-on-the-left symmetrization), `:103-110` (`_line_parameter`), `:43-50`
(`_question_format`); `src/samplers/ldt.jl:151-159` (`diagonal_line`); test
`test/tb1_ld_sampler.jl:249-260`. Against rk-light law 4.

**My independent computation.** I wrote five semantic mutants the proposer did not anticipate, applied
each on a COPY (`mktempdir`, `src/` + `test/tb1_ld_sampler.jl` only, never the tree) and ran the whole
TB1 test file with `TB1_TARGET=all`:

```
NEWMUTANT N1 line_point_test_always_agrees          => SURVIVED (exit=0)
NEWMUTANT N2 drop_point_on_left_symmetrization      => SURVIVED (exit=0)
NEWMUTANT N3 verifier_diagonal_line_skips_pi        => SURVIVED (exit=0)
NEWMUTANT N4 drop_point_on_line_verification        => SURVIVED (exit=0)
NEWMUTANT N5 question_format_accepts_any_arity      => SURVIVED (exit=0)
NEWMUTANT N6 restrict_drops_constant_term (control) => KILLED   (exit=1, "TB1 all honest line restrictions")
```

- **N1** replaces `line_value == point_value_j ||` with `true ||` — i.e. the axis and diagonal
  line-versus-point tests *always agree*. The suite stays GREEN. This is the entire content of
  `fig:ld-decider` items 2 and 3.
- **N2** deletes the `elseif right_type in (:ALine,:DLine) && left_type == :Point` arm, so `(Point,
  ALine)` and `(Point, DLine)` fall through to `:ld_noop` **accept**. GREEN.
- **N3** makes the *verifier-side* `diagonal_line` use the raw direction instead of
  `pi_prefix(direction, axis-1)`, deleting `fig:ld-decider` item 3's `v' = pi_{i-1}(v)`. GREEN (it is a
  no-op on honest questions, whose direction register is already projected — which is exactly why it
  must be tested against a *malformed* question). The proposer's M-π mutates only the sampler.
- **N4** replaces the on-line verification `(line_point(line,t) == point, t)` with `(true, t)`. GREEN.
- **N5** replaces the question arity check with `length(raw) >= 0`. GREEN.

Why the suite is blind: of the 71,360 "support decisions" the report advertises, my independent count
shows **30,592** are `(ALine,DLine)`/`(DLine,ALine)` pairs that hit the `:ld_noop` unconditional accept
(`verifiers/ldt.jl:163`), **2,880** are equal-type pairs whose two questions are *literally identical*
(so `_answers_equal` is a tautology), and the remaining **37,888** are line-versus-point decisions on an
honest strategy — none of which can distinguish the comparison from `true`. The only FAIL rules the
suite ever observes are `:ld_consistency` (hand-built at `test:243-244`) and `:ld_axis_degree` (a format
check that returns at `verifiers/ldt.jl:84-86`, before `_line_point_test` is ever reached).

The implementation itself is **correct** — I verified directly that it rejects:

```
cheating axis answer (honest+1, legal degree 1)  -> rule=ld_axis_point       passed=false
same with Point on the LEFT                       -> rule=ld_axis_point       passed=false
cheating diagonal answer (honest+1)               -> rule=ld_diagonal_point   passed=false
malformed 2-element Point question                -> rule=ld_question_format  passed=false
```

— but **nothing in the suite establishes any of this**, so under law 4 `D^ld` is "runs without errors",
not a test.

**FIX DEMAND.** Add a `decider_rejections` testset containing exactly those four assertions (they are
verified-red as printed above), and register N1–N5 as permanent mutants in `test/mutations/`.

**SURVIVING WEAKER STATEMENT.** `ld_decider` ACCEPTS the honest `g = 1 + x_1 + x_1x_2` strategy on all
71,360 distinct support pairs and rejects one hand-built equal-type mismatch and one over-degree axis
answer; no evidence in the rung shows that `fig:ld-decider` items 2 or 3, the `Point`-on-the-left
symmetrization, the on-line guard, or the question-format guard can reject anything.

---

### O3 — **MAJOR** — the `SOURCE_REPAIR` carrying 7.03 % of the diagonal histogram mass is neither certificate-graded nor carried into the proposed TESTED row

**Location.** `src/samplers/ldt.jl:19-22` (a *comment*) and `test/tb1_ld_sampler.jl:23` (a *comment*),
against `docs/DESIGN.md` §1.5 ("the IR uses `L_lnf(0)=identity` and **marks the node** `SOURCE_REPAIR`"),
§3 ("`ASSUMED` and `SOURCE_REPAIR` nodes carry their visible residue"; "no detached evidence cache is
retained"; "Tests inspect the tree, not its prose"), and `docs/definitions.md:181` ("Only `CONSTRUCTED`
and `CHECKED` count as machine evidence").

**My independent computation.** `def:cl-canonical` is defined only for a set `F` of **linearly
independent** vectors; `{0}` is not one, so `L^lnf_0` is *undefined in the source*, while `def:line`'s
footnote explicitly permits `v=0`. The repair is load-bearing on exactly the subset DESIGN §5.3 demands
be included: **512 of 18,432** diagonal support keys (2.78 %), carrying
`64*(4*1 + 4*8) = 2,304` of `32,768` seeds (**7.03 %** of the mass), and **512 of 512** zero-direction
keys. Meanwhile `grep -n "CertNode\|Grade\|CONSTRUCTED\|CHECKED\|CITED"` over the entire TB1 lane
(`src/samplers/*.jl`, `src/verifiers/ldt.jl`, `test/tb1_ld_sampler.jl`) returns **one line**: the
`SOURCE_REPAIR` *comment*. TB1 constructs no `CertNode` at all, so `verify_certificate` and
`traceprint` cannot see the repair, and DESIGN §3's "tests inspect the tree" is vacuous for this rung.

**FIX DEMAND.** Emit `CertNode(SOURCE_REPAIR, :ld_lnf_zero_direction; facts=(support=512, mass=2304,
of=32768))` as a child of the diagonal-histogram evidence node, assert its presence and grade in the
levels testset, and append the scope clause to the C4a row text (authorized verbatim in §4).

**SURVIVING WEAKER STATEMENT.** The diagonal histogram equality is CHECKED from `def:cl-canonical`
alone on 17,920 of 18,432 support points; the remaining 512 additionally rest on a DESIGN
`SOURCE_REPAIR` that is not machine evidence by `definitions.md:181`.

---

### O4 — **MINOR** — `restrict`/`D^ld` degree bounds are format checks only; the "named point" in the degree separator is decorative

**Location.** `test/tb1_ld_sampler.jl:262-283`; `src/verifiers/ldt.jl:69-88`.

**My independent computation.** For `bad = x_1^2` on the axis line `l((0,5), e_1)` the restriction is
`t^2`, degree 2 > `d=1`, so `_answer_format` returns `:ld_axis_degree` at `location=(:left,1)` **before**
`_line_point_test` runs. The point `(3,5)` is indeed on that line (`(0,5)+3e_1`), but it plays no role
in the rejection. The test is honest (it asserts `result.rule == :ld_axis_degree`); the *report* is not:
"KILLED by the named point `(3,5)` / `x1^2` separator" attributes the kill to a point test that never
executed.

**FIX DEMAND.** Reword the report line to "KILLED by the `:ld_axis_degree` answer-format bound", and add
the complementary separator that *does* use the point: a degree-1 answer for `x_1^2` on that line, which
must fail `:ld_axis_point` at `t=3` (this is the N1-covering red test from O2).

**SURVIVING WEAKER STATEMENT.** `D^ld` rejects a `d=1`-claimed `x_1^2` because the honest axis
restriction over-runs the declared answer format, not because of any evaluation at `(3,5)`.

---

### O5 — **MAJOR** — the eager branch table makes `CLStep` unable to represent the very PCP samplers the same claim row talks about

**Location.** `src/samplers/cl.jl:70-93` — `_field_tuples(F, length(factor))` enumerates
`q^{|factor|}` **domain** points to discover the image, and `branches::Dict{Any,AbstractCL{F}}`
materialises one entry per image value. Against `docs/DESIGN.md` §1.5's own citation
`gt-04-cl.tex:L590-L595`, where the paper's sampler is an *algorithm* answering
`(factor, j, u)` and `(linear, j, u, y)` queries and never materialises a table.

**My independent computation** (measured on the archived copy):

```
L_ALine(GF8, m=1): enumerated inputs q^(m+1)=64      branch dict = 8   build 0.548 s
L_ALine(GF8, m=2): enumerated inputs q^(m+1)=512     branch dict = 8   build 0.120 s
L_ALine(GF8, m=4): enumerated inputs q^(m+1)=32768   branch dict = 8   build 1.759 s   (~54 us/input)
```

The dict stays at `q`; the *enumeration* grows as `q^{|factor|}`. At DESIGN §5.4's TB2 row (`q=2^11`):
`_build_L_ALine(GF2048, 2)` enumerates `2048^3 = 8,589,934,592` inputs — about **5.4 days** at the
measured rate. For PCP copy 6 (DESIGN §1.5: `dim(V_{6,coord})=6`, `dim(V_{6,dir})=m'=5m+5+s >= 15`),
stage 1 enumerates `>= 2048^21 ~ 3.45e69` inputs, and `L_DLine_6`'s direction stage has a branch dict of
up to `2048^15 ~ 4.68e49` **entries** — the latter is an intrinsic table size, not a slow loop, and no
optimisation of the enumeration fixes it. DD-7 ("make the conditional continuation a field of
`CLStep`") does **not** require eagerness; the paper's own sampler interface is lazy for exactly this
reason.

**FIX DEMAND.** Store the branch as a closure with a memoising `_child` that validates level and
register per encountered key; derive the image of `A` from its column space rather than by sweeping the
domain; keep the eager sweep behind an explicit budget that raises `ExpansionRefused`, as TB0's
`MonomialBudget` already does.

**SURVIVING WEAKER STATEMENT.** `CLStep`'s "level is impossible to forge" property is established only
for samplers every one of whose stages has a materialisable image; TB1's `(q,m)=(8,2)` instance
qualifies and DESIGN §5.4's `q=2^11` PCP family does not. C4's second sentence is therefore not merely
unbuilt but **unrepresentable in this IR as written**.

---

### O6 — **MINOR** — `CLStep` does not enforce `V_1 (+) V_{>1} = V`, which `def:cl-func` requires

**Location.** `src/samplers/cl.jl:64-65` (disjointness only) and `:85-86` (child register `==` rest).
There is no check that `factor ∪ rest` exhausts `1:seed_dim`.

**My independent computation.** `def:cl-func` (`gt-04-cl.tex:47-49`) says "There exist **complementary**
register subspaces `V_1` and `V_{>1}` of `V`", and `lem:cl-kth` item 2 says
`V = (+)_{i=1}^{l} V_{i, x^{L_{<i}}}` for all `x`. I constructed a step that violates it:

```
CLStep(GF8, 5, (1,2), (3,), I, CLZero(GF8,5,(3,)))
  -> SURVIVED. level=1  register_indices=(1,2,3)  seed_dim=5
```

Coordinates 4 and 5 belong to no factor space. The resulting map is still *a* CL function on `V` (pad
the last factor with the missing coordinates and the zero map), so no false CL claim follows — but the
datatype's invariant is "CL on `span(register_indices)`, extended by zero", not "CL on `V`", which is
weaker than DESIGN §1.5's "disjoint coordinate-index sets **spanning the ambient standard basis**".
TB1's own three objects are safe: `test/tb1_ld_sampler.jl:68-69` asserts
`register_indices == (1,2,3,4,5)` for all three.

**FIX DEMAND.** Add `Set(factor) ∪ Set(rest) == Set(1:n) || throw(...)` to both `CLStep` constructors
(allowing `CLZero(F,n,())` only as the terminal of a chain that already covered `1:n`), plus a red test
constructing the step above and expecting a throw.

**SURVIVING WEAKER STATEMENT.** Level and register-subspace-ness are CONSTRUCTED for the three TB1
objects (asserted at `test:66-69`), not for arbitrary `CLStep` values.

---

### O7 — **MINOR** — `level()` is the constructed nesting depth (an upper bound), and `pad_level` inflates it without limit

**Location.** `src/samplers/cl.jl:39-40`; `src/samplers/typed.jl:3-14`.

**My independent computation.** `pad_level(L_Point(GF8,2), 9)` has `level == 9` and is pointwise equal
to `L_Point` on all `8^5` seeds (verified exhaustively). This is *sound* — `rk:higher-level`
(`gt-04-cl.tex:127-134`) says every `l`-level CL function is also `(l+1)`-level — but it means
`level(L_ALine)==2` is a statement about the constructed witness, not a minimality claim, and the
M-level mutant (`1 + level(...)` → `level(...)`) only detects the increment being *lost* (it collapses
every level to 0), never inflation. `level` also reads `first(values(L.branches))`, i.e. an arbitrary
`Dict` entry; correctness rests on the uniform-child-level check at `cl.jl:87-91`, which is invisible at
the read site.

**FIX DEMAND.** Add `@test level(pad_level(L_Point(GF8,2), 5)) == 5` and a comment at `cl.jl:40` naming
`cl.jl:87-91` as the invariant that makes `first(values(...))` well-defined; state the upper-bound
reading in the C4a row (done in §4).

**SURVIVING WEAKER STATEMENT.** The three maps are CL functions of constructed nesting depth 1, 2, 3;
no lower bound on their minimum CL level is established or needed.

---

### O8 — **MINOR** — a third of the new sampler code is exported, untested, and unmutated

**Location.** `src/samplers/cl.jl:187-291` (`_shift_cl`, `_combine_embedded`, `_graft_concatenation`,
`direct_sum`, `concatenate`, `product`), `src/samplers/typed.jl` (entire file).

**My independent computation.** Grepping every exported TB1 symbol against `test/tb1_ld_sampler.jl` and
`test/tb0_core.jl` gives **zero** test references for: `AbstractCL`, `CLZero`, `CLStep`, `CLMarginal`,
`CLDistribution`, `concatenate`, `direct_sum`, `product`, `pad_level`, `TypedSampler`, `sample`,
`AffineLine`, `L_lnf`, `chi`, `pi_prefix`, `D_ld`. In particular the level equations these implement —
`lem:cl-concat` (`k+l`) and the direct-sum maximum (`gt-04-cl.tex:315-327`) — are never asserted, and
no mutation targets them. DESIGN §1.5's invariant table nevertheless grades "typed graph and product"
CONSTRUCTED, and brief 16 step 2 required them.

**FIX DEMAND.** Add three one-line assertions — `level(concatenate(a,b)) == level(a)+level(b)`,
`level(direct_sum(a,b)) == max(level(a),level(b))`, `TypedSampler(...).common_level == max(...)` — plus
one mutation flipping the `+` in `_graft_concatenation`'s level accounting; or delete the combinators
from the TB1 lane until TB2 needs them.

**SURVIVING WEAKER STATEMENT.** Only `L_Point`/`L_ALine`/`L_DLine`, `apply`, `level`, `seed_dim`,
`register_indices`, `marginal_k`, `sum_stage_outputs`, `distribution`, `histogram`, `axis_line`,
`diagonal_line`, `line_point`, `point_value`, `restrict`, `univariate_degree` and `ld_decider` carry
any TB1 evidence.

---

### O9 — **MINOR** — the 60 s gate is measured inside the process that must precompile the package, so the sequence CLAUDE.md documents fails on a clean checkout

**Location.** `test/runtests.jl:3-15` — `started = time()` precedes `include("tb0_core.jl")`, whose
`using MIPStarLambda` triggers package precompilation inside the timed region.

**My measurements on the archived copy** (see §2 for the full table). Cold (fresh
`JULIA_DEPOT_PATH`): gate measured **101.046 s**, `@test elapsed < 60` FAILS, exit **1**. First run at a
new source path with the shared depot: gate **92.697 s**, FAILS, exit **1**. Fully warm: **43.641 s** and
**42.281 s**, PASSES, exit **0**, 122/122. A single cold precompile of `MIPStarLambda` alone measures
**51.52 s** on this machine. The brief's condition ("if the 60 s gate fails warm on a quiet machine,
MAJOR") is **not** met — warm passes — so this is MINOR; but `CLAUDE.md`'s documented
`Pkg.instantiate()` then `julia --project=. test/runtests.jl` exits 1 on a fresh clone, and the warm
43.6 s sits 1.4 s under DESIGN's own 45 s **warning** line with TB1 contributing ~8 s.

**FIX DEMAND.** Subtract `Base.cumulative_compile_time_ns()` from `elapsed` (or move `using
MIPStarLambda` above `started`), and record TB1's ~8 s against the 45 s warning line.

**SURVIVING WEAKER STATEMENT.** The suite meets the 60 s gate on a **warm** cache only; the first
invocation after checkout or after any source-path change does not.

---

### O10 — **NOTE** — question parsing uses the ambient arity for all three types

`src/verifiers/ldt.jl:46` requires `length(raw) == 2m+1` for `Point`, `ALine` and `DLine` alike, where
`fig:ld-decider`'s table gives per-type widths `m`, `m+1`, `2m+1`; nothing checks that a `Point`
question's coordinate/direction registers, or an `ALine` question's direction register, are zero. Since
N5 survives, no arity is checked in practice either. Harmless for the CL encoding TB1 uses (all maps
output in `V`), but it must not be inherited by TB2's answer parsers, where `fig:decider-pcp` reads
per-type fields.

### O11 — **NOTE** — `kappa` is exercised only at 1

`LDParams(TB1_F, TB1_M, TB1_D, 1)` everywhere; `fig:ld-decider`'s `for all j in {1,...,kappa}` loops are
single-iteration throughout, and `_answer_entries` arity is never tested at `kappa > 1`. DESIGN §5.4
needs `ldparams' = (q, m', d, kappa = m'+6 = 22)`.

### O12 — **NOTE** — the mutation registry's wall time is not reproducible, and the harness re-precompiles the package 12 times

Report: "TB1 registry 114.81 s …; full 12-mutant registry 140.35 s." I measure **1233.16 s**
(20 m 33 s): TB0 block 12 m 23.6 s, TB1 block 8 m 08.1 s. `copied_mutant` (`test/mutations/run.jl:50-58`)
copies `src/` into a fresh `mktempdir()` per mutant, so each mutant pays a full package precompile,
measured at 51.5 s here; `12 * 51.5 = 618 s` plus 7 TB0 core runs (~35 s each) plus 5 TB1 runs (~6 s
each) accounts for essentially all of it. The machine was loaded (see §2). All key *numbers* in the
report reproduce exactly (§0); only this wall figure does not, so this is a NOTE, not a MAJOR
disagreement. **FIX DEMAND:** reuse one scratch project across mutants, rewriting only the mutated file
(cuts the registry to ~5 min and makes the reported figure reproducible).

---

## 2. Test and mutation summary lines observed

Full suite, archived copy, `julia --project=. test/runtests.jl` (Julia 1.12.5):

| run | depot / cache state | uptime load at start | gate `elapsed` | wall | exit |
|---|---|---|---|---|---|
| cold | fresh `JULIA_DEPOT_PATH` | `1,40 1,60 2,17` | **101.046 s → FAIL** | 104.70 s | 1 |
| warm-1 | shared depot, new source path | `1,97 2,15 2,33` | **92.697 s → FAIL** | 96.36 s | 1 |
| warm-2 | fully cached | `2,20 2,32 2,37` | **43.641 s → PASS** | 44.48 s (USER 44.35) | 0 |
| warm-3 | fully cached | `2,26 2,32 2,37` | **42.281 s → PASS** | 43.04 s (USER 42.94) | 0 |

```
Test Summary:                                             | Pass  Total     Time
MIPStarLambda                                             |  122    122     41.9s
  ... (16 TB0 testsets) ...
  TB1 datatype levels                                     |    3      3     0.0s
  TB1 exact axis histogram (M-χ owner)                    |    3      3     0.8s
  TB1 exact diagonal histogram (M-π, M-lnf owner)         |    4      4     0.5s
  TB1 exhaustive marginal replay                          |    3      3     1.5s
  TB1 all honest line restrictions                        |    5      5     0.5s
  TB1 D^ld honest deterministic sweep and consistency     |    5      5     2.5s
  TB1 axis degree rejection (M-deg owner)                 |    3      3     0.1s
  TB1 sampled question-pair trace                         |    3      3     0.4s
TB0 total wall seconds = 42.281 (warning=45.0, hard_limit=60.0)
```

**Was the machine loaded?** Yes. 12 cores; a TB2 `codex` worker ran throughout. Load average was
**1.3–3.3** during all four timed suite runs and USER ≈ WALL in both warm runs, so the (single-threaded)
Julia process was never CPU-starved and the 42–44 s warm figures are trustworthy; load later rose to
**10.08** during the mutation registry, which is why §1 O12's wall figure carries a caveat. The
proposer's warm claim of 41.37 s reproduces (42.3–43.6 s here).

Mutation registry, `julia --project=. test/mutations/run.jl` — **exit 0, 12/12 killed**:

```
MUTANT A e-2_to_e-1                       target=zero_basis            => KILLED (exit=1)
MUTANT B omit_g2_minus_o2                 target=pcp_separator         => KILLED (exit=1)
MUTANT C omit_output_literal              target=circuit               => KILLED (exit=1)
MUTANT D corrupt_field_reduction          target=field                 => KILLED (exit=1)
MUTANT E w1_fanout_2_to_1                 target=occurrence            => KILLED (exit=1)
MUTANT F degenerate_witness_ii_a3         target=nondegenerate         => KILLED (exit=1)
MUTANT C8 occurrence_ignores_fanout       target=c8                    => KILLED (exit=1)
Test Summary:          | Pass  Total      Time
TB0 targeted mutations |    7      7  12m23.6s
MUTANT TB1 M-χ shift_bucket_boundary      target=tb1_histogram_axis    => KILLED (exit=1)
MUTANT TB1 M-π omit_prefix_projection     target=tb1_histogram_diagonal=> KILLED (exit=1)
MUTANT TB1 M-lnf noncanonical_complement  target=tb1_histogram_diagonal=> KILLED (exit=1)
MUTANT TB1 M-deg axis_accepts_md          target=tb1_degree            => KILLED (exit=1)
MUTANT TB1 M-level omit_inductive_increment target=tb1_levels          => KILLED (exit=1)
Test Summary:          | Pass  Total     Time
TB1 targeted mutations |    5      5  8m08.1s
MUTWALL 1233.16 s
```

No FATAL: the suite runs, the mutation runner runs, and every registered mutant is killed.

## 3. My new mutations and their outcomes

Applied on copies only (`mktempdir`; `src/` + `test/tb1_ld_sampler.jl`), runner at
`.../critic-tb1-r1/indep/newmut.jl`.

| id | file:site | semantic change | outcome |
|---|---|---|---|
| N1 | `src/verifiers/ldt.jl:124` | `line_value == point_value_j ||` → `true ||` — the axis/diagonal line-vs-point tests always agree | **SURVIVED** |
| N2 | `src/verifiers/ldt.jl:159-161` | delete the `Point`-on-the-left arm; `(Point,ALine)`/`(Point,DLine)` fall through to `:ld_noop` accept | **SURVIVED** |
| N3 | `src/samplers/ldt.jl:157-158` | verifier-side `diagonal_line` skips `pi_prefix(direction, axis-1)` (`fig:ld-decider` item 3's `v'`) | **SURVIVED** |
| N4 | `src/verifiers/ldt.jl:109` | `_line_parameter` returns `(true, t)` — drop the point-on-line verification | **SURVIVED** |
| N5 | `src/verifiers/ldt.jl:46` | `length(raw) == 2m+1` → `length(raw) >= 0` | **SURVIVED** |
| N6 (control) | `src/verifiers/ldt.jl:26` | `restrict` doubles each coefficient (char 2: zeroes it) | KILLED by `TB1 all honest line restrictions` |

Five surviving semantic mutants ⇒ O2. The control confirms the harness is red-capable.

**The red tests my fix demand requires** (all four verified by me to reject on the unmutated code, §1 O2):

```julia
@testset "TB1 D^ld rejections" begin
    params = LDParams(GF8, 2, 1, 1)
    lay  = VarLayout((:x1,:x2), (VarBlock(:X,1:2),))
    g    = constant_poly(GF8,lay,1) + polyvar(GF8,lay,1) + polyvar(GF8,lay,1)*polyvar(GF8,lay,2)
    lay1 = VarLayout((:t,), (VarBlock(:LineParameter,1:1),))
    raw_axis  = (GF8(0),GF8(5),GF8(0),GF8(0),GF8(0))
    raw_point = (GF8(3),GF8(5),GF8(0),GF8(0),GF8(0))
    cheat = restrict(g, axis_line(raw_axis,2)) + constant_poly(GF8,lay1,GF8(1))
    pa    = (evaluate(g,[GF8(3),GF8(5)]),)
    @test univariate_degree(cheat) == 1                                    # format-legal
    @test ld_decider(params,:ALine,raw_axis,:Point,raw_point,(cheat,),pa).rule == :ld_axis_point
    @test !passed(ld_decider(params,:ALine,raw_axis,:Point,raw_point,(cheat,),pa))
    @test !passed(ld_decider(params,:Point,raw_point,:ALine,raw_axis,pa,(cheat,)))   # kills N2
    raw_d = (GF8(3),GF8(0),GF8(0),GF8(2),GF8(7))
    dl    = diagonal_line(raw_d,2); p = line_point(dl,GF8(4))
    cd    = restrict(g,dl) + constant_poly(GF8,lay1,GF8(1))
    @test ld_decider(params,:DLine,raw_d,:Point,(p...,GF8(0),GF8(0),GF8(0)),
                     (cd,),(evaluate(g,collect(p)),)).rule == :ld_diagonal_point
    @test !passed(ld_decider(params,:Point,(GF8(1),GF8(2)),:Point,(GF8(1),GF8(2)),
                             (GF8(0),),(GF8(0),)))                          # kills N5
end
```

## 4. Adjudication of the MERGE PROPOSAL (brief §Additional obligations)

The proposal is: *split C4 at its TB1 boundary; TESTED for the three CL functions' levels + histogram
equality; the 18-map product sentence stays CONJECTURE until TB2.*

**The split is AUTHORIZED. The proposed row text is REFUSED** (it carries "chi-independent", which O1
refutes, and it names `decider` as where-tested, which O2 refutes). **The following two rows are
authorized and must be copied VERBATIM** — format adaptations only in surrounding scaffolding, per
rk-light lane discipline.

**C4a — PROMOTE to TESTED:**

> | C4a | (Sampler is CL — TB1 instance) For `(q,m,d)=(8,2,1)` and ambient `V=V_pt (+) V_coord (+) V_dir` of `seed_dim` 5, `L_Point`, `L_ALine` and `L_DLine` are CL functions of constructed nesting depth 1, 2 and 3 respectively — upper bounds in the sense of `rk:higher-level`, not minimality claims — built only from `CLStep` stages whose factor and rest registers are disjoint coordinate-index sets whose union is all of `{1,...,5}`; `apply` equals the sum of the first `level` stage outputs on all `3 x 8^5 = 98,304` marginal replays (`lem:cl-kth` item 3); and over all `8^5 = 32,768` seeds the induced distributions `mu_{L_ALine,L_Point}` and `mu_{L_DLine,L_Point}` have exact histograms of support 512 and 18,432 (mass 32,768 each; 512 zero-direction support points carrying 2,304 seeds) agreeing entry-for-entry with a separately transcribed evaluation of `eq:cl-ptf`/`eq:cl-alnf`/`eq:cl-dlnf` **including `eq:chi-func`** — the comparison is NOT `chi`-independent (`verdicts/tb1-r1.md` O1) — and on the 512 zero-direction points the equality additionally rests on the DESIGN `SOURCE_REPAIR` `L^lnf_0 = id`, which `def:cl-canonical` does not define (O3). No claim is made here about `D^ld`, about `concatenate`/`direct_sum`/`product`/`TypedSampler`, or about any other `(q,m)`. | TESTED | D2 | — | `test/tb1_ld_sampler.jl` (`levels`, `histogram_axis`, `histogram_diagonal`, `marginals`); red: `test/mutations/tb1_{chi,pi,lnf,level}.jl` | `verdicts/tb1-r1.md` |

**C4b — HOLD at CONJECTURE** (agreeing with the proposer, and naming the missing step):

> | C4b | (Sampler is CL — PCP family) The 18 PCP maps `{Point_i, ALine_i, DLine_i}_{i=1..6}` form one typed CL family on `V^pcp`, each of level 1, 2 or 3 and padded to common level 3, and the typed answer-reduced product of that family with the oracularized sampler has level `max(ell,3)`. **Missing step:** not built at any parameter — `CLStep` materialises its branch table eagerly, so at DESIGN §5.4's `q=2^11` a single `L_ALine` stage enumerates `2048^3` domain points and `L_DLine_6`'s direction stage would need up to `2048^15` branch entries (`verdicts/tb1-r1.md` O5); a lazy/memoised branch representation matching `gt-04-cl.tex:L590-L595` is a precondition. | CONJECTURE | D2, C4a | — | — | — |

**Lockstep follow-ups for the orchestrator** (not TB1's lane): `C7`'s `depends-on` currently reads `C4`
and must become `C4a,C4b`; DESIGN §5.3's "the reference histogram is `chi`-free" sentence must be struck
or rewritten per O1; DESIGN §1.5's invariant row "equality to paper distributions | CHECKED | TB1 exact
histograms" should gain the SOURCE_REPAIR scope from O3.

## 5. Per-claim recommendation

| claim | recommendation | missing step (for HOLD) |
|---|---|---|
| **C4 → C4a** | **PROMOTE to TESTED**, with the authorized row text in §4 and only that text | — |
| **C4 → C4b** | **HOLD at CONJECTURE** | the family is unrepresentable in the current `CLStep` (O5); no lazy branch representation, no typed-product level test (O8) |
| **C7** | **HOLD at CONJECTURE** | it depends on C4; "affine restrictions, random-point tests, and products preserve CL-ness" needs the untested `concatenate`/`direct_sum`/`product` level equations (O8) |
| C1, C2, C3, C5, C6, C8, N1 | **unchanged** — outside this rung's lane; no TB1 evidence bears on them | — |

## 6. Elegance — three places the code is more complicated than the mathematics

1. **`L_lnf` materialises an `N x N` matrix for a one-line projector.** `src/samplers/ldt.jl:16-32`
   builds `_identity_matrix` and mutates a column, then every use pays an `O(N^2)` `_matvec` (three
   times per seed across 32,768 seeds). `def:cl-canonical` for a single kernel vector is
   `L_v(u) = u - (u_{j0}/v_{j0}) v` — and the *test's* reference `tb1_ref_lnf`
   (`test/tb1_ld_sampler.jl:21-26`) is exactly that one line, so the "reference" is the simple form and
   the "implementation" is the complicated one. **Simplification:** define `L_lnf(v, u)` as the
   one-liner, and derive the matrix only where a `CLStep` stage demands one, by applying it to the
   standard basis. Deletes `_identity_matrix` and ~12 lines.
2. **~105 lines (a third of `cl.jl`) rebuild whole branch tables under index shifts for combinators
   nothing calls.** `_shift_cl` / `_combine_embedded` / `_graft_concatenation`
   (`src/samplers/cl.jl:187-291`) implement `direct_sum` and `concatenate`, whose mathematical content
   (`lem:cl-concat`, `gt-04-cl.tex:315-327`) is two level equations. Zero TB1 call sites, zero tests,
   zero mutants (O8). **Simplification:** delete them from the TB1 lane and reintroduce them in TB2
   where the typed product actually needs them, with `level(concatenate(a,b)) == level(a)+level(b)` and
   `level(direct_sum(a,b)) == max(...)` as the tested contract.
3. **16 lines of hand caching duplicate the dispatch surface to save 0.12 s.**
   `src/samplers/ldt.jl:113-128` introduces three module-level consts plus a `GF8`-and-`Int(m)==2`
   specialisation of each of `L_Point`/`L_ALine`/`L_DLine`, alongside the generic `GF2k` method. I
   measured the thing being cached at **0.120 s**. Worse, the specialisation is keyed on `GF8`, so it
   silently does not apply to `GF2048` — precisely the TB2 field. **Simplification:** one
   `const _CL_CACHE = Dict{Tuple{DataType,Int},AbstractCL}()` with `get!`, or hoist the three objects
   into a `let` in the test; removes six methods and the field asymmetry.

*Runners-up (dead or vestigial, all one-line deletions):* `_answer_format`'s
`valid ? :ld_point_format : :ld_point_format` ternary with identical branches
(`src/verifiers/ldt.jl:66`); `tb1_actual_histogram` defined and never called
(`test/tb1_ld_sampler.jl:51-58`); `D_ld` exported and never used (`src/verifiers/ldt.jl:166`);
`marginal_k` constructing a `CLMarginal` twice merely to call `sum_stage_outputs` on the first
(`src/samplers/cl.jl:181-184`); `copied_mutant` re-precompiling the package 12 times (O12).

---

**What this rung got right, for the record:** the CL datatype genuinely forbids non-register stages
(§0(5)); `L_lnf` is genuinely the *canonical* map of `def:cl-canonical`, not merely some complement
(§0(2)); `chi` matches `eq:chi-func` exactly (§0(3)); every one of the report's printed numbers —
512, 18,432, 512 zero-direction, 98,304, 71,360, 16, 568, and the whole seed-`(3,5,4,6,7)` trace —
reproduces exactly against an implementation written from the ground truth alone (§0(1)); the honest
restrictions match hand computation (§0(4)); the suite is 122/122 green warm inside the 60 s gate; all
12 registered mutants are killed; no bare `@assert` appears anywhere in the lane; and the proposer
raised no status themselves. The four MAJORs are about what the evidence *says*, not about whether the
construction is right.

VERDICT: FAIL(O1,O2,O3,O5)
