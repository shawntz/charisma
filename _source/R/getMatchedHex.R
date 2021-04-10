getMatchedHex <- function(color_name, mapping) {
  
  ##get default HEX values from mapping
  hex <- getMappedHex(mapping)
  hex <- c(hex, "#FFFFFF") #default background color for sprite plot
  names(hex) <- c(colors, "is.bg")
  
  return(hex[which(names(hex) == color_name)])
  
}