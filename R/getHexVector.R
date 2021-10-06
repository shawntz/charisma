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
getHexVector <- function(mapping = color.map) {

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)

  # get default hex values from color mapping
  hex <- getMappedHex(mapping)

  # append default background color for sprite plot (white)
  hex <- c(hex, "#FFFFFF")
  names(hex) <- c(color_names, "is.bg")

  return(hex)

}
