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
    stressmajorize_layout

include("deprecations.jl")

# layout algorithms
include("layout.jl")
include("stress.jl")

# ploting utilities
include("shape.jl")
include("lines.jl")
include("plot.jl")
include("collapse_plot.jl")

end # module
