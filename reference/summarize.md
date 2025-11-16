# Summarize color classification results

This function takes a charisma object and produces a summary table
showing the proportion of pixels classified into each discrete color
category.

## Usage

``` r
summarize(charisma_obj)

summarise(charisma_obj)
```

## Arguments

- charisma_obj:

  A charisma object (output from
  [`charisma`](https://shawnschwartz.com/charisma/reference/charisma.md)
  or
  [`charisma2`](https://shawnschwartz.com/charisma/reference/charisma2.md))
  containing color classification results.

## Value

A data frame with one row per image showing the proportion of pixels
assigned to each color category. Row names are set to the basename of
the image file path.

## Details

The summary table shows the percentage of pixels classified into each of
the discrete color categories defined in the Color Look-Up Table (CLUT).
This provides a quantitative overview of the color composition of the
analyzed image.

## See also

[`charisma`](https://shawnschwartz.com/charisma/reference/charisma.md)
for the main classification pipeline,
[`validate`](https://shawnschwartz.com/charisma/reference/validate.md)
for CLUT validation

## Examples

``` r
if (FALSE) { # \dontrun{
# Run charisma on an image
result <- charisma("path/to/image.jpg")

# Summarize the color classification results
summary_table <- summarize(result)
print(summary_table)
} # }
```
