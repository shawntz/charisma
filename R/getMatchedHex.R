getMatchedHex <- function(color_name, hex_vector) {

  # check if color_name exists in hex_vector names
  if(!color_name %in% names(hex_vector))
    stop("Error: specified color name is not defined in color mapping.
         Please check definitions in color mapping file.")

  return(hex_vector[which(names(hex_vector) == color_name)])

}
