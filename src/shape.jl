# draw a regular n-gon
function ngon(x, y, r, n=3, θ=0.0)
    αs = linspace(0,2pi,n+1)[1:end-1]
    [(r*cos(α-θ)+x, r*sin(α-θ)+y) for α in αs]
end

function ngon(xs::Vector, ys::Vector, rs::Vector, ns::Vector=fill(3,length(xs)), θs::Vector=zeros(length(xs)))
    [ngon(xs[i], ys[i], rs[i], ns[i], θs[i]) for i=1:length(xs)]
end
