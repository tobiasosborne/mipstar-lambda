# CRITIC verdict r6 — rung TB1 (`src/samplers/{cl,typed,ldt}.jl`, `src/verifiers/ldt.jl`, `test/tb1_ld_sampler.jl`, `test/mutations/tb1_*.jl`) at commit `7423c53`

Round 6, the closing round. **Prior.** `verdicts/tb1-r5.md` (FAIL(N29); N30/N31 MINOR, N32/N33 NOTE; C4a
RE-AFFIRM with an authorized row; C4c HELD with a pre-written row in two variants) is the work order, together
with `briefs/65-tb1-tb2-repair-r5.md` and its response table `briefs/65-tb1-tb2-repair-r5.last.md`. Everything
r1–r5 accepted is settled and is not re-litigated. Every TB1 row of the brief-65 table is adjudicated in §0; the
objections in §2 are new.

**Isolation.** `git archive 7423c53 | tar -x -C <scratch>/tree` into
`/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-…/scratchpad/critic-tb1-r6/tree`, `Pkg.instantiate()`
+ `Pkg.precompile()` there (196 s cold), and every test, mutation and experiment run there. `src/` and `test/`
were never read or run from the live tree; `docs/`, `briefs/`, `ground-truth/` were read from the **archived**
copy and every `file:line` below is that copy, except where §2 N35 explicitly reports on the live
`docs/DESIGN.md`. `claims/CLAIMS.md` was read live (orchestrator-owned). My only repo output is this file. No
state-changing git command was run.

**Independence.** §1.1's numbers come from `indep/probe1.jl`, which loads **no package code at all**: my own
GF(8) (carry-less multiply mod `x^3+x+1`, own inverse by `a^6`), my own `chi` from `eq:chi-func`, my own
`pi_prefix`, my own `L^lnf_v` read off `def:line-representative` (projection with kernel `span(v)` zeroing the
first nonzero coordinate; identity at `v=0`), my own `L_Point`/`L_ALine`/`L_DLine` transcribed from
`eq:cl-ptf`/`eq:cl-alnf`/`eq:cl-dlnf`, my own restriction of `g = 1 + x1 + x1 x2` to a line, my own on-line solve,
and my own transcription of `fig:ld-decider` items 1–3 under the variant-(b) reading. It reproduces the nine
support cells, the totals, `off_line = 0` and the 1,024 degenerate decisions from scratch. §1.2–§1.4 use the
package only to obtain the objects being judged.

**Machine note.** `powerprofilesctl get` reports **`balanced`**, not the `performance` that brief 67 states;
`/sys/.../scaling_governor` reads `powersave`; 12 CPUs; residual desktop load 1.0–6.2 throughout. `uptime` load
is quoted with every wall in §3. The TB0 gate measured 20.4 s and 21.9 s against a 60 s hard limit and a 45 s
warning — ~2.8× headroom even at load 5 on a non-performance profile.

**Lane check (law 1).** `git show --stat 7423c53` touches `briefs/65-…last.md`, `docs/DESIGN.md`,
`src/samplers/cl.jl`, `src/verifiers/{ldt,answer_reduce}.jl`, `test/tb1_ld_sampler.jl`,
`test/tb2_answer_reduce.jl`, `test/tb3_frontend.jl`, `test/mutations/{run.jl, tb1_kappa.jl, +4 new}` — **no
`claims/`**. No status was raised by the proposer; every claim edit is a MERGE PROPOSAL. The `docs/DESIGN.md`
edits are the orchestrator's, applied at this commit, and are checked in §0. Law 1 respected.

---

## 0. Adjudication of the brief-65 response table (TB1 rows)

| row | claimed | adjudicated | basis |
|---|---|---|---|
| **N29 MAJOR** (degenerate line checked at `t=0` only) | FIXED, variant (b) | **ACCEPTED** — with a new residue (N34) | The source-exact branch was taken, which is the branch I asked for by preference. `src/verifiers/ldt.jl:132` is `admissible = all(iszero, line.direction) ? field_elements(F) : (t,)` and `:133` is `for j in 1:params.kappa, s in admissible`; `field_elements(GF8)` is all eight elements (`gf2k.jl:106`), so item 3 (`gt-07-ldt.tex:379-384`) is now literal. I re-derived the whole thing without the package (§1.1): 1,024 of the 37,888 line-versus-point decisions are against a zero-direction line, **every one of them** with the point equal to the base, all of them `:DLine` (an axis line's direction is `e_{chi(s)}`, never zero), and the honest sweep still accepts everything with `off_line = 0`. My r5 cheat `f(t)=1+t` at seed `(0,0,0,0,0)` agrees with the point answer at `t=0` **only** and is now REJECTED at `location == 1` in **both** orders (§1.4, package; §1.1, my own rules). The off-base fixture is `:ld_diagonal_point` at `location == :question`. `tb1_degenerate_line.jl` is my NM15 verbatim, observed **KILLED (8.05 s)**, and its registered evidence line `off_base=ld_diagonal_point@1` is the *mutated* value (clean prints `@question`), so the kill is credited only when the branch actually flips. The new counter is **not** an NM11-style dead fact: my NM18 (`degenerate_hits += false`) is **KILLED** at `tb1:677` and `tb1:692` (§4). Residue: the *quantifier* "at all of them" is unwitnessed — N34. |
| **N30** (throw not closed under `direct_sum`) | DECIDED: normalise in `direct_sum` | **ACCEPTED as the correct decision** | `cl.jl:743` `_whole_space_zero(L::CLZero) = isempty(L.indices) \|\| _register(L) == 1:seed_dim(L)`, `:755` the all-whole-space shortcut. Independently reproduced (§1.2): `full+empty`, `empty+full` and `full+full` all give register `(1,2,3,4,5)` and promote to factor spaces `[[1,2,3,4,5]]`; `empty+empty` keeps `()` and promotes; `sub(3,[2])+full(2)` is transported verbatim to `(2,4,5)` and `pad_level` still refuses it with `ArgumentError`, as does `full(2)+sub(3,[2])` at `(1,2,4)` and the single-summand `sub(5,[2])`. I also checked what the response table did not claim: the normalisation is **associative** — `f+e+e`, `(f+e)+e` and `f+(e+e)` all give the full register `(1,2,3)` and `e+e+e` gives `()` — and the normalised sums still act as the zero map on 20 seeds. Choosing normalisation over widening `_pad_top` is right: it keeps N25's throw exactly where the r4/r5 argument put it. `tb1_dsum_zero_spellings.jl` observed **KILLED (13.85 s)**; my stronger NM19 (`_whole_space_zero ≡ true`) is also **KILLED**, at `tb1:212-213` (§4), so the sub-register refusal is pinned from both sides. |
| **N31** (canonical bytes not a canonical form) | option 2 (declare) + one assertion | **ACCEPTED for the code; PARTIAL for the lockstep** | `tb1:413-414` asserts `register_indices(CLZero(F,5,[2,1])) == register_indices(CLZero(F,5,[1,2])) == (1,2)` and that their canonical bytes differ. Independently reproduced (§1.3): same register, `apply` agrees on 20 seeds, bytes first differ at position **24**, and `decode_cl` round-trips both to `(1,2)`. The declaration half is where it is incomplete: r5 N32 authorized a DESIGN §9.3 sentence ("register index vectors are serialized in their declared order, so canonical bytes are canonical only up to that order"), and it landed **nowhere** — see N35. The C4a row already carries the N31 sentence, so claim and DESIGN are out of step. MINOR, orchestrator's lane. |
| TB2 rows (NG1, NG2, N27, N28, N30) | FIXED / disposition | **deferred to `verdicts/tb2-r6.md`** (brief 68) | Out of my lane. Two cross-lane facts belong on the record here because they run through TB1 code: (i) TB2 inherits variant (b) through the shared `_line_point_test`, so N34 applies to `C9` too (§2 N34); (ii) all 18 TB2 mutants and both new diagonal ones are KILLED in my registry run (§3). |
| CROSS-LANE EDIT (`test/tb3_frontend.jl` `7` → `9`) | declared | **ACCEPTED** | `tb3_frontend.jl:650,654`: the bare count pin on `_answer_reduce_replay_cases()` and the `/9` print. Mechanically forced by the two new replay cases, correctly declared, and TB3 is green in both suite runs. Nothing else in TB3 was touched. |
| DESIGN merges (DD-4 item 4; §9.4 N30 sentence) | orchestrator | **ACCEPTED — landed and accurate** | Archived `docs/DESIGN.md:1060` carries the DD-4 downstream sentence verbatim as proposed, and `:1239` the §9.4 N30 sentence. I checked the §9.4 sentence against the code and it is exactly right, including "full register unless every summand used the empty one". The r5 N32 §9.3 additions for row-major and `decode_cl`'s ambient re-imposition are at `:1215`. Only the N31 clause is missing (N35). |
| MERGE PROPOSALS (C4c variant (b), C4a N30 replacement, C9) | orchestrator | **PARTIAL** | C4a re-authorized in §5 with the proposer's N30 replacement verbatim (I verified every word of it) plus `dsum_zero_spellings` in the red list. C4c **promoted** in §5 with the variant-(b) sentence and **one added scope clause** for N34. C9 is brief 68's. |

---

## 1. Independent recomputation

### 1.1 The whole sweep, recomputed with no package code (`indep/probe1.jl`)

```
R6-P1 per-pair support:  Point -> [64, 512, 18432]   ALine -> [512, 64, 15296]   DLine -> [18432, 15296, 2752]
R6-P1 total support decisions = 71360
R6-P1 non_noop=40768 equal_type=2880 line_vs_point=37888 OFF_LINE=0
R6-P1 DEGENERATE line-vs-point decisions=1024 (point==base on 1024)  by kind=Dict(:DLine => 1024, :ALine => 0)
R6-P1 honest sweep all accepted (variant b) = true
R6-P1 zero-direction DLine/Point support points=512 carried by seeds=2304 => decisions over both orders=1024
```

Every number C4c asserts is mine, from `eq:cl-*` and `fig:ld-decider` alone. The last line is an independent
second route to the same 1,024: a zero-direction DLine question is `(u, s, 0)` (since `L^lnf_0 = id`) paired with
the Point question `(u,0,0)`, so the distinct pairs are indexed by `(u,s) in F_q^2 x F_q` — `64 * 8 = 512` of
them, carried by `2,304` seeds (`chi(s)=1` forces `v=(0,0)`, 256 seeds; `chi(s)=2` forces only `v_2=0`, 2,048
seeds), and `2 * 512 = 1,024` over both orders. That also re-derives C4a's "512 zero-direction support points
carrying 2,304 seeds" from the source.

### 1.2 `direct_sum`'s zero-map normalisation (`indep/probe3.jl`)

```
full(3)+empty(2)    register=(1, 2, 3, 4, 5)  pad_level(.,1) factor_spaces => [[1, 2, 3, 4, 5]]
empty(3)+full(2)    register=(1, 2, 3, 4, 5)  pad_level(.,1) factor_spaces => [[1, 2, 3, 4, 5]]
empty(3)+empty(2)   register=()               pad_level(.,1) factor_spaces => [[1, 2, 3, 4, 5]]
full(3)+full(2)     register=(1, 2, 3, 4, 5)  pad_level(.,1) factor_spaces => [[1, 2, 3, 4, 5]]
sub(3,[2])+full(2)  register=(2, 4, 5)        pad_level(.,1) factor_spaces => THROW ArgumentError
3-way f+e+e / nested (f+e)+e / nested f+(e+e)  register=(1, 2, 3)  => [[1, 2, 3]]     (associative)
3-way e+e+e         register=()               => [[1, 2, 3]]
```

### 1.3 N31, reproduced

```
register_indices([2,1]) vs [1,2] = ((1, 2), (1, 2));  apply agrees on 20 seeds = true
bytes equal? = false;  first differing byte position = 24;  decode_cl round trip both = ((1, 2), (1, 2))
```

### 1.4 The degenerate fixtures, and my own sharper cheat (`indep/probe2.jl`)

```
seed(0,0,0,0,0) diagonal line = (base (0,0), direction (0,0));  honest accepted = true
degree-1 cheat 1+t   (L,R) = (:ld_diagonal_point, false, 1)   (R,L) = (:ld_diagonal_point, false, 1)
degree-2 cheat degree = 2; values over t=0..7 = [1, 1, 7, 7, 3, 3, 5, 5]
degree-2 cheat a+t+t^2 (L,R) = (:ld_diagonal_point, false, 1)  (R,L) = (:ld_diagonal_point, false, 1)
off-base point on a degenerate line = (:ld_diagonal_point, false, :question, :point_on_line)
```

The degree-2 cheat `f(t) = 1 + t + t^2` has degree `2 <= md = 2`, agrees with the point answer at `t = 0` **and**
`t = 1` and at no other parameter. The clean executable rejects it, which is direct evidence that the comparison
really is made beyond `{0,1}`. It is also the witness the suite lacks — N34.

---

## 2. New objections

### N34 — **MINOR** — "compared at all `t in F_q`" has no red witness: a two-parameter admissible set survives the entire suite

**Location.** `src/verifiers/ldt.jl:132`. Against rk-light law 4 and the sentence C4c is being created with
("the executable requires agreement at all of them, which is the literal item") and the DESIGN DD-4 sentence at
`docs/DESIGN.md:1060` ("every `t in F_q` is admissible and the answers are compared at all of them").

**My computation (§4).** Replacing `field_elements(F)` by `(zero(F), one(F))` on the degenerate branch —
i.e. comparing at two parameters instead of eight — **SURVIVED** the TB1 rung (18.2 s, exit 0) and then
**SURVIVED the whole suite**, TB0+TB1+TB2+TB3, 1037/1037 in 87.1 s (run 4). Nothing notices: the honest sweep is
unaffected because honest restrictions on a degenerate line are constants; `degenerate_hits` is unaffected; the
certificate replay is unaffected; TB2's zero-seed diagonal cases — the ones the DESIGN sentence names — are
unaffected, because their corrupted answers differ from the honest ones at every parameter. The corpus's only
degenerate cheat is `degenerate_t0_cheat = 1 + t`, degree 1, agreeing at `t = 0` alone, so **any** admissible set
that contains one parameter where a degree-1 line answer differs from the constant passes every test; even the
singleton `(one(F),)` would survive. What is witnessed today is "the comparison happens somewhere useful", not
"at all eight".

The neighbouring residue, for the record: with `admissible` now driving the loop, the second component of
`_line_parameter`'s degenerate return (`zero(F)`) is dead, so a mutation of that constant alone is a genuine
no-op. `tb1_degenerate_line.jl` still bites because it flips the *boolean*.

**Why MINOR and not MAJOR** (brief 67's default is MAJOR for a survivor; I decline it deliberately). (i) The
executable is **source-exact** — I verified the all-parameter behaviour myself with a degree-2 cheat (§1.4), so
unlike r5's N29 there is no divergence from `gt-07-ldt.tex` and no accepted cheat; the claim text is TRUE, merely
under-witnessed by the repo's own corpus. (ii) The residue is the same species as the NM11 residue that r5
carried as a C4c **scope clause rather than an objection**, and I carry this one the same way, so the row I
authorize does not overclaim. (iii) It is a regression-coverage gap, not a fidelity gap: the exposure is that a
future refactor of `admissible` could silently weaken the decider. The orchestrator may of course run the six-line
repair below anyway; **nothing in this verdict's authorizations depends on it.**

**FIX DEMAND** (next TB1/TB2 touch, or brief 39 — not a further round). In `decider_rejections`, beside
`degenerate_t0_cheat`:

```julia
# verdicts/tb1-r6.md N34: a degree-2 cheat (md = 2) agreeing with the point
# answer at t = 0 AND t = 1 and nowhere else pins the quantifier "every t in
# F_q", which the degree-1 cheat alone does not.
degenerate_t01_cheat = constant_poly(GF8, lay1, base_answer[1]) +
                       polyvar(GF8, lay1, 1) + polyvar(GF8, lay1, 1)^2
@test univariate_degree(degenerate_t01_cheat) == 2
@test [evaluate(degenerate_t01_cheat, GF8[GF8(i)]) for i in 0:7] == GF8[1, 1, 7, 7, 3, 3, 5, 5]
t01_lr = ld_decider(params, :DLine, raw_degenerate, :Point, raw_base_point,
                    (degenerate_t01_cheat,), base_answer)
t01_rl = ld_decider(params, :Point, raw_base_point, :DLine, raw_degenerate,
                    base_answer, (degenerate_t01_cheat,))
@test t01_lr.rule == :ld_diagonal_point && !passed(t01_lr) && t01_lr.location == 1
@test t01_rl.rule == :ld_diagonal_point && !passed(t01_rl) && t01_rl.location == 1
```

extend the printed marker with ` t01_cheat_passed=`, and register
`test/mutations/tb1_degenerate_admissible.jl`:

```julia
Mutant("TB1 N34-degenerate-admissible compare_only_at_two_parameters",
       "src/verifiers/ldt.jl",
       "    admissible = all(iszero, line.direction) ? field_elements(F) : (t,)",
       "    admissible = all(iszero, line.direction) ? (zero(F), one(F)) : (t,)",
       "tb1_decider_rejections",
       "MUTATION_EXPECTED_RULE degenerate_line off_base=ld_diagonal_point@question t0_cheat_passed=false t01_cheat_passed=true")
```

shown KILLED. When it lands, the N34 scope clause may be struck from C4c by the next verdict — never by the
author.

**SURVIVING WEAKER STATEMENT.** The executable compares at all `q` admissible parameters; I verified it directly
(§1.4). The suite witnesses that it compares at at least one parameter separating a degree-1 cheat from the
constant, and that the degenerate branch's on-line predicate is red-capable in both directions.

### N35 — **NOTE** — r5 N32's §9.3 N31 sentence never landed, so DESIGN and C4a are out of lockstep on canonical bytes

**Location.** `docs/DESIGN.md:1215`, archived **and** live (`grep` for "declared order", "canonical only up to"
and "N31" over both returns nothing). The §9.3 byte-format paragraph took the r5 N32 additions for row-major and
`decode_cl`'s ambient re-imposition but not the third: "register index vectors are serialized in their declared
order, so canonical bytes are canonical only up to that order". C4a's landed row already asserts exactly that
(and `tb1:413` pins it), so the single-source paragraph is the one place that does not say it. Orchestrator's
lane; the fix is the one sentence r5 already authorized. This matters for TB5: `S^rep` hashing needs a
normalising step or a stated convention, and DESIGN §9.3 is where a TB5 author will look.

### N36 — **NOTE** — a degenerate-line failure does not report which parameter failed

`_line_point_test` returns `location = j` (the answer index) with `expected`/`actual` taken at the failing `s`,
but `s` itself is dropped. Before variant (b) there was only one admissible parameter, so `location = j` was a
complete address; now, on 1,024 of TB1's decisions and on TB2's zero-seed diagonal cases, it is not. Nothing
today depends on it — every assertion in the corpus checks `rule`, `passed` and `location` only — but a
diagnostic that cannot say *where* on the line the answers diverge will be awkward when TB5/TB6 replay these
transcripts. Cheap fix when the file is next touched: `location = (j, s)` on the degenerate branch, or add `s` to
the `CheckResult` facts. Not demanded.

---

## 3. Test and mutation runs observed (archived copy at `7423c53`, Julia 1.12.5)

All runs are mine, on the archived tree. `uptime` load average is quoted at start → end. Power profile
`balanced`, governor `powersave`, 12 CPUs.

| run | what | load (start → end) | TB0 test-body wall | wall | result |
|---|---|---|---|---|---|
| 0 | `Pkg.instantiate()` + `Pkg.precompile()` (cold) | `1.59 3.29 3.96` → — | — | 196 s | exit 0, `using MIPStarLambda` OK |
| 1 | `test/runtests.jl` | `3.32 3.32 3.82` → `5.00 3.92 3.96` | **20.361 s** (warning 45 not fired) | 158 s | **exit 0, 1038/1038** |
| 2 | `test/mutations/run.jl` | `1.02 3.16 3.74` → `5.30 6.16 5.10` | — | 505 s | **exit 0**, `MUTATION REGISTRY: killed=101/101 baselines ok=47/47 wall=504.28 s` |
| 3 | `test/runtests.jl` | `5.30 6.16 5.10` → `2.91 5.11 4.82` | **21.885 s** | 91 s | **exit 0, 1038/1038** |
| 4 | NM17 over TB0+TB1+TB2+TB3 | `2.91 5.11 4.82` → `1.90 4.21 4.52` | — | 87 s | **exit 0, 1037/1037 → SURVIVED** (N34) |
| 5 | `indep/probe1.jl` (no package code) | `4.46 4.04 4.00` → `4.51 4.06 4.01` | — | 6 s | §1.1 |
| 6 | `indep/newmut.jl` (4 mutants, TB1 rung each) | `4.79 4.25 4.08` → `5.13 4.49 4.18` | — | 71 s | §4 |
| 7 | `indep/probe2.jl`, `indep/probe3.jl` | `2.50 3.92 4.01` → `1.55 3.44 3.84` | — | 8 s | §1.2–§1.4 |

Zero `SURVIVED`, `UNATTRIBUTABLE`, `LOAD-ERROR` or `KILLED-BY-CRASH` lines in the registry run, and 47/47
baselines OK. The registry is **101 mutants over 47 baselines**: 28 TB0, **37 TB1**, 18 TB2, 18 TB3 — up from
r5's 84/43 by this round's 2 TB1 + 2 TB2 arrivals and TB3's 13 (brief 63). This round's TB1 arrivals and the
re-headed mutant:

```
MUTANT TB1 M-kappa line_point_checks_first_entry_only                    target=tb1_decider_rejections => KILLED ( 5.59 s)
MUTANT TB1 N29-degenerate-line every_point_on_degenerate_line            target=tb1_decider_rejections => KILLED ( 8.05 s)
MUTANT TB1 N30-dsum-zero-spellings direct_sum_keeps_concatenated_register target=tb1_levels            => KILLED (13.85 s)
```

**`tb1_kappa.jl` is still meaningful after the re-heading.** Its `before` was rewritten to
`for j in 1:params.kappa, s in admissible\n        line_value = evaluate(line_answer[j], [s])` and its `after`
changes only `1:params.kappa` → `1:1`; the `s` loop is carried through unchanged, so the mutation is exactly the
old one (check only the first answer entry) and it is owned by the `kappa = 2` second-entry-cheat fixture, which
is why it is KILLED. The re-heading is a context update, not a weakening.

Suite evidence lines on the unmutated tree (run 1), all present:

```
MUTATION_EXPECTED_RULE degenerate_line off_base=ld_diagonal_point@question t0_cheat_passed=false
MUTATION_EXPECTED_RULE dsum_zero_spellings promoted=true
MUTATION_EXPECTED_RULE off_line reached=false hits=0
TB1 D^ld: type_pairs=9 seeds=32768 support_decisions=71360 non_noop=40768
          (equal-type tautologies=2880 line_vs_point=37888) off_line_hits=0 degenerate_line_vs_point=1024
```

## 4. My new mutations

Applied on copies only (`mktempdir`; the mutated file written to a sandbox and `Base.include`d into the loaded
module, exactly as `test/mutations/run.jl` does; the archived tree never modified). Runner
`indep/newmut.jl`, `TB1_TARGET=all`; NM17 additionally re-run over all four rung test files (run 4).

| id | file:site | semantic change | outcome |
|---|---|---|---|
| **NM16** | `ldt.jl:132` | revert to the r5 N29 bug: `admissible = (t,)` unconditionally | **KILLED** (27.2 s) — sole failures `tb1:806` and `tb1:807` (`t0_lr`/`t0_rl`), evidence flips to `t0_cheat_passed=true`. The fix is red-capable. **No registered mutant owns this site**, though: `tb1_degenerate_line.jl` mutates `_line_parameter`, a different function. Registering NM16 alongside the N34 mutant would be tidy; it is not demanded, since the N34 mutant subsumes it. |
| **NM17** | `ldt.jl:132` | compare at two parameters only on a degenerate line: `(zero(F), one(F))` | **SURVIVED** the TB1 rung (18.2 s) **and the whole suite** (1037/1037, 87.1 s) → **N34** |
| **NM18** | `ldt.jl:249` | the sweep stops counting degenerate decisions (`degenerate_hits += false`) | **KILLED** (15.6 s) — `tb1:677` (`report.degenerate_hits == 1_024`) and `tb1:692` (the CHECKED node's `degenerate_line_vs_point`). Unlike `off_line_hits`, the new counter is red-capable as an *expression*, because its honest value is nonzero. |
| **NM19** | `cl.jl:743` | `_whole_space_zero ≡ true`: a proper sub-register zero summand is treated as whole-space | **KILLED** (8.3 s) — `tb1:212` (`register_indices(...) == (2,4,5)`) and `tb1:213` (the `@test_throws`). The normalisation is pinned on the refusal side too. |

Three of the four are killed by assertions this round added; the fourth is the objection.

## 5. Per-claim decision

| claim | decision | note |
|---|---|---|
| **C4a** | **RE-AFFIRM at TESTED**, replacing the row with the authorized text below | Every fact in the brief-65 N30 merge proposal independently reproduced (§1.2), including the associativity and zero-map-semantics checks the proposal did not claim; N31 reproduced (§1.3); `tb1_dsum_zero_spellings.jl` observed KILLED and my stronger NM19 also KILLED. The proposer's replacement sentence is adopted **verbatim**. Status may not rise further. |
| **C4c** | **PROMOTE: created at TESTED** with the row below (variant (b), plus one added scope clause) | The r5 missing step (N29) is discharged in the strong form: the source-exact branch, 1,024 recomputed by me from `eq:cl-*` by two independent routes, the honest sweep still accepting with `off_line = 0`, the degree-1 cheat rejected in both orders, the off-base point still the `:ld_off_line_rejects` SOURCE_REPAIR, the counter red-capable (NM18 KILLED), and `tb1_degenerate_line.jl` KILLED with a mutation-only evidence line. The one residue (N34) is a witness gap in the quantifier, not a divergence, and it is stated in the row's scope, so the row does not overclaim. |
| **C4b** | defer to `verdicts/tb2-r6.md` | brief 68's lane. TB1-relevant residue only: `pad_level`'s promotion path is now pinned from both sides (NM19). |
| **C9** | defer to `verdicts/tb2-r6.md` | TB2's lane. Carry N34 across: C9's inheritance of variant (b) at `kappa = 22`, `q = 2048` is equally unwitnessed (run 4). |
| **C7** | HOLD at CONJECTURE | `depends-on = C4a,C4b` remains correct; no TB1 evidence bears on it. |
| C1–C3, C5, C6, C8, C12–C19 | unchanged | outside this rung's lane. |

**C4a — AUTHORIZED VERBATIM ROW.** It is the currently landed row with exactly two changes: the N30 sentence
("`direct_sum` of a whole-space zero map declared on its full register … not interchangeable under `pad_level`
after `direct_sum` (`verdicts/tb1-r5.md` N30).") replaced by the proposer's text, and `dsum_zero_spellings` added
to the red list. Nothing else in the row may move.

> Replacement sentence: `direct_sum` of whole-space zero maps in either spelling is the whole-space zero map on the summed ambient (full register unless every summand used the empty one), so the two spellings stay interchangeable under `pad_level`; a proper sub-register summand is transported verbatim and still refused (`verdicts/tb1-r5.md` N30; `verdicts/tb1-r6.md` §1.2; `tb1_dsum_zero_spellings.jl`).
>
> Red list: append `dsum_zero_spellings` to `test/mutations/tb1_{…}.jl`.
>
> Verdict column: append `verdicts/tb1-r6.md`.

**C4c — AUTHORIZED VERBATIM ROW** (copy exactly; only surrounding table scaffolding may be adapted). This is
`verdicts/tb1-r5.md` §5's pre-written row with variant (b) kept and variant (a) dropped, as the proposer's merge
proposal asks, plus the r6 recount citations and the N34 scope clause:

> | C4c | (TB1 `D^ld`, `(q,m,d)=(8,2,1)` at `kappa=1`) `ld_decider` implements `fig:ld-decider` with answer bounds `d=1` (axis) and `md=2` (diagonal, tight: `verdicts/tb1-r3.md` §1.4), symmetrized over the pair order. Over all `8^5` seeds the honest prover for `g = 1 + x1 + x1 x2` is accepted on all 71,360 distinct support decisions of the nine ordered type pairs (per pair: 64/512/18,432; 512/64/15,296; 18,432/15,296/2,752 — recomputed independently in `verdicts/tb1-r4.md` §1.6, in `verdicts/tb1-r5.md` §1.3, and again in `verdicts/tb1-r6.md` §1.1 from `eq:cl-ptf`/`eq:cl-alnf`/`eq:cl-dlnf` with no package code); 40,768 are non-noop, split 2,880 equal-type tautologies / 37,888 line-versus-point; the off-line branch is reached 0 times. The sweep is a CHECKED `:ld_honest_sweep` node (`ld_sweep_evidence`) whose replay re-runs it from `(params, g, samplers, seeds)` and rejects a tampered report, carrying `SOURCE_REPAIR :ld_off_line_rejects` (`gt-07-ldt.tex:377-384` accepts vacuously when no `t` exists; the executable rejects, strictly stricter). On a zero-direction diagonal line — 1,024 of the 37,888 line-versus-point decisions, every one of them with the point equal to the line's base, and all of them of type `DLine` since an axis line's direction `e_{chi(s)}` is never zero — every `t in F_q` satisfies item 3's constraint, and the executable requires agreement at all of them, which is the literal item (`verdicts/tb1-r5.md` N29, variant (b); count re-derived two ways in `verdicts/tb1-r6.md` §1.1 — 512 zero-direction support points carrying 2,304 seeds, doubled over the pair order — and the `degenerate_line_vs_point` fact is red-capable, `verdicts/tb1-r6.md` §4 NM18). Separately, at `kappa=2` the `for all j in 1..kappa` loops and the answer arity are exercised by three fixtures (accept, second-entry cheat at `location==2`, short answer `:ld_answer_arity`). **Scope:** one polynomial, one field row, no soundness claim; the sweep's counts are functions of the question supports and the guard dispatch and do not depend on the honest polynomial's identity (`verdicts/tb1-r4.md` N28); equal-type decisions are identical-question tautologies (`verdicts/tb1-r2.md` N11); `off_line_hits = 0` is red-capable as a fact (`tb1_off_line.jl` drives it positive) but the counter expression itself may still be replaced by the constant `false` without any test noticing, its honest value being 0 (`verdicts/tb1-r5.md` §4, NM11). The degenerate branch's *quantifier* is critic-verified, not yet suite-witnessed: this critic checked directly that a degree-2 cheat `f(t)=1+t+t^2` agreeing with the point answer at `t in {0,1}` only is rejected at `location==1` in both orders (`verdicts/tb1-r6.md` §1.4), but the suite's own degenerate cheat is degree 1 and agrees at `t=0` alone, so replacing the admissible set by any two parameters — or even by the singleton `t=1` — survives the whole suite, TB2 included (ibid. N34). | TESTED | D2, C4a | — | `test/tb1_ld_sampler.jl` (`decider`, `decider_rejections`, `degree`, `restrictions`, `trace`); red: `test/mutations/tb1_{deg,agreement,symmetry,verifier_pi,online,off_line,degenerate_line,question_arity,kappa,dline_degree}.jl` | `verdicts/tb1-r1.md`..`verdicts/tb1-r6.md` |

**Lockstep follow-up for the orchestrator** (not TB1's lane): the one DESIGN §9.3 sentence of N35, already
authorized verbatim in `verdicts/tb1-r5.md` N32.

## 6. Forward look — residuals for the record (no further TB1 round demanded)

- **NOTE for brief 39 (TB5), amending r5's list.** NOTE 1 (byte format): row-major is pinned at both ends; index
  vectors are serialized in declared order and must be normalised before `S^rep` hashing — and DESIGN §9.3 still
  does not say so (N35). NOTE 2 (zero components): **closed** — `direct_sum` now normalises whole-space zero maps
  and the rule is associative (§1.2), so the description-level `DL9-direct-sum` can be written against a settled
  rule; the only remaining shape is a proper sub-register summand, which is transported and refused by design.
  NOTE 7 (degenerate lines downstream): DD-4's question is now answered for `D^ld` at both parameter rows, and
  the answer is "compare at every `t`"; whoever writes `fig:decider-pcp` steps 3/4(b)/4(c) against a larger
  `kappa` inherits the `q * kappa` cost on degenerate lines, and inherits N34's witness gap unless the degree-2
  fixture goes in. r5's NOTEs 3–6 stand.
- **MINOR carried, not demanded:** N34 (the six-line red test above), N35 (one DESIGN sentence), N36 (report the
  failing line parameter).

---

**What this round got right, for the record.** The MAJOR was closed in the strong direction — the source-exact
reading of item 3, not the declared totalization — and the repair went past its brief: the new
`degenerate_line_vs_point` fact is asserted in both the report and the certificate and is red-capable (my NM18
dies), which is more than `off_line_hits` ever managed; the N30 decision picked the branch that preserves N25's
throw rather than undoing it, and it turns out to be associative and semantically silent; and the re-headed
`tb1_kappa` mutant is unweakened. 1038/1038 twice, 101/101 mutants over 47/47 baselines, every number in C4a and
C4c reproduced from the TeX with no package code on the path. The one thing left is a witness, not a defect: the
decider does compare at all eight parameters — I checked — but only I checked.

VERDICT: PASS
