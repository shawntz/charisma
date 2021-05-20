#' Add together two numbers
#'
#' @param x A number
#' @param y A number
#' @return The sum of \code{x} and \code{y}
#' @examples
#' add(1, 1)
#' add(10, 1)
#'
#' @export
getRasterMatrices <- function(charisma_obj, mapping = color.map) {

  # get all color names from color mapping
  color_names <- getMappedColors(mapping)
  num_colors <- length(color_names)

  # extract charisma color call columns from charisma_obj
  calls <- charisma_obj[,c(4,8:(13 + num_colors))]
  calls <- calls[,c(1,7:(6 + num_colors))]

  # modify values for easy sorting of background vs. color called pixels
  # multiply all values by -1 so that non-background pixels are the smallest values
  calls <- calls * -1
  # multiply is.bg column by -10 so that background pixel labels are the largest values
  calls$is.bg <- calls$is.bg * -10
  # get color pixels
  color_pixels <- apply(calls, 1, which.min)
  # get background pixels
  bg_pixels <- apply(calls, 1, which.max)

  # combine data frames with background pixel and color location labels
  combos <- as.data.frame(cbind(is.bg = calls[,1], color.loc = color_pixels))
  combos <- cbind(combos, color.name = colnames(calls)[combos[,2]])

  # get raw color name character strings based on combos to then convert to hex values in matrix
  color_names <- ifelse(combos$is.bg == 10, "is.bg", as.character(combos$color.name))

  # get vector of hex value lookups
  hex_lookup <- getHexVector(mapping)

  # convert raw color name strings into corresponding hex values
  hex_values <- sapply(color_names, getMatchedHex, hex_lookup, simplify = TRUE)

  # make matrices for raster plotting
  dim(color_names) <- c(charisma_obj$nrows[1], charisma_obj$ncols[1])
  dim(hex_values) <- c(charisma_obj$nrows[1], charisma_obj$ncols[1])

  end.list <- vector("list", length = 2)
  endList_names <- c("hex.matrix", "cname.matrix")
  names(end.list) <- endList_names

  end.list$hex.matrix <- hex_values
  end.list$cname.matrix <- color_names

  return(end.list)

}
