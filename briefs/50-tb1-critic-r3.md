# Brief 50 — CRITIC verdict r3 on rung TB1 after repair r2 (brief 46: objections + §9 describability)

You are the adversarial critic (Opus). ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/tb1-r3.md` ONLY; Julia and files only under the scratch dir; never edit repo files; never run git commands that change state. Evaluate the ARCHIVED tree at commit `dcaaf34` (`git archive dcaaf34 | tar -x -C <scratch>/tree`; instantiate there; cold precompile ~100 s). The live tree is being edited by another worker — never read src/test from it.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb1-r3/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `docs/DESIGN.md` §1.5, §1.6, §5.3–5.4, §9 (as amended at dcaaf34); `claims/CLAIMS.md` (C4a — TESTED; the rows' scope clauses are what brief 46 proposes to change).
2. `verdicts/tb1-r2.md` — your prior; the work order. Do not re-litigate what r2 accepted.
3. `briefs/40-tb1-critic-r2.md`, `briefs/46-tb1-tb2-repair-r2-describable.md` (binding directives incl. the §9 preparation), `briefs/46-tb1-tb2-repair-r2-describable.last.md` (response table, §9-prep table, description sizes, MERGE PROPOSALS, the six "unresolved" items).
4. Ground truth as in brief 40 (recompute, never from memory), plus `gt-04-cl.tex` L122–L130 (rk:higher-level), L572–L601 (def:sampler).

## Obligations
- **Run** the suite (paste summary + TB0 wall; quiet re-run per the timing caveat) and the runner (paste the `MUTATION REGISTRY` line; all KILLED; baselines ok).
- **Adjudicate** every r2 row for this rung (ACCEPTED / REJECTED with residual / PARTIAL) and every §9-prep item claimed for this rung's maps.
- **Independent recomputation on a COPY:** (1) `_build_L_Point` ambient-factor form: `enu:cl-space-sum` replay for all three maps, exhaustive at (8,2,1) — recompute the chain counts [1,8,288]; (2) the four `_child` guards: for EACH of wrong level / wrong rest register / wrong seed_dim / wrong field, check on a copy that disabling ONLY that guard makes its case pass (brief 46 unresolved item 5 — the proposer did not isolate them); (3) `pad_level` APPENDS: `marginal_k(pad(L_ALine,3),z,1)==marginal_k(L_ALine,z,1)` and the CLZero promotion; (4) the diagonal `md` bound red test and NM1; (5) description_size of the three maps (75/132/156 bytes) from your own reserialization; (6) `Factor` domain enforcement (`u in L_{<j}(V)`) vs `Linear` broader domain — probe an unreachable `u` on both. Disagreement with the printed report is MAJOR.
- **Two NEW semantic mutations** not used before; survivors are MAJOR with the red test as FIX DEMAND.
- **§9 readiness verdict (≤ 10 lines):** can TB5's `describe_cl` adapter and the four-query API be used AS IS by `typed_anchor_sampler`/`repeat_sampler` (DESIGN §10)? Name each remaining gap as a NOTE with the file:line that must change.
- **Certificate honesty, lockstep, elegance** per `briefs/templates/rung-critic.md`.

## Output: `verdicts/tb1-r3.md`
Adjudication table; recomputations; new objections (N-numbered continuing from r2) with severity/location/computation/FIX DEMAND/SURVIVING WEAKER STATEMENT; test/runner lines + walls; your mutations; per-claim decision for C4a with AUTHORIZED verbatim row text where the scope clauses change (statuses already TESTED — re-affirm or withdraw); final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
