

function children(mat::SparseMatrixCSC, node::Int64)
    return findall(x -> x != 0, mat[node::Int64, :])
end

children(net::SimpleWeightedGraph, node::Int64)= children(net.weights, node)
children(net::SimpleWeightedDiGraph, node::Int64)= children(net.weights, node)


function parents(mat::SparseMatrixCSC, node::Int64)
    return findall(x -> x != 0, mat[:, node])
end

parents(net::SimpleWeightedDiGraph, node::Int64) = parents(net.weights, node)
parents(net::SimpleWeightedGraph, node::Int64) = parents(net.weights, node)


function neighbors(mat::SparseMatrixCSC, node::Int64)
    return union(children(mat, node), parents(mat, node))
end

neighbors(net::SimpleWeightedGraph, node::Int64)= neighbors(net.weights, node)
neighbors(net::SimpleWeightedDiGraph, node::Int64)= neighbors(net.weights, node)


