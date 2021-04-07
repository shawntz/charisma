validateMapping <- function(mapping) {
  
  ##build validation slices
  invisible(capture.output(buildValidationSlices()))
  
  ##get validation slices
  dest <- "_source/data/validation_slices"
  slices <- getImgPaths(dest)
  slices <- gtools::mixedsort(sort(slices))
  
  ##validate along each slice
  missing <- list()
  for(ii in 1:length(slices)) {
    slice <- readImg(slices[ii], alpha = F)
    calls <- callColors(slice, mapping)
    n_missing <- nrow(slice) - sum(calls$total)
    
    if(n_missing > 0) {
      missing[[ii]] <- calls[calls$total == 0,]
      cat("Missing color calls. Mapping validation failed. See output for missing pixels.\n")
      return(missing)
    } else {
      cat("No missing color calls. Mapping successfully validated!\n")
      return(TRUE)
    }
  }
  
}