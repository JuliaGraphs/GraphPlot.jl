# to do
type PIENODE
    x::Float64
    y::Float64
    r::Float64
    prop::Vector{Float64}
    colors
    strokes
end

function pie(pn::PIENODE)
    p = [0.0;2pi*pn.prop/sum(pn.prop)]
    θ = cumsum(p)
    s = Vector[]
    for i=1:length(θ)-1
        push!(s, sector(pn.x, pn.y, pn.r, θ[i], θ[i+1]))
    end
    compose(context(),path(s), fill(pn.colors), stroke(pn.strokes))
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
