# charisma: an R tool to automatically determine discrete color classes for high-throughput color pattern analysis (in preparation)

Shawn T. Schwartz <sup>1*</sup>, Whitney L.E. Tsai<sup>1</sup>, Elizabeth A. Karan<sup>1</sup>, & Michael E. Alfaro<sup>1</sup>

<sup>1</sup> Department of Ecology and Evolutionary Biology, Terasaki 2149, University of California, Los Angeles, Los Angeles, CA 90095, USA

<sup>*</sup>Corresponding author. Email: shawnschwartz@ucla.edu

---

We present a standalone `R` script to perform high-throughput color pattern analyses inspired by `colordistance` [(Weller and Westneat, 2018)](https://peerj.com/articles/6398/) and `pavo` [(Maia _et al._, 2013)](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12069).

To get started, clone the repository:
```shell
$ git clone https://github.com/ShawnTylerSchwartz/charisma.git
```

Our script can be run via `source` from within the `R` console or `RStudio` interface, as well as exclusively from the command line using the `Rscript` call.

## Command Line Demo
**charisma** includes a variety of command line argument options to streamline our high-throughput approach. For help, please run:
```shell
$ Rscript charisma.R --help
```

Though, here are all of the options and defaults:
```
Options:
	-m MASKEDPATH, --maskedPath=MASKEDPATH
		path/to/background_masked_images, no default

	-p UNMASKEDPATH, --unmaskedPath=UNMASKEDPATH
		path/to/transparent_bg_images, no default

	-s COLORSPACE, --colorspace=COLORSPACE
		set color space to either 'rgb' or 'hsv', default='rgb'

	-r LOWERRED, --lowerRed=LOWERRED
		Lower-bound Red value (0.0 to 1.0), default=0.0

	-g LOWERGREEN, --lowerGreen=LOWERGREEN
		Lower-bound Green value (0.0 to 1.0), default=0.55

	-b LOWERBLUE, --lowerBlue=LOWERBLUE
		Lower-bound Blue value (0.0 to 1.0), default=0.0

	-y UPPERRED, --upperRed=UPPERRED
		Upper-bound Red value (0.0 to 1.0), default=0.24

	-u UPPERGREEN, --upperGreen=UPPERGREEN
		Upper-bound Green value (0.0 to 1.0), default=1.0

	-n UPPERBLUE, --upperBlue=UPPERBLUE
		Upper-bound Blue value (0.0 to 1.0), default=0.24

	-a MODE, --mode=MODE
		Mode for thresholding. Type either 'lower' or 'upper': (lower: captures colors that exceeds (using --method) that threshold; upper: captures all colors necessary to explain some upper bound threshold), default=lower

	-t THRESHOLD, --threshold=THRESHOLD
		Minimum threshold of pixel percentage to count as a color, default=0.05

	-z METHOD, --method=METHOD
		Method for threshold cutoff. Type either 'GE' or 'G': (GE='>=' and G='>'), default=GE.

	-e, --colorDataOutput
		Enable saving of RDS file with R list data of RGB/HSV values for each k, for each image, default=FALSE

	-d, --diagnostic
		Enable diagnostic plotting mode, default=FALSE

	-w, --colorWheelPlot
		Plot color wheel plots when in diagnostic plotting mode, default=FALSE

	-v PLOTWIDTH, --plotWidth=PLOTWIDTH
		Pixel width of diagnostic plot, default=750

	-i PLOTHEIGHT, --plotHeight=PLOTHEIGHT
		Pixel height of diagnostic plot, default=500

	-q, --saveDiagnosticPlots
		Automatically save diagnostic plots to directory, default=FALSE

	-o SAVEDIAGNOSTICPLOTSPATH, --saveDiagnosticPlotsPath=SAVEDIAGNOSTICPLOTSPATH
		Location to automatically save diagnostic plots to directory (-q)

	-c, --colorPatternAnalysis
		Run color pattern analysis pipeline after automatic color classification, default=FALSE

	-h, --help
		Show this help message and exit

```

### Demo 1: Run only automatic color classification
Running the automatic color classification requires having a directory of images masked with a solid background color (that doesn't appear within the body of the organism of interest). For all of our examples, we use a solid green background, specifically: `(R=0.0, G=1.0, B=0.0)`. The defaults in **charisma** are already set to best accommodate a solid green background color; i.e., `-r 0.0 -g 0.55 -b 0.0 -y 0.24 -u 1.0 -n 0.24`. As such, if your images are already pre-processed with a solid green background, no additional command line arguments are required. However, if a unique solid background masking color is used, please use the `-r -g -b -y -u -n` flags to specific the lower-bounds (`-r -g -b`) and upper-bounds (`-y -u -n`) of the background color to ignore (ranging from 0 to 1 for each RGB value). **Note: you will have to play around with these parameters to best accommodate your background color (to ensure the backdrop isn't counted as a prominent color in the analysis).**
```shell
$ Rscript charisma.R -m demo/tanagers_masked
```

#### Color Spaces
**charisma** allows for the calculation of k color classes in either the **rgb** or **hsv** color space, using the `-s` flag to specify this setting. 
Example:
```shell
$ Rscript charisma.R -m demo/tanagers_masked -s hsv
```

_See **Diagnostic plots** below for an example of the difference between an **rgb** and **hsv** color space output._

#### Diagnostic Plots
To obtain diagnostic plots, such as these...
![Example Diagnostic Output](http://dev.shawntylerschwartz.com/charisma/rgb_vs_hsv_outputs_sample.png)

use the following options:
```shell
$ Rscript charisma.R -m demo/tanagers_masked -d -q # for RGB outputs
$ Rscript charisma.R -m demo/tanagers_masked -d -q -s hsv # for HSV outputs
```
_Note: `-d` enables diagnostic plotting and `-q` enables saving of these plots. The saving plot is defaulted to `diagnostic_outputs`, however, a custom path can be specified using the `-o` flag._

You can also plot HSV color wheels with points for each color detected by using the `-w` flag. _(Warning, this mode will take significantly more time/memory to generate these graphics.)_ For example:
```shell
$ Rscript charisma.R -m demo/tanagers_masked -d -q -w
```
![Example Color Wheel Output](http://dev.shawntylerschwartz.com/charisma/colorwheel_sample.png)

**To also save the RGB/HSV classifications used for the diagnostic plots as a `.RDS` data file, please use the `-e` flag. For example:**
```shell
$ Rscript charisma.R -m demo/tanagers_masked -d -q -e
```

#### Modes
There are currently two modes to select color classes (`lower` and `upper`, **default: lower**). The mode is set using the `-a` flag.
##### 'lower' mode
The `lower` mode will select color classes based on bins that are either at or above (`-z GE`) or just above (`-z G`) a specified lower-bound threshold (e.g., `-t .05`) with respect to their frequency across the image.
```shell
$ Rscript charisma.R -m demo/tanagers_masked -d -q -e -a lower -t .05
```

##### 'upper' mode
The `upper` mode will select color classes based on a cumulative summation of bin pixel frequencies that make up at least some specified upper-bound threshold (e.g., `-t .95`). The idea here is to select color classes until some specified percentage of the cumulative color diversity present in the image is explained by the minimum number of bins necessary to do so.
```shell
$ Rscript charisma.R -m demo/tanagers_masked -d -q -e -a upper -t .95
```

### Demo 2: Run automatic color classification & color pattern analysis using these automatically calculated k-values
The command line calls for running color pattern analysis utilize the same options from **Demo 1**, expect a corresponding directory of un-masked (i.e., not solid-background color masked images) must be supplied using the `-p` flag (with the same image names as the masked directory), along with the `-c` flag to enable the color pattern analysis functionality of **charisma**.
```shell
$ Rscript charisma.R -m demo/tanagers_masked -p demo/tanagers -d -q -e -c
```

## RStudio/R Console Demo
We also provide a demo R Script file (`charisma-demo-script.R`) if you would prefer to use **charisma** from within RStudio or the R console. 
```R
#################################################################
##               Demo Implementation of charisma               ##
##                  (charisma-demo-script.R)                   ##
#################################################################

#### Setup ####
rm(list = ls())

wd <- "C:/Users/shawn/charisma"
setwd(wd)

#### Load charisma Source ####
source("charisma.source.R")

#### Constants ####
#Must have two directories with equal number of images with the name filenames (except one set is 
# masked with an arbitrary solid background color and the other set is transparent)
images_masked_path <- file.path("demo", "tanagers_masked")
images_path <- file.path("demo", "tanagers")

#These values are the RGB bounds to ignore the masked arbitrary background color
# (e.g, if background is solid green (i.e., R=0,G=1.0,B=0), then lowerG and upperG should be set to 1.0
# to ignore only the solid green parts of the image (i.e., the masked out background pixels))
lowerR <- 0.0
lowerG <- 0.55
lowerB <- 0.0
upperR <- 0.24
upperG <- 1.0
upperB <- 0.24
thresh <- .05 # (5% minimum threshold)
method <- "GE" # greater than or equal to method (contrasted to 'G' ~> greater than only for threshold comparison)
mode <- "lower" # set to either 'lower' or 'upper'
colorspace <- "rgb" # set to either 'rgb' or 'hsv'
width <- 750 # pixel width of output diagnostic plots
height <- 500 # pixel height of output diagnostic plots
colorwheel <- TRUE

#### Run Pipeline ####
#This step uses the masked versions of the images
k_out <- autoComputeKPipeline(images_masked_path, diagnosticMode = TRUE,
                              lowerR = lowerR, lowerG = lowerG, lowerB = lowerB,
                              upperR = upperR, upperG = upperG, upperB = upperB, 
                              colOut = TRUE, mode = mode, thresh = thresh, method = method, saveDiagnosticPlots = TRUE,
                              width = width, height = height, colorspace = colorspace, colorwheel = colorwheel)

write.csv(k_out, "tanagers_k_values_output.csv", row.names = FALSE)

#### Run Color Pattern Analysis ####
#This step uses the unmasked versions of the images
color_classified <- classifyColorPipeline(images_path, k_out)
color_classified
write.csv(color_classified, "color_pattern_analysis_tanagers_demo.csv", row.names = FALSE)

pca_k <- runColorPCA(color_classified)
pca_k

pca_k_summary <- getColorPCASummary(pca_k)
pca_k_summary

```