getImages <- function(path)
{
  return(colordistance::getImagePaths(path))
}

getHist <- function(img, bins = 3, plotting = FALSE, 
                    lowerR = 0.0, lowerG = 1.0, lowerB = 0.0,
                    upperR = 0.4, upperG = 1.0, upperB = 0.0, colorspace = "rgb")
{
  #check if valid image
  if(!file.exists(img))
  {
    stop("Specified image not found.")
  }
  else
  {
    if(Sys.info()['sysname'] != "Windows")
    {
      cat(paste0("\nAnalyzing: ", tail(strsplit(img, "/")[[1]], 1)))
    } 
    else
    {
      cat(paste0("\nAnalyzing: ", tail(strsplit(img, "\\\\")[[1]], 1)))  
    }
    
    if(colorspace == "rgb")
    {
      return(suppressMessages(colordistance::getImageHist(img, bins = bins, plotting = plotting,
                                                          lower = c(lowerR,lowerG,lowerB),
                                                          upper = c(upperR,upperG,upperB))))
    }
    else if(colorspace == "hsv")
    {
      return(suppressMessages(colordistance::getImageHist(img, bins = bins, plotting = plotting,
                                                          lower = c(lowerR,lowerG,lowerB),
                                                          upper = c(upperR,upperG,upperB), hsv = TRUE)))
    }
    else
    {
      stop("Invalid color space provided! Must be either 'rgb' or 'hsv'.")
    }
  }
  
}

hex2hsv <- function(hex_vec)
{
  hsv_out <- data.frame(h = numeric(), s = numeric(), v = numeric())
  for(color in hex_vec)
  {
    hsv_out <- hsv_out %>%
      rbind(t(rgb2hsv(col2rgb(color))))
  }
  return(hsv_out)
}