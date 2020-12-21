#### Command Line Parameters ----
option_list <- list(
  make_option(c("-m", "--maskedPath"), default="NULL", help="path/to/background_masked_images, no default"),
  make_option(c("-p", "--unmaskedPath"), default="NULL", help="path/to/transparent_bg_images, no default"),
  make_option(c("-s", "--colorspace"), default="rgb", help="set color space to either 'rgb' or 'hsv', default='rgb'"),
  make_option(c("-r", "--lowerRed"), type="double", default=0.0, help="Lower-bound Red value (0.0 to 1.0), default=0.0"),
  make_option(c("-g", "--lowerGreen"), type="double", default=0.55, help="Lower-bound Green value (0.0 to 1.0), default=0.55"),
  make_option(c("-b", "--lowerBlue"), type="double", default=0.0, help="Lower-bound Blue value (0.0 to 1.0), default=0.0"),
  make_option(c("-y", "--upperRed"), type="double", default=0.24, help="Upper-bound Red value (0.0 to 1.0), default=0.24"),
  make_option(c("-u", "--upperGreen"), type="double", default=1.0, help="Upper-bound Green value (0.0 to 1.0), default=1.0"),
  make_option(c("-n", "--upperBlue"), type="double", default=0.24, help="Upper-bound Blue value (0.0 to 1.0), default=0.24"),
  make_option(c("-a", "--mode"), default="lower", help="Mode for thresholding. Type either 'lower' or 'upper': (lower: captures colors that exceeds (using --method) that threshold; upper: captures all colors necessary to explain some upper bound threshold), default=lower"),
  make_option(c("-t", "--threshold"), type="double", default=0.05, help="Minimum threshold of pixel percentage to count as a color, default=0.05"),
  make_option(c("-z", "--method"), default="GE", help="Method for threshold cutoff. Type either 'GE' or 'G': (GE='>=' and G='>'), default=GE."),
  make_option(c("-e", "--colorDataOutput"), action="store_true", default=FALSE, help="Enable saving of RDS file with R list data of RGB/HSV values for each k, for each image, default=FALSE"),
  make_option(c("-d", "--diagnostic"), action="store_true", default=FALSE, help="Enable diagnostic plotting mode, default=FALSE"),
  make_option(c("-w", "--colorWheelPlot"), action="store_true", default=FALSE, help="Plot color wheel plots when in diagnostic plotting mode, default=FALSE"),
  make_option(c("-v", "--plotWidth"), type="double", default=11, help="Inch width of diagnostic plot, default=11"),
  make_option(c("-i", "--plotHeight"), type="double", default=8.5, help="Inch height of diagnostic plot, default=8.5"),
  make_option(c("-q", "--saveDiagnosticPlots"), action="store_true", default=FALSE, help="Automatically save diagnostic plots to directory, default=FALSE"),
  make_option(c("-o", "--saveDiagnosticPlotsPath"), default="diagnostic_outputs", help="Location to automatically save diagnostic plots to directory (-q)"),
  make_option(c("-c", "--colorPatternAnalysis"), action="store_true", default=FALSE, help="Run color pattern analysis pipeline after automatic color classification, default=FALSE"),
  make_option("--colorRefTable", default=file.path("_source", "color_reference_master.csv"), help="CSV file containing reference colors for discrete color classification."),
  make_option("--maskR", default=0.0),
  make_option("--maskG", default=255.0),
  make_option("--maskB", default=0.0),
  make_option("--resize", action="store_true", default=FALSE),
  make_option("--scale", type="double", default=25),
  make_option("--transparency", action="store_true", default=FALSE)
)

#### Parse Command Line Parameters ----
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
colorWheelPlot <- opt$colorWheelPlot
plotWidth <- opt$plotWidth
plotHeight <- opt$plotHeight
colOut <- opt$colorDataOutput
saveDiagnosticPlots <- opt$saveDiagnosticPlots
plotOutputDirInput <- opt$saveDiagnosticPlotsPath
colorPatternAnalysis <- opt$colorPatternAnalysis
colorRefTable <- opt$colorRefTable
maskR <- opt$maskR
maskG <- opt$maskG
maskB <- opt$maskB
resize <- opt$resize
scale_value <- opt$scale
transparency <- opt$transparency

#### charisma checks ---- 
## check if both masked/unmasked img dirs are provided if color pattern analysis option is selected
if((colorPatternAnalysis == TRUE) & (images_notmasked == "NULL" | images_masked == "NULL"))
{
  stop("\n\n\n***charisma warning: Corresponding masked/unmasked directories must be provided to run color pattern analysis!***\n\n\n")
}

#### Setup output dir for data ----
output_dir <- file.path(wd, format(Sys.time(), "charisma_%F_%H.%M.%S"))
dir.create(output_dir)
cat(paste("    Created directory for charisma run output files at:"), output_dir, "\n")
output_dir_root <- paste0(output_dir, "/")
plot_output_dir <- paste0(output_dir, "/", plotOutputDirInput)
images_masked_path <- paste0(wd, "/", images_masked)
images_path <- paste0(wd, "/", images_notmasked)

if(resize == TRUE)
{
  cat("\n")
  resize_dir <- file.path(wd, paste0(images_masked, "_", "resized"))
  ifelse(!dir.exists(resize_dir), dir.create(resize_dir), FALSE)
  cat(paste("    Created directory for resized image files:"), resize_dir, "\n\n")
}

#### Save session parameters ----
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
  cat(paste0("--colorWheelPlot=", opt$colorWheelPlot, "\n"))
  cat(paste0("--plotWidth=", opt$plotWidth, "\n"))
  cat(paste0("--plotHeight=", opt$plotHeight, "\n"))
  cat(paste0("--saveDiagnosticPlots=", opt$saveDiagnosticPlots, "\n"))
  cat(paste0("--saveDiagnosticPlotsPath=", opt$saveDiagnosticPlotsPath, "\n"))
  cat(paste0("--colorPatternAnalysis=", opt$colorPatternAnalysis, "\n"))
  cat(paste0("--colorRefTable=",opt$colorRefTable, "\n"))
  cat(paste0("--maskR=",opt$maskR, "\n"))
  cat(paste0("--maskG=",opt$maskG, "\n"))
  cat(paste0("--maskB=",opt$maskB, "\n"))
  cat(paste0("--resize=",opt$resize, "\n"))
  cat(paste0("--scale=",opt$scale, "\n"))
  cat(paste0("--transparency=",opt$transparency, "\n"))
sink()

#### Load In Color Reference Table ----
color_table <- read.csv(opt$colorRefTable, header = T, sep = ",")