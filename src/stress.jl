using LinearAlgebra

# This layout algorithm is copy from [IainNZ](https://github.com/IainNZ)'s [GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl)
@doc """
Compute graph stressmajorize_layoutlayout using stress majorization

Inputs:

    g: The input graph.
    p: Dimension of embedding (default: 2)
    w: Matrix of weights. If not specified, defaults to
           w[i,j] = δ[i,j]^-2 if δ[i,j] is nonzero, or 0 otherwise
    X0: Initial guess for the layout. Coordinates are given in rows.
        If not specified, default to random matrix of Gaussians

Additional optional keyword arguments control the convergence of the algorithm
and the additional output as requested:

    maxiter:   Maximum number of iterations. Default: 400size(X0, 1)^2
    abstols:   Absolute tolerance for convergence of stress.
               The iterations terminate if the difference between two
               successive stresses is less than abstol.
               Default: √(eps(eltype(X0))
    reltols:   Relative tolerance for convergence of stress.
               The iterations terminate if the difference between two
               successive stresses relative to the current stress is less than
               reltol. Default: √(eps(eltype(X0))
    abstolx:   Absolute tolerance for convergence of layout.
               The iterations terminate if the Frobenius norm of two successive
               layouts is less than abstolx. Default: √(eps(eltype(X0))
    C:   The target distance between a pair of connected vertices.
    verbose:   If true, prints convergence information at each iteration.
               Default: false

Output:

    The final layout X, with coordinates given in rows, unless returnall=true.

Reference:

    The main equation to solve is (8) of:

    @incollection{
        author = {Emden R Gansner and Yehuda Koren and Stephen North},
        title = {Graph Drawing by Stress Majorization}
        year={2005},
        isbn={978-3-540-24528-5},
        booktitle={Graph Drawing},
        seriesvolume={3383},
        series={Lecture Notes in Computer Science},
        editor={Pach, J\'anos},
        doi={10.1007/978-3-540-31843-9_25},
        publisher={Springer Berlin Heidelberg},
        pages={239--250},
    }
"""
function stressmajorize_layout(g::AbstractGraph,
                               p=2,
                               w=nothing,
                               X0=randn(nv(g), p);
                               maxiter = 400size(X0, 1)^2,
                               abstols=√(eps(eltype(X0))),
                               reltols=√(eps(eltype(X0))),
                               abstolx=√(eps(eltype(X0))),
                               C = 1.0,
                               verbose = false,
                               )

    @assert size(X0, 2)==p
    # graph theoretical distance
    δ = C .* hcat([gdistances(g, i) for i=1:nv(g)]...)

    if w === nothing
        w = δ .^ -2
        w[.!isfinite.(w)] .= 0
    end

    @assert size(X0, 1)==size(δ, 1)==size(δ, 2)==size(w, 1)==size(w, 2)
    Lw = weightedlaplacian(w)
    pinvLw = pinv(Lw)
    newstress = stress(X0, δ, w)
    iter = 0
    L = zeros(nv(g), nv(g))
    local X
    for outer iter = 1:maxiter
        #TODO the faster way is to drop the first row and col from the iteration
        X = pinvLw * (LZ!(L, X0, δ, w)*X0)
        @assert all(isfinite.(X))
        newstress, oldstress = stress(X, δ, w), newstress
        verbose && @info("""Iteration $iter
        Change in coordinates: $(norm(X - X0))
        Stress: $newstress (change: $(newstress-oldstress))
        """)
        if abs(newstress - oldstress) < reltols * newstress ||
                abs(newstress - oldstress) < abstols ||
                norm(X - X0) < abstolx
            break
        end
        X0 = X
    end
    iter == maxiter && @warn("Maximum number of iterations reached without convergence")
    return X[:,1], X[:,2]
end

@doc """
Stress function to majorize

Input:
    X: A particular layout (coordinates in rows)
    d: Matrix of pairwise distances
    w: Weights for each pairwise distance

See (1) of Reference
"""
function stress(X, d, w)
    s = 0.0
    n = size(X, 1)
    @assert n==size(d, 1)==size(d, 2)==size(w, 1)==size(w, 2)
    @inbounds for j=1:n, i=1:j-1
        s += w[i, j] * (sqrt(sum(k->abs2(X[i,k] - X[j,k]), 1:size(X,2))) - d[i,j])^2
    end
    @assert isfinite(s)
    return s
end

@doc """
Compute weighted Laplacian given ideal weights w

Lʷ defined in (4) of the Reference
"""
function weightedlaplacian(w)
    n = LinearAlgebra.checksquare(w)
    T = eltype(w)
    Lw = zeros(T, n, n)
    for i=1:n
        D = zero(T)
        for j=1:n
            i==j && continue
            Lw[i, j] = -w[i, j]
            D += w[i, j]
        end
        Lw[i, i] = D
    end
    return Lw
end

@doc """
Computes L^Z defined in (5) of the Reference

Input: L: A matrix to store the result.
       Z: current layout (coordinates)
       d: Ideal distances (default: all 1)
       w: weights (default: d.^-2)
"""
function LZ!(L, Z, d, w)
    fill!(L, zero(eltype(L)))
    n = size(Z, 1)
    @inbounds for i=1:n-1
        D = 0.0
        for j=i+1:n
            nrmz = sqrt(sum(k->abs2(Z[i,k] - Z[j,k]), 1:size(Z,2)))
            δ = w[i, j] * d[i, j]
            lij = -δ/max(nrmz, 1e-8)
            L[i, j] = lij
            D -= lij
        end
        L[i, i] += D
    end
    @inbounds for i=2:n
        D = 0.0
        for j=1:i-1
            lij = L[j,i]
            L[i,j] = lij
            D -= lij
        end
        L[i,i] += D
    end
    return L
end
