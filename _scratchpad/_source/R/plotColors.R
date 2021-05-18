plotColors <- function(color_scores, mapping, type = c("freq", "spatial"), threshold = .05) {
  
  ##check if valid plot type
  type <- match.arg(type)
  
  ##get default HEX values from mapping
  hex <- getMappedHex(mapping)
  
  if(type == "freq") {
    
    ##get k-value
    k <- length(color_scores[color_scores >= threshold])
    
    ##make plot
    barplot(height = color_scores, names = names(color_scores), col = hex, main = paste0("Color Frequency (k=", k, ", ", (threshold*100), "%)"), 
            ylim = c(0,1), ylab = "Proportion of Image", las = 2)
    abline(h = threshold, col = "red", lty = "dashed")
    
  } else if(type == "spatial") {
    
    ##get k-value
    k <- length(color_scores[color_scores >= threshold])
    
    ##make plot
    barplot(height = color_scores, names = names(color_scores), col = hex, main = paste0("Spatial Density (k=", k, ", ", (threshold*100), "%)"), 
            ylim = c(0,1), ylab = "Proportion of Image", las = 2)
    abline(h = threshold, col = "red", lty = "dashed")
    
  }
  
}