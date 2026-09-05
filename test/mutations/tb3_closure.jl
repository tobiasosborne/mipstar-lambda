# briefs/23-tb3.md M-closure: bounded_trace accepts a runtime Closure and
# traces its body as if it were a description (DD-1 violated); the type
# refusal test fails.
const TB3_CLOSURE_MUTANT = Mutant(
    "TB3 M-closure bounded_trace_accepts_closure",
    "src/frontend/bounded_trace.jl",
    "bounded_trace(::Closure, input::Tuple, T::Int) =\n    throw(ArgumentError(\"bounded_trace consumes a Quoted description, not a runtime Closure\"))",
    "bounded_trace(c::Closure, input::Tuple, T::Int) =\n    bounded_trace(quote_program(Lambda(c.arity, c.body); sort=:Decider), input, T)",
    "tb3_quote")
