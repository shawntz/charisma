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
load_image <- function(img_path = system.file("extdata/corbetti.png", package = "recolorize"),
                       verbose = TRUE) {
  img <- recolorize::readImage(img_path, resize = NULL, rotate = NULL)
  recolorize_defaults <- suppressMessages(recolorize::recolorize2(img = img,
                                                                 bins = 4,
                                                                 cutoff = 20,
                                                                 plotting = FALSE))
  if (verbose) {
    plot(recolorize_defaults)

    RESPONSE <- readline("Would you like to merge any colors? [Y/N] ")
    if (tolower(RESPONSE) == "y") {
      RESPONSE <- readline("Enter each color pair to merge as follows: [e.g., c(2,3), c(4,7), c(9,10)] ")
      recolorize_defaults <- merge_colors(recolorize_defaults, RESPONSE)
    }
  }

  return(recolorize_defaults)
}
