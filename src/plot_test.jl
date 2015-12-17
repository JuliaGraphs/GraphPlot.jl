using Colors

# this function is copy from [GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl) and make some modifications.
"""
Given a graph and two vectors of X and Y coordinates, returns
a Compose tree of the graph layout

**Arguments**

`G`
Graph to draw

`layout`
Optional. Layout algorithm. Currently can be one of [random_layout,
circular_layout, spring_layout, shell_layout, stressmajorize_layout,
spectral_layout].
Default: `spring_layout`

`locs_x, locs_y`
Locations of the nodes. Can be any units you want,
but will be normalized and centered anyway

`NODESIZE`
Optional. Max size for the nodes. Default: `3.0/sqrt(N)`

`nodesize`
Optional. Relative size for the nodes, can be a Vector. Default: `1.0`

`nodelabel`
Optional. Labels for the vertices, a Vector or nothing. Default: `nothing`

`nodelabelc`
Optional. Color for the node labels, can be a Vector. Default: `colorant"black"`

`nodelabeldist`
Optional. Distances for the node labels from center of nodes. Default: `0.0`

`nodelabelangleoffset`
Optional. Angle offset for the node labels. Default: `π/4.0`

`NODELABELSIZE`
Optional. Largest fontsize for the vertice labels. Default: `4.0`

`nodelabelsize`
Optional. Relative fontsize for the vertice labels, can be a Vector. Default: `1.0`

`nodefillc`
Optional. Color to fill the nodes with, can be a Vector. Default: `colorant"turquoise"`

`nodestrokec`
Optional. Color for the nodes stroke, can be a Vector. Default: `nothing`

`nodestrokelw`
Optional. Line width for the nodes stroke, can be a Vector. Default: `0.0`

`edgelabel`
Optional. Labels for the edges, a Vector or nothing. Default: `nothing`

`edgelabelc`
Optional. Color for the edge labels, can be a Vector. Default: `colorant"black"`

`edgelabeldistx, edgelabeldisty`
Optional. Distance for the edge label from center of edge. Default: `0.0`

`EDGELABELSIZE`
Optional. Largest fontsize for the edge labels. Default: `4.0`

`edgelabelsize`
Optional. Relative fontsize for the edge labels, can be a Vector. Default: `1.0`

`EDGELINEWIDTH`
Optional. Max line width for the edges. Default: `0.25/sqrt(N)`

`edgelinewidth`
Optional. Relative line width for the edges, can be a Vector. Default: `1.0`

`edgestrokec`
Optional. Color for the edge strokes, can be a Vector. Default: `colorant"lightgray"`

`arrowlengthfrac`
Optional. Fraction of line length to use for arrows.
Equal to 0 for undirected graphs. Default: `0.1` for the directed graphs

`arrowangleoffset`
Optional. Angular width in radians for the arrows. Default: `π/9 (20 degrees)`

"""
function gplot1{T<:Real}(G,
    locs_x::Vector{T}, locs_y::Vector{T};
    nodelabel = nothing,
    nodelabelc = colorant"black",
    nodelabelsize = 1.0,
    NODELABELSIZE = 4.0,
    nodelabeldist = 0.0,
    nodelabelangleoffset = π/4.0,
    edgelabel = nothing,
    edgelabelc = colorant"black",
    edgelabelsize = 1.0,
    EDGELABELSIZE = 4.0,
    edgestrokec = colorant"lightgray",
    edgelinewidth = 1.0,
    EDGELINEWIDTH = 3.0/sqrt(_nv(G)),
    edgelabeldistx = 0.0,
    edgelabeldisty = 0.0,
    nodesize = 1.0,
    NODESIZE = 0.25/sqrt(_nv(G)),
    nodefillc = colorant"turquoise",
    nodestrokec = nothing,
    nodestrokelw = 0.0,
    nodeshape = 0,
    shaperot = 0.0,
    arrowlengthfrac = _is_directed(G) ? 0.1 : 0.0,
    arrowangleoffset = π/9.0,
    linetype = "straight",
    outangle = pi/5)

    length(locs_x) != length(locs_y) && error("Vectors must be same length")
    const N = _nv(G)
    const NE = _ne(G)
    if nodelabel != nothing && length(nodelabel) != N
        error("Must have one label per node (or none)")
    end
    if edgelabel != nothing && length(edgelabel) != NE
        error("Must have one label per edge (or none)")
    end

    # Scale to unit square
    min_x, max_x = minimum(locs_x), maximum(locs_x)
    min_y, max_y = minimum(locs_y), maximum(locs_y)
    function scaler(z, a, b)
        2.0*((z - a)/(b - a)) - 1.0
    end
    map!(z -> scaler(z, min_x, max_x), locs_x)
    map!(z -> scaler(z, min_y, max_y), locs_y)

    # Determine sizes
    #const NODESIZE    = 0.25/sqrt(N)
    #const LINEWIDTH   = 3.0/sqrt(N)

    max_nodesize = NODESIZE/maximum(nodesize)
    nodesize *= max_nodesize
    max_edgelinewidth = EDGELINEWIDTH/maximum(edgelinewidth)
    edgelinewidth *= max_edgelinewidth
    max_edgelabelsize = EDGELABELSIZE/maximum(edgelabelsize)
    edgelabelsize *= max_edgelabelsize
    max_nodelabelsize = NODELABELSIZE/maximum(nodelabelsize)
    nodelabelsize *= max_nodelabelsize
    max_nodestrokelw = maximum(nodestrokelw)
    if max_nodestrokelw > 0.0
        max_nodestrokelw = EDGELINEWIDTH/max_nodestrokelw
        nodestrokelw *= max_nodestrokelw
    end

    nshape = nothing
    if isa(nodeshape, Array)
        nshape = nodeshape
    else
        nshape = fill(nodeshape, length(locs_x))
    end
    # Create nodes
    circle_idx = Int[]
    polygon_idx = Int[]
    for i=1:length(nshape)
        if nshape[i]==0
            push!(circle_idx, i)
        else
            push!(polygon_idx, i)
        end
    end

    circles = nothing
    if !isempty(circle_idx)
        nodecircle = fill(0.4Compose.w, length(circle_idx))
        if isa(nodesize, Real)
            for i=1:length(circle_idx)
                nodecircle[i] *= nodesize
            end
        else
            for (i, s) in enumerate(circle_idx)
                nodecircle[i] *= nodesize[s]
            end
        end
        circles = circle(locs_x[circle_idx], locs_y[circle_idx], nodecircle)
    end

    θ = nothing
    if isa(shaperot, Array)
        θ = shaperot
    else
        θ = fill(shaperot, length(locs_x))
    end

    polygons = nothing
    if !isempty(polygon_idx)
        nodepolygon = fill(1.2, length(polygon_idx))
        if isa(nodesize, Real)
            for i=1:length(polygon_idx)
                nodepolygon[i] *= nodesize
            end
        else
            for (i, s) in enumerate(polygon_idx)
                nodepolygon[i] *= nodesize[s]
            end
        end

        polygons = polygon(ngon(locs_x[polygon_idx], locs_y[polygon_idx], nodepolygon, nshape[polygon_idx], θ[polygon_idx]))
    end

    circlec = nothing
    polygonc = nothing
    circle_strokec = nothing
    polygon_strokec = nothing
    circle_strokelw = nothing
    polygon_strokelw = nothing
    if isa(nodestrokelw, Array)
        !isempty(circle_idx) && (circle_strokelw = nodestrokelw[circle_idx])
        !isempty(polygon_idx) && (polygon_strokelw = nodestrokelw[polygon_idx])
    else
        circle_strokelw = nodestrokelw
        polygon_strokelw = nodestrokelw
    end

    if isa(nodestrokec, Array)
        !isempty(circle_idx) && (circle_strokec = nodestrokec[circle_idx])
        !isempty(polygon_idx) && (polygon_strokec = nodestrokec[polygon_idx])
    else
        circle_strokec = nodestrokec
        polygon_strokec = nodestrokec
    end

    if isa(nodefillc, Array)
        !isempty(circle_idx) && (circlec = nodefillc[circle_idx])
        !isempty(polygon_idx) && (polygonc = nodefillc[polygon_idx])
    else
        circlec = nodefillc
        polygonc = nodefillc
    end

    # Create node labels if provided
    texts = nothing
    if nodelabel != nothing
        texts = text(locs_x .+ nodesize .* (nodelabeldist*cos(nodelabelangleoffset)),
                     locs_y .- nodesize .* (nodelabeldist*sin(nodelabelangleoffset)),
                     map(string, nodelabel), [hcenter], [vcenter])
    end
    # Create edge labels if provided
    edgetexts = nothing
    if edgelabel != nothing
        edge_locs_x = zeros(T, NE)
        edge_locs_y = zeros(T, NE)
        for (e_idx, e) in enumerate(_edges(G))
            i = _src_index(e, G)
            j = _dst_index(e, G)
            edge_locs_x[e_idx] = (locs_x[i]+locs_x[j])/2.0 + edgelabeldistx*NODESIZE
            edge_locs_y[e_idx] = (locs_y[i]+locs_y[j])/2.0 + edgelabeldisty*NODESIZE
        end
        edgetexts = text(edge_locs_x, edge_locs_y, map(string, edgelabel), [hcenter], [vcenter])
    end

    # Create lines and arrow heads
    lines, arrows = nothing, nothing
    if linetype=="curve"
        if arrowlengthfrac > 0.0
            lines_cord, arrows_cord = graphcurve(G, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset, outangle)
            lines = path(lines_cord)
            arrows = line(arrows_cord)
        else
            lines_cord = graphcurve(G, locs_x, locs_y, nodesize, outangle)
            lines = path(lines_cord)
        end
    else
        if arrowlengthfrac > 0.0
            lines_cord, arrows_cord = graphline(G, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset)
            lines = line(lines_cord)
            arrows = line(arrows_cord)
        else
            lines_cord = graphline(G, locs_x, locs_y, nodesize)
            lines = line(lines_cord)
        end
    end

    compose(context(units=UnitBox(-1.2,-1.2,+2.4,+2.4)),
            compose(context(), texts, fill(nodelabelc), stroke(nothing), fontsize(nodelabelsize)),
            compose(context(), circles, fill(circlec), stroke(circle_strokec), linewidth(circle_strokelw)),
            compose(context(), polygons, fill(polygonc), stroke(polygon_strokec), linewidth(polygon_strokelw)),
            compose(context(), edgetexts, fill(edgelabelc), stroke(nothing), fontsize(edgelabelsize)),
            compose(context(), arrows, stroke(edgestrokec), linewidth(edgelinewidth)),
            compose(context(), lines, stroke(edgestrokec), fill(nothing), linewidth(edgelinewidth)))
end

function gplot1(G; layout::Function=spring_layout, keyargs...)
    gplot1(G, layout(G)...; keyargs...)
end

# take from [Gadfly.jl](https://github.com/dcjones/Gadfly.jl)
function open_file(filename)
    if OS_NAME == :Darwin
        run(`open $(filename)`)
    elseif OS_NAME == :Linux || OS_NAME == :FreeBSD
        run(`xdg-open $(filename)`)
    elseif OS_NAME == :Windows
        run(`$(ENV["COMSPEC"]) /c start $(filename)`)
    else
        warn("Showing plots is not supported on OS $(string(OS_NAME))")
    end
end

# take from [Gadfly.jl](https://github.com/dcjones/Gadfly.jl)
function gplothtml1(G; layout::Function=spring_layout, keyargs...)
	filename = string(tempname(), ".html")
    output = open(filename, "w")

    plot_output = IOBuffer()
    draw(SVGJS(plot_output, Compose.default_graphic_width,
               Compose.default_graphic_width, false), gplot1(G, layout(G)...; keyargs...))
    plotsvg = takebuf_string(plot_output)

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
                $(readall(Compose.snapsvgjs))
            </script>
            <script charset="utf-8">
                $(readall(gadflyjs))
            </script>
            $(plotsvg)
          </body>
        </html>
        """)
    close(output)
    open_file(filename)
end

function gplothtml1{T<:Real}(G, lx::Vector{T}, ly::Vector{T}; keyargs...)
	filename = string(tempname(), ".html")
    output = open(filename, "w")

    plot_output = IOBuffer()
    draw(SVGJS(plot_output, Compose.default_graphic_width,
               Compose.default_graphic_width, false), gplot1(G, lx, ly; keyargs...))
    plotsvg = takebuf_string(plot_output)

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
                $(readall(Compose.snapsvgjs))
            </script>
            <script charset="utf-8">
                $(readall(gadflyjs))
            </script>
            $(plotsvg)
          </body>
        </html>
        """)
    close(output)
    open_file(filename)
end