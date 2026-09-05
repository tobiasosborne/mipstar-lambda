using MIPStarLambda
tr = Lambda(5, Prim(:true, Concrete(1), ()))
eq = Lambda(5, Prim(:eq, Concrete(1), (BoundVar(0,3), BoundVar(0,4))))
qt = quote_program(tr; sort=:Decider)
b = canonical_bytes(qt.term)
println("TRIVIAL_BYTES_HEX=", bytes2hex(b))
println("TRIVIAL_LEN=", length(b), " desc_size=", description_size(qt.term))
qe = quote_program(eq; sort=:Decider)
be = canonical_bytes(qe.term)
println("EQ_BYTES_HEX=", bytes2hex(be))
println("EQ_LEN=", length(be))
inp = (1, Bool[], Bool[], Bool[true], Bool[false])
for f in 0:6
  r = eval_program(tr, inp, f)
  println("TRIVIAL_FUEL f=", f, " result=", typeof(r.result), " used=", r.used)
end
for f in 0:7
  r = eval_program(eq, inp, f)
  println("EQ_FUEL f=", f, " result=", typeof(r.result), " used=", r.used, " val=", r.result isa Value ? r.result.value : "-")
end
println("EVAL_OVERHEAD=", eval_overhead(qt, inp))
println("TERM_SIZE trivial=", term_size(tr), " eq=", term_size(eq))
# CL descriptions
for (nm, L) in (("L_Point", L_Point(GF8, 2, 1)), )
  try
    d = describe_cl(L)
    bb = canonical_bytes(d)
    println(nm, "_DESC_HEX=", bytes2hex(bb))
    println(nm, "_DESC_LEN=", length(bb))
  catch e
    println(nm, "_ERR=", e)
  end
end
