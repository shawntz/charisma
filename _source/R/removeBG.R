## Adapted and Modified from R::colordistance function `removeBackground`
removeBG <- function(img,
                      lower = NULL, upper = NULL,
                      quietly = FALSE,
                      alpha.channel = TRUE) {

  # assume no background masking to start
  idx <- NULL
  
  # and store RGB channels
  original.rgb <- img[ , , 1:3]
  
  # if there's transparency, use that for background indexing
  # set transparent pixels to white
  if (dim(img)[3] == 4 & alpha.channel == TRUE) {
    
    if (min(img[ , , 4]) < 1) {
      
      if (!quietly) {
        message("Using PNG transparency (alpha channel) as background mask")
      }
      
      # index background pixels based on opacity
      idx <- which(img[ , , 4] != 1)
      
      # make transparent pixels white for plotting
      for (i in 1:3) {
        channel <- original.rgb[ , , i]
        channel[idx] <- 1
        original.rgb[ , , i] <- channel
      }
    } else {
      
      warning("No transparent pixels in image")
      
    }
    
  }
  
  # if there was no transparency, try color
  if (is.null(idx)) {
    
    # if upper and lower are numeric:
    # index values inside of upper and lower bounds
    if (is.numeric(upper) & is.numeric(lower)) {
      idx <- which((lower[1] <= img[, , 1] &
                      img[, , 1] <= upper[1]) &
                     (lower[2] <= img[, , 2] &
                        img[, , 2] <= upper[2]) &
                     (lower[3] <= img[, , 3] &
                        img[, , 3] <= upper[3]))
    }
    
  }
  
  # make filtered.rgb.2d: all the non-indexed pixels from img
  pix <- original.rgb
  dim(pix) <- c(dim(img)[1] * dim(img)[2], 3)
  
  ## START - NEW FUNCTION ##
  pix <- cbind(pix, rep(0, nrow(pix)))
  colnames(pix) <- c("r", "g", "b", "is.bg")
  if (length(idx) != 0) {
    pix[idx,4] <- 1
  }
  ## END - NEW FUNCTION ##
  
  # return 3D array for plotting
  # and flattened non-background RGB triplets
  return(list(original.rgb = original.rgb,
              filtered.rgb.2d = pix))
  
}