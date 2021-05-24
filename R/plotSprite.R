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
plotSprite <- function(charisma_obj, centroids = FALSE, plot.centroids = c("alpha", "silhouette", "original"), cex = 3, multi.plot = FALSE, mapping = color.map) {

  # for resetting
  if(!multi.plot)
    user_par <- graphics::par(no.readonly = TRUE)

  # check if valid plot.centroids method
  plot.centroids <- tolower(plot.centroids)
  plot.centroids <- match.arg(plot.centroids)
  if(is.null(plot.centroids))
    stop("Invalid plot.centroids method specified.
         Please select from 'alpha', 'silhouette', or 'original'.")

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)
  num_colors <- length(color_names)

  # get default hex values from color mapping
  hexes <- getHexVector(mapping)

  # get flattened image data for image dimensions
  img <- charisma_obj$filtered.2d

  # get rasterized object for plotting based on centroids option
  if(!centroids)
    hex_values <- charisma_obj$hex.matrix
  else if(centroids)
    if(plot.centroids == "alpha")
      hex_values <- charisma_obj$alpha.matrix
    else if(plot.centroids == "silhouette")
      hex_values <- charisma_obj$silhouette.matrix
    else if(plot.centroids == "original")
      hex_values <- charisma_obj$hex.matrix

  asp <- img$nrows[1] / img$ncols[1]

  plot(0:1, 0:1, type = "n", axes = FALSE,
       asp = asp, main = "Sprite Plot", xlab = "", ylab = "")

  graphics::rasterImage(hex_values, 0, 0, 1, 1)

  # plot centroids if requested
  if(centroids) {
    # get scaled x-coordinates for centroid plots
    x_coords <- charisma_obj$centroid.x[which(charisma_obj$centroid.x > 0)]
    print(x_coords)

    # get scaled y-coordinates for centroid plots
    y_coords <- charisma_obj$centroid.y[which(charisma_obj$centroid.y > 0)]
    print(y_coords)

    # iteratively plot x-y centroids in matching color on plot
    for(i in 1:length(x_coords)) {
      cur_color <- names(hexes[which(names(hexes) == names(x_coords)[i])])
      points(x_coords[i], y_coords[i], bg = cur_color, col = "black", pch = 23, cex = cex)
    }
  }

  # reset parameters
  if(!multi.plot)
    graphics::par(user_par)

}
