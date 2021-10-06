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
getColorMeans <- function(charisma_obj, mapping = color.map) {

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)
  num_colors <- length(color_names)

  # only get means for non-background color pixels
  img <- charisma_obj$filtered.2d
  img <- subset(img, is.bg == 0)

  return(apply(img[,13:(12 + num_colors)], 2, mean))

}
