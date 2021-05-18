## Adapted and Modified from R::colordistance function `loadImage`
loadImg <- function(path, lower = c(0, 0.55, 0), upper = c(0.24, 1, 0.24), hsv = TRUE,
                    CIELab = FALSE, sample.size = 100000, ref.white = NULL, 
                    alpha.channel = TRUE, alpha.message = FALSE) {
  
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
  
  # Once the file is read in, eliminate pixels that fall between lower and upper
  # bounds (background)
  filtered.img <- removeBG(img,
                            lower = lower,
                            upper = upper,
                            quietly = alpha.message,
                            alpha.channel = alpha.channel)
  
  # Initialize and name empty list depending on flagged color spaces At minimum,
  # includes original image path, 3D RGB array, 2D RGB array with background
  # pixels removed 
  # Optional flags: HSV pixels, CIELab pixels
  end.list <- vector("list", length = (3 + sum(c(hsv, CIELab))))
  endList_names <- c("path", "original.rgb", "filtered.rgb.2d")
  if (hsv) {
    endList_names <- c(endList_names, "filtered.hsv.2d")
  }
  
  if (CIELab & !is.null(ref.white)) {
    endList_names <- c(endList_names, "filtered.lab.2d")
  }
  
  names(end.list) <- endList_names
  
  end.list[1:3] <- list(path,
                        filtered.img$original.rgb, 
                        filtered.img$filtered.rgb.2d)
  pix <- filtered.img$filtered.rgb.2d
  
  # Return a list with the path to the image, the original RGB image (3d array),
  # and the reshaped matrix with background pixels removed (for clustering
  # analysis)
  
  if (hsv) {
    end.list$filtered.hsv.2d <- t(rgb2hsv(t(pix[,1:3]), maxColorValue = 1))
  }
  
  if (CIELab) {
    ref.whites <- c("A", "B", "C", "E", "D50", "D55", "D65")
    
    # If user did not choose a reference white, skip conversion
    if (is.null(ref.white)) {
      
      warning("CIELab reference white not specified; skipping 
              CIELab color space conversion")
      
    } else if (!(ref.white %in% ref.whites)) {
      
      warning("Reference white is not a standard CIE illuminant 
              (see function documentation); skipping CIELab color 
              space conversion")
      
    } else {
      end.list$filtered.lab.2d <- colordistance::convertColorSpace(pix, 
                                                                   from = "sRGB", to = "Lab", 
                                                                   sample.size = sample.size, 
                                                                   to.ref.white = ref.white)
      end.list$ref.white <- ref.white
    }
  }
  
  ##add modified background labels for sprite plot generation
  end.list$hsv.version <- t(rgb2hsv(filtered.img$filtered.rgb.2d[,1], filtered.img$filtered.rgb.2d[,2], filtered.img$filtered.rgb.2d[,3], maxColorValue = 1))
  end.list$hsv.version <- cbind(end.list$hsv.version, end.list$filtered.rgb.2d[,4])
  colnames(end.list$hsv.version)[4] <- "is.bg"
  
  return(end.list)
  
}
