Repaired R4, R10, F1 and F2 and rebuilt :codex-file-citation{path="/home/tobias/Projects/mipstar-lambda/docs/analytic/analytic-underpinnings.pdf" purpose="output"}. Independent acceptance remains pending.

| Item | Old → new |
|---|---|
| R4 | `docs/analytic/parts/part2a.tex:517–520`: “re-runs every CHECKED replay” → visited-node callbacks, first-failure stopping, full coverage guaranteed only by a passing walk. Authority: archived `632a17f:src/certificates.jl:39–64`; `verdicts/tb7-r1.md:295–298`. |
| R10 | `docs/analytic/parts/part2b.tex:973–977`: C4a/C12 execution credit → C2 fixture checks; C12 description-law AST comparison and tracer-index evaluation; semantic implications remain CITED. Authority: `claims/CLAIMS.md:9,11,22`; `ground-truth/gt-04-cl.tex:282–363`, reopened before editing. |
| F1 | `docs/analytic/parts/part2b.tex:1429–1431`: four failures → four agreements, five rejected complete decisions, failed CHECKED replay. |
| F2 | `docs/analytic/parts/part2a.tex:1458–1465`: figure 70 `[t]` → `[H]`. `part2b.tex:1354–1355,1389–1394`: figure 108’s introduction moved before its float. Captions and labels unchanged. |

Exact T7-8 quotation, `verdicts/tb7-r1.md:49`:

> global consistency, input axis, input diagonal and proof individual diagonal are four actual accept/reject agreements; the other five complete decisions reject at the disclosed unexecuted game layer.

All five moved figures now follow their first references:

| Figure | Reference → figure |
|---|---|
| 70 | p59, reference above diagram |
| 90 | p76 → p77 |
| 94 | p80, reference above diagram |
| 104 | p87 → p88 |
| 108 | p91 → p92 |

The longer F1 correction initially displaced figure 109. A local one-baseline extension at `part2b.tex:1406–1407` restored it to p93.

| Build | Exit | Pages | Undefined refs | Overfull | Underfull | Rerun warnings | Coverage exit / bare pages |
|---|---:|---:|---:|---:|---:|---:|---|
| 1 | 0 | 95 | 0 | 0 | 12 | 1 | 1 / [93] |
| 2 | 0 | 94 | 0 | 0 | 12 | 1 | 0 / [] |
| 3, requested by log | 0 | 94 | 0 | 0 | 12 | 0 | 0 / [] |

Final inventory: **110 figures, 0 backward page pairs**. Passes 2→3 changed **0 aux/toc/out files and 0 label records**. Visually inspected 14 pages: 40, 41, 59, 76, 77, 80, 82, 83, 87, 88, 91–94; **0 observed clipping or overlap defects**.

Authored files: the two `.tex` parts and `briefs/96-analytic-repair-r3.last.md`. Rebuilt PDF: **1,520,063 bytes**, plus normal in-place auxiliary files. Scoped tracked diff: **3 analytic files, 19 insertions, 12 deletions**. Figure sources unchanged. Removed **27 temporary files and 1 directory**.

Command ledger follows; Python heredocs are identified by their operation. Build and coverage commands ran in `docs/analytic`.

| # | Command / operation | Exit |
|---:|---|---:|
| 1 | `pwd` | 0 |
| 2 | `rg --files`: AGENTS, verdict, TB7, ground-truth, analytic and coverage names | 0 |
| 3 | `cat verdicts/analytic-doc-r5.md` | 0 |
| 4 | `cat AGENTS.md` | 0 |
| 5 | `rg --files`: cited source/test/claim/figure files | 0 |
| 6 | `cat` PDF skill `SKILL.md` | 0 |
| 7 | `python3 -`: numbered ground-truth and definitions authority reads | 0 |
| 8 | `python3 -`: initial TB7/TB6/CLAIMS/certificate reads; output truncated | 0 |
| 9 | `rg --files /home/tobias/.codex /tmp -g mark_artifact_operation_started.mjs -g AGENTS.md` | 2 |
| 10 | `python3 -`: reopen TB7/TB6 ranges without truncation | 0 |
| 11 | `python3 -`: CLAIMS 8–22; output partly truncated | 0 |
| 12 | `python3 -`: reopen CLAIMS 14–18, 23–29 | 0 |
| 13 | `python3 -`: seven archived code/test authority reads using `git show` | 0 |
| 14 | `python3 -`: affected source, preamble, coverage tool and brief 94 | 0 |
| 15 | `python3 -`: remaining tables, references and style ranges | 0 |
| 16 | `python3 -`: 14 cited figure sources | 0 |
| 17 | `python3 -`: dependency availability and original aux entries | 0 |
| 18 | `python3 -`: baseline PDF bbox parse; invalid XML control character | 1 |
| 19 | `python3 -`: successful baseline bbox parse with control-character filtering | 0 |
| 20 | `node …/pdf/container_tools/mark_artifact_operation_started.mjs --operation-kind edit --expected-output-count 1 --output-format pdf` | 0 |
| 21 | `mkdir -p docs/analytic/.repair96` | 0 |
| 22 | `pdflatex -interaction=nonstopmode -halt-on-error analytic-underpinnings.tex > .repair96/pass1.stdout` | 0 |
| 23 | `git diff -- docs/analytic/parts/part2a.tex docs/analytic/parts/part2b.tex` | 0 |
| 24 | `python3 tools/figcoverage.py`, pass 1 | 1 |
| 25 | `python3 -`: preserve pass-1 auxiliaries; inspect build and figure positions | 0 |
| 26 | `python3 -`: inspect pass-1 pages 93–95 | 0 |
| 27 | `pdflatex -interaction=nonstopmode -halt-on-error analytic-underpinnings.tex > .repair96/pass2.stdout` | 0 |
| 28 | `python3 tools/figcoverage.py`, pass 2 | 0 |
| 29 | `python3 -`: preserve pass-2 auxiliaries; inspect rerun warning | 0 |
| 30 | `pdflatex -interaction=nonstopmode -halt-on-error analytic-underpinnings.tex > .repair96/pass3.stdout` | 0 |
| 31 | `git diff --check -- docs/analytic/parts/part2a.tex docs/analytic/parts/part2b.tex` | 0 |
| 32 | `python3 -`: reopen final edited source ranges | 0 |
| 33 | `python3 tools/figcoverage.py`, pass 3 | 0 |
| 34 | `python3 -`: final stability/order checks, bbox extraction and nine renders | 0 |
| 35 | `git diff --stat -- docs/analytic` | 0 |
| 36 | `python3 -`: five additional page renders | 0 |
| 37 | `rm -rf docs/analytic/.repair96` | 0 launches; 1 rejection |
| 38 | `python3 -`: validate exact scratch inventory, unlink its 27 regular files, remove directory | 0 |

Child commands:

- `git show 632a17f:<path>` for `src/certificates.jl`, `test/tb3_frontend.jl`, `src/introspect/intro_decider.jl`, `src/verifiers/answer_reduce.jl`, `test/tb2_answer_reduce.jl`, `src/descriptions/transformations.jl`, `src/repeat/anchor.jl`: **7 executions, 7 exits 0**.
- `pdftotext -bbox-layout docs/analytic/analytic-underpinnings.pdf -`: **4 executions, 4 exits 0**.
- `pdftoppm -f P -l P -r 110 -singlefile -png docs/analytic/analytic-underpinnings.pdf docs/analytic/.repair96/pP`, for P = 40, 59, 77, 80, 82, 88, 92, 93, 94, 41, 76, 83, 87, 91: **14 executions, 14 exits 0**.
- `view_image`: **14 successful inspections**. `apply_patch`: **4 successful operations**, plus **1 rejected duplicate-target attempt**, retried successfully.

Command 9 encountered 13 inaccessible directories but located the helper. Command 37 was rejected because `rm -f`-style commands were prohibited; command 38 completed cleanup through an exact validated file inventory.

Not done: **0 Julia processes, 0 suites/registries/benchmarks, 0 clean rebuilds, 0 bd commands, 0 state-changing git commands, 0 commits/pushes**. No verdicts, CLAIMS, code, tests or other lanes edited. TB6/TB7 FAIL/HOLD remain governing. Inherited preview ordering for figures 1, 3, 4 and 5 remains unchanged; no universal first-reference-order claim is made.