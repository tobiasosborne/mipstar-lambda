# Brief — CRITIC verdict r1 on rung tb2 (files: src/samplers/pcp_sampler.jl, src/samplers/oracularize.jl, src/verifiers/answer_reduce.jl, test/tb2_answer_reduce.jl, test/mutations/tb2_*.jl)

You are the adversarial critic. ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/tb2-r1.md` ONLY. You may run Julia and create files ONLY under a temp dir you create in the scratch area given below; never edit repo files.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-0dce-432d-85cc-272c91280792/scratchpad/critic-tb2-r1/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`
2. `CLAUDE.md`, `docs/DESIGN.md` (single source), `docs/definitions.md`, `claims/CLAIMS.md`
3. The rung brief `briefs/18-tb2.md` and the proposer's report `briefs/<BRIEF>.last.md`
4. Ground truth cited by the rung (recompute from it, never from memory): ground-truth/gt-10-answer-reduction.tex sec:ld-compiler (sampler paragraphs incl. eq:V-pcp, table:tpcp, fig:decider-pcp, thm:ar), ground-truth/gt-09-oracularization.tex (typed oracularized sampler and decider), ground-truth/gt-06-types.tex (typed samplers, product type graphs), ground-truth/gt-07-ldt.tex (fig:ld-decider, ldparams)
5. Prior verdicts on this rung, if any (`verdicts/tb2-r*.md`) — treat as priors; adjudicate deltas; do not re-litigate what passed.
6. The target files.

## Obligations
- **Run** `julia --project=. test/runtests.jl` (or the rung's test entry) yourself and paste the summary line. Then run the mutation runner and paste its summary. A test suite or mutation runner that cannot be run is FATAL.
- **Independent recomputation** of the rung's key numbers on a COPY (never in place): (1) transcribe fig:decider-pcp yourself and check every guard, every type pair, the i in {3,4,5} restriction and both ldparams tuples against the implementation; (2) verify the register dimensions of eq:V-pcp incl. the V_{6,coord} SOURCE_REPAIR (6 vs m') and that the product sampler really pushes ONE uniform seed through a pair of CL maps per oriented edge (typed-CL semantics, not an independent mixture); (3) verify the honest strategy answers are the actual restrictions of the PCP polynomials (recompute two line answers by hand from Π); (4) verify step 5 (game check) is non-vacuous: what (x,y) reaches pcpverifier and is the oracularized L^alice/L^bob used; (5) check the no-check fraction 76/81 by your own count of ordered type pairs; (6) write two new semantic mutants (e.g. swap alpha_v vs alpha_v' in input consistency; use ldparams instead of ldparams' for the simultaneous test) and confirm they are KILLED. Disagreement with the proposer's printed report is MAJOR.
- **Write at least two NEW mutations** the proposer did not anticipate (semantic, not syntactic: e.g. swap o_i ↔ 1−o_i; drop one clause; use total- instead of individual-degree bound; replace zero(z) by z²; make L_DLine skip the π_{i−1} projection). Apply on a copy; if the suite stays GREEN under a mutation that should break the construction, that is MAJOR and your fix demand is the red test to add.
- **Fidelity audit** vs the ground truth: every formula and step id in fig:pcpverifier / fig:ld-decider / fig:decider-pcp / def:cl-func that the rung claims to implement.
- **Certificate honesty**: every leaf marked CHECKED is actually checked by code that can fail; every CITED leaf cites an existing label in ground-truth; no derivation tree node is stronger than its children.
- **Lockstep**: DESIGN.md ↔ code ↔ CLAIMS.md ↔ proposer's report. Any status in CLAIMS.md the proposer raised themselves is a violation (law 1).
- **Elegance**: name the three places where the code is more complicated than the mathematics, with a concrete simplification each.

## Output: `verdicts/tb2-r1.md`
Numbered objections: severity FATAL/MAJOR/MINOR/NOTE · exact location (file:line or DESIGN §) · your independent computation · one-line FIX DEMAND · SURVIVING WEAKER STATEMENT. Then: the test/mutation summary lines you observed; your new mutations and their outcomes; per-claim PROMOTE/HOLD recommendation for the claims this rung targets (with the missing step named for every HOLD). Final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.

## Additional obligations
- Isolation: evaluate `git -C /home/tobias/Projects/discussions archive 4a3474c | tar -x -C <scratch>/tb2/`; other workers edit the live tree. Report cold and warm walls and machine load.
- The lane-local lazy CL adapter (`PCPCLMap`): is its level CONSTRUCTED by nesting depth like `CLStep`, or is it a fresh unverified datatype? Does it satisfy def:cl-func (register subspaces, linear stage maps, continuation depending only on earlier stage outputs)? If not, C4b cannot be promoted.
- Adjudicate MERGE PROPOSALS C9 (new row) and C4b in `briefs/18-tb2.last.md`: authorize exact row text or HOLD with the missing step.
