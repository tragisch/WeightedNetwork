using SimpleWeightedGraphs
using SparseArrays

function rand_network(nodeNumber::Int, density::Float64; weights = 1:10)
    adj_matrix = zeros(nodeNumber, nodeNumber)
    for row in 1:nodeNumber
        for element in 1:nodeNumber
            if rand() < density && (element != row)
                wert = rand(weights)
                adj_matrix[row, element] = wert
                adj_matrix[element, row] = wert
            end
        end
    end
    SimpleWeightedGraph(adj_matrix)
end

function rand_directed_network(nodeNumber::Int, density::Float64; weights = 1:10)
    adj_matrix = zeros(nodeNumber, nodeNumber)
    for row in 1:nodeNumber
        for element in 1:nodeNumber
            if rand() < density && (element != row)
                wert = rand(weights)
                adj_matrix[row, element] = wert
            end
        end
    end
    SimpleWeightedDiGraph(adj_matrix)
end

function is_symmetric(M::SparseMatrixCSC)
    sz = size(M)

    if sz[1] != sz[2]
        return false
    else

        if M == M'
            return true
        else
            return false
        end
    end
end
