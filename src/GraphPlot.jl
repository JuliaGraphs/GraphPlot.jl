module GraphPlot
    if VERSION < v"0.4.0"
        using Docile
    end
    using Graphs
    using Compose  # for plotting features

    # layout algorithms
    export random_layout, circular_layout, spring_layout, stressmajorize_layout
    include("layout.jl")
    include("stress.jl")

    # ploting utilities
    export gplot
    include("plot.jl")

end # module
