# Verdict — TB6 r1 (brief 79). Critic: Opus, 2026-09-05. Target: archived tree `0ec462e`.

Lane: this file only. Nothing else in the repo was written; no state-changing git ran.
Everything below was extracted with `git archive 0ec462e | tar -x` into
`…/scratchpad/critic-tb6-r1/tree` and run there; `claims/CLAIMS.md` was read live.
Every number in §1 was recomputed with the critic's own code on a copy
(`…/critic-tb6-r1/own/{A_recompute.jl,B_cross.jl,B5.jl}`) or by hand from the TeX,
never from the package's machines and never from memory.

---

## 0. Runs, walls, load

| run | result | wall | load (`uptime`, before → after) |
|---|---|---|---|
| `Pkg.instantiate()` + cold `using MIPStarLambda` | exit 0; `70362.3 ms ✓ MIPStarLambda` | 70.4 s precompile (≈3 min incl. registry update) | 16:45 `0.20/1.57/2.61` → 16:49 `0.24/1.62/2.64` |
| `julia --project=. test/runtests.jl` | **12105/12105, exit 0** | `/usr/bin/time` **2:10.70**, Test Summary 2m08.7 s, maxrss **1843.0 MiB** | 16:49:52 `0.20 1.57 2.61` → 16:52:03 `1.61 1.60 2.48` |
| `MUTATION_JOBS=4 julia --project=. test/mutations/run.jl` | **exit 1** — 181 KILLED, 1 UNATTRIBUTABLE, **1 BROKEN baseline**, no `MUTATION REGISTRY` line | **24 m 13 s** | 16:56:18 `0.79 1.46 2.24` → 17:20:31 `5.57 7.02 6.42` |
| critic mutants CRIT-1..CRIT-4 (own, on copies) | 2 SURVIVED, 2 KILLED (§3) | 4 × ≈2.5 min | 17:26–17:40, load 1.0–2.5 |
| critic recomputations A/B/B5 | see §1 | 2 s / 40 s / 20 s | 17:24–17:26, load 1.0–2.3 |

In-suite component walls (quiet): TB0 body **15.479 s**, calibration kernel 0.4798 s,
ratio **32.3** (gate 50, hard wall 60) — both gates pass. TB6 body **28.469 s** =
TB6a 2.765 s + 6.43 s `_require_image` measurement + TB6b 19.265 s
(E construction 0.223 / transcripts 2.281; M construction 0.074 / transcripts 1.755);
TB6b RSS delta 211.8 MiB (< 512).

Runner detail (this is objection O2): `BASELINE runtests.jl TB0_TARGET=all => BROKEN
(exit=1, 305.9 s)`, failing at `test/tb6a_audit.jl:215`,
`@test tb6a_audit_elapsed < 5` — **measured 5.429 s** with the calibration kernel at
1.2769 s (2.7× its quiet value) under the runner's own 4-way load. Consequence:
`TB0 M-gate-body-inflated` is reported `UNATTRIBUTABLE (target exits 1 unmutated)`
even though its target did fail exactly as designed (`TB0 test-body wall 76.675 s`,
`wall<60.0 => false`), the registry summary line never prints, and the process exits 1.
All 15 TB6 mutants and all 9 brief-77 mutants were KILLED in the same run.

---

## 1. Independent recomputation (own code, on a copy)

**(1) Type sets and graphs — from the TikZ, by hand and in my own code.**
`TypePauli` = ({Point,ALine,DLine,Pauli,Pair}×{X,Z}) ∪ 6 Constraints ∪ 9 Variables ∪ {Pair}
= **26**. `G^pauli` non-loops = 18 Magic-Square incidences (`\foreach` i∈1..3,j∈1..3,
k=(i−1)3+j and i∈4..6,j∈1..3, k=i−3+(j−1)3) + 6 chain edges + `PointX–Variable1`,
`PointZ–Variable5` + the two `PointW–PairW–Pair` chains = **30**; oriented =
2·30+26 = **86**. Matches `pauli_types.jl` and the test's hand list.
`TypeIntro` = 32+2ℓ; non-loops = 30 + per role (Sample–Introspect, Introspect–Read,
PauliZ–Sample, PauliX–Hide₁, ℓ−1 chain edges, Hide_ℓ–Read) + IntroA–IntroB = **2ℓ+39**;
oriented = **6ℓ+110**. At ℓ=1,3,9: 34/38/50 types, 41/45/57 non-loops, **116/128/164**
oriented — all confirmed. Hide-incident oriented = 2(4+2(ℓ−1))+2ℓ = **10 / 22 / 58**.
(The brief-43 report prints "10/22/**46**"; the code and I both give 58 — objection O5.)

**(2) `D^pauli`'s guards and census.** Re-read `fig:decider_pauli` (gt-07:L1126–L1227):
seven enumerated items (consistency; low-degree 2(a)/2(b); Point/Pauli; then γ and
commutation, Point/Pair, Magic-Square, Point/Variable). My own enumeration of the
applicability sets over all 26×26 ordered label pairs gives
`26 / 4 / 2 / 2 / 2 / 54 / 18` — identical to `pauli_guard_table()` and to the printed
census; `_pauli_guard` fires on exactly the 82 listed non-loop ordered pairs.

**(3) Dimensions and parameters.** E (m=1,q=2,ℓ=1,λ=1,s=1): 3m+3=**6**, downsized
6·log₂2=**6**, |TypeIntro|=34, detyped 6+4·34=**142**, Q=2^m·log₂q=**2**, M=**2**,
R=4^1=**4**, dm/q=1/2 (VACUOUS). M (m=2,q=8,ℓ=3,λ=2,s=6): 3m+3=9, downsized 9·3=**27**,
|TypeIntro|=38, detyped 27+4·38=**179**, Q=**12**, M=**4**, R=**16**, dm/q=**1/4** (live).
Canonical-`introparams` obstructions, recomputed from `def:introparams`
(k=c⌈lg lg R⌉+1, m = largest 2^j ≤ c⌈lg R⌉+1, c even ≥ 2): at R=4 the tuple's k=1
forces c=0 (forbidden) and the least legal c=2 gives (q,m,d)=(8,**4**,1) vs tuple m=1;
at R=16 the tuple's k=3 forces c=1 (odd, forbidden), that value would give m=4, and
c=2 gives (32,**8**,1) vs tuple m=2. **Both printed policy reports match DESIGN §11.6
verbatim, line for line**, including every PASS/FAIL/VACUOUS/NOT_EVALUABLE and owner.

**(4) The query schedule.** Derived independently from gt-08:L520–L524 (Dimension first),
L570–L579 (`factor(1,0)`, then `factor(j, y_{≤j−1})` with `y_{≤j−1}=L_{≤j−1}(y)`),
L659–L668 (`factor(k+1, y_{w̄,≤k})` then one `linear` per basis vector h_i), L616–L626
(`marginal(N,role,ℓ,z)` for `L^role(z)`). For (Hide₁,Hide₂) on M my derivation is
`dimension; factor(1,0)[w]; factor(1,0)[w̄]; marginal(1,y_{w̄}); factor(2,u); linear(2,u,h₁);
linear(2,u,h₂)` — exactly the recorded log, and `intro_query_plan(ℓ)` at ℓ=1,3,9 agrees
term by term with my reading for every one of the nine tests (empty for `pauli`,
`sampling_pauli`, `hiding_intro`, `consistency`; `(:Marginal, ℓ)` for `sampling_intro`;
`(:Marginal, ℓ−1)×2` for `hiding_read`; `(:Factor,1),(:Linear,1,·)` for `hiding_pauli`;
`(:Decider,N)` for `game`). Every call is at N=2ⁿ.

**(5) THE TWO NEW SOURCE_REPAIRs — the central judgment.**

*(a) `intro-perp-orthogonal` — **GENUINE SOURCE DEFECT; the repair is the only reading
consistent with the source's own definitions. ACCEPTED.***
gt-08:L669–L678 step (d) says: "Compute the canonical complement S of F, as in
Definition~\ref{def:canonical-complement}. S is a basis for ker(L)^⊥", then step (e)
applies `def:cl-canonical` with kernel basis S. But `def:canonical-complement`
(gt-03:L307–L318) returns `{ê_j : j ∉ J}` for the RREF pivot set J of F, and the
source's *own* Remark (gt-03:L333–L340) says its span coincides with `S^⊥` **only when
the subspace is a register subspace**. So the sentence "S is a basis for ker(L)^⊥" is
false in general, and the procedure does not implement `def:Lperp` (gt-03:L386–L392).
My own F₂ linear algebra on TB6b-M's stage-2 map `M=[[1,1],[0,0]]` (columns c₁=c₂=(1,0)):
ker(M)=⟨(1,1)⟩=⟨e₄+e₅⟩; canonical complement = {(0,1)}=⟨e₅⟩; orthogonal complement
= {v : v·(1,1)=0} = ⟨(1,1)⟩. Hence
* literal reading: `L^⊥_lit = [[1,0],[0,0]]`, ker = ⟨e₅⟩, `(ker L^⊥)^⊥ = ⟨e₄⟩ ⊄ ker(L)` —
  `lem:commute` **fails**, and exactly one (Z,X) generator pair anticommutes
  (⟨(1,1)⟩ vs ⟨(1,0)⟩, symplectic product 1);
* orthogonal reading: `L^⊥ = [[0,0],[1,1]]`, ker = ⟨(1,1)⟩ = ker(L)^⊥, so
  `ker(L^⊥) = ker(L)^⊥` (`lem:L_perp_perp`) and `(ker L^⊥)^⊥ = ker(L)`, i.e. exactly the
  criterion the completeness proof invokes at gt-08:L1136–L1141 — 0 anticommuting pairs.

The source is therefore **internally inconsistent**: its honest strategy needs
`ker(L_j^⊥)^⊥ = ker(L_j)` (L1136–L1141, `lem:perp_perp`), which its own decider
procedure does not deliver. `perp_map` implements `def:Lperp` exactly; `perp_map_literal`
keeps the literal reading visible; the map is basis-independent (the RREF pivot set of a
basis depends only on its span). **On the honest Hide₁/Hide₂ transcripts the literal dual
map rejects 48 of 64 leaves and the orthogonal map rejects 0 — I reproduced 48/64 and 0/64
with my own `rref`/kernel/canonical-complement/projector code, reading only `(x_w, y^⊥_{w̄})`
off the package's transcripts** (`own/B_cross.jl`, B2). Not a misreading.

*(b) `intro-hide-suffix-register` — **GENUINE SOURCE DEFECT; the repair is what the
source's own footnote requires. ACCEPTED.***
gt-08:L646–L649 states that `x_{w,>k+1}` and `x_{w̄,>k+1}` are the projections to
`V_{>k+1}(y_w)` and `V_{>k+1}(y_{w̄})` *respectively*. But `V_{k+1}(y)` is selected by
the prefix `L_{≤k}(y)` (L565–L575), and the honest `(Hide_k,role)` player measures only
`y_1..y_{k−1}` (L1155–L1163), so `y_{w,k}=0` while `y_{w̄,k}` is the measured value.
When the stage-(k+1) register is prefix-dependent the two register subspaces differ and
the check compares vectors supported on disjoint coordinate sets. The source's own
footnote (L652–L657) makes exactly this argument for the *other* two projections
("the latter factor space depends on `y_{w̄}` and not `y_w` … because it is the `w̄`
player who receives the `(Hide_{k+1},role)` question … whereas the `w` player is only
supposed to measure `k−1` registers"), so the executable's choice — both suffixes on
`V_{>k+1}(y_{w̄})` — is the footnote's rule applied consistently, and it is what the
honest EPR correlations satisfy (the Hide_k player X-measures all of `V_{>k}`, the
Hide_{k+1} player X-measures the sub-register `V_{>k+1}(y_{w̄})`). Quantitatively, with
my own register rule (V₁=⟨e₁⟩; prefix 0 → V₂=⟨e₂,e₃⟩; prefix e₁ → V₂=⟨e₄,e₅⟩) I get
**30 of 64 honest Hide₁/Hide₂ leaves rejected under the literal registers and 0 under the
operative register** — exactly the printed counts. (Structurally: Alice's stage-1 map is
the identity, so `y_{w̄,1}=1` on half the leaves; those 32 leaves compare
`x_w|⟨e₄,e₅,e₆⟩` with `x_{w̄}|⟨e₂,e₃,e₆⟩`, of which 2 agree by chance → 30.) Not a misreading.

**(6) The step meter and the ten cost slots.** The charge table is a definition; I
re-derived every published number *by hand from the code's own charges* and got exact
agreement: `_validated_answer` charges `1+ndigits(n;base=2)` (=4 at N=4), `+2` for
(player, stage), `+s` (Marginal/Factor) or `+2s` (Linear), `+|answer|`; `_metered_stage`
charges `k + k² + k + 1`; `_metered_marginal` adds `k` per stage; `_metered_walk` charges
`k` per skipped stage, the full Gaussian elimination when `reachable`, `+1` per branch and
`+s` for the support scan; `_metered_factor` adds `s`. Hence on the M child:
Dimension 4+1 = **5**; Marginal(3) at z\* = 6+6+(5+11+19)+6 = **53**; Factor(2,e₁) =
6+6+21+6 = **39**; Linear(2,e₁,e₄) = 6+12+16+6 = **40**; Factor at stage 3 = **60**;
Linear at stage 3 = **50**. E: 5 / 13 / 10 / 13. So the printed slots
(E 5/13/10/13/10, M 5/53/60/50/22) are correct; 8 of the 10 I verified by hand, the two
decider slots are the package's measurement. Budget semantics: `_charge!` refuses the
whole block **before** it executes and leaves `ctx.steps` unchanged, so the (budget+1)-th
step never runs and a return at step budget is permitted; the sizing `Dimension` probe
runs on the same meter (7 dimension records for 6 vector calls in the recorded log);
`by_depth` is charged at `max(depth,1)` and is nonempty on every record. I verified by
hand that the honest Introspect/Sample `Marginal` lands on 4+2+6+1+1+1+1 = 16 exactly
before the next charge would exceed R, which is why the timeout records read
`steps = 16 = supplied_fuel = source_R`.

**(7) Stabilizer simulation.** `lem:commute` holds for the Read/Hide families by
construction: `coarse_measure!` measures Z on a basis of `ker(M)^⊥` and X on a basis of
`ker(L^⊥)^⊥ = ker(M)`, and every generator of `ker(M)^⊥` is orthogonal to every generator
of `ker(M)` — this is exactly gt-08:L923–L953. The symplectic precheck refuses an
anticommuting family before sampling. My own enumeration over **all 116 oriented E pairs**
(64 seeds on Pauli-incident pairs, 1 on the rest) reproduces **14,378 leaves**, every leaf
mass exactly `2^{-depth}`, `P_intro_operative = 1`, `P_intro_literal = 53/58 = 106/116`,
`max answer bits = 6 = 3Q`, and the 10 literally-rejected pairs are exactly the
Hide-incident set. **But see O3: "total mass one" is a structural identity of
`enumerate_branches`, not evidence about the tableau.**

**(8) Rejection counts.** 10/116 and 22/128 = the Hide-incident oriented pairs
(§1(1)); `P_intro_literal` 106/116 and 106/128 = 53/58 and 53/64; operative 1 in both.
The identity "literally-rejected = Hide-incident" additionally needs the child answer
length ≤ 1 at E, which the suite pins via `max_bits == 3Q == 6`. 30/64 and 48/64
reproduced independently (§1(5)).

**(9) `T6-view-swap`.** The typed decider rejects `(y_B*,y_A*,0,0)` on the valid
`(IntrospectAlice,IntrospectBob)` encoding with `fired == [:game]`, and the detyped
decider preserves the rejection; `M-detype-view-orientation` is KILLED in my registry run.

**(10) Sampler independence.** With two byte-distinct diagnostic deciders I get identical
`S^intro` bytes (`quote_hash = f2820686472a3e44` both) and
`dependency_set = {b3c0aac09c1a7d26}` in both cases; `|S^intro| = 24 B`,
`|D^intro| = 1996 B`.

**(11) Certificate census.** My own walk of `introspect(V_M,2,3)`'s tree gives
`(nodes, CONSTRUCTED, CHECKED, CITED, ASSUMED, SOURCE_REPAIR) = (82, 7, 25, 18, 23, 9)`;
0 CHECKED nodes without a replay; 0 failing CHECKED replays outside the `HypothesisAudit`;
`verify_certificate` returns `hypothesis_violated @ lambda_bounded_description` for both
the raw `introspect` result and the `ExecutableIntrospect` stage, so **no theorem
conclusion is invoked**. Every CITED leaf's `\label{}` lies inside its declared line range
(asserted by the suite; spot-checked `lem:commute` 923:953, `def:Lperp` 386:392,
`fig:decider_pauli` 1126:1227).

**(12) `_require_image`.** 142 → 74,671 steps / 148 child calls; 179 → 113,946 / 185;
step ratio 1.526 vs dimension ratio 1.261, i.e. ≈ dim^1.82 over this range — super-linear,
as reported. See O7 for the adjudication of the decision not to switch.

---

## 2. Objections

### O1 — MAJOR. The nine-item introspection predicate is an AND with no negative witness for its non-Pauli conjuncts; two dropped conjuncts survive the whole suite

**Location.** `src/introspect/intro_decider.jl`, `_intro_ordered` items 2(a)–3(d), and the
`IntroDecider` `replay` closure (L467–L478), whose only negative cases are an
out-of-range type, a `3Q+1`-bit answer, and unequal answers at equal types;
`test/tb6b_introspect.jl` (f)/(g), which assert only that honest leaves **accept**.

**Computation.** All 14,378 E leaves and all 8·64+4096·2+48 M leaves are *accepting*
transcripts. A conjunct that is simply deleted can therefore only be caught by a
negative transcript, and none exists for items 2(a), 2(b), 3(a), 3(b), 3(c), 3(d). I built
two mutants on copies:

```
CRIT-1  drop "&& aw_p.a == av_p.a" from enu:sampling-intro (2b) AND enu:hiding-intro (3a)
        TB6B_TARGET=all  exit=0        FULL SUITE 12105/12105 exit=0 (2m06.8s)  => SURVIVED
CRIT-4  drop "&& aw_p.y_perp == av_p.y_perp" from enu:hiding-read (3b)
        TB6B_TARGET=all  exit=0        FULL SUITE exit=0, 0 failures            => SURVIVED
```
(Controls: `CRIT-2`, the tableau `_rowsum!` with the `_g` phase accumulation dropped, is
KILLED; `CRIT-3`, the equal-type consistency replaced by `true`, is KILLED by the
`IntroDecider` replay. So the corpus *is* red-capable elsewhere; the gap is specific.)

`a_w = a_{w̄}` (gt-08:L451–L455 and L462–L463) is the clause that ties the Sample/Read
players' introspected answers to the Introspect player's; `y^⊥_w = y^⊥_{w̄}`
(`enu:hiding-read`) is the clause that ties the Read player's dual outcomes to Hide_ℓ's.
Both are load-bearing in `thm:introspection`'s soundness argument and neither is tested.
This is the TB5 O1 defect class recurring one rung up.

**FIX DEMAND.** Add named negative transcripts, one per conjunct of items 2(a), 2(b),
3(a), 3(b), 3(c), 3(d): take an honest leaf of the corresponding oriented pair, corrupt
exactly the field the conjunct compares (`a_{w̄}`, `y_{w̄}`, `y^⊥_{w̄}`, `x_{w̄}`,
`y^⊥_{w̄,k+1}`, `â_w^{V_{>1}}`), and assert rejection with the fired-test name; register
the six conjunct-drop mutants (`M6-answer-consistency`, `M6-read-perp`, …) and show them
KILLED. On TB6b-M the child answer is the single bit `false`, so each witness is one line.

**SURVIVING WEAKER STATEMENT.** The introspection decider *accepts* every honest leaf of
every oriented pair of E (14,378 leaves) and of the eight directed M transcripts, and
*rejects* an out-of-range type, an over-long answer, unequal answers at equal types, the
`T6-view-swap` game transcript, and a child that exceeds its fuel; no evidence excludes a
decider that omits the answer-consistency clause of `enu:sampling-intro`/`enu:hiding-intro`
or the `y^⊥` clause of `enu:hiding-read`.

---

### O2 — MAJOR. The mandatory mutation registry does not complete: an uncalibrated TB6a wall gate breaks the suite baseline under the runner's own parallel load

**Location.** `test/tb6a_audit.jl:215`, `@test tb6a_audit_elapsed < 5`;
`test/mutations/run.jl` `:suite` rung (`tb0_gate` → `runtests.jl`).

**Computation (mine).** `MUTATION_JOBS=4 julia --project=. test/mutations/run.jl` on the
archived tree: **exit 1**, no `MUTATION REGISTRY` summary line, 181 mutants KILLED and

```
BASELINE runtests.jl TB0_TARGET=all => BROKEN (exit=1, 305.9 s)
  TB6a in-suite audit wall < 5 s (measured 5.429 s ...): Test Failed at test/tb6a_audit.jl:215
  suite calibration kernel seconds = 1.2769      (quiet value 0.4798)
MUTANT TB0 M-gate-body-inflated ... => UNATTRIBUTABLE (target exits 1 unmutated)
```

The quiet in-suite measurement is 2.765 s, so the gate has only a 1.8× headroom while the
runner deliberately loads the box 4-way; the calibration kernel shows the box running
2.7× slower at that moment. This is exactly the failure mode that `verdicts/tb5-r1.md` §4
adjudicated for TB0 and fixed with a calibrated ratio; TB6a introduces a **new absolute
wall gate outside that discipline**. Collateral damage: brief 77's approved-with-conditions
red witness for the TB0 ratio gate (condition (iv)) cannot be attributed, so the corpus's
newest red test is unverified in the very run that is supposed to verify it. (Its target
did fail as designed — `TB0 test-body wall 76.675 s`, `wall<60.0 => false` — so the witness
itself is sound; the runner cannot say so.)

**FIX DEMAND.** Replace `@test tb6a_audit_elapsed < 5` by a calibrated gate using the same
`suite_calibration_kernel()` as TB0/TB4 (e.g. `tb6a_audit_elapsed / kernel < K` with K set
from the quiet ratio ≈ 5.8 plus headroom), keep an absolute ceiling only at a value the
runner's own load cannot reach, and re-run the registry to a clean
`MUTATION REGISTRY: killed=182/182 baselines ok=…, exit 0`; report the `uptime` at both ends.
Same discipline for the TB5 walls (`construction<2`, `transcripts<5`) and the TB6b walls
(3/15/25/43), which are absolute and are exercised inside the same `:suite` baseline.

**SURVIVING WEAKER STATEMENT.** On a quiet box the whole suite is green (12105/12105) and
181 of 182 registered mutants are KILLED with every TB6 and every brief-77 mutant among
them; the registry as a whole is not reproducible under its own default parallelism, and
`TB0 M-gate-body-inflated` is unattributed on this box.

---

### O3 — MINOR. "Total mass one" is a structural identity of `enumerate_branches` and carries no information about the tableau

**Location.** `src/introspect/stabilizer.jl` `enumerate_branches`;
`test/tb6b_introspect.jl` (d):344, (f):469, (g):578; DESIGN §11.6 ("require total mass one");
the C14 merge proposal ("exact stabilizer enumeration has total mass one").

**Computation.** `enumerate_branches(f)` explores the complete binary tree of fair-bit
tapes and assigns each leaf `2^{-(bits drawn)}`; for any deterministic `f` the leaf
probabilities sum to 1 by induction on the tree. I ran it on three arbitrary tape
functions unrelated to the simulator:

```
mass = 1//1 (4 leaves) ; mass = 1//1 (3 leaves) ; mass = 1//1 (1 leaf)
```

No mutation of `measure!`, `_rowsum!`, `coarse_measure!` or `_solve_gf2` can make the sum
differ from 1. The substantive checks are `P_intro_operative == 1` over 14,378 leaves
and the `M6-noncommuting` precheck — both of which are real (CRIT-2 confirms the tableau
arithmetic is exercised).

**FIX DEMAND.** Either delete the mass assertion from C14's evidence and from DESIGN
§11.6's "required output" cell, or replace it by a check that can fail — e.g. assert the
*per-pair outcome distribution* against an independently computed one (E has only
2(Q+1)=6 qubits, so a 64-amplitude reference state vector is affordable in a test-only
reference implementation), or assert the leaf count and the exact multiset of
probabilities per oriented pair.

**SURVIVING WEAKER STATEMENT.** The enumeration is exhaustive and every leaf carries an
exact dyadic probability; the operative decider accepts every leaf of every oriented pair,
and an anticommuting family is refused before sampling.

---

### O4 — MINOR. The measured quantities C14 cites as evidence are printed, not pinned

**Location.** `test/tb6b_introspect.jl` (i) — the ten cost slots are only asserted
`haskey(...)` and `≤ F_child`, never equal to 5/13/10/13/10 and 5/53/60/50/22; the charge
table (5/53/39/40) is only `println`ed; (g) asserts `literal_suffix_rejections > 0` and
`literal_perp_rejections > 0`, never `== 30` and `== 48`; `_require_image`'s 74,671 /
113,946 are printed.

**Computation.** All of these are deterministic (I reproduced eight of the ten slots and
the whole charge table by hand, and 30/48 with my own code, §1(5)–(6)). A regression that
silently changed any of them — e.g. a meter charge dropped, or a register rule changed so
that only 2 leaves differ — would leave the suite green while invalidating the sentences
C14 is asking to have promoted.

**FIX DEMAND.** Assert the ten slots, the four charge-table values and the two literal
counts exactly, and register one mutant per group (e.g. drop the `_charge!(ctx, 1)` branch
charge in `_metered_stage`; make `hide_suffix_literal` use `y_{w̄}` for both registers)
shown KILLED.

**SURVIVING WEAKER STATEMENT.** The slots exist for all five modes and every honest record
fits `F_child`; their exact values are reported by the proposer and independently
reproduced by this critic at `0ec462e`, but are not defended by the corpus.

---

### O5 — MINOR. The brief-43 report's ℓ=9 Hide-incident count is wrong

**Location.** `briefs/43-tb6-introspect.last.md`, "Hide-incident oriented 10/22/**46**".

**Computation.** Hide-incident oriented pairs = 2·(4 + 2(ℓ−1)) + 2ℓ = 6ℓ+4, i.e.
10, 22, **58** at ℓ=1,3,9 — the formula the test itself asserts
(`tb6a_audit.jl:81`) and the value my own construction returns. 46 is on no line through
(1,10) and (3,22).

**FIX DEMAND.** Correct the report (and any downstream summary) to 10/22/58. No code change.

---

### O6 — MINOR (lockstep). Four documentation obligations from §11.6 and from `verdicts/tb5-r1.md` §4 have not landed

(a) DESIGN §11.6's ten-slot table still prints `NE` in every cost cell although the same
section orders "At implementation, replace each cost slot with exact per-call counts and
the finite maximum"; DESIGN now contradicts the measured artifact.
(b) DESIGN §11.6 and §13.1 still state the TB6a target `<1 s` while the enforced gate is
`<5 s` and the quiet measurement is 2.765 s (this is also O2's gate).
(c) DESIGN §13.1 does **not** contain brief 77's calibration-kernel sentence, which was
condition (ii) of the gate approval in `verdicts/tb5-r1.md` §4; the gate is live in code
and undocumented.
(d) `docs/definitions.md` §H has no rows for `SOURCE_REPAIR(intro-perp-orthogonal)` and
`SOURCE_REPAIR(intro-hide-suffix-register)` (it has one for `intro-3Q-guard`), and the
`k_rep(n)` row still lacks the integrality clause `verdicts/tb5-r1.md` §4 required
("The one addition I require is a clause on the `k_rep(n)` row").
(Positively verified as landed: §9.4's O7c/O7d sentences, §10.2's `k(n)(B(n)+32)`
replacement and the L219/L220 source finding, §9.2's non-additivity sentence.)

**FIX DEMAND.** Orchestrator merges (a)–(d) verbatim; the two SOURCE_REPAIR rows must
carry the gt anchors `gt-08:L669–L678` + `gt-03:L307–L318`, `L333–L340`, `L386–L392` and
`gt-08:L464–L473` + `L641–L657` respectively.

---

### O7 — NOTE. `_require_image` was measured super-linear and not switched; the TB7 extrapolation is asserted, not shown

The brief-43 addendum said "if it is super-linear, replace the column-space rebuild by the
stored stage matrices (report the choice)". The proposer measured
1.526× steps for 1.261× dimension (≈ dim^1.82 locally) and did **not** switch, on the
ground that the rebuild is the only query-purity-preserving reachability test at the parent
and that the alternative is the `(:Pad, extra, S)` grammar node requested for TB7. I accept
the choice as reported — but the claim "binding at TB7's 1696" is not demonstrated: the
measured wall at 179 is 2·10⁻⁴ s, and even a cubic extrapolation to 1696 (×850) gives
≈0.17 s per construction. **FIX DEMAND:** either measure `_require_image` at a dimension
near 1696 in TB6a (it is a pure sampler-side cost, no fixture needed) or downgrade the
"binding" wording to "to be measured at TB7".

### O8 — NOTE. The recorded query log contains one child `Dimension` sizing probe per vector query

Seven `dimension` records for six vector calls on the Hide₁/Hide₂ leaf. DESIGN §11.4 says
"It first asks only `Dimension(N)`", which is true of the *first* call but reads as a
bound on the whole schedule; `intro_query_plan`'s docstring already excludes the probe,
and the proposed §11.4 sentence names it. Land that sentence (see §4) so the schedule and
the log cannot be read as disagreeing.

### O9 — NOTE. `FuelExhausted` reports a step number that can exceed `budget+1`

`_charge!` throws `FuelExhausted(ctx.steps + k, budget)` for a whole block, so the reported
`steps` can be `budget + k` for `k > 1`. The meter's own `ctx.steps` is left correct (I
verified the timeout records read exactly 16), and the semantics "the (budget+1)-th step
never executes" is preserved because the block is refused before any of it runs — but the
exception's printed number is not a step index. Cosmetic; name it `attempted` or clamp it.

### O10 — NOTE. E is degenerate as a hiding fixture, by construction

At ℓ=1, `enu:hiding-same` is VACUOUS (printed) and `s(N)=1`, so `V_{>1}=∅` and the
Hide₁/Read and PauliX/Hide₁ checks carry no register content; every live adaptive check
rests on TB6b-M alone, i.e. on **one** child sampler with **one** nonsymmetric stage map.
Both source repairs are exhibited on that single fixture. Not an error — but C14 should
say that the live evidence for the hiding chain is single-fixture.

---

## 3. The critic's own mutations (all on copies, never in the repo)

| id | mutation | target | result |
|---|---|---|---|
| CRIT-1 | `enu:sampling-intro` and `enu:hiding-intro` drop `a_w == a_{w̄}` | `tb6b` all; full suite | **SURVIVED** (12105/12105, exit 0) |
| CRIT-2 | `_rowsum!` drops the `_g(...)` phase accumulation (tableau update loses a phase) | `tb6b` all | KILLED (exit 1) |
| CRIT-3 | equal-type consistency `a == b` → `true` | `tb6b` all | KILLED (exit 1, `IntroDecider` replay) |
| CRIT-4 | `enu:hiding-read` drops `y^⊥_w == y^⊥_{w̄}` | `tb6b` all; full suite | **SURVIVED** (exit 0) |

CRIT-1 and CRIT-4 are the FIX DEMAND of O1.

---

## 4. DESIGN / definitions adjudication

| proposal (briefs/43-tb6-introspect.last.md) | decision |
|---|---|
| §11.4 fuel-unit sentence ("one primitive step of the universal interpreter machine … counted by `Meter.steps` … the budget refuses the (budget+1)-th step … the sizing `Dimension` probe runs on the same meter; `by_depth` attributes steps per machine depth") | **APPROVED, with one correction required before landing.** The charge list must match the code: it is `1 + ⌈lg n⌉+1` bits for the decoded index (`1+ndigits(n;base=2)`, i.e. 4 at N=4, not "1 + 2 index bits"), a fixed **2** for the (player, stage) fields, **s** for a Marginal/Factor input vector and **2s** for Linear's two vectors, `k + k² + k + 1` per evaluated stage, one per canonical-elimination row operation, and one per serialized output element. With that correction the sentence is exactly what `machines.jl`/`meter.jl` charge — I reproduced Dimension 5, Marginal(3) 53, Factor(2,e₁) 39, Linear(2,e₁,e₄) 40, Factor(3) 60, Linear(3) 50 by hand from it. |
| §9.5 oriented-edge sentence ("the stored type graph is the oriented pair set … G^pauli: 26 loops + 30 non-loops = 86 … G^intro: 2ℓ+39 non-loops, 6ℓ+110 oriented pairs … `detype_decider` iterates the oriented list") | **APPROVED verbatim.** Independently confirmed (§1(1)); §9.5 currently has no edge-convention sentence at all. |
| §9.6 primitive tags / `TypedDecider` sentence | **APPROVED with a merge note.** §9.6 already names `pauli_sampler`, `tilde_S_intro`, `graph_sampler` in the mandatory-output-row paragraph, so land only the new clause: "`TypedDecider(TypeSet, body)` is the general typed decider term whose bytes carry the labels, with `pauli_decider` and `typed_intro_decider` as instances and `:TypedAnchor` as the compact spelling of the anchor instance." Do not duplicate the tag list. |
| DESIGN §11.6 cost table, §11.6/§13.1 TB6a target, §13.1 calibration sentence | **REQUIRED, not yet landed** — O6(a)(b)(c). |
| `docs/definitions.md` §H | **Two new rows REQUIRED** (`SOURCE_REPAIR(intro-perp-orthogonal)`, `SOURCE_REPAIR(intro-hide-suffix-register)`) plus the `k_rep(n)` integrality clause from brief 77 — O6(d). Everything else in §G–H matches the built code (`TypePauli/G^pauli` 26 loops + 30 non-loops / 86 oriented; `introparams`; `Q_EPR`; `IntroAnswerEncoding`; `typed_intro_decider`; `TIME_child/F_child/toy_child_fuel`; `StabilizerTranscriptSimulator`). |

---

## 5. Claim decisions

### C14 — **PROMOTE `CONJECTURE → TESTED`**, with the row below, which is the proposer's merge proposal minus two unsupported phrases plus three scoping sentences

Rationale: every construction number, every policy line, the whole query schedule, all ten
cost slots, both rejection-count families, the census, the dependency set and both source
repairs were reproduced independently at `0ec462e` (§1); 15/15 TB6 mutants KILLED; both
`HypothesisAudit`s refuse. The two MAJORs are (O1) a red-coverage gap inside the predicate
and (O2) a test-infrastructure gate, neither of which touches the constructions the row
asserts — but both must be named in the row (rk-light law 5, the `tb5-r1` C13 pattern).

Apply **verbatim**:

> (TB6 Introspect, explicit toy child fuel) `introspect(V, lambda, ell; tuple, F_child)` is
> executable end to end on `TB6b-E` (n=2, N=4, λ=1, ℓ=1, (2,1,1), dimension 6→142) and
> `TB6b-M` (λ=2, ℓ=3, s=6, (8,2,1), 27→179): `TypePauli`/`G^pauli` (26 types, 30 non-loops,
> 86 oriented pairs) and `TypeIntro`/`G^intro` (32+2ℓ types, 2ℓ+39 non-loops, 6ℓ+110 oriented
> pairs at ℓ=1,3,9) are CHECKED against hand transcriptions of `fig:type-graph-ms`,
> `fig:type-graph-pauli` and `fig:type-graph-intro`; the Pauli family, `tilde S^intro` and
> `graph_sampler` carry the §9.6 output-sampler replay rows with the promoted zero maps
> (`SOURCE_REPAIR(zero-map-factor-partition)`); `D^pauli` executes all eight guards of
> `fig:decider_pauli` in both player orders on hand-built accept/reject transcripts and its
> applicability census is `26/4/2/2/2/54/18`; the typed introspection decider reads `V` only
> through the four queries and one decider call — the recorded query log equals the §11.4
> schedule and every call is at `N=2^n` (`M6-N` red) — each under the step meter with budget
> `N^lambda` in production (every honest Introspect/Sample transcript times out at exactly
> `R=16` and the decider rejects; acceptance under the source gate is withdrawn) or the
> supplied `F_child=65,536` in toy mode, with `toy_child_fuel=FAIL(owner=tb6-child-meter)`;
> the ten honest cost slots are measured in the DESIGN §11.4 unit (E 5/13/10/13/10,
> M 5/53/60/50/22 steps) and every record fits `F_child`; the exact stabilizer simulation of
> the honest strategy is enumerated over every oriented pair of E (14,378 leaves, each with
> an exact dyadic probability) and over eight directed M transcripts plus 512 seeded draws,
> typed and detyped, and the operative toy decider accepts every one of them; the
> paper-literal `>=3Q` guard rejects exactly 10 of 116 and 22 of 128 oriented pairs (the
> Hide-incident sets) while the operative `>3Q` guard admits the honest `3Q`-bit Hide answer;
> `T6-view-swap` is rejected typed and after detyping; the sampler description is intensionally
> independent of the input decider (dependency set `{hash(S)}`, identical bytes for
> byte-distinct deciders); two further source defects are disclosed and repaired
> (`intro-perp-orthogonal`, `intro-hide-suffix-register`); the `thm:introspection` ASSUME clause
> `|V| <= lambda` FAILS on both toy quotes, so the `HypothesisAudit` refuses and no theorem
> conclusion is invoked; `thm:pauli`, `thm:introspection`, `lem:intro-sampler-complexity`,
> `lem:intro-decider-complexity` and `lem:commute` stay CITED. Fifteen owned mutants are KILLED.
> **Scope.** The nine-item predicate is an AND whose non-Pauli conjuncts have no negative
> witness: dropping `a_w = a_wbar` from `enu:sampling-intro` and `enu:hiding-intro`, or
> `y_perp_w = y_perp_wbar` from `enu:hiding-read`, passes the entire suite
> (`verdicts/tb6-r1.md` O1, mutants CRIT-1 and CRIT-4); the corpus's negative introspection
> witnesses are an out-of-range type, an over-long answer, unequal answers at equal types,
> `T6-view-swap`, and a child that exceeds its fuel. The "total mass one" of the leaf
> enumeration is a structural identity of the branch enumerator and is not evidence about the
> tableau; the substantive stabilizer evidence is operative acceptance of all 14,378 E leaves
> and the anticommuting-family refusal (`verdicts/tb6-r1.md` O3). The ten cost slots, the
> charge table, and the literal-register (30 of 64) and literal-dual-map (48 of 64) rejection
> counts are printed and independently reproduced by the critic but are not pinned by
> assertions (`verdicts/tb6-r1.md` O4); all live adaptive hiding evidence rests on the single
> `TB6b-M` child sampler, since `enu:hiding-same` is VACUOUS and `s(N)=1` at `TB6b-E`
> (`verdicts/tb6-r1.md` O10). Acceptance is asserted only for the operative toy decider under
> the supplied `F_child`; no production-fuel acceptance and no claim about `thm:introspection`'s
> conclusion follows.

`status TESTED`; `depends-on C12, C4a`; `where-tested test/tb6a_audit.jl`,
`test/tb6b_introspect.jl`; `red test/mutations/tb6_introspect.jl`;
`verdict verdicts/tb6-r1.md (PROMOTE, scoped)`.

Two phrases of the proposer's merge proposal are **struck** and must not appear:
"exact stabilizer enumeration has total mass one" as evidence (O3), and any wording that
presents the ten cost slots or the 30/64, 48/64 counts as asserted rather than reported (O4).

### C15 — no change (stays CONJECTURE; TB7 has not run).

---

## 6. TB5 r2 — adjudication of brief 77 (so the TB5 lane closes here)

| item | decision |
|---|---|
| **O1** `T5-last-corrupt` + `M5-and-drops-last` | **ACCEPTED.** The all-Game transcript `repeat(z1,81)` with `as[81]` flipped rejects, with 81 logged calls and exactly one rejecting at index 81; `MUTANT TB5 M5-and-drops-last kth_verdict_discarded => KILLED` in my registry run. |
| **O2** pinned `Factor`/`Linear` + prefix-dependent child | **ACCEPTED.** I read `_metered_node`: `at_most ? (0 ≤ … ≤ expected) : (c.marginal == expected && c.factor == expected && c.linear == expected)` — pinned exactly as demanded; the prefix-dependent-factor child fixture is in (f); `MUTANT TB5 M5-repeat-factor-block1 block_one_factor_replicated => KILLED`. |
| **O3** integrality of the **value** | **ACCEPTED.** `k_rep(1,1,1//2,9) == 27` and `k_rep(1,1,2//3,8) == 32` are asserted, `Dimension = 243`, `KRepIntegrality` PASS with the display `k(9) = (1*9)^((1 + 1//2)*1) = 27`, `verify_certificate` true; my own arithmetic gives `9^{3/2}=27` and `8^{5/3}=32`. `M5-exponent-integrality => KILLED`. |
| **O4** `SOURCE_REPAIR :RepeatGuardExponent` | **ACCEPTED.** Node present with `lines=219:220`; DESIGN §10.2 carries the source finding; `M5-drop-guard-exponent => KILLED`. |
| **O5** walls as hard gates, real peak | **ACCEPTED.** `construction<2`, `transcripts<5`, `total<7` are `@test`s, the allocation figure is relabelled and a real RSS/GC peak is asserted `<256 MiB`; `M5-wall-construction`, `M5-wall-transcripts => KILLED`. *Caveat:* these are absolute walls and share O2's fragility. |
| **O6** exact census | **ACCEPTED.** `census == (56, 9, 27, 10, 4, 6)` (55 + the O4 node) asserted, plus CHECKED ⇒ replay; `M5-drop-framing-disclosure => KILLED`. |
| **O7** lockstep §9.2/§9.3/§9.4/§10.2 | **ACCEPTED** for (a)–(d): I verified in the archived DESIGN that §10.2 now emits `k(n)*(B(n)+32)` with `SOURCE_REPAIR(RepeatTupleFraming)` and the L219/L220 finding, and that §9.4 carries both critic-added sentences (public vs internal `DL9-anchor`/`DL9-repeat`; `O(...)` dropped in the emitted ASTs). `M5-law-framing-dropped => KILLED`. |
| **O8** edge-view / `(Game,Game)` counts | **ACCEPTED with the proposer's correction.** 185/42 of 10368 on the suite's own `rand(rng,(0,1))` stream; my r1 figures 159/40 are the `rand(rng,Bool,729)` stream of the same seed, which the proposer reproduced. Expectation 10368/64 = 162 either way. `M5-view-vertex-only => KILLED`. |
| **gate red test** (condition (iv)) | **ACCEPTED as built, NOT VERIFIED by the registry.** `test/mutations/tb5_gate.jl` exists, its `:suite` rung is wired, and on my run its target failed exactly as designed (`TB0 test-body wall 76.675 s`, `wall<60.0 => false`); but the runner reported it `UNATTRIBUTABLE` because the unmutated baseline broke on the TB6a gate (O2). Re-verify after O2. |
| **DESIGN §13.1 calibration sentence** | **NOT LANDED** — required by `verdicts/tb5-r1.md` §4 condition (ii). O6(c). |
| **definitions §H `k_rep` clause** | **NOT LANDED** — required by `verdicts/tb5-r1.md` §4. O6(d). |

**C12 — the O2 scope sentence is DISCHARGED. Strike, verbatim:**
> "The per-block `Factor`/`Linear` clause of `DL9-repeat` is checked only on fixtures whose
> child factor spaces and prefix domains are prefix-independent, and the metered
> `Factor`/`Linear` counts are bounded above rather than pinned, so a wrapper answering every
> block from block 1's child factor is not excluded by the current tests (verdicts/tb5-r1.md O2)."

**and insert in its place, verbatim:**
> "The per-block `Factor`/`Linear` clause of `DL9-repeat` is red-covered on a
> prefix-dependent-factor child (block-2 factor and prefix domain differ from block 1's;
> `M5-repeat-factor-block1` KILLED) and the metered `Marginal`/`Factor`/`Linear` counts are
> pinned exactly (verdicts/tb6-r1.md §6)."

Keep C12's O9 (`DescribeCL` LawCert) sentence: not addressed, still true.
`status TESTED` unchanged; add `test/mutations/tb5_repeat.jl` (nine new mutants) and
`test/mutations/tb5_gate.jl` to `where-tested`.

**C13 — the O1 scope sentence is DISCHARGED; the O3/O4 and O8 sentences are superseded.**
Strike, verbatim:
> "The repeated AND is red-covered only at non-final component indices: a decider that
> discards the k-th component's verdict passes the whole suite (verdicts/tb5-r1.md O1)."

insert, verbatim:
> "The repeated AND is red-covered at the final index: `T5-last-corrupt` flips component 81
> of the all-Game transcript and `M5-and-drops-last` is KILLED (verdicts/tb6-r1.md §6)."

replace "159 present a valid oriented-edge graph view and 40 are `(Game,Game)` pairs" by
> "185 present a valid oriented-edge graph view and 42 are `(Game,Game)` pairs (on the suite's
> own seeds; the r1 critic's 159/40 are the `rand(rng, Bool, 729)` draws of the same seed)"

and replace "and the stored `k(n)` term is refused whenever `(1 + c')tau` is non-integral even
where `k(n)` is a positive integer (verdicts/tb5-r1.md O3, O4)" by
> "and the stored `k(n)` term is refused exactly when its value is not a positive integer
> (k(9) = 27 at c' = 1/2 admitted; the gt-11:L219/L220 guard-exponent tension is disclosed as
> `SOURCE_REPAIR :RepeatGuardExponent`) (verdicts/tb6-r1.md §6)."

Add to the evidence: "warm construction < 2 s, transcripts < 5 s, total < 7 s as hard gates;
exact census (56, 9, 27, 10, 4, 6)". `status TESTED` unchanged.
**No further TB5 round is required**; O2 above (the wall gates' calibration) is carried as
part of the TB6 repair, not as a TB5 lane.

---

## 7. TB7 readiness (brief 44)

1. **Not yet.** TB6 delivers a real `Introspect` `CompressStage` (`ExecutableIntrospect`,
   `origin=:Introspect`, levels 5, `sampler_dependencies=(:lambda,:ell)`) and TB5 a real
   `Repeat`; brief 44 can start only after the four API REQUESTS below are decided.
2. **Blocking (1) — the fuel unit.** §11.4's step unit is not lowered into §1.1 `Eval`
   `FuelBound`, so TB7's `D_{M,lambda}` budget and the child budget are two different
   currencies. Decide the lowering (or an explicit two-meter contract) before brief 44.
3. **Blocking (2) — nested typed deciders.** `_metered_decide_typed` refuses a
   `TypedDecider` child, so `Compress = Repeat ∘ AnswerReduce ∘ Introspect` cannot meter a
   composed introspection decider as a child. One grammar/dispatch change.
4. **Blocking (3) — `(:Pad, extra, S)`.** `_require_image` is measured super-linear
   (O7); at 206→1696 the term-level `Pad` node of `verdicts/tb5-r1.md` O12 is the clean
   fix and also deletes `_require_image`. Cheap now, expensive later.
5. **Blocking (4) — `REPEAT_CONTRACT`'s `completeness_decider_time` index and
   `_normal_form_status` display** (`verdicts/tb5-r1.md` O11) live in `src/compress.jl`,
   outside both r1 lanes; TB7 owns them.
6. **Also required before TB7 green:** O2's calibrated wall gates (TB7's own `<60 s`
   target will be exercised inside the same `:suite` baseline) and O1's negative
   introspection transcripts (TB7 executes only the Pauli-typed introspection predicates,
   so the untested conjuncts would silently stay untested one rung up).
7. **Ready as-is:** the four-query API, `downsize`/`direct_sum`/`product`/`detype`/`anchor`/
   `repeat`/`introspect` with the mandatory replay rows, the step meter with `by_depth`,
   the `TypedDecider` tag, the oriented-edge convention, the stabilizer simulator, and the
   `HypothesisAudit` refusal machinery.
8. **Known TB7 shape issues already documented and unchanged:** the fixed-width `sigma_1`
   slots (`SOURCE_REPAIR(intro-decider-fixed-width)`), `P_pcp_encodes_D1 = FAIL` with the
   honest `enu:ar-game` path `NOT_EXECUTED(owner=pcpverifier-D1-trace)` via TB3's front
   end, and the ToyPolicy predicate table (§12.4) — all must print as such, never fold to PASS.
9. Recommendation: run **brief 44 only after a TB6 repair round** clears O1 and O2;
   TB6a/TB6b themselves need no design round.

---

VERDICT: FAIL(O1,O2)
