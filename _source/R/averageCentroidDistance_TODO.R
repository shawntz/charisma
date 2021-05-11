library(tidyverse)
​
#pass in csv with x and y coordinates and the specified color as string 
# example: averageCentroidDistance("demo_bird_with_xy_coords.csv", "purple")
#function is slow reading in csv each call. Could change it to read it in prior and then use the dataframe inside
#color would be the only argument
​
## TODO: SHAWN:
  ## create verbose output with x,y calculated centroids 
  ## need to add in filter out is.bg column
  ## make white halo around color in sprite plot matrix using rounded centroid coordinate

averageCentroidDistance <- function(df, color) {
  #df <- read.csv(parsed_birds_csv)
  
  #filter by color
  df <- df[ df[[color]] == 1, ]
  
  #x and y coordinates of the centroid 
  meanx <- sum(df$x.coord) / nrow(df)
  meany <- sum(df$y.coord) / nrow(df)
  
  print(paste0(meanx, ", ", meany))
  
  #define centroid distance calculation for apply
  calculateCentroidDist <- function(df) {
    diffxsquared <- (df["x.coord"] - meanx) ^ 2
    diffysquared <- (df["y.coord"] - meany) ^ 2
    return(sqrt(diffxsquared + diffysquared))
  }
  
  #vector of all centroid distances returned from apply 
  centroidDist <- apply(df, 1, calculateCentroidDist)
  avgCentroidDistance <- sum(centroidDist) / nrow(df)
  
  return(avgCentroidDistance)
}
