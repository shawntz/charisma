callColors <- function(img, mapping) {
  
  ##read in color mapping sheet
  #mapping <- read.csv(mapping, header = T, sep = ",")
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  
  ##get T/F calls for each color
  calls <- list()
  for(color in 1:length(colors)) {
    print(colors[color])
    parsed_mapping <- parseMapping(mapping, colors[color])
    parsed_conditional <- parseConditional(parsed_mapping)
    calls[[color]] <- apply(img[,1:3], 1, checkColor, parsed_conditional)
  }
  
  names(calls) <- colors
  
  return(calls)
  
}