# Re-analyze and edit saved charisma objects

The `charisma2` function allows users to step through and edit
previously saved `charisma` objects. This function enables rewinding to
specific merge or replacement states, applying different thresholds, or
continuing interactive editing from any saved state, ensuring full
reproducibility of the analysis.

## Usage

``` r
charisma2(
  charisma.obj,
  interactive = TRUE,
  new.threshold = NULL,
  which.state = c("none", "merge", "replace"),
  state.index = NULL,
  k.override = NULL
)
```

## Arguments

- charisma.obj:

  A `charisma` object to be re-analyzed. Cannot be a `charisma2` object
  (attempting to run `charisma2` on a `charisma2` object will produce an
  error).

- interactive:

  Logical. If `TRUE`, enters interactive mode for manual color
  adjustments. Default is `TRUE`.

- new.threshold:

  Numeric value between 0 and 1 to apply a different color proportion
  threshold than the original analysis. If `NULL`, uses the original
  threshold. Default is `NULL`.

- which.state:

  Character string specifying which state to revert to. Options are
  `"none"` (most recent state), `"merge"` (specific merge state), or
  `"replace"` (specific replacement state). Default is `"none"`.

- state.index:

  Integer specifying which state index to revert to when `which.state`
  is `"merge"` or `"replace"`. Must be provided if `which.state` is not
  `"none"`. Default is `NULL`.

- k.override:

  Integer to force a specific number of color clusters. Default is
  `NULL`.

## Value

A `charisma2` object (also of class `charisma`) containing the same
structure as a `charisma` object, with updated states based on the
specified reversion point and any new operations performed.

## Details

The `charisma2` function provides powerful state management
capabilities:

- **State rewinding**: Jump to any previous merge or replacement state

- **Re-thresholding**: Apply different color proportion thresholds
  without re-running the entire pipeline

- **Continued editing**: Resume interactive editing from saved states

- **Full provenance**: All operations maintain complete history for
  reproducibility

Note: Interactive adjustment of merge states is disabled if replacement
states exist, as replacement operations depend on post-merge cluster
indices.

## References

Schwartz, S.T., Tsai, W.L.E., Karan, E.A., Juhn, M.S., Shultz, A.J.,
McCormack, J.E., Smith, T.B., and Alfaro, M.E. (2025). charisma: An R
package to perform reproducible color characterization of digital images
for biological studies. (In Review).

## See also

[`charisma`](https://shawnschwartz.com/charisma/reference/charisma.md)
for initial color classification,
[`plot.charisma`](https://shawnschwartz.com/charisma/reference/plot.charisma.md)
for visualization

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a previously saved charisma object
obj <- readRDS("path/to/charisma_object.RDS")

# Re-enter interactive mode with original threshold
result <- charisma2(obj, interactive = TRUE)

# Apply a different threshold without interactive mode
result <- charisma2(obj, interactive = FALSE, new.threshold = 0.10)

# Revert to a specific merge state
result <- charisma2(obj, which.state = "merge", state.index = 2)

# Revert to a specific replacement state
result <- charisma2(obj, which.state = "replace", state.index = 1)
} # }
```
