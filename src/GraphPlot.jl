__precompile__(true)

module GraphPlot

using Compose  # for plotting features
using LightGraphs

const gadflyjs = joinpath(dirname(Base.source_path()), "gadfly.js")

export
    gplot,
    gplot1,
    gplothtml,
    gplothtml1,
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
include("shape.jl")
include("lines.jl")
include("plot.jl")
include("plot_test.jl")

# read graph
include("graphio.jl")

function test()
	include(joinpath(Pkg.dir("GraphPlot"), "test", "runtests.jl"))
end

    
# These functions are mappings to various graph packages.
# Currently only LightGraphs is supported.
_nv(g::LightGraphs.Graph) = LightGraphs.nv(g)
_ne(g::LightGraphs.Graph) = LightGraphs.ne(g)
_vertices(g::LightGraphs.Graph) = LightGraphs.vertices(g)
_edges(g::LightGraphs.Graph) = LightGraphs.edges(g)
_src_index(e::LightGraphs.Edge, g::LightGraphs.Graph) = LightGraphs.src(e)
_dst_index(e::LightGraphs.Edge, g::LightGraphs.Graph) = LightGraphs.dst(e)
_adjacency_matrix(g::LightGraphs.Graph) = LightGraphs.adjacency_matrix(g)
_is_directed(g::LightGraphs.Graph) = LightGraphs.is_directed(g)
_laplacian_matrix(g::LightGraphs.Graph) = LightGraphs.laplacian_matrix(g)
end # module
