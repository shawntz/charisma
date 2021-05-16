
getSpatialDensity <- function(img, color_name, verbose = FALSE) {
  
  ##get size information about img (vector of color names [strings])
  n_row <- nrow(img)
  n_col <- ncol(img)
  surface_area <- n_row * n_col
  
  img_string <- img
  
  ##one hot encode img colors to numbers
  img[img != color_name] <- 0
  img[img == color_name] <- 1
  
  ##convert matrix of characters to matrix of numerics
  img <- as.matrix(apply(img, c(1,2), as.numeric))
  
  ##compute sums of neighboring cells (using Manhattan Distance; i.e., no diagonal cells are counted)
  ##adapted from: https://stackoverflow.com/questions/22572901/for-each-element-in-a-matrix-find-the-sum-of-all-of-its-neighbors
  neighbor_sums <- rbind(img[-1,],0) + rbind(0,img[-nrow(img),]) + cbind(img[,-1],0) + cbind(0,img[,-ncol(img)])
  #print(neighbor_sums)
  neighbor_sums[which(img_string != color_name)] <- 0
  print(img_string)
  print(neighbor_sums)
  
  num_colors <- sum(img_string == color_name)
  print(num_colors)
  num_colors2 <- sqrt(num_colors)
  print(num_colors2)
  ideal_img <- matrix(1, nrow = num_colors2, ncol = num_colors2)
  ideal_img_original_ncol <- ncol(ideal_img)
  ideal_img_original_nrow <- nrow(ideal_img) + 1
  square_area <- nrow(ideal_img) * ncol(ideal_img)
  new_row_size <- num_colors - square_area
  ideal_img <- rbind(ideal_img, rep(0, ideal_img_original_ncol))
  ideal_img <- cbind(ideal_img, rep(0, ideal_img_original_nrow))
  
  #calculate the number of colors in the remainder. Allocate to row then column 
  row_fill = new_row_size 
  col_fill = 0
  img_size <- nrow(ideal_img)
  if(row_fill > img_size - 1) {
    col_fill = row_fill - img_size + 1
    row_fill = img_size - 1
  }
  #create new row and column to set into image
  new_row <- c(rep(1, row_fill), rep(0, img_size - row_fill))
  new_col <- c(rep(1, col_fill), rep(0, img_size - col_fill))
  #set ideal_image 
  ideal_img[img_size, ] = new_row
  ideal_img[, img_size] = new_col
  
  #ideal_img <- rbind(ideal_img, c(rep(1, new_row_size), rep(0, ncol(ideal_img) - new_row_size))) ## find the largest possible patch square & and in remaining difference of square area
  print(ideal_img)
  ideal_neighbor_sums <- rbind(ideal_img[-1,],0) + rbind(0,ideal_img[-nrow(ideal_img),]) + cbind(ideal_img[,-1],0) + cbind(0,ideal_img[,-ncol(ideal_img)])
  print(ideal_neighbor_sums)
  print(paste("sum real img: ", sum(neighbor_sums)))
  print(paste("sum ideal img: ", sum(ideal_neighbor_sums)))
  print(sum(neighbor_sums) / sum(ideal_neighbor_sums))
  return(sum(neighbor_sums) / sum(ideal_neighbor_sums))
}

