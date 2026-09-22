# Brief 81 — CRITIC verdict r2 on rung TB6 (brief 80 = TB6 repair r1, as implemented in session 4 and verified/repaired in session 5) — and the readiness gate for TB7 (brief 44)

You are the adversarial critic (Opus). ATTACK; do not summarize. Autonomous; no questions. Lane: write `verdicts/tb6-r2.md` ONLY; Julia and files only under your scratch dir; never edit repo files; no state-changing git. Evaluate the ARCHIVED tree at commit `0db7811` (`git archive 0db7811 | tar -x -C <scratch>/tree`; `julia --project=. -e 'using Pkg; Pkg.instantiate()'` there; cold precompile ~3–4 min on this 4-core box). Never read src/test from the live tree; `claims/CLAIMS.md` may be read live.

Scratch: `/tmp/claude-0/-home-user-mipstar-lambda/a4d58236-e7cb-5bd3-a245-a0a49974d60b/scratchpad/critic-tb6-r2/`

Environment: a 4-core cloud container, Julia 1.12.7 at `/usr/local/bin/julia`, no performance governor. Wall numbers are advisory; gates are clock-calibrated ratios. The user has said calibration precision is not important — do not spend the round on it beyond checking that the gates are honest and red-capable.

## Read order
1. The rk-light laws as stated in `CLAUDE.md` §Method (the skill file is not present in this container): claims ratchet up only via a converged critic verdict; every machine-checkable claim has a test and a mutation that can fail it; red before green.
2. `claims/CLAIMS.md` (C14 TESTED scoped — the target; C12/C13 as edited in 0db7811; C11, C15).
3. `verdicts/tb6-r1.md` IN FULL — your prior; adjudicate the deltas (O1–O10, §4, §5, §6, §7); do not re-litigate what passed.
4. `briefs/80-tb6-repair-r1.md` (the work order, D1–D14) and `briefs/80-tb6-repair-r1.last.md` (the report, including the five session-5 fixes).
5. `docs/DESIGN.md` §9.5, §9.6, §11 (esp. §11.4 "Fuel currency", "Nested typed deciders"; §11.6 cost table), §12.1 (the D13 padding decision), §13.1; `docs/definitions.md` §H.
6. `HANDOFF.md` "RESUME (session 5)" and `worklog/2026-09-22.md`.
7. Ground truth, recomputed never from memory: `gt-08-introspection.tex` L401–L498, L417–L419, L451–L455, L462–L473, L550–L579, L641–L684, L923–L953; `gt-03-prelim.tex` L307–L318, L333–L340, L386–L392; `gt-05-games-normalform.tex` L624–L634; `gt-11-parallel-repetition.tex` L216–L220; `gt-12-compression.tex` L448–L449; `gt-10-answer-reduction.tex` L200–L205.
8. The diff `git diff 7578c0d 0db7811 -- src test docs claims` (7578c0d = the tb6-r1 verdict commit).

## Obligations
- **Run** `julia --project=. test/runtests.jl` (paste the summary line + TB0/TB6 gate lines + `uptime`) and `MUTATION_JOBS=4 julia --project=. test/mutations/run.jl` (paste the `MUTATION REGISTRY` line; the report claims `killed=216/216 baselines ok=85/85`). Run them one at a time; nothing else runs Julia meanwhile.
- **O1–O10 discharge.** For each r1 objection: DISCHARGED / PARTIAL / NOT, with your evidence. In particular: D1's 13-conjunct table re-derived from `_intro_ordered` yourself (is 13 the right count?), each witness corrupts exactly one field, and each conjunct-drop mutant is killed by ITS witness (not by an unrelated test); D2's gates are ratio gates on a kernel excluded from the timed body; D3's dense reference is independent of the tableau code.
- **Adjudicate the session-5 changes explicitly** (they were made by the orchestrator, not a proposer, so they need a critic):
  (a) TB6b (k): the assertion was changed from `@test_throws FuelExhausted` at budget `total-1` to "rejection (`false`) at `total-1`; `FuelExhausted` only below the enclosing level's own depth-1 charges". Is that what DESIGN §11.4 "Nested typed deciders" and gt-08:L417–L419 require, or did the orchestrator weaken a test to match the code? Recompute the boundaries yourself.
  (b) TB6b (m): `falses(6)` → `Vector{Bool}` arguments. Is the primitive contract (refuse `BitVector`) correct, or should the primitive accept any `AbstractVector{Bool}`?
  (c) `lower_sampler` `Lambda(8)` → `Lambda(7)`: correct against DESIGN §1.1's Sampler sort and the `sampler_machine` signature? Is `M7-lower-sampler-arity` killed for the right reason?
  (d) `intro_decider.jl` nested `TypedDecider` `Vector{Bool}` normalization.
  (e) `test/calibration.jl` kernel moved into a module with `@optlevel 2`; `test/mutations/run.jl` test-file mutants now run from a shadow tree; two TB5 evidence strings changed. Could the sandbox change let any mutant be credited that should not be?
  (f) The CALIBRATED_GATES values (set from one in-suite run on this box) — honest? red-capable?
- **Independent recomputation on a COPY** (your own code, never the package's machines): the ten cost slots and the charge table from the §11.4 charge list by hand for at least two modes; the one-currency overheads (10 sampler / 8 decider) — are they a constant by construction or a coincidence of these three queries?; `_require_image` step counts at 206.
- **Two NEW semantic mutations** the proposer did not anticipate (on copies), aimed at the new surface: e.g. the nested meter charging the parent before vs after the child returns; the dense reference sharing code with the tableau; a conjunct witness that corrupts two fields. Survivors are MAJOR with the red test as FIX DEMAND.
- **Claims.** C14: the r1 row's O1 and O4 scope sentences are now false (report §"C14 scope proposals"). Authorize a replacement C14 row VERBATIM (scoped weaker allowed) or HOLD with the missing step named. C13: the orchestrator did NOT paste r1 §6's "warm construction < 2 s, transcripts < 5 s, total < 7 s as hard gates" clause because D2 replaced those walls — rule on it and authorize corrected text verbatim if needed. C12: confirm.
- **Lockstep**: DESIGN §9.5/§9.6 (landed verbatim?), §11.4/§11.6/§12.1/§13.1, definitions §H, CLAIMS, the report — all consistent with the code at 0db7811?
- **TB7 readiness (≤ 15 lines).** With D11–D14 landed and the partial TB7 tree on main (`src/compress/`, `src/policy/`, `test/tb7_compress.jl` with only testset (a), not in `runtests.jl`), what exactly must brief 44 still do? Name blockers vs obligations; say whether brief 44 can start now.
- **Elegance**: three places where the code is more complicated than the mathematics, with a concrete simplification each.

## Output: `verdicts/tb6-r2.md`
Numbered objections (severity FATAL/MAJOR/MINOR/NOTE · exact location · your independent computation · one-line FIX DEMAND · SURVIVING WEAKER STATEMENT); the O1–O10 discharge table; the session-5 adjudications (a)–(f); runs + load; your mutations and outcomes; per-claim decisions with verbatim authorized rows; TB7 readiness; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
