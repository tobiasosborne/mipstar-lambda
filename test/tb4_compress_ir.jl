using Test
using MIPStarLambda
Base.Experimental.@optlevel 0

# TB4: the Compress skeleton with ASSUME/PROVE contracts, Hole/Specialize,
# and the quoted fixed point D_{M,lambda} = Fix(Psi_{M,lambda})
# (briefs/24-tb4.md with addenda; DESIGN.md sections 1.1, 1.6, 2, 3, 5.6).
# Everything below runs on the two-state machines and the TB3 trivial
# front-end fixture; no theorem stub is executed (DESIGN 5.6).

const TB4_TARGET = get(ENV, "TB4_TARGET", "all")
tb4_runs(name) = TB4_TARGET == "all" || TB4_TARGET == name
const TB4_CACHE = Dict{Symbol,Any}()
const TB4_LAMBDA = 1024
const TB4_ROOT = normpath(joinpath(@__DIR__, ".."))

# Budget gate (verdicts/tb4-r1.md O13; tb1-r5 N33): the 5 s TB4 body budget
# of briefs/24-tb4.md is enforced as a clock-calibrated RATIO, not a wall
# clock. A fixed GF(8) kernel is timed in-process here, before any testset;
# at the end of a whole-file run the body wall divided by that calibration
# must stay below TB4_RATIO = 42, set once from quiet performance-governor
# runs (brief 72): the kernel measures 0.14 s standalone and 0.18 s inside
# the suite, the body 5.9 s in-suite (ratio 32), so 42 is the revised 6 s
# budget of DESIGN 5.6 at the standalone kernel rate. An optional
# TB4_BUDGET_SECONDS adds a plain wall bound and never loosens the gate.
function tb4_calibration_kernel()
    acc = zero(GF8)
    for _ in 1:20_000, a in field_elements(GF8), b in field_elements(GF8), c in field_elements(GF8)
        acc += a * b + c
    end
    acc
end
tb4_calibration_kernel()
const TB4_CALIBRATION = @elapsed tb4_calibration_kernel()
const TB4_RATIO = 42.0
const TB4_BODY_STARTED = time()

tb4_input(n::Int) = (n, Bool[], Bool[], Bool[true], Bool[false])

# The fixture verifier V = (S_lambda, D_{M,lambda}) for the halting two-state
# machine, and its Compress output; built once per process.
tb4_verifier() = get!(TB4_CACHE, :verifier) do
    halting_verifier(TWO_STATE_HALTING, TB4_LAMBDA)
end
tb4_compressed() = get!(TB4_CACHE, :compressed) do
    Compress(tb4_verifier(), TB4_LAMBDA)
end

# Tree helpers: every node with a rule, in preorder; relabel one node.
function tb4_nodes(node::CertNode, found=CertNode[])
    push!(found, node)
    foreach(child -> tb4_nodes(child, found), node.children)
    found
end
tb4_rules(node) = [n.rule for n in tb4_nodes(node)]
tb4_find(node, rule::Symbol) = [n for n in tb4_nodes(node) if n.rule == rule]
function tb4_relabel(node::CertNode, rule::Symbol, grade::Grade)
    children = Tuple(tb4_relabel(child, rule, grade) for child in node.children)
    CertNode(node.rule == rule ? grade : node.grade, node.rule;
             facts=node.facts, children, replay=node.replay)
end
tb4_first_lines(path) = readlines(joinpath(TB4_ROOT, "ground-truth", path))

if tb4_runs("tb4_specialize")
    @testset "TB4 (a) Hole/Specialize: closed Quoted with a SubstCert; capture-freedom" begin
        template = psi_template()
        # lambda occurs twice (the Compress argument and the FuelBound), so
        # the template is closed by substitute, never by the affine specialize.
        @test holes(template) == Dict(:machine => 1, :lambda => 2, :self_code => 1)
        @test !is_closed(template)
        # The materialised unfolding Specialize(P, {self_code -> d_P}) of
        # thm:ycode: every hole closed by `specialize`, a closed Quoted with
        # the SubstCert (size law) that replays.
        d = halting_decider(TWO_STATE_HALTING, nat(TB4_LAMBDA))
        unfolded = fix_unfolding(TWO_STATE_HALTING, nat(TB4_LAMBDA))
        @test unfolded.term isa Quoted{:Decider} && is_closed(decode_program(unfolded.term))
        @test unfolded.certificate.rule == :Specialize && unfolded.certificate.grade == CHECKED
        @test passed(verify_certificate(unfolded))
        @test description_size(unfolded.term) ==
              description_size(d.term) - FIX_TAG_BYTES - term_size(Hole(:self_code, :Decider)) +
              term_size(Quote(decode_program(d.term), :Decider))
        # Host-side specialization contract (DESIGN 1.1): machine and lambda
        # closed by substitute, self_code tied by Fix, then quote_program;
        # the CHECKED :Specialize node replays the size law with c_fix = 5.
        @test d.term isa Quoted{:Decider}
        @test d.certificate.rule == :Specialize && d.certificate.grade == CHECKED
        @test d.certificate.children[1].rule == :Quote
        @test passed(verify_certificate(d))
        @test FIX_TAG_BYTES == 5
        expected = term_size(template) - term_size(Hole(:machine, :MachineDesc)) -
                   2 * term_size(Hole(:lambda, :Nat)) + term_size(TWO_STATE_HALTING) +
                   2 * term_size(nat(TB4_LAMBDA)) + FIX_TAG_BYTES
        @test term_size(decode_program(d.term)) == expected
        @test occursin("c_fix = 5", d.certificate.facts.display)
        # A specialization certificate is bound to its own object: the
        # looping machine's quoted decider is refused by the halting one's.
        d_loop = halting_decider(TWO_STATE_LOOPING, nat(TB4_LAMBDA))
        refused = verify_certificate(Checked(d_loop.term, d.certificate))
        @test !passed(refused)
        # A hole under a binder: the inserted closed term keeps its own
        # binder (de Bruijn indices are not shifted), so applying the result
        # to 5 and then 7 returns the INNER argument 7, never the outer 5.
        outer = Lambda(1, Hole(:h, :Program))
        filled = specialize(outer, (:h => Lambda(1, BoundVar(0, 0)),); sort=:Program)
        @test program_equal(decode_program(filled.term), Lambda(1, Lambda(1, BoundVar(0, 0))))
        applied = eval_program(Apply(Apply(decode_program(filled.term), (nat(5),)), (nat(7),)), (), 20)
        @test applied.result isa Value && applied.result.value == 7
        # A capturing substitution would have produced BoundVar(1, 0).
        captured = Lambda(1, Lambda(1, BoundVar(1, 0)))
        @test eval_program(Apply(Apply(captured, (nat(5),)), (nat(7),)), (), 20).result.value == 5
        # specialize refuses to bind self_code under Fix and refuses an
        # environment that leaves a hole open.
        @test_throws ArgumentError specialize(Fix(substitute(template,
            Dict{Symbol,Program}(:machine => TWO_STATE_HALTING, :lambda => nat(3)))),
            (:self_code => Quote(decode_program(d.term)),); sort=:Decider)
        @test_throws ArgumentError specialize(template, (:machine => TWO_STATE_HALTING,); sort=:Decider)
        # verdicts/tb4-r1.md O14: the guard capture-freedom rests on -- an
        # OPEN replacement is refused -- and specialize's CHECKED :Specialize
        # node is bound to its own Quoted (a byte-identical Quoted built by a
        # second call is refused as borrowed) and recomputes the term.
        @test_throws ArgumentError specialize(outer, (:h => BoundVar(0, 0),); sort=:Program)
        twin = specialize(outer, (:h => Lambda(1, BoundVar(0, 0)),); sort=:Program)
        @test twin.term.bytes == filled.term.bytes && twin.term !== filled.term
        @test passed(verify_certificate(filled)) && passed(verify_certificate(twin))
        borrowed = verify_certificate(Checked(twin.term, filled.certificate))
        @test !passed(borrowed) && borrowed.rule == :certificate_binding && borrowed.location == :Specialize
        @test filled.certificate.replay(filled.term).rule == :specialize_size_law
        println("TB4 specialize: |Psi template| = ", term_size(template), " bytes; |D_{M,lambda}| = ",
                description_size(d.term), " bytes; |unfolded| = ", description_size(unfolded.term),
                " bytes; hash = ", quote_hash(d.term))
    end
end

if tb4_runs("tb4_ycode")
    @testset "TB4 (b) YCode: eval(Fix P, u; f) = eval(P[self_code -> Quote(Fix P)], u; f - c_Y); Fix, not Julia recursion" begin
        template = psi_template()
        fixed_point(machine) = begin
            body = substitute(template, Dict{Symbol,Program}(:machine => machine, :lambda => nat(TB4_LAMBDA)))
            (body, YCode(body), decode_program(fix_unfolding(machine, nat(TB4_LAMBDA)).term))
        end
        body, y, unfolded = fixed_point(TWO_STATE_HALTING)
        # Term inspection: the fixed point is the Fix constructor over the
        # body, closed, of sort Decider, and |YCode(P)| = |P| + c_fix.
        @test y isa Fix && !(y isa Function)
        @test program_equal(y.body, body) && y.sort == :Decider
        @test is_closed(y) && holes(body) == Dict(:self_code => 1)
        @test term_size(y) == term_size(body) + FIX_TAG_BYTES
        @test program_equal(decode_term(term_bytes(y)), y)
        @test program_equal(unfolded, substitute(body, Dict{Symbol,Program}(:self_code => Quote(y, :Decider))))
        # thm:ycode at every fuel from c_Y past termination, on both
        # branches at n = 2 (the halting machine halts in two steps; the
        # looping one takes the compressed branch under 2^lambda, clamped):
        # outcome for outcome, with the left side using exactly c_Y = 3
        # more units. (n = 1 is excluded by def:lambda's footnote: 1^lambda
        # = 1 unit cannot run the compressed decider -- OutOfFuel.)
        for machine in (TWO_STATE_HALTING, TWO_STATE_LOOPING)
            _, y_m, unfolded_m = fixed_point(machine)
            u = tb4_input(2)
            terminal = eval_program(y_m, u, 10_000)
            @test terminal.result isa Value && terminal.result.value === true
            agree = true
            for f in FIX_UNFOLD_CHARGE:(terminal.used + 3)
                left = eval_program(y_m, u, f)
                right = eval_program(unfolded_m, u, f - FIX_UNFOLD_CHARGE)
                agree &= typeof(left.result) == typeof(right.result)
                agree &= (left.result isa Value ? left.result.value == right.result.value : true)
                agree &= left.used == right.used + FIX_UNFOLD_CHARGE
            end
            @test agree
            # Same-fuel form: both terminate from the halting fuel onwards.
            same_fuel = eval_program(unfolded_m, u, terminal.used)
            @test same_fuel.result isa Value && same_fuel.result.value === true &&
                  same_fuel.used == terminal.used - FIX_UNFOLD_CHARGE
        end
        @test FIX_UNFOLD_CHARGE == 3
        # Halting branch: Fix 3 + closure 1 + beta 1 + M 1 + n 1 +
        # halts_within (1 + 2 steps) 3 + If 1 + true 1 = 12.
        @test eval_program(y, tb4_input(2), 100).used == 12
        # The tiny fixture Fix(self_code : Program) terminates at every fuel
        # <= 6 from c_Y + 1 on: eval gives the code of the fixed point.
        tiny = YCode(Hole(:self_code, :Program))
        for f in 4:6
            left = eval_program(tiny, (), f)
            right = eval_program(Quote(tiny, :Program), (), f - FIX_UNFOLD_CHARGE)
            @test left.result isa Value && right.result isa Value &&
                  program_equal(left.result.value.program, right.result.value.program)
            @test left.used == 4 && right.used == 1
        end
        @test eval_program(tiny, (), 3).result isa OutOfFuel
        # The identity compressor: the compressed branch of the LOOPING
        # machine re-enters D_{M,lambda} through its own quote under
        # FuelBound(n, lambda) and ends in OutOfFuel at the declared
        # budget -- description-level self-reference, never Julia recursion
        # (DESIGN 12.6).
        d_self = halting_decider(TWO_STATE_LOOPING, nat(TB4_LAMBDA); compress=COMPRESS_IDENTITY)
        looping = eval_quoted(d_self.term, tb4_input(2), 5_000; hard_cap=100_000)
        @test looping.result isa OutOfFuel && looping.used == 5_000
        halting_self = eval_quoted(halting_decider(TWO_STATE_HALTING, nat(TB4_LAMBDA);
                                                   compress=COMPRESS_IDENTITY).term, tb4_input(2), 5_000)
        @test halting_self.result isa Value && halting_self.result.value === true
        @test eval_program(y, tb4_input(1), 10_000).result isa OutOfFuel
        # verdicts/tb4-r1.md O3: the "compressed branch" above is the
        # evaluation of the inlined COMPRESS_STUB -- the constant
        # (pair, lambda) -> Quote(lambda n x y a b . true), 46 of the 376
        # term bytes -- not of any compressor; the verifier's certificate
        # discloses it as [ASSUMED] CompressStubInTerm.
        _, y_loop, _ = fixed_point(TWO_STATE_LOOPING)
        @test program_equal(y_loop.body.body.else_branch.code.head, COMPRESS_STUB)
        stub_pair = Prim(:quoted_pair, Concrete(1), (Quote(SAMPLER_STUB, :Sampler), Quote(y_loop, :Decider)))
        stub_value = eval_program(Apply(COMPRESS_STUB, (stub_pair, nat(TB4_LAMBDA))), (), 50)
        @test stub_value.result isa Value && stub_value.result.value == Code(TRIVIAL_DECIDER, :Decider)
        @test term_size(COMPRESS_STUB) == 46 && term_size(y_loop) == 376
        stub_nodes = tb4_find(tb4_verifier().certificate, :CompressStubInTerm)
        @test length(stub_nodes) == 1 && stub_nodes[1].grade == ASSUMED
        @test occursin("COMPRESS_STUB", stub_nodes[1].facts.display) &&
              occursin("46 of 376", stub_nodes[1].facts.display) &&
              occursin("constant", stub_nodes[1].facts.display) &&
              occursin("COMPRESS_IDENTITY", stub_nodes[1].facts.display)
        println("TB4 ycode: halting branch used 12; compressed branch (looping machine) used ",
                eval_program(fixed_point(TWO_STATE_LOOPING)[2], tb4_input(2), 10_000).used,
                "; identity-compressor loop => OutOfFuel(", looping.used, ")")
    end
end

if tb4_runs("tb4_psi")
    @testset "TB4 (c) Psi_{M,lambda} is well-sorted; D_{M,lambda} has an exact description_size" begin
        template = psi_template()
        body = substitute(template, Dict{Symbol,Program}(:machine => TWO_STATE_HALTING,
                                                          :lambda => nat(TB4_LAMBDA)))
        # The displayed term of DESIGN 1.1: Lambda(5, If(halts_within, true,
        # Eval(Apply(Compress, quoted_pair(Quote(S), self_code), lambda), (n,x,y,a,b), FuelBound(n, lambda)))).
        @test body isa Lambda && body.arity == DECIDER_ARITY
        cond = body.body
        @test cond isa If && cond.condition isa Prim && cond.condition.name == :halts_within
        @test program_equal(cond.condition.args[1], TWO_STATE_HALTING) && cond.condition.args[2] == BoundVar(0, 0)
        @test program_equal(cond.then_branch, Prim(true, Concrete(1), ()))
        ev = cond.else_branch
        @test ev isa Eval && ev.args == ntuple(i -> BoundVar(0, i - 1), 5)
        @test ev.fuel isa FuelBound && ev.fuel.n == BoundVar(0, 0) && program_equal(ev.fuel.lambda, nat(TB4_LAMBDA))
        @test ev.code isa Apply && program_equal(ev.code.head, COMPRESS_STUB)
        pair = ev.code.args[1]
        @test pair isa Prim && pair.name == :quoted_pair && program_equal(pair.args[1], Quote(SAMPLER_STUB, :Sampler))
        @test pair.args[2] == Hole(:self_code, :Decider)
        @test program_equal(ev.code.args[2], nat(TB4_LAMBDA))
        # Sorts (N17, R9, R10): the literals have their declared sorts, the
        # Compressor is a two-argument closed Lambda (not a code value:
        # Apply(Quote(Compress), ...) would be SortError(:apply_non_closure)),
        # Level is declared, and the decider input is value-sorted.
        @test quote_program(TWO_STATE_HALTING; sort=:MachineDesc).term isa Quoted{:MachineDesc}
        @test quote_program(nat(TB4_LAMBDA); sort=:Nat).term isa Quoted{:Nat}
        @test quote_program(nat(9); sort=:Level).term isa Quoted{:Level}
        @test :Level in DECLARED_SORTS
        @test_throws ArgumentError quote_program(nat(0); sort=:Level)
        @test_throws ArgumentError quote_program(Prim(true, Concrete(1), ()); sort=:Level)
        @test quote_program(COMPRESS_STUB; sort=:Compressor).term isa Quoted{:Compressor}
        @test quote_program(SAMPLER_STUB; sort=:Sampler).term isa Quoted{:Sampler}
        closed_pair = Prim(:quoted_pair, Concrete(1), (Quote(SAMPLER_STUB, :Sampler), Quote(TRIVIAL_DECIDER, :Decider)))
        @test eval_program(Apply(Quote(COMPRESS_STUB, :Compressor), (closed_pair, nat(3))), (), 50).result ==
              SortError(:apply_non_closure)
        @test eval_program(Apply(COMPRESS_STUB, (closed_pair, nat(3))), (), 50).result.value == Code(TRIVIAL_DECIDER, :Decider)
        @test DECIDER_ARGUMENT_SORTS == (:Nat, :Bits, :Bits, :Bits, :Bits)
        @test decider_input_sorted(tb4_input(2))
        @test !decider_input_sorted((true, Bool[], Bool[], Bool[true], Bool[false]))
        @test !decider_input_sorted((2, Bool[], Bool[], Bool[true]))
        d = YCode(body)
        @test MIPStarLambda._admits_sort(d, :Decider) && !MIPStarLambda._admits_sort(d, :Compressor)
        # Exact description size from canonical bytes: header, sort, term.
        q = quote_program(d; sort=:Decider).term
        @test description_size(q) == length(canonical_bytes(q))
        @test description_size(q) == 1 + 4 + sizeof("Decider") + term_size(d)
        @test description_size(q) == description_size(halting_decider(TWO_STATE_HALTING, nat(TB4_LAMBDA)).term)
        @test program_equal(decode_program(q), d)
        # The embedded self_code, once unfolded, quotes D itself: the quote
        # hash of the inner code equals the outer hash (DESIGN 12.6 item 2).
        inner = MIPStarLambda._fix_unfold(d)
        inner_quote = inner.body.else_branch.code.args[1].args[2]
        @test inner_quote isa Quote && quote_hash(quote_program(inner_quote.code; sort=:Decider).term) == quote_hash(q)
        # The verifier carrier: V = (S_lambda, D_{M,lambda}) with |V| = max.
        v = tb4_verifier()
        @test v.term isa Verifier && v.term.levels == 9
        @test description_length(v.term) == max(description_size(v.term.sampler), description_size(v.term.decider))
        @test description_length(v.term) == description_size(q) && description_length(v.term) <= TB4_LAMBDA
        @test passed(verify_certificate(v))
        @test tb4_rules(v.certificate) == [:Verifier, :Quote, :Specialize, :Quote, :HaltDeciderFuelBound,
                                           :CompressStubInTerm]
        # verdicts/tb4-r1.md O4: the outer Eval's FuelBound(n, lambda) is a
        # construction change against fig:halt_f step 5 (no budget there;
        # TIME <= n^lambda is lem:lambda's conclusion), disclosed as a
        # SOURCE_REPAIR under :Specialize, and the verifier's runtime bound
        # says the budget is enforced, not measured.
        repair = tb4_find(v.certificate, :HaltDeciderFuelBound)
        @test length(repair) == 1 && repair[1].grade == SOURCE_REPAIR
        @test occursin("gt-12-compression.tex:L451-L453", repair[1].facts.display) &&
              occursin("lem:lambda", repair[1].facts.display) &&
              occursin("OutOfFuel", repair[1].facts.display)
        @test v.certificate.children[2].rule == :Specialize &&
              any(n -> n.rule == :HaltDeciderFuelBound, v.certificate.children[2].children)
        @test occursin("enforced by construction, not measured", v.term.runtime.description)
        @test occursin("HaltDeciderFuelBound", v.term.runtime.description)
        println("TB4 psi: |D_{M,lambda}| = ", description_size(q), " bytes; |S_lambda| = ",
                description_size(v.term.sampler), " bytes; |V| = ", description_length(v.term),
                "; hash = ", quote_hash(q))
    end
end

if tb4_runs("tb4_compress")
    @testset "TB4 (d) Compress(V, lambda): 9-level StubVerifier; CHECKED Quote/Specialize/PCP; exactly named CITED leaves" begin
        compressed = tb4_compressed()
        @test compressed isa Checked{StubVerifier}
        out = compressed.term
        @test out.origin == :Compress && out.levels == 9
        root = compressed.certificate
        rules = tb4_rules(root)
        @test root.rule == :Compress && root.grade == CONSTRUCTED
        # Composition order fig:compress: Introspect, AnswerReduce, Repeat.
        @test out.input.origin == :Repeat && out.input.input.origin == :AnswerReduce &&
              out.input.input.input.origin == :Introspect && out.input.input.input.input isa Verifier
        @test level_chain(out) == [9, 5, 7, 9]
        @test occursin("Introspect, AnswerReduce, Repeat", root.facts.display)
        # CHECKED program/specialization nodes of the input verifier.
        @test any(n -> n.rule == :Quote && n.grade == CHECKED, tb4_nodes(root))
        @test any(n -> n.rule == :Specialize && n.grade == CHECKED, tb4_nodes(root))
        # The CHECKED PCP subtree from TB0/TB3 through the real answer_reduce
        # path: build_pcp's certificate (with the front end's UpstreamEvidence
        # chain down to its Quote) and TB2's TypedAnswerReduce.
        for rule in (:PCPProof, :UpstreamEvidence, :Pad5, :Decouple5, :CookLevin, :BoundedTrace,
                     :Tseitin, :PCPVerifier, :TypedAnswerReduce, :AnswerReduceSamplerProduct)
            @test any(n -> n.rule == rule && n.grade == CHECKED, tb4_nodes(root))
        end
        @test any(n -> n.rule == :Detype && n.grade == CITED, tb4_nodes(root))
        @test any(n -> n.rule == :AnswerReduceSurrogate && n.grade == ASSUMED, tb4_nodes(root))
        # verdicts/tb4-r1.md O10: the surrogate disclosure is the PARENT of
        # the fixture evidence it qualifies -- every PCP/front-end/TB2 node
        # under :AnswerReduce is a descendant of [ASSUMED] AnswerReduceSurrogate.
        surrogate = only(tb4_find(root, :AnswerReduceSurrogate))
        under = tb4_nodes(surrogate)
        @test length(surrogate.children) == 2
        for rule in (:PCPProof, :UpstreamEvidence, :Pad5, :Decouple5, :CookLevin, :BoundedTrace,
                     :Tseitin, :PCPVerifier, :TypedAnswerReduce, :AnswerReduceSamplerProduct, :Detype)
            @test count(n -> n.rule == rule, under) >= 1
            @test count(n -> n.rule == rule, under) == count(n -> n.rule == rule, tb4_nodes(root))
        end
        # verdicts/tb4-r1.md O8: the front end's Tseitin reproduction is a
        # build-time CONSTRUCTED child of the identity-anchored
        # :UpstreamEvidence, not part of its CHECKED content.
        upstream = only(tb4_find(root, :UpstreamEvidence))
        @test any(c -> c.rule == :UpstreamReproduction && c.grade == CONSTRUCTED, upstream.children)
        @test occursin("build-time", only(tb4_find(root, :UpstreamReproduction)).facts.display)
        # Exactly named CITED leaves with ground-truth line ranges that
        # exist: the test greps the label inside the cited range.
        leaves = Dict{Symbol,CertNode}()
        for label in (Symbol("thm:introspection"), Symbol("thm:ar"), Symbol("thm:repetition"),
                      Symbol("thm:compression"), Symbol("lem:compress-independent-samplers"))
            found = tb4_find(root, label)
            @test length(found) == 1
            leaf = found[1]
            @test leaf.grade == CITED && isempty(leaf.children) && leaf.replay === nothing
            lines = tb4_first_lines(leaf.facts.source)
            range = leaf.facts.lines
            @test first(range) >= 1 && last(range) <= length(lines)
            @test any(occursin("\\label{$(String(label))}", lines[i]) for i in range)
            @test occursin("$(leaf.facts.source):L$(first(range))-L$(last(range))", leaf.facts.display)
            leaves[label] = leaf
        end
        @test leaves[Symbol("thm:introspection")].facts.source == "gt-08-introspection.tex"
        @test leaves[Symbol("thm:ar")].facts.source == "gt-10-answer-reduction.tex"
        @test leaves[Symbol("thm:repetition")].facts.source == "gt-11-parallel-repetition.tex"
        @test leaves[Symbol("thm:compression")].facts.source == "gt-12-compression.tex"
        # verdicts/tb4-r1.md O11: every CITED node that carries a locatable
        # citation (source, lines, label) is grepped the same way -- the TB2
        # :Detype and :Oracularization leaves included.
        located = [n for n in tb4_nodes(root) if n.grade == CITED && haskey(n.facts, :source) &&
                   haskey(n.facts, :lines) && haskey(n.facts, :label)]
        @test issubset(Set([:Detype, :Oracularization, keys(leaves)...]), Set(n.rule for n in located))
        for leaf in located
            lines = tb4_first_lines(leaf.facts.source)
            range = leaf.facts.lines
            @test first(range) >= 1 && last(range) <= length(lines)
            @test any(occursin("\\label{$(leaf.facts.label)}", lines[i]) for i in range)
            @test occursin("$(leaf.facts.source):L$(first(range))-L$(last(range))", leaf.facts.display)
        end
        @test only(tb4_find(root, :Detype)).facts.label == "lem:detyping-verifiers"
        @test only(tb4_find(root, :Oracularization)).facts.source == "gt-09-oracularization.tex"
        # Every CITED node has no replay; every CHECKED node has one.
        @test all(n.replay === nothing for n in tb4_nodes(root) if n.grade == CITED)
        @test all(n.replay !== nothing for n in tb4_nodes(root) if n.grade == CHECKED)
        @test passed(verify_certificate(compressed))
        # sigma = |D| is passed explicitly to the answer-reduction contract
        # (verdicts/tb3-r2.md N12): it is the fixture decider's canonical
        # byte length, and the typed decider carries that very number.
        ar = out.input.input
        @test ar.payload.sigma == description_size(ar.payload.fixture.quoted.term)
        @test ar.payload.typed.term.decider.sigma == ar.payload.sigma
        @test ar.payload.sigma == 33
        @test occursin("sigma = 33", tb4_find(root, :AnswerReduceSurrogate)[1].facts.display)
        # The toy universal constants are visible.
        @test any(n -> n.rule == :ToyUniversalConstants && n.grade == ASSUMED, tb4_nodes(root))
        # The sampler-description independence bookkeeping: the output
        # sampler depends on lambda, the universal constants and |D1| only.
        @test any(n -> n.rule == :SamplerIndependence && n.grade == CHECKED, tb4_nodes(root))
        @test any(n -> n.rule == :IntroDeciderFixedWidth && n.grade == SOURCE_REPAIR, tb4_nodes(root))
        @test issubset(out.sampler_dependencies, (:lambda, :ell, :mu, :gamma, :tau, :D1_size))
        @test :lambda in out.sampler_dependencies
        println("TB4 compress: nodes = ", length(rules), "; grades = ",
                join(("$(g)=$(count(n -> n.grade == g, tb4_nodes(root)))" for g in instances(Grade)), ", "))
        traceprint(stdout, root)
    end
end

if tb4_runs("tb4_hypotheses")
    @testset "TB4 (e) contracts are ASSUME/PROVE objects: a violated hypothesis is a node, never a silent PASS" begin
        # |V| > lambda: the lambda-boundedness hypothesis of thm:introspection
        # fails (description length exceeds 7 bytes) and the certificate
        # says so; verify_certificate refuses it.
        small = halting_verifier(TWO_STATE_HALTING, 7)
        @test description_length(small.term) > 7
        intro = Introspect(small, 7, 9)
        @test intro isa Checked{StubVerifier} && intro.term.levels == 5
        violated = [n for n in tb4_nodes(intro.certificate)
                    if n.grade == ASSUMED && haskey(n.facts, :status) && n.facts.status == FAIL]
        @test length(violated) == 1 && violated[1].rule == :lambda_bounded_description
        @test occursin("FAIL", violated[1].facts.display)
        refused = verify_certificate(intro)
        @test !passed(refused) && refused.rule == :hypothesis_violated &&
              refused.location == :lambda_bounded_description
        # The hypothesis list is the theorem's: three ASSUME clauses, the
        # time bound not evaluable on an Opaque runtime.
        statuses = Dict(n.rule => n.facts.status for n in tb4_nodes(intro.certificate)
                        if n.grade == ASSUMED && haskey(n.facts, :status))
        @test statuses[:lambda_bounded_description] == FAIL
        @test statuses[:lambda_bounded_time] == NOT_EVALUABLE
        @test statuses[:ell_level] == PASS
        @test length(INTROSPECT_CONTRACT.hypotheses) == 3
        # verdicts/tb4-r1.md O7: thm:introspection's 5-level result and its
        # three complexity bounds are unconditional (gt-08:789-797); only
        # completeness/soundness/entanglement need the lambda-bounded
        # ell-level hypothesis (gt-08:801-803), so every Introspect
        # hypothesis is scoped exactly as Compress's are.
        @test all(startswith(h.statement, "(completeness/soundness only)") for h in INTROSPECT_CONTRACT.hypotheses)
        @test all(startswith(h.statement, "(completeness/soundness only)") for h in COMPRESS_CONTRACT.hypotheses)
        # Wrong level: a 9-level V handed to Introspect(V, lambda, 5).
        wrong_level = Introspect(tb4_verifier(), TB4_LAMBDA, 5)
        @test !passed(verify_certificate(wrong_level))
        @test verify_certificate(wrong_level).location == :ell_level
        # The fixture satisfies every checkable hypothesis.
        good = Introspect(tb4_verifier(), TB4_LAMBDA, 9)
        @test passed(verify_certificate(good))
        # verdicts/tb4-r1.md O4: the fixture's time hypothesis quotes the
        # enforced budget as such, never as a measured runtime.
        @test occursin("enforced by construction, not measured",
                       only(n for n in tb4_nodes(good.certificate) if n.rule == :lambda_bounded_time).facts.display)
        @test all(n.facts.status != FAIL for n in tb4_nodes(good.certificate)
                  if n.grade == ASSUMED && haskey(n.facts, :status))
        # A concrete runtime is checked against n^lambda from n = 2 (a
        # constant c <= 2^lambda) on the 33-byte trivial decider, lambda = 40.
        tiny_d = quote_program(TRIVIAL_DECIDER; sort=:Decider).term
        s = tb4_verifier().term.sampler
        gap = tb4_verifier().term.gap
        @test description_size(tiny_d) == 33
        fast = Verifier(s, tiny_d, Concrete(0), Concrete(1), Concrete(1 << 40), gap, 9)
        @test passed(verify_certificate(Introspect(Checked(fast, CertNode(CONSTRUCTED, :Verifier)), 40, 9)))
        too_slow = Verifier(s, tiny_d, Concrete(0), Concrete(1), Concrete((1 << 40) + 1), gap, 9)
        @test verify_certificate(Introspect(Checked(too_slow, CertNode(CONSTRUCTED, :Verifier)), 40, 9)).location ==
              :lambda_bounded_time
        # Compress on the small-lambda verifier propagates the violation.
        bad = Compress(small, 7)
        @test !passed(verify_certificate(bad)) && verify_certificate(bad).rule == :hypothesis_violated
        # Every contract names its theorem, source and hypotheses.
        for contract in (INTROSPECT_CONTRACT, ANSWER_REDUCE_CONTRACT, REPEAT_CONTRACT, COMPRESS_CONTRACT)
            @test !isempty(contract.hypotheses) && !isempty(contract.conclusions)
            @test all(h -> !isempty(h.source), contract.hypotheses)
        end
        @test ANSWER_REDUCE_CONTRACT.theorem == Symbol("thm:ar")
        @test REPEAT_CONTRACT.theorem == Symbol("thm:repetition")
        @test COMPRESS_CONTRACT.theorem == Symbol("thm:compression")
        # verdicts/tb4-r1.md O12: every hypothesis source of the form
        # `gt-NN-*.tex:La-Lb (label[, label])` contains each named \label
        # inside its own range (enu:pr-completeness is at gt-11:239).
        cited_hypotheses = 0
        for contract in (INTROSPECT_CONTRACT, ANSWER_REDUCE_CONTRACT, REPEAT_CONTRACT, COMPRESS_CONTRACT),
            h in contract.hypotheses
            m = match(r"^(gt-[^:]+\.tex):L(\d+)-L(\d+) \((.+)\)$", h.source)
            @test m !== nothing
            lines = tb4_first_lines(m[1])
            range = parse(Int, m[2]):parse(Int, m[3])
            @test first(range) >= 1 && last(range) <= length(lines)
            for label in split(m[4], ", ")
                occursin(':', label) || continue   # a prose locator, not a \label
                cited_hypotheses += 1
                @test any(occursin("\\label{$(label)}", lines[i]) for i in range)
            end
        end
        @test cited_hypotheses >= 12
        @test occursin("L239-L243 (enu:pr-completeness)", REPEAT_CONTRACT.hypotheses[2].source)
    end
end

if tb4_runs("tb4_levels")
    @testset "TB4 (f) level and runtime bookkeeping composed per the theorems" begin
        # thm:introspection: 5 for every ell; thm:ar: max(ell + 2, 5);
        # thm:repetition: ell + 2; thm:compression: 9.
        @test all(introspect_levels(ell) == 5 for ell in 1:12)
        @test [answer_reduce_levels(ell) for ell in 1:7] == [5, 5, 5, 6, 7, 8, 9]
        @test [repeat_levels(ell) for ell in 1:7] == [3, 4, 5, 6, 7, 8, 9]
        @test COMPRESS_LEVELS == 9
        @test repeat_levels(answer_reduce_levels(introspect_levels(9))) == 9
        # A 5-level result handed directly to Repeat is 7-level, not 9.
        intro = Introspect(tb4_verifier(), TB4_LAMBDA, 9)
        @test Repeat(intro, TB4_LAMBDA, 1).term.levels == 7
        out = tb4_compressed().term
        @test level_chain(out) == [9, 5, 7, 9]
        @test out.levels == 9 && out.input.levels == 9 && out.input.input.levels == 7 &&
              out.input.input.input.levels == 5
        # Runtimes: the theorem's bound at each stage, composed by binding
        # the universal constants and |D1|; the final free parameters are
        # exactly {n, lambda}, and Compress reports poly(n, lambda).
        v1, v2, v3 = out.input.input.input, out.input.input, out.input
        @test startswith(v1.sampler_time.description, "poly(n, lambda, ell)") &&
              startswith(v1.decider_time.description, "poly(2^(lambda*n), ell)")
        @test startswith(v1.description.description, "poly(lambda, ell)") && occursin("[ell = 9]", v1.description.description)
        @test free_parameters(v1.sampler_time) == (:n, :lambda)
        @test startswith(v2.sampler_time.description, "poly((lambda*n)^mu, |D|, gamma)")
        @test occursin("|D| = poly(lambda, ell)", v2.sampler_time.description)
        @test free_parameters(v2.sampler_time) == (:n, :lambda) && free_parameters(v2.decider_time) == (:n, :lambda)
        @test startswith(v3.sampler_time.description, "O(k(n) * TIME_S(n))")
        @test occursin("k(n) = (lambda*n)^((1+c')*tau)", v3.sampler_time.description)
        @test startswith(v3.decider_time.description, "O(k(n) * max(TIME_D(n), (lambda*n)^tau))")
        @test free_parameters(v3.sampler_time) == (:n, :lambda) && free_parameters(v3.decider_time) == (:n, :lambda)
        @test out.sampler_time == Opaque("poly(n, lambda)", (:n, :lambda))
        @test out.decider_time == Opaque("poly(n, lambda)", (:n, :lambda))
        composition = tb4_find(tb4_compressed().certificate, :RuntimeComposition)
        @test length(composition) == 1 && composition[1].grade == CHECKED
        @test passed(composition[1].replay(out))
        chain = tb4_find(tb4_compressed().certificate, :LevelChain)
        @test length(chain) == 1 && chain[1].grade == CHECKED && passed(chain[1].replay(out))
        # verdicts/tb4-r1.md O1: the origin-order conjunct is the whole
        # content of :LevelChain -- a hand-built Introspect -> Repeat ->
        # AnswerReduce chain has the SAME levels 9 -> 5 -> 7 -> 9 (both rules
        # map 5 to 7) and must be refused by the node's replay.
        fixture = out.input.input.payload.fixture
        stage = AnswerReduceOnFixture(fixture)
        w1 = Introspect(tb4_verifier(), TB4_LAMBDA, 9)
        w2 = Repeat(w1, TB4_LAMBDA, 1)
        w3 = AnswerReduce(stage, w2, TB4_LAMBDA, 1, 1)
        swapped = StubVerifier(out; input=w3.term)
        @test level_chain(swapped) == [9, 5, 7, 9]
        @test [s.origin for s in MIPStarLambda._chain(swapped)] == [:Introspect, :Repeat, :AnswerReduce, :Compress]
        @test !MIPStarLambda._level_chain_ok(swapped)
        refused = chain[1].replay(swapped)
        @test !passed(refused) && refused.rule == :level_chain && refused.actual == [9, 5, 7, 9]
        # verdicts/tb4-r1.md O2: fig:compress's literal ell = 9
        # (ComputeIntroVerifier(V, lambda, 9), gt-12:79-80) is what Compress
        # hands Introspect, not the input's own level: compressing a 5-level
        # verifier records `levels = 5, ell = 9 => FAIL` at ell_level.
        v9 = tb4_verifier().term
        five = Verifier(v9.sampler, v9.decider, v9.question_length, v9.answer_length, v9.runtime, v9.gap, 5)
        @test five.levels == 5
        five_out = Compress(Checked(five, CertNode(CONSTRUCTED, :Verifier)), TB4_LAMBDA;
                            stages=CompressStages(IntrospectStub(), stage, RepeatStub()))
        ell_node = only(tb4_find(five_out.certificate, :ell_level))
        @test ell_node.facts.status == FAIL
        @test occursin("levels = 5, ell = 9 => FAIL", ell_node.facts.display)
        @test level_chain(five_out.term) == [5, 5, 7, 9]
        @test verify_certificate(five_out).location == :nine_level
        # An unbound universal constant is a composition failure.
        @test free_parameters(bind_parameter(Opaque("poly(x, mu)", (:x, :mu)), :mu => 1)) == (:x,)
        @test bind_parameter(Opaque("poly(x, mu)", (:x, :mu)), :mu => 1).description == "poly(x, mu) [mu = 1]"
        @test free_parameters(bind_parameter(Opaque("f(|D|)", (:D_size,)), :D_size => Opaque("poly(lambda)", (:lambda,)))) == (:lambda,)
        @test !runtime_composition_ok(StubVerifier(out; sampler_time=Opaque("poly(n, lambda, mu)", (:n, :lambda, :mu))))
        @test runtime_composition_ok(out)
    end
end

if tb4_runs("tb4_two_verifiers")
    @testset "TB4 (h) two byte-distinct inputs at one lambda: the traces differ only at the input decider's Quote (verdicts/tb4-r1.md O9)" begin
        # DESIGN 12.3's byte/hash form of sampler independence needs sampler
        # bytes, which TB4's StubVerifier output has none of (TB5's S^rep
        # carries that check). The form TB4 supports: Compress of the
        # halting and the looping machine at lambda = 1024 -- byte-distinct
        # D_{M,lambda} of equal size -- yields certificates whose traceprints
        # differ in exactly one line, the input decider's Quote hash, and
        # identical dependency symbols.
        halting = tb4_compressed()
        fixture = halting.term.input.input.payload.fixture
        stages = CompressStages(IntrospectStub(), AnswerReduceOnFixture(fixture), RepeatStub())
        looping_v = halting_verifier(TWO_STATE_LOOPING, TB4_LAMBDA)
        @test canonical_bytes(looping_v.term.decider) != canonical_bytes(tb4_verifier().term.decider)
        @test description_length(looping_v.term) == description_length(tb4_verifier().term)
        looping = Compress(looping_v, TB4_LAMBDA; stages)
        a = split(sprint(traceprint, halting.certificate), '\n')
        b = split(sprint(traceprint, looping.certificate), '\n')
        @test length(a) == length(b) && length(a) > 60
        differing = [i for i in eachindex(a) if a[i] != b[i]]
        @test length(differing) == 1
        @test occursin("[CHECKED] Quote", a[differing[1]]) &&
              occursin(quote_hash(tb4_verifier().term.decider), a[differing[1]]) &&
              occursin(quote_hash(looping_v.term.decider), b[differing[1]])
        @test looping.term.sampler_dependencies == halting.term.sampler_dependencies
        @test passed(verify_certificate(looping))
        println("TB4 two verifiers: ", length(a), " trace lines each; differing lines = ", length(differing),
                " (the input decider's Quote: ", quote_hash(tb4_verifier().term.decider), " vs ",
                quote_hash(looping_v.term.decider), "); dependency symbols equal")
    end
end

if tb4_runs("tb4_relabel")
    @testset "TB4 (g) verify_certificate rejects a CITED leaf relabelled CHECKED" begin
        compressed = tb4_compressed()
        @test passed(verify_certificate(compressed))
        for label in (Symbol("thm:introspection"), Symbol("thm:ar"), Symbol("thm:repetition"),
                      Symbol("thm:compression"))
            relabelled = tb4_relabel(compressed.certificate, label, CHECKED)
            @test count(n -> n.rule == label && n.grade == CHECKED, tb4_nodes(relabelled)) == 1
            result = verify_certificate(Checked(compressed.term, relabelled))
            @test !passed(result) && result.rule == :certificate_replay && result.location == label
            @test result.expected == :replay && result.actual === nothing
        end
        # Relabelling a CHECKED node CITED is the opposite lie: the tree
        # still verifies (nothing is replayed there), which is why the
        # CHECKED count is asserted in (d).
        println("MUTATION_EXPECTED_RULE certificate_replay relabelled_cited_leaf_refused=true")
    end
end

# The budget is the IN-SUITE body (briefs/24-tb4.md section 4; the critic's
# 6.055 s was measured there): runtests.jl includes tb0_core.jl first, whose
# TB0_TARGET marks the warm suite process. A standalone `all` run is a
# cold-JIT run (7-13 s of compilation on this box) and prints ungated; the
# registry's `tb4_gate` target (empty body) owns the gate's mechanics.
const TB4_IN_SUITE = isdefined(Main, :TB0_TARGET)
if TB4_TARGET in ("all", "tb4_gate")
    tb4_elapsed = time() - TB4_BODY_STARTED
    tb4_ratio = tb4_elapsed / TB4_CALIBRATION
    tb4_wall_budget = haskey(ENV, "TB4_BUDGET_SECONDS") ? parse(Float64, ENV["TB4_BUDGET_SECONDS"]) : Inf
    println("TB4 test-body wall seconds = ", round(tb4_elapsed; digits=3), "; calibration kernel = ",
            round(TB4_CALIBRATION; digits=4), " s; ratio = ", round(tb4_ratio; digits=1),
            " (gate ", TB4_RATIO, "; TB4_BUDGET_SECONDS = ", tb4_wall_budget,
            TB4_IN_SUITE || TB4_TARGET == "tb4_gate" ? "; gated)" : "; ungated: standalone cold-JIT run)")
    if TB4_IN_SUITE || TB4_TARGET == "tb4_gate"
        @testset "TB4 budget gate: body / calibration kernel < $(TB4_RATIO) (tb1-r5 N33; verdicts/tb4-r1.md O13)" begin
            @test tb4_ratio < TB4_RATIO
            @test tb4_elapsed < tb4_wall_budget
        end
    end
end
