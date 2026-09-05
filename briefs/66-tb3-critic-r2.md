# Brief 66 — CRITIC verdict r2 on rung TB3 after repair r1 (brief 63) — also the readiness gate for TB4

You are the adversarial critic (Opus). ATTACK; do not summarize. Autonomous; no questions. Lane: write `verdicts/tb3-r2.md` ONLY; Julia/files only under scratch; never edit repo files; no state-changing git. Evaluate the ARCHIVED tree at commit `f8bd881` (`git archive f8bd881 | tar -x -C <scratch>/tree`; instantiate there; cold precompile ~90 s under the performance governor). Never read src/test from the live tree (a worker edits it); `claims/CLAIMS.md` may be read live.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb3-r2/`

## Read order
`~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `verdicts/tb3-r1.md` (your prior — the work order: N1–N10, the DESIGN adjudication with ADMIT conditions, the C10 authorized row, §8 TB4 gaps 1–8); `briefs/63-tb3-repair-r1.md`, `briefs/63-tb3-repair-r1.last.md` (response table, runs, CROSS-LANE = the `build_pcp` upstream slot, MERGE PROPOSALS incl. the two C10 corrections and the C16/C18 shrink — already applied by the orchestrator at f8bd881 — and the three "unresolved" notes: the chimera fixture is a T=1 twin because N7 makes the critic's B pad to m=2; two DESIGN §1.1 notes beyond the adjudicated list; runner contamination on the first passes); `docs/DESIGN.md` §1.1, §1.2, §5.5 (as amended), `docs/definitions.md` §F; `docs/analytic/parts/part2a.tex` §8 (C16), `part2b.tex` §11 (C19); `claims/CLAIMS.md` C16, C18, C19 (clauses as amended), C10 (proposed).

## Obligations
- **Run** suite (summary + TB0 wall + `uptime`) and runner (`MUTATION REGISTRY` line; all 97 KILLED; baselines ok). Run `tools/cold_precompile.sh` once.
- **Adjudicate** every r1 row (N1–N10), each DESIGN ADMIT condition, and each TB4 gap 1–8: ACCEPTED / REJECTED / PARTIAL.
- **Independent recomputation on a COPY:** (1) N2: build your own chimera — ANY program whose padded object equals the trivial decider's — and confirm it is refused at a TB3 node with `:certificate_binding`; probe whether `frontend_pcp` can ever print a foreign `|D|`/hash; decide whether the T=1 twin is an acceptable substitute for your literal B given N7 (or whether N2 and N7 conflict); (2) N7: T=2 pads to m=2, s=17, m'=32 — recompute; (3) `c_Y = 3`: the fixed-point fuel figure 8 = unfolded + 3 and the Ψ_{M,λ} evaluations (M_3 halting branch 13, compressed branch 91, M_loop 92) from your own trace of the charge table; (4) the equality run's row contents (control/fuel/fields) against your own CEK trace; (5) sort checks: construct a mis-sorted `Quote` and a `Hole` of the wrong sort and confirm `SortError`; (6) FuelBound overflow → clamped budget, never SortError.
- **Certificate honesty**: every CHECKED node red-capable (the 13 new mutants); `:UpstreamEvidence` replay recomputes the reproduction against the attached proof; ASSUMED/CITED leaves name exactly what they omit.
- **Lockstep**: DESIGN §1.1/§1.2/§5.5 ↔ definitions §F ↔ code ↔ C16/C18/C19 clauses ↔ part2a §8 / part2b §11 (the orchestrator amended part2b §11's TB3 sentence at f8bd881 — check it) — any residual contradiction is an objection.
- **Two NEW semantic mutations**; survivors are MAJOR with the red test as FIX DEMAND.
- **Per-claim**: C10 — PROMOTE to TESTED with the AUTHORIZED verbatim row (the r1 row + the two corrections, or your own wording), or HOLD with the missing step; C16/C18/C19 — RE-AFFIRM SKETCH (or say exactly what the fixture evidence now covers).
- **TB4 readiness (≤ 10 lines)**: with YCode, evaluable Ψ, sorts, FuelBound and the Verifier carrier in place, can brief 24 (+addendum) be executed without a further design round? Name any blocking gap; adjudicate the proposer's two deviations (runtime `Specialize` vacuous under closed-only `Quote` → TB4 must specialize on the host or admit a partial-code sort; `Apply(Quote(Compress),…)` not evaluable) as design decisions for TB4.

## Output: `verdicts/tb3-r2.md`
Adjudication table; recomputations; new objections (N11…); runs + walls + load; your mutations; per-claim block; TB4 readiness block; final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
