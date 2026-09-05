# Verdict — TB3 quoted front end, critic round 1 (brief 60)

Critic: Opus, autonomous, adversarial. Evaluated the **archived** tree at `0093328`
(`git archive 0093328 | tar -x`) in
`/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb3-r1/tree`.
No repo file other than this verdict was written; no state-changing git; `src/`, `test/` were read
only from the archive; `claims/CLAIMS.md` read live (identical to the archived copy for C16/C19).

Every number below was recomputed from the ground-truth TeX and from my own code on a copy, never
taken from `briefs/23-tb3.last.md`.

---

## 0. Runs and walls

Machine: 12 cores. **Not quiet** — throughout the session another agent's Julia processes held load
average 2.6 → 7.7 (four foreign `julia` processes at 100 % each at 07:34). All wall figures below
carry that contamination; the pass/fail outcomes do not.

| run | command | result | wall |
|---|---|---|---|
| instantiate + cold image | `Pkg.instantiate()` in the archive | ok | 191 s (Pkg's own figure for the `MIPStarLambda` image: **182.7 s**, load ≈ 2.6) |
| suite | `julia --project=. test/runtests.jl` | **807/807, exit 0** | 145 s (testset total 2m22.8s) |
| TB0 body clock | in-suite | **42.308 s** (warn 45.0, hard gate 60.0) | — |
| TB3 in-suite | (a) 1.0 (b) 0.9 (c) 1.1 (d) 0.6 (e) 3.8 (f) 7.3 (g) 4.3 | 162 tests, all pass | **19.0 s** (≤ 20 s) |
| runner | `julia --project=. test/mutations/run.jl` | `MUTATION REGISTRY: killed=77/77 baselines ok=41/41 wall=666.06 s`, exit 0 | 666 s |
| cold precompile | `tools/cold_precompile.sh` (scratch depot) | 264.3 s (concurrent) and **311.4 s** (load 3.9→7.7) | — |
| cold precompile, TB3 workload removed | same, `include("frontend/precompile_frontend.jl")` commented out | **146.4 s** | 148 s |

All five TB3 mutants and the three TB0 r4-sweep mutants reproduce as KILLED, with the expected
evidence lines; no `SURVIVED`, `LOAD-ERROR`, `UNATTRIBUTABLE` or `BROKEN` baseline anywhere.

**Precompile honesty: CLEAN.** I rebuilt the package in a private depot with
`src/frontend/precompile_frontend.jl` removed from `src/MIPStarLambda.jl` and re-ran
`test/tb3_frontend.jl` standalone: **exit 0**, and every printed TB3 fact is byte-identical
(`|D| = 33`, `f8561ef8c5761695`, `h(d,u) = 63`, gallery sizes `[13,28,22,42,43,46,58,37,88,66,52]`,
`T=1 rows=2`, `m=1 M=2 clauses=1 present=16/64`, `widths=(0,0,1,1,1)`, `padded m=1 s=6 m'=16
present=256/1024 witnesses=512/1024`, `|c0| (i)=10140 (ii)=162240`, `decider 7/7`, equality
`T=3 rows=4 3SAT m=3 M=8 clauses=15 | 5SAT 47 copy=4 eq=28 | padded m=3 live=423 s=492 m'=512 |
ExpansionRefused(279936)`). Only timings move. No TB3 outcome comes from the image. That run took
130 s of wall against 19 s in-suite, i.e. the workload buys ≈ 110 s of test-time JIT for ≈ 40 s of
image build (146.4 s → ≈ 185 s quiet). **NOTE, not an objection.** But DESIGN §5's single figure
"188.2 s" is load-sensitive by ±60 % on this machine (I measured 182.7 / 264.3 / 311.4 s for the
same build); the clause should carry the load caveat the way the r3/r4 figures carry their delta.

---

## 1. Independent recomputation (all on a copy; the encoder was re-implemented from the spec)

I re-implemented the canonical encoder by hand from DESIGN §1.1 + `src/samplers/cl.jl`'s
`_encode_int!` (4-byte big-endian) — not by calling `term_bytes` — and hashed it with my own FNV-1a:

* trivial decider `Lambda(5, Prim(true, Concrete(1), ()))`: header `0xC2` (1) + sort `"Decider"`
  (4 + 7) + `Lambda` (1 + 4 + 4) + `Prim` (1 + 2 + 5 + 4) = **33 bytes**,
  fnv1a64 = **`f8561ef8c5761695`**. `description_size` = 33 = `length(canonical_bytes)`;
  round trip `decode_program`→`quote_program` reproduces the bytes; truncation and a trailing byte
  are both refused with `ArgumentError`. ✓
* `|enc(u)| = 27` for `u = (1, [], [], [1], [0])`, hence **`h(d,u) = 3 + 33 + 27 = 63`** by C16's
  formula, matching `eval_overhead` exactly, and `eval_quoted(...).used = 66 = 63 + 3`. ✓
* equality decider `|D| = 64` bytes, `cea6bf9d6835b634`.
* `Quote(BoundVar(0,0))`, `quote_program(Hole)`, `bounded_trace(::Closure, …)` and
  `quote_program(::Closure)` all refuse with `ArgumentError`. ✓
* T = 1 trace: 2 rows — row 0 `Prim(true)` fuel 1 `running`, row 1 `Value(true)` fuel 0 `accept`,
  result `Value(true)`, `accepts = true`. ✓
* 3SAT: `m = 1`, `M = 2`, **one** template `((1,true),nothing,nothing)`, `accept_variable = 1`,
  `answer_variables = (a=[0], b=[0])` (the answer bits *do not occur*). My own enumeration of all
  2^6 tuples gives **16 present**, and the compiled relation circuit agrees on all 64. My own
  brute-force satisfiability with `a,b` pinned matches `accepts` on all four answer pairs — but
  **vacuously**: the trivial decider accepts on all four (see N10).
* 5SAT: widths **(0,0,1,1,1)**, five signs, one clause `(nothing,nothing,(1,true),nothing,nothing)`,
  0 copy / 0 equality gadgets, literal blocks = {3}. Padded: `m = 1`, `live = 1`, `s = 6`,
  `m' = 5m+5+s = 16`, gates `[AndGate, NotGate×5]`. My own enumeration: **256/1024 present**,
  circuit agrees on all 1024; my own φ_C sweep: **512/1024 witnesses** (exactly `w_3[2] = 1`). ✓
* Feeding it myself to `frontend_pcp` (GF8, d = 6, tables (0,1)^5, budget 2 500 000, TB0 certified
  points): `verify_certificate` passes, `|c_0| = 162 240`, `dependency_coordinates(g_i) = {i}` for
  all five. Then `change_field(…, GF2048, 11)` + `answer_reduce_pcp` + `honest_pcp_strategy`:
  **7/7** `fig:decider-pcp` guard cases accepted (global_consistency, input_consistency, input_axis,
  input_diagonal, proof_consistency, proof_simultaneous_axis, game). ✓
* Equality decider `λ n x y a b . (a == b)`: `T=0,1,2 → OutOfFuel`, **`T = 3` is the minimal
  accepting fuel** *under the implemented charge table* (see N3), rows 4; 3SAT `m=3 M=8` **15
  clauses** (raw 15, aux 0, eliminated 0), answers `(a=[1], b=[2])`, accept 3; 5SAT widths
  (0,0,3,3,3), **47 = 15 formula + 4 copy + 28 equality**; padded `m=3 live=423 s=492 m'=512`;
  `arith_q` under the witness-(i) budget → **`ExpansionRefused(estimate = 279 936, budget = 160 000)`**.
  With **my own DPLL** (unit + pure-literal + last-literal branching, written independently of
  `src/frontend/cook_levin.jl`'s `dpll`) over the 26 block variables with `a, b` pinned:
  φ5 satisfiable **⟺ a == b** on all four pairs. ✓

Every number in `briefs/23-tb3.last.md` that I checked reproduces. The arithmetic is not in dispute.

---

## 2. Objections

### N1 (MAJOR) — the bounded trace's row content is not evidence-bearing: the rows can be reduced to the outcome flag alone and all 162 TB3 assertions stay green

**Location:** `src/frontend/bounded_trace.jl` `_row_fields` / `_trace_certificate`;
`src/frontend/cook_levin.jl` `_tableau_formula`; `test/tb3_frontend.jl` testsets (c)–(g);
DESIGN §1.2 invariant row `bounded evaluation trace | CHECKED | transition-by-transition trace`.

**Computation.** Two critic mutants, applied the way `test/mutations/run.jl` applies its own
(`Base.include(MIPStarLambda, mutated_file)`), then the whole `test/tb3_frontend.jl`:

* **N2a** — `push!(fields, :control => (c isa Ret ? … : _term_key(c, points)))` replaced by
  `push!(fields, :control => (:constant,))`. **SURVIVED** (exit 0, 162/162). Silently changes the
  equality fixture from 15 → **7** 3SAT clauses, 47 → **27** 5SAT clauses (copy 4, eq **16**), live
  gates 423 → **247**. Nothing asserts those numbers; they are printed only.
* **N2b** — `_row_fields` returns `Pair{Symbol,Any}[:outcome => _outcome(m)]` and nothing else (no
  control, no continuation frames, no environment frames). **SURVIVED** (exit 0, 162/162), and the
  entire trivial-fixture pipeline is *numerically unchanged*: `m=1 M=2 clauses=1 present=16/64`,
  `widths=(0,0,1,1,1)`, `padded m=1 s=6 m'=16 present=256/1024 witnesses=512/1024`,
  `|c0| (i)=10140 (ii)=162240`, TB2 decider **7/7**. Only the equality fixture shrinks
  (`3SAT m=2 M=4 clauses=5`, `5SAT 21`, `padded m=2 s=241 m'=256`).

So: the *only* content of a trace row that any test constrains is the acceptance flag. The whole
generated PCP that TB2 accepts is reproduced bit-for-bit by a "trace" whose rows are literally
`(outcome)`. `_replay_trace` cannot detect this because it recomputes the rows with the same
(mutated) `_trace_rows` — it is a determinism check, not an oracle. DESIGN §1.2 grades this
invariant **CHECKED** with representation "transition-by-transition trace"; on the evidence in the
tree that grade is unearned.

**FIX DEMAND.** (a) Add a red-capable test that pins the row *contents* — e.g. for the equality
fixture at T = 3, assert the ordered `Symbol` key set of each row's `fields` and a stable digest of
their values, plus the three control labels (`Prim(eq)`/`BoundVar(0,3)`/… ). (b) Register a mutant
that constantizes `_row_fields` (my N2a is a one-line registry entry) and show it KILLED.
(c) Until (a)+(b) land, DESIGN §1.2's row must read
`bounded evaluation trace | CHECKED (result and row count) / ASSUMED (row contents)`.

**SURVIVING WEAKER STATEMENT.** `bounded_trace` decodes the canonical bytes, produces exactly
`T + 1` rows with the halting self-loop padding, and its `result`/`accepts` are correct and
red-capable (M-acc).

---

### N2 (MAJOR) — a borrowed front-end certificate passes: `|D|` and the quote hash reach the PCP tree unauthenticated

**Location:** `src/frontend/decouple5.jl` `frontend_pcp` (the `:Tseitin` graft);
`src/verifiers/pcp.jl` `_bind_evidence` / `_bind_certificate`; `test/tb3_frontend.jl:481`.

**Computation.** Build two *different* deciders whose padded relations coincide:

```
A = λ n x y a b . true                  |D| = 33  fnv1a64 = f8561ef8c5761695
B = λ n x y a b . not(false)   (T=2)    |D| = 51  fnv1a64 = b22faceec70cb02c
both pad to m = 1, s = 6, m' = 16, and A.clauses == B.clauses
```

Then `frontend_pcp(Checked(B.padded_term, A.padded_certificate), GF8, 6, …)`:

```
GRAFT verify passed = true   rule = certificate_replay
[CHECKED] BoundedTrace | T = 1 body transitions …; accepts = true; fnv1a64 = f8561ef8c5761695
[CHECKED] Quote        | |D| = 33 bytes; fnv1a64 = f8561ef8c5761695; sort = Decider
```

i.e. a PCP proof for **B** carries, and passes verification with, **A**'s description size and hash.
`_bind_certificate` anchors the grafted subtree to `proof.tf`, which *is* B's `tf` — so the binding
check `locate(proof) === anchor` succeeds, and every front-end replay then falls through
`x isa Pad5Type ? x : captured` to A's captured objects, none of which is ever compared with the
circuit the proof is about.

The existing test is not evidence against this: I instrumented it and
`verify_certificate(Checked(plain.proof, fx.certificate))` refuses at
`rule = certificate_binding, location = **Tseitin**` — the TB0/r4 binding on the Tseitin formula,
not at any TB3 node. No test exercises the front-end binding at all, and no registered mutant targets
`tb3_pcp` (the runner shows baselines only for `tb3_quote`, `tb3_eval`, `tb3_cook_levin`,
`tb3_decouple`).

**FIX DEMAND.** The grafted node's replay must bind the front-end object to the proof it is attached
to: check `padded.circuit === proof.tf.circuit` (or `tseitin(padded.circuit).term == proof.tf`)
*inside* `_replay_pad5`/the graft node, so the chain Quote → … → Pad5 → Tseitin is closed by
identity. Add a red test that grafts a foreign padded certificate (the A/B pair above works
verbatim) and require `:certificate_binding` (or a new `:frontend_binding`) at the `:Pad5` node.
Then, and only then, may a claim row say the quote hash and `|D|` "propagate into the PCP
certificate".

**SURVIVING WEAKER STATEMENT.** A whole TB3 certificate attached to a *foreign* `PCPProof` object is
refused with `:certificate_binding`; and every front-end node replays its own captured object
consistently.

---

### N3 (MAJOR) — the implemented charge table and codec are not C16's; the reported fuel figures (3, 5, `T=1`, `T=3`, `h = 63`, Fix = 1) belong to a strictly cheaper machine and a different serialization

**Location:** `src/ir/programs.jl` `step!` / `_charge!` / `settle!` and its header comment at L651;
`src/ir/programs.jl` `_encode_*` / `_quoted_bytes`; `docs/analytic/parts/part2a.tex` L437 (`|t| :=
|ser(t)|` **in bits**), L429 (**four-bit** constructor tag, ν prefix code), L606–L612, L654–L655;
`claims/CLAIMS.md` C16, C18.

**Computation.**

1. **Administrative transitions.** part2a §8.3 L606: *"All administrative CEK transitions cost one
   unit. They include variable lookup, creating a closure, **pushing or popping one continuation
   frame**, selecting a Boolean branch, and **returning a value**."* The implementation folds all of
   those into the following contraction (its own comment says so) and `settle!` pops delimiters and
   recognises the final value **free of charge**. Consequence:
   `eval_program(λnxyab.true, u, 100).used = **3**` (closure + beta + Prim), whereas §8.3 charges at
   least 5 for the same run (closure, return, frame pop/beta, Prim, return). Every fuel number the
   rung reports — `trivial uses 3`, `equality uses 5`, `T = 1` and `T = 3` as *minimal accepting
   fuel*, `T + 2` for the frame installation — is a figure of the folded table, not of §8.3.
2. **`Fix` costs 1, not `c_Y = 3`.** `step!`: `elseif c isa Fix; _charge!(m, 1)`. part2a L654–655:
   *"Including the application and binding frames, an unfolding costs the fixed constant `c_Y = 3`"*,
   and C18's row states `c_Y = 3` as part of the claim. Direct contradiction, one line.
3. **Units.** def:l-serialization (L425–L443) fixes a **four-bit** tag, a ν prefix code
   (`|ν(m)| = 2ℓ+1`), and `|t| := |ser(t)|` **in bits**. The code uses a 1-byte tag, fixed-width
   4-byte big-endian integer fields, and `description_size` in **bytes**. So `h(d,u) = 3 + 33 + 27 =
   63` is not C16's `h(d,u)`; the additive constant 3 does not scale with the unit, so the two are
   genuinely different overheads, not a change of units.
4. Minor, same family: `src/ir/programs.jl:651` cites "analytic part2a 8.5"; §8 has only §8.1–§8.4.

None of this is hidden — the proposer listed (3) as a DEVIATION and the code comments (1) — but a
disclosed divergence is still a divergence, and it is exactly the divergence that decides whether
TB3 is machine evidence for C16.

**FIX DEMAND.** Choose one and write it down in both places: (a) amend part2a §8.3 to the
implemented folded charge table and §8.1 to the implemented byte codec, and restate C16/C18's
constants accordingly (`c_Y` becomes 1, `h` becomes the byte-unit overhead); or (b) keep §8 as the
mathematics and add to DESIGN §1.1 and to the C16/C18 rows an explicit clause: *the implementation
instantiates `L` with a coarser charge (context navigation folded), a byte-unit fixed-width codec,
and `c_Y = 1`; TB3 is evidence for that instantiation, not for §8's constants.* Fix the `8.5` cite.

**SURVIVING WEAKER STATEMENT.** On the two fixtures the implementation exhibits determinism, the
`Value`/`OutOfFuel`/`SortError` trichotomy, fuel monotonicity with *exact* usage
(`used = 3` at fuel 3, 4, 8, 103), the Quote/Eval equation in the *shape*
`Eval(Quote t, u; f + h) = eval(t, u; f)` using exactly `h + c`, and the exact affine-hole
specialization size identity — all of which are the structural content of C16 in the implemented
unit.

---

### N4 (MINOR) — the Cook–Levin honesty leaves do not disclose the actual mechanism

The CITED `:CookLevinGeneral` display says *"field alphabets enumerated over all N answer inputs,
not decoded from an O(log T + log sigma)-bit window; enc_Gamma answer format not enforced (raw
answer bits)"*, and the ASSUMED `:RawAnswerBlocks` covers the enc_Γ / `(10)^{L/2-T}` clauses. That is
true as far as it goes. It omits four further departures I found by reading `_tableau_formula`:

1. the transition constraints are a **greedily minimised function fit**: for each row-`i` field the
   code checks that the field is a function of (row `i-1` fields, answer bits) *across the enumerated
   inputs*, greedily drops candidates, and emits one implication per **observed** support key — off-table
   keys are unconstrained;
2. there are **no initialisation clauses at all** (the loop is `for i in 2:row_count`); row 0 is
   "asserted" only by the accident that its fields have singleton alphabets, hence width 0;
3. no fuel counter, head marker, endmarker, track structure or window function `ω` appears anywhere,
   so `lem:transition-window` has no executable counterpart;
4. C19's **`2F` reserved bits per answer block** are absent (the answers are 1-bit blocks read raw);
   the ASSUMED node names the *format*, not the *reservation*.

No CHECKED node states a falsehood — I checked each display against its replay. But a reader of the
trace cannot tell (1)–(4) from the tree.

**FIX DEMAND.** Extend the `:CookLevinGeneral` display to name (1)–(3) and the `:RawAnswerBlocks`
display to name (4); add to DESIGN §1.2's invariant table a row
`general Cook--Levin locality | ASSUMED | fixture uses an enumerated per-field function fit`.

---

### N5 (MINOR) — CHECKED nodes without registered mutations (rk-light law 4)

The five registered TB3 mutants touch `bounded_trace.jl` (×2), `programs.jl` (×2) and
`decouple5.jl::_slot_block` (×1). Consequently:

* `:Pad5` — no mutant. My critic mutant **N3** (`for _ in 1:(s - live.gate_count)` →
  `… - live.gate_count - 1`) is **KILLED** at `test/tb3_frontend.jl:395,398`, so this is a one-line
  registry addition.
* the equality-gadget set of `decouple5` — no mutant. My critic mutant **N1** (drop
  `Clause5((nothing,nothing,nothing,(u,o),(u,!o)))`, i.e. the `u_4 = u_5` pair) is **KILLED** at
  `test/tb3_frontend.jl:433,434`. Register it.
* targets `tb3_pcp` and `tb3_equality` have **no** mutant at all (the runner prints baselines only for
  `tb3_quote`, `tb3_eval`, `tb3_cook_levin`, `tb3_decouple`) — so the front-end→PCP graft, the TB2
  seven-case acceptance and the `ExpansionRefused` snapshot are entirely unmutated. This is the same
  hole N2 lives in.

**FIX DEMAND.** Register the two mutants above (both already shown red by me) and one mutant on the
`tb3_pcp` target once N2's binding check exists.

---

### N6 (MINOR) — `CompilationRefused` is exported and proposed for DESIGN §1.2, but no test reaches it

`grep` over `test/` finds no occurrence. `gate_budget` is already a keyword on `cook_levin`,
`decouple5` and `pad5`, so `decouple5(sat3; gate_budget = 1)` is a one-line red-capable test.
**FIX DEMAND:** add that test before the DESIGN §1.2 sentence lands; a documented refusal path with no
executed branch is a promise, not a checked invariant.

---

### N7 (MINOR) — the padded object does not check obligation 1 of `prop:explicit-padded-succinct-deciders`

`_replay_pad5` checks `ispow2(m')`, `m' = 5m+5+s`, `gate_count = s`, `m = max(index_widths)`, the
block extents and the exhaustive relation — but not **`2^m ≥ 2T`**
(`gt-10-answer-reduction.tex` L1237–L1239). Both fixtures satisfy it (m = 1, 2T = 2; m = 3, 2T = 6),
so this is one line and cannot regress the rung. **FIX DEMAND:** add it to the shape check and to the
`:Pad5` display.

---

### N8 (MINOR) — `decouple5` emits a proper subset of the paper's gadget set with no visible residue

`prop:explicit-succinct-deciders` (gt-10 L1046–L1060) makes the circuit present on
`(i_3 = i_4) ∧ (o_3 ≠ o_4)` and `(i_4 = i_5) ∧ (o_4 ≠ o_5)` for **every** index — that is what yields
`w_1 = w_2 = w_3` at L1105–L1112. The code emits the pair only for variables occurring in ≥ 2 of the
three 3SAT slots. I confirmed with my own DPLL that this is satisfiability-preserving on the equality
fixture (φ5 sat ⟺ a == b on all four pairs), and the source comment says why. But the
`:Decouple5` display reports `equality 28` as though it were the construction, and no node records
the omission; DD-17 and §1.2 both cite the paper's relation as the thing being represented.
**FIX DEMAND:** a SOURCE-deviation/ASSUMED leaf naming the omitted per-index gadgets, or emit the
full set. (The *placement* is correct and matches C19 exactly: literal 1 → block 3 = `w_1`, 2 → 4,
3 → 5, copy gadgets tying blocks 1, 2 to `w_1`; `_slot_block(k) = 2 + k`, verified.)

---

### N9 (MINOR) — `Aborted` is a fourth outcome outside the declared trichotomy

DESIGN §1.1/DD-2 and `thm:l-determinism` promise exactly `Value | OutOfFuel | TypeError`. `step!`
adds `Aborted(:hard_cap)` at `DEFAULT_HARD_CAP = 1_000_000` uncharged steps. I could not reach it
with a legitimate program up to fuel 5 × 10⁶ (`Fix(Eval(self_code, (), 4e9))` returns `OutOfFuel`
with `used = fuel` at 300 / 10⁵ / 10⁶ / 2×10⁶ / 5×10⁶, because each unfolding charges ≈ 47), but it
is reachable in principle whenever charged transitions become cheap relative to `hard_cap`.
**FIX DEMAND:** state in DESIGN §1.1 that `Aborted` is a host guard outside the semantics and can only
fire when `steps > hard_cap`, and either scale the default cap with the requested fuel or assert
`hard_cap ≥ fuel` in `eval_program`/`eval_quoted`.

---

### N10 (MINOR) — the trivial fixture is vacuous for the "satisfiable iff accepts" clause, and it is the *only* fixture that reaches `build_pcp`

For `λ n x y a b . true` all four answer pairs accept, the answer variables are eliminated
(`answer_variables = (a=[0], b=[0])`, index 0 = padding), and the entire 3SAT collapses to the single
unit clause `[accept]`. So test (d)'s and test (e)'s exhaustive "⟺" quantifications are `true == true`
four times. Every discriminating instance of the equivalence lives in the equality fixture — which
never reaches `build_pcp` (`ExpansionRefused`) — and in M-acc. **FIX DEMAND:** say this explicitly in
the C10 row, so that "satisfiable iff D accepts … exhaustively over 2^M" is not read as
discriminating evidence on the fixture that feeds the PCP.

---

**Counts: 3 MAJOR (N1, N2, N3), 7 MINOR (N4–N10), 0 CRITICAL.**
Top three: **N1** (trace rows carry no checked content — two critic mutants survive),
**N2** (borrowed front-end certificate passes; `|D|`/hash propagation is unauthenticated),
**N3** (charge table and codec are not C16's/C18's — `c_Y = 1` vs 3, folded administrative
transitions, bytes vs bits).

---

## 3. Critic mutations

| id | mutation | file | result |
|---|---|---|---|
| **C-N1** | drop the `u_4 = u_5` equality gadget pair | `src/frontend/decouple5.jl` | **KILLED** (exit 1; `test/tb3_frontend.jl:433,434`) |
| **C-N2a** | `_row_fields` `:control` → `(:constant,)` | `src/frontend/bounded_trace.jl` | **SURVIVED** (exit 0, 162/162; equality 15→7 / 47→27 / live 423→247) |
| **C-N2b** | `_row_fields` returns only `:outcome` | `src/frontend/bounded_trace.jl` | **SURVIVED** (exit 0, 162/162; trivial pipeline numerically identical, TB2 7/7) |
| **C-N3** | pad5 emits one padding gate too few | `src/frontend/decouple5.jl` | **KILLED** (exit 1; `test/tb3_frontend.jl:395,398`) |

C-N2a and C-N2b are the two survivors; their red tests are the FIX DEMAND of N1.
C-N1 and C-N3 are killed and must be **registered** (FIX DEMAND of N5).

---

## 4. Fidelity of the Cook–Levin surrogate — graded honestly

**Grade: fixture-only surrogate, D.** Of the paper's `prop:standard-succinct-sat` /
analytic `thm:l-succinct-sat` construction, what is implemented is: a fixed-length row sequence with
halting-self-loop padding, a per-row coded-field alphabet, an accept clause, `≤ 3`-literal chain
splitting, and the succinct *relation-circuit* interface `C(i_1,i_2,i_3,o_1,o_2,o_3)` of
`def:succinct-formulas` with don't-care families (the complementary-pair argument is sound — I
verified `(l_1 ∨ l_2 ∨ v) ∧ (l_1 ∨ l_2 ∨ ¬v) ≡ l_1 ∨ l_2` is what makes 16/64 correct). What is
**not** implemented: `Γ_L`, the track count `r_0`, head markers, endmarkers, the window function `ω`,
initialisation clauses, format clauses, the binary fuel counter, the `O(log F + log σ)` index decode,
the `poly` size/time bound, and the `2F`-bit reserved answer blocks with `enc_Γ`. The transition
constraints are an enumerated, greedily minimised **function fit** over all `2^{|a|+|b|}` answer
inputs. C-N2b proves the fit does not depend on the trace at all beyond the outcome.

**Is the CITED/ASSUMED labelling correct and visible?** Partially. `[CITED] CookLevinGeneral` and
`[ASSUMED] RawAnswerBlocks` do appear in the printed tree (I reproduced the printout), their gt
labels exist and their line ranges bracket the right text (`prop:standard-succinct-sat` label at
`gt-10:237`; the copy/blank-padding clauses at `gt-10:1046–1112`, inside the cited 1036–1130;
`def:decoupled-5sat` inside 920–979; `prop:explicit-padded-succinct-deciders` label at
`gt-10:1226`). But the leaves name only the alphabet enumeration and the enc_Γ format — see N4 for
the four undisclosed departures. **No CHECKED node overclaims**: I read each `facts.display` against
its `replay` and every displayed quantity is one the replay recomputes. The overclaim risk is
structural, not textual: `_replay_cook_levin`, `_replay_decouple5`, `_replay_pad5` and
`_replay_trace` all rebuild with the *same* function, so a CHECKED grade here certifies determinism
plus the exhaustive relation/equivalence sweeps, and nothing about faithfulness to the source.

**`decouple5`'s five-block form vs the paper: correct in shape.** Clause form
`x_{1,i_1}^{o_1} ∨ … ∨ x_{5,i_5}^{o_5}` (eq:5sat, `gt-10:930–965`) ✓; five possibly unequal blocks
with `N_i = 2^{n_i}` ✓; literal 1 → `w_1`, 2 → `w_2`, 3 → `w_3` (`gt-10:1105–1107`) ✓; copy gadgets
tying blocks 1, 2 into `w_1` at the `a`-then-`b` prefix positions ✓; both "undesirable properties"
(three reads of one assignment; `a, b` buried inside the assignment) are structurally addressed ✓.
Deviations: N8 (gadget subset), N7 (`2^m ≥ 2T` unchecked), and the padding gates are **dead** — five
`NotGate`s chained off the output while the output stays `live.output`, so they contribute variables
to Tseitin but nothing to `C`. That fact is not in the `:Pad5` display ("padding 5 NOT gates" does
not say *dead*) and must be.

---

## 5. Claim decisions

### C10 — **HOLD** (not promoted to TESTED this round)

Every arithmetic clause of the proposed row reproduces under independent recomputation. It is held
on three named steps, all MAJOR:

* **N1** — the row says "`bounded_trace` rows replay from the canonical bytes". They do; but with the
  rows reduced to the outcome flag every downstream number is unchanged, so the phrase reads as
  evidence it is not. Needs the row-content test + registered mutant.
* **N2** — the row's downstream half ("the GENERATED circuit passes `build_pcp` … and TB2's decider
  accepts") is true, but the graft that carries `|D|`/hash into that tree admits a foreign front end.
  Needs the binding check + red test.
* **N5** — `:Pad5` and the equality-gadget set are CHECKED with no registered mutation, and the
  `tb3_pcp` target has none at all. Two one-line registry additions, both already shown red by me.

**AUTHORIZED VERBATIM (admissible as TESTED once N1, N2 and N5 are discharged; not before):**

> | C10 | (Front-end faithfulness on the fixtures) For `D = λ n x y a b . true` (T = 1, `|D| = 33`
> bytes, fnv1a64 `f8561ef8c5761695`) and `D = λ n x y a b . (a == b)` (T = 3, `|D| = 64` bytes),
> with one-bit answers and `x = y = ()`: `bounded_trace` decodes the canonical bytes and returns
> `T+1` rows with halting-self-loop padding, and its result and acceptance flag replay; `cook_levin`
> emits a `Succinct3SAT` (`m=1, M=2`, 1 clause family, 16/64 present; `m=3, M=8`, 15 clauses) whose
> relation circuit matches the template relation exhaustively and which, with the answer bits pinned,
> is satisfiable iff `D` accepts on each of the four answer pairs — a discriminating test only for
> the equality fixture, since the trivial fixture accepts on all four; `decouple5` emits a
> `SuccinctDecoupled5SAT` with five index blocks and five signs, 3SAT literals confined to blocks
> 3–5, copy gadgets tying blocks 1–2 into block 3, and equality gadgets for multi-slot variables
> ((0,0,1,1,1)/1 clause; (0,0,3,3,3)/47 = 15 + 4 + 28), satisfiable iff `D` accepts (exhaustive over
> 256 witnesses; DPLL with the answer blocks pinned); `pad5` gives `m=1, s=6, m'=16` (one live
> `AND(x_3,o_3)` plus five **dead** NOT gates) with the padded relation equal to the decoupled one on
> all 1024 tuples and 512/1024 `phi_C` witnesses; the GENERATED circuit passes `build_pcp` for both
> retained witnesses (`|c_0| = 10 140` and `162 240` under budgets 160 000 / 2 500 000) and TB2's
> answer-reduced decider accepts the honest strategy on all seven `fig:decider-pcp` guard cases;
> the equality fixture's padded circuit (`m=3`, live 423, `s=492`, `m'=512`) is refused by `arith_q`
> with `ExpansionRefused(279 936 > 160 000)`. Red-capable by M-acc, M-size, M-fuel, M-decouple,
> M-closure, the pad5 padding mutant and the `u_4 = u_5` gadget mutant. The fuel figures are those of
> the implemented charge table (§ DESIGN 1.1), which folds continuation navigation into the following
> contraction and charges `c_Y = 1`; they are not `docs/analytic` §8.3's. The Cook--Levin step is a
> fixture-only surrogate: field alphabets are enumerated over all `2^{|a|+|b|}` answer inputs and the
> transition constraints are a per-field function fit, with no window function, initialisation,
> format or `2F`-reserved-answer clauses. | TESTED | C1, C9, C16, C19 | `test/tb3_frontend.jl`,
> `src/ir/programs.jl`, `src/frontend/{bounded_trace,cook_levin,decouple5}.jl` |
> `verdicts/tb3-r1.md` | — |

### C16 — **RE-AFFIRM SKETCH**

TB3 is the first machine evidence for C16 and it is real evidence, but it does not cover the
statement. What it *does* cover, on two fixtures and an 11-term codec gallery: determinism and the
outcome trichotomy (modulo N9's `Aborted`); fuel monotonicity **with exact usage** (`used = 3` at
fuel 3, 4, 8, 103; `used = 5` for the equality decider, `OutOfFuel` at 4); the Quote/Eval equation
in the shape `Eval(Quote t, u; f + h) = eval(t, u; f)` with the left side using exactly `h + c`
(`63 + 3 = 66`, verified); the exact affine-hole `Specialize` size identity
`|Specialize(P,σ)| = |P| − Σ|Hole| + Σ|σ(h)|` (verified on a two-branch fixture, with duplicate-hole,
missing-hole, extra-hole and open-replacement all refused); and `SortError` (never a host exception)
on six distinct contract failures. What it does **not** cover: the charge table itself (N3 — the
implementation is strictly cheaper than §8.3 and charges `c_Y = 1` against C16/C18's 3), the
serialization (N3 — bytes with a fixed-width codec vs §8.1's bit-counted ν code with 4-bit tags,
hence a different `h(d,u)`), and the universal quantification over all closed terms/arguments/fuels.
**SKETCH stands.** The C16 row should gain the sentence: *the implemented instantiation folds
context navigation into the following contraction and measures `|·|` in bytes; TB3 checks the
identities in that instantiation.*

### C19 — **RE-AFFIRM SKETCH**

Two changes to the row are required and one is not a promotion. (i) The row's final sentence *"no
`bounded_trace`, `cook_levin` or `decouple5` implementation exists"* is now **false** and must be
replaced (likewise `docs/analytic/parts/part2b.tex` L262–L270, which says the same). (ii) What TB3
actually establishes is the *decoupled-form* half of C19's last clause, on fixtures: the first,
second and third 3SAT literals land in `u_3, u_4, u_5`, equality gadgets restore `u_3 = u_4 = u_5`
(for multi-slot variables — N8), copy gadgets tie `a, b` to `u_3`, and the resulting relation is
satisfiable with `a, b` pinned iff the decider accepts (exhaustive over 256 witnesses for the trivial
fixture; my own DPLL over 26 block variables for the equality fixture). Everything in the first two
thirds of C19 — `Γ_L`, `r_0`, `ω`, the transition-window lemma's converse, the `O(log F + log σ)`
index width, the `poly(log n, log F, Q, σ)` size and construction time, and the `2F` reserved bits
per answer block — has **no** executable counterpart, and C-N2b shows the implemented transformation
does not even weakly instantiate the window lemma. **SKETCH stands**, with the final sentence
rewritten to: *`bounded_trace`, `cook_levin` and `decouple5` now exist and implement the decoupled
five-block placement and its guarantee on two one-bit-answer fixtures; the alphabet, window function
and answer-block reservation are not implemented and remain CITED/ASSUMED.*

---

## 6. DESIGN wording adjudication (the proposer's three proposals)

**§5.5 — ADMIT with amendments.** The claim that the front end emits a relation "extensionally equal
to TB0's 128-clause relation" and "compiles it to TB0's six-gate circuit" is **false** and must go;
my independent enumeration gives the generated relation as `AND(x_3, o_3)` with **256/1024** present
tuples and **512/1024** `phi_C` witnesses, `m = 1`, `s = 6` (one live gate + five padding),
`m' = 16`. The proposer's replacement text is factually correct. Required amendments before it lands:
(a) the five padding gates must be described as **dead** (chained off the output, output unchanged) —
otherwise a reader assumes they participate in `C`; (b) the sentence *"Confidence is medium: measure
whether the front-end circuit normalization preserves the exact six-gate fixture before proceeding"*
must be replaced by a statement that it does **not**, and that TB3's PCP evidence therefore rests on a
different circuit from TB0's (the five `g_i` are still all non-constant with
`dependency_coordinates(g_i) = {i}`, so TB2's block-locality evidence survives — I re-verified 7/7);
(c) `T = body transitions, eval(D,u;T+2) installing the argument frame` and the equality decider's
`T = 3` must both be qualified by N3's charge-table clause; (d) keep the existing directive to feed
**both** retained witnesses to `build_pcp` and only witness (ii) to TB2 — the tests honour it.

**§1.1 — ADMIT in part, REFUSE in part.** ADMIT: the rename `TypeError → SortError` (and the same
rename in `docs/definitions.md` §F, which still says `TypeError`); `Quote(code, sort)` carrying its
sort `A`; literal `PrimName`s (`Bool`, `Int`, `Vector{Bool}`) as the realisation of DESIGN's
*"`true` abbreviates `Prim(true,Concrete(1),())`"*; `Aborted` **as a host guard explicitly outside the
semantics**, with N9's caveat. **REFUSE** the bare proposal "byte-unit `|d|`": §1.1 already says
"canonical byte count", so there is nothing to change there — the missing text is the *reconciliation*
demanded in N3, namely an explicit clause that the implementation's codec is not
`def:l-serialization`'s ν code and that `|·|` is bytes there and bits in part2a, so `h(d,u)` and
`c_Y` differ between the two. That clause is required, the proposed one is not sufficient.

**§1.2 — ADMIT conditionally.** `CompilationRefused` may be listed beside `ExpansionRefused` **once a
test drives it** (N6). Two further §1.2 edits are required, not proposed: the
`bounded evaluation trace` invariant row must be split CHECKED/ASSUMED per N1, and a
`general Cook--Levin locality | ASSUMED` row must be added per N4.

---

## 7. Elegance — three places the code is more complicated than the mathematics

1. **The certificate is worked around rather than extended.** The pattern
   `replay = x -> _replay_foo(x isa FooType ? x : captured_foo)` appears in all five front-end nodes,
   because `verify_certificate` hands every node the *root* term and `_bind_evidence` admits only
   proof components. DESIGN §3 says a CHECKED node "is recomputed against the attached term"; here
   four of five nodes ignore the attached term entirely. The mathematics is a tree of judgements each
   about its own object; the code is a tree of closures each about a captured object. This is the
   direct cause of N2, and the proposer's own API REQUEST 1 (per-node terms, or a first-class
   upstream-evidence slot) is the right fix — it would delete the fallback in all five places.
2. **Four representations of one relation.** `Clause3`/`Clause5` (`NTuple{k,Union{Nothing,Tuple}}`),
   `_template_matches`, `relation_tuples` + `relation_input` (bit layout), and `compile_relation`
   (an AND/OR tree) all encode "which signed indexed clauses are present", and `_check_relation`
   exists only to reconcile the last two. `def:succinct-formulas` has exactly one object: a circuit
   whose value *is* membership. A single `present :: (indices, signs) -> Bool` plus one compiler,
   with the tuple enumeration living in the test, would halve this.
3. **`_replay_cook_levin` rebuilds the world.** It re-runs `_build_3sat`, which re-traces all
   `2^{|a|+|b|}` answer inputs, then re-checks the relation circuit (already checked one line earlier
   in `cook_levin` for the display — the exhaustive sweep is done twice per constructor in all three
   of `cook_levin`, `decouple5`, `pad5`), then re-traces every answer input a third time for the
   equivalence loop. The mathematics has one statement ("the formula is satisfiable iff the term
   accepts"); the code checks it three times over and calls the composite a replay. Honourable
   mention: `Succinct3SAT` stores its own `BoundedTrace` and `Tableau`, so the term carries its
   provenance and the "replay against the attached term" is tautologically satisfiable — the type is
   doing the certificate's job.

---

## 8. Forward look — TB4 (brief 24) gaps

1. **`YCode` does not exist.** No constructor, no export, no test; DESIGN §1.1 and C18 both name it
   (`c_Y = 3`), and TB4's `D_{M,λ} = YCode(Ψ_{M,λ})` cannot be written. `Fix` exists and unfolds
   correctly (`self_code ↦ Quote(Fix(P))`, verified) but charges **1**, not `c_Y = 3` (N3).
2. **The primitives of Ψ are unregistered.** `halts_within` and `quoted_pair` are named in DESIGN
   §1.1 but absent from `PRIMITIVES`, so `_primitive` returns `nothing` and Ψ_{M,λ} evaluates to
   `SortError(:unknown_primitive)`. It round-trips as bytes (test (a)'s gallery proves that) but is
   not evaluable — TB4 must either register them with charges or declare Ψ syntax-only.
3. **Sorts are unchecked `Symbol`s.** `Quoted{A}` carries `A` as a bare symbol; `MachineDesc`,
   `Level`, `Sampler`, `Compressor`, `Quoted{Decider}` are never validated, and
   `Specialize` is "sort-agnostic" by construction. TB4's `Hole(self_code, Quoted{Decider})` and the
   `P{MachineDesc}`/`P{Level}` literals of definitions.md §F therefore have no enforcement.
4. **`FuelBound` disagrees across the three sources.** DESIGN §1.1 `FuelBound(P{Nat},P{Nat})`,
   `docs/definitions.md` §F `FuelBound(P{Nat},P{Level})`, code `_fuel_value` requires two `Int`s and
   returns `nothing` (→ `SortError`) when `λ·log₂ n > 62`. Ψ_{M,λ} uses `FuelBound(n, lambda)`;
   pick one before TB4 writes it.
5. **`Specialize` coverage is exact-match.** `names == Set(keys(counts))` and `holes()` deletes
   `self_code` under `Fix`, so `specialize(Fix(Ψ), (:self_code => …))` throws (no holes to cover);
   TB4 must specialize the **body** `Ψ` and re-`Fix`. Worth a contract note, since the fixed-point
   equation in DESIGN §1.1 is written on `Fix(P)`.
6. **The four contracts have no carrier.** `Verifier[QuestionLength, AnswerLength, Runtime, Gap,
   Levels]` (definitions.md §F, DESIGN §1.6) is not reachable from `Quoted`/`Program`; TB4's
   "9-level `StubVerifier`" assertions need a bridge that does not exist in the IR yet.
7. **The graft will recur.** `Compress = Repeat ∘ AnswerReduce ∘ Introspect` will attach upstream
   description evidence to a downstream proof exactly as `frontend_pcp` does; unless N2's binding
   check lands first, TB4 inherits the same unauthenticated propagation, one level deeper.
8. **Circuit capacity.** `Circuit.gates::Tuple` compiles to ~500 gates and `CompilationRefused` caps
   at 4096; the equality fixture already sits at 423 live gates. TB4 is stub-level so this is not
   blocking, but a vector-backed `Circuit` is a prerequisite for anything past it.

---

VERDICT: FAIL(N1,N2,N3)
