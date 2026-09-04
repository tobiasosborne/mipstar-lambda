# Brief 40 — CRITIC verdict r2 on rung TB1 (files: src/samplers/cl.jl, src/samplers/typed.jl, src/samplers/ldt.jl, src/verifiers/ldt.jl, test/tb1_ld_sampler.jl, test/mutations/tb1_*.jl) after repair r1 (brief 21 / brief 38)

You are the adversarial critic (Opus). ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/tb1-r2.md` ONLY. You may run Julia and create files ONLY under the scratch dir below; never edit repo files; never run git commands that change state. Evaluate the ARCHIVED tree at commit `<SHA>` (`git archive <SHA> | tar -x -C <scratch>/tree`; instantiate there).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb1-r2/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`
2. `CLAUDE.md`, `docs/DESIGN.md` §1.5, §1.6, §5.3–5.4, §9 (the description layer TB5 will need — note where the lazy `CLStep` adapter of §9.3 is assumed), `docs/definitions.md`, `claims/CLAIMS.md` (C4a)
3. `verdicts/tb1-r1.md` — your prior; it is the work order. Adjudicate every objection's disposition; do not re-litigate what passed.
4. `briefs/21-tb1-repair.md` (binding directives, incl. the TB2 EXTENSION), `briefs/38-tb1-tb2-repair-r1-resume.md`, and the proposer's report `briefs/38-tb1-tb2-repair-r1-resume.last.md` (response table + MERGE PROPOSALS).
5. Ground truth (recompute from it, never from memory): ground-truth/gt-04-cl.tex (def:cl-func, lem:alnf, lem:dlnf, L590–595 lazy interface), ground-truth/gt-07-ldt.tex (L_Point, L_ALine, L_DLine, fig:ld-decider, eq:chi-func).
6. The target files in the archived tree.

## Obligations
- **Run** `julia --project=. test/runtests.jl` and paste the summary line + TB0 wall; run `julia --project=. test/mutations/run.jl` and paste its summary (every mutant listed, every one KILLED, exit 0, total wall). Timing caveat: another Julia job may run concurrently on this machine; if the TB0 60 s gate fails, wait until `pgrep -f 'runtests|mutations/run'` shows only your processes and re-run once; a gate failing ONLY under load is a NOTE with both walls.
- **Adjudicate every response-table row** for this rung: ACCEPTED / REJECTED (exact residual defect) / PARTIAL. DOWNGRADED rows: justified by ground truth under law 5, or an escape?
- **Independent recomputation on a COPY:** (1) rebuild the (line, point) joint histogram for (q,m,d)=(8,2,1) with your own enumeration and compare to the printed one; (2) eq:chi-func bucket boundaries by hand for three chosen seeds; (3) apply(L_DLine_6) cost at q=2^11, m'=16 (must be microseconds — time it yourself); (4) the CONSTRUCTED level by nesting depth for each of the three maps; (5) the five surviving r1 mutants (fig:ld-decider items 2 and 3 replaced by `true`, cheating answers in both orders) are now registered and KILLED. Disagreement with the printed report is MAJOR.
- **Two NEW semantic mutations** not used in r1; apply on a copy; a survivor that should break the construction is MAJOR with the red test as FIX DEMAND.
- **Fidelity, certificate honesty, lockstep, elegance** as in `briefs/templates/rung-critic.md`.
- **Forward look (≤ 8 lines):** does this rung's sampler datatype support DESIGN §9's `SamplerDescription` adapter and the four query modes (Dimension/Marginal/Factor/Linear) that TB5 will call? Name concrete gaps as NOTEs.

## Output: `verdicts/tb1-r2.md`
Adjudication table; recomputations; new objections (N1, N2, …) with severity/location/computation/FIX DEMAND/SURVIVING WEAKER STATEMENT; test/mutation summary lines and walls; your new mutations; per-claim PROMOTE/HOLD for C4a with AUTHORIZED verbatim row text for any PROMOTE (statuses in CLAIMS.md change only via this verdict); final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
