# HANDOFF — mipstar-lambda (session 1, 2026-09-03/04)

`handoff.md` is the original mandate; this file is the state of the campaign. Read `CLAUDE.md` first, then this, then `claims/CLAIMS.md`, then the latest `worklog/`.

## North star (user)
A COMPLETE executable implementation of `Compress = Repeat ∘ AnswerReduce ∘ Introspect` on verifier *descriptions*, every invariant tracked and adversarially verified (rk-light), plus (a) a pdflatex document `docs/analytic/` explaining the Turing-machine → lambda-calculus underpinnings with a computability refresher for physicists, and (b) an HTML tutorial artifact for physicists driven by the real objects and traces. Introspect (§8) and Repeat (§11) are to be BUILT (TB5–TB7), not cited. Soundness theorems stay CITED leaves; constructions are executed and their bookkeeping CHECKED.

## Method and roles
- rk-light (`~/.claude/skills/rk-light/SKILL.md`): claims ratchet in `claims/CLAIMS.md`; statuses rise only via a converged verdict in `verdicts/`.
- Proposer: `codex exec` (gpt-5.6-sol, xhigh, the config default) from briefs in `briefs/NN-*.md`, launched as `nohup codex exec --skip-git-repo-check -s workspace-write -C <repo> -o briefs/NN-*.last.md - < briefs/NN-*.md`. Workers write their own `.last.md` mid-run, so wait on PROCESS EXIT with a non-self-matching pattern, e.g. `while pgrep -f "briefs/2[1]-tb1" >/dev/null; do sleep 15; done`.
- Critic: Opus subagent (never Fable), brief from `briefs/templates/rung-critic.md`, evaluating an ARCHIVED copy of a named commit (`git archive <sha> | tar -x -C scratch`) because other workers edit the live tree. Verdicts in `verdicts/<rung>-rN.md`.
- Never run Julia timing checks while a codex worker runs (contention). Lanes must be disjoint; `test/runtests.jl` and `test/mutations/run.jl` are shared, so code rungs are SEQUENTIAL.
- User rules: soften the F1 framing (never "error in the paper"; "our reading may be wrong"); no Fable subagents; tracer bullets; commit and push every checkpoint (public repo, AGPL).

## State at pause
| Rung | Commit state | Verdict | Next |
|---|---|---|---|
| Design v1 (§1–8) | converged | design-r4 PASS | — |
| Midpoint toy | C6, N1 PROVED | midpoint-r2 PASS | — |
| TB0 | repair r2 landed (175/175 warm 35.9 s) | tb0-r1 FAIL(7 MAJOR) → repaired | critic r2 (brief from template; adjudicate O1–O16; MERGE PROPOSALS C1, C2 in `briefs/20-tb0-repair-r2.last.md`) |
| TB1 | r0 landed; C4a TESTED; repair r1 (brief 21) INTERRUPTED by the user's stop — partial state is on branch `wip/tb1-tb2-repair-r1` (pushed), NOT on main; on that branch the suite is 220/221 assertions green (only the cold-precompile timing gate tripped), 6 new TB1 mutant files added, mutation runner NOT re-run | tb1-r1 FAIL(O1,O2,O3,O5) | resume on that branch (rebase onto main first) from brief 21 (`briefs/21-tb1-repair.last.md` may be absent: reconstruct from `git diff 4a3474c HEAD -- src test`); run mutations; then critic r2 for TB1 and TB2 |
| TB2 | r0 landed; partially repaired by the interrupted brief 21 (lazy CL adapter work, TB2 tests/mutants edited) | tb2-r1 FAIL(O1 FATAL runner, O2–O7); C9, C4b HOLD | same as TB1 |
| TB3 | brief 23 written | — | launch after TB1+TB2 repair lands and its critic passes |
| TB4 | brief 24 written | — | after TB3 |
| TB5 Repeat, TB6 Introspect, TB7 end-to-end | DESIGN v2 LANDED (DESIGN.md §9–13, 691 lines; C12–C15 proposed in `briefs/28-design-v2-full-compress.last.md`) | none yet | Opus critic on DESIGN v2 (brief from `briefs/02-design-critic.md` pattern; recompute the toy dimensions 206→840→848→1696 and the level chain 9→5→7→9) → repair → TB5 → TB6 → TB7 |
| Analytic doc | v3 committed: 47 pp, Part I = 14-page computability refresher, 13 reminder boxes | none yet | Opus critic on the document (fidelity to ground truth + pedagogy + the softened F1 framing) |
| Tutorial artifact | bd issue open | — | after TB4; use the Artifact tool with `artifact-design`; drive it from the real trace printouts |

No worker is running at the end of session 1 (all three were stopped/finished before the final push). If a worker is running when you resume: check `pgrep -x codex`; if none, its lane's files are final — run `julia --project=. test/runtests.jl` (warm, twice) and `test/mutations/run.jl` on a quiet machine, then commit with a status-bearing message and push.

## Findings so far
- F1 (`docs/findings.md`, claim C8 TESTED): as we read NW19's Tseitin gadget, a gate wire with fan-out f has formal individual degree 2+2f, not 2; the theorem survives with `deg_F + 5d` and d ≥ 8. Framing must stay soft.
- F2: NW19's Tseitin formula omits the output literal; we add `w_out`.
- Design-level: `dim V_{6,coord}` is 6 (eq:V-pcp) not m′ (SOURCE_REPAIR in DESIGN); `L^lnf_0 = id` is a SOURCE_REPAIR for singleton lines; def:pcpparams's literal `(2+5k)` predicate vs the structural one is tracked as `P_formula_structural`.
- Structural: the paper's sampler is a TM answering four queries (`dimension`, `marginal`, `linear`, `factor`; def:sampler); anchoring, repetition, downsizing, detyping and introspection are all wrappers over those queries. DESIGN v2 makes that interface the API.

## Housekeeping
- Public repo: https://github.com/tobiasosborne/mipstar-lambda (no beads remote; `bd` is local). History still contains ~93 MB of codex transcripts from early commits (now gitignored/untracked); purge with `git filter-repo --force --path-glob 'briefs/*.codex.log' --invert-paths` on a CLEAN tree, then force-push (nobody has cloned).
- Beads: `bd ready` lists TB5–TB7 and the tutorial; design residue R9/R10 filed for TB4.
- Memory: `~/.claude/projects/-home-tobias-Projects-discussions/memory/mipstar-lambda-campaign.md`.
