## Resubmission

This is a resubmission addressing reviewer feedback from the initial submission.

### Changes made in response to reviewer feedback:

1. **Updated example documentation**:

   - Replaced `\dontrun{}` with `\donttest{}` for examples that can be executed but take longer than 5 seconds (`validate.Rd`, `summarize.Rd`, `plot.charisma.Rd`, `charisma2.Rd`).
   - Unwrapped examples that execute quickly (`charisma.Rd` basic example, `mosaic.Rd`).
   - Added `if(interactive()){}` wrapper for interactive examples where appropriate.

2. **Fixed graphical parameter handling**:
   - Added proper `on.exit()` calls immediately after `par()` changes in `mosaic.R` to ensure graphical parameters are restored even if the function exits unexpectedly.
   - Ensured all functions that modify graphical parameters restore them upon exit.

## Test environments

- Local macOS (Darwin 25.2.0, R 4.5.2)
- GitHub Actions (macOS-latest, windows-latest, ubuntu-latest) (R-release, R-devel, R-oldrel-1)
- win-builder (R-release)

## R CMD check results

── R CMD check results ───────────────────────────────────────────────────────── charisma 1.0.0 ────
Duration: 21.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

## Reverse dependencies

There are currently no reverse dependencies for this package.

## Additional comments

- This package implements the methods described in our manuscript currently under peer review
- The package integrates with recolorize (Weller et al. 2024, doi:10.1111/ele.14378) for image preprocessing
- Optional integration with pavo (Maia et al. 2019, doi:10.1111/2041-210X.13174) for color pattern analysis
- All examples and vignettes run successfully with required dependencies installed
- Example data included: _Tangara fastuosa_ (bird) image for demonstrations
- Unit tests cover main functionality with 100% pass rate on supported platforms
