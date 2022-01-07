using SimpleWeightedGraphs, GraphPlot

function plot_network(netw1::SparseMatrixCSC;
    layout = spring_layout,
    label = true,
    nodes = 1:netw1.m,
    color = Colors.parse(Colorant, "turquoise"))

    @show directed = !is_Matrix_symmetric(netw1)
    swn = SimpleWeightedDiGraph(netw1)
    #directed = is_directed(swn) 

    gplot(swn,
        layout = layout,
        NODESIZE = 0.14 / sqrt(netw1.n),
        NODELABELSIZE = (netw1.m < 50) ? 3 : 2,
        nodelabel = nodes,
        nodefillc = color,
        edgelabel = (directed == false) ? netw1.nzval / 2 : netw1.nzval,
        EDGELINEWIDTH = 2 / sqrt(length(netw1.nzval)),
        EDGELABELSIZE = label ? 3 : 0,
        arrowlengthfrac = (directed == false) ? 0.0 : maximum([0.025, 0.3 / length(netw1.nzval)]),
        arrowangleoffset = π / 9
    )

end

function plot_network(netw1::SimpleWeightedDiGraph;
    layout = spring_layout,
    label = true,
    color = Colors.parse(Colorant, "turquoise"))
    plot_network(netw1.weights; layout, label, color)
end

function plot_network(netw1::SimpleWeightedGraph;
    layout = spring_layout,
    label = true,
    color = Colors.parse(Colorant, "turquoise"))
    plot_network(netw1.weights; layout, label, color)
end

using Plots
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
        mat = SimpleWeightedDiGraph(sparse_mat)
        colors = palette(:default, sparse_mat.m)
        comp = dfs_find_components(mat)
        plot_network(sparse_mat; label = false, color = colors[comp])
    else
        plot_network(sparse_mat; label = false)
    end


end