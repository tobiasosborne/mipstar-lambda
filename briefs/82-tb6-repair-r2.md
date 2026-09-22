# Brief 82 — TB6 repair r2 (work order = `verdicts/tb6-r2.md`: N1, N2, N3 MAJOR; N4–N8 MINOR)

Proposer: the session-5 orchestrator itself (user directive: continue the work; no codex; everything on `main`). Report: `briefs/82-tb6-repair-r2.last.md` (≤ 20 lines). The next critic (TB6 r3) adjudicates it.

Lane: `src/introspect/intro_decider.jl` (the `IntroDecider` replay only); `test/tb6a_audit.jl` (3); `test/tb6b_introspect.jl` (i), (j), (k); `test/mutations/{run,tb6_introspect}.jl`; `test/calibration.jl` (comment); `docs/DESIGN.md` §§10.3, 11.4, 11.6, 12.1, 13.1. Never `claims/CLAIMS.md` (the C14 row's N1–N3 scope sentences are struck only by the next critic).

## Directives (verdict ids)
- **N1.** Named out-of-`V` negative transcripts on TB6b-M (`y⊥` on Read via 3(a), `z` on Sample via 2(b) and 2(a), `x` on Hide via 3(c)), rejected at the parse with no child call past `Dimension`; `M6-in-V` (`_in_V ≡ true`) KILLED; one generic out-of-`V` case in the `IntroDecider` replay.
- **N2.** Pin the timed-out nested accounting in TB6b (k): budget 22,632 → `(22631, [22618, 13])`, 22,622 → `(22622, [22618, 4])`; `M6-nested-timeout-uncharged` (CRIT-5) KILLED.
- **N3.** Code fix is brief 44's. Now: restate DESIGN §11.4 "Nested typed deciders" to what is metered, name the gap `UNCHARGED(owner=tb7-nested-own-steps)`, and pin the identity `by_depth[2] == Σ child-call steps` (15 = 5 + 10) in (k).
- **N4.** The 13 conjunct witnesses are corrupted honest leaves of the TB6b-M fixture and the replay is fixture-generic: record D1(d) as DOWNGRADED (the red capability of the thirteen conjuncts lives at test level, with the diagonal kill matrix); the generic out-of-`V` case (N1) is added to the replay.
- **N5.** Pin `(steps, child_calls)` at 206, 824, 1648 and `child_calls == dim + 6`; say "proxy" for 824/1648 in §12.1 and state the wall as advisory.
- **N6.** Correct (i) §10.3/§13.1 TB5 walls, (ii) §11.6 E/M targets, (iii) §11.4 NOT_EVALUABLE sentence and §11.6 "C14 remains a proposal", (iv) "pinned per oriented pair", (v) the "≥ 12×" ceiling claim (DESIGN §13.1 and `test/calibration.jl`).
- **N7.** Replace §11.4's prose charge list by the exhaustive charge-site table and derive the four `TB6b-M` charge-table values from that table in TB6b (i) (with the test's own GF(2) elimination cost count).
- **N8.** The runner credits only `KILLED` (assertion failure); `KILLED-BY-CRASH` fails the registry; evidence strings on `M5-gate-body-inflated` and `M6b-gate-body-inflated`.
- **Close:** suite `n/n` exit 0; registry `killed=N/N baselines ok=b/b` exit 0 with no KILLED-BY-CRASH.
