plotSprite <- function(img, mapping) {
  
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
  
  hex_values <- getHexValuesMatrix(img, mapping)
  
  asp <- img$nrows[1] / img$ncols[1]
  
  plot(0:1, 0:1, type = "n", axes = FALSE,
       asp = asp, main = "Sprite Plot", xlab = "", ylab = "")
  
  graphics::rasterImage(hex_values, 0, 0, 1, 1)
  
}