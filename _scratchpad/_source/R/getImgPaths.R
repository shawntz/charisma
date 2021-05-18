## Copied from R::colordistance function `getImagePaths`
getImgPaths <- function(path) {
  
  # Make sure input is both a string and a valid folder path
  if (!is.character(path)) {
    
    stop("Provided filepath is not a string (character type)")
    
  } else if (!file.exists(path)) {
    
    stop("Folder does not exist")
    
  } else {
    
    im.dir <- normalizePath(dir(path, pattern = "^.*.(jpg|jpeg|png)$",
                                ignore.case = T, full.names = T))     
    # returns absolute filepaths of images in folder that end in either .jpg,
    # .jpeg, or .png (case-insensitive)
    
    # If no images were found but the folder path was valid, print message
    # instead of returning an empty vector; otherwise return vector of image
    # paths
    if (length(im.dir) == 0) {
      message(paste("No images of compatible format (JPG or PNG) in", path))
    } else {
      return(im.dir)
    }
  }
  
}