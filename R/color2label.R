#' Convert RGB color triplets to discrete color labels
#'
#' This function classifies an RGB color triplet into one of the discrete
#' color categories defined in the Color Look-Up Table (CLUT) by testing for
#' membership within non-overlapping HSV ranges.
#'
#' @param color_triplet Numeric vector of length 3 containing RGB values
#'   (0-255 scale). The vector should be c(red, green, blue).
#' @param verbose Logical. If \code{TRUE}, prints the color triplet and
#'   classification results for debugging. Default is \code{FALSE}.
#' @param clut Data frame containing the Color Look-Up Table with HSV boundaries
#'   for each color class. Default is \code{charisma::clut}.
#'
#' @return Character string indicating the matched color label from the CLUT.
#'   Returns \code{"NA"} if the input contains NA values.
#'
#' @details
#' The classification process involves:
#' \enumerate{
#'   \item Converting RGB to HSV (using \code{rgb2hsv})
#'   \item Scaling HSV to match CLUT ranges (H: 0-360, S: 0-100, V: 0-100)
#'   \item Testing the HSV coordinate against all color definitions in the CLUT
#'   \item Returning the single matching color label
#' }
#'
#' Each color in the CLUT has non-overlapping HSV ranges that partition the
#' entire HSV color space. If multiple matches occur, a warning is issued as
#' this indicates overlapping color boundaries in the CLUT.
#'
#' @references
#' Schwartz, S.T., Tsai, W.L.E., Karan, E.A., Juhn, M.S., Shultz, A.J.,
#' McCormack, J.E., Smith, T.B., and Alfaro, M.E. (2025). charisma: An R package
#' to perform reproducible color characterization of digital images for
#' biological studies. (In Review).
#'
#' @seealso
#' \code{\link{charisma}} for the main classification pipeline,
#' \code{\link{validate}} for CLUT validation
#'
#' @examples
#' # Classify a blue RGB color
#' color2label(c(0, 0, 255))
#'
#' # Classify a red RGB color
#' color2label(c(255, 0, 0))
#'
#' # Verbose output for debugging
#' color2label(c(128, 128, 128), verbose = TRUE)
#'
#' @export
color2label <- function(
  color_triplet,
  verbose = FALSE,
  clut = charisma::clut
) {
  # check if any NAs in color triplet and return NA if true
  if (any(is.na(color_triplet))) {
    return("NA")
  }

  # convert color space to hsv
  color_triplet <- as.data.frame(t(rgb2hsv(
    color_triplet[1],
    color_triplet[2],
    color_triplet[3]
  )))

  # extract and scale HSV values for conditional evaluation
  h <- color_triplet$h * 360 # scale to 0-360
  s <- color_triplet$s * 100 # scale to 0-100
  v <- color_triplet$v * 100 # scale to 0-100

  if (verbose) {
    print(color_triplet)
  }

  # get all color names from CLUT
  color_names <- unique(clut[, 1])

  # evaluate for each color
  calls <- rep(NA, length(color_names))
  names(calls) <- color_names

  for (color in 1:length(color_names)) {
    parsed_lut <- parse_lut(color_names[color], clut)
    conditional <- construct_conditional(parsed_lut, destination = "getter")
    calls[color] <- ifelse(eval(parse(text = conditional)), 1, 0)
  }

  # see which color was matched (should only return 1 match)
  matched_color <- names(calls)[which.max(calls)]

  if (verbose) {
    print(calls)
  }

  overlap_warning <- paste(
    "More than 1 color label matched on color triplet!",
    "There are likely overlapping color boundaries in",
    "the CLUT. Please check and update color",
    "boundary definitions in the CLUT."
  )

  if (length(which.max(calls)) > 1) {
    warning(strwrap(
      overlap_warning,
      width = 0.95 * getOption("width"),
      prefix = "\n"
    ))
  }

  return(matched_color)
}
