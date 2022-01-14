# Functions for representing graphs in GraphViz's dot format
# http://www.graphviz.org/
# http://www.graphviz.org/Documentation/dotguide.pdf
# http://www.graphviz.org/pub/scm/graphviz2/doc/info/lang.html

# orientated on and based on:
# https://github.com/epatters/Catlab.jl/blob/master/src/graphics/Graphviz.jl
# https://github.com/JuliaAttic/OldGraphs.jl/blob/master/src/dot.jl
# and only simply modified (Roettgermann, 12/21)


#typealias
const AttributeDict = Dict{Symbol,Vector{String}}


# define graphviz default attributes 
function default_attributes(mat::SparseMatrixCSC; node_label::Bool = true, edge_label::Bool = true)
    directed = Network.is_directed(mat)
    attr = AttributeDict(
        :arrowsize => ["E", (edge_label) ? "1.0" : "0.0"],
        :arrowtype => ["E", "normal"],
        :center => ["G", "1"],
        :color => ["N", "red"],
        :concentrate => ["G", (directed) ? "true" : "false"],
        :fontsize => ["NE", "40"],
        :width => ["N", "0.05"],
        :height => ["N", "0.05"],
        :margin => ["N", "0"],
        :landscape => ["G", "true"],
        # :layout => ["G", " "], # dot or neato
        :shape => ["N", (node_label) ? "circle" : "point"]
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
function to_dot(attrs::AttributeDict, gne::String)

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
        str_attr = string("[", join(map(a -> to_dot(a[1], a[2][2]), collect(gne_attrs)), ","), "]")
    end

    return str_attr
end

to_dot(sym::Symbol, value::String) = "$sym=$value"

graph_type_string(graph::AbstractGraph) = Network.is_directed(graph) ? "digraph" : "graph"
graph_type_string(mat::SparseMatrixCSC) = Network.is_directed(mat) ? "digraph" : "graph"
edge_op(graph::AbstractGraph) = Network.is_directed(graph) ? "->" : "--"
edge_op(mat::SparseMatrixCSC) = Network.is_directed(mat) ? "->" : "--"


# Write the dot representation of a graph to a file by name.
function to_dot(graph::SimpleWeightedDiGraph, filename::AbstractString; attrs::AttributeDict = default_attributes(graph))
    open(filename, "w") do f
        to_dot(graph.weights, f, attrs)
    end
end

# Get the dot representation of a graph as a string.
function to_dot(graph::SimpleWeightedDiGraph; attrs::AttributeDict = default_attributes(graph))
    str = IOBuffer()
    @show typeof(str)
    to_dot(graph.weights, str, attrs)
    String(take!(str)) #takebuf_string(str)
end

# a DOT-Language representation:
function to_dot(mat::SparseMatrixCSC, stream::IO, attrs::AttributeDict)
    write(stream, "$(graph_type_string(mat)) graphname {\n")
    G = "G"
    write(stream, "$(to_dot(attrs, G))\n")
    n_vertices = length(mat[1, :])
    for node = 1:n_vertices
        for val in values(attr)
            if contains(val[1], "N")
                N = "N"
                write(stream, " $node $(to_dot(attrs, N));\n")
            end

        end

    end
    for node = 1:n_vertices
        childs = Network.children(mat, node)
        E = "E"
        for kid in childs
            if n > kid
                write(stream, " $node $(edge_op(mat)) $kid $(to_dot(attrs, E));\n")
            end
        end
    end
    write(stream, "}\n")
    return stream
end

# plot:
function plot_graphviz(g::AbstractGraph; gviz_args = "")
    if !isequal(gviz_args, "")
        # Provide the command line code for GraphViz directly
        cla_list = split(gviz_args)
        arg = `$cla_list`
    else
        # Default uses x11 window
        arg = `dot -Tsvg`
    end
    stdin, proc = open(arg, "w")
    to_dot(g, stdin)
    close(stdin)
end


