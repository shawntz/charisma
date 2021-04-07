validationTwo <- function(mapping) {
  v <- seq(from = 0, to = 1, length.out = 360)
  h <- rep(0)
}

validateMapping <- function(mapping) {
  
  ##generate color space data frame
  v <- seq(from = 0, to = 100, by = 1)
  h <- rep(0:360, each = length(v))
  s <- rep(0:100, each = length(v))
  
  s <- rep(s, length(h))
  v <- rep(v, length(h))
  
  ##combine into color space data frame
  cspace <- data.frame(h, s, v)
  
  ##clear individual components from memory
  rm(h)
  rm(s)
  rm(v)
  
  ##hack data frame size to avoid vector memory issues
  missing <- list()
  chunk_size_static <- 500000
  chunk_size_current <- chunk_size_static
  start <- 1
  end <- nrow(cspace)
  pb <- progress::progress_bar$new(total = end, format = " [:bar] :percent eta: :eta", clear = F)
  for(ii in start:chunk_size_current) {
    subset <- cspace[start:chunk_size_current,]
    calls <- callColors(subset, mapping, scale = F)
    
    n_missing <- nrow(subset) - sum(calls$total)
    if(n_missing > 0) {
      missing[[ii]] <- calls[calls$total == 0,]
    } else {
      missing[[ii]] <- NA
    }
    
    if(chunk_size_current < end) {
      start <- chunk_size_current + 1
      chunk_size_current <- start + chunk_size_static
    } else {
      chunk_size_current <- end
    }
    pb$tick()
  }
  
  return(missing)
  
  ##validate space
  #calls <- callColors(cspace, mapping)
  
  #n_missing <- nrow(cspace) - sum(calls$total)
  #if(n_missing > 0) {
  #  missing <- calls[calls$total == 0,]
  #  return(missing)
  #} else {
  #  cat("No missing color calls. Mapping successfully validated!\n")
  #  return(TRUE)
  #}
  
}
