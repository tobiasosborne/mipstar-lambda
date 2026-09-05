# FACTS.md — every grounded number for the tutorial page (brief 64)

Collected 2026-09-05. NOTHING on the page may be a number that is not here or in
one of the cited artefacts. Sources: `docs/tutorial/build/data/suite59q.log`,
`data/mut59.log`, `claims/CLAIMS.md`, `verdicts/*.md`, `briefs/23-tb3.last.md`,
`docs/DESIGN.md`, `docs/analytic/parts/*.tex`, `docs/findings.md`, and three short
read-only Julia probes (`probe.jl`, `extract.jl`, `guards.jl` in this directory).

## Claim statuses, verbatim from claims/CLAIMS.md

| id | status | depends-on | verdict |
|---|---|---|---|
| C1 | TESTED | C2,C3,D1 | `verdicts/tb0-r4.md` (PROMOTE) |
| C2 | TESTED | D1 | `verdicts/tb0-r3.md` (PROMOTE) |
| C3 | TESTED | D1,C8 | `verdicts/tb0-r1.md` (PROMOTE); `tb0-r3.md` (re-affirmed) |
| C4a | TESTED | D2 | `verdicts/tb1-r1..r4.md` |
| C4b | TESTED | D2, C4a | `verdicts/tb2-r2..r4.md` |
| C5 | SKETCH | C2,C8 | — |
| C6 | PROVED | — | `verdicts/midpoint-r2.md` (PROMOTE) |
| C7 | CONJECTURE | C4a,C4b | — |
| N1 | PROVED | C6 | `verdicts/midpoint-r2.md` (PROMOTE; "cannot serve as a compression step" struck — O15) |
| C8 | TESTED | — | `verdicts/tb0-r1.md` (PROMOTE, scoped); r2, r3 re-affirmed |
| C9 | TESTED | D1,D2,C3,C4a,C4b | `verdicts/tb2-r2..r4.md` |
| C12 | CONJECTURE | C4a,C4b | `verdicts/design-v2-r2.md` (AUTHORIZED as CONJECTURE) |
| C13 | CONJECTURE | C12 | `verdicts/design-v2-r2.md` |
| C14 | CONJECTURE | C12,C4a | `verdicts/design-v2-r3.md` |
| C15 | CONJECTURE | C12,C13,C14 | `verdicts/design-v2-r2.md` |
| C16 | SKETCH | — | — (part2a §8.3–8.4) |
| C17 | SKETCH | C16 | — (part2a §9.1–9.3) |
| C18 | SKETCH | C16,C17 | — (part2a §10.1–10.3) |
| C19 | SKETCH | C16,C17 | — (part2b §11.1–11.3) |

**There is no C4c row.** `verdicts/tb1-r4.md` §5: **C4c — HOLD** (not created at
TESTED). Missing step: N23 — `off_line_hits = 0` of 71,360 has no red witness.
There is no C10/C11 row either: TB3's merge proposal C10 is a *proposal*;
`verdicts/tb3-r1.md` = `FAIL(N1,N2,N3)`. Chapters 6 and 11 must say so.

## Suite state (data/suite59q.log)
- `MIPStarLambda | 906 passed, 1 failed, 907 total, 5m05.1s`.
- The single failure is the **wall-clock gate**: `TB0 60 s test-body hard limit
  (measured 85.199 s)`; `runtests.jl:19` asserts `elapsed < 60`. Not a
  mathematical failure. Report it honestly.
- `MUTATION REGISTRY: killed=84/84 baselines ok=43/43 wall=790.69 s` (data/mut59.log).
- Load/precompile 1.89 s; cold image build 188.2 s (briefs/23-tb3.last.md).

## Ch.1 — the equality machine M= (part1a §1.2)
Two one-bit input tapes A,B; work W; output O; states q0,q1,qh. Five rows,
tested top to bottom, last is the catch-all:
1. q0, (0,0,␣,␣) or (1,1,␣,␣) → (q1; W:=1, O:=␣; R,R,S,S)   equal-input
2. q0, (0,1,␣,␣) or (1,0,␣,␣) → (q1; W:=0, O:=␣; R,R,S,S)   unequal-input
3. q1, (␣,␣,r,␣), r∈{0,1}      → (q0; W:=r, O:=r; S,S,S,S)   copy
4. q0, (␣,␣,r,r), r∈{0,1}      → (qh; W:=r, O:=r; S,S,S,S)   halt
5. q0,q1, everything else      → (qh; 0,0; S,S,S,S)          catch-all
Trace on (1,1): i=0 q0 → i=1 q1 → i=2 q0 → i=3 qh. M=(1,1)=1, Time=3.

## Ch.2 — quotation, canonical bytes (probe.jl, briefs/23-tb3.last.md)
Trivial decider `λ n x y a b . true`: **33 bytes**, fnv1a64 `f8561ef8c5761695`.
Hex: `c2 00000007 44656369646572 22 00000005 00000001 26 43 01 30 00000001 00000000`
Field labels (src/ir/programs.jl `_encode_program!`, `_PROGRAM_TAGS`):
`c2` PROGRAM_HEADER · `00000007` sort-symbol length · `Decider` · `22` Lambda ·
`00000005` arity 5 · `00000001` child count · `26` Prim · `43` NameBool · `01` true ·
`30` Concrete · `00000001` bound 1 · `00000000` arg count 0.  (1+4+7+1+4+4+1+1+1+1+4+4=33)
Equality decider `λ n x y a b . (a==b)`: **64 bytes**, hex
`c2000000074465636964657222000000050000000126400000000265713000000001000000022000000000000000030000000020000000000000000400000000`
TB3 gallery sizes: [13, 28, 22, 42, 43, 46, 58, 37, 88, 66, 52].
De Bruijn: λx.λy.x y ≡ λ.λ.(1 0); frames [B],[A] resolve 0→B, 1→A (part1b §4).
Y = λF.(λx.F(xx))(λx.F(xx)); Z = λF.(λx.F(λu.xxu))(λx.F(λu.xxu)); c_Y = 3 in §8's
constants but **c_Y = 1 in the TB3 instantiation** (C18 row, verdicts/tb3-r1.md N3).

## Ch.3 — fuel / CEK (src/ir/programs.jl, probe.jl)
Charged contractions: BoundVar lookup, closure creation, beta, If selection,
Prim (its charge), Quote, Fix unfolding, Eval front end h(d,u), Specialize.
Context navigation is folded in. Every registered primitive costs **1**:
not, and, or, eq, lt, add, sub, length, bit (and literal Bool/Int/bits).
`eval_overhead h(d,u) = 3 + description_size(d) + encoded_size(u)`; measured **63**
for the trivial decider on TB3_INPUT.
Specialize charge = `1 + term_size(code) + Σ term_size(env terms)`.
Measured (probe.jl, input `(1, [], [], [true], [false])`):
- trivial: OutOfFuel at f=0,1,2; **Value at f=3, used 3** (and 3 for any larger f).
- equality: OutOfFuel at f=0..4; **Value(false) at f=5, used 5**.
- looping Fix → OutOfFuel in 0.001 s; `M-fuel` mutant hits the host hard cap → Aborted.
Outcomes are `Value` / `OutOfFuel` / `SortError` (never a host exception); `Aborted`
is the host guard.  Bounded trace: **T = 1** for the trivial decider, **T = 3** for
the equality decider (rows count BODY transitions; eval(D,u;T+2) installs the frame).

## Ch.4/5 — CL samplers (C4a TESTED)
(q,m,d)=(8,2,1); ambient V = V_pt ⊕ V_coord ⊕ V_dir, seed_dim 5.
levels 1, 2, 3 for L_Point, L_ALine, L_DLine. Factor registers:
all of V (Point); {3,4,5},{1,2} (ALine); {3},{4,5},{1,2} (DLine).
Distinct branch chains 1, 8, 288.  98,304 marginal replays;
196,608 = 32,768+65,536+98,304 k-checks. Factor/Linear at j=2 for L_ALine: 8 and 512.
`description_size` **75 / 132 / 156 bytes**; closures and every direct_sum/concatenate
output are `NotDescribable`. Stage-1 matrix occupies bytes 41:65.
Joint histograms over all 8^5 = 32,768 seeds:
  μ_{ALine,Point} support **512**, every mass **64**;
  μ_{DLine,Point} support **18,432**, masses **1 or 8**;
  512 zero-direction support points carrying **2,304** seeds.
χ-free marginal content: axis support 128 (all masses 256); diagonal 4,096 (masses 4, 36).
Memo: distinct Linear prefixes 10,000, CL_MEMO_LIMIT 4,096, max_entries 1,808.
Four queries (def:sampler): Dimension / Marginal / Factor / Linear.
Real query answers (suite): `Factor(L_ALine,1,0)=[0,0,1,1,1]`,
`Factor(L_ALine,2,(0,0,4,0,0))=[1,1,0,0,0]`, `Linear` at the unreachable prefix
`(0,0,4,1,0)` answered=true.
GF(8) modulus **11** = 0x00b = x³+x+1. Mul table in data/cl_table.b64's sibling probe.
**data/cl_table.b64** = apply(L,z) for all 32,768 seeds × 3 maps, 2 bytes/question
(5 GF(8) coords packed 3 bits each, big-endian), 196,608 bytes. Cross-checked:
it reproduces 512/64, 18,432/{1,8}, zero-direction 512/2,304 exactly.
descriptions (extract.jl): Point 75 B `c1000000080000000500000001...`, ALine 132 B,
DLine 156 B — full hex in data/ (regenerate with extract.jl).

## Ch.6 — the classical low-degree test (NO CLAIM ROW; C4c is HELD)
Honest polynomial in the authorized-but-held C4c text: **g = 1 + x1 + x1·x2**.
Answer bounds d=1 (axis) and md=2 (diagonal, tight). κ=1 for the sweep; the κ=2
content is three separate `decider_rejections` fixtures.
Over all 8^5 seeds: **71,360** distinct support decisions across the nine ordered
type pairs, per pair
  64 / 512 / 18,432
  512 / 64 / 15,296
  18,432 / 15,296 / 2,752      (rows = left type Point/ALine/DLine)
**40,768** non-noop = 2,880 equal-type tautologies + 37,888 line-versus-point.
**off_line_hits = 0** — carries `SOURCE_REPAIR :ld_off_line_rejects`
(gt-07-ldt.tex:377-384 accepts vacuously; the executable rejects — strictly stricter).
Degree separator (suite): `point=(GF(2^3)(3), GF(2^3)(5)) claimed_d=1 actual_degree=2
format_rule=ld_axis_degree point_rule=ld_axis_point`.
Honest restrictions: axis_lines=16, diagonal_representatives=568, degree_bounds 1/2.
Trace triples (suite): Point×Point → ld_consistency PASS; ALine×Point → ld_axis_point
PASS; DLine×Point → ld_diagonal_point PASS.

## Ch.7 — Tseitin, arithmetization, F1 (C8 TESTED, C3 TESTED)
The real six-gate TB0 circuit (src/ir/circuits.jl `tb0_circuit`), inputs
x1..x5, o1..o5:
  g1 = NOT x1 ; g2 = NOT g1 ; g3 = NOT g1 ; g4 = g2 AND g3 ;
  g5 = g4 AND o1 ; g6 = g5 AND x5 ; output = g6.
Occurrence vector over the 16 Tseitin variables (x1..x5, o1..o5, w1..w6):
  **(2, 0, 0, 0, 2, 2, 0, 0, 0, 0, 6, 4, 4, 4, 4, 3)**
c_0 degree vector: **(3, 0, 0, 0, 2, 3, 1, 1, 1, 1, 6, 4, 4, 4, 4, 3)**
F1 formula (docs/findings.md): occ(w_i) = 2 + 2·fanout(gate i), occ(x_j) = 2·fanout(j);
with the output conjunct w_out, occ(w_out) = 3 + 2·fanout.  g1 has fan-out 2 → 6. ✓
C8 two-gate regression: degrees (x1,x2,x3,w1,w2) = (2,2,2,4,3), deg_w1 = 4.
Surviving weaker statement: deg_v(F_arith) ≤ 2(1+fanout_max) ≤ 6 with copy gates,
so c_0 has individual degree ≤ 7 and the Schwartz–Zippel bounds become
(6+5d)m'/q and (2+d)m'/q — the theorem survives with changed constants provided
d ≥ 7, satisfied by the paper's d = k ≥ 11.  **Frame softly: "our reading of NW19
may be wrong" (docs/findings.md F1), never "error in the paper".**
F2 (NOTE): NW19's F omits the output constraint; TB0's Tseitin adds w_out.

## Ch.8 — zero basis (C2, C1 TESTED)
c_0 = Σ_{i=1..16} c_i · zero(z_i) + r, a **formal coefficient identity**.
Witness (i) `([0,1],[0,0],[0,0],[0,0],[0,0])`: |c_0| = **33,432** monomials,
r = 0, identity true, c_0 vanishes at all **65,536** Boolean points; exactly
c_2,c_3,c_4,c_7,c_8,c_9,c_10 are zero, nine quotients nonzero, max inddeg(c_i)=6≤d.
Witness (ii) `([0,1],[0,1],[0,1],[0,1],[0,1])`: c_0 vector (3,1,1,1,3,3,1,1,1,1,6,4,4,4,4,3);
critic-Z/local-char2 support 788,032/534,912; build 14.556 s, peak RSS 680.6 MiB.
Witness (iii) all-zero: φ_C = false, |c_0| = **18,620**, |r| = **2** monomials,
coefficient identity **false**.
Boolean scope: clauses 128/896, assignments 65,536; 1,024-witness loop is a
clause-relation count (512 satisfying) — a surrogate, NOT a remainder computation.
Arbitrary-coefficient quartics: 512/512 correct; critic counterexample remainder 0.

## Ch.9 — the PCP verifier (C1 TESTED)
Witness (i) accepted by `pcpverifier` at all **128** points of the 16 named GF(8)
coordinate lines S_j through b_ρ.  At the separator `b_rho[O2<-rho]`:
honest **β₀ = 2** over GF(8), **β₀ = 96** over GF(2^11); deleting `g_2 - o_2` gives
**1** and **48**.  `c_0(b_rho) = 48 ≠ 0` for witness (ii) over GF(2^11).
GF(8) modulus 0x00b, exhaustive triples 512; GF(2^11) modulus 0x805, seed 0x092048,
triples 10,000.  Field change re-certified with 4 CHECKED nodes replayed; d=5 refused.
Layout m=2: 18 variables, sign block 11:15, c_0(z) = GF(2^3)(2) ≠ 0.
Policy γ=1: small = (PASS, FAIL, FAIL, FAIL, FAIL, FAIL);
sampled = (PASS, NOT_EVALUABLE, PASS, PASS, PASS, PASS); degree_formula = 6.
Budget: witness (i) support 33,432; product counts [37240, 33432, 33432, 33432, 33432];
cumulative 170,968 > budget 160,000 ≥ peak 37,240.

## Ch.10 — answer reduction (C4b, C9 TESTED)
(q,k,m,d,s,m') = (2048, 11, 1, 11, 6, 16). 18 PCP types, 324 edges, dims V6=(16,6,16),
SOURCE_REPAIR=true. Product: **54 types** (3 oracular roles × 18), **2,916** ordered
pairs, level 3.  Roles: alice, bob, oracle.
`guard_split actual = (2736, 180, 107, 92, 54, 53)`
= (no-check, triggering, step-5 any, step-5 only, step-1 any, step-1 only);
2736/2916 = **76/81 = 93.827 %**.
**data/tb2-guard-map.txt** (guards.jl) is the full 54×54 map: 54 type names and a
2,916-entry index into these 10 distinct guard sets, and it reproduces the split above:
  `global_consistency` 53 · `` (none) 2736 · `game` 92 · `proof_consistency+game` 3 ·
  `proof_individual_low_degree` 12 · `game+proof_consistency` 3 ·
  `global_consistency+game` 1 · `proof_simultaneous_low_degree+game` 4 ·
  `input_consistency+game` 4 · `input_low_degree` 8.
Certificate replay outcomes (7 cases, honest 21 / corrupted-rejected 21 at 3 seeds):
global_consistency, input_consistency, input_axis→ld_axis_point,
input_diagonal→ld_diagonal_point, proof_consistency,
proof_simultaneous_axis→ld_axis_point, game→pcpverifier.
Describability: 18/18; sizes Point_i 3009, ALine_1..5 2893, ALine_6 10228,
DLine_1..5 2754, DLine_6 10479.  The 54 product maps are NotDescribable
(direct_sum wraps host closures) — DL9-direct-sum at description level not implemented.
Structural guard set: individual copies (3,4,5) exactly.
Lockstep: decider trace == enumerator on 2916/2916; step 1 rejects entries 1/6/7/22
on 5 equal-type copy-6 pairs at tb2_seed 5; arity 22, rejected_with_rule 20/20.
256 conditioned seeded honest questions accepted 256/256 (RNG 0x182048).
`apply(DLine_6)` 2.65 µs warm memo, 13.19 µs on 1,000 fresh seeds; peak RSS 814.9 MiB.
The detyping "+2 levels" and quantum soundness remain CITED.

## Ch.11 — the quoted front end, TB3 (NO CLAIM ROW; verdicts/tb3-r1.md FAIL(N1,N2,N3))
Trivial decider: T=1, rows 2 (`row 0 Prim(true) fuel=1 running`; `row 1 Value(true)
fuel=0 accept`), accepts=true.
cook_levin: m=1, M=2, clauses 1, present tuples 16/64, gates 1, eliminated 0.
decouple5: widths **(0,0,1,1,1)**, 1 clause; pad5: m=1, s=6 (live 1 = AND(x3,o3),
5 NOT padding), m'=16, present 256/1024, witnesses 512/1024.
PCP: |c_0| (i) = **10,140**, (ii) = **162,240**; build 0.35 s / 4.605 s;
TB2 decider cases accepted **7/7** in 1.013 s; peak RSS 1,291,759,616 B.
Equality decider snapshot: T=3, rows 4; 3SAT m=3 M=8 **15 clauses**, 0 eliminated;
5SAT widths (0,0,3,3,3), **47 clauses** = 15 formula + 4 copy + 28 equality;
padded m=3, live 423, s=492, m'=512;
`arith_q` → **ExpansionRefused(279,936 > 160,000)** at the 7th gadget.
Certificate leaves: `[CITED] CookLevinGeneral` (prop:standard-succinct-sat,
gt-10:237-273) and `[ASSUMED] RawAnswerBlocks` (enc_Γ format and the (10)^(L/2-T)
padding clauses of gt-10:1036-1130 not emitted).
A borrowed front-end certificate on another proof is refused with `:certificate_binding`.

## Ch.12 — introspection, DESIGN §11 (C14 CONJECTURE — designed, not yet executable)
R = N^λ. c = smallest even integer ≥ (b+a)/b; q = 2^(c·⌈log log R⌉+1);
m = largest power of two ≤ c·⌈log R⌉+1; d = 1; M = 2^m; Q = M·log2(q).
a, b remain symbols → a production numeric instance is NOT_EVALUABLE.
Capacity chain s(N) ≤ R ≤ M ≤ Q; the theorem predicate is **M ≥ R**, not Q ≥ R.
TypePauli = ({Point,ALine,DLine,Pauli,Pair}×{X,Z}) ∪ {Constraint_1..6} ∪
{Variable_1..9} ∪ {Pair} — **26 types**; G^pauli: 30 non-loop + 26 loop = **86**
oriented pairs (18 Magic-Square incidence edges).
TypeIntro adds ({Introspect,Sample,Read,Hide_1..Hide_ℓ}×{alice,bob}):
|TypeIntro| = **32+2ℓ**; 2ℓ+39 non-loops, 32+2ℓ loops, **6ℓ+110** oriented pairs.
V^pauli = V_xpt⊕V_zpt⊕V_coord⊕V_dir⊕V_rxpt⊕V_rzpt, dim_q = 3m+3.
Ŝ^intro typed: field 2, level 3, dim (3m+3)·log2 q.
S^intro untyped: field 2, **level 5**, dim (3m+3)·log2 q + 4·(32+2ℓ).
Child fuel unit = one metered quoted-interpreter step; production gives every child
call exactly **R** units; the counter rejects before executing step R+1.
TB6b-E: n=2, N=4, λ=1, R=4, ℓ=1, (q,m,d)=(2,1,1), dimension 142, F_child = **65,536**,
`toy_child_fuel = FAIL(owner=tb6-child-meter)`; exact support/mass one over 116 pairs;
literal rejection count 10. TB6b-M: λ=2, R=16, ℓ=3, s=6, (8,2,1), dimension 179,
literal rejection count 22, 512 draws. Twelve owned mutations.
Wire format: every vector field y, z, y⊥, x is a full **Q-bit** vector with its last
Q−s(N) coordinates zero (gt-08:524-530); requires the separately printed Q ≥ s(N).
Quantum rigidity stays CITED from thm:pauli (gt-07-ldt.tex:1426-1447).

## Ch.13 — anchoring and repetition, DESIGN §10 (C13 CONJECTURE — design only)
k(n) = **(λn)^((1+c')τ)**; the description is valid only when this is a positive
integer; the universal-bound predicate is reported NOT_EVALUABLE.
Source finding: gt-12:70 prints the shorter (λn)^τ, conflicting with gt-11:200 and
gt-12:355; the executable keeps the latter two and reports the inconsistent line.
Anchoring: type set {Game, Anchor}, complete graph with both self-loops; Anchor is
the zero map, `SOURCE_REPAIR(zero-map-factor-partition)`; after detyping,
field 2, level ℓ+2, dimension s(n)+8.
Repeat: field 2, level ℓ+2, dimension k(n)·(s(n)+8), question bits ≤ k(n)·(s(n)+8).
`repeat_decider` computes B(n) = (λn)^τ **before** reading payloads (DD-26).
TB5 instance: V_copy over F_2, ℓ=1, s(n)=1; λ=τ=c'=1, n=9 →
**B = 9, k = 9² = 81**; anchor level 3 dim 1+8 = **9**; repeat level 3 dim 81·9 = **729**;
question bound 729 bits.  128 seeded repeated question pairs, all accept.
Four named negative/boundary transcripts T5-game-seed1, T5-anchor-one,
T5-one-corrupt, T5-boundary; seven owned M5-* mutations.
Ent map and thm:repetition soundness stay CITED.

## Ch.14 — Compress and the fixed point, DESIGN §12 (C15 CONJECTURE — design only)
V1 = introspect(V,λ,9); V2 = answer_reduce(V1,λ,μ,γ); V3 = repeat(V2,λ,τ).
μ = ⌈C_intro⌉; γ = ⌈2a₁/(b₁b₂)⌉;
ε₁(n) = (1/(8a₁(λn)^a₁))^(1/b₁); ε₂(n) = (ε₁/(8a₂(λn)^a₂))^(1/b₂);
τ = least integer with τ ≥ C_ar and (λn)^τ ≥ (1/(c₃ε₂^17))·ln(8/ε₂) for all n ≥ τ, λ ≥ 1.
Level chain **9 → 5 → 7 → 9** (max(5+2,5)=7 at detype; direct sums do not raise level).
TB7 fixture: n=2, λ=32,768, s_0=9, intro (q,m,d)=(2,1,1),
AR (q,m,d,s,m') = (2^11,1,11,6,16), μ=γ=τ=c'=1, k_toy = 2.
Dimensions **s₁ = 6+200 = 206**, **s₂ = 206+38·11+216 = 840**, anchored **848**,
final **1,696**.  |TypeIntro| = 50 at ℓ=9; |TypeAR| = 3·18 = 54.
Largest TB2 line answer (m'+6)(m'd+1) = 22·177 = **3,894** field symbols = **42,834**
bits over F_{2^11}; the Repeat component guard (λn)^τ = **65,536**, so the honest toy
answer is not rejected.  16 questions occupy 16·1696 = **27,136** bits; two largest
declared line answers 2·42,834 = **85,668** bits ≈ 0.014 MiB.
Fail-visible predicates that MUST be shown: intro embedding **Q_I ≥ s₀(N): 2 ≥ 9 FAIL**;
M_I = 2^1 = 2, Q_I = 2, **3Q_I = 6 < 9**; every non-Pauli Introspect/Sample/Read/Hide
answer schema is **VACUOUS(owner=Q_I<s_0)**; `P_pcp_encodes_D1` **FAIL(owner=
pcpverifier-D1-trace)**; `enu:ar-game` **NOT_EXECUTED(owner=pcpverifier-D1-trace)**;
repeat `k_toy` FAIL; AR tuple equality FAIL; AR P_growth NOT_EVALUABLE.
Structural c_j evaluator; never materializes a dense 12^16 ≈ 1.8e17-monomial vector.
Fixed point: D_{M,λ} = Y Ψ_{M,λ} = Fix(Ψ_{M,λ}); λ=32,768; M_loop's start state
loops and its halt state is unreachable; n=2 is the smallest shared index.
Eleven named M7-* mutations.  Two layers are NOT executed on faithful content.

## Ch.15 — the process (verdicts/, mut59.log)
MAJOR-objection trajectories (the number each verdict itself tracks):
  design      13 → 3 → 1 → 0   (r4 PASS)
  design-v2   10 → 2 → 0       (r3 PASS)
  midpoint     4 → 0           (r2 PASS)
  tb0          7 → 5 → 1 → 0   (r4 PASS)
  analytic-doc 11 → 6 → 0      (r3 PASS)
  tb1          4 → 3 → 2 → 1   **still FAIL(N23) at r4**
  tb2          6 → 1 → 1 → 2   **still FAIL(NF1,NF2) at r4**  (r1 headings say
               1 FATAL + 6 MAJOR + 5 MINOR + 2 NOTE; the trajectory line repeated in
               r2/r3/r4 says 1 FATAL + 4 MAJOR + 6 MINOR + 3 NOTE — both total 14)
  tb3          3                **FAIL(N1,N2,N3) at r1**
Total-objection (all severities) trajectories: design 31→9→6→7; design-v2 27→13→7;
midpoint 14→7; tb0 23→7→10→12; tb1 12→11→11→6; tb2 14→5→5→6; tb3 10;
analytic-doc 35→15→6.
No verdict line reads PROMOTE — only PASS (6 files) and FAIL(...) (19 files);
promotions live in the per-claim decision sections.
Mutation runner: baseline-first, isolated copies, **84/84 KILLED, 43/43 baselines OK,
790.69 s**; no SURVIVED / LOAD-ERROR / UNATTRIBUTABLE.
Certificate grades: CONSTRUCTED, CHECKED, CITED, ASSUMED, SOURCE_REPAIR
(src/MIPStarLambda.jl:107) plus the policy outcomes PASS, FAIL, NOT_EVALUABLE,
VACUOUS, NOT_EXECUTED.

## Ch.16 — the real certificate trees (data/suite59q.log, verbatim)
TB0 witness (i), eleven nodes:
```
[CHECKED] PCPProof | polynomials = 22; d = 6; sparse terms are authoritative
  [CHECKED] Tseitin | variables = 16; output literal = true
  [CHECKED] ArithTseitin | degrees = occurrences; inddeg = 6
  [CHECKED] MultilinearExtension | bound = 1; coordinates = (1,)
  [CHECKED] MultilinearExtension | bound = 0; coordinates = (2,)   … (3,) (4,) (5,)
  [CHECKED] BuildC0 | inddeg = 6; monomials = 33432
  [CHECKED] ZeroBasis | remainder = 0; coefficient identity = true
  [CHECKED] PCPVerifier | formula + zero tests = accept on 1 stored certified views
```
TB3 generated instance (same shape, with the front end grafted under Tseitin):
```
[CHECKED] Pad5 | m = 1; s = 6 (live 1, padding 5 NOT gates); m' = 5m+5+s = 16;
                 relation check = exhaustive (1024); fnv1a64 = f8561ef8c5761695
  [CHECKED] Decouple5 | widths = (0,0,1,1,1); clauses = 1 (formula 1, copy 0,
                 equality 0); circuit gates = 1; exhaustive (256)
    [CHECKED] CookLevin | m = 1; M = 2; clauses = 1; rows = 2; raw = 2; aux = 0;
                 eliminated = 0; circuit gates = 1; exhaustive (64)
      [CHECKED] BoundedTrace | T = 1 body transitions (eval fuel T + 2); rows = 2;
                 result = Value(true); accepts = true
        [CHECKED] Quote | |D| = 33 bytes; fnv1a64 = f8561ef8c5761695; sort = Decider
      [CITED] CookLevinGeneral | prop:standard-succinct-sat (gt-10:237-273) …
  [ASSUMED] RawAnswerBlocks | answer blocks read as raw bits of widths 1, 1 …
[CHECKED] BuildC0 | inddeg = 5; monomials = 162240
```
