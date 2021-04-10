buildPlots <- function(img, mapping, threshold = .05) {
  
  ##make 1 row, 3 column plotting space
  par(mfrow=c(1,3))
  
  ##panel 1: source image
  plotImage(img)
  
  ##panel 2: sprite plot
  plotSprite(img, mapping)
  
  ##panel 3: color frequency histogram
  color_means <- getColorMeans(img, mapping)
  plotColors(color_means, mapping, threshold)
  
}