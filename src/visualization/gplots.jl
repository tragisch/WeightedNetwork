# Functions for representing graphs with GraphPlot package
# https://github.com/JuliaGraphs/GraphPlot.jl


function plot_network(netw1::SparseMatrixCSC;
    layout = spring_layout,
    label = true,
    edgelinewidth = 1.0,
    color = Colors.parse(Colorant, "turquoise")
)

    directed = !is_symmetric(netw1)

    n = netw1.m
    swn = SimpleWeightedDiGraph(netw1')


    p = gplot(swn,
        layout = layout,
        NODESIZE = 0.25 / sqrt(n),
        nodefillc = color,
        nodelabel = 1:n,
        nodelabeldist = 0,
        nodelabelangleoffset = π / 4,
        NODELABELSIZE = (n < 50) ? 5 : 2,
        edgelabel = netw1.nzval,
        EDGELABELSIZE = label ? 3 : 0,
        edgestrokec = Colors.parse(Colorant, "gray74"),
        edgelinewidth = edgelinewidth,
        EDGELINEWIDTH = 1.7 / sqrt(n),
        arrowlengthfrac = (directed == false) ? 0.0 : maximum([0.028, 0.3 / length(netw1.nzval)]),
        arrowangleoffset = (π / 9),
    )
    return p
end

function plot_network(netw1::SimpleWeightedDiGraph;
    layout = spring_layout,
    label = true,
    edgelinewidth = 1.0,
    color = Colors.parse(Colorant, "turquoise"))
    return plot_network(netw1.weights; layout = layout, label = label,
        edgelinewidth = edgelinewidth, color = color)
end

function plot_network(netw1::SimpleWeightedGraph;
    layout = spring_layout,
    label = true,
    edgelinewidth = 1.0,
    color = Colors.parse(Colorant, "turquoise"))
    return plot_network(netw1.weights; layout = layout, label = label,
        edgelinewidth = edgelinewidth, color = color)
end


function plot_graph(g::SimpleGraph; color = false)
    # transform in a Simple Weighted Graph
    sparse_mat = adjacency_matrix(g)

    if color
        mat = SimpleWeightedGraph(sparse_mat)
        colors = palette(:default, sparse_mat.m)
        comp = dfs_find_components(mat)
        plot_network(sparse_mat; label = false, color = colors[comp])
    else
        plot_network(sparse_mat; label = false)
    end

end


function plot_graph(g::SimpleDiGraph; color = false)
    sparse_mat = adjacency_matrix(g)

    if color
        mat = SimpleWeightedDiGraph(sparse_mat')
        colors = palette(:default, sparse_mat.m)
        comp = dfs_find_components(mat)
        plot_network(sparse_mat; label = false, color = colors[comp])
    else
        plot_network(sparse_mat; label = false)
    end


end