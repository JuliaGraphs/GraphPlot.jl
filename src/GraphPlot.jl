module GraphPlot

if VERSION < v"0.4.0"
    using Docile
end

using Compat
import Graphs
import LightGraphs
using Compose  # for plotting features

const gadflyjs = joinpath(dirname(Base.source_path()), "gadfly.js")

export
    gplot,
    gplothtml,
    random_layout,
    circular_layout,
    spring_layout,
    spectral_layout,
    shell_layout,
    stressmajorize_layout,
    graphfamous,
    readedgelist

# layout algorithms
include("layout.jl")
include("stress.jl")

# ploting utilities
include("lines.jl")
include("plot.jl")

# read graph
include("graphio.jl")

function test()
	include(joinpath(Pkg.dir("GraphPlot"), "test", "runtests.jl"))
end

_nv{V}(g::Graphs.AbstractGraph{V}) = Graphs.num_vertices(g)
_nv(g::LightGraphs.SimpleGraph) = LightGraphs.nv(g)
_ne{V}(g::Graphs.AbstractGraph{V}) = Graphs.num_edges(g)
_ne(g::LightGraphs.SimpleGraph) = LightGraphs.ne(g)
_vertices{V}(g::Graphs.AbstractGraph{V}) = Graphs.vertices(g)
_vertices(g::LightGraphs.SimpleGraph) = LightGraphs.vertices(g)
_edges{V}(g::Graphs.AbstractGraph{V}) = Graphs.edges(g)
_edges(g::LightGraphs.SimpleGraph) = LightGraphs.edges(g)
_src_index{V}(e::Graphs.Edge{V}, g::Graphs.AbstractGraph{V}) = Graphs.vertex_index(Graphs.source(e), g)
_src_index(e::LightGraphs.Edge, g::LightGraphs.SimpleGraph) = LightGraphs.src(e)
_dst_index{V}(e::Graphs.Edge{V}, g::Graphs.AbstractGraph{V}) = Graphs.vertex_index(Graphs.target(e), g)
_dst_index(e::LightGraphs.Edge, g::LightGraphs.SimpleGraph) = LightGraphs.dst(e)
_adjacency_matrix{V}(g::Graphs.AbstractGraph{V}) = Graphs.adjacency_matrix(g)
_adjacency_matrix(g::LightGraphs.SimpleGraph) = LightGraphs.adjacency_matrix(g)
_is_directed{V}(g::Graphs.AbstractGraph{V}) = Graphs.is_directed(g)
_is_directed(g::LightGraphs.SimpleGraph) = LightGraphs.is_directed(g)
_laplacian_matrix{V}(g::Graphs.AbstractGraph{V}) = Graphs.laplacian_matrix(g)
_laplacian_matrix(g::LightGraphs.SimpleGraph) = LightGraphs.laplacian_matrix(g)
end # module
