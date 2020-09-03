#!/usr/bin/Rscript

cat("\n\n#######################################################################
##                              charisma                             ##
##  Automatic Detection of Color Classes for Color Pattern Analysis  ##
##                  Written by Shawn Schwartz, 2020                  ##
##                      <shawnschwartz@ucla.edu>                     ##
#######################################################################\n\n\n")

## init
ptm <- proc.time() #begin run timer
wd <- getwd()
source("charisma.source.R")

## parameters
option_list <- list(
  make_option(c("-m", "--maskedPath"), default="NULL", help="path/to/background_masked_images, no default"),
  make_option(c("-p", "--unmaskedPath"), default="NULL", help="path/to/transparent_bg_images, no default"),
  make_option(c("-s", "--colorspace"), default="rgb", help="set color space to either 'rgb' or 'hsv', default='rgb'"),
  make_option(c("-r", "--lowerRed"), type="double", default=0.0, help="Lower-bound Red value (0.0 to 1.0), default=0.0"),
  make_option(c("-g", "--lowerGreen"), type="double", default=1.0, help="Lower-bound Green value (0.0 to 1.0), default=1.0"),
  make_option(c("-b", "--lowerBlue"), type="double", default=0.0, help="Lower-bound Blue value (0.0 to 1.0), default=0.0"),
  make_option(c("-y", "--upperRed"), type="double", default=0.0, help="Upper-bound Red value (0.0 to 1.0), default=0.0"),
  make_option(c("-u", "--upperGreen"), type="double", default=1.0, help="Upper-bound Green value (0.0 to 1.0), default=1.0"),
  make_option(c("-n", "--upperBlue"), type="double", default=0.0, help="Upper-bound Blue value (0.0 to 1.0), default=0.0"),
  make_option(c("-b", "--mode"), default="lower", help="Mode for thresholding. Type either 'lower' or 'upper': (lower: captures colors that exceeds (using --method) that threshold; upper: captures all colors necessary to explain some upper bound threshold), default=lower"),
  make_option(c("-t", "--threshold"), type="double", default=0.05, help="Minimum threshold of pixel percentage to count as a color, default=0.05"),
  make_option(c("-z", "--method"), default="GE", help="Method for threshold cutoff. Type either 'GE' or 'G': (GE='>=' and G='>'), default=GE."),
  make_option(c("-e", "--colorDataOutput"), action="store_true", default=FALSE, help="Enable saving of RDS file with R list data of RGB/HSV values for each k, for each image, default=FALSE"),
  make_option(c("-d", "--diagnostic"), action="store_true", default=FALSE, help="Enable diagnostic plotting mode, default=FALSE"),
  make_option(c("-q", "--saveDiagnosticPlots"), action="store_true", default=FALSE, help="Automatically save diagnostic plots to directory, default=FALSE"),
  make_option(c("-o", "--saveDiagnosticPlotsPath"), default="diagnostic_outputs", help="Location to automatically save diagnostic plots to directory (-q)"),
  make_option(c("-c", "--colorPatternAnalysis"), action="store_true", default=FALSE, help="Run color pattern analysis pipeline after automatic color classification, default=FALSE")
)

## parse command line args
opt <- parse_args(OptionParser(option_list = option_list))

images_masked <- opt$maskedPath
images_notmasked <- opt$unmaskedPath
colorspace <- opt$colorspace
lowerR <- opt$lowerRed
lowerG <- opt$lowerGreen
lowerB <- opt$lowerBlue
upperR <- opt$upperRed
upperG <- opt$upperGreen
upperB <- opt$upperBlue
mode <- opt$mode
thresh <- opt$threshold
method <- opt$method
diagnosticMode <- opt$diagnostic
colOut <- opt$colorDataOutput
saveDiagnosticPlots <- opt$saveDiagnosticPlots
plotOutputDirInput <- opt$saveDiagnosticPlotsPath
colorPatternAnalysis <- opt$colorPatternAnalysis

## check if both masked/unmasked img dirs are provided if color pattern analysis option is selected
if((colorPatternAnalysis == TRUE) & (images_notmasked == "NULL" | images_masked == "NULL"))
{
  stop("\n\n\n***charisma warning: Corresponding masked/unmasked directories must be provided to run color pattern analysis!***\n\n\n")
}

## setup output dir for data
output_dir <- file.path(wd, format(Sys.time(), "charisma_%F_%H.%M.%S"))
dir.create(output_dir)
cat(paste("\nCreated directory for charisma run output files at:"), output_dir, "\n")
output_dir_root <- paste0(output_dir, "/")
plot_output_dir <- paste0(output_dir, "/", plotOutputDirInput)
images_masked_path <- paste0(wd, "/", images_masked)
images_path <- paste0(wd, "/", images_notmasked)

## save session parameters
sink(paste0(output_dir_root, "charisma_session_parameters_log.txt"))
  cat(paste0("--maskedPath=", opt$maskedPath, "\n"))
  cat(paste0("--unmaskedPath=", opt$unmaskedPath, "\n"))
  cat(paste0("--colorspace=", opt$colorspace, "\n"))
  cat(paste0("--lowerRed=", opt$lowerRed, "\n"))
  cat(paste0("--lowerGreen=", opt$lowerGreen, "\n"))
  cat(paste0("--lowerBlue=", opt$lowerBlue, "\n"))
  cat(paste0("--upperRed=", opt$upperRed, "\n"))
  cat(paste0("--upperGreen=", opt$upperGreen, "\n"))
  cat(paste0("--upperBlue=", opt$upperBlue, "\n"))
  cat(paste0("--mode=", opt$mode, "\n"))
  cat(paste0("--threshold=", opt$threshold, "\n"))
  cat(paste0("--method=", opt$method, "\n"))
  cat(paste0("--colorDataOutput=", opt$colorDataOutput, "\n"))
  cat(paste0("--diagnostic=", opt$diagnostic, "\n"))
  cat(paste0("--saveDiagnosticPlots=", opt$saveDiagnosticPlots, "\n"))
  cat(paste0("--saveDiagnosticPlotsPath=", opt$saveDiagnosticPlotsPath, "\n"))
  cat(paste0("--colorPatternAnalysis=", opt$colorPatternAnalysis, "\n"))
sink()

## begin automatic color class determination pipeline
cat("\nRunning automatic color class determination now...\n")
k_out <- autoComputeKPipeline(images_masked_path, diagnosticMode = diagnosticMode,
                              lowerR = lowerR, lowerG = lowerG, lowerB = lowerB,
                              upperR = upperR, upperG = upperG, upperB = upperB,
                              mode = mode, thresh = thresh, method = method, colOut = colOut, colOutPath = output_dir_root,
                              saveDiagnosticPlots = saveDiagnosticPlots, diagnosticPlotsOutputDir = plot_output_dir, colorspace = colorspace)
cat("\nSaving automatic color class determination results...\n")
saveRDS(k_out, file.path(output_dir, "k-values.RDS"))
write.csv(k_out, file.path(output_dir, "k-values.csv"))
cat("\nFinished saving automatic color class determination results successfully!\n")

## run pavo color pattern analysis pipeline
if(colorPatternAnalysis == TRUE)
{
  cat("\nRunning color pattern analysis classification pipeline...\n\n")
  color_classified <- classifyColorPipeline(images_path, k_out)
  cat("\nSaving color pattern analysis classification results...")
  saveRDS(color_classified, file.path(output_dir, "color-pattern-analysis.RDS"))
  write.csv(color_classified, file.path(output_dir, "color-pattern-analysis.csv"))
  cat("Finished saving color pattern analysis classification results successfully!\n\n")
  
  cat("\nRunning color pattern analysis classification PCA...\n")
  pca_k <- runColorPCA(color_classified)
  pca_k_summary <- getColorPCASummary(pca_k)
  cat("\nSaving color pattern analysis classification PCA results... (2 files)")
  saveRDS(pca_k, file.path(output_dir, "color-pattern-analysis-PCA.RDS"))
  saveRDS(pca_k_summary, file.path(output_dir, "color-pattern-analysis-PCA_summary.RDS"))
  cat("\nFinished saving color pattern analysis classification PCA results successfully! (2 files)\n\n")  
}

## clean up charisma's main path
if(file.exists("Rplots.pdf"))
{
  cat("\nCleaning up directory...")
  unlink("Rplots.pdf")
  cat("Done!\n")
}

## sink final run time
final_run_time <- proc.time() - ptm #end run timer

if(colorPatternAnalysis == TRUE)
{
  sink(paste0(output_dir_root, "total_run_time_log.txt"))
    cat(paste(final_run_time[[3]], "seconds to automatically classify k and run color pattern analysis on", nrow(k_out), "images."))
  sink()
} else if(colorPatternAnalysis == FALSE)
{
  sink(paste0(output_dir_root, "total_run_time_log.txt"))
  cat(paste(final_run_time[[3]], "seconds to automatically classify k for", nrow(k_out), "images."))
  sink()
}

## finishing message
cat(paste("\ncharisma pipeline successfully completed in", final_run_time[[3]], "seconds.\n\n"))
