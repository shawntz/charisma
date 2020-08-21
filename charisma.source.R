#################################################################
##                       charisma source                       ##
##                    ('charisma.source.R')                    ##
#################################################################

### @Author: Shawn T. Schwartz
### @Email: <shawnschwartz@ucla.edu>
### @Description: Source functions for charisma (automatic detection of color classes)
### @Acknowledgements: Thank you to Hannah Weller, Brown University, for helpful insights and 
###   discussions regarding the methodology and functionality behind our approach presented here.

#################################################################
##                       Setup Workspace                       ##
#################################################################

#################################################################
##                       Launch charisma                       ##
#################################################################
cat("Loading charisma...\n")

##################################################################
##                  Install Required Libraries                  ##
##################################################################
required_libraries <- c("colordistance", "pavo", "tidyverse", "plyr", "optparse")
if(length(setdiff(required_libraries, rownames(installed.packages()))) > 0)
{
  install.packages(setdiff(required_libraries, rownames(installed.packages())))
}

#################################################################
##                   Load Required Libraries                   ##
#################################################################
for(libs in required_libraries)
{
  eval(bquote(library(.(libs))))
}

cat("Finished loading charisma!")

############################################################################
############################################################################
###                                                                      ###
###                           HELPER FUNCTIONS                           ###
###                                                                      ###
############################################################################
############################################################################
getImages <- function(path)
{
  return(colordistance::getImagePaths(path))
}

getHist <- function(img, bins = 3, plotting = FALSE, 
                    lowerR = 0.0, lowerG = 1.0, lowerB = 0.0,
                    upperR = 0.4, upperG = 1.0, upperB = 0.0)
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
      cat(paste0("\nAnalyzing: ", tail(strsplit(img, "/")[[1]], 1)),"\n")
    } 
    else
    {
      cat(paste0("\nAnalyzing: ", tail(strsplit(img, "\\\\")[[1]], 1)),"\n")  
    }
    return(colordistance::getImageHist(img, bins = bins, plotting = plotting,
                                       lower = c(lowerR,lowerG,lowerB),
                                       upper = c(upperR,upperG,upperB)))
  }
  
}

extractColorClasses <- function(hist, thresh = .05, method = "GE")
  #methods => "GE": "greater than or equal to", "G": "greather than only"
{
  col_classes <- data.frame(r=numeric(), g=numeric(), b=numeric(), Pct=numeric())
  for(bin in nrow(hist):1)
  {
    if(method == "GE")
    {
      if(hist$Pct[bin] >= thresh)
      {
        col_classes <- hist[bin,] %>%
          rbind(col_classes)
      }
    }
    else if(method == "G")
    {
      if(hist$Pct[bin] > thresh)
      {
        col_classes <- hist[bin,] %>%
          rbind(col_classes)
      }
    }
  }
  return(col_classes)
}

getNumColorClasses <- function(extracted_colors)
{
  return(nrow(extracted_colors))
}

debugPlot <- function(path, colClasses, lowerR = 0.0, lowerG = 1.0, lowerB = 0.0,
                      upperR = 0.0, upperG = 1.0, upperB = 0.0, savePlots = FALSE, plotOutputDir = "debug_outputs")
{
  source_image <- colordistance::loadImage(path, lower = c(lowerR,lowerG,lowerB),
                                           upper = c(upperR,upperG,upperB))
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
  rgb_hex_values <- apply(colClasses, 1, function(x) rgb(x[1], x[2], x[3]))
  num_colors <- length(rgb_hex_values)
  bar_heights <- rep((1/num_colors), length(rgb_hex_values))
  x_values <- seq(1:length(rgb_hex_values))
  barplot(bar_heights, col = rgb_hex_values, axes = F, space = 0, border = NA, horiz = F)
  title(paste0("(k = ", num_colors, ") colors identified"))
  text((x_values-0.5), (bar_heights/2), labels = paste0((round(colClasses[,4], digits = 2) * 100),"%"))
  
  if (savePlots == TRUE)
  {
    dev.off()
  }
  
  par(mfrow = current_par$mfrow, mar = current_par$mar)
  
}

#################################################################
##           Color Classification Pipeline Functions           ##
##    Adapted from Alfaro, Karan, Schwartz, & Shultz (2019)    ##
#################################################################
classifyByUniqueK <- function(path, kdf)
{
  image_paths <- kdf$img
  images_list <- rep(NA, length(image_paths))
  for(image in 1:length(images_list))
  {
    if(Sys.info()['sysname'] != "Windows")
    {
      images_list[image] <- tail(strsplit(image_paths[image], "/")[[1]], 1)
    }
    else
    {
      images_list[image] <- tail(strsplit(image_paths[image], "\\\\")[[1]], 1)
    }
  }
  
  classifications <- list()
  
  for(image in 1:length(images_list))
  {
    pic <- pavo::getimg(file.path(path, images_list[image]), max.size = 3)
    cat(paste0("Image (", image, "/", length(images_list),"): ", images_list[image], 
               " with (k = ", kdf$k[image], ")\n"))
    classifications[[image]] <- pavo::classify(pic, kcols = kdf$k[image])
    cat("\n")
  }
  
  names(classifications) <- images_list
  return(classifications)
}

rgbEucDist <- function(rgb_table_altered, c1, c2) 
{
  euc_dist <- sqrt((rgb_table_altered[c1,"col1"]-rgb_table_altered[c2,"col1"])^2+(rgb_table_altered[c1,"col2"]-rgb_table_altered[c2,"col2"])^2) %>%
    .[1,1]
  return(euc_dist)
}

rgbLumDist <- function(rgb_table_altered, c1, c2)
{
  lum_dist <- sqrt((rgb_table_altered[c1,"lum"]-rgb_table_altered[c2,"lum"])^2) %>%
    .[1,1]
  return(lum_dist)
}

#input is a single classified image
calcEucLumDists <- function(classified_image)
{
  #extract RGB values for n colors
  class_rgb <- attr(classified_image, 'classRGB')
  class_rgb_altered <- class_rgb %>%
    rownames_to_column(var = "col_num") %>%
    as_tibble %>%
    mutate(col1 = (R-G)/(R+G), col2 = (G-B)/(G+B), lum = R+G+B) %>%
    select(col1, col2, lum)
  
  #create a matrix to hold colors based on the number of possible color comparisons
  euc_dists <- matrix(nrow=choose(nrow(class_rgb),2),ncol=4)
  
  combos_simple <- t(combn(rownames(class_rgb),2)) %>%
    as_tibble %>%
    transmute(c1 = as.numeric(V1), c2 = as.numeric(V2)) %>%
    as.data.frame()
  
  combos <- matrix(nrow=nrow(combos_simple),ncol=4)
  for(i in 1:nrow(combos_simple))
  {
    combos[i,1] <- combos_simple[i,1]
    combos[i,2] <- combos_simple[i,2]
    combos[i,3] <- rgbEucDist(class_rgb_altered,combos_simple[i,1],combos_simple[i,2])
    combos[i,4] <- rgbLumDist(class_rgb_altered,combos_simple[i,1],combos_simple[i,2])
  }
  
  combos <- combos %>%
    as.data.frame %>%
    as_tibble %>%
    dplyr::rename(c1 = V1,
                  c2 = V2,
                  dS = V3,
                  dL = V4) %>%
    as.data.frame
  
  return(combos)
}

#get distance data frame for each picture
getImgClassKDists <- function(classifications, euclidean_lum_dists) 
{
  return(map(.x=classifications,.f=euclidean_lum_dists))
}

#calculate the adjacency stats for each image, using the calculated distances as proxies for dS and dL
getAdjStats <- function(classifications, img_class_k_dists, xpts=100, xscale=100) 
{
  adj_k_dists_list <- list()
  
  for(i in 1:length(classifications)) 
  {
    adj_k_dists_list[[i]] <- adjacent(classimg = classifications[[i]],coldists=img_class_k_dists[[i]],xpts=xpts,xscale=xscale)
  }
  
  return(adj_k_dists_list)
}

#clean up and select relevant stats
getCleanedupStats <- function(adj_k_dists_list) 
{
  img_adj_k_dists <- Reduce(rbind.fill,adj_k_dists_list) %>%
    rownames_to_column(var = "name") %>%
    as_tibble()
  
  img_adj_k_dists_select <- img_adj_k_dists %>%
    dplyr::select(name,m,m_r,m_c,A,Sc,St,Jc,Jt,m_dS,s_dS,cv_dS,m_dL,s_dL,cv_dL)
  
  return(img_adj_k_dists_select)
}

############################################################################
############################################################################
###                                                                      ###
###                        MAIN WRAPPER FUNCTIONS                        ###
###                                                                      ###
############################################################################
############################################################################
autoComputeKPipeline <- function(path, bins = 3, debugMode = FALSE, 
                     lowerR = 0.0, lowerG = 0.0, lowerB = 0.0,
                     upperR = 0.0, upperG = 0.0, upperB = 0.0,
                     thresh = .05, method = "GE", rgbOut = FALSE, rgbOutPath = "./",
                     saveDebugPlots = FALSE, debugPlotsOutputDir = "debug_outputs")
{
  images <- getImages(path)
  images_names <- rep(NA, length(images))
  hist_list <- list()
  color_classes_list <- list()
  k_values <- rep(NA, length(images))
  
  for(ii in 1:length(images))
  {
    hist_list[[ii]] <- getHist(images[ii], bins = bins, plotting = FALSE,
                          lowerR = lowerR, lowerG = lowerG, lowerB = lowerB,
                          upperR = upperR, upperG = upperG, upperB = upperB)
    if(Sys.info()['sysname'] != "Windows")
    {
      images_names[ii] <- tail(strsplit(images[ii], "/")[[1]], 1)
    }
    else
    {
      images_names[ii] <- tail(strsplit(images[ii], "\\\\")[[1]], 1)
    }
  }
  
  for(ii in 1:length(hist_list))
  {
    color_classes_list[[ii]] <- extractColorClasses(hist_list[[ii]], thresh = thresh, method = method)
  }
  names(color_classes_list) <- images_names
  
  for(ii in 1:length(color_classes_list))
  {
    k_values[ii] <- getNumColorClasses(color_classes_list[[ii]])
  }
  
  if(debugMode == TRUE)
  {
    for(ii in 1:length(images))
    {
      debugPlot(images[ii], color_classes_list[[ii]], lowerR = lowerR, lowerG = lowerG, lowerB = lowerB,
                upperR = upperR, upperG = upperG, upperB = upperB, 
                savePlots = saveDebugPlots, plotOutputDir = debugPlotsOutputDir)
    }
  }
  
  color_class_data <- data.frame(img = images, k = k_values)
  
  if(rgbOut == TRUE)
  {
    cat("\nSaving k RGB values to RDS file...")
    saveRDS(color_classes_list, paste0(rgbOutPath, "rgb_values_output.RDS"))
    cat("Successfully saved k RGB values to RDS file!\n")
  }
  
  return(color_class_data)
}

classifyColorPipeline <- function(path, kdf)
{
  classifications <- classifyByUniqueK(path, kdf)
  classified_k_dists <- getImgClassKDists(classifications, calcEucLumDists)
  adj_stats_raw <- getAdjStats(classifications, classified_k_dists, 100, 100)
  adj_stats <- getCleanedupStats(adj_stats_raw)
  
  image_paths <- kdf$img
  images_list <- rep(NA, length(image_paths))
  for(image in 1:length(images_list))
  {
    if(Sys.info()['sysname'] != "Windows")
    {
      images_list[image] <- tail(strsplit(image_paths[image], "/")[[1]], 1)
    }
    else
    {
      images_list[image] <- tail(strsplit(image_paths[image], "\\\\")[[1]], 1)
    }
  }
  
  adj_stats <- adj_stats %>%
    mutate(name = images_list)
  
  return(adj_stats)
}

runColorPCA <- function(adj_stats)
{
  pca_input <- select(adj_stats, name, m, m_r, m_c, Sc, St, A, m_dS,m_dL) %>% as.data.frame %>%
    column_to_rownames("name")
  pca_res <- prcomp(pca_input, center = T, scale = T)
  return(pca_res)
}

getColorPCASummary <- function(pca_res)
{
  return(summary(pca_res))
}
