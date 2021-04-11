callColors <- function(img, mapping, scale = T) {
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  
  img <- as.data.frame(img)
  if(scale) {
    img$h <- round(img$h * 360)
    img$s <- round(img$s * 100)
    img$v <- round(img$v * 100) 
  } else {
    img$h <- round(img$h)
    img$s <- round(img$s)
    img$v <- round(img$v) 
  }
  
  ##get T/F calls for each color
  calls <- list()
  
  for(color in 1:length(colors)) {
    parsed_mapping <- parseMapping(mapping, colors[color])
    parsed_conditional <- parseConditional(parsed_mapping)
    calls[[color]] <- ifelse(eval(parse(text = parsed_conditional)), 1, 0)
  }
  
  names(calls) <- colors
  
  ##rearrange color called data into columns with original pixels
  pixel_calls <- data.frame(do.call(cbind, calls))
  combo_data <- cbind(img, pixel_calls)
  
  ##sum counts and add column
  combo_data <- combo_data %>%
    mutate(total = rowSums(.[11:ncol(combo_data)]))
  
  return(combo_data)
  
}