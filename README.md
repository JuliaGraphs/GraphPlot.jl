# GraphPlot

Graph layout and visualization algorithms based on [Compose.jl](https://github.com/dcjones/Compose.jl) and inspired by [GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl).

The `spring_layout` and `stressmajorize_layout` function are copy from [IainNZ](https://github.com/IainNZ)'s [GraphLayout.jl](https://github.com/IainNZ/GraphLayout.jl).

Other layout algorithms are wrapped from [NetworkX](https://github.com/networkx/networkx).

`gadfly.js` is copied from [Gadfly.jl](https://github.com/dcjones/Gadfly.jl)

# Getting Started

From the Julia REPL the latest version can be installed with
```{execute="false"}
Pkg.clone("git://github.com/JuliaGraphs/GraphPlot.jl.git")
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

## Curve edge
```
gplot(g, linetype="curve")
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

# Arguments
+ `G` graph to plot
+ `layout` Optional. layout algorithm. Currently can choose from
[random_layout, circular_layout, spring_layout, stressmajorize_layout, 
shell_layout, spectral_layout].
Default: `spring_layout`
+ `nodelabel` Optional. Labels for the vertices. Default: `nothing`
+ `nodefillc` Optional. Color to fill the nodes with.
Default: `colorant"turquoise"`
+ `nodestrokec` Color for the node stroke.
Default: `nothing`
+ `arrowlengthfrac` Fraction of line length to use for arrows.
Set to 0 for no arrows. Default: 0 for undirected graph and 0.1 for directed graph
+ `arrowangleoffset` angular width in radians for the arrows. Default: `π/9` (20 degrees)

# Reporting Bugs

Filing an issue to report a bug, counterintuitive behavior, or even to request a feature is extremely valuable in helping me prioritize what to work on, so don't hestitate.

