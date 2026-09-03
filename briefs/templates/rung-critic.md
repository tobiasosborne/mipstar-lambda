# Brief — CRITIC verdict rN on rung <TB> (files: <FILES>)

You are the adversarial critic. ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/<TB>-rN.md` ONLY. You may run Julia and create files ONLY under a temp dir you create in the scratch area given below; never edit repo files.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-0dce-432d-85cc-272c91280792/scratchpad/critic-<TB>-rN/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`
2. `CLAUDE.md`, `docs/DESIGN.md` (single source), `docs/definitions.md`, `claims/CLAIMS.md`
3. The rung brief `briefs/<BRIEF>.md` and the proposer's report `briefs/<BRIEF>.last.md`
4. Ground truth cited by the rung (recompute from it, never from memory): <GT LIST>
5. Prior verdicts on this rung, if any (`verdicts/<TB>-r*.md`) — treat as priors; adjudicate deltas; do not re-litigate what passed.
6. The target files.

## Obligations
- **Run** `julia --project=. test/runtests.jl` (or the rung's test entry) yourself and paste the summary line. Then run the mutation runner and paste its summary. A test suite or mutation runner that cannot be run is FATAL.
- **Independent recomputation** of the rung's key numbers on a COPY (never in place): <KEY STEPS — e.g. evaluate g_a at a cube point by hand; verify c₀ = Σ cᵢ zero(zᵢ) coefficientwise for one instance with your own code; count monomials; recompute the degree report>. Disagreement with the proposer's printed report is MAJOR.
- **Write at least two NEW mutations** the proposer did not anticipate (semantic, not syntactic: e.g. swap o_i ↔ 1−o_i; drop one clause; use total- instead of individual-degree bound; replace zero(z) by z²; make L_DLine skip the π_{i−1} projection). Apply on a copy; if the suite stays GREEN under a mutation that should break the construction, that is MAJOR and your fix demand is the red test to add.
- **Fidelity audit** vs the ground truth: every formula and step id in fig:pcpverifier / fig:ld-decider / fig:decider-pcp / def:cl-func that the rung claims to implement.
- **Certificate honesty**: every leaf marked CHECKED is actually checked by code that can fail; every CITED leaf cites an existing label in ground-truth; no derivation tree node is stronger than its children.
- **Lockstep**: DESIGN.md ↔ code ↔ CLAIMS.md ↔ proposer's report. Any status in CLAIMS.md the proposer raised themselves is a violation (law 1).
- **Elegance**: name the three places where the code is more complicated than the mathematics, with a concrete simplification each.

## Output: `verdicts/<TB>-rN.md`
Numbered objections: severity FATAL/MAJOR/MINOR/NOTE · exact location (file:line or DESIGN §) · your independent computation · one-line FIX DEMAND · SURVIVING WEAKER STATEMENT. Then: the test/mutation summary lines you observed; your new mutations and their outcomes; per-claim PROMOTE/HOLD recommendation for the claims this rung targets (with the missing step named for every HOLD). Final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.
