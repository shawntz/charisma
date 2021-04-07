callColors <- function(img, mapping) {
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  
  img <- as.data.frame(img[,1:3])
  img$h <- round(img$h * 360)
  img$s <- round(img$s * 100)
  img$v <- round(img$v * 100)
  
  ##get T/F calls for each color
  calls <- list()
  
  cat("Counting colors...\n")
  for(color in 1:length(colors)) {
    parsed_mapping <- parseMapping(mapping, colors[color])
    parsed_conditional <- parseConditional(parsed_mapping)
    calls[[color]] <- ifelse(eval(parse(text = parsed_conditional)), 1, 0)
  }
  
  names(calls) <- colors
  
  ##rearrange color called data into columns with original pixels
  pixel_calls <- data.frame(do.call(cbind, calls))
  combo_data <- cbind(img, pixel_calls)
  
  return(combo_data)
  
}