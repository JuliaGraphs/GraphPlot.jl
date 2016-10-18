using FactCheck
using GraphPlot
using LightGraphs
using Colors
using Compose

g = graphfamous("karate")
h = LightGraphs.WheelGraph(10)

nodelabel = collect(1:nv(g))
nodesize = outdegree(g) .* 1.0

cachedout = joinpath(Pkg.dir("GraphPlot"), "test", "examples")
facts("karate network (undirected), nodesize is proportion to its degree") do
    filename = joinpath(cachedout, "karate_different_nodesize.svg")
    draw(SVG(filename, 8inch, 8inch), gplot(g, nodesize=nodesize.^0.3, nodelabel=nodelabel, nodelabelsize=nodesize.^0.3))
end

facts("karate network as directed") do
    FactCheck.context("straight line edge") do
        filename = joinpath(cachedout, "karate_straight_directed.svg")
        draw(SVG(filename, 10inch, 10inch), gplot(g, arrowlengthfrac=0.02, nodelabel=nodelabel))
    end
end

facts("Nodes in different memberships have different colors (karate network)") do
    # nodes membership
	membership = [1,1,1,1,1,1,1,1,2,1,1,1,1,1,2,2,1,1,2,1,2,1,2,2,2,2,2,2,2,2,2,2,2,2]
	nodecolor = [colorant"lightseagreen", colorant"orange"]
	# membership color
	nodefillc = nodecolor[membership]
    filename = joinpath(cachedout, "karate_groups.svg")
    draw(SVG(filename, 8inch, 8inch), gplot(g, nodelabel=nodelabel, nodefillc=nodefillc))
end

facts("LightGraphs test") do
    filename = joinpath(cachedout, "LightGraphs_wheel10.svg")
    draw(SVG(filename, 8inch, 8inch), gplot(h))
end
