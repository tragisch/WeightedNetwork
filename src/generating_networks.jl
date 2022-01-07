using SimpleWeightedGraphs
using SparseArrays

abstract type GraphDataType end

mutable struct AdjacencyList <: GraphDataType
    flist::Vector{Array{Int64}}
    flist_w::Vector{Array{Float64}}
    blist::Vector{Array{Int64}}
    blist_w::Vector{Array{Float64}}

    directed::Bool
end

function Base.show(io::IO, p::AdjacencyList)
    dire = "directed"
    if !p.directed
        dire = "undirected"
    end

    print(io, "AdjacencyList: $dire")
end

function AdjacencyList(mat::SparseMatrixCSC)

    flist = Array{Int64}[]
    flist_w = Array{Float64}[]
    blist = Array{Int64}[]
    blist_w = Array{Float64}[]
    directed = false

    for i = 1:mat.m
        vec = findall(x -> x > 0, mat[i, :])
        push!(flist, vec)
        push!(flist_w, mat[i, vec'])
    end

    for i = 1:mat.n
        vec = findall(x -> x > 0, mat[:, i])
        push!(blist, vec)
        push!(blist_w, mat[vec', i])
    end

    if mat != mat'
        directed = true
    end

    return AdjacencyList(flist, flist_w, blist, blist_w, directed)

end


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
function adjacency_matrix(adj_list::AdjacencyList)
    n = length(adj_list.flist)
    mat = zeros(n, n)
    for i = 1:n
        row = adj_list.flist[i]
        j = 1
        for r in row
            mat[i, r] = adj_list.flist_w[i][j]
            j = j + 1
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