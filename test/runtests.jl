using Network
using Network # own!

using Test
using SparseArrays
using Graphs
using SimpleWeightedGraphs
using DataStructures
using LinearAlgebra
using Plots
using GraphPlot
using DataStructures
using ShowGraphviz
using Cairo
using Fontconfig
using Random
using Tokenize

const testdir = dirname(@__FILE__)

tests = [
    "generators/test_generators",
    "generators/test_graph_utils"
]

@testset "Network.jl" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end


