## Submission

This is the first submission of the charisma package.

## Test environments

* Local macOS (Darwin 25.2.0, R 4.5.2)
* GitHub Actions (macOS-latest, windows-latest, ubuntu-latest) (R-release, R-devel, R-oldrel-1)
* win-builder (R-release, R-devel, R-oldrel-1)

## R CMD check results

── R CMD check results ─────────────────────────────────────────────────────────── charisma 1.0.0 ────
Duration: 36.1s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

## Reverse dependencies

There are currently no reverse dependencies for this package.

## Additional comments

* This package implements the methods described in our manuscript currently under peer review
* The package integrates with recolorize (Weller et al. 2024, doi:10.1111/ele.14378) for image preprocessing
* Optional integration with pavo (Maia et al. 2019, doi:10.1111/2041-210X.13174) for color pattern analysis
* All examples and vignettes run successfully with required dependencies installed
* Example data included: Anampses caeruleopunctatus (marine fish) image for demonstrations
* Unit tests cover main functionality with 100% pass rate on supported platforms
