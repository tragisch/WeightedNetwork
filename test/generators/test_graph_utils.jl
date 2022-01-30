@testset "Graph Utils" begin

    # define matrix
    M = SparseMatrixCSC([
        0 1 5 6
        1 0 4 10
        5 4 0 3
        6 10 3 0
    ])

    # test children of AdjacencyMatrix
    @test WeightedNetwork.children(M, 1) == [2, 3, 4]
    @test WeightedNetwork.children(M, 2) == [1, 3, 4]
    @test WeightedNetwork.children(M, 3) == [1, 2, 4]
    @test WeightedNetwork.children(M, 4) == [1, 2, 3]

    # test parents of AdjacencyMatrix
    @test WeightedNetwork.parents(M, 1) == [2, 3, 4]
    @test WeightedNetwork.parents(M, 2) == [1, 3, 4]
    @test WeightedNetwork.parents(M, 3) == [1, 2, 4]
    @test WeightedNetwork.parents(M, 4) == [1, 2, 3]

    SyM = zeros(10, 10)
    SyM[3, 1] = -0.9521
    SyM[10, 1] = 0.8540
    SyM[3, 2] = 0.1250
    SyM[8, 2] = 0.0397
    SyM[1, 3] = -0.9521
    SyM[2, 3] = 0.1250
    SyM[8, 3] = 0.5301
    SyM[6, 4] = 1.6742
    SyM[5, 5] = -0.9382
    SyM[8, 5] = 0.1092
    SyM[4, 6] = 1.6742
    SyM[8, 7] = 0.3891
    SyM[10, 7] = -1.6066
    SyM[2, 8] = 0.0397
    SyM[3, 8] = 0.5301
    SyM[5, 8] = 0.1092
    SyM[7, 8] = 0.3891
    SyM[1, 10] = 0.8540
    SyM[7, 10] = -1.6066

    SyM2 = deepcopy(SyM)
    SyM2[7, 3] = 1.9876

    # test symmetric of Matrix
    @test WeightedNetwork.is_symmetric(SparseMatrixCSC(SyM)) == true
    @test WeightedNetwork.is_symmetric(SparseMatrixCSC(SyM2)) == false

end