# Validate Color Look-Up Table completeness

This function validates that a Color Look-Up Table (CLUT) provides
complete and non-overlapping coverage of the HSV color space by testing
every HSV coordinate against the CLUT definitions. Validation ensures
each color maps to exactly one color class.

## Usage

``` r
validate(clut = charisma::clut, simple = TRUE)
```

## Arguments

- clut:

  Data frame containing the Color Look-Up Table with HSV boundaries for
  each color class. Default is
  [`charisma::clut`](https://shawnschwartz.com/charisma/reference/clut.md).

- simple:

  Logical. If `TRUE` (default), tests a reduced HSV space with 1-degree
  increments (361 x 101 x 101 = 3,682,561 coordinates). If `FALSE`, uses
  finer 0.5-degree increments, which is more thorough but significantly
  slower and best suited for cluster computing.

## Value

If validation passes, returns 0 and prints a success message. If
validation fails, returns a data frame containing all HSV coordinates
that either: (1) were not classified to any color, or (2) were
classified to multiple colors (indicating overlap).

## Details

The validation process:

1.  Generates a complete grid of HSV color space coordinates

2.  Uses parallel processing (all available cores - 1) to classify each
    coordinate using the CLUT definitions

3.  Checks that each coordinate maps to exactly one color class

4.  Reports any missing or duplicate classifications

Validation is essential when modifying the CLUT or creating custom CLUTs
for different image datasets. The process can take several minutes even
with `simple = TRUE`.

## References

Schwartz, S.T., Tsai, W.L.E., Karan, E.A., Juhn, M.S., Shultz, A.J.,
McCormack, J.E., Smith, T.B., and Alfaro, M.E. (2025). charisma: An R
package to perform reproducible color characterization of digital images
for biological studies. (In Review).

## See also

[`charisma`](https://shawnschwartz.com/charisma/reference/charisma.md)
for using validated CLUTs,
[`color2label`](https://shawnschwartz.com/charisma/reference/color2label.md)
for color classification

## Examples

``` r
if (FALSE) { # \dontrun{
# Validate the default CLUT (takes several minutes with parallel processing)

# Note: These examples are not run during R CMD check due to CRAN build
# limitations. With only 2 cores available during CRAN checks, validation
# can exceed 20 minutes.

result <- validate()

# Validate a custom CLUT
my_clut <- charisma::clut  # Start with default
# ... modify my_clut ...
result <- validate(clut = my_clut)

# More thorough validation (much slower, recommended for cluster computing)
result <- validate(simple = FALSE)
} # }
```
