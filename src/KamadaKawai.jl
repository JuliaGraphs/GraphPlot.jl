import Optim
using Distances
@doc raw"""
 Computes the layout corresponding to

 ```math
\min \sum_{i,j} (K_{ij} - \|x_i - x_j\|)^\frac{1}{2},
 ```
where $K_{ij}$ is the shortest path distance between vertices `i` abd `j`, and $x_i$ and $x_j$ are the positions of vertices `i` and `j` in the layout, respectively.

Inputs:

 - G: Graph to layout
 - X: starting positions. If no starting positions are provided a shell_layout is constructed.

Optional keyword arguments:

 - maxiter: maximum number of iterations Optim.optimize will perform in an attempt to optimize the layout.
 - distmx: Distance matrix for the Floyd-Warshall algorithm to discern shortest path distances on the graph. By default the edge weights of the graph.

 Outputs:

 - (`locs_x`, `locs_y`) positions in the x and y directions, respectively.

"""
function kamada_kawai_layout(G, X=nothing; maxiter=100, distmx=weights(G) )
    if !is_connected(G)
        @warn "This graph is disconnected. Results may not be reasonable."
    end
    if X===nothing
        locs_x = zeros(nv(G))
        locs_y = zeros(nv(G))
    else
        locs_x = X[1]
        locs_y = X[2]
    end

    function Objective(M,K)
        D = pairwise(Euclidean(),M, dims=2)
        D-= K
        R = sum(D.^2)/2
        return R
    end

    function dObjective!(dR,M,K)
        dR .= zeros(size(M))
        Vs = size(M,2)
        D = pairwise(Euclidean(),M, dims=2)
        D += I # Prevent division by zero
        D .= K./D # Use negative for simplicity, since diag K = 0 everything is fine.
        D .-= 1.0 # (K-(D+I))./(D+I) = K./(D+I) .- 1.0
        D += I # Remove the false diagonal
        for v1 in 1:Vs
            dR[:,v1] .= -M[:,v1]*sum(D[:,v1])
        end
        dR .+= M*D
        dR .*=2
        return dR
    end

    function scaler(z, a, b)
        2.0*((z - a)/(b - a)) - 1.0
    end
    N = nv(G)
    Vertices=collect(vertices(G))

    if X !== nothing
        _locs_x = locs_x
        _locs_y = locs_y
    else
        Vmax=findmax([degree(G,x) for x in vertices(G)])[2]
        filter!(!isequal(Vmax), Vertices)
        Shells=[[Vmax]]
        VComplement = copy(Shells[1])
        while !isempty(Vertices)
            Interim = filter(!∈(VComplement),vcat([collect(neighbors(G,s)) for s in Shells[end]]...))
            unique!(Interim)
            push!(Shells,Interim)
            filter!(!∈(Shells[end]),Vertices)
            append!(VComplement,Shells[end])
        end
        _locs_x, _locs_y = shell_layout(G,Shells)
    end

    # The optimal distance between vertices
    # Currently only LightGraphs are supported using the Dijkstra shortest path algorithm

    K = floyd_warshall_shortest_paths(G,distmx).dists

    M0 =  vcat(_locs_x',_locs_y')
    OptResult = Optim.optimize(x->Objective(x,K),(x,y) -> dObjective!(x,y,K), M0, method=Optim.LBFGS(), iterations = maxiter )
    M0 = Optim.minimizer(OptResult)

    (min_x, max_x), (min_y, max_y) = extrema(M0,dims=2)
    locs_x .= M0[1,:]
    locs_y .= M0[2,:]

    # Scale to unit square
    map!(z -> scaler(z, min_x, max_x), locs_x, locs_x)
    map!(z -> scaler(z, min_y, max_y), locs_y, locs_y)

    return locs_x,locs_y
end
