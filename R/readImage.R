readImage <- function(path, lower = NULL, upper = NULL, alpha.channel = TRUE, mapping = charisma::color.map) {

  # Read in the file as either JPG or PNG (or, if neither, stop execution and
  # return error message)
  if (!is.character(path)) {
    stop("Provided filepath is not a string (must be of character type)")
  }

  # Get absolute filepath in case relative one was provided
  path <- normalizePath(path)

  # Get filetype so we know how to read it in; make lowercase so checking later
  # is easier
  filetype <- tolower(tail(strsplit(path, split = "[.]")[[1]], 1))

  if (filetype %in% "png") {
    img <- png::readPNG(path)
  } else if (filetype %in% c("jpg", "jpeg")) {
    img <- jpeg::readJPEG(path)
  } else {
    stop("Images must be either JPEG (.jpg or .jpeg) or PNG (.png) format")
  }

  # Once the file is read in, eliminate transparent background pixels

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

  # get 3D array for plotting
  # and flattened non-background RGB triplets
  filtered.img <- list(original.rgb = original.rgb,
                       filtered.rgb.2d = pix)

  # Initialize and name empty list for original image path,
  # 3D RGB array, 2D RGB+HSV array with background pixels
  # removed and labeled, matrix of hex values for raster,
  # and matrix of paired color names to hex values for raster
  end.list <- vector("list", length = 5)
  endList_names <- c("path", "original.rgb", "filtered.2d",
                     "hex.matrix", "cname.matrix")
  names(end.list) <- endList_names

  end.list[1:3] <- list(path,
                        filtered.img$original.rgb,
                        filtered.img$filtered.rgb.2d)
  #pix <- filtered.img$filtered.rgb.2d

  end.list$filtered.2d <- t(rgb2hsv(t(pix[,1:3]), maxColorValue = 1))

  # add modified background labels for sprite plot generation
  end.list$filtered.2d <- t(rgb2hsv(filtered.img$filtered.rgb.2d[,1],
                                            filtered.img$filtered.rgb.2d[,2],
                                            filtered.img$filtered.rgb.2d[,3],
                                            maxColorValue = 1))
  end.list$filtered.2d <- cbind(end.list$filtered.2d,
                                filtered.img$filtered.rgb.2d[,4])
  colnames(end.list$filtered.2d)[4] <- "is.bg"

  # save original image dimensions for later plotting
  nrows <- dim(end.list$original.rgb)[1]
  ncols <- dim(end.list$original.rgb)[2]

  # get x,y coordinates of each hsv pixel value for spatial centroid analysis
  surface.area <- nrows * ncols
  a <- matrix(1:surface.area, nrow = ncols, ncol = nrows)
  out <- which(a != 0, arr.ind = TRUE)

  # refactor filtered.hsv.rgb.2d dataframe necessary for charisma analyses
  rgb_coords <- filtered.img$filtered.rgb.2d
  refactored <- as.data.frame(end.list$filtered.2d)
  refactored <- cbind(refactored, rgb_coords)
  refactored$id <- seq(1, nrow(refactored))
  refactored$x.coord <- out[,2]
  refactored$y.coord <- out[,1]
  refactored$nrows <- rep(nrows, nrow(refactored))
  refactored$ncols <- rep(ncols, nrow(refactored))

  # remove extra `is.bg` column from cbind with rgb matrix
  refactored <- refactored[,-8]

  end.list$filtered.2d <- refactored

  # identify colors with charisma and append to end.list filtered.2d data
  end.list$filtered.2d <- identifyColors(end.list$filtered.2d, mapping)

  # get hex mapping matrix for fast raster sprite plotting
  raster_objects <- getRasterMatrices(end.list$filtered.2d, mapping)

  end.list$hex.matrix <- raster_objects$hex.matrix

  # get matched color mapping matrix for fast raster sprite plotting
  end.list$cname.matrix <- raster_objects$cname.matrix

  return(end.list)

}
