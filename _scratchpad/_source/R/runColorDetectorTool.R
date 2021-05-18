runColorDetectorTool <- function(img) {
  
  r <- graphics::rasterImage(img, 0, 0, 1, 1)
  
  raster::click(r, id = TRUE, xy = TRUE, cell = TRUE)
  
}
