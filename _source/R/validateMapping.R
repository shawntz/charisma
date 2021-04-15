validateMapping <- function(mapping) {
  
  ##build validation slices
  invisible(capture.output(buildValidationSlices()))
  
  ##get validation slices
  dest <- "_source/data/validation_slices"
  slices <- getImgPaths(dest)
  slices <- gtools::mixedsort(sort(slices))
  
  ##validate along each slice
  missing <- list()
  total_n_missing <- 0
  for(ii in 1:length(slices)) {
    slice <- readImg(slices[ii], alpha = F)
    calls <- callColors(slice, mapping)
    
    n_missing <- nrow(slice) - sum(calls$total)
    total_n_missing <- total_n_missing + n_missing
    missing[[ii]] <- calls[calls$total == 0,]
  }
  
  if(total_n_missing > 0) {
    cat(paste0("\n    Missing color calls for ", total_n_missing, " pixels ==> Mapping validation failed.\nSee output for missing pixels.\n"))
    return(missing)
  } else {
    cat("\n    No missing color calls. Mapping successfully validated!\n\n")
    return(TRUE)
  }
  
}