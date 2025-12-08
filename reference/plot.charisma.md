# Plot method for charisma objects

This function creates visualizations of color classification results
from a charisma analysis. It can display the original image, recolored
image, masked image, color proportions, and pavo color pattern geometry
results.

## Usage

``` r
# S3 method for class 'charisma'
plot(
  x,
  plot.all = TRUE,
  plot.original = FALSE,
  plot.recolored = FALSE,
  plot.masked = FALSE,
  plot.props = FALSE,
  plot.pavo.img = FALSE,
  plot.pavo.classes = FALSE,
  font.size = 1.75,
  props.x.cex = 1.5,
  real.bar.colors = TRUE,
  ...
)
```

## Arguments

- x:

  A charisma object (output from
  [`charisma`](https://shawnschwartz.com/charisma/reference/charisma.md)
  or
  [`charisma2`](https://shawnschwartz.com/charisma/reference/charisma2.md)).

- plot.all:

  Logical. If `TRUE`, plots all available visualizations. Default is
  `TRUE`.

- plot.original:

  Logical. If `TRUE`, plots the original image. Default is `FALSE`.

- plot.recolored:

  Logical. If `TRUE`, plots the recolored image showing discrete color
  classifications. Default is `FALSE`.

- plot.masked:

  Logical. If `TRUE`, plots the masked image after background removal.
  Default is `FALSE`.

- plot.props:

  Logical. If `TRUE`, plots a bar chart showing the proportion of pixels
  in each color category. Default is `FALSE`.

- plot.pavo.img:

  Logical. If `TRUE`, plots the image used for pavo color pattern
  geometry analysis. Default is `FALSE`. Only available if pavo analysis
  was performed.

- plot.pavo.classes:

  Logical. If `TRUE`, plots the color palette from pavo k-means
  clustering. Default is `FALSE`. Only available if pavo analysis was
  performed.

- font.size:

  Numeric. Size multiplier for plot text elements. Default is `1.75`.

- props.x.cex:

  Numeric. Size multiplier for x-axis labels in the proportions plot.
  Default is `1.5`.

- real.bar.colors:

  Logical. If `TRUE`, uses actual color values for bars in the
  proportions plot. If `FALSE`, uses a default color scheme. Default is
  `TRUE`.

- ...:

  Additional arguments (currently not used).

## Value

This function is called for its side effects (creating plots) and does
not return a value.

## Details

When `plot.all = TRUE`, all available plots are displayed in a
multi-panel layout. Individual plots can be selected by setting the
corresponding `plot.*` parameters to `TRUE`.

The function automatically detects whether pavo analysis results are
present in the charisma object and adjusts the plot layout accordingly.

## See also

[`charisma`](https://shawnschwartz.com/charisma/reference/charisma.md)
for the main classification pipeline,
[`charisma2`](https://shawnschwartz.com/charisma/reference/charisma2.md)
for batch processing

## Examples

``` r
# \donttest{
# Run charisma on an image
img <- system.file("extdata", "Tangara_fastuosa_LACM60421.png",
                   package = "charisma")
result <- charisma(img)
#> Warning: if any are empty, remove them
#> Discrete color classes identified: k=7
#> (black, blue, brown, green, grey, orange, yellow)
#> Image classification in progress...
#> Using single set of coldists for all images.
#> 

# Plot all results
plot(result)

#> Error in par(oldpar): invalid value specified for graphical parameter "pin"

# Plot only original and recolored images
plot(result, plot.all = FALSE, plot.original = TRUE, plot.recolored = TRUE)


# Plot color proportions
plot(result, plot.all = FALSE, plot.props = TRUE)

# }
```
