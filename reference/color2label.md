# Convert RGB color triplets to discrete color labels

This function classifies an RGB color triplet into one of the discrete
color categories defined in the Color Look-Up Table (CLUT) by testing
for membership within non-overlapping HSV ranges.

## Usage

``` r
color2label(color_triplet, verbose = FALSE, clut = charisma::clut)
```

## Arguments

- color_triplet:

  Numeric vector of length 3 containing RGB values (0-255 scale). The
  vector should be c(red, green, blue).

- verbose:

  Logical. If `TRUE`, prints the color triplet and classification
  results for debugging. Default is `FALSE`.

- clut:

  Data frame containing the Color Look-Up Table with HSV boundaries for
  each color class. Default is
  [`charisma::clut`](https://shawnschwartz.com/charisma/reference/clut.md).

## Value

Character string indicating the matched color label from the CLUT.
Returns `"NA"` if the input contains NA values.

## Details

The classification process involves:

1.  Converting RGB to HSV (using `rgb2hsv`)

2.  Scaling HSV to match CLUT ranges (H: 0-360, S: 0-100, V: 0-100)

3.  Testing the HSV coordinate against all color definitions in the CLUT

4.  Returning the single matching color label

Each color in the CLUT has non-overlapping HSV ranges that partition the
entire HSV color space. If multiple matches occur, a warning is issued
as this indicates overlapping color boundaries in the CLUT.

## References

Schwartz, S.T., Tsai, W.L.E., Karan, E.A., Juhn, M.S., Shultz, A.J.,
McCormack, J.E., Smith, T.B., and Alfaro, M.E. (2025). charisma: An R
package to perform reproducible color characterization of digital images
for biological studies. (In Review).

## See also

[`charisma`](https://shawnschwartz.com/charisma/reference/charisma.md)
for the main classification pipeline,
[`validate`](https://shawnschwartz.com/charisma/reference/validate.md)
for CLUT validation

## Examples

``` r
# Classify a blue RGB color
color2label(c(0, 0, 255))
#> [1] "blue"

# Classify a red RGB color
color2label(c(255, 0, 0))
#> [1] "red"

# Verbose output for debugging
color2label(c(128, 128, 128), verbose = TRUE)
#>   h s         v
#> 1 0 0 0.5019608
#>  black  white   grey  brown    red orange yellow  green   blue purple 
#>      0      0      1      0      0      0      0      0      0      0 
#> [1] "grey"
```
