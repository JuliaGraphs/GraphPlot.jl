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
`spectral_layout`].
Default: `spring_layout`

`title`
Plot title. Default: `""`

`title_color`
Plot title color. Default: `colorant"black"`

`title_size`
Plot title size. Default: `4.0`

`font_family`
Font family for all text. Default: `"Helvetica"`

`NODESIZE`
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
Angle offset for the node labels. Default: `π/4.0`

`NODELABELSIZE`
Largest fontsize for the vertex labels. Default: `4.0`

`nodelabelsize`
Relative fontsize for the vertex labels, can be a Vector. Default: `1.0`

`nodefillc`
Color to fill the nodes with, can be a Vector. Default: `colorant"turquoise"`

`nodestrokec`
Color for the nodes stroke, can be a Vector. Default: `nothing`

`nodestrokelw`
Line width for the nodes stroke, can be a Vector. Default: `0.0`

`edgelabel`
Labels for the edges, a Vector or nothing. Default: `[]`

`edgelabelc`
Color for the edge labels, can be a Vector. Default: `colorant"black"`

`edgelabeldistx, edgelabeldisty`
Distance for the edge label from center of edge. Default: `0.0`

`EDGELABELSIZE`
Largest fontsize for the edge labels. Default: `4.0`

`edgelabelsize`
Relative fontsize for the edge labels, can be a Vector. Default: `1.0`

`EDGELINEWIDTH`
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
Type of line used for edges ("straight", "curve"). Default: "straight"

`outangle`
Angular width in radians for the edges (only used if `linetype = "curve`). 
Default: `π/5 (36 degrees)`

`background_color`
Color for the plot background. Default: `nothing`

`plot_size`
Tuple of measures for width x height for plot area. Default: `(10cm, 10cm)`

`leftpad, rightpad, toppad, bottompad`
Padding for the plot margins. Default: `0mm`

`pad`
Padding for plot margins (overrides individual padding if given). Default: `nothing`
"""
function gplot(g::AbstractGraph{T},
    locs_x_in::AbstractVector{R1}, locs_y_in::AbstractVector{R2};
    title = "",
    title_color = colorant"black",
    title_size = 4.0,
    font_family = "Helvetica",
    nodelabel = nothing,
    nodelabelc = colorant"black",
    nodelabelsize = 1.0,
    NODELABELSIZE = 4.0,
    nodelabeldist = 0.0,
    nodelabelangleoffset = π / 4.0,
    edgelabel = [],
    edgelabelc = colorant"black",
    edgelabelsize = 1.0,
    EDGELABELSIZE = 4.0,
    edgestrokec = colorant"lightgray",
    edgelinewidth = 1.0,
    EDGELINEWIDTH = 3.0 / sqrt(nv(g)),
    edgelabeldistx = 0.0,
    edgelabeldisty = 0.0,
    nodesize = 1.0,
    NODESIZE = 0.25 / sqrt(nv(g)),
    nodefillc = colorant"turquoise",
    nodestrokec = nothing,
    nodestrokelw = 0.0,
    arrowlengthfrac = is_directed(g) ? 0.1 : 0.0,
    arrowangleoffset = π / 9,
    linetype = "straight",
    outangle = π / 5,
    background_color = nothing,
    plot_size = (10cm, 10cm),
    leftpad = 0mm, 
    rightpad = 0mm, 
    toppad = 0mm, 
    bottompad = 0mm,
    pad = nothing
    ) where {T <:Integer, R1 <: Real, R2 <: Real}

    length(locs_x_in) != length(locs_y_in) && error("Vectors must be same length")
    N = nv(g)
    NE = ne(g)
    if !isnothing(nodelabel) && length(nodelabel) != N
        error("Must have one label per node (or none)")
    end
    if !isempty(edgelabel) && length(edgelabel) != NE
        error("Must have one label per edge (or none)")
    end

    locs_x = convert(Vector{Float64}, locs_x_in)
    locs_y = convert(Vector{Float64}, locs_y_in)

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

    # Determine sizes
    #NODESIZE    = 0.25/sqrt(N)
    #LINEWIDTH   = 3.0/sqrt(N)

    max_nodesize = NODESIZE / maximum(nodesize)
    nodesize *= max_nodesize
    max_edgelinewidth = EDGELINEWIDTH / maximum(edgelinewidth)
    edgelinewidth *= max_edgelinewidth
    max_edgelabelsize = EDGELABELSIZE / maximum(edgelabelsize)
    edgelabelsize *= max_edgelabelsize
    max_nodelabelsize = NODELABELSIZE / maximum(nodelabelsize)
    nodelabelsize *= max_nodelabelsize
    max_nodestrokelw = maximum(nodestrokelw)
    if max_nodestrokelw > 0.0
        max_nodestrokelw = EDGELINEWIDTH / max_nodestrokelw
        nodestrokelw *= max_nodestrokelw
    end

    # Create nodes
    nodecircle = fill(0.4*2.4, length(locs_x)) #40% of the width of the unit box
    if isa(nodesize, Real)
        for i = 1:length(locs_x)
            nodecircle[i] *= nodesize
        end
    else
        for i = 1:length(locs_x)
            nodecircle[i] *= nodesize[i]
        end
    end
    nodes = circle(locs_x, locs_y, nodecircle)

    # Create node labels if provided
    texts = nothing
    if !isnothing(nodelabel)
        text_locs_x = deepcopy(locs_x)
        text_locs_y = deepcopy(locs_y)
        texts = text(text_locs_x .+ nodesize .* (nodelabeldist * cos(nodelabelangleoffset)),
                     text_locs_y .- nodesize .* (nodelabeldist * sin(nodelabelangleoffset)),
                     map(string, nodelabel), [hcenter], [vcenter])
    end
    # Create edge labels if provided
    edgetexts = nothing
    if !isempty(edgelabel)
        edge_locs_x = zeros(R1, NE)
        edge_locs_y = zeros(R2, NE)
        for (e_idx, e) in enumerate(edges(g))
            i = src(e)
            j = dst(e)
            mid_x = (locs_x[i]+locs_x[j]) / 2.0
            mid_y = (locs_y[i]+locs_y[j]) / 2.0
            edge_locs_x[e_idx] = (is_directed(g) ? (mid_x+locs_x[j]) / 2.0 : mid_x) + edgelabeldistx * NODESIZE
            edge_locs_y[e_idx] = (is_directed(g) ? (mid_y+locs_y[j]) / 2.0 : mid_y) + edgelabeldisty * NODESIZE

        end
        edgetexts = text(edge_locs_x, edge_locs_y, map(string, edgelabel), [hcenter], [vcenter])
    end

    # Create lines and arrow heads
    lines, larrows = nothing, nothing
    curves, carrows = nothing, nothing
    if linetype == "curve"
        curves, carrows = build_curved_edges(edges(g), locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset, outangle)
    elseif has_self_loops(g)
        lines, larrows, curves, carrows = build_straight_curved_edges(g, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset, outangle)
    else
        lines, larrows = build_straight_edges(edges(g), locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset)
    end

    # Set plot_size
    if length(plot_size) != 2 || !isa(plot_size[1], Compose.AbsoluteLength) || !isa(plot_size[2], Compose.AbsoluteLength)
        error("`plot_size` must be a Tuple of lengths")
    end
    Compose.set_default_graphic_size(plot_size...)
    
    # Plot title
    title_offset = isempty(title) ? 0 : 0.1*title_size/4 #Fix title offset
    title = text(0, -1.2 - title_offset/2, title, hcenter, vcenter)

    # Plot padding
    if !isnothing(pad)
        leftpad, rightpad, toppad, bottompad = pad, pad, pad, pad
    end

    # Plot area size
    plot_area = (-1.2, -1.2 - title_offset, +2.4, +2.4 + title_offset)
    
    # Build figure
    compose(
        context(units=UnitBox(plot_area...; leftpad, rightpad, toppad, bottompad)),
        compose(context(), title, fill(title_color), fontsize(title_size), font(font_family)),
        compose(context(), texts, fill(nodelabelc), fontsize(nodelabelsize), font(font_family)),
        compose(context(), nodes, fill(nodefillc), stroke(nodestrokec), linewidth(nodestrokelw)),
        compose(context(), edgetexts, fill(edgelabelc), fontsize(edgelabelsize)),
        compose(context(), larrows, fill(edgestrokec)),
        compose(context(), carrows, fill(edgestrokec)),
        compose(context(), lines, stroke(edgestrokec), linewidth(edgelinewidth)),
        compose(context(), curves, stroke(edgestrokec), linewidth(edgelinewidth)),
        compose(context(units=UnitBox(plot_area...)), rectangle(plot_area...), fill(background_color))
    )
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
