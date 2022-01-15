

function children(mat::SparseMatrixCSC, node::Int64)
    return findall(x -> x != 0, mat[node, :])
end

children(net::SimpleWeightedGraph, node::Int64) = children(net.weights, node)
children(net::SimpleWeightedDiGraph, node::Int64) = children(net.weights, node)


function parents(mat::SparseMatrixCSC, node::Int64)
    return findall(x -> x != 0, mat[:, node])
end

parents(net::SimpleWeightedDiGraph, node::Int64) = parents(net.weights, node)
parents(net::SimpleWeightedGraph, node::Int64) = parents(net.weights, node)


function neighbors(mat::SparseMatrixCSC, node::Int64)
    return union(children(mat, node), parents(mat, node))
end

neighbors(net::SimpleWeightedGraph, node::Int64) = neighbors(net.weights, node)
neighbors(net::SimpleWeightedDiGraph, node::Int64) = neighbors(net.weights, node)

function toplogicalsort!(mat::SparseMatrixCSC)
    order, acyclic = Network._topologicalsort_kahn(mat::SparseMatrixCSC)
    if acyclic
        n = length(mat[1, :])
        mat2 = similar(mat)
        for i = 1:n
            mat2[i, :] = mat[order[i], :]
        end
        mat1 = mat2
    end
end

function toplogicalsort!(net::SimpleWeightedGraph)
    toplogicalsort!(net.weights)
end
function toplogicalsort!(net::SimpleWeightedDiGraph)
    toplogicalsort!(net.weights)
end

function toplogicalsort(mat::SparseMatrixCSC; method = "kahn")
    if Network.is_directed(mat)
        if method == "kahn"
            L, acyclic = _topologicalsort_kahn(mat)
        else
            L, acyclic = _topologicalsort_dfs(mat)
        end
        return L, acyclic
    else
        print("undirected graph. No topological order")
        return [], false
    end
end

toplogicalsort(net::SimpleWeightedGraph; method = "kahn") = toplogicalsort(net.weights; method)
toplogicalsort(net::SimpleWeightedDiGraph; method = "kahn") = toplogicalsort(net.weights; method)

function _topologicalsort_kahn(mat::SparseMatrixCSC)

    # if there exists a topological order of directed graph g, then it is acyclic
    acyclic = true

    adj = deepcopy(mat)
    # get set $S$ of all nodes with no incoming edge
    n = length(adj[1, :])
    S = Int64[]
    num_parents = zeros(Int, 1, n) # no incoming EDGELABELSIZE
    for i = 1:n
        num_parents[i] = length(Network.parents(adj, i))
        if num_parents[i] == 0
            push!(S, i)
        end
    end

    L = [] # return value

    while !isempty(S)
        node = pop!(S)
        push!(L, node)
        childs = Network.children(adj, node)
        for kid in childs
            adj[node, kid] = 0
            if length(Network.parents(adj, kid)) == 0
                push!(S, kid)
            end
        end
    end

    if sum(adj) == 0.0 || sum(adj) == 0
        acyclic = true
        return L, acyclic
    else
        acyclic = false
        print("No tolpological order. This is not a DAG. The direct graph is cyclic!")
        return [], acyclic
    end
end

function _topologicalsort_dfs(adj::SparseMatrixCSC)

    # if there exists a topological order of directed graph g, then it is acyclic
    acyclic = true

    mat = deepcopy(adj)
    L = Int64[]
    n = length(mat[:, 1])
    marked = zeros(Int, 1, n)
    unmarked_node = marked[1]

    function visit(node)
        if marked[node] == 2 # 2 = permanent_mark
            return
        elseif marked[node] == 1 # 1 = temporary mark
            acyclic = false # then this unacyclic and not a DAG.
            print("No tolpological order. This is not a DAG. The direct graph is cyclic!")
            return []
        end

        marked[node] = 1

        childs = Network.children(mat, node)
        for kid in childs
            visit(kid)
        end

        marked[node] = 2
        push!(L, node)
    end

    while !isnothing(unmarked_node)
        unmarked_node = findfirst(isequal(0), marked)
        if !isnothing(unmarked_node)
            visit(unmarked_node[1])
        end
    end

    return reverse(L), acyclic

end


function is_directed(mat::SparseMatrixCSC)
    return !(mat == mat')
end

is_directed(g::SimpleWeightedDiGraph) = is_directed(g.weights)
is_directed(g::SimpleWeightedGraph) = is_directed(g.weights)

