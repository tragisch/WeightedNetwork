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

    return SimpleWeightedDiGraph(dag) # stores transposed
end

"""
    mk_connected_layered_dag(n, m, p = 0.3; super = true, weights = 1:1)


Generator for a random, connected and weighted DAG. Per default a super-source and super-sink is added.

#### Arguments
- `n::Int64`: number of layers.
- `m:Int64`: number of maximum node per layer.
- `p::Float64`: probability for short-cuts 
- (optional) `super = true`: If true, than add super-source and super-sink to network.
- (optional) `weights=1:1`: add random (Float64) weights to your edges.
"""
function mk_connected_layered_dag(n::Int64, m::Int64, p = 0.3::Float64; super = true, weights = 1:1)
    s = 0
    (super) ? super_sink_source = 1 : super_sink_source = 0

    # create layers
    L = []

    if super_sink_source == 1
        push!(L, [1])
        s = 1
    end
    for i = 1:n
        layer = collect(1+s:rand(1+s:m+s))
        push!(L, layer)
        s = maximum(layer)
    end
    n_nodes = maximum(maximum(L))
    (super_sink_source == 1) ? push!(L, [n_nodes + 1]) : nothing

    # @show L

    # create adjacency matrix:
    adj = SparseMatrixCSC(zeros(n_nodes + super_sink_source, n_nodes + super_sink_source))

    # connect super_sink to layer-1
    if super_sink_source == 1
        for i = 1+super_sink_source:maximum(L[2])
            adj[1, i] = rand(weights)
        end
    end

    # inter node completation:
    n = n + 2 * super_sink_source
    for k = (1+super_sink_source):n
        for i = minimum(L[k]):maximum(L[k])

            if (k < n)
                # inter layer ! 
                for j = 1:length(L[k])
                    ls = Random.shuffle!(L[k+1])
                    adj[L[k][j], ls[1]] = rand(weights)
                end

                # inter network:
                if (rand() < p)

                    kj = collect(minimum(L[k]):maximum(L[n]))
                    cs = Random.shuffle!(kj)
                    (cs[1] != i) ? adj[i, cs[1]] = rand(weights) : nothing
                end
            end

            # no empty parents !
            if isempty(WeightedNetwork.parents(adj, i)) && (i != 1)
                dd = Random.shuffle!(L[k-1])
                adj[dd[1], i] = rand(weights)
            end

        end
    end

    if super_sink_source == 1
        for k = (1+super_sink_source):n-1
            for i = minimum(L[k]):maximum(L[k])
                childs = WeightedNetwork.children(adj, i)
                if isempty(childs)
                    adj[i, n_nodes+1] = rand(weights)
                end
            end
        end
    end


    return SimpleWeightedDiGraph(adj')

end


"""
    mk_directed_grid(n::Int,m::Int)


Generate a directed grid graph `g` with ``n`` rows and m column

#### Arguments
- `n::Int`: number of rows
- `m::Int`: number of columns
- (optional) `weights = 1:1`: Edge-weights randomly between k:K
"""
function mk_directed_grid(n::Int, m::Int; weights = 1:1)
    dim = m * n
    adj = SparseMatrixCSC(zeros(dim, dim))

    for i = 1:m*n
        if i + 1 <= ceil(i / n) * n
            adj[i, i+1] = rand(weights)
        end
        if i + n <= n * m
            adj[i, i+n] = rand(weights)
        end
    end

    return SimpleWeightedDiGraph(adj')
end


"""
    mk_grid(n::Int,m::Int)


Generate a (undirected) grid graph `g` with n rows and m column

#### Arguments
- `n::Int`: number of rows
- `m::Int`: number of columns
- (optional) `weights = 1:1`: Edge-weights randomly between k:K
"""
function mk_grid(n::Int, m::Int; weights = 1:1)
    grid = mk_directed_grid_graph(n, m, weights)
    dim = nv(grid)

    for j = 1:m
        for i = 1:n
            grid.weights[j, i] = grid.weights[i, j]
        end
    end

    return SimpleWeightedGraph(grid)

end