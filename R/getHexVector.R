getHexVector <- function(mapping = charisma::color.map) {

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)

  # get default hex values from color mapping
  hex <- getMappedHex(mapping)

  # append default background color for sprite plot (white)
  hex <- c(hex, "#FFFFFF")
  names(hex) <- c(color_names, "is.bg")

  return(hex)

}
