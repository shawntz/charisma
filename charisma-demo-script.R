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
# (e.g, if background is solid green (i.e., R=0,G=1.0,B=0), then the defaults below 
# should be used to ignore only the solid green parts of the image 
# (i.e., the masked out background pixels))
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
