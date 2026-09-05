# Verdict — TB4 r2 (critic, Opus): adjudication of brief 72's repair of `verdicts/tb4-r1.md`

Target: the ARCHIVED tree at `8af9073`, extracted with `git archive 8af9073 | tar -x -C
…/scratchpad/critic-tb4-r2/tree` and instantiated there. Nothing in the live tree was read except
`claims/CLAIMS.md`; nothing outside this file was written; no state-changing git command was run.
Every recomputation below was done on that copy or from the ground-truth TeX, never from memory.

**VERDICT LINE AT THE BOTTOM.** Objections: **2 MAJOR, 3 MINOR, 2 NOTE** (r1: 5 MAJOR, 9 MINOR,
4 NOTE). Adjudication: **11 ACCEPTED, 4 PARTIAL, 0 REJECTED** across O1–O14 + N1–N4.

---

## 0. Runs, walls, load, governor

`powerprofilesctl get` → **performance** for every run. The box is an i7-1365U (12 threads).
**This box was NOT quiet for most of the session**: other agents held 7–16 `julia` processes,
including a *second* `test/mutations/run.jl` that overlapped mine (`/tmp/jl_sglw55` and
`/tmp/jl_mkZT9U` both present in `ps`). Walls are reported with that contamination named.

| run | wall | result | `uptime` before / after |
|---|---|---|---|
| cold `Pkg.instantiate()` + precompile | `real 2m26,375s` (`MIPStarLambda` 131.7 s; another process was precompiling the same package) | exit 0 | `13:49:05 load 1,45 3,09 3,39` / `13:51:48 load 4,04 3,29 3,40` |
| suite #1 (light contention: one other `test/runtests.jl` running) | `real 1m47,804s`, exit 0 | **2393/2393**; TB0 body **17.875 s** (gate 60); **TB4 body 6.100 s, calibration kernel 0.1669 s, ratio 36.6 (gate 42.0)**; TB4 include 6.494 s; TB5 24.85 s | `13:51:55 load 3,50 3,19 3,36` / `13:53:42 load 2,22 2,84 3,21` |
| `test/mutations/run.jl` | `real 16m29,256s`, exit 0 | **`MUTATION REGISTRY: killed=157/157 baselines ok=64/64 wall=988.98 s`**; all 26 TB4 mutants KILLED, all 9 TB4 baselines OK | `13:54:04 load 1,46 2,61 3,13` / `14:10:34 load 9,66 9,88 7,54` |
| critic mutants CRITIC-3 / -4 / -5 (full TB4 file, `TB4_TARGET=all`, 8/8 testsets each) | 13.4 s / 17.0 s / 8.3 s | **SURVIVED / SURVIVED / KILLED** | `14:11:11 load 7,26 9,26 7,41` / `14:11:50 load 6,67 8,84 7,35` |
| suite #2 **under 8 `yes` hogs + 15 julia processes** | `real 5m09,391s`, exit 0 | TB0 body **46.155 s** (its own 45 s warning crossed); **TB4 body 23.452 s, kernel 0.6616 s, ratio 35.4** | `14:12:32 load 9,87 9,31 7,57` / `14:17:42 load 14,71 13,02 9,70` |
| suite #3 **quiet** (no other julia) | `real 1m38,286s`, exit 0 | **2393/2393**; TB0 body **16.112 s**; **TB4 body 5.497 s, kernel 0.154 s, ratio 35.7**; TB4 include 5.86 s | `14:20:38 load 1,90 7,67 8,18` / `14:22:16 load 1,17 5,77 7,44` |
| critic scripts (independent encoder, tree walk, chain/fuel replays) | ≈ 40 s total | §2 | load 1,2–7 |

The registry wall (988.98 s) exceeds the proposer's 709.43 s only because a second registry run of
another lane overlapped mine end to end; every disposition matches theirs.

**TB4 calibration kernel and ratio, as the suite prints them:** `0.154 s / ratio 35.7` (quiet),
`0.1669 s / ratio 36.6` (light contention), `0.6616 s / ratio 35.4` (heavy load). Gate `42.0`.

---

## 1. Adjudication of every r1 row

| r1 row | severity | disposition | basis (recomputed on the copy / from the TeX) |
|---|---|---|---|
| **O1** LevelChain ORDER conjunct not red-capable | MAJOR | **ACCEPTED** | §2(1). The certificate's own replay now refuses the swapped chain; `M-order-blind` = CRITIC-2 verbatim, KILLED (20.69 s, baseline `tb4_levels` OK). |
| **O2** ℓ = 9 unpinned | MAJOR | **ACCEPTED (scoped)** | §2(2). Pinned as a certificate FACT asserted by the test file; `verify_certificate` still refuses at `nine_level` under both pristine and mutant, so no verification OUTCOME distinguishes them. `M-ell-from-input` = CRITIC-1 verbatim, KILLED. The scoping sentence must survive into C11. |
| **O3** inlined compressor stub undisclosed | MAJOR | **PARTIAL** | §2(3). The node, the 46/376 numbers and the (b) branch assertion are all present and `M-stub-undisclosed` is KILLED — but *which* compressor the disclosure names is unowned: **NEW-2**. |
| **O4** `FuelBound` ungraded construction change | MAJOR | **PARTIAL** | §2(4). `SOURCE_REPAIR(:HaltDeciderFuelBound)`, the §F row, the "enforced by construction, not measured" wording and `M-fuelbound-undisclosed` (KILLED) are all in place — but the citation is **wrong** and the wrong range is pinned by a test: **NEW-1**. |
| **O5** DESIGN §5.6 unattainable red criterion | MAJOR | **ACCEPTED** | §5.6 now reads "require the origin sequence to differ from (Introspect, AnswerReduce, Repeat); at ℓ = 5 both rules give 7, so levels alone cannot witness the swap" — brief 24 MP (2) verbatim. |
| **O6** §F lockstep (three defects) | MINOR | **PARTIAL** | (a) `Compressor` row rewritten with `lambda : P{Nat}` + the ground-truth licence; (b) `Psi_{M,L}`/`D_{M,L}`/`S_L` renamed in all five rows (no residual match); (c) the row I named (`lambda`, line 169) has its third cell. Residue: the `Level` row still has 3 pipes — **NEW-4**, and my r1 sentence "every other row in the table has 4" was itself wrong (`git show 278b1ac:docs/definitions.md` has two 3-pipe rows, 152 and 169). |
| **O7** Introspect contract mis-scopes `thm:introspection` | MINOR | **ACCEPTED** | All three hypotheses prefixed "(completeness/soundness only)", conclusions marked "(unconditionally)", `ell_level` source widened to L784–L803; DESIGN §1.6 bullet 1 rewritten; `M-intro-unscoped` KILLED. Re-derived from the TeX: gt-08:L789–797 unconditional, L801–803 conditional. I also checked the two contracts I did *not* object to and they are right: `thm:ar` (gt-10:L2082–L2085 — "suppose that V satisfies … Then V^ar is max{ℓ+2,5}-level, has time complexity bounds") makes the level/time conclusions conditional, so AR's unscoped hypotheses are correct; `thm:repetition` (gt-11:L235–L236) conditions everything on normal form and puts `TIME_D ≤ (λn)^τ` inside `enu:pr-completeness` only, exactly as `REPEAT_CONTRACT` scopes it. |
| **O8** N14 justification and grade | MINOR | **ACCEPTED** | `:UpstreamEvidence`'s CHECKED content is the identity anchor alone; `[CONSTRUCTED] UpstreamReproduction` is its second child (TB3 (f)'s `children[1] == :Pad5` preserved); the source comment now states that `TseitinFormula.program` is mutable in place and that a tampered formula is caught by `:PCPVerifier`'s replay. `M-reproduction-undisclosed` KILLED. |
| **O9** sampler independence is a symbol-set assertion | MINOR | **ACCEPTED (in the form TB4 supports)** | §2(5). New testset (h): 71 trace lines, exactly 1 differing line, both hashes critic-reserialized; `M-independence-leak` KILLED. The byte/hash form is discharged one rung up (TB5 C13: identical `S^rep` fnv1a64 `925f2085c0763b30` for byte-distinct deciders). |
| **O10** surrogate is a sibling | MINOR | **ACCEPTED** | §2(6). My own tree walk is stronger than the test's: *no* node under `:AnswerReduce` outside the contract nodes lies outside the surrogate. `M-surrogate-sibling` KILLED. |
| **O11** two CITED leaves unlocatable | MINOR | **ACCEPTED as demanded** | `:Detype` → `gt-06-types.tex:L445-L475 (lem:detyping-verifiers)` (label at 445 ✓), `:Oracularization` → `gt-09-oracularization.tex:L34-L86 (sec:orac-def)` (label at 34 ✓); test (d) greps every CITED node carrying source/lines/label (7 of 9). Residue: **NEW-5** — two *other* CITED leaves are still display-only, and my r1 count of "two of the nine" was wrong (it was four). |
| **O12** off-by-one citation range | MINOR | **ACCEPTED** | `L239-L243`; `\label{enu:pr-completeness}` at gt-11:**239** ✓. The new (e) grep covers 12 hypothesis labels; I verified all 12 independently: `def:lambda` 642 ∈ 641:653 (×4), `thm:introspection` 785 ∈ 784:803, `eq:ar-params-1` 1814 and `eq:ar-time-assumption` 1820 ∈ 1811:1822 (×2 each), `enu:pr-completeness` 239 ∈ 239:243, `thm:compression` 27 ∈ 27:41 (×2). `M-offbyone` KILLED. |
| **O13** body over budget and unenforced | MINOR | **PARTIAL** | §3. The ratio gate is real and works; the 6 s revision is documented; but the threshold is derived from the wrong kernel regime and the written budget is again exceeded in-suite — **NEW-3**. |
| **O14** `specialize` guard unowned, replay unbound | MINOR | **ACCEPTED** | `specialize`'s node is `_bound_replay`-anchored and recomputes `substitute(p, bindings)` by `program_equal`; (a) asserts the open-replacement `ArgumentError` and that a byte-identical twin `Quoted` is refused `:certificate_binding` at `:Specialize`. `M-specialize-open` (my text verbatim) and `M-specialize-unbound` KILLED. Bonus not demanded: `fix_specialize`'s own replay now recomputes `Fix(substitute(template, bindings))` too. |
| **N1** part2a §10 stale | NOTE | **ACCEPTED as a merge proposal** (analytic lane, correctly untouched) | Re-verified from my own encoder: `Fix` serializes as tag `0x24` ‖ a 4-byte child count and **no** sort annotation, so `c_fix = 5` **bytes**; and DESIGN §1.1 carries `fuel − c_Y`, `c_Y = 3`. The proposer's MP (2) is **AUTHORIZED verbatim** for the analytic lane. |
| **N2** `bind_parameter` naming fact | NOTE | **ACCEPTED** | Carried into the proposed C11 sentence, correctly. |
| **N3** `:LevelChain` CHECKED over constructed data | NOTE | **ACCEPTED; MP (3) AUTHORIZED** | §4. DESIGN §1.6's invariant table still grades "CL levels | CONSTRUCTED". |
| **N4** `AnswerReduce`/`Repeat` namespace | NOTE | **ACCEPTED as unchanged** | TB5's `Repeat(::ExecutableRepeat, …)` coexists by dispatch; the suite's "TB5 Repeat as a CompressStage swappable for TB4's stub" testset is 8/8. |
| r1 §7 TB5 readiness gaps A, B, G1 | — | **CLOSED** | `abstract type AbstractStageVerifier`, `StubVerifier <: AbstractStageVerifier`, `_VERIFIER_INPUT = Union{Verifier,AbstractStageVerifier,VerifierDescription}`, `params::NamedTuple` on all three stage methods and `stage_params` on `Compress`; `src/descriptions/**` supplies the description layer. Trap (a) survives: `Compress`'s default `stages=tb4_stages()` still rebuilds the fixture per call, and (f)/(h) correctly pass explicit stages. Trap (c) done. |
| r1 §5 MP-2 (i), the circular §F justification | — | **ACCEPTED** | DESIGN §1.1 and the §F `Compressor` row now cite `fig:halt_f` step 3 + `lem:dhalt-values` (L502–L519, label at 502 ✓) + `lem:compress-independent-samplers` (L108–L118, label at 109 ✓), and record the decider-only `Compressor` as a *named, deliberate narrowing*. That is exactly the fix demanded. |

---

## 2. Independent recomputations

**(0) `COMPRESS_STUB` = 46 of 376 bytes, from my own encoder.** I re-wrote the serializer from
DESIGN §1.1's codec paragraph plus the tag table over plain nested tuples, importing nothing from
`MIPStarLambda` (`…/critic-tb4-r2/indep.jl`), and also hand-derived every figure before running it:

```
critic |Hole machine| = 31   |machine literal| = 31
critic |Hole lambda|  = 22   |nat(1024)|      = 15
critic |Psi template| = 385
critic |term(Fix)|    = 376
critic |COMPRESS_STUB| = 46 of 376 term bytes = 12.2%
critic |TRIVIAL_DECIDER description| = 33
critic |D_{M,lambda}| = 388 bytes    fnv1a64 = dbf2c0815358657f
critic looping |D|    = 388 bytes    fnv1a64 = 2b9de4fb8ea9b2f9
size law: 385 - 31 - 2*22 + 31 + 2*15 + c_fix(5) = 376
```

Hand check of the 46: `Prim(true,Concrete(1),())` = 1+2+5+4 = 12; `Lambda(5,·)` = 1+4+4+12 = **21**;
`Quote(·,:Decider)` = 1+(4+7)+(4+21) = **37**; `Lambda(2,·)` = 1+4+4+37 = **46**. All of the tree's
numbers are confirmed; the certificate's `stub_bytes=46, term_bytes=376` facts are true.

**(1) O1 — the swapped chain is refused by the node's own replay. CONFIRMED.**

```
origins  = [:Introspect, :Repeat, :AnswerReduce, :Compress]
levels   = [9, 5, 7, 9]        (pristine chain = [9, 5, 7, 9])   <- F-a still holds
_level_chain_ok(swapped) = false
LevelChain replay(swapped): passed=false  rule=level_chain  actual=[9, 5, 7, 9]
```

**(2) O2 — the 5-level input. CONFIRMED, with the scope r1 anticipated.**

```
ell_level: FAIL | (completeness/soundness only) V is an ell-level verifier: levels = 5, ell = 9 => FAIL
chain = [5, 5, 7, 9]     verify_certificate refuses at :nine_level
```

`_level_chain_ok` computes its `expected` from the constant `COMPRESS_LEVELS`, and
`introspect_levels(ℓ) = 5` for every ℓ, so the chain check cannot see the difference either; only
the `ell_level` FACT can, and the test file is what reads it. The certificate's *verdict* is
`:nine_level` under both pristine and mutant. That is the strongest witness TB4 admits and it is
honest, but C11 must say so.

**(3) O3 — the disclosure node. CONFIRMED as present, DEFECTIVE as owned (see NEW-2).**

```
CompressStubInTerm  grade=ASSUMED  facts=(:display,:compressor,:stub_bytes,:term_bytes)
  stub_bytes=46  term_bytes=376  compressor=COMPRESS_STUB
```

**(4) O4 — the `:HaltDeciderFuelBound` facts against the TeX. The node is right, the citation is
wrong.** Numbering `gt-12-compression.tex` with `grep -n ""`:

```
448:    \item Accepts if the decider $\decider^\compr$ of verifier
449:      $\verifier^\compr$ accepts $(n, x, y, a, b)$.
450:    \end{enumerate}
451:  \end{gamespec}
452:  \caption{Description of Turing machine $\cal{F}$.
453:    The Turing machines $\ComputeSampler$ and $\Compress$ are given in
455:  \label{fig:halt_f}
```

fig:halt_f **step 5 is L448–L449**. The cited `L451-L453` is `\end{gamespec}` plus two caption
lines: it contains neither step 5 nor `\label{fig:halt_f}`. `lem:lambda` is fine: its label is at
gt-12:**570**, inside the cited `L570-L638`, and its proof does conclude λ-boundedness (hence
`TIME_{D^halt}(n) ≤ n^λ`) at `λ = ⌈max{λ₀,λ₁,λ₂}⌉` (L633), so the *substance* of the node is
correct. Only the pointer is wrong — and my own r1 O4 wrote `L451-L453` first, so this error is
mine before it is the proposer's. See NEW-1.

```
HaltDeciderFuelBound  grade=SOURCE_REPAIR  source=gt-12-compression.tex  lines=451:453  label: absent
```

**(5) O9 — two byte-distinct inputs. CONFIRMED.** The suite prints
`TB4 two verifiers: 71 trace lines each; differing lines = 1 (the input decider's Quote:
dbf2c0815358657f vs 2b9de4fb8ea9b2f9); dependency symbols equal`, and **both hashes are the ones my
own encoder produced** (§2(0)), so the one differing line is exactly the input decider's identity
and nothing else in 71 lines depends on `V`.

**(6) O10 — the surrogate is the ancestor of every fixture node. CONFIRMED, more strongly than the
test asserts.** My walk over the real tree:

```
rules under :AnswerReduce not under the surrogate (excluding the contract nodes): Symbol[]
surrogate children: [:Detype, :PCPProof]
CHECKED under the surrogate: 20 of the tree's 30
rules under the surrogate NOT in the test's 11-name list: :Oracularization, :TypedPCPSampler,
  :PCPCLDatatype, :PCPCopy6CoordinateScalar, :AnswerReduceHypotheses, :PCPVerifierFixedFormula,
  :PCPGameOtherwiseFallthrough, :AnswerReduceQuantumContract, :Quote, :CookLevinGeneral,
  :RawAnswerBlocks, :PerIndexEqualityGadgets, :UpstreamReproduction, :ArithTseitin,
  :MultilinearExtension, :BuildC0, :ZeroBasis
```

**(7) Census and fuel. CONFIRMED.** 70 nodes = CONSTRUCTED 7 + CHECKED 30 + CITED 9 + ASSUMED 19 +
SOURCE_REPAIR 5, matching the proposed C11 exactly. `eval` of `D_{M,λ}` at `u = (2,(),(),(1),(0))`:
halting `used=12 result=Value(true)`, looping `used=91 result=Value(true)` — the `FuelBound(2,1024)`
delimiter never binds, as both r1 and the proposed row say.

**(8) Citation hygiene, audited exhaustively.** Of the 9 CITED nodes, 7 carry `source`/`lines`/
`label` and are grepped; `:AnswerReduceQuantumContract` and `:CookLevinGeneral` are display-only.
Of the 5 SOURCE_REPAIR nodes, only `:HaltDeciderFuelBound` carries machine-readable citation facts —
and it carries no `label`, so it falls outside the (d) filter
(`haskey(:source) && haskey(:lines) && haskey(:label)`) and outside the (e) hypothesis-source grep.
The one node the repair round created is precisely the one the repair round's own citation
discipline does not cover.

---

## 3. The ratio gate — RULING

**Is a clock-calibrated ratio an honest replacement for the 5 s wall budget? YES, and I have direct
evidence for it.** I ran the whole suite three times on the same box under load averages 1.9, 3.5
and 9.9→14.7 (8 `yes` hogs plus 15 julia processes):

| condition | kernel | TB4 body | **ratio** | TB0 body (uncalibrated 60 s wall gate) |
|---|---|---|---|---|
| quiet (load 1.9) | 0.1540 s | 5.497 s | **35.7** | 16.112 s |
| light contention (load 3.5) | 0.1669 s | 6.100 s | **36.6** | 17.875 s |
| heavy load (load 9.9→14.7) | 0.6616 s | 23.452 s | **35.4** | **46.155 s** — crosses its own 45 s warning |

A **4.3× machine slowdown moved the ratio by 3.4 %** while it moved TB0's plain wall by 2.9× to
within 23 % of a hard `@test`. The mechanism works, it is the right answer to r1 O13, and TB0's own
gate is now the fragile one. `M-gate-uncalibrated` is genuinely KILLED (registry, 3.54 s).

**The 6 s revision: ACCEPTED as an honest, documented budget revision** — DESIGN §5.6 states it,
gives the reason (the O1/O2/O9 witnesses add two `Compress` calls), and my quiet measurement
(5.497 s) and the proposer's (5.348 s) are both under it.

**But the calibration constant is derived from the wrong regime — NEW-3.** `TB4_RATIO = 42` is
`6 s ÷ 0.14 s`, the **standalone** kernel rate, while the gate *only ever runs in-suite*
(`TB4_IN_SUITE = isdefined(Main, :TB0_TARGET)`), where the kernel measures 0.154–0.19 s. The
enforced in-suite body budget is therefore **6.5–8.0 s, not 6 s**: my light-contention run measured
a **6.1 s body — over the written budget — and passed at 36.6 / 42**. That is precisely the failure
r1 O13 named ("do not silently exceed a written budget"), now hidden one level of indirection
deeper. DESIGN §5.6's reference figure ("the in-suite ratio measured 32") is also not reproducible
here: three runs spanning a 4.3× speed range all give **35.4–36.7**, leaving 13–15 % headroom to the
gate rather than the ~30 % the documented figure implies.

Two further honest caveats about the mechanism, for the record. (i) `tb4_calibration_kernel` is
defined in a file carrying `Base.Experimental.@optlevel 0`, so the calibration measures unoptimised
loop scaffolding around optimised package arithmetic, while the body is allocation- and
GC-dominated; the three data points show this does not matter in practice, but the equivalence is
empirical, not structural. (ii) The registry's `tb4_gate` target has an **empty body**
(`BASELINE tb4_compress_ir.jl TB4_TARGET=tb4_gate => OK (exit=0, 3.59 s)`), so the one mutant that
owns the gate kills on `elapsed / 1e-9`, not on anything about a slow body; nothing in the corpus
demonstrates the gate firing on the quantity it exists to bound. That is a gap in ownership, not an
error.

---

## 4. New objections

### NEW-1 (MAJOR) — `SOURCE_REPAIR(:HaltDeciderFuelBound)` cites the wrong lines, and a test pins the error

*Location*: `src/compress.jl:154` (docstring), `:164` (display), `:165` (`lines=451:453`);
`docs/definitions.md:223` (§F anchor cell); `test/tb4_compress_ir.jl:293`
(`@test occursin("gt-12-compression.tex:L451-L453", repair[1].facts.display)`); and the C11 MERGE
PROPOSAL, which repeats it.

*Computation*: §2(4). fig:halt_f step 5 is **L448–L449**; `L451-L453` is `\end{gamespec}` and two
caption lines, and does not even contain `\label{fig:halt_f}` (L455). Two mutation experiments on
the copy, both on the full TB4 file with `TB4_TARGET=all` (8/8 testsets):

| id | mutation | outcome |
|---|---|---|
| **CRITIC-3** | `source="gt-12-compression.tex", lines=451:453))` → `… lines=1:1))` | **SURVIVED** (exit 0, 13.4 s) |
| **CRITIC-5** | display `…step 5 (gt-12-compression.tex:L451-L453) accepts iff` → `…(gt-12-compression.tex:L448-L449)…` | **KILLED** at `tb4_compress_ir.jl:293` |

So the machine-readable `lines` fact is owned by nothing at all, and the corpus actively *rejects
the correct citation*. This is the O12 defect class — a cited range that excludes its own subject —
reintroduced by the O4 repair, in the one node whose whole purpose is to point at ground truth, and
the O11/O12 greps miss it because they filter on `haskey(:label)` and on hypothesis sources.

*FIX DEMAND*: set `lines=448:449` and the display/docstring/§F anchor to
`gt-12-compression.tex:L448-L449 (fig:halt_f step 5)` — or, if a `label` fact is wanted, widen to
`426:456`, which contains `\label{fig:halt_f}` at 455 — in all five sites at once
(`src/compress.jl` ×3, `docs/definitions.md:223`, `test/tb4_compress_ir.jl:293`); extend the (d)/(e)
grep to every node of ANY grade carrying `source`+`lines` (label optional: grep the range's
existence and, when a label is present, the label); and register CRITIC-3 verbatim as
`M-fuelbound-unlocated`.

*SURVIVING WEAKER STATEMENT*: the SOURCE_REPAIR's substance is correct and independently verified —
fig:halt_f step 5 imposes no budget, and `TIME_{D^halt}(n) ≤ n^λ` is `lem:lambda`'s conclusion
(gt-12:L570–L638, λ = ⌈max{λ₀,λ₁,λ₂}⌉ at L633) — only its pointer is off by three lines, and no
other citation in the tree is wrong.

### NEW-2 (MAJOR) — which compressor `CompressStubInTerm` names is unowned

*Location*: `src/compress.jl:197-199` (the `compressor` ternary in `halting_verifier`);
`test/tb4_compress_ir.jl:208-218` (the (b) assertions).

*Computation*: **CRITIC-4** swaps the first two branches of the ternary, so that
`compress === COMPRESS_STUB` is reported as `"COMPRESS_IDENTITY, (pair, lambda) -> snd_code(pair),
the input decider's own code"`. Full TB4 file, `TB4_TARGET=all`: **8/8 testsets, exit 0 —
SURVIVED** (17.0 s). The tree then prints

```
[ASSUMED] CompressStubInTerm | the Compress program inlined in D_{M,lambda} is COMPRESS_IDENTITY,
  (pair, lambda) -> snd_code(pair), the input decider's own code: 46 of 376 term bytes; …
```

— a materially *false* and materially *stronger* statement (a non-constant compressor returning the
input decider's own code, rather than a 46-byte constant), and every one of the four `occursin`
guards still passes: `"COMPRESS_STUB"`, `"constant"` and `"COMPRESS_IDENTITY"` all appear in the
node's fixed tail sentence regardless of the branch taken, and `"46 of 376"` is unaffected. The
`compressor` symbol fact (`:COMPRESS_STUB`) is read by nothing. So the disclosure that O3 demanded
can name the wrong object, and the corpus is blind to it.

*FIX DEMAND*: assert the identity, not the substring — `@test stub_nodes[1].facts.compressor ==
:COMPRESS_STUB` and `@test occursin("is COMPRESS_STUB, the constant", …)`, plus the matching
positive case built with `compress=COMPRESS_IDENTITY` asserting
`facts.compressor == :COMPRESS_IDENTITY`; register CRITIC-4 verbatim as `M-stub-misnamed`.

*SURVIVING WEAKER STATEMENT*: the node's *numbers* are owned and true (46 of 376, both
critic-recomputed; `M-stub-undisclosed` KILLED proves the node's presence is required, and (b)
proves the branch evaluates to `Code(TRIVIAL_DECIDER)`); only the English naming which of the two
compressors is inlined is unattested.

### NEW-3 (MINOR) — the gate's threshold is calibrated against a regime the gate never runs in

*Location*: `test/tb4_compress_ir.jl:17-36` (`TB4_RATIO = 42.0`, and the comment deriving it from
"0.14 s standalone"); `docs/DESIGN.md` §5.6 ("42 (6 s at the standalone kernel rate; the in-suite
ratio measured 32)").

*Computation*: §3. The gate runs only when `TB4_IN_SUITE`, where the kernel is 0.154–0.19 s, so 42
enforces a **6.5–8.0 s** body against a **6 s** written budget; my light-contention run measured
6.100 s and passed. The documented in-suite reference ratio 32 is not reproducible: 35.7 / 36.6 /
35.4 across load 1.9 / 3.5 / 14.7.

*FIX DEMAND*: derive `TB4_RATIO` from the **in-suite** kernel with a stated headroom (e.g.
`ceil(1.25 × max observed in-suite ratio)` = 46, or lower the body under 5.2 s and set 36), and
state in DESIGN §5.6 the *enforced* in-suite body budget the constant corresponds to, alongside the
observed ratio range and the number of runs it came from. Add a body-inflating mutant (e.g. an extra
`for _ in 1:12; tb4_calibration_kernel(); end` inside a testset) so the gate is owned on the quantity
it bounds, not only on its denominator.

*SURVIVING WEAKER STATEMENT*: the calibrated ratio is a genuine improvement on a wall clock — under
a 4.3× slowdown it moved 3.4 % where TB0's wall gate moved 2.9× — and the 6 s revision is honest and
met on a quiet box; only the constant's derivation and the documented reference figure are off.

### NEW-4 (MINOR) — one `definitions.md` §F row still has three pipes

*Location*: `docs/definitions.md:152`, the `Level` row.

*Computation*: `awk '/^\|/ {n=gsub(/\|/,"|"); if (n!=4) print}'` over §F: the `Level` row has 3
pipes, i.e. no ground-truth-anchor cell — the same column-contract violation O6(c) named. `git show
278b1ac:docs/definitions.md` shows lines 152 **and** 169 both had 3 pipes at r1, so my sentence
"every other row in the table has 4" was wrong and the proposer fixed exactly the row I named.

*FIX DEMAND*: give the `Level` row its anchor cell (`gt-04-cl.tex` for `level(V)`, or
`gt-05-games-normalform.tex:L619-L635` for the ℓ-level verifier), and add a one-line CI/test check
that every §F/§G data row has four pipes so the class cannot recur.

### NEW-5 (MINOR) — two CITED leaves still carry no locatable citation

*Location*: `:AnswerReduceQuantumContract` and `:CookLevinGeneral` — facts `(:display,)` only.

*Computation*: §2(8). O11 named `:Detype` and `:Oracularization` and both are fixed; my r1 count of
"two of the nine" was simply wrong — four of the nine were display-only. The new (d) filter
(`source && lines && label`) silently excludes the remaining two rather than failing on them.

*FIX DEMAND*: give both nodes `source`/`lines`/`label` (TB2 and TB3 lanes) and turn the (d) filter
into a completeness assertion — `@test all(haskey(n.facts,:source) for n in CITED nodes)` — so an
unlocatable CITED leaf fails instead of being filtered out.

### Notes

**N5 (NOTE, orchestrator)** — `claims/CLAIMS.md` C11 is stale against `8af9073` in three places: it
says the certificate is "67 nodes (CONSTRUCTED 6 … ASSUMED 18, SOURCE_REPAIR 4)" (now 70 / 7 / 19 /
5), "13/13 KILLED" (now 26/26), and "NOT red-capable: the fig:compress ORDER conjunct of
`:LevelChain` and the literal ℓ = 9" (both now owned). Lockstep (law 2) requires the row and the code
to move together; either apply the row authorised in §5 in the same commit as the NEW-1 fix, or mark
the row stale until then. Not the proposer's lane — brief 72 correctly forbade touching CLAIMS.

**N6 (NOTE)** — `docs/index.html` and `docs/tutorial/compress-explained.html` still quote
`1364 / 1364` assertions and `119 / 119` mutants against a tree at 2393 and 157, and describe TB4 as
`FAIL(O1–O5) at r1`. This under-claims, so it is safe, but summary documents are exactly where the
ratchet is audited; refresh them when this round closes.

---

## 5. Per-claim decisions

### C11 — **AUTHORIZE a strengthened row, in my own wording, CONDITIONAL on the NEW-1 fix**

The proposer's proposed row is accurate on everything I checked except that it repeats the false
citation `gt-12-compression.tex:L451-L453` and asserts the two things NEW-1/NEW-2 show are unowned.
The row below is the proposer's, corrected and re-scoped; it may be pasted **only in the same commit
that lands the NEW-1 correction** (otherwise the row would cite L448–L449 while the code, §F and the
test pin L451–L453, which is the lockstep failure this method exists to catch). Until then C11 keeps
the r1 weaker row. The proposer may not strengthen a word of the text below.

> | C11 | (Compress skeleton — composition, contracts and the quoted fixed point) On the TB4 fixture `V = (S_λ stub, D_{M,λ})` at λ = 1024, with `\|D_{M,λ}\| = 388` bytes and fnv1a64 `dbf2c0815358657f` (critic-reserialized independently from the DESIGN §1.1 codec in `verdicts/tb4-r1.md` §1 and again in `verdicts/tb4-r2.md` §2), `Compress = Repeat ∘ AnswerReduce ∘ Introspect` builds the three ASSUME/PROVE contracts in fig:compress order (`gt-12-compression.tex:L75-L98`) with level chain 9→5→7→9 (`introspect_levels(9)=5`, `answer_reduce_levels(5)=max(7,5)=7`, `repeat_levels(7)=9`). The ORDER conjunct is enforced by the certificate's own `:LevelChain` replay and is red-capable: a hand-built Introspect→Repeat→AnswerReduce chain has the identical levels `[9,5,7,9]` (at ℓ = 5 both rules give 7, so levels alone cannot witness the swap) and the node's replay refuses it with `rule=:level_chain, actual=[9,5,7,9]` (`M-order-blind`, the critic's CRITIC-2 verbatim, KILLED). fig:compress's literal ℓ = 9 is pinned only as a certificate FACT that the test file asserts — `Compress` of a 5-level verifier records `levels = 5, ell = 9 => FAIL` at `ell_level` (`M-ell-from-input`, CRITIC-1 verbatim, KILLED) — while `verify_certificate` refuses at `nine_level` under both the constant and the input's own level, so no verification OUTCOME distinguishes them. Composed runtime bounds have free parameters exactly {n, λ} after binding ℓ = 9, the toy literals μ = γ = τ = 1, and `c'` and `\|D1\|` to prose descriptions of unexposed constants (`bind_parameter` ignores an absent name and accepts any host value, so that closure is partly a naming fact, `verdicts/tb4-r1.md` N2); the composed sampler-DEPENDENCY-SYMBOL set is ⊆ {λ, ℓ, μ, γ, τ, \|D1\|} and contains no component of `V` (no sampler bytes exist at TB4: the output is a `StubVerifier`; DESIGN §12.3's byte/hash form is TB5's `S^rep`), and in the form TB4 supports, `Compress` of the two byte-distinct 388-byte inputs at one λ yields 71-line traces differing in exactly one line — the input decider's `Quote` hash `dbf2c0815358657f` vs `2b9de4fb8ea9b2f9`, both critic-reserialized — with equal dependency symbols (`M-independence-leak` KILLED). The executable evidence is CHECKED Quote/Specialize on `D_{M,λ}` (host-side specialization; size law `385 − 31 − 2·22 + 31 + 2·15 + c_fix(5) = 376` with `c_fix = 5` bytes, critic-recomputed; both `specialize`'s and `fix_specialize`'s nodes are identity-bound and recompute the substitution by `program_equal`, `M-specialize-open`/`M-specialize-unbound` KILLED) and the TB0/TB2/TB3 PCP and typed-answer-reduction subtrees **on the 33-byte trivial front-end fixture**, every one of which is a DESCENDANT of `[ASSUMED] AnswerReduceSurrogate` (critic-verified by tree walk: no node under `:AnswerReduce` outside the contract nodes lies outside it; 20 of the tree's 30 CHECKED nodes are below it) with σ = 33 passed explicitly (`M-surrogate-sibling` KILLED), the front end's Tseitin reproduction being the CONSTRUCTED child `:UpstreamReproduction` of the identity-anchored `:UpstreamEvidence` (`M-reproduction-undisclosed` KILLED). The certificate is 70 nodes (CONSTRUCTED 7, CHECKED 30, CITED 9, ASSUMED 19, SOURCE_REPAIR 5); every CITED leaf carries `replay === nothing`; 7 of the 9 CITED nodes carry `source`/`lines`/`label` and each is grepped inside its cited range, as is every one of the 12 `\label`s named by a hypothesis source, while `:AnswerReduceQuantumContract` and `:CookLevinGeneral` remain display-only and no SOURCE_REPAIR node's citation is grepped; a violated checkable hypothesis (\|V\| > λ; wrong ℓ; a Concrete TIME > n^λ at n = 2) is an ASSUMED FAIL node that `verify_certificate` rejects at that hypothesis; and every Introspect and Compress hypothesis is scoped "(completeness/soundness only)" per gt-08:L789-L803 / gt-12:L26-L53, thm:ar's and thm:repetition's hypotheses being correctly unscoped. **Scope:** three stubs stand in for the construction, all three disclosed in the tree — `S_λ` (`λx.x`, 34 bytes), the `Introspect` and `Repeat` stages (CITED, no execution), and the `Compress` program inlined in `D_{M,λ}` itself (`[ASSUMED] CompressStubInTerm`: `COMPRESS_STUB`, 46 of 376 term bytes critic-recomputed, the constant `(pair,λ) ↦ Quote(λnxyab.true)`), so the "compressed branch" evaluated in testset (b) is that constant; and the outer `Eval` runs the returned decider under an enforced `FuelBound(n,λ)` where `fig:halt_f` step 5 (`gt-12-compression.tex:L448-L449`) imposes no budget and `TIME_{D^halt}(n) ≤ n^λ` is `lem:lambda`'s conclusion (`L570-L638`) — `SOURCE_REPAIR(:HaltDeciderFuelBound)`, the verifier's time bound reading "enforced by construction, not measured", never binding on the fixtures (12 and 91 units at n = 2). Red-capable by 26/26 registered mutants (`test/mutations/tb4_compress.jl`, all KILLED with 9/9 TB4 baselines OK); NOT red-capable: which compressor the `CompressStubInTerm` disclosure names, and the `source`/`lines` facts of `SOURCE_REPAIR(:HaltDeciderFuelBound)` (`verdicts/tb4-r2.md` NEW-2, NEW-1). The in-suite body is gated at `elapsed / calibration < 42` against a GF(8) kernel timed in-process (tb1-r5 N33); the gate normalises machine speed well (a 4.3× slowdown moved the measured ratio 3.4 %) but its constant corresponds to a 6.5–8.0 s in-suite body, not DESIGN §5.6's 6 s (`verdicts/tb4-r2.md` NEW-3). | TESTED | C9, C10, C16, C18 | `src/compress.jl`, `src/ir/programs.jl` | `test/tb4_compress_ir.jl`; red: `test/mutations/tb4_compress.jl` | `verdicts/tb4-r2.md` |

### C15 — **stays CONJECTURE.**

What TB4 r2 adds to r1's answer, i.e. what the skeleton now discharges of C15: the **composition
order** is no longer a test-file assertion but a red-capable conjunct of the certificate's own
`:LevelChain` replay; fig:compress's **ℓ = 9** is attested as a certificate fact; all three stubs
and the one construction deviation are **disclosed in the tree** (`CompressStubInTerm`,
`HaltDeciderFuelBound`, the `S_λ`/stage stubs), so the row's "constructs the composition order,
checked level chain 9→5→7→9" clause is now backed by evidence that can fail; and the surrogate is
structurally the ancestor of every fixture node, so a consumer cannot attribute the 20 CHECKED
fixture nodes to the stage's input. Sideways, TB5 (C12/C13 now TESTED) supplies the executable
`Repeat` behind the same `CompressStage` interface and the identical-`S^rep`-bytes form of sampler
independence, which was O9's deferred half.

What remains **entirely undischarged**, and is the whole of C15's content: the dimensions
206→840→848→1696; the fixed-width two-input identical **sampler hash** at TB7's parameters; the
printed ToyPolicy predicate report; `P_pcp_encodes_D1` (printed FAIL); the `enu:ar-game` and
non-Pauli-schema non-execution disclosures; and executable **Introspect** (TB6) inside `Compress`.
TB4 supplies the frame and now the frame's red tests; TB6–TB7 must supply every number in the row.

### DESIGN §1.6 N3 sentence — **AUTHORIZE, verbatim, with one added clause**

The invariant table still grades "CL levels | CONSTRUCTED" while `:LevelChain` is graded CHECKED. I
verified the substance: `_level_chain_ok` recomputes `introspect_levels`/`answer_reduce_levels`/
`repeat_levels` over data the constructors wrote, and two of the three stage levels are CITED theorem
literals. Apply the proposer's MP (3) sentence verbatim, appending the clause in brackets:

> the chain's arithmetic and origin order are CHECKED over the constructors' data; the stage levels
> themselves are CITED theorem literals [both conjuncts are red-capable — `M-level`/`M-level-sort`
> own the arithmetic, `M-order-blind` owns the order].

### part2a §10 N1 item (analytic lane) — **AUTHORIZE, verbatim**

I re-verified both halves from my own encoder and from DESIGN §1.1: `Fix` serializes as one tag byte
(`0x24`) plus a 4-byte child count and **no** sort annotation, so `c_fix = 5` **bytes**; and DESIGN
§1.1 now carries `eval(Fix(P),u;f) = eval(specialize(P,{self_code ↦ Quote(Fix P)}),u;f − c_Y)` with
`c_Y = 3`, adopted, so part2a §10 must stop calling MP-2 (ii) an open proposal. Apply the proposer's
MP (2) as written; analytic-doc lane, not TB4's.

### C16, C18, C10 — untouched by this round.

r1's caveats were applied by the orchestrator and nothing here weakens or strengthens them. The one
new datum is that `fix_specialize`'s replay now recomputes the substitution (`program_equal`), which
makes C16's specialization-size clause slightly better evidenced without changing its scope: the
instance still has λ at **two** hole sites and so still lies outside C16's stated affine-hole
discipline.

---

## 6. My mutations (all on the copy, full TB4 file, `TB4_TARGET=all`, 8/8 testsets)

| id | mutation | file | outcome | objection |
|---|---|---|---|---|
| CRITIC-3 | `source="gt-12-compression.tex", lines=451:453))` → `… lines=1:1))` | `src/compress.jl` | **SURVIVED** (exit 0) | NEW-1 |
| CRITIC-4 | swap the first two branches of the `compressor` ternary in `halting_verifier` | `src/compress.jl` | **SURVIVED** (exit 0) | NEW-2 |
| CRITIC-5 (diagnostic) | display `…(gt-12-compression.tex:L451-L453) accepts iff` → `…L448-L449…` (the TRUE range) | `src/compress.jl` | **KILLED** at `tb4_compress_ir.jl:293` | NEW-1 |

Per the brief, survivors are MAJOR. I also re-confirmed the registry's own dispositions: all 26 TB4
mutants KILLED with 9/9 passing TB4 baselines, and my r1 survivors CRITIC-1/CRITIC-2 are registered
verbatim as `M-ell-from-input`/`M-order-blind` and are now KILLED (32.47 s / 20.69 s) by the (f)
witnesses I independently reproduced in §2(1)–(2).

---

## 7. Surrogate honesty — grade **A−** (was B)

Both defects that held r1 to B are gone: the disclosure is now the structural **parent** of every
fixture node (§2(6)), and the third stub — the compressor inlined in `D_{M,λ}` — is named in the
tree with its size and value. What keeps it off a clean A is NEW-2: the parent-child structure is
mutation-owned, but the *naming* inside the third disclosure is not, so the tree can say a
non-constant compressor is inlined and pass. Fix that assertion and this is an A.

---

## 8. Residuals if the two MAJORs are fixed

- The ℓ = 9 pin is a fact assertion, not a verification outcome (§2(2)); TB6/TB7 will get a better
  witness once `Introspect` is executable and a non-9-level chain can be verified past `nine_level`.
- `_INDEPENDENCE_ALLOWED` and the `stub_bytes`/`term_bytes`/`compressor` facts are read by the
  replays and displays but not asserted as data by any test; the same substring-not-value pattern
  that produced NEW-2 lives in several other displays.
- `Compress`'s default `stages=tb4_stages()` still rebuilds a full front-end fixture per call.
- `M-relabel` still targets `src/certificates.jl` (proposer-reported, unchanged).

---

**VERDICT: FAIL(NEW-1,NEW-2)**
