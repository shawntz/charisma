checkColorFaster <- function(img, parsed_conditional, color_name, scale = T, color_space = c("HSV", "RGB")) {
  
  ##check if valid color space
  color_space <- match.arg(color_space)
  
  ##convert color space to HSV if RGB
  if(color_space == "RGB") {
    color_triplet <- as.data.frame(t(rgb2hsv(img$h, img$s, img$v)))
  }
  
  ##rescale hsv color triplet to match scales used in parsed color mapping
  if(scale) {
    h <- round(img$h * 360)
    s <- round(img$s * 100)
    v <- round(img$v * 100)
  } else {
    h <- round(img$h)
    s <- round(img$s)
    v <- round(img$v)
  }
  
  ##TODO: catch missed color or >1 colors
  ##TODO: need a function to test someone's color definitions before running through Charisma pipeline
  if(eval(parse(text = parsed_conditional))) {
    is_color <- 1
  } else {
    is_color <- 0
  }
  
  return(is_color)
  
}