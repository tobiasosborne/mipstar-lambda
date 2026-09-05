using Test
using Random
using MIPStarLambda
Base.Experimental.@optlevel 0

# TB3: the quoted front end (briefs/23-tb3.md; DESIGN.md sections 1.1, 1.2,
# 2, 5.5). Program IR -> canonical bytes -> fuel-bounded CEK trace ->
# Cook-Levin 3SAT -> decoupled 5SAT -> padded circuit -> TB0's PCP builder
# -> TB2's typed answer-reduced decider, on GENERATED objects.

const TB3_TARGET = get(ENV, "TB3_TARGET", "all")
tb3_runs(name) = TB3_TARGET == "all" || TB3_TARGET == name

const TB3_PARAMS = PCPParams(2048, 11, 1, 11, 6, 16, 1)
# Decider input tuple (n, x, y, a, b) of def:decider (gt-05:613-622): n an
# index, x, y questions (empty here, Q_len = 0), a, b one-bit answers.
tb3_input(a::Bool, b::Bool) = (1, Bool[], Bool[], Bool[a], Bool[b])
const TB3_INPUT = tb3_input(true, false)
const TB3_CACHE = Dict{Symbol,Any}()

tb3_true() = Prim(:true, Concrete(1), ())
tb3_false() = Prim(:false, Concrete(1), ())
# lambda n x y a b . true (DESIGN 5.5): slots 0..4 of the argument frame.
tb3_trivial() = Lambda(5, tb3_true())
# lambda n x y a b . (a == b): the two-argument equality decider.
tb3_equality() = Lambda(5, Prim(:eq, Concrete(1), (BoundVar(0, 3), BoundVar(0, 4))))
# lambda n x y a b . true with an Opaque bound on the literal: T = 1, the same
# trace shape and padded relation as the trivial decider, but |D| = 45 and a
# different hash (N2's fixture B, lambda n x y a b . not(false) at T = 2, no
# longer pads to the same object: 2^m >= 2T now forces m = 2 for T = 2).
tb3_twin() = Lambda(5, Prim(true, Opaque("one step", ()), ()))
tb3_not_false() = Lambda(5, Prim(:not, Concrete(1), (tb3_false(),)))
tb3_nat(n::Int) = Prim(n, Concrete(1), ())
tb3_bits(s::String) = Prim(Bool[c == '1' for c in s], Concrete(1), ())
# MachineDesc literals (src/ir/programs.jl `_is_machine_desc`): entry
# (state, symbol) at bit offset 4(2s+b) = (write, right?, next_hi, next_lo),
# next >= S halts. M_3 walks 0 -> 1 -> 2 -> halt in exactly three steps;
# M_loop (DESIGN 12.6) never leaves state 0.
tb3_machine_halt3() = tb3_bits("1101" * "0100" * "1110" * "0100" * "1111" * "0100")
tb3_machine_loop() = tb3_bits("0100" * "0100" * "0100" * "0100")

function tb3_pipeline(decider::Program, T::Int, key::Symbol)
    get!(TB3_CACHE, key) do
        quoted = quote_program(decider; sort=:Decider)
        trace = bounded_trace(quoted, TB3_INPUT, T)
        sat3 = cook_levin(trace)
        sat5 = decouple5(sat3)
        padded = pad5(sat5)
        (; quoted, trace, sat3, sat5, padded)
    end
end

tb3_trivial_pipeline() = tb3_pipeline(tb3_trivial(), 1, :trivial)

# All 2^M assignments of a 3SAT formula (0-based variable order).
tb3_assignments(f) = [[isodd(code >> (i - 1)) for i in 1:f.variable_count]
                      for code in 0:(1 << f.variable_count) - 1]
# All five-block witnesses (a, b, w1, w2, w3) of a decoupled relation.
function tb3_witnesses(d)
    sizes = ntuple(k -> 1 << d.index_widths[k], 5)
    total = sum(sizes)
    offsets = cumsum((0, sizes...))
    [ntuple(k -> [isodd(code >> (offsets[k] + i - 1)) for i in 1:sizes[k]], 5)
     for code in 0:(1 << total) - 1]
end

# Every clause tuple of the succinct relation, as (indices..., signs...).
function tb3_tuples(widths, sign_count)
    total = sum(widths) + sign_count
    [(let bits = [isodd(code >> (k - 1)) for k in 1:total]
          position = 0
          indices = ntuple(length(widths)) do block
              value = 0
              for k in 1:widths[block]
                  value |= Int(bits[position + k]) << (k - 1)
              end
              position += widths[block]
              value
          end
          signs = ntuple(k -> bits[position + k], sign_count)
          (indices, signs)
      end) for code in 0:(1 << total) - 1]
end

if tb3_runs("tb3_quote")
    @testset "TB3 (a) program IR: canonical bytes, exact size, closedness, closure refusal" begin
        trivial = tb3_trivial()
        quoted = quote_program(trivial; sort=:Decider)
        @test quoted.term isa Quoted{:Decider}
        bytes = canonical_bytes(quoted.term)
        # Same encoding family as src/samplers/cl.jl (header byte, then
        # tagged nodes with UInt32 big-endian integer fields): 0xC1 is a CL
        # description, 0xC2 a program description.
        @test bytes[1] == 0xC2
        @test description_size(quoted.term) == length(bytes)
        @test description_size(quoted.term) ==
              term_size(trivial) + 1 + 4 + sizeof("Decider")
        @test program_equal(decode_program(bytes), trivial)
        @test canonical_bytes(quote_program(decode_program(bytes); sort=:Decider).term) == bytes
        @test passed(verify_certificate(quoted))
        @test quoted.certificate.rule == :Quote && quoted.certificate.grade == CHECKED
        @test occursin("|D| = $(length(bytes)) bytes", quoted.certificate.facts.display)
        @test occursin(quote_hash(quoted.term), quoted.certificate.facts.display)

        # Every constructor round-trips through the term codec, holes and
        # opaque bounds included (term_bytes/decode_term work on open terms;
        # quote_program does not).
        gallery = (
            BoundVar(0, 4), Hole(:self_code, :Quoted), Lambda(2, BoundVar(0, 1)),
            Apply(Lambda(1, BoundVar(0, 0)), (Prim(3, Concrete(1), ()),)),
            Fix(Eval(Hole(:self_code, :Program), (), FuelLiteral(7))),
            If(tb3_true(), Prim(Bool[true, false], Concrete(1), ()), tb3_false()),
            Prim(:halts_within, Opaque("n steps", (:n,)), (Prim(1, Concrete(1), ()),)),
            Quote(tb3_trivial()),
            Eval(Quote(tb3_trivial()), (Prim(2, Concrete(1), ()),),
                 FuelBound(Prim(2, Concrete(1), ()), Prim(3, Concrete(1), ()))),
            Specialize(Quote(tb3_trivial()), (:flag => tb3_true(),)),
            tb3_equality())
        roundtrip_ok = true
        sizes = Int[]
        for term in gallery
            encoded = term_bytes(term)
            decoded = decode_term(encoded)
            roundtrip_ok &= program_equal(decoded, term)
            roundtrip_ok &= term_bytes(decoded) == encoded
            roundtrip_ok &= term_size(term) == length(encoded)
            push!(sizes, length(encoded))
        end
        @test roundtrip_ok
        @test length(Set(term_bytes(term) for term in gallery)) == length(gallery)
        @test_throws ArgumentError decode_program(bytes[1:end - 1])
        @test_throws ArgumentError decode_program(vcat(bytes, 0x00))

        # Closed(P): every BoundVar scoped, no Hole. Quote is a checked
        # constructor and refuses open terms; so does quote_program.
        @test_throws ArgumentError Quote(BoundVar(0, 0))
        @test_throws ArgumentError Quote(Lambda(1, BoundVar(1, 0)))
        @test_throws ArgumentError Quote(Lambda(1, BoundVar(0, 1)))
        @test_throws ArgumentError Quote(Lambda(5, Hole(:h, :Bit)))
        @test_throws ArgumentError quote_program(Hole(:h, :Bit))
        @test Quote(Lambda(1, BoundVar(0, 0)), :Sampler) isa Quote
        # Quote(code, sort) carries the A of Quoted{A} and checks it against
        # the term's shape: a one-argument Lambda is no Decider.
        @test_throws ArgumentError Quote(Lambda(1, BoundVar(0, 0)))
        @test_throws ArgumentError Quote(tb3_trivial(), :Undeclared)

        # Specialize: capture-free hole substitution with the exact size
        # identity |Specialize(P,s)| = |P| - sum|Hole| + sum|s(h)| (C16).
        partial = Lambda(5, If(Hole(:flag, :Bit), tb3_true(), tb3_false()))
        replacement = Prim(:not, Concrete(1), (tb3_false(),))
        specialized = specialize(partial, (:flag => replacement,))
        @test specialized.term isa Quoted
        @test passed(verify_certificate(specialized))
        @test description_size(specialized.term) - description_size(quoted.term) ==
              term_size(Lambda(5, If(replacement, tb3_true(), tb3_false()))) - term_size(trivial)
        @test term_size(program(specialized.term)) ==
              term_size(partial) - term_size(Hole(:flag, :Bit)) + term_size(replacement)
        @test_throws ArgumentError specialize(partial, ())
        @test_throws ArgumentError specialize(partial, (:flag => tb3_true(), :other => tb3_true()))
        @test_throws ArgumentError specialize(partial, (:flag => BoundVar(0, 0),))
        # The affine-hole discipline: a hole name occurs at most once.
        @test_throws ArgumentError specialize(
            If(Hole(:flag, :Bit), Hole(:flag, :Bit), tb3_true()), (:flag => tb3_true(),))
        # Fix binds self_code: it is never a specialization hole, and a Fix
        # body carries no other hole (constructor), so every other hole is
        # closed BEFORE Fix (host `substitute` of the open body, then
        # Fix/YCode, then quote_program); specialize(Fix(P), {}) is the
        # identity under the size law (DESIGN 1.1 contract note).
        open_body = Lambda(5, If(Hole(:flag, :Bit), tb3_true(),
                                 Eval(Hole(:self_code, :Decider), (), FuelLiteral(1))))
        @test_throws ArgumentError Fix(open_body)
        closed_fix = YCode(substitute(open_body, Dict{Symbol,Program}(:flag => tb3_true())))
        @test closed_fix isa Fix && is_closed(closed_fix)
        @test_throws ArgumentError specialize(closed_fix, (:self_code => Quote(closed_fix),))
        identity = specialize(closed_fix, ())
        @test program_equal(program(identity.term), closed_fix)
        @test passed(verify_certificate(identity))

        # A runtime closure is a value, never a description: bounded_trace
        # refuses it (DD-1) instead of tracing its body.
        closure = eval_program(trivial, (), 1).result.value
        @test closure isa Closure && closure.arity == 5
        @test_throws ArgumentError bounded_trace(closure, TB3_INPUT, 1)
        @test_throws ArgumentError bounded_trace(trivial, TB3_INPUT, 1)
        @test_throws ArgumentError quote_program(closure)
        println("TB3 quote: |D| = ", length(bytes), " bytes; hash = ",
                quote_hash(quoted.term), "; gallery sizes = ", sizes)
    end
end

if tb3_runs("tb3_eval")
    @testset "TB3 (b) fuel-bounded evaluation: total, monotone, Quote/Eval overhead" begin
        trivial = tb3_trivial()
        # eval(D, u; f): D applied to the five values with an application
        # continuation (analytic part2a 8.3); closure (1) + beta (1) +
        # Prim true (1) = 3 units exactly.
        direct = eval_program(trivial, TB3_INPUT, 3)
        @test direct.result isa Value && direct.result.value === true
        @test direct.used == 3
        @test eval_program(trivial, TB3_INPUT, 2).result isa OutOfFuel
        @test eval_program(trivial, TB3_INPUT, 0).result isa OutOfFuel
        # Fuel monotonicity: more fuel, same result, same usage.
        monotone_ok = true
        for extra in (0, 1, 5, 100)
            more = eval_program(trivial, TB3_INPUT, 3 + extra)
            monotone_ok &= more.result isa Value && more.result.value === true &&
                           more.used == 3
        end
        @test monotone_ok
        # SortError, never a host exception: apply a non-closure, wrong
        # arity, non-bit condition, absent address, residual hole.
        @test eval_program(Apply(tb3_true(), ()), (), 5).result isa SortError
        @test eval_program(Apply(Lambda(2, tb3_true()), (tb3_true(),)), (), 5).result isa SortError
        @test eval_program(If(Prim(3, Concrete(1), ()), tb3_true(), tb3_false()), (), 5).result isa SortError
        @test eval_program(Lambda(1, BoundVar(2, 0)), (true,), 5).result isa SortError
        @test eval_program(Lambda(1, Hole(:h, :Bit)), (true,), 5).result isa SortError
        @test eval_program(Prim(:nonsense, Concrete(1), ()), (), 5).result isa SortError
        # A declared Concrete bound below the primitive's charge is a
        # contract failure (SortError), not silently accepted.
        @test eval_program(Prim(:eq, Concrete(0), (tb3_true(), tb3_true())), (), 5).result isa SortError
        # Fix ties self_code to Quote(Fix(P)) (DESIGN 1.1): the term that
        # re-evaluates its own quote forever returns OutOfFuel under every
        # finite fuel, without a host exception, and within a hard step cap.
        loop = Fix(Eval(Hole(:self_code, :Program), (), FuelLiteral(4_000_000_000)))
        seconds = @elapsed looped = eval_program(loop, (), 300)
        println("MUTATION_EXPECTED_RULE fuel_bound looped=", typeof(looped.result),
                " starved=", typeof(eval_program(trivial, TB3_INPUT, 2).result))
        @test looped.result isa OutOfFuel
        @test looped.used == 300
        @test seconds < 5
        # Fix with a terminating body: the fixed point of the trivial body.
        fixed = Fix(Lambda(5, If(tb3_true(), tb3_true(), Eval(Hole(:self_code, :Decider), (), FuelLiteral(1)))))
        @test eval_program(fixed, TB3_INPUT, 10).result.value === true
        @test_throws ArgumentError Fix(tb3_true())
        # The unfolding charges c_Y = 3 exactly (part2a 8.3, C18): the fixed
        # point uses three units more than its self_code-substituted body.
        unfolded = substitute(fixed.body, Dict{Symbol,Program}(:self_code => Quote(fixed)))
        @test eval_program(fixed, TB3_INPUT, 10).used == eval_program(unfolded, TB3_INPUT, 10).used + 3
        @test eval_program(fixed, TB3_INPUT, 10).used == 8
        @test eval_program(fixed, TB3_INPUT, 7).result isa OutOfFuel
        # The host step cap is a guard outside the semantics: it must not
        # be below the fuel (DESIGN 1.1, verdicts/tb3-r1.md N9).
        @test_throws ArgumentError eval_program(trivial, TB3_INPUT, 3; hard_cap=2)
        # Quote/Eval equation with explicit overhead (C16, part2a Theorem
        # quote-eval): Eval_L(Quote(t), u; f + h(d,u)) = eval_L(t, u; f)
        # with h(d,u) = 3 + |d| + |enc(u)|, the left side using exactly
        # h(d,u) + c when the right side uses c <= f.
        quoted = quote_program(trivial; sort=:Decider).term
        overhead = eval_overhead(quoted, TB3_INPUT)
        @test overhead == 3 + description_size(quoted) + encoded_size(TB3_INPUT)
        via_quote = eval_quoted(quoted, TB3_INPUT, 3 + overhead)
        @test via_quote.result isa Value && via_quote.result.value === true
        @test via_quote.used == overhead + 3
        @test eval_quoted(quoted, TB3_INPUT, 2 + overhead).result isa OutOfFuel
        @test eval_quoted(quoted, TB3_INPUT, overhead - 1).result isa OutOfFuel
        # Eval as syntax: code, argument and fuel terms are evaluated first
        # (each literal costs its charge), then the delimiter is installed.
        literal_args = (Prim(1, Concrete(1), ()), Prim(Bool[], Concrete(1), ()),
                        Prim(Bool[], Concrete(1), ()), Prim(Bool[true], Concrete(1), ()),
                        Prim(Bool[false], Concrete(1), ()))
        syntax = Eval(Quote(trivial), literal_args, FuelLiteral(3))
        as_syntax = eval_program(syntax, (), 100)
        @test as_syntax.result isa Value && as_syntax.result.value === true
        @test as_syntax.used == 1 + 5 + overhead + 3
        @test eval_program(Eval(Quote(trivial), literal_args, FuelLiteral(2)), (), 100).result isa OutOfFuel
        # FuelBound(n, lambda) = n^lambda (definitions.md F).
        bound = Eval(Quote(trivial), literal_args,
                     FuelBound(Prim(2, Concrete(1), ()), Prim(2, Concrete(1), ())))
        @test eval_program(bound, (), 100).result.value === true
        @test eval_program(Eval(Quote(trivial), literal_args,
                                FuelBound(Prim(1, Concrete(1), ()), Prim(1, Concrete(1), ()))),
                           (), 100).result isa OutOfFuel
        # Equality decider on values.
        equality = tb3_equality()
        @test eval_program(equality, tb3_input(true, true), 5).result.value === true
        @test eval_program(equality, tb3_input(true, false), 5).result.value === false
        @test eval_program(equality, tb3_input(true, false), 5).used == 5
        @test eval_program(equality, tb3_input(true, false), 4).result isa OutOfFuel
        println("TB3 eval: trivial uses 3; overhead h(d,u) = ", overhead,
                "; equality uses 5; looping Fix OutOfFuel in ", round(seconds; digits=3), " s")
    end
end

if tb3_runs("tb3_trace")
    @testset "TB3 (c) bounded trace of lambda n x y a b . true at T = 1" begin
        pipeline = tb3_trivial_pipeline()
        trace = pipeline.trace
        term = trace.term
        @test term isa BoundedTrace
        @test term.T == 1
        @test term.accepts
        @test term.result isa Value && term.result.value === true
        # The explicit one-transition accepting trace: row 0 is the body at
        # fuel 1, row 1 the value true at fuel 0 (T + 1 rows, halting
        # self-loop pads longer budgets).
        rows = term.configurations
        @test length(rows) == 2
        @test rows[1].fuel == 1 && rows[1].outcome == :running
        @test occursin("Prim(true", rows[1].control)
        @test rows[2].fuel == 0 && rows[2].outcome == :accept
        @test occursin("true", rows[2].control)
        @test description_size(term.program) == description_size(pipeline.quoted.term)
        @test passed(verify_certificate(trace))
        @test trace.certificate.rule == :BoundedTrace
        @test trace.certificate.children[1].rule == :Quote
        @test occursin(quote_hash(pipeline.quoted.term), trace.certificate.facts.display)
        # Out of fuel at T = 0 is a rejecting trace, never an exception.
        starved = bounded_trace(pipeline.quoted, TB3_INPUT, 0).term
        @test !starved.accepts && starved.result isa OutOfFuel
        @test length(starved.configurations) == 1
        # Longer budgets pad with the halting self-loop.
        padded = bounded_trace(pipeline.quoted, TB3_INPUT, 4).term
        @test padded.accepts && length(padded.configurations) == 5
        @test all(row.outcome == :accept for row in padded.configurations[2:end])
        # The trace is replayed from the bytes: a trace whose stored
        # acceptance disagrees with its own rows is refused by the checker,
        # and the certificate (bound by identity to its own trace) refuses
        # the tampered copy outright.
        flipped = BoundedTrace(term.program, term.input, term.T, term.configurations,
                               term.result, !term.accepts)
        @test !passed(MIPStarLambda._replay_trace(flipped))
        tampered = verify_certificate(Checked(flipped, trace.certificate))
        @test !passed(tampered) && tampered.rule == :certificate_binding
        # The equality decider needs three body transitions (two lookups,
        # one primitive): T = 2 is out of fuel, T = 3 decides a == b.
        equality = quote_program(tb3_equality(); sort=:Decider)
        @test !bounded_trace(equality, tb3_input(true, true), 2).term.accepts
        @test bounded_trace(equality, tb3_input(true, true), 2).term.result isa OutOfFuel
        @test bounded_trace(equality, tb3_input(true, true), 3).term.accepts
        @test !bounded_trace(equality, tb3_input(true, false), 3).term.accepts
        # verdicts/tb3-r1.md N1: the row CONTENTS are pinned (the Cook-Levin
        # fields of each configuration of the equality run on (a,b) = (1,0)
        # at T = 3): control (program point 2 = Prim(eq), then the looked-up
        # values), the pending prim frame k1 with its evaluated values, the
        # fuel and the outcome flag.
        erows = bounded_trace(equality, TB3_INPUT, 3).term.configurations
        expected_rows = [
            ("Prim(eq)", 3, :running,
             [:control => (:point, 2), :outcome => :running]),
            ("Value([1])", 2, :running,
             [:control => (:value, (:bits, (true,))), :k1 => (:seq, :prim, (:point, 2), 0, 2),
              :outcome => :running]),
            ("Value([0])", 1, :running,
             [:control => (:value, (:bits, (false,))), :k1 => (:seq, :prim, (:point, 2), 1, 2),
              :k1v1 => (:bits, (true,)), :outcome => :running]),
            ("Value(false)", 0, :reject,
             [:control => (:value, (:bool, false)), :outcome => :reject])]
        println("MUTATION_EXPECTED_RULE trace_rows row1_control=", repr(erows[2].fields[1][2]),
                " row2_keys=", repr(first.(erows[3].fields)))
        @test length(erows) == 4
        rows_ok = true
        for (row, (control, fuel, outcome, fields)) in zip(erows, expected_rows)
            rows_ok &= row.control == control && row.fuel == fuel && row.outcome == outcome
            rows_ok &= first.(row.fields) == first.(fields) && row.fields == fields
        end
        @test rows_ok
        # The accepting run differs from the rejecting one only in the
        # looked-up b and the final value: same keys, same frames.
        arows = bounded_trace(equality, tb3_input(true, true), 3).term.configurations
        @test [first.(row.fields) for row in arows] == [first.(row.fields) for row in erows]
        @test arows[3].fields[1] == (:control => (:value, (:bits, (true,))))
        @test arows[4].fields == [:control => (:value, (:bool, true)), :outcome => :accept]
        println("TB3 trace: T=1 rows=", length(rows), " result=", term.result,
                " accepts=", term.accepts)
        for row in rows
            println("  row ", row.index, ": ", row.control, " fuel=", row.fuel,
                    " outcome=", row.outcome)
        end
    end
end

if tb3_runs("tb3_cook_levin")
    @testset "TB3 (d) Cook-Levin: succinct 3SAT satisfiable iff the trace accepts" begin
        pipeline = tb3_trivial_pipeline()
        sat3 = pipeline.sat3
        formula = sat3.term
        @test formula isa Succinct3SAT
        @test formula.index_width == 1
        @test formula.variable_count == 2
        # One retained variable (the final-row acceptance bit, index 1;
        # index 0 is padding) and one clause family (x_1 v * v *).
        @test length(formula.clauses) == 1
        @test formula.clauses[1].slots == ((1, true), nothing, nothing)
        @test formula.accept_variable == 1
        # def:succinct-formulas: C(i1,i2,i3,o1,o2,o3) = 1 iff the signed
        # clause is present; here iff i1 = 1 and o1 = 1 (don't-care family).
        exhaustive_ok = true
        present = 0
        for (indices, signs) in tb3_tuples((1, 1, 1), 3)
            expected = indices[1] == 1 && signs[1]
            actual = clause_present(formula, indices, signs)
            exhaustive_ok &= actual == expected
            exhaustive_ok &= evaluate_circuit(formula.circuit,
                                              relation_input(formula, indices, signs)) == expected
            present += actual
        end
        @test exhaustive_ok
        @test present == 16
        @test formula.circuit.gate_count == 1
        # Satisfiable exactly by the assignments with x_1 = 1 (2 of 4).
        @test satisfiable(formula)
        @test count(w -> satisfies(formula, w), tb3_assignments(formula)) == 2
        @test passed(verify_certificate(sat3))
        @test sat3.certificate.rule == :CookLevin
        @test any(child -> child.grade == CITED && child.rule == :CookLevinGeneral,
                  sat3.certificate.children)
        @test sat3.certificate.children[1].rule == :BoundedTrace
        # Trace/formula equivalence is replayed BEFORE any PCP object exists:
        # a trace whose acceptance flag was flipped with the formula unchanged
        # is refused with :trace_formula_equivalence.
        flipped_trace = BoundedTrace(pipeline.trace.term.program, pipeline.trace.term.input,
                                     pipeline.trace.term.T, pipeline.trace.term.configurations,
                                     pipeline.trace.term.result, false)
        flipped = Succinct3SAT(formula.variable_count, formula.index_width, formula.clauses,
                               formula.answer_variables, formula.accept_variable,
                               formula.circuit, flipped_trace, formula.tableau)
        refused = MIPStarLambda._replay_cook_levin(flipped)
        println("MUTATION_EXPECTED_RULE trace_formula_equivalence passed=", passed(refused),
                " rule=", refused.rule)
        @test !passed(refused) && refused.rule == :trace_formula_equivalence
        # The certificate is bound to its own formula: the tampered copy is
        # refused before any replay.
        tampered = verify_certificate(Checked(flipped, sat3.certificate))
        @test !passed(tampered) && tampered.rule == :certificate_binding
        # Descending certificates are bound by identity through the
        # constructor chain: the same trace certificate under a foreign
        # formula whose trace is a different object is refused.
        other = cook_levin(bounded_trace(pipeline.quoted, TB3_INPUT, 1))
        foreign = verify_certificate(Checked(other.term, sat3.certificate))
        @test !passed(foreign) && foreign.rule == :certificate_binding
        # Exhaustive over the answer inputs: satisfiable iff D accepts.
        equivalence_ok = true
        for a in (false, true), b in (false, true)
            accepts = bounded_trace(pipeline.quoted, tb3_input(a, b), 1).term.accepts
            equivalence_ok &= satisfiable(formula, tb3_input(a, b)) == accepts
        end
        @test equivalence_ok
        println("TB3 cook_levin: m=", formula.index_width, " M=", formula.variable_count,
                " clauses=", length(formula.clauses), " present tuples=", present,
                "/64 gates=", formula.circuit.gate_count,
                " eliminated=", formula.tableau.eliminated)
    end
end

if tb3_runs("tb3_decouple")
    @testset "TB3 (e) decoupled 5SAT: five index blocks, five signs, iff D accepts" begin
        pipeline = tb3_trivial_pipeline()
        sat5 = pipeline.sat5
        d5 = sat5.term
        @test d5 isa SuccinctDecoupled5SAT
        # DD-17: the general sort keeps five possibly unequal blocks (the
        # one-bit answers give N_1 = N_2 = 1, the u-blocks N = 2).
        @test d5.index_widths == (0, 0, 1, 1, 1)
        @test d5.sign_count == 5
        @test length(d5.clauses) == 1
        # The 3SAT clause's first literal lands in block 3 (u_3); blocks 1
        # and 2 (a, b) appear only in copy gadgets, of which there are none.
        @test d5.clauses[1].slots == (nothing, nothing, (1, true), nothing, nothing)
        @test d5.copy_gadgets == 0 && d5.equality_gadgets == 0
        println("MUTATION_EXPECTED_RULE decoupled_shape literal_blocks=",
                sort(collect(literal_blocks(d5))))
        @test literal_blocks(d5) == Set([3])
        @test passed(verify_certificate(sat5))
        @test sat5.certificate.rule == :Decouple5
        @test sat5.certificate.children[1].rule == :CookLevin
        # The guarantee (gt-10:920-979): (a,b,w1,w2,w3) satisfies phi_5 for
        # some w iff D accepts (n,x,y,a,b); exhaustive over a, b and w.
        guarantee_ok = true
        for a in (false, true), b in (false, true)
            accepts = bounded_trace(pipeline.quoted, tb3_input(a, b), 1).term.accepts
            exists = any(w -> satisfies5(d5, tb3_input(a, b), w), tb3_witnesses(d5))
            guarantee_ok &= exists == accepts
            guarantee_ok &= satisfiable5(d5, tb3_input(a, b)) == accepts
        end
        @test guarantee_ok
        # Padded form (prop:explicit-padded-succinct-deciders): equal m-bit
        # blocks, and gates padded so 5m + 5 + s is a power of two.
        padded = pipeline.padded
        p = padded.term
        @test p isa PaddedSuccinctDecoupled5SAT
        @test p.m == 1 && p.s == 6 && p.live_gates == 1 && p.m_prime == 16
        @test p.circuit.gate_count == 6
        @test length(p.circuit.input_layout.names) == 10
        @test [block.name for block in p.circuit.input_layout.blocks] == [:X1, :X2, :X3, :X4, :X5, :O]
        @test passed(verify_certificate(padded))
        @test padded.certificate.rule == :Pad5
        @test occursin("padding 5 dead NOT gates", padded.certificate.facts.display)
        @test occursin("2^m = 2 >= 2T = 2", padded.certificate.facts.display)
        # verdicts/tb3-r1.md N8: the omitted per-index equality gadgets are
        # an ASSUMED leaf of the decoupled certificate.
        @test any(child -> child.grade == ASSUMED && child.rule == :PerIndexEqualityGadgets,
                  sat5.certificate.children)
        @test any(child -> child.grade == ASSUMED && child.rule == :RawAnswerBlocks &&
                           occursin("2F reserved bits", child.facts.display),
                  sat5.certificate.children)
        # N7: obligation 1 of prop:explicit-padded-succinct-deciders, 2^m >=
        # 2T, is a construction step: the T = 2 trace of the trivial decider
        # (3 rows, one live variable) is padded to m = 2, not m = 1.
        wide = pad5(decouple5(cook_levin(bounded_trace(pipeline.quoted, TB3_INPUT, 2))))
        @test wide.term.m == 2 && (1 << wide.term.m) >= 4
        @test wide.term.live_gates == 3 && wide.term.s == 17 && wide.term.m_prime == 32
        @test passed(verify_certificate(wide))
        @test occursin("2^m = 4 >= 2T = 4", wide.certificate.facts.display)
        # N6: the gate budget is a refusal path, not a promise: every relation
        # compiler returns CompilationRefused with the counts when over budget.
        refusal = decouple5(pipeline.sat3; gate_budget=0)
        @test refusal isa CompilationRefused && refusal.gates == 1 && refusal.budget == 0
        @test cook_levin(pipeline.trace; gate_budget=0) isa CompilationRefused
        @test pad5(sat5; gate_budget=0) isa CompilationRefused
        # The padded relation on all 1024 signed index tuples equals the
        # decoupled relation, and its phi_C witnesses are exactly those with
        # u_3[1] = 1: 512 of 1024.
        relation_ok = true
        present = 0
        for (indices, signs) in tb3_tuples((1, 1, 1, 1, 1), 5)
            expected = clause_present5(d5, indices, signs)
            actual = evaluate_circuit(p.circuit, relation_input(p, indices, signs))
            relation_ok &= actual == expected
            present += actual
        end
        @test relation_ok
        @test present == 256
        satisfying = 0
        for code in 0:1023
            witness = ntuple(i -> [isodd(code >> (2i - 2)), isodd(code >> (2i - 1))], 5)
            satisfying += phi_C(p.circuit, witness)
        end
        @test satisfying == 512
        @test phi_C(p.circuit, ([false, false], [false, false], [false, true], [false, false], [false, false]))
        @test !phi_C(p.circuit, ([true, true], [true, true], [true, false], [true, true], [true, true]))
        # The equality decider: the decoupled formula is satisfiable exactly
        # when a == b, exhaustively over the four answer pairs.
        equality = tb3_pipeline(tb3_equality(), 3, :equality)
        e5 = equality.sat5.term
        @test e5.copy_gadgets > 0
        @test literal_blocks(e5) == Set([3, 4, 5])
        equality_ok = true
        for a in (false, true), b in (false, true)
            equality_ok &= satisfiable5(e5, tb3_input(a, b)) == (a == b)
            equality_ok &= satisfiable(equality.sat3.term, tb3_input(a, b)) == (a == b)
        end
        @test equality_ok
        @test passed(verify_certificate(equality.sat5))
        println("TB3 decouple5: widths=", d5.index_widths, " clauses=", length(d5.clauses),
                " padded m=", p.m, " s=", p.s, " (live ", p.live_gates, ") m'=", p.m_prime,
                " present=", present, "/1024 witnesses=", satisfying, "/1024")
    end
end

if tb3_runs("tb3_pcp")
    @testset "TB3 (f),(h) generated circuit through TB0's PCP builder and TB2's decider" begin
        pipeline = tb3_trivial_pipeline()
        padded = pipeline.padded
        circuit = padded.term.circuit
        # Witness (i)-analogue: only u_3 = [0,1]; witness (ii)-analogue: all
        # five blocks [0,1] (every g_i = X_i, non-constant).
        tables_i = ((0, 0), (0, 0), (0, 1), (0, 0), (0, 0))
        tables_ii = ((0, 1), (0, 1), (0, 1), (0, 1), (0, 1))
        @test frontend_witness_tables(padded.term; nondegenerate=false) == tables_i
        @test frontend_witness_tables(padded.term; nondegenerate=true) == tables_ii
        # TB0's own fixture builder on the GENERATED circuit.
        seconds_i = @elapsed plain = build_pcp_fixture(circuit, GF8, 6, tables_i,
                                                       MonomialBudget(160_000),
                                                       tb0_certified_points(GF8))
        @test !(plain isa ExpansionRefused)
        @test passed(verify_certificate(Checked(plain.proof, plain.certificate)))
        # The front-end pipeline grafted onto the same TB0 functions: the
        # certificate carries the quote hash and |D| into the PCP tree.
        seconds_ii = @elapsed fx = frontend_pcp(padded, GF8, 6, tables_ii,
                                                MonomialBudget(2_500_000),
                                                tb0_certified_points(GF8))
        @test !(fx isa ExpansionRefused)
        @test passed(verify_certificate(Checked(fx.proof, fx.certificate)))
        @test fx.certificate.rule == :PCPProof
        @test all(dependency_coordinates(fx.gs[i]) == Set((i,)) for i in 1:5)
        printed = sprint(traceprint, fx.certificate)
        @test occursin("[CHECKED] Quote | |D| = $(description_size(pipeline.quoted.term)) bytes", printed)
        @test occursin(quote_hash(pipeline.quoted.term), printed)
        @test occursin("[CHECKED] BoundedTrace", printed)
        @test occursin("[CHECKED] CookLevin", printed)
        @test occursin("[CITED] CookLevinGeneral", printed)
        @test occursin("[CHECKED] Decouple5", printed)
        @test occursin("[CHECKED] Pad5", printed)
        @test occursin("[CHECKED] UpstreamEvidence", printed)
        @test occursin("[CHECKED] Tseitin", printed)
        @test occursin("[CHECKED] PCPVerifier", printed)
        @test occursin("[ASSUMED] PerIndexEqualityGadgets", printed)
        @test fx.certificate.children[1].rule == :UpstreamEvidence
        @test fx.certificate.children[1].children[1].rule == :Pad5
        # M-size: the propagated size is the exact byte length.
        @test occursin("|D| = $(length(canonical_bytes(pipeline.quoted.term))) bytes", printed)
        # The bound front-end evidence is refused on another proof.
        borrowed = verify_certificate(Checked(plain.proof, fx.certificate))
        @test !passed(borrowed) && borrowed.rule == :certificate_binding
        # verdicts/tb3-r1.md N2: a front-end certificate is bound to the
        # objects it was built for. B = the twin decider (|D| = 45, T = 1)
        # pads to the same relation as the trivial decider A; A's padded
        # certificate on B's padded term is refused at the :Pad5 node with
        # :certificate_binding, and build_pcp's upstream-evidence slot
        # refuses it before any PCP certificate (with A's |D| and hash)
        # exists.
        b = tb3_pipeline(tb3_twin(), 1, :twin)
        @test description_size(b.quoted.term) == 45
        @test quote_hash(b.quoted.term) != quote_hash(pipeline.quoted.term)
        @test b.padded.term.clauses == padded.term.clauses && b.padded.term.m_prime == 16
        # The critic's B (not(false), T = 2) now pads to m = 2 (N7).
        @test tb3_pipeline(tb3_not_false(), 2, :not_false).padded.term.m == 2
        chimera = Checked(b.padded.term, padded.certificate)
        refused = verify_certificate(chimera)
        println("MUTATION_EXPECTED_RULE certificate_binding borrowed_passed=", passed(refused),
                " location=", refused.location)
        @test !passed(refused) && refused.rule == :certificate_binding && refused.location == :Pad5
        @test_throws ArgumentError frontend_pcp(chimera, GF8, 6, tables_ii,
                                                MonomialBudget(2_500_000), tb0_certified_points(GF8))
        # B's own certificate goes through, carrying B's size and hash.
        fb = frontend_pcp(b.padded, GF8, 6, tables_ii, MonomialBudget(2_500_000),
                          tb0_certified_points(GF8))
        @test passed(verify_certificate(Checked(fb.proof, fb.certificate)))
        printed_b = sprint(traceprint, fb.certificate)
        @test occursin("|D| = 45 bytes", printed_b) && occursin(quote_hash(b.quoted.term), printed_b)
        @test !occursin(quote_hash(pipeline.quoted.term), printed_b)
        # The slot binds the front end to the proof's formula: an upstream
        # object whose circuit did not generate tf is refused at build time.
        equality = tb3_pipeline(tb3_equality(), 3, :equality)
        decomposition_i = zero_basis_decompose(plain.c0, 1:length(plain.tf.layout.names))
        @test_throws ArgumentError build_pcp(plain.tf, plain.gs, plain.c0, decomposition_i, 6,
                                             tb0_certified_points(GF8), ();
                                             upstream=(equality.padded,))
        @test_throws ArgumentError upstream_circuit(plain.tf)
        # TB2's typed answer-reduced decider on the generated proof: the
        # nine fig:decider-pcp guard cases with honest answers (brief 65:
        # the diagonal orientations of steps 4(b)/4(c) were added).
        proof11 = change_field(fx.proof, GF2048, 11).term
        original = trivial_original_verifier(GF2048, TB3_PARAMS, fx.tf;
                                             n=2, T=1, Q_len=1, sigma=description_size(pipeline.quoted.term),
                                             label=:tb3_generated)
        reduced = answer_reduce_pcp(original, 1, 1, 1).term
        strategy = honest_pcp_strategy(proof11, TB3_PARAMS)
        seed = ntuple(j -> GF2048(mod(37 + 13j, 2048)), seed_dim(reduced.sampler))
        decisions = Tuple{Symbol,Bool}[]
        seconds_ar = @elapsed for case in MIPStarLambda._answer_reduce_replay_cases()
            left_q, right_q = sample_answer_reduce_questions(reduced, case.left, case.right, seed)
            left_a = honest_pcp_answer(strategy, case.left.pcp, left_q.pcp)
            right_a = honest_pcp_answer(strategy, case.right.pcp, right_q.pcp)
            decision = typed_answer_reduced_decider(reduced.decider, case.left, left_q,
                                                    case.right, right_q, left_a, right_a)
            push!(decisions, (case.case, passed(decision)))
        end
        @test all(last, decisions)
        @test length(decisions) == 9
        println("TB3 pcp: |c0| (i)=", monomial_count(plain.c0), " (ii)=", monomial_count(fx.c0),
                " build (i)=", round(seconds_i; digits=3), " s (ii)=", round(seconds_ii; digits=3),
                " s; decider cases accepted=", count(last, decisions), "/9 in ",
                round(seconds_ar; digits=3), " s; peak_rss=", Sys.maxrss())
        traceprint(stdout, fx.certificate)
    end
end

if tb3_runs("tb3_equality")
    @testset "TB3 (g) equality decider snapshot: trace, 3SAT, 5SAT, circuit, c0 growth" begin
        equality = tb3_pipeline(tb3_equality(), 3, :equality)
        trace = equality.trace.term
        @test trace.accepts == false      # TB3_INPUT has a = 1, b = 0
        @test length(trace.configurations) == 4
        @test passed(verify_certificate(equality.trace))
        @test passed(verify_certificate(equality.sat3))
        @test passed(verify_certificate(equality.sat5))
        f3 = equality.sat3.term
        d5 = equality.sat5.term
        p = equality.padded.term
        @test passed(verify_certificate(equality.padded))
        @test p.m == maximum(d5.index_widths)
        @test ispow2(p.m_prime) && p.m_prime == 5p.m + 5 + p.s
        # DESIGN 7 risk 9: snapshot gate/monomial growth and stop on the
        # budget. The generated circuit is fed to Tseitin and arith_q under
        # the witness (i) budget; refusal is a result.
        tf = tseitin(p.circuit).term
        expansion = arith_q(tf, GF8, MonomialBudget(160_000))
        candidates = frontend_c0_estimate(p)
        println("TB3 equality snapshot: T=3 rows=", length(trace.configurations),
                " 3SAT m=", f3.index_width, " M=", f3.variable_count,
                " clauses=", length(f3.clauses), " eliminated=", f3.tableau.eliminated,
                " | 5SAT widths=", d5.index_widths, " clauses=", length(d5.clauses),
                " copy=", d5.copy_gadgets, " eq=", d5.equality_gadgets,
                " | padded m=", p.m, " live=", p.live_gates, " s=", p.s, " m'=", p.m_prime,
                " | F_arith candidates <= ", candidates.farith,
                " c0 candidates <= ", candidates.c0, " | arith_q => ",
                expansion isa ExpansionRefused ? "ExpansionRefused($(expansion.estimate))" :
                    "monomials = $(monomial_count(expansion.term))")
        @test expansion isa ExpansionRefused || monomial_count(expansion.term) > 0
        @test candidates.c0 >= candidates.farith
    end
end

if tb3_runs("tb3_tb4prep")
    @testset "TB3 (h) TB4 prerequisites: YCode, halts_within/quoted_pair, sorts, FuelBound, Verifier" begin
        # verdicts/tb3-r1.md section 8, gaps 1-6.
        trivial = tb3_trivial()
        # Gap 1: D = YCode(Psi) is representable, closed, quotable, and is Fix.
        sampler_stub = Lambda(1, BoundVar(0, 0))
        compress_stub = Lambda(2, Quote(trivial))           # (pair, lambda) -> a decider's code
        @test quote_program(sampler_stub; sort=:Sampler).term isa Quoted{:Sampler}
        @test quote_program(compress_stub; sort=:Compressor).term isa Quoted{:Compressor}
        n, x, y, a, b = ntuple(i -> BoundVar(0, i - 1), 5)
        lambda = tb3_nat(7)
        # Psi_{M,lambda} of DESIGN 1.1 with the stub Compress in place of
        # Compress (its code position evaluates to a decider's code; the
        # outer Eval runs that decider on (n,x,y,a,b) under n^lambda).
        psi(machine) = Lambda(5,
            If(Prim(:halts_within, Opaque("n steps", (:n,)), (machine, n)),
               tb3_true(),
               Eval(Apply(compress_stub,
                          (Prim(:quoted_pair, Concrete(1),
                                (Quote(sampler_stub, :Sampler), Hole(:self_code, :Decider))),
                           lambda)),
                    (n, x, y, a, b), FuelBound(n, lambda))))
        halting = psi(tb3_machine_halt3())
        @test holes(halting) == Dict(:self_code => 1)
        d_halt = YCode(halting)
        @test d_halt isa Fix && is_closed(d_halt) && program_equal(d_halt, Fix(halting))
        quoted_d = quote_program(d_halt; sort=:Decider)
        @test passed(verify_certificate(quoted_d))
        @test program_equal(decode_program(quoted_d.term), d_halt)
        # Gap 2: the primitives are registered with charges, so D EVALUATES.
        # M_3 halts in three steps: n = 3 takes the halting branch, n = 2 the
        # compressed branch (which runs the stub's decider under 2^7 = 128).
        input(nn) = (nn, Bool[], Bool[], Bool[true], Bool[false])
        halt_branch = eval_program(d_halt, input(3), 200)
        @test halt_branch.result isa Value && halt_branch.result.value === true
        # Fix 3 + closure 1 + beta 1 + M literal 1 + n lookup 1 +
        # halts_within (1 + 3 steps) 4 + If 1 + true 1 = 13.
        @test halt_branch.used == 13
        compressed_branch = eval_program(d_halt, input(2), 200)
        @test compressed_branch.result isa Value && compressed_branch.result.value === true
        @test compressed_branch.used > halt_branch.used
        d_loop = YCode(psi(tb3_machine_loop()))
        looping = eval_program(d_loop, input(3), 200)
        @test looping.result isa Value && looping.result.value === true
        @test looping.used == compressed_branch.used + 1      # one more simulated step
        # The charge of halts_within is 1 + steps (the Opaque "n steps" bound).
        h(machine, nn, fuel) = eval_program(Prim(:halts_within, Opaque("n steps", (:n,)), (machine, tb3_nat(nn))), (), fuel)
        @test h(tb3_machine_halt3(), 3, 10).result.value === true && h(tb3_machine_halt3(), 3, 10).used == 2 + 4
        @test h(tb3_machine_halt3(), 2, 10).result.value === false && h(tb3_machine_halt3(), 2, 10).used == 2 + 3
        @test h(tb3_machine_loop(), 5, 20).result.value === false && h(tb3_machine_loop(), 5, 20).used == 2 + 6
        @test h(tb3_machine_loop(), 5, 7).result isa OutOfFuel
        @test h(tb3_true(), 3, 10).result == SortError(:primitive_contract)
        # quoted_pair joins two code values; its code is the pair term of
        # sort Pair, which evaluates to itself; fst_code/snd_code project.
        pair = eval_program(Prim(:quoted_pair, Concrete(1), (Quote(sampler_stub, :Sampler), Quote(trivial))), (), 10)
        @test pair.result isa Value && pair.result.value isa Code && pair.result.value.sort == :Pair
        @test pair.used == 3
        again = eval_program(pair.result.value.program, (), 10).result.value
        @test again isa Code && program_equal(again.program, pair.result.value.program)
        @test eval_program(Prim(:snd_code, Concrete(1), (pair.result.value.program,)), (), 10).result.value ==
              Code(trivial, :Decider)
        @test eval_program(Prim(:quoted_pair, Concrete(1), (tb3_true(), Quote(trivial))), (), 10).result ==
              SortError(:primitive_contract)
        # Gap 3: sorts are checked where a term becomes a description.
        @test_throws ArgumentError quote_program(sampler_stub; sort=:Decider)
        @test_throws ArgumentError quote_program(trivial; sort=:Compressor)
        @test_throws ArgumentError quote_program(tb3_true(); sort=:Sampler)
        @test_throws ArgumentError quote_program(tb3_bits("101"); sort=:MachineDesc)
        @test quote_program(tb3_machine_loop(); sort=:MachineDesc).term isa Quoted{:MachineDesc}
        @test_throws ArgumentError Fix(Lambda(2, Eval(Hole(:self_code, :Decider), (), FuelLiteral(1))))
        @test_throws ArgumentError specialize(Lambda(1, If(Hole(:flag, :Bit), tb3_true(), tb3_false())),
                                              (:flag => tb3_true(),); sort=:Decider)
        # ... and at evaluation, as SortError, never a host exception: a
        # MachineDesc is not applicable code.
        @test eval_program(Eval(Quote(tb3_machine_loop(), :MachineDesc), (), FuelLiteral(5)), (), 100).result ==
              SortError(:eval_sort)
        @test all(sort in DECLARED_SORTS for sort in FUNCTION_SORTS)
        # Gap 4: FuelBound(P{Nat}, P{Nat}); an overflowing n^lambda is a
        # budget beyond the ambient fuel, so the outcome is Value or
        # OutOfFuel, never SortError.
        literal_args = (tb3_nat(1), Prim(Bool[], Concrete(1), ()), Prim(Bool[], Concrete(1), ()),
                        Prim(Bool[true], Concrete(1), ()), Prim(Bool[false], Concrete(1), ()))
        huge = Eval(Quote(trivial), literal_args, FuelBound(tb3_nat(1 << 40), tb3_nat(3)))
        @test eval_program(huge, (), 200).result.value === true
        @test eval_program(huge, (), 70).result isa OutOfFuel
        @test eval_program(Eval(Quote(trivial), literal_args, FuelBound(tb3_true(), tb3_nat(3))), (), 200).result ==
              SortError(:eval_fuel)
        # Gap 6: the Verifier carrier is reachable from Quoted and checks
        # the payload sorts.
        sampler_q = quote_program(sampler_stub; sort=:Sampler).term
        decider_q = quoted_d.term
        gap = (Opaque("value 1 accepted", ()), Opaque("value <= 1/2 rejected", ()))
        verifier = Verifier(sampler_q, decider_q, Concrete(0), Concrete(1),
                            Opaque("poly(n, lambda)", (:n, :lambda)), gap, 9)
        @test verifier.levels == 9 && description_size(verifier) ==
              description_size(sampler_q) + description_size(decider_q)
        @test_throws ArgumentError Verifier(decider_q, decider_q, Concrete(0), Concrete(1),
                                            Concrete(1), gap, 9)
        @test_throws ArgumentError Verifier(sampler_q, sampler_q, Concrete(0), Concrete(1),
                                            Concrete(1), gap, 9)
        @test_throws ArgumentError Verifier(sampler_q, decider_q, Concrete(0), Concrete(1),
                                            Concrete(1), gap, 0)
        println("TB3 tb4prep: |D_halt| = ", description_size(quoted_d.term), " bytes; hash = ",
                quote_hash(quoted_d.term), "; halting branch used ", halt_branch.used,
                "; compressed branch used ", compressed_branch.used, "; looping used ", looping.used)
    end
end
