
# Parents: use findall in adjacency matrix, instead of `Graphs.innerneigbhors` method:
children(mat::SparseMatrixCSC, node::Int64) = findall(x -> x != 0, mat[node, :])
children(net::AbstractSimpleWeightedGraph, node::Int64) = Graphs.inneighbors(net, node)

# Parents: use findall in adjacency matrix, instead of `Graphs.outneigbhors` method:
parents(mat::SparseMatrixCSC, node::Int64) = findall(x -> x != 0, mat[:, node])
parents(net::AbstractSimpleWeightedGraph, node::Int64) = Graphs.outneighbors(net, node)

# Parents: use findall in adjacency matrix, instead of `Graphs.all_neigbhors` method:
neighbors(mat::SparseMatrixCSC, node::Int64) = union(children(mat, node), parents(mat, node))
neighbors(net::AbstractSimpleWeightedGraph, node::Int64) = Graphs.all_neighbors(net, node)


function toplogicalsort(net::AbstractSimpleWeightedGraph; method = "graphs")
    if Graphs.is_directed(net)
        if method == "dfs"
            L, acyclic = _topologicalsort_dfs(net)
        elseif method == "kahn"
            L, acyclic = _topologicalsort_kahn(net)
        else
            try # Todo: ooh, that's not valid in all error cases!
                acyclic = true
                L = Graphs.topological_sort_by_dfs(net)
            catch e
                L = []
                acyclic = false
            end
        end
        return L, acyclic
    else
        print("undirected graph or cyclic graph. No topological order")
        return [], false
    end
end

function _topologicalsort_kahn(g::AbstractSimpleWeightedGraph)

    # if there exists a topological order of directed graph g, then it is acyclic
    acyclic = true

    adj = g.weights
    # get set $S$ of all nodes with no incoming edge
    n = nv(g)
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

function _topologicalsort_dfs(g::AbstractSimpleWeightedGraph)

    # if there exists a topological order of directed graph g, then it is acyclic
    acyclic = true

    mat = g.weights
    L = Int64[]
    n = nv(g)
    marked = zeros(Int, 1, n)

    # choose node with most children:
    unmarked_node = marked[1]

    function visit(node)
        if marked[node] == 2 # 2 = permanent_mark
            return
        elseif marked[node] == 1 # 1 = temporary mark
            acyclic = false # then this unacyclic and not a DAG.
            print("No tolpological order. This is not a DAG. The direct graph is cyclic!")
            return [], acyclic
        end

        marked[node] = 1

        childs = Network.children(g, node)

        for kid in childs
            visit(kid)
        end

        marked[node] = 2
        push!(L, node)
    end

    i = 1
    while !isnothing(unmarked_node)
        unmarked_node = findfirst(isequal(0), marked)
        if !isnothing(unmarked_node)
            visit(unmarked_node[2])
        end
    end

    return reverse(L), acyclic
end

# 8-May-1998	 4:44 PM	ATC	Created under MATLAB 5.1.0.421
# ATC = Ali Taylan Cemgil,
# SNN - University of Nijmegen, Department of Medical Physics and Biophysics
# modified for Julia, Röttgermann, 12/2021
# Test-only
function _toposort(g::AbstractSimpleWeightedGraph)
    adj = g.weights
    N = nv(g)
    indeg = sum(g, 2)
    outdeg = sum(g, 1)

    seq = Int64[]

    for i = 1:N
        idx = findall(x -> x == 0, indeg)

        if isempty(idx)
            seq = []
            break
        end

        max, idx_max = findmax(outdeg[idx])
        indx = idx[idx_max]
        push!(seq, indx)

        indeg[indx] = -1
        idx = findall(x -> x > 0, adj[indx, :])
        !isempty(idx) ? indeg[idx] = indeg[idx] .- 1 : nothing
        @show seq
    end

    return vec(seq)'

end


function is_tree(mat::SparseMatrixCSC)
    # zusammenhängend
    error("Is not implemented yet!")
    # 
end

is_tree(g::SimpleWeightedDiGraph) = is_tree(g.weights)
is_tree(g::SimpleWeightedGraph) = is_tree(g.weights)

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

is_symmetric(g::AbstractSimpleWeightedGraph) = is_symmetric(g.weights)