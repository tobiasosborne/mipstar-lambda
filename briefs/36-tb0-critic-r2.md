# Brief 36 — CRITIC verdict r2 on rung TB0 (files: Project.toml, src/**, test/tb0_core.jl, test/mutations/run.jl TB0 entries) after repair r2

You are the adversarial critic (Opus). ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/tb0-r2.md` ONLY. You may run Julia and create files ONLY under the scratch dir below; never edit repo files. Evaluate the ARCHIVED tree at commit `2d91620` (`git archive 2d91620 | tar -x -C <scratch>/tree`; its src/test are the TB0-repair-r2 code, commit 1a96917). The live working tree has UNCOMMITTED TB1/TB2 repair work in progress — do not read src/test from the live tree.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb0-r2/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`
2. `CLAUDE.md`, `docs/DESIGN.md` §1–8, `docs/definitions.md`, `claims/CLAIMS.md` (C1, C2, C3, C8 rows)
3. `verdicts/tb0-r1.md` — your prior (O1–O16). It is the work order; adjudicate deltas; do not re-litigate what passed.
4. `briefs/20-tb0-repair-r2.md` (binding directives) and `briefs/20-tb0-repair-r2.last.md` (response table + MERGE PROPOSALS for C1, C2).
5. Ground truth (recompute from it, never from memory): `ground-truth/gt-03-prelim.tex` (sec:ld-encoding, lem:schwartz-zippel), `gt-10-answer-reduction.tex` (def:tseitin, def:formula-arithmetization, prop:zero-basis, def:pcpparams, fig:pcpverifier, thm:pcp-decider), `ground-truth/nw19/nw19-tseitin-arith.tex`.
6. The target files in the archived tree.

## Obligations
- **Run** `julia --project=. test/runtests.jl` in the archived tree (instantiate first) and paste the summary line and the TB0 wall time; then `julia --project=. test/mutations/run.jl` and paste its summary. **Timing caveat:** another Julia job (the TB1/TB2 repair worker) may run on this machine concurrently. If the TB0 60 s gate fails, wait until `pgrep -f 'runtests|mutations/run'` shows only your own processes and re-run once; a gate that fails ONLY under load is a NOTE with both wall times, not MAJOR. A gate that fails on a quiet machine is MAJOR.
- **Adjudicate every response-table row** O1–O16: ACCEPTED / REJECTED (exact residual defect) / PARTIAL. Especially: the real bug `zero_basis_decompose` off the prime subfield (O5 in r1) — verify with your own GF(2^11) instance that generic coefficients are handled; the "CHECKED node that cannot fail" (O7) — find any remaining certificate leaf that no test can turn red; the ⟺ clause of C2.
- **C1 narrowing** (law 5, tracked as `mipstar-lambda-yqw`): is the narrowed C1 text honest about what the 1024-witness check covers vs. the retracted 10⁴-point sparse sampling?
- **Independent recomputation on a COPY**: (1) occurrence vector vs actual individual-degree vector with your own sparse arithmetic; (2) witness (ii) c₀ support and remainder; (3) pcpverifier at b_ρ and b_ρ[O2←ρ] in GF(8) and GF(2^11); (4) modulus irreducibility; (5) the six def:pcpparams reports. Disagreement with the printed report is MAJOR.
- **Two NEW semantic mutations** you did not use in r1; apply on a copy; a surviving mutation that should break the construction is MAJOR with the red test as the FIX DEMAND.
- **Certificate honesty, lockstep, elegance** as in `briefs/templates/rung-critic.md`.

## Output: `verdicts/tb0-r2.md`
Per-row adjudication table; recomputations; new objections (numbered N1, N2, …) with severity/location/computation/FIX DEMAND/SURVIVING WEAKER STATEMENT; test/mutation summary lines and wall times observed; your new mutations; per-claim PROMOTE/HOLD for C1, C2, C3, C8 with AUTHORIZED row text (verbatim) for any PROMOTE; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
