# Brief 91 report: analytic citation fixes (2026-10-01)

Edited only docs/analytic/parts/part2a.tex, part2b.tex (+ rebuilt PDF).

- D1 VERIFIED+FIXED (part2b §14.6 cell): thm:pauli label at gt-07-ldt.tex:1432; thm:introspection gt-08:785.
  Old: `thm:pauli, thm:introspection / gt-08` -> New: `thm:pauli / gt-07-ldt.tex; thm:introspection / gt-08-introspection.tex`.
- D2 REJECTED by orchestrator; untouched (did not append L874-L892: cell format has no range slot).
- D3 VERIFIED+FIXED (part2a, Julia/repair paragraph): gt-12 fig:halt_f L425-455: step 3 ComputeSampler, step 4 Compress, step 5 runs decider^compr. "step 3" -> "steps 4--5".
- D4 VERIFIED+FIXED (part2b §14.4 rows): gt-10 L1886-1894 (3 x 6 = 18 types, in sec:ar-verifier L1850), L1949 (type^ar = type^ora x type^pcp), gt-09 L43 (type^ora = {oracle,alice,bob}).
  Old: `sec:ld-compiler` x2 -> New: `sec:ar-verifier, gt-10 L1889--L1894` and `sec:ar-verifier, gt-10 L1949; gt-09 L43`.
- D5 VERIFIED+FIXED: gt-10 L161-172 (def:formula-arithmetization) states only agreement on {0,1}^m. Prose: "Arithmetization follows the NW19 rule def:arithmetization, found in nw19-tseitin-arith.tex. It recursively applies ..."; "The paper's definition states only that it agrees ... on the Boolean cube" keeps the gt footnote. Table cell: gt cite marked "(agreement on the cube); connective rules from NW19 def:arithmetization".
- D6 VERIFIED+FIXED (part2a ~L55): gt-03 L94-98 says only "polynomial overhead". Now: "The paper says only that such simulations carry a polynomial overhead; the explicit form below is this document's own quantification ... not notation from the paper", and "C_U,c_U (our notation)".

Footnotes (verbatim):
1. At F(x,w)=1 in §tseitin: "The source's \code{def:tseitin} writes \(F(x,s)\) here; this document uses the corrected \(F(x,w)\)."
2. After the arithmetization-agreement sentence: "The source writes the domain of \(F_{\mathrm{arith}}\) as \(\mathbb F_q^{m'}\) in this definition; this document uses \(\mathbb F_q^{m}\), matching the \(m\) variables of \(F\)."

Build (pdflatex x2, exit 0/0): pages 92 -> 92; overfull 0 -> 0; underfull 11 -> 12; undefined 0 -> 0; figcoverage exit 0.
(Intermediate overfull from the long NW19 path in prose fixed by rewording.)
