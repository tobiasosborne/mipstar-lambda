# Brief — CRITIC verdict r1 on rung tb1 (files: src/samplers/**, src/verifiers/ldt.jl, test/tb1_ld_sampler.jl, test/mutations/tb1_*.jl)

You are the adversarial critic. ATTACK; do not summarize. Work fully autonomously; do not ask questions. Lane: write `verdicts/tb1-r1.md` ONLY. You may run Julia and create files ONLY under a temp dir you create in the scratch area given below; never edit repo files.

Scratch: `/tmp/claude-1000/-home-tobias-Projects-discussions/fee4af66-0dce-432d-85cc-272c91280792/scratchpad/critic-tb1-r1/`

## Read order
1. `~/.claude/skills/rk-light/SKILL.md`
2. `CLAUDE.md`, `docs/DESIGN.md` (single source), `docs/definitions.md`, `claims/CLAIMS.md`
3. The rung brief `briefs/16-tb1.md` and the proposer's report `briefs/<BRIEF>.last.md`
4. Ground truth cited by the rung (recompute from it, never from memory): ground-truth/gt-04-cl.tex (def:cl-func, def:cl-dist, lem:cl-kth, lem:cl-concat, def:register-subspace), ground-truth/gt-03-prelim.tex or gt-04 (def:cl-canonical), ground-truth/gt-07-ldt.tex (def:line, def:line-representative, eq:cl-ptf/alnf/dlnf, eq:chi-func, lem:alnf, lem:dlnf, fig:ld-decider)
5. Prior verdicts on this rung, if any (`verdicts/tb1-r*.md`) — treat as priors; adjudicate deltas; do not re-litigate what passed.
6. The target files.

## Obligations
- **Run** `julia --project=. test/runtests.jl` (or the rung's test entry) yourself and paste the summary line. Then run the mutation runner and paste its summary. A test suite or mutation runner that cannot be run is FATAL.
- **Independent recomputation** of the rung's key numbers on a COPY (never in place): (1) derive by hand the expected histogram supports for q=8, m=2: axis 512, diagonal 18,432 with 512 zero-direction pairs, and confirm against the code's printed numbers AND your own independent sampler; (2) verify L_lnf_v is the CANONICAL linear map of def:cl-canonical (kernel span(v), image the canonical complement as the paper defines it — not merely some complement) on 5 hand-picked v; (3) verify chi(s) bucket boundaries for q=8,m=2 against eq:chi-func; (4) restrict g=1+x1+x1x2 to one axis and one diagonal line by hand and compare; (5) confirm CLStep only admits coordinate-index register subspaces (M6 of design-r1) by reading the constructor and attempting to construct a non-register step. Disagreement with the proposer's printed report is MAJOR.
- **Write at least two NEW mutations** the proposer did not anticipate (semantic, not syntactic: e.g. swap o_i ↔ 1−o_i; drop one clause; use total- instead of individual-degree bound; replace zero(z) by z²; make L_DLine skip the π_{i−1} projection). Apply on a copy; if the suite stays GREEN under a mutation that should break the construction, that is MAJOR and your fix demand is the red test to add.
- **Fidelity audit** vs the ground truth: every formula and step id in fig:pcpverifier / fig:ld-decider / fig:decider-pcp / def:cl-func that the rung claims to implement.
- **Certificate honesty**: every leaf marked CHECKED is actually checked by code that can fail; every CITED leaf cites an existing label in ground-truth; no derivation tree node is stronger than its children.
- **Lockstep**: DESIGN.md ↔ code ↔ CLAIMS.md ↔ proposer's report. Any status in CLAIMS.md the proposer raised themselves is a violation (law 1).
- **Elegance**: name the three places where the code is more complicated than the mathematics, with a concrete simplification each.

## Output: `verdicts/tb1-r1.md`
Numbered objections: severity FATAL/MAJOR/MINOR/NOTE · exact location (file:line or DESIGN §) · your independent computation · one-line FIX DEMAND · SURVIVING WEAKER STATEMENT. Then: the test/mutation summary lines you observed; your new mutations and their outcomes; per-claim PROMOTE/HOLD recommendation for the claims this rung targets (with the missing step named for every HOLD). Final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`.

## Additional obligations
- Isolation: evaluate `git -C /home/tobias/Projects/discussions archive <TB1 commit> | tar -x -C <scratch>/tb1/` (the commit is the one whose message starts "TB1 r0"); other workers edit the live tree.
- Adjudicate the MERGE PROPOSAL in `briefs/16-tb1.last.md` (split C4 at the TB1 boundary; TESTED for the three CL functions' levels + histogram equality; the 18-map product sentence stays CONJECTURE until TB2): authorize exact row text(s) or HOLD.
- Timing: report cold and warm wall for the full suite on the archived copy; if the 60 s gate fails warm on a quiet machine, MAJOR.
