# GraphPlot

![CI](https://github.com/JuliaGraphs/GraphPlot.jl/workflows/CI/badge.svg?branch=master)
[![version](https://juliahub.com/docs/GraphPlot/version.svg)](https://juliahub.com/ui/Packages/GraphPlot/bUwXr)

Graph layout and visualization algorithms based on [Compose.jl](https://github.com/dcjones/Compose.jl) and inspired by [GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl).

The `spring_layout` and `stressmajorize_layout` function are copy from [IainNZ](https://github.com/IainNZ)'s [GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl).

Other layout algorithms are wrapped from [NetworkX](https://github.com/networkx/networkx).

`gadfly.js` is copied from [Gadfly.jl](https://github.com/dcjones/Gadfly.jl)

# Getting Started

From the Julia REPL the latest version can be installed with
```julia
Pkg.add("GraphPlot")
```
GraphPlot is then loaded with
```julia
using GraphPlot
```

# Usage
## karate network
```julia
using Graphs: smallgraph
g = smallgraph(:karate)
gplot(g)

```

## Add node label
```julia
using Graphs
nodelabel = 1:nv(g)
gplot(g, nodelabel=nodelabel)

```

## Adjust node labels
```julia
gplot(g, nodelabel=nodelabel, nodelabeldist=1.5, nodelabelangleoffset=π/4)
```

## Control the node size
```julia
# nodes size proportional to their degree
nodesize = [Graphs.outdegree(g, v) for v in Graphs.vertices(g)]
gplot(g, nodesize=nodesize)
```

## Control the node color
Feed the keyword argument `nodefillc` a color array, ensure each node has a color. `length(nodefillc)` must be equal `|V|`.
```julia
using Colors

# Generate n maximally distinguishable colors in LCHab space.
nodefillc = distinguishable_colors(nv(g), colorant"blue")
gplot(g, nodefillc=nodefillc, nodelabel=nodelabel, nodelabeldist=1.8, nodelabelangleoffset=π/4)
```

## Transparent
```julia
# stick out large degree nodes
alphas = nodesize/maximum(nodesize)
nodefillc = [RGBA(0.0,0.8,0.8,i) for i in alphas]
gplot(g, nodefillc=nodefillc)
```
## Control the node label size
```julia
nodelabelsize = nodesize
gplot(g, nodelabelsize=nodelabelsize, nodesize=nodesize, nodelabel=nodelabel)
```

## Draw edge labels
```julia
edgelabel = 1:Graphs.ne(g)
gplot(g, edgelabel=edgelabel, nodelabel=nodelabel)
```

## Adjust edge labels
```julia
edgelabel = 1:Graphs.ne(g)
gplot(g, edgelabel=edgelabel, nodelabel=nodelabel, edgelabeldistx=0.5, edgelabeldisty=0.5)
```

## Color the graph
```julia
# nodes membership
membership = [1,1,1,1,1,1,1,1,2,1,1,1,1,1,2,2,1,1,2,1,2,1,2,2,2,2,2,2,2,2,2,2,2,2]
nodecolor = [colorant"lightseagreen", colorant"orange"]
# membership color
nodefillc = nodecolor[membership]
gplot(g, nodefillc=nodefillc)
```

## Different layout

### spring layout (default)
This is the defaut layout and will be chosen if no layout is specified. The [default parameters to the spring layout algorithm](https://github.com/JuliaGraphs/GraphPlot.jl/blob/master/src/layout.jl#L78) can be changed by supplying an anonymous function, e.g., if nodes appear clustered too tightly together, try
```julia
layout=(args...)->spring_layout(args...; C=20)
gplot(g, layout=layout, nodelabel=nodelabel)
```
where `C` influences the desired distance between nodes.

### random layout
```julia
gplot(g, layout=random_layout, nodelabel=nodelabel)
```
### circular layout
```julia
gplot(g, layout=circular_layout, nodelabel=nodelabel)
```
### spectral layout
```julia
gplot(g, layout=spectral_layout)
```
### shell layout
```julia
nlist = Vector{Vector{Int}}(undef, 2) # two shells
nlist[1] = 1:5 # first shell
nlist[2] = 6:nv(g) # second shell
locs_x, locs_y = shell_layout(g, nlist)
gplot(g, locs_x, locs_y, nodelabel=nodelabel)
```

## Curve edge
```julia
gplot(g, linetype="curve")
```

## Show plot

When using an IDE such as VSCode, `Cairo.jl` is required to visualize the plot inside the IDE.
When using the REPL, `gplothtml` will allow displaying the plot on a browser.

## Save to figure
```julia
using Compose
# save to pdf
draw(PDF("karate.pdf", 16cm, 16cm), gplot(g))
# save to png
draw(PNG("karate.png", 16cm, 16cm), gplot(g))
# save to svg
draw(SVG("karate.svg", 16cm, 16cm), gplot(g))
```
# Graphs.jl integration
```julia
using Graphs
h = watts_strogatz(50, 6, 0.3)
gplot(h)
```

# Arguments
+ `G` Graph to draw
+ `locs_x, locs_y` Locations of the nodes (will be normalized and centered). If not specified, will be obtained from `layout` kwarg.

# Keyword Arguments
+ `layout` Layout algorithm: `random_layout`, `circular_layout`, `spring_layout`, `shell_layout`, `stressmajorize_layout`, `spectral_layout`. Default: `spring_layout`
+ `NODESIZE` Max size for the nodes. Default: `3.0/sqrt(N)`
+ `nodesize` Relative size for the nodes, can be a Vector. Default: `1.0`
+ `nodelabel` Labels for the vertices, a Vector or nothing. Default: `nothing`
+ `nodelabelc` Color for the node labels, can be a Vector. Default: `colorant"black"`
+ `nodelabeldist` Distances for the node labels from center of nodes. Default: `0.0`
+ `nodelabelangleoffset` Angle offset for the node labels. Default: `π/4.0`
+ `NODELABELSIZE` Largest fontsize for the vertice labels. Default: `4.0`
+ `nodelabelsize` Relative fontsize for the vertice labels, can be a Vector. Default: `1.0`
+ `nodefillc` Color to fill the nodes with, can be a Vector. Default: `colorant"turquoise"`
+ `nodestrokec` Color for the nodes stroke, can be a Vector. Default: `nothing`
+ `nodestrokelw` Line width for the nodes stroke, can be a Vector. Default: `0.0`
+ `edgelabel` Labels for the edges, a Vector or nothing. Default: `[]`
+ `edgelabelc` Color for the edge labels, can be a Vector. Default: `colorant"black"`
+ `edgelabeldistx, edgelabeldisty` Distance for the edge label from center of edge. Default: `0.0`
+ `EDGELABELSIZE` Largest fontsize for the edge labels. Default: `4.0`
+ `edgelabelsize` Relative fontsize for the edge labels, can be a Vector. Default: `1.0`
+ `EDGELINEWIDTH` Max line width for the edges. Default: `0.25/sqrt(N)`
+ `edgelinewidth` Relative line width for the edges, can be a Vector. Default: `1.0`
+ `edgestrokec` Color for the edge strokes, can be a Vector. Default: `colorant"lightgray"`
+ `arrowlengthfrac` Fraction of line length to use for arrows. Equal to 0 for undirected graphs. Default: `0.1` for the directed graphs
+ `arrowangleoffset` Angular width in radians for the arrows. Default: `π/9 (20 degrees)`
+ `linetype` Type of line used for edges ("straight", "curve"). Default: "straight"
+ `outangle` Angular width in radians for the edges (only used if `linetype = "curve`). Default: `π/5 (36 degrees)`
+ `background_color` Color for the plot background. Default: `nothing`

# Reporting Bugs

Filing an issue to report a bug, counterintuitive behavior, or even to request a feature is extremely valuable in helping me prioritize what to work on, so don't hestitate.
