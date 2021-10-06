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
  color_names_string <- color_names
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
  print(head(color_names))

  # get silhouette version of color_names
  print("Getting hex lookup parsed...")
  silhouette_color_names <- ifelse(combos$is.bg == 10, "is.bg", as.character("black"))

  # get vector of hex value lookups
  hex_lookup <- getHexVector(mapping)
  hex_lookup <- data.frame(color = names(hex_lookup), hex = hex_lookup)

  # get vector of hex value lookups with alpha
  hex_lookup_transparent <- colorspace::adjust_transparency(getHexVector(mapping), alpha = .4)
  names(hex_lookup_transparent) <- hex_lookup$color
  hex_lookup_transparent <- data.frame(color = names(hex_lookup_transparent), hex = hex_lookup_transparent)
  print(hex_lookup_transparent)

  # convert raw color name strings into corresponding hex values
  #hex_values <- sapply(color_names, getMatchedHex, hex_lookup, simplify = TRUE)
  hex_values <- hex_lookup$hex[match(color_names, hex_lookup$color)]
  alpha_values <- hex_lookup_transparent$hex[match(color_names, hex_lookup_transparent$color)]
  silhouette_values <- hex_lookup$hex[match(silhouette_color_names, hex_lookup$color)]
  #alpha_values <- sapply(color_names, getMatchedHex, hex_lookup_transparent, simplify = TRUE)
  #silhouette_values <- sapply(silhouette_color_names, getMatchedHex, hex_lookup, simplify = TRUE)

  # get color cluster versions of each matrix for color-specific centroid plotting
  color_hex_matrices <- list()
  for(ii in 1:length(color_names_string)) {
    print(paste("Getting color matrix for:", color_names_string[ii]))
    temp_color_mat <- ifelse(combos$is.bg == 10, "is.bg",
                             ifelse(combos$color.name == color_names_string[ii], as.character(color_names_string[ii]),
                                    as.character("black")))
    #temp_hex_values <- sapply(temp_color_mat, getMatchedHex, hex_lookup, simplify = T)
    temp_hex_values <- hex_lookup_transparent$hex[match(temp_color_mat, hex_lookup_transparent$color)]
    dim(temp_hex_values) <- c(charisma_obj$nrows[1], charisma_obj$ncols[1])
    color_hex_matrices[[ii]] <- temp_hex_values
  }

  names(color_hex_matrices) <- color_names_string

  # make matrices for raster plotting
  dim(color_names) <- c(charisma_obj$nrows[1], charisma_obj$ncols[1])
  dim(hex_values) <- c(charisma_obj$nrows[1], charisma_obj$ncols[1])
  dim(alpha_values) <- c(charisma_obj$nrows[1], charisma_obj$ncols[1])
  dim(silhouette_values) <- c(charisma_obj$nrows[1], charisma_obj$ncols[1])

  end.list <- vector("list", length = 5)
  endList_names <- c("hex.matrix", "cname.matrix", "alpha.matrix", "silhouette.matrix", "color.clusters")
  names(end.list) <- endList_names

  end.list$hex.matrix <- hex_values
  end.list$cname.matrix <- color_names
  end.list$silhouette.matrix <- silhouette_values
  end.list$alpha.matrix <- alpha_values
  end.list$color.clusters <- color_hex_matrices

  return(end.list)

}
