#' Summarize color classification results
#'
#' This function takes a charisma object and produces a summary table showing
#' the proportion of pixels classified into each discrete color category.
#'
#' @param charisma_obj A charisma object (output from \code{\link{charisma}}
#'   or \code{\link{charisma2}}) containing color classification results.
#'
#' @return A data frame with one row per image showing the proportion of pixels
#'   assigned to each color category. Row names are set to the basename of the
#'   image file path.
#'
#' @details
#' The summary table shows the percentage of pixels classified into each of the
#' discrete color categories defined in the Color Look-Up Table (CLUT). This
#' provides a quantitative overview of the color composition of the analyzed
#' image.
#'
#' @seealso
#' \code{\link{charisma}} for the main classification pipeline,
#' \code{\link{validate}} for CLUT validation
#'
#' @examples
#' \dontrun{
#' # Run charisma on an image
#' img <- system.file("extdata", "Tangara_fastuosa_LACM60421.png",
#'                    package = "charisma")
#' result <- charisma(img)
#'
#' # Summarize the color classification results
#' summary_table <- summarize(result)
#' print(summary_table)
#' }
#'
#' @export
summarize <- function(charisma_obj) {
  summary_table <- summarise_colors(charisma_obj$colors)
  rownames(summary_table) <- basename(charisma_obj$path)
  return(summary_table)
}

# Alias for UK spelling
#' @rdname summarize
#' @export
summarise <- summarize
