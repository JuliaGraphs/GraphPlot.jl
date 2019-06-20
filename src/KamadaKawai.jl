import Optim
using Distances
function kamada_kawai_layout(G, X=nothing; C= 1.0, MAXITER=100 )
    Offset = 0.0
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
    # Stack individual graphs next to each other
    for SubGraphVertices in connected_components(G)
        SubGraph = induced_subgraph(G,SubGraphVertices)[1]
        N = nv(SubGraph)
        if X !== nothing
            _locs_x = locs_x[SubGraphVertices]
            _locs_y = locs_y[SubGraphVertices]
        else
            Vertices=collect(vertices(SubGraph))
            Vmax=findmax([degree(SubGraph,x) for x in vertices(SubGraph)])[2]
            filter!(x->x!=Vmax, Vertices)
            Shells=[[Vmax]]
            VComplement = copy(Shells[1])
            while length(Vertices)>0
                Interim = filter(x->!(x ∈ VComplement),vcat([collect(neighbors(SubGraph,s)) for s in Shells[end]]...))
                unique!(Interim)
                push!(Shells,Interim)
                filter!(x->!(x ∈ Shells[end]),Vertices)
                append!(VComplement,Shells[end])
            end
            _locs_x, _locs_y = shell_layout(SubGraph,Shells)
        end

        # The optimal distance between vertices
        # Currently only LightGraphs are supported using the Dijkstra shortest path algorithm
        K = zeros(N,N)
        for v in 1:N
            K[:,v] = dijkstra_shortest_paths(SubGraph,v).dists
        end

        M0 =  vcat(_locs_x',_locs_y')
        OptResult = Optim.optimize(x->Objective(x,K),(x,y) -> dObjective!(x,y,K), M0, method=Optim.LBFGS(),iterations = MAXITER )
        M0 = Optim.minimizer(OptResult)
        min_x, max_x = minimum(M0[1,:]), maximum(M0[1,:])
        min_y, max_y = minimum(M0[2,:]), maximum(M0[2,:])
        map!(z -> scaler(z, min_x, max_x), M0[1,:], M0[1,:])
        map!(z -> scaler(z, min_y, max_y), M0[2,:], M0[2,:])
        locs_x[SubGraphVertices] .= M0[1,:] .+ Offset
        locs_y[SubGraphVertices] .= M0[2,:]
        Offset += maximum(M0[1,:])+C
    end
    # Scale to unit square
    min_x, max_x = minimum(locs_x), maximum(locs_x)
    min_y, max_y = minimum(locs_y), maximum(locs_y)
    map!(z -> scaler(z, min_x, max_x), locs_x, locs_x)
    map!(z -> scaler(z, min_y, max_y), locs_y, locs_y)

    return locs_x,locs_y
end
