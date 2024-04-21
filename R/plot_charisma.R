#' Add together two numbers
#'
#' @title this is a test
#' @param x A number
#' @param y A number
#' @return The sum of \code{x} and \code{y}
#' @examples
#' add(1, 1)
#' add(10, 1)
#'
#' @rdname plot.charisma
#' @export
plot.charisma <- function(x, plot.all = T, plot.original = F,
                          plot.recolored = F, plot.masked = F,
                          plot.props = F, plot.pavo.img = F,
                          plot.pavo.classes = F, font.size = 1.75,
                          real.bar.colors = T) {
  # reset graphical env
  current_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(current_par))

  # set new graphical env defaults
  par(cex.main = font.size, cex.lab = font.size,
      cex.axis = font.size, mar = c(10,1,8,1))

  # check whether charisma object contains pavo classifications
  if (
    is.null(x$input2pavo) ||
    is.null(x$pavo_adj_stats) ||
    is.null(x$pavo_adj_class) ||
    is.null(x$pavo_adj_class_plot_cols)
  ) {
    plot.pavo.img <- FALSE
    plot.pavo.classes <- FALSE
  }

  # construct layouts
  if (plot.all) {
    plot_layout <- matrix(c(0, 1, 4, 0, 0, 2, 5, 0, 0, 3, 6, 0),
                          ncol = 3, nrow = 4)
    plot_heights <- rep(c(0.15, 0.35, 0.35, 0.15), times = 3)
  } else {
    num_plots <- sum(c(plot.original, plot.recolored, plot.masked,
                       plot.props, plot.pavo.img, plot.pavo.classes))
    if (num_plots == 0) {
      stop("nothing to plot!")
    }

    if (num_plots == 1) {
      plot_layout <- matrix(c(1), ncol = 1, nrow = 1)
      plot_heights <- 1
    } else if (num_plots == 5 | num_plots == 6) {
      plot_layout <- matrix(c(0, 1, 4, 0, 0, 2, 5, 0, 0, 3, 6, 0),
                            ncol = 3, nrow = 4)
      plot_heights <- rep(c(0.15, 0.35, 0.35, 0.15), times = 3)
    } else if (num_plots == 4) {
      plot_layout <- matrix(c(0, 1, 3, 0, 0, 2, 4, 0),
                            ncol = 2, nrow = 4)
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

  # test layout
  # layout.show(6)

  if (plot.original) plot_original(x)

  if (plot.recolored) plot_recolored(x)

  if (plot.masked) plot_masked(x)

  if (plot.props) {
    if (num_plots <= 4) {
      mar = c(7.5, 8, 5, 2)
    } else {
      mar = c(5.5, 8, 5, 0)
    }
    plot_props(x, !real.bar.colors, mar)
  }

  if (plot.pavo.img) plot_pavo_input(x)

  if (plot.pavo.classes) {
    if (num_plots <= 4) {
      mar = c(2, 2, 5, 2)
    } else {
      mar = c(0, 2, 5, 4.5)
    }
    plot_pavo_pal(x, mar)
  }
}
