1. Created [DESIGN.md](/home/tobias/Projects/discussions/docs/DESIGN.md) with all eight required sections.
2. Created [definitions.md](/home/tobias/Projects/discussions/docs/definitions.md) as the authoritative symbol glossary.
3. Separated closures, quoted programs, circuits, evaluators, and specialization.
4. Specified circuit, formula, sparse-polynomial, and zero-basis certificate IRs.
5. Made structural and support-computed degree bounds independently checkable.
6. Encoded CL functions inductively, including typed six-copy PCP sampling.
7. Distinguished executable AnswerReduce components from explicitly CITED theorem stubs.
8. Separated all four soundness layers and represented C5 as a derivation tree.
9. Defined TB0–TB4 plus TB0.5, with parameters, budgets, outputs, and red mutations.
10. Markdown and citation-label validation passed; no Julia files were created. A commit was blocked because `.git` is read-only.

Least-certain decisions:

- The `L_v^lnf` identity convention at `v=0`, explicitly marked `SOURCE_REPAIR`.
- Whether sparse expansion remains practical beyond the 32-monomial fixture.
- TB2’s sub-60-second target for simultaneous diagonal-line answers.
- TB3’s duplicated-literal arithmetization and unused padding variables.
- Whether the description-level `YCode` interface is the best minimal account of capture-free self-reference.