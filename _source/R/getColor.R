getColor <- function(color_triplet, parsed_conditional, scale = T, color_space = c("HSV", "RGB")) {
  
  ##check if valid color space
  color_space <- match.arg(color_space)
  
  ##convert color space to HSV if RGB
  if(color_space == "RGB") {
    color_triplet <- as.data.frame(t(rgb2hsv(color_triplet[1], color_triplet[2], color_triplet[3])))
  }
  
  ##rescale hsv color triplet to match scales used in parsed color mapping
  if(scale) {
    h <- color_triplet[1] * 360.00
    s <- color_triplet[2] * 100.00
    v <- color_triplet[3] * 100.00
  } else {
    h <- color_triplet[1]
    s <- color_triplet[2]
    v <- color_triplet[3]
  }
  
  if(eval(parse(text = parsed_conditional))) {
    is_color <- TRUE
  } else {
    is_color <- FALSE
  }
  
  return(is_color)
  
}