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
summarize <- function(charisma_obj) {
  summary_table <- summarise_colors(charisma_obj$colors)
  return(summary_table)
}

# Alias for UK spelling
#' @rdname summarize
#' @export
summarise <- summarize
