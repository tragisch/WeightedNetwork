module Network

export rand_network
export rand_directed_network
export adjacency_list
export adjacency_matrix
export plot_network
export plot_graph

include("generating_networks.jl")
include("plotting_networks.jl")


end
