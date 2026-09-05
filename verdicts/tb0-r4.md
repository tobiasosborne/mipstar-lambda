# CRITIC verdict r4 — rung TB0 (`src/**`, `test/tb0_core.jl`, `test/mutations/run.jl`, `src/precompile.jl`, `tools/cold_precompile.sh`) at commit `44160d1`

Round 4 (adjudicate, closing). Priors: `verdicts/tb0-r1.md` (O1–O16), `verdicts/tb0-r2.md` (N1–N7, X1–X4),
`verdicts/tb0-r3.md` (N8 MAJOR; N9–N12 MINOR; the C1/C2/C3/C8 decisions). Work order: `briefs/55-tb0-critic-r4.md`;
repair order `briefs/49-tb0-repair-r4.md`; response table `briefs/49-tb0-repair-r4.last.md` (5 rows + runs + a C1 merge
proposal). Nothing that passed in r1–r3 is re-litigated; the attack is scoped to `git diff 6f4083a 44160d1` on
`src/verifiers/pcp.jl`, `src/precompile.jl`, `test/tb0_core.jl`, `test/mutations/run.jl`, `tools/cold_precompile.sh`,
`test/runtests.jl` and `docs/DESIGN.md` §5/§5.1.

**Isolation.** `git archive 44160d1 | tar -x` into
`/tmp/.../scratchpad/critic-tb0-r4/tree/`; `Pkg.instantiate()` there (that instantiate's own image build reported
**112,244.3 ms**). Every run, probe and mutation is in that copy or under `.../critic-tb0-r4/{tree-disarm,mut-*}/`. The
live working tree was read for exactly one file, `claims/CLAIMS.md` (orchestrator-owned, as the brief directs); no `src/`
or `test/` file of the live tree was read or run. No repo file other than this verdict was written; no state-changing git
command was run. The archived tree was never edited: the separator-disarm scenario ran in a separate copy
(`tree-disarm/`), and all five of my new mutations ran as `Base.include(MIPStarLambda, <mutated copy>)` against the
unmodified tree, i.e. through the repository's own isolation mechanism.

**Independence.** §0 recomputes the r4 delta from the objects themselves (`.../probe1.jl`, `probe2.jl`, `probe3.jl`): a
16-pair borrowed-certificate matrix, a chimera sweep that isolates which identity anchor refuses, a five-coordinate
separator sweep in both fields, a set-equality check of the encoding sweep against an independently enumerated
`GF(8)^m`, and liveness positive controls for every mutation I report as SURVIVED. The arithmetic constants (18,620 / 2 /
33,432 / 534,912 / occurrence and degree vectors) were re-derived from scratch in `verdicts/tb0-r3.md` §0 and are
unchanged at `44160d1` (`src/tb0.jl`, `src/ir/circuits.jl`, `src/polynomials/**` are byte-identical between `6f4083a`
and `44160d1`); I re-measured them through the repository's own code and they reproduce exactly.

---

## 0. Independent recomputation (brief obligations)

**(1) The disarm scenario of N8 is now RED.** On `tree-disarm/` (the archived tree with `src/tb0.jl:13` changed to
`separator[8] = primitive_element(F)`, i.e. the certified separator moved `O2 -> O3`):

```
UNMUTATED  TB0_TARGET=pcp_separator                exit 1;  "5a. mutation-B formula separator | 5 pass 4 fail 9"
   :417  separator8.mutated_beta0  == separator8.mutated     Evaluated: GF(2^3)(2)  == GF(2^3)(1)
   :418  separator8.mutated_beta0  != separator8.view.beta0  Evaluated: GF(2^3)(2)  != GF(2^3)(2)
   :419  separator11.mutated_beta0 == separator11.mutated    Evaluated: GF(2^11)(96) == GF(2^11)(48)
   :420  separator11.mutated_beta0 != separator11.view.beta0 Evaluated: GF(2^11)(96) != GF(2^11)(96)
MUTATION_FILTER="B omit"  on the same tree
   BASELINE tb0_core.jl TB0_TARGET=pcp_separator => BROKEN (exit=1, 21.75 s)
   MUTANT B omit_g2_minus_o2 target=pcp_separator => UNATTRIBUTABLE (target exits 1 unmutated) (exit=1, 26.45 s)
   isolated targeted mutations: Test Failed at run.jl:316 and :317      runner exit 1
```

r3's exact disarm — the one that left the whole suite green and silently killed mutant B's discriminating power — is now
impossible: the unmutated target goes red at four assertions and B is refused a kill. **N8's fix demand is met literally.**

**(2) The separator coordinate is pinned by the assertion, not by a literal — and `O2` is the unique detecting sign
coordinate.** My sweep (`probe1.jl` §P3) moves `rho` to each of `O1..O5` on witness (ii) and recomputes
`mutated_beta0 = F_arith(z)·prod_{i != 2}(alpha_i - z[o_i])` from the fixture:

| sign coordinate | `beta_0` GF(8) | mutated GF(8) | differ | `beta_0` GF(2^11) | mutated | differ |
|---|---|---|---|---|---|---|
| O1 (6) | 2 | 2 | no | 96 | 96 | no |
| **O2 (7)** | **2** | **1** | **yes** | **96** | **48** | **yes** |
| O3 (8) | 2 | 2 | no | 96 | 96 | no |
| O4 (9) | 2 | 2 | no | 96 | 96 | no |
| O5 (10) | 2 | 2 | no | 96 | 96 | no |

`pcpverifier` accepts the honest view at all five. So `test/tb0_core.jl:417-420` is exactly the discriminator r3
demanded: it is satisfiable only at a point where the `g_2-o_2` factor is detectable, and among the five sign
coordinates only `O2` is such a point. The literals `rho^5(1+rho)=2` and `rho^4(1+rho)=1` (`:412-415`) are now
cross-checked against the fixture-computed value rather than standing alone.

**(3) The borrowed-certificate refusal is real and reaches every bound node.** Full 4×4 matrix over
{witness (i), (ii), (iii), a **second, structurally identical build of (i)**} (`probe1.jl` §P1):

```
the 3 diagonal pairs (i,i), (ii,ii), (i',i')  => passed=true  (certificate_replay, PCPProof)
the diagonal pair  (iii,iii)                   => passed=false rule=coefficient_identity  (its own honest failure)
each of the other 12 pairs                     => passed=false rule=certificate_binding  loc=Tseitin
   including (proof=i, cert=i') and (proof=i', cert=i), whose components have EQUAL monomial dictionaries
   (fi.c0.terms == fi2.c0.terms is true) but are distinct objects (=== false).
```

Because `verify_certificate` stops at the first failure, the suite's own borrowed test only exercises the `:Tseitin`
anchor. My chimera sweep (`probe2.jl`) shows the deeper anchors are individually live:

| attached proof | first refusing node |
|---|---|
| (i).tf + all of (iii) | `:MultilinearExtension` |
| (i).tf, (i).gs + (iii).c0/decomposition | `:BuildC0` |
| (i).tf, (i).gs, (i).c0 + (iii).decomposition | `:ZeroBasis` |
| (i) with **only `g_3`** swapped for (iii)'s `g_3` (same monomials, different object) | `:MultilinearExtension` |

So `_bind_evidence` anchors each node to the component it is evidence for, and the anchor fires per component. This is a
strictly stronger property than DESIGN §3's "recomputes it against the attached term": ten of the eleven nodes replay
their captured sub-term only after `locate(proof) === anchor`, and the captured sub-term then *is* the attached proof's
component. §3 is satisfied; the r3 N10 defect (a proof with `|r| = 2` passing on another proof's certificate) is gone —
I re-ran that exact probe and it now returns `:certificate_binding`.

**(4) The encoding sweep covers all of `GF(8)^m` and 512 seeded `GF(2^11)` points.** Repository function and my own
enumeration (`probe1.jl` §P4):

```
encoding_checks(GF8)                       = (m1_ok, m2_ok, m3_ok, 8, 64, 512)      all true
encoding_checks(GF2048; rng=MT(0x092048))  = (m1_ok, m2_ok, m3_ok, 512, 512, 512)   all true
Set(encoding_points(GF8,m,nothing,·)) == Iterators.product(field_elements(GF8)^m):  m=1,2,3 all TRUE  (8/64/512)
seeded GF(2^11): distinct 453 / 512 / 512 (birthday collisions at m=1 only), off-cube 511 / 512 / 512
```

`encoding_checks` (`test/tb0_core.jl:56-89`) compares `evaluate(extension, p)` with `sum(table .* ind(p))` on
`points[m]` for `m=1,2,3` and both/all tables, in addition to the Boolean values and the `dec` round trip. Testset 2
(`:91-104`) asserts the whole named tuple, so the point counts are pinned, not printed. **N12's item-2 demand is met by
extension, not by striking.**

**(5) The root degree replay is still an upper-bound check.** `d`-sweep on `change_field` (`probe1.jl` §P6):
`d = 1` and `d = 5` are refused with `:pcp_degree`; `d = 6, 11, 1000` all pass. `11` remains the caller's label. C1's
authorized text says so verbatim ("an upper-bound check, not a re-derivation of 11") and is unchanged on this point.

**(6) `ev_z`'s block-locality guard is live and now owned.** `dependency_coordinates(g_1 * z_12) = {1,12}`; `ev_z` throws
`ArgumentError`; `_pcp_view` on the same proof returns a view. `test/tb0_core.jl:511-518` asserts both the dependency set
and `@test_throws ArgumentError ev_z(bad_locality, tb0_base_point(GF8))`, and mutant `NM3` is registered and KILLED.

---

## 1. Adjudication of the r4 response table (`briefs/49-tb0-repair-r4.last.md`)

| id | claimed | adjudication | evidence / exact residual |
|---|---|---|---|
| **N8** (r3 MAJOR) | FIXED | **ACCEPTED** | `mutation_b_separator` computes `mutated_beta0` from the fixture (`:398-402`), testset 5a asserts it equals the literal mutated value and differs from `view.beta0` on both fields (`:417-420`); 5a is 9/9 in the default suite. Mutant **S** (`separator[7] -> separator[8]`, target `pcp_separator`) registered (`run.jl:118-120`) and **KILLED** under `BASELINE pcp_separator => OK`. I re-ran r3's disarm end to end (§0(1)): the unmutated target now exits 1 and mutant B is `UNATTRIBUTABLE`, runner exit 1. §0(2) confirms `O2` is the unique sign coordinate at which the assertion can hold. Nothing residual. |
| **N9** | FIXED | **ACCEPTED** | `:511-518` (dependency set + `@test_throws`); mutant `NM3` registered (`run.jl:122-124`, target `certificate`) and **KILLED** under `BASELINE certificate => OK`. Guard liveness independently confirmed (§0(6)). Residue: nothing tests that the *constructor* routes stored views through `ev_z` rather than `_pcp_view` — **N15** (MINOR). |
| **N10** | FIXED | **ACCEPTED** | `_bind_certificate(node, term, anchor, locate)` refuses with `:certificate_binding` unless `locate(proof) === anchor`; `_bind_evidence` anchors `tf`, `g_i`, `c_0`, decomposition by identity and `F_arith` (not a proof component) to its `tf`, and throws on any other foreign term (`pcp.jl:139-178`). Testset 4c `:365-370` asserts witness (iii)'s proof with witness (i)'s certificate fails with `:certificate_binding` while its own certificate still fails at `:coefficient_identity`. Mutant **P** registered (target `witness_iii`) and **KILLED**. Verified in depth (§0(3)): the anchor fires per component, and even a structurally identical rebuild is refused. The chosen option is the one the brief demanded (identity binding), not the DESIGN §3 amendment. Residue: only the `:Tseitin` anchor is exercised by the suite — **N14** (MINOR). |
| **N11** | FIXED | **ACCEPTED (one correction)** | `docs/DESIGN.md:740-745` records that `src/precompile.jl` executes a full TB0 workload at image-build time, that it caches specializations and no values, and the four r3 figures; `test/runtests.jl:5-9` names `tools/cold_precompile.sh` and the "reported separately" clause is gone; `MIPSTAR_SKIP_EXPLICIT_PRECOMPILE` is **deleted** (no occurrence anywhere in `src/` or `test/`). `tools/cold_precompile.sh` builds into a `mktemp -d` depot stacked before the default depots, so the shared cache is untouched — I read it and confirm it can neither read nor write `~/.julia/compiled` for this package. Its measured figure on this machine: **124.4 s** (§3). **Correction:** the DESIGN sentence attributes 97 s / 31 s to "the r3 critic" but reads as the cost of the *current* workload, which r4 enlarged (borrowed-certificate refusal, `ev_z` refusal, GF(2^11) encoding paths); measured 124.4 s — **N16** (MINOR). |
| **N12 / N7 residue** | FIXED | **ACCEPTED** | Item 2 (`DESIGN.md:836-837`) now states "on all points of `GF(8)^m` (8, 64, 512 points), then on 512 seeded `GF(2^11)` points per `m` (seed `0x092048`)" and `encoding_checks` does exactly that, asserted by tuple equality (§0(4)). Item 6 (`:859-860`) strikes the `GF(2^11)` sampling and says the named GF(8) line sweep is witness (i)'s only, witness (ii)'s completeness evidence being the separator in both fields — which matches `coordinate_line_report`'s single call at `:466` (witness (i)) and testset 5a. Lockstep between DESIGN §5.1, the code and C1's retraction now holds. |
| **CROSS-LANE** | none expected | **ACCEPTED** | `test/runtests.jl` changed only in the preamble comment and the `println` string; `tools/cold_precompile.sh` is new; `claims/CLAIMS.md` untouched by the proposer (the orchestrator's `44160d1` re-pointed C2/C3/C8 only). `src/tb0.jl`, `src/ir/**`, `src/polynomials/**`, `src/fields/**` are byte-identical to `6f4083a`. |
| **MERGE PROPOSAL C1** | verbatim | **REJECTED as submitted; superseded by §6** | Two defects, both mine to fix rather than the proposer's to re-do (see N17, N18): (a) its five `where-tested` pointers are the *pre-shift* line numbers (`:427-434`, `:372-385`, `:438-493`, `:500-516`, `:565-587`), contradicted by the proposer's own shift table one line above; (b) its sentence "ten of the eleven replay the constructor's own sub-terms … and only the root reads the `PCPProof` object" was true at `6f4083a` and is **false at `44160d1`** — after N10 every bound node reads `locate(proof)` from the attached proof. §6 carries the corrected authorized row. |

---

## 2. New objections

All four are MINOR. I record the severity calibration explicitly, because the brief's default was "a surviving new
semantic mutation is MAJOR": r3 rated **N9 MINOR** for a checker with *no* red test at all. Each survivor below is a
checker that *does* have a registered red test which is KILLED (X2/6e for the degree root, P for the identity binding,
NM3 for the locality guard) and whose coverage is incomplete in one direction. Rating those above r3's own N9 would be
inconsistent with my prior verdict, so they are MINOR. None of them makes any statement in `claims/CLAIMS.md` false; I
verified each checker is *correct* by a positive control before reporting the mutation as surviving.

### N13 · MINOR · `src/verifiers/pcp.jl:117-126` (`_replay_pcp_degree`) — the root `def:pcp-proof` replay's coverage of the quotients `c_1..c_16` has no red witness

`def:pcp-proof` (`gt-10-answer-reduction.tex:1428-1434`) requires individual degree at most `d` on `g_1..g_5` **and**
`c_0,...,c_{m'}`. Mutation **R4M3**, `polynomials = (proof.gs..., proof.c0, proof.cs...)` -> `(proof.gs..., proof.c0)`,
full `TB0_TARGET=all` run of the archived tree: **SURVIVED, exit 0, every testset green.** The reason is arithmetic, not
accidental: on both TB0 fixtures `max_j inddeg(c_j) = 6 = inddeg(c_0)`, so dropping the quotients never changes the
reported maximum. **Positive control** (`probe3.jl`): a proof whose `c_16` is replaced by `c_0·z_11` (individual degree
7 > d = 6) with `c_0` and every `g_i` untouched is refused unmutated (`:pcp_degree`, `actual = 7`) and **accepted** under
R4M3 (`actual = 6`). So the check is live and the mutation genuinely removes half of `def:pcp-proof`.
**FIX DEMAND** — two lines in testset 5c: build that over-degree proof and
`@test !passed(MIPStarLambda._replay_pcp_degree(over_proof))`; register R4M3 as a permanent mutant with target
`certificate`.
**SURVIVING WEAKER STATEMENT** — the substance is asserted directly and is red-capable elsewhere: `:456` asserts
`all(q -> max inddeg(q) <= fixture.proof.d, quotients)` for witness (i) and `:555-557` asserts it for
`(gs..., c_0, quotients...)` for witness (ii); mutant Q (KILLED) owns the quotients. What is unevidenced is that the
*root replay node* C1 cites covers them.

### N14 · MINOR · `src/verifiers/pcp.jl:161-178` (`_bind_evidence`) — the borrowed-certificate test exercises one of ten identity anchors

`verify_certificate` returns at the first failing node, and for every borrowed pair the first failure is the `:Tseitin`
anchor (§0(3)). Mutation **R4M5**, `(proof -> proof.gs[i]), gs[i]` -> `(proof -> proof.gs[1]), gs[1]` (all five
multilinear-extension nodes anchored to `g_1`): **SURVIVED, exit 0, whole suite green.** **Positive control**
(`probe3.jl`): the chimera that keeps witness (i)'s `tf`, `c_0`, decomposition and certified views and swaps only `g_3`
for witness (iii)'s (structurally identical zero polynomial, different object) is refused unmutated at
`:MultilinearExtension` with `:certificate_binding`, and is **accepted** (`passed = true`) under R4M5.
**FIX DEMAND** — one assertion in testset 5c: the `g_3`-swap chimera above must fail with `:certificate_binding` and
`location == :MultilinearExtension`; register R4M5 as a permanent mutant.
**SURVIVING WEAKER STATEMENT** — the binding *mechanism* is owned (mutant P, KILLED) and the per-component anchors are
in fact correct (my chimera sweep exercises all four node kinds and each refuses); what is untested is the anchor map.

### N15 · MINOR · `src/verifiers/pcp.jl:192-196` (`_certified_views`) — the constructor's routing through `ev_z` is unowned

Mutation **R4M2**, `map(point -> ev_z(proof, point), certified_points)` ->
`map(point -> _pcp_view(proof.gs, proof.c0, proof.cs, point), certified_points)`: **SURVIVED, exit 0, whole suite
green.** The code comment above the function states the property normatively ("Certified views go through `ev_z`, so
every stored view has passed the block-locality guard; a bare `_pcp_view` never reaches a certificate"); §0(6) confirms
`_pcp_view` on a locality-violating proof returns a view where `ev_z` throws, so the bypass is real. This is the residue
of r2's NOTE (e) that N9's repair did not reach: N9 bought a red test for the guard, not for the routing.
**FIX DEMAND** — one assertion: `@test_throws ArgumentError build_pcp(tf, bad_gs, c0, decomposition, d,
tb0_certified_points(GF8), ())`, or register R4M2 as a permanent mutant with a test that builds a proof through
`build_pcp` from a locality-violating `g_1`.
**SURVIVING WEAKER STATEMENT** — no claim row depends on the routing; C3's block-locality evidence is the direct
`dependency_coordinates(g_i) == Set((i,))` at `:570`, which is green and owned by mutant F.

### N16 · MINOR · `docs/DESIGN.md:743-745` — the recorded cold-build figure is r3's, for a workload r4 enlarged

The sentence reads "`src/precompile.jl` executes a full TB0 workload … The r3 critic measured the cold image build at
97 s with the workload and 31 s without". r4 added the borrowed-certificate refusal, the `ev_z` refusal and the GF(2^11)
encoding paths to that workload (`src/precompile.jl:10-20, :45-57`). My measurements of the **shipped** workload:
`tools/cold_precompile.sh` **124.4 s** (documented command, scratch depot, quiet); `Pkg.instantiate()` into the shared
depot **112.2 s**. The proposer independently measured 128.5 s. So the documented figure understates the shipped one by
~25–30% and is attributed to a round in which the workload was smaller.
**FIX DEMAND** — one clause: keep the r3 comparison as the *with/without* delta and add the r4 figure from the
documented command ("`tools/cold_precompile.sh` measures 124 s (critic r4) / 128 s (proposer) for the current
workload"). No code change.
**SURVIVING WEAKER STATEMENT** — the load-bearing claim of the sentence — that the 60 s gate certifies warm-image TB0
compute and never the cost from cold — is true, documented, and unaffected by the numeric drift.

### N17 · MINOR (proposal-level, discharged here) · `briefs/49-tb0-repair-r4.last.md:15` — the C1 merge proposal carries the pre-shift pointers

The proposal reproduces r3's authorized `where-tested` cell verbatim (`:427-434`, `:372-385`, `:438-493`, `:500-516`,
`:565-587`) while line 14 of the same file lists the shifts that invalidate all five. At `44160d1` those ranges land on
testset 5a's policy body, the `mutation_b_separator` helper, testset 5a/5b, testsets 5c/6a boundaries and testset 7 —
none of which is what the cell names. **FIX DEMAND** — apply §6's row, whose cells I resolved against the archived tree
one by one (§5). No further repair round is needed.

### N18 · MINOR (proposal-level, discharged here) · the C1 merge proposal's binding sentence is stale

"ten of the eleven replay the constructor's own sub-terms … and only the root reads the `PCPProof` object" described
`6f4083a`. At `44160d1` every one of the ten reads `locate(proof)` off the attached proof before replaying. Copying it
verbatim would put a false sentence into a promoted row — exactly the silent-drift failure mode rk-light law 2 targets,
here in the harmless direction (the code is *stronger* than the text). **FIX DEMAND** — apply §6's row. Discharged.

### NOTEs (no fix demanded)

(a) `disposition` (`run.jl:281`) still credits `KILLED-BY-CRASH` as a kill; none occurred — all 64 lines are `KILLED`,
i.e. each mutant's target printed a failed `@test`. The proposer lists this under "Not done (no fix demanded)"; r3's
NOTE (a) stands unchanged. (b) DESIGN §5.1's mutation-owner paragraph still names only A–F; the registry now carries 25
TB0 mutants (A B C D E F C8 G H I J K L M X1 X1b X2 X3 X4 N O Q S NM3 P). Pre-existing, not a regression. (c) `:BuildC0`'s
displayed `inddeg = …; monomials = …` is still formatted at construction and no replay checks the string; the numbers are
pinned separately at `:444-446`. (d) No `@assert` appears anywhere in `src/` or `test/` (the only match is the docstring
at `certificates.jl:3`). (e) All eleven TB0 certificate nodes are CHECKED, asserted at `:486`; the `change_field`
certificate's four nodes at `:616`. No CITED or ASSUMED leaf appears in the TB0 derivation tree, as DESIGN §3 requires
for C1–C3. (f) r3's elegance item 1 is weaker than it looked: I mutated `line_values` to collapse every line to its base
point (**R4M4**) and it was **KILLED** at `5b:469` (`(formula_ok=false, zero_ok=false, count=128)`), because
`coordinate_line_report` builds the substituted point independently of the evaluator. The 128-point sweep is red-capable.

---

## 2b. Fidelity audit of the changed code (checks that PASSED)

| ground truth / normative text | changed code | verdict |
|---|---|---|
| DESIGN §3: a CHECKED node "recomputes it against the attached term at test time … stale evidence unrepresentable without detached caches" | `_bind_certificate` + `_bind_evidence` (`pcp.jl:139-178`) | faithful, and strictly stronger than at r3: the captured sub-term is admitted only when it *is* the attached proof's component (`===`), verified per node kind by my chimera sweep |
| `def:pcp-proof` degree condition on all `g_i, c_0, c_j` (`gt-10:1428-1434`) | `_replay_pcp_degree` | faithful as written (all 22 polynomials); its quotient coverage has no red witness (N13) |
| `fig:pcpverifier` steps 4–5 (`gt-10:1548-1585`) | `pcpverifier` unchanged | faithful; my new mutation R4M1 (zero test truncated to `1:N-1`) is KILLED at `5a:413, :415` |
| `sec:ld-encoding` big-endian identification (`gt-03:873-897`) | `ind` / `g_a` unchanged; the sweep now runs on all of `GF(8)^m` and 512 seeded `GF(2^11)` points per `m` | faithful; mutants G and H (bit-order reversals) both KILLED under `BASELINE encoding => OK` |
| DESIGN §5.1 items 2 and 6 | `encoding_checks`, `coordinate_line_report` | lockstep restored (§0(4)); the DESIGN text and the code now sweep the same sets |
| DESIGN §5 60 s gate semantics | `test/runtests.jl:5-9,:17-20`, `tools/cold_precompile.sh` | faithful; the cold cost is now reachable from a documented command, with the numeric drift of N16 |

All `gt-NN:Lx-Ly` citations in the changed code resolve to the labels they name.

---

## 3. Test and mutation runs I observed

Archived tree, warm image after `Pkg.instantiate()`. Julia 1.12.5, 12 cores.

```
RUN 1 (load avg 2.43 at start; no other julia process)
MIPStarLambda load/precompile seconds = 0.337   (ungated; cold image build: tools/cold_precompile.sh)
TB0 test-body wall seconds = 39.205 (warning=45.0, hard_limit=60.0)        no warning
TB0 60 s test-body hard limit (measured 39.205 s) | 1 Pass
Test Summary: MIPStarLambda | 507  507  1m56.0s                            exit 0
EXTERNAL WALL  real 1m57.577s / user 1m56.568s

RUN 2 (QUIET: no julia and no pdflatex resident, load avg 1.72 at start)
MIPStarLambda load/precompile seconds = 0.338
TB0 test-body wall seconds = 38.229 (warning=45.0, hard_limit=60.0)        no warning
Test Summary: MIPStarLambda | 507  507  1m54.5s                            exit 0
EXTERNAL WALL  real 1m56.005s / user (quiet)
```

All 18 TB0 testsets execute under the default `TB0_TARGET=all`, including "5a. mutation-B formula separator" (**9/9**,
up from 5/5 at r3 — the four new N8 assertions) and "5c. sparse terms and replayable derivation tree" (**16/16**, up
from 13, carrying N9's `@test_throws` and the dependency-set assertion) and "4c. witness (iii)" (**13/13**, up from 11,
carrying N10's borrowed-certificate assertions).

Mutation runner (`MUTATION_JOBS=4 julia --project=. test/mutations/run.jl`), same tree, quiet:

```
36 baselines, all "=> OK":  field zero_basis occurrence c8 encoding pcp_separator c0_terms circuit witness_iff
                            layout_m2 certificate nonprime field_change nondegenerate pcp witness_iii   (TB0, 16)
                            + 13 TB1 + 7 TB2
TB0: A B C D E F C8 G H I J K L M X1 X1b X2 X3 X4 N O Q  +  S  NM3  P   (25) => all KILLED
TB1: 27 => all KILLED        TB2: 12 => all KILLED
MUTATION REGISTRY: killed=64/64 baselines ok=36/36 wall=541.37 s
isolated targeted mutations | 2 Pass 2 Total                             runner exit 0
EXTERNAL WALL  real 9m2.092s
```

Every one of the 64 lines is labelled `KILLED` — none `KILLED-BY-CRASH`, none `UNATTRIBUTABLE`, none `LOAD-ERROR`, none
`SURVIVED` — and every one of the 36 baselines exits 0. The three new r4 mutants are killed under passing baselines:
`S` (target `pcp_separator`, baseline OK 19.47 s), `NM3` (target `certificate`, baseline OK 6.38 s), `P` (target
`witness_iii`, baseline OK 21.17 s).

**Cold precompile (brief obligation).** `tools/cold_precompile.sh`, quiet, one julia process:

```
MIPStarLambda cold image build seconds = 124.4 (src/precompile.jl TB0 workload included; scratch depot)
real 2m5.629s / user 6m28.992s
```

For comparison, my own `Pkg.instantiate()` into the shared depot reported `112244.3 ms  ✓ MIPStarLambda`. Both exceed
the 97 s recorded in DESIGN §5 (N16). The script's isolation is genuine: `JULIA_DEPOT_PATH="$depot:"` with a
`mktemp -d` depot and a `trap … EXIT` cleanup, so the shared `~/.julia/compiled` cache is neither read as a source of
this package's image nor written.

---

## 4. My new mutations (semantic, not used in r1–r3; on copies, full `TB0_TARGET=all` runs)

| id | mutation | site | outcome |
|---|---|---|---|
| **R4M1** | `pcpverifier`'s zero test truncated: `for i in 1:N` -> `for i in 1:N-1`, i.e. `fig:pcpverifier` step 5 drops the last coordinate's `beta_i z_i(1-z_i)` term | `src/verifiers/pcp.jl:294` | **KILLED** — testset 5a `:413` and `:415` (`passed(separator8.result)`, `passed(separator11.result)`), 7 passed / 2 failed, exit 1 |
| **R4M2** | `_certified_views` bypasses `ev_z` and calls `_pcp_view` directly | `src/verifiers/pcp.jl:195` | **SURVIVED — exit 0, whole suite green** → **N15** (bypass liveness verified separately, §0(6)) |
| **R4M3** | the root `def:pcp-proof` replay drops the quotients: `(proof.gs..., proof.c0, proof.cs...)` -> `(proof.gs..., proof.c0)` | `src/verifiers/pcp.jl:118` | **SURVIVED — exit 0, whole suite green** → **N13** (positive control: over-degree `c_16` refused unmutated, accepted mutated) |
| **R4M4** | `line_values` collapses every coordinate line to its base point (`map(field_elements(F))` -> `map(fill(base[coordinate], 8))`) | `test/tb0_core.jl:299` | **KILLED** — testset 5b `:469`, `(formula_ok=false, zero_ok=false, count=128)`, exit 1 |
| **R4M5** | all five `:MultilinearExtension` anchors collapsed to `g_1`: `(proof -> proof.gs[i]), gs[i]` -> `(proof -> proof.gs[1]), gs[1]` | `src/verifiers/pcp.jl:171` | **SURVIVED — exit 0, whole suite green** → **N14** (positive control: `g_3`-swap chimera refused unmutated, accepted mutated) |

Plus the probes of §0: the disarm scenario end to end, the 16-pair borrowed-certificate matrix, the chimera anchor
sweep, the five-coordinate separator sweep in both fields, the `GF(8)^m` set-equality check, the `d`-sweep, and the
`ev_z` guard positive control.

---

## 5. Pointer audit (every `where-tested` cell against the archived tree at `44160d1`)

Read from the live `claims/CLAIMS.md` (HEAD, orchestrator-owned), resolved against `44160d1`'s `test/tb0_core.jl`:

| claim | cell | resolves to | ok |
|---|---|---|---|
| C2 | `:173-195` (`2^16` table) | testset 4a, `@testset` line 173 … `end` 195 | ✓ |
| C2 | `:199-218` (clause-relation count) | testset 4b, 199 … 218 | ✓ |
| C2 | `:346-385` (witness (iii), cube vs `phi_C`) | testset 4c, 346 … 385 | ✓ |
| C2 | `:450-456` (`r=0`, identity, (i)) | `quotients = collect(...)` 450 … `all(q -> … <= d)` 456 | ✓ |
| C2 | `:545-561` ((ii)) | testset 6a, 545 … 561 | ✓ |
| C2 | mutants A, I, K, N, O, Q | all present in `run.jl`, all KILLED under passing baselines | ✓ |
| C3 | `:674-684` (occurrence/degree equality) | testset 8, 674 … 684 | ✓ |
| C3 | `:450-456` (witness (i) split) | as above; `findall(isempty, quotients) == [2,3,4,7,8,9,10]` at 453, nine nonzero 454, max inddeg 6 at 455 | ✓ |
| C3 | `:521` (all eleven CHECKED replays) | `@test passed(verify_certificate(Checked(proof, fixture.certificate)))` | ✓ |
| C3 | `:545-561`, `:563-576` ((ii)) | testsets 6a and 6b; exact dependencies at 569-570 | ✓ |
| C3 | mutants E, F, C8, Q, X4 | all present, all KILLED | ✓ |
| C8 | `:674-684`; `:688-698` | testsets 8 and 9 | ✓ |
| C8 | mutants E, C8 | present, KILLED | ✓ |

**All twelve pointer cells resolve to the assertions they name.** The r4 re-pointing at `44160d1` is correct. The only
broken pointers in the round are in the C1 *merge proposal* (N17), which §6 supersedes.

---

## 6. Per-claim decisions

### C1 — **PROMOTE to `TESTED`**

N8, the single MAJOR of r3, is discharged in substance and by construction: the value that distinguishes mutant B is now
computed from the fixture, the assertion is satisfiable only at a point where the deleted factor is detectable, `O2` is
the unique such sign coordinate, moving the separator turns the unmutated target red, and mutant B becomes
`UNATTRIBUTABLE` rather than silently surviving — I reproduced every step. Everything else the row asserts I reproduced
independently: 128/128 line acceptances and the 65,536-point cube for witness (i), `2`/`1` over `GF(8)` and `96`/`48`
over `GF(2^11)` at the separator, both certificates replaying, the field change re-certified with upper-bound `d`
semantics, and the identity binding now refusing a borrowed certificate at every node kind. Two corrections to r3's
authorized text are mandatory and are applied below: the binding sentence (N18) and the five pointer cells (N17). Two
additions are authorized: mutant `S` as a further red-test owner of the separator sentence, and mutant `P` as the owner
of the binding sentence. No statement is strengthened — the binding sentence is *weakened* relative to r3's, in that it
now says what the code does rather than what it did.

**AUTHORIZED row text (apply verbatim; no word added or removed):**

`| C1 | For the explicit real six-gate TB0 instance, both retained PCP proofs — witness (i) `([0,1],[0,0],[0,0],[0,0],[0,0])` and witness (ii) `([0,1],[0,1],[0,1],[0,1],[0,1])` — are checked by formal coefficient identities: `verify_certificate` replays every CHECKED node of each proof's certificate, including `c_0=sum_j c_j zero(z_j)` with `r=0`; the eleven-node rule sequence and all-CHECKED grades are asserted for witness (i). Ten of the eleven replay the constructor's own sub-terms, each admitted only after an object-identity check that the attached `PCPProof` owns that sub-term (`tf`, `g_i`, `c_0`, decomposition; `F_arith`, not a proof component, is anchored to its `tf`), so a certificate borrowed from another proof is refused with `:certificate_binding`; only the root reads the `PCPProof` without an identity anchor, replaying the `def:pcp-proof` degree condition. Witness (i)'s proof is accepted by `pcpverifier` at all 128 points of the 16 named `GF(8)` coordinate lines `S_j` through `b_rho` and its `c_0` vanishes at all 65,536 Boolean points; `c_0(b_rho) != 0` is asserted for witness (ii) in both fields (1 over `GF(8)`, 48 over `GF(2^11)`). At the separator `b_rho[O2<-rho]` `pcpverifier` accepts the honest view with `beta_0=2` over `GF(8)` (both witnesses; witness (i)'s as its stored certified view) and `beta_0=96` over `GF(2^11)` (witness (ii) via `ev_z`; witness (i) as the stored certified view of the re-certified `change_field` proof, whose four-node certificate replays the `def:pcp-proof` degree condition `max inddeg <= d` at the relabelled `d=11` — an upper-bound check, not a re-derivation of 11), where deleting `g_2-o_2` gives 1 and 48, values recomputed from the fixture as `F_arith(z)*prod_{i!=2}(alpha_i-z[o_i])` and asserted to differ from the honest `beta_0`, so the certified separator coordinate is pinned by that assertion and not by a literal. No uniform `z` in `GF(2^11)^16` are sampled (tracked as `mipstar-lambda-yqw`). This is completeness evidence on named points and lines, not an exhaustive all-`z` or soundness claim. | TESTED | C2,C3,D1 | — | `test/tb0_core.jl:464-471` (lines, cube); `:406-421` (separators and the fixture-computed mutated value, both fields); `:475-538` (witness (i) replays, node sequence, stored view); `:365-370` (borrowed certificate refused); `:545-561` (witness (ii)); `:610-632` (field change); `test/mutations/run.jl` mutants B, J, L, P, S, X2, X3 (all KILLED) | `verdicts/tb0-r4.md` (PROMOTE) |`

### C2 — **RE-AFFIRM `TESTED`**

Promoted at r3; the r4 delta touched none of its evidence. I re-measured `|c_0| = 33,432 / 534,912 / 18,620`,
`|r| = 0 / 0 / 2` and `inddeg(c_0) = 6` on all three witnesses through the repository's own code, and the occurrence
vector `(2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)` on each. Testset 4c is now 13/13 (the two N10 assertions were added inside
it) and its `:coefficient_identity` failure for witness (iii)'s own certificate is unchanged — the borrowed-certificate
addition sits beside it, not in place of it, which I verified by running both paths. Mutants A, I, K, N, O, Q remain
KILLED under passing baselines. **The row stays exactly as committed at `claims/CLAIMS.md:9` — statement, status,
depends-on and all six `where-tested` pointers verified correct against the archived tree (§5); no word changes.** The
`verdict` cell becomes ``verdicts/tb0-r3.md`` (PROMOTE); ``verdicts/tb0-r4.md`` (re-affirmed).

### C3 — **RE-AFFIRM `TESTED`**

Unchanged evidence, all pointers verified (§5). Witness (ii)'s exact dependencies (`:569-570`), its degree vector
`(3,1,1,1,3,3,1,1,1,1,6,4,4,4,4,3)` (`:552-553`) and witness (i)'s seven-zero/nine-nonzero split (`:453-454`) all reproduce.
Mutants E, F, C8, Q, X4 KILLED. **The row stays exactly as committed at `claims/CLAIMS.md:10` — no word changes.** The
`verdict` cell becomes ``verdicts/tb0-r1.md`` (PROMOTE); ``verdicts/tb0-r3.md``, ``verdicts/tb0-r4.md`` (re-affirmed).

### C8 — **RE-AFFIRM `TESTED`**

Substance re-confirmed for the fourth time: TB0's occurrence vector with equality on all sixteen coordinates
(testset 8, 4/4) and the two-gate vector `(2,2,2,4,3)` with `deg_{w1} = 4 > 2` (testset 9, 4/4), both in the default
suite. Mutants E (target `occurrence`) and C8 (target `c8`) KILLED under passing baselines. **The row stays exactly as
committed at `claims/CLAIMS.md:18` — no word changes; the `where-tested` cell `test/tb0_core.jl:674-684`;
`test/tb0_core.jl:688-698`; `test/mutations/run.jl` mutants E, C8 is verified correct and stands.** The `verdict` cell
becomes ``verdicts/tb0-r1.md`` (PROMOTE, scoped); ``verdicts/tb0-r2.md``, ``verdicts/tb0-r3.md``,
``verdicts/tb0-r4.md`` (re-affirmed).

---

## 7. Trajectory

r1: 7 MAJOR / 9 MINOR / 7 NOTE. r2: 5 MAJOR / 2 MINOR. r3: 1 MAJOR / 4 MINOR / 5 NOTE.
r4: **0 FATAL, 0 MAJOR, 6 MINOR (two of them proposal-level and discharged in this verdict), 6 NOTE.** The loop has
converged: every r3 objection is discharged in substance, each verified by fresh computation rather than by reading the
response table — the disarm that killed r3 is now red at four assertions and refuses to credit mutant B, a borrowed
certificate is refused at whichever component first differs (including a structurally identical rebuild), the
block-locality guard has a `@test_throws` and a registered mutant, the encoding sweep really does cover all 584 points
of `GF(8)^{1,2,3}` plus 1,536 seeded `GF(2^11)` points, and the cold image cost is reachable from a documented command
that cannot touch the shared depot. The registry grew from 45/45 to **64/64 KILLED with 36/36 baselines OK**, and the
TB0 block from 22 to 25 mutants, with no `KILLED-BY-CRASH` and no `UNATTRIBUTABLE`. Three of my five new semantic
mutations survived; all three are coverage gaps inside checkers that are correct (I proved each with a positive control)
and that already carry a KILLED red test, so none is MAJOR by r3's own N9 calibration and none makes a claim false —
they are the r5 work order, not a blocker. The arithmetic remains impeccable: `18,620`, `2`, `33,432`, `37,240`,
`534,912`, `788,032`, `148,176`, `2,370,816`, both degree vectors, the seven-zero/nine-nonzero split, `1`/`48`,
`2`/`96`, `128`, `65,536`, `(2,2,2,4,3)` and `minimal_checkable_odd_k = 11` all reproduce.

VERDICT: PASS
