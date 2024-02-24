# charisma: an R package to analyze color pattern diversity at massive scale

> [!WARNING]  
> This package is still under critical development and validation. Please use and interpret results with caution.

# Installing Package

``` r
# install devtools
install.packages("devtools")

# install charisma from GitHub
remotes::install_github("shawntschwartz/charisma")
``` 

# Help

> [!IMPORTANT]  
> Please use the issues tab (https://github.com/shawntylerschwartz/charisma/issues) to file any bugs or suggestions.

# Demo Usage

> [!NOTE]  
> Apologies in advance, I have yet to write documentation for the core functions.

Below are two example use cases of the primary `charisma()` pipeline wrapper function. I have added some extra support code to facilitate saving the `charisma` color classifications `R` objects, diagnostic plots for visual inspection, as well as summary `dataframes` / `csv` outputs of color pattern geometry statistics computed with [`pavo`](https://github.com/rmaia/pavo).

## Example Usage
``` r
# load charisma package
library(charisma)

# settings
COLOR_PROPORTION_INCLUSION_THRESHOLD <- 0.0 # 0.0 ~> allow any proportion of colors to be considered
USE_INTERACTIVE_MODE <- FALSE # TRUE ~> interrupt each loaded image with manual intervention interface

# define input and output dirs
in_dir <- file.path("~", "path", "to", "images")
out_dir <- "diagnostic_plots"

# create output dir to store diagnostic plots
if (!dir.exists(out_dir)) {
  dir.create(out_dir)
}

# create subdirs
if (!dir.exists(file.path(out_dir, "charisma_objects"))) {
  dir.create(file.path(out_dir, "charisma_objects"))
}

if (!dir.exists(file.path(out_dir, "color_geometry_stats"))) {
  dir.create(file.path(out_dir, "color_geometry_stats"))
}

if (!dir.exists(file.path(out_dir, "diagnostic_plots"))) {
  dir.create(file.path(out_dir, "diagnostic_plots"))
}

# make a pipeline wrapper function
run_charisma <- function(img, out_dir) {
  if (USE_INTERACTIVE_MODE) {
    # interactive mode
    img_c <- charisma(img, threshold = COLOR_PROPORTION_INCLUSION_THRESHOLD, verbose = TRUE, plot = TRUE)
  } else {
    # high-throughput / automation mode)
    img_c <- charisma(img, threshold = COLOR_PROPORTION_INCLUSION_THRESHOLD, verbose = FALSE, plot = FALSE)
  }
  
  # assuming appropriate output dirs
  saveRDS(img_c, file.path(out_dir, "charisma_objects", paste0("charisma_", basename(img), ".RDS")))

  # then, save out all the relevant data to csvs for analysis later
  write.csv(img_c$pavo_adj_stats, file.path(out_dir, "color_geometry_stats", paste0("charisma_", basename(img), "_pavo.csv")), row.names = FALSE)
  
  # and save out the diagnostic plots to the specified directory
  fname <- paste0(tools::file_path_sans_ext(basename(img)), ".jpeg")
  jpeg(file.path(out_dir, "diagnostic_plots", fname), width = 1920, height = 300, units = "px")
  plot_diagnostics(img_c)
  dev.off()
}

# run the pipeline!
my_image_files <- list.files(in_dir, pattern = "*.png", all.files = TRUE, full.names = TRUE)

for (my_image in my_image_files) {
  run_charisma(img = my_image, out_dir = out_dir)
}

```
