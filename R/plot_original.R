plot_original <- function(charisma_obj) {
  asp <- dim(charisma_obj$original_img)[1] / dim(charisma_obj$original_img)[2]
  plot(0:1, 0:1, type = "n", axes = FALSE, asp = asp, main = "original image", xlab = "", ylab = "")
  graphics::rasterImage(charisma_obj$original_img, 0, 0, 1, 1)
  # plot(charisma_obj$original_img, main = "original image", asp = asp / 2)
}
