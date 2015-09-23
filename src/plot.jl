using Colors
using ColorTypes
typealias ComposeColorVector Union(Vector{Colors.RGB}, Vector{ASCIIString}, Vector{Colors.Color}, Vector{Colors.AlphaColor}, Vector{Colors.String})

@doc """
**Description:**

Given an adjacency matrix and two vectors of X and Y coordinates, returns
a Compose tree of the graph layout

**Arguments:**

*G:*
Adjacency matrix of some type. Non-zero of the eltype
of the matrix is used to determine if a link exists,
but currently no sense of magnitude

*layout:*
Optional. layout algorithm. Currently can be [random_layout, circular_layout].
Default: random_layout

*locs_x, locs_y:*
Locations of the nodes. Can be any units you want,
but will be normalized and centered anyway

*filename:*
Output figure name

*labels:*
Optional. Labels for the vertices. Default: Any[]

*nodefillc:*
Color to fill the nodes with. Default: fill("#AAAAFF", N)

*nodestrokec:*
Color for the nodes stroke. Default: fill("#BBBBBB", N)

*edgestrokec:*
Color for the edge strokes. Default: fill("#BBBBBB", N)

*arrowlengthfrac:*
Fraction of line length to use for arrows.
Set to 0 for no arrows. Default: 0.1

*angleoffset*
angular width in radians for the arrows. Default: π/9 (20 degrees).

""" ->
function plot{V, T<:Real}(
    G::AbstractGraph{V},
    locs_x::Vector{T}, locs_y::Vector{T};
    labels::Vector=[1:num_vertices(G)],
    labelc::Vector=fill(colorant"#000000", num_vertices(G)),
    nodefillc::Vector=fill(colorant"skyblue", num_vertices(G)),
    nodestrokec::Vector=fill(colorant"#BBBBBB", num_vertices(G)),
    edgestrokec::Vector=fill(colorant"#BBBBBB", num_vertices(G)),
    labelsize::Vector{T}=fill(4.0, num_vertices(G)),
    nodesize::Vector{T}=ones(Float64, num_vertices(G)),
    lw::Vector{T}=ones(Float64, num_vertices(G)),
    arrowlengthfrac::Real=0.1,
    angleoffset=20.0/180.0*π)

    length(locs_x) != length(locs_y) && error("Vectors must be same length")
    const N = length(locs_x)
    if length(labels) != N && length(labels) != 0
        error("Must have one label per node (or none)")
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
    #const ARROWLENGTH = LINEWIDTH * arrowlengthfrac
    #nodesize /= maximum(nodesize)
    #lw /= maximum(lw)
    nodesize *= NODESIZE
    lw *= LINEWIDTH
    arrowlength = lw * arrowlengthfrac
    labelsize *= 4.0

    # Create lines and arrow heads
    lines = Any[]
    for e in edges(G)
        i = vertex_index(source(e, G), G)
        j = vertex_index(target(e, G), G)
        push!(lines, lineij(locs_x, locs_y, i, j, nodesize[j], arrowlength[j], angleoffset))
    end

    # Create nodes
    nodes = [circle(locs_x[i],locs_y[i],nodesize[i]) for i=1:N]

    # Create labels (if wanted)
    texts = length(labels) == N ?
        [text(locs_x[i],locs_y[i],labels[i],hcenter,vcenter) for i=1:N] : Any[]

    compose(context(units=UnitBox(-1.2,-1.2,+2.4,+2.4)),
        [compose(context(), texts[i], fill(labelc[i]), stroke(nothing), fontsize(labelsize[i])) for i=1:N],
        [compose(context(), nodes[i], fill(nodefillc[i]), stroke(nodestrokec[i])) for i=1:N],
        [compose(context(), lines[i], stroke(edgestrokec[i]), linewidth(lw[i])) for i=1:N],
    )
end

function plot{V, T<:Real}(
    G::AbstractGraph{V};
    layout::Function=random_layout,
    filename::String="",
    labels::Vector=[1:num_vertices(G)],
    labelc::Vector=fill(colorant"#000000", num_vertices(G)),
    nodefillc::Vector=fill(colorant"skyblue", num_vertices(G)),
    nodestrokec::Vector=fill(colorant"#BBBBBB", num_vertices(G)),
    edgestrokec::Vector=fill(colorant"#BBBBBB", num_vertices(G)),
    labelsize::Vector{T}=fill(4.0, num_vertices(G)),
    nodesize::Vector{T}=ones(Float64, num_vertices(G)),
    lw::Vector{T}=ones(Float64, num_vertices(G)),
    arrowlengthfrac::Real=0.1,
    angleoffset=20.0/180.0*π)
    draw(filename == "" ? SVG(8inch, 8inch) : SVG(filename, 8inch, 8inch),
         plot(G, layout(G)..., labels=labels, labelc=labelc, nodefillc=nodefillc,
         nodestrokec=nodestrokec, edgestrokec=edgestrokec, labelsize=labelsize,
         nodesize=nodesize, lw=lw, arrowlengthfrac=arrowlengthfrac, angleoffset=angleoffset)
         )
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
        composenode = compose(
                context(),
                line([(locs_x[i], locs_y[i]), (endx, endy)]),
                line([arr1, (endx, endy)]),
                line([arr2, (endx, endy)])
            )
    else
        composenode = compose(
                context(),
                line([(locs_x[i], locs_y[i]), (endx, endy)])
            )
    end
    return composenode
end
