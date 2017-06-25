using GraphPlot
using LightGraphs
using Colors
using Compose
using Base.Test

g = graphfamous("karate")
h = LightGraphs.WheelGraph(10)

nodelabel = collect(1:nv(g))
nodesize = outdegree(g) .* 1.0

cachedout = joinpath(Pkg.dir("GraphPlot"), "test", "examples")

@testset "Undirected Karate Net" begin
    filename = joinpath(cachedout, "karate_different_nodesize.svg")
    draw(SVG(filename, 8inch, 8inch), gplot(g, nodesize=nodesize.^0.3, nodelabel=nodelabel, nodelabelsize=nodesize.^0.3))
end

@testset "Directed Karate Net" begin
    filename = joinpath(cachedout, "karate_straight_directed.svg")
    draw(SVG(filename, 10inch, 10inch), gplot(g, arrowlengthfrac=0.02, nodelabel=nodelabel))
end

@testset "Membership" begin
    # nodes membership
    membership = [1,1,1,1,1,1,1,1,2,1,1,1,1,1,2,2,1,1,2,1,2,1,2,2,2,2,2,2,2,2,2,2,2,2]
    nodecolor = [colorant"lightseagreen", colorant"orange"]
    # membership color
    nodefillc = nodecolor[membership]
    filename = joinpath(cachedout, "karate_groups.svg")
    draw(SVG(filename, 8inch, 8inch), gplot(g, nodelabel=nodelabel, nodefillc=nodefillc))
end

@testset "WheelGraph" begin
    filename = joinpath(cachedout, "LightGraphs_wheel10.svg")
    draw(SVG(filename, 8inch, 8inch), gplot(h))
end
