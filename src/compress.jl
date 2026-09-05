# DESIGN.md sections 1.1, 1.6, 2, 3, 5.6 (TB4): the Compress skeleton
#
#     Compress(V, lambda) = Repeat_{lambda,tau}(AnswerReduce_{lambda,mu,gamma}(Introspect_{lambda,9}(V)))
#
# in exactly the order of fig:compress (gt-12-compression.tex:75-98), with
# the four theorem contracts as ASSUME/PROVE objects, and the quoted fixed
# point D_{M,lambda} = Fix(Psi_{M,lambda}) of the halting verifier
# (gt-12-compression.tex:415-492, fig:halt_f).
#
# Contract interface (module swap for TB5-TB7). Each stage is a value of a
# `CompressStage` subtype; `Introspect(stage, V, lambda, ell)`,
# `AnswerReduce(stage, V, lambda, mu, gamma)` and `Repeat(stage, V, lambda,
# tau)` dispatch on it and return `Checked{StubVerifier, CertNode}` whose
# tree is: the theorem's ASSUME clauses as ASSUMED nodes with a status, one
# CHECKED `HypothesisAudit` that re-evaluates them on the attached input, the
# CITED theorem LEAF named by its label with the ground-truth line range,
# the stage's executable evidence, and the input's certificate relocated
# under it (DD-10). TB5-TB7 replace `IntrospectStub`, `AnswerReduceOnFixture`
# and `RepeatStub` by executable stages behind the same three methods; the
# level rules, bound rules, contracts and `Compress` itself do not change.
#
# What is executable here: Hole/Specialize/Fix/Quote (CHECKED), the level
# and symbolic-runtime bookkeeping of the three theorems (CHECKED), the PCP
# subtree and TB2's typed answer-reduced decider on the front-end fixture
# (CHECKED, through the real `frontend_pcp` and `answer_reduce_pcp`), and
# every checkable hypothesis. What is CITED: the four theorems and
# lem:compress-independent-samplers. Introspect and Repeat are stubs: they
# produce bookkeeping and citations only.

# ---------------------------------------------------------------------------
# Literals, the two-state machines, the stub programs.

"A Nat literal (DESIGN 1.1)."
nat(n::Integer) = Prim(Int(n), Concrete(1), ())

"A MachineDesc literal from its bit string (src/ir/programs.jl `_is_machine_desc`)."
function machine_desc(bits::AbstractString)
    literal = Prim(Bool[c == '1' for c in bits], Concrete(1), ())
    _check_sort(literal, :MachineDesc)
end

# Two states, entries (write, right?, next_hi, next_lo) at offset 4(2s+b),
# next >= 2 halts. HALTING: 0 -> 1 -> halt in exactly two steps on the blank
# tape. LOOPING: state 0 rewrites 0 and moves right forever; state 1 is
# unreachable (DESIGN 12.6's M_loop).
const TWO_STATE_HALTING = machine_desc("0101" * "0100" * "0110" * "0100")
const TWO_STATE_LOOPING = machine_desc("0100" * "0100" * "0100" * "0100")

"S_lambda stub: a one-argument closed program of sort Sampler (TB5 supplies the real one)."
const SAMPLER_STUB = Lambda(1, BoundVar(0, 0))
"lambda n x y a b . true (TB3's trivial decider, |D| = 33 bytes)."
const TRIVIAL_DECIDER = Lambda(5, Prim(true, Concrete(1), ()))
"Compress stub of sort Compressor: (pair, lambda) -> the code of the trivial decider."
const COMPRESS_STUB = Lambda(2, Quote(TRIVIAL_DECIDER, :Decider))
"Identity compressor: (pair, lambda) -> snd_code(pair), the input decider's own code."
const COMPRESS_IDENTITY = Lambda(2, Prim(:snd_code, Concrete(1), (BoundVar(0, 0),)))

"c_fix: the Fix tag byte and its 4-byte child count (analytic thm:ycode's |YCode(P)| = |P| + c_fix)."
const FIX_TAG_BYTES = 5
"c_Y = 3, the Fix unfolding charge of the CEK machine (part2a 8.3; C18)."
const FIX_UNFOLD_CHARGE = 3

# ---------------------------------------------------------------------------
# Psi_{M,lambda}: the displayed term of DESIGN 1.1 with typed holes
# machine : MachineDesc, lambda : Nat (twice: the Compress argument and the
# FuelBound) and the distinguished self_code : Decider.

"""
    psi_template(; sampler, compress)

The open body of Psi_{M,lambda} (DESIGN 1.1):

    Lambda(5, If(halts_within(machine, n), true,
                 Eval(Apply(compress, quoted_pair(Quote(sampler), self_code), lambda),
                      (n, x, y, a, b), FuelBound(n, lambda))))

`lambda` occurs twice, so the template is closed by `substitute` (host-side
specialization contract), never by the affine `specialize`.
"""
function psi_template(; sampler::Program=SAMPLER_STUB, compress::Program=COMPRESS_STUB)
    _check_sort(sampler, :Sampler)
    _check_sort(compress, :Compressor)
    n, x, y, a, b = ntuple(i -> BoundVar(0, i - 1), 5)
    lambda = Hole(:lambda, :Nat)
    Lambda(5,
        If(Prim(:halts_within, Opaque("n steps", (:n,)), (Hole(:machine, :MachineDesc), n)),
           Prim(true, Concrete(1), ()),
           Eval(Apply(compress,
                      (Prim(:quoted_pair, Concrete(1),
                            (Quote(sampler, :Sampler), Hole(SELF_CODE, :Decider))),
                       lambda)),
                (n, x, y, a, b), FuelBound(n, lambda))))
end

# Size law of the host-side specialization: every hole node named by the
# environment trades its own bytes for the inserted term's (the encoding has
# no ancestor length fields).
function _specialization_size(template::Program, env::Dict{Symbol,Program})
    total = term_size(template)
    for hole in _hole_nodes(template)
        haskey(env, hole.name) || continue
        total += term_size(env[hole.name]) - term_size(hole)
    end
    total
end

"""
    fix_specialize(template, env; sort) :: Checked{Quoted{sort}, SubstCert}

Host-side specialization contract (DESIGN 1.1; verdicts/tb3-r2.md section 7
item 4): close every hole but `self_code` by `substitute`, tie `self_code`
by `Fix`, quote. The CHECKED `:Specialize` node replays the size law
|Fix(P[env])| = |P| - sum|Hole| + sum|inserted| + c_fix against the decoded
bytes and recomputes the term; its child is `quote_program`'s `:Quote` node.
"""
function fix_specialize(template::Program, env::Tuple; sort::Symbol=:Decider)
    all(binding -> binding isa Pair{Symbol,<:Program}, env) ||
        throw(ArgumentError("a static environment maps hole names to programs"))
    names = map(first, env)
    length(unique(names)) == length(names) || throw(ArgumentError("duplicate binding"))
    SELF_CODE in names && throw(ArgumentError("self_code is tied by Fix, not by the environment"))
    for (name, term) in env
        is_closed(term) || throw(ArgumentError("replacement for $name is not closed"))
    end
    bindings = Dict{Symbol,Program}(name => term for (name, term) in env)
    body = substitute(template, bindings)
    holes(body) == Dict(SELF_CODE => 1) ||
        throw(ArgumentError("the environment must close every hole but self_code"))
    fixed = Fix(body)
    quoted = quote_program(fixed; sort)
    expected = _specialization_size(template, bindings) + FIX_TAG_BYTES
    sites = count(hole -> haskey(bindings, hole.name), _hole_nodes(template))
    replay = q -> begin
        decoded = decode_program(q)
        recomputed = Fix(substitute(template, bindings))
        ok = decoded isa Fix && term_size(decoded) == expected && program_equal(decoded, recomputed)
        CheckResult(ok, :specialize_size_law; location=:Specialize, expected=expected,
                    actual=term_size(decoded))
    end
    node = CertNode(CHECKED, :Specialize;
        facts=(display="host-side: |P| = $(term_size(template)); holes closed = $(join(String.(names), ", ")) ($(sites) sites); self_code tied by Fix; |Fix(P[env])| = $(term_size(fixed)) = |P| - sum|Hole| + sum|inserted| + c_fix, c_fix = $(FIX_TAG_BYTES); |D| = $(description_size(quoted.term)) bytes",),
        children=(quoted.certificate,),
        replay=_bound_replay(quoted.term, :Specialize, replay))
    Checked(quoted.term, node)
end

"""
    halting_decider(machine, lambda; sampler, compress) :: Checked{Quoted{:Decider}}

D_{M,lambda} = Fix(Psi_{M,lambda}). The CHECKED :Specialize node of
`fix_specialize` gains one SOURCE_REPAIR child (verdicts/tb4-r1.md O4):
the outer `Eval` of the RETURNED decider runs under `FuelBound(n, lambda)`,
an enforced budget of n^lambda units that fig:halt_f step 5
(gt-12-compression.tex:L451-L453) does not impose -- there the decider
"accepts if D^compr accepts (n, x, y, a, b)" and TIME_{D^halt}(n) <= n^lambda
is lem:lambda's CONCLUSION (L570-L638), not a specification. Below the
budget the fixed point returns OutOfFuel, which is not a decider answer.
"""
function halting_decider(machine::Program, lambda::Program; sampler::Program=SAMPLER_STUB,
                         compress::Program=COMPRESS_STUB)
    checked = fix_specialize(psi_template(; sampler, compress), (:machine => machine, :lambda => lambda))
    node = checked.certificate
    repair = CertNode(SOURCE_REPAIR, :HaltDeciderFuelBound;
        facts=(display="the returned decider runs under Eval(..., FuelBound(n, lambda)) = n^lambda units, a construction change: fig:halt_f step 5 (gt-12-compression.tex:L451-L453) accepts iff D^compr accepts (n, x, y, a, b) with no budget, and TIME_{D^halt}(n) <= n^lambda is lem:lambda's conclusion (gt-12-compression.tex:L570-L638), not a specification; below the budget the fixed point returns OutOfFuel, not a decider answer (definitions.md F: SOURCE_REPAIR(HaltDeciderFuelBound))",
               source="gt-12-compression.tex", lines=451:453))
    Checked(checked.term, CertNode(node.grade, node.rule; facts=node.facts,
                                   children=(node.children..., repair), replay=node.replay))
end

"The materialised unfolding Specialize(P, {self_code -> Quote(Fix P)}) of thm:ycode, a closed Quoted with the SubstCert."
function fix_unfolding(machine::Program, lambda::Program; sampler::Program=SAMPLER_STUB,
                       compress::Program=COMPRESS_STUB)
    body = substitute(psi_template(; sampler, compress),
                      Dict{Symbol,Program}(:machine => machine, :lambda => lambda))
    specialize(body, (SELF_CODE => Quote(Fix(body), :Decider),); sort=:Decider)
end

"""
    halting_verifier(machine, lambda; sampler, compress, levels, runtime) :: Checked{Verifier}

V = (S_lambda, D_{M,lambda}) (fig:halt_f steps 2-4, gt-12:426-455). The
level count is the stub sampler's CONSTRUCTED datum (the compressed sampler
is 9-level by thm:compression); the certificate carries the sampler's Quote
node and the decider's Specialize/Quote nodes, each bound to its object.
"""
function halting_verifier(machine::Program, lambda::Integer; sampler::Program=SAMPLER_STUB,
                          compress::Program=COMPRESS_STUB, levels::Int=9,
                          runtime::BoundExpr=Opaque("TIME_D: budget n^lambda enforced by construction, not measured (FuelBound(n, lambda) on the returned decider, SOURCE_REPAIR HaltDeciderFuelBound), plus the halts_within charge 1 + n", (:n, :lambda)))
    quoted_sampler = quote_program(sampler; sort=:Sampler)
    decider = halting_decider(machine, nat(lambda); sampler, compress)
    gap = (Opaque("value 1 accepted", ()), Opaque("value <= 1/2 rejected", ()))
    verifier = Verifier(quoted_sampler.term, decider.term, Concrete(0), Concrete(1), runtime, gap, levels)
    # verdicts/tb4-r1.md O3: the third stub. The Compress program inlined in
    # D_{M,lambda} is disclosed by name, size and value; COMPRESS_IDENTITY
    # (snd_code of the pair) is the only non-constant compressor exercised.
    fixed = decode_program(decider.term)
    compressor = compress === COMPRESS_STUB ? "COMPRESS_STUB, the constant (pair, lambda) -> Quote(lambda n x y a b . true)" :
                 compress === COMPRESS_IDENTITY ? "COMPRESS_IDENTITY, (pair, lambda) -> snd_code(pair), the input decider's own code" :
                 "a caller-supplied Compressor program"
    stub_node = CertNode(ASSUMED, :CompressStubInTerm;
        facts=(display="the Compress program inlined in D_{M,lambda} is $(compressor): $(term_size(compress)) of $(term_size(fixed)) term bytes; so the compressed branch of this decider evaluates that program, not Compress = Repeat o AnswerReduce o Introspect; COMPRESS_STUB is a constant (TRIVIAL_DECIDER's code) and COMPRESS_IDENTITY is the only non-constant compressor exercised",
               compressor=compress === COMPRESS_STUB ? :COMPRESS_STUB :
                          compress === COMPRESS_IDENTITY ? :COMPRESS_IDENTITY : :custom,
               stub_bytes=term_size(compress), term_bytes=term_size(fixed)))
    node = CertNode(CONSTRUCTED, :Verifier;
        facts=(display="V = (S_lambda, D_{M,lambda}); levels = $(levels) (stub sampler datum); |V| = max(|S|, |D|) = max($(description_size(quoted_sampler.term)), $(description_size(decider.term))) = $(description_length(verifier)); lambda = $(lambda)",),
        children=(_relocate(quoted_sampler.certificate, x -> x.sampler),
                  _relocate(decider.certificate, x -> x.decider), stub_node))
    Checked(verifier, node)
end

# ---------------------------------------------------------------------------
# Symbolic bounds (DESIGN 3): Concrete | Opaque(description, parameters).
# `bind_parameter` closes a parameter by a value or by another bound, appending the
# binding to the description and merging the inner bound's parameters, so
# the free parameters of a composed bound are computed, never invented.

_symbol_display(name::Symbol) =
    name == :D_size ? "|D|" : name == :D1_size ? "|D1|" : name == :c_prime ? "c'" : String(name)

bind_parameter(bound::Concrete, pairs::Pair{Symbol}...) = bound
function bind_parameter(bound::Opaque, pairs::Pair{Symbol}...)
    description = bound.description
    parameters = collect(bound.parameters)
    for (name, value) in pairs
        name in parameters || continue
        filter!(p -> p != name, parameters)
        if value isa Opaque
            description *= " [$(_symbol_display(name)) = $(value.description)]"
            for p in value.parameters
                p in parameters || push!(parameters, p)
            end
        elseif value isa Concrete
            description *= " [$(_symbol_display(name)) = $(value.value)]"
        else
            description *= " [$(_symbol_display(name)) = $(value)]"
        end
    end
    Opaque(description, Tuple(parameters))
end

free_parameters(bound::Opaque) = bound.parameters
free_parameters(::Concrete) = ()

# ---------------------------------------------------------------------------
# Verifier sorts. `Verifier` (src/ir/programs.jl) is the executable payload:
# quoted sampler and decider with one runtime bound for both. `StubVerifier`
# (DD-9) is a theorem-backed placeholder with the bookkeeping the theorems
# state; nobody can mistake it for an executable verifier.

# TB5 (verdicts/tb4-r1.md section 7 A): every stage output is an
# AbstractStageVerifier; StubVerifier stays the CITED-only carrier and
# `StageVerifier` (src/repeat/repeat.jl) carries an executable stage's
# real objects in `payload`.
abstract type AbstractStageVerifier end

struct StubVerifier <: AbstractStageVerifier
    origin::Symbol
    levels::Int
    sampler_time::BoundExpr
    decider_time::BoundExpr
    description::BoundExpr
    question_length::BoundExpr
    answer_length::BoundExpr
    gap::Tuple{BoundExpr,BoundExpr}
    sampler_dependencies::Tuple{Vararg{Symbol}}
    input::Any
    payload::Any
end

"Copy with fields replaced (test and stage convenience)."
StubVerifier(v::StubVerifier; kwargs...) =
    StubVerifier((haskey(kwargs, name) ? kwargs[name] : getfield(v, name)
                  for name in fieldnames(StubVerifier))...)

const _VERIFIER_INPUT = Union{Verifier,AbstractStageVerifier,VerifierDescription}

_levels(v::Verifier) = v.levels
_levels(v::AbstractStageVerifier) = v.levels
_levels(v::VerifierDescription) = v.sampler.level
_sampler_time(v::Verifier) = v.runtime
_sampler_time(v::AbstractStageVerifier) = v.sampler_time
_sampler_time(v::VerifierDescription) = Opaque("TIME_S(n): $(v.sampler.query_time), metered child calls only; NOT_EVALUABLE(owner=tb5-decider-meter)", (:n,))
_decider_time(v::Verifier) = v.runtime
_decider_time(v::AbstractStageVerifier) = v.decider_time
_decider_time(v::VerifierDescription) = Opaque("TIME_D(n): $(v.decider.time_bound), not metered in the source's unit; NOT_EVALUABLE(owner=tb5-decider-meter) (DD-31)", (:n,))
_description_bound(v::Verifier) = Concrete(description_length(v))
_description_bound(v::AbstractStageVerifier) = v.description
_description_bound(v::VerifierDescription) = Concrete(description_length(v))
_sampler_dependencies(v::Verifier) = (:S,)
_sampler_dependencies(v::AbstractStageVerifier) = v.sampler_dependencies
_sampler_dependencies(v::VerifierDescription) = (:S,)
_gap(v::Verifier) = v.gap
_gap(v::AbstractStageVerifier) = v.gap
_gap(v::VerifierDescription) = (Opaque("value 1 accepted", ()), Opaque("value <= 1/2 rejected", ()))

_split(checked::Checked) = (checked.term, checked.certificate)
_split(v::_VERIFIER_INPUT) = (v, CertNode(CONSTRUCTED, :Verifier; facts=(display="unattested input",)))

"The original input of a Compress chain: walk `input` down to the Verifier."
function _chain(v::AbstractStageVerifier)
    stages = AbstractStageVerifier[v]
    while stages[end].input isa AbstractStageVerifier
        push!(stages, stages[end].input)
    end
    reverse!(stages)
end
_original(v::AbstractStageVerifier) = _chain(v)[1].input

# ---------------------------------------------------------------------------
# ASSUME/PROVE contracts. A Hypothesis has a check `(input, params) ->
# (PredicateStatus, detail)`; PASS/FAIL where the input carries a Concrete
# figure, NOT_EVALUABLE where it carries an Opaque theorem bound or a
# property no executable here decides (normal form of a stub). A FAIL is a
# node with `status = FAIL`, and the CHECKED HypothesisAudit refuses the
# certificate with rule :hypothesis_violated at that hypothesis.

struct Hypothesis
    name::Symbol
    statement::String
    source::String
    check::Function
end

struct Contract
    name::Symbol
    theorem::Symbol
    source::String
    lines::UnitRange{Int}
    hypotheses::Tuple{Vararg{Hypothesis}}
    conclusions::Tuple{Vararg{String}}
end

_combine(statuses) = any(==(FAIL), statuses) ? FAIL :
                     any(==(NOT_EVALUABLE), statuses) ? NOT_EVALUABLE : PASS

# A constant runtime c satisfies c <= limit(n) for all n >= 2 iff c <= limit(2)
# when limit is nondecreasing in n (n^lambda, (2^(lambda n))^mu, (lambda n)^mu, (lambda n)^tau).
function _time_status(bound::BoundExpr, limit::BigInt, label::String, limit_label::String)
    bound isa Concrete || return (NOT_EVALUABLE, "$(label) = $(bound.description) (opaque)")
    (big(bound.value) <= limit ? PASS : FAIL, "$(label) = $(bound.value) <= $(limit_label)")
end

function _times_status(v, limit::BigInt, limit_label::String)
    s = _time_status(_sampler_time(v), limit, "TIME_S", limit_label)
    d = _time_status(_decider_time(v), limit, "TIME_D", limit_label)
    (_combine((s[1], d[1])), s[2] * "; " * d[2])
end

function _description_status(v, lambda::Integer)
    bound = _description_bound(v)
    bound isa Concrete || return (NOT_EVALUABLE, "|V| = $(bound.description) (opaque)")
    (bound.value <= lambda ? PASS : FAIL, "|V| = $(bound.value) <= lambda = $(lambda)")
end

_normal_form_status(v::Verifier, params) =
    (NOT_EVALUABLE, "sampler is a stub description; field size 2 and the decider format are not decided here")
_normal_form_status(v::AbstractStageVerifier, params) =
    (NOT_EVALUABLE, "normal form of a $(v.origin) output is that stage's CITED conclusion")
_normal_form_status(v::VerifierDescription, params) =
    (v.sampler.field_size == 2 && v.sampler.typing isa Untyped ? PASS : FAIL,
     "sampler over F_$(v.sampler.field_size), $(v.sampler.typing isa Untyped ? "untyped" : "typed"), level $(v.sampler.level), decider a total $(v.decider.typing isa Untyped ? "five" : "seven")-input predicate (structural check of gt-05:625-635; the value/PCC content is not decided here)")

const _DEF_LAMBDA = "gt-05-games-normalform.tex:L641-L653 (def:lambda)"
const _DEF_NORMAL_FORM = "gt-05-games-normalform.tex:L625-L635 (normal form verifier)"

const INTROSPECT_CONTRACT = Contract(:Introspect, Symbol("thm:introspection"),
    "gt-08-introspection.tex", 784:817,
    # verdicts/tb4-r1.md O7: gt-08:789-797 states the 5-level result and the
    # three complexity bounds "for all ell" unconditionally; only
    # completeness/soundness/entanglement (L801-L803) need the hypotheses.
    (Hypothesis(:lambda_bounded_description, "(completeness/soundness only) V is lambda-bounded: |V| = max(|S|, |D|) <= lambda",
                _DEF_LAMBDA, (v, p) -> _description_status(v, p.lambda)),
     Hypothesis(:lambda_bounded_time, "(completeness/soundness only) V is lambda-bounded: TIME_S(n), TIME_D(n) <= n^lambda for n >= 2",
                _DEF_LAMBDA, (v, p) -> _times_status(v, big(2)^p.lambda, "2^lambda (n = 2)")),
     Hypothesis(:ell_level, "(completeness/soundness only) V is an ell-level verifier",
                "gt-08-introspection.tex:L784-L803 (thm:introspection)",
                (v, p) -> (_levels(v) == p.ell ? PASS : FAIL, "levels = $(_levels(v)), ell = $(p.ell)"))),
    ("V^intro is a 5-level normal-form verifier for every ell (unconditionally)",
     "TIME_S = poly(n, lambda, ell) (unconditionally)", "TIME_D = poly(2^(lambda*n), ell) (unconditionally)", "|D^intro| = poly(lambda, ell) (unconditionally)",
     "completeness, soundness with delta(eps, n) = a((lambda n)^a eps^b + (lambda n)^-b), entanglement max{Ent(V_{2^n}, 1 - delta), (1 - delta) 2^(2^(lambda n))} under the hypotheses"))

const ANSWER_REDUCE_CONTRACT = Contract(:AnswerReduce, Symbol("thm:ar"),
    "gt-10-answer-reduction.tex", 2077:2116,
    (Hypothesis(:normal_form, "V is an ell-level normal form verifier", _DEF_NORMAL_FORM, _normal_form_status),
     Hypothesis(:decider_time_T, "TIME_D(n) <= T(n) = (2^(lambda*n))^mu",
                "gt-10-answer-reduction.tex:L1811-L1822 (eq:ar-params-1, eq:ar-time-assumption)",
                (v, p) -> _time_status(_decider_time(v), big(2)^(2 * p.lambda * p.mu), "TIME_D", "(2^(2 lambda))^mu (n = 2)")),
     Hypothesis(:sampler_time_Q, "TIME_S(n) <= Q(n) = (lambda*n)^mu",
                "gt-10-answer-reduction.tex:L1811-L1822 (eq:ar-params-1, eq:ar-time-assumption)",
                (v, p) -> _time_status(_sampler_time(v), big(2 * p.lambda)^p.mu, "TIME_S", "(2 lambda)^mu (n = 2)"))),
    ("V^ar is max{ell + 2, 5}-level", "TIME_S = TIME_D = poly((lambda n)^mu, |D|, gamma)",
     "S^ar depends only on S, (lambda, mu, gamma) and |D|",
     "completeness (SPCC), soundness with delta(eps, n), entanglement for n >= 2"))

const REPEAT_CONTRACT = Contract(:Repeat, Symbol("thm:repetition"),
    "gt-11-parallel-repetition.tex", 229:258,
    (Hypothesis(:normal_form, "V is an ell-level normal form verifier", _DEF_NORMAL_FORM, _normal_form_status),
     Hypothesis(:completeness_decider_time, "(completeness only) TIME_D(n) <= (lambda*n)^tau",
                "gt-11-parallel-repetition.tex:L239-L243 (enu:pr-completeness)",
                (v, p) -> _time_status(_decider_time(v), big(2 * p.lambda)^p.tau, "TIME_D", "(2 lambda)^tau (n = 2)"))),
    ("V^rep is (ell + 2)-level with k(n) = (lambda n)^((1 + c') tau)",
     "TIME_S = O(k(n) TIME_S(n)); TIME_D = O(k(n) max(TIME_D(n), (lambda n)^tau))",
     "S^rep depends only on S, lambda, tau", "completeness (PCC), soundness Ent(V^rep_n, p) >= Ent(V_n, 1 - eps)"))

const COMPRESS_CONTRACT = Contract(:Compress, Symbol("thm:compression"),
    "gt-12-compression.tex", 26:53,
    (Hypothesis(:lambda_bounded_description, "(completeness/soundness only) V is lambda-bounded: |V| <= lambda",
                _DEF_LAMBDA, (v, p) -> _description_status(v, p.lambda)),
     Hypothesis(:lambda_bounded_time, "(completeness/soundness only) TIME_S(n), TIME_D(n) <= n^lambda for n >= 2",
                _DEF_LAMBDA, (v, p) -> _times_status(v, big(2)^p.lambda, "2^lambda (n = 2)")),
     Hypothesis(:nine_level, "(completeness/soundness only) V is 9-level",
                "gt-12-compression.tex:L27-L41 (thm:compression)",
                (v, p) -> (_levels(v) == 9 ? PASS : FAIL, "levels = $(_levels(v))")),
     Hypothesis(:normal_form, "(completeness/soundness only) V is a normal form verifier", _DEF_NORMAL_FORM, _normal_form_status),
     Hypothesis(:n_at_least_C0, "(completeness/soundness only) n >= C_0, N = 2^n",
                "gt-12-compression.tex:L27-L41 (thm:compression)",
                (v, p) -> (NOT_EVALUABLE, "C_0 is a universal constant the source does not expose"))),
    ("V^compr is a 9-level normal form verifier (unconditionally)",
     "TIME_S = TIME_D = poly(n, lambda) (unconditionally)",
     "S^compr is independent of V, computable from lambda in polylog(lambda)",
     "completeness: value-1 PCC of V_N => value-1 PCC of V^compr_n",
     "soundness: Ent(V^compr_n, 1/2) >= max{Ent(V_N, 1/2), 2^(N^lambda - 1)}"))

const INDEPENDENT_SAMPLERS_LEMMA = Contract(:IndependentSamplers, Symbol("lem:compress-independent-samplers"),
    "gt-12-compression.tex", 108:118, (),
    ("S^compr depends only on lambda", "ComputeSampler(lambda) outputs it in polylog(lambda)"))

function _cited_leaf(contract::Contract)
    CertNode(CITED, contract.theorem;
        facts=(display="$(contract.source):L$(first(contract.lines))-L$(last(contract.lines)) ($(contract.theorem)): $(join(contract.conclusions, "; "))",
               source=contract.source, lines=contract.lines, label=String(contract.theorem),
               conclusions=contract.conclusions,
               hypotheses=Tuple(h.name for h in contract.hypotheses)))
end

# The ASSUME nodes with their status, plus the CHECKED audit whose replay
# re-evaluates every hypothesis on the attached input (relocated by the
# caller to that input).
function _audit(contract::Contract, input, params::NamedTuple)
    nodes = CertNode[]
    statuses = PredicateStatus[]
    for hypothesis in contract.hypotheses
        status, detail = hypothesis.check(input, params)
        push!(statuses, status)
        push!(nodes, CertNode(ASSUMED, hypothesis.name;
            facts=(display="$(hypothesis.statement): $(detail) => $(status) ($(hypothesis.source))",
                   status=status, source=hypothesis.source)))
    end
    summary = join(("$(h.name)=$(s)" for (h, s) in zip(contract.hypotheses, statuses)), ", ")
    audit = CertNode(CHECKED, :HypothesisAudit;
        facts=(display="$(contract.theorem) ASSUME clauses re-evaluated on the attached input: $(summary)",),
        replay=x -> begin
            for hypothesis in contract.hypotheses
                status, detail = hypothesis.check(x, params)
                status == FAIL && return CheckResult(false, :hypothesis_violated;
                                                     location=hypothesis.name, expected=PASS, actual=detail)
            end
            CheckResult(true, :hypothesis_violated; location=contract.name)
        end)
    (Tuple(nodes), audit)
end

# ---------------------------------------------------------------------------
# Level rules (DD-21) and the stage interface.

"thm:introspection: V^intro is 5-level for every ell (gt-08:788-790)."
introspect_levels(ell::Integer) = 5
"thm:ar: V^ar is max{ell + 2, 5}-level (gt-10:2085)."
answer_reduce_levels(ell::Integer) = max(ell + 2, 5)
"thm:repetition: V^rep is (ell + 2)-level (gt-11:252)."
repeat_levels(ell::Integer) = ell + 2
"thm:compression: V^compr is 9-level (gt-12:30)."
const COMPRESS_LEVELS = 9

abstract type CompressStage end
"Introspect as a CITED stub (TB6 replaces it)."
struct IntrospectStub <: CompressStage end
"Repeat as a CITED stub (TB5 replaces it)."
struct RepeatStub <: CompressStage end

"""
    FrontEndFixture

The executable front end of a quoted decider: its trace at fuel T, the
padded decoupled 5SAT, and TB0's PCP proof with the front-end certificate in
`build_pcp`'s upstream-evidence slot. `sigma = |D|` is the decider's
canonical byte length, carried EXPLICITLY (verdicts/tb3-r2.md N12): the
upstream slot authenticates a front end that generates the formula, not the
program, so sigma is never read off a certificate node.
"""
struct FrontEndFixture
    quoted::Checked
    input::Tuple
    T::Int
    padded::Checked
    pcp::NamedTuple
    params::PCPParams
    sigma::Int
end

function frontend_fixture(decider::Program=TRIVIAL_DECIDER; T::Int=1,
                          input::Tuple=(1, Bool[], Bool[], Bool[true], Bool[false]),
                          F::Type=GF8, d::Int=6, budget::MonomialBudget=MonomialBudget(160_000),
                          params::PCPParams=PCPParams(2048, 11, 1, 11, 6, 16, 1),
                          nondegenerate::Bool=false)
    decider_input_sorted(input) || throw(ArgumentError("a decider input is (n : Nat, x y a b : Bits)"))
    quoted = quote_program(decider; sort=:Decider)
    trace = bounded_trace(quoted, input, T)
    padded = pad5(decouple5(cook_levin(trace)))
    tables = frontend_witness_tables(padded.term; nondegenerate)
    pcp = frontend_pcp(padded, F, d, tables, budget, tb0_certified_points(F))
    pcp isa ExpansionRefused && throw(ArgumentError("front-end fixture refused: $(pcp)"))
    FrontEndFixture(quoted, input, T, padded, pcp, params, description_size(quoted.term))
end

"AnswerReduce whose executable part runs on a front-end fixture standing in for the CITED introspective decider."
struct AnswerReduceOnFixture <: CompressStage
    fixture::FrontEndFixture
end

struct CompressStages{I<:CompressStage,A<:CompressStage,R<:CompressStage}
    introspect::I
    answer_reduce::A
    repeat::R
end

"The TB4 stage table: two CITED stubs around the fixture-backed answer reduction."
tb4_stages(fixture::FrontEndFixture=frontend_fixture()) =
    CompressStages(IntrospectStub(), AnswerReduceOnFixture(fixture), RepeatStub())

"Evidence carried by the AnswerReduce output: the fixture, TB2's typed verifier, its CITED detyping, and sigma."
struct AnswerReduceEvidence
    fixture::FrontEndFixture
    typed::Checked
    detyped::Checked
    sigma::Int
end

const _UNSTATED = Opaque("unstated in the theorem statement", ())
const _C_PRIME = "universal constant c' > 0 of thm:repetition (value unexposed)"

# --- Introspect ------------------------------------------------------------

function Introspect(::IntrospectStub, checked::Union{Checked,_VERIFIER_INPUT}, lambda::Integer, ell::Integer;
                    params::NamedTuple=(;))
    input, input_cert = _split(checked)
    lambda >= 1 || throw(ArgumentError("lambda must be positive"))
    levels = introspect_levels(ell)
    sampler_time = bind_parameter(Opaque("poly(n, lambda, ell)", (:n, :lambda, :ell)), :ell => ell)
    decider_time = bind_parameter(Opaque("poly(2^(lambda*n), ell)", (:n, :lambda, :ell)), :ell => ell)
    description = bind_parameter(Opaque("poly(lambda, ell)", (:lambda, :ell)), :ell => ell)
    gap = (Opaque("completeness: value-1 PCC strategy of V_{2^n} => value-1 PCC strategy of V^intro_n", ()),
           Opaque("soundness: val*(V^intro_n) > 1 - eps => val*(V_{2^n}) >= 1 - delta(eps, n)", ()))
    output = StubVerifier(:Introspect, levels, sampler_time, decider_time, description,
                          _UNSTATED, _UNSTATED, gap, (:lambda, :ell), input, nothing)
    hypotheses, audit = _audit(INTROSPECT_CONTRACT, input, (; lambda, ell))
    node = CertNode(CONSTRUCTED, :Introspect;
        facts=(display="CITED stub (TB6 replaces this stage behind the CompressStage interface); level = 5 for every ell (ell = $(ell)); TIME_S = $(sampler_time.description); TIME_D = $(decider_time.description); |D^intro| = $(description.description); sampler depends on (lambda, ell)",),
        children=(hypotheses..., _relocate(audit, x -> x.input), _cited_leaf(INTROSPECT_CONTRACT),
                  _relocate(input_cert, x -> x.input)))
    Checked(output, node)
end

Introspect(checked::Union{Checked,_VERIFIER_INPUT}, lambda::Integer, ell::Integer) =
    Introspect(IntrospectStub(), checked, lambda, ell)

# --- AnswerReduce ------------------------------------------------------------

function AnswerReduce(stage::AnswerReduceOnFixture, checked::Union{Checked,_VERIFIER_INPUT},
                      lambda::Integer, mu::Integer, gamma::Integer; params::NamedTuple=(;))
    input, input_cert = _split(checked)
    fixture = stage.fixture
    sigma = fixture.sigma
    original = trivial_original_verifier(GF2048, fixture.params, fixture.pcp.tf;
                                         n=2, T=fixture.T, Q_len=1, sigma, label=:tb4_fixture)
    typed = answer_reduce_pcp(original, lambda, mu, gamma)
    detyped = detype(typed)
    ell = _levels(input)
    levels = answer_reduce_levels(ell)
    time = bind_parameter(Opaque("poly((lambda*n)^mu, |D|, gamma)", (:n, :lambda, :mu, :D_size, :gamma)),
                :mu => mu, :gamma => gamma, :D_size => _description_bound(input))
    description = bind_parameter(Opaque("poly(|D|, lambda, mu, gamma) (ComputeAnsVerifier runs in polynomial time)",
                              (:D_size, :lambda, :mu, :gamma)),
                       :mu => mu, :gamma => gamma, :D_size => _description_bound(input))
    dependencies = Tuple(unique((_sampler_dependencies(input)..., :lambda, :mu, :gamma, :D1_size)))
    gap = (Opaque("completeness: value-1 PCC strategy of V_n => value-1 SPCC strategy of V^ar_n", ()),
           Opaque("soundness: val*(V^ar_n) > 1 - eps => val*(V_n) >= 1 - delta(eps, n)", ()))
    output = StubVerifier(:AnswerReduce, levels, time, time, description, _UNSTATED, _UNSTATED, gap,
                          dependencies, input, AnswerReduceEvidence(fixture, typed, detyped, sigma))
    hypotheses, audit = _audit(ANSWER_REDUCE_CONTRACT, input, (; lambda, mu, gamma))
    p = fixture.params
    # verdicts/tb4-r1.md O10: the surrogate disclosure is the PARENT of the
    # fixture evidence it qualifies (TB2's detyped verifier and the PCP
    # subtree), so no consumer can attribute those CHECKED nodes to the
    # stage's own input.
    surrogate = CertNode(ASSUMED, :AnswerReduceSurrogate;
        facts=(display="executable part built on the front-end fixture decider (|D| = $(sigma) bytes, fnv1a64 = $(quote_hash(fixture.quoted.term)), T = $(fixture.T)), not on the CITED introspective decider; sigma = $(sigma) passed explicitly (verdicts/tb3-r2.md N12); PCP row (q,k,m,d,s,m') = ($(p.q),$(p.k),$(p.m),$(p.d),$(p.s),$(p.m_prime)); level here = max($(ell) + 2, 5) with the fixture's typed level $(level(typed.term.sampler)); every CHECKED node below is about the fixture",),
        children=(_relocate(detyped.certificate, x -> x.payload.typed.term),
                  _relocate(fixture.pcp.certificate, x -> x.payload.fixture.pcp.proof)))
    node = CertNode(CONSTRUCTED, :AnswerReduce;
        facts=(display="detype o answer_reduce_pcp; level max(ell + 2, 5) = max($(ell) + 2, 5) = $(levels); TIME_S = TIME_D = $(time.description); |D^ar| = $(description.description); sampler depends on $(join(String.(dependencies), ", "))",),
        children=(hypotheses..., _relocate(audit, x -> x.input), _cited_leaf(ANSWER_REDUCE_CONTRACT),
                  surrogate,
                  _relocate(input_cert, x -> x.input)))
    Checked(output, node)
end

AnswerReduce(checked::Union{Checked,_VERIFIER_INPUT}, lambda::Integer, mu::Integer, gamma::Integer;
             fixture::FrontEndFixture=frontend_fixture()) =
    AnswerReduce(AnswerReduceOnFixture(fixture), checked, lambda, mu, gamma)

# --- Repeat ------------------------------------------------------------------

function Repeat(::RepeatStub, checked::Union{Checked,_VERIFIER_INPUT}, lambda::Integer, tau::Integer;
                params::NamedTuple=(;))
    input, input_cert = _split(checked)
    ell = _levels(input)
    levels = repeat_levels(ell)
    k = "k(n) = (lambda*n)^((1+c')*tau)"
    sampler_time = bind_parameter(Opaque("O(k(n) * TIME_S(n)), $(k)", (:n, :lambda, :tau, :c_prime, :TIME_S)),
                        :tau => tau, :c_prime => _C_PRIME, :TIME_S => _sampler_time(input))
    decider_time = bind_parameter(Opaque("O(k(n) * max(TIME_D(n), (lambda*n)^tau)), $(k)",
                               (:n, :lambda, :tau, :c_prime, :TIME_D)),
                        :tau => tau, :c_prime => _C_PRIME, :TIME_D => _decider_time(input))
    description = bind_parameter(Opaque("poly(|D|, lambda, tau) (ComputeParrepVerifier runs in polynomial time)",
                              (:D_size, :lambda, :tau)),
                       :tau => tau, :D_size => _description_bound(input))
    dependencies = Tuple(unique((_sampler_dependencies(input)..., :lambda, :tau)))
    gap = (Opaque("completeness: value-1 PCC strategy of V_n and TIME_D(n) <= (lambda n)^tau => value-1 PCC strategy of V^rep_n", ()),
           Opaque("soundness: Ent(V^rep_n, p) >= Ent(V_n, 1 - eps) for p > (4/eps) exp(-c eps^17 k(n)/(lambda n)^(tau c'))", ()))
    output = StubVerifier(:Repeat, levels, sampler_time, decider_time, description, _UNSTATED,
                          _UNSTATED, gap, dependencies, input, nothing)
    hypotheses, audit = _audit(REPEAT_CONTRACT, input, (; lambda, tau))
    node = CertNode(CONSTRUCTED, :Repeat;
        facts=(display="CITED stub (TB5 replaces this stage behind the CompressStage interface); level ell + 2 = $(ell) + 2 = $(levels); TIME_S = $(sampler_time.description); TIME_D = $(decider_time.description); sampler depends on $(join(String.(dependencies), ", "))",),
        children=(hypotheses..., _relocate(audit, x -> x.input), _cited_leaf(REPEAT_CONTRACT),
                  _relocate(input_cert, x -> x.input)))
    Checked(output, node)
end

Repeat(checked::Union{Checked,_VERIFIER_INPUT}, lambda::Integer, tau::Integer) =
    Repeat(RepeatStub(), checked, lambda, tau)

# --- Compress ----------------------------------------------------------------

"The levels of V, V^(1), V^(2), V^(3) along a Compress output's input chain."
function level_chain(v::AbstractStageVerifier)
    stages = _chain(v)
    Int[_levels(stages[1].input); (s.levels for s in stages if s.origin != :Compress)...]
end

const _COMPRESS_FREE = (:n, :lambda)
const _INDEPENDENCE_ALLOWED = (:lambda, :ell, :mu, :gamma, :tau, :D1_size)

"Every runtime bound along the chain closes to free parameters within {n, lambda}, and Compress reports poly(n, lambda)."
function runtime_composition_ok(v::AbstractStageVerifier)
    v.origin == :Compress || return false
    stages = _chain(v)
    length(stages) == 4 || return false
    bounds = (v.sampler_time, v.decider_time, stages[3].sampler_time, stages[3].decider_time)
    all(issubset(free_parameters(b), _COMPRESS_FREE) for b in bounds) &&
        v.sampler_time == Opaque("poly(n, lambda)", _COMPRESS_FREE) &&
        v.decider_time == Opaque("poly(n, lambda)", _COMPRESS_FREE) &&
        all(free_parameters(stages[i].sampler_time) == free_parameters(stages[i].decider_time) == _COMPRESS_FREE
            for i in 1:3)
end

function _level_chain_ok(v::AbstractStageVerifier)
    stages = _chain(v)
    length(stages) == 4 || return false
    origins = [s.origin for s in stages]
    origins == [:Introspect, :AnswerReduce, :Repeat, :Compress] || return false
    ell0 = _levels(stages[1].input)
    expected = [ell0, introspect_levels(COMPRESS_LEVELS), answer_reduce_levels(introspect_levels(COMPRESS_LEVELS)),
                repeat_levels(answer_reduce_levels(introspect_levels(COMPRESS_LEVELS)))]
    level_chain(v) == expected && expected[end] == COMPRESS_LEVELS && v.levels == COMPRESS_LEVELS
end

"""
    Compress(V, lambda; stages=tb4_stages(), mu=1, gamma=1, tau=1) :: Checked{StubVerifier, CertNode}

fig:compress (gt-12-compression.tex:75-98): V^(1) = Introspect(V, lambda, 9),
V^(2) = AnswerReduce(V^(1), lambda, mu, gamma), V^(3) = Repeat(V^(2), lambda,
tau); return V^(3) as the 9-level compressed verifier. mu, gamma, tau are
universal constants (eq:mu-gamma, eq:c_rep); here toy literals (DESIGN 12.4).
"""
function Compress(checked::Union{Checked,_VERIFIER_INPUT}, lambda::Integer;
                  stages::CompressStages=tb4_stages(), mu::Integer=1, gamma::Integer=1, tau::Integer=1,
                  stage_params::NamedTuple=(;))
    input, _ = _split(checked)
    lambda >= 1 || throw(ArgumentError("lambda must be positive"))
    v1 = Introspect(stages.introspect, checked, lambda, COMPRESS_LEVELS; params=stage_params)
    v2 = AnswerReduce(stages.answer_reduce, v1, lambda, mu, gamma; params=stage_params)
    v3 = Repeat(stages.repeat, v2, lambda, tau; params=stage_params)
    time = Opaque("poly(n, lambda)", _COMPRESS_FREE)
    gap = (Opaque("completeness: value-1 PCC strategy of V_N => value-1 PCC strategy of V^compr_n, N = 2^n, n >= C_0", ()),
           Opaque("soundness: Ent(V^compr_n, 1/2) >= max{Ent(V_N, 1/2), 2^(N^lambda - 1)}", ()))
    output = StubVerifier(:Compress, COMPRESS_LEVELS, time, time, v3.term.description,
                          v3.term.question_length, v3.term.answer_length, gap,
                          v3.term.sampler_dependencies, v3.term, nothing)
    hypotheses, audit = _audit(COMPRESS_CONTRACT, input, (; lambda))
    chain = CertNode(CHECKED, :LevelChain;
        facts=(display="$(join(level_chain(output), " -> ")) by introspect_levels(9) = 5, answer_reduce_levels(5) = max(5 + 2, 5) = 7, repeat_levels(7) = 9; order Introspect, AnswerReduce, Repeat (fig:compress)",),
        replay=x -> CheckResult(_level_chain_ok(x), :level_chain; location=:LevelChain,
                                expected=[_levels(input), 5, 7, 9], actual=level_chain(x)))
    composition = CertNode(CHECKED, :RuntimeComposition;
        facts=(display="V^(3): TIME_S free parameters = $(free_parameters(v3.term.sampler_time)), TIME_D free parameters = $(free_parameters(v3.term.decider_time)) after binding ell = 9, mu = $(mu), gamma = $(gamma), tau = $(tau), c', |D1|; Compress reports TIME_S = TIME_D = $(time.description)",),
        replay=x -> CheckResult(runtime_composition_ok(x), :runtime_composition; location=:RuntimeComposition,
                                expected=_COMPRESS_FREE,
                                actual=(free_parameters(x.input.sampler_time), free_parameters(x.input.decider_time))))
    independence = CertNode(CHECKED, :SamplerIndependence;
        facts=(display="S^compr depends on $(join(String.(output.sampler_dependencies), ", ")) and on nothing of V's content; allowed = $(join(String.(_INDEPENDENCE_ALLOWED), ", "))",),
        replay=x -> CheckResult(issubset(x.sampler_dependencies, _INDEPENDENCE_ALLOWED) &&
                                !any(d in x.sampler_dependencies for d in (:S, :D, :V)),
                                :sampler_independence; location=:SamplerIndependence,
                                expected=_INDEPENDENCE_ALLOWED, actual=x.sampler_dependencies))
    fixed_width = CertNode(SOURCE_REPAIR, :IntroDeciderFixedWidth;
        facts=(display="the lemma's step '|D^(1)| is determined by lambda' uses a polynomial upper bound, not equal lengths, while thm:ar makes S^ar depend on |D^(1)| (DESIGN 12.3); |D1| stays a named dependency here",))
    constants = CertNode(ASSUMED, :ToyUniversalConstants;
        facts=(display="mu = $(mu), gamma = $(gamma), tau = $(tau) are toy literals (DESIGN 12.4), not the eq:mu-gamma (gt-12:263-271) / eq:c_rep (gt-12:347-359) values; ell = 9 is fig:compress's",))
    node = CertNode(CONSTRUCTED, :Compress;
        facts=(display="Repeat o AnswerReduce o Introspect in the order Introspect, AnswerReduce, Repeat (fig:compress, gt-12:75-98); level chain $(join(level_chain(output), " -> ")); TIME_S = TIME_D = $(time.description); lambda = $(lambda)",),
        children=(chain, composition, independence, fixed_width, constants, hypotheses...,
                  _relocate(audit, _original), _cited_leaf(COMPRESS_CONTRACT),
                  _cited_leaf(INDEPENDENT_SAMPLERS_LEMMA),
                  _relocate(v3.certificate, x -> x.input)))
    Checked(output, node)
end

Base.show(io::IO, v::StubVerifier) =
    print(io, "StubVerifier(", v.origin, ", levels=", v.levels, ")")
