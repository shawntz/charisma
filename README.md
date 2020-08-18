# charisma: script to automatically determine the number of color classes within an image for high-throughput color pattern analyses

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
```shell
Options:
	-m MASKEDPATH, --maskedPath=MASKEDPATH
		path/to/background_masked_images, no default

	-p UNMASKEDPATH, --unmaskedPath=UNMASKEDPATH
		path/to/transparent_bg_images, no default

	-r LOWERRED, --lowerRed=LOWERRED
		Lower-bound Red value (0.0 to 1.0), default=0.0

	-g LOWERGREEN, --lowerGreen=LOWERGREEN
		Lower-bound Green value (0.0 to 1.0), default=1.0

	-b LOWERBLUE, --lowerBlue=LOWERBLUE
		Lower-bound Blue value (0.0 to 1.0), default=0.0

	-y UPPERRED, --upperRed=UPPERRED
		Upper-bound Red value (0.0 to 1.0), default=0.0

	-u UPPERGREEN, --upperGreen=UPPERGREEN
		Upper-bound Green value (0.0 to 1.0), default=1.0

	-n UPPERBLUE, --upperBlue=UPPERBLUE
		Upper-bound Blue value (0.0 to 1.0), default=0.0

	-t THRESHOLD, --threshold=THRESHOLD
		Minimum threshold of pixel percentage to count as a color, default=0.05

	-z METHOD, --method=METHOD
		Method for threshold cutoff. Type either 'GE' or 'G': (GE='>=' and G='>'), default=GE.

	-d, --debug
		Enable debug plotting mode, default=FALSE

	-e, --rgbDataOutput
		Enable saving of RDS file with R list data of RGB values for each k, for each image, default=FALSE

	-q, --saveDebugPlots
		Automatically save debug plots to directory, default=FALSE

	-o SAVEDEBUGPLOTSPATH, --saveDebugPlotsPath=SAVEDEBUGPLOTSPATH
		Location to automatically save debug plots to directory (-q)

	-c, --colorPatternAnalysis
		Run color pattern analysis pipeline after automatic color classification, default=FALSE

	-h, --help
		Show this help message and exit

```

### Demo 1: Run only automatic color classification
Running the automatic color classification requires having a directory of images masked with a solid background color (that doesn't appear within the body of the organism of interest). For all of our examples, we use a solid green background, specifically: `(R=0.0, G=1.0, B=0.0)`. These are also the defaults used by **charisma**. As such, if your images are already pre-processed with a solid green background, no additional command line arguments are required. However, if a unique solid background masking color is used, please use the `-r -g -b -y -u -n` flags to specific the lower-bounds (`-r -g -b`) and upper-bounds (`-y -u -n`) of the background color to ignore (ranging from 0 to 1 for each RGB value). **Note: the lower- and upper-bound RGB values should usually be the exact same for solid background colors. For example, if the background color was solid red, the options would look something like this: `-r 1.0 -g 0.0 -b 0.0 -y 1.0 -u 0.0 -n 0.0`.**
```shell
$ Rscript charisma.R -m tanagers_masked
```

To obtain debug plots, such as this...
![Example Debug Output](http://dev.shawntylerschwartz.com/charisma/debug_demo.png)
use the following options:
```shell
$ Rscript charisma.R -m tanagers_masked -d -q
```
_Note: `-d` enables debug plotting and `-q` enables saving of these plots. The saving plot is defaulted to `debug_outputs`, however, a custom path can be specified using the `-o` flag._

**To also save the RGB classifications used for the debug plots as a `.RDS` data file, please use the `-e` flag. For example:**
```shell
$ Rscript charisma.R -m tanagers_masked -d -q -e
```

### Demo 2: Run automatic color classification & color pattern analysis using these automatically calculated k-values
The command line calls for running color pattern analysis utilize the same options from **Demo 1**, expect a corresponding directory of un-masked (i.e., not solid-background color masked images) must be supplied using the `-p` flag (with the same image names as the masked directory), along with the `-c` flag to enable the color pattern analysis functionality of **charisma**.
```shell
$ Rscript charisma.R -m tanagers_masked -p tanagers -d -q -e -c
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

wd <- "~/your/dir/here/charisma"
setwd(wd)

#### Load charisma Source ####
source("charisma.source.R")

#### Constants ####
#Must have two directories with equal number of images with the name filenames (except one set is 
# masked with an arbitrary solid background color and the other set is transparent)
images_masked_path <- "tanagers_masked"
images_path <- "tanagers"

#These values are the RGB bounds to ignore the masked arbitrary background color
# (e.g, if background is solid green (i.e., R=0,G=1.0,B=0), then lowerG and upperG should be set to 1.0
# to ignore only the solid green parts of the image (i.e., the masked out background pixels))
lowerR <- 0.0
lowerG <- 1.0
lowerB <- 0.0
upperR <- 0.0
upperG <- 1.0
upperB <- 0.0
thresh <- .05 # (5% minimum threshold)
method <- "GE" # greater than or equal to method (contrasted to "G" ~> greater than only for threshold comparison)

#### Run Pipeline ####
#This step uses the masked versions of the images
k_out <- autoComputeKPipeline(images_masked_path, debugMode = TRUE,
                              lowerR = lowerR, lowerG = lowerG, lowerB = lowerB,
                              upperR = upperR, upperG = upperG, upperB = upperB, 
                              rgbOut = TRUE, rgbOutPath = wd,
                              thresh = thresh, method = method, saveDebugPlots = TRUE)

write.csv(k_out, "tanagers_k_values_output.csv")

#### Run Color Pattern Analysis ####
#This step uses the unmasked versions of the images
color_classified <- classifyColorPipeline(images_path, k_out)
color_classified
write.csv(color_classified, "color_pattern_analysis_tanagers_demo.csv")

pca_k <- runColorPCA(color_classified)
pca_k

pca_k_summary <- getColorPCASummary(pca_k)
pca_k_summary
```