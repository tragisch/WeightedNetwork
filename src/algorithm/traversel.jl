




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