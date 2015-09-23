using FactCheck
using GraphPlot
using Graphs
using Colors

cachedout = joinpath(Pkg.dir("GraphLayout"), "test", "examples")
facts("random_layout") do
    context("simple_house_graph") do
        g = simple_house_graph()
        filename = joinpath(cachedout, "simple_house_random.svg")
        GraphPlot.plot(g, filename=filename)
    end
    context("simple_wheel_graph") do
        g = simple_wheel_graph(10)
        filename = joinpath(cachedout, "simple_wheel_random.svg")
        GraphPlot.plot(g, filename=filename)
    end
end

facts("circular_layout") do
    context("simple_house_graph") do
        g = simple_house_graph()
        filename = joinpath(cachedout, "simple_house_circular.svg")
        GraphPlot.plot(g, filename=filename, layout=circular_layout)
    end
    context("simple_wheel_graph") do
        g = simple_wheel_graph(10)
        filename = joinpath(cachedout, "simple_wheel_circular.svg")
        GraphPlot.plot(g, filename=filename, layout=circular_layout)
    end
end

facts("Nodes have different colors and their size are proportional to their degree") do
    context("simple_house_graph") do
        g = simple_house_graph()
        nodesize = Float64[out_degree(v, g) for v in vertices(g)]
        # Generate n maximally distinguishable colors in LCHab space.
        nodefillc = distinguishable_colors(num_vertices(g), colorant"red")
        filename = joinpath(cachedout, "simple_house_graph.svg")
        GraphPlot.plot(g, filename=filename, layout=circular_layout,
             nodefillc=nodefillc, nodesize=nodesize)
    end
    context("simple_wheel_graph") do
        g = simple_wheel_graph(10)
        nodesize = Float64[out_degree(v, g) for v in vertices(g)]
        nodefillc = distinguishable_colors(num_vertices(g), colorant"red")
        filename = joinpath(cachedout, "simple_wheel_graph.svg")
        GraphPlot.plot(g, filename=filename, layout=circular_layout,
             nodefillc=nodefillc, nodesize=nodesize)
    end
end
