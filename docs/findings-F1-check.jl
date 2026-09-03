# Independent check of finding F1: formal individual degree of w1 in arith(Tseitin(C)) for g1=x1∧x2, g2=w1∧x3.
# Polynomials over Q as Dict{NTuple{5,Int},Rational{Int}} in variables (x1,x2,x3,w1,w2).
const P = Dict{NTuple{5,Int},Rational{Int}}
var(i) = P(ntuple(j->j==i ? 1 : 0, 5) => 1//1)
const one_ = P(ntuple(_->0,5) => 1//1)
add(a,b) = (c=copy(a); for (k,v) in b; c[k]=get(c,k,0//1)+v; end; filter!(kv->kv[2]!=0, c); c)
neg(a) = P(k=>-v for (k,v) in a)
sub(a,b) = add(a,neg(b))
mul(a,b) = (c=P(); for (k1,v1) in a, (k2,v2) in b; k=k1.+k2; c[k]=get(c,k,0//1)+v1*v2; end; filter!(kv->kv[2]!=0, c); c)
AND(a,b) = mul(a,b); NOT(a) = sub(one_,a); OR(a,b) = NOT(AND(NOT(a),NOT(b)))   # NW19 step (i)+(ii)
x1,x2,x3,w1,w2 = var(1),var(2),var(3),var(4),var(5)
z(g,w) = OR(AND(g,w), AND(NOT(g),NOT(w)))
F = AND(AND(z(AND(x1,x2),w1), z(AND(w1,x3),w2)), w2)   # output constraint added (F2)
inddeg(p,i) = maximum(k[i] for k in keys(p))
println("individual degrees (x1,x2,x3,w1,w2) = ", [inddeg(F,i) for i in 1:5], "   monomials = ", length(F))
# Boolean-cube agreement sanity: F(x,w)=1 iff w are wire values and output true
ev(p,pt) = sum(v*prod(pt[i]^k[i] for i in 1:5) for (k,v) in p; init=0//1)
okv = Ref(true)
for x1v in 0:1, x2v in 0:1, x3v in 0:1, w1v in 0:1, w2v in 0:1
    expect = (w1v == x1v*x2v) && (w2v == w1v*x3v) && (w2v == 1) ? 1 : 0
    okv[] &= ev(F,(x1v,x2v,x3v,w1v,w2v)) == expect
end
println("cube agreement = ", okv[])
