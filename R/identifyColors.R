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
identifyColors <- function(charisma_obj, mapping = charisma::color.map) {

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)

  charisma_obj <- as.data.frame(charisma_obj)

  # rescale hsv values to match color mapping definitions
  charisma_obj$h <- round(charisma_obj$h * 360, 2)
  charisma_obj$s <- round(charisma_obj$s * 100, 2)
  charisma_obj$v <- round(charisma_obj$v * 100, 2)

  # get TRUE/FALSE (1,0) calls for each discrete color name label
  calls <- list()

  img <- charisma_obj

  for(color in 1:length(color_names)) {
    parsed_mapping <- parseMapping(color_names[color], mapping)
    parsed_conditional <- parseConditional(parsed_mapping)
    calls[[color]] <- ifelse(eval(parse(text = parsed_conditional)), 1, 0)
  }

  names(calls) <- color_names

  # rearrange color called data into columns with original pixels
  pixel_calls <- data.frame(do.call(cbind, calls))
  combo_data <- cbind(charisma_obj, pixel_calls)

  # sum counts and add column of total counts (k)
  combo_data <- dplyr::mutate(combo_data, total = rowSums(combo_data[13:ncol(combo_data)]))

  return(combo_data)

}
