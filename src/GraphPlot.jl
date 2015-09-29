module GraphPlot
    if VERSION < v"0.4.0"
        using Docile
    end
    using Graphs
    using LightGraphs # for plot LightGraph directly
    using Compose  # for plotting features

    typealias LightGraph Union(LightGraphs.Graph, LightGraphs.DiGraph)

    export
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
    include("plot.jl")

    # read graph
    include("graphio.jl")

end # module
