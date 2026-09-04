# Brief 42 — TB0 repair r3 (work order = verdicts/tb0-r2.md: N1–N5 MAJOR, N7 MINOR, X1/X1b/X2/X3 survivors; O6, O15 REJECTED; O14 PARTIAL)

Proposer (Fable). Autonomous; no questions; **no git** (orchestrator commits). Lane: `src/**` TB0 files (`src/ir/circuits.jl`, `src/tb0.jl`, the certificate/replay code, `change_field`), `test/tb0_core.jl`, `test/mutations/run.jl` (runner semantics — shared with every rung: keep all other rungs' mutants listed and KILLED), TB0 mutants. Report: `briefs/42-tb0-repair-r3.last.md` (≤ 30 lines, response table). Also permitted: `docs/DESIGN.md` §5.1 item 5 and the §5 table row ONLY as N7 demands (lockstep), and `claims/CLAIMS.md` C3's where-tested cell ONLY (no status or statement text changes — law 1).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/tb0-r3/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md` (laws 1, 4, 5); `CLAUDE.md`; `docs/DESIGN.md` §1.2–1.4, §3, §5.1; `claims/CLAIMS.md` C1, C2, C3, C8.
2. `verdicts/tb0-r2.md` IN FULL — every FIX DEMAND is binding: N1 (witness (iii) all-zero; `boolean_cube_zero_report(c_0).zero == phi_C(circuit,witness)` for (i), (ii), (iii); the 1,024-witness loop stays but labelled a clause-relation count), N2 (GF(2^11) view via `ev_z(proof11, point)` / carry certified points across `change_field`; `copied_mutant` runs the targeted testset UNMUTATED first and requires exit 0 before crediting a kill — the permanent red test for false kills), N3 (restore `runs("layout_m2")`; X1 and X1b as permanent mutants; testset 7 calls `pcpverifier` on the m=2 layout; guard 5a), N4 (`verify_certificate` on BOTH fixtures' proofs; restore the four witness-(i) assertions; make `:Tseitin`'s replay falsifiable — X4 must be KILLED), N5 (`change_field` returns a `Checked` with root replay `_replay_pcp_degree`; X2 as a permanent mutant), X3 (empty-view replay must not be vacuously true — permanent mutant), N7 (DESIGN §5.1 item 5 + §5 table row match the C1 retraction; state whether the 60 s limit is per rung or per suite — it is per TB0 test body per `test/runtests.jl`; re-point C3 where-tested).
3. `verdicts/tb0-r1.md` and `briefs/20-tb0-repair-r2.last.md` for context. Ground truth as cited there (recompute, never from memory).

## Rules
- Red/green: every restored or new assertion shown RED on a copy (the critic's X1/X1b/X2/X3/X4 mutants are your red witnesses) before GREEN; every new assertion gets a registered mutant shown KILLED under the repaired (unmutated-first) runner.
- TB0 test body must stay under 60 s warm on a quiet machine; report quiet and loaded walls (`pgrep -fa 'runtests|mutations/run'` before measuring).
- Mutation runner: exit 0, every rung's mutants listed KILLED, total wall reported; the runner's unmutated-first check must itself be demonstrated by planting one no-op "mutant" on a copy and showing it is reported UNATTRIBUTABLE, not KILLED.
- N6 (report overwritten) is a harness defect from the codex era: you write the report file directly, so simply do so.

## Report
Response table (N1–N7, X1–X4, O6, O14, O15): FIXED / DOWNGRADED / RESIDUE with file:line; test summary lines + walls; full mutation runner summary; CROSS-LANE EDITS; MERGE PROPOSALS for C1, C2, C3 (verbatim row text; proposals only).
