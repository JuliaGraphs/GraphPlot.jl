using LightGraphs
typealias LightGraph Union{LightGraphs.Graph, LightGraphs.DiGraph}

"""Plot LightGraphs directly"""
function gplot(g::LightGraph; keyargs...)
    s = Graphs.simple_graph(nv(g), is_directed=LightGraphs.is_directed(g))
    for e in LightGraphs.edges(g)
           Graphs.add_edge!(s, src(e), dst(e))
    end
    gplot(s; keyargs...)
end
