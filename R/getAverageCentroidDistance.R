getAverageCentroidDistance <- function(charisma_obj, color.name) {

  # get color pixel data
  df <- charisma_obj$filtered.2d

  # filter out background pixels
  df <- subset(df, is.bg == 0)

  # filter by color
  df <- df[df[[color.name]] == 1,]

  # get x and y coordinates of the centroid
  meanx <- sum(df$x.coord) / nrow(df)
  meany <- sum(df$y.coord) / nrow(df)

  # define centroid distance calculation for apply
  calculateCentroidDist <- function(df) {
    diffxsquared <- (df["x.coord"] - meanx)^2
    diffysquared <- (df["y.coord"] - meany)^2
    return(sqrt(diffxsquared + diffysquared))
  }

  # vector of all centroid distances returned from apply
  centroidDists <- apply(df, 1, calculateCentroidDist)
  avgCentroidDistance <- sum(centroidDists) / nrow(df)

  return(avgCentroidDistance)

}
