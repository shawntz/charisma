plotDiagnostic <- function(charisma_obj, mapping = charisma::color.map,
                           freq.threshold = .05, spatial.threshold = .01) {


  # for resetting
  user_par <- graphics::par(no.readonly = TRUE)

  # make 1 row, 4 column plotting space
  par(mfrow=c(1,4))

  # panel 1: source image
  plotImage(charisma_obj, multi.plot = TRUE)

  # panel 2: sprite plot
  plotSprite(charisma_obj, multi.plot = TRUE)

  # panel 3: color frequency histogram
  plotColors(charisma_obj, type = "freq", threshold = freq.threshold, multi.plot = TRUE)

  # panel 4: color spatial density scores
  plotColors(charisma_obj, type = "spatial", threshold = spatial.threshold, multi.plot = TRUE)

  # reset parameters
  graphics::par(user_par)

}
