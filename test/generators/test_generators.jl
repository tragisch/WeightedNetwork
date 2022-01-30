@testset "Generator" begin


    # 
    m = 10
    density = 0.2
    net = WeightedNetwork.rand_network(m, density)
    adj = WeightedNetwork.AdjacencyList(net.weights)
    mat = WeightedNetwork.adjacency_matrix(adj)
    @test mat == net.weights


end