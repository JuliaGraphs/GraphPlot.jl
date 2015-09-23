# GraphPlot

[![Build Status](https://travis-ci.org/afternone/GraphPlot.jl.svg?branch=master)](https://travis-ci.org/afternone/GraphPlot.jl)


GraphPlot is package for plotting and visualization of graphs (networks)

## Getting Started

From the Julia REPL a up to date version can be installed with
```
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
Feed the keyword argument `nodefillc` an color array, ensure each node has a color. `length(nodefillc)` must be equal `|V|`.
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

## You also can draw the edge label
```
edgelabels = [1:num_edges(g)]
gplot(g, edgelabels=edgelabels)
```

# Arguments
+ `G` graph to plot
+ `layout` Optional. layout algorithm. Currently can be chose from
[random_layout, circular_layout, spring_layout, stressmajorize_layout].
Default: `spring_layout`
+ `labels` Optional. Labels for the vertices. Default: `Any[]``
+ `nodefillc` Optional. Color to fill the nodes with.
Default: `fill(colorant"turquoise", N)`
+ `nodestrokec` Color for the nodes stroke.
Default: `fill(colorant"gray", N)`
+ `arrowlengthfrac` Fraction of line length to use for arrows.
Set to 0 for no arrows. Default: 0 for undirected graph and 0.1 for directed graph
+ `angleoffset` angular width in radians for the arrows. Default: `π/9` (20 degrees)

# Reporting Bugs

Filing an issue to report a bug, counterintuitive behavior, or even to request a feature is extremely valuable in helping me prioritize what to work on, so don't hestitate.

