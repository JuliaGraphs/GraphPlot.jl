using GraphPlot
using LightGraphs
using Cairo
using Colors
using Compose
using Random
using Test
using VisualRegressionTests

# global variables
istravis = "TRAVIS" ∈ keys(ENV)
datadir = joinpath(@__DIR__, "data")

# graphs to test
g = graphfamous("karate")
h = LightGraphs.WheelGraph(10)

# plot and save function for visual regression tests
function plot_and_save(fname, g; gplot_kwargs...)
    Random.seed!(2017)
    draw(PNG(fname, 8inch, 8inch), gplot(g; gplot_kwargs...))
end

@testset "Karate Net" begin
    # auxiliary variables
    nodelabel = collect(1:nv(g))
    nodesize = outdegree(g) .* 1.0

    # test nodesize
    plot_and_save1(fname) = plot_and_save(fname, g, nodesize=nodesize.^0.3, nodelabel=nodelabel, nodelabelsize=nodesize.^0.3)
    refimg1 = joinpath(datadir, "karate_different_nodesize.png")
    @test test_images(VisualTest(plot_and_save1, refimg1), popup=!istravis) |> success

    # test directed graph
    plot_and_save2(fname) = plot_and_save(fname, g, arrowlengthfrac=0.02, nodelabel=nodelabel)
    refimg2 = joinpath(datadir, "karate_straight_directed.png")
    @test test_images(VisualTest(plot_and_save2, refimg2), popup=!istravis) |> success

    # test node membership
    membership = [1,1,1,1,1,1,1,1,2,1,1,1,1,1,2,2,1,1,2,1,2,1,2,2,2,2,2,2,2,2,2,2,2,2]
    nodecolor = [colorant"lightseagreen", colorant"orange"]
    nodefillc = nodecolor[membership]
    plot_and_save3(fname) = plot_and_save(fname, g, nodelabel=nodelabel, nodefillc=nodefillc)
    refimg3 = joinpath(datadir, "karate_groups.png")
    @test test_images(VisualTest(plot_and_save3, refimg3), popup=!istravis) |> success
end

@testset "WheelGraph" begin
    # default options
    plot_and_save1(fname) = plot_and_save(fname, h)
    refimg1 = joinpath(datadir, "wheel10.png")
    @test test_images(VisualTest(plot_and_save1, refimg1), popup=!istravis) |> success
end
