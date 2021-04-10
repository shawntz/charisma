summarizeCalledColors <- function(img, mapping, threshold = .05) {
  
  color_means <- getColorMeans(img, mapping)
  
  return(color_means[color_means >= threshold])
  
}