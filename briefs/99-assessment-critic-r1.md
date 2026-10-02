# Brief 99 — CRITIC (codex gpt-6-astra xhigh): final assessment draft r1 (bd f7v)

You are a rigorous, skeptical reviewer. Autonomous; no questions. Lane: write `verdicts/assessment-r1.md` ONLY; scratch `/tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/d3f5af8d-c6be-47d3-8dfd-f5988bd164de/scratchpad/b99/`. No Julia (read code; do not run it). Do not edit `docs/assessment.md`.

Target: `docs/assessment.md` (brief 98, report `briefs/98-final-assessment-draft.last.md`), which answers `handoff.md` deliverables 7–8 (L263–L280).

## Obligations
1. **Status fidelity**: every row of its claims table and every status word in the prose against `claims/CLAIMS.md` (incl. HOLD annotations) and `verdicts/tb7-r1.md`, `tb6-r4.md`. Any sentence stronger than CLAIMS is MAJOR; noticeably weaker is MINOR.
2. **Citation check**: open EVERY cited range (gt file:line, verdict §, code file:line, DESIGN line) and say whether it supports the sentence. List each as SUPPORTS / PARTIAL / DOES NOT. Recompute yourself any number it states (degree bounds from F1 incl. "deg_F ≤ 7, requires d ≥ 8" vs `docs/findings.md` "≤7 … d ≥ 7"; the level chain; the dimension chain — the draft writes 206→840→848→1696 while CLAIMS/HANDOFF give 206→624→840→848→1696; the `Q_I=2<s_0=9` guard statement).
3. **Content quality** for a MIP*=RE author who wants to extend the construction and for a physicist: is "what became clearer" concrete and true, or generic? Is "what remains difficult" correctly split into mathematical / scale / representational? Is anything important missing (e.g. findings in `docs/findings.md`, `HANDOFF.md` "Findings so far" and "Future directions")? Are the next steps ranked sensibly and actionable (success criterion, size)?
4. **Prose**: sober, no marketing, no hedging chains; truncated or garbled sentences.

## Output
`verdicts/assessment-r1.md`: numbered findings (severity · file:line · quoted text · authority · one-line FIX DEMAND), the citation table, a short "missing content" list, final line exactly `VERDICT: PASS` or `VERDICT: FAIL(<ids>)`. Final message ≤ 8 lines.
