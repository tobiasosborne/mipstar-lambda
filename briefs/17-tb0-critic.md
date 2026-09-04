# Brief — CRITIC verdict r1 on rung tb0 (files: Project.toml, src/**, test/**)

You are the adversarial critic. ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/tb0-r1.md` ONLY. You may run Julia and create files ONLY under a temp dir you create in the scratch area given below; never edit repo files.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-0dce-432d-85cc-272c91280792/scratchpad/critic-tb0-r1/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`
2. `CLAUDE.md`, `docs/DESIGN.md` (single source), `docs/definitions.md`, `claims/CLAIMS.md`
3. The rung brief `briefs/14-tb0-repair.md` and the proposer's report `briefs/<BRIEF>.last.md`
4. Ground truth cited by the rung (recompute from it, never from memory): ground-truth/gt-03-prelim.tex (sec:ld-encoding, lem:schwartz-zippel, admissible field sizes), ground-truth/gt-10-answer-reduction.tex (def:tseitin, def:formula-arithmetization, prop:tseitin-arith-degree, prop:zero-basis, def:pcpparams, def:pcp-proof, def:pcp-eval, fig:pcpverifier, thm:pcp-decider), ground-truth/nw19/nw19-tseitin-arith.tex
5. Prior verdicts on this rung, if any (`verdicts/tb0-r*.md`) — treat as priors; adjudicate deltas; do not re-litigate what passed.
6. The target files.

## Obligations
- **Run** `julia --project=. test/runtests.jl` (or the rung's test entry) yourself and paste the summary line. Then run the mutation runner and paste its summary. A test suite or mutation runner that cannot be run is FATAL.
- **Independent recomputation** of the rung's key numbers on a COPY (never in place): (1) rebuild F_arith for the TB0 circuit with YOUR OWN sparse arithmetic and confirm the occurrence vector (2,0,0,0,2, 2,0,0,0,0, 6,4,4,4,4,3) equals the actual individual-degree vector; (2) for witness (ii)=([0,1])^5 confirm c₀ vector (3,1,1,1,3,3,1,1,1,1,6,4,4,4,4,3), normalized support 534,912 in char 2, remainder 0, coefficient identity; (3) evaluate pcpverifier by hand at b_ρ and at b_ρ[O2←ρ] in GF(8) (honest β₀ = 2, mutation-B β₀ = 1) and GF(2^11) (96 vs 48); (4) verify GF(2^11) modulus irreducibility independently; (5) confirm the lifted proof agrees with a direct GF(2^11) evaluation at ≥50 points of your choosing; (6) check the six def:pcpparams predicate reports (TB0-small: PASS,FAIL,FAIL,FAIL,FAIL,FAIL; TB0-sampled: PASS,NOT_EVALUABLE,PASS,PASS,PASS,PASS) against def:pcpparams line by line. Disagreement with the proposer's printed report is MAJOR.
- **Write at least two NEW mutations** the proposer did not anticipate (semantic, not syntactic: e.g. swap o_i ↔ 1−o_i; drop one clause; use total- instead of individual-degree bound; replace zero(z) by z²; make L_DLine skip the π_{i−1} projection). Apply on a copy; if the suite stays GREEN under a mutation that should break the construction, that is MAJOR and your fix demand is the red test to add.
- **Fidelity audit** vs the ground truth: every formula and step id in fig:pcpverifier / fig:ld-decider / fig:decider-pcp / def:cl-func that the rung claims to implement.
- **Certificate honesty**: every leaf marked CHECKED is actually checked by code that can fail; every CITED leaf cites an existing label in ground-truth; no derivation tree node is stronger than its children.
- **Lockstep**: DESIGN.md ↔ code ↔ CLAIMS.md ↔ proposer's report. Any status in CLAIMS.md the proposer raised themselves is a violation (law 1).
- **Elegance**: name the three places where the code is more complicated than the mathematics, with a concrete simplification each.

## Output: `verdicts/tb0-r1.md`
Numbered objections: severity FATAL/MAJOR/MINOR/NOTE · exact location (file:line or DESIGN §) · your independent computation · one-line FIX DEMAND · SURVIVING WEAKER STATEMENT. Then: the test/mutation summary lines you observed; your new mutations and their outcomes; per-claim PROMOTE/HOLD recommendation for the claims this rung targets (with the missing step named for every HOLD). Final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.

## Additional obligations specific to TB0 (from verdicts/design-r4.md §3 and the orchestrator)
- Confirm the two extra design-r4 directives are implemented: (4) an assertion that the sixteen named GF(8) lines are non-vacuous for witness (ii) (c₀(b_ρ) ≠ 0); (5) an assertion of the cumulative-vs-per-multiplication budget distinction at witness (i).
- The suite must pass the 60 s gate on YOUR run of `julia --project=. test/runtests.jl` with nothing else running; report wall time. A gate that fails on a quiet machine is MAJOR; a gate that passes only because a check was weakened is MAJOR (diff test/tb0_core.jl against commit d196bdd to see what changed).
- No `/tmp` depot manipulation may remain in test sources.
- `pcpverifier` must be layout-driven (no hard-coded `5 + i`); check with the m=2 test and by reading the code.
- Fidelity: fig:pcpverifier steps 4–5 exactly; def:pcp-eval ordering of (α₁..α₅, β₀..β_{m'}); g_a per eq:ld-encoding; zero-basis order and the d−2 bookkeeping per prop:zero-basis.
- Elegance: does the code read like DESIGN.md/definitions.md? Name the three worst spots with concrete simplifications (this feeds the user's north star).
- Adjudicate the MERGE PROPOSALS in `briefs/14-tb0-repair.last.md` for C1, C2, C3, C8: PROMOTE to TESTED (authorize exact row text) or HOLD with the missing step. C8's proposed row also asserts the general occurrence formula; check whether the code/tests establish it generally or only on two instances, and scope the row accordingly.

## Isolation (mandatory)
A TB1 worker is concurrently adding files under src/samplers, src/verifiers/ldt.jl and test/. Evaluate the COMMITTED TB0 state only: run `git -C /home/tobias/Projects/discussions archive 747f746 | tar -x -C <your scratch dir>/tb0/` and run all tests/mutations there (`julia --project=. test/runtests.jl`; note the first run includes precompilation — report both cold and warm wall times). Read code from that copy. Your verdict cites file:line in that copy (identical to commit 747f746).
