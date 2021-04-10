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
input_path <- "demo/"
img_dir <- "chaets"
imgs <- getImgPaths(paste0(input_path, img_dir))

## Create Another Output Directory for img_dir path
ifelse(!dir.exists(file.path(output, img_dir)), dir.create(file.path(output, img_dir)), FALSE)

## Call Colors
calls <- callColorsPipeline(imgs, mapping)

## Save Classifications
saveRDS(calls, paste0(output, "/", img_dir, "/", img_dir, ".RDS"))

## Summarize Calls and Save
calls_summary <- summarizeCalledColorsPipeline(calls, mapping, threshold)
write.csv(calls_summary, paste0(output, "/", img_dir, "/", img_dir, "_summary.csv"))

## Build and Save Diagnostic Plots for Each Call
##PDF Version
for(ii in 1:length(imgs)) {
  pdf(paste0(output, "/", img_dir, "/", "Charisma_Diagnostic_Output_", basename(imgs[ii]), ".pdf"), width = 10, height = 5)
    buildPlots(calls[[ii]], mapping, threshold)
  dev.off()
}

##JPEG Version
for(ii in 1:length(imgs)) {
  jpeg(paste0(output, "/", img_dir, "/", "Charisma_Diagnostic_Output_", basename(imgs[ii]), ".jpeg"), width = 1000, height = 500, res = 150)
    buildPlots(calls[[ii]], mapping, threshold)
  dev.off()
}
