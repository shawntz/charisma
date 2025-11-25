# charisma 1.0.0

## Initial CRAN Release

First public release of charisma - an R package for reproducible color characterization of digital images for biological studies (and other things).

### Features

* **Automatic Color Classification**: Classify image colors into one of 10 discrete, biologically-inspired categories (black, blue, brown, green, grey, orange, purple, red, white, yellow)

* **CLUT System**: Color Look-Up Table (CLUT) with scientifically-defined HSV boundaries for each color category, validated across 3.6+ million color coordinates

* **Main Functions**:
  - `charisma()`: Main color classification pipeline with automatic thresholding
  - `charisma2()`: Rewind and edit saved charisma objects without re-running full pipeline
  - `color2label()`: Convert individual RGB/HSV colors to discrete labels
  - `validate()`: Validate CLUT completeness across color space

* **Integration**:
  - Leverages `recolorize` for image preprocessing and color segmentation
  - Optional `pavo` integration for color pattern geometry analysis
  - Supports both interactive and automated workflows

* **Reproducibility**:
  - Complete state tracking with merge/replacement history
  - Save and reload analyses with full provenance
  - Deterministic color classification for cross-study comparisons

* **Visualization**:
  - Plot methods for charisma objects
  - Mosaic plots showing color proportions
  - Color masks and classification overlays

### Documentation

* Comprehensive vignette with step-by-step tutorial
* Example data from bird (*Tangara fastuosa*)
* Tips for museum specimens and automated workflows
* pkgdown website with full documentation

### Testing

* Unit tests covering main functions
* Example workflows validated against published results
* CLUT validation across full HSV color space
