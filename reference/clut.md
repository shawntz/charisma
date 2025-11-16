# Default Color (Labels) Look Up Table (CLUT)

This LUT contains all color boundaries which cut up the continuous HSV
color space into 10 discrete color labels (i.e., black, white, grey,
brown, red, orange, yellow, green, blue, and purple).

## Usage

``` r
clut
```

## Format

A data frame with color boundary definitions for HSV color space. Each
row defines the HSV ranges for a specific discrete color category.

## Details

These color boundaries were determined by forming consensus across three
experts in the biology of color. Color boundaries were intentionally
tuned to reflect accurate color label classifications for images of
various bird and fish museum specimens.

Although we attempted to determine color boundaries in an object
fashion, there are of course perceptual biases and variability across
computer models/ displays that can influence whether any given color at
the boundary of the continuous color space is ultimately called one
color over another.

Accordingly, we gladly welcome further optimization of the default color
LUT and/or submissions of color LUTS specifically tuned to any given
organism or stimulus. Leveraging contributions from the community will
only help `charisma` be more useful for everybody who would like to use
it!

## See also

[`charisma`](https://shawnschwartz.com/charisma/reference/charisma.md)
for the main classification pipeline,
[`validate`](https://shawnschwartz.com/charisma/reference/validate.md)
for CLUT validation

## Examples

``` r
# View the default CLUT
head(clut)
#>   color.name default.hex
#> 1      black     #000000
#> 2      white     #FFFFFF
#> 3       grey     #808080
#> 4      brown     #964B00
#> 5        red     #FF0000
#> 6     orange     #FFA500
#>                                                           h
#> 1                                                    0::360
#> 2                                                    0::360
#> 3                               0::360,0::360,0::360,0::360
#> 4 0::54|320::360,0::54|300::360,16::54,20::40,20::40,36::40
#> 5              0::15|300::360,0::19|300::360,0::19|300::360
#> 6                        20::40,20::35,20::35,36::40,36::40
#>                                              s
#> 1                                       0::100
#> 2                                        0::19
#> 3                      0::25,0::19,0::19,0::15
#> 4 26::100,20::100,20::100,16::80,20::80,20::50
#> 5                      20::100,16::100,20::100
#> 6         81::100,20::80,81::100,20::50,51::80
#>                                           v
#> 1                                     0::30
#> 2                                   82::100
#> 3               31::40,41::60,61::75,76::81
#> 4 31::40,41::60,61::75,76::81,82::84,85::90
#> 5                     61::75,76::81,82::100
#> 6    76::85,85::100,82::100,91::100,85::100
```
