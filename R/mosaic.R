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
mosaic <- function(color.props, size = 10, out.path = normalizePath("~"),
                   out.prefix = "charisma_mosaic", verbose = TRUE) {
  if (!all(sapply(color.props, function(x) grepl("^#[0-9A-Fa-f]{6}$", x$hex)))) {
    stop("Invalid hex color code detected.")
  }

  if (sum(sapply(color.props, function(x) x$prop)) != 1) {
    stop("The sum of proportions must be equal to 1.")
  }

  total_cells <- size * size
  n_color <- sapply(color.props, function(x) round(x$prop * total_cells))
  color_vec <- unlist(mapply(function(hex, count) rep(hex, count),
                             sapply(color.props, function(x) x$hex),
                             n_color))



  if (length(color_vec) < total_cells) {
    color_vec <- c(color_vec, rep(color.props[[1]]$hex, total_cells - length(color_vec)))
  } else if (length(color_vec) > total_cells) {
    color_vec <- color_vec[1:total_cells]
  }

  color_vec <- sample(color_vec)

  color_mat <- matrix(color_vec, nrow = size, byrow = TRUE)

  color_labels <- sapply(color.props, function(x) paste0("hex-", gsub("#", "", x$hex), "_color-", x$color, "_prop-", x$prop))
  filename <- paste0(out.prefix, "_", paste(color_labels, collapse = "_"), ".png")

  full_output_path <- file.path(out.path, filename)

  if (verbose) {
    message(full_output_path)
  }

  png(full_output_path, width = size * 100, height = size * 100)
  par(mar = c(0, 0, 0, 0), xaxs = "i", yaxs = "i")
  plot(NA, xlim = c(0, size), ylim = c(0, size), type = "n", xlab = "", ylab = "", axes = FALSE)

  for (i in 1:size) {
    for (j in 1:size) {
      rect(i - 1, j - 1, i, j, col = color_mat[i, j], border = NA)
    }
  }

  dev.off()

  return(full_output_path)
}
