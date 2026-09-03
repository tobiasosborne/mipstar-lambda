# Design repair r3 response

Work order: `verdicts/design-r3.md` R6--R8. No claim status is promoted. Disposition: **FIXED 3 / RETRACTED 0 / DOWNGRADED 0 /
RESIDUE 0**.

| id | disposition | exact edit location | repair |
|---|---|---|---|
| R6 | FIXED | `DESIGN.md` §5, §5.1, §5.4, §5.5; C3 tuple substitution below; `DIRECTIVES FOR TB0` | Replaced witness (ii) everywhere with `([0,1],[0,1],[0,1],[0,1],[0,1])`, retaining all previously authorized C3 facts. Recorded the r3 critic's 788,032-over-`Z` / 534,912-in-characteristic-two support counts as external measurements pending TB0 confirmation. At `b_rho[O2 <- rho]`, re-derived honest `beta_0=rho^5(1+rho)` versus mutated `beta_0=rho^4(1+rho)` (2 versus 1 in `GF(8)`, 96 versus 48 in `GF(2^11)`), so mutation B is red-capable again. |
| R7 | FIXED | `DESIGN.md` §1.3, §5, §5.1, §5.5 | Made factor cardinalities follow `support(g_i)+1`: complement tables in positions 2 and 4 would give trinomial factors and `6^3*7^3*(2*3*2*3*2)=5,334,336`, while the retained five-`[0,1]` witness has only binomial factors and the correct estimate `7^3*6^3*(1+1)^5=2,370,816`. Its predicted per-multiplication peak is 788,032, so the existing `MonomialBudget=2,500,000` is retained. |
| R8 | FIXED | `DESIGN.md` §1.1; `definitions.md` §§A/F | Declared `MachineDesc`, `Level`, `M:P{MachineDesc}`, `L:P{Level}`, `n:P{Nat}`, `S_L:ClosedProgram{Sampler}`, and `Compress:ClosedProgram{Compressor}`; typed `FuelBound` as `P{Nat} x P{Level} -> Fuel`; and passed the same `L` term to both `Compress` and `FuelBound`. Primitive names and the typed `self_code` hole account for every remaining symbol. |

## C3 AUTHORIZED TUPLE SUBSTITUTION

Per the r3 scoping note, this is the authorized C3 row with only the non-degenerate witness tuple changed; every other character of the
row is retained.

```markdown
| C3 | (Degree/dependency report) TB0 retains two satisfying witnesses. For the fast degenerate witness `(a_1,...,a_5)=([0,1],[0,0],[0,0],[0,0],[0,0])`, `g_2=...=g_5=0`, so their block-locality contracts and Figure `decider-pcp` checks 4(a)/4(b) are vacuous and are not C3 evidence. Its structural and actual vectors are `(2,0,0,0,2,2,0,0,0,0,6,4,4,4,4,3)` for `F_arith` and `(3,0,0,0,2,3,1,1,1,1,6,4,4,4,4,3)` for `c_0`; its certificate checks `c_0=sum_i c_i zero(z_i)`, `r=0`, and `max_i inddeg(c_i)=6<=d` (with equality on TB0-small), with exactly `c_2,c_3,c_4,c_7,c_8,c_9,c_10` zero because the corresponding `deg_j(c_0)<=1` and the other nine quotients nonzero. For the non-degenerate witness `([0,1],[0,1],[0,1],[0,1],[0,1])`, every `g_i` is non-constant and support checks `Dependencies(g_i)={X_i}` exactly; only this witness supplies block-dependency evidence. Its `c_0` structural and actual vector is `(3,1,1,1,3,3,1,1,1,1,6,4,4,4,4,3)`, `inddeg(c_0)=6`, and every quotient is checked against the explicit relation `inddeg(c_i)<=6<=d`. | CONJECTURE | D1,C8 | — | — | — |
```

## DIRECTIVES FOR TB0

1. Replace witness (ii) with `([0,1],[0,1],[0,1],[0,1],[0,1])` everywhere it feeds TB0, C3 locality evidence, TB2 checks
   4(a)/4(b), or TB3. Keep `MonomialBudget=2,500,000`, enforced per multiplication, and assert the predicted peak 788,032 fits it.
2. Confirm or refute the r3 critic's external measurements of 788,032 normalized monomials over `Z` and 534,912 in characteristic two;
   print TB0's own support, elapsed time, and peak memory without promoting the external figures to local measurements.
3. Keep mutation B owned by witness (ii) at `b_rho[O2 <- rho]`. Assert honest `beta_0=rho^5(1+rho)` and mutated
   `beta_0=rho^4(1+rho)` (2/1 in `GF(8)` and 96/48 in `GF(2^11)`), with the verifier RHS equal to the honest value.

## RESIDUE

None.
