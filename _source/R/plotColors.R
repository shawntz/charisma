plotColors <- function(color_means, mapping, threshold = .05) {
  
  ##get default HEX values from mapping
  hex <- getMappedHex(mapping)
  
  ##make plot
  barplot(height = color_means, names = names(color_means), col = hex, main = "Color Frequency", 
          ylim = c(0,1), ylab = "Proportion of Image", las = 2)
  abline(h = threshold, col = "red", lty = "dashed")
  
}