getSpatialDensity <- function(charisma_obj, color_name) {

  img <- charisma_obj$cname.matrix

  # save a copy of color name matrix before manipulating
  img_string <- img

  # one hot encode img colors to numbers
  img[img != color_name] <- 0
  img[img == color_name] <- 1

  # convert matrix of characters to matrix of numerics
  img <- as.matrix(apply(img, c(1,2), as.numeric))

  # compute sums of neighboring cells using a Manhattan algorithm
  # i.e., no diagonal cells are counted, just up, down, left, right
  # thus, the maximum number of neighbors a cell can have is 4
  # adapted from: https://stackoverflow.com/questions/22572901/for-each-element-in-a-matrix-find-the-sum-of-all-of-its-neighbors
  neighbor_sums <- rbind(img[-1,],0) + rbind(0,img[-nrow(img),]) + cbind(img[,-1],0) + cbind(0,img[,-ncol(img)])

  # remove cell counts for colors that have a matching neighbor but are not the color of interest
  neighbor_sums[which(img_string != color_name)] <- 0

  # find the number of pixels with that specific color present in the matrix
  num_colors <- sum(img_string == color_name)

  # get the square root of the number of colors to build the ideal square matrix
  # of optimal "patchiness" such that the density of the patch is maximized
  num_colors_sq <- sqrt(num_colors)

  ideal_img <- matrix(1, nrow = num_colors_sq, ncol = num_colors_sq)
  ideal_img_original_ncol <- ncol(ideal_img)
  ideal_img_original_nrow <- nrow(ideal_img) + 1

  square_area <- nrow(ideal_img) * ncol(ideal_img)
  new_row_size <- num_colors - square_area
  ideal_img <- rbind(ideal_img, rep(0, ideal_img_original_ncol))
  ideal_img <- cbind(ideal_img, rep(0, ideal_img_original_nrow))

  row_fill <- new_row_size
  col_fill <- 0
  if(row_fill > nrow(ideal_img)) {
    col_fill <- row_fill - nrow(ideal_img)
    row_fill <- 4
  }

  # get Manhattan neighbor score on ideal square patch
  ideal_neighbor_sums <- rbind(ideal_img[-1,],0) + rbind(0,ideal_img[-nrow(ideal_img),]) + cbind(ideal_img[,-1],0) + cbind(0,ideal_img[,-ncol(ideal_img)])

  return(sum(neighbor_sums) / sum(ideal_neighbor_sums))

}
