##Inspiration from: https://stackoverflow.com/questions/29105175/find-neighbouring-elements-of-a-matrix-in-r
getSpatial <- function(img, color_name) {
  
  #img <- as.matrix(img)
  
  n_row <- nrow(img)
  n_col <- ncol(img)
  surface_area <- n_row * n_col
  
  ##one hot encode img colors to numbers
  img[img != color_name] <- 0
  img[img == color_name] <- 1
  
  print(dim(img))
  #img <- as.matrix(sapply(img, as.numeric))
  img <- as.matrix(apply(img, c(1,2), as.numeric))
  print(dim(img))
  
  neighbor_sums <- rbind(img[-1,],0) + rbind(0,img[-nrow(img),]) + cbind(img[,-1],0) + cbind(0,img[,-ncol(img)])
  print(neighbor_sums)
  #return(sum(neighbor_sums == max(neighbor_sums)))
  return(sum(neighbor_sums != 1 & neighbor_sums != 0) / surface_area)
  
  
  # find distances between row and column indexes
  # interested in values where the distance is one
  w <- which(img == img, arr.ind = TRUE)
  #d <- as.matrix(dist(w, "manhattan", diag = TRUE, upper = TRUE))
  d <- as.matrix(parDist(w, "manhattan", threads = 32))
  
  # extract neighboring values for each element
  # extract where max distance is one
  
  cl <- makeCluster(detectCores())
  neighbors <- parApply(cl, d, 1, function(i) img[i == 1])
  stopCluster()
  #neighbors <- apply(d, 1, function(i) img[i == 1])
  
  counter <- 0
  for(ii in 1:length(neighbors)) {
    if(length(unique(neighbors[[ii]])) == 1)
      if(unique(neighbors[[ii]]) == 1)
        counter <- counter + 1
  }
  
  return(counter / surface_area)
}