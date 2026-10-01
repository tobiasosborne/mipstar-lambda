# Brief 94 — PROPOSER (Opus): analytic document repair r2 (verdicts/analytic-doc-r4.md R1–R4 MAJOR, R5–R11 MINOR)

Role: Opus writer/editor. Autonomous; no questions. Lane: `docs/analytic/**` and `briefs/94-analytic-repair-r2.last.md` ONLY. No Julia (another worker owns it; use `grep -rn` over `src/`, `test/`, `toys/` for code facts). pdflatex in place (PDF tracked; rebuild twice, leave it). No git commands that change state. Never edit `verdicts/**`, `claims/CLAIMS.md`.

## Specification
`verdicts/analytic-doc-r4.md` IN FULL: every R-item's finding and the §7 repair plan are binding. Then `briefs/89-analytic-lockstep-r1.last.md`, `briefs/91-analytic-citation-fix.last.md` (what r1 changed), `verdicts/tb7-r1.md` §1 (T7-1…T7-9: the TB7 facts the document must now reflect: C15 HOLD; replay not bound to node facts; zero introspection predicate dispatch at TB7 since Q=2<s=9; AR agreement 4/9 failed CHECKED; pair-padding deviation), `verdicts/tb6-r4.md` head (C14 HOLD; R1 discharged; T6-1/T6-2 open).

## Rules
- The document may never be AHEAD of `claims/CLAIMS.md`, and where the latest converged verdict is stricter than a stale CLAIMS sentence, the document follows the VERDICT (critic's ruling, §"Four MAJOR"). Concretely: C10 TESTED but the equality fixture is refused by `arith_q` and never reaches `build_pcp` (R1) — state the true scope; C15 CONJECTURE/HOLD with the exact surviving weaker statements from tb7-r1 (R2: no Pauli predicate executes at TB7); Fig 104 splits TB2/C9 evidence from TB7/C15 (R3); the universal "stale evidence unrepresentable / any mutation turns the suite red" assurance is withdrawn and replaced by what is actually tested and what tb7-r1 T7-2 found (R4).
- "pending critic r1" language → the actual state: FAIL/HOLD with a repair round in progress (brief 93), historical runs labelled with their dates (R7).
- R5/R6 source attributions, R8 product provenance, R9 detyping representation, R10 blanket theorem coverage, R11 tick overlap: fix each exactly as the verdict specifies; verify every ground-truth citation you touch by opening the lines.
- Visual system unchanged; `python3 tools/figcoverage.py` exit 0; 0 undefined refs; report pages/overfull/underfull before/after.

## Output
`briefs/94-analytic-repair-r2.last.md` (≤ 60 lines): per R1–R11: DONE/PARTIAL/NOT with file:line, old→new (short), authority used; build numbers; anything you dispute in the verdict with evidence. Hand back a 10-line summary.
