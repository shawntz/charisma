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
plot.charisma <- function(x, ...,
                          plot.original = TRUE,
                          plot.sprite = TRUE,
                          plot.spatial = TRUE,
                          plot.centroids = FALSE,
                          plot.centroids.type = c("alpha", "silhouette", "original"),
                          freq.threshold = 0.1,
                          spatial.threshold = 0.85,
                          centroid.threshold = 0.5) {

  # for resetting
  user_par <- graphics::par(no.readonly = TRUE)

  # layout
  if(plot.original) {
    if(plot.sprite) {
      if(plot.spatial) {
        if(plot.centroids) {
          graphics::layout(matrix(c(1,2,3,4,5,6), 2, 3, byrow = TRUE))
        } else {
          graphics::layout(matrix(c(1,2,3,4), 2, 2, byrow = TRUE))
        }
      } else {
          if(plot.centroids) {
            graphics::layout(matrix(c(1,2,3,4,5,5), 2, 3, byrow = TRUE))
          } else {
            graphics::layout(matrix(c(1,2,3,3), 2, 2, byrow = TRUE))
          }
      }
    } else {
      if(plot.spatial) {
        if(plot.centroids) {
          graphics::layout(matrix(c(1,2,2,3,4,5), 2, 3, byrow = TRUE))
        } else {
          graphics::layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
        }
      } else {
          if(plot.centroids) {
            graphics::layout(matrix(c(1,2,3,4), 2, 2, byrow = TRUE))
          } else {
            graphics::layout(matrix(c(1,2), 2, 2, byrow = TRUE))
          }
      }
    }
  } else {
    if(plot.sprite) {
      if(plot.spatial) {
        if(plot.centroids) {
          graphics::layout(matrix(c(1,2,2,3,4,5), 2, 3, byrow = TRUE))
        } else {
          graphics::layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
        }
      } else {
          if(plot.centroids) {
            graphics::layout(matrix(c(1,2,3,4), 2, 2, byrow = TRUE))
          } else {
            graphics::layout(matrix(c(1,2), 2, 2, byrow = TRUE))
          }
      }
    } else {
      if(plot.spatial) {
        if(plot.centroids) {
          graphics::layout(matrix(c(1,2,3,4), 2, 2, byrow = TRUE))
        } else {
          graphics::layout(matrix(c(1,2), 2, 2, byrow = TRUE))
        }
      } else {
        if(plot.centroids) {
          graphics::layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
        } else {
          graphics::layout(matrix(c(1,1), 2, 2, byrow = TRUE))
        }
      }
    }
  }

  # plot original if specified
  if(plot.original)
    plotImage(x, multi.plot = TRUE)

  # plotting sprite image
  if(plot.sprite)
    plotSprite(x, multi.plot = TRUE)

  # plotting modified sprite with centroids
  if(plot.centroids)
    plotSprite(x, centroids = plot.centroids, plot.centroids.type = plot.centroids.type, multi.plot = TRUE)

  # plotting frequency
  plotColors(x, type = "freq", threshold = freq.threshold, multi.plot = TRUE)

  # plotting spatial
  if(plot.spatial)
    plotColors(x, type = "spatial", threshold = spatial.threshold, multi.plot = TRUE)

  # plotting centroid distances
  if(plot.centroids)
    plotColors(x, type = "centroid", threshold = centroid.threshold, multi.plot = TRUE)

  # reset parameters
  graphics::par(user_par)

}
