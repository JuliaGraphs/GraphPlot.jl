module GraphPlot
if VERSION < v"0.4.0"
    using Docile
end
using Compat
using Graphs
using Compose  # for plotting features

export
    gdraw,
    gplot,
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


# for ploting LightGraphs
include("lightgraphplot.jl")

# read graph
include("graphio.jl")

end # module
