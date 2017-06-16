using FactCheck
using GraphPlot
using LightGraphs
using Colors
using Compose


example_dir = joinpath(dirname(@__FILE__), "examples")
facts("LightGraphs test") do
    facts("wheel graph printed ok") do
        h = LightGraphs.WheelGraph(10)
        filename = joinpath(example_dir, "wheel10.svg")
        draw(SVG(filename, 8inch, 8inch), gplot(h))
    end
    facts("grid network (undirected), nodesize is proportional to its degree") do
        g = LightGraphs.StarGraph(6)
        LightGraphs.add_edge!(g, 2, 3)
        filename = joinpath(example_dir, "grid_different_nodesize.svg")
        nodesize = outdegree(g) .* 1.0
        nodelabel = collect(1:LightGraphs.nv(g))
        draw(SVG(filename, 8inch, 8inch), gplot(g, nodesize=nodesize.^0.3, nodelabel=nodelabel, nodelabelsize=nodesize.^0.3))
    end

    facts("grid network as directed") do
        FactCheck.context("straight line edge") do
            g = LightGraphs.Grid([4,4])
            nodelabel = collect(1:LightGraphs.nv(g))
            filename = joinpath(example_dir, "grid_straight_directed.svg")
            draw(SVG(filename, 10inch, 10inch), gplot(g, arrowlengthfrac=0.02, nodelabel=nodelabel))
        end
    end

    facts("Nodes in different memberships have different colors (grid network)") do
        # nodes membership
        g = LightGraphs.Grid([4,4])
    	membership = rand([1,2], LightGraphs.nv(g))
    	nodecolor = [colorant"lightseagreen", colorant"orange"]
    	# membership color
    	nodefillc = nodecolor[membership]
        nodelabel = collect(1:LightGraphs.nv(g))
        filename = joinpath(example_dir, "grid_groups.svg")
        draw(SVG(filename, 8inch, 8inch), gplot(g, nodelabel=nodelabel, nodefillc=nodefillc))
    end

end
