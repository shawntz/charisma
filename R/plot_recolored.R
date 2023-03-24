plot_recolored <- function(img) {
  plot(as.raster(recolorize::recoloredImage(img)))
}
