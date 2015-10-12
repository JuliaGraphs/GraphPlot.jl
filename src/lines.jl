"""
Return lines and arrow heads
"""
function graphline{V, T<:Real}(g::AbstractGraph{V}, locs_x, locs_y, nodesize::Vector{T}, arrowlength, angleoffset)
    lines = Array(Vector{Tuple{Float64,Float64}}, num_edges(g))
    arrows = Array(Vector{Tuple{Float64,Float64}}, num_edges(g))
    for e in Graphs.edges(g)
        e_idx = edge_index(e, g)
        i = vertex_index(source(e, g), g)
        j = vertex_index(target(e, g), g)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan2(Δy,Δx)
        startx = locs_x[i] + nodesize[i]*cos(θ)
        starty = locs_y[i] + nodesize[i]*sin(θ)
        endx  = locs_x[i] + (d-nodesize[j])*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize[j])*1.00*sin(θ)
        lines[e_idx] = [(startx, starty), (endx, endy)]
        arr1, arr2 = arrowcoords(θ, endx, endy, arrowlength, angleoffset)
        arrows[e_idx] = [arr1, (endx, endy), arr2]
    end
    lines, arrows
end

function graphline{V, T<:Real}(g::AbstractGraph{V}, locs_x, locs_y, nodesize::T, arrowlength, angleoffset)
    lines = Array(Vector{Tuple{Float64,Float64}}, num_edges(g))
    arrows = Array(Vector{Tuple{Float64,Float64}}, num_edges(g))
    for e in Graphs.edges(g)
        e_idx = edge_index(e, g)
        i = vertex_index(source(e, g), g)
        j = vertex_index(target(e, g), g)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan2(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ)
        starty = locs_y[i] + nodesize*sin(θ)
        endx  = locs_x[i] + (d-nodesize)*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize)*1.00*sin(θ)
        lines[e_idx] = [(startx, starty), (endx, endy)]
        arr1, arr2 = arrowcoords(θ, endx, endy, arrowlength, angleoffset)
        arrows[e_idx] = [arr1, (endx, endy), arr2]
    end
    lines, arrows
end

function graphline{V, T<:Real}(g::AbstractGraph{V}, locs_x, locs_y, nodesize::Vector{T})
    lines = Array(Vector{Tuple{Float64,Float64}}, num_edges(g))
    for e in Graphs.edges(g)
        e_idx = edge_index(e, g)
        i = vertex_index(source(e, g), g)
        j = vertex_index(target(e, g), g)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan2(Δy,Δx)
        startx = locs_x[i] + nodesize[i]*cos(θ)
        starty = locs_y[i] + nodesize[i]*sin(θ)
        endx  = locs_x[i] + (d-nodesize[j])*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize[j])*1.00*sin(θ)
        lines[e_idx] = [(startx, starty), (endx, endy)]
    end
    lines
end

function graphline{V, T<:Real}(g::AbstractGraph{V}, locs_x, locs_y, nodesize::T)
    lines = Array(Vector{Tuple{Float64,Float64}}, num_edges(g))
    for e in Graphs.edges(g)
        e_idx = edge_index(e, g)
        i = vertex_index(source(e, g), g)
        j = vertex_index(target(e, g), g)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan2(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ)
        starty = locs_y[i] + nodesize*sin(θ)
        endx  = locs_x[i] + (d-nodesize)*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize)*1.00*sin(θ)
        lines[e_idx] = [(startx, starty), (endx, endy)]
    end
    lines
end

function arrowcoords(θ, endx, endy, arrowlength, angleoffset=20.0/180.0*π)
    arr1x = endx - arrowlength*cos(θ+angleoffset)
    arr1y = endy - arrowlength*sin(θ+angleoffset)
    arr2x = endx - arrowlength*cos(θ-angleoffset)
    arr2y = endy - arrowlength*sin(θ-angleoffset)
    return (arr1x, arr1y), (arr2x, arr2y)
end
