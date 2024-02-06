# modified from recolorize
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
charisma_to_img <- function(charisma_obj, out_type = c('jpg', 'jpeg', 'png'), bg_color = "white", render_method = c('array', 'raster'), render_with_threshold = FALSE, filename = "") {
  out_type <- tolower(out_type)
  out_type <- match.arg(out_type)

  render_method <- tolower(render_method)
  render_method <- match.arg(render_method)

  # if user specifies a transparent background, set a placeholder color
  #  before adding the alpha layer
  if (is.null(bg_color)) {
    is_transparent <- TRUE
    bg_color <- "white"
  } else {
    is_transparent <- FALSE
  }

  # make two copies of matrix as a cimg object:
  index_cimg <- imager::as.cimg(charisma_obj$pixel_assignments)
  final_cimg <- index_cimg

  # color the background in
  # you won't see this unless you remove the alpha layer:
  final_cimg <- imager::colorise(final_cimg,
                                 index_cimg == 0,
                                 bg_color)

  # color in every color center:
  for (i in 1:nrow(charisma_obj$centers)) {
    if (render_with_threshold) {
      hex_values <- charisma_obj$color_mask_LUT_filtered$hex
    } else {
      hex_values <- charisma_obj$color_mask_LUT$hex
    }
    final_cimg <- imager::colorise(final_cimg,
                                   index_cimg == i,
                                   hex_values[i+1])
  }

  # convert to a regular array:
  as_array <- cimg_to_array(final_cimg)

  # and add an alpha channel:
  if (is_transparent) {
    alpha_layer <- charisma_obj$pixel_assignments
    alpha_layer[which(alpha_layer > 0)] <- 1
    as_array <- abind::abind(as_array,
                             alpha_layer,
                             along = 3)
  }

  img <- as_array

  if (render_method == "raster") {
    img <- grDevices::as.raster(charisma_obj$color_mask)
  }

  if (out_type %in% c('jpg', 'jpeg')) {
    jpeg::writeJPEG(img, target = filename, quality = 1)
  }

  if (out_type == 'png') {
    png::writePNG(img, target = filename)
  }
}

# from recolorize
cimg_to_array <- function(x) {
  img <- as.numeric(x)
  dim(img) <- dim(x)[c(1, 2, 4)]
  if (dim(img)[3] == 1) {
    dim(img) <- dim(img)[1:2]
  }
  return(img)
}
