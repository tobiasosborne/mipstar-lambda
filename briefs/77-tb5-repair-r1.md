# Brief 77 — TB5 repair r1 (work order = verdicts/tb5-r1.md: O1, O2 MAJOR; O3–O7 MINOR; O8–O12 NOTE; the gate conditions) — small

Proposer (Fable). Autonomous; no questions; **no git**. Lane: `src/descriptions/**`, `src/repeat/**`, `test/tb5_repeat.jl`, `test/mutations/tb5_*.jl`, `test/mutations/run.jl` (additively), `test/runtests.jl` ONLY for the gate conditions. Report: `briefs/77-tb5-repair-r1.last.md` (≤ 20 lines).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/tb5-r1/`

Read `verdicts/tb5-r1.md` IN FULL. Binding:
- **O1**: `T5-last-corrupt` — an all-Game transcript with component k (=81) flipped must reject; the critic's discard-k-th mutant registered and KILLED.
- **O2**: (i) `_metered_node` pins `Factor`/`Linear` counts exactly where the critic says; (ii) a prefix-DEPENDENT-factor child fixture (the critic built one: clean `[0,1,1,0|0,1,0,0|…]` = gt-11:L281) so the per-block child Factor is red-capable; the replicate-block-1 mutant registered and KILLED.
- **O3**: integrality of the VALUE: evaluate `(λn)^{(1+c')τ}` exactly (rational arithmetic) and refuse only when the value is not a positive integer (c'=1/2, n=9 → k=27 must be accepted); `QueryError` text truthful.
- **O4**: a `SOURCE_REPAIR`/`ASSUMED` node `RepeatGuardExponent` for the gt-11:L219/L220 inconsistency (consistent only when c'=1).
- **O5**: assert the §10.3 numbers (construction < 2 s, transcripts < 5 s) as tests, not prints; **O6**: assert the exact node census tuple `(55, 9, 27, 10, 4, 5)` (adjusted for the nodes you add) and the grade counts; **O7**: DESIGN sentences already landed by the orchestrator (§9.2, §9.3, §9.4, §10.2 with `k(n)(B(n)+32)`) — verify code agrees; O7's remaining code items as demanded; **O8**: print the per-run edge-view / `(Game,Game)` component counts (159 / 40 of 10,368) and add them to the C13 evidence.
- **Gate conditions (approved with conditions)**: keep `elapsed < 60` hard; the calibration kernel named, deterministic, in-process and EXCLUDED from the timed body; the ratio gate a hard `@test`; and a **mandatory red test**: an owned mutant that inflates the TB0 body (or the TB4/TB5 body under the ratio) must fail the gate — register it and show it KILLED. Document kernel + measured quiet value in DESIGN §13.1 (propose the sentence).
- Every new assertion gets a registered mutant KILLED; baseline-first runner exit 0; suite quiet (`uptime`). MERGE PROPOSALS: C12/C13 with the O1/O2 scope sentences struck once fixed (verbatim; proposals only).
