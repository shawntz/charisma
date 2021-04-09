readImg <- function(path, alpha = T) {
  
  img <- loadImg(path, lower = NULL, upper = NULL, alpha.channel = alpha)
  
  ##save original image dimensions for later plotting
  nrows <- dim(img$original.rgb)[1]
  ncols <- dim(img$original.rgb)[2]
  
  ##refactor img as dataframe in long format
  rgb_version <- img$filtered.rgb.2d
  img <- as.data.frame(img$hsv.version)
  img <- cbind(img, rgb_version)
  img$id <- seq(1, nrow(img))
  img$nrows <- rep(nrows, nrow(img))
  img$ncols <- rep(ncols, nrow(img))
  
  return(img)
  
}