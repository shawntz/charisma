getSummary <- function(charisma_obj, mapping = charisma::color.map,
                       method = c("both", "freq", "spatial"),
                       freq.threshold = .05, spatial.threshold = .05) {

  # check if valid summary method
  method <- tolower(method)
  method <- match.arg(method)
  if(is.null(method))
    stop("Invalid summary method specified.
         Please select from `both`, `freq`, or `spatial`.")

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)

  # extract color means for each color
  color_means <- charisma_obj$color.frequencies
  color_means <- color_means[color_means >= freq.threshold]
  called_colors_freq <- names(color_means)

  # extract spatial density scores for each color
  spatial_scores <- charisma_obj$spatial.density
  spatial_scores <- spatial_scores[spatial_scores >= spatial.threshold]
  called_colors_spatial <- names(spatial_scores)

  # build organized summary array of 1's and 0's for each possible color
  if(method == "both") {
    color_summary <- ifelse((color_names %in% called_colors_freq) |
                              (color_names %in% called_colors_spatial),
                            1, 0)
  } else if(method == "freq") {
    color_summary <- ifelse(color_names %in% called_colors_freq, 1, 0)
  } else if(method == "spatial") {
    color_summary <- ifelse(color_names %in% called_colors_spatial, 1, 0)
  }
  names(color_summary) <- color_names

  # get total number of color calls (k) and append to end of data frame
  color_summary <- color_summary %>%
    t() %>%
    as.data.frame() %>%
    dplyr::mutate(k = rowSums(.))

  return(color_summary)

}
