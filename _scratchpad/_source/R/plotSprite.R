plotSprite <- function(img, mapping) {
  
  # If a filepath is passed, load the image from that filepath
  if (is.character(img)) {
    if (file.exists(img)) {
      # Read in the file as either JPG or PNG (or, if neither, stop execution
      # and return error message)
      img <- loadImage(img)
    } else {
      stop("File does not exist")
    }
  }
  
  ##get all color names from mapping
  colors <- getMappedColors(mapping)
  
  hex_values <- getHexValuesMatrix(img, mapping)
  
  ##modify hex to have centroid halos
  x_coords <- sapply(colors, getCentroidCoordinateX, img, simplify = T)
  y_coords <- sapply(colors, getCentroidCoordinateY, img, simplify = T)
  centroid_distances <- sapply(colors, getAverageCentroidDistance, img, simplify = T)
  
  print(x_coords)
  print(y_coords)
  print(centroid_distances)
  
  halo_color <- "#FF00D9"
  
  ##make hex vector
  hex_vector <- getHexVector(mapping)
  
  for(ii in 1:length(centroid_distances)) {
    for(jj in 1:100) {
      for(kk in 1:15) {
        ##up
        hex_values[x_coords[ii]+kk, y_coords[ii]+jj+kk] <- hex_vector[ii]
        
        ##down
        hex_values[x_coords[ii]+kk, y_coords[ii]-jj+kk] <- hex_vector[ii]
        
        ##left
        hex_values[x_coords[ii]-jj+kk, y_coords[ii]+kk] <- hex_vector[ii]
        
        ##right
        hex_values[x_coords[ii]+jj+kk, y_coords[ii]+kk] <- hex_vector[ii]
      }
    }
  }
  
  asp <- img$nrows[1] / img$ncols[1]
  
  plot(0:1, 0:1, type = "n", axes = FALSE,
       asp = asp, main = "Sprite Plot", xlab = "", ylab = "")
  
  graphics::rasterImage(hex_values, 0, 0, 1, 1)
  
}
