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
plotCentroidGrid <- function(charisma_obj, cex = 1.5, mapping = color.map) {

  # for resetting
  user_par <- graphics::par(no.readonly = TRUE)

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)
  num_colors <- length(color_names)

  # get default hex values from color mapping
  hexes <- getHexVector(mapping)

  # get flattened image data for image dimensions
  img <- charisma_obj$filtered.2d

  graphics::layout(matrix(c(1,2,3,4,5,6,7,8,9,10), 2, 5, byrow = TRUE))

  asp <- img$nrows[1] / img$ncols[1]

  for(ii in 1:num_colors) {
    plot(0:1, 0:1, type = "n", axes = FALSE,
         asp = asp, main = paste0("Centroid: ", color_names[ii]), xlab = "", ylab = "")

    graphics::rasterImage(charisma_obj$color.clusters[[ii]], 0, 0, 1, 1)

    # get scaled x-coordinates for centroid plots
    x_coords <- charisma_obj$centroid.x
    #x_coords <- charisma_obj$centroid.x[which(charisma_obj$centroid.x > 0)]
    #print(x_coords)
    #print(charisma_obj$color.frequencies)
    #print(which(charisma_obj$color.frequencies < .01))
    x_coords[which(charisma_obj$color.frequencies < .01)] <- NaN
    print(x_coords) #temp for debugging

    # get scaled y-coordinates for centroid plots
    y_coords <- charisma_obj$centroid.y
    #y_coords <- charisma_obj$centroid.y[which(charisma_obj$centroid.y > 0)]
    y_coords[which(charisma_obj$color.frequencies < .01)] <- NaN
    print(y_coords) #temp for debugging

    # iteratively plot x-y centroids in matching color on plot
    cur_color <- names(hexes[which(names(hexes) == names(x_coords)[ii])])
    points(x_coords[ii], y_coords[ii], bg = cur_color, col = "black", pch = 23, cex = cex)
  }




}
