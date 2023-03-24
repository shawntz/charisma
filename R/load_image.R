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

    SWAP_RESPONSE <- readline("Would you like to SWAP any colors? [Y/N] ")
    CONTINUE_SWAPPING <-TRUE
    UNDO <- FALSE

    if (tolower(SWAP_RESPONSE) == "y") {
      while (CONTINUE_SWAPPING) {
        SWAP_RESPONSE_FROM <- readline(" > Enter the number of the color you'd like to swap: ")
        SWAP_RESPONSE_TO <- readline(paste(" > Which color (number) would you like to replace", SWAP_RESPONSE_FROM, "with: "))
        swapped_img <- swap_color(recolorize_defaults, SWAP_RESPONSE_FROM, SWAP_RESPONSE_TO)
        CONTINUE_SWAPPING_RESP <- readline("Would you like to SWAP any other colors? [Y/N/Undo] ")
        if (tolower(CONTINUE_SWAPPING_RESP) == "y") {
          recolorize_defaults <- swapped_img$img
          CONTINUE_SWAPPING = TRUE
        } else if (tolower(CONTINUE_SWAPPING_RESP) == "u" || tolower(CONTINUE_SWAPPING_RESP) == "undo") {
          recolorize_defaults <- swapped_img$undo_state
          plot(recolorize_defaults)
          CONTINUE_SWAPPING = TRUE
        } else {
          recolorize_defaults <- swapped_img$img
          CONTINUE_SWAPPING = FALSE
        }
      }
    }

    MERGE_RESPONSE <- readline("Would you like to MERGE any colors? [Y/N] ")
    if (tolower(MERGE_RESPONSE) == "y") {
      MERGE_RESPONSE <- readline("Enter each color pair to merge as follows: [e.g., c(2,3), c(4,7), c(9,10)] ")
      recolorize_defaults <- merge_colors(recolorize_defaults, MERGE_RESPONSE)
    }
  }

  # TODO: Ask Whitney.. so swapping the colors out in the
  # recolorize_defaults_rerun <- suppressMessages(recolorize::recolorize2(img = recolorize::recoloredImage(recolorize_defaults),
  #                                                                       bins = 4,
  #                                                                       cutoff = 20,
  #                                                                       plotting = FALSE))
  #
  # plot(recolorize_defaults_rerun)

  # return(recolorize_defaults_rerun)

  plot_recolored(recolorize_defaults)

  return(recolorize_defaults)
}
