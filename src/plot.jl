using Colors

"""
Given an adjacency matrix and two vectors of X and Y coordinates, returns
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

`nodesize`
Optional. Size for the vertices. Default: `1.0`

`nodelabel`
Optional. Labels for the vertices. Default: `nothing`

`nodelabelc`
Optional. Color for the node labels. Default: `colorant"black"`

`nodelabeldist`
Optional. Distances for the node labels from center of nodes. Default: `0.0`

`nodelabelangleoffset`
Optional. Angle offset for the node labels. Default: `π/4.0`

`nodelabelsize`
Optional. Fontsize for the vertice labels, can be a Vector. Default: `4.0`

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

`edgelabelsize`
Optional. Fontsize for the edge labels, can be a Vector. Default: `4.0`

`edgelinewidth`
Optional. Line width for the edges, can be a Vector. Default: `1.0`

`edgestrokec`
Optional. Color for the edge strokes, can be a Vector. Default: `colorant"lightgray"`

`arrowlengthfrac`
Optional. Fraction of line length to use for arrows.
Equal to 0 for undirected graphs. Default: `0.1` for the directed graphs

`arrowangleoffset`
Optional. Angular width in radians for the arrows. Default: `π/9 (20 degrees)`

"""
function gplot{V, T<:Real}(
    G::AbstractGraph{V},
    locs_x::Vector{T}, locs_y::Vector{T};
    nodelabel = nothing,
    nodelabelc = colorant"black",
    nodelabelsize = 4.0,
    nodelabeldist = 0.0,
    nodelabelangleoffset = π/4.0,
    edgelabel = nothing,
    edgelabelc = colorant"black",
    edgelabelsize = 4.0,
    edgestrokec = colorant"lightgray",
    edgelinewidth = 1.0,
    edgelabeldistx = 0.0,
    edgelabeldisty = 0.0,
    nodesize = 1.0,
    nodefillc = colorant"turquoise",
    nodestrokec = nothing,
    nodestrokelw = 0.0,
    arrowlengthfrac = 0.1,
    arrowangleoffset = π/9.0)

    length(locs_x) != length(locs_y) && error("Vectors must be same length")
    const N = num_vertices(G)
    const NE = num_edges(G)
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
    const NODESIZE    = 0.25/sqrt(N)
    const LINEWIDTH   = 3.0/sqrt(N)
    max_nodesize = NODESIZE/maximum(nodesize)
    nodesize *= max_nodesize
    max_edgelinewidth = LINEWIDTH/maximum(edgelinewidth)
    edgelinewidth *= max_edgelinewidth
    max_edgelabelsize = 4.0/maximum(edgelabelsize)
    edgelabelsize *= max_edgelabelsize
    max_nodelabelsize = 4.0/maximum(nodelabelsize)
    nodelabelsize *= max_nodelabelsize
    max_nodestrokelw = maximum(nodestrokelw)
    if max_nodestrokelw > 0.0
        max_nodestrokelw = LINEWIDTH/max_nodestrokelw
        nodestrokelw *= max_nodestrokelw
    end

    # Create nodes
    nodes = circle(locs_x, locs_y, [nodesize])

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
        for e in Graphs.edges(G)
            i = vertex_index(source(e, G), G)
            j = vertex_index(target(e, G), G)
            edge_locs_x[edge_index(e, G)] = (locs_x[i]+locs_x[j])/2.0 + edgelabeldistx*NODESIZE
            edge_locs_y[edge_index(e, G)] = (locs_y[i]+locs_y[j])/2.0 + edgelabeldisty*NODESIZE
        end
        edgetexts = text(edge_locs_x, edge_locs_y, map(string, edgelabel), [hcenter], [vcenter])
    end

    # Create lines and arrow heads
    lines, arrows = nothing, nothing
    if Graphs.is_directed(G)
        lines = graphline(G, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset)
    else
        lines, arrows = graphline(G, locs_x, locs_y, nodesize)
    end

    compose(context(units=UnitBox(-1.2,-1.2,+2.4,+2.4)),
            compose(context(), texts, fill(nodelabelc), stroke(nothing), fontsize(nodelabelsize)),
            compose(context(), nodes, fill(nodefillc), stroke(nodestrokec), linewidth(nodestrokelw)),
            compose(context(), edgetexts, fill(edgelabelc), stroke(nothing), fontsize(edgelabelsize)),
            compose(context(), line(lines), stroke(edgestrokec), linewidth(edgelinewidth)),
            compose(context(), line(arrows), stroke(edgestrokec), linewidth(edgelinewidth)))
end

function gplot{V}(G::AbstractGraph{V}; layout::Function=spring_layout, keyargs...)
    gplot(G, layout(G)...; keyargs...)
end
