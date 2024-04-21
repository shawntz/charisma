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
color2label <- function(color_triplet, hsv = F, verbose = F, lut = color.lut) {
  if (!hsv) {
    # convert color space to hsv
    color_triplet <- as.data.frame(t(rgb2hsv(color_triplet[1],
                                             color_triplet[2],
                                             color_triplet[3])))
  } else {
    # this is to feed in a single row of h, s, and v values
    #  (a la the patch set in long format that whitney sent me)
    color_triplet <- as.data.frame(cbind(h = color_triplet$h[1],
                                         s = color_triplet$s[1],
                                         v = color_triplet$v[1]))
  }

  # check if any NAs in color triplet and return NA if true
  if (is.na(sum(color_triplet[1,]))) return("NA")

  if (verbose) print(color_triplet)

  # rescale hsv color triplet to match scales used in parsed color LUT
  h <- round(color_triplet[1] * 360, 2)
  s <- round(color_triplet[2] * 100, 2)
  v <- round(color_triplet[3] * 100, 2)

  # get all color names from color LUT
  color_names <- unique(lut[,1])

  # evaluate for each color
  calls <- rep(NA, length(color_names))
  names(calls) <- color_names

  for (color in 1:length(color_names)) {
    parsed_lut <- parse_lut(color_names[color], lut)
    conditional <- construct_conditional(parsed_lut, destination = "getter")
    calls[color] <- ifelse(eval(parse(text = conditional)), 1, 0)
  }

  # see which color was matched (should only return 1 match)
  matched_color <- names(calls)[which.max(calls)]

  if (verbose) print(calls)

  overlap_warning <- paste("More than 1 color label matched on color triplet!",
                           "There are likely overlapping color boundaries in",
                           "the color LUT. Please check and update color",
                           "boundary definitions in the LUT.")

  if (length(which.max(calls)) > 1) {
    warning(strwrap(overlap_warning,
                    width = 0.95 * getOption("width"),
                    prefix = "\n"))
  }

  return(matched_color)
}
