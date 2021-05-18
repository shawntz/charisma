runPipeline <- function(images, mapping = charisma::color.map,
                        summary.method = c("both", "freq", "spatial"),
                        freq.threshold = .05, spatial.threshold = .05,
                        validate.color.map = FALSE, validation.simple = TRUE, lower = NULL, upper = NULL,
                        alpha.channel = TRUE, plot.diagnostic = FALSE, save.plots = FALSE, output.dir = getwd(),
                        save.plot.type = c("pdf", "png", "jpeg", "tiff", "bmp"), plot.width = 10, plot.height = 5) {

  # check if valid summary method
  summary.method <- tolower(summary.method)
  summary.method <- match.arg(summary.method)
  if(is.null(summary.method))
    stop("Invalid summary method specified.
         Please select from `both`, `freq`, or `spatial`.")

  # check if valid save.plot.type
  save.plot.type <- tolower(save.plot.type)
  save.plot.type <- match.arg(save.plot.type)
  if(is.null(save.plot.type))
    stop("Invalid save plot filetype specified.
         Please select from `pdf`, `png`, `jpeg`, `tiff`, or `bmp`.")

  # Get image paths ####
  # If argument isn't a string/vector of strings, throw an error
  # Copied from: R::colordistance
  if (!is.character(images)) {
    stop("'images' argument must be a string (folder containing the images),",
         " a vector of strings (paths to individual images),",
         " or a combination of both")
  }

  im.paths <- c()

  # Extract image paths from any folders
  # Copied from: R::colordistance
  if (length(which(dir.exists(images))) >= 1) {
    im.paths <- unlist(sapply(images[dir.exists(images)], getImagePaths),
                       use.names = FALSE)
  }

  # For any paths that aren't folders, append to im.paths if they are existing
  # image paths
  # ok this is confusing so to unpack: images[!dir.exists(images)] are all paths
  # that are not directories; then from there we take only ones for which
  # file.exists=TRUE, so we're taking any paths that are not folders but which
  # do exist
  # Copied from: R::colordistance
  im.paths <- c(im.paths,
                images[!dir.exists(images)][file.exists(images[!dir.exists(images)])])

  # Grab only valid image types (jpegs and pngs)
  # Copied from: R::colordistance
  im.paths <- im.paths[grep(x = im.paths,
                            pattern = "[.][jpg.|jpeg.|png.]",
                            ignore.case = TRUE)]

  message(paste(length(im.paths), "images"))

  # Validate color map if true
  if(validate.color.map)
    validation <- validateColorMap(mapping, validation.simple)

  # Create data frame to store call summaries
  call_summaries <- data.frame()

  # Run Per Image in Path
  for(i in 1:length(im.paths)) {
    # Read in Image
    img <- readImage(im.paths[i], lower = lower, upper = upper,
                     alpha.channel = alpha.channel, mapping = mapping)

    if(plot.diagnostic) {
      if(save.plots) {
        filename <- file.path(output.dir, paste0("diagnostic_", basename(img$path), ".", save.plot.type))
        if(save.plot.type == "pdf")
          pdf(file = filename, width = plot.width, height = plot.height)
        else if(save.plot.type == "png")
          png(filename = filename, width = plot.width, height = plot.height, units = "in", res = 300)
        else if(save.plot.type == "jpeg")
          jpeg(filename = filename, width = plot.width, height = plot.height, units = "in", res = 300)
        else if(save.plot.type == "tiff")
          tiff(filename = filename, width = plot.width, height = plot.height, units = "in", res = 300)
        else if(save.plot.type == "bmp")
          bmp(filename = filename, width = plot.width, height = plot.height, units = "in", res = 300)
      }

      plotDiagnostic(img, mapping = mapping, freq.threshold = freq.threshold, spatial.threshold = spatial.threshold)

      if(save.plots)
        dev.off()
    }

    # Get charisma color calls summary
    img_summary <- getSummary(img, mapping = mapping, method = summary.method,
                              freq.threshold = freq.threshold, spatial.threshold = spatial.threshold)

    # Bind summary to data frame
    call_summaries <- rbind(call_summaries, img_summary)
  }

  # Name data frame rows with paths of images
  rownames(call_summaries) <- im.paths

  return(call_summaries)

}
