# Functions for representing graphs in GraphViz's dot format
# http://www.graphviz.org/
# http://www.graphviz.org/Documentation/dotguide.pdf
# http://www.graphviz.org/pub/scm/graphviz2/doc/info/lang.html

# orientated and based more or less on :
# https://github.com/JuliaAttic/OldGraphs.jl/blob/master/src/dot.jl
# https://github.com/tkf/ShowGraphviz.jl
# and only simply modified (Roettgermann, 12/21)


#typealias
const AttributeDict = Dict{Symbol,Vector{String}}

# return default attributes for GraphViz plots:
function default_attributes(graph::AbstractSimpleWeightedGraph; node_label::Bool = true, edge_label::Bool = false)::AttributeDict
    directed = Graphs.is_directed(graph)
    n = nv(graph)
    #size_graph=minimum(5.0 +*/sqrt, 15.0)  # ToDo: automated scaler
    attr = AttributeDict(
        :weights => ["P", (edge_label) ? "true" : "false"],
        :largenet => ["P", "200"],
        :arrowsize => ["E", "0.5"],
        :arrowtype => ["E", "normal"],
        :center => ["G", "1"],
        :overlap => ["G", "scale"],
        :color => ["N", "Turquoise"],
        :concentrate => ["G", "true"],
        :orientation => ["N", "90"],
        :fontsize => ["N", (node_label) ? ((n < 100) ? "7.0" : "5") : "1.0"],
        :width => ["N", (node_label) ? "0.25" : "0.20"],
        :height => ["N", (node_label) ? "0.25" : "0.20"],
        :fixedsize => ["N", "true"],
        :fontsize => ["E", (edge_label) ? "8.0" : "1.0"],
        :layout => ["G", (directed) ? "dot" : "neato"], # dot or neato
        :size => ["G", (n < 20) ? "3.0" : ((n < 100) ? "7.0" : "10")],
        :shape => ["N", (node_label) ? "circle" : "point"]
    )

    # modify attr_ if it is a large network:
    if n > parse(Int64, attr[:largenet][2])
        attr = _mod_attr_large_network!(attr)
    end

    return attr
end

# internal function to modify `GraphViz` plot-paramter for large graphs
function _mod_attr_large_network!(attrs::AttributeDict)
    attrs[:shape] = ["N", "point"]
    attrs[:color] = ["N", "black"]
    attrs[:fontsize] = ["G", "1"]
    attrs[:concetrate] = ["G", "true"]
    attrs[:layout] = ["G", "sfdp"]
    attrs[:weights] = ["P", "false"]
    return attrs
end

# get `G`raph, `E`dge and `N`ode relateted attributes:
function get_GNE_attributes(attrs::AttributeDict, gne::String)
    if !isempty(attrs)
        GNE_attrs = Dict()
        for key in keys(attrs)
            if contains(attrs[key][1], gne)
                GNE_attrs[key] = attrs[key]
            end
        end
        return GNE_attrs
    else
        return ""
    end

end

# get a suitable string out of the attribute dictionary:
function _parse_attributes(mat::AbstractSimpleWeightedGraph, attrs::AttributeDict, gne::String)

    gne_attrs = get_GNE_attributes(attrs, gne)
    str_attr::String = ""

    if gne == "N" # node attributes
        str_attr = string("[", join(map(a -> to_dot(a[1], a[2][2]), collect(gne_attrs)), ","))
    elseif gne == "G" # graph attributes
        for key in keys(attrs)
            if contains(attrs[key][1], "G")
                str_attr = str_attr * string(to_dot(key, attrs[key][2]), ";\n ")
            end
        end
    elseif gne == "E" # edge attributes
        str_attr = string("[", join(map(a -> to_dot(a[1], a[2][2]), collect(gne_attrs)), ","))
    end
    return str_attr
end

to_dot(sym::Symbol, value::String) = "$sym=$value"
graph_type_string(graph::AbstractSimpleWeightedGraph) = Network.is_directed(graph) ? "digraph" : "graph"
edge_op(graph::AbstractSimpleWeightedGraph) = Network.is_directed(graph) ? "->" : "--"

# Write the dot representation of a graph to a file by name.
function to_dot_file(graph::AbstractSimpleWeightedGraph, filename::AbstractString; attributes::AttributeDict = default_attributes(graph), path = [])
    open(filename, "w") do f
        _to_dot(graph, f, attributes; path = path)
    end
end

# Get the dot representation of a graph as a string.
function to_dot(graph::AbstractSimpleWeightedGraph; attributes::AttributeDict = default_attributes(graph), path = [])
    str = IOBuffer()
    _to_dot(graph, str, attributes; path = path)
    String(take!(str)) #takebuf_string(str)
end

# a DOT-Language representation:
function _to_dot(mat::AbstractSimpleWeightedGraph, stream::IO, attrs::AttributeDict; path = [])

    # check if `weighted` and labeled:
    edge_label = false
    if haskey(attrs, :weights)
        attr_ = attrs[:weights][2]
        (attr_ == "true") ? edge_label = true : edge_label = false
    end
    # write DOT:
    write(stream, "$(graph_type_string(mat)) graphname {\n")
    G = "G"
    write(stream, " $(_parse_attributes(mat,attrs, G))\n")
    n_vertices = nv(mat)
    N = "N"
    for node = 1:n_vertices
        if !isempty(path) && !Base.isnothing(findfirst(isequal(node), path))
            color_node = ",color=red]" # hard-coded> ToDo: could be part of attribute_list
        else
            color_node = "]"
        end
        write(stream, " $node $(_parse_attributes(mat,attrs, N)) $color_node;\n")
    end
    for node = 1:n_vertices
        childs = Network.children(mat, node)
        E = "E"
        for kid in childs
            if n_vertices > kid
                if !isempty(path) && !Base.isnothing(findfirst(isequal(node), path)) && !Base.isnothing(findfirst(isequal(kid), path))
                    edge_node = ",color=red]" # hard-coded> ToDo: could be part of attribute_list
                else
                    edge_node = "]"
                end

                if edge_label
                    w = mat.weights[node, kid]
                    write(stream, " $node $(edge_op(mat)) $kid $(_parse_attributes(mat,attrs, E)), xlabel=$w $edge_node;\n")
                else
                    write(stream, " $node $(edge_op(mat)) $kid $(_parse_attributes(mat,attrs, E)) $edge_node;\n")
                end
            end
        end

    end
    write(stream, "}\n")
    return stream
end

# plot, using ShowGraphviz.jl package:
function plot_graphviz(g::AbstractSimpleWeightedGraph, node_label::Bool = true, edge_label::Bool = false; path = [])
    attributes = default_attributes(g; node_label = node_label, edge_label = edge_label)
    gv_dot = to_dot(g; attributes = attributes, path = path)
    plot_graphviz(gv_dot)
end

function plot_graphviz(g::AbstractSimpleWeightedGraph, attributes::AttributeDict; path = [])
    gv_dot = to_dot(g; attributes = attributes, path = path)
    plot_graphviz(gv_dot)
end

plot_graphviz(str::AbstractString) = ShowGraphviz.DOT(str)



