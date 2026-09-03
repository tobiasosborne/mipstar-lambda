# Exact value and sequential repetition of the midpoint protocol

## Definitions and strategy space

⟨1⟩1. **ASSUME** an ambient set $S$, a nonempty prover-message set
$D\subseteq S$, a function $f:S\to S$, points $x,y\in D$, and a level
$n\in\mathbb N$. **PROVE** the following notation is well-defined.

⟨2⟩1. Define $f^0(a)=a$ and $f^{m+1}(a)=f(f^m(a))$.

⟨2⟩2. A deterministic prover strategy maps each finite public transcript
ending at an `Ask` to an element of $D$. The verifier reveals its selected
`Coin` branch before the next `Ask`, so the strategy may adapt to all
earlier verifier coins, including coins from earlier sequential copies.

⟨2⟩3. Define $V_n(x,y)$ as the **supremum** of acceptance probabilities over
deterministic prover strategies for the level-$n$ claim
$y=f^{2^n}(x)$. For a randomized prover, condition first on all its private
randomness: its value is an average of deterministic-strategy values, so it
cannot exceed the same supremum.

⟨2⟩4. **PROVE** the protocol recurrence
$$
V_0(x,y)={\bf 1}[y=f(x)],\qquad
V_n(x,y)=\sup_{z\in D}
\frac{V_{n-1}(x,z)+V_{n-1}(z,y)}2 .
$$

⟨3⟩1. At level $0$ the verifier directly tests $y=f(x)$, giving the first
identity.

⟨3⟩2. At level $n>0$, because the coin outcome is public,
$\sigma\mapsto(\sigma(\varnothing),\sigma|_{b_1},\sigma|_{b_2})$ is a
bijection onto $D\times\Sigma_{n-1}\times\Sigma_{n-1}$. Consequently
$$
\sup_{z,\sigma_1,\sigma_2}
\frac{v(\sigma_1;x,z)+v(\sigma_2;z,y)}2
=\sup_{z\in D}\frac{V_{n-1}(x,z)+V_{n-1}(z,y)}2,
$$
where the equality remains valid for infinite $D$ because all three optima
are written as suprema. **QED**.

⟨2⟩5. Put $p_n=1-2^{-n}$. Thus $p_0=0$ and
$p_n=(1+p_{n-1})/2$ for $n>0$.

⟨2⟩6. Let
$$
H(f,D,x,n)\quad\Longleftrightarrow\quad
\{f^k(x):0\le k\le 2^n\}\subseteq D .
$$
This orbit-prefix condition is strictly weaker than $f(D)\subseteq D$.

⟨2⟩7. Every value is in $[0,1]$: tests are Boolean, coins average, and
suprema of subsets of $[0,1]$ remain in $[0,1]$.

⟨2⟩8. **QED** for the definitions.

## Single-copy theorem (C6)

⟨1⟩2. **ASSUME** ⟨1⟩1. **PROVE**, simultaneously for every $n$:

1. without any orbit hypothesis, if $y\ne f^{2^n}(x)$ then
   $V_n(x,y)\le p_n$;
2. under $H(f,D,x,n)$, if $y=f^{2^n}(x)$ then $V_n(x,y)=1$; and
3. under $H(f,D,x,n)$, if $y\ne f^{2^n}(x)$ then $V_n(x,y)=p_n$, and the
   supremum is attained by a deterministic strategy.

⟨2⟩1. **PROVE** all three statements at $n=0$.

⟨3⟩1. The verifier directly tests $y=f(x)$. A true claim therefore has
value $1$, while a false claim has value $0=p_0$.

⟨3⟩2. The false-claim upper bound and equality follow immediately. The
true-claim assertion follows as well; its stated hypothesis includes
$x,f(x)\in D$ but the direct test itself needs no prover move.

⟨3⟩3. **QED** for the base case.

⟨2⟩2. **ASSUME** the three statements at level $n-1$, for all endpoint
pairs in $D$. Put $h=2^{n-1}$. **PROVE** them at level $n>0$.

⟨3⟩1. **ASSUME** $y\ne f^{2^n}(x)$. **PROVE**
$V_n(x,y)\le p_n$ without assuming $H(f,D,x,n)$.

⟨4⟩1. Fix arbitrary $z\in D$. The subclaims $z=f^h(x)$ and $y=f^h(z)$
cannot both be true, since together they imply
$y=f^h(f^h(x))=f^{2^n}(x)$.

⟨4⟩2. At least one selected subclaim is therefore false. Its value is at
most $p_{n-1}$ by the orbit-free induction hypothesis; the other value is at
most $1$ by ⟨1⟩1.⟨2⟩7.

⟨4⟩3. The average for this $z$ is at most
$(1+p_{n-1})/2=p_n$. Taking the supremum over $z$ preserves the bound.

⟨4⟩4. **QED** for the sharp upper bound.

⟨3⟩2. **ASSUME** $H(f,D,x,n)$ and $y=f^{2^n}(x)$. **PROVE**
$V_n(x,y)=1$.

⟨4⟩1. Choose $z=f^h(x)$. The orbit-prefix hypothesis places $z$ in $D$
and implies both $H(f,D,x,n-1)$ and $H(f,D,z,n-1)$.

⟨4⟩2. Both subclaims are true. By the induction hypothesis, the
perfect-completeness strategies on the two public branches attain value $1$.
Their combination is a legal deterministic adaptive strategy of value $1$.

⟨4⟩3. No value exceeds $1$, so $V_n(x,y)=1$. **QED**.

⟨3⟩3. **ASSUME** $H(f,D,x,n)$ and $y\ne f^{2^n}(x)$. **PROVE**
$V_n(x,y)\ge p_n$ and that this value is attained.

⟨4⟩1. Again choose $z=f^h(x)\in D$. The left subclaim is true and the
right subclaim is false. The original orbit prefix implies the level-$(n-1)$
orbit-prefix hypothesis for both starting points $x$ and $z$.

⟨4⟩2. By the induction hypothesis, deterministic strategies attain values
$1$ on the left branch and $p_{n-1}$ on the right branch.

⟨4⟩3. Because the selected branch is public, combine those strategies after
the fixed first message $z$. This attains
$(1+p_{n-1})/2=p_n$.

⟨4⟩4. Together with ⟨2⟩2.⟨3⟩1, this gives equality. In particular, the
supremum in ⟨1⟩1.⟨2⟩3 is attained in every theorem case. **QED**.

⟨3⟩4. **QED** for the induction step.

⟨2⟩3. By induction, all statements hold for every $n\in\mathbb N$.
**QED**.

## Exact sequential AND repetition (N1, downgraded to sequential)

⟨1⟩3. **ASSUME** a false base claim satisfying the hypotheses of ⟨1⟩2,
whose single-copy optimal value is $p=p_n$. Copies run sequentially and the
verifier accepts iff all $r$ copies accept. **PROVE** that even a prover
adaptive across copies has optimal value $p^r$.

⟨2⟩1. Randomized provers may again be conditioned on their private
randomness, so fix a deterministic adaptive prover.

⟨2⟩2. For copy $i$, let $T_{<i}$ be the complete public transcript before
that copy begins, and let $A_i$ be its acceptance event.

⟨2⟩3. **Measurability and independence.** The event
$A_1\cap\cdots\cap A_{i-1}$ is $T_{<i}$-measurable. Conditioned on any
$T_{<i}=t$, the prover's residual behavior in copy $i$ is a legal
single-copy strategy, while copy $i$'s verifier coins are fresh and
independent of $T_{<i}$. Hence
$$
\Pr[A_i\mid T_{<i}=t]\le p
$$
pointwise for every reachable $t$.

⟨2⟩4. Iterated conditioning using ⟨2⟩3 gives
$$
\Pr[A_1\cap\cdots\cap A_r]\le p^r .
$$

⟨2⟩5. The bound is attained by playing an attaining single-copy strategy
in every copy. Therefore the exact adaptive sequential value is $p^r$.
**QED**.

⟨1⟩4. **PARALLEL REPETITION: UNTESTED.** The proof in ⟨1⟩3 is only for
sequential repetition. This artifact implements no lockstep parallel game
and makes no claim that its exact parallel value is $p^r$. Independent play
does give the scheme-independent lower bound $p^r$ for any repetition
format, but that observation is also untested here and is not part of the
proposed N1 row.

## Number of repetitions and cost

⟨1⟩5. **ASSUME** $n\ge1$ and
$$
r(n)=\min\{r\in\mathbb N:(1-2^{-n})^r\le1/2\}.
$$
**PROVE**
$$
2^n\ln2-\ln2\le r(n)\le2^n\ln2+1,
$$
and hence $r(n)=\Theta(2^n)$.

⟨2⟩1. With $\varepsilon=2^{-n}$ and $p=1-\varepsilon$,
$$
r(n)=\left\lceil\frac{\ln2}{-\ln p}\right\rceil .
$$

⟨2⟩2. The standard integral bounds
$$
\varepsilon\le-\ln(1-\varepsilon)
\le\frac{\varepsilon}{1-\varepsilon}
$$
follow by bounding $1/(1-t)$ on $0\le t\le\varepsilon$ between
$1$ and $1/(1-\varepsilon)$.

⟨2⟩3. Using the upper logarithm bound and $\lceil a\rceil\ge a$,
$$
r(n)\ge\frac{\ln2}{\varepsilon/(1-\varepsilon)}
=(2^n-1)\ln2=2^n\ln2-\ln2.
$$

⟨2⟩4. Using the lower logarithm bound and
$\lceil a\rceil\le a+1$,
$$
r(n)\le\frac{\ln2}{\varepsilon}+1=2^n\ln2+1.
$$

⟨2⟩5. The two bounds are constant multiples of $2^n$ for $n\ge1$.
**QED**.

⟨1⟩6. **ASSUME** unit work for each `Ask`, `Coin`, direct `Test`, and
application of $f$ at the leaf. **PROVE** the single-run and amplified costs.

⟨2⟩1. **Transcript-shape induction.** At level $0$ the direct `Test` has
profile $(0,0,1)$. At level $n>0$, an execution visits the root `Ask` and
`Coin`, then one level-$(n-1)$ branch; the induction hypothesis therefore
gives exactly $n$ `Ask` nodes, $n$ `Coin` nodes, and one `Test`.

⟨2⟩2. The leaf `Test` applies $f$ once. Thus one run has verifier work
exactly $n+n+1+1=2n+2=\Theta(n)$.

⟨2⟩3. By ⟨1⟩5, sequential amplification to error at most $1/2$ costs
$r(n)\cdot\Theta(n)=\Theta(n2^n)$, versus exactly $2n+2=\Theta(n)$ for one
run. **QED**.

In this cost model amplification is exponentially more expensive than a single
run; no claim is made about the `Compress` operator of
`docs/definitions.md`, which this toy does not instantiate.

## Proof scope versus executable checks

⟨1⟩7. **ASSUME** the files in this directory. **PROVE** their scopes are
explicit.

⟨2⟩1. `test.jl` checks the term/evaluator contracts and, for two functions
on $\mathbb Z/5\mathbb Z$ and $\mathbb Z/8\mathbb Z$, all endpoints and
levels $0\le n\le5$. These are finite instances of ⟨1⟩2.

⟨2⟩2. The test suite evaluates the adaptive cross-copy sequential DP and
checks exact equality with $p^r$ for $1\le n\le4$ and $0\le r\le4$.
It does not test parallel repetition.

⟨2⟩3. For $1\le n\le12$, the suite characterizes $r(n)$ by exact rational
powers and verifies the bounds of ⟨1⟩5 with rigorous rational lower and upper
enclosures for $\ln2$; it uses no floating-point tolerance.

⟨2⟩4. The suite checks every transcript shape through level $5$, the critic's
failed-hypothesis counterexample, a non-$f$-closed domain satisfying the sharp
hypothesis, and the bottom-up $\mathbb Z/17\mathbb Z$ table through level $8$.

⟨2⟩5. `mutations/run.jl` applies every mutation only to a temporary copy
and requires the suite to exit nonzero. Mutation killing is regression
evidence, not a mathematical proof.

⟨2⟩6. The proof covers infinite $D$ by using suprema. The Julia evaluator is
deliberately finite-domain brute force.

⟨2⟩7. **QED**.
