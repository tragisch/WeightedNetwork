using Network
using Test

@testset "Network.jl" begin

    # test creating network and 
    m = 10
    density = 0.2
    net = Network.rand_network(m, density)
    adj = Network.AdjacencyList(net.weights)
    mat = Network.adjacency_matrix(adj)
    @test mat == net.weights

end
