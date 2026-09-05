# Verdict — TB4 r1 (critic, Opus): the Compress contract skeleton, Hole/Specialize/YCode, Ψ_{M,λ} and D = Y Ψ

Target: ARCHIVED tree at `278b1ac`, extracted with `git archive 278b1ac | tar -x` into
`…/scratchpad/critic-tb4-r1/tree` and instantiated there. Nothing in the live tree was read except
`claims/CLAIMS.md`; nothing outside this file was written; no git state was changed.

**VERDICT LINE AT THE BOTTOM.** Objections: 5 MAJOR, 9 MINOR, 4 NOTE.

---

## 0. Runs, walls, load, governor

`powerprofilesctl get` → **performance** for every run below.

| run | wall | result | `uptime` before / after |
|---|---|---|---|
| cold `Pkg.instantiate()` + precompile | `real 1m23,086s` (package image 69.0 s) | 1 dep precompiled | — |
| `julia --project=. test/runtests.jl` | `real 1m16,802s`, exit 0 | **1253/1253**; TB0 body **16.226 s** (gate 60), TB4 body **6.055 s** (budget 5.0) | `11:06:01 up 2:18, load 2,47 2,54 2,95` / `11:07:18 up 2:19, load 2,10 2,34 2,84` |
| `julia --project=. test/mutations/run.jl` | `real 11m17,904s`, exit 0 | **`MUTATION REGISTRY: killed=115/115 baselines ok=55/55 wall=677.6 s`**; all 13 TB4 mutants KILLED with passing baselines | `11:07:35 up 2:20, load 2,29 2,37 2,84` / `11:18:53 up 2:31, load 3,11 5,76 5,00` (peak ≈ 9,2 during the 4-way run) |
| critic's 2 new mutants (full TB4 file each, 7/7 testsets) | `real 0m15,865s` | both **SURVIVED**, exit 0 | `11:19:53 up 2:32, load 1,73 4,88 4,74` / `11:20:08 load 1,79 4,74 4,69` |
| critic recomputation scripts (fuel sweep, chains, two-verifier, N14 tamper) | ≈ 40 s total | see §1 | load 1,7–2,2 |

Registry wall differs from the proposer's 469.4 s only by contention (my run overlapped nothing but
sat on a machine whose 1-minute load had been ≥ 2 since the suite). TB4's in-suite body measured
**6.055 s against the 5 s budget of `briefs/24-tb4.md` §4**; the proposer measured 4.955 s and 4.594 s
on a quieter machine. Recorded as O13, not as a kill.

## 1. Independent recomputations (all on the archived copy or from the TeX)

**(1) `|D_{M,λ}| = 388` bytes, fnv1a64 `dbf2c0815358657f` — CONFIRMED.** I wrote a self-contained
encoder (`…/critic-tb4-r1/indep_size.jl`) from the codec spec in DESIGN §1.1 plus the tag table, over
a plain nested-tuple term representation, with my own FNV-1a-64, importing nothing from
`MIPStarLambda`. It reproduces the DESIGN §1.1 display and yields

```
critic |term(Fix)|        = 376
critic |D_{M,lambda}|     = 388 bytes          (= 1 header + 4 len + 7 "Decider" + 376)
critic fnv1a64            = dbf2c0815358657f
critic |Psi template|     = 385
|Hole machine| = 31 = |machine literal|;  |Hole lambda| = 22, |nat(1024)| = 15
size law: 385 − 31 − 2·22 + 31 + 2·15 + c_fix(5) = 376
critic |COMPRESS_STUB subterm| = 46 of 376 term bytes
```

The size law is a sum over hole **sites** (λ occurs twice) — see §5, C16.

**(2) The fixed-point equation at every fuel — CONFIRMED, 0 mismatches.** For both machines at
`u = (2, (), (), (1), (0))`, comparing `eval(Fix(P),u;f)` with `eval(specialize(P,{self_code ↦
Quote(Fix P)}),u;f−3)` outcome-for-outcome and used-for-used:

```
HALTING: used=12 result=Value(true)   fuels 3..15  mismatches=0
LOOPING: used=91 result=Value(true)   fuels 3..94  mismatches=0
below c_Y: f=0,1,2 => OutOfFuel(f) on the left; at f=3 => OutOfFuel(3), right at f=0 => OutOfFuel(0)
```

**Hand CEK trace of the halting branch** (`step!`, `src/ir/programs.jl:984-1071`): `Fix` unfold 3 +
`Lambda`→closure 1 + `:apply` β 1 + nullary `MachineDesc` literal 1 + `BoundVar(0,0)` 1 +
`halts_within` charge `1+steps` with `_simulate_machine("0101 0100 0110 0100", 2)` halting at step 2
→ 3 + `IfFrame` selection 1 + `Prim(true)` 1 = **12**. `TWO_STATE_LOOPING = "0100"×4` never halts
(state 0 → 0), so the else branch runs; 91 units reproduced by execution.

**(3) The level chain and the origin order — CONFIRMED, and F-a is real.**
`introspect_levels(9)=5`, `answer_reduce_levels(5)=max(7,5)=7`, `repeat_levels(7)=9` → `[9,5,7,9]`.
Swapping Repeat and AnswerReduce: `repeat_levels(5)=7` and `answer_reduce_levels(7)=9` → **the same
`[9,5,7,9]`**. On a hand-built `Introspect → Repeat → AnswerReduce` chain `_level_chain_ok` returns
`false` — the origin conjunct is doing the work — but the check is **not red-capable** (O1).

**(4) `RuntimeComposition` free parameters — CONFIRMED `(:n, :lambda)`** at all four stages, with
`|D|` free in `(:lambda,)`. Caveats in N2.

**(5) Dependency set with two byte-distinct input verifiers at the same λ — PARTIALLY MET (O9).**
`halting_verifier(TWO_STATE_HALTING,1024)` and `…(TWO_STATE_LOOPING,1024)`: both `|D| = 388`, hashes
`dbf2c0815358657f` and `2b9de4fb8ea9b2f9`, canonical bytes distinct. Both `Compress` outputs carry
the identical tuple `(:lambda,:ell,:mu,:gamma,:D1_size,:tau)`, and the two 67-node traces differ in
**exactly one line** — the relocated input `Quote` node's hash. But `:sampler ∉
fieldnames(StubVerifier)`: there are no sampler bytes at TB4, so DESIGN §12.3's actual obligation
("identical sampler bytes and hashes") has no counterpart here.

**(6) Every CITED leaf's label exists at the cited range — CONFIRMED for the 5 grepped leaves, and I
checked the contract sources too.** `\label{thm:introspection}` gt-08:**785** ∈ 784–817;
`\label{thm:ar}` gt-10:**2077** ∈ 2077–2116; `\label{thm:repetition}` gt-11:**230** ∈ 229–258;
`\label{thm:compression}` gt-12:**27** ∈ 26–53; `\label{lem:compress-independent-samplers}`
gt-12:**109** ∈ 108–118; `\label{def:lambda}` gt-05:**642** ∈ 641–653; `\label{eq:ar-params-1}`
gt-10:**1814** and `\label{eq:ar-time-assumption}` gt-10:**1820** ∈ 1811–1822;
`\label{prop:standard-succinct-sat}` gt-10:**237** ∈ 237–273. Two failures: O11 (two CITED leaves
carry no locatable range at all) and O12 (`enu:pr-completeness` is at gt-11:**239**, outside the
cited 240–243). I also re-derived the CITED conclusion texts against the theorem statements: thm:ar's
`max{ℓ+2,5}` / `poly((λn)^μ,|D|,γ)` / "S^ar only depends on S, (λ,μ,γ) and |D|"; thm:repetition's
`k(n)=(λn)^{(1+c′)τ}` / `(ℓ+2)`-level / `O(k·TIME_S)` / `O(k·max(TIME_D,(λn)^τ))`;
thm:introspection's 5-level-for-every-ℓ and the `max{Ent, (1−δ)2^{2^{λn}}}` floor; thm:compression's
`max{Ent(V_N,½), 2^{N^λ−1}}`. **All match verbatim in substance.** Note that fig:compress writes
`k(n)=(λn)^τ` at gt-12:L70 while thm:repetition writes `(λn)^{(1+c′)τ}`; the code uses the theorem's,
which is right, and brief 39 already flags L70.

**(7) A violated checkable hypothesis is an ASSUMED FAIL node that `verify_certificate` rejects —
CONFIRMED for all three.** `|V| = 388 > λ = 7` → `lambda_bounded_description=FAIL`, refusal at that
location; `Introspect(V₉, λ, 5)` → `ell_level=FAIL`; `Concrete(2^40+1) > 2^40 = n^λ|_{n=2}` →
`lambda_bounded_time=FAIL`. `Compress(small,7)` propagates. My own run on a 5-level input:
`nine_level: levels = 5 => FAIL`, `ell_level: levels = 5, ell = 9 => FAIL`, refusal at `nine_level`.

**(8) `YCode ≡ Fix`, no Julia recursion — CONFIRMED.** `YCode(body) = Fix(body)` (`programs.jl:123`);
term inspection `y isa Fix`, `program_equal(y.body, body)`, `term_size(y) = term_size(body)+5`,
byte round trip. The tiny `Fix(Hole(self_code,:Program))` agrees with `Quote(tiny)` at fuels 4–6
(left uses 4, right 1) and is `OutOfFuel` at 3. See §5/C18 for how much this actually buys.

**(9) Capture-freedom — CONFIRMED, and the guard is tested.** `substitute` never shifts indices
because replacements must be closed; `specialize(Lambda(1,Hole(:h)), (:h ↦ Lambda(1,BoundVar(0,0))))`
yields `Lambda(1,Lambda(1,BoundVar(0,0)))`, which returns the **inner** argument 7, whereas the
capturing spelling `Lambda(1,Lambda(1,BoundVar(1,0)))` returns 5. The open-replacement refusal is
tested at `test/tb3_frontend.jl:160`. Residue in O14 (no mutant owns that guard).

**Certificate census — CONFIRMED.** 67 nodes = CONSTRUCTED 6 + CHECKED 30 + CITED 9 + ASSUMED 18 +
SOURCE_REPAIR 4. All 9 CITED nodes have `replay === nothing`; all 30 CHECKED nodes have one.

---

## 2. Objections

### O1 (MAJOR) — the `LevelChain` node's fig:compress ORDER conjunct is not red-capable

*Location*: `src/compress.jl:600-608` (`_level_chain_ok`), the `:LevelChain` node at `src/compress.jl:654-658`;
`test/tb4_compress_ir.jl` (f).

*Computation*: my new mutation **CRITIC-2** replaces
`origins == [:Introspect, :AnswerReduce, :Repeat, :Compress] || return false`
by `Set(origins) == Set([...]) || return false`. Run with the project's own isolation harness
(mutated file re-included into the loaded module) against the full `test/tb4_compress_ir.jl`
(`TB4_TARGET=all`): **7/7 testsets, exit 0 — SURVIVED**. I verified the weakening is real: on a
hand-built `Introspect → Repeat → AnswerReduce` chain, `_level_chain_ok = false` (pristine) while
`Set(origins) == Set(expected) = true` (mutant). Because F-a is true (§1(3)), the origin conjunct is
the *entire* content of this check; a certificate that silently stopped checking the order would
verify.

*FIX DEMAND*: add to (f) `@test !passed(chain_node.replay(swapped))` on a hand-built swapped chain
(`v1=Introspect(V,λ,9); v2=Repeat(v1,λ,1); v3=AnswerReduce(v2,λ,1,1)`; wrap with
`StubVerifier(out; input=v3.term)`), and register `M-order-blind` with exactly the CRITIC-2 text.

*SURVIVING WEAKER STATEMENT*: the composition order is pinned by test (d)'s explicit
`out.input.origin == :Repeat && …` assertions, not by the certificate; the `:LevelChain` node's order
claim currently has CONSTRUCTED strength, and only its arithmetic half is mutation-owned (M-level).

### O2 (MAJOR) — fig:compress's literal ℓ = 9 is unpinned

*Location*: `src/compress.jl:648` (`Introspect(stages.introspect, checked, lambda, COMPRESS_LEVELS)`);
gt-12-compression.tex:L79-L80 (`ComputeIntroVerifier(V, λ, 9)`).

*Computation*: my new mutation **CRITIC-1** replaces `COMPRESS_LEVELS` by `_levels(input)`.
Full TB4 file, `TB4_TARGET=all`: **7/7 testsets, exit 0 — SURVIVED**. The two agree on every input
TB4 exercises (9-level). On a 5-level input the pristine tree records
`ell_level: V is an ell-level verifier: levels = 5, ell = 9 => FAIL` while the mutant would record
`ell = 5 => PASS`; no verification outcome distinguishes them because `nine_level` refuses first
(I confirmed: `verify=false at nine_level`). So fig:compress's step-1 constant is nowhere attested.

*FIX DEMAND*: in (f), `Compress` a deliberately non-9-level verifier and
`@test occursin("ell = 9", ell_level_node.facts.display)`; register CRITIC-1 as a mutant.

*SURVIVING WEAKER STATEMENT*: on the 9-level inputs TB4 uses, the ℓ handed to Introspect coincides
with fig:compress's 9; the constant itself is unattested bookkeeping.

### O3 (MAJOR) — the `Compress` program inlined in `D_{M,λ}` is a third, undisclosed stub

*Location*: `src/compress.jl:52` (`COMPRESS_STUB = Lambda(2, Quote(TRIVIAL_DECIDER, :Decider))`),
used as the default of `psi_template`/`halting_decider`/`halting_verifier`; the 67-node trace; brief
24's proposed C11 row.

*Computation*: `COMPRESS_STUB` is **46 of the 376 term bytes (12 %)** of `D_{M,λ}` (my independent
reserialization). It is the constant function `(pair, λ) ↦ Quote(λ n x y a b . true)`. The
"compressed branch" that testset (b) exercises — the looping machine, 91 units, `Value(true)` — is
therefore the evaluation of that constant, not of any compressor. The certificate discloses the
sampler stub (`V = (S_lambda, D_{M,lambda}); levels = 9 (stub sampler datum)`) and the two stage
stubs (`Introspect`/`Repeat` "CITED stub"), but **no node anywhere names the inlined compressor
stub**, and neither does the proposed C11 row, which does name the `S_λ` stub.

*FIX DEMAND*: add `[ASSUMED] CompressStubInTerm` under `:Verifier` (or `:Specialize`) naming
`COMPRESS_STUB`, its 46 bytes, its constant value, and the fact that `COMPRESS_IDENTITY` is the only
non-constant compressor exercised; add the clause to C11.

*SURVIVING WEAKER STATEMENT*: `|D_{M,λ}| = 388` and `dbf2c0815358657f` are exact for the term whose
`Compress` subterm is a 46-byte constant stub; they are not sizes of any term containing a
compressor.

### O4 (MAJOR) — `FuelBound(n, λ)` on the returned decider is an ungraded construction change against `fig:halt_f`

*Location*: DESIGN §1.1's Ψ display and `src/compress.jl:88` (`FuelBound(n, lambda)`);
gt-12-compression.tex:L451-L453 (fig:halt_f step 5) and L570-L638 (`lem:lambda`).

*Computation from the TeX*: fig:halt_f step 5 reads "Accepts if the decider `D^compr` of verifier
`V^compr` accepts `(n,x,y,a,b)`" — **no budget**. `TIME_{D^halt}(n) ≤ n^λ` is a *conclusion* of
lem:lambda for `λ ≥ ⌈max{λ₀,λ₁,λ₂}⌉` (eq:125-dec + lem:lambda-bound), not a specification. The
implementation *enforces* `min(n^λ, remaining)` as an `Eval` delimiter, so below that threshold the
fixed point returns `OutOfFuel`, which is not a decider answer. This is observable in the suite:
`eval_program(y, tb4_input(1), 10_000)` is `OutOfFuel` (F-c), and the identity compressor at n = 2
gives `OutOfFuel(5000)`. No SOURCE_REPAIR or ASSUMED node records the deviation; instead the
`lambda_bounded_time` hypothesis quotes the enforced budget as if it were the measured runtime
("`TIME_S = fuel-bounded: n^lambda by FuelBound(n, lambda) …`"), which makes def:lambda's condition 1
true by fiat (and it is then reported `NOT_EVALUABLE` anyway).

*FIX DEMAND*: add `SOURCE_REPAIR(:HaltDeciderFuelBound)` under `:Specialize`, a `definitions.md` §F
row, and a C11 clause; restate the `lambda_bounded_time` detail as "budget enforced by construction,
not measured".

*SURVIVING WEAKER STATEMENT*: the term implements fig:halt_f with step 5 executed under an explicit
`n^λ` delimiter. On the two-state fixtures at n = 2 the delimiter never binds (12 and 91 units), so
every tested outcome coincides with the unbudgeted reading.

### O5 (MAJOR) — `docs/DESIGN.md` §5.6 states a red criterion no implementation can meet

*Location*: `docs/DESIGN.md` §5.6 ¶2: "Mutate composition order, pass a 5-level result directly to
`Repeat`, and require the computed chain to differ from `5 -> 7 -> 9`."

*Computation*: `repeat_levels(5) = 7 = answer_reduce_levels(5)` and `answer_reduce_levels(7) = 9 =
repeat_levels(7)`, so the swapped composition yields the identical chain `[9,5,7,9]` (§1(3)). The
single-source design document therefore demands an unattainable witness while the code silently does
something else (the origin check), and brief 24's MERGE PROPOSAL (2), which fixes exactly this, was
not merged — commit `0cc8928` merged only `definitions.md` §F.

*FIX DEMAND*: apply brief 24 MERGE PROPOSAL (2) verbatim: replace the sentence by "require the origin
sequence to differ from (Introspect, AnswerReduce, Repeat); at ℓ = 5 both rules give 7, so levels
alone cannot witness the swap."

*SURVIVING WEAKER STATEMENT*: the code's behaviour is correct; only the design document is wrong.

### O6 (MINOR) — `docs/definitions.md` §F lockstep residue (three defects)

*Location*: `docs/definitions.md` lines 153, 165, 166, 168, 169, 223 (and 21).

*Computation*: (a) the `Compressor` row still reads "accepts the quoted sampler/decider pair and a
`Level`", contradicting DESIGN §1.1 ("`Compress`'s second argument is `lambda : P{Nat}`") and the
`Level` row four lines below it ("The fixed-point parameter is NOT a level"). (b) brief 24 MERGE
PROPOSAL (3)'s rename applied only in part: lines 21, 165, 166, 168 and 223 still spell `Psi_{M,L}`,
`D_{M,L}`, `S_L`, while line 169 spells `Psi_{M,lambda}`. (c) line 169 — the row the orchestrator
merged for brief 24 — has **3 pipes where every other row in the table has 4**: it carries no
ground-truth-anchor cell, violating the table's own column contract.

*FIX DEMAND*: `Compressor` → "…and `lambda : P{Nat}`, the resource bound of `def:lambda`"; finish the
rename in all five rows; give line 169 its third cell (`gt-05-games-normalform.tex:L641-L653
(def:lambda)`).

*SURVIVING WEAKER STATEMENT*: the code and DESIGN §1.1 agree; only §F trails them.

### O7 (MINOR) — the Introspect contract mis-scopes `thm:introspection`

*Location*: `src/compress.jl:INTROSPECT_CONTRACT` (three unqualified hypotheses) and `docs/DESIGN.md`
§1.6 bullet 1.

*Computation from the TeX*: gt-08:L789-L797 states the 5-level result and all three complexity
bounds "For all ℓ ∈ N" **unconditionally**; only completeness/soundness/entanglement "hold **if**
`V` is a λ-bounded ℓ-level verifier" (L801-L803). `COMPRESS_CONTRACT` correctly marks its five
hypotheses "(completeness/soundness only)"; `INTROSPECT_CONTRACT` marks none, and a FAIL refuses the
whole tree — `Introspect(halting_verifier(M,7), 7, 9)` is refused at `lambda_bounded_description`
even though `V^intro` is 5-level regardless. DESIGN §1.6 has the same defect ("ASSUME `V` is a
`lambda`-bounded `ell`-level verifier. PROVE the 5-level result, sampler time …").

*FIX DEMAND*: prefix all three Introspect hypotheses "(completeness/soundness only)" and amend
DESIGN §1.6 bullet 1 to separate the unconditional conclusions, exactly as bullet 4 already does.

*SURVIVING WEAKER STATEMENT*: the refusal is over-strict, never unsound; no false statement is made.

### O8 (MINOR) — N14: decision ACCEPTED, justification and grade OBJECTED

*Location*: `src/verifiers/pcp.jl:186-213`; the `[CHECKED] UpstreamEvidence` display.

*Computation*: the recorded justification is "`tf` and `circuit` are immutable and `tseitin` is
deterministic, so re-running it at replay could never fail once the anchor holds". The premise is
false as stated: `TseitinFormula.program::Vector{FormulaInstruction}` (`src/ir/circuits.jl:180`) is
mutable in place. I tampered with it (`tf.program[1] = tf.program[end]`) and measured, reproducibly:

```
before: verify=true   same_tseitin=true
after : verify=false at PCPVerifier;  proof.tf === tf = true;  same_tseitin = false
        UpstreamEvidence replay alone after tamper: true
```

So the anchor and the `UpstreamEvidence` node both still accept the tampered formula; the tree is
saved by a *different* node (`PCPVerifier`'s replay). The practical conclusion of N14 survives, but
for a reason other than the one recorded. Separately, DESIGN §3 makes a CHECKED node's evidence *be*
its replay; a build-time `throw` is precisely the detached check that grade forbids.

*FIX DEMAND*: make the reproduction a `CONSTRUCTED :UpstreamReproduction` child (or say "CONSTRUCTED
at build time" in the display), and correct the immutability premise in `src/verifiers/pcp.jl:189-191`
and in any verdict/CLAIMS prose that repeats it.

*SURVIVING WEAKER STATEMENT*: `:UpstreamEvidence`'s CHECKED content is exactly the identity anchor
`proof.tf === tf`; the reproduction is a construction-time precondition, not certificate evidence.

### O9 (MINOR) — sampler independence is a symbol-set assertion, not DESIGN §12.3's byte check

*Location*: `src/compress.jl` `:SamplerIndependence` replay; `test/tb4_compress_ir.jl` (d)
`@test issubset(out.sampler_dependencies, (…))`; `docs/DESIGN.md` §12.3.

*Computation*: §12.3 requires "two byte-distinct input verifier pairs at the same `lambda` must yield
identical sampler bytes and hashes". TB4's check inspects a hand-written tuple against a hand-written
allow-list, and `StubVerifier` has no sampler field. My two-verifier experiment (§1(5)) shows the two
Compress trees differ in exactly one line (the input `Quote` hash) and the dependency tuples are
equal — the conclusion holds, but trivially, because the output is a stub.

*FIX DEMAND*: add the two-verifier test now in the form TB4 can support (assert the two 67-node
`traceprint`s differ only at the input `Quote` node) and defer the byte/hash form to TB5's `S^rep`;
scope C11's phrase to "the composed dependency SYMBOLS".

*SURVIVING WEAKER STATEMENT*: the three theorems' declared sampler dependencies compose to a set
⊆ {λ, ℓ, μ, γ, τ, |D1|} containing no component of `V`; `lem:compress-independent-samplers` is not
exercised on bytes at TB4.

### O10 (MINOR) — the AR surrogate is a sibling, not an ancestor, of the evidence it qualifies

*Location*: `src/compress.jl` `AnswerReduce(::AnswerReduceOnFixture, …)` `children=(…, surrogate,
_relocate(detyped.certificate, …), _relocate(fixture.pcp.certificate, …), …)`.

*Computation*: `[ASSUMED] AnswerReduceSurrogate` is a childless leaf placed *beside* the 24 CHECKED
nodes (PCPProof, UpstreamEvidence, Pad5, Decouple5, CookLevin, BoundedTrace, Quote, Tseitin,
ArithTseitin, 5×MultilinearExtension, BuildC0, ZeroBasis, PCPVerifier, TypedAnswerReduce,
AnswerReduceSamplerProduct, TypedPCPSampler …) that are about the 33-byte fixture rather than the
stage's own input. DD-10 says "each combinator retains its child's certificate and adds one node"; a
consumer walking the tree for CHECKED evidence under `:AnswerReduce` gets no structural marker.

*FIX DEMAND*: re-parent — `surrogate` becomes the parent of `detyped.certificate` and
`fixture.pcp.certificate`.

*SURVIVING WEAKER STATEMENT*: no CHECKED node states a false proposition; every CHECKED number under
`:AnswerReduce` is true of the fixture. The defect is structural, not semantic.

### O11 (MINOR) — two of the nine CITED leaves carry no locatable citation

*Location*: `src/verifiers/answer_reduce.jl:112-114` (`:Detype`, `display="lem:detyping-verifiers;
+2 levels; factor=16^54"` — no `source`, no `lines`); `:Oracularization` ("gt-09:36-86", no label
named). Test (d) greps `\label{…}` for only the five named theorem leaves.

*FIX DEMAND*: give both nodes `source`/`lines` facts (`gt-06-types.tex:L445` carries
`\label{lem:detyping-verifiers}`) and extend the (d) grep to every CITED node that has them.
(TB2 lane.)

### O12 (MINOR) — one off-by-one citation range

*Location*: `src/compress.jl` `REPEAT_CONTRACT`, hypothesis `completeness_decider_time`, source
string `gt-11-parallel-repetition.tex:L240-L243 (enu:pr-completeness)`.

*Computation*: `\label{enu:pr-completeness}` is at gt-11 line **239**; the cited range excludes its
own label. *FIX DEMAND*: `L239-L243`.

### O13 (MINOR) — TB4 body over budget and unenforced

*Location*: `test/tb4_compress_ir.jl` final print; `briefs/24-tb4.md` §4 ("TB4 ≤ 5 s"); DESIGN §5.6.

*Computation*: my in-suite measurement is **6.055 s** (budget 5.0); the proposer measured 4.955 s and
4.594 s quiet. The line only prints — unlike TB0's 60 s gate, which is a `@test`.

*FIX DEMAND*: either an enforced, clock-calibrated budget assertion (tb1-r5 N33's ratio gate) or an
explicit budget revision in DESIGN §5.6. Do not silently exceed a written budget.

### O14 (MINOR) — `specialize`'s guard is unowned and its replay is size-only and unbound

*Location*: `src/ir/programs.jl:608-635`.

*Computation*: (a) `is_closed(term) || throw(ArgumentError("replacement for $name is not closed"))`
— the guard on which capture-freedom rests — is tested (`test/tb3_frontend.jl:160`) but owned by no
mutant (`M-closure` targets `bounded_trace`, not this). (b) `specialize`'s CHECKED `:Specialize`
replay checks only `term_size(decoded) == expected && is_closed(decoded)` and is **not** wrapped in
`_bound_replay`, so any closed term of the same byte length passes and a borrowed `Quoted` is
accepted. (`fix_specialize`'s replay does check `program_equal` and *is* bound — that path is fine,
and `fix_unfolding` uses the weak one.)

*FIX DEMAND*: register `M-specialize-open` (`is_closed(term) || throw(…)` → `true || throw(…)`), and
add `program_equal(decoded, recomputed)` plus `_bound_replay` to `specialize`'s node.

### Notes

**N1** — `docs/analytic/parts/part2a.tex` §10 is now stale against DESIGN §1.1: it still declares
"§1.1 writes the fixed-point equation with the *same* fuel on both sides" and that "the first two
remain open proposed edits to `DESIGN.md` §1.1", although MP-2 (ii) was **adopted** (DESIGN §1.1 now
carries `fuel − c_Y`, `c_Y = 3`) and (i) was refuted in part. Also part2a's `c_fix` is "the fixed
four-bit Fix tag and its fixed sort annotation", whereas the implementation's `c_fix = 5` **bytes** is
one tag byte plus a 4-byte child count, and `Fix` serializes **no** sort annotation (the sort is read
off the `self_code` hole). Analytic-doc lane; merge proposal, not a TB4 defect.

**N2** — `bind_parameter` silently ignores a name absent from the bound
(`bind_parameter(Opaque("poly(n,mu)",(:n,:mu)), :nu => 1)` → free params still `(:n,:mu)`) and accepts
any host value (`:mu => "anything at all"` → `poly(n,mu) [mu = anything at all]`). "Free parameters
exactly {n, λ}" is therefore partly a naming fact: `c'`, whose value the source does not expose, is
removed from the parameter list by binding it to a prose string. Honest as *displayed*
("after binding … tau = 1, c', |D1|"); worth one sentence in C11.

**N3** — `:LevelChain` is graded CHECKED but recomputes integer arithmetic over data the constructors
wrote; two of the three stage levels are CITED theorem literals, never measured. DESIGN §1.6's own
invariant table grades "CL levels" as CONSTRUCTED.

**N4** — namespace: TB4 adds methods to the *TB2* function `AnswerReduce`
(`src/verifiers/answer_reduce.jl:118`), which is exported from the TB2 list (TB4's own export block
omits it). One name now has two meanings (`Checked{CitedDetypedVerifier}` vs
`Checked{StubVerifier}`). TB5 will hit the same with `Repeat`.

---

## 3. My two new semantic mutations

Both run with the project's own isolation discipline (mutated copy of `src/compress.jl` re-included
into the loaded module; the tree untouched), against the **full** `test/tb4_compress_ir.jl` with
`TB4_TARGET=all`; both completed all 7 testsets.

| id | mutation | target | outcome |
|---|---|---|---|
| CRITIC-1 | `Introspect(stages.introspect, checked, lambda, COMPRESS_LEVELS)` → `… , _levels(input))` | all | **SURVIVED** (exit 0) → O2 |
| CRITIC-2 | `origins == [:Introspect,:AnswerReduce,:Repeat,:Compress]` → `Set(origins) == Set([…])` | all | **SURVIVED** (exit 0) → O1 |

Per the brief, survivors are MAJOR; the red tests demanded are in O1 and O2.

The registry's own 13 TB4 mutants are all genuinely KILLED with passing baselines, and I confirmed
the two `M-order` mutants really do flip the origin conjunct (levels alone cannot, §1(3)).

---

## 4. Surrogate honesty — grade **B** (disclosed; two structural defects)

- **No CHECKED node inherits from the surrogate**: `[ASSUMED] AnswerReduceSurrogate` is a childless
  leaf, so nothing is a descendant of it. Every CHECKED number beneath `:AnswerReduce`
  (`|D| = 33`, `fnv1a64 = f8561ef8c5761695`, `T = 1`, 10 140 monomials, `inddeg = 5`, exhaustive
  relation checks) is a true statement about the 33-byte fixture, not about the introspective decider.
- **No downstream number is graded above its warrant**: the stage's level 7 and its
  `poly((λn)^μ,|D|,γ)` bounds come from the theorem rules applied to the *stub* input and sit under a
  CONSTRUCTED node; the fixture's own typed level 3 is printed beside them in the surrogate display,
  so the two objects are distinguishable in the trace. `σ = 33` is passed explicitly and asserted
  (N12 honoured; `M-sigma` owns it).
- **Why not A**: (i) O10 — the disclosure is a *sibling*, so nothing structural stops a consumer from
  attributing the 24 CHECKED fixture nodes to the stage's input; (ii) O3 — a *third* stub, the
  compressor inlined in `D_{M,λ}` itself, is disclosed nowhere at all, and the sizes/hashes/branch
  runtimes of the rung's central term depend on it.

---

## 5. Adjudications

### MP-2 (`briefs/47-analytic-doc-repair-r1.last.md`), recomputed from the TeX

**(ii) — ADOPTION UPHELD.** `eval(Fix(P),u;f) = eval(specialize(P,{self_code ↦ Quote(Fix P)}),u;f−3)`
for every `f ≥ c_Y = 3`, outcome for outcome, with `used_left = used_right + 3`. Verified by
execution at every fuel `3..15` and `3..94` on both machines (0 mismatches) and by hand-tracing the
CEK for the halting branch (12 = 3+1+1+1+1+3+1+1). DESIGN §1.1's amended display is correct and
part2a §10 must stop calling it an open proposal (N1).

**(i) — REFUTED IN PART, but for a better reason than the one recorded.**
- *`F_C` (a fuel symbol for the compression call)*: **correctly refuted, and I confirm the mechanism.**
  In `step!`, an `Eval` node evaluates its `code` child **before** the `:eval` contraction installs
  the `Delimiter`; so `Apply(Compress, …)` runs inside the *ambient* budget and only `D^compr`'s run
  is delimited by `n^λ`. That is exactly lem:lambda's accounting, which charges steps 2–4 (computing
  `D̄`, `S̄^compr`, `D̄^compr`) inside `TIME_{D^halt}` (gt-12:L578-L596, items enu:d/enu:cdc) and
  bounds the total by `n^λ` for large λ. No separate symbol is needed.
- *`ans` (the selector)*: **the elimination is right, the stated justification is circular.** DESIGN
  §1.1 argues "no `ans` selector is needed because `Compressor` returns the decider description
  (`definitions.md` §F)" — an appeal to a project definition. The ground-truth argument is: fig:halt_f
  computes `S̄^halt = ComputeSampler(λ)` at step 3 and uses only `D^compr` at step 5, and
  lem:dhalt-values (gt-12:L521-L528) records that `V^halt_n` and `V^compr_n` *use the same sampler*;
  by lem:compress-independent-samplers that sampler is `S^compr`. So dropping the pair and returning
  the decider description is licensed by ground truth, not by §F. **FIX DEMAND**: replace the circular
  sentence in DESIGN §1.1 with those two citations, and record the decider-only `Compressor` as a
  named, deliberate narrowing of thm:compression's pair-valued output.
- *A deviation neither side raised*: the outer `Eval`'s `FuelBound(n,λ)` itself — see **O4**.

### Per-claim decisions

**C11 — HOLD (no promotion this round).**
There is no `C11` row in `claims/CLAIMS.md` at all (present ids: C1, C2, C3, C4a, C4b, C4c, C5, C6,
C7, C8, N1, C9, C10, C12–C19); C11 exists only as brief 24 MERGE PROPOSAL (1). **Missing steps**, in
order: O1 (the "checked level chain" phrase — the order half of that check is not red-capable),
O2 (ℓ = 9 unpinned), O3 (the row discloses the `S_λ` stub but not the inlined compressor stub),
O4 (the row is silent about the `FuelBound` construction change), O9 (the "sampler-dependency set"
phrase overstates a symbol-set assertion as sampler independence).

Because rk-light law 5 prefers the honest downgrade to a delayed promotion, I **AUTHORIZE the
following weaker row verbatim, as TESTED**, to be pasted as-is (the proposer may not strengthen a
word of it); brief 24's stronger phrasing stays HELD until O1–O4 and O9 are discharged:

> | C11 | (Compress skeleton — composition, contracts and the quoted fixed point) On the TB4 fixture `V = (S_λ stub, D_{M,λ})` at λ = 1024, with `|D_{M,λ}| = 388` bytes and fnv1a64 `dbf2c0815358657f` (critic-reserialized independently, `verdicts/tb4-r1.md` §1), `Compress = Repeat ∘ AnswerReduce ∘ Introspect` builds the three ASSUME/PROVE contracts in fig:compress order (`gt-12-compression.tex:L75-L98`) with level chain 9→5→7→9 (`introspect_levels(9)=5`, `answer_reduce_levels(5)=max(7,5)=7`, `repeat_levels(7)=9`; the ORDER half of that chain is asserted by the test file, not by the certificate's own replay, and at ℓ = 5 the two rules coincide so levels alone cannot witness a Repeat/AnswerReduce swap), composed runtime bounds whose free parameters are exactly {n, λ} after binding ℓ = 9 and the toy literals μ = γ = τ = 1 and after binding `c'` and `\|D1\|` to prose descriptions of unexposed constants, and a composed sampler-DEPENDENCY-SYMBOL set ⊆ {λ, ℓ, μ, γ, τ, \|D1\|} containing no component of `V` (no sampler bytes exist at TB4: the output is a `StubVerifier`). The executable evidence in the tree is CHECKED Quote/Specialize on `D_{M,λ}` (host-side specialization, size law with `c_fix = 5`) and the TB0/TB2/TB3 PCP and typed-answer-reduction subtrees **on the 33-byte trivial front-end fixture**, disclosed as `[ASSUMED] AnswerReduceSurrogate` with σ = 33 passed explicitly; the certificate is 67 nodes (CONSTRUCTED 6, CHECKED 30, CITED 9, ASSUMED 18, SOURCE_REPAIR 4), every CITED leaf carries `replay === nothing` and the five theorem leaves' `\label{…}` were verified inside their cited ranges; a violated checkable hypothesis (\|V\| > λ; wrong ℓ; a Concrete TIME > n^λ at n = 2) is an ASSUMED FAIL node that `verify_certificate` rejects at that hypothesis. **Scope:** three stubs stand in for the construction — `S_λ` (`λx.x`, 34 bytes), the `Introspect` and `Repeat` stages (CITED, no execution), and the `Compress` program inlined in `D_{M,λ}` itself (`COMPRESS_STUB`, 46 of 376 term bytes, the constant `(pair,λ) ↦ Quote(λnxyab.true)`), so the "compressed branch" evaluated in testset (b) is that constant; and the outer `Eval` runs the returned decider under an enforced `FuelBound(n,λ)` where `fig:halt_f` step 5 (`gt-12-compression.tex:L451-L453`) imposes no budget. Red-capable by M-order (×2), M-relabel, M-ycode, M-hyp, M-audit, M-level, M-bind, M-sigma, M-level-sort, M-cfix, M-cited, M-independence (13/13 KILLED); NOT red-capable: the fig:compress ORDER conjunct of `:LevelChain` and the literal ℓ = 9 (`verdicts/tb4-r1.md` O1, O2). | TESTED | C9, C10, C16, C18 | `src/compress.jl`, `src/ir/programs.jl` | `test/tb4_compress_ir.jl`; red: `test/mutations/tb4_compress.jl` | `verdicts/tb4-r1.md` |

**C15 — stays CONJECTURE.** What TB4's skeleton now discharges of C15's "missing steps": the
composition ORDER and the level chain 9→5→7→9 exist as constructed, partly checked objects; the four
theorem contracts are ASSUME/PROVE objects with replayed hypothesis audits; the free-parameter
closure of the composed runtimes to {n, λ}; and `D_{M,λ} = Y Ψ_{M,λ}` is a finite closed term with an
exact byte size and a machine-checked `thm:ycode` at every fuel. What remains entirely undischarged
and is the whole of C15's content: the dimensions 206→840→848→1696, the fixed-width two-input
**identical sampler hash**, the printed ToyPolicy predicate report, `P_pcp_encodes_D1` (printed FAIL)
and the `enu:ar-game` / non-Pauli-schema non-execution disclosures, and executable Introspect and
Repeat. TB4 supplies the frame; TB5–TB7 must supply every number in the row.

**C16 — RE-AFFIRM SKETCH.** TB4 adds, as first machine evidence for one clause only, the
specialization size identity `|Specialize(P,σ)| = |P| − Σ_h|Hole(h)| + Σ_h|σ(h)|`, which I recomputed
independently: 385 − 31 − 2·22 + 31 + 2·15 = 371, +`c_fix` 5 = 376, hence `|D| = 1+4+7+376 = 388`.
**Caveat that must go into the row**: TB4's instance has λ occurring **twice**, so the sum is over
hole *sites* and the instance lies outside C16's stated "affine-hole discipline"; it is executed by
`substitute`, not by `specialize` (which refuses a repeated hole name). The determinism, fuel
monotonicity and `Eval_L` overhead clauses of C16 are TB3's evidence, not TB4's; §8's constants
remain uninstantiated (the byte codec, folded context navigation and the full `h(d,u)` per `Eval`).

**C18 — RE-AFFIRM SKETCH.** TB4 adds: `YCode(P) = Fix(P)` is the constructor and is term-inspected
to be syntax, not Julia recursion; `|YCode(P)| = |P| + c_fix` with `c_fix = 5` bytes; and
`thm:ycode`'s `f − c_Y` with `c_Y = 3` verified outcome-for-outcome at **every** fuel from `c_Y` past
termination on two machines (0/13 and 0/92 mismatches). **How much this buys must be stated in the
row**: in this instantiation the equation is one clause of the evaluator — `step!`'s `Fix` case
charges 3 and sets `control = _fix_unfold(c)` — so the test is a consistency check on that clause,
not independent evidence; and it says nothing about C18's substantive content (the s-m-n transformer
`s_{r,k}` and `a_s,b_s`; Kleene's `e_Q = s(p,p)` and `a_K,b_K`; the claim that
`F(F,M,λ,…)`, the Kleene fixed point and `D_{M,λ}` are three descriptions of one partial function).
`c_fix`'s analytic justification does not match the implementation (N1).

**C10 — untouched.** TB4 consumes it; nothing here weakens it.

---

## 6. Elegance — three places the code is more complicated than the mathematics

1. **The stage-dispatch interface (the one that matters for TB5–TB7).** The mathematics is
   `Compress = Repeat ∘ AnswerReduce ∘ Introspect`, three named transformations. The code spends an
   abstract type `CompressStage`, three singleton/struct subtypes, a three-field parametric
   `CompressStages{I,A,R}`, six methods (a stage-taking and a convenience method per transformation,
   the latter re-running `frontend_fixture()` as a *default argument*), and a smuggling channel:
   `AnswerReduceOnFixture` carries an entire 7-field `FrontEndFixture` that has nothing to do with
   thm:ar's arguments `(λ, μ, γ)`. Two of the three subtypes have no fields at all. The same
   swappability is a `NamedTuple{(:introspect,:answer_reduce,:repeat)}` of functions
   `(V, params) → Checked{…}`; the abstract type, the parametric record, three of the six methods and
   the default-argument fixture build all disappear, and TB5 swaps a closure instead of adding a type.

2. **The `Opaque` / `bind_parameter` string algebra.** The mathematics is substitution into a symbolic
   bound. The code carries a free-text `description` and a parallel `parameters` tuple, and binding
   *concatenates English* (`"poly(n, lambda, ell) [ell = 9]"`) while `filter!`-ing the tuple. The two
   halves can drift silently (N2): binding an absent name is a no-op, and any host object — a
   `String` — is accepted as a value. A two-field `Bound(ast, env::Dict{Symbol,Any})` with a printer
   would be shorter, would make `free_parameters` a fold rather than a bookkeeping tuple, and would
   make the display a *function of* the state instead of a second copy of it.

3. **`_relocate` + `_bound_replay` as composed closures.** The mathematics is "this node's evidence is
   about that component of the term". The code encodes the component as an anonymous locator that
   composes on every relocation, so a replay deep in the tree ends up applying
   `x -> x.input.input.payload.typed.term` built from four separate lambdas. Nothing is inspectable or
   printable, and `_verify_node` turns a *wrong path* (a `MethodError`) into the same
   `CheckResult(false, :certificate_replay)` as a *false check* — I hit exactly that while probing
   (`no method matching _levels(::Nothing)`). An explicit path `(:input, :input, :payload, :typed,
   :term)` walked by one generic function would be printable in the trace, testable, and
   distinguishable from a genuine refusal.

(Honourable mention: `StubVerifier` has 11 positional fields with two `::Any` slots, and eight
hand-written two-method accessors (`_levels`, `_sampler_time`, …) re-implement a `Verifier` ↔
`StubVerifier` interface that a single record with a `payload` would not need.)

---

## 7. TB5 readiness (brief 39 + addenda 1–3)

1. **Not executable without one small design decision, but no full design round is needed.**
2. **Blocking gap A — the stage output carrier.** `_VERIFIER_INPUT = Union{Verifier,StubVerifier}` is
   closed, and `_chain`/`level_chain`/`_level_chain_ok`/`runtime_composition_ok` all require a chain
   of exactly four `StubVerifier`s. An executable `Repeat` returning a `VerifierDescription` breaks
   every one of them. The workable convention already exists (`AnswerReduceOnFixture` puts real
   objects in `payload`) but it is undocumented and collides with DD-9's rationale for the name
   `StubVerifier` ("no caller can mistake it for an executable verifier"). Decide: widen the union, or
   rename to `StageVerifier` with a `payload` and keep DD-9's `StubVerifier` for CITED-only stages.
3. **Blocking gap B — stage parameters.** `Repeat(::RepeatStub, checked, lambda, tau)` has nowhere to
   put `c_prime`, `n`, `k(n)` or `B(n)`, which brief 39 (f) needs at `λ = τ = c' = 1, n = 9`
   (`B = 9, k = 81`). `c'` today is only a prose string bound into an `Opaque`. A `params` NamedTuple
   on the stage methods (and hence on `Compress`'s keywords) is required.
4. **Unchanged blocking gap from brief 39's own addendum: G1.** The description layer does not exist.
   `CLDescription`, `describe_cl`, `decode_cl`, `canonical_bytes`, `NotDescribable`,
   `ZERO_MAP_FACTOR_PARTITION`, `pad_level_evidence` and the four query modes ARE present and exported
   (TB1 + brief 54), and the `decode_cl(canonical_bytes(describe_cl(L)))` round trip exists — good.
   Absent: `SamplerDescription`/`DeciderDescription`/`VerifierDescription` records and the
   description-level `direct_sum`/`concatenate`/`product` combinators. TB4 adds nothing here, exactly
   as brief 39 anticipated.
5. **Minor traps.** (a) `Compress`'s default `stages=tb4_stages()` builds a full front-end fixture per
   call (~3 s); TB5 tests must pass explicit stages. (b) TB4's methods extend the *TB2* function
   `AnswerReduce`; TB5's executable `Repeat` will extend TB4's `Repeat` the same way — pin the
   signatures to avoid an ambiguity. (c) O1/O2's red tests should land in the same repair round, since
   TB5 will inherit `_level_chain_ok`.
6. **Reusable as-is**: `Contract`/`Hypothesis`/`_audit`, the CITED-leaf + `\label` grep pattern, the
   `_relocate` discipline, and the 67-node `traceprint` format.

---

**VERDICT: FAIL(O1,O2,O3,O4,O5)**
