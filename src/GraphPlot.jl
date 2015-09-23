module GraphPlot
    if VERSION < v"0.4.0"
        using Docile
    end
    using Graphs
    using Compose  # for plotting features
    import Graphs.plot

    # layout algorithms
    export random_layout, circular_layout
    include("layout.jl")

    # ploting utilities
    export plot
    include("plot.jl")

end # module
