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
getSpatialDensityScores <- function(charisma_obj, mapping = color.map) {

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)
  num_colors <- length(color_names)

  # get spatial density score for each color
  scores <- rep(NA, num_colors)
  for(i in 1:num_colors) {
    scores[i] <- getSpatialDensity(charisma_obj, color_names[i])
  }
  names(scores) <- color_names

  return(scores)

}
