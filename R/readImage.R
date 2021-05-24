#' Import image and generate discrete color classification(s)
#'
#' Imports a single image and returns a list with the absolute path to the original image,
#' original image as a 3D array, a 2D matrix with background pixels identified,
#' HSV and RGB coordinates, the original dimensions of the 3D image, binary color classifications,
#' total number of discrete colors (k), a matrix of hex values for raster plotting of classified image,
#' a matrix of corresponding discrete color names for spatial color pattern analyses,
#' the relative proportions of each color in the image (not including background pixels),
#' and the spatial density scores for each color classified in the image.
#'
#' @param path Path to image (a string).
#' @param resize Fraction by which to reduce image size. Important for speed.
#' Inherited from \code{\link{[recolorize::readImage]}}.
#' @param lower RGB or HSV triplet specifying the lower bounds for background pixels.
#'   Default upper and lower bounds are set to \code{NULL} given that no background
#'   filtering is needed for images with transparent backgrounds
#'   (the default assumed image type with file extension ".png").
#'   Inherited from \code{\link{[colordistance::loadImage]}}.
#' @param upper RGB or HSV triplet specifying the upper bounds for background pixels.
#'   Default upper and lower bounds are set to \code{NULL} given that no background
#'   filtering is needed for images with transparent backgrounds
#'   (the default assumed image type with file extension ".png"). Determining these
#'   bounds may take some trial and error, but the following bounds may work for certain
#'   common background colors: \itemize{ \item Black: lower=c(0, 0, 0);
#'   upper=c(0.1, 0.1, 0.1) \item White: lower=c(0.8, 0.8, 0.8); upper=c(1, 1, 1)
#'   \item Green: lower=c(0, 0.55, 0); upper=c(0.24, 1, 0.24) \item Blue:
#'   lower=c(0, 0, 0.55); upper=c(0.24, 0.24, 1) } If no background filtering is
#'   needed, set bounds to some non-numeric value (\code{NULL}, \code{FALSE},
#'   \code{"off"}, etc); any non-numeric value is interpreted as \code{NULL}.
#'   Inherited from \code{\link{[colordistance::loadImage]}}.
#' @param alpha.channel Logical. If available, should alpha channel transparency be
#'   used to mask background?
#' @param mapping Data Frame. Color mapping definitions with min and max ranges for
#'   H, S, and V. Provided by default. See \code{\link{loadCustomColorMapping}} for more details
#'   regarding loading in a CSV file with custom color definitions.
#'
#' @return A list with original image ($original.rgb, 3D array), 2D matrix with background pixels identified
#'   ($filtered.2d), the path to the original source image ($path), matrix of hex values for raster plotting
#'   of classified image ($hex.matrix), a matrix of corresponding discrete color names for
#'   spatial color pattern analyses ($cname.matrix), the relative proportions of each color in the image
#'   (not including background pixels) ($color.frequencies), and the spatial density scores for each color
#'   classified in the image ($spatial.density).
#'
#' @note The 3D array is useful for displaying the original image, the 2D arrays (HSV and RGB) are treated as
#'   rows of data for discrete color classification in the rest of the package, and the matrix of hex values
#'   is used for creating a rasterized graphic (sprite plot) to see a regenerated image displaying which colors
#'   were identified via discrete color classification (these colors are defined in the `default.hex` column
#'   of \code{charisma::color.map} and/or a custom defined color mapping built with \code{\link{loadCustomColorMapping}}).
#'
#' @examples
#' demoImg <- charisma::readImage(system.file("extdata",
#' "Tangara/Tangara_transparent/Tangara_01.png", package = "charisma"))
#'
#' demoImgWhiteBG <- charisma::readImage(system.file("extdata",
#' "Tangara/Tangara_whitebg/Tangara_01.jpeg", package = "charisma"),
#' lower = c(0.8, 0.8, 0.8), upper = c(1, 1, 1), alpha.channel = FALSE)
#'
#' @details The upper and lower limits for background pixel elimination set the
#' inclusive bounds for which pixels should be ignored for the 2D arrays; while
#' all background pixels are ideally a single color, images photographed against
#' "uniform" backgrounds often contain some variation, and even segmentation
#' done with photo editing software will produce some variance as a result of
#' image compression.
#'
#' The upper and lower bounds represent cutoffs: any pixel for which the first
#' channel falls between the first upper and lower bounds, the second channel
#' falls between the second upper and lower bounds, and the third channel falls
#' between the third upper and lower bounds, will be ignored. For example, if
#' you have a green pixel with RGB channel values [0.1, 0.9, 0.2], and your
#' upper and lower bounds were (0.2, 1, 0.2) and (0, 0.6, 0) respectively, the
#' pixel would be ignored because 0 <= 0.1 <= 0.2, 0.6 <= 0.9 <= 1, and 0 <= 0.2
#' <= 0.2. But a pixel with the RGB channel values [0.3, 0.9, 0.2] would not be
#' considered background because 0.3 >= 0.2.
#'
#' @source Many of the pixel filtering functions, documentation, and descriptions here
#' were either copied directly or modified/adapted from \code{\link{[colordistance::loadImage]}}.
#'
#' \link{https://cran.r-project.org/web/packages/colordistance/}
#'
#' @export
readImage <- function(path, resize = NULL, lower = NULL, upper = NULL, alpha.channel = TRUE, mapping = color.map) {

  # Read in the file as either JPG or PNG (or, if neither, stop execution and
  # return error message)
  if (!is.character(path)) {
    stop("Provided filepath is not a string (must be of character type)")
  }

  # Get absolute filepath in case relative one was provided
  path <- normalizePath(path)

  # Read in image
  img_ext <- tolower(tools::file_ext(path))
  if (img_ext %in% c("jpeg", "jpg", "png", "bmp")) {
    img <- imager::load.image(path)
  } else {
    stop("Image must be either JPG, PNG, or BMP")
  }

  # Resize image if specified
  if(!is.null(resize)) {
    img <- imager::imresize(img, scale = resize, interpolation = 6)
  }

  # Undo rotation by imager::load.image
  img <- imager::imrotate(img, -90)

  # drop depth channel
  temp <- array(dim = dim(img)[c(1:2, 4)])
  temp <- img[ , , 1, ]

  # flip the image
  temp[ , , ] <- apply(temp, 3, function(mat) mat[ , ncol(mat):1, drop=FALSE])
  img <- temp
  rm(temp)

  # Once the file is read in, eliminate transparent background pixels
  # assume no background masking to start
  idx <- NULL

  # and store RGB channels
  original.rgb <- img[ , , 1:3]

  # if there's transparency, use that for background indexing
  # set transparent pixels to white
  if (dim(img)[3] == 4 & alpha.channel == TRUE) {

    if (min(img[ , , 4]) < 1) {


      message("Using PNG transparency (alpha channel) as background mask.")


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

  message("This may take a moment for large images (consider resizing image with `resize` paramemter)... Please wait...")

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
  end.list <- vector("list", length = 12)
  endList_names <- c("path", "original.rgb", "filtered.2d",
                     "hex.matrix", "cname.matrix", "alpha.matrix",
                     "silhouette.matrix", "color.frequencies", "spatial.density",
                     "centroid.dists", "centroid.x", "centroid.y")
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

  # get semi-transparent matched color mapping matrix for fast raster sprite plotting with centroids
  end.list$alpha.matrix <- raster_objects$alpha.matrix

  # get silhouette matrix for fast raster sprite plotting with centroids
  end.list$silhouette.matrix <- raster_objects$silhouette.matrix

  # get color means for fast color plotting
  end.list$color.frequencies <- getColorMeans(end.list)

  # get spatial density scores for fast color plotting
  end.list$spatial.density <- getSpatialDensityScores(end.list)

  # get centroid distances for fast color plotting
  end.list$centroid.dists <- getCentroidDistances(end.list)

  # get centroid x-coordinates per color
  end.list$centroid.x <- getCentroidCoordinates(end.list, "x", TRUE)

  # get centroid y-coordinates per color
  end.list$centroid.y <- getCentroidCoordinates(end.list, "y", TRUE)

  # set class
  class(end.list) <- "charisma"

  return(end.list)

}
