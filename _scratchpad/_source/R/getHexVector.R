getHexVector <- function(mapping) {
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  
  ##get default HEX values from mapping
  hex <- getMappedHex(mapping)
  hex <- c(hex, "#FFFFFF") #default background color for sprite plot
  names(hex) <- c(colors, "is.bg")
  
  return(hex)
  
}