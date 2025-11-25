#' Plot method for charisma objects
#'
#' This function creates visualizations of color classification results from
#' a charisma analysis. It can display the original image, recolored image,
#' masked image, color proportions, and pavo color pattern geometry results.
#'
#' @param x A charisma object (output from \code{\link{charisma}} or
#'   \code{\link{charisma2}}).
#' @param plot.all Logical. If \code{TRUE}, plots all available visualizations.
#'   Default is \code{TRUE}.
#' @param plot.original Logical. If \code{TRUE}, plots the original image.
#'   Default is \code{FALSE}.
#' @param plot.recolored Logical. If \code{TRUE}, plots the recolored image
#'   showing discrete color classifications. Default is \code{FALSE}.
#' @param plot.masked Logical. If \code{TRUE}, plots the masked image after
#'   background removal. Default is \code{FALSE}.
#' @param plot.props Logical. If \code{TRUE}, plots a bar chart showing the
#'   proportion of pixels in each color category. Default is \code{FALSE}.
#' @param plot.pavo.img Logical. If \code{TRUE}, plots the image used for
#'   \pkg{pavo} color pattern geometry analysis. Default is \code{FALSE}.
#'   Only available if pavo analysis was performed.
#' @param plot.pavo.classes Logical. If \code{TRUE}, plots the color palette
#'   from \pkg{pavo} k-means clustering. Default is \code{FALSE}. Only available
#'   if pavo analysis was performed.
#' @param font.size Numeric. Size multiplier for plot text elements. Default
#'   is \code{1.75}.
#' @param props.x.cex Numeric. Size multiplier for x-axis labels in the
#'   proportions plot. Default is \code{1.5}.
#' @param real.bar.colors Logical. If \code{TRUE}, uses actual color values
#'   for bars in the proportions plot. If \code{FALSE}, uses a default color
#'   scheme. Default is \code{TRUE}.
#' @param ... Additional arguments (currently not used).
#'
#' @return This function is called for its side effects (creating plots) and
#'   does not return a value.
#'
#' @details
#' When \code{plot.all = TRUE}, all available plots are displayed in a
#' multi-panel layout. Individual plots can be selected by setting the
#' corresponding \code{plot.*} parameters to \code{TRUE}.
#'
#' The function automatically detects whether \pkg{pavo} analysis results are
#' present in the charisma object and adjusts the plot layout accordingly.
#'
#' @seealso
#' \code{\link{charisma}} for the main classification pipeline,
#' \code{\link{charisma2}} for batch processing
#'
#' @examples
#' \donttest{
#' # Run charisma on an image
#' img <- system.file("extdata", "Tangara_fastuosa_LACM60421.png",
#'                    package = "charisma")
#' result <- charisma(img)
#'
#' # Plot all results
#' plot(result)
#'
#' # Plot only original and recolored images
#' plot(result, plot.all = FALSE, plot.original = TRUE, plot.recolored = TRUE)
#'
#' # Plot color proportions
#' plot(result, plot.all = FALSE, plot.props = TRUE)
#' }
#'
#' @rdname plot.charisma
#'
#' @export
plot.charisma <- function(
  x,
  plot.all = TRUE,
  plot.original = FALSE,
  plot.recolored = FALSE,
  plot.masked = FALSE,
  plot.props = FALSE,
  plot.pavo.img = FALSE,
  plot.pavo.classes = FALSE,
  font.size = 1.75,
  props.x.cex = 1.5,
  real.bar.colors = TRUE,
  ...
) {
  # reset graphical env
  current_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(current_par))

  # set new graphical env defaults
  par(
    cex.main = font.size,
    cex.lab = font.size,
    cex.axis = font.size,
    mar = c(10, 1, 8, 1)
  )

  # check whether charisma object contains pavo classifications
  has_pavo <- TRUE

  if (
    is.null(x$input2pavo) ||
      is.null(x$pavo_adj_stats) ||
      is.null(x$pavo_adj_class) ||
      is.null(x$pavo_adj_class_plot_cols)
  ) {
    has_pavo <- FALSE
    plot.pavo.img <- FALSE
    plot.pavo.classes <- FALSE
  }

  # construct layouts
  if (plot.all) {
    plot.original <- TRUE
    plot.recolored <- TRUE
    plot.masked <- TRUE
    plot.props <- TRUE

    if (has_pavo) {
      plot.pavo.img <- TRUE
      plot.pavo.classes <- TRUE
      num_plots <- sum(c(
        plot.original,
        plot.recolored,
        plot.masked,
        plot.props,
        plot.pavo.img,
        plot.pavo.classes
      ))
      plot_layout <- matrix(
        c(0, 1, 4, 0, 0, 2, 5, 0, 0, 3, 6, 0),
        ncol = 3,
        nrow = 4
      )
      plot_heights <- rep(c(0.15, 0.35, 0.35, 0.15), times = 3)
    } else {
      num_plots <- sum(c(
        plot.original,
        plot.recolored,
        plot.masked,
        plot.props
      ))
      plot_layout <- matrix(c(0, 1, 3, 0, 0, 2, 4, 0), ncol = 2, nrow = 4)
      plot_heights <- rep(c(0.15, 0.35, 0.35, 0.15), times = 2)
    }
  } else {
    num_plots <- sum(c(
      plot.original,
      plot.recolored,
      plot.masked,
      plot.props,
      plot.pavo.img,
      plot.pavo.classes
    ))
    if (num_plots == 0) {
      stop("nothing to plot!")
    }

    if (num_plots == 1) {
      plot_layout <- matrix(c(1), ncol = 1, nrow = 1)
      plot_heights <- 1
    } else if (num_plots == 5 || num_plots == 6) {
      plot_layout <- matrix(
        c(0, 1, 4, 0, 0, 2, 5, 0, 0, 3, 6, 0),
        ncol = 3,
        nrow = 4
      )
      plot_heights <- rep(c(0.15, 0.35, 0.35, 0.15), times = 3)
    } else if (num_plots == 4) {
      plot_layout <- matrix(c(0, 1, 3, 0, 0, 2, 4, 0), ncol = 2, nrow = 4)
      plot_heights <- rep(c(0.15, 0.35, 0.35, 0.15), times = 2)
    } else if (num_plots == 2) {
      plot_layout <- matrix(c(1, 2), ncol = 2, nrow = 1)
      plot_heights <- c(1, 1)
    } else if (num_plots == 3) {
      plot_layout <- matrix(c(1, 2, 3), ncol = 3, nrow = 1)
      plot_heights <- c(1, 1, 1)
    }
  }

  graphics::layout(plot_layout, heights = plot_heights)

  if (plot.original) {
    plot_original(x)
  }

  if (plot.recolored) {
    plot_recolored(x)
  }

  if (plot.masked) {
    plot_masked(x)
  }

  if (plot.props) {
    if (num_plots <= 4) {
      mar <- c(7.5, 8, 5, 2)
    } else {
      mar <- c(5.5, 8, 5, 0)
    }
    plot_props(x, !real.bar.colors, mar, cex = props.x.cex)
  }

  if (plot.pavo.img) {
    plot_pavo_input(x)
  }

  if (plot.pavo.classes) {
    if (num_plots <= 4) {
      mar <- c(2, 2, 5, 2)
    } else {
      mar <- c(0, 2, 5, 4.5)
    }
    if (!is.null(x$k_override)) {
      k_arg <- x$k_override
    } else {
      k_arg <- NULL
    }
    plot_pavo_pal(x, k = k_arg, mar = mar)
  }
}
