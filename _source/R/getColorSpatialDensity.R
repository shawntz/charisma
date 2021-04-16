##Inspiration from: https://stackoverflow.com/questions/29105175/find-neighbouring-elements-of-a-matrix-in-r
getColorSpatialDensity <- function(img, color_name) {
  
  n.row <- nrow(img)
  n.col <- ncol(img)
  surface.area <- n.row * n.col
  print(surface.area)
  addresses <- expand.grid(x = 1:n.row, y = 1:n.col)
  
  ##returns a list with neighbors
  neighbors <- apply(addresses, 1, getNeighbors, img)
  
  ##get linear list of color names
  all_colors <- as.vector(t(t(img)))
  
  counter <- 0
  for(ii in 1:length(neighbors)) {
    if(length(unique(neighbors[[ii]])) == 1)
      if(unique(neighbors[[ii]]) == color_name)
        counter <- counter + 1
  }
  
  return(counter / surface.area)
  
}