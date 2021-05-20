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
plot.charisma <- function(x, ...,
                          plot.original = TRUE,
                          plot.sprite = TRUE,
                          plot.spatial = TRUE,
                          freq.threshold = 0.5,
                          spatial.threshold = 0.5) {

  # for resetting
  user_par <- graphics::par(no.readonly = TRUE)

  # layout
  if(plot.original) {
    if(plot.sprite) {
      if(plot.spatial) {
        graphics::layout(matrix(c(1,2,3,4), 2, 2, byrow = TRUE))
      } else {
        graphics::layout(matrix(c(1,2,3,3), 2, 2, byrow = TRUE))
      }
    } else {
      if(plot.spatial) {
        graphics::layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
      } else {
        graphics::layout(matrix(c(1,2), 2, 2, byrow = TRUE))
      }
    }
  } else {
    if(plot.sprite) {
      if(plot.spatial) {
        graphics::layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
      } else {
        graphics::layout(matrix(c(1,2), 2, 2, byrow = TRUE))
      }
    } else {
      if(plot.spatial) {
        graphics::layout(matrix(c(1,2), 2, 2, byrow = TRUE))
      } else {
        graphics::layout(matrix(c(1,1), 2, 2, byrow = TRUE))
      }
    }
  }

  # plot original if specified
  if(plot.original)
    plotImage(x, multi.plot = TRUE)

  # plotting image
  if(plot.sprite)
    plotSprite(x, multi.plot = TRUE)

  # plotting frequency
  plotColors(x, type = "freq", threshold = freq.threshold, multi.plot = TRUE)

  # plotting spatial
  if(plot.spatial)
    plotColors(x, type = "spatial", threshold = spatial.threshold, multi.plot = TRUE)

  # reset parameters
  graphics::par(user_par)

}
