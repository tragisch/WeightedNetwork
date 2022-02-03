

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
