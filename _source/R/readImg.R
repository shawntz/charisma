readImg <- function(path) {
  
  img <- loadImg(path, lower = NULL, upper = NULL, alpha.channel = T)
  img <- as.data.frame(img$hsv.version)
  img$id <- seq(1, nrow(img))
  
  return(img)
  
}