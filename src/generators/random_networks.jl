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

function rand_dag(N::Int, p::Float64; weights = 1:10)

    # schuffel vertiges
    dag = zeros(N, N)
    sink = Random.shuffle!(collect(1:N))

    # randomly connect i>j nodes:
    L = length(sink)
    for k = 1:L
        nArcs = trunc(Int, round(p * (L - k)))
        idx = shuffle!(findall(x -> x > k, (1:L)))
        for l = 1:nArcs
            dag[sink[k], sink[idx[l]]] = rand(weights)
        end
    end

    return SimpleWeightedDiGraph(dag)
end