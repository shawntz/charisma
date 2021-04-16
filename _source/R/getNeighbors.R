##From: https://stackoverflow.com/questions/29105175/find-neighbouring-elements-of-a-matrix-in-r
getNeighbors <- function(address, mat) {
  
  ##relative addresses
  z <- rbind(c(-1,0,1,-1,1,-1,0,1), c(-1,-1,-1,0,0,1,1,1))
  
  ##convert to absolute addresses 
  z2 <- t(z + unlist(address))
  
  ##choose those with indices within mat 
  b.good <- rowSums(z2 > 0) == 2 & z2[,1] <= nrow(mat) & z2[,2] <= ncol(mat)
  mat[z2[b.good,]]
  
}