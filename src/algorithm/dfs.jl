
"""
dfs_path(g::SimpleWeightedGraph, startnode::Int64)

Explore the graph in a **deep first search (DFS)** algorithm.  Return a vector of parent vertices indexed by vertex.

Build on `William Fists Graph Theory algorithm`.

#### Arguments
- `g::AbstractSimpleWeightedGraph`: a graph representation to export 
- `startnode::Int64`: the node to start dfs-search
"""
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


function connected_components(netw::AbstractSimpleWeightedGraph)
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
    println("Graph contains $count component(s)")
    return components

end
