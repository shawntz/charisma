buildPlots <- function(img, mapping, freq_threshold = .05, spatial_threshold = .01) {
  
  ##make 1 row, 3 column plotting space
  par(mfrow=c(1,4))
  
  ##panel 1: source image
  plotImage(img)
  
  ##panel 2: sprite plot
  plotSprite(img, mapping)
  
  ##panel 3: color frequency histogram
  color_means <- getColorMeans(img, mapping)
  plotColors(color_means, mapping, type = "freq", freq_threshold)
  
  ##panel 4: color spatial density histogram
  color_densities <- getSpatialDensityScores(img, mapping)
  plotColors(color_densities, mapping, type = "spatial", spatial_threshold)
  
}