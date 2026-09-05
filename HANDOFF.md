# HANDOFF — mipstar-lambda (session 3, 2026-09-04)

`handoff.md` is the original mandate; this file is the state of the campaign. Read `CLAUDE.md` first, then this, then `claims/CLAIMS.md`, then the latest `worklog/`.

## North star (user)
A COMPLETE executable implementation of `Compress = Repeat ∘ AnswerReduce ∘ Introspect` on verifier *descriptions*, every invariant tracked and adversarially verified (rk-light), plus (a) the pdflatex document `docs/analytic/` (TM → lambda underpinnings with a computability refresher for physicists) — **user directive 2026-09-04: at least one excellent figure on every page; TM and lambda diagrams; the design canvas and figure plan are approved** — and (b) an HTML tutorial artifact for physicists driven by the real objects. Introspect (§8) and Repeat (§11) are BUILT rungs (TB5–TB7), not cited stubs. Soundness theorems stay CITED leaves.


## RESUME AFTER RESTART (written 2026-09-05 ~08:25, machine restart imminent)
Session 3 was running four agents when the user restarted the machine. Everything committed is safe. On disk but UNCOMMITTED (survives the reboot): the Fable worker's partial brief-63 edits in `src/`/`test/` (TB3 repair r1 + TB4 prerequisites) and the tutorial builder's partial `docs/tutorial/**`. Resume protocol:
1. `claude --resume` (or `claude -c`) in this repo to reopen this conversation; say "resume after restart". Then: `git status -s`; `git log --oneline -5`; `ls briefs/63-*.last.md briefs/64-*.last.md verdicts/tb1-r5.md` — each agent was asked to write a WIP checkpoint before the restart; read whichever exist.
2. **Brief 63 (Fable)**: relaunch with the same launch prompt (worklog) plus "start from the on-disk partial state described in briefs/63-tb3-repair-r1.last.md (WIP checkpoint); keep/rework/discard as you see fit". If no checkpoint exists, `git diff --stat` shows the partial state; the agent reads it.
3. **Brief 61 (TB1 critic r5, Opus)**: if `verdicts/tb1-r5.md` is a DRAFT, relaunch the critic on archived 3f2d1f1 telling it to finish from its draft; if absent, relaunch from scratch.
4. **Brief 62 (TB2 critic r5)**: DONE — `verdicts/tb2-r5.md` FAIL(NG1,NG2) committed 076a356; C4b/C9 re-affirmed. Fold NG1/NG2 (two replay cases: diagonal 4(b)/4(c) corrupted-reject) + N27–N30 + tb1-r5's outcome into ONE small TB1/TB2 repair r5 brief (65) — and apply brief 59's DESIGN §9.3/§9.4 wording proposals, which never landed (tb2-r5 N29): §9.4 "a top-level zero map declared on a proper nonempty sub-register is refused by `pad_level`"; §9.3 "stage matrix entries serialized row-major, pinned by an off-diagonal witness; `decode_cl` re-imposes `factor ⊎ rest = {1..n}` on the top stage".
5. **Brief 64 (tutorial artifact, Opus)**: relaunch with the same launch prompt plus "continue from docs/tutorial/** and briefs/64-tutorial-artifact.last.md (WIP checkpoint)". When it lands: publish `docs/tutorial/compress-explained.html` with the Artifact tool (favicon on first publish; title "Compress, Explained"), send the link.
6. Timing: the CPU governor/power profile was switched to performance at ~08:10; the TB0 gate then read 34–35 s (was 74–85 s under powersave + load). Check `powerprofilesctl get` after the reboot — if it reverted to balanced/powersave, ask the user to set performance again before any gate measurement.
7. Worker order after 63: 65 (small) → 24 (TB4) → 39 (TB5) → 43 (TB6) → 44 (TB7). Critic on each landed rung from the template while the worker builds the next.

## Method and roles
- **Session 3 directive (user):** NO codex workers. Critics and visual QA are Opus subagents; the hard main-quest work (landing TB rungs) goes to at most ONE Fable subagent at a time; the analytic doc is a sidequest. Briefs are still written to `briefs/NN-*.md` and reports to `briefs/NN-*.last.md`; the agent is launched with the brief as its work order; proposer agents never run git — the orchestrator commits with status-bearing messages.
- rk-light (`~/.claude/skills/rk-light/SKILL.md`): claims ratchet in `claims/CLAIMS.md`; statuses rise only via a converged verdict in `verdicts/`. The orchestrator may paste rows a verdict marks AUTHORIZED verbatim.
- Proposer: `codex exec` (gpt-5.6-sol, xhigh) from `briefs/NN-*.md`: `nohup codex exec --skip-git-repo-check -s workspace-write -C <repo> -o briefs/NN-*.last.md - < briefs/NN-*.md > briefs/NN-*.codex.log 2>&1 &`. **Waiter pattern:** the brief file is stdin and is NOT on the command line — wait on the `.last.md` argument with a non-self-matching bracket: `while pgrep -f 'NN-slug\.last\.md' >/dev/null; do sleep 30; done` (using `-slug\.md` exits immediately — lesson learned twice).
- Critic: Opus subagent (never Fable), from `briefs/templates/rung-critic.md` / the design-critic pattern (`briefs/29-*`, `33-*`), evaluating an ARCHIVED commit (`git archive <sha> | tar -x -C scratch`). Verdicts in `verdicts/<target>-rN.md`.
- Visual QA on figures: Opus subagents with vision (`briefs/32-figure-visual-qa.md`), one per part file, each compiling into its own `docs/analytic/build/qa<L>/` and looking at rendered pages (`pdftoppm -r 110`). A network outage killed all four once; `SendMessage` to the agent id resumes it with context intact and partial edits survive on disk.
- Lanes are disjoint; `test/runtests.jl` and `test/mutations/run.jl` are shared, so code rungs are SEQUENTIAL. Never run Julia timing checks while a codex worker runs.
- User rules: soften F1 ("our reading may be wrong"); no Fable subagents; tracer bullets; commit and push every checkpoint (public repo, AGPL); no git remote for beads.

## State (2026-09-04, session 3 in flight — see worklog for which lanes are running)
| Lane | State | Next |
|---|---|---|
| Design v1 (§1–8) | converged, design-r4 PASS | — |
| Midpoint toy | C6, N1 PROVED | — |
| TB0 | **CONVERGED** r4 PASS (`verdicts/tb0-r4.md`); C1, C2, C3, C8 TESTED; N13–N16 MINOR folded into brief 23 | — |
| TB1 / TB2 | TB1 CONVERGED (r6 PASS). TB2 repair r6 landed 8a1b6e2 (54-outcome replay); C4b, C9 TESTED | **TB2 critic r7 RUNNING (brief 71, closing)** → paste C9; lane converged on PASS |
| TB3 | repair r1 landed; critic r2 FAIL(N11) (orchestrator's clause narrowing — corrected 443092d); **C10 TESTED**; N12–N17 MINOR folded into brief 24 addendum 3 | — (TB3 minors close inside TB4's round; a TB3 r3 critic is optional) |
| TB4 | **landed 278b1ac** (1253/1253, 115/115): CompressStage interface, contracts, YCode/Fix, Ψ_{M,λ} evaluable, D = Y Ψ (388 bytes), fixed-point equation c_Y=3; C11 proposed TESTED | **critic r1 + TB5 readiness gate RUNNING (brief 70)** → paste C11 if authorized; worker → brief 39 (TB5) after brief 69 |
| TB5 | **RUNNING (brief 39 + addenda 1–3, Fable)** — §9 description layer (all composites describable) + §10 anchoring/81-fold Repeat as a real CompressStage | forward the TB4 critic's TB5-readiness notes to the worker via SendMessage when brief 70 lands; when TB5 lands: verify, commit, Opus critic r1, worker → brief 43 (TB6) |
| TB6, TB7 | briefs 43, 44 written | sequential on the one Fable worker; critics in parallel |
| **DESIGN v2 (§9–13)** | **CONVERGED**: r1 FAIL(10) → r2 FAIL(2) → r3 PASS (`verdicts/design-v2-r3.md`); C12–C15 all CONJECTURE in CLAIMS; TB5 implementation-ready; briefs 39 (TB5), 43 (TB6), 44 (TB7) written | — |
| **Analytic doc (sidequest)** | **CONVERGED** r3 PASS (`verdicts/analytic-doc-r3.md`); 92 pp, 110 figures; PDF v6 sent | pedagogy round (bd d48: n6–n10) and lockstep updates as TB3–TB7 land — low priority |
| Figure atlas canvas | published: https://claude.ai/code/artifact/d3c355d4-541f-4983-a57f-4d6d7ca097f1 (user approved the direction) | optional: re-seed with rendered figure PNGs as a review gallery (working files in the session scratchpad `atlas/` — regenerate from `docs/analytic` if lost) |
| Tutorial artifact | **v1 PUBLISHED**: https://claude.ai/code/artifact/f58405e9-db42-4e9b-ab26-aa41c5c9ff12 (source `docs/tutorial/compress-explained.html`, brief 64; 16 chapters, six WebM clips, three.js machine room; every number from the repo) | republish (same file path in this session, or `url`) as TB3–TB7 land: chapters 11–14 flip from "designed"/"no claim row" to executed; keep the claims table verbatim |

If a worker is running when you resume: `pgrep -fa 'codex exec'`; if none, its lane's files are final — verify (compile / tests), commit with a status-bearing message, push.

## docs/analytic layout (new this session)
`analytic-underpinnings.tex` = preamble (Libertinus / Source Sans / Inconsolata, `\input{figstyle}`, two-column TOC + roadmap figure) + `\input{parts/part1a,1b,2a,2b}`. `figstyle.tex` = the ONLY colours/styles (roles machine/term/desc/check/cited/focus/bad). `FIGURES.md` = visual system rules + 76-figure plan. `figs/fig-<slug>.tex` = one tikzpicture each. `tools/figcoverage.py [aux] [--from A --to B]` = pages without a figure (exit 1 if any). `build/` is gitignored; lanes compile with `-output-directory=build/<lane>`. Known source typo fixed: `,qquad` → `,\qquad` in §7.1.

## Findings so far
- F1 (`docs/findings.md`, C8 TESTED): as we read NW19's Tseitin gadget, a gate wire with fan-out f has individual degree 2+2f, not 2; theorem survives with `deg_F + 5d`, d ≥ 8. Framing stays soft.
- F2: NW19's Tseitin formula omits the output literal; we add `w_out`.
- Design-level SOURCE_REPAIRs: `dim V_{6,coord}=6`; `L^lnf_0 = id`; `P_formula_structural`; **new in v2: `intro-3Q-guard` (operative `>3Q`, literal `≥3Q` printed with its rejection count 10/116, 22/128), `intro-decider-fixed-width`**.
- Critic r2's cross-cutting observation: O2, N1, N2 are one pattern — a paper-parameter guard that stops admitting the honest witness at toy size; §12.4 needs the rule "such guards print VACUOUS/FAIL with an owner" (brief 34 directive).

## Housekeeping
- Public repo: https://github.com/tobiasosborne/mipstar-lambda (pushed 2026-09-05). **GitHub Pages site: https://tobiasosborne.github.io/mipstar-lambda/** = `docs/index.html`, built from `docs/tutorial/compress-explained.html` by `tools/build_site.py` (source branch main, path /docs; the PDF is served at /analytic/analytic-underpinnings.pdf). README redesigned around the explainer. After each explainer republish: run `python3 tools/build_site.py`, commit `docs/index.html`, push.
- Beads: epic `mipstar-lambda-hd8` (figure programme) with lanes 30A–D closed, 32A/C/D in progress, 32B closed; `5iy`/`kjn` closed; `9w7` (brief 34) in progress; TB5–TB7 and tutorial open.
- Memory: `~/.claude/projects/-home-tobias-Projects-discussions/memory/mipstar-lambda-campaign.md`.
