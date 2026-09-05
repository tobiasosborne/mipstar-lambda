# TB6 (DESIGN 11.1, 11.3): the finite type sets and type graphs of the Pauli
# basis test and of the introspection game, transcribed from
# gt-07-ldt.tex eq:pauli-type (L964-L972), fig:type-graph-ms (L565-L604) and
# fig:type-graph-pauli (L1012-L1068), and gt-08-introspection.tex
# fig:type-graph-intro (L217-L315). The source graphs are UNDIRECTED with a
# self-loop at every vertex (captions at gt-07:L1064-L1066, gt-08:L311-L313);
# the stored graph is the ORIENTED pair set: every non-loop edge in both
# orientations plus every loop (DESIGN 9.5 convention, briefs/43 addendum
# Gap 3). `detype_decider` iterates the oriented list.

const PAULI_BASES = ("X", "Z")
"Type labels of type^pauli: ({Point, ALine, DLine, Pauli, Pair} x {X, Z}) u type^ms u {Pair} (26 labels)."
function pauli_type_labels()
    labels = String[]
    for kind in ("Point", "ALine", "DLine", "Pauli", "Pair"), W in PAULI_BASES
        push!(labels, "$(kind)_$(W)")
    end
    append!(labels, ["Constraint_$(i)" for i in 1:6])
    append!(labels, ["Variable_$(j)" for j in 1:9])
    push!(labels, "Pair")
    labels
end

"The three variables of Magic Square constraint i: rows 1-3, columns 4-6 (gt-07:L559-L562, fig:type-graph-ms L586-L592)."
magic_square_variables(i::Integer) = 1 <= i <= 3 ? [3(i - 1) + 1, 3(i - 1) + 2, 3(i - 1) + 3] :
                                     4 <= i <= 6 ? [i - 3, i - 3 + 3, i - 3 + 6] :
                                     throw(ArgumentError("constraint index out of range"))
"The parity each constraint demands: 0 for the rows and the first two columns, 1 for the last column (gt-07:L527-L530)."
magic_square_parity(i::Integer) = i == 6 ? true : false

"The 30 undirected non-loop edges of G^pauli, transcribed from the TikZ source (gt-07:L1031-L1037, L1055-L1061)."
function pauli_undirected_edges()
    edges = Tuple{String,String}[]
    for i in 1:6, v in magic_square_variables(i)
        push!(edges, ("Constraint_$(i)", "Variable_$(v)"))
    end
    for W in PAULI_BASES
        push!(edges, ("ALine_$(W)", "Point_$(W)"))
        push!(edges, ("DLine_$(W)", "Point_$(W)"))
        push!(edges, ("Point_$(W)", "Pauli_$(W)"))
    end
    push!(edges, ("Point_X", "Variable_1"))
    push!(edges, ("Point_Z", "Variable_5"))
    for W in PAULI_BASES
        push!(edges, ("Point_$(W)", "Pair_$(W)"))
        push!(edges, ("Pair_$(W)", "Pair"))
    end
    edges
end

"Both orientations of every non-loop edge plus every self-loop, in label order."
function oriented_pairs(labels::Vector{String}, undirected::Vector{Tuple{String,String}})
    seen = Set{Tuple{String,String}}()
    pairs = Tuple{String,String}[]
    for (a, b) in undirected
        a == b && throw(ArgumentError("loops are implicit"))
        for e in ((a, b), (b, a))
            e in seen && continue
            push!(seen, e)
            push!(pairs, e)
        end
    end
    for l in labels
        push!(pairs, (l, l))
    end
    pairs
end

"TypePauli with G^pauli as a Typed(labels, oriented pairs): 26 types, 30 non-loops, 86 oriented pairs."
pauli_typing() = Typed(pauli_type_labels(), oriented_pairs(pauli_type_labels(), pauli_undirected_edges()))

const INTRO_ROLES = ("alice", "bob")
"Type labels of type^intro = type^pauli u ({Introspect, Sample, Read, Hide_1..Hide_ell} x {alice, bob}) (gt-08:L219-L223)."
function intro_type_labels(ell::Integer)
    ell >= 1 || throw(ArgumentError("ell >= 1"))
    labels = pauli_type_labels()
    for role in INTRO_ROLES
        for kind in ("Introspect", "Sample", "Read")
            push!(labels, "$(kind)_$(role)")
        end
        for k in 1:ell
            push!(labels, "Hide_$(k)_$(role)")
        end
    end
    labels
end

"The 2 ell + 39 undirected non-loop edges of G^intro (gt-08:L294-L310)."
function intro_undirected_edges(ell::Integer)
    edges = pauli_undirected_edges()
    for role in INTRO_ROLES
        push!(edges, ("Sample_$(role)", "Introspect_$(role)"))
        push!(edges, ("Introspect_$(role)", "Read_$(role)"))
        push!(edges, ("Pauli_Z", "Sample_$(role)"))
        push!(edges, ("Pauli_X", "Hide_1_$(role)"))
        for k in 1:ell-1
            push!(edges, ("Hide_$(k)_$(role)", "Hide_$(k + 1)_$(role)"))
        end
        push!(edges, ("Hide_$(ell)_$(role)", "Read_$(role)"))
    end
    push!(edges, ("Introspect_alice", "Introspect_bob"))
    edges
end

"TypeIntro with G^intro: 32 + 2 ell types, 2 ell + 39 non-loops, 6 ell + 110 oriented pairs."
intro_typing(ell::Integer) = Typed(intro_type_labels(ell), oriented_pairs(intro_type_labels(ell), intro_undirected_edges(ell)))

"Parse a type label: (:Point, \"X\"), (:Constraint, 3), (:Variable, 7), (:Pair, nothing), (:Introspect, \"alice\"), (:Hide, (2, \"bob\"))."
function parse_type_label(label::AbstractString)
    parts = split(label, "_")
    head = Symbol(parts[1])
    head == :Pair && length(parts) == 1 && return (:Pair, nothing)
    head in (:Point, :ALine, :DLine, :Pauli, :Pair) && return (head, String(parts[2]))
    head in (:Constraint, :Variable) && return (head, parse(Int, parts[2]))
    head in (:Introspect, :Sample, :Read) && return (head, String(parts[2]))
    head == :Hide && return (:Hide, (parse(Int, parts[2]), String(parts[3])))
    throw(ArgumentError("unknown type label $(label)"))
end
is_pauli_label(label::AbstractString) = label in pauli_type_labels()
