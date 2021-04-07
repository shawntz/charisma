getColor <- function(color_triplet, parsed_conditional, scale = T, color_space = c("HSV", "RGB")) {
  
  ##check if valid color space
  color_space <- match.arg(color_space)
  
  ##convert color space to HSV if RGB
  if(color_space == "RGB") {
    color_triplet <- as.data.frame(t(rgb2hsv(color_triplet[1], color_triplet[2], color_triplet[3])))
  }
  
  ##rescale hsv color triplet to match scales used in parsed color mapping
  if(scale) {
    h <- round(color_triplet[1] * 360)
    s <- round(color_triplet[2] * 100)
    v <- round(color_triplet[3] * 100)
  } else {
    h <- round(color_triplet[1])
    s <- round(color_triplet[2])
    v <- round(color_triplet[3])
  }
  
  if(eval(parse(text = parsed_conditional))) {
    is_color <- TRUE
  } else {
    is_color <- FALSE
  }
  
  return(is_color)
  
}