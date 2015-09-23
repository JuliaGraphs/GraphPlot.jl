using FactCheck
using GraphPlot
using Graphs
using Colors

facts("random_layout") do
    context("simple_house_graph") do
        g = simple_house_graph()
        GraphPlot.plot(g, filename="simple_house_random.svg")
    end
    context("simple_wheel_graph") do
        g = simple_wheel_graph(10)
        GraphPlot.plot(g, filename="simple_wheel_random.svg")
    end
end

facts("circular_layout") do
    context("simple_house_graph") do
        g = simple_house_graph()
        GraphPlot.plot(g, filename="simple_house_circular.svg", layout=circular_layout)
    end
    context("simple_wheel_graph") do
        g = simple_wheel_graph(10)
        GraphPlot.plot(g, filename="simple_wheel_circular.svg", layout=circular_layout)
    end
end

facts("Nodes have different colors and their size are proportional to their degree") do
    context("simple_house_graph") do
        g = simple_house_graph()
        nodesize = Float64[out_degree(v, g) for v in vertices(g)]
        # Generate n maximally distinguishable colors in LCHab space.
        nodefillc = distinguishable_colors(num_vertices(g), colorant"red")
        GraphPlot.plot(g, filename="simple_house_graph.svg", layout=circular_layout,
             nodefillc=nodefillc, nodesize=nodesize)
    end
    context("simple_wheel_graph") do
        g = simple_wheel_graph(10)
        nodesize = Float64[out_degree(v, g) for v in vertices(g)]
        nodefillc = distinguishable_colors(num_vertices(g), colorant"red")
        GraphPlot.plot(g, filename="simple_wheel_graph.svg", layout=circular_layout,
             nodefillc=nodefillc, nodesize=nodesize)
    end
end
