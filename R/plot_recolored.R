plot_recolored <- function(img) {
  asp <- dim(img$original_img)[1] / dim(img$original_img)[2]
  plot(0:1, 0:1, type = "n", axes = FALSE, asp = asp, main = "recolored img", xlab = "", ylab = "")
  graphics::rasterImage(recolorize::recoloredImage(img), 0, 0, 1, 1)
  # graphics::plot(as.raster(recolorize::recoloredImage(img)), main = "recolored image for charisma", asp = asp / 2 )
}
