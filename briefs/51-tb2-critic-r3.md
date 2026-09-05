# Brief 51 — CRITIC verdict r3 on rung TB2 after repair r2 (brief 46: objections + §9 describability)

You are the adversarial critic (Opus). ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/tb2-r3.md` ONLY; Julia and files only under the scratch dir; never edit repo files; never run git commands that change state. Evaluate the ARCHIVED tree at commit `dcaaf34` (`git archive dcaaf34 | tar -x -C <scratch>/tree`; instantiate there; cold precompile ~100 s). The live tree is being edited by another worker — never read src/test from it.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/critic-tb2-r3/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`; `CLAUDE.md`; `docs/DESIGN.md` §1.5, §1.6, §5.3–5.4, §9 (as amended at dcaaf34); `claims/CLAIMS.md` (C4b, C9 — TESTED; the rows' scope clauses are what brief 46 proposes to change).
2. `verdicts/tb2-r2.md` — your prior; the work order. Do not re-litigate what r2 accepted.
3. `briefs/41-tb2-critic-r2.md`, `briefs/46-tb1-tb2-repair-r2-describable.md` (binding directives incl. the §9 preparation), `briefs/46-tb1-tb2-repair-r2-describable.last.md` (response table, §9-prep table, description sizes, MERGE PROPOSALS, the six "unresolved" items).
4. Ground truth as in brief 41 (recompute, never from memory), plus `gt-04-cl.tex` L122–L130 (rk:higher-level), L572–L601 (def:sampler).

## Obligations
- **Run** the suite (paste summary + TB0 wall; quiet re-run per the timing caveat) and the runner (paste the `MUTATION REGISTRY` line; all KILLED; baselines ok).
- **Adjudicate** every r2 row for this rung (ACCEPTED / REJECTED with residual / PARTIAL) and every §9-prep item claimed for this rung's maps.
- **Independent recomputation on a COPY:** (1) `sample_answer_reduce_questions` is a projection of `sample(verifier.sampler,(l,r),seed)` — verify with your own summand-swap mutant (ND2) and one new one; (2) the tensor `E^ora x E^pcp` equals the complete 54^2 graph here and the DESIGN red-test edge is present; (3) the 7-case replay asserts honest-accept AND corrupted-reject with expected rules — re-run ND4; (4) the chain set `tb2-chi16-directed+rng20(0x9C)`: recompute distinct chains and completed replays per map; (5) description_size of the 18 PCP maps (3009/2893/10228/2754/10479) by your own reserialization; the 54 product maps are `NotDescribable` (brief 46 unresolved item 1) — is that honestly stated and is it acceptable for DESIGN §9.4 `DL9-direct-sum`?; (6) the C4b/C9 scope clauses proposed in brief 46's report vs the rows now in CLAIMS.md. Disagreement with the printed report is MAJOR.
- **Two NEW semantic mutations** not used before; survivors are MAJOR with the red test as FIX DEMAND.
- **§9 readiness verdict (≤ 10 lines):** can TB5's `describe_cl` adapter and the four-query API be used AS IS by `typed_anchor_sampler`/`repeat_sampler` (DESIGN §10)? Name each remaining gap as a NOTE with the file:line that must change.
- **Certificate honesty, lockstep, elegance** per `briefs/templates/rung-critic.md`.

## Output: `verdicts/tb2-r3.md`
Adjudication table; recomputations; new objections (N-numbered continuing from r2) with severity/location/computation/FIX DEMAND/SURVIVING WEAKER STATEMENT; test/runner lines + walls; your mutations; per-claim decision for C4b, C9 with AUTHORIZED verbatim row text where the scope clauses change (statuses already TESTED — re-affirm or withdraw); final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
