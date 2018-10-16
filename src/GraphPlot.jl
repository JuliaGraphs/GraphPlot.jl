module GraphPlot

using Compose  # for plotting features
using LightGraphs

const gadflyjs = joinpath(dirname(Base.source_path()), "gadfly.js")

export
    gplot,
    gplothtml,
    random_layout,
    circular_layout,
    collapse_layout,
    community_layout,
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
include("collapse_plot.jl")

# read graph
include("graphio.jl")


# These functions are mappings to various graph packages.
# Currently only LightGraphs is supported.
_nv(g::LightGraphs.AbstractGraph) = LightGraphs.nv(g)
_ne(g::LightGraphs.AbstractGraph) = LightGraphs.ne(g)
_vertices(g::LightGraphs.AbstractGraph) = LightGraphs.vertices(g)
_edges(g::LightGraphs.AbstractGraph) = LightGraphs.edges(g)
_src_index(e::LightGraphs.AbstractEdge, g::LightGraphs.AbstractGraph) = LightGraphs.src(e)
_dst_index(e::LightGraphs.AbstractEdge, g::LightGraphs.AbstractGraph) = LightGraphs.dst(e)
_adjacency_matrix(g::LightGraphs.AbstractGraph) = LightGraphs.adjacency_matrix(g)
_is_directed(g::LightGraphs.AbstractGraph) = LightGraphs.is_directed(g)
_laplacian_matrix(g::LightGraphs.AbstractGraph) = LightGraphs.laplacian_matrix(g)
end # module
