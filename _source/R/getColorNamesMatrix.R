getColorNamesMatrix <- function(img, mapping) {
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  num_colors <- length(colors)
  
  ##extract color call columns
  calls <- img[,c(4,8:(10 + num_colors))]
  calls_cut <- calls[,c(1, 5:(4 + num_colors))]
  
  ##modify values for easy sorting of background vs. color called pixels
  calls_cut <- calls_cut * -1
  calls_cut$is.bg <- calls_cut$is.bg * -10
  color_pixels <- apply(calls_cut, 1, which.min)
  bg_pixels <- apply(calls_cut, 1, which.max)
  
  combos <- as.data.frame(cbind(is.bg = calls_cut[,1], color.loc = color_pixels))
  combos <- cbind(combos, color.name = colnames(calls_cut)[combos[,2]])
  
  ##get raw color names based on combos to then convert to hex values
  color_names <- ifelse(combos$is.bg == 10, "is.bg", combos$color.name)
  
  ##make plot
  asp <- img$nrows[1] / img$ncols[1]
  dim(color_names) <- c(img$nrows[1], img$ncols[2])
  
  return(color_names)
  
}