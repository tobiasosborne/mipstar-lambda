# Brief 20 — TB0 repair r2 (work order = verdicts/tb0-r1.md: O1–O7 MAJOR, m8–m16 MINOR, NOTEs, §5 elegance)

Proposer (gpt-5.6-sol, xhigh). Autonomous; no questions; no git. Lane: `src/fields/**`, `src/polynomials/**`, `src/ir/**`, `src/verifiers/pcp.jl`, `src/tb0.jl`, `src/precompile.jl`, `src/certificates.jl`, `src/traceprint.jl`, `test/tb0_core.jl`, `test/mutations/run.jl` (TB0 entries only), `test/mutations/tb0_*.jl`, and the clock lines of `test/runtests.jl`. Do NOT touch TB1/TB2 files (`src/samplers/**`, `src/verifiers/ldt.jl`, `src/verifiers/answer_reduce.jl`, `test/tb1_*`, `test/tb2_*`) except where an API change you make forces a one-line adaptation — list every such line under "CROSS-LANE EDITS". Report: `briefs/20-tb0-repair-r2.last.md` with a response table (id → FIXED/RETRACTED/DOWNGRADED/RESIDUE, file:line).

Read `verdicts/tb0-r1.md` IN FULL; `docs/DESIGN.md` §1.3–1.4, §3, §5.1; rk-light law 4/5.

Binding fix demands (apply as adjudicated):
- O1: `using MIPStarLambda` (and any precompile) happens BEFORE the 60 s clock starts; the gate measures the test body only; print cold/warm.
- O2: assert `c₀(b_ρ) ≠ 0` for witness (ii) (design-r4 directive 4) and the per-multiplication vs cumulative budget distinction at witness (i) (directive 5).
- O3: `pcpverifier`/`ev_z` must read the certified sparse expansion: add a terms-vs-evaluation agreement test (replace `c0.terms` by `{}` on a copy must be KILLED); simplify per §5(1): evaluate each c_j from its own terms with a shared power table; delete `SharedEvalPlan`/`EvalDAGNode` and the `_as` raw path; build the GF(2^11) proof directly via `change_field` (the critic measured 1.9 s) and delete `PrimeFieldPCPProof`/`lift_pcp` unless you can show a ≥10 s saving — report the measurement.
- O4: asymmetric m=2 table `[0,0,1,0]` (and one m=3 table) so reversing the index order in `g_a`/`ind` is KILLED; add both as permanent mutants.
- O5: fix `zero_basis_decompose` off the prime subfield (the critic exhibits x³+2x²+3x over GF(8) among 150/512 failing vanishing quartics): the rewrite must be correct for arbitrary GF(2^k) coefficients; add the critic's counterexample family as a test (all 512 univariate quartics vanishing on {0,1}? — do what the verdict specifies) and a mutant that reintroduces the bug.
- O6: implement the `r = 0 ⟺ witness satisfies φ_C` loop over all 1024 five-block witnesses (512 satisfying ⇒ r=0; 512 non-satisfying ⇒ r≠0) — this is claim C2's second clause; measure time and if too slow use the fast witness-(i)-style path or a cheaper equivalent and say so.
- O7: the `:PCPVerifier` CHECKED node must replay something that can fail (e.g. re-run both equations on the stored views).
- m8–m16 and NOTEs: fix or downgrade with one-line reasons. §5 elegance cuts 1–3: apply.
Run `julia --project=. test/runtests.jl` (cold and warm walls) and `julia --project=. test/mutations/run.jl` (all mutant lines, incl. the new ones). Report ≤ 35 lines; MERGE PROPOSALS for C1 and C2 answering the HOLD reasons exactly (statuses proposed TESTED) — proposals only.
