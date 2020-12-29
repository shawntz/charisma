getImages <- function(path)
{
  return(colordistance::getImagePaths(path))
}

downsampleImage <- function(img, loc, scale = scale_value)
{
  pic <- magick::image_read(img)
  pic_dnsmpl <- magick::image_scale(magick::image_scale(pic, paste0(scale,"%")), paste0(scale,"%"))
  #pic_dnsmpl <- magick::image_scale(pic, "x100")
  magick::image_write(pic_dnsmpl, file.path(loc, basename(img)))
}

rgb2hex <- function(r, g, b)
{
  return(rgb(r, g, b, maxColorValue = 255))
}

hex2rgb <- function(hex)
{
  return(t(col2rgb(hex)))
}