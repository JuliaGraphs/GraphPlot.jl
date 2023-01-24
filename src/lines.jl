"""
Return lines and arrow heads
"""
function midpoint(pt1,pt2)
    x = (pt1[1] + pt2[1]) / 2
    y = (pt1[2] + pt2[2]) / 2
    return x,y
end

function interpolate_bezier(x::Vector,t)
    n = length(x)-1
    x_loc = sum(binomial(n,i)*(1-t)^(n-i)*t^i*x[i+1][1] for i in 0:n)
    y_loc = sum(binomial(n,i)*(1-t)^(n-i)*t^i*x[i+1][2] for i in 0:n)
    return x_loc.value, y_loc.value
end

interpolate_bezier(x::Compose.CurvePrimitive,t) =
    interpolate_bezier([x.anchor0, x.ctrl0, x.ctrl1, x.anchor1], t)

function interpolate_line(locs_x,locs_y,i,j,t)
    x_loc = locs_x[i] + (locs_x[j]-locs_x[i])*t
    y_loc = locs_y[i] + (locs_y[j]-locs_y[i])*t
    return x_loc, y_loc
end

function graphline(edge_list, locs_x, locs_y, nodesize::Vector{T}, arrowlength, angleoffset) where {T<:Real}
    num_edges = length(edge_list)
    lines = Array{Vector{Tuple{Float64,Float64}}}(undef, num_edges)
    arrows = Array{Vector{Tuple{Float64,Float64}}}(undef, num_edges)
    for (e_idx, e) in enumerate(edge_list)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        θ = atan(Δy,Δx)
        startx = locs_x[i] + nodesize[i]*cos(θ)
        starty = locs_y[i] + nodesize[i]*sin(θ)
        endx = locs_x[j] + nodesize[j]*cos(θ+π)
        endy = locs_y[j] + nodesize[j]*sin(θ+π)
        arr1, arr2 = arrowcoords(θ, endx, endy, arrowlength, angleoffset)
        endx0, endy0 = midpoint(arr1, arr2)
        e_idx2 = findfirst(==(Edge(j,i)), collect(edge_list)) #get index of reverse arc
        if !isnothing(e_idx2) && e_idx2 < e_idx #only make changes if lines/arrows have already been defined for that arc
            startx, starty = midpoint(arrows[e_idx2][[1,3]]...) #get midopint of reverse arc and use as new start point
            lines[e_idx2][1] = (endx0, endy0) #update endpoint of reverse arc
        end
        lines[e_idx] = [(startx, starty), (endx0, endy0)]
        arrows[e_idx] = [arr1, (endx, endy), arr2]
    end
    lines, arrows
end

function graphline(edge_list, locs_x, locs_y, nodesize::Real, arrowlength, angleoffset)
    num_edges = length(edge_list)
    lines = Array{Vector{Tuple{Float64,Float64}}}(undef, num_edges)
    arrows = Array{Vector{Tuple{Float64,Float64}}}(undef, num_edges)
    for (e_idx, e) in enumerate(edge_list)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        θ = atan(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ)
        starty = locs_y[i] + nodesize*sin(θ)
        endx = locs_x[j] + nodesize*cos(θ+π)
        endy = locs_y[j] + nodesize*sin(θ+π)
        arr1, arr2 = arrowcoords(θ, endx, endy, arrowlength, angleoffset)
        endx0, endy0 = midpoint(arr1, arr2)
        e_idx2 = findfirst(==(Edge(j,i)), collect(edge_list)) #get index of reverse arc
        if !isnothing(e_idx2) && e_idx2 < e_idx #only make changes if lines/arrows have already been defined for that arc
            startx, starty = midpoint(arrows[e_idx2][[1,3]]...) #get midopint of reverse arc and use as new start point
            lines[e_idx2][1] = (endx0, endy0) #update endpoint of reverse arc
        end
        lines[e_idx] = [(startx, starty), (endx0, endy0)]
        arrows[e_idx] = [arr1, (endx, endy), arr2]
    end
    lines, arrows
end

function graphline(edge_list, locs_x, locs_y, nodesize::Vector{T}) where {T<:Real}
    num_edges = length(edge_list)
    lines = Array{Vector{Tuple{Float64,Float64}}}(undef, num_edges)
    for (e_idx, e) in enumerate(edge_list)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        θ = atan(Δy,Δx)
        startx = locs_x[i] + nodesize[i]*cos(θ)
        starty = locs_y[i] + nodesize[i]*sin(θ)
        endx = locs_x[j] + nodesize[j]*cos(θ+π)
        endy = locs_y[j] + nodesize[j]*sin(θ+π)
        lines[e_idx] = [(startx, starty), (endx, endy)]
    end
    lines
end

function graphline(edge_list, locs_x, locs_y, nodesize::Real)
    num_edges = length(edge_list)
    lines = Array{Vector{Tuple{Float64,Float64}}}(undef, num_edges)
    for (e_idx, e) in enumerate(edge_list)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        θ = atan(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ)
        starty = locs_y[i] + nodesize*sin(θ)
        endx = locs_x[j] + nodesize*cos(θ+π)
        endy = locs_y[j] + nodesize*sin(θ+π)
        lines[e_idx] = [(startx, starty), (endx, endy)]
    end
    return lines
end

function graphcurve(edge_list, locs_x, locs_y, nodesize::Vector{T}, arrowlength, angleoffset, outangle=pi/5) where {T<:Real}
    num_edges = length(edge_list)
    curves = Matrix{Tuple{Float64,Float64}}(undef, num_edges, 4)
    arrows = Array{Vector{Tuple{Float64,Float64}}}(undef, num_edges)
    for (e_idx, e) in enumerate(edge_list)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        θ = atan(Δy,Δx)
        startx = locs_x[i] + nodesize[i]*cos(θ+outangle)
        starty = locs_y[i] + nodesize[i]*sin(θ+outangle)
        endx = locs_x[j] + nodesize[j]*cos(θ+π-outangle)
        endy = locs_y[j] + nodesize[j]*sin(θ+π-outangle)

        d = hypot(endx-startx, endy-starty)

        if i == j
            d = 2 * π * nodesize[i]
        end

        arr1, arr2 = arrowcoords(θ-outangle, endx, endy, arrowlength, angleoffset)
        endx0 = (arr1[1] + arr2[1]) / 2
        endy0 = (arr1[2] + arr2[2]) / 2
        curves[e_idx, :] = curveedge(startx, starty, endx0, endy0, θ, outangle, d)
        arrows[e_idx] = [arr1, (endx, endy), arr2]
    end
    return curves, arrows
end

function graphcurve(edge_list, locs_x, locs_y, nodesize::Real, arrowlength, angleoffset, outangle=pi/5)
    num_edges = length(edge_list)
    curves = Matrix{Tuple{Float64,Float64}}(undef, num_edges, 4)
    arrows = Array{Vector{Tuple{Float64,Float64}}}(undef, num_edges)
    for (e_idx, e) in enumerate(edge_list)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        θ = atan(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ+outangle)
        starty = locs_y[i] + nodesize*sin(θ+outangle)
        endx = locs_x[j] + nodesize*cos(θ+π-outangle)
        endy = locs_y[j] + nodesize*sin(θ+π-outangle)

        d = hypot(endx-startx, endy-starty)

        if i == j
            d = 2 * π * nodesize
        end

        arr1, arr2 = arrowcoords(θ-outangle, endx, endy, arrowlength, angleoffset)
        endx0 = (arr1[1] + arr2[1]) / 2
        endy0 = (arr1[2] + arr2[2]) / 2
        curves[e_idx, :] = curveedge(startx, starty, endx0, endy0, θ, outangle, d)
        arrows[e_idx] = [arr1, (endx, endy), arr2]
    end
    return curves, arrows
end

function graphcurve(edge_list, locs_x, locs_y, nodesize::Real, outangle)
    num_edges = length(edge_list)
    curves = Matrix{Tuple{Float64,Float64}}(undef, num_edges, 4)
    for (e_idx, e) in enumerate(edge_list)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        θ = atan(Δy,Δx)
        startx = locs_x[i] + nodesize*cos(θ+outangle)
        starty = locs_y[i] + nodesize*sin(θ+outangle)
        endx = locs_x[j] + nodesize*cos(θ+π-outangle)
        endy = locs_y[j] + nodesize*sin(θ+π-outangle)

        d = hypot(endx-startx, endy-starty)

        if i == j
            d = 2 * π * nodesize
        end

        curves[e_idx, :] = curveedge(startx, starty, endx, endy, θ, outangle, d)
    end
    return curves
end

function graphcurve(edge_list, locs_x, locs_y, nodesize::Vector{T}, outangle) where {T<:Real}
    num_edges = length(edge_list)
    curves = Matrix{Tuple{Float64,Float64}}(undef, num_edges, 4)
    for (e_idx, e) in enumerate(edge_list)
        i = src(e)
        j = dst(e)
        Δx = locs_x[j] - locs_x[i]
        Δy = locs_y[j] - locs_y[i]
        θ = atan(Δy,Δx)
        startx = locs_x[i] + nodesize[i]*cos(θ+outangle)
        starty = locs_y[i] + nodesize[i]*sin(θ+outangle)
        endx = locs_x[j] + nodesize[j]*cos(θ+π-outangle)
        endy = locs_y[j] + nodesize[j]*sin(θ+π-outangle)

        d = hypot(endx-startx, endy-starty)

        if i == j
            d = 2 * π * nodesize[i]
        end

        curves[e_idx, :] = curveedge(startx, starty, endx, endy, θ, outangle, d)
    end
    return curves
end

# this function is copy from [IainNZ](https://github.com/IainNZ)'s [GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl)
function arrowcoords(θ, endx, endy, arrowlength, angleoffset=20.0/180.0*π)
    arr1x = endx - arrowlength*cos(θ+angleoffset)
    arr1y = endy - arrowlength*sin(θ+angleoffset)
    arr2x = endx - arrowlength*cos(θ-angleoffset)
    arr2y = endy - arrowlength*sin(θ-angleoffset)
    return (arr1x, arr1y), (arr2x, arr2y)
end

function curveedge(x1, y1, x2, y2, θ, outangle, d; k=0.5)

    r = d * k

    # Control points for left bending curve.
    xc1 = x1 + r * cos(θ + outangle)
    yc1 = y1 + r * sin(θ + outangle)

    xc2 = x2 + r * cos(θ + π - outangle)
    yc2 = y2 + r * sin(θ + π - outangle)

    return [(x1,y1) (xc1, yc1) (xc2, yc2) (x2, y2)]
end

function build_curved_edges(edge_list, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset, outangle)
    if arrowlengthfrac > 0.0
        curves_cord, arrows_cord = graphcurve(edge_list, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset, outangle)
        curves = curve(curves_cord[:,1], curves_cord[:,2], curves_cord[:,3], curves_cord[:,4])
        carrows = polygon(arrows_cord)
    else
        curves_cord = graphcurve(edge_list, locs_x, locs_y, nodesize, outangle)
        curves = curve(curves_cord[:,1], curves_cord[:,2], curves_cord[:,3], curves_cord[:,4])
        carrows = nothing
    end

    return curves, carrows
end

function build_straight_edges(edge_list, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset)
    if arrowlengthfrac > 0.0
        lines_cord, arrows_cord = graphline(edge_list, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset)
        lines = line(lines_cord)
        larrows = polygon(arrows_cord)
    else
        lines_cord = graphline(edge_list, locs_x, locs_y, nodesize)
        lines = line(lines_cord)
        larrows = nothing
    end

    return lines, larrows
end

function build_straight_curved_edges(g, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset, outangle)
    edge_list1 = filter(e -> src(e) != dst(e), collect(edges(g)))
    edge_list2 = filter(e -> src(e) == dst(e), collect(edges(g)))
    lines, larrows = build_straight_edges(edge_list1, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset)
    curves, carrows = build_curved_edges(edge_list2, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset, outangle)

    return lines, larrows, curves, carrows
end