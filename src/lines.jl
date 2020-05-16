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
        θ = atan(Δy,Δx)
        startx = locs_x[i] + nodesize[i]*cos(θ)
        starty = locs_y[i] + nodesize[i]*sin(θ)
        endx = locs_x[j] + nodesize[j]*cos(θ+π)
        endy = locs_y[j] + nodesize[j]*sin(θ+π)
        lines[e_idx] = [(startx, starty), (endx, endy)]
        arr1, arr2 = arrowcoords(θ, endx, endy, arrowlength, angleoffset)
        arrows[e_idx] = [arr1, (endx, endy), arr2]
    end
    lines, arrows
end

function hasReverseEdge(g, e)
	return has_edge(g,dst(e),src(e))
end

function filterUndef(array)
	result = nothing
	for i in 1:length(array) 
		if isassigned(array,i) 
			if result == nothing
				result = typeof(array[i])[]
			end
			push!(result,array[i])
		end
	end
	return result
end

function graphline(g::AbstractGraph{T}, locs_x, locs_y, nodesize::Real, arrowlength, angleoffset) where {T<:Integer}
    lines = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    arrows = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    for (e_idx, e) in enumerate(edges(g))
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
		println("graphLineEdited")
		#TODO add propertie in patch
		#TODO extend to other functions
		if !hasReverseEdge(g,e) 	
			arr1, arr2 = arrowcoords(θ, endx, endy, arrowlength, angleoffset)
			arrows[e_idx] = [arr1, (endx, endy), arr2]
		end
    end
	arrows = filterUndef(arrows)
    lines, arrows
end

function graphline(g::AbstractGraph{T}, locs_x, locs_y, nodesize::Vector{<:Real}) where {T<:Integer}
    lines = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    for (e_idx, e) in enumerate(edges(g))
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

function graphline(g::AbstractGraph{T}, locs_x, locs_y, nodesize::Real) where {T<:Integer}
    lines = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    for (e_idx, e) in enumerate(edges(g))
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

function graphcurve(g::AbstractGraph{T}, locs_x, locs_y, nodesize::Vector{<:Real}, arrowlength, angleoffset, outangle=pi/5) where {T<:Integer}
    curves = Matrix{Tuple{Float64,Float64}}(undef, ne(g), 4)
    arrows = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    for (e_idx, e) in enumerate(edges(g))
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

        arr1, arr2 = arrowcoords(θ-outangle, endx, endy, arrowlength, angleoffset)
        arrows[e_idx] = [arr1, (endx, endy), arr2]
    end
    return curves, arrows
end

function graphcurve(g, locs_x, locs_y, nodesize::Real, arrowlength, angleoffset, outangle=pi/5)
    curves = Matrix{Tuple{Float64,Float64}}(undef, ne(g), 4)
    arrows = Array{Vector{Tuple{Float64,Float64}}}(undef, ne(g))
    for (e_idx, e) in enumerate(edges(g))
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

        arr1, arr2 = arrowcoords(θ-outangle, endx, endy, arrowlength, angleoffset)
        arrows[e_idx] = [arr1, (endx, endy), arr2]
    end
    return curves, arrows
end

function graphcurve(g, locs_x, locs_y, nodesize::Real, outangle)
    curves = Matrix{Tuple{Float64,Float64}}(undef, ne(g), 4)
    for (e_idx, e) in enumerate(edges(g))
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

function graphcurve(g::AbstractGraph{T}, locs_x, locs_y, nodesize::Vector{<:Real}, outangle) where {T<:Integer}
    curves = Matrix{Tuple{Float64,Float64}}(undef, ne(g), 4)
    for (e_idx, e) in enumerate(edges(g))
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
