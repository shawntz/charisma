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
plotSprite <- function(charisma_obj, centroids = FALSE, plot.centroids.type = c("alpha", "silhouette", "original"), cex = 1, multi.plot = FALSE, mapping = color.map) {

  # for resetting
  if(!multi.plot)
    user_par <- graphics::par(no.readonly = TRUE)

  # check if valid plot.centroids.type method
  plot.centroids.type <- tolower(plot.centroids.type)
  plot.centroids.type <- match.arg(plot.centroids.type)
  if(is.null(plot.centroids.type))
    stop("Invalid plot.centroids.type method specified.
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
    if(plot.centroids.type == "alpha")
      hex_values <- charisma_obj$alpha.matrix
    else if(plot.centroids.type == "silhouette")
      hex_values <- charisma_obj$silhouette.matrix
    else if(plot.centroids.type == "original")
      hex_values <- charisma_obj$hex.matrix

  asp <- img$nrows[1] / img$ncols[1]

  main_title <- "Sprite Plot"
  if(centroids)
    main_title <- "Centroid Plot"

  plot(0:1, 0:1, type = "n", axes = FALSE,
       asp = asp, main = main_title, xlab = "", ylab = "")

  graphics::rasterImage(hex_values, 0, 0, 1, 1)
  #points(0.2661157, 1-0.4738292, col = "black", pch = 8, cex = 5)
  #temp_mat <- cbind(charisma_obj$filtered.2d$x.coord/1210, charisma_obj$filtered.2d$y.coord/1815)
  #print(head(temp_mat))
  #selectedPoints <- fhs(temp_mat)
  #points(0.3991736, 0.1404959, col = "black", pch = 8, cex = 5)
  #points(0.3991736, 1-0.1404959, col = "red", pch = 8, cex = 5)
  #points(0.1404959, 0.3991736, col = "blue", pch = 8, cex = 5)
  #points(1-0.1404959, 0.3991736, col = "orange", pch = 8, cex = 5)
  #print(selectedPoints)

  # plot centroids if requested
  if(centroids) {
    # get scaled x-coordinates for centroid plots
    x_coords <- charisma_obj$centroid.x
    #x_coords <- charisma_obj$centroid.x[which(charisma_obj$centroid.x > 0)]
    x_coords[which(charisma_obj$color.frequencies < .01)] <- NaN
    print(x_coords) #temp for debugging

    # get scaled y-coordinates for centroid plots
    y_coords <- charisma_obj$centroid.y
    #y_coords <- charisma_obj$centroid.y[which(charisma_obj$centroid.y > 0)]
    y_coords[which(charisma_obj$color.frequencies < .01)] <- NaN
    print(y_coords) #temp for debugging

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
