## Adapted and Modified from R::colordistance function `plotImage`
plotImage <- function(img) {
  
  # If a filepath is passed, load the image from that filepath
  if (is.character(img)) {
    if (file.exists(img)) {
      # Read in the file as either JPG or PNG (or, if neither, stop execution
      # and return error message)
      img <- loadImage(img)
    } else {
      stop("File does not exist")
    }
  }
  
  ##subset relevant data for plotting
  img <- as.data.frame(cbind(r = img$r, g = img$g, b = img$b, is.bg = img$is.bg, nrows = img$nrows, ncols = img$ncols))
  
  ##make plot
  asp <- img$nrows[1] / img$ncols[1]
  rasterized <- rgb2hex(img[,1:3])
  dim(rasterized) <- c(img$nrows[1], img$ncols[1])
  plot(0:1, 0:1, type = "n", axes = FALSE,
       asp = asp, main = "Source Image", xlab = "", ylab = "")
  
  graphics::rasterImage(rasterized, 0, 0, 1, 1)
  
}