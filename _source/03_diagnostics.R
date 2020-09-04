diagnosticPlot <- function(path, colClasses, lowerR = 0.0, lowerG = 1.0, lowerB = 0.0,
                      upperR = 0.0, upperG = 1.0, upperB = 0.0, mode = "lower", thresh = .05, 
                      method = "GE", savePlots = FALSE, plotOutputDir = "diagnostic_outputs", width = 750, height = 500, 
                      colorspace = "rgb", colorwheel = FALSE)
{
  source_image <- colordistance::loadImage(path, lower = c(lowerR,lowerG,lowerB),
                                             upper = c(upperR,upperG,upperB), hsv = TRUE)
  img <- source_image$original.rgb
    
  current_par <- par()
  
  #step 1: swatch plots
  if(savePlots == TRUE)
  {
    #wd <- getwd()
    #ifelse(!dir.exists(file.path(wd, plotOutputDir)), dir.create(file.path(wd, plotOutputDir)), FALSE)
    ifelse(!dir.exists(plotOutputDir), dir.create(plotOutputDir), FALSE)
    
    if(Sys.info()['sysname'] != "Windows")
    {
      cat(paste0("\nSaving diagnostic plot for: ", tail(strsplit(path, "/")[[1]], 1), " as: ", paste0("diagnostic_", tail(strsplit(path, "/")[[1]], 1))))
      png(paste0(plotOutputDir,"/diagnostic_", tail(strsplit(path, "/")[[1]], 1)), width = width, height = height)
    }
    else
    {
      cat(paste0("\nSaving diagnostic plot for: ", tail(strsplit(path, "\\\\")[[1]], 1), " as: ", paste0("diagnostic_", tail(strsplit(path, "\\\\")[[1]], 1))))
      png(paste0(plotOutputDir,"/diagnostic_", tail(strsplit(path, "\\\\")[[1]], 1)), width = width, height = height)
    }
  }
  
  par(mfrow = c(1,2), mar = rep(1, 4) + 0.1)
  asp <- dim(img)[1] / dim(img)[2]
  
  plot(0:1, 0:1, type = "n", axes = FALSE, asp = asp, xlab = "", ylab = "")
  
  #panel 1: original image
  if(Sys.info()['sysname'] != "Windows")
  {
    title(paste("\nDiagnostic mode: \nImg: ", tail(strsplit(path, "/")[[1]], 1)))
  }
  else
  {
    title(paste("\nDiagnostic mode: \nImg: ", tail(strsplit(path, "\\\\")[[1]], 1)))
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
  if(mode == "lower")
  {
    title(paste0("(k = ", num_colors, ") colors identified in [", colorspace, "]"), sub = paste0("using [", mode, "] mode with a ", mode, "threshold of: ", method, thresh, "."))
  }
  else if(mode == "upper")
  {
    title(paste0("(k = ", num_colors, ") colors identified in [", colorspace, "]"), sub = paste0("using [", mode, "] mode with a cumulative diversity ", mode, "threshold of: <= ", thresh, "."))
  }
  text((x_values-0.5), (bar_heights/2), labels = paste0((round(colClasses[,4], digits = 2) * 100),"%"))
  
  if (savePlots == TRUE)
  {
    dev.off()
  }
  
  par(mfrow = current_par$mfrow, mar = current_par$mar)

  #step 2: color wheel plots
  if(colorwheel == TRUE)
  {
    for(hex in 1:length(hex_values))
    {
      if(savePlots == TRUE)
      {
        if(Sys.info()['sysname'] != "Windows")
        {
          cat(paste0("\nSaving color wheel plot (", hex, "/", length(hex_values), ") for:", tail(strsplit(path, "/")[[1]], 1), " as: ", paste0("diagnostic_", tail(strsplit(path, "/")[[1]], 1))))
          png(paste0(plotOutputDir, "/diagnostic_colorwheel_", hex, "_" tail(strsplit(path, "/")[[1]], 1)), width = width, height = height)
        }
        else {
          cat(paste0("\nSaving color wheel plot (", hex, "/", length(hex_values), ") for:", tail(strsplit(path, "\\\\")[[1]], 1), " as: ", paste0("diagnostic_", tail(strsplit(path, "\\\\")[[1]], 1))))
          png(paste0(plotOutputDir, "/diagnostic_colorwheel_", hex, "_" tail(strsplit(path, "\\\\")[[1]], 1)), width = width, height = height)
        }
      }

      hsv_converted <- hex2hsv(hex)
      
      if(Sys.info()['sysname'] != "Windows")
      {
        colorwheel_plot <- plotColorWheel(hsv_converted, title = paste0("Color Wheel Diagnostic: ", tail(strsplit(path, "/")[[1]], 1)))
      }
      else
      {
        colorwheel_plot <- plotColorWheel(hsv_converted, title = paste0("Color Wheel Diagnostic: ", tail(strsplit(path, "\\\\")[[1]], 1)))
      }

      colorwheel_plot

      if(savePlots == TRUE)
      {
        dev.off()
      }
    }
  }
}

plotColorWheel <- function(hsv_color_row, title = "Color Wheel Diagnostic Plot")
{
  #adapted from https://stackoverflow.com/questions/21490210/how-to-plot-a-colour-wheel-by-using-ggplot
  d <- expand.grid(h = seq(0,1,0.01), s = seq(0,1,0.05), v = hsv_color_row$v)

  p <- ggplot() +
    coord_polar(theta="x") +
    scale_x_continuous(breaks=NULL) +
    scale_y_continuous(breaks=NULL) +
    scale_fill_identity() +
    geom_rect(data = d, mapping = aes(xmin = h, xmax = h + resolution(h),
                                      ymin = s, ymax = h + resolution(s),
                                      fill = hsv(h,s,v))) +
    annotate("point", x = hsv_color_row$h, y = hsv_color_row$s, colour = "black", shape = 18) +
    labs(title = title, subtitle = paste0("(h=", hsv_color_row$h, ", s=", hsv_color_row$s, ", v=", hsv_color_row$v, ")")) +
    theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.position="none",
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank())

  return(p)
}