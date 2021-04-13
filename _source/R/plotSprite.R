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
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  num_colors <- length(colors)
  
  ##extract color call columns
  calls <- img[,c(4,8:(10 + num_colors))]
  calls_cut <- calls[,c(1, 5:(4 + num_colors))]
  
  ##modify values for easy sorting of background vs. color called pixels
  calls_cut <- calls_cut * -1
  calls_cut$is.bg <- calls_cut$is.bg * -10
  color_pixels <- apply(calls_cut, 1, which.min)
  bg_pixels <- apply(calls_cut, 1, which.max)
  
  combos <- as.data.frame(cbind(is.bg = calls_cut[,1], color.loc = color_pixels))
  combos <- cbind(combos, color.name = colnames(calls_cut)[combos[,2]])
  
  ##get raw color names based on combos to then convert to hex values
  color_names <- ifelse(combos$is.bg == 10, "is.bg", combos$color.name)
  
  ##make hex vector
  hex_vector <- getHexVector(mapping)
  
  ##convert raw color name strings into corresponding hex values
  hex_values <- sapply(color_names, getMatchedHex, hex_vector, simplify = T)
  
  ##make plot
  asp <- img$nrows[1] / img$ncols[1]
  dim(hex_values) <- c(img$nrows[1], img$ncols[2])
  
  plot(0:1, 0:1, type = "n", axes = FALSE,
       asp = asp, main = "Sprite Plot", xlab = "", ylab = "")
  
  graphics::rasterImage(hex_values, 0, 0, 1, 1)
  
}