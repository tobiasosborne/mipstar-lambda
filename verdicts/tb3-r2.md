# Verdict — TB3 quoted front end, critic round 2 (brief 66), also the TB4 readiness gate

Critic: Opus, autonomous, adversarial. Evaluated the **archived** tree at `f8bd881`
(`git archive f8bd881 | tar -x`) in
`/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb3-r2/tree`.
No repo file other than this verdict was written; no state-changing git; `src/`, `test/`,
`docs/`, `ground-truth/` were read only from the archive; `claims/CLAIMS.md` was read live and is
**byte-identical** to the archived copy (`diff` clean), so the claim texts adjudicated below are
the live ones.

Every number is recomputed from the ground-truth TeX and from my own code on a copy. The canonical
encoder and FNV-1a were **re-implemented by hand** from DESIGN §1.1 and the tag table (never by
calling `term_bytes`); the equality trace rows were derived by hand from the CEK rules before being
compared with `bounded_trace`; the Ψ fuel figures were decomposed transition by transition.

Prior: `verdicts/tb3-r1.md` — FAIL(N1, N2, N3), 3 MAJOR + 7 MINOR. This round adjudicates deltas
only; nothing that passed in r1 is re-litigated.

---

## 0. Runs, walls and load

Machine: 12 cores. **CPU governor is `powersave`**, not `performance` — brief 66 assumed
`performance`, and every wall below is therefore not comparable with brief 63's. The machine was
not quiet: load average moved between 1.9 and 10.3 during the session (my own runs plus other
processes). Pass/fail outcomes are unaffected.

| run | command | result | wall / load |
|---|---|---|---|
| instantiate + image | `Pkg.instantiate()` in the archive | ok, exit 0 | ≈ 110 s (not separately clocked; load 2.1 → 3.2) |
| suite | `julia --project=. test/runtests.jl` | **989/989, exit 0** | **76.09 s**, peak RSS 1 535 716 KB; load 3.24 → 2.59 |
| TB0 body clock | in-suite | **16.564 s** (warn 45.0, hard gate 60.0) | — |
| TB3 in-suite | (a) 0.7 (b) 0.4 (c) 1.0 (d) 0.3 (e) 2.3 (f)+(h) 8.0 (g) 2.1 (h) 0.6 | 244 TB3 assertions, all pass | **≈ 15.4 s** (≤ 20 s) |
| runner | `julia --project=. test/mutations/run.jl` | `MUTATION REGISTRY: killed=97/97 baselines ok=46/46 wall=503.31 s`, exit 0 | 503 s; load 1.93 → 9.00 |
| cold image | `tools/cold_precompile.sh` | 198.7 s | governor `powersave`, load 5.43 → 7.73 |

All 13 new TB3 mutants are **KILLED** (plain KILLED, none KILLED-BY-CRASH): C-N2a, C-N2b, C-N1,
C-N3, M-bind, M-upstream, M-budget, M-width, M-cY, M-halts, M-sort, M-fuelbound, M-verifier. No
`SURVIVED`, `LOAD-ERROR`, `UNATTRIBUTABLE` or `BROKEN` baseline anywhere; the four registered
evidence lines fired.

The cold figure 198.7 s against brief 63's 89.4 s is **not** an objection: DESIGN §5's clause
already carries the governor/load caveat the r1 verdict demanded, and this measurement is exactly
what that caveat predicts.

---

## 1. Independent recomputation (all on a copy)

**(1) Canonical bytes and hashes — my own encoder.** Header `0xC2`, 4-byte big-endian length-prefixed
sort symbol, then the tagged tree; my bytes are **byte-identical** to `canonical_bytes` for every
term I tried:

| term | my \|D\| | code \|D\| | my fnv1a64 | code fnv1a64 |
|---|---|---|---|---|
| `λnxyab.true` | 33 | 33 | `f8561ef8c5761695` | `f8561ef8c5761695` |
| `λnxyab.(a==b)` | 64 | 64 | `cea6bf9d6835b634` | `cea6bf9d6835b634` |
| twin `Prim(true,Opaque("one step",()))` | 45 | 45 | `e6a1d72daec2d7ef` | `e6a1d72daec2d7ef` |
| **my chimera** `Prim(true,Concrete(2))` | 33 | 33 | `d24975794d87d76c` | `d24975794d87d76c` |

`|enc(u)| = 27` for `u = (1,[],[],[1],[0])` (5+5+5+6+6 by hand), hence `h(d,u) = 3+33+27 = 63`,
matching `eval_overhead`; `eval_quoted(...).used = 66 = 63 + 3`. ✓

**(2) N2 — my own chimera, built independently of the fixture.** Brief 66 asks for *any* program
whose padded object equals the trivial decider's. I did not use the proposer's twin. I used
`B = λnxyab.Prim(true, Concrete(2), ())` — **the same `|D| = 33`** as `A = λnxyab.true`, a different
hash, and (verified) `A.padded.m == B.padded.m`, `A.padded.s == B.padded.s`,
`A.padded.clauses == B.padded.clauses`, equal gate counts, and
`tseitin(A.circuit) == tseitin(B.circuit)` field for field, while `A.padded !== B.padded`. Then:

```
verify_certificate(Checked(B.padded, A.certificate))
    -> passed = false, rule = :certificate_binding, location = :Pad5
frontend_pcp(Checked(B.padded, A.certificate), ...)
    -> ArgumentError: PCP upstream evidence does not verify against its term:
       certificate_binding at Pad5
B's own tree: contains A's hash = false; contains B's hash = true; verify = true
```

This is a **harder** witness than the fixture's twin (|D| coincides, so not even the size
distinguishes the two), and it settles the brief's question: **N2 and N7 do not conflict.** The
binding is by object identity (`x === subject`), so the value-equal object is the extremal case; a
T ≥ 2 decider (which N7 now widens to `m = 2`) would be caught one step earlier, at
`_same_tseitin`, with a *different* message. The T = 1 twin is therefore an acceptable — indeed
stronger — substitute for the r1 fixture `not(false)`.

`frontend_pcp` cannot print a foreign `|D|`/hash: every front-end display is computed from the
object it is attached to (`quote_hash(p.source.source.trace.program)`), and the graft is refused
before any PCP certificate exists. See N12 for the one residual reading.

**(3) N7 — recomputed.** `_padded_width = max(max index_widths, ceil(log2 2T))`. T = 2 (trivial):
`m = 2`, `live = 3`, `5m+5+live = 18`, `nextpow2(18) = 32 = m'`, `s = 32 − 15 = 17`, `2^2 = 4 ≥ 2T = 4` ✓
— **m = 2, s = 17, m' = 32** exactly as claimed. `not(false)` at T = 2 likewise gives m = 2, s = 17,
m' = 32. `gt-10-answer-reduction.tex:1238` confirms obligation 1 is `2^m ≥ 2T`.

**(4) c_Y = 3 and the fuel figure 8 — my own trace.** For
`fixed = Fix(λ5. If(true, true, Eval(self_code,(),1)))`: Fix 3 + Lambda 1 + beta 1 + `Prim(true)` 1
+ If-selection 1 + `Prim(true)` 1 = **8**; the self-code-substituted body uses **5**; delta = **3** =
`c_Y`; `OutOfFuel` at fuel 7. Code agrees exactly. part2a L654–655 states `c_Y = 3`, so the r1 N3
contradiction is gone.

**(5) Ψ_{M,λ} — my own decomposition.** Halting branch (M₃, n = 3):
`Fix 3 + Lambda 1 + beta 1 + M-literal 1 + n-lookup 1 + halts_within(1+3) 4 + If 1 + true 1 = 13` ✓.
Compressed branch (n = 2):
`3+1+1+1+1+3+1` (to the If) `+ 1+1+1+1+1+1+1` (stub closure, two Quotes, quoted_pair, λ-literal,
beta, quoted body) `+ 5+1+1` (five argument lookups, the two FuelBound operands) `+ h(d,u) = 63`
`+ 3` (inner Lambda, beta, Prim) = **91** ✓. `M_loop` at n = 3 costs one extra simulated step: **92** ✓.
`|D_halt| = 396`, hash `91b97bf8e30a1eba`. All three printed figures reproduce transition by
transition.

**(6) Equality-run rows — my own CEK derivation, written before reading the fixture.** Program
points of the body in prefix order: Lambda 1, `Prim(eq)` 2, `BoundVar(0,3)` 3, `BoundVar(0,4)` 4.
I derive, and `bounded_trace(equality, (1,[],[],[1],[0]), 3)` returns, exactly:

```
row 0  Prim(eq)      fuel 3  running  [control=>(:point,2), outcome=>:running]
row 1  Value([1])    fuel 2  running  [control=>(:value,(:bits,(true,))), k1=>(:seq,:prim,(:point,2),0,2), outcome=>:running]
row 2  Value([0])    fuel 1  running  [control=>(:value,(:bits,(false,))), k1=>(:seq,:prim,(:point,2),1,2), k1v1=>(:bits,(true,)), outcome=>:running]
row 3  Value(false)  fuel 0  reject   [control=>(:value,(:bool,false)), outcome=>:reject]
```

Ordered key sets, values, fuel and outcome all match my derivation. ✓

**(7) Sort checks.** `Quote(trivial,:Compressor)` → `ArgumentError: term does not have sort
Compressor`; `Quote(trivial,:Quoted)` → `ArgumentError: undeclared sort Quoted`;
`quote_program(Lambda(1,·); sort=:Decider)` → `ArgumentError`;
`Fix(Lambda(2, …Hole(:self_code,:Decider)…))` → `ArgumentError`. **Construction-time** sort failures
are host `ArgumentError`s, **not** `SortError`; `SortError` is the *evaluation* outcome
(`SortError(:eval_sort)` on a `MachineDesc` code value, `SortError(:residual_hole)` on a residual
hole). DESIGN §1.1 states exactly this split ("checked by shape wherever a term becomes a
description … and at evaluation … `SortError(:eval_sort)`"), so this is correct, not an objection —
but the brief's phrasing ("confirm `SortError`") should be read as: the *runtime* contract failures
are `SortError`, the *constructor* refusals are `ArgumentError`.

**(8) FuelBound overflow.** `Eval(Quote(trivial), literals, FuelBound(2^40, 3))` at ambient fuel 200
→ `Value(true)`, `used = 74` (= Quote 1 + five literals 5 + two fuel operands 2 + h 63 + inner 3);
at ambient fuel 70 → `OutOfFuel(70)`. Never `SortError`. An ill-sorted operand →
`SortError(:eval_fuel)`. `hard_cap < fuel` → `ArgumentError`. ✓ (gap 4, N9)

**(9) Equality fixture, recomputed end to end.** 3SAT `m=3, M=8`, **15** clauses; 5SAT widths
`(0,0,3,3,3)`, **47** clauses = 15 formula + **4** copy + **28** equality; padded `m=3`, live **423**,
`s=492`, `m'=512` (5·3+5+492 = 512 ✓, `2^3 = 8 ≥ 2T = 6` ✓); `arith_q` under the witness-(i) budget →
`ExpansionRefused(279 936 > 160 000)`. All reproduce. See N13 for what the *suite* does and does not
assert about them.

---

## 2. Adjudication of every r1 row, DESIGN condition and TB4 gap

| item | disposition | evidence |
|---|---|---|
| **N1** trace rows carry no checked content | **ACCEPTED** | `test/tb3_frontend.jl:337-365` pins control label, fuel, outcome and the ordered `fields` (with values) of all four equality rows at T = 3, plus the accepting run's identical key set; C-N2a and C-N2b registered and **KILLED**; DESIGN §1.1's invariant row now reads CHECKED with the contents named and general locality ASSUMED. My own CEK derivation reproduces the rows (§1.6). |
| **N2** borrowed front-end certificate passes | **ACCEPTED** (residue N12, N14) | First-class `upstream=` slot in `build_pcp`; `_bound_replay`/`_relocate` replace the captured-object fallback in all five nodes (grep: no `isa …Type ? x : captured` remains); my own chimera refused at `:Pad5` with `:certificate_binding`; `frontend_pcp(chimera)` throws; M-bind, M-upstream KILLED; the r1 §7-1 elegance defect is gone. |
| **N3** charge table / codec are not C16's | **PARTIAL** → **N11** | Option (b) landed: DESIGN §1.1's instantiation clause (bytes vs bits, folded navigation), the `8.5`→`8.3` cite fixed, and `c_Y` **aligned to 3** (verified, §1.4). But the *shrunk* C16/C18 clause claims the deviation list is now exhaustive, and it is not — see N11. |
| **N4** Cook–Levin honesty leaves | **ACCEPTED** | `:CookLevinGeneral` names (1) the observed-support function fit, (2) the absent initialisation clauses, (3) the absent counter/head/endmarker/track/ω; `:RawAnswerBlocks` names (4) the missing 2F reserved bits. Printed tree reproduced in §3. |
| **N5** CHECKED nodes without mutants | **ACCEPTED** (residue N13) | C-N1, C-N3 registered and KILLED; `tb3_pcp` now owns M-bind and M-upstream. The fix demand is fully met. `tb3_equality` still owns no mutant — that residue is N13, not a re-opening of N5. |
| **N6** `CompilationRefused` unreachable | **ACCEPTED** | `gate_budget=0` drives it in all three compilers (`test:506-509`), `CompilationRefused(1,0)` asserted; M-budget KILLED; the DESIGN §1.2 sentence names the driving test. |
| **N7** `2^m ≥ 2T` unchecked | **ACCEPTED** | Construction step in `_padded_width`, replay-checked, displayed (`2^m = 2 >= 2T = 2`); T = 2 → m = 2, s = 17, m' = 32 asserted and independently recomputed; M-width KILLED. |
| **N8** gadget subset with no residue | **ACCEPTED** | ASSUMED `:PerIndexEqualityGadgets` leaf names the omitted per-index pairs *and counts them* (0 emitted / 2 omitted indices on the trivial fixture). |
| **N9** `Aborted` outside the trichotomy | **ACCEPTED** | Documented in DESIGN §1.1 as a host guard; `hard_cap >= fuel` enforced with `ArgumentError` at both entry points; asserted. |
| **N10** trivial fixture vacuous for the "iff" | **ACCEPTED** | Stated in DESIGN §5.5 (the equality decider is "the discriminating fixture … it never reaches `build_pcp`") and carried into the C10 row below. |
| **DESIGN §5.5** ADMIT (a) dead gates | **ACCEPTED** | "five **dead** `NOT` gates (a chain dangling off the output, the output unchanged, contributing Tseitin variables but nothing to `C`)". |
| **DESIGN §5.5** ADMIT (b) retract "medium confidence / six-gate" | **ACCEPTED** | Replaced by "This is NOT TB0's six-gate circuit and not its 128-clause relation: the front-end normalization does not preserve the TB0 fixture …" with the surviving block-locality statement (7/7). |
| **DESIGN §5.5** ADMIT (c) T qualified by the charge clause | **ACCEPTED** | "`T` counts body transitions under the implemented charge table of 1.1"; the equality `T=3` likewise. |
| **DESIGN §5.5** ADMIT (d) both witnesses to `build_pcp`, (ii) to TB2 | **ACCEPTED with a wording residue (N16)** | The tests honour it, but the sentence routes *both* witnesses "through `build_pcp`'s upstream-evidence slot"; witness (i) goes through `build_pcp_fixture` with **no** upstream evidence. |
| **DESIGN §1.1** ADMIT part / REFUSE part | **ACCEPTED** | `SortError` rename (and definitions §F "returns `TypeError` (Julia: `SortError`)"), `Quote(code, sort)`, literal `PrimName`s, `Aborted` as a host guard, and — the part r1 REFUSED as insufficient — the explicit reconciliation clause (ν code vs 4-byte fields, bits vs bytes, folded navigation, `c_Y = 3` **is** part2a's). |
| **DESIGN §1.2** ADMIT conditionally | **ACCEPTED** | `CompilationRefused` listed *after* its driving test; the `general Cook--Levin locality \| ASSUMED \| fixture uses an enumerated per-field function fit` row is present; the trace invariant is split in §1.1's table. |
| **TB4 gap 1** `YCode` | **ACCEPTED** | `YCode(P) = Fix(P)` exported; `D = YCode(Ψ)` closed, quotable, replays; `Fix` charges `c_Y = 3`. |
| **TB4 gap 2** Ψ primitives | **ACCEPTED** | `halts_within` (charge 1 + steps, `Opaque("n steps")` bound honoured), `quoted_pair`/`fst_code`/`snd_code` registered; Ψ **evaluates** (13 / 91 / 92, all recomputed). |
| **TB4 gap 3** sorts | **PARTIAL** → **N17** | `DECLARED_SORTS` checked at `Quote`, `quote_program`, `specialize`, `Fix` and at evaluation; M-sort KILLED. But `:Level` is not a declared sort, and DESIGN §1.1's displayed `Hole(self_code,Quoted{Decider})` is not constructible. |
| **TB4 gap 4** `FuelBound` | **ACCEPTED** | `FuelBound(P{Nat},P{Nat})` in DESIGN §1.1, definitions §F and the code; overflow clamps to the ambient budget; M-fuelbound KILLED. |
| **TB4 gap 5** `Specialize` of `Fix` | **ACCEPTED** | Contract note in §1.1; `specialize(Fix(P), {self_code↦…})` refused and `specialize(Fix(P), {})` is the identity under the size law, both asserted. |
| **TB4 gap 6** `Verifier` carrier | **ACCEPTED** | Record with `Quoted{:Sampler}`/`Quoted{:Decider}` sort checks, `levels ≥ 1`, `description_size`; three refusals asserted; M-verifier KILLED. |
| **TB4 gap 7** the graft will recur | **ACCEPTED** | The slot exists and is the mechanism TB4 must reuse. |
| **TB4 gap 8** vector-backed `Circuit` | **NOT DONE, honestly declared** | Reported as not done; the equality fixture at 423 live gates is still under the 4096 cap. Not blocking TB4. |

**Counts: 10/10 r1 rows ACCEPTED or PARTIAL (0 REJECTED); 8/8 DESIGN ADMIT conditions ACCEPTED
(one with a wording residue); TB4 gaps 1,2,4,5,6,7 ACCEPTED, 3 PARTIAL, 8 declared not done.**

---

## 3. Certificate honesty

I reproduced the printed front-end tree and read every `facts.display` against its `replay`:

```
[CHECKED] PCPProof
  [CHECKED] UpstreamEvidence | tseitin(circuit) reproduces tf (6 gates)
    [CHECKED] Pad5        | m = 1 (2^m = 2 >= 2T = 2); s = 6 (live 1, padding 5 dead NOT gates
                            off the unchanged output); m' = 16; relation check = exhaustive (1024)
      [CHECKED] Decouple5 | widths (0,0,1,1,1); clauses 1 (formula 1, copy 0, equality 0)
        [CHECKED] CookLevin | m=1; M=2; clauses=1; rows=2; raw=2; aux=0; eliminated=0
          [CHECKED] BoundedTrace | T = 1 body transitions (eval fuel T + 2; the implemented charge
                                   table of DESIGN 1.1, not part2a 8.3's); rows = 2
            [CHECKED] Quote | |D| = 33 bytes; fnv1a64 = f8561ef8c5761695; sort = Decider
          [CITED]   CookLevinGeneral  | (1) function fit … (2) no initialisation … (3) no ω …
        [ASSUMED] RawAnswerBlocks     | … (4) C19's 2F reserved bits per answer block not reserved
        [ASSUMED] PerIndexEqualityGadgets | 0 multi-slot vars; 2 indices omitted
  [CHECKED] Tseitin / ArithTseitin / 5× MultilinearExtension / BuildC0 / ZeroBasis / PCPVerifier
```

* **No CHECKED node states a falsehood.** Every displayed quantity is one its replay recomputes,
  and every front-end node is now identity-bound to its own subject through the constructor chain.
* **Red-capability of the CHECKED nodes:** all 13 new mutants KILLED, and the `:Pad5` node fails on
  my own chimera. One conjunct of the `:UpstreamEvidence` replay is *not* red-capable — N14.
* **ASSUMED/CITED leaves name exactly what they omit** — the four r1 departures are now spelled out
  verbatim, with counts computed from the attached object rather than written as literals.
* **`:UpstreamEvidence` replay** does recompute `_same_tseitin(tseitin(circuit).term, proof.tf)`
  against the attached proof, as the brief requires — but see N14 for the missing red witness, and
  N12 for what the reproduction does and does not authenticate.

---

## 4. My two new semantic mutations

Applied the way `test/mutations/run.jl` applies its own (`Base.include(MIPStarLambda, mutated_file)`
in a fresh process, then the rung's test file with `TB3_TARGET` set), on copies; the tree was never
modified.

| id | mutation | file | result |
|---|---|---|---|
| **X1** | `:UpstreamEvidence` replay drops the reproduction: `proof.tf === tf && _same_tseitin(tseitin(circuit).term, proof.tf)` → `proof.tf === tf` | `src/verifiers/pcp.jl` | **SURVIVED** (`tb3_pcp`, exit 0, 36/36) |
| **X2** | the greedy support minimisation of the per-field function fit is disabled: `consistent(trial) && (support = trial)` → `false && …` | `src/frontend/cook_levin.jl` | **KILLED** under `tb3_cook_levin` (10/19) and `tb3_decouple` (18/32); **SURVIVED** under `tb3_equality` (exit 0, 10/10) |

X2's survival under `tb3_equality` is the interesting half: with the fit unminimised the whole
equality snapshot changes — 3SAT `m` 3 → 5, `M` 8 → 32, clauses 15 → **45**; 5SAT widths
`(0,0,3,3,3)` → `(0,0,5,5,5)`, clauses 47 → **173**, equality gadgets 28 → **124**; padded `m` 3 → 5,
live 423 → **2363**, `s` 492 → **4066**, `m'` 512 → **4096** — and testset (g) stays green, printing
the new numbers. The mutant is caught only by the *trivial* fixture's assertions in two other
targets.

Both survivors are graded below their default (the brief's rule is "survivor ⇒ MAJOR"); the reasons
are given in N13 and N14, and the orchestrator can overrule.

---

## 5. New objections

### N11 (MAJOR) — the shrunk C16/C18 deviation clause is exhaustive and false: the runtime `Eval` contraction charges `h(d,u)`, where part2a §8.3 charges two units

**Location:** `claims/CLAIMS.md` C16 and C18, the sentence *"`c_Y = 3` is now the analytic value
(brief 63) and **only** the folded context navigation and the byte unit remain as deviations"*;
`src/ir/programs.jl` `_contract_sequence!`, the `frame.kind == :eval` branch;
`docs/analytic/parts/part2a.tex` L631–L636 and L740–L761; `docs/DESIGN.md` §1.1 implementation note.

**Computation.** part2a §8.3 is explicit that an internal `Quote` is a *syntax pointer* and that
running it is cheap: *"`Eval` evaluates its code, arguments, and fuel expression, installs a
delimiter holding the requested inner budget, and runs the same CEK transition relation inside it.
**Installing and removing that delimiter costs two units.**"* The byte-level overhead is a different
account, and part2a says so in as many words: *"The constant 3 … pays for installing the Eval
delimiter, removing it, and the one tag check that decides whether `d` is well-formed code. It
therefore **absorbs** the two delimiter units charged above, and the two accounts do not
double-count."*

The implementation charges the **full** `h(d,u) = 3 + |ser(code)| + |enc(args)|` at *every* `Eval`
contraction, including one whose code came from an internal `Quote` node. I verified this three
ways on a copy:

* `Eval(Quote(λnxyab.true), five literals, FuelLiteral(3))` at ambient fuel 100 uses
  `1 + 5 + 63 + 3 = 72` — the 63 is `h`, not 2 (the suite asserts this figure itself, test (b)).
* the same term with `FuelBound(2^40, 3)` uses `74` (two extra fuel operands).
* **63 of the 91 units of Ψ's compressed branch are this charge** (§1.5): under part2a §8.3 the same
  run costs 30.

So a third deviation remains, and it is neither "coarser" (it charges *more*) nor "the byte unit"
(even in bits it would be `3 + |d| + |enc(u)| ≫ 2`). The clause was narrowed during repair, in a
direction that makes the implementation look closer to §8 than it is, and it was applied to
`claims/CLAIMS.md` without adjudication. That is the silent-strengthening failure mode the ratchet
exists to catch.

**FIX DEMAND.** Replace *"only the folded context navigation and the byte unit remain as
deviations"* in C16 **and** C18 by: *"the remaining deviations are the folded context navigation,
the byte unit, and the `Eval` contraction, which charges the full front-end overhead
`h(d,u) = 3 + |d| + |enc(u)|` at every `Eval` — including one applied to an internal `Quote` — where
part2a §8.3 charges two units for installing and removing the delimiter"*, and add the same sentence
to DESIGN §1.1's implementation note.

**SURVIVING WEAKER STATEMENT.** `c_Y = 3` **is** part2a's constant (verified: 8 = 5 + 3), and the
implementation's charge table differs from part2a §8.3 in exactly three named places — context
navigation (cheaper), the byte unit (different scale), and the `Eval` front end (dearer). TB3 is
machine evidence for that instantiation.

---

### N12 (MINOR) — the upstream binding authenticates *a* front end that generates the formula, not *the* program: `|D|` is not pinned by the proof

**Location:** `src/verifiers/pcp.jl` `_bind_upstream` (`_same_tseitin` is a value comparison);
`docs/DESIGN.md` §5.5 ("Assert canonical quote-size propagation"); the C10 row's
"`|D|`/hash propagate into the PCP certificate".

**Computation.** `_same_tseitin` must compare by value (`tseitin(circuit)` returns a fresh object),
so any front end whose padded circuit Tseitinises to the same formula is admissible. I built A's
PCP proof and handed it **B's** upstream evidence:

```
build_pcp(tf_A, gs, c0, decomposition, 6, points, evidence; upstream = (B.padded,))
  -> SUCCEEDED; verify_certificate = true; prints B's |D| and B's hash; A's hash absent
```

Nothing here is false — B really does generate that formula — but the circuit does **not** determine
`|D|`: A (33 bytes), my chimera (33 bytes, different hash) and the fixture's twin (**45** bytes) all
produce the same padded circuit at T = 1. A downstream consumer that read `σ ≥ |D|` off the upstream
node could therefore read 33 for a 45-byte decider. Test (f) does not: it takes
`sigma = description_size(pipeline.quoted.term)` from the pipeline.

**FIX DEMAND.** Scope the sentence — in the C10 row (done below) and in DESIGN §5.5 — to *"the
attached front-end evidence is one that generates the proof's Tseitin formula; the formula does not
determine `|D|`, so the propagated size and hash are the attached front end's, not a property of the
proof"*. If TB4 needs `σ` to be authenticated, the answer-reduction parameters must carry it
separately, not read it off this node.

**SURVIVING WEAKER STATEMENT.** A front-end certificate attached to a proof whose Tseitin formula it
does **not** generate is refused at build time; a certificate attached to a *different object* is
refused at `:Pad5` with `:certificate_binding`; and every display is computed from the object it is
attached to.

---

### N13 (MINOR) — the `tb3_equality` target owns none of its own numbers

**Location:** `test/tb3_frontend.jl` testset (g) (lines 659–693) — ten assertions, none of which
pins a count; `test/mutations/run.jl` — no mutant targets `tb3_equality`.

**Computation.** My mutation **X2** leaves testset (g) green 10/10 while every printed figure of the
equality snapshot changes (15 → 45 clauses, 47 → 173, 28 → 124, 423 → 2363, 492 → 4066, 512 → 4096).
The only equality-fixture facts that are red-capable live in testset (e) — `satisfiable5(e5, (a,b)) ==
(a == b)` and `satisfiable(e3, (a,b)) == (a == b)` exhaustively over the four pairs,
`literal_blocks(e5) == {3,4,5}`, `copy_gadgets > 0`, owned by C-N1 — and those are exactly the
*discriminating* clause of C10. The counts are not.

I grade this MINOR rather than MAJOR because (i) X2 is KILLED by the registry as a whole, (ii) the
r1 N5 fix demand named `tb3_pcp`, not `tb3_equality`, and was fully met, and (iii) I recompute every
one of the figures myself in §1.9, so the C10 row can carry them with an honest attribution rather
than being held.

**FIX DEMAND.** In testset (g) assert `f3.index_width == 3`, `f3.variable_count == 8`,
`length(f3.clauses) == 15`, `d5.index_widths == (0,0,3,3,3)`, `length(d5.clauses) == 47`,
`d5.copy_gadgets == 4`, `d5.equality_gadgets == 28`, `p.m == 3 && p.live_gates == 423 && p.s == 492
&& p.m_prime == 512`, and `expansion.estimate == 279_936`; then register one mutant on the
`tb3_equality` target (mine is a one-line registry entry). Until then the C10 row must carry the
scoping sentence written below.

---

### N14 (MINOR) — one conjunct of the `:UpstreamEvidence` replay has no red witness

**Location:** `src/verifiers/pcp.jl` `_bind_upstream`, the `replay=` closure.

**Computation.** My mutation **X1** reduces the replay to `proof.tf === tf` and `tb3_pcp` stays green
36/36. So the *recomputation* the node advertises ("tseitin(circuit) reproduces tf") is not
evidence-bearing at replay time.

I grade this MINOR, not MAJOR as the brief's default would have it, and say why: `tf` and `circuit`
are immutable, `tseitin` is deterministic, and the build-time check already established the
reproduction on those very objects, so `proof.tf === tf` **implies** the second conjunct. No
soundness is lost, and the node as a whole is demonstrably able to fail (M-bind, M-upstream and my
chimera all make it fail). What is unearned is only the claim that the replay *recomputes* the
reproduction.

**FIX DEMAND.** Either register a mutant that deletes the conjunct together with a test that makes
it red (verify an upstream node against a value-equal but distinct `tf` — reachable via my A/B pair),
or change the node display and the C10 wording to say that the replay's binding is the identity
anchor and the reproduction is a build-time check.

**SURVIVING WEAKER STATEMENT.** The reproduction is checked once, at build time, on the objects the
node captures, and the replay refuses any proof that does not own that formula.

---

### N15 (MINOR, lockstep) — `part2b.tex` still says the front end is absent

**Location:** `docs/analytic/parts/part2b.tex` §"Description front end (planned TB3)", L963–L1005:
the section title, the figure caption (*"three named front-end operations that are still absent"*,
*"currently absent description-to-SAT implementation"*), and five longtable rows grading
`Quote, Eval, Specialize`, `description_size`, `bounded_trace, cook_levin` and `decouple5` as
**"CITED; absent"** / **"analytic only; absent"**.

This is false since brief 23 and directly contradicts the sentence the orchestrator amended 700 lines
earlier (L266–L270) and claim C19 as it now stands. It is the same defect class the r1 verdict's
C19 item (i) named at L262–L270; the amendment fixed one occurrence and left the table.

**FIX DEMAND.** Retitle the subsection, rewrite the caption, and change the four affected grade cells
to name what is executed (`bounded_trace`, `cook_levin`, `decouple5`, `pad5`, `Quote`, `Eval`,
`specialize`, `description_size` on two one-bit-answer fixtures) and what stays CITED (Γ_L, r₀, ω,
the index-width and size bounds, the 2F reservation).

---

### N16 (MINOR, lockstep) — two "both/two fixtures" overstatements

1. `docs/analytic/parts/part2b.tex` L266–L270 (the sentence amended at `f8bd881`): the four
   transformations *"run the generated instance through the PCP builder and the answer-reduced
   decider **on two one-bit-answer fixtures**"*. Only the **trivial** fixture reaches `build_pcp`;
   the equality fixture is refused with `ExpansionRefused(279 936 > 160 000)` and never reaches the
   builder or TB2 — which is exactly N10, and which DESIGN §5.5 states correctly.
2. `docs/DESIGN.md` §5.5: *"Feed the generated … circuit and **both retained witnesses** into TB0's
   Tseitin/PCP builder **through `build_pcp`'s upstream-evidence slot**"*. Witness (i) goes through
   `build_pcp_fixture` with **no** upstream evidence (`test:562`); only witness (ii) goes through
   the slot (`test:570`).

**FIX DEMAND.** (1) *"…run the two one-bit-answer fixtures through the front end, and the trivial
fixture's generated instance through the PCP builder and the answer-reduced decider"*. (2) *"…both
retained witnesses into TB0's Tseitin/PCP builder, witness (ii) through `build_pcp`'s
upstream-evidence slot"*.

---

### N17 (MINOR, TB4-blocking) — `Level` is not a declared sort, and DESIGN §1.1's displayed Ψ literal is not constructible

**Location:** `src/ir/programs.jl` `DECLARED_SORTS`; `docs/definitions.md` §F rows `Level`,
`Psi_{M,L}`, `D_{M,L}`, `L (fixed-point context)`; `docs/DESIGN.md` §1.1 grammar and Ψ display.

**Computation.**

* `Quote(Prim(3,Concrete(1),()), :Level)` → `ArgumentError: undeclared sort Level`.
  `DECLARED_SORTS = (:Program,:Decider,:Compressor,:Sampler,:MachineDesc,:Pair,:Nat,:Bit,:Bits)`.
  definitions §F says *"The fixed-point parameter `L` is a closed literal term of sort `P{Level}` and
  is passed unchanged to `Compress`"*. That term cannot be written. The r1 verdict's gap 3 named
  `Level` explicitly; the repair declared the other four sorts and dropped this one.
* `Fix(Lambda(5, …Hole(:self_code, :Quoted)…))` → `ArgumentError: undeclared sort Quoted`. DESIGN
  §1.1's *displayed* Ψ writes `Hole(self_code,Quoted{Decider})`, and part2a §10 asserts that
  DESIGN §1.1 *"now declares `self_code : Quoted{A}`"*, so both documents agree with each other and
  disagree with the code, which names the hole by `A` (`Hole(:self_code, :Decider)`, as test (h)
  does). The implementation note discloses this ("`Fix`, whose `self_code` hole names `A`") but the
  display was not updated, so the term TB4 must construct is not the term §1.1 prints.
* definitions §F names the fixed point `Psi_{M,L}` / `D_{M,L}` with `L : P{Level}` passed to
  `Compress`; DESIGN §1.1 names it `Psi_M_lambda` and passes `lambda : P{Nat}` to `Compress`. TB4
  has to pick one.

**FIX DEMAND.** Add `:Level` to `DECLARED_SORTS` with an `_admits_sort` shape (a `Nat` literal, or a
declared `Level` literal), rewrite the §1.1 display's hole as `Hole(self_code, A)` with a one-line
note that `A` is the result sort whose *code* the hole receives, and settle in one place whether
`Compress`'s second argument is `lambda : P{Nat}` or `L : P{Level}`.

---

**Counts: 1 MAJOR (N11), 6 MINOR (N12–N17), 0 FATAL.**
Trajectory r1 → r2: **3 MAJOR + 7 MINOR → 1 MAJOR + 6 MINOR**, and the single MAJOR is a claims-text
repair, not a defect in the executable. Every r1 MAJOR is discharged.

---

## 6. Claim decisions

### C10 — **PROMOTE to TESTED**

N1, N2 and N5 — the three named holds of r1 — are discharged, each verified by fresh recomputation
(§1.2, §1.6) and by KILLED mutants I re-ran. The proposer's two corrections (`c_Y = 3`; the
`2^m ≥ 2T` construction step with T = 2 → m = 2, s = 17, m' = 32) are correct and are folded in. I
add two scoping clauses forced by this round: N12 (what the upstream binding authenticates) and N13
(which equality-fixture figures the suite asserts and which it only prints), and I correct the
charge-table sentence for N11 so that C10 stays honest independently of when C16/C18 are repaired.

**AUTHORIZED VERBATIM (apply exactly; do not paraphrase upward):**

> | C10 | (Front-end faithfulness on the fixtures) For `D = λ n x y a b . true` (T = 1, `|D| = 33`
> bytes, fnv1a64 `f8561ef8c5761695`) and `D = λ n x y a b . (a == b)` (T = 3, `|D| = 64` bytes),
> with one-bit answers and `x = y = ()`: `bounded_trace` decodes the canonical bytes and returns
> `T+1` rows with halting-self-loop padding, and its result, acceptance flag and row CONTENTS
> replay — for the equality fixture at T = 3 the ordered field keys and values of all four rows
> (control label and program point, the pending `prim` frame with its evaluated values, fuel,
> outcome) are pinned, and the accepting run has the identical key set; `cook_levin` emits a
> `Succinct3SAT` (`m=1, M=2`, 1 clause family, 16/64 present; `m=3, M=8`, 15 clauses) whose relation
> circuit matches the template relation exhaustively and which, with the answer bits pinned, is
> satisfiable iff `D` accepts on each of the four answer pairs — a discriminating test only for the
> equality fixture, since the trivial fixture accepts on all four; `decouple5` emits a
> `SuccinctDecoupled5SAT` with five index blocks and five signs, 3SAT literals confined to blocks
> 3–5, copy gadgets tying blocks 1–2 into block 3, and equality gadgets for multi-slot variables
> ((0,0,1,1,1)/1 clause; (0,0,3,3,3)/47 = 15 + 4 + 28), satisfiable iff `D` accepts (exhaustive over
> 256 witnesses; and asserted on all four answer pairs for the equality fixture); `pad5` gives
> `m=1, s=6, m'=16` (one live `AND(x_3,o_3)` plus five **dead** NOT gates) with the padded relation
> equal to the decoupled one on all 1024 tuples and 512/1024 `phi_C` witnesses, and enforces
> obligation 1 of `prop:explicit-padded-succinct-deciders` as a construction step, `2^m >= 2T`
> (T = 2 pads to `m=2, s=17, m'=32`); the GENERATED circuit passes `build_pcp` for both retained
> witnesses (`|c_0| = 10 140` and `162 240` under budgets 160 000 / 2 500 000) and TB2's
> answer-reduced decider accepts the honest strategy on all seven `fig:decider-pcp` guard cases; the
> equality fixture's padded circuit (`m=3`, live 423, `s=492`, `m'=512`) is refused by `arith_q`
> with `ExpansionRefused(279 936 > 160 000)` and never reaches `build_pcp`. The front-end
> certificate reaches the PCP tree through `build_pcp`'s upstream-evidence slot: at build time the
> upstream circuit must reproduce the proof's Tseitin formula and its certificate must verify
> against its own term, and every front-end node is bound by object identity to its subject through
> the constructor chain, so a certificate attached to a different padded object — even one whose
> padded relation, gate count and `|D|` are equal — is refused at `:Pad5` with `:certificate_binding`
> before any PCP certificate exists (critic recomputation, `verdicts/tb3-r2.md` §1.2). **Scope:** the
> slot authenticates *a* front end that generates the proof's Tseitin formula, not *the* program —
> the formula does not determine `|D|` (three distinct programs of 33, 33 and 45 bytes generate the
> same padded circuit at T = 1) — so the propagated size and hash are the attached front end's, not
> a property of the proof (`verdicts/tb3-r2.md` N12). The fuel figures are those of the implemented
> charge table (§ DESIGN 1.1), which folds continuation navigation into the following contraction,
> measures `|·|` in bytes, charges `c_Y = 3` (part2a's constant) and charges the full front-end
> overhead `h(d,u) = 3 + |d| + |enc(u)|` at every `Eval` contraction where part2a §8.3 charges two
> units; they are not §8.3's. The Cook--Levin step is a fixture-only surrogate: field alphabets are
> enumerated over all `2^{|a|+|b|}` answer inputs and the transition constraints are a per-field
> function fit over the observed support keys, with no window function, initialisation, format or
> `2F`-reserved-answer clauses. The equality fixture's counts (`M=8`, 15 / 47 = 15+4+28, live 423,
> `s=492`, `m'=512`, estimate 279 936) are PRINTED by testset (g) and independently recomputed by
> the critic, but are not asserted by the suite and no registered mutant owns the `tb3_equality`
> target (`verdicts/tb3-r2.md` N13); what is asserted and red-capable there is the satisfiable-iff-
> accepts equivalence on all four answer pairs and `literal_blocks = {3,4,5}`. Red-capable by M-acc,
> M-size, M-fuel, M-decouple, M-closure, M-bind, M-upstream, M-budget, M-width, M-cY, M-halts,
> M-sort, M-fuelbound, M-verifier, C-N1 (`u_4 = u_5` gadget), C-N2a/C-N2b (trace row contents) and
> C-N3 (pad5 padding). | TESTED | C1, C9, C16, C19 | `test/tb3_frontend.jl`, `src/ir/programs.jl`,
> `src/frontend/{bounded_trace,cook_levin,decouple5}.jl`, `src/verifiers/pcp.jl` |
> `test/tb3_frontend.jl`; red: `test/mutations/tb3_{quote,eval,fuel,cook_levin,decouple,r1}.jl` |
> `verdicts/tb3-r2.md` |

### C16 — **RE-AFFIRM SKETCH**

The fixture evidence now covers, on two fixtures and an 11-term codec gallery: determinism and the
outcome trichotomy (with `Aborted` documented as a host guard outside it and `hard_cap >= fuel`
enforced); fuel monotonicity with *exact* usage; the Quote/Eval equation in the shape
`Eval(Quote t,u;f+h) = eval(t,u;f)` using exactly `h + c` (63 + 3 = 66, recomputed); the exact
affine-hole `Specialize` size identity with duplicate-, missing-, extra-hole and open-replacement
refusals; the `Fix` unfolding at **`c_Y = 3` — now part2a's own constant** (8 = 5 + 3, recomputed and
owned by M-cY); declared-sort checking at every point where a term becomes a description and at
evaluation; and `FuelBound` overflow resolving to `Value`/`OutOfFuel`, never `SortError`. What it
still does not cover: the charge table itself (folded navigation; and the `Eval` overcharge of
N11), the serialization (bytes with fixed-width fields vs §8.1's bit-counted ν code, hence a
different `h(d,u)`), and the universal quantification over all closed terms, arguments and fuels.
**SKETCH stands**, and the row's deviation clause must be corrected per N11 before it is quoted
anywhere else.

### C18 — **RE-AFFIRM SKETCH**

`c_Y = 3` is no longer a contradiction: `YCode(P) = Fix(P)` exists, is exported, closes the single
`self_code` hole, and charges exactly 3 (verified twice). `D_{M,λ} = YCode(Ψ_{M,λ})` is now a real,
closed, quotable, **evaluable** term (`|D| = 396` bytes, three branch costs recomputed). Everything
else in C18 — the s-m-n transformer, its size bound, Kleene's `e_Q`, the linear-time claim, and the
"three descriptions of the same partial function" — has no executable counterpart. **SKETCH stands**,
with the same N11 correction owed to its deviation clause.

### C19 — **RE-AFFIRM SKETCH**

The row's amendments landed correctly: the false "no implementation exists" sentence is gone, the
decoupled-form half is named as fixture evidence, and the `2^m >= 2T` obligation is recorded as
enforced by `pad5` (independently recomputed: T = 2 → m = 2). What the fixture evidence now covers:
the five-block placement (literals 1,2,3 → `u_3,u_4,u_5`), the copy gadgets tying `a,b` to `u_3`,
the equality gadgets for multi-slot variables (with the omitted per-index pairs carried as an
ASSUMED leaf that counts them), the exhaustive relation checks, and the satisfiable-iff-accepts
guarantee on both fixtures. Not covered, and still CITED/ASSUMED: `Γ_L`, `r_0`, `ω` and the
transition-window lemma, initialisation and format clauses, the `O(log F + log σ)` index width, the
`poly(...)` size and construction time, and the `2F` reserved bits per answer block. **SKETCH
stands.** Its `where-proved` pointer must be repaired per N15 — `part2b.tex` still grades the same
transformations "absent" 700 lines below the amended sentence.

---

## 7. TB4 readiness

1. **Executable prerequisites are in place.** `YCode`, an evaluable `Ψ_{M,λ}` (halting branch 13,
   compressed 91, looping 92 — all recomputed), `halts_within`/`quoted_pair`/`fst_code`/`snd_code`
   with charges, declared-sort checking, a reconciled `FuelBound`, and the `Verifier` carrier all
   exist, are exported, are tested and are mutation-owned.
2. **Brief 24 (+ addendum) can be executed without a further design round**, with one exception
   below. The `Compress = Repeat ∘ AnswerReduce ∘ Introspect` skeleton, the 9-level `StubVerifier`
   assertion, `|D_{M,λ}|` from canonical bytes, and the CHECKED/CITED grade structure all have
   carriers now.
3. **Blocking gap: N17.** `:Level` is not a declared sort, so definitions §F's `P{Level}` literal
   cannot be written, and DESIGN §1.1's displayed `Hole(self_code,Quoted{Decider})` is not
   constructible. Both are one-line fixes, but TB4 writes exactly these terms, so they must land
   first, together with the `lambda : P{Nat}` vs `L : P{Level}` decision for `Compress`'s second
   argument.
4. **Deviation 1 — runtime `Specialize` is vacuous — is a correct design decision for TB4.**
   `Quote` admits only closed terms, so a `Code` value can never carry a hole and
   `Specialize(Quote(t), σ)` is the identity (verified: it returns the same code). TB4 must therefore
   specialize on the host (`substitute` the open body, then `Fix`/`YCode`, then `quote_program`) —
   which is what §1.1's contract note now says. **Accepted as a design decision**; the alternative
   (a partial-code sort) is a strictly larger change and should not be attempted inside TB4.
5. **Deviation 2 — `Apply(Quote(Compress), …)` is not evaluable — is also accepted, but §1.1's
   display must change, not merely gain a reading note.** Verified: it returns
   `SortError(:apply_non_closure)`. A displayed term that the evaluator refuses is a trap for TB4,
   which will transcribe the display. **Demand:** rewrite the §1.1 display to the evaluable form
   `Eval(Apply(Compress, quoted_pair(...), lambda), (n,x,y,a,b), FuelBound(n,lambda))` and keep the
   note explaining why `Quote(Compress)` was dropped.
6. **N12 propagates into TB4.** `Compress` consumes `(S_λ, d)` and must know `|d|`; the upstream slot
   authenticates the formula, not the description, so TB4 must pass `σ` explicitly rather than read
   it from a certificate node.
7. **Not blocking:** gap 8 (vector-backed `Circuit`, cap 4096, equality fixture at 423 live gates)
   and N13/N14 (test-coverage residues).
8. **Verdict on readiness:** GO for brief 24 once N17's two one-line sort fixes and item 5's display
   correction land; nothing else in this round blocks TB4.

---

## 8. Elegance — the r1 §7 items, revisited

1. **Resolved.** The `x isa FooType ? x : captured` fallback is gone from all five front-end nodes;
   `_bound_replay` + `_relocate` express "a judgement about its own object, reached through the
   constructor chain" directly, and `build_pcp` has a first-class slot instead of a graft. This is
   the round's best piece of work.
2. **Unchanged.** Four representations of one relation (`Clause3`/`Clause5`, `_template_matches`,
   `relation_tuples`/`relation_input`, `compile_relation`) still coexist with `_check_relation` as
   their reconciler.
3. **Unchanged.** The exhaustive relation sweep is still performed twice per constructor (once for
   the display, once in the replay) and the equivalence loop re-traces every answer input a third
   time; the equality fixture's testset (g) now costs 4m25s under a mutant for that reason.

---

VERDICT: FAIL(N11)
