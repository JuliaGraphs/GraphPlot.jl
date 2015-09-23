# Usage
```
using GraphPlot
using Graphs
g = simple_house_graph()
GraphPlot.plot(g, circular_layout(g)...)
```
# Examples
```
locs_x, locs_y = random_layout(g)
GraphPlot.plot(g, locs_x, locs_y)
```
