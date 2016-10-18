"""
read some famous graphs

**Paramenters**

*graphname*
Currently, `graphname` can be one of ["karate", "football", "dolphins",
"netscience", "polbooks", "power", "cond-mat"]

**Return**
a graph

**Example**
    julia> g = graphfamous("karate")
"""
function graphfamous(graphname::AbstractString)
    file = joinpath(Pkg.dir("GraphPlot"), "data", graphname*".dat")
    readedgelist(file)
end

"""read graph from in edgelist format"""
function readedgelist(filename; is_directed::Bool=false, start_index::Int=0, delim::Char=' ')
    es = readdlm(filename, delim, Int)
    es = unique(es, 1)
    if start_index == 0
        es = es + 1
    end
    N = maximum(es)
    if is_directed
        g = DiGraph(N)
        for i=1:size(es,1)
            add_edge!(g, es[i,1], es[i,2])
        end
        return g
    else
        for i=1:size(es,1)
            if es[i,1] > es[i,2]
                es[i,1], es[i,2] = es[i,2], es[i,1]
            end
        end
        es = unique(es, 1)
        g = Graph(N)
        for i=1:size(es,1)
            add_edge!(g, es[i,1], es[i,2])
        end
        return g
    end
end
