using Graphs
using GraphPlot

function collapse_graph{V}(g::AbstractGraph{V}, membership::Vector{Int})
    nb_comm = maximum(membership)

    collapsed_edge_weights = Array(Dict{Int,Float64}, nb_comm)
    for i=1:nb_comm
        collapsed_edge_weights[i] = Dict{Int,Float64}()
    end

    for e in Graphs.edges(g)
        u = source(e,g)
        v = target(e,g)
        u_idx = vertex_index(u,g)
        v_idx = vertex_index(v,g)
        u_comm = membership[u_idx]
        v_comm = membership[v_idx]

        # for special case of undirected network
        if !Graphs.is_directed(g)
            u_comm, v_comm = minmax(u_comm, v_comm)
        end

        if haskey(collapsed_edge_weights[u_comm], v_comm)
            collapsed_edge_weights[u_comm][v_comm] += 1
        else
            collapsed_edge_weights[u_comm][v_comm] = 1
        end
    end

    collapsed_graph = simple_graph(nb_comm, is_directed=false)
    collapsed_weights = Float64[]

    for u=1:nb_comm
        for (v,w) in collapsed_edge_weights[u]
            Graphs.add_edge!(collapsed_graph, u, v)
            push!(collapsed_weights, w)
        end
    end

    collapsed_graph, collapsed_weights
end

function community_layout{V}(g::AbstractGraph{V}, membership::Vector{Int})
    N = length(membership)
    lx = zeros(N)
    ly = zeros(N)
    comms = Dict{Int,Vector{Int}}()
    for (idx,lbl) in enumerate(membership)
        if haskey(comms, lbl)
            push!(comms[lbl], idx)
        else
            comms[lbl] = collect(idx)
        end
    end
    h, w = collapse_graph(g, membership)
    clx, cly = spring_layout(h)
    for (lbl, nodes) in comms
        θ = linspace(0, 2pi, length(nodes) + 1)[1:end-1]
        for (idx, node) in enumerate(nodes)
            lx[node] = 1.8*length(nodes)/N*cos(θ[idx]) + clx[lbl]
            ly[node] = 1.8*length(nodes)/N*sin(θ[idx]) + cly[lbl]
        end
    end
    lx, ly
end

function collapse_layout{V}(g::AbstractGraph{V}, membership::Vector{Int})
    lightg = LightGraphs.Graph(num_vertices(g))
    for e in Graphs.edges(g)
        u = vertex_index(source(e,g), g)
        v = vertex_index(target(e,g), g)
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
            comms[lbl] = collect(idx)
        end
    end
    h, w = collapse_graph(g, membership)
    clx, cly = spring_layout(h)
    for (lbl, nodes) in comms
        subg = lightg[nodes]
        sublx, subly = spring_layout(subg)
        θ = linspace(0, 2pi, length(nodes) + 1)[1:end-1]
        for (idx, node) in enumerate(nodes)
            lx[node] = 1.8*length(nodes)/N*sublx[idx] + clx[lbl]
            ly[node] = 1.8*length(nodes)/N*subly[idx] + cly[lbl]
        end
    end
    lx, ly
end
