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
get_mapped_hex <- function(mapping = color.map) {
  # return(unique(mapping$default.hex))
  return(mapping %>% select(color.name, default.hex))
}
