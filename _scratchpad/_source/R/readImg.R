readImg <- function(path, alpha = T) {
  
  img <- loadImg(path, lower = NULL, upper = NULL, alpha.channel = alpha)
  
  ##save original image dimensions for later plotting
  nrows <- dim(img$original.rgb)[1]
  ncols <- dim(img$original.rgb)[2]
  
  ##get x,y coordinates of each H,S,V pixel value for spatial centroid analysis
  surface.area <- nrows * ncols
  a <- matrix(1:surface.area, nrow = ncols, ncol = nrows)
  out <- which(a != 0, arr.ind = TRUE)
  
  ##refactor img as dataframe in long format
  rgb_version <- img$filtered.rgb.2d
  img <- as.data.frame(img$hsv.version)
  img <- cbind(img, rgb_version)
  img$id <- seq(1, nrow(img))
  img$x.coord <- out[,2]
  img$y.coord <- out[,1]
  img$nrows <- rep(nrows, nrow(img))
  img$ncols <- rep(ncols, nrow(img))
  
  ##remove extra `is.bg` column
  img <- img[,-8]
  
  return(img)
  
}