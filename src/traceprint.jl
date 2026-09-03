function _trace_line(io::IO, node::CertNode, indent::Int)
    padding = repeat("  ", indent)
    display = haskey(node.facts, :display) ? node.facts.display : ""
    suffix = isempty(display) ? "" : " | " * display
    println(io, padding, "[", node.grade, "] ", node.rule, suffix)
    for child in node.children
        _trace_line(io, child, indent + 1)
    end
end

traceprint(io::IO, node::CertNode) = _trace_line(io, node, 0)
traceprint(node::CertNode) = traceprint(stdout, node)
