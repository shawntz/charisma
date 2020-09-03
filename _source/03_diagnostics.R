debugPlot <- function(path, colClasses, lowerR = 0.0, lowerG = 1.0, lowerB = 0.0,
                      upperR = 0.0, upperG = 1.0, upperB = 0.0, savePlots = FALSE, plotOutputDir = "debug_outputs", colorspace = "rgb")
{
  source_image <- colordistance::loadImage(path, lower = c(lowerR,lowerG,lowerB),
                                             upper = c(upperR,upperG,upperB), hsv = TRUE)
  img <- source_image$original.rgb
    
  current_par <- par()
  
  if(savePlots == TRUE)
  {
    #wd <- getwd()
    #ifelse(!dir.exists(file.path(wd, plotOutputDir)), dir.create(file.path(wd, plotOutputDir)), FALSE)
    ifelse(!dir.exists(plotOutputDir), dir.create(plotOutputDir), FALSE)
    
    if(Sys.info()['sysname'] != "Windows")
    {
      cat(paste0("\nSaving debug plot for: ", tail(strsplit(path, "/")[[1]], 1), " as: ", paste0("debug_", tail(strsplit(path, "/")[[1]], 1))))
      png(paste0(plotOutputDir,"/debug_", tail(strsplit(path, "/")[[1]], 1)), width = 750, height = 500)
    }
    else
    {
      cat(paste0("\nSaving debug plot for: ", tail(strsplit(path, "\\\\")[[1]], 1), " as: ", paste0("debug_", tail(strsplit(path, "\\\\")[[1]], 1))))
      png(paste0(plotOutputDir,"/debug_", tail(strsplit(path, "\\\\")[[1]], 1)), width = 750, height = 500)
    }
  }
  
  par(mfrow = c(1,2), mar = rep(1, 4) + 0.1)
  asp <- dim(img)[1] / dim(img)[2]
  
  plot(0:1, 0:1, type = "n", axes = FALSE, asp = asp, xlab = "", ylab = "")
  
  #panel 1: original image
  if(Sys.info()['sysname'] != "Windows")
  {
    title(paste("\nDebug mode: \nImg: ", tail(strsplit(path, "/")[[1]], 1)))
  }
  else
  {
    title(paste("\nDebug mode: \nImg: ", tail(strsplit(path, "\\\\")[[1]], 1)))
  }
  rasterImage(img, 0, 0, 1, 1)
  
  #panel 2: k-values
  if(colorspace == "rgb")
  {
    hex_values <- apply(colClasses, 1, function(x) rgb(x[1], x[2], x[3]))
  }
  else if(colorspace == "hsv")
  {
    hex_values <- apply(colClasses, 1, function(x) hsv(x[1], x[2], x[3]))
  }
  else
  {
    stop("Invalid color space provided! Must be either 'rgb' or 'hsv'.")
  }
  
  num_colors <- length(hex_values)
  bar_heights <- rep((1/num_colors), length(hex_values))
  x_values <- seq(1:length(hex_values))
  barplot(bar_heights, col = hex_values, axes = F, space = 0, border = NA, horiz = F)
  title(paste0("(k = ", num_colors, ") colors identified in [", colorspace, "]"))
  text((x_values-0.5), (bar_heights/2), labels = paste0((round(colClasses[,4], digits = 2) * 100),"%"))
  
  if (savePlots == TRUE)
  {
    dev.off()
  }
  
  par(mfrow = current_par$mfrow, mar = current_par$mar)
  
}