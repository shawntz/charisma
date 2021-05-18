validateMapping <- function(mapping, simple = T) {
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  
  ##create empty list to hold color calls in
  calls <- list()
  
  ##generate entire HSV color space
  if(simple) {
    h <- rep(0:360)
    s <- rep(0:100)
    v <- rep(0:100)
  } else if(!simple) {
    h <- seq(0, 360, length.out = (361*2))
    s <- seq(0, 100, length.out = (101*2))
    v <- s
  }
  
  img <- expand.grid(h,s,v)
  colnames(img) <- c("h", "s", "v")
  
  cat(paste0("Running Color Validation along ", nrow(img), " colors in HSV space. Please wait...\n\n"))
  
  for(color in 1:length(colors)) {
    parsed_mapping <- parseMapping(mapping, colors[color])
    parsed_conditional <- parseConditional(parsed_mapping)
    calls[[color]] <- ifelse(eval(parse(text = parsed_conditional)), 1, 0)
  }
  
  names(calls) <- colors
  
  ##convert list of color calls to dataframe
  calls <- data.frame(matrix(unlist(calls), ncol = length(calls), byrow = F))
  colnames(calls) <- colors
  
  ##sum counts per pixel and add column
  h <- img$h
  s <- img$s
  v <- img$v
  calls <- calls %>%
    mutate(total = rowSums(.)) %>%
    add_column(h, .before = as.character(colors[1])) %>%
    add_column(s, .after = "h") %>%
    add_column(v, .after = "s")
  
  ##extract missing or duplicate pixels in HSV space
  invalid <- calls[calls$total != 1,]
  
  if(nrow(invalid) > 0) {
    cat(paste0("\n    Missing color calls for ", nrow(invalid), " pixels ==> Mapping validation failed.\nSee output `missingColorCalls` for missing pixels.\n"))
    return(invalid)
  } else {
    cat("\n    No missing color calls. Color Mapping successfully validated!\n\n")
    return("NONE")
  }
  
}