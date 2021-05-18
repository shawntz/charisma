plotColors <- function(charisma_obj, mapping = charisma::color.map, type = c("freq", "spatial"), threshold = .05) {

  # check if valid plot type
  type <- match.arg(type)
  if(is.null(type))
    stop("Invalid plot type specified. Please select from `freq` or `spatial`.")

  # for resetting
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
  k <- length(color_scores[color_scores >= threshold])

  if(type == "freq") {
    # make plot
    barplot(height = color_scores, names = names(color_scores), col = hex, main = paste0("Color Frequency (k=", k, ", ", (threshold*100), "%)"),
            ylim = c(0,1), ylab = "Proportion of Image", las = 2)
  } else if(type == "spatial") {
    # make plot
    barplot(height = color_scores, names = names(color_scores), col = hex, main = paste0("Spatial Density (k=", k, ", ", (threshold*100), "%)"),
            ylim = c(0,1), ylab = "Proportion of Maximized Patchiness", las = 2)
  }
  abline(h = threshold, col = "red", lty = "dashed")

  # reset parameters
  graphics::par(user_par)

}
