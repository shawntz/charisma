getCentroidCoordinate <- function(charisma_obj, color.name, dimension = c("x", "y"), scale = FALSE) {

  # check if valid dimension
  dimension <- tolower(dimension)
  dimension <- match.arg(dimension)
  if(is.null(dimension))
    stop("Invalid dimension specified.
         Please select from 'x' or 'y'.")

  # get color pixel data
  df <- charisma_obj$filtered.2d

  # filter out background pixels
  df <- subset(df, is.bg == 0)

  # filter by color
  df <- df[df[[color]] == 1,]

  # get x or y coordinates of the centroid
  if(dimension == "x")
    mean_coord <- sum(df$x.coord) / nrow(df)
  else if(dimension == "y")
    mean_coord <- sum(df$y.coord) / nrow(df)

  # scale for sprite plot overlay if requested
  if(scale)
    if(dimension == "x")
      mean_coord <- mean_coord / df$ncols
    else if(dimension == "y")
      mean_coord <- mean_coord / df$nrows

  return(mean_coord)

}
