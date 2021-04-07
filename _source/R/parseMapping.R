parseMapping <- function(mapping, color_name) {
  
  ##check if color exists in mapping
  if(!color_name %in% mapping$color)
    stop("Error: specified color name is not defined in color mapping. Please check definitions in color mapping file.")
  
  ##subset color ranges
  mapping <- mapping[which(mapping$color == color_name),]
  h <- mapping$h
  s <- mapping$s
  v <- mapping$v
  
  ##check defined mapping lengths
  h <- strsplit(h, ",")[[1]]
  s <- strsplit(s, ",")[[1]]
  v <- strsplit(v, ",")[[1]]
  col_lens <- c(length(h), length(s), length(v))
  if(length(unique(col_lens)) != 1)
    stop("Error: specified color ranges are not of equal length. Please check definitions in color mapping file.")
  
  ##parse: split 'or' pipes
  h <- strsplit(h, "\\|")
  s <- strsplit(s, "\\|")
  v <- strsplit(v, "\\|")
  
  ##format output
  output <- list(h, s, v)
  names(output) <- c("h", "s", "v")
  
  return(output)
  
}