summarizeCalledColors <- function(call, mapping, threshold = .05) {
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  
  ##get all means for each color
  color_means <- getColorMeans(call, mapping)
  
  ##get color names that surpassed the threshold
  color_means <- color_means[color_means >= threshold]
  called_colors <- names(color_means)
  
  ##build organized summary of 1's and 0's for each possible color
  color_summary <- ifelse(colors %in% called_colors, 1, 0)
  names(color_summary) <- colors
  
  return(color_summary)
  
}