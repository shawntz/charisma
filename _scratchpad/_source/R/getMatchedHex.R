getMatchedHex <- function(color_name, hex_vector) {
  
  return(hex_vector[which(names(hex_vector) == color_name)])
  
}