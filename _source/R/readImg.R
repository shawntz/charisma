readImg <- function(path, alpha = T) {
  
  img <- loadImg(path, lower = NULL, upper = NULL, alpha.channel = alpha)
  img <- as.data.frame(img$hsv.version)
  img$id <- seq(1, nrow(img))
  
  return(img)
  
}