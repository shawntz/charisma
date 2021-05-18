callColorsPipeline <- function(imgs, mapping) {
  
  ##create empty list to hold color calls in
  calls <- list()
  
  ##run for all imgs in path
  for(i in 1:length(imgs)) {
    img <- readImg(imgs[i])
    calls[[i]] <- callColors(img, mapping)
  }
  names(calls) <- basename(imgs)
  
  return(calls)
  
}