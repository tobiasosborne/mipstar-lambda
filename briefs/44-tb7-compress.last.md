# Brief 44 — TB7 WIP checkpoint (2026-09-25; codex exec, gpt-6-sol, xhigh; NO GIT)

Starting state: main at 2eff253; suite 12500/12500, registry 218/218 (orchestrator baseline). Fixture n=2, λ=32768, s_0=9; toy intro (2,1,1), AR (2048,1,11,6,16), mu=gamma=tau=c'=1, repetitions=2. Lane: `src/compress/**`, `src/policy/**`, TB7 tests/mutations, plus the cross-lane files listed below.

RED: `tb7_nested_meter` 0/3 — Pauli, AnswerReduce, Intro own bodies all returned under a one-step enclosing budget; expected `FuelExhausted` (test lines 163/166/168).
RED: `tb7_api` 4 pass / 3 fail — one-argument Sampler admitted; `FuelExhausted.attempted` missing; `showerror` called the attempted count a step.
RED: ProductionPolicy `compress_terms` throws rather than constructing a compact symbolic verifier (3 pass / 1 error); one visible `@test_broken` remains. RED actual-D1 evidence lacked `decoupled_clauses` (8/9); GREEN 9/9 after `bounded_trace → cook_levin → decouple5`. RED residue inventory lacked the three halting labels; GREEN exact §13.2 set.
GREEN: TB6b nested 16/16, total 22747 steps, `by_depth=[22618,129]`. Final full suite `MIPStarLambda | 12583 passed, 1 broken, 12584 total`, exit 0, wall 3m32.6; TB0 ratio gate PASS. TB7 calibrated elapsed 34.868 s / kernel 0.5232 s = 66.65 < K=198, ceiling 380.16 s. Uptime at TB7 gate 15:21:14, load 1.39/2.29/4.12.
Walls: Introspect 1.454 s; AnswerReduce 8.751 s; Repeat 2.941 s; construction 13.411 s; TB7 total 34.916 s (<60 warm target); 16-question warm allocation 0.64 MiB. Process peak 1842.9 MiB includes TB0–TB6; uptime 15:21:07, load 1.37/2.32/4.15.
Certificate tutorial: [full 317-node tree and census](44-tb7-compress.certificate.md): CONSTRUCTED 34, CHECKED 133, CITED 70, ASSUMED 62, SOURCE_REPAIR 18; CITED labels exactly §13.2. `sigma_1=67648` bytes, oversized input decider 34006 bytes > λ; actual D1 front end m=3, 10 3SAT/38 decoupled clauses vs fixture m=1 (tree wall 84.941 s, uptime 14:56:56, load 4.95/5.94/7.86). Fixed point 5/5; 16 final questions, all four modes, 54 types/2916 edges, 3894 symbols = 42834 bits.
Mutations: eleven named `M7-*` plus Pad terminal and gate inflation, with four earlier TB7 API mutants: focused `MUTATION_JOBS=4` registry `killed=17/17 baselines ok=10/10 wall=672.35 s`, exit 0 (uptime at start 15:06:10, load 1.07/3.82/6.10); all thirteen new labels KILLED by targeted assertions, no crash/survivor. Final full registry pending.

13-row predicate report (§12.5; printed status cells):
input field/level/lambda bounded; n>=2 | PASS
intro field admissible, m_I divides q_I, d_I=1 | PASS
intro embedding Q_I>=s_0(N): 2>=9 | FAIL(owner=Q_I<s_0)
intro canonical tuple equality; source M_I>=R | FAIL
non-Pauli introspection answer schemas: Introspect, Sample, Read, every Hide stage (both roles) | VACUOUS(owner=Q_I<s_0)
AR P_shape, P_formula_paper, P_tail, P_divisibility, P_degree, structural formula check | PASS
AR P_growth, universal mu/gamma/tau, n>=C_0 | NOT_EVALUABLE
AR tuple equals pcpparams(n,T,Q,sigma,gamma) | FAIL
P_pcp_encodes_D1: PCP instance arithmetizes the actual fixed-width D1 trace at printed (T,sigma_1) | FAIL(owner=pcpverifier-D1-trace)
enu:ar-game against the actual D1 | NOT_EXECUTED(owner=pcpverifier-D1-trace)
fixed-width sigma_1=length(canonical_bytes(D1)) printed as an exact integer | PASS
repeat k_toy=(lambda*n)^((1+c')tau) | FAIL
repeat question and answer component guard | PASS

| stage | field | level | dimension | exact dimension law | description dependency |
|---|---:|---:|---:|---|---|
| input V | 2 | 9 | 9 | s_0(n) = 9 | S_0,D_0 |
| V1 = Intro(V,lambda,9) | 2 | 5 | 206 | (3m_I+3) log q_I + 4(32 + 2 ell) = 206 | sampler: lambda; decider: V,lambda |
| typed AR | 2 | 5 | 624 | s_1 + (2m'_A+6) log q_A = 624 | S_1,lambda,mu,gamma,sigma_1 |
| V2 = detype(typed AR) | 2 | 7 | 840 | s_1 + (2m'_A+6) log q_A + 4|Type^ar| = 840 | same sampler dependencies |
| anchored V2 | 2 | 9 | 848 | s_2 + 8 = 848 | sampler: S_2; decider: D_2 |
| V3 = repeat | 2 | 9 | 1696 | k (s_2 + 8) = 1696, k=2 toy; source k(n)=65536² FAIL | S_2,lambda,tau |
Per-sampler `id hash / chain_set_id / selected,distinct,replayed` (all PASS):
DL9-repeat-toy 232697784bfd7f0c / tb5-rng4(0x5a)@n=2 / 4,8,8; DL9-detype 5c450e5fe8ecc354 / tb5-rng4(0x5a)@n=2 / 4,7,8; DL9-anchor 3ea107609a57499e / tb5-rng4(0x5a)@n=2 / 4,10,16; DL9-detype 7f20dfc11d58133f / tb5-rng4(0x5a)@n=2 / 4,8,8.
DL9-product 26e23c09952aa7bd / tb5-rng4(0x5a)@n=2 / 4,432,432; DL9-oracularize 8674eb43a4b363cf / tb5-rng4(0x5a)@n=2 / 4,24,24; DL9-pad 60eacc53ca7df175 / tb5-rng4(0x5a)@n=2 / 4,144,144; DL9-downsize 10293b8e70a9235c / tb5-rng4(0x5a)@n=2 / 4,144,144.
PCPSampler 6fd3bfa11a9d0968 / tb5-rng4(0x5a)@n=2 / 4,144,144; DL9-detype 39d94d514cdd2d47 / tb5-rng4(0x5a)@n=2 / 4,8,8; DL9-downsize 83df2baae19d407d / tb5-exhaustive-2^6@n=2 / 64,660,6400; TildeSIntro 51fdc294004e2929 / tb5-exhaustive-2^6@n=2 / 64,660,6400.

CROSS-LANE EDITS: `src/ir/programs.jl` Sampler sort arity `>=1→==7`; `src/compress.jl` stub arity 1→7; `test/tb3_frontend.jl` lines 141,709 use arity seven; `src/descriptions/machines.jl` `FuelExhausted.steps→attempted`/display; `test/tb6b_introspect.jl` lines 1066–1087 re-pin depth/boundaries, line 1119 field name; `src/introspect/{pauli_decider,intro_decider}.jl` nested charges; `docs/DESIGN.md` §11.4 retains UNCHARGED; `src/MIPStarLambda.jl`, `test/runtests.jl`, `test/calibration.jl` additive; `test/mutations/run.jl` TB7 registration plus exclusive whole-suite baseline/inflation scheduling after a four-way load failure. TB2 changed lines: none; `answer_reduce_pcp(::VerifierDescription,...)` added in `src/compress/answer_reduce.jl`.

DEVIATIONS: production symbolic description absent because §9 grammar encodes parameters as u32 literals (`gt-12:L263–359` needs universal symbols); nested vector/dual/Pauli/PCP arithmetic remains `UNCHARGED(owner=tb7-nested-own-steps)` (`gt-08:L417–419`); the primitive chain sets are rng4/exhaustive64 and do not yet include the 16 final seeds. Repairs: PCP downsize (`gt-10:L1948–1965`) and two λ-byte decider slots (`gt-08:L757–776`, `gt-12:L128–147`).
MERGE PROPOSAL: Keep C15 CONJECTURE; concrete ToyPolicy has measured order/levels/dimensions, two fail-visible non-executed layers, fixed-width hashes, and one finite fixed-point unfold; production symbolic construction and complete nested arithmetic metering remain open. Generalisation surface: new `src/<name>/` module supplies description-stage dispatch, canonical terms, law certificates, replayable certificate nodes, policy predicates and CITED leaves to the existing §9 API.
