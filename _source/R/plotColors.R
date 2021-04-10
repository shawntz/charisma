plotColors <- function(color_means, mapping, threshold = .05) {
  
  ##get default HEX values from mapping
  hex <- getMappedHex(mapping)
  
  ##get k-value
  k <- length(color_means[color_means >= threshold])
  
  ##make plot
  barplot(height = color_means, names = names(color_means), col = hex, main = paste0("Color Frequency (k=", k, ", ", (threshold*100), "%)"), 
          ylim = c(0,1), ylab = "Proportion of Image", las = 2)
  abline(h = threshold, col = "red", lty = "dashed")
  
}