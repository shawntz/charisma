plotColors <- function(charisma_obj, mapping = charisma::color.map, type = c("freq", "spatial"), threshold = .05, multi.plot = FALSE) {

  # check if valid plot type
  type <- tolower(type)
  type <- match.arg(type)
  if(is.null(type))
    stop("Invalid plot type specified. Please select from `freq` or `spatial`.")

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
  }

  # get k-value (i.e., total number of discrete color classes)
  # extract color means for each color
  if(type == "freq") {
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
  }

  names(color_summary) <- color_names

  # get total number of color calls (k) and append to end of data frame
  color_summary <- color_summary %>%
    t() %>%
    as.data.frame() %>%
    dplyr::mutate(k = rowSums(.))

  if(type == "freq") {
    # make plot
    barplot(height = color_scores, names = names(color_scores), col = hex, main = paste0("Color Frequency (k=", color_summary$k, ", ", (threshold*100), "%)"),
            ylim = c(0,1), ylab = "Proportion of Image", las = 2)
  } else if(type == "spatial") {
    # make plot
    barplot(height = color_scores, names = names(color_scores), col = hex, main = paste0("Spatial Density (k=", color_summary$k, ", ", (threshold*100), "%)"),
            ylim = c(0,1), ylab = "Proportion of Maximized Patchiness", las = 2)
  }
  abline(h = threshold, col = "red", lty = "dashed")

  # reset parameters
  if(!multi.plot)
    graphics::par(user_par)

}
