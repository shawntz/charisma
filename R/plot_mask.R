plot_mask <- function(img) {
  asp <- dim(img$original_img)[1] / dim(img$original_img)[2]
  plot(0:1, 0:1, type = "n", axes = FALSE, asp = asp, main = "masked img", xlab = "", ylab = "")
  graphics::rasterImage(img$color_mask, 0, 0, 1, 1)
}
