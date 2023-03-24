summarise_colors <- function(uniq_color_vec, mapping = color.map) {
  # get all color names from mapping
  color_names <- get_mapped_colors(mapping)

  color_summary <- ifelse(color_names %in% uniq_color_vec, 1, 0)

  names(color_summary) <- color_names

  # get total number of color calls (k) and append to end of data frame
  color_summary <- color_summary %>%
    t() %>%
    as.data.frame() %>%
    dplyr::mutate(k = rowSums(.))

  return(color_summary)
}
