module Network

using SparseArrays
using Graphs
using SimpleWeightedGraphs
using DataStructures
using LinearAlgebra
using Plots
using GraphPlot
using DataStructures
using ShowGraphviz

include("./data_types/graphdata_types.jl")
include("./generators/random_networks.jl")
include("./visualization/plotting_networks.jl")
include("./algorithm/traversel.jl")
include("./algorithm/graph_utils.jl")
include("./visualization/dot.jl")

export
    # generators
    rand_network, rand_directed_network,

    # graph properties
    children, parent, neighbors, is_directed,

    # dataformat
    adjacency_matrix, AdjacencyList,

    # visualization mit GraphPlot:
    plot_network, plot_graph,

    # visualization mit Graphviz (for small graphs or use file_export:)
    plot_graphviz, to_dot_file, to_dot, AttributeDict, default_attributes,

    # algorithm:
    dfs_path, bfs_path, toplogicalsort, node_color, path_to_adj_matrix



end
