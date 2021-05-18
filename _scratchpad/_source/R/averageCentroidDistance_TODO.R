
## TODO: SHAWN:
  ## create verbose output with x,y calculated centroids 
  ## need to add in filter out is.bg column
  ## make white halo around color in sprite plot matrix using rounded centroid coordinate

getCentroidCoordinateX <- function(color, df) {
  #filter out background pixels
  df <- subset(df, is.bg == 0)  
  
  #filter by color
  df <- df[ df[[color]] == 1, ]
  
  #coordinates of the centroid
  meanx <- sum(df$x.coord) / nrow(df)
  
  return(ceiling(meanx))
}

getCentroidCoordinateY <- function(color, df) {
  #filter out background pixels
  df <- subset(df, is.bg == 0) 
  
  #filter by color
  df <- df[ df[[color]] == 1, ]
  
  #coordinates of the centroid
  meany <- sum(df$y.coord) / nrow(df)
  
  return(ceiling(meany))
}

getAverageCentroidDistance <- function(color, df) {
  #df <- read.csv(parsed_birds_csv)
  
  #filter out background pixels
  df <- subset(df, is.bg == 0) 
  
  #filter by color
  df <- df[ df[[color]] == 1, ]
  
  #x and y coordinates of the centroid 
  meanx <- sum(df$x.coord) / nrow(df)
  meany <- sum(df$y.coord) / nrow(df)
  
  #define centroid distance calculation for apply
  calculateCentroidDist <- function(df) {
    diffxsquared <- (df["x.coord"] - meanx) ^ 2
    diffysquared <- (df["y.coord"] - meany) ^ 2
    return(sqrt(diffxsquared + diffysquared))
  }
  
  #vector of all centroid distances returned from apply 
  centroidDist <- apply(df, 1, calculateCentroidDist)
  avgCentroidDistance <- sum(centroidDist) / nrow(df)
  
  return(log(avgCentroidDistance))
}
