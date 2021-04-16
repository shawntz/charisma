getSpatialDensity <- function(img, color_name) {
  
  ##get size information about img (vector of color names [strings])
  n_row <- nrow(img)
  n_col <- ncol(img)
  surface_area <- n_row * n_col
  
  ##one hot encode img colors to numbers
  img[img != color_name] <- 0
  img[img == color_name] <- 1
  
  ##convert matrix of characters to matrix of numerics
  img <- as.matrix(apply(img, c(1,2), as.numeric))
  
  ##compute sums of neighboring cells (using Manhattan Distance; i.e., no diagonal cells are counted)
  ##adapted from: https://stackoverflow.com/questions/22572901/for-each-element-in-a-matrix-find-the-sum-of-all-of-its-neighbors
  neighbor_sums <- rbind(img[-1,],0) + rbind(0,img[-nrow(img),]) + cbind(img[,-1],0) + cbind(0,img[,-ncol(img)])
  
  ##return spatial density score:
  ##(i.e., number of cells with a neighbor score > 1 / surface_area of image matrix)
  return(sum(neighbor_sums != 1 & neighbor_sums != 0) / surface_area)
  
}