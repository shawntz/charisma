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
charisma <- function(img_path, stack_colors = TRUE, threshold = 0.05, verbose = TRUE) {
  # load image with clustered centers
  img <- load_image(img_path, verbose = verbose)

  # get proportion table for cluster centers
  sizes_prop <- prop.table(img$sizes)

  # combine clustered data
  color_data <- as.data.frame(cbind(img$centers * 255, t(t(img$sizes)), t(t(sizes_prop))))
  colnames(color_data) <- c("r", "g", "b", "size", "prop")

  # get discrete color names for clusters
  color_labels <- rep(NA, nrow(color_data))

  for(color in 1:length(color_labels)) {
    color_labels[color] <- parse_color(c(color_data$r[color], color_data$g[color], color_data$b[color]))
  }

  # combine label classifications with color data
  color_data <- cbind(color_data, classification = t(t(color_labels)))

  # stack by color (if requested)
  if (stack_colors) color_data <- aggregate(cbind(size, prop) ~ classification, data = color_data, FUN = sum)

  # filter out colors based on proportion threshold (if set)
  color_data <- color_data[color_data$prop >= threshold,]

  # sort classifications
  color_data <- color_data[order(color_data$prop, decreasing = TRUE), ]

  # unique colors classified
  # print(unique(color_data$classification))

  # TODO: color replacement function (over the merging function)
  # TODO: add in a function to just spit out the k-value per image

  # TODO: add in proportion threshold and filter out zero-prop colors (and also add same color classes together)
  # TODO: add in mediated setting to that is synchronously swaps colors in recolorized sample + the palette (e.g., change_color(from = 2, to = 4))
  #  ... and make it have a 1-step back undo feature (bird_obj_copy$pixel_assignments[which(bird_obj_copy$pixel_assignments == 4)] <- 2)
  # TODO: make it easy to save recolorized output pngs through a setting so that the output 'k' classifications matches the output recolorized image
  return(color_data)
}
