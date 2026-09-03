# Exact value of the recursive midpoint protocol

## Definitions

⟨1⟩1. **ASSUME** a nonempty domain (D), a function (f:D\to D), points
(x,y\in D), and a level (n\in\mathbb N). **PROVE** the notation below is
well-defined.

⟨2⟩1. Define (f^m) by (f^0(a)=a) and
(f^{m+1}(a)=f(f^m(a))).

⟨2⟩2. Let (V_n(x,y)) be the maximum acceptance probability of the
level-(n) protocol, where a prover may choose any (z\in D) at every `Ask`.

⟨2⟩3. Define (p_n=1-2^{-n}). Thus (p_0=0) and
(p_n=(1+p_{n-1})/2) for (n>0).

⟨2⟩4. Every protocol value lies in ([0,1]): a `Test` has value zero or one,
a `Coin` averages two values in this interval, and an `Ask` maximizes such
values.

⟨2⟩5. **QED** for the definitions.

## The theorem

⟨1⟩2. **ASSUME** ⟨1⟩1. **PROVE**, simultaneously for every (n):

1. if (y=f^{2^n}(x)), then (V_n(x,y)=1) (perfect completeness); and
2. if (y\ne f^{2^n}(x)), then (V_n(x,y)=p_n=1-2^{-n}).

⟨2⟩1. **PROVE** the claims at (n=0).

⟨3⟩1. **ASSUME** (y=f(x)). **PROVE** (V_0(x,y)=1).

⟨4⟩1. At level zero the verifier directly tests (y=f(x)), so it accepts.

⟨4⟩2. **QED**.

⟨3⟩2. **ASSUME** (y\ne f(x)). **PROVE** (V_0(x,y)=p_0).

⟨4⟩1. The direct test rejects, so (V_0(x,y)=0=p_0).

⟨4⟩2. **QED**.

⟨3⟩3. **QED** for the base case.

⟨2⟩2. **ASSUME** both claims of ⟨1⟩2 hold at level (n-1), for every pair
of endpoints. **PROVE** they hold at level (n>0).

⟨3⟩1. Put (h=2^{n-1}). After the prover supplies (z), the verifier
uniformly selects the left claim (z=f^h(x)) or the right claim
(y=f^h(z)), each at level (n-1).

⟨3⟩2. **ASSUME** (y=f^{2^n}(x)). **PROVE** (V_n(x,y)=1).

⟨4⟩1. The prover chooses (z=f^h(x)).

⟨4⟩2. The left claim is true by construction, and the right claim is true
because (f^h(z)=f^h(f^h(x))=f^{2h}(x)=y).

⟨4⟩3. By the induction hypothesis, the prover makes either selected
subprotocol accept with probability one. Hence their average, and therefore
(V_n(x,y)), is one.

⟨4⟩4. **QED**.

⟨3⟩3. **ASSUME** (y\ne f^{2^n}(x)). **PROVE** the sharp upper bound
(V_n(x,y)\le p_n).

⟨4⟩1. Fix an arbitrary prover choice (z\in D).

⟨4⟩2. The two subclaims cannot both be true: if
(z=f^h(x)) and (y=f^h(z)), then
(y=f^h(f^h(x))=f^{2^n}(x)), contradicting the assumption.

⟨4⟩3. Thus at least one subclaim is false. Its value is (p_{n-1}) by the
induction hypothesis, while the other subclaim's value is at most one by
⟨1⟩1.⟨2⟩4.

⟨4⟩4. For this arbitrary (z), acceptance is therefore at most
((1+p_{n-1})/2=p_n). Maximizing over (z) preserves the bound.

⟨4⟩5. **QED**.

⟨3⟩4. **ASSUME** (y\ne f^{2^n}(x)). **PROVE** the matching lower bound
(V_n(x,y)\ge p_n).

⟨4⟩1. Choose the honest midpoint (z=f^h(x)), which belongs to (D)
because (f:D\to D).

⟨4⟩2. The left subclaim is true. The right subclaim must be false, since its
truth would imply (y=f^h(z)=f^{2^n}(x)).

⟨4⟩3. On the left branch use the perfect-completeness strategy from the
induction hypothesis; on the right branch use its optimal false-claim
strategy. These have values one and (p_{n-1}), respectively.

⟨4⟩4. This strategy attains
((1+p_{n-1})/2=p_n), proving the lower bound.

⟨4⟩5. **QED**.

⟨3⟩5. The upper and lower bounds give (V_n(x,y)=p_n) for every false
claim, while ⟨3⟩2 gives perfect completeness. **QED** for the induction step.

⟨2⟩3. By induction, both conclusions hold for every (n\in\mathbb N).
**QED**.

## Proof scope versus executable checks

⟨1⟩3. **ASSUME** the theorem and the files in this directory. **PROVE** their
respective scopes are explicit.

⟨2⟩1. `test.jl` exhaustively checks levels (0\) through (5), every (x),
every false (y), and every true (y), for the two requested functions on
(D=\mathbb Z/5\mathbb Z) and (D=\mathbb Z/8\mathbb Z). It also checks the
generic term evaluators, the true-claim optimum, and exact AND repetition
through level (8).

⟨2⟩2. `mutations/run.jl` checks that the same suite rejects each specified
incorrect implementation. Mutation killing supplies regression evidence; it
is not a mathematical proof.

⟨2⟩3. The argument in ⟨1⟩2 is general: it covers every domain (D), every
function (f:D\to D), every (x,y\in D), and every (n\ge0). Finiteness is
needed only by the executable brute-force `optval`, not by the proof (the
displayed matching strategy attains the bound even when (D) is infinite).

⟨2⟩4. **QED**.
