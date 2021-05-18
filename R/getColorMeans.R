getColorMeans <- function(charisma_obj, mapping = charisma::color.map) {

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)
  num_colors <- length(color_names)

  # only get means for non-background color pixels
  img <- charisma_obj$filtered.2d
  img <- subset(img, is.bg == 0)

  return(apply(img[,13:(10 + num_colors)], 2, mean))

}
