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

# define graphviz default attributes 
function default_attributes(mat::SparseMatrixCSC; node_label::Bool = true, edge_label::Bool = true)::AttributeDict
    directed = Network.is_directed(mat)
    #n = length(mat[1, :])   # ToDo: automated scaler
    #size_graph=minimum(5.0 +*/sqrt, 15.0)
    attr = AttributeDict(
        :weights => ["P", "false"],
        :arrowsize => ["E", "1.0"],
        :arrowtype => ["E", "normal"],
        :center => ["G", "1"],
        :color => ["N", "red"],
        :concentrate => ["G", (directed) ? "true" : "false"],
        :orientation => ["N", "90"],
        :fontsize => ["N", "40"],
        :width => ["N", "0.05"],
        :height => ["N", "0.05"],
        :margin => ["N", "0"],
        :labelfontsize => ["E", "8.0"],
        # :layout => ["G", " "], # dot or neato
        :size => ["G", "5.0"],
        :shape => ["N", "circle"]
    )

    return attr
end

default_attributes(g::SimpleWeightedGraph; node_label::Bool = true, edge_label::Bool = true) = default_attributes(g.weights; node_label, edge_label)
default_attributes(g::SimpleWeightedDiGraph; node_label::Bool = true, edge_label::Bool = true) = default_attributes(g.weights; node_label, edge_label)


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
function _parse_attributes(mat::SparseMatrixCSC, attrs::AttributeDict, gne::String; weighted::Bool = false)

    gne_attrs = get_GNE_attributes(attrs, gne)
    str_attr::String = ""

    if gne == "N" # node attributes
        str_attr = string("[", join(map(a -> to_dot(a[1], a[2][2]), collect(gne_attrs)), ","), "]")
    elseif gne == "G" # graph attributes
        for key in keys(attrs)
            if contains(attrs[key][1], "G")
                str_attr = str_attr * string(to_dot(key, attrs[key][2]), ";\n ")
            end
        end
    elseif gne == "E" # edge attributes
        if weighted
            str_attr = string("[", join(map(a -> to_dot(a[1], a[2][2]), collect(gne_attrs)), ","))
        else
            str_attr = string("[", join(map(a -> to_dot(a[1], a[2][2]), collect(gne_attrs)), ","), "]")
        end
    end
    return str_attr
end

to_dot(sym::Symbol, value::String) = "$sym=$value"

graph_type_string(graph::AbstractGraph) = Network.is_directed(graph) ? "digraph" : "graph"
graph_type_string(mat::SparseMatrixCSC) = Network.is_directed(mat) ? "digraph" : "graph"
edge_op(graph::AbstractGraph) = Network.is_directed(graph) ? "->" : "--"
edge_op(mat::SparseMatrixCSC) = Network.is_directed(mat) ? "->" : "--"


# Write the dot representation of a graph to a file by name.
function to_dot_file(mat::SparseMatrixCSC, filename::AbstractString; attributes::AttributeDict = default_attributes(graph))
    open(filename, "w") do f
        _to_dot(mat, f, attributes)
    end
end

to_dot_file(g::SimpleWeightedDiGraph, filename::AbstractString; attributes::AttributeDict = default_attributes(g)) = to_dot_file(g.weights, filename; attributes)
to_dot_file(g::SimpleWeightedGraph, filename::AbstractString; attributes::AttributeDict = default_attributes(g)) = to_dot_file(g.weights, filename; attributes)

# Get the dot representation of a graph as a string.
function to_dot(mat::SparseMatrixCSC; attributes::AttributeDict = default_attributes(graph))
    str = IOBuffer()
    _to_dot(mat, str, attributes)
    String(take!(str)) #takebuf_string(str)
end

to_dot(graph::SimpleWeightedDiGraph; attributes::AttributeDict = default_attributes(graph)) = to_dot(graph.weights; attributes)
to_dot(graph::SimpleWeightedGraph; attributes::AttributeDict = default_attributes(graph)) = to_dot(graph.weights; attributes)

# a DOT-Language representation:
function _to_dot(mat::SparseMatrixCSC, stream::IO, attrs::AttributeDict)

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
    n_vertices = length(mat[1, :])
    N = "N"
    for node = 1:n_vertices
        write(stream, " $node $(_parse_attributes(mat,attrs, N));\n")
    end
    for node = 1:n_vertices
        childs = Network.children(mat, node)
        E = "E"
        for kid in childs
            if n_vertices > kid
                if edge_label
                    w = mat[node, kid]
                    write(stream, " $node $(edge_op(mat)) $kid $(_parse_attributes(mat,attrs, E; weighted=true)), xlabel=$w];\n")
                else
                    write(stream, " $node $(edge_op(mat)) $kid $(_parse_attributes(mat,attrs, E));\n")
                end
            end
        end
    end
    write(stream, "}\n")
    return stream
end

# plot, using ShowGraphviz.jl package:
function plot_graphviz(g::AbstractGraph; node_label::Bool = true, edge_label::Bool = true)
    attributes = default_attributes(g)

    # modfify arguments 
    (node_label) ? attributes[:shape] = ["N", "circle"] : attributes[:shape] = ["N", "points"]
    if edge_label
        attributes[:weights] = ["E", "1"]
        attributes[:arrowsize] = ["E", "1.0"]
    end

    gv_dot = to_dot(g; attributes)
    plot_graphviz(gv_dot)
end

function plot_graphviz(g::AbstractGraph, attributes::AttributeDict)
    gv_dot = to_dot(g; attributes)
    plot_graphviz(gv_dot)
end

plot_graphviz(str::AbstractString) = ShowGraphviz.DOT(str)



