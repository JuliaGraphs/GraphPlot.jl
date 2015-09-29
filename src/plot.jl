using Colors

typealias ComposeColor @compat Union(Nothing, Vector,
                             Colors.Color, Colors.String,
                             Colors.AlphaColor, Colors.TransparentColor)

"""
Given an adjacency matrix and two vectors of X and Y coordinates, returns
a Compose tree of the graph layout

**Arguments**

*G*
a graph

*layout*
Optional. layout algorithm. Currently can be one of [random_layout,
circular_layout, spring_layout, shell_layout, stressmajorize_layout,
spectral_layout].
Default: spring_layout

*locs_x, locs_y*
Locations of the nodes. Can be any units you want,
but will be normalized and centered anyway

*nodesize*
Optional. size for the vertices. Default: 1

*nodelabel*
Optional. Labels for the vertices. Default: nothing

*nodelabelc*
Optional. Color for the node labels. Default: colorant"black"

*nodelabeldist*
Optional. Distances for the node labels from center of nodes. Default: 0

*nodelabelangleoffset*
Optional. Angle offset for the node labels. Default: π/4.0

*nodelabelsize*
Optional. fontsize for the vertice labels. Default: 4

*nodefillc*
Color to fill the nodes with. Default: colorant"turquoise"

*nodestrokec*
Color for the nodes stroke. Default: nothing

*nodestrokelw*
line width for the nodes stroke. Default: 0

*edgelabel*
Optional. Labels for the edges. Default: nothing

*edgelabelc*
Optional. Color for the edge labels. Default: colorant"black"

*edgelabeldistx, edgelabeldisty*
Optional. Distances for the edge labels from center of edges. Default: 0

*edgelabelsize*
Optional. fontsize for the edge labels. Default: 4

*edgelinewidth*
Optional. line width for the edges. Default: 1

*edgestrokec*
Color for the edge strokes. Default: colorant"lightgray"

*arrowlengthfrac*
Fraction of line length to use for arrows.
Set to 0 for no arrows. Default: 0.1

*arrowangleoffset*
angular width in radians for the arrows. Default: π/9 (20 degrees).

"""
function gplot{V, T<:Real}(
    G::AbstractGraph{V},
    locs_x::Vector{T}, locs_y::Vector{T};
    nodelabel::@compat Union(Nothing, Vector) = nothing,
    nodelabelc::ComposeColor = colorant"black",
    nodelabelsize::@compat Union(Real, Vector) = 4,
    nodelabeldist::Real = 0,
    nodelabelangleoffset::Real = π/4.0,
    edgelabel::@compat Union(Nothing, Vector) = nothing,
    edgelabelc::ComposeColor = colorant"black",
    edgelabelsize::@compat Union(Real, Vector) = 4,
    edgestrokec::ComposeColor = colorant"lightgray",
    edgelinewidth::@compat Union(Real, Vector) = 1,
    edgelabeldistx::Real = 0,
    edgelabeldisty::Real = 0,
    nodesize::@compat Union(Real, Vector) = 1,
    nodefillc::ComposeColor = colorant"turquoise",
    nodestrokec::ComposeColor = nothing,
    nodestrokelw::@compat Union(Real, Vector) = 0,
    arrowlengthfrac::Real = Graphs.is_directed(G) ? 0.1 : 0.0,
    arrowangleoffset = 20.0/180.0*π)

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
    nodesize *= NODESIZE/maximum(nodesize)
    edgelinewidth *= LINEWIDTH/maximum(edgelinewidth)
    edgelabelsize *= 4.0/maximum(edgelabelsize)
    nodelabelsize *= 4.0/maximum(nodelabelsize)
    if nodestrokelw > 0
        nodestrokelw *= LINEWIDTH/maximum(nodestrokelw)
    end

    # Create nodes
    nodes = circle(locs_x, locs_y, [nodesize])

    # Create node labels if provided
    texts = nodelabel == nothing ? nothing : text(locs_x .+ nodelabeldist .* [nodesize] .* cos(nodelabelangleoffset),
                                                  locs_y .- nodelabeldist .* [nodesize] .* sin(nodelabelangleoffset),
                                                  map(string, nodelabel), [hcenter], [vcenter])
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
    lines = Any[]
    if isa(nodesize, Real)
        for e in Graphs.edges(G)
            i = vertex_index(source(e, G), G)
            j = vertex_index(target(e, G), G)
            push!(lines, lineij(locs_x, locs_y, i, j, nodesize, arrowlengthfrac, arrowangleoffset))
        end
    else
        for e in Graphs.edges(G)
            i = vertex_index(source(e, G), G)
            j = vertex_index(target(e, G), G)
            push!(lines, lineij(locs_x, locs_y, i, j, nodesize[j], arrowlengthfrac, arrowangleoffset))
        end
    end


    compose(context(units=UnitBox(-1.2,-1.2,+2.4,+2.4)),
            compose(context(), texts, fill(nodelabelc), stroke(nothing), fontsize(nodelabelsize)),
            compose(context(), nodes, fill(nodefillc), stroke(nodestrokec), linewidth(nodestrokelw)),
            compose(context(), edgetexts, fill(edgelabelc), stroke(nothing), fontsize(edgelabelsize)),
            begin
                if isa(edgestrokec, Vector) && isa(edgelinewidth, Vector)
                    [compose(context(), lines[i], stroke(edgestrokec[i]), linewidth(edgelinewidth[i])) for i=1:NE]
                elseif isa(edgestrokec, Vector) && !isa(edgelinewidth, Vector)
                    [compose(context(), lines[i], stroke(edgestrokec[i]), linewidth(edgelinewidth)) for i=1:NE]
                elseif !isa(edgestrokec, Vector) && !isa(edgelinewidth, Vector)
                    [compose(context(), lines[i], stroke(edgestrokec), linewidth(edgelinewidth)) for i=1:NE]
                else
                    [compose(context(), lines[i], stroke(edgestrokec), linewidth(edgelinewidth[i])) for i=1:NE]
                end
            end)
end

using LightGraphs
function gplot{T<:Real}(
    G::LightGraph,
    locs_x::Vector{T}, locs_y::Vector{T};
    nodelabel::@compat Union(Nothing, Vector) = nothing,
    nodelabelc::ComposeColor = colorant"black",
    nodelabelsize::@compat Union(Real, Vector) = 4,
    nodelabeldist::Real = 0,
    nodelabelangleoffset::Real = π/4.0,
    edgelabel::@compat Union(Nothing, Vector) = nothing,
    edgelabelc::ComposeColor = colorant"black",
    edgelabelsize::@compat Union(Real, Vector) = 4,
    edgestrokec::ComposeColor = colorant"lightgray",
    edgelinewidth::@compat Union(Real, Vector) = 1,
    edgelabeldistx::Real = 0,
    edgelabeldisty::Real = 0,
    nodesize::@compat Union(Real, Vector) = 1,
    nodefillc::ComposeColor = colorant"turquoise",
    nodestrokec::ComposeColor = nothing,
    nodestrokelw::@compat Union(Real, Vector) = 0,
    arrowlengthfrac::Real = LightGraphs.is_directed(G) ? 0.1 : 0.0,
    arrowangleoffset = 20.0/180.0*π)

    length(locs_x) != length(locs_y) && error("Vectors must be same length")
    const N = LightGraphs.nv(G)
    const NE = LightGraphs.ne(G)
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
    nodesize *= NODESIZE/maximum(nodesize)
    edgelinewidth *= LINEWIDTH/maximum(edgelinewidth)
    edgelabelsize *= 4.0/maximum(edgelabelsize)
    nodelabelsize *= 4.0/maximum(nodelabelsize)
    if nodestrokelw > 0
        nodestrokelw *= LINEWIDTH/maximum(nodestrokelw)
    end

    # Create nodes
    nodes = circle(locs_x, locs_y, [nodesize])

    # Create node labels if provided
    texts = nodelabel == nothing ? nothing : text(locs_x .+ nodelabeldist .* [nodesize] .* cos(nodelabelangleoffset),
                                                  locs_y .- nodelabeldist .* [nodesize] .* sin(nodelabelangleoffset),
                                                  map(string, nodelabel), [hcenter], [vcenter])
    # Create edge labels if provided
    src
    edgetexts = nothing
    if edgelabel != nothing
        edge_locs_x = zeros(T, NE)
        edge_locs_y = zeros(T, NE)
        for (e_idx, e) in enumerate(LightGraphs.edges(G))
            i = LightGraphs.src(e)
            j = LightGraphs.dst(e)
            edge_locs_x[e_idx] = (locs_x[i]+locs_x[j])/2.0 + edgelabeldistx*NODESIZE
            edge_locs_y[e_idx] = (locs_y[i]+locs_y[j])/2.0 + edgelabeldisty*NODESIZE
        end
        edgetexts = text(edge_locs_x, edge_locs_y, map(string, edgelabel), [hcenter], [vcenter])
    end

    # Create lines and arrow heads
    lines = Any[]
    if isa(nodesize, Real)
        for e in LightGraphs.edges(G)
            i = LightGraphs.src(e)
            j = LightGraphs.dst(e)
            push!(lines, lineij(locs_x, locs_y, i, j, nodesize, arrowlengthfrac, arrowangleoffset))
        end
    else
        for e in LightGraphs.edges(G)
            i = LightGraphs.src(e)
            j = LightGraphs.dst(e)
            push!(lines, lineij(locs_x, locs_y, i, j, nodesize[j], arrowlengthfrac, arrowangleoffset))
        end
    end


    compose(context(units=UnitBox(-1.2,-1.2,+2.4,+2.4)),
            compose(context(), texts, fill(nodelabelc), stroke(nothing), fontsize(nodelabelsize)),
            compose(context(), nodes, fill(nodefillc), stroke(nodestrokec), linewidth(nodestrokelw)),
            compose(context(), edgetexts, fill(edgelabelc), stroke(nothing), fontsize(edgelabelsize)),
            begin
                if isa(edgestrokec, Vector) && isa(edgelinewidth, Vector)
                    [compose(context(), lines[i], stroke(edgestrokec[i]), linewidth(edgelinewidth[i])) for i=1:NE]
                elseif isa(edgestrokec, Vector) && !isa(edgelinewidth, Vector)
                    [compose(context(), lines[i], stroke(edgestrokec[i]), linewidth(edgelinewidth)) for i=1:NE]
                elseif !isa(edgestrokec, Vector) && !isa(edgelinewidth, Vector)
                    [compose(context(), lines[i], stroke(edgestrokec), linewidth(edgelinewidth)) for i=1:NE]
                else
                    [compose(context(), lines[i], stroke(edgestrokec), linewidth(edgelinewidth[i])) for i=1:NE]
                end
            end)
end

function gplot{V}(
    G::AbstractGraph{V};
    layout::Function=spring_layout,
    keyargs...)

    gplot(G, layout(G)...; keyargs...)
end

function gplot(
    G::LightGraph;
    layout::Function=spring_layout,
    keyargs...)

    gplot(G, layout(G)...; keyargs...)
end

function arrowcoords(θ, endx, endy, arrowlength, angleoffset=20.0/180.0*π)
    arr1x = endx - arrowlength*cos(θ+angleoffset)
    arr1y = endy - arrowlength*sin(θ+angleoffset)
    arr2x = endx - arrowlength*cos(θ-angleoffset)
    arr2y = endy - arrowlength*sin(θ-angleoffset)
    return (arr1x, arr1y), (arr2x, arr2y)
end

function lineij(locs_x, locs_y, i, j, NODESIZE, ARROWLENGTH, angleoffset)
    Δx = locs_x[j] - locs_x[i]
    Δy = locs_y[j] - locs_y[i]
    d  = sqrt(Δx^2 + Δy^2)
    θ  = atan2(Δy,Δx)
    endx  = locs_x[i] + (d-NODESIZE)*1.00*cos(θ)
    endy  = locs_y[i] + (d-NODESIZE)*1.00*sin(θ)
    if ARROWLENGTH > 0.0
        arr1, arr2 = arrowcoords(θ, endx, endy, ARROWLENGTH, angleoffset)
        composenode = Compose.compose(
                context(),
                line([(locs_x[i], locs_y[i]), (endx, endy)]),
                line([arr1, (endx, endy)]),
                line([arr2, (endx, endy)])
            )
    else
        composenode = Compose.compose(
                context(),
                line([(locs_x[i], locs_y[i]), (endx, endy)])
            )
    end
    return composenode
end
