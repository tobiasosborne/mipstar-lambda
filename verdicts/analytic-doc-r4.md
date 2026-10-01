# Analytic document r4 — adversarial verdict (brief 92)

Target: the live `docs/analytic/` source, copied into the authorized `critic-analytic-r4/analytic/` scratch directory before compilation. The document and CLAIMS hashes stayed unchanged during this audit. `test/tb7_compress.jl` and `verdicts/tb7-r1.md` changed concurrently; I re-read the latter's substantive verdict and the live test assertions. Its final ruling remains `FAIL(T7-1,T7-2,T7-3,T7-4,T7-5,T7-6,T7-7,T7-8)`, C15 HOLD, with no authorized replacement row. Live repair code is not a converged verdict.

**Four MAJOR findings block PASS: R1–R4. Seven MINOR findings: R5–R11.** The literal C-id/status pairs match CLAIMS; the prose and the scope of one figure do not. Matching a stale sentence in CLAIMS does not override the explicitly mandated TB7 verdict.

No Julia was run. Code facts were checked with `grep -rn` over `src/`, `test/`, and `toys/`. No git command was run. Only this verdict was written in the repository; all compilation, extraction, manifests, and PNGs are under the authorized scratch directory. `bd prime` was read; no tracking database was mutated because the brief restricts repository writes to this verdict.

## 1. Lockstep audit

In the tables below, `A` means `docs/analytic/parts/part2a.tex`, `B` means `docs/analytic/parts/part2b.tex`, and figure filenames are under `docs/analytic/figs/`. Ranges group repeated occurrences with the same ruling; they are not spot checks. CHECKED/CITED are certificate grades, whereas TESTED/SKETCH/etc. are ratchet statuses. MATCH requires the asserted scope to match too.

CLAIMS authority: C1–C3 at lines 8–10; C4a/C4b/C4c at 11–13; C5/C6/C7/N1 at 14–17; C9/C8 at 18–19; C10–C15 at 20–25; C16–C19 at 26–29.

| Location | Claim/object | Written status or execution fact | CLAIMS / governing authority | Result |
|---|---|---|---|---|
| `analytic-underpinnings.tex:68–76` | C1–C4, C8–C15 | prototype realizes part; constructs polynomials/samplers; checks finite identities; analytic theorems imported | finite instances TESTED; C15 CONJECTURE; quantum conclusions CITED | MATCH |
| A:333–346 | C16–C19 | thirteen explicitly enumerated results SKETCH, no converged proof verdict | four SKETCH rows, exactly this partition | MATCH |
| A:347 | C16 | example chip `C16 SKETCH` | SKETCH | MATCH |
| A:689,717,780,806 | C16 | four environment chips SKETCH | SKETCH, semantics/fuel/specialization | MATCH |
| A:925,1010,1148 | C17 | three environment chips SKETCH | SKETCH, costed bridge | MATCH |
| A:1222,1260,1359,1486 | C18 | four environment chips SKETCH | SKETCH, self-reference | MATCH |
| B:43,108 | C19 | two environment chips SKETCH | SKETCH, Cook–Levin | MATCH |
| A:490–514; `fig-grades.tex:4–24` | certificate API | five grades; CHECKED has replay; CITED imports theorem | DESIGN §3 and certificate structs; not a proof-status promotion | MATCH for API description; R4 below for guarantee |
| A:515–517 | general replay guarantee | “stale evidence unrepresentable”; a term/certificate mutation turns suite red | no universal ratchet row; last TB7 verdict refutes that guarantee | **AHEAD — R4** |
| A:522–531; `fig-certificate-tree.tex:5–70` | C9/C4b, TB2 tree | CITED Detype root; CHECKED typed decider, sampler/product; fixed-formula assumption and source repair | C9/C4b TESTED on TB2; detyping quantum contract CITED | MATCH, explicitly the legacy TB2 overload |
| A:535–544 | C15 policy report | five outcome names, no non-PASS folded into PASS | C15 CONJECTURE; policy output is not theorem evidence | MATCH as outcome vocabulary; not an endorsement of the archived eligibility checker |
| A:1451–1454 | C11, C16/C18 | TB4 pins fixed-point equation on two machines; link 5 bytes | C11 TESTED; C18 general theorem SKETCH; fixed-width codec caveat explicit in CLAIMS | MATCH |
| B:266–274 | C10/C19 | generated instance reaches PCP builder and AR decider “on two one-bit-answer fixtures”; C10 TESTED | C10: equality fixture is refused by `arith_q` and never reaches `build_pcp`; C19 SKETCH | **AHEAD — R1** |
| B:310–328,365–391 | C2/C8/C5 | Tseitin occurrence replay; sparse arithmetization; fixture degree accounts TESTED; general repair SKETCH | C2/C8 TESTED; C5 SKETCH | MATCH |
| B:426–442,497–503 | C2/C3 | `g_a`, support dependencies, `build_c0`, coefficient division executed on fixtures; general implications cited | TESTED instance identities/dependencies | MATCH |
| B:402; `fig-four-layers.tex:3–60` | C1/C5 and quantum leaves | identities executed; two bounds CHECKED; identity implication CITED; C5 SKETCH | C1 TESTED; C5 SKETCH; no numerical soundness theorem | MATCH |
| B:531–539,574–620 | C1/C2/C3/C8/C5 | local equations and identities; C1 named-line completeness only; C5 SKETCH; extraction CITED | same scopes and statuses | MATCH |
| B:654–665,699–708,771–785 | C4a/C12 | inductive CL constructors, marginals, exact 32768-seed histograms; local CL laws | C4a/C12 TESTED, constructed levels are upper bounds | MATCH |
| B:803–806 | C4b | TypedSampler shape/field/graph/padding checks | TESTED at the named PCP tuple | MATCH |
| B:811–813 | legacy TB2 detype | `detype` returns CitedDetypedVerifier; certificate CITED | C9's host-object overload does; C12 separately tests description detyping | MATCH for this overload; misleading mixed table R9 |
| B:824–831 | C4b | private `_pcp_cl_map`, `pad_level`, family; copy-6 SOURCE_REPAIR | named maps TESTED, repair disclosed | MATCH |
| B:839–847 | C4b/C9 | product “not evidenced as the source of the questions” | product projections and 20×54 comparisons are explicitly TESTED | **BEHIND — R8** |
| B:849–864; `fig-D-decider-guards.tex:5–55` | C9 | five finite guards execute, at both LD tuples, on fixture | TESTED TB2 guards, fixed-formula scope | MATCH in the surrounding TB2 context |
| B:878–880 | `thm:ar` | quantum implication and asymptotic theorem CITED | C9 does not promote quantum conclusions | MATCH |
| B:919–925,932 | C7/C12/C14 | C7 CONJECTURE; C12 TESTED; C14 TESTED on two quotes with explicit toy child fuel; introspection soundness CITED | same | MATCH |
| B:939–948 | grade/status distinction | constructed/checked/cited; built transformation does not promote adjacent theorem | CLAIMS legend and scoped rows | MATCH |
| B:949–955; A:312,318 | all Part II environments | every theorem/lemma is said to be carried by C16–C19 | only §§8–11's thirteen; §12 and §13 also contain lemmas | **BEHIND/false coverage — R10** |
| B:962 | ladder caption | every claim represented; TB7 toy checkpoint, C15 CONJECTURE | same statuses | MATCH; stale “pending” is separately R7 |
| B:968 | correspondence-map invariant | figure/table claim values must agree for same object | map's composite rows match corresponding table groups | MATCH |
| B:975–980 | C10/C19 | description-to-SAT front end checked on two fixtures; general C19 SKETCH | both fixtures do reach SAT; general construction SKETCH | MATCH — does not make R1's stronger PCP statement true |
| B:995 | C17 | machine bridge analytic only, SKETCH; syntax constructed | SKETCH | MATCH |
| B:999–1000 | C11/C17 | input format checked on fixtures; bound analytic; TESTED/SKETCH | C11 sort/quote fixture checks; C17 general bound SKETCH | MATCH |
| B:1005–1006 | C11/C16 | `eval_program`, `specialize` fixture checks; theorems analytic; TESTED/SKETCH | C11 fixed-point/specialization checks; C16 general semantics SKETCH | MATCH only for fixture checks, not all C16 clauses |
| B:1009–1010 | C10/C19 | `bounded_trace`, `cook_levin`: CHECKED two fixtures; general CITED; TESTED/SKETCH | same | MATCH |
| B:1012–1013 | C10/C19 | `decouple5`, `pad5`: CHECKED two fixtures; general CITED; TESTED/SKETCH | same | MATCH |
| B:1036–1038 | C2 | Tseitin occurrence CHECKED, TESTED | TESTED finite occurrence/Boolean checks | MATCH |
| B:1040–1041 | C8 | arithmetization/degrees CHECKED, TESTED | TESTED occurrence/degree fixtures | MATCH |
| B:1043–1045 | C3 | multilinear assignment/support CONSTRUCTED/CHECKED, TESTED | TESTED nondegenerate witness dependencies | MATCH |
| B:1047–1050 | C2 | zero-remainder coefficient replay CHECKED, TESTED | TESTED named satisfying and failing witnesses | MATCH |
| B:1052–1053 | C1 | PCP finite views CHECKED, TESTED | TESTED named views/lines, not all z | MATCH |
| B:1055–1057 | C5 | conditional PCP theorem CITED / CHECKED parts, SKETCH | SKETCH structural soundness derivation; parameter checks finite | MATCH |
| B:1080–1083 | C4a | CL constructors CONSTRUCTED, TESTED | TESTED TB1 instance | MATCH |
| B:1085–1087 | C4a | marginal sums CHECKED, TESTED | TESTED query-compiler replays; value identity constructed | MATCH |
| B:1089–1092 | C12 | CL memberships constructed; DL9 laws CHECKED, TESTED | TESTED description AST laws; semantic implications CITED | MATCH as separated in the grade cell |
| B:1094–1096 | C4a | line/point pushforwards CHECKED TB1, TESTED | TESTED finite histograms with disclosed chi/source-repair dependencies | MATCH |
| B:1098–1099 | C4c | `ld_decider`, degree/point-line fixture CHECKED, TESTED | TESTED q=8,m=2,d=1 | MATCH |
| B:1101–1102 | quantum LDT | polynomial-measurement extraction CITED; no row | no ratchet row for quantum extraction | MATCH |
| B:1125–1127 | C4b | typed sampler shape CONSTRUCTED, TESTED | TESTED PCP family | MATCH |
| B:1129–1131 | C4b | 18-map family local CHECKED, TESTED | TESTED named tuple | MATCH |
| B:1133–1136 | C4b | 54-type product shape CHECKED; theorem cited, TESTED | TESTED tensor-product fixture | MATCH |
| B:1138–1140 | C9 | five guarded finite paths CHECKED, TESTED | TESTED TB2 paths | MATCH |
| B:1142–1143 | C12 / detyping loss | DL9 levels CHECKED, C12 TESTED; loss CITED/no row | same split | MATCH status; **R9 type/role mismatch** |
| B:1145–1147 | C9 / `thm:ar` | executable portion TESTED; analytic contract CITED/no row | same split | MATCH |
| B:1170–1172 | C6 | false midpoint value with orbit condition, PROVED | PROVED with orbit-prefix hypothesis | MATCH |
| B:1174–1176 | N1 | sequential AND value, PROVED | PROVED sequential only | MATCH |
| B:1190–1199 | C11–C15 | C11–C13 TESTED; C14 TESTED scoped; C15 CONJECTURE; soundness CITED | same literal statuses | MATCH status; BEHIND adjudication R7 |
| B:1207 | C11/C15 | built composition; TB4 skeleton TESTED; TB7 checkpoint CONJECTURE; leaves cited | same | MATCH |
| B:1218–1222 | C12 | six transformations from four queries; laws CHECKED, semantics CITED, TESTED | TESTED DL9 laws/queries, semantic implications cited | MATCH |
| B:1224–1227 | C13 | TB5 level/dim 1,1→3,9→3,729, CHECKED fixture, TESTED | TESTED TB5 anchor + 81-repeat fixture | MATCH |
| B:1229–1233 | C14 | TB6 34/116 and 38/128; CHECKED two toys; TESTED scoped | TESTED explicit toy child fuel, type/pair counts | MATCH |
| B:1235–1239 | C11/C15 | order/levels CHECKED TB4, C11 TESTED; C15 CONJECTURE | same | MATCH |
| B:1241–1244 | C15/`thm:compression` | theorem CITED; only toy sampler hash printed; CONJECTURE | same limited claim | MATCH |
| B:1246–1251 | C11/C15/C18 | TB4 fixed-point checks TESTED; TB7 CONJECTURE; general theorem SKETCH | same, TB4 does not test s-m-n/Kleene theorem | MATCH |
| B:1262–1274 | C15 | level/dim chains and thirteen printed outcomes, explicitly “not a verified claim” | CONJECTURE; TB7 verdict confirms these default numerical facts | MATCH for printed facts; BEHIND adjudication R7 |
| B:1278–1287 | C15 execution | only non-Pauli schemas vacuous; Pauli predicates execute | literal CLAIMS sentence agrees, but mandated `tb7-r1` T7-6 refutes it | **MATCH to stale CLAIMS / AHEAD of governing verdict — R2** |
| B:1300,1319–1339 | evidence-boundary classes | fixture constructions/identities executed; general analytic leaves CITED; TB7 CONJECTURE | matches scoped C1–C14 and C15 | MATCH |
| B:1355–1365 | C12–C15 | built toys; scoped TESTED rows; C15 CONJECTURE “pending critic r1”; missing a verdict | C15 still CONJECTURE, but r1 already FAIL/HOLD | **BEHIND — R7** |
| B:1369–1373 | run history | as of 2026-09-27, 12730/1 broken; 235 killed; 93 baselines, full+focused history | HANDOFF §RESUME says this; later TB7 verdict reproduces 233/235 | MATCH as dated history; **BEHIND as current evidence — R7** |
| B:1400–1404 | C6/N1 | PROVED; sequential model; excludes actual Compress/quantum repetition | PROVED same restrictions | MATCH |
| B:1417,1431–1440 | fixed point / analytic leaves | syntax closes self-reference; algebraic middle does not prove quantum/compression contracts | C11 TESTED syntax, C18 SKETCH general theorem; leaves CITED | MATCH |

Figure status inventory, including bare tags without an adjacent C-id:

| Location | Claim/object | Written | CLAIMS | Result |
|---|---|---|---|---|
| `fig-ladder.tex:19` | C1,C2,C3,C8 | TESTED | TESTED | MATCH |
| `fig-ladder.tex:20` | C6,N1 | PROVED | PROVED | MATCH |
| `fig-ladder.tex:21` | C4a,C4c | TESTED | TESTED | MATCH |
| `fig-ladder.tex:22` | C4b,C9; C5 | TESTED; SKETCH | same | MATCH |
| `fig-ladder.tex:23` | C10 | TESTED | TESTED | MATCH |
| `fig-ladder.tex:25` | C15 | CONJECTURE; toy runs | CONJECTURE; finite construction survives r1 | MATCH |
| `fig-ladder.tex:26–28` | C14,C13,C11 | TESTED, C14 scoped | same | MATCH |
| `fig-ladder.tex:35,37,42` | C12,C7,C16–C19 | TESTED, CONJECTURE, SKETCH | same | MATCH |
| `fig-ladder.tex:46–49` | every claim | named-fixture execution; all soundness cited; pending r1 | statuses match; r1 exists | MATCH status / BEHIND R7 |
| `fig-three-provenances.tex:7,15–18` | source definitions/theorems | CITED | imported leaves | MATCH |
| `fig-three-provenances.tex:26,30–40,62–64` | C16–C19 | SKETCH, four correctly enumerated groups | SKETCH | MATCH for listed results |
| `fig-three-provenances.tex:45–57` | C1–C4c,C8–C14,C6,N1 | executed/ratcheted; TESTED/PROVED; C14 scoped | same; C15 excluded | MATCH |
| `fig-correspondence-map.tex:15–16` | C10/C19 | two fixture checks TESTED; general SKETCH | same | MATCH |
| `fig-correspondence-map.tex:19–20` | C2,C3,C8 | checked instances TESTED | TESTED | MATCH |
| `fig-correspondence-map.tex:23–24` | C4a | TB1 exact TESTED | TESTED | MATCH |
| `fig-correspondence-map.tex:27–28` | C4b,C9 | shape checked/theorem cited; TESTED | TESTED fixture checks | MATCH |
| `fig-correspondence-map.tex:31–32` | C6,N1 | PROVED | PROVED | MATCH |
| `fig-correspondence-map.tex:35–36` | C11,C15 | TB4 checked/TB7 toy; TESTED/CONJECTURE | same | MATCH |
| `fig-D-correspondence-description.tex:6,9,11–13` | C10/C19 | three front-end operations on two fixtures TESTED; general SKETCH/CITED | same | MATCH |
| `fig-D-correspondence-polynomial.tex:3–13` | C1–C3,C8/C5 | named instances CHECKED; soundness SKETCH | same | MATCH |
| `fig-D-correspondence-cl.tex:3–10` | C4a / LDT theorem | levels 1,2,3; 32768-seed checks TESTED; extraction CITED | same | MATCH |
| `fig-D-correspondence-typed.tex:3–11` | C4b,C9 / loss and `thm:ar` | TESTED finite shapes/guards; quantum CITED/no row | same | MATCH |
| `fig-D-correspondence-midpoint.tex:4–9` | C6,N1 | exact adaptive DP; PROVED | same | MATCH |
| `fig-D-correspondence-compression.tex:3,14` | C14 | built TB6; TESTED scoped | TESTED toy child fuel | MATCH |
| `fig-D-correspondence-compression.tex:5,15` | C9/C15 | “built (TB2; TB7 on descriptions)” under C9 TESTED | C9 tests TB2 only; TB7 is C15 CONJECTURE | **AHEAD — R3** |
| `fig-D-correspondence-compression.tex:7,16` | C13 | built TB5; TESTED | TESTED | MATCH |
| `fig-D-correspondence-compression.tex:10,18–27` | C11/C15 and leaves | TESTED skeleton; CONJECTURE checkpoint; soundness CITED | same | MATCH |
| `fig-tb7-card.tex:4–26,53–55` | C15 | 9→5→7→9; 206→840→848→1696; ToyPolicy repeat override 2; CONJECTURE | same default construction facts | MATCH; pending r1 BEHIND R7 |
| `fig-tb7-card.tex:37–49` | C15's 13 predicates | each printed outcome | test vector and r1 default cells | MATCH, every row separately audited in §5 |
| `fig-evidence-boundary.tex:5,24–44` | C1–C4,C8–C14 / general leaves | finite checks below; analytic theorems cited above; no certificate promotion | same | MATCH |
| `fig-tseitin-fanout.tex:40–46`; `fig-occurrence-vector.tex:6,20` | C8 | bare TESTED tags on named measured occurrence/degree examples | C8 TESTED, not general fan-out theorem | MATCH |
| `fig-D-threshold-margin.tex:18–19` | C5 arithmetic / Schwartz–Zippel | parameter arithmetic executed, implication CITED | finite checks; C5 SKETCH; analytic lemma cited | MATCH |
| `fig-D-closure-gap.tex:9–10`; `fig-structural-hypothesis.tex:22–26` | C4/C12 local laws; C7 global closure | local CONSTRUCTED/CHECKED; global CONJECTURE | same | MATCH |
| `fig-final-accounting.tex:13–23`; `fig-D-final-seal.tex` | algebraic middle / fixed point / soundness leaves | middle executed; fixed point closes syntax; difficult leaves cited | C1–C4,C8–C11 finite evidence; C18 SKETCH; soundness cited | MATCH |

The remaining green source-operation diagrams in Parts I and II depict specified machine/term reductions, source transformations, or the analytic construction of §§8–11. They have no TESTED/PROVED claim chips. Their captions were read as mathematical source-operation descriptions, not as evidence of a general Julia TM compiler: `analytic-underpinnings.tex:86`, `part1a.tex:570`, `part1b.tex:627–634,685`, A:130,219,246,280,878,918,973,1352,1478, and the associated pipeline/source/quotation/simulation figures. The SKETCH chips and the separation of project evidence in §14 prevent a general implementation claim there. They do not rescue the explicit overclaims below.

**R1 — MAJOR, fixture scope ahead of C10.** `docs/analytic/parts/part2b.tex:268–271`: “run the generated instance through the PCP builder and the answer-reduced decider on two one-bit-answer fixtures. That fixture evidence is claim C10 at TESTED”. Authority: `claims/CLAIMS.md:20` expressly says the equality fixture is refused with `ExpansionRefused(279936 > 160000)` and “never reaches build_pcp”. Static corroboration: `test/tb3_frontend.jl:659–700`, particularly the `arith_q` call at 686 and refusal assertion at 699; the successful PCP/AR section at 550–655 builds the trivial fixture's circuit. This is not repaired by the later refusal disclosure at B:1325–1326. Say that both fixtures reach trace/SAT/padding, and only the trivial fixture reaches the PCP/AR continuation.

**R2 — MAJOR, TB7 predicates falsely said to execute.** `docs/analytic/parts/part2b.tex:1285–1286`: “Introspect, Sample, Read and Hide are VACUOUS in both roles and only the Pauli-typed introspection predicates execute at TB7.” Authority: `verdicts/tb7-r1.md`, T7-6, finds zero Pauli firings in all 86 Pauli-oriented pairs. `src/introspect/intro_decider.jl:470` returns false on `Q < s` before dispatch at 483–486. The live report at `src/compress/compress7.jl:263–267` now explicitly says zero dispatches, and `test/tb7_compress.jl:386–389` asserts 0/164 total and 0/86 Pauli pairs. CLAIMS C15 retains the old sentence, so literal transcription is MATCH to a stale row; the brief explicitly makes the existing TB7 verdict controlling. Replace the positive predicate-execution claim with Pauli sampler construction/query execution, and keep local Pauli predicate evidence at TB6.

**R3 — MAJOR, C9 TESTED is extended to TB7.** `docs/analytic/figs/fig-D-correspondence-compression.tex:5,15`: “AnswerReduce / built (TB2; TB7 on descriptions)” under “C9 TESTED”. Authority: `claims/CLAIMS.md:18` defines C9 on the TB0/TB2 proof/formula fixture and its five executable guards; C15 at line 25 is CONJECTURE and the actual-D1 game is NOT_EXECUTED. `verdicts/tb7-r1.md` T7-8 finds only four of nine complete local agreements; five decisions reject at the unexecuted game layer. One green TESTED label spanning both implementations overclaims the tested scope. Split the TB2 C9 TESTED object from the TB7 C15 CONJECTURE object. The adjacent C15 chip on the separate Compress box does not narrow the C9 chip over AnswerReduce. Likewise, card row 6 must be read as the disclosed local polynomial fixture's checks, not as successful checks of D1's formula; the figure should say that locally.

**R4 — MAJOR, universal certificate protection is advertised without a ratcheted basis.** `docs/analytic/parts/part2a.tex:515–517`: “That is what makes stale evidence unrepresentable: there is no detached cache to go out of date, and a mutation that changes the term but not the certificate turns the suite red.” Authority: `verdicts/tb7-r1.md` T7-2 explicitly found captured-object replays authenticating forged recorded assertions; T7-3 found substituted execution/discarded self-code survivors. Its surviving statement is captured-object recomputation, not universal authentication. C1/C10/C11 authorize particular identity-bound tests; C15 does not authorize an all-transformations guarantee. Static API inspection also shows that `CertNode.replay` is an arbitrary callback (`src/certificates.jl:23–29`); calling it is not a proof that it checks the attached subject. The concurrent `BoundReplay` repair at lines 31–97 is visible and may address recorded-fact/child binding, but has no converged verdict in this audit and does not justify “unrepresentable” for every stale subject or arbitrary callback. State what replay does, name the fixtures with validated binding, and disclose the TB7 r1 failure/repair state instead of asserting a universal test guarantee. I am not declaring that every archived counterexample still survives the live repair.

## 2. Julia-name audit

I grepped every identifier in the six §14 tables and all `fig-*correspondence*.tex` files, joining intentional line splits before lookup. Function existence was distinguished from its role and return type. The table gives the decisive declaration/implementation anchors; repeated figure occurrences use the same check.

| §14 location / figure uses | Identifiers checked | Declaration/role evidence | Ruling |
|---|---|---|---|
| B:994; description/fixed-point rows | `Quote`, `Eval`, `Specialize` | `src/ir/programs.jl:81,86,94`, Program constructors | exist, correct syntax role |
| B:994,998,1005,1248 | `Quoted`, `Quoted{A}`, `Quoted{Decider}` | `src/ir/programs.jl` quotation value/sort implementation; `docs/DESIGN.md:45–51` | sort templates, not literal parametric instantiations with a Julia `Decider` type |
| B:999 | `description_length`, `decider_input_sorted` | `src/ir/programs.jl:183,1171`; descriptions overload at `src/descriptions/sorts.jl:158` | correct max-length and five-input sort predicates |
| B:1005 | `eval_program`, `specialize` | `src/ir/programs.jl:1125,620` | evaluator and host specialization; fixture scope only |
| B:1005,1237,1248 | `ClosedProgram`, `PartialProgram`, `Compressor` | zero hits for first two in src/test/toys; `docs/DESIGN.md:45–51`, `docs/definitions.md:153–155`; `:Compressor` admitted at `src/ir/programs.jl:153` | intentionally document sorts; not missing Julia functions |
| B:1009–1010; description/map figures | `BoundedTrace`, `bounded_trace` | `src/frontend/bounded_trace.jl:17,189–198` | canonical quoted-program trace; Checked wrapper supported; raw Program/Closure refused |
| B:1009–1010; description figure | `Succinct3SAT`, `cook_levin` | `src/frontend/cook_levin.jl:28,529` | Checked BoundedTrace→Checked SAT; fixture surrogate, not implemented general window compiler |
| B:1013; description/map figures | `SuccinctDecoupled5SAT`, `decouple5`, `pad5` | `src/frontend/decouple5.jl:17,200,286` | SAT conversion and checked padded conversion; matches table |
| B:1037–1038; map | `Circuit`, `TseitinFormula`, `tseitin`, `occurrences` | `src/ir/circuits.jl:173,214,246` and circuit declarations | finite circuit/formula and occurrence traversal |
| B:1040–1041; polynomial/map figures | `Poly`, `arith_q`, `actual_degrees` | `src/polynomials/sparse.jl:267`; `src/ir/circuits.jl:355,377` | sparse polynomial and degree account; expansion may be refused |
| B:1044 | `g_a`, `dependency_blocks` | `src/polynomials/sparse.jl:334,270` | assignment interpolation on supplied layout/block; actual support dependencies |
| B:1049–1050; polynomial/map figures | `ZeroDecomposition`, `zero_basis_decompose`, `verify_zero_decomposition` | `src/polynomials/zero_basis.jl:10,46,135` | formal decomposition and coefficient replay |
| B:1052–1057; polynomial figure | `PCPView`, `PCPProof`, `pcpverifier`, `build_pcp`, `parameter_policy` | `src/verifiers/pcp.jl:91,265,326,32` and PCPProof declaration | finite proof/view, local two-equation checker, constructor, policy; no soundness proof checker |
| B:1081–1092; CL/map figures | `AbstractCL`, `CLZero`, `CLStep`, `level`, `CLMarginal`, `marginal_k`, `sum_stage_outputs` | `src/samplers/cl.jl:43,49,251,259,267`; exported AbstractCL/level | inductive maps and marginal replay |
| B:1091; map/closure figure | `concatenate`, `direct_sum`, `product` | `src/samplers/cl.jl:745,797–809,840`; description overloads at `src/descriptions/transformations.jl:236,256` | concatenate takes CL continuation/map; direct sum and product have distinct host/description overloads; DL9 claims refer to descriptions |
| B:1094–1096; CL/map figures | `CLDistribution`, `L_Point`, `L_ALine`, `L_DLine`, `histogram` | `src/samplers/cl.jl:811,831`; `src/samplers/ldt.jl` L-map definitions | correct distributions and named maps |
| B:1098–1099 | `LDParams`, `ld_decider`, `restrict` | `src/verifiers/ldt.jl:19,145` and params declaration | low-degree format/consistency predicate and polynomial restriction |
| B:1125–1127 | `TypedSampler`, `sample`, `pad_level` | `src/samplers/typed.jl:101,115,151–174`, pad_level methods | typed shared-seed sampling and level padding |
| B:1129–1131; typed/map figures | `_pcp_cl_map`, `pcp_sampler`, `intrinsic_pcp_levels` | `src/samplers/pcp_sampler.jl:65,153,179` | map constructor, family constructor, intrinsic-level account |
| B:1134–1135; typed/map figures | `Checked{TypedSampler}`, `oracularize_sampler`, `typed_sampler_product` | `src/samplers/oracularize.jl:97,101`; constructed checked product | correct checked typed product |
| B:1139–1140; typed figure | `TypedAnswerReducedDecider`, `typed_answer_reduced_decider` | `src/verifiers/answer_reduce.jl:24,394` | host TB2 typed decider and guarded execution |
| B:1143 | `CitedDetypedVerifier`, `detype_sampler`, `detype_decider` | marker struct at `src/verifiers/answer_reduce.jl:103`; descriptor functions at `src/descriptions/transformations.jl:288`, `src/repeat/anchor.jl:45` | **R9: they exist but are not the same representation/return role** |
| B:1146–1147; map | `TypedAnswerReducedVerifier`, `answer_reduce_pcp`, `AnswerReduce` | `src/verifiers/answer_reduce.jl:37,71,120`; description overload at `src/compress/answer_reduce.jl:23–25` | real host typed construction; legacy `AnswerReduce` detypes to cited marker; description overload belongs to TB7 |
| B:1171,1175; midpoint/map figures | `Test`, `Ask`, `Coin`, `sequential_and_optval` | `toys/midpoint/midpoint.jl` term structs and function at 260 | exact adaptive strategy DP; not a quantum repetition implementation |
| B:1219–1221 | `SamplerDescription`, `query`, `downsize`, `direct_sum`, `product`, `detype_sampler`, `typed_anchor_sampler`, `repeat_sampler` | `src/descriptions/sorts.jl`; query at `src/descriptions/machines.jl:850`; transformations at 273,236,256,288,305; repeat at `src/repeat/repeat.jl:47` | description/query-only constructors as claimed |
| B:1225–1226 | `VerifierDescription`, `anchor`, `anchored_repeat`, `repeat_decider` | `src/repeat/anchor.jl:96`, `src/repeat/repeat.jl:163,97`; verifier description declaration | checked anchored/repeated description constructions |
| B:1231–1232 | `introspect`, `pauli_decider`, `typed_intro_decider` | `src/introspect/introspect.jl:15`; `pauli_decider.jl:280`; `intro_decider.jl:533` | explicit tuple/F_child constructors; predicate scope not broader than C14 |
| B:1237–1243; compression/map figures | `Compress`, `compress`, `answer_reduce`, `compute_sampler` | `src/compress.jl:705`; `src/compress/compress7.jl` compress/compute_sampler definitions; `src/compress/answer_reduce.jl:230` | capital TB4 contract skeleton distinct from lower-case TB7 construction; compute_sampler calls toy/production policy path |
| B:1248–1249 | `Hole`, `Specialize`, `Fix`, `YCode`, `fix_specialize` | `src/ir/programs.jl:59,86,109,126`; `src/compress.jl:116` | syntax hole/fixed point and checked specialization |

The other correspondence-figure monospace tokens (`thm:ar`, `lem:ld-soundness`, etc.) are source labels, not Julia identifiers; they were audited in §3. Claim IDs are also not function names. `Test/Ask/Coin` is three identifiers, not one slash-containing name; `TypedAnswer`+`ReducedDecider/Verifier`, `CitedDetyped`+`Verifier`, `typed_answer_`+`reduced_decider`, and `sequential_and_`+`optval` are deliberate typesetting splits. No missing implementation identifier remains after joining these splits. `ClosedProgram` and `PartialProgram` are confined to the IR-sort column.

**R9 — MINOR, existence check passes but table role does not.** `docs/analytic/parts/part2b.tex:1142–1143`: IR sort “CitedDetyped / Verifier”, Julia names “detype_sampler, detype_decider”, grade “CHECKED DL9 levels”. Authority: the cited-only marker is created by the one-argument `detype(::Checked{<:TypedAnswerReducedVerifier})` at `src/verifiers/answer_reduce.jl:110–117`. `detype_sampler` instead constructs a checked SamplerDescription at `src/descriptions/transformations.jl:288–294`; `detype_decider` constructs a DeciderDescription at `src/repeat/anchor.jl:45–68`; their combined two-argument `detype` makes a VerifierDescription at 77–87. Replace the marker with the description sorts, or split legacy marker and executable DL9 rows. The prose at B:811 is correct for the legacy overload but needs that qualifier to coexist clearly with the new table.

## 3. Ground-truth fidelity — all 79 sites independently rechecked

Independent inventory reproduced exactly **79 literal source-reference site lines**, including **31 `\gt` calls / 38 label uses**. Every `\gt` label was checked with `grep -nF '\label{...}'` in its stated file: **38/38 resolve**. Table and inline label anchors were checked separately; neither file nor label is missing after the Pauli-file correction. Escaped `eq:c\_rep` was normalized to the actual label `eq:c_rep` for grep.

Below, `gt-03` means `ground-truth/gt-03-prelim.tex`, and similarly for the numbered slices. All ranges refer to those files, not to memory or another version of the paper. “OK” means label/file resolution and attribution, not that this audit proves the cited theorem or promotes any claim. Project adaptations named as adaptations were not mistaken for literal source text.

| # | Document site | Cited object / independently read authority | Attribution ruling |
|---|---|---|---|
| 1 | A:55 | `sec:tms`, gt-03:L38–L200, especially L116–L124 | **R5: new claim that the source has no explicit universal bound is false** |
| 2 | A:98 | `def:decider`, gt-05:L612–L622 | OK: total five-input bit output, worst time at index |
| 3 | A:123 | `def:sampler`, gt-04:L572–L611 | OK: four query interfaces, at most six tapes |
| 4 | A:156 | `def:normal-ver`, `def:lambda`, gt-05:L624–L653 | OK: field 2, max description length, n≥2 bounds |
| 5 | A:175 | `fig:compress`, `eq:mu-gamma`, `eq:c_rep`, gt-12:L75–L98,L263–L270,L350–L355 | OK: construction constants; ToyPolicy values distinguished |
| 6 | A:213 | `fig:compress`, `thm:compression`, gt-12:L26–L53,L75–L98 | OK: ordered description transformations return verifier pairs |
| 7 | A:226 | `thm:ar`, gt-10:L2077–L2081 | OK: outputs answer-reduced verifier description |
| 8 | A:263 | intro-decider complexity / introspection, gt-08:L704–L776,L784–L817 | OK: raw machine, hardwiring, verifier-pair fallback |
| 9 | A:274 | PCP figure and succinct-SAT proposition, gt-10:L237–L271,L1558–L1569 | OK: D description and σ enter circuit reconstruction |
| 10 | A:300 | `fig:halt_f`, gt-12:L429–L449 | OK: eight-input self-description, hardwired five-input decider |
| 11 | A:1457 | `fig:halt_f` steps 4–5 / related lemmas, gt-12:L443–L449,L108–L118,L502–L519 | **R6: source returns pair; decider-only interface is a project narrowing** |
| 12 | A:1461 | `lem:lambda` accounting, gt-12:L578–L596 | OK: compression construction and returned-decider execution are counted |
| 13 | A:1541 | `fig:halt_f` and adjacent Kleene note, gt-12:L462–L486 | OK: paper itself says earlier version used recursion theorem |
| 14 | B:155 | succinct-SAT proposition, gt-10:L237–L271 | OK: arguments, 2T answer positions, poly(log n,log T,Q,σ) |
| 15 | B:246 | `sec:succinct-deciders`, gt-10:L864–L905,L1096–L1117 | OK: first/second/third literals, equality/copy/padding; F is declared counterpart of T |
| 16 | B:303 | `def:tseitin`, gt-10:L152–L158 | OK: semantic contract and linear size; x,s→x,w typo explicitly footnoted |
| 17 | B:325 | formula arithmetization, gt-10:L161–L171 | OK: Boolean-cube agreement only; erroneous m′ domain footnoted |
| 18 | B:335 | degree proposition, gt-10:L174–L187 | OK: the source really states degree ≤2; project discrepancy not concealed |
| 19 | B:425 | `sec:ld-encoding`, gt-03:L874–L895 | OK: explicit multilinear indicator/interpolation and linear a→g_a |
| 20 | B:442 | PCP completeness proof, gt-10:L1662–L1710 | OK: satisfying blocks imply Boolean-cube vanishing of c0 |
| 21 | B:449 | zero-basis proposition, gt-10:L1281–L1294 | OK: individual-degree vanishing polynomial is in generated ideal |
| 22 | B:494 | zero-basis proof, gt-10:L1296–L1359 | OK: ordered division, multilinear remainder, uniqueness argument |
| 23 | B:514 | PCP proof/evaluation definitions, gt-10:L1429–L1453 | OK: tables, blocks, evaluated tuple |
| 24 | B:534 | PCP verifier figure, gt-10:L1548–L1585 | OK: reconstruction plus two identities; Julia's restricted portion explicitly distinguished |
| 25 | B:555 | Schwartz–Zippel, gt-03:L859–L864 | OK: unequal bounded-total-degree polynomials, uniform point, Δ/q |
| 26 | B:584 | PCP decider theorem, gt-10:L1455–L1534 | OK: low-degree >1/2 acceptance yields accepting bounded computation; repaired degree reasoning kept SKETCH |
| 27 | B:590 | LD decider figure, gt-07:L348–L391 | OK: point-line consistency and format |
| 28 | B:593 | quantum LD theorem, gt-07:L413–L440 | OK: approximate polynomial measurements, explicitly cited |
| 29 | B:609 | `thm:ar`, gt-10:L2077–L2116 | OK: quantum directed soundness/Ent contract, not a polynomial identity |
| 30 | B:654 | `def:cl-func`, gt-04:L35–L57 | OK: inductive conditional stages with complementary registers |
| 31 | B:664 | `lem:cl-kth`, gt-04:L151–L203 | OK: stage factor/marginal decomposition |
| 32 | B:672 | `rk:higher-level`, gt-04:L122–L130; nonuniqueness L275–L280 | OK: upper-bound membership, not minimal depth |
| 33 | B:699 | concatenation lemma/proof, gt-04:L282–L313 | OK: k+ℓ-stage construction |
| 34 | B:707 | direct-sum lemma/proof, gt-04:L315–L352 | OK: max-level membership and componentwise construction |
| 35 | B:755 | canonical projection, gt-03:L375–L384 | OK for independent kernel basis; v=0 repair is disclosed at B:773–775 |
| 36 | B:757 | line representative, gt-07:L151–L174 | OK: projection selects canonical point of line |
| 37 | B:770 | LD game maps, gt-07:L188–L237 | OK: Point/ALine/DLine formulas and 1/2/3-stage presentations |
| 38 | B:777 | CL distribution, gt-04:L132–L138 | OK: one shared uniform seed |
| 39 | B:783 | `lem:alnf`, `lem:dlnf`, gt-07:L244–L272 | OK source distributions; finite implementation scope checked separately in §1 |
| 40 | B:803 | typed sampler + induced distribution, gt-06:L95–L151 | OK: seven-input machine distinguished from graph/seed sampling |
| 41 | B:810 | detyping lemma, gt-06:L445–L475 | OK: +2 levels, value-one PCC preservation, 16^Type error map; legacy marker described separately |
| 42 | B:823 | LD compiler / six PCP copies, gt-10:L1789–L1808,L1865–L1946 | OK: six-copy construction; finer anchor now used in table |
| 43 | B:836 | oracularization definition, gt-09:L34–L86 | OK: oracle gets full seed; isolated role gets corresponding CL image |
| 44 | B:852 | AR decider figure, gt-10:L2004–L2071 | OK: five guarded checks; source player/step order not promoted to a new theorem |
| 45 | B:878 | AR theorem plus parameter assumption, gt-10:L1813–L1828,L2077–L2116 | OK: T,Q,time premises; max(ℓ+2,5); conditional quantum conclusions |
| 46 | B:897 | introspection theorem, gt-08:L784–L817 | OK: description transformation and directed soundness cited |
| 47 | B:902 | anchored repetition, gt-11:L194–L258 | OK: AND copies against correlated strategies; theorem imported |
| 48 | B:991 | `sec:tms`, gt-03:L38–L200 | OK table anchor; project bridge marked analytic C17 SKETCH |
| 49 | B:996 | decider definition, gt-05:L612–L622 | OK: five-input format; project bound theorem separately SKETCH |
| 50 | B:1007 | succinct-SAT proposition, gt-10:L237–L271 | OK: source asymptotics, project window lemma distinguished |
| 51 | B:1011 | succinct-decider section, gt-10:L864–L905,L1096–L1117 | OK: shared reads→five decoupled blocks |
| 52 | B:1035 | Tseitin definition, gt-10:L152–L158 | OK: linear-size auxiliary-wire formula |
| 53 | B:1039 | agreement definition, gt-10:L161–L171; NW19 arithmetization at `nw19-tseitin-arith.tex:L33–L46` | OK: connective rules now assigned to NW19; OR rule is algebraically equivalent to De Morgan expansion |
| 54 | B:1042 | low-degree encoding, gt-03:L874–L892 | OK: assignment→multilinear extension; rejected defect 2 was wrong |
| 55 | B:1046 | zero-basis proposition/proof, gt-10:L1281–L1359 | OK: division and zero remainder, project algorithm labelled |
| 56 | B:1051 | PCP figure, gt-10:L1575–L1581 | OK: two equations on one supplied view |
| 57 | B:1054 | PCP theorem, gt-10:L1510–L1530 | OK: stated low-degree hypothesis essential and present |
| 58 | B:1079 | CL definition, gt-04:L35–L57 | OK: inductive stages |
| 59 | B:1084 | CL kth decomposition, gt-04:L151–L203 | OK: marginal stage sum |
| 60 | B:1088 | concat/direct sum, gt-04:L282–L292,L315–L327 | OK: membership wording, no minimum claim |
| 61 | B:1093 | axis/diagonal pushforwards, gt-07:L244–L272 | OK |
| 62 | B:1097 | LD decider, gt-07:L348–L391 | OK: consistency and degree format |
| 63 | B:1100 | LD soundness, gt-07:L413–L440 | OK: quantum measurement conclusion cited/no row |
| 64 | B:1124 | typed sampler, gt-06:L95–L151 | OK: selected pair of maps shares seed |
| 65 | B:1128 | AR verifier, gt-10:L1889–L1894 | OK: 3×6=18 named types and complete graph |
| 66 | B:1132 | AR product, gt-10:L1949–L1965; oracular roles gt-09:L43–L47 | OK: 3×18=54; graph product rather than general complete-graph claim |
| 67 | B:1137 | AR decider, gt-10:L2010–L2064 | OK: five guarded checks |
| 68 | B:1141 | detyping lemma, gt-06:L445–L475 | OK source +2/16^54 attribution; code-role issue R9 |
| 69 | B:1144 | AR theorem, gt-10:L2077–L2116 | OK: conditional contracts; executed C9 distinguished from theorem |
| 70 | B:1217 | sampler queries, gt-04:L572–L611 | OK as interface anchor for project's six DL9 operations, not an assertion that this definition states all six transformations |
| 71 | B:1223 | anchor + repetition, gt-11:L113–L136,L230–L258 | OK source contracts; 1,1→3,9→3,729 explicitly TB5 instance |
| 72 | B:1228 | Pauli theorem gt-07:L1432–L1445; intro theorem gt-08:L785–L817 | OK: each label in correct file; TB6 counts separately checked |
| 73 | B:1234 | compression figure, gt-12:L75–L98,L276–L277,L339–L345 | OK: order and 9→5→7→9 |
| 74 | B:1240 | compression theorem, gt-12:L26–L53 | OK: nine-level output, independence, conditional gap/value/Ent implications |
| 75 | B:1245 | halt figure / Kleene footnote, gt-12:L429–L449,L476–L486 | OK: paper program and alternative recursion theorem; project's equivalence theorem SKETCH |
| 76 | B:1375 | compression figure/theorem, gt-12:L26–L98 | OK analytic endpoint; run-history claims are not evidence from this source |
| 77 | `fig-certificate-tree.tex:21` | gt-09:L36–L86 | OK: three roles, oracle identity, shared seed |
| 78 | `fig-certificate-tree.tex:51` | gt-10:L2077–L2116 | OK: AR completeness/soundness/Ent theorem, cited |
| 79 | `fig-parameter-card.tex:24` | gt-12:L350–L359, specifically L355 | OK: k(n)=(λn)^((1+c3′)τ), distinguished from toy override |

**Orchestrator adjudication of checker defect 2: ACCEPTED.** `sec:ld-encoding` starts at gt-03:L833 but does not end at Schwartz–Zippel. At L874–L889 the source defines `ind_{m,y}` and `g_a`; L891–L895 states interpolation and linearity. Both B:425 and B:1042 cite the right section/file. The earlier checker stopped too early. No replacement with an answer-reduction-section citation is warranted.

**R5 — MINOR, citation “repair” falsely demotes source content to this document.** `docs/analytic/parts/part2a.tex:55–57`: “The paper says only that such simulations carry a polynomial overhead; the explicit form below is this document's own quantification of that overhead, not notation from the paper.” Authority: **gt-03:L116–L124**, `thm:universal-tm`, explicitly states `C(k|α||x|T)^c` with universal `C,c≥1`. `C_U,c_U` are renamed notation, but the bound's form is already in the cited source. Checker defect 6 was also wrong; brief 91's fix introduced this false attribution. Cite that theorem and say only that the constants have been renamed.

**R6 — MINOR, decider-only adapter silently attributed to pair-valued paper Compress.** `docs/analytic/parts/part2a.tex:1456–1458`: “no ans selector is needed because the compressor returns the decider description (gt-12 fig:halt_f steps 4–5 with lem:dhalt-values and lem:compress-independent-samplers)”. Authority: **gt-12:L445–L449** first computes the verifier-pair description, then uses its decider. **gt-12:L28–L39** and L111–L117 also specify the pair/sampler interface. The project is entitled to a decider-only Compressor: `docs/definitions.md:153` and `docs/DESIGN.md:85–91` explicitly call it a deliberate narrowing, and `src/compress/lowering.jl:126–155` returns the decider's code. The document must name that narrowing; changing “step 3” to “steps 4–5” did not make the paper itself return only a decider. No adapter-code change is demanded.

Both known source-typo footnotes are correct: Tseitin's `F(x,s)` at gt-10:L156 and arithmetization's `F_q^{m′}` at L164. Neither footnote is being treated as evidence for a general executable theorem.

## 4. Regression sweep — m1–m29 and n1–n10

The original meanings of m1–m21/n1–n3 were read from r1/r2; m22–m28/n4–n5 from r2/r3; m29/n6–n10 from r3. Historical observations about an old tree are not rewritten as timeless guarantees. Most repairs survive, but the earlier “no overclaims” conclusion does not.

| Item | Current evidence | Still closed? |
|---|---|---|
| m1 | no “the second.” fragment in source/PDF text | YES |
| m2 | A:584–600, (8.2), retains full q,η,K,H,f configurations; η′ explained at 580–581 | YES |
| m3 | `fig-D-threshold-margin.tex:9–15`: b2 left of b1; difference criterion degF+4d>2 | YES; separate old tick overprint R11 |
| m4 | all 110 `.aux` figure/page entries recomputed; zero backward page pairs | YES |
| m5 | `fig-roadmap.tex:30–43` has the extra λ-refresher→costed-code path; main caption at line 104 explains universality/PCP exceptions | YES |
| m6 | window function remains ω in B:47–71,131; μ,γ,τ,k,ε1,ε2,C0 in parameter card | YES |
| m7 | A:151–155 forward-references CL definition; symbol table level row explicitly upper bound | YES |
| m8 | A:762–766 explicitly says constant 3 absorbs delimiter install/remove and tag check | YES for analytic account; no new claim that Julia uses identical internal-Eval charges |
| m9 | Part I has multistep reductions and =β fixed-point equations; Curry/Turing distinction retained | YES |
| m10 | A:1287–1309 hardwires z into first input of z; (k+1)-input program and correct doubled size bound | YES |
| m11 | A:1435–1463 declares/adjudicates the three DESIGN differences | original disclosure YES; **source attribution still defective R6** |
| m12 | A:265–280 places circuit reconstruction inside invoked PCP verifier, not as AR step 1 | YES |
| m13 | B:798–803 names both typed-machine and induced-distribution definitions | YES |
| m14 | description figure uses SuccinctDecoupled5SAT | YES |
| m15 | map uses zero_basis_decompose and has all six claim-column rows | YES |
| m16 | `fig-y-derivation.tex:12`, `fig-psi-ml.tex:41` use rust copyflow | YES |
| m17 | ladder's second-row chips are below their own boxes; p82 visually inspected | YES |
| m18 | decoupled figure uses separate (u3)1/(u3)2 copies and L/R padded lengths | YES |
| m19 | zero-rewrite, CL-definition, level-law labels remain; §14 references resolve | YES |
| m20 | degF notation retained; no δ_F survivor | YES |
| m21 | A:78 says integer in binary, without added positivity restriction | YES |
| m22 | miniature lines 37–41 say cells numbered from 1 and window (q0,Ap),λ,v | YES, source check |
| m23 | C2 present on ladder and Fig47 TB0 rows, along with now-tested C1 | YES |
| m24 | parameter card lines 32–35 say other seven fixed; λ supplied per call | YES |
| m25 | card lines 25–26 explicitly label repetitions=2 a ToyPolicy override | YES |
| m26 | symbol table lines 18–19 explicitly identifies F with paper T slot | YES |
| m27 | same arity fix as m10; residual k+2 occurrences refer to machine tape count, not Kleene input arity | YES |
| m28 | C17 row and A:939–940 use c0(|M|+k+1)T(T+|x|), no stray factor 2 | YES |
| m29 | map first row is C10 TESTED/C19 SKETCH; table rows 1010/1013 agree | YES |
| n1 | C4b explicitly lazy quoted branches; `CLStep` continuation role still lazy | YES |
| n2 | old conclusion that document is everywhere weaker, with no inflated statuses | **NO as a present-tree conclusion: R1–R4** |
| n3 | build/coverage gate reproduced, now 92 pages/110 figures | YES |
| n4 | DESIGN's self-code sort is Quoted{A}; parameter is λ; adopted cY fuel difference disclosed | YES |
| n5 | old report-fidelity/no-overclaim observation | historical r3 acceptance stands; **not valid for brief89's complete lockstep claim: R1–R3,R8,R9** |
| n6 | all thirteen governed environments have the right amber chip (11 A, 2 B); example chip is extra, not a fourteenth theorem | YES; overbroad surrounding sentence is R10 |
| n7 | Fig98 caption states invariant; actual composite claim values agree with §14 tables | YES |
| n8 | p58 equation (10.4) tag clears formula; p74 policy box clears m′/bounds box | YES, both visually inspected |
| n9 | ladder contains C1,C7 and every C1–C19/N1 row, including C4 subdivisions | YES |
| n10 | Fig47 headers break at whole words; no header/tag overstrike on p37 | YES |

**R10 — MINOR, false blanket provenance statement.** `docs/analytic/parts/part2b.tex:949–950`: “Every theorem and lemma of Part II is instead a written derivation of this project recorded as C16–C19”. A:312/318 similarly promises coverage of “every named result”. Authority: `claims/CLAIMS.md:26–29` govern the thirteen results of §§8–11 only; B:452–453 also contains Lemma 12.1, and B:675–676 Lemma 13.2. Brief 89 itself correctly says those two have no row/chip. Narrow the blanket sentence to the enumerated thirteen; explain the separate algebra/CL lemmas if claiming exhaustive Part II provenance. This does not call for falsely adding C16–C19 chips to those lemmas.

## 5. Figures and scratch build

Two successful `pdflatex -interaction=nonstopmode -halt-on-error -output-directory=../build analytic-underpinnings.tex` passes in the scratch copy. Final PDF: **92 pages; 110 figures; 0 errors; 0 overfull; 12 underfull; 0 LaTeX warnings; 0 undefined references; 0 backward figure/page pairs**. `python3 tools/figcoverage.py ../build/analytic-underpinnings.aux` **exited 0**, with `pages without a figure: []`. `pdftotext -layout` of the scratch PDF is **identical** to that of the repository PDF.

PNG inspection at 115 dpi covered pp. **37,58,74,82,83,85,87,88,89**: Fig47; both n8 sites; ladder; correspondence map and description figure; CL and typed correspondence; compression figure; TB7 card; evidence boundary. Source checks additionally covered all other correspondence diagrams. The typography gate passes apart from the retained minor tick blemish; the semantic gate does not.

| Required figure/site | Inspection result |
|---|---|
| Fig97 ladder, p82 | all C1–C19/N1 identifiers and correct literal statuses visible; C4a/b/c present; C14 scoped; C15 CONJECTURE; no chip misplaced |
| Fig105 TB7 card, p88 | thirteen rows present and readable; amber toy chain; override 2 explicit; default cells match test; stale pending-r1 footer R7 |
| Fig98 correspondence map, p83 | C10 TESTED/C19 SKETCH first row; C11 TESTED/C15 CONJ last; no old NO ROW; caption invariant visible |
| Fig47 column 3, p37 | C1,C4c,C10–C14 added; C14 scoped; C6/N1 PROVED; no C15 illicitly in ratcheted column |
| Fig47 headers, p37 (n10) | whole-word line breaks; clear tags and body text |
| Equation (10.4), p58 (n8) | split line and equation number clear; no F_C overprint |
| Fig88 policy box, p74 (n8) | box clear of m′ and bounds; R11 retains separate threshold tick overprint |
| Fig104 compression correspondence, p87 | readable; **C9 chip applies to combined TB2/TB7 box — R3** |
| Fig102 typed correspondence, p85 | C4b/C9 chips and cited/no-row quantum leaf correct |
| Fig99 description correspondence, p83 | C10 TESTED versus C19 SKETCH distinction visible |
| Fig106 evidence boundary, p89 | toy construction labels below, cited analytic leaves above; no graphical theorem promotion |

All thirteen predicate rows, compared to `test/tb7_compress.jl:129–135` and the individually adjudicated default cells in `verdicts/tb7-r1.md`:

| Row / figure line | Predicate | Written | Asserted | Governing scope / ruling |
|---|---|---|---|---|
| 1 / 37 | field, level, λ-boundedness, n≥2 | PASS | PASS | MATCH printed outcome; r1 says runtime conjunct is prose, not a general measured bound |
| 2 / 38 | intro admissibility/divisibility/d=1 | PASS | PASS | MATCH, computed tuple checks |
| 3 / 39 | QI≥s0(N) | FAIL, owner QI<s0 | FAIL, same owner | MATCH, 2<9 |
| 4 / 40 | canonical intro tuple/M≥R | FAIL | FAIL | MATCH default numerical refutations |
| 5 / 41 | non-Pauli schemas | VACUOUS, owner QI<s0 | VACUOUS, same owner | MATCH status; accompanying prose's claimed Pauli execution is R2 |
| 6 / 42 | six AR shape/degree predicates | PASS | PASS | MATCH **on local surrogate polynomial fixture**, not D1 content; state this in card |
| 7 / 43 | AR growth/universal constants/C0 | NOT_EVALUABLE | NOT_EVALUABLE | MATCH default γ=1; not proof of general policy checker |
| 8 / 44 | canonical PCP tuple | FAIL | FAIL | MATCH, m=1 cannot encode source-time D1 trace |
| 9 / 45 | PCP encodes actual D1 | FAIL, owner pcpverifier-D1-trace | FAIL, same owner | MATCH faithful-content failure |
| 10 / 46 | actual-D1 AR game | NOT_EXECUTED, same owner | NOT_EXECUTED, same owner | MATCH; multiple guard cases can reach this layer |
| 11 / 47 | exact fixed-width σ1 | PASS | PASS | MATCH default padded object; not blanket tamper authentication |
| 12 / 48 | toy count equals source k(n) | FAIL | FAIL | MATCH, 2 versus 4294967296 |
| 13 / 49 | question/answer component guard | PASS | PASS | MATCH, 848 and 42834 ≤65536 |

These thirteen MATCHes certify transcription, not policy eligibility, completeness, or red capability. In particular row 1's printed PASS does not establish λ-boundedness for all inputs; row 6 is not a PCP for D1; and row 5 is not positive TB7 Pauli predicate evidence.

**R11 — MINOR, retained visual blemish.** `docs/analytic/figs/fig-D-threshold-margin.tex:5,7`: the `1/2` tick is placed at `(5.5,-0.4)` and the amber threshold line runs to `(5.5,-0.45)`. The p74 render visibly crosses that tick's glyph. Authority: rendered p74 and the skill's no-overlapping-elements criterion. This predates r4 and is distinct from the two repaired n8 overprints. Stop the line above the tick or move the tick downward; no semantic change is needed.

## 6. Pedagogy — attack on the evidence narrative

The §14.6/§14.7/§15 story cannot yet be accepted as a clear account of what is built, tested, and cited. The explicit toy-fuel and CITED language is useful, but it is contradicted by the following sentences/labels. A physicist who follows the prose, rather than consulting verdict files, would infer more executed or protected content than the ratchet authorizes.

| Location | Quoted overclaim/underclaim | Contradicting authority / effect | Severity |
|---|---|---|---|
| B:268–271 | “run the generated instance through the PCP builder and the answer-reduced decider on two one-bit-answer fixtures” | C10 explicitly stops equality before PCP. “Two fixtures” is being confused with “two successful end-to-end pipelines”. R1 | MAJOR |
| B:1285–1286 | “only the Pauli-typed introspection predicates execute at TB7” | TB7 r1 T7-6 and pre-dispatch Q≥s guard; zero such predicate dispatches. Readers cannot infer predicate coverage from sampler construction. R2 | MAJOR |
| `fig-D-correspondence-compression.tex:5,15` | “TB7 on descriptions” under “C9 TESTED” | C9 is the TB2 fixture; C15 is the separate unpromoted description construction. R3 | MAJOR |
| A:515–517 | “stale evidence unrepresentable” and “a mutation ... turns the suite red” | last TB7 verdict found actual stale-fact/provenance survivors; callback existence and successful scoped bindings are being turned into a universal assurance. R4 | MAJOR |
| B:1194,1267,1274,1362–1365; ladder:49; TB7-card:55 | “pending critic r1”; “What is missing is not the toy implementation but the analytic leaves, a production-policy construction ... and a C15 verdict” | r1 exists and FAILs eight implementation/evidence obligations. This leaves readers with the false impression that only an initial review and the intentionally cited mathematics remain. R7 | MINOR |
| B:845–846 | “generated by an explicit seed split rather than by applying the product maps, so the product is not evidenced as the source of the questions” | C4b/C9 and live `_answer_reduce_project`/`sample_answer_reduce_questions` say the reverse: product-sample projections, tested against a reference split. R8 | MINOR |
| B:1143, alongside B:811–813 | “CitedDetypedVerifier” beside executable `detype_sampler`, `detype_decider` | cited host marker and executable descriptions are different overloads. A reader cannot identify the implemented object from this row. R9 | MINOR |
| B:949–950 | “Every theorem and lemma of Part II ... recorded as C16–C19” | two other lemma environments are outside those rows; the status-chip rule is narrower than its prose promise. R10 | MINOR |

**R7 — MINOR, TB7 review state is stale throughout the closing story.** Exact sites are in the table above. Authority: the existing `verdicts/tb7-r1.md` FAIL/HOLD, especially its authorized-replacement section and T7-1–T7-8. Keep C15 CONJECTURE, explicitly say the first review failed, and name the outstanding or unverified repairs. B:1369–1373's dated 2026-09-27 suite/registry numbers are supported by HANDOFF's stitched full+focused history, so I do not call them fabricated. But the document calls them “the executable evidence behind these rows” without reporting the later reproducible 233/235 registry failure at `verdicts/tb7-r1.md:148`. Date/source the old run as history and give the latest governing result. No new full-run numbers were obtained here.

**R8 — MINOR, underclaims the actual TB2 question provenance.** `docs/analytic/parts/part2b.tex:845–846` quoted above. Authority: `claims/CLAIMS.md:12,18` explicitly ratchet product projections and the 20×54×both-sides comparison. `src/verifiers/answer_reduce.jl:143–150` calls `sample(verifier.sampler,...)` and projects its returned questions; `test/tb2_answer_reduce.jl:165–180` compares these with `tb2_hand_split` and asserts 54×20 comparisons. The explicit split is the independent test reference, not the production question generator. This stale negative claim obscures a repair that has already landed.

The closing chapters should give three distinct concrete examples in their existing prose: the trivial TB3 fixture reaches PCP while equality is refused; TB6 predicates accept only with disclosed toy child fuel; TB7 constructs sampler stages and a finite self-reference, but its actual-D1 game and **all** introspection predicate dispatches are absent at this fixture, with r1 evidence failures still governing promotion. The card's PASS cells must retain their precise printed/default/local-fixture interpretation. The source soundness leaves must remain CITED.

**Not checked:** no Julia suite, mutation registry, replay callbacks, policy perturbation runs, performance/fuel measurements, or live brief-93 repair execution; no reproduction of TB7 r1's Julia experiments; no new proof of any ground-truth quantum/compression theorem; no full reproof of all thirteen SKETCH derivations; no visual inspection of the other 83 PDF pages; no audit of HTML tutorial, bibliography beyond the referenced ground-truth/NW19 anchors, or repository history. Regression checks outside the nine inspected pages are source/PDF-text checks. Code facts here are static grep observations and existing ratcheted verdict evidence. Concurrent code repairs were not promoted by inspection.

## 7. Repair plan (≤ 5 lines)

1. Fix R1's two-fixture PCP overclaim and R2's Pauli execution claim; keep C10 TESTED/C15 CONJECTURE with the exact surviving scopes.
2. Split Fig104's TB2 C9 TESTED evidence from TB7 C15 CONJECTURE (R3); label card row 6's local surrogate.
3. Narrow the universal replay assurance (R4), replace pending-r1 language with FAIL/HOLD/repair state, and distinguish historical runs (R7).
4. Correct source attributions R5/R6, product provenance R8, detyping representation R9, and blanket theorem coverage R10; clear tick overlap R11.
5. Rebuild in scratch, recheck the changed claims/citations and targeted pages, and require figcoverage exit 0; this audit authorizes no claim promotion.

VERDICT: FAIL(R1,R2,R3,R4)
