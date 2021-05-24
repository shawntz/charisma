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
plotSprite <- function(charisma_obj, multi.plot = FALSE, mapping = color.map) {

  # for resetting
  if(!multi.plot)
    user_par <- graphics::par(no.readonly = TRUE)

  img <- charisma_obj$filtered.2d

  hex_values <- charisma_obj$hex.matrix

  asp <- img$nrows[1] / img$ncols[1]

  plot(0:1, 0:1, type = "n", axes = TRUE,
       asp = asp, main = "Sprite Plot", xlab = "", ylab = "")

  graphics::rasterImage(hex_values, 0, 0, 1, 1)

  points(.168, .502, col = "black", pch = 8, cex = 3)
  points(.502, .502, col = "black", pch = 9, cex = 3)
  points(0.836, .502, col = "black", pch = 10, cex = 3)

  #points(0.48, 0.5009, col = "purple", pch = 8, cex = 3)
  #points(0.503, 0.500, col = "white", pch = 8, cex = 3)
  #points(0.4542, 0.5407, col = "red", pch = 8, cex = 3)
  #points(0.505, .5017, col = "orange", pch = 8, cex = 3)
  #points(0.36, 0.49, col = "yellow", pch = 8, cex = 3)
  #points(0.4023, 0.5057, col = "green", pch = 8, cex = 3)

  # reset parameters
  if(!multi.plot)
    graphics::par(user_par)

}
