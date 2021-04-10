#######################################################################
##                              Charisma                             ##
##  Automatic Detection of Color Classes for Color Pattern Analysis  ##
##                      <shawnschwartz@ucla.edu>                     ##
#######################################################################

## Initialize Main
validate <- FALSE
source("compile.R")

## Create Output Directory If It Doesn't Exist
ifelse(!dir.exists(file.path(getwd(), output)), dir.create(file.path(getwd(), output)), FALSE)

## Get Images
input_path <- "demo/birds"
imgs <- getImgPaths(input_path)

## Call Colors
calls <- callColorsPipeline(imgs, mapping)

## Build and Save Diagnostic Plots for Each Call
##PDF Version
for(ii in 1:length(imgs)) {
  pdf(paste0(output, "/", "Charisma_Diagnostic_Output_", basename(imgs[ii]), ".pdf"), width = 10, height = 5)
    buildPlots(calls[[ii]], mapping, threshold)
  dev.off()
}

##JPEG Version
for(ii in 1:length(imgs)) {
  jpeg(paste0(output, "/", "Charisma_Diagnostic_Output_", basename(imgs[ii]), ".jpeg"), width = 1000, height = 500, res = 150)
  buildPlots(calls[[ii]], mapping, threshold)
  dev.off()
}
