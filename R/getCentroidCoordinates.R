#' Add together two numbers
#'
#' @param x A number
#' @param y A number
#' @return The sum of \code{x} and \code{y}
#' @examples
#' add(1, 1)
#' add(10, 1)
#'
#' @export
getCentroidCoordinates <- function(charisma_obj, dimension = c("x", "y"), scale = FALSE, mapping = color.map) {

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)
  num_colors <- length(color_names)

  # get centroid distances for each color
  coordinates <- rep(NA, num_colors)
  for(i in 1:num_colors) {
    coordinates[i] <- getCentroidCoordinate(charisma_obj, color_names[i], dimension, scale)
  }
  names(coordinates) <- color_names

  return(coordinates)

}
