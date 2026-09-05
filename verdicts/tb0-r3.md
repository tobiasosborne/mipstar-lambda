# CRITIC verdict r3 — rung TB0 (`src/**`, `test/tb0_core.jl`, `test/mutations/run.jl`, `src/precompile.jl`) at commit `6f4083a`

Round 3 (adjudicate). Priors: `verdicts/tb0-r1.md` (O1–O16), `verdicts/tb0-r2.md` (N1–N7, X1–X4; O6/O15 REJECTED, O14 PARTIAL).
Work order: `briefs/48-tb0-critic-r3.md`; repair order `briefs/42-tb0-repair-r3.md`; response table
`briefs/42-tb0-repair-r3.last.md` (23 lines, written by the proposer — O15/N6 is genuinely discharged this round).
Nothing that passed in r1 or r2 is re-litigated.

**Isolation.** `git archive 6f4083a | tar -x` into
`/tmp/.../scratchpad/critic-tb0-r3/tree/`; `Pkg.instantiate()` there (cold image build **96,773.7 ms**). Every run, probe and
mutation is in that copy or under `.../critic-tb0-r3/{indep,mut,tree-nopc}/`. The live working tree (concurrent
documentation lane) was never read for `src/` or `test/` and never run. No repo file other than this verdict was written; no
state-changing git command was run. The two test files I temporarily edited in the scratch tree for the UNATTRIBUTABLE
demonstration were restored byte-for-byte (md5 verified) before the reported timing runs.

**Independence.** §0 is recomputed by a *new* from-scratch Python implementation written against `gt-10`
(`def:tseitin` via NW19, `def:formula-arithmetization`, `prop:zero-basis`) and `gt-03` `sec:ld-encoding` prose —
16-variable sparse `GF(2)` arithmetic, its own Tseitin gadget builder, its own occurrence counter, its own multilinear
extension and its own multilinear-quotient reduction (`.../indep/tb0.py`, `.../indep/c8.py`). It shares no code with `src/`,
with `docs/`, or with r1's/r2's scratch.

---

## 0. Independent recomputation (brief obligations)

**(1) N1's numbers — CONFIRMED, from scratch and again through the repository's own code.**

```
occurrence vector (my own Tseitin walk)   = (2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)
inddeg(F_arith)  (my own char-2 product)  = (2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)   |F_arith| = 18,620
witness (iii) ((0,0),(0,0),(0,0),(0,0),(0,0)):  |c_0| = 18,620      |r| = 2
   r = X1 X5 O1 O2 O3 O4 O5 W2 W3 W4 W5 W6 (1 + W1)      (exactly the two monomials r2 predicted)
witness (i)   ((0,1),(0,0),(0,0),(0,0),(0,0)):  |c_0| = 33,432      |r| = 0
   inddeg(c_0) = (3,0,0,0,2,3,1,1,1,1,6,4,4,4,4,3)
   per-product candidate counts = [37240, 33432, 33432, 33432, 33432]  sum 170,968  peak 37,240
```

Repository cross-check (`.../indep/probe1.jl`, archived tree): `|c_0^{(i)}| = 33432`, `|c_0^{(iii)}| = 18620`,
`|r^{(iii)}| = 2`, `r^{(i)}` empty, `inddeg(c_0^{(iii)}) = (2,0,0,0,2,3,1,1,1,1,6,4,4,4,4,3)`. **N1's fix demand was
arithmetically sound and the repair reproduces it exactly.** `test/tb0_core.jl:334, :337` pin 18,620 and 2.

**(2) C8's two circuits — CONFIRMED independently.** By hand from finding F1 (`2·fanout` for inputs,
`2 + 2·fanout + [i=out]` for gate wires): TB0 gives `(2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)`; the two-gate circuit gives
`(2,2,2,4,3)`. My own char-2 arithmetization of the two-gate circuit has `|F_arith| = 49` with individual degrees exactly
`(2,2,2,4,3)`, i.e. `deg_{w1} = 4 > 2`. Equality holds on all named coordinates in both cases.

**(3) `c_0(b_rho)` — CONFIRMED, and a coverage fact.** `c_0^{(i)}(b_rho) = c_0^{(ii)}(b_rho) = 1` over `GF(8)` and `48`
over `GF(2^11)`; `F_arith(b_rho) = rho^4(1+rho) = 1` in `GF(8)`. The suite asserts `!iszero` only for witness (ii)
(`:528`, `:530`); for witness (i) the value is true but unasserted. C1's authorized text is scoped accordingly (§6).

**(4) N4's `:Tseitin` probe (r2's X4) re-run on the archived tree — now FALSIFIABLE.** `circuits.jl:265-272` compares the
stored vector against `tseitin_occurrence_account(circuit)`, which is computed from `fanout(circuit)` alone and never from
the formula. My probe: the TB0 certificate replayed against the **C8** `tf` returns `false` (r2's version could not
distinguish anything). The registered mutant `X4` (`counts[...] += 1 -> = 1`) is KILLED, and my own new mutation of the
*account* side (NM2, §4) is also KILLED, so the comparison is falsifiable from both directions.

**(5) N5's `change_field` probe — the root replay does NOT re-derive `d`.** `.../indep/probe1.jl`, mutating `d` and the
certified points on the archived tree:

| `change_field(proof_i, GF2048, d, tb0_certified_points(GF2048))` | `verify_certificate` |
|---|---|
| `d = 5` | **false**, rule `:pcp_degree` |
| `d = 6` | true |
| `d = 11` | true |
| `d = 1000` | **true** |

`_replay_pcp_degree` (`pcp.jl:117-126`) checks `max_p inddeg(p) <= proof.d`; `11` is the caller's label, and every
`d >= 6` passes. The repair is correct and sufficient for `def:pcp-proof` (`gt-10:1426-1442` requires *at most* `d`), but
the merge-proposal sentence "**whose root replay re-derives `d=11`**" is **false as written** and is corrected in §6.
Mutating the point instead: the certified view is accepted at `b_rho` itself (`beta_0 = 48`) and at a uniformly random
`z` (`beta_0 = 1660`) — for an honest proof `pcpverifier` accepts identically at every point, so the `:PCPVerifier` replay
is falsified by a corrupted view (`:463-468`) or a corrupted `c_0` (mutant J), never by the choice of point. This is the
root of N8.

---

## 1. Adjudication of the r3 response table (`briefs/42-tb0-repair-r3.last.md`)

| id | claimed | adjudication | evidence / exact residual |
|---|---|---|---|
| **N1** | FIXED | **ACCEPTED** | Testset 4c (`:325-360`) builds witness (iii) through the real pipeline at the DESIGN budget 160,000 and asserts `\|c_0\|=18,620`, `\|r\|=2`, `!passed(verify_zero_decomposition)`, `verify_certificate` failing with rule `:coefficient_identity`, the display `"remainder = 2; coefficient identity = false"`, `cube_iii == (zero=false, count=65_536)`, and `boolean_cube_zero_report(c_0).zero == phi_C(...)` on (i), (ii), (iii). The 1,024 loop survives, relabelled a clause-relation count (`:138-148`, `:179`, and the printed line says so). Every number independently reproduced (§0(1)). Owners **N** and **O** KILLED under passing baselines. The De Morgan tautology is now honestly labelled instead of being passed off as the ⟺ clause. |
| **N2** | FIXED | **ACCEPTED** | (a) `mutation_b_separator` (`:364-370`) evaluates through `ev_z(proof, only(tb0_certified_points(F)))`, so it works on either field; testset "5a. mutation-B formula separator" is guarded by `runs("pcp_separator")` and **runs in the default suite** (5/5 in both of my runs); its baseline is `OK (exit=0, 20.33 s)`. (b) `run.jl:188-199, 229-243`: one unmutated baseline per distinct `(test file, target variable, target)`, `disposition` returns `UNATTRIBUTABLE` when the baseline is broken, and the registry `@testset` asserts `all(baseline.ok ...)`. Reproduced by me (§3). Residual: `killed = failed_after_start && evidence_ok` still credits a `KILLED-BY-CRASH` (nonzero exit with no failed `@test`) as a kill; none occurred in this run — NOTE (a). |
| **N3** | FIXED | **ACCEPTED** | `if runs("layout_m2")` (`:590`); testset 7 runs in the default suite (11/11, 0.4 s) and now calls `pcpverifier` on the `ev_z` view of the `m=2` proof, on a view whose sign product used the TB0 constant `6:10` (rejected), and `verify_certificate`. `X1` and `X1b` are registered with target `layout_m2` and both KILLED under a passing baseline. My own permutation of the `m=2` fixture's tables (NM1, §4) is also KILLED there, four assertions deep, so the testset is load-bearing and not merely reachable. |
| **N4** | FIXED | **ACCEPTED (two residues)** | `verify_certificate` on witness (i) (`:476`), witness (ii) (`:515`) and witness (iii) (`:340`, must fail); the four witness-(i) assertions restored at `:414-418` (`r=0`, coefficient identity, zero quotients `[2,3,4,7,8,9,10]`, nine nonzero, `max inddeg = 6`) plus `:419` (`<= d`); the `:ZeroBasis` display is computed by `zero_basis_display` (`zero_basis.jl:105-111`) — no literal survives, and mutant **N** flips it; the `:Tseitin` replay is falsifiable (§0(4)); `_certified_views` routes stored views through `ev_z` (`pcp.jl:162-164`). Residues: the `ev_z` guard itself has no red test (**N9**), and `_bind_certificate` detaches ten of the eleven replays from the attached proof (**N10**). |
| **N5** | FIXED | **ACCEPTED with a correction** | `change_field(proof, F, d, certified_points)` returns a `Checked` with root `:PCPProof` and children `:BuildC0`, `:ZeroBasis`, `:PCPVerifier` (`pcp.jl:227-241`); unlike `build_pcp`'s evidence children these replay **against the attached proof** (`_pcp_upstream_nodes` uses `_replay_pcp_c0` / `_replay_pcp_zero`, both functions of `PCPProof`), so the field-changed certificate is strictly better bound than the constructor one. Testset 6e (`:565-587`) pins the four-rule sequence, all-CHECKED grades, `d == 11`, the stored view at `b_rho[O2<-rho]` with `beta_0 = 96`, `d = 5` refused with `:pcp_degree` and the point-less change refused with `:pcpverifier_replay`. `X2` and `X3` KILLED. **Correction:** "re-derives `d=11`" is false (§0(5)); it is an upper-bound check. |
| **N6** | FIXED | **ACCEPTED** | `briefs/42-tb0-repair-r3.last.md` is the real 23-line response table, written by the proposer. O15 discharged after two failed rounds. |
| **N7** | FIXED | **PARTIAL** | Discharged: `DESIGN.md:738-740` now states "The 60-second limit is per rung test body, not per suite … package load/precompile is reported ungated, and TB1/TB2 are included after the TB0 clock and carry no gate of their own"; the TB0-sampled table row and §5.1 item 5 now match C1's retraction (separator only, no seeded sampling, budget 37,240 with 160,000 exercised by witness (iii)); C3's `where-tested` re-pointed; C8's cell re-pointed by the orchestrator — I verified `:629-640` is exactly testset 8 and `:643-653` exactly testset 9. **Residue (N12):** §5.1 item 6 still requires "Run the same named GF(8) and sampled GF(2^11) completeness checks" for witness (ii) — `coordinate_line_report` is called once, at `:429`, on witness (i) only; and §5.1 item 2 still requires the encoding comparison "on all points of `GF(8)^m`, then on seeded `GF(2^11)` points" — `encoding_checks` is called only with `GF8` and only over the Boolean cube. |
| **X1 / X1b** | FIXED | **ACCEPTED** | Registered (`run.jl:89-94`), target `layout_m2`, both `KILLED (exit=1)` with `BASELINE … TB0_TARGET=layout_m2 => OK`. |
| **X2** | FIXED | **ACCEPTED** | Registered, target `field_change`, `KILLED`. My `d`-sweep (§0(5)) confirms the mechanism: `d=1` is below `inddeg(c_0)=6`. |
| **X3** | FIXED | **ACCEPTED** | `_replay_pcp_verifier` returns `false` on an empty view tuple (`pcp.jl:149-151`), asserted directly at `:471-473`, registered as a mutant, `KILLED`. |
| **X4** | FIXED | **ACCEPTED** | Registered with target `certificate`, `KILLED`; the direct falsifiability assertion is at `:485-491`; my independent probe agrees (§0(4)). |
| **O6** | via N1 | **ACCEPTED** | The ⟺ clause now has a real witness on the failing side. |
| **O14** | via N5 | **ACCEPTED** | With the `d`-semantics correction of §0(5). |
| **O15** | via N6 | **ACCEPTED** | — |

---

## 2. New objections

### N8 · **MAJOR** · `src/tb0.jl:11-15` + `test/tb0_core.jl:364-385` — the certified separator coordinate is asserted nowhere; moving it `O2 -> O3` leaves the whole suite green and **silently disarms mutant B**

`tb0_certified_points` sets `separator[7] = primitive_element(F)`, i.e. `b_rho[O2 <- rho]`. `DESIGN.md` §5.1 fixes that
coordinate and gives the reason: with all five `g_i(b_rho) = 0`, the honest sign product is `rho` and deleting `g_2 - o_2`
changes it to `1`, so honest `beta_0 = rho^5(1+rho) = 2` and mutated `beta_0 = rho^4(1+rho) = 1`. Nothing in the suite
asserts *which* `O` coordinate carries `rho`, and every asserted value is invariant under moving it:

- `:379-382` compare `view.beta0` against `separator8.honest`, which is the **literal** `rho^5*(1+rho)`, and
  `separator8.mutated` against the **literal** `rho^4*(1+rho)`. The "mutated" value is never computed from the proof.
- `:383` and `:452` compare `view.z` with `only(tb0_certified_points(GF8))` — a tautology.
- `:453`/`:576` pin `beta_0` to `2`/`96`, which is what *any* single perturbed `O` coordinate gives for both witnesses.

**My computation.** Mutation **NM4**, `separator[7] -> separator[8]` (`src/tb0.jl:13`), full `TB0_TARGET=all` run of the
archived tree: **SURVIVED, exit 0, every testset green.** Then, with NM4 *and* the registered mutant B applied together
and the owning target run:

```
mutant B alone (separator at O2):     5a. mutation-B formula separator -> 1 passed, 4 failed, exit 1   (KILLED)
mutant B + separator moved to O3:     5a. mutation-B formula separator |  5  5  20.5s,   exit 0        (SURVIVED)
```

The arithmetic: at `b_rho[O3 <- rho]` the honest product is still `rho` (`1·1·rho·1·1`), and omitting the `i=2` factor
leaves `1·rho·1·1 = rho` — the same value, so `beta_0` is unchanged and the verifier accepts. The `MUTATION REGISTRY`
would still print `killed=45/45`. This is r2's N2 defect class one level down: a red test whose discriminating power rests
on a fixture constant that no assertion pins.

**FIX DEMAND** — in testset 5a compute the mutated value *from the fixture* rather than from a literal:
`mutated_beta0 = evaluate_arith_formula(tf, z) * prod(view.alpha[i] - z[o_i] for i in (1,3,4,5))` and
`@test mutated_beta0 != view.beta0` (both fields); register that assertion's owner as a mutant moving the separator
coordinate. Three lines, and mutant B's ownership becomes self-certifying.
**SURVIVING WEAKER STATEMENT** — as shipped at `6f4083a` the separator *is* at `O2`, mutant B *is* attributable (baseline
`OK`, kill reproduced by me at four assertions), and every value C1 quotes (`2`, `1`, `96`, `48`) is correct; what is not
evidenced is that the point the suite certifies is a point at which the `g_2 - o_2` factor is detectable.

### N9 · MINOR · `src/verifiers/pcp.jl:205-213` — `ev_z`'s block-locality guard is a checker with no red test

Mutation **NM3**, `dependency_coordinates(proof.gs[i]) <= coordinates ||` -> `true ||`: **SURVIVED, exit 0, whole TB0
suite green.** I verified the mutation is live (with it, `ev_z` on a proof whose `g_1` has been multiplied by `z_12`
returns a view instead of throwing; without it, it throws). Nothing in the rung ever constructs a proof that violates
block locality, so r2's NOTE (e) repair — routing `build_pcp`'s stored views through `ev_z` (`pcp.jl:162-164`) — is
unverifiable by either documented command. rk-light law 4 asks every checker to be demonstrably able to fail.
**FIX DEMAND** — one `@test_throws ArgumentError ev_z(bad_proof, tb0_base_point(GF8))` with `bad_proof` built by
multiplying `g_1` by an out-of-block variable, plus NM3 as a registered mutant.
**SURVIVING WEAKER STATEMENT** — the guard is present and does fire (my probe); C3's block-locality evidence
(`dependency_coordinates(g_i) == Set((i,))`, `:524-525`) is separate and green, so no claim row depends on the guard.

### N10 · MINOR · `src/verifiers/pcp.jl:139-146` vs `docs/DESIGN.md` §3 — `_bind_certificate` detaches ten of the eleven replays from the attached term

`replay = node.grade == CHECKED ? (_ -> node.replay(term)) : node.replay` discards the term `verify_certificate` passes and
replays against the sub-term captured at construction. DESIGN §3 states normatively that a CHECKED node "recomputes it
against the attached term at test time" and that "this makes stale evidence unrepresentable without detached caches".
**My computation:** `verify_certificate(Checked(fixture_iii.proof, fixture_i.certificate))` returns **`passed = true`**,
although `fixture_iii.proof` has `|r| = 2`; only the root `_replay_pcp_degree` reads the attached proof, and `6 <= 6`
holds for witness (iii) too. (With its own certificate the same proof correctly fails with `:coefficient_identity`.)
`change_field`'s four-node certificate does not have this defect (§1, N5 row).
**FIX DEMAND** — either bind by identity (`p -> p.c0 === c0 && ...`, `p.decomposition === decomposition`, `p.tf === tf`)
so a borrowed certificate is refused, or amend DESIGN §3 to say that constructor evidence nodes replay their own
sub-terms and that only the root is term-addressed.
**SURVIVING WEAKER STATEMENT** — for both TB0 fixtures the certificate and the proof come out of the same
`build_pcp_fixture` call, so the ten sub-term replays *are* about the attached proof's own components; the defect is that
`verify_certificate` does not check that pairing.

### N11 · MINOR · `src/precompile.jl` + `docs/DESIGN.md` §5 — the precompile workload caches no value (good), but the 60 s gate now excludes ~62 s of relocated TB0 JIT that no documented command reports

Measurements on the archived tree and on a copy with `src/precompile.jl` emptied (`.../tree-nopc/`):

| | cold `Pkg.precompile()` | TB0 test body | suite | exit |
|---|---|---|---|---|
| as shipped | **96,773.7 ms** | **38.086 s** (quiet) | 275/275, 1m43.1s | 0 |
| `precompile.jl` emptied | **30,761.2 ms** | **99.59 s** — 45 s warning fires, `@test elapsed < 60` **FAILS** | 274 pass / 1 fail, 3m18.2s | **1** |

**Honesty finding (the brief's question): no test outcome is precomputed and re-read.** Every printed TB0 fact is
byte-identical between the two runs — `|c_0| = 18,620`, `|r| = 2`, `33,432`, `534,912`, `788,032`, both degree vectors,
`[37240, 33432, 33432, 33432, 33432]`, the policy vectors, `96/48`, `128`, `65,536`, `(2,2,2,4,3)` — and every testset's
pass count is identical (only wall-clock seconds differ). `src/precompile.jl` assigns to no global; `src/tb0.jl` no longer
carries the r2 caches; the only module-level mutable container in `src/` (`_HONEST_PCP_CACHES`, TB2) is never touched by
it. So the workload caches method specializations, not values. The residual objections are reporting ones:
(a) the suite prints `load/precompile seconds = 0.334 (ungated; cold/warm cache reported separately)` and **nothing
reports the cold figure** — a first-time reader of `test/runtests.jl` sees 38 s where the true first-run cost is
≈97 s + 38 s; (b) DESIGN §5 says load/precompile is ungated but never says that a full TB0 workload (witness (i) end to
end in both fields, all replays, the refusal path, the `m=2` fixture, the C8 circuit) now executes at image-build time;
(c) `MIPSTAR_SKIP_EXPLICIT_PRECOMPILE` is dead — no caller sets it, and Julia does not invalidate a package image when an
`ENV` value read in the module body changes, so a copied mutation project cannot in fact disable the workload this way.
**FIX DEMAND** — add one sentence to DESIGN §5 recording that `src/precompile.jl` executes a TB0 workload at image-build
time, with the two measured cold figures (97 s / 31 s) and the two test-body figures (38 s / 100 s); either print the cold
build time from a documented command or delete the "reported separately" clause; and either wire
`MIPSTAR_SKIP_EXPLICIT_PRECOMPILE` into `test/mutations/run.jl` or delete it.
**SURVIVING WEAKER STATEMENT** — the 60 s gate certifies TB0 compute after JIT, on a warm image; it does not certify that
the rung costs under 60 s from cold, and it never did.

### N12 · MINOR · `docs/DESIGN.md` §5.1 items 2 and 6 — N7's lockstep sweep stopped one item short

Item 6 still requires, for witness (ii), "Run the same named GF(8) and sampled GF(2^11) completeness checks needed by
TB2"; `coordinate_line_report` is called exactly once, at `test/tb0_core.jl:429`, on witness (i), and no `GF(2^11)`
sampling exists anywhere after C1's retraction. Item 2 still requires the encoding comparison "on all points of
`GF(8)^m`, then on seeded `GF(2^11)` points"; `encoding_checks` is invoked only as `encoding_checks(GF8)` (`:78`) and
compares `evaluate` with `a·ind_m(x)` only on the Boolean cube (`:60-61`, `:70-71`).
**FIX DEMAND** — in the same commit that applies §6's rows: strike "and sampled `GF(2^11)`" from item 6 and say the named
GF(8) line sweep is witness (i)'s (or add the sweep for witness (ii)); and either extend `encoding_checks` to all of
`GF(8)^m` plus seeded `GF(2^11)` points (cheap: `8^2 = 64` and `8^3 = 512` points) or strike the sentence.
**SURVIVING WEAKER STATEMENT** — neither item is load-bearing for C1, C2, C3 or C8; both are pre-existing DESIGN
over-promises, not regressions of this repair.

### NOTEs (no fix demanded)

(a) `disposition` (`run.jl:239-241`) credits `KILLED-BY-CRASH` as a kill. None occurred: all 45 lines are `KILLED`, i.e.
each mutant's target printed a failed `@test`. (b) `:BuildC0`'s displayed `inddeg = …; monomials = …` is still formatted at
construction and no replay checks it; the numbers are pinned separately at `:407-408`. (c) C3's `where-tested` cites
`:409-419`; the cited assertions are at `:413-419` (`:409-412` are `expected_support`, a comment and a `collect`) —
corrected in §6. (d) No `@assert` appears in `src/` or `test/` (the only match is the docstring at
`certificates.jl:3`). (e) All eleven TB0 certificate nodes are `CHECKED`, asserted at `:449` and `:571`; no CITED or
ASSUMED leaf appears in the TB0 derivation tree, as DESIGN §3 requires for C1–C3.

---

## 2b. Fidelity audit of the changed code (checks that PASSED)

| ground truth | changed code | verdict |
|---|---|---|
| `def:tseitin` via NW19, finding F1 (`2·fanout` / `2 + 2·fanout + [i=out]`) | `tseitin_occurrence_account` (`circuits.jl:232-243`), computed from `fanout(circuit)` alone | faithful; my hand derivation and my own arithmetization agree on both circuits |
| `def:pcp-proof` degree condition on **all** `g_i, c_0, c_j` (`gt-10:1426-1442`) | `_replay_pcp_degree`, now also the root of the `change_field` certificate | faithful (upper-bound semantics, §0(5)) |
| `fig:pcpverifier` steps 4–5 (`gt-10:1548-1585`) | `pcpverifier` (`pcp.jl:246-269`), sign block via `block_coordinates(tf.layout, :O)` | faithful; the `m=2` regression now exercises the layout lookup in both `build_c0` and `pcpverifier` |
| `prop:zero-basis` (`gt-10:1281-1373`) | `zero_basis_decompose` + `zero_basis_display` computing the displayed fact from the checker | faithful; witness (iii) exhibits the nonzero-remainder branch end to end |
| `def:pcp-eval` ordering | unchanged `PCPView` | faithful |
| `sec:ld-encoding` big-endian identification (`gt-03:873-897`) | unchanged `ind` / `g_a`, pinned by the asymmetric `m=2` / `m=3` tables | faithful |

All `gt-NN:Lx-Ly` citations in `src/` resolve to the labels they name.

---

## 3. Test and mutation runs I observed

Archived tree, warm image after `Pkg.instantiate()`. No other Julia process ran during either timing run
(`pgrep -fa julia` empty); a single-core `pdflatex` from the neighbouring documentation lane was resident throughout,
which is the whole of the load-average difference between the two.

```
RUN 1 (pdflatex resident, load avg 3.1)
MIPStarLambda load/precompile seconds = 0.329        (ungated)
TB0 test-body wall seconds = 36.31 (warning=45.0, hard_limit=60.0)     no warning
Test Summary:  | Pass  Total     Time
MIPStarLambda  |  275    275  1m41.2s               exit 0
EXTERNAL WALL  real 1m42.665s / user 1m41.997s

RUN 2 (quiet; no julia anywhere, load avg 4.1 from pdflatex alone)
MIPStarLambda load/precompile seconds = 0.334        (ungated)
TB0 test-body wall seconds = 38.086 (warning=45.0, hard_limit=60.0)    no warning
TB0 60 s test-body hard limit (measured 38.086 s) | 1 Pass
Test Summary:  | Pass  Total     Time
MIPStarLambda  |  275    275  1m43.1s               exit 0
EXTERNAL WALL  real 1m44.604s / user 1m43.969s
```

All 18 TB0 testsets execute under the default `TB0_TARGET=all`, **including** "5a. mutation-B formula separator" (5/5)
and "7. layout-driven sign block for m=2" (11/11) — r2's N2 and N3 reachability defects are gone.

Mutation runner (`MUTATION_JOBS=4 julia --project=. test/mutations/run.jl`), same tree, one of my probe processes
resident for part of the run:

```
29 baselines, all "=> OK":  field zero_basis occurrence c8 encoding pcp_separator c0_terms circuit witness_iff
                            layout_m2 nonprime certificate field_change nondegenerate pcp witness_iii  (TB0, 16)
                            + 7 TB1 + 6 TB2
MUTANT A ... M   (14)  => KILLED     MUTANT X1, X1b, X2, X3, X4 (5) => KILLED
MUTANT N, O, Q   (3)   => KILLED     15 TB1 mutants => KILLED       8 TB2 mutants => KILLED
MUTATION REGISTRY: killed=45/45 baselines ok=29/29 wall=372.11 s
isolated targeted mutations |    2      2  0.1s                     runner exit 0
```

Every one of the 45 lines is labelled `KILLED` (none `KILLED-BY-CRASH`, none `UNATTRIBUTABLE`, none `LOAD-ERROR`), and
every one of the 29 baselines exits 0. The TB0 block is 22 mutants (A B C D E F C8 G H I J K L M X1 X1b X2 X3 X4 N O Q).

**UNATTRIBUTABLE reproduction (brief obligation) — the runner does NOT credit a kill on a broken baseline.** On the
scratch tree I planted `error("PLANTED BASELINE BREAK (critic r3)")` as the first statement of testset 9 (target `c8`,
*unmutated*) and registered a semantically null mutant against that same target
(`fanout(circuit::Circuit) = circuit.fanout_counts` -> `... = (circuit.fanout_counts)`), then ran with
`MUTATION_FILTER=NOOP`:

```
BASELINE tb0_core.jl TB0_TARGET=c8 => BROKEN (exit=1, 5.21 s)
MUTANT NOOP planted_no_change target=c8 => UNATTRIBUTABLE (target exits 1 unmutated) (exit=1, 5.34 s)
isolated targeted mutations: Test Failed at test/mutations/run.jl:278   (baselines)
isolated targeted mutations: Test Failed at test/mutations/run.jl:279   (kills)
runner exit=1
```

The mutant process itself exited 1 printing `Some tests did not pass` — exactly the string r2's predicate accepted — so
the r2 runner would have printed `=> KILLED` here. Both files were then restored byte-for-byte (md5 verified) before the
§3 timing runs. **N2's permanent red test is real and works.**

---

## 4. My new mutations (semantic, not used in r1/r2; applied on copies, full `TB0_TARGET=all` runs)

| id | mutation | site | outcome |
|---|---|---|---|
| **NM1** | the `m=2` layout fixture's tables permuted: the satisfying all-ones block moves from `X1` to `X2` | `src/tb0.jl:75-76` | **KILLED** — testset 7, four assertions (`!iszero(expected)` `:608`, `isempty(remainder.terms)` `:611` with the two surviving monomials printed, `verify_certificate` `:612`, `!passed(pcpverifier(tf, wrong))` `:619`), exit 1 |
| **NM2** | `tseitin_occurrence_account` drops the output-literal term (`include_output && (… += 1)` -> `true && (… += 0)`), i.e. the *independent* side of N4's comparison | `src/ir/circuits.jl:242` | **KILLED** — testset 4c `:341`, the `:Tseitin` replay rejects with `:formula_occurrences` before `:coefficient_identity`, exit 1 |
| **NM3** | `ev_z`'s block-locality guard removed | `src/verifiers/pcp.jl:209` | **SURVIVED — exit 0, whole suite green** → **N9** (liveness verified separately) |
| **NM4** | the certified separator moves from `O2` to `O3` (`separator[7]` -> `separator[8]`) | `src/tb0.jl:13` | **SURVIVED — exit 0, whole suite green**; combined with mutant B, testset 5a passes 5/5 and **B survives** → **N8** |

Plus the probes of §0: the `d`-sweep and point-sweep of `change_field`, the borrowed-certificate probe, the cross-circuit
`:Tseitin` replay, and the `ev_z` guard positive control.

---

## 5. Elegance — three places the code is still more complicated than the mathematics

1. **`line_values` (`test/tb0_core.jl:259-288`) is a second, unanchored polynomial evaluator.** It computes the 128 line
   acceptances that C1 rests on and is never cross-checked against `evaluate`. (`boolean_cube_zero_report` is no longer in
   this class: witness (iii) anchors it against `phi_C`.) *Simplification:* one assertion,
   `line_values(p, base, j)[index_of(base[j])] == evaluate(p, base)`, or move `restrict_to_line` into
   `src/polynomials/` beside `evaluate`.
2. **Five module-level mutable caches memoise two fixtures** (`NONDEGENERATE_INTEGER_STATS`, `POLY_CACHE`, `BUILD_STATS`,
   `PROOF11_CACHE`, `C0_11_CACHE`, `:208-212`), and `tb0_build_nondegenerate_fixture` still wraps a hard-coded `788_032`
   plus a timing. *Simplification:* build the three fixtures once into `const`s at the top of the file and assert
   `788_032` directly in testset 6a; `src/tb0.jl` then loses its wrapper entirely.
3. **Two evidence-binding regimes for one certificate shape.** `build_pcp` binds children to captured sub-terms
   (`_bind_certificate`) while `change_field` binds them to the attached proof (`_pcp_upstream_nodes`); the second is
   strictly better (N10) and covers `:BuildC0` and `:ZeroBasis` already. *Simplification:* use the proof-addressed
   replays everywhere and keep `_bind_certificate` only for the genuinely upstream `:Tseitin` / `:ArithTseitin` /
   `:MultilinearExtension` nodes, whose terms are not fields of `PCPProof`. (The four char-2 fast paths of r2 §2d are
   unchanged and remain the fourth candidate.)

---

## 6. Per-claim decisions

### C1 — **HOLD** (one named missing step: N8)

Everything the proposed row asserts is true and I reproduced the substance independently: 128/128 line acceptances and
the 65,536-point cube for witness (i), `2`/`1` over `GF(8)` and `96`/`48` over `GF(2^11)` at the separator, both
certificates replaying, the field change re-certified. The retractions remain honest. **Missing step:** the row cites
mutant **B** as one of its five red tests, and N8 shows that B's discriminating power rests on `tb0_certified_points`'
unasserted choice of `O2` — moving it leaves the suite green and B alive. Add N8's three lines and C1 is promotable
verbatim as below. Two text errors are corrected regardless of N8: "re-derives `d=11`" (false — §0(5)) and
"`c_0(b_rho) != 0` for both witnesses" (asserted only for witness (ii) — §0(3)).

**AUTHORIZED row text (apply verbatim once N8 is fixed; no word added or removed):**

`| C1 | For the explicit real six-gate TB0 instance, both retained PCP proofs — witness (i) `([0,1],[0,0],[0,0],[0,0],[0,0])` and witness (ii) `([0,1],[0,1],[0,1],[0,1],[0,1])` — are checked by formal coefficient identities: `verify_certificate` replays all eleven CHECKED nodes of each proof's certificate, including `c_0=sum_j c_j zero(z_j)` with `r=0`; ten of the eleven replay the constructor's own sub-terms (that proof's `tf`, `F_arith`, `g_i`, `c_0`, decomposition) and only the root reads the `PCPProof` object. Witness (i)'s proof is accepted by `pcpverifier` at all 128 points of the 16 named `GF(8)` coordinate lines `S_j` through `b_rho` and its `c_0` vanishes at all 65,536 Boolean points; `c_0(b_rho) != 0` is asserted for witness (ii) in both fields (1 over `GF(8)`, 48 over `GF(2^11)`). At the separator `b_rho[O2<-rho]` `pcpverifier` accepts the honest view with `beta_0=2` over `GF(8)` (both witnesses; witness (i)'s as its stored certified view) and `beta_0=96` over `GF(2^11)` (witness (ii) via `ev_z`; witness (i) as the stored certified view of the re-certified `change_field` proof, whose four-node certificate replays the `def:pcp-proof` degree condition `max inddeg <= d` at the relabelled `d=11` — an upper-bound check, not a re-derivation of 11), where deleting `g_2-o_2` gives 1 and 48. No uniform `z` in `GF(2^11)^16` are sampled (tracked as `mipstar-lambda-yqw`). This is completeness evidence on named points and lines, not an exhaustive all-`z` or soundness claim. | TESTED | C2,C3,D1 | — | `test/tb0_core.jl:427-434` (lines, cube); `:372-385` (separators, both fields); `:438-493` (witness (i) replays, stored view); `:500-516` (witness (ii)); `:565-587` (field change); `test/mutations/run.jl` mutants B, J, L, X2, X3 (all KILLED) | `verdicts/tb0-r3.md` (PROMOTE on N8) |`

### C2 — **PROMOTE to `TESTED`**

N1 is discharged in substance, not by relabelling: witness (iii) goes through the real `build_c0` /
`zero_basis_decompose` at the DESIGN budget, and I reproduced `|c_0| = 18,620`, `|r| = 2` and the exact two-monomial
remainder from scratch (§0(1)) and again through the repository's own code. The `2^16` truth table, 128/896, 512, the
`vanishes_on_cube(c_0) == phi_C` comparison on all three witnesses, and `r = 0` with the coefficient identity for (i) and
(ii) are all asserted and red-capable; mutants A, I, K, N, O, Q are correctly owned and KILLED under passing baselines.
Only the pointer cells needed correction.

**AUTHORIZED row text (apply verbatim; no word added or removed):**

`| C2 | (Zero-basis certificate) For `c_0` built from `arith_q(tseitin(C) and w_out)` in TB0, the multilinearization rewrite produces `c_1,...,c_16` with `c_0=sum_i c_i zero(z_i)` as a formal coefficient identity and zero multilinear remainder for both retained satisfying witnesses (i) and (ii); for the unsatisfying witness (iii) `([0,0],[0,0],[0,0],[0,0],[0,0])` the same pipeline yields `|c_0|=18,620`, a two-monomial remainder `r != 0` and a failing coefficient-identity replay. Exhaustive Boolean truth tables over all `2^16` assignments check the circuit/Tseitin/`F_arith` correspondence; the 1,024-witness loop is a clause-relation count (512 satisfying, derived from the 128 present clauses, not a remainder computation); and on the three retained witnesses `c_0` vanishes on the `2^16` Boolean cube exactly when `phi_C` holds. The general correspondence remains CITED. | TESTED | D1 | — | `test/tb0_core.jl:153-175` (`2^16` table); `:179-199` (clause-relation count); `:325-360` (witness (iii), cube vs `phi_C` on (i),(ii),(iii)); `:413-419`, `:500-516` (`r=0` and identity, (i) and (ii)); `test/mutations/run.jl` mutants A, I, K, N, O, Q (all KILLED) | `verdicts/tb0-r3.md` (PROMOTE) |`

### C3 — **RE-AFFIRM `TESTED`** (the r2 withholding is lifted)

The witness-(i) certificate sentence now has its machine evidence: `:414-418` asserts `r = 0`, the coefficient identity,
`findall(isempty, quotients) == [2,3,4,7,8,9,10]`, nine nonzero and `max inddeg = 6`, and `:476` runs all eleven replays.
I recomputed every one of those facts from scratch (§0(1)). Witness (ii)'s vectors, exact dependencies and
`verify_certificate` are at `:500-516`, `:518-531`. Mutants E, F, C8, Q, X4 are all correctly owned and KILLED.

**Statement, status `TESTED` and depends-on stay exactly as committed at `claims/CLAIMS.md:10` — no word changes.** The
only permitted edit is the `where-tested` cell, which must become: ``test/tb0_core.jl:629-640`` (occurrence/degree
equality, structural and actual); ``test/tb0_core.jl:413-419`` (witness (i): `r=0`, coefficient identity, quotient split
`[2,3,4,7,8,9,10]`, nine nonzero, max inddeg = 6) and ``:476`` (all eleven CHECKED replays via `verify_certificate`);
``test/tb0_core.jl:500-516``, ``:518-531`` (witness (ii) support, vectors, `r=0`, identity, `verify_certificate`, exact
dependencies); ``test/mutations/run.jl`` mutants E, F, C8, Q, X4 (all KILLED). The `verdict` cell becomes
``verdicts/tb0-r1.md`` (PROMOTE); ``verdicts/tb0-r3.md`` (re-affirmed).

### C8 — **RE-AFFIRM `TESTED`**

Substance independently re-confirmed for the third time, and this round from a fresh implementation of the F1 account as
well as of the arithmetization: TB0's occurrence vector `(2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)` with equality on all sixteen
coordinates, and the two-gate vector `(2,2,2,4,3)` with `deg_{w1} = 4 > 2` and `|F_arith| = 49`. Testsets 8 and 9 run
green in the default suite; mutants E (target `occurrence`) and C8 (target `c8`) are KILLED under passing baselines.

**Authorized row text: the C8 row exactly as committed at `claims/CLAIMS.md:17`, unchanged — no word added or removed.**
The `where-tested` cell as re-pointed by the orchestrator (`test/tb0_core.jl:629-640`; `test/tb0_core.jl:643-653`;
`test/mutations/run.jl` mutants E, C8 (both KILLED)) is **verified correct** and stands. The `verdict` cell becomes
``verdicts/tb0-r1.md`` (PROMOTE, scoped); ``verdicts/tb0-r2.md`` (re-affirmed); ``verdicts/tb0-r3.md`` (re-affirmed).

---

## 7. Trajectory

r1: 7 MAJOR / 9 MINOR / 7 NOTE. r2: 5 MAJOR / 2 MINOR. r3: **1 MAJOR / 4 MINOR / 5 NOTE, 0 FATAL** — and, unlike r2, the
single MAJOR is **not** a regression introduced by the repair: it is a pre-existing fragility that only became visible
once mutant B was made attributable at all. Every one of r2's five MAJORs is discharged in substance, each verified by
fresh computation rather than by reading the response table: witness (iii) is a real object with a real nonzero
remainder, the runner refuses to credit kills on broken baselines (I broke one and watched it refuse), both previously
unreachable testsets now run and both previously surviving layout mutations now die, all eleven replays run on both
proofs with a `:Tseitin` node that I could falsify from either side, and the `GF(2^11)` proof carries a four-node
certificate that is better term-bound than the constructor's. The arithmetic remains impeccable: `18,620`, `2`, `33,432`,
`37,240`, `170,968`, `534,912`, `788,032`, `148,176`, `2,370,816`, both degree vectors, the seven-zero/nine-nonzero
split, `1`/`48`, `2`/`96`, `128`, `65,536`, `(2,2,2,4,3)` and `minimal_checkable_odd_k = 11` all reproduce against a
from-scratch implementation. The remaining work is three lines in testset 5a (N8), one `@test_throws` (N9), and three
documentation sentences (N11, N12).

VERDICT: FAIL(N8)
