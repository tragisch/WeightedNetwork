


# convert precedessor list in path:
spath(ds, source, sink) = source == sink ? source : [spath(ds, ds.parents[source], sink) source]