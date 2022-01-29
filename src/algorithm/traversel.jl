

function dfs_path(netw::SimpleWeightedGraph, startnode::Int64)
    n_vertex = nv(netw)
    path = zeros(Int, n_vertex)
    visited = zeros(Int, n_vertex)
    parents = zeros(Int, n_vertex)

    function _dfs(at)
        if (visited[at] == 1)
            nothing
        else
            visited[at] = 1
            if parents[at] > 0
                pa = parents[at]
            end
            path[at] = pa
            neig = neighbors(netw, at)
            for p in neig
                parents[p] = at
                _dfs(p)
            end
        end
    end

    at = startnode
    pa = startnode
    parents[at] = startnode
    _dfs(at)

    return path
end


function path_to_adj_matrix(path::Vector{Int64})
    dim = maximum([maximum(path), length(path)])
    adj_mat = zeros(dim, dim)

    for i in 1:length(path)
        if (path[i] != 0) && (path[i] != i)
            adj_mat[path[i], i] = 1
        end
    end

    return SparseMatrixCSC(adj_mat)
end

function node_color(netw::AbstractSimpleWeightedGraph)
    adj = netw.weights
    count = 0
    n = nv(netw)
    components = zeros(Int, n)
    visited = zeros(Int, n)

    function findComponents()
        for i = 1:n
            if (visited[i] == 0)
                count += 1
                dfs(i)
            end
        end
        return count, components
    end

    function dfs(at)
        visited[at] = 1
        components[at] = count
        neigh = neighbors(netw, at)
        for next in neigh
            if (visited[next] == 0)
                dfs(next)
            end
        end
    end

    count, components = findComponents()
    @show count
    return components

end

function bfs_path(g::AbstractSimpleWeightedGraph, startnode::Int64, endnode::Int64)
    n = nv(g)

    q = Queue{Int64}()
    enqueue!(q, startnode)

    visitied = zeros(Int64, 1, n)
    visitied[startnode] = 1

    prev = zeros(Int64, 1, n)

    while (isempty(q.store) == false)
        node = dequeue!(q)
        neigh = neighbors(g, node)
        for next in neigh

            if (visitied[next] != 1)
                enqueue!(q, next)
                visitied[next] = 1
                prev[next] = node
            end
        end
    end

    if prev[endnode] == 0
        return []
    end

    at = endnode
    path = []
    while true
        at = prev[at]
        if at == 0
            break
        else
            push!(path, at)
        end
    end


    path = reverse(path)
    push!(path, endnode)
    return path

end

# shortest_path using dijkstra_shortest_paths form `Graphs.jl`:
function shortest_path(g::AbstractSimpleWeightedGraph, source::Int64, sink::Int64)
    ds = Graphs.dijkstra_shortest_paths(g, sink)
    try
        return reverse(spath(ds, source, sink))
    catch e
        return []
    end

end

# convert precedessor list in path:
spath(ds, source, sink) = source == sink ? source : [spath(ds, ds.parents[source], sink) source]