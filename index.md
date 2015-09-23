# **GraphPlot**

GraphPlot is package for plotting and visualization of graphs (networks)


# Getting Started

From the Julia REPL a up to date version can be installed with
```{execute="false"}
Pkg.clone("git://github.com/afternone/GraphPlot.jl.git")
```
GraphPlot is then loaded with
```
using GraphPlot
```

# Examples
## A simple example
```
using Graphs

g = simple_house_graph()
gplot(g)

```

## Control the node color
Feed the keyword argument `nodefillc` a color array, ensure each node has a color. `length(nodefillc)` must be equal `|V|`.
```
using Colors

# Generate n maximally distinguishable colors in LCHab space.
nodefillc = distinguishable_colors(num_vertices(g), colorant"blue")
gplot(g, nodefillc=nodefillc)
```

## Control the node size
```
nodesize = Float64[out_degree(v, g) for v in vertices(g)]
gplot(g, nodesize=nodesize)
```

## Control the label size
```
labels = [1:num_vertices(g)]
labelsize = Float64[out_degree(v, g) for v in vertices(g)]
nodesize = Float64[out_degree(v, g) for v in vertices(g)]
gplot(g, labels=labels, labelsize=labelsize, nodesize=nodesize)
```

## You can also draw the edge label
```
edgelabels = [1:num_edges(g)]
gplot(g, edgelabels=edgelabels)
```

## Karate club network
```
# edges, first and second element is the first edge, and so on
es = [1,2,1,3,1,4,1,5,1,6,1,7,1,8,1,9,1,11,1,12,1,13,1,14,1,18,1,
      20,1,22,1,32,2,3,2,4,2,8,2,14,2,18,2,20,2,22,2,31,3,4,3,8,3,
      9,3,10,3,14,3,28,3,29,3,33,4,8,4,13,4,14,5,7,5,11,6,7,6,11,
      6,17,7,17,9,31,9,33,9,34,10,34,14,34,15,33,15,34,16,33,16,34,
      19,33,19,34,20,34,21,33,21,34,23,33,23,34,24,26,24,28,24,30,24,
      33,24,34,25,26,25,28,25,32,26,32,27,30,27,34,28,34,29,32,29,34,
      30,33,30,34,31,33,31,34,32,33,32,34,33,34]

# construct the network
karate = simple_graph(maximum(es), is_directed=false)
for i=1:2:length(es)
    add_edge!(karate, es[i], es[i+1])
end

# nodes membership
membership = [1,1,1,1,1,1,1,1,2,1,1,1,1,1,2,2,1,1,2,1,2,1,2,2,2,2,2,2,2,2,2,2,2,2]
nodecolor = [colorant"lightseagreen", colorant"orange"]
# membership color
nodefillc = nodecolor[membership]
gplot(karate, nodefillc=nodefillc)
```


# Arguments
+ `G` graph to plot
+ `layout` Optional. layout algorithm. Currently can be chose from
[random_layout, circular_layout, spring_layout, stressmajorize_layout].
Default: `spring_layout`
+ `labels` Optional. Labels for the vertices. Default: `Any[]`
+ `nodefillc` Optional. Color to fill the nodes with.
Default: `fill(colorant"turquoise", N)`
+ `nodestrokec` Color for the nodes stroke.
Default: `fill(colorant"gray", N)`
+ `arrowlengthfrac` Fraction of line length to use for arrows.
Set to 0 for no arrows. Default: 0 for undirected graph and 0.1 for directed graph
+ `angleoffset` angular width in radians for the arrows. Default: `π/9` (20 degrees)

# Reporting Bugs

Filing an issue to report a bug, counterintuitive behavior, or even to request a feature is extremely valuable in helping me prioritize what to work on, so don't hestitate.

