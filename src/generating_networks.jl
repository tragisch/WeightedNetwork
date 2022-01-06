using SimpleWeightedGraphs

function rand_network(nodeNumber::Int, density::Float64; weights = 1:10)
    adj_matrix = zeros(nodeNumber, nodeNumber)
    for row in 1:nodeNumber
        for element in 1:nodeNumber
            if rand() < den && (element != row)
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
            if rand() < den && (element != row)
                wert = rand(weights)
                adj_matrix[row, element] = wert
            end
        end
    end
    SimpleWeightedDiGraph(adj_matrix; permute = false)
end

function adjacency_list(mat::SparseMatrixCSC; weighted = true)

    if weighted
        adj = Array{Array{Float64}}[]
        for i = 1:mat.m
            ind_i = findall(x -> x > 0, mat[i, :])
            line_i = []
            for j = 1:length(ind_i)
                push!(line_i, [ind_i[j], mat[i, ind_i[j]]])
            end
            push!(adj, line_i)
        end
        return adj
    else
        adj = Vector{Vector{Int64}}[]
        for i = 1:mat.m
            push!(adj, findall(x -> x > 0, mat[i, :]))
        end
        return adj
    end

end

import Graphs.LinAlg.adjacency_matrix
function adjacency_matrix(list::Vector{Array{Array{Float64}}})
    n = length(list)
    mat = zeros(n, n)
    for i = 1:length(list)
        node = list[i]
        for el in node
            edge = el
            mat[i, trunc(Int, edge[1])] = edge[2]
        end

    end

    return SparseMatrixCSC(mat)

end

function node_list(adj_matrix::SparseMatrixCSC)
    b = []
    weigth = 0
    for c in 1:adj_matrix.m
        for r in 1:adj_matrix.n
            weight = adj_matrix[r, c]
            if weight > 0
                push!(b, [r, c, weight])
            end
        end
    end
    b
end

function node_list_to_matrix(adj_list)

    dim = 0.0
    for vec in adj_list
        m = maximum([vec[1], vec[2]])
        if m > dim
            dim = m
        end
    end
    dim = trunc(Int, dim)

    adj_mat = zeros(dim, dim)
    for node in adj_list
        if length(node) > 2
            adj_mat[trunc(Int, node[1]), trunc(Int, node[2])] = node[3]
        else
            adj_mat[trunc(Int, node[1]), trunc(Int, node[2])] = 1
        end
    end
    return SparseMatrixCSC(adj_mat)
end