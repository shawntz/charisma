getSpatialDensityScores <- function(img, mapping) {
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  num_colors <- length(colors)
  
  color_names_matrix <- getColorNamesMatrix(img, mapping)
  
  ##get spatial density scores for each color
  scores <- rep(NA, num_colors)
  for(ii in 1:num_colors) {
    scores[ii] <- getSpatialDensity(color_names_matrix, colors[ii])
  }
  names(scores) <- colors
  
  return(scores)
  
}