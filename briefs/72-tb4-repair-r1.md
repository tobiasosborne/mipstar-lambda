# Brief 72 — TB4 repair r1 (work order = verdicts/tb4-r1.md: O1–O5 MAJOR; O6–O14 MINOR; N1–N4 NOTE) — queued after TB5; coordinate with TB5's carrier/params changes

Proposer (Fable). Autonomous; no questions; **no git**. Lane: `src/compress.jl`, `src/ir/programs.jl` (additive), `test/tb4_compress_ir.jl`, `test/mutations/tb4_*.jl`, `test/mutations/run.jl` (additively), `docs/DESIGN.md` §5.6 and §1.1/§1.6 ONLY as the verdict demands, `docs/definitions.md` §F row for the new SOURCE_REPAIR. Report: `briefs/72-tb4-repair-r1.last.md` (≤ 25 lines).

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/548f633b-c857-457a-bb33-0aa1a7879403/scratchpad/tb4-r1/`

Read `verdicts/tb4-r1.md` IN FULL — every FIX DEMAND is binding:
- **O1** the origin-order conjunct of `_level_chain_ok` gets a red witness (a hand-built swapped chain replay must fail; the critic's CRITIC-2 registered and KILLED).
- **O2** ℓ = 9 pinned: `Compress` of a deliberately non-9-level verifier yields the hypothesis-violated node (CRITIC-1 KILLED).
- **O3** the third stub disclosed: `[ASSUMED] CompressStubInTerm` under `:Verifier`/`:Specialize` naming `COMPRESS_STUB` (46 of 376 bytes) and that testset (b)'s compressed branch runs it.
- **O4** `SOURCE_REPAIR(:HaltDeciderFuelBound)` under `:Specialize` with a definitions §F row: the outer `Eval`'s `FuelBound(n,λ)` is a construction change — fig:halt_f step 5 (gt-12:L451–453) has no budget; `TIME ≤ n^λ` is lem:lambda's conclusion.
- **O5** DESIGN §5.6: apply brief 24's MERGE PROPOSAL (2) verbatim ("require the origin order …"), striking the unattainable "chain differs from 5→7→9".
- **O6–O14, N1–N4**: as demanded (Compressor sort wording; Introspect hypotheses prefixed "(completeness/soundness only)"; `:UpstreamReproduction` as a CONSTRUCTED child; the two-verifier independence test in the form TB4 supports; surrogate re-parenting so the disclosure is the PARENT of the fixture subtree; source/lines facts on the two nodes; the L239–L243 off-by-one; the TB4 5 s budget as a calibrated or env-var assertion (tb1-r5 N33); `M-specialize-open` registered; the circular §F justification replaced by fig:halt_f step 3 + lem:dhalt-values + lem:compress-independent-samplers).
- **C16/C18**: the orchestrator applied the critic's two caveats to the rows; do not touch CLAIMS. C11 (weaker) is TESTED; propose the strengthened C11 row for the critic (verbatim; proposal only).
Coordinate with what TB5 (brief 39) changed in `src/compress.jl` (StageVerifier carrier, params NamedTuple) — build on it, do not revert it. Red/green with the critic's survivors as red witnesses; every new assertion gets a registered mutant KILLED; runner exit 0; suite under the TB0 gate quiet (`uptime`).
