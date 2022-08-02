using Colors

# this function is copy from [GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl) and make some modifications.
"""
Given a graph and two vectors of X and Y coordinates, returns
a Compose tree of the graph layout

**Arguments**

`G`
Graph to draw

`locs_x, locs_y`
Locations of the nodes. Can be any units you want,
but will be normalized and centered anyway. If not provided, will
be obtained from `layout` kwarg.

**Keyword Arguments**

`layout`
Layout algorithm. Currently can be one of [`random_layout`,
`circular_layout`, `spring_layout`, `shell_layout`, `stressmajorize_layout`,
`spectral_layout`, `community_layout`].
Default: `spring_layout`

`max_nodesize`
Max size for the nodes. Default: `3.0/sqrt(N)`

`nodesize`
Relative size for the nodes, can be a Vector. Default: `1.0`

`nodelabel`
Labels for the vertices, a Vector or nothing. Default: `nothing`

`nodelabelc`
Color for the node labels, can be a Vector. Default: `colorant"black"`

`nodelabeldist`
Distances for the node labels from center of nodes. Default: `0.0`

`nodelabelangleoffset`
Angle offset for the node labels (only used when `nodelabeldist` is not zero). Default: `π/4.0`

<<<<<<< HEAD
`max_nodelabelsize`
Largest fontsize for the vertex labels. Default: `4.0`

`nodelabelsize`
Relative fontsize for the vertice labels, can be a Vector. Default: `1.0`

`nodefillc`
Color to fill the nodes with, can be a Vector. Default: `colorant"turquoise"`

`nodestrokec`
Color for the nodes stroke, can be a Vector. Default: `nothing`

`nodestrokelw`
Line width for the nodes stroke, can be a Vector. Default: `0.0`

`edgelabel`
Labels for the edges, a Vector or nothing. Default: `nothing`

`edgelabelc`
Color for the edge labels, can be a Vector. Default: `colorant"black"`

`edgelabeldistx, edgelabeldisty`
Distance for the edge label from center of edge. Default: `0.0`

`max_edgelabelsize`
Largest fontsize for the edge labels. Default: `4.0`

`edgelabelsize`
Relative fontsize for the edge labels, can be a Vector. Default: `1.0`

`max_edgelinewidth`
Max line width for the edges. Default: `0.25/sqrt(N)`

`edgelinewidth`
Relative line width for the edges, can be a Vector. Default: `1.0`

`edgestrokec`
Color for the edge strokes, can be a Vector. Default: `colorant"lightgray"`

`arrowlengthfrac`
Fraction of line length to use for arrows.
Equal to 0 for undirected graphs. Default: `0.1` for the directed graphs

`arrowangleoffset`
Angular width in radians for the arrows. Default: `π/9 (20 degrees)`

`linetype`
Type of line used for edges (:straight, :curve). Default: :straight

`outangle`
Angular width in radians for the edges (only used if `linetype = "curve`). 
Default: `π/5 (36 degrees)`

"""
function gplot(g::AbstractGraph{T},
    locs_x_in::Vector{R1}, locs_y_in::Vector{R2};
    nodelabel = nothing,
    nodelabelc = colorant"black",
    nodelabelsize = 1.0,
    max_nodelabelsize = 4.0,
    nodelabeldist = 0.0,
    nodelabelangleoffset = π / 4.0,
    edgelabel = nothing,
    edgelabelc = colorant"black",
    edgelabelsize = 1.0,
    max_edgelabelsize = 4.0,
    edgestrokec = colorant"lightgray",
    edgelinewidth = 1.0,
    max_edgelinewidth = 3.0 / sqrt(nv(g)),
    edgelabeldistx = 0.0,
    edgelabeldisty = 0.0,
    nodesize = 1.0,
    max_nodesize = 0.25 / sqrt(nv(g)),
    nodefillc = colorant"turquoise",
    nodestrokec = nothing,
    nodestrokelw = 0.0,
    arrowlengthfrac = is_directed(g) ? 0.1 : 0.0,
    arrowangleoffset = π / 9,
    linetype = :straight,
    outangle = π / 5) where {T <:Integer, R1 <: Real, R2 <: Real}

    @assert length(locs_x_in) == length(locs_y_in) == nv(g) "Position vectors must be of the same length as the number of nodes"
    @assert isnothing(nodelabel) || length(nodelabel) == nv(g) "`nodelabel` must either be `nothing` or a vector of the same length as the number of nodes"
    @assert isnothing(edgelabel) || length(edgelabel) == ne(g) "`edgelabel` must either be `nothing` or a vector of the same length as the number of edges"

    locs_x = Float64.(locs_x_in)
    locs_y = Float64.(locs_y_in)

    # Scale to unit square
    min_x, max_x = extrema(locs_x)
    min_y, max_y = extrema(locs_y)
    function scaler(z, a, b)
        if (a - b) == 0.0
            return 0.5
        else
            return 2.0 * ((z - a) / (b - a)) - 1.0
        end
    end
    map!(z -> scaler(z, min_x, max_x), locs_x, locs_x)
    map!(z -> scaler(z, min_y, max_y), locs_y, locs_y)

    # Scale sizes
    nodesize *= (max_nodesize / maximum(nodesize))
    edgelinewidth *= (max_edgelinewidth / maximum(edgelinewidth))
    edgelabelsize *= (max_edgelabelsize / maximum(edgelabelsize))
    nodelabelsize *= (max_nodelabelsize / maximum(nodelabelsize))
    max_nodestrokelw = maximum(nodestrokelw)
    if !iszero(max_nodestrokelw)
        nodestrokelw *= (max_edgelinewidth / max_nodestrokelw)
    end

    # Create nodes
    nodecircle = fill(0.4Compose.w, nv(g)) .* nodesize
    nodes = circle(locs_x, locs_y, nodecircle)

    # Create node labels if provided
    texts = nothing
    if nodelabel != nothing
        text_locs_x = deepcopy(locs_x)
        text_locs_y = deepcopy(locs_y)
        texts = text(text_locs_x .+ nodesize .* (nodelabeldist * cos(nodelabelangleoffset)),
                     text_locs_y .- nodesize .* (nodelabeldist * sin(nodelabelangleoffset)),
                     map(string, nodelabel), [hcenter], [vcenter])
    end
    # Create edge labels if provided
    edgetexts = nothing
    if !isnothing(edgelabel)
        edge_locs_x = zeros(R, NE)
        edge_locs_y = zeros(R, NE)
        for (e_idx, e) in enumerate(edges(g))
            i = src(e)
            j = dst(e)
            mid_x = (locs_x[i]+locs_x[j]) / 2.0
            mid_y = (locs_y[i]+locs_y[j]) / 2.0
            edge_locs_x[e_idx] = (is_directed(g) ? (mid_x+locs_x[j]) / 2.0 : mid_x) + edgelabeldistx * max_nodesize
            edge_locs_y[e_idx] = (is_directed(g) ? (mid_y+locs_y[j]) / 2.0 : mid_y) + edgelabeldisty * max_nodesize
        end
        edgetexts = text(edge_locs_x, edge_locs_y, map(string, edgelabel), [hcenter], [vcenter])
    end

    # Create lines and arrow heads
    lines, arrows = nothing, nothing
    if linetype == :curve
        if !iszero(arrowlengthfrac)
            curves_cord, arrows_cord = graphcurve(g, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset, outangle)
            lines = curve(curves_cord[:,1], curves_cord[:,2], curves_cord[:,3], curves_cord[:,4])
            arrows = line(arrows_cord)
        else
            curves_cord = graphcurve(g, locs_x, locs_y, nodesize, outangle)
            lines = curve(curves_cord[:,1], curves_cord[:,2], curves_cord[:,3], curves_cord[:,4])
        end
    else
        if !iszero(arrowlengthfrac)
            lines_cord, arrows_cord = graphline(g, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset)
            lines = line(lines_cord)
            arrows = line(arrows_cord)
        else
            lines_cord = graphline(g, locs_x, locs_y, nodesize)
            lines = line(lines_cord)
        end
    end

    #build plot
    compose(context(units=UnitBox(-1.2, -1.2, +2.4, +2.4)),
            compose(context(), texts, fill(nodelabelc), fontsize(nodelabelsize)),
            compose(context(), nodes, fill(nodefillc), stroke(nodestrokec), linewidth(nodestrokelw)),
            compose(context(), edgetexts, fill(edgelabelc), fontsize(edgelabelsize)),
            compose(context(), arrows, stroke(edgestrokec), linewidth(edgelinewidth)),
            compose(context(), lines, stroke(edgestrokec), linewidth(edgelinewidth)))
end

function gplot(g; layout::Function=spring_layout, keyargs...)
    gplot(g, layout(g)...; keyargs...)
end

# take from [Gadfly.jl](https://github.com/dcjones/Gadfly.jl)
function open_file(filename)
    if Sys.isapple() #apple
        run(`open $(filename)`)
    elseif Sys.islinux() || Sys.isbsd() #linux
        run(`xdg-open $(filename)`)
    elseif Sys.iswindows() #windows
        run(`$(ENV["COMSPEC"]) /c start $(filename)`)
    else
        @warn("Showing plots is not supported on OS $(string(Sys.KERNEL))")
    end
end

# taken from [Gadfly.jl](https://github.com/dcjones/Gadfly.jl)
function gplothtml(args...; keyargs...)
    filename = string(tempname(), ".html")
    output = open(filename, "w")

    plot_output = IOBuffer()
    draw(SVGJS(plot_output, Compose.default_graphic_width,
               Compose.default_graphic_width, false), gplot(args...; keyargs...))
    plotsvg = String(take!(plot_output))

    write(output,
        """
        <!DOCTYPE html>
        <html>
          <head>
            <title>GraphPlot Plot</title>
            <meta charset="utf-8">
          </head>
            <body>
            <script charset="utf-8">
                $(read(Compose.snapsvgjs, String))
            </script>
            <script charset="utf-8">
                $(read(gadflyjs, String))
            </script>
            $(plotsvg)
          </body>
        </html>
        """)
    close(output)
    open_file(filename)
end
