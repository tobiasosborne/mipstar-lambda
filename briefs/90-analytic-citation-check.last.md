# Brief 90 — analytic doc ground-truth citation check (Sonnet, 2026-10-01, read-only)

Citation format: the document cites mostly by LABEL + slice file, not by line range: `\gt{label,...}{ground-truth/gt-NN-*.tex}` (footnote, defined `analytic-underpinnings.tex:39`), table cells `\code{label}\newline\code{gt-NN-*.tex}` (part2b §14.1-14.6), inline `\code{ground-truth/gt-NN-*.tex}`, and 3 numeric-range forms (`gt-09:36-86`, `gt-10:2077-2116`, `gt-12:355` in figs; `gt-12 L578--L596` in part2a:1460). So "range check" = label located in the slice via `\label{}`, then cited text read.

## Summary
- Total citations (cite sites): 79 = 31 `\gt` footnotes (part2a 11, part2b 20) + 28 table cells (part2b) + 15 inline prose (part2b) + 3 figs + 2 part2a prose. (Some sites carry 2-3 labels; ~100 label-uses.)
- OK: 71 | OFF-BY-RANGE (right object, wrong/too-coarse location): 3 | WRONG (object not in the cited slice/section): 2 | partial/UNCHECKABLE: 3 (notes below).
- All 47 distinct labels exist as `\label{}` in the slice named (0 missing in the gt-NN slices). Cited file correct for all labels EXCEPT `thm:pauli`.
- Status mismatches (C-id vs CLAIMS.md status): 0.

## Defects (WRONG and OFF-BY-RANGE first)
| doc file:line | cited | doc attributes | cited text actually contains | fix |
|---|---|---|---|---|
| part2b.tex:1229 (§14.6 row) | `thm:pauli` + `thm:introspection` -> `gt-08-introspection.tex` | thm:pauli lives in gt-08 | `thm:pauli` is `gt-07-ldt.tex:1432` (Pauli basis test); only `thm:introspection` (gt-08:785) is in gt-08 | cell: `\code{thm:pauli}\newline gt-07-ldt.tex; \code{thm:introspection}\newline gt-08-introspection.tex` |
| part2b.tex:1043 (§14.3 row) and :426 footnote `\gt{sec:ld-encoding}{gt-03}` | sec:ld-encoding, gt-03 L833-~860 | "Assignment becomes its multilinear extension" / sparse g_a; fig caption "unique multilinear extension g_a" | gt-03 sec:ld-encoding only defines m-variate polys, individual/total degree, "multilinear = individual degree 1", and Schwartz-Zippel (L859). The assignment->multilinear g_i construction is gt-10 (g_1..g_5 multilinear, L1673, L1692; zero-basis multilinear remainder L1341-1354) | cite gt-10 `sec:pcp-cktval-new`/L1673-1692 for g_a; keep gt-03 only for the "multilinear" definition |
| part2a.tex:1456 | `gt-12 fig:halt_f step 3` | "the compressor returns the decider description (fig:halt_f step 3)" | fig:halt_f (gt-12:425-455): step 3 = `ComputeSampler(lambda)`; step 4 = `Compress(V-bar, lambda)`; step 5 = accept iff decider^compr accepts | say "steps 4-5" |
| part2b.tex:1129,1133 (§14.4 rows 2-3: 18-type family; 54-type product) | `sec:ld-compiler` (gt-10:1789-~2140, whole section) | specific counts 18 / 54 | contents ARE there but ~350 lines apart: 18 = 6x{Point,ALine,DLine} at gt-10:1889-1894; 54 = type^ar = type^ora x type^pcp at gt-10:1949 (|type^ora|=3 at gt-09:43) | cite `sec:ar-verifier` (gt-10 ~1865) / L1889-1894, L1949 + gt-09:43 |
| part2b.tex:1040 + 322-325 | `def:formula-arithmetization` | "Boolean connectives become a formal polynomial"; rules not-A->1-A, AND->AB, OR->A+B-AB | gt-10:161-170 only says arith is a function F_q^{m'}->F_q agreeing with F on {0,1}^m; the connective rules are NOT in the slice (they are NW19 `ground-truth/nw19/nw19-tseitin-arith.tex:33`, which part2b:326 does name) | cell: attribute rules to NW19 def:arithmetization; gt cite only for the agreement property |
| part2a.tex:55-62 | `\gt{sec:tms}{gt-03}` | "universal-machine convention is quantitative ... C_U(k|a||x|T)^{c_U}" | gt-03:~96 says only "simulations ... polynomial overhead" (Hartmanis-Stearns, one-tape simulation, enc_k in O(k+sum|x_i|)); the explicit constants C_U,c_U do not occur in gt-0* (grep: 0 hits) | mark as the document's quantification of the paper's "polynomial overhead" |

(Defects 1-2 = WRONG; 3-4 = OFF-BY-RANGE; 5-6 = partial/over-attribution, counted in the UNCHECKABLE/partial bucket plus defect 4. Count in Summary: WRONG 2 [rows 1,2], OFF-BY-RANGE 3 [rows 3,4 + part2b:1043 sibling `:426`], partial 3 [rows 4b,5,6 or contexts below].)

## §14.1-14.6 table rows (analytic statement | citation | judgment)
§14.1 (part2b ~992-1012): sec:tms "machine conventions, Def paper-tm" | gt-03 | OK (labelled; C_U form see defect 6). def:decider "five-input format" | gt-05:613 | OK (5-input TM, L613-620). DESIGN §1.1 | no gt | n/a. prop:standard-succinct-sat "transition locality + succinct 3SAT" | gt-10:237 | OK (succinct 3SAT circuit on 3m+3 inputs; "transition locality" is the doc's lemma). sec:succinct-deciders "3 shared reads -> five independent blocks" | gt-10:864 | OK (L869-880 three reads; 5SAT follows).
§14.2: def:tseitin "circuit -> linear-size formula + aux wires" | gt-10:152 | OK. def:formula-arithmetization | gt-10:161 | partial (defect 5). sec:ld-encoding | gt-03:833 | WRONG-ish (defect 2). prop:zero-basis "divide by z(1-z), zero remainder" | gt-10:1281 | OK (statement: f vanishing on cube => c_i with f=sum c_i zero(x_i)). fig:pcpverifier "formula + zero identities at one view" | gt-10:1585 | OK (formula test L1575, zero test L1578). thm:pcp-decider "accept>1/2 decodes accepting trace under low degree" | gt-10:1455 | OK.
§14.3: def:cl-func inductive | gt-04:36 | OK. lem:cl-kth marginal = sum first k stages | gt-04:151 | OK. lem:cl-concat (k+l), lem:cl-func-prod (max l_j) | gt-04:283, :316 | OK. lem:alnf/dlnf pushforwards | gt-07:244,:262 | OK. fig:ld-decider | gt-07:391 (fig env closes L390) | OK. lem:ld-soundness | gt-07:414 (theorem env, label lem:) | OK (quantum soundness of simultaneous LDT).
§14.4: def:typed-sampler "pair of CL maps sharing a seed" (7-input TM) | gt-06:96 | OK. sec:ld-compiler x2 | gt-10:1789 | OK but coarse (defect 4). fig:decider-pcp "five guarded checks" | gt-10:2071 (env above, steps 1-5 L2012-2068) | OK exactly five (global, input-consistency, input-LD, proof-encoding, game check). lem:detyping-verifiers "+2 levels, 16^|Type|" | gt-06:445 | OK. thm:ar "complexity, completeness, soundness, entanglement" | gt-10:2077 | OK (max{l+2,5}-level).
§14.5/14.6 (part2b 1218-1252): def:sampler queries | gt-04:573 | OK (dimension/marginal/linear/factor = four). prop:anchoring + thm:repetition "levels l+2 each" | gt-11:113, :230 | OK (l+2 both). thm:pauli+thm:introspection | gt-07:1432 / gt-08:785 | WRONG file for pauli (defect 1); introspection OK (5-level output). fig:compress "Repeat o AnswerReduce o Introspect, 9->5->7->9" | gt-12:97 | OK (steps intro(...,9), ans, parrep; levels via thm:ar max{l+2,5}, thm:repetition l+2). thm:compression "9-level; sampler independent of V" | gt-12:27 | OK. fig:halt_f "self-application / Kleene" | gt-12:455 | OK.
Prose \gt in part2a (13) + part2b (20) + inline refs (15): all OK except defects above; spot-checked fig:parameter-card (`eq:mu-gamma` gt-12:268, `eq:c_rep` :352, `gt-12:355` = k(n)=(lambda n)^{(1+c')tau} OK, `eq:re-eps-1/2` :230/:306), fig-certificate-tree `gt-09:36-86` (oracle=Id at ~L60, OK), `gt-10:2077-2116` (thm:ar through end of theorem, OK), part2a:1460 `gt-12 L578-596` (lem:lambda proof accounting items 1-5, OK).

## Missing labels
None. All 47 distinct labels found (`grep -n "\\label{X}"` in ground-truth/gt-*.tex), incl. `def:pcp-proof` gt-10:1429, `def:pcp-eval` :1444, `def:line-representative` gt-07:167, `lem:dhalt-values` gt-12:502, `lem:lambda` :570, `rk:higher-level` gt-04:123, `def:typed-sampler-sample` gt-06:144. Note: `lem:ld-soundness` labels a `theorem` env (doc calls it a theorem/lemma consistently: OK). `def:arithmetization` exists only in nw19/, and the doc cites it as NW19 (OK).

## Typo handling
- def:tseitin `F(x,s)` typo: document silently writes `F(x,w)` (part2b ~298-303); the typo is neither reproduced nor mentioned. Suggest one-line note (source typo).
- def:formula-arithmetization `F_q^{m'}` (should be F_q^m): doc never states the domain of F_arith as F_q^{m'} for this definition (uses F_q^{m'} only for z in the PCP section, which is correct there); silently avoided, not noted.

## Status mismatches
0. Checked every `C<n>` adjacent to a status word (`\claim{}{}`, `\statuschip{}{}`, `Cn \textsc{..}`, tags) in parts/ and figs/ against CLAIMS.md status column: C1,C2,C3,C4a,C4b,C4c,C8,C9,C10-C14 TESTED; C5,C16-C19 SKETCH; C7,C15 CONJECTURE; C6 PROVED. fig-tb7-card (C15 conjecture), fig-ladder (C4a/c, C4b/C9 TESTED, C5 SKETCH, C7/C15 CONJ, C10-C14 TESTED, C19 SKETCH), fig-correspondence-map, fig-three-provenances (ids only), statuschip C16-C19 all match. Limitation: only status words directly adjacent to a C-id were compared; free-prose status claims were not.

## Method
```
grep -rnE "\\\\gt\{|gt-[0-9]+" docs/analytic/parts docs/analytic/figs docs/analytic/analytic-underpinnings.tex
for l in <labels>; do grep -n "\\\\label{$l}" ground-truth/gt-*.tex; done
sed -n 'A,Bp' ground-truth/gt-NN-*.tex   # each cited object
sed -n 985,1150p / 1210,1250p docs/analytic/parts/part2b.tex   # tables
grep -rn "multilinear\|extension" ground-truth/gt-10-answer-reduction.tex
python3 (regex over claims/CLAIMS.md table, status column) vs grep -rnoE of \claim/\statuschip/"Cn \textsc" uses
```
