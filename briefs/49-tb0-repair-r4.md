# Brief 49 — TB0 repair r4 (work order = verdicts/tb0-r3.md: N8 MAJOR; N9, N10, N11, N12 MINOR; N7 PARTIAL) — small, closing round

Proposer (Fable). Autonomous; no questions; **no git**. Lane: `src/tb0.jl`, `src/verifiers/pcp.jl` (`_bind_certificate`, `ev_z`), `src/precompile.jl`, `test/tb0_core.jl`, `test/mutations/run.jl` (additively), TB0 mutants; `docs/DESIGN.md` §5 ONLY as N11/N12 demand; `claims/CLAIMS.md` NOT at all (the orchestrator pastes C1 on the verdict). Report: `briefs/49-tb0-repair-r4.last.md` (≤ 20 lines).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/tb0-r4/`

Read `verdicts/tb0-r3.md` IN FULL (the FIX DEMANDs are binding), `briefs/42-tb0-repair-r3.last.md`, `docs/DESIGN.md` §3, §5.
- **N8**: testset 5a computes `mutated_beta0` from the fixture (`evaluate_arith_formula(tf,z) * prod(view.alpha[i] - z[o_i] for i in (1,3,4,5))`), asserts `!= view.beta0` on both fields; register a permanent mutant moving the certified separator `O2→O3` (`src/tb0.jl:13`) and show it KILLED; re-verify mutant B stays KILLED with the separator moved on a copy (the critic's disarm scenario must now be red).
- **N9**: `@test_throws ArgumentError ev_z(bad_proof, tb0_base_point(GF8))` with `g_1` multiplied by an out-of-block variable; the critic's NM3 registered and KILLED.
- **N10**: `_bind_certificate` binds sub-term replays by identity (`===` on `c0`, `decomposition`, `tf`) so a borrowed certificate is refused; test: witness (iii)'s proof with witness (i)'s certificate must FAIL `verify_certificate`; mutant restoring the detached binding KILLED. (Alternatively amend DESIGN §3 — do NOT choose this; identity binding is what §3 already promises.)
- **N11**: DESIGN §5 sentence recording the precompile workload with the four measured figures (cold image 97 s / 31 s without; test body 38 s / 100 s); print the cold build time from a documented command (e.g. `julia --project=. -e 'using Pkg; Pkg.precompile()'` timed in `test/runtests.jl`'s preamble comment or a `tools/cold_precompile.sh`); wire `MIPSTAR_SKIP_EXPLICIT_PRECOMPILE` into `run.jl` or delete it.
- **N12 / N7 partial**: DESIGN §5.1 items 2 and 6 — strike "and sampled GF(2^11)" from item 6 and say the GF(8) line sweep is witness (i)'s; either extend `encoding_checks` to all of GF(8)^m plus seeded GF(2^11) points (64 + 512 points, cheap) or strike the sentence — prefer extending.
- Whole suite green, TB0 body < 60 s warm quiet, runner exit 0 with every mutant KILLED and baselines ok; report quiet walls.
Report: response table (N7–N12), test/runner lines, CROSS-LANE EDITS (none expected), MERGE PROPOSAL: C1 row = the verdict's authorized text with its two mandatory corrections (verbatim; proposal only).
