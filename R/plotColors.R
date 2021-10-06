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
plotColors <- function(charisma_obj, type = c("freq", "spatial", "centroid"), threshold = .05, multi.plot = FALSE, mapping = color.map) {

  # check if valid plot type
  type <- tolower(type)
  type <- match.arg(type)
  if(is.null(type))
    stop("Invalid plot type specified. Please select from 'freq', 'spatial', or 'centroid'.")

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)

  # for resetting
  if(!multi.plot)
    user_par <- graphics::par(no.readonly = TRUE)

  # get default hex values from color mapping
  hex <- getMappedHex(mapping)

  # extract color scores
  if(type == "freq") {
    # extract frequency means
    color_scores <- charisma_obj$color.frequencies
  } else if(type == "spatial") {
    # extract spatial density scores
    color_scores <- charisma_obj$spatial.density
  } else if(type == "centroid") {
    # extract centroid distances
    color_scores <- charisma_obj$centroid.dists
  }

  # get k-value (i.e., total number of discrete color classes)
  if(type == "freq") {
    # extract color means for each color
    color_means <- charisma_obj$color.frequencies
    color_means <- color_means[color_means >= threshold]
    called_colors_freq <- names(color_means)
    color_summary <- ifelse(color_names %in% called_colors_freq, 1, 0)
  } else if(type == "spatial") {
    # extract spatial density scores for each color
    spatial_scores <- charisma_obj$spatial.density
    spatial_scores <- spatial_scores[spatial_scores >= threshold]
    called_colors_spatial <- names(spatial_scores)
    color_summary <- ifelse(color_names %in% called_colors_spatial, 1, 0)
  } else if(type == "centroid") {
    # extract centroid distances for each color
    centroid_distances <- charisma_obj$centroid.dists

    # transform values before plotting
    # replace NaN values with 0
    centroid_distances[is.na(centroid_distances)] <- 0

    # replace colors with frequency less than 1% with 0
    centroid_distances[which(charisma_obj$color.frequencies < .01)] <- 0

    # scale all distances to the max distances
    centroid_distances <- centroid_distances / max(centroid_distances)

    centroid_distances <- centroid_distances[centroid_distances >= threshold]
    called_colors_centroid <- names(centroid_distances)
    color_summary <- ifelse(color_names %in% called_colors_centroid, 1, 0)
  }

  names(color_summary) <- color_names

  # get total number of color calls (k) and append to end of data frame
  color_summary <- color_summary %>%
    t() %>%
    as.data.frame() %>%
    dplyr::mutate(k = rowSums(.))

  if(type == "freq") {
    # make plot
    freq_bar <- barplot(height = color_scores, names = names(color_scores), col = hex, main = paste0("Color Frequency (k=", color_summary$k, ", ", (threshold*100), "%)"),
            ylim = c(0,1), ylab = "Proportion of Image", las = 2)
    #text(freq_bar, round(color_scores, 2) + .1, round(color_scores, 2), cex = 1, srt = 90)
  } else if(type == "spatial") {
    # transform values before plotting
    # replace colors with frequency less than 1% with 0
    color_scores[which(charisma_obj$color.frequencies < .01)] <- 0

    # make plot
    spatial_bar <- barplot(height = color_scores, names = names(color_scores), col = hex, main = paste0("Spatial Density (k=", color_summary$k, ", ", (threshold*100), "%)"),
            ylim = c(0,1), ylab = "Proportion of Maximized Patchiness", las = 2)
    #text(spatial_bar, round(color_scores, 2) + .1, round(color_scores, 2), cex = 1, srt = 90)
  } else if(type == "centroid") {

    # transform values before plotting
    # replace NaN values with 0
    color_scores[is.na(color_scores)] <- 0

    # replace colors with frequency less than 1% with 0
    color_scores[which(charisma_obj$color.frequencies < .01)] <- 0

    # scale all distances to the max distances
    print(color_scores)
    print(max(color_scores))
    color_scores <- color_scores / max(color_scores)

    # make plot
    centroid_bar <- barplot(height = color_scores, names = names(color_scores), col = hex, main = paste0("Scaled Centroid Distances (k=", color_summary$k, ", ", (threshold*100), "%)"),
            ylim = c(0,1), ylab = "Scaled Centroid Distances", las = 2)
    #text(centroid_bar, round(color_scores, 2) + .05, round(color_scores, 2), cex = 1.5, srt = 90)
  }
  abline(h = threshold, col = "red", lty = "dashed")

  # reset parameters
  if(!multi.plot)
    graphics::par(user_par)

}
