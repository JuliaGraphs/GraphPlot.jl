"""
Return lines and arrow heads
"""
function graphline(g, locs_x, locs_y, nodesize::Vector{T}, arrowlength, angleoffset) where {T<:Real}
    lines = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    arrows = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    for (e_idx, e) in enumerate(edges(g))
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan(Δy,Δx)
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

function graphline(g::AbstractGraph{T}, locs_x, locs_y, nodesize::Real, arrowlength, angleoffset) where {T<:Integer}
    lines = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    arrows = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    for (e_idx, e) in enumerate(edges(g))
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan(Δy,Δx)
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

function graphline(g::AbstractGraph{T}, locs_x, locs_y, nodesize::Vector{<:Real}) where {T<:Integer}
    lines = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    for (e_idx, e) in enumerate(edges(g))
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan(Δy,Δx)
        startx = locs_x[i] + nodesize[i]*cos(θ)
        starty = locs_y[i] + nodesize[i]*sin(θ)
        endx  = locs_x[i] + (d-nodesize[j])*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize[j])*1.00*sin(θ)
        lines[e_idx] = [(startx, starty), (endx, endy)]
    end
    lines
end

function graphline(g::AbstractGraph{T}, locs_x, locs_y, nodesize::Real) where {T<:Integer}
    lines = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    for (e_idx, e) in enumerate(edges(g))
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ)
        starty = locs_y[i] + nodesize*sin(θ)
        endx  = locs_x[i] + (d-nodesize)*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize)*1.00*sin(θ)
        lines[e_idx] = [(startx, starty), (endx, endy)]
    end
    return lines
end

function graphcurve(g::AbstractGraph{T}, locs_x, locs_y, nodesize::Vector{<:Real}, arrowlength, angleoffset, outangle=pi/5) where {T<:Integer}
    lines = Array{Vector}(ne(g))
    arrows = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    for (e_idx, e) in enumerate(edges(g))
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan(Δy,Δx)
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
    return lines, arrows
end

function graphcurve(g, locs_x, locs_y, nodesize::Real, arrowlength, angleoffset, outangle=pi/5)
    lines = Array{Vector}(ne(g))
    arrows = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    for (e_idx, e) in enumerate(edges(g))
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan(Δy,Δx)
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
    return lines, arrows
end

function graphcurve(g, locs_x, locs_y, nodesize::Real, outangle)
    lines = Array{Vector}(ne(g))
    for (e_idx, e) in enumerate(edges(g))
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ)
        starty = locs_y[i] + nodesize*sin(θ)
        endx  = locs_x[i] + (d-nodesize)*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize)*1.00*sin(θ)
        lines[e_idx] = curveedge(startx, starty, endx, endy, outangle)
    end
    lines
end

function graphcurve(g::AbstractGraph{T}, locs_x, locs_y, nodesize::Vector{<:Real}, outangle) where {T<:Integer}
    lines = Array{Vector}(ne(g))
    for (e_idx, e) in enumerate(edges(g))
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        d  = sqrt(Δx^2 + Δy^2)
        θ  = atan(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ)
        starty = locs_y[i] + nodesize*sin(θ)
        endx  = locs_x[i] + (d-nodesize)*1.00*cos(θ)
        endy  = locs_y[i] + (d-nodesize)*1.00*sin(θ)
        lines[e_idx] = curveedge(startx, starty, endx, endy, outangle)
    end
    return lines
end

# this function is copy from [IainNZ](https://github.com/IainNZ)'s [GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl)
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
    return (arr1x, arr1y), (arr2x, arr2y)
end

# using when startx > endx
function curvearrowcoords2(θ1, θ2, endx, endy, arrowlength, angleoffset=20.0/180.0*π)
    arr1x = endx + arrowlength*cos(pi+θ1+θ2-angleoffset)
    arr1y = endy + arrowlength*sin(pi+θ1+θ2-angleoffset)
    arr2x = endx + arrowlength*cos(pi+θ1+θ2+angleoffset)
    arr2y = endy + arrowlength*sin(pi+θ1+θ2+angleoffset)
    return (arr1x, arr1y), (arr2x, arr2y)
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
    return [:M, x1,y1, :Q, x, y, x2, y2]
end
