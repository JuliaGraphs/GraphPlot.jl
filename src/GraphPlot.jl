VERSION > v"0.4-" && __precompile__()

module GraphPlot
if VERSION < v"0.4.0"
    using Docile
end
using Compat
using Graphs
using LightGraphs
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


# for ploting LightGraphs
#include("lightgraphplot.jl")

# read graph
include("graphio.jl")

if VERSION >= v"0.4.0-dev+5512"
    include("precompile.jl")
    _precompile_()
end

function test()
	include(joinpath(Pkg.dir("GraphPlot"), "test", "runtests.jl"))
end

end # module
