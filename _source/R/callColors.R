callColors <- function(img, mapping) {
  
  ##read in color mapping sheet
  #mapping <- read.csv(mapping, header = T, sep = ",")
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  
  img <- as.data.frame(img[,1:3])
  img$h <- round(img$h * 360)
  img$s <- round(img$s * 100)
  img$v <- round(img$v * 100)
  print(head(img))
  ##get T/F calls for each color
  calls <- list()
  pb <- progress::progress_bar$new(total = length(colors), format = " [:bar] :percent eta: :eta", clear = F)
  cat("Counting colors...\n")
  for(color in 1:length(colors)) {
    pb$tick()
    
    parsed_mapping <- parseMapping(mapping, colors[color])
    parsed_conditional <- parseConditional(parsed_mapping)
    #calls[[color]] <- apply(img[,1:3], 1, checkColor, parsed_conditional)
    #calls[[color]] <- apply(img, 1, checkColorFaster, parsed_conditional)
    print(parsed_conditional)
    calls[[color]] <- ifelse(eval(parse(text = parsed_conditional)), 1, 0)
  }
  
  names(calls) <- colors
  
  ##rearrange color called data into columns with original pixels
  pixel_calls <- data.frame(do.call(cbind, calls))
  combo_data <- cbind(img, pixel_calls)
  
  return(combo_data)
  
}