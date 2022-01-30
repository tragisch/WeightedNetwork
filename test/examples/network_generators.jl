using Pkg
Pkg.activate(".")
using Revise
using WeightedNetwork

# generat random (undirected) network:
g1 = WeightedNetwork.rand_network(6, 0.2)

# it's type ist SimpleWeightedGraph.
g1.weights

# plot graph:
plot_network(g1)

# generate random (directed) network:
g2 = WeightedNetwork.rand_directed_network(6, 0.2)

# plot graph:
plot_network(g2)