charisma_to_jpeg <- function(charisma_obj, filename = "") {
  img <- recolorize::recoloredImage(charisma_obj)
  jpeg::writeJPEG(img, target = filename)
}
