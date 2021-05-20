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
getColor <- function(color_triplet, color.space = c("rgb", "hsv"),
                     mapping = charisma::color.map, verbose = FALSE) {

  # check if valid color space
  color.space <- tolower(color.space)
  color.space <- match.arg(color.space)

  # convert color space to hsv if rgb
  if(color.space == "rgb") {
    color_triplet <- as.data.frame(t(rgb2hsv(color_triplet[1], color_triplet[2], color_triplet[3])))
  }

  if(verbose)
    print(color_triplet)

  # rescale hsv color triplet to match scales used in parsed color mapping
  h <- round(color_triplet[1] * 360, 2)
  s <- round(color_triplet[2] * 100, 2)
  v <- round(color_triplet[3] * 100, 2)

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)

  # evaluate for each color
  calls <- rep(NA, length(color_names))
  names(calls) <- color_names

  for(color in 1:length(color_names)) {
    parsed_mapping <- parseMapping(color_names[color], mapping)
    parsed_conditional <- parseConditional(parsed_mapping, destination = "getter")
    calls[color] <- ifelse(eval(parse(text = parsed_conditional)), 1, 0)
  }

  # see which color was matched (should only return 1 match)
  matched_color <- names(calls)[which.max(calls)]
  if(verbose)
    print(calls)

  if(length(which.max(calls)) > 1)
    warning("More than 1 color matched on color triplet -- overlapping color boundaries.
            Check and update color mapping boundary definitions.")

  return(matched_color)

}
