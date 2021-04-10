getColorMeans <- function(img, mapping) {
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  num_colors <- length(colors)
  
  ##only get means for non-background color pixels
  img <- subset(img, is.bg == 0)
  
  return(apply(img[,11:(10 + num_colors)], 2, mean))
  
}