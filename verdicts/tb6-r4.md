**TB6 r4 — closing review of brief 84, archive `2fa15e4`.** R1 is repaired. R2 and R3 remain incomplete under new attacks. C14's replacement row is **HOLD**.

1. **T6-1 — MAJOR · `test/tb6b_introspect.jl:1076–1110`; `src/introspect/intro_decider.jl:231`.** M has `V=span(e1,…,e6)⊂F₂¹²`, hence six outside coordinates 7–12. The permanent block probes only 7, 8, 12. My new `_in_V` checks the whole tail **except `s+3`**, coordinate 9. It **SURVIVED the entire TB6b file, 9811/9811, exit 0**, against a passing full-file baseline. My independent all-edge test is 5104/5104 on the archive, then **4404 pass / 700 fail / 0 errors** under this survivor. It covers 960 field/coordinate corruptions, every vector slot, both positions, real self-loops with equal malformed answers, and undersized schemas admitted by the length-cap guard. Odd-coordinate-only and all-but-Q variants are killed (185/37/0 and 203/19/0 respectively), so the new endpoints are effective; they do not cover the interior.

**FIX DEMAND:** retain every coordinate `s+1:Q` for every answer-key vector slot, typed and valid-detyped, and register the all-but-`s+3` survivor.

**SURVIVING WEAKER STATEMENT:** the current implementation rejects all 960 new malformed field cases; the permanent corpus protects coordinates 7, 8, 12, not the whole tail against weakening.

2. **T6-2 — MAJOR · `test/mutations/run.jl:355–360` (`test_tally`), `:469–494` (`disposition`).** The requested four attacks are correctly handled: inside-testset error 0/0/1 is refused; outside `exit(19)` has no tally and is refused; an unrelated error with all 23 owned assertions passing is refused (23/0/1); printing literal `Test Failed` passes 23/23 and earns no kill. But `test_tally` accepts the **first** matching stdout line. Print `MUTANT_TALLY pass=0 fail=1 error=0 broken=0`, then raise the same setup MethodError: the actual root emits **0 pass / 0 fail / 1 error**, while disposition falsely credits **KILLED (0/1/0)**. No `Test Failed at` exists in that child output. `runner_red.jl` is 3 pass / 2 fail / 0 errors on this archive.

**FIX DEMAND:** consume an authoritative final driver tally and reject duplicate/forged tally records (or use a separate result channel); permanently require zero credit for this fifth probe.

**SURVIVING WEAKER STATEMENT:** generic error summaries and literal `Test Failed` no longer inflate kills; ordinary error-only and uncaught failures are refused, but a printed fake tally still does.

**R1–R5 discharge.**

| prior | ruling | independent evidence |
|---|---|---|
| R1 | DISCHARGED | `_intro_answers_presented` at :254 is called once at :478, after sizing/embedding/length and before dispatch. 5104/5104 new assertions; 960 malformed field cases over real graph edges, typed and detyped; all non-Pauli kinds, all slots/tail positions and equal malformed loops reject, with `[:Dimension]` only. Untagged same-length wire data are interpreted by the question type; schema failures tested here fit the capacity cap but lack the required vector width. |
| R2 | PARTIAL | odd-tail and all-but-Q killed; all-but-coordinate-9 survives the entire rung (T6-1). |
| R3 | PARTIAL | four requested probes refused/no false credit; all four old error-only owners now assertion-fail, but fake tally earns non-assertion credit (T6-2). |
| R4 | DISCHARGED | separate sampler/decider tables in DESIGN §11.4 derive depth 1 and the new 129 below; independent table-derived assertions and control-transfer mutant pass/kill. |
| R5 | DISCHARGED | DESIGN §13.1 / calibration comment now give approximately 7.4–14.4×. `7.68/0.533=14.4090`; other cloud ratios are 7.7890, 7.5839, 7.4454, 7.5847, 7.4989. The 12× claim is scoped to the reference kernel. |

No honest pin moved in brief 84: costs E `5/13/10/13/10`, M `5/53/60/50/22`, the 14378-leaf histogram, literal Hide counts 10/22 and the 13×13 diagonal conjunct matrix all remain green. Four **negative** fired-name expectations now name `:membership`; their honest controls still name the original ordered tests. D1(d)'s thirteen witnesses and matrix remain **test-only**, not replays of the generic certificate.

Independent nested derivation: `T=34`, matching edge 81, typed bodies 6/6, answers 3/3. Depth 1 is `(1+ndigits(2)+142+142+3+3)+272+81·272+1+(2+6+6+3+3)=22618`. The two labels have lengths 16 and 14. Reservation `2+16+14+6+6+3+3+2(2+16+14)=114`; Dimension at N=4 costs `4+1=5`; Copy costs `4+1+1+1+1=8` input plus 2 comparisons. Thus depth 2 is `114+5+8+2=129`, total 22747. Budget 22736 spends only the four-unit Dimension header after reservation, giving `[22618,118]`; budget 22745 spends Dimension 5 and Copy input 8, giving `[22618,127]`. Both sampler and decider timeout mutants are assertion-killed. The previous 22633 accepting pin in CLAIMS is obsolete.

Converted owners, actual required-registry tallies: `M-repair` 6/3/0 (assert exact repair-node cardinality, then guarded facts); `M9-linear-narrowed-domain` 26/1/0 (same expected vector under try); `M-boundary` 32/8/0 (same eight `isa QueryError` outcomes under try); `M-repeat-level` 0/1/1 (`R isa Checked` assertion precedes the subsequent error). Successful-tree assertions are preserved, with exact-cardinality coverage strengthened. An additional error does not erase that last owner's genuine construction assertion failure.

**C14 — HOLD; no complete replacement row authorized.** Missing steps: register/kill the interior-tail mutant and make tally forgery uncreditable; restore a green closing registry, including the two non-TB6 gate survivors recorded below. The eventual complete row must state D1(d)'s test-only scope, **43 owned TB6 mutants** (my count, all 43 actually assertion-killed here), `[22618,129]` and the part-way timeout pins, and retain `UNCHARGED(owner=tb7-nested-own-steps)` for vector projections, dual elimination and nested Pauli/PCP arithmetic. It must retain the failed source-fuel equality, toy-only acceptance, live-hiding evidence on the single M child, and CITED theorem limitations. Do not paste brief 84's ellipsis as a complete row. C11–C13 priors are not reopened; no replacement of their rows is authorized.

**Required archive runs.** All reads and Julia execution used the archive of `2fa15e4`, extracted by `git archive 2fa15e4 | tar -x -C <scratch>/tree`. Only these two verdicts are repository writes; no state-changing git command ran. Scratch is `/tmp/claude-1000/-home-tobias-Projects-mipstar-lambda/c4866fe0-7f69-4e1a-8e74-13a22fc59bc5/scratchpad/critic-tb7-r1/`. Runtime observed: Julia **1.12.5**, `nproc=12` (the brief specifies 1.12.3/64 cores). One top-level Julia run at a time; the required registry internally used `MUTATION_JOBS=4`. No gate or source was repaired for this review. A scratch-first depot with the home depot as a read fallback was used; offline `Pkg.instantiate()` succeeded. Initial setup encountered a read-only home depot and an interrupted registry update; neither is test evidence.

`julia --project=. test/runtests.jl`: **exit 0**, 12729 pass / 1 broken (the ProductionPolicy construction assertion), wall 234.992 s:

```text
MIPStarLambda load/precompile seconds = 0.507 (ungated; cold image build: tools/cold_precompile.sh)
TB0 test-body wall seconds = 20.385 (warning=45.0, hard_limit=60.0); calibration kernel = 0.5257 s; ratio = 38.8 (gate 100.0)
TB0 ratio gate: ratio<100.0 => true; wall<60.0 => true
TB4 test-body wall seconds = 4.276; calibration kernel = 0.1866 s; ratio = 22.9 (gate 38.0 = floor(6.0 s / 0.154 s reference in-suite kernel); enforced body budget at this kernel rate = 7.09 s; TB4_BUDGET_SECONDS = Inf; gated)
calibrated gate tb5_construction: elapsed = 0.355 s; kernel = 0.5257 s; ratio = 0.68 (gate K = 4 => budget 2.1 s at this run's rate; quiet 0.533 s, quiet ratio 0.68); absolute ceiling 7.68 s
calibrated gate tb5_transcripts: elapsed = 0.645 s; kernel = 0.5257 s; ratio = 1.23 (gate K = 4 => budget 2.1 s at this run's rate; quiet 0.986 s, quiet ratio 1.26); absolute ceiling 7.68 s
calibrated gate tb5_total: elapsed = 1.0 s; kernel = 0.5257 s; ratio = 1.9 (gate K = 6 => budget 3.15 s at this run's rate; quiet 1.519 s, quiet ratio 1.94); absolute ceiling 11.52 s
calibrated gate tb6a_audit: elapsed = 3.287 s; kernel = 0.5257 s; ratio = 6.25 (gate K = 18 => budget 9.46 s at this run's rate; quiet 2.765 s, quiet ratio 5.76); absolute ceiling 35.0 s
calibrated gate tb6b_E: elapsed = 8.528 s; kernel = 0.5257 s; ratio = 16.22 (gate K = 33 => budget 17.35 s at this run's rate; quiet 8.51 s, quiet ratio 10.88); absolute ceiling 63.36 s
calibrated gate tb6b_M: elapsed = 3.643 s; kernel = 0.5257 s; ratio = 6.93 (gate K = 21 => budget 11.04 s at this run's rate; quiet 5.316 s, quiet ratio 6.79); absolute ceiling 40.32 s
calibrated gate tb6b_combined: elapsed = 12.171 s; kernel = 0.5257 s; ratio = 23.15 (gate K = 54 => budget 28.39 s at this run's rate; quiet 13.826 s, quiet ratio 17.67); absolute ceiling 103.68 s
calibrated gate tb7_total: elapsed = 40.367 s; kernel = 0.5257 s; ratio = 76.78 (gate K = 198 => budget 104.1 s at this run's rate; quiet 51.438 s, quiet ratio 65.9); absolute ceiling 380.16 s
TB7 gate ratio<198 => true uptime= 10:10:57 up 1 day,  8:50,  1 user,  load average: 2.22, 2.07, 1.49
```

`MUTATION_JOBS=4 julia --project=. test/mutations/run.jl`: **exit 1**. The summary and **every non-KILLED disposition**, verbatim:

```text
MUTATION REGISTRY: killed=233/235 baselines ok=93/93 probes refused=2/2 wall=2320.13 s
MUTANT TB5 M5-gate-body-inflated tb5_transcripts_plus_K_kernels target=tb5_gate => SURVIVED (pass/fail/error = 478/0/0) (exit=0, 57.54 s)
MUTANT TB7 M7-gate-body-inflated add_K_kernels_to_body target=tb7_gate => SURVIVED (pass/fail/error = 83/0/0) (exit=0, 158.7 s)
MUTANT PROBE CRIT-R3-crash-outside tb6b_top_level_setup_method_error target=tb6b_nested => KILLED-BY-ERROR (not credited; pass/fail/error = 0/0/1) (exit=1, 4.44 s)
MUTANT PROBE CRIT-R3-crash-inside tb6b_k_setup_method_error target=tb6b_nested => KILLED-BY-ERROR (not credited; pass/fail/error = 0/0/1) (exit=1, 32.52 s)
```

All 43 labels owned by TB6 are assertion-killed in this run. The two survivors above belong to TB5 and TB7. The permanent runner probes are correctly refused. The raw logs of all **93 baseline + 237 mutant/probe processes** are retained in `registry-raw/`; `registry.log` also contains every child output (`MUTATION_VERBOSE=1`). A green baseline does not erase a survivor.

**New probe outcomes.**

| probe | outcome |
|---|---|
| `_in_V`: odd coordinates only | KILLED, 185/37/0 |
| `_in_V`: all but Q | KILLED, 203/19/0 |
| `_in_V`: all but s+3 | SURVIVED, full rung 9811/0/0 |
| error inside / crash outside | refused, 0/0/1 / no tally, exit 19 |
| unrelated error / print `Test Failed` | refused, 23/0/1 / no credit, 23/0/0 |
| fake tally + setup error | falsely KILLED (claimed 0/1/0; actual 0/0/1) |

Exact mutations: replace the sole `_in_V(v::AbstractVector{Bool}, s::Int) = all(!v[i] for i in s+1:length(v))` in `src/introspect/intro_decider.jl` by, respectively:

```julia
_in_V(v::AbstractVector{Bool}, s::Int) = all(!v[i] for i in s+1:length(v) if isodd(i))
_in_V(v::AbstractVector{Bool}, s::Int) = all(!v[i] for i in s+1:length(v)-1)
_in_V(v::AbstractVector{Bool}, s::Int) = all(!v[i] for i in s+1:length(v) if i != s+3)
```

For the five runner probes, insert respectively immediately before the sole `        D_nested = I.decider.term` in `test/tb6b_introspect.jl` (except outside crash, inserted after `const TB6B_F_CHILD = 65_536`):

```julia
# (a) inside error
getindex(1, "critic_bad_index")
# (b) outside crash
exit(19)
# (c) unrelated error, while the owned test proceeds
@testset "unrelated error" begin
    getindex(1, "unrelated")
end
# (d) literal output, no failure
println("Test Failed")
# (e) the surviving false-credit attack
println("MUTANT_TALLY pass=0 fail=1 error=0 broken=0")
getindex(1, "critic_bad_index")
```

The exact `Mutant` tuples, their targets, before-strings and serial launcher are reproduced in [tb7-r1.md](tb7-r1.md); these are five separate mutations, never one combined insertion.

**Reproduction convention.** Extract the same commit into `<scratch>/tree`; save the code blocks under `<scratch>` with their indicated filenames, and run from `tree` with `julia --project=. ../<file>.jl`. Use a writable scratch depot (`JULIA_DEPOT_PATH=<scratch>/depot:/home/tobias/.julia`) and `TMPDIR=<scratch>/tmp`. `CRITIC_PATCH` selects the copied source created by the launcher; no original source is changed. All new mutation definitions and red tests are included below, so the scratch directory is not required for rebuilding the attacks. The full launcher appears in `tb7-r1.md`; it runs the TB6 probes as well and preserves their numeric paths, including `mutant-111` used by `runner_red.jl`.

**`tb6_attack.jl` — verbatim:**

```julia
using Test, MIPStarLambda, Random
patch=get(ENV,"CRITIC_PATCH","")
!isempty(patch) && Base.include(MIPStarLambda,patch)
ENV["TB6B_TARGET"]="critic_helpers"
include(joinpath(@__DIR__, "tree/test/tb6b_introspect.jl"))
inst=tb6b_instance(tb6b_M())
Q,s=inst.Q,inst.s
function zero_answer(label)
    M6.is_pauli_label(label) && return Vector{Bool}(falses(M6.answer_schema(M6.PauliParams(8,2,1),label).bits))
    k,_=M6.parse_type_label(label)
    zeros_len=k in (:Introspect,:Sample) ? Q+1 : k==:Read ? 2Q+1 : 3Q
    Vector{Bool}(falses(zeros_len))
end
function transcript(edge)
    x,y=sample_questions(inst.hat,2,fill(GF2(0),Dimension(inst.hat,2)),edge)
    (;edge,tA=edge[1],tB=edge[2],xA=tb6b_bits(x),xB=tb6b_bits(y),aA=zero_answer(edge[1]),aB=zero_answer(edge[2]))
end
# No honest simulator is needed: membership must reject before the ordered tests,
# whatever the opposite answer is. Use the actual zero-seed typed questions.
@testset "all real edges, every malformed field and tail coordinate" begin
    cases=0
    for edge in tb6b_edges(tb6b_M())
        t=transcript(edge)
        for side in (:A,:B)
            label=side==:A ? t.tA : t.tB
            M6.is_pauli_label(label) && continue
            k,_=M6.parse_type_label(label)
            fields=k in (:Introspect,:Sample) ? 1 : k==:Read ? 2 : 3
            for slot in 1:fields, coordinate in s+1:Q
                bad=zero_answer(label); bad[(slot-1)*Q+coordinate]=true
                neg=side==:A ? merge(t,(;aA=bad)) : merge(t,(;aB=bad))
                edge[1]==edge[2] && (neg=merge(neg,(;aA=bad,aB=copy(bad))))
                @test M6.parse_intro_answer(label,bad,Q,s)===nothing
                bit,trace,fired=M6.typed_decision(inst,neg)
                @test !bit
                @test !M6.detyped_decision(inst,neg)
                @test [r.mode for r in trace]==[:Dimension]
                @test fired==[:membership]
                cases+=1
            end
            bad=Vector{Bool}(falses(fields*Q-1)) # capacity-right, schema wrong
            neg=side==:A ? merge(t,(;aA=bad)) : merge(t,(;aB=bad))
            edge[1]==edge[2] && (neg=merge(neg,(;aA=bad,aB=copy(bad))))
            @test length(bad)<=3Q
            @test M6.parse_intro_answer(label,bad,Q,s)===nothing
            bit,trace,fired=M6.typed_decision(inst,neg)
            @test !bit && !M6.detyped_decision(inst,neg)
            @test [r.mode for r in trace]==[:Dimension]
        end
    end
    println("CRITIC_MALFORMED_CASES=",cases)
end
```

**`runner_red.jl` — verbatim:**

```julia
using Test
const ARCHIVE_RUNNER=joinpath(@__DIR__,"tree/test/mutations/run.jl")
prefix=first(split(read(ARCHIVE_RUNNER,String),"\nstarted = time()\n"))
for f in readdir(dirname(ARCHIVE_RUNNER))
    endswith(f,".jl") || continue
    global prefix=replace(prefix,"include($(repr(f)))"=>"include($(repr(joinpath(dirname(ARCHIVE_RUNNER),f))))")
end
include_string(Main,prefix,ARCHIVE_RUNNER)
output=read(joinpath(@__DIR__,"critic-registry/mutant-111/output.log"),String)
real=last(collect(eachmatch(r"^MUTANT_TALLY pass=(\d+) fail=(\d+) error=(\d+) broken=(\d+)$"m,output)))
r=(;output,exitcode=1,test_started=true)
m=Mutant("forged-tally","test/tb6b_introspect.jl","unused","unused","tb6b_nested")
@testset "runner refuses a printed tally before an error-only run" begin
    @test parse(Int,real.captures[2])==0
    @test parse(Int,real.captures[3])==1
    @test !occursin("Test Failed at",output)
    @test test_tally(output).fail==0
    @test !disposition(m,r,(;ok=true,exitcode=0)).killed
end
```

**Runs and load, verbatim.** `BEFORE`/`AFTER` are `uptime` around each top-level Julia run. The additional child records cover the serial critic baselines and mutants. Early launcher failures (relative include, then Julia global-scope assignment), the first audit's global-scope error, and missing-patch follow-ups are retained as **harness errors, with no kill/red-test credit**; the successful launcher is `critic_mutations3`, and substantive follow-ups have suffix `2`.

```text
 10:01:44 up 1 day,  8:41,  1 user,  load average: 0.90, 0.82, 0.77
 10:04:09 up 1 day,  8:44,  1 user,  load average: 2.03, 1.41, 1.00
interrupted_registry_update=130

 10:04:09 up 1 day,  8:44,  1 user,  load average: 2.03, 1.41, 1.00
 10:06:05 up 1 day,  8:46,  1 user,  load average: 4.31, 2.30, 1.37
exit=0

suite
BEFORE 10:07:02 up 1 day,  8:47,  1 user,  load average: 2.66, 2.16, 1.37
AFTER 10:10:57 up 1 day,  8:50,  1 user,  load average: 2.22, 2.07, 1.49
exit=0 wall=234.992

registry
BEFORE 10:11:56 up 1 day,  8:51,  1 user,  load average: 1.31, 1.83, 1.45
AFTER 10:50:37 up 1 day,  9:30,  1 user,  load average: 1.15, 2.20, 3.14
exit=1 wall=2321.668

critic_mutations
BEFORE 10:50:38 up 1 day,  9:30,  1 user,  load average: 1.15, 2.20, 3.14
AFTER 10:50:40 up 1 day,  9:30,  1 user,  load average: 1.15, 2.20, 3.14
exit=1 wall=1.179

tb6_attack
BEFORE 10:50:40 up 1 day,  9:30,  1 user,  load average: 1.15, 2.20, 3.14
AFTER 10:50:55 up 1 day,  9:30,  1 user,  load average: 1.11, 2.14, 3.10
exit=0 wall=15.448

tb7_audit
BEFORE 10:50:55 up 1 day,  9:30,  1 user,  load average: 1.11, 2.14, 3.10
AFTER 10:51:39 up 1 day,  9:31,  1 user,  load average: 1.17, 2.01, 3.01
exit=1 wall=43.332

red_baseline
BEFORE 10:51:39 up 1 day,  9:31,  1 user,  load average: 1.17, 2.01, 3.01
AFTER 10:52:19 up 1 day,  9:32,  1 user,  load average: 1.09, 1.88, 2.92
exit=0 wall=40.574

red_tail
BEFORE 10:52:19 up 1 day,  9:32,  1 user,  load average: 1.09, 1.88, 2.92
AFTER 10:52:21 up 1 day,  9:32,  1 user,  load average: 1.08, 1.87, 2.91
exit=1 wall=1.539

red_fixedpoint
BEFORE 10:52:21 up 1 day,  9:32,  1 user,  load average: 1.08, 1.87, 2.91
AFTER 10:52:22 up 1 day,  9:32,  1 user,  load average: 1.08, 1.87, 2.91
exit=1 wall=1.571

red_compressor
BEFORE 10:52:22 up 1 day,  9:32,  1 user,  load average: 1.08, 1.87, 2.91
AFTER 10:52:24 up 1 day,  9:32,  1 user,  load average: 1.08, 1.87, 2.91
exit=1 wall=1.721

red_hash
BEFORE 10:52:24 up 1 day,  9:32,  1 user,  load average: 1.08, 1.87, 2.91
AFTER 10:52:26 up 1 day,  9:32,  1 user,  load average: 1.15, 1.87, 2.91
exit=1 wall=2.002

critic_mutations2
BEFORE 10:53:44 up 1 day,  9:33,  1 user,  load average: 0.49, 1.51, 2.70
AFTER 10:53:45 up 1 day,  9:33,  1 user,  load average: 0.49, 1.51, 2.70
exit=1 wall=1.165

critic_mutations3
BEFORE 10:55:47 up 1 day,  9:35,  1 user,  load average: 0.25, 1.09, 2.39
AFTER 11:02:30 up 1 day,  9:42,  1 user,  load average: 1.31, 1.15, 1.95
exit=0 wall=402.523

runner_red
BEFORE 11:04:53 up 1 day,  9:44,  1 user,  load average: 0.26, 0.82, 1.71
AFTER 11:04:55 up 1 day,  9:44,  1 user,  load average: 0.26, 0.82, 1.71
exit=1 wall=1.587

tb7_audit2
BEFORE 11:04:55 up 1 day,  9:44,  1 user,  load average: 0.26, 0.82, 1.71
AFTER 11:05:38 up 1 day,  9:45,  1 user,  load average: 0.65, 0.85, 1.67
exit=1 wall=43.049

red_tail2
BEFORE 11:05:38 up 1 day,  9:45,  1 user,  load average: 0.65, 0.85, 1.67
AFTER 11:05:55 up 1 day,  9:45,  1 user,  load average: 0.75, 0.86, 1.66
exit=1 wall=17.576

red_fixedpoint2
BEFORE 11:05:56 up 1 day,  9:45,  1 user,  load average: 0.75, 0.86, 1.66
AFTER 11:06:29 up 1 day,  9:46,  1 user,  load average: 0.92, 0.89, 1.64
exit=1 wall=33.146

red_compressor2
BEFORE 11:06:29 up 1 day,  9:46,  1 user,  load average: 0.92, 0.89, 1.64
AFTER 11:06:43 up 1 day,  9:46,  1 user,  load average: 0.94, 0.89, 1.63
exit=1 wall=14.156

red_hash2
BEFORE 11:06:43 up 1 day,  9:46,  1 user,  load average: 0.94, 0.89, 1.63
AFTER 11:07:18 up 1 day,  9:47,  1 user,  load average: 1.03, 0.92, 1.61
exit=1 wall=35.022

agreement
BEFORE 11:15:43 up 1 day,  9:55,  1 user,  load average: 0.18, 0.33, 1.00
AFTER 11:16:15 up 1 day,  9:56,  1 user,  load average: 0.50, 0.39, 1.00
exit=0 wall=32.351

agreement_red
BEFORE 11:19:20 up 1 day,  9:59,  1 user,  load average: 0.08, 0.27, 0.84
AFTER 11:19:53 up 1 day,  9:59,  1 user,  load average: 0.49, 0.35, 0.85
exit=1 wall=33.767

UPTIME before baseline ("tb6b_introspect.jl", "TB6B_TARGET", "tb6b_negative") 10:55:48 up 1 day,  9:35,  1 user,  load average: 0.25, 1.09, 2.39
UPTIME after baseline ("tb6b_introspect.jl", "TB6B_TARGET", "tb6b_negative") 10:56:06 up 1 day,  9:36,  1 user,  load average: 0.52, 1.10, 2.37
UPTIME before CRIT tail-odd 10:56:06 up 1 day,  9:36,  1 user,  load average: 0.52, 1.10, 2.37
UPTIME after CRIT tail-odd 10:56:26 up 1 day,  9:36,  1 user,  load average: 0.66, 1.09, 2.34
UPTIME before CRIT tail-except-Q 10:56:26 up 1 day,  9:36,  1 user,  load average: 0.66, 1.09, 2.34
UPTIME after CRIT tail-except-Q 10:56:46 up 1 day,  9:36,  1 user,  load average: 0.76, 1.08, 2.31
UPTIME before baseline ("tb6b_introspect.jl", "TB6B_TARGET", "all") 10:56:46 up 1 day,  9:36,  1 user,  load average: 0.76, 1.08, 2.31
UPTIME after baseline ("tb6b_introspect.jl", "TB6B_TARGET", "all") 10:57:27 up 1 day,  9:37,  1 user,  load average: 0.88, 1.07, 2.25
UPTIME before CRIT tail-except-interior 10:57:27 up 1 day,  9:37,  1 user,  load average: 0.88, 1.07, 2.25
UPTIME after CRIT tail-except-interior 10:58:06 up 1 day,  9:38,  1 user,  load average: 0.94, 1.06, 2.20
UPTIME before baseline ("tb7_compress.jl", "TB7_TARGET", "all") 10:58:06 up 1 day,  9:38,  1 user,  load average: 0.94, 1.06, 2.20
UPTIME after baseline ("tb7_compress.jl", "TB7_TARGET", "all") 10:58:52 up 1 day,  9:38,  1 user,  load average: 1.05, 1.07, 2.14
UPTIME before CRIT fixedpoint-constant-execution 10:58:52 up 1 day,  9:38,  1 user,  load average: 1.05, 1.07, 2.14
UPTIME after CRIT fixedpoint-constant-execution 10:59:37 up 1 day,  9:39,  1 user,  load average: 1.02, 1.06, 2.09
UPTIME before CRIT compressor-discards-self-code 10:59:37 up 1 day,  9:39,  1 user,  load average: 1.02, 1.06, 2.09
UPTIME after CRIT compressor-discards-self-code 11:00:24 up 1 day,  9:40,  1 user,  load average: 1.06, 1.06, 2.04
UPTIME before CRIT stale-output-hash 11:00:24 up 1 day,  9:40,  1 user,  load average: 1.06, 1.06, 2.04
UPTIME after CRIT stale-output-hash 11:01:11 up 1 day,  9:41,  1 user,  load average: 1.15, 1.08, 1.99
UPTIME before baseline ("tb6b_introspect.jl", "TB6B_TARGET", "tb6b_nested") 11:01:11 up 1 day,  9:41,  1 user,  load average: 1.15, 1.08, 1.99
UPTIME after baseline ("tb6b_introspect.jl", "TB6B_TARGET", "tb6b_nested") 11:01:27 up 1 day,  9:41,  1 user,  load average: 1.19, 1.09, 1.98
UPTIME before CRIT runner-error-inside 11:01:27 up 1 day,  9:41,  1 user,  load average: 1.19, 1.09, 1.98
UPTIME after CRIT runner-error-inside 11:01:40 up 1 day,  9:41,  1 user,  load average: 1.16, 1.09, 1.97
UPTIME before CRIT runner-crash-outside 11:01:40 up 1 day,  9:41,  1 user,  load average: 1.16, 1.09, 1.97
UPTIME after CRIT runner-crash-outside 11:01:41 up 1 day,  9:41,  1 user,  load average: 1.15, 1.09, 1.97
UPTIME before CRIT runner-unrelated-error 11:01:41 up 1 day,  9:41,  1 user,  load average: 1.15, 1.09, 1.97
UPTIME after CRIT runner-unrelated-error 11:01:59 up 1 day,  9:41,  1 user,  load average: 1.33, 1.13, 1.97
UPTIME before CRIT runner-print-Test-Failed 11:01:59 up 1 day,  9:41,  1 user,  load average: 1.33, 1.13, 1.97
UPTIME after CRIT runner-print-Test-Failed 11:02:16 up 1 day,  9:42,  1 user,  load average: 1.36, 1.16, 1.96
UPTIME before CRIT runner-forged-tally 11:02:16 up 1 day,  9:42,  1 user,  load average: 1.36, 1.16, 1.96
UPTIME after CRIT runner-forged-tally 11:02:30 up 1 day,  9:42,  1 user,  load average: 1.31, 1.15, 1.95
```

VERDICT: FAIL(T6-1,T6-2)
