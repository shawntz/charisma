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
load_image <- function(img_path, interactive = TRUE, bins = 4, cutoff = 20) {
  img <- recolorize::readImage(img_path, resize = NULL, rotate = NULL)

  recolorize_defaults <- suppressMessages(
    recolorize::recolorize2(img = img,
                            bins = bins,
                            cutoff = cutoff,
                            plotting = FALSE)
  )

  if (interactive) {
    out.list <- interactive_session(recolorize_defaults)
  } else {
    out.list <- list(
      final_img = recolorize_defaults,
      replacement_history = NULL,
      replacement_states = NULL,
      merge_history = NULL,
      merge_states = NULL
    )
  }

  return(out.list)
}
