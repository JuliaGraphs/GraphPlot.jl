using GraphPlot

function collapse_graph(g::AbstractGraph, membership::Vector{Int})
    nb_comm = maximum(membership)

    collapsed_edge_weights = Vector{Dict{Int,Float64}}(undef, nb_comm)
    for i=1:nb_comm
        collapsed_edge_weights[i] = Dict{Int,Float64}()
    end

    for e in edges(g)
        u = src(e)
        v = dst(e)
        u_comm = membership[u]
        v_comm = membership[v]

        # for special case of undirected network
        if !is_directed(g)
            u_comm, v_comm = minmax(u_comm, v_comm)
        end

        if haskey(collapsed_edge_weights[u_comm], v_comm)
            collapsed_edge_weights[u_comm][v_comm] += 1
        else
            collapsed_edge_weights[u_comm][v_comm] = 1
        end
    end

    collapsed_graph = SimpleGraph(nb_comm)
    collapsed_weights = Float64[]

    for u=1:nb_comm
        for (v,w) in collapsed_edge_weights[u]
            add_edge!(collapsed_graph, u, v)
            push!(collapsed_weights, w)
        end
    end

    return collapsed_graph, collapsed_weights
end

function community_layout(g::AbstractGraph, membership::Vector{Int})
    N = length(membership)
    lx = zeros(N)
    ly = zeros(N)
    comms = Dict{Int,Vector{Int}}()
    for (idx,lbl) in enumerate(membership)
        if haskey(comms, lbl)
            push!(comms[lbl], idx)
        else
            comms[lbl] = Int[idx]
        end
    end
    h, w = collapse_graph(g, membership)
    clx, cly = spring_layout(h)
    for (lbl, nodes) in comms
        θ = range(0, stop=2pi, length=(length(nodes) + 1))[1:end-1]
        for (idx, node) in enumerate(nodes)
            lx[node] = 1.8*length(nodes)/N*cos(θ[idx]) + clx[lbl]
            ly[node] = 1.8*length(nodes)/N*sin(θ[idx]) + cly[lbl]
        end
    end
    return lx, ly
end

function collapse_layout(g::AbstractGraph, membership::Vector{Int})
    lightg = LightGraphs.SimpleGraph(nv(g))
    for e in edges(g)
        u = src(e)
        v = dst(e)
        LightGraphs.add_edge!(lightg, u, v)
    end
    N = length(membership)
    lx = zeros(N)
    ly = zeros(N)
    comms = Dict{Int,Vector{Int}}()
    for (idx,lbl) in enumerate(membership)
        if haskey(comms, lbl)
            push!(comms[lbl], idx)
        else
            comms[lbl] = Int[idx]
        end
    end
    h, w = collapse_graph(g, membership)
    clx, cly = spring_layout(h)
    for (lbl, nodes) in comms
        subg = lightg[nodes]
        sublx, subly = spring_layout(subg)
        θ = range(0, stop=2pi, length=(length(nodes) + 1))[1:end-1]
        for (idx, node) in enumerate(nodes)
            lx[node] = 1.8*length(nodes)/N*sublx[idx] + clx[lbl]
            ly[node] = 1.8*length(nodes)/N*subly[idx] + cly[lbl]
        end
    end
    return lx, ly
end
