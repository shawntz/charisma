# Getting Started

## Introduction

The `charisma` package provides a standardized and reproducible
framework for characterizing and classifying discrete color classes from
digital images of biological organisms. This vignette walks you through
the basic workflow and demonstrates key features of the package.

### What does charisma do?

`charisma` automatically determines the presence or absence of 10
human-visible color categories in images:

- **black**, **blue**, **brown**, **green**, **grey**
- **orange**, **purple**, **red**, **white**, **yellow**

The package uses a biologically-inspired Color Look-Up Table (CLUT) that
partitions HSV color space into non-overlapping regions, ensuring each
color maps to exactly one category.

## Installation

### System Dependencies

`charisma` depends on spatial R packages that require system-level
libraries. Install these first:

**macOS (via Homebrew):**

``` bash
brew install udunits gdal proj geos
```

**Ubuntu/Debian:**

``` bash
sudo apt-get install libudunits2-dev libgdal-dev libgeos-dev libproj-dev
```

**Fedora/RedHat:**

``` bash
sudo dnf install udunits2-devel gdal-devel geos-devel proj-devel
```

### Development Version (GitHub)

``` r
# install.packages("remotes")
remotes::install_github("shawntz/charisma")
```

### Stable Version (CRAN)

``` r
install.packages("charisma")  # Coming soon!
```

## Load the Package

``` r
library(charisma)
```

## Basic Workflow

### Step 1: Load an Image

The package includes an example image of a colorful bird (*Tangara
fastuosa*):

``` r
img_path <- system.file(
  "extdata",
  "Tangara_fastuosa_LACM60421.png",
  package = "charisma"
)
```

### Step 2: Run charisma

The simplest analysis uses default parameters:

``` r
result <- charisma(
  img_path,
  threshold = 0.0,
  interactive = FALSE,
  plot = FALSE,
  pavo = FALSE
)
```

**Key parameters:**

- `threshold`: Minimum proportion of pixels for a color to be retained
  (0-1)
- `interactive`: Enable manual color merging/replacement
- `plot`: Show diagnostic plots during processing
- `pavo`: Compute color pattern geometry statistics

### Step 3: Visualize Results

``` r
plot(result)
```

This creates a multi-panel visualization showing:

- Original image
- Color-masked image
- Color proportions
- Color histogram

## Understanding the Pipeline

The `charisma` workflow consists of three main stages:

### 1. Image Preprocessing

Images are pre-processed using the `recolorize` package to:

- Perform spatial-color binning
- Remove noisy pixels
- Create a smoothed representation of dominant colors

``` r
# Control preprocessing with bins and cutoff parameters
result <- charisma(
  img_path,
  bins = 4,     # Bins per RGB channel (4^3 = 64 clusters)
  cutoff = 20   # Euclidean distance threshold
)
```

### 2. Color Classification

Each color cluster is converted from RGB to HSV and matched against the
CLUT:

``` r
# Example: Classify a single RGB color
color2label(c(255, 0, 0))    # Red
#> [1] "red"
color2label(c(0, 0, 255))    # Blue
#> [1] "blue"
color2label(c(255, 255, 0))  # Yellow
#> [1] "yellow"
```

### 3. Optional Manual Curation

In interactive mode, you can manually refine classifications:

``` r
result <- charisma(
  img_path,
  interactive = TRUE,
  threshold = 0.0
)
```

**Interactive operations:**

- **Merge**: Combine color clusters (e.g., `c(2,3)`)
- **Replace**: Reassign pixels from one cluster to another
- Complete operation history is saved for reproducibility

## Working with Thresholds

Thresholds automatically remove colors with low pixel proportions:

``` r
# No threshold - keep all colors
result_0 <- charisma(img_path, threshold = 0.0)

# 5% threshold - remove colors < 5% of image
result_5 <- charisma(img_path, threshold = 0.05)

# 10% threshold - remove colors < 10% of image
result_10 <- charisma(img_path, threshold = 0.10)
```

Higher thresholds are useful for:

- Removing image artifacts (shadows, feather overlap in bird specimens)
- Focusing on dominant colors
- Reducing noise in automated workflows

## Saving and Loading Results

Save results for reproducibility:

``` r
# Save with automatic timestamping
out_dir <- file.path("~", "Documents", "charisma_outputs")

result <- charisma(
  img_path,
  threshold = 0.05,
  logdir = out_dir
)
```

This creates:

- `charisma_objects/`: Timestamped .RDS files (full charisma object)
- `diagnostic_plots/`: Timestamped .PDF files (visualization)

Load and re-analyze saved objects:

``` r
# Load saved object
obj <- system.file("extdata", "Tangara_fastuosa.RDS", package = "charisma")
obj <- readRDS(obj)

# Re-analyze with different threshold
result2 <- charisma2(
  obj,
  new.threshold = 0.10
)

# Revert to specific state
result3 <- charisma2(
  obj,
  which.state = "merge",
  state.index = 2
)
```

## Extracting Color Data

The charisma object contains all classification data:

``` r
# Get unique colors present
unique_colors <- unique(result$classification)

# Get number of colors (k)
k <- length(unique_colors)

# Get color proportions
color_props <- result$color_mask_LUT_filtered

# Create presence/absence matrix
summary <- summarize(result)
```

## Custom Color Look-Up Tables

The default CLUT covers 10 human-visible colors, but you can create
custom CLUTs:

``` r
# View default CLUT
View(charisma::clut)

# Use custom CLUT
my_clut <- charisma::clut  # Start with default

# ... modify HSV ranges ...
result <- charisma(img_path, clut = my_clut)

# Validate custom CLUT (ensures complete HSV coverage)
validation <- validate(clut = my_clut)
```

**CLUT validation** tests every HSV coordinate to ensure:

1.  No gaps (every color maps to a category)
2.  No overlaps (each color maps to exactly one category)

## Integration with Evolutionary Analyses

`charisma` output integrates seamlessly with phylogenetic packages:

``` r
# Process multiple species
species_colors <- lapply(image_paths, function(img) {
  result <- charisma(img, threshold = 0.05)
  summarize(result)
})

# Combine into data frame
color_matrix <- do.call(rbind, species_colors)

# Use with geiger, phytools, pavo, etc.
library(geiger)
library(phytools)

# Fit evolutionary models
fit_er <- fitDiscrete(
  phylogeny,
  color_matrix[, "blue"],
  model = "ER"
)

fit_ard <- fitDiscrete(
  phylogeny,
  color_matrix[, "blue"],
  model = "ARD"
)

# Reconstruct ancestral states
ancestral <- ace(
  color_matrix[, "blue"],
  phylogeny,
  type = "discrete"
)
```

## Tips for Best Results

### For Bird Museum Specimens

- Use **manual mode** to remove feather artifact colors (brown/grey from
  feather bases)
- Set `threshold = 0.0` and manually curate
- Remove bill, leg, and tag pixels before analysis

### For Automated Workflows

- Test different `threshold` values on a subset
- Use `bins = 4` and `cutoff = 20` as starting points
- Save all intermediate results with `logdir`

### For Custom Image Sets

- Validate that the default CLUT works for your images
- Consider creating a custom CLUT for non-biological images
- Always validate custom CLUTs with
  [`validate()`](https://shawnschwartz.com/charisma/reference/validate.md)

## Citation

If you use `charisma` in your research, please cite:

> Schwartz, S.T., Tsai, W.L.E., Karan, E.A., Juhn, M.S., Shultz, A.J.,
> McCormack, J.E., Smith, T.B., and Alfaro, M.E. (2025). charisma: An R
> package to perform reproducible color characterization of digital
> images for biological studies. (In Review).

## Getting Help

- **Documentation**:
  [`?charisma`](https://shawnschwartz.com/charisma/reference/charisma.md),
  [`?charisma2`](https://shawnschwartz.com/charisma/reference/charisma2.md),
  [`?color2label`](https://shawnschwartz.com/charisma/reference/color2label.md)
- **Issues**: <https://github.com/shawntz/charisma/issues>
- **Email**: <shawn.t.schwartz@gmail.com>

## Acknowledgments

`charisma` builds upon and integrates with:

- [`recolorize`](https://cran.r-project.org/package=recolorize) (Weller
  et al. 2024) for image preprocessing
- [`pavo`](https://cran.r-project.org/package=pavo) (Maia et al. 2019)
  for color pattern geometry
- [`imager`](https://cran.r-project.org/package=imager)
  (Barthelme, 2025) for image processing operations

We thank the developers of these excellent packages for making this work
possible.
