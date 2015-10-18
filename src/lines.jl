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

function graphline{T<:Real}(g::LightGraphs.SimpleGraph, locs_x, locs_y, nodesize::Vector{T}, arrowlength, angleoffset)
    lines = Vector{Tuple{Float64,Float64}}[]
    arrows = Vector{Tuple{Float64,Float64}}[]
    for e in LightGraphs.edges(g)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan2(Δy,Δx)
        startx = locs_x[i] + nodesize[i]*cos(θ)
        starty = locs_y[i] + nodesize[i]*sin(θ)
        endx  = locs_x[i] + (d-nodesize[j])*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize[j])*1.00*sin(θ)
        push!(lines, [(startx, starty), (endx, endy)])
        arr1, arr2 = arrowcoords(θ, endx, endy, arrowlength, angleoffset)
        push!(arrows, [arr1, (endx, endy), arr2])
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

function graphline{T<:Real}(g::LightGraphs.SimpleGraph, locs_x, locs_y, nodesize::T, arrowlength, angleoffset)
    lines = Vector{Tuple{Float64,Float64}}[]
    arrows = Vector{Tuple{Float64,Float64}}[]
    for e in LightGraphs.edges(g)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan2(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ)
        starty = locs_y[i] + nodesize*sin(θ)
        endx  = locs_x[i] + (d-nodesize)*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize)*1.00*sin(θ)
        push!(lines, [(startx, starty), (endx, endy)])
        arr1, arr2 = arrowcoords(θ, endx, endy, arrowlength, angleoffset)
        push!(arrows, [arr1, (endx, endy), arr2])
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

function graphline{T<:Real}(g::LightGraphs.SimpleGraph, locs_x, locs_y, nodesize::Vector{T})
    lines = Vector{Tuple{Float64,Float64}}[]
    for e in LightGraphs.edges(g)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan2(Δy,Δx)
        startx = locs_x[i] + nodesize[i]*cos(θ)
        starty = locs_y[i] + nodesize[i]*sin(θ)
        endx  = locs_x[i] + (d-nodesize[j])*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize[j])*1.00*sin(θ)
        push!(lines, [(startx, starty), (endx, endy)])
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
        endx  = locs_x[i] + (d-nodesize)*1.0*cos(θ)
        endy  = locs_y[i] + (d-nodesize)*1.0*sin(θ)
        lines[e_idx] = [(startx, starty), (endx, endy)]
    end
    lines
end

function graphline{T<:Real}(g::LightGraphs.SimpleGraph, locs_x, locs_y, nodesize::T)
    lines = Vector{Tuple{Float64,Float64}}[]
    for e in LightGraphs.edges(g)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan2(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ)
        starty = locs_y[i] + nodesize*sin(θ)
        endx  = locs_x[i] + (d-nodesize)*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize)*1.00*sin(θ)
        push!(lines, [(startx, starty), (endx, endy)])
    end
    lines
end

function graphcurve{V, T<:Real}(g::AbstractGraph{V}, locs_x, locs_y, nodesize::Vector{T}, arrowlength, angleoffset, outangle=pi/5)
    lines = Array(Vector, num_edges(g))
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
        lines[e_idx] = curveedge(startx, starty, endx, endy, outangle)
        if startx <= endx
            arr1, arr2 = curvearrowcoords1(θ, outangle, endx, endy, arrowlength, angleoffset)
            arrows[e_idx] = [arr1, (endx, endy), arr2]
        else
            arr1, arr2 = curvearrowcoords2(θ, outangle, endx, endy, arrowlength, angleoffset)
            arrows[e_idx] = [arr1, (endx, endy), arr2]
        end
    end
    lines, arrows
end

function graphcurve{T<:Real}(g::LightGraphs.SimpleGraph, locs_x, locs_y, nodesize::Vector{T}, arrowlength, angleoffset, outangle=pi/5)
    lines = Vector[]
    arrows = Vector{Tuple{Float64,Float64}}[]
    for e in LightGraphs.edges(g)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan2(Δy,Δx)
        startx = locs_x[i] + nodesize[i]*cos(θ)
        starty = locs_y[i] + nodesize[i]*sin(θ)
        endx  = locs_x[i] + (d-nodesize[j])*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize[j])*1.00*sin(θ)
        push!(lines, curveedge(startx, starty, endx, endy, outangle))
        if startx <= endx
            arr1, arr2 = curvearrowcoords1(θ, outangle, endx, endy, arrowlength, angleoffset)
            push!(arrows, [arr1, (endx, endy), arr2])
        else
            arr1, arr2 = curvearrowcoords2(θ, outangle, endx, endy, arrowlength, angleoffset)
            push!(arrows, [arr1, (endx, endy), arr2])
        end
    end
    lines, arrows
end

function graphcurve{V, T<:Real}(g::AbstractGraph{V}, locs_x, locs_y, nodesize::T, arrowlength, angleoffset, outangle=pi/5)
    lines = Array(Vector, num_edges(g))
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
        lines[e_idx] = curveedge(startx, starty, endx, endy, outangle)
        if startx <= endx
            arr1, arr2 = curvearrowcoords1(θ, outangle, endx, endy, arrowlength, angleoffset)
            arrows[e_idx] = [arr1, (endx, endy), arr2]
        else
            arr1, arr2 = curvearrowcoords2(θ, outangle, endx, endy, arrowlength, angleoffset)
            arrows[e_idx] = [arr1, (endx, endy), arr2]
        end
    end
    lines, arrows
end

function graphcurve{T<:Real}(g::LightGraphs.SimpleGraph, locs_x, locs_y, nodesize::T, arrowlength, angleoffset, outangle=pi/5)
    lines = Vector[]
    arrows = Vector{Tuple{Float64,Float64}}[]
    for e in LightGraphs.edges(g)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan2(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ)
        starty = locs_y[i] + nodesize*sin(θ)
        endx  = locs_x[i] + (d-nodesize)*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize)*1.00*sin(θ)
        push!(lines, curveedge(startx, starty, endx, endy, outangle))
        if startx <= endx
            arr1, arr2 = curvearrowcoords1(θ, outangle, endx, endy, arrowlength, angleoffset)
            push!(arrows, [arr1, (endx, endy), arr2])
        else
            arr1, arr2 = curvearrowcoords2(θ, outangle, endx, endy, arrowlength, angleoffset)
            push!(arrows, [arr1, (endx, endy), arr2])
        end
    end
    lines, arrows
end

function graphcurve{V, T<:Real}(g::AbstractGraph{V}, locs_x, locs_y, nodesize::T, outangle)
    lines = Array(Vector, num_edges(g))
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
        lines[e_idx] = curveedge(startx, starty, endx, endy, outangle)
    end
    lines
end

function graphcurve{T<:Real}(g::LightGraphs.SimpleGraph, locs_x, locs_y, nodesize::T, outangle)
    lines = Vector[]
    for e in LightGraphs.edges(g)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan2(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ)
        starty = locs_y[i] + nodesize*sin(θ)
        endx  = locs_x[i] + (d-nodesize)*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize)*1.00*sin(θ)
        push!(lines, curveedge(startx, starty, endx, endy, outangle))
    end
    lines
end

function graphcurve{V, T<:Real}(g::AbstractGraph{V}, locs_x, locs_y, nodesize::Vector{T}, outangle)
    lines = Array(Vector, num_edges(g))
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
        lines[e_idx] = curveedge(startx, starty, endx, endy, outangle)
    end
    lines
end

function graphcurve{T<:Real}(g::LightGraphs.SimpleGraph, locs_x, locs_y, nodesize::Vector{T}, outangle)
    lines = Vector[]
    for e in LightGraphs.edges(g)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan2(Δy,Δx)
        startx = locs_x[i] + nodesize[i]*cos(θ)
        starty = locs_y[i] + nodesize[i]*sin(θ)
        endx  = locs_x[i] + (d-nodesize[j])*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize[j])*1.00*sin(θ)
        push!(lines, curveedge(startx, starty, endx, endy, outangle))
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

# using when startx <= endx
# θ1 is the angle between line from start point to end point with x axis
# θ2 is the out angle of edge
function curvearrowcoords1(θ1, θ2, endx, endy, arrowlength, angleoffset=20.0/180.0*π)
    arr1x = endx + arrowlength*cos(pi+θ1-θ2-angleoffset)
    arr1y = endy + arrowlength*sin(pi+θ1-θ2-angleoffset)
    arr2x = endx + arrowlength*cos(pi+θ1-θ2+angleoffset)
    arr2y = endy + arrowlength*sin(pi+θ1-θ2+angleoffset)
    (arr1x, arr1y), (arr2x, arr2y)
end

# using when startx > endx
function curvearrowcoords2(θ1, θ2, endx, endy, arrowlength, angleoffset=20.0/180.0*π)
    arr1x = endx + arrowlength*cos(pi+θ1+θ2-angleoffset)
    arr1y = endy + arrowlength*sin(pi+θ1+θ2-angleoffset)
    arr2x = endx + arrowlength*cos(pi+θ1+θ2+angleoffset)
    arr2y = endy + arrowlength*sin(pi+θ1+θ2+angleoffset)
    (arr1x, arr1y), (arr2x, arr2y)
end

function sector(x, y, r, θ1, θ2)
    if θ2-θ1<=pi
        [:M, x+r*cos(θ1),y-r*sin(θ1), :A, r, r, 0, false, false, x+r*cos(θ2), y-r*sin(θ2),  :L, x, y, :Z]
    else
        [
            :M, x+r*cos(θ1),y-r*sin(θ1),
            :A, r, r, 0, false, false, x+r*cos(θ1+pi), y-r*sin(θ1+pi),
            :A, r, r, 0, false, false, x+r*cos(θ2), y-r*sin(θ2),
            :L, x, y,
            :Z
        ]
    end
end
function sector{T<:Real}(x::Vector{T}, y::Vector{T}, r::Vector{T}, θ1::Vector{T}, θ2::Vector{T})
    s = Vector[]
    for i=1:length(x)
        push!(s, sector(x[i],y[i],r[i],θ1[i],θ2[i]))
    end
    s
end

function curveedge(x1, y1, x2, y2, θ)
    θ1 = atan((y2-y1)/(x2-x1))
    d = sqrt((x2-x1)^2+(y2-y1)^2)
    r = d/2cos(θ)
    if x1 <= x2
        x = x1 + r*cos(θ+θ1)
        y = y1 + r*sin(θ+θ1)
    else
        x = x2 + r*cos(θ+θ1)
        y = y2 + r*sin(θ+θ1)
    end
    [:M, x1,y1, :Q, x, y, x2, y2]
end
#function curveedge{T<:Real}(x1::Vector{T}, y1::Vector{T}, x2::Vector{T}, y2::Vector{T}, θ::Vector{T})
#    c = Vector[]
#    for i=1:length(x1)
#        push!(c, curveedge(x1[i],y1[i],x2[i],y2[i],θ[i]))
#    end
#    c
#end
