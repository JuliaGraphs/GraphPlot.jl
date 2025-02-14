@info "Importing test packages..."
# This should fix an error, see : https://github.com/JuliaIO/ImageMagick.jl/issues/133
(Sys.islinux() || Sys.iswindows()) && import ImageMagick

using GraphPlot
using GraphPlot.Graphs
using Cairo
using GraphPlot.Colors
using GraphPlot.Compose
using Random
using Test
using VisualRegressionTests
using ImageMagick

# global variables
istravis = "TRAVIS" ∈ keys(ENV)
datadir = joinpath(@__DIR__, "data")


@info "Starting tests..."


# TODO smallgraph(:karate) has already been added to Graphs
# but as there hasn't been any new version tagged, we relay on this instead
karate_edges = Edge.([
  1 => 2,   1 => 3,   1 => 4,   1 => 5,   1 => 6,   1 => 7,
  1 => 8,   1 => 9,   1 => 11,  1 => 12,  1 => 13,  1 => 14,
  1 => 18,  1 => 20,  1 => 22,  1 => 32,  2 => 3,   2 => 4,
  2 => 8,   2 => 14,  2 => 18,  2 => 20,  2 => 22,  2 => 31,
  3 => 4,   3 => 8,   3 => 9,   3 => 10,  3 => 14,  3 => 28,
  3 => 29,  3 => 33,  4 => 8,   4 => 13 , 4 => 14,  5 => 7,
  5 => 11,  6 => 7,   6 => 11,  6 => 17 , 7 => 17,  9 => 31,
  9 => 33,  9 => 34, 10 => 34, 14 => 34, 15 => 33, 15 => 34,
 16 => 33, 16 => 34, 19 => 33, 19 => 34, 20 => 34, 21 => 33,
 21 => 34, 23 => 33, 23 => 34, 24 => 26, 24 => 28, 24 => 30,
 24 => 33, 24 => 34, 25 => 26, 25 => 28, 25 => 32, 26 => 32,
 27 => 30, 27 => 34, 28 => 34, 29 => 32, 29 => 34, 30 => 33,
 30 => 34, 31 => 33, 31 => 34, 32 => 33, 32 => 34, 33 => 34,
])
# graphs to test
#g = smallgraph(:karate)
g = SimpleGraph(karate_edges)
h = Graphs.wheel_graph(10)

test_layout(g::AbstractGraph; kws...) = spring_layout(g, 2017, kws...)

# plot and save function for visual regression tests
# TODO visual regression tests are currently broken for higher Julia versions
@static if VERSION < v"1.7"
    function plot_and_save(fname, g; gplot_kwargs...)
        draw(PNG(fname, 8inch, 8inch), gplot(g; layout=test_layout, gplot_kwargs...))
    end

    function save_comparison(result::VisualTestResult)
        grid = hcat(result.refImage, result.testImage)
        path = joinpath(datadir, string(basename(result.refFilename)[1:end-length(".png")], "-comparison.png"))
        ImageMagick.save(path, grid)
        return result
    end
end

@static if VERSION < v"1.7"
    @testset "Karate Net" begin
        # auxiliary variables
        nodelabel = collect(1:nv(g))
        nodesize = outdegree(g) .* 1.0

    # test nodesize
        plot_and_save1(fname) = plot_and_save(fname, g, nodesize=nodesize.^0.3, nodelabel=nodelabel, nodelabelsize=nodesize.^0.3)
        refimg1 = joinpath(datadir, "karate_different_nodesize.png")
        @test test_images(VisualTest(plot_and_save1, refimg1), popup=!istravis) |> save_comparison |> success


            # test directed graph
        plot_and_save2(fname) = plot_and_save(fname, g, arrowlengthfrac=0.05, nodelabel=nodelabel, font_family="Sans")
        refimg2 = joinpath(datadir, "karate_straight_directed.png")
        @test test_images(VisualTest(plot_and_save2, refimg2), popup=!istravis) |> save_comparison |> success

        # test node membership
        membership = [1,1,1,1,1,1,1,1,2,1,1,1,1,1,2,2,1,1,2,1,2,1,2,2,2,2,2,2,2,2,2,2,2,2]
        nodecolor = [colorant"lightseagreen", colorant"orange"]
        nodefillc = nodecolor[membership]

        plot_and_save3(fname) = plot_and_save(fname, g, nodelabel=nodelabel, nodefillc=nodefillc)
        refimg3 = joinpath(datadir, "karate_groups.png")
        @test test_images(VisualTest(plot_and_save3, refimg3), popup=!istravis) |> save_comparison |> success

    # test background color
        plot_and_save4(fname) = plot_and_save(fname, g, background_color=colorant"lightyellow")
        refimg4 = joinpath(datadir, "karate_background_color.png")
        @test test_images(VisualTest(plot_and_save4, refimg4), popup=!istravis) |> save_comparison |> success
    end
end

@static if VERSION < v"1.7"
    @testset "WheelGraph" begin
        # default options
        plot_and_save1(fname) = plot_and_save(fname, h)
        refimg1 = joinpath(datadir, "wheel10.png")
        @test test_images(VisualTest(plot_and_save1, refimg1), popup=!istravis) |> save_comparison |> success
    end
end

@static if VERSION < v"1.7"
    @testset "Curves" begin

        g2 = DiGraph(2)
        add_edge!(g2, 1,2)
        add_edge!(g2, 2,1)

        plot_and_save1(fname) = plot_and_save(fname, g2, linetype="curve", arrowlengthfrac=0.2, pad=5mm)
        refimg1 = joinpath(datadir, "curve.png")
        @test test_images(VisualTest(plot_and_save1, refimg1), popup=!istravis) |> save_comparison |> success

        g3 = DiGraph(2)
        add_edge!(g3, 1,1)
        add_edge!(g3, 1,2)
        add_edge!(g3, 2,1)

        plot_and_save2(fname) = plot_and_save(fname, g3, linetype="curve", arrowlengthfrac=0.2, leftpad=20mm, toppad=3mm, bottompad=3mm)
        refimg2 = joinpath(datadir, "self_directed.png")
        @test test_images(VisualTest(plot_and_save2, refimg2), popup=!istravis) |> save_comparison |> success
    end
end

@testset "Spring Layout" begin
    g1 = path_digraph(3)
    x1, y1 = spring_layout(g1, 0; C = 1)
    # TODO spring_layout uses random values which have changed on higher Julia versions
    #   we should therefore use StableRNGs.jl for these layouts
    @static if VERSION < v"1.7"
        @test all(isapprox.(x1, [1.0, -0.014799825222963192, -1.0]))
        @test all(isapprox.(y1, [-1.0, 0.014799825222963303, 1.0]))
    end
end

@testset "Circular Layout" begin
    #single node
    g1 = SimpleGraph(1)
    x1,y1 = circular_layout(g1)
    @test iszero(x1)
    @test iszero(y1)
    #2 nodes
    g2 = SimpleGraph(2)
    x2,y2 = circular_layout(g2)
    @test all(isapprox.(x2, [1.0, -1.0]))
    @test all(isapprox.(y2, [0.0, 1.2246467991473532e-16]))
end

@testset "Shell Layout" begin
    #continuous nlist
    g = SimpleGraph(6)
    x1,y1 = shell_layout(g,[[1,2,3],[4,5,6]])
    @test all(isapprox.(x1, [1.0, -0.4999999999999998, -0.5000000000000004, 2.0, -0.9999999999999996, -1.0000000000000009]))
    @test all(isapprox.(y1, [0.0, 0.8660254037844387, -0.8660254037844385, 0.0, 1.7320508075688774, -1.732050807568877]))
    #skipping positions
    x2,y2 = shell_layout(g,[[1,3,5],[2,4,6]])
    @test all(isapprox.(x2, [1.0, 2.0, -0.4999999999999998, -0.9999999999999996, -0.5000000000000004, -1.0000000000000009]))
    @test all(isapprox.(y2, [0.0, 0.0, 0.8660254037844387, 1.7320508075688774, -0.8660254037844385, -1.732050807568877]))
end
