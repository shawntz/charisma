# Launch the CLUT Editor

Opens the interactive Color Lookup Table (CLUT) Editor in your web
browser. The CLUT Editor allows you to visually design and customize HSV
color space partitions for color classification, with 3D visualizations
and coverage statistics.

## Usage

``` r
launch_clut_editor(online = TRUE)
```

## Arguments

- online:

  Logical. If `TRUE` (default), opens the hosted version at
  <https://charisma.shawnschwartz.com/app>. If `FALSE`, opens the local
  version bundled with the package.

## Value

Invisibly returns the URL that was opened. Called primarily for its side
effect of opening the CLUT Editor in the default web browser.

## Details

The CLUT Editor provides:

- Visual editing of HSV color space boundaries for each color category

- Real-time coverage statistics showing gaps and overlaps

- Multiple visualization modes: hue slices, 3D cone, 3D scatter, hue
  wheel

- Export to R code or JSON for use with
  [`charisma()`](https://shawnschwartz.com/charisma/reference/charisma.md)

- Import/export functionality for sharing custom CLUTs

Custom CLUTs created with the editor can be validated using
[`validate()`](https://shawnschwartz.com/charisma/reference/validate.md)
and then used in
[`charisma()`](https://shawnschwartz.com/charisma/reference/charisma.md)
analyses via the `clut` parameter.

## See also

[`validate`](https://shawnschwartz.com/charisma/reference/validate.md)
for validating custom CLUTs,
[`charisma`](https://shawnschwartz.com/charisma/reference/charisma.md)
for using custom CLUTs in analyses,
[`clut`](https://shawnschwartz.com/charisma/reference/clut.md) for the
default Color Look-Up Table

## Examples

``` r
if (FALSE) { # \dontrun{
# Open the online CLUT Editor (recommended)
launch_clut_editor()

# Open the local version bundled with the package
launch_clut_editor(online = FALSE)
} # }
```
