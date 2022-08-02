module GraphPlot

using Compose  # for plotting features
using Graphs

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
    stressmajorize_layout

# layout algorithms
include("layout.jl")

# ploting utilities
include("lines.jl")
include("plot.jl")

end # module
