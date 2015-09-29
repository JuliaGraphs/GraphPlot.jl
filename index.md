# **GraphPlot**

Plotting and visualization of graphs (networks)


# Getting Started

From the Julia REPL the latest version can be installed with
```{execute="false"}
Pkg.clone("git://github.com/afternone/GraphPlot.jl.git")
```
GraphPlot is then loaded with
```
using GraphPlot
```

# Usage
## karate network
```
g = graphfamous("karate")
gplot(g)

```

## Add node label
```
using Graphs
nodelabel = [1:num_vertices(g)]
gplot(g, nodelabel=nodelabel)

```

## Adjust node labels
```
gplot(g, nodelabel=nodelabel, nodelabeldist=1.5, nodelabelangleoffset=π/4)
```

## Control the node size
```
# nodes size proportional to their degree
nodesize = [Graphs.out_degree(v, g) for v in Graphs.vertices(g)]
gplot(g, nodesize=nodesize)
```

## Control the node color
Feed the keyword argument `nodefillc` a color array, ensure each node has a color. `length(nodefillc)` must be equal `|V|`.
```
using Colors

# Generate n maximally distinguishable colors in LCHab space.
nodefillc = distinguishable_colors(num_vertices(g), colorant"blue")
gplot(g, nodefillc=nodefillc, nodelabel=nodelabel, nodelabeldist=1.8, nodelabelangleoffset=π/4)
```

## Transparent
```
# stick out large degree nodes
alphas = nodesize/maximum(nodesize)
nodefillc = [RGBA(0.0,0.8,0.8,i) for i in alphas]
gplot(g, nodefillc=nodefillc)
```
## Control the node label size
```
nodelabelsize = nodesize
gplot(g, nodelabelsize=nodelabelsize, nodesize=nodesize, nodelabel=nodelabel)
```

## Draw edge labels
```
edgelabel = [1:Graphs.num_edges(g)]
gplot(g, edgelabel=edgelabel, nodelabel=nodelabel)
```

## Adjust edge labels
```
edgelabel = [1:Graphs.num_edges(g)]
gplot(g, edgelabel=edgelabel, nodelabel=nodelabel, edgelabeldistx=0.5, edgelabeldisty=0.5)
```

## Color the graph
```
# nodes membership
membership = [1,1,1,1,1,1,1,1,2,1,1,1,1,1,2,2,1,1,2,1,2,1,2,2,2,2,2,2,2,2,2,2,2,2]
nodecolor = [colorant"lightseagreen", colorant"orange"]
# membership color
nodefillc = nodecolor[membership]
gplot(g, nodefillc=nodefillc)
```

## Different layout
### random layout
```
gplot(g, layout=random_layout, nodelabel=nodelabel)
```
### circular layout
```
gplot(g, layout=circular_layout, nodelabel=nodelabel)
```
### spectral layout
```
gplot(g, layout=spectral_layout)
```
### shell layout
```
nlist = Array(Vector{Int}, 2) # two shells
nlist[1] = [1:5] # first shell
nlist[2] = [6:num_vertices(g)] # second shell
locs_x, locs_y = shell_layout(g, nlist)
gplot(g, locs_x, locs_y, nodelabel=nodelabel)
```
## Save to figure
```{execute="false"}
using Compose
# save to pdf
draw(PDF("karate.pdf", 16cm, 16cm), gplot(g))
# save to png
draw(PNG("karate.png", 16cm, 16cm), gplot(g))
# save to svg
draw(SVG("karate.svg", 16cm, 16cm), gplot(g))
```
# LightGraphs integration
```
using LightGraphs
h = watts_strogatz(50, 6, 0.3)
gplot(h)
```

# Function prototype
```{execute="false"}
function gplot{V, T<:Real}(
    G::AbstractGraph{V},
    locs_x::Vector{T}, locs_y::Vector{T};
    nodelabel::Union(Nothing, Vector) = nothing,
    nodelabelc::ComposeColor = colorant"black",
    nodelabelsize::Union(Real, Vector) = 4,
    nodelabeldist::Real = 0,
    nodelabelangleoffset::Real = π/4.0,
    edgelabel::Union(Nothing, Vector) = nothing,
    edgelabelc::ComposeColor = colorant"black",
    edgelabelsize::Union(Real, Vector) = 4,
    edgestrokec::ComposeColor = colorant"lightgray",
    edgelinewidth::Union(Real, Vector) = 1,
    edgelabeldistx::Real = 0,
    edgelabeldisty::Real = 0,
    nodesize::Union(Real, Vector) = 1,
    nodefillc::ComposeColor = colorant"turquoise",
    nodestrokec::ComposeColor = nothing,
    nodestrokelw::Union(Real, Vector) = 0,
    arrowlengthfrac::Real = Graphs.is_directed(G) ? 0.1 : 0.0,
    arrowangleoffset = 20.0/180.0*π)
```

# Arguments
+ `G` graph to plot
+ `layout` Optional. layout algorithm. Currently can be chose from
[random_layout, circular_layout, spring_layout, stressmajorize_layout, 
shell_layout, spectral_layout].
Default: `spring_layout`
+ `nodelabel` Optional. Labels for the vertices. Default: `nothing`
+ `nodefillc` Optional. Color to fill the nodes with.
Default: `colorant"turquoise"`
+ `nodestrokec` Color for the nodes stroke.
Default: `nothing`
+ `arrowlengthfrac` Fraction of line length to use for arrows.
Set to 0 for no arrows. Default: 0 for undirected graph and 0.1 for directed graph
+ `arrowangleoffset` angular width in radians for the arrows. Default: `π/9` (20 degrees)

# Reporting Bugs

Filing an issue to report a bug, counterintuitive behavior, or even to request a feature is extremely valuable in helping me prioritize what to work on, so don't hestitate.

