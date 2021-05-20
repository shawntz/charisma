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
plotImage <- function(charisma_obj, multi.plot = FALSE) {

  # for resetting
  if(!multi.plot)
    user_par <- graphics::par(no.readonly = TRUE)

  img <- charisma_obj$original.rgb

  # make plot
  asp <- nrow(img) / ncol(img)
  plot(0:1, 0:1, type = "n", axes = FALSE,
       asp = asp, main = basename(charisma_obj$path), xlab = "", ylab = "")

  graphics::rasterImage(img, 0, 0, 1, 1)

  # reset parameters
  if(!multi.plot)
    graphics::par(user_par)

}
