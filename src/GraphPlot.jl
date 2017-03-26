__precompile__(true)

module GraphPlot

using Compose  # for plotting features
using LightGraphs

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
include("shape.jl")
include("lines.jl")
include("plot.jl")

# read graph
include("graphio.jl")


# These functions are mappings to various graph packages.
# Currently only LightGraphs is supported.
_nv(g::LightGraphs.SimpleGraph) = LightGraphs.nv(g)
_ne(g::LightGraphs.SimpleGraph) = LightGraphs.ne(g)
_vertices(g::LightGraphs.SimpleGraph) = LightGraphs.vertices(g)
_edges(g::LightGraphs.SimpleGraph) = LightGraphs.edges(g)
_src_index(e::LightGraphs.Edge, g::LightGraphs.SimpleGraph) = LightGraphs.src(e)
_dst_index(e::LightGraphs.Edge, g::LightGraphs.SimpleGraph) = LightGraphs.dst(e)
_adjacency_matrix(g::LightGraphs.SimpleGraph) = LightGraphs.adjacency_matrix(g)
_is_directed(g::LightGraphs.SimpleGraph) = LightGraphs.is_directed(g)
_laplacian_matrix(g::LightGraphs.SimpleGraph) = LightGraphs.laplacian_matrix(g)
end # module
