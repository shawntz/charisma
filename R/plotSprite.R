plotSprite <- function(charisma_obj, mapping = charisma::color.map) {

  img <- charisma_obj$filtered.2d

  hex_values <- charisma_obj$hex.matrix

  asp <- img$nrows[1] / img$ncols[1]

  plot(0:1, 0:1, type = "n", axes = FALSE,
       asp = asp, main = "Sprite Plot", xlab = "", ylab = "")

  graphics::rasterImage(hex_values, 0, 0, 1, 1)

}
