# Change colors of dendrogram tips

Internal function for
[recolorize::recluster](https://hiweller.github.io/recolorize/reference/recluster.html)
plotting.

## Usage

``` r
labelCol(x, hex_cols, pch = 20, cex = 2)
```

## Arguments

- x:

  Leaf of a dendrogram.

- hex_cols:

  Hex color codes for colors to change to.

- pch:

  The type of point to draw.

- cex:

  The size of the point.

## Value

An `hclust` object with colored tips.
