#' Create a color mosaic visualization from color proportions
#'
#' This function generates a randomized mosaic grid visualization representing
#' the proportions of different colors, useful for visually displaying color
#' composition in a standardized format.
#'
#' @param color.props List of color proportion objects, where each element
#' contains:
#'   \itemize{
#'     \item \code{hex}: Hex color code (e.g., "#FF0000")
#'     \item \code{color}: Color name
#'     \item \code{prop}: Proportion value (all proportions must sum to 1)
#'   }
#' @param size Integer specifying the dimensions of the mosaic grid
#'   (size x size). Default is 10 (resulting in a 10 x 10 = 100 cell mosaic).
#' @param out.path Character string specifying the directory path for saving the
#'   output PNG file. Default is the user's home directory.
#' @param out.prefix Character string prefix for the output filename. Default is
#'   \code{"charisma_mosaic"}.
#' @param verbose Logical. If \code{TRUE}, prints the full output path. Default
#'   is \code{TRUE}.
#'
#' @return Character string containing the full path to the saved PNG file.
#'
#' @details
#' The mosaic function creates a visual representation of color proportions by:
#' \enumerate{
#'   \item Allocating grid cells proportional to each color's proportion
#'   \item Randomly shuffling cell positions to create a mosaic pattern
#'   \item Saving the result as a PNG file with an informative filename
#' }
#'
#' The output filename automatically encodes the hex codes, color names, and
#' proportions for documentation purposes.
#'
#' ![Example mosaic function output](charisma_mosaic_example.png)
#'
#' @seealso
#' \code{\link{charisma}} for generating color classifications
#'
#' @examples
#' # Create a mosaic from color proportions
#' colors <- list(
#'   list(hex = "#FF0000", color = "red", prop = 0.4),
#'   list(hex = "#00FF00", color = "green", prop = 0.3),
#'   list(hex = "#0000FF", color = "blue", prop = 0.3)
#' )
#' mosaic(colors, size = 10, out.path = tempdir())
#'
#' @export
mosaic <- function(
  color.props,
  size = 10,
  out.path = normalizePath("~"),
  out.prefix = "charisma_mosaic",
  verbose = TRUE
) {
  if (
    !all(sapply(color.props, function(x) grepl("^#[0-9A-Fa-f]{6}$", x$hex)))
  ) {
    stop("Invalid hex color code detected.")
  }

  if (sum(sapply(color.props, function(x) x$prop)) != 1) {
    stop("The sum of proportions must be equal to 1.")
  }

  total_cells <- size * size
  n_color <- sapply(color.props, function(x) round(x$prop * total_cells))
  color_vec <- unlist(mapply(
    function(hex, count) rep(hex, count),
    sapply(color.props, function(x) x$hex),
    n_color
  ))

  if (length(color_vec) < total_cells) {
    color_vec <- c(
      color_vec,
      rep(color.props[[1]]$hex, total_cells - length(color_vec))
    )
  } else if (length(color_vec) > total_cells) {
    color_vec <- color_vec[1:total_cells]
  }

  color_vec <- sample(color_vec)

  color_mat <- matrix(color_vec, nrow = size, byrow = TRUE)

  color_labels <- sapply(color.props, function(x) {
    paste0("hex-", gsub("#", "", x$hex), "_color-", x$color, "_prop-", x$prop)
  })
  filename <- paste0(
    out.prefix,
    "_",
    paste(color_labels, collapse = "_"),
    ".png"
  )

  full_output_path <- file.path(out.path, filename)

  if (verbose) {
    message(full_output_path)
  }

  png(full_output_path, width = size * 100, height = size * 100)
  oldpar <- par(mar = c(0, 0, 0, 0), xaxs = "i", yaxs = "i")
  on.exit(par(oldpar), add = TRUE)
  plot(
    NA,
    xlim = c(0, size),
    ylim = c(0, size),
    type = "n",
    xlab = "",
    ylab = "",
    axes = FALSE
  )

  for (i in 1:size) {
    for (j in 1:size) {
      rect(i - 1, j - 1, i, j, col = color_mat[i, j], border = NA)
    }
  }

  dev.off()

  return(full_output_path)
}
